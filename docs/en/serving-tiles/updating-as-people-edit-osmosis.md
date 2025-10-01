---
layout: docs
title: Updating your database as people edit OpenStreetMap
lang: en
---

# Updating your database as people edit OpenStreetMap using Osmosis

Every day there are millions of new map updates so to prevent a map becoming "stale" you can refresh the data used to create map tiles regularly.

If you're using a recent version of osm2pgsql (version 1.4.2 or above) then you may be able to follow the [new](/serving-tiles/updating-as-people-edit-osm2pgsql-replication.md) instructions. Those are especially useful if you want to use an update source that exactly matches your download area (for example, Geofabrik can provide daily updates for their download areas). If using `osm2pgsql` for replication is not an option for you, read on...

Here, we'll use `osmosis` for this, which will also install Java. `osmosis` is a general-purpose OSM data utility, and one of the things that it can do is to update a database with recent changes from OSM. Other options are available, such as `osmium`.

```sh
sudo apt install osmosis
```

(that'll eventually say "done.")

We'll use `trim_osc.py` from Zverik's "regional" scripts to trim down the updates from OpenStreetMap.org down to just the area that we're interested in. We do this so that the postgres database doesn't grow significantly as updates are applied to it. We will also need to fetch some dependencies for that.

```sh
cd ~/src
git clone https://github.com/zverik/regional
chmod u+x ~/src/regional/trim_osc.py

sudo apt install python3-shapely python3-lxml
```

If you have followed the Ubuntu instructions, you'll already have the scripts needed for the next part. For Debian, you'll need to fetch those manually:

```sh
cd ~/src
git clone -b switch2osm https://github.com/SomeoneElseOSM/mod_tile.git
cd mod_tile
```

The `openstreetmap-tiles-update-expire` script is what will be used to fetch updates from OpenStreetMap. In there is:

```sh
TRIM_REGION_OPTIONS="-b -14.17 48.85 2.12 61.27"
```

That corresponds roughly to the UK; you may want to edit it to contain different values. You can also use a `.poly` file to define the boundary.

Also in there is:

```sh
ACCOUNT=renderaccount
```

That will need to be changed to whatever is the non-root username below which the `mod_tile` and "regional" source exists. On Debian 11 it will be different to the account that you are rendering tiles as.

Also make sure that the script does NOT contain `-e$EXPIRY_METAZOOM:$EXPIRY_METAZOOM`. If it does, change the `:` to a `-`: `-e$EXPIRY_METAZOOM-$EXPIRY_METAZOOM`.

Something else to consider is that you'll probably want to edit the OSM2PGSQL_OPTIONS to refer to the lua tag transform script that you used when loading the database, and the `.style` file that determines what columns are created. There may be other parameters that you need to pass here too depending on what you used when creating the database. Change `/path/to/` to the actual path, of course:

```sh
OSM2PGSQL_OPTIONS="-d $DBNAME --tag-transform-script /path/to/src/openstreetmap-carto/openstreetmap-carto.lua -S /path/to/src/openstreetmap-carto/openstreetmap-carto.style"
```

Next, we'll create the log directory for tile expiry logs, and change the ownership to the username used for rendering tiles (for Debian 11, this will be `_renderd`). The script must also be run as this account, and because this account may be different to where the software is downloaded, we'll pass the complete location of the script - modify `/path/to` to whatever is correct.

The parameter passed to `openstreetmap-tiles-update-expire` should be the age of the data originally loaded. If you downloaded data from Geofabrik it should be what the "and contains all OSM data up" date was on e.g. <http://download.geofabrik.de/asia/azerbaijan.html>{: target=_blank} when you downloaded the data.

```sh
sudo mkdir /var/log/tiles
sudo chown renderaccount /var/log/tiles
sudo -u renderaccount /path/to/src/mod_tile/openstreetmap-tiles-update-expire 2020-11-14T21:42:02Z
```

The last line of the output that you get should look something like

```log
2020-11-15 23:50:16 (2.62 MB/s) - ‘/var/lib/mod_tile/.osmosis/state.txt’ saved [342/342]
```

That has created a directory `.osmosis` in `/var/lib/mod_tile` with details of the last imported data.

On one ssh session to the server run:

```sh
tail -f /var/log/tiles/run.log
```

On another run:

```sh
sudo -u renderaccount /path/to/src/mod_tile/openstreetmap-tiles-update-expire
```

modifying that like with the correct account and path as was done previously; but this time with no parameter.

If you see a message like:

```log
openstreetmap-tiles-update-expire: 1: python: not found
```

don't worry - this is just a disk space check.

The output into the log file should be something like:

```log
[2020-11-15 23:58:28] 3850 start import from seq-nr 4283484, replag is 1 day(s) and 2 hour(s)
[2020-11-15 23:58:28] 3850 downloading diff
[2020-11-15 23:59:31] 3850 filtering diff
[2020-11-15 23:59:58] 3850 importing diff
[2020-11-16 00:01:23] 3850 expiring tiles
[2020-11-16 00:01:23] 3850 Done with import
```

The `replag` value shown is the replication lag; by default, an hours-worth of data is taken in at a time. If this doesn't work properly, check that `osmosis` is correctly installed, and you can run it from the command line.

Run `openstreetmap-tiles-update-expire` again in the same way; you should see that `replag` is an hour less than it was.

Next, we'll set up `openstreetmap-tiles-update-expire` in crontab to run every few minutes. We'll want this to run from the crontab of the user that does the rendering, so on Debian 11 we'll need to do this:

```sh
sudo -u _renderd crontab -e
```

You may see a message "problems with history file" - don't worry if you do. On non-Debian 11 systems, we will probably be able to run `crontab -e` directly from the username that is rendering tiles. The first time you run `crontab -e` you may be asked to choose an editor. Go down to the end of the file. Lines starting with `#` are comments. The last comment line is:

```sh
# m h  dom mon dow   command
```

These fields are `m` – "minutes", `h` –"hours", `dom` – "day of month", `mon` – "month", `dow` – "day of week" and `command`. We'll add the following line:

```sh
*/5  * *   *   *     /home/renderaccount/src/mod_tile/openstreetmap-tiles-update-expire
```

so that the script runs every 5 minutes. Replace `renderaccount` with the username below which the script is located. Monitor the output with `tail -f /var/log/tiles/run.log` and wait 5 minutes. Eventually it'll catch up, and new edits to OpenStreetMap will appear in your tiles too.

## Potential Problems with updates

If an error such as "Expiry failed" appears in `/var/log/tiles/run.log` then the likely problem is that `render_expired`, one of the programs called from within there, has run out of memory. If that is the case, reduce `EXPIRY_MAXZOOM` in the script until it works. You can get more details about what has gone wrong from the other files in `/var/log/tiles/`.

If an error such as "rm: cannot remove '/var/lib/mod_tile/dirty_tiles.6877':" occurs, it might mean that `osm2pgsql` failed, and it didn't produce a list of dirty tiles at the end of its run. The location of the logfile it creates is higher up in the script. By default, it is `/var/log/tiles/osm2pgsql.log`, and if you look in there you should see the actual error.

## Configuring munin

If you are using munin to report on `mod_tile` and `renderd` activity, you can configure it to display the database replication lag by looking at the `state.txt` file:

```sh
sudo nano /etc/munin/plugins/replication_delay
```

You can obtain the contents of the script from [here](https://raw.githubusercontent.com/SomeoneElseOSM/mod_tile/switch2osm/munin/replication_delay_osmosis){: target=_blank}. You may need to edit that so the the correct file location is used (typically either `/var/cache/renderd` or `/var/lib/mod_tile`). Then:

```sh
sudo /etc/init.d/munin-node restart
```

Shortly after doing that, `http://your.server.address/munin/renderd-day.html` should show a "Data import lag" graph. If it doesn't, look at the logs in `/var/log/munin`. If you need more help to understand what is going wrong, have a look [here](https://guide.munin-monitoring.org/en/latest/develop/plugins/howto-write-plugins.html){: target=_blank}.

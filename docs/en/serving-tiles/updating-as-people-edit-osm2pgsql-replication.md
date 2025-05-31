---
layout: docs
title: Updating your database as people edit OpenStreetMap
lang: en
---

# Updating your database as people edit OpenStreetMap using osm2pgsql

Every day there are millions of new map updates, so to prevent a map becoming "stale" you can refresh the data used to create map tiles regularly.

Using `osm2pgsql` (version 1.4.2 or above) it's now much easier to do this than it was previously. Version 1.6.0 is distributed as part of Ubuntu 22.04; version 1.8.0 as part of Debian 12; version 1.11.0 as part of Ubuntu 24.04, and it can also be obtained by following [these instructions](https://osm2pgsql.org/doc/install.html){: target=_blank}. With `osm2pgsql` comes [osm2pgsql-replication](https://osm2pgsql.org/doc/manual.html#updating-an-existing-database){: target=_blank} - that provides a relatively simple way to keep a database up to date. A more flexible approach is to call `PyOsmium` directly - see [this guide](/serving-tiles/updating-as-people-edit-pyosmium.md) for how to do that.

It's possible to set up replication from many different sources. OpenStreetMap itself provides minutely, hourly and daily updates, and other sources such as Geofabrik can provide daily updates that match the regional data extracts available at [download.geofabrik.de](http://download.geofabrik.de/index.html){: target=_blank}.

## A worked example using Geofabrik data

In this example we'll download the data for London from Geofabrik, load a database with it, and then set up updates to it. The updates from Geofabrik will be limited to the region that you have downloaded and will be made available once per day.

First, from whichever non-root account you are using, download the data:

```sh
# if it doesn't already exist
mkdir ~/data
cd ~/data
wget http://download.geofabrik.de/europe/great-britain/england/greater-london-latest.osm.pbf
```

Next, load the database. The numbers here for processes and memory can be varied to match the system being used:

```sh
sudo -u _renderd \
    osm2pgsql -d gis --create --slim  -G --hstore \
    --tag-transform-script \
        ~/src/openstreetmap-carto/openstreetmap-carto.lua \
    -C 3000 --number-processes 4 \
    -S ~/src/openstreetmap-carto/openstreetmap-carto.style \
    ~/data/greater-london-latest.osm.pbf
```

Important note - the tile expiry script used below assumes that tiles are written below `/var/cache/renderd/`. If `/etc/renderd.conf` specifies another location, you'll need to modify it before expiring tiles using the scripts you're going to create here.

Then, initialise replication. As described [here](https://osm2pgsql.org/doc/manual.html#updating-an-existing-database){: target=_blank} files downloaded from Geofabrik (and [download.openstreetmap.fr](https://download.openstreetmap.fr/){: target=_blank}) contain all the information needed for replication (the URL from which to download updates and what date to start from).

```sh
sudo -u _renderd \
    osm2pgsql-replication init \
    -d gis \
    --osm-file ~/data/greater-london-latest.osm.pbf
```

That produces output something like this:

```log
2022-04-24 23:32:42 [INFO]: Initialised updates for service 'http://download.geofabrik.de/europe/great-britain/england/greater-london-updates'.
2022-04-24 23:32:42 [INFO]: Starting at sequence 3314 (2022-04-23 20:21:53+00:00).
```

In this example, the date shown there corresponds to the date visible [on this page](http://download.geofabrik.de/europe/great-britain/england/greater-london.html){: target=_blank} when the data was downloaded.

### Creating scripts to apply updates

Next, we'll create somewhere for expiry logfiles to be written and scripts to apply any pending updates and expire any affected tiles. When we expire a tile we can rerender it, mark it as `dirty`, or delete it.

```sh
sudo mkdir /var/log/tiles
sudo chown _renderd /var/log/tiles
sudo nano /usr/local/sbin/expire_tiles.sh
```

An example of this script would be something like this:

```sh title="expire_tiles.sh"
#!/bin/bash
render_expired --map=s2o --min-zoom=13 --max-zoom=20 \
    -s /run/renderd/renderd.sock < /var/cache/renderd/dirty_tiles.txt
rm /var/cache/renderd/dirty_tiles.txt
```

The `dirty` tile list needs to be writable by the `_renderd` account that we will run this script from. See the [man page](https://manpages.ubuntu.com/manpages/jammy/en/man1/render_expired.1.html){: target=_blank} for possible settings for the other parameters. The example above will try and rerender all `dirty` tiles from zoom level 13 upwards. A more realistic example would be something like:

```sh title="expire_tiles.sh"
#!/bin/bash
render_expired --map=s2o --min-zoom=13 --touch-from=13 --delete-from=19 --max-zoom=20 \
    -s /run/renderd/renderd.sock < /var/cache/renderd/dirty_tiles.txt
rm /var/cache/renderd/dirty_tiles.txt
```

which matches the [defaults](https://github.com/SomeoneElseOSM/mod_tile/blob/switch2osm/openstreetmap-tiles-update-expire#L58){: target=_blank} that the older osmosis scripts used - tiles up to zoom level 12 are ignored, tiles from zoom levels 13 to 19 are marked as `dirty` and zoom level 20 tiles are deleted. That example can also be found [here](https://github.com/SomeoneElseOSM/mod_tile/blob/switch2osm/expire_tiles.sh){: target=_blank}.

Next:

```sh
sudo nano /usr/local/sbin/update_tiles.sh
```

initially, this script should contain:

```sh title="update_tiles.sh"
#!/bin/bash
osm2pgsql-replication \
    update -d gis \
    --post-processing /usr/local/sbin/expire_tiles.sh \
    --max-diff-size 10  --  \
    -G --hstore \
    --tag-transform-script \
        /home/renderaccount/src/openstreetmap-carto/openstreetmap-carto.lua \
    -C 3000 --number-processes 4 \
    -S /home/renderaccount/src/openstreetmap-carto/openstreetmap-carto.style \
    --expire-tiles=1-20 \
    --expire-output=/var/cache/renderd/dirty_tiles.txt
```

Everything in the `osm2pgsql-replication update` line after `--` is passed as parameters to osm2pgsql - they will all need to match what the database was loaded with in the first place. Before the `--`, `-d gis` just defines what database we're using and `--max-diff-size 10` how much data to process at once, but note that `osm2pgsql-replication` will actually repeat downloading data and updating the database until there is no more to process, which may take some time. The `--max diff-size` determines how much data is fetched on each iteration. The `--post-processing /usr/local/sbin/expire_tiles.sh` just calls our other script.

Make both scripts executable:

```sh
sudo chmod ugo+x /usr/local/sbin/update_tiles.sh
sudo chmod ugo+x /usr/local/sbin/expire_tiles.sh
```

### Making sure that you can see debug messages

It'd be really useful at this point to be able to see the output from the tile rendering process, to see that tiles marked as `dirty` are being processed. By default, with recent mod_tile versions, this is turned off. To turn it on:

```sh
sudo nano /usr/lib/systemd/system/renderd.service
```

If it is not there already, add:

```ini
Environment=G_MESSAGES_DEBUG=all
```

after "[Service]". Then:

```sh
sudo systemctl daemon-reload
sudo systemctl restart renderd
sudo systemctl restart apache2
```

### Testing

In another session:

```sh
sudo tail -f /var/log/syslog
```

or if you are using Debian 12, which does not have a "syslog" file by default:

```sh
sudo journalctl -ef
```

and you should now see some output corresponding to `mod_tile` requests.

Run the script once:

```sh
sudo -u _renderd /usr/local/sbin/update_tiles.sh
```

If there are no pending updates (Geofabrik updates for these files appear daily) then something like this will be shown:

```log
2023-07-02 16:57:03 [INFO]: Using replication service 'http://download.geofabrik.de/europe/britain-and-ireland-updates'. Current sequence 3743 (2023-07-01 20:21:30+00:00).
2023-07-02 16:57:03 [INFO]: Database already up-to-date.
```

If there are pending updates, then instead you will see something like:

```log
2022-06-05 16:29:32 [INFO]: Using replication service 'http://download.geofabrik.de/europe/great-britain/england/greater-london-updates'. Current sequence 3355 (2022-06-03 20:21:26+00:00).
2022-06-05 16:29:33  osm2pgsql version 1.6.0
2022-06-05 16:29:33  Database version: 14.3 (Ubuntu 14.3-0ubuntu0.22.04.1)
2022-06-05 16:29:33  PostGIS version: 3.2
2022-06-05 16:29:34  Setting up table 'planet_osm_point'
2022-06-05 16:29:34  Setting up table 'planet_osm_line'
2022-06-05 16:29:34  Setting up table 'planet_osm_polygon'
2022-06-05 16:29:34  Setting up table 'planet_osm_roads'
2022-06-05 16:29:51  Reading input files done in 17s.
2022-06-05 16:29:51    Processed 4267 nodes in 7s - 610/s
2022-06-05 16:29:51    Processed 1108 ways in 7s - 158/s
2022-06-05 16:29:51    Processed 4 relations in 3s - 1/s
2022-06-05 16:29:52  Going over 993 pending ways (using 4 threads)
Left to process: 0.....
2022-06-05 16:29:57  Processing 993 pending ways took 5s at a rate of 198.60/s
2022-06-05 16:29:57  Going over 129 pending relations (using 4 threads)
...
```

When there is a tile to expire, a line like this will appear:

```log
Read and expanded 42700 tiles from list.
render: file:///var/cache/renderd/tiles/s2o/18/17/245/244/200/0.meta
Read and expanded 42800 tiles from list.
```

at the end totals will be printed:

```log
Read and expanded 121200 tiles from list.
Read and expanded 121300 tiles from list.
Waiting for rendering threads to finish

Total for all tiles rendered
Meta tiles rendered: Rendered 1 tiles in 18.19 seconds (0.05 tiles/s)
Total tiles rendered: Rendered 64 tiles in 18.19 seconds (3.52 tiles/s)
Total tiles in input: 121357
Total tiles expanded from input: 10766
Total meta tiles deleted: 0
Total meta tiles touched: 0
Total tiles ignored (not on disk): 10765
2022-06-05 16:36:58 [INFO]: Data imported until 2022-06-04 20:21:41+00:00. Backlog remaining: 20:15:17.919969
```

In the log, output will include something like:

```log
Jun  5 16:36:40 ubuntuvm75 renderd[5838]: Data is available now on 1 fds
Jun  5 16:36:40 ubuntuvm75 renderd[5838]: Got incoming connection, fd 5, number 0, total conns 1, total slots 1
Jun  5 16:36:40 ubuntuvm75 renderd[5838]: Data is available now on 1 fds
Jun  5 16:36:40 ubuntuvm75 renderd[5838]: Got incoming request with protocol version 2
Jun  5 16:36:40 ubuntuvm75 renderd[5838]: Got command RenderBulk fd(5) xml(s2o), z(18), x(131008), y(87168), mime(image/png), options()
Jun  5 16:36:40 ubuntuvm75 renderd[5838]: START TILE s2o 18 131008-131015 87168-87175, age 0.04 days
Jun  5 16:36:40 ubuntuvm75 renderd[5838]: Rendering projected coordinates 18 131008 87168 -> -9783.939621|6710559.587216 -8560.947168|6711782.579668 to a 8 x 8 tile
Jun  5 16:36:58 ubuntuvm75 renderd[5838]: DONE TILE s2o 18 131008-131015 87168-87175 in 18.046 seconds
Jun  5 16:36:58 ubuntuvm75 renderd[5838]: Creating and writing a metatile to /var/cache/renderd/tiles/s2o/18/17/245/244/200/0.meta
Jun  5 16:36:58 ubuntuvm75 renderd[5838]: Sending message Done to 5
Jun  5 16:36:58 ubuntuvm75 renderd[5838]: Sending render cmd(3 s2o 18/131008/87168) with protocol version 2 to fd 5
Jun  5 16:36:58 ubuntuvm75 renderd[5838]: Data is available now on 1 fds
Jun  5 16:36:58 ubuntuvm75 renderd[5838]: Failed to read cmd on fd 5
Jun  5 16:36:58 ubuntuvm75 renderd[5838]: Connection 0, fd 5 closed, now 0 left, total slots 1
```

### Running every day

The script to perform the update can be added to root's crontab. First, amend `update_tiles.sh` to do some error checking at startup, and to append a summary to a logfile only. You can get a copy of that from [here](https://github.com/SomeoneElseOSM/mod_tile/blob/switch2osm/update_tiles.sh){: target=_blank}. Again, change `renderaccount` to the name of whatever non-root account you are using here. You can also adjust the number of threads and the amount of memory cache used.

Then add to root's crontab:

```sh
04 04  *   *   *     sudo -u _renderd /usr/local/sbin/update_tiles.sh
```

This example runs once per day at 04:04 every morning. There's no point in running it more than once per day, since Geofabrik updates are only released daily.

## Using minutely updates from openstreetmap.org

Updates are also available from openstreetmap.org. These are for anything anywhere in the world, and will therefore be larger than a set of updates for the same time period for a region from e.g. Geofabrik. To set this up

```sh
sudo -u _renderd \
    osm2pgsql-replication init -d gis  \
    --server https://planet.openstreetmap.org/replication/minute
```

that will return something like

```log
2022-06-05 20:49:21 [INFO]: Initialised updates for service 'https://planet.openstreetmap.org/replication/minute'.
2022-06-05 20:49:21 [INFO]: Starting at sequence 5088118 (2022-06-04 17:11:02+00:00).
```

The date that updates will start from is obtained by looking at the most recent way object in the database, which will typically be a little earlier than any "this extract contains all OSM data up to" cut-off date. If that comes from somewhere other than OSM, an error will occur. Hourly and daily updates are also available, so you could also run the hourly or daily versions instead:

```sh
sudo -u _renderd \
    osm2pgsql-replication init -d gis  \
    --server https://planet.openstreetmap.org/replication/hour
```

```sh
sudo -u _renderd \
    osm2pgsql-replication init -d gis  \
    --server https://planet.openstreetmap.org/replication/day
```

Once initialisation has been done, set up the same scripts described in "Creating scripts to apply updates" above and test it in the same way:

```sh
sudo -u _renderd /usr/local/sbin/update_tiles.sh
```

Again, note that `osm2pgsql-replication` will actually repeat downloading data and updating the database until there is no more to process, and the `--max diff-size` in the script determines how much data is fetched on each iteration. Eventually, it will complete, ending with something like:

```log
2022-06-05 22:30:47 [INFO]: Data imported until 2022-06-05 21:45:42+00:00. Backlog remaining: 0:45:05.948787
```

The script to perform the update can be edited as above to output a summary to a logfile and added to root's crontab:

```sh
*/5 *  *   *   *     sudo -u _renderd /usr/local/sbin/update_tiles.sh >> /var/log/tiles/run.log
```

As we're updating based on minutely updates, and we've made the script check that it is not already running before trying to apply updates, we can run this more often than once per day; in this case every 5 minutes.

It's a good idea to clear the "osm2pgsql-replication is running" flag when `renderd` is restarted. To do that:

```sh
sudo nano /usr/lib/systemd/system/renderd.service
```

and add:

```ini
ExecStartPre=rm -f /var/cache/renderd/update_tiles.sh.running
```

in the "[Service]" section. Then:

```sh
sudo systemctl daemon-reload
sudo systemctl restart renderd
```

It's also a good idea to use the “osm2pgsql-replication is running” flag to stop replication running when you're doing a database reimport - don't start the reimport if the flag is set, and set the flag while the reimport happens to prevent replication running then.

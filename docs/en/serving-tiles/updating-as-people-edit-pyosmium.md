---
layout: docs
title: Updating your database as people edit OpenStreetMap
lang: en
---

# Updating your database as people edit OpenStreetMap using PyOsmium

Every day there are millions of new map updates so to prevent a map becoming "stale" you can refresh the data used to create map tiles regularly.

Using osm2pgsql (version 1.4.2 or above) it's now much easier to do this than it was previously.  Suitable versions are distributed as part of Ubuntu 22.04 and Debian 12, and it can also be obtained by following [these instructions](https://osm2pgsql.org/doc/install.html){: target=_blank}.

A simpler, but less flexible, method to update a database is to use "osm2pgsql-replication", described [here](/serving-tiles/updating-as-people-edit-osm2pgsql-replication.md). In this example we'll use "PyOsmium" to update a database initially loaded from Geofabrik with minutely updates from planet.openstreetmap.org.

## Making sure that you can see debug messages

It'd be really useful at this point to be able to see the output from the tile rendering process, to see that tiles marked as dirty are being processed.  By default with recent mod_tile versions, this is turned off.  To turn it on:

```sh
sudo nano /usr/lib/systemd/system/renderd.service
```

If it's not already there below `[Service]`, add:

```ini
Environment=G_MESSAGES_DEBUG=all
```

Then run these commands to reload the configuration:

```sh
sudo systemctl daemon-reload
sudo systemctl restart renderd
sudo systemctl restart apache2
```

## Initialising replication

Important note - the tile expiry script used below assumes that tiles are written below `/var/cache/renderd/`. If `/etc/renderd.conf` specifies another location, you'll need to modify it before expiring tiles using the scripts you're going to create here.  Because that directory will always exist, we'll also use it for workfiles needed by "pyosmium".

For the sake of this example, we'll assume that you've loaded your database in this way:

```sh
sudo -u _renderd \
    osm2pgsql -d gis --create --slim  -G --hstore \
    --tag-transform-script \
        ~/src/openstreetmap-carto/openstreetmap-carto.lua \
    -C 3000 --number-processes 4 \
    -S ~/src/openstreetmap-carto/openstreetmap-carto.style \
    ~/data/greater-london-latest.osm.pbf
```

The data to load was obtained from a page such as [this one](http://download.geofabrik.de/europe/united-kingdom/england/greater-london.html){: target=_blank}, which says something like "... and contains all OSM data up to 2023-07-02T20:21:43Z". We'll use that date when setting up replication below:

```sh
sudo mkdir /var/cache/renderd/pyosmium
sudo chown _renderd /var/cache/renderd/pyosmium
sudo mkdir /var/log/tiles
sudo chown _renderd /var/log/tiles
cd /var/cache/renderd/pyosmium
sudo apt install pyosmium
sudo -u _renderd pyosmium-get-changes -D 2023-07-02T20:21:43Z -f sequence.state -v
```

The last line creates a "sequence.state" file.  The actual date used in that line will need to match the data that you downloaded.

## Using "trim_osc.py" to only apply updates for a particular area

(optional, but recommended if updating a database containing only a region of the planet)

We’ll use “trim_osc.py” from Zverik’s “regional” scripts to trim down the updates from OpenStreetMap.org down to just the area that we’re interested in. We do this so that the postgres database doesn’t grow significantly as updates are applied to it. We will also need to fetch some dependencies for that.  As whatever non-root user you are using:

```sh
cd ~/src
git clone https://github.com/zverik/regional
chmod u+x ~/src/regional/trim_osc.py

sudo apt install python3-shapely python3-lxml
```

## Applying updates

A script to actually apply updates has been created [here](https://raw.githubusercontent.com/SomeoneElseOSM/mod_tile/switch2osm/call_pyosmium.sh){: target=_blank}. A good place to create that is `/usr/local/sbin`. That will need some customisation:

* If you're not using "trim_osc.py", just remove the section of code between the "Trim the downloaded changes" comment and the "The osm2pgsql append line" one.

* If you are using "trim_osc.py" you'll need to make sure that TRIM_BIN points to the correct location and TRIM_REGION_OPTIONS matches the area that you are interested in (the default in the script covers IE+GB).

* The parameters to "osm2pgsql --append" will need customising to match the server you're using (amount of memory allocated, number of threads, etc.)

* The parameters passed to "render_expired" will need to be customised (how many zoom levels to process, and what to do with dirty tiles at each level)

A script to display the current database replication lag is available [here](https://raw.githubusercontent.com/SomeoneElseOSM/mod_tile/switch2osm/pyosmium_replag.sh){: target=_blank}, which is based on the "mod_tile" one that is shipped as an example with the mod_tile source. `pyosmium_replag` displays the replication lag in seconds; `pyosmium_replag -h` displays the replication lag in hours (or if less than an hour minutes, or seconds). It is suggested to also create that in `/usr/local/sbin`. Don't forget to make both scripts executable.

To run the script once:

```sh
sudo -u _renderd /usr/local/sbin/call_pyosmium.sh
```

As it runs, it creates workfiles (and the verbose output from the commands that it runs) in `/var/cache/renderd/pyosmium`. At completion you should see something like:

```log
Pyosmium update started:  Mon Jul 3 11:15:36 PM UTC 2023
Filtering newchange.osc.gz
Importing newchange.osc.gz
2023-07-03 23:17:44  osm2pgsql took 45s overall.
Expiring tiles

Total for all tiles rendered
Meta tiles rendered: Rendered 0 tiles in 1.54 seconds (0.00 tiles/s)
Total tiles rendered: Rendered 0 tiles in 1.54 seconds (0.00 tiles/s)
Total tiles in input: 2334224
Total tiles expanded from input: 305839
Total meta tiles deleted: 0
Total meta tiles touched: 0
Total tiles ignored (not on disk): 305839
Database Replication Lag: 1 day(s) and 1 hour(s)
```

The amount downloaded per run can be tuned in the script by changing the size (`-s`) parameter to `pyosmium-get-changes`. This size is in MB - the script is set to 20 by default, and if not specified 100MB at a time is downloaded.

The script to perform the update can be added to the crontab of the `_renderd` account:

```sh
sudo -u _renderd crontab -e
```

and then add:

```sh
*/5 *  *   *   *     /usr/local/sbin/call_pyosmium.sh >> /var/log/tiles/run.log
```

The script checks that it is not already running before trying to apply updates, so can run it fairly frequently; in this case every 5 minutes.

It's a good idea to clear the "pyosmium is running" flag when renderd is restated.  To do that:

```sh
sudo nano /usr/lib/systemd/system/renderd.service
```

and add:

```ini
ExecStartPre=rm -f /var/cache/renderd/pyosmium/call_pyosmium.running
```

in the "[Service]" section. Then:

```sh
sudo systemctl daemon-reload
sudo systemctl restart renderd
```

## Configuring munin

If you are using munin to report on "mod_tile" and "renderd" activity, you can configure it to display the database replication lag by calling "pyosmium_replag.sh" as well:

```sh
sudo nano /etc/munin/plugins/replication_delay
```

You can obtain the contents of the script from [here](https://raw.githubusercontent.com/SomeoneElseOSM/mod_tile/switch2osm/munin/replication_delay_pyosmium){: target=_blank}. It uses the `pyosmium_replag.sh` that we created earlier to obtain the replication delay in seconds. Make that script executable by anyone, then:

```sh
sudo /etc/init.d/munin-node restart
```

Shortly after doing that, `http://yourserveraddress/munin/renderd-day.html` should show a "Data import lag" graph. If it doesn't, look at the logs in `/var/log/munin`. If you need more help understanding what is going wrong, have a look [here](https://guide.munin-monitoring.org/en/latest/develop/plugins/howto-write-plugins.html){: target=_blank}.

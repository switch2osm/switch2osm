---
layout: docs
title: Updating your database as people edit OpenStreetMap
permalink: /serving-tiles/updating-as-people-edit-osm2pgsql/
---

# Updating your database as people edit OpenStreetMap using osm2pgsql

Every day there are millions of new map updates so to prevent a map becoming "stale" you can refresh the data used to create map tiles regularly.

Using osm2pgsql (version 1.4.2 or above) it's now much easier to do this than it was previously.  This is the version that is distributed as part of Ubuntu 22.04, and it can also be obtained by following [these instructions](https://osm2pgsql.org/doc/install.html).

It's possible to set up replication from many different sources.  OpenStreetMap itself provides minutely. hourly and daily updates, and other sources such as Geofabrik can provide daily updates that match the regional data extracts available at [download.geofabrik.de](http://download.geofabrik.de/index.html).

In this example we'll download the data for London from Geofabrik, load a database with it, and then set up updates to it.  First, download the data:

    (if it doesn't already exist) mkdir ~/data
    cd ~/data
    wget http://download.geofabrik.de/europe/great-britain/england/greater-london-latest.osm.pbf

Next, load the database.  The numbers here for processes and memory can be varied to match the system being used:

    sudo -u _renderd osm2pgsql -d gis --create --slim  -G --hstore --tag-transform-script ~/src/openstreetmap-carto/openstreetmap-carto.lua -C 3000 --number-processes 4 -S ~/src/openstreetmap-carto/openstreetmap-carto.style ~/data/greater-london-latest.osm.pbf

Then, initialise replication.  As described [here](https://osm2pgsql.org/doc/manual.html#updating-an-existing-database) downloads from Geofabrik (and [download.openstreetmap.fr](https://download.openstreetmap.fr/)) contain all the information needed for replication (the URL from which to download updates and what date to start from).

    sudo -u _renderd osm2pgsql-replication init -d gis --osm-file ~/data/greater-london-latest.osm.pbf

That produces output something like this:

    2022-04-24 23:32:42 [INFO]: Initialised updates for service 'http://download.geofabrik.de/europe/great-britain/england/greater-london-updates'.
    2022-04-24 23:32:42 [INFO]: Starting at sequence 3314 (2022-04-23 20:21:53+00:00).

The date shown there corresponds to the date currently visible [here](http://download.geofabrik.de/europe/great-britain/england/greater-london.html).  Next, apply any pending updates:

    sudo -u _renderd osm2pgsql-replication update -d gis --max-diff-size 10  --  -G --hstore --tag-transform-script ~/src/openstreetmap-carto/openstreetmap-carto.lua -C 3000 --number-processes 4 -S ~/src/openstreetmap-carto/openstreetmap-carto.style

Everything there after "--" is passed as parameters to osm2pgsql - the .style and the .lua files will need to match what the database was loaded with in the first place.  Before the "--", "-d gis" just defines what database we're using and "--max-diff-size 10" how much data to process at once, but note that osm2pgsql-replication will actually repeat downloading data and updating the database until there is no more to process.  If there are no pending updates (Geofabrik updates are daily) then something like this will be shown:

    2022-04-24 23:46:32 [INFO]: Using replication service 'http://download.geofabrik.de/europe/great-britain/england/greater-london-updates'. Current sequence 3314 (2022-04-23 20:21:53+00:00).
    2022-04-24 23:46:32 [INFO]: Database already up-to-date.

If there are pending updates, then after the "Using replication service" line, the output from osm2pgsql will be shown.


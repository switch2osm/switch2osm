---
layout: page
title: Building a tile server from packages
permalink: /serving-tiles/building-a-tile-server-from-packages/
---

If you’d like to build your own tile server, using packages can save you a good deal of installation work.

These packages work with Ubuntu Linux versions 12.04 LTS (Precise Pangolin) and above. After installation, you should have your own working tileserver with the standard OSM Mapnik stylesheet, into which you can import an extract of the OSM data for rendering.

It is based on the same software that OSM’s own tile server uses:
* mod_tile for serving
* renderd as the rendering daemon
* mapnik for the actual rendering

The main aim of these packages is to simplify installation, by automating as much as possible into packaging scripts.

# Installation

The following commands need to be entered into the terminal to set things up:
In case you do not have add-apt-repository installed, add it with:

for Ubuntu 12.04

    sudo apt-get install python-software-properties

for Ubuntu 12.10 and later

    sudo apt-get install software-properties-common

Add the repository containing the packages:

    sudo add-apt-repository ppa:kakrueger/openstreetmap

Update the local package list to pick up the new repository:

    sudo apt-get update

Install the package libapache2-mod-tile and its dependencies. During configuration, it will ask you few questions. To make sure the automatic setup scripts work, you should keep the defaults. However, in the question about permissions for users of the database, you want to add your own username after the user www-data separated by a space to be able import data under your user.

    sudo apt-get install libapache2-mod-tile

# Import map data
Download the OpenStreetMap data you want to render (complete planet files can be found on planet.openstreetmap.org, country extracts can be found e.g. on download.geofabrik.de). e.g:

    wget http://download.geofabrik.de/europe/ireland-and-northern-ireland-latest.osm.pbf
    
Import the data into your postgresql database with osm2pgsql. There are a number of different parameters one can use with osm2pgsql that depend on your available hardware and the size of the data extract you want to import. The most likely ones you will need to set are ``-C``, ``--slim`` and ``-number-processes``. ``-C`` specifies the number of Mb osm2pgsql will use to cache data. So this depends on the amount of RAM you have available. ``--slim`` keeps the complete osm data on disk, necessary for updates and low memory environments. ``--number-processes`` specifies the number of parallel processes that are used for some parts of the import process. The optimal value mostly depends on the speed of your disk system and the available processor cores.

    osm2pgsql --slim -C 1500 --number-processes 4 ireland-and-northern-ireland.osm.pbf

Depending on the size of the extract you are importing and the performance of the computer, this can take anywhere from a few minutes for small extracts up to several days for the full planet on slower hardware! If you are importing the full planet, it is strongly recommended to set -C 18000 (18 GB of ram cache and may increase as the OSM database grows). This may cause your server to swap during the import if you don’t have a sufficient amount of memory, but in many cases it will still be faster than using smaller values for the node cache. However, you need to ensure you have sufficient swap memory configured.

If you are importing a full planet file, you might also want to use the –flat-nodes option. It uses a custom format file for some of the data rather than the postgis database which makes it more efficient, but less efficient for regional extracts. It may also make sense to temporarily change your PostgreSQL configurations during the import. (For example, increase the number of checkpoint segments, reduce shared buffer size.)

A large proportion of the import time as well as size of the database are used for creating indexes to keep track of updates. If you are not planning to keep the database continously up-to-date with “diff files”, you may want to import the data with the ``--drop`` option which will drop the “slim-tables” after import whih are not needed for rendering and does not create indexes which are only needed to support diff imports. Once you update less often than perhaps once every 1 – 2 weeks, it may be more efficient to do full reimports each time rather than use updates.

mod_tile is designed to always serve up-to-date tiles (see updating below). As it is generally not feasible to re-render all changed tiles at the time of change, mod_tile initiates re-rendering of outdated tiles at the time of serving. As such mod_tile needs to know when the planet was imported. This is done by changing the timestamp on the file planet-import-complete

    touch /var/lib/mod_tile/planet-import-complete

Finally, you need to restart the rendering daemon after which all should be ready.

    sudo /etc/init.d/renderd restart

If everything worked OK, you should have a working tileserver and you can view its results by going to http://localhost/osm/slippymap.html

If you are not opening slippymap.html on localhost and you are seeing only pink tiles, you will need to edit the html page and replace localhost with the correct server name in ‘new OpenLayers.Layer.OSM(“Local Tiles”…’ or change it to a relative URL.

# Updating
The following commands explain how to keep your tile server up-to-date with the latest OSM data.

After importing the initial database with osm2pgsql as described above (you will need to have used the ``--slim`` option in the initial import to allow for updating), you need to do the following steps

Install osmosis

    sudo apt-get install osmosis
    
Grant rights to the update tables to user www-data

    sudo /usr/bin/install-postgis-osm-user.sh gis www-data

Initialise the osmosis replication stack to the data of your data import. Choose the date of the planet data, as this is the date from which the diffs will start.

    sudo -u www-data /usr/bin/openstreetmap-tiles-update-expire 2012-04-21

As the packaged script currently uses an outdated service to determine the correct replication start-point, you will need to manually choose and download the correct state.txt from the base_url (see below) which corresponds to slightly before the age of the extract to make sure all modifications are included in your db. This needs to be copied to /var/lib/mod_tile/.osmosis/state.txt

You will next need to update the default configuration of osmosis. In /var/lib/mod_tile/.osmosis/configuration.txt change the base_url to
`http://planet.openstreetmap.org/replication/minute/`

Update your tileserver by up to an hour and expire the corresponding rendered tiles

sudo -u www-data /usr/bin/openstreetmap-tiles-update-expire

If your tile server is behind more than an hour you will need to call the openstreetmap-tiles-expire script multiple times. If you want to continuously keep your server up to data, you need to add the openstreetmap-tiles-expire script to your crontab.

Keeping the data up-to-date can be resource intense, in particular because after the import you may already be multiple days behind. Consider changing maxInterval in /var/lib/mod_tile/.osmosis/configuration.txt to 21600 (six hours) till you have caught up. Further, add “–number-processes 2” to the osm2pgsql command in /usr/bin/openstreetmap-tiles-update-expire or a higher number if this is appropriate for your hardware.

The initial install installed pre-processed coastlines, from time to time it may make sense to replace the files with new versions:

    wget http://tile.openstreetmap.org/processed_p.tar.bz2

and extract it to

    /etc/mapnik-osm-data/world_boundaries/

# Troubleshooting

There are a number of things that can go wrong. Here are a few of the common problems and there solutions:

## Connection to database failed in osm2pgsql

If you are getting the following error message when importing data with osm2pgsql, you have probably forgotten to add your username in the allowed users section during the configuration. Connection to database Failed: FATAL: Ident authentication failed for user “xyz”

You can fix this in one of two ways:

Either you reconfigure the package, this time including both www-data and your own user name in a space separated list,

    sudo dpkg-reconfigure openstreetmap-postgis-db-setup

Or, you manually grant permissions to your user account with the following command:

    sudo /usr/bin/install-postgis-osm-user.sh gis xyz

# Hardware

Hardware requirements can be quite demanding if you want to render larger areas, but aren’t too bad if you are only interested in smaller regions. For a standard desktop (approximately 4 GB of ram, standard harddisk, dual – quad core CPU) probably an extract size of about 100 – 300 Mb is reasonable (import time of the order of an hour).

If you want to import and render the whole world, you will need a considerably beefier server than a typical desktop. E.g. starting from about 24Gb of RAM upwards. It is also strongly recomend to use an SSD for the database or at least a fast RAID array. The full planet import is currently around about 256GB, so to store all of the DB on an SSD, you will likely need a 512GB SSD. An import that is not updated and uses the –drop option on the otherhand likely still fits on a 256GB SSD. You can also selectively put the most important parts of the database on an SSD and the rest on slower disks. Osm2pgsql supports using separate tablespaces for different parts of the database for this purpose.

# FAQ
## Where are the various files (DB / Tiles, etc.)?
* Style sheets and coastlines are in /etc/mapnik-osm-data
* Tiles are in /var/lib/mod_tile
* Renderd configuration in /etc/renderd.conf
* mod_tile configuration in /etc/apache2/sites-available/tileserver_site
* Scripts are in /usr/bin
* Database configuration is in /etc/postgresql/X.X/main (where X.X is the PostgreSQL version, for example 9.1)
* osm2pgsql configuration and state.txt is in /var/lib/mod_tile/.osmosis

## How do I pre-render tiles?

You can use render_list to pre-render tiles:

    Usage: render_list [OPTION] ...
     -a, --all render all tiles in given zoom level range instead of reading from STDIN
     -f, --force render tiles even if they seem current
     -m, --map=MAP render tiles in this map (defaults to 'default')
     -l, --max-load=LOAD sleep if load is this high (defaults to 5)
     -s, --socket=SOCKET unix domain socket name for contacting renderd
     -n, --num-threads=N the number of parallel request threads (default 1)
     -t, --tile-dir tile cache directory (defaults to '/var/lib/mod_tile')
     -z, --min-zoom=ZOOM filter input to only render tiles greater or equal to this zoom level (default is 0)
     -Z, --max-zoom=ZOOM filter input to only render tiles less than or equal to this zoom level (default is 18)

If you are using –all, you can restrict the tile range by adding these options:

     -x, --min-x=X minimum X tile coordinate
     -X, --max-x=X maximum X tile coordinate
     -y, --min-y=Y minimum Y tile coordinate
     -Y, --max-y=Y maximum Y tile coordinate


Without –all, send a list of tiles to be rendered from STDIN in the format X Y Z, e.g.

    0 0 1
    0 1 1
    1 0 1
    1 1 1

The above would cause all 4 tiles at zoom 1 to be rendered
Note that you have to set ``--socket=/var/run/renderd/renderd.sock``

# Acknowledgements
Thanks to Kai Krueger for maintaining the packages and preparing the documentation.
---
layout: docs
title: Using a Docker container
lang: en
---

# {{ title }}

If you just want to try things out or you're using an OS other than Ubuntu, and you're using Docker for containerisation, you can try [this](https://github.com/Overv/openstreetmap-tile-server){: target=_blank} (thanks to all the contributors there).  It's based on the instructions [here](/serving-tiles/manually-building-a-tile-server-ubuntu-22-04-lts.md), but is a pre-built container you can install.

## Docker

If you don't already have Docker installed, there are lots of "how-tos" around - see for example [here](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-debian-10){: target=_blank}.

You'll need around 30GB of disk space for even a small data extract, because the worldwide boundary data that is added to the database is quite large.

## OpenStreetmap Data

In this example run-through I’ll download data for Zambia and import it, but any OSM .pbf file should work.  For testing, try a small .pbf first.  When logged in as the non-root user that you run Docker from, download the data for Zambia:

```sh
cd
wget https://download.geofabrik.de/africa/zambia-latest.osm.pbf
```

Create a docker volume for the data:

```sh
docker volume create osm-data
```

And install it and import the data:

```sh 
time \
    docker run \
    -v /home/renderaccount/zambia-latest.osm.pbf:/data/region.osm.pbf \
    -v osm-data:/data/database/ \
    overv/openstreetmap-tile-server import
```

The path to the data file needs to be the absolute path to the data file - it can't be a relative path.  In this example it's in the root directory of the "renderaccount" user.  Also, if something goes wrong, you'll need to "docker volume rm osm-data" and restart from "docker volume create osm-data" above.  At the end of the process you should see:

```sh
INFO:root: Import complete
```

If you see something like:

```sh
/data/region.osm.pbf: Is a directory
```

or

```sh
createuser: error: creation of new role failed: ERROR: role "renderer" already exists
```

then something has gone wrong; you'll need to use "docker ps -a" to identify the failed container; "docker rm" (followed by the container id) to delete it, and then delete and recreate "osm-data" as described above.

How long this takes depends very much on the local network speed and the size of the area that you are loading. Zambia, used in this example, is relatively small.

Note that if something goes wrong the error messages may be somewhat cryptic, and unfortunately the import process can't be restarted after failure.  Also, note that newer versions of the Docker container might use newer versions of postgres, so an “osm-data” created with an earlier version might not work - you may need to remove it with “docker volume rm osm-data” and recreate.

For more details about what it’s actually doing, have a look at [this file](https://github.com/Overv/openstreetmap-tile-server/blob/master/Dockerfile){: target=_blank}. You’ll see that it closely matches the “manually building a tile server” instructions [here](/serving-tiles/manually-building-a-tile-server-ubuntu-22-04-lts.md), with some minor changes such as the tile URL and the internal account used. Internally you can see that it’s using Ubuntu 22.04.  You don’t need to interact with that directly, but you can (via "docker exec -it mycontainernumber bash") if you want to.

To start the tile server running:

```sh
docker run \
    -p 8080:80 \
    -v osm-data:/data/database \
    -d overv/openstreetmap-tile-server \
    run
```

and to check that it’s working, from a new incognito window browse to:

`http://your.server.ip.address:8080/tile/0/0/0.png`

You should see a map of the world in your browser.  Then try:

`http://your.server.ip.address:8080`

for a map that you can zoom in and out of.  Tiles (especially at low zoom levels) will take a short period of time to appear.

### More Information

This docker container actually supports a lot more than the simple example here - see the [readme](https://github.com/Overv/openstreetmap-tile-server/blob/master/README.md){: target=_blank} for more details about updates, performance tweaks, etc.

### Viewing tiles

For a simple “slippy map” that you can modify, you can use an html file “sample_leaflet.html” which is [here](https://github.com/SomeoneElseOSM/mod_tile/blob/switch2osm/extra/sample_leaflet.html){: target=_blank} in mod_tile’s “extra” folder. Edit “hot” in the URL in that file to read “tile”, and then just open that file in a web browser on the machine where you installed the docker container. If that isn’t possible because you’re installing on a server without a local web browser, you’ll also need to edit it to replace “127.0.0.1” with the IP address of the server and copy it to below “/var/www/html” on that server.

If you want to load a different area, just repeat the process from “wget” above. Unfortunately it is necesary to delete and recreate "osm-data" every time you want to load some new data.

---
layout: docs
title: Using a Docker container
permalink: /serving-tiles/using-a-docker-container/
---

If you just want to try things out or you're using an OS other than Ubuntu, and you're using Docker for containerisation, you can try [this](https://github.com/Overv/openstreetmap-tile-server/blob/master/README.md).  It's based on the instructions [here](https://switch2osm.org/serving-tiles/manually-building-a-tile-server-18-04-lts/), but is a pre-built container you can install.

# Docker

If you don't already have Docker installed, there are lots of "how-tos" around - see for example [here](https://www.openstreetmap.org/user/SomeoneElse/diary/45070) and the links from there.

# OpenStreetmap Data

In this example run-through I’ll download data for Zambia and import it, but any OSM .pbf file should work.  For testing, try a small .pbf first.  When logged in as the non-root user that you run Docker from, download the data for Zambia:

    cd
    wget https://download.geofabrik.de/africa/zambia-latest.osm.pbf

Create a docker volume for the data:

    docker volume create openstreetmap-data

And install it and import the data:

    time docker run -v /home/renderaccount/zambia-latest.osm.pbf:/data.osm.pbf -v openstreetmap-data:/var/lib/postgresql/10/main overv/openstreetmap-tile-server import

The path to the data file needs to be the absolute path to the data file - it can't be a relative path.  In this example it's in the root directory of the "renderaccount" user.

How long this takes depends very much on the local network speed and the size of the area that you are loading. Zambia, used in this example, is relatively small.

Note that if something goes wrong the error messages may be somewhat cryptic - you might get “… is a directory” if the data file isn’t found. The “time” at the start of the command isn’t necessary for the installation and import; it just tells you how long it took for future reference.

For more details about what it’s actually doing, have a look at [this file](https://github.com/Overv/openstreetmap-tile-server/blob/master/Dockerfile). You’ll see that it closely matches the “manually building a tile server” instructions [here](https://switch2osm.org/serving-tiles/manually-building-a-tile-server-18-04-lts/), with some minor changes such as the tile URL and the internal account used. Internally you can see that it’s using Ubuntu 18.04, though you don’t need to interact with that directly.

When the import is complete you should see something like this:

    Osm2pgsql took 568s overall

    real    9m34.378s
    user    0m0.030s
    sys     0m0.060s

That tells you how long things took in total (in this case 9.5 minutes). 

To start the tile server running:

    docker run -p 80:80 -v openstreetmap-data:/var/lib/postgresql/10/main -d overv/openstreetmap-tile-server run

and to check that it’s working, browse to:

    http://your.server.ip.address/tile/0/0/0.png

You should see a map of the world in your browser.

## Viewing tiles

For a simple “slippy map” we can use an html file “sample_leaflet.html” which is [here](https://github.com/SomeoneElseOSM/mod_tile/blob/switch2osm/extra/sample_leaflet.html) in mod_tile’s “extra” folder. Edit “hot” in the URL in that file to read “tile”, and then just open that file in a web browser on the machine where you installed the docker container. If that isn’t possible because you’re installing on a server without a local web browser, you’ll also need to edit it to replace “127.0.0.1” with the IP address of the server and copy it to below “/var/www/html” on that server.

If you want to load a different area, just repeat the process from “wget” above. It’ll be quicker the next time because the static data needed by the map style won’t be needed.
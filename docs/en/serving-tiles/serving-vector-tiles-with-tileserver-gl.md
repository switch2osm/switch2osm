---
layout: docs
title: Getting started with TileServer GL
---

# {{ title }}

TileServer GL is a powerful open-source tool that allows you to serve vector and raster tiles from various data sources. It enables you to create your own tile server and serve map tiles that can be rendered and customized in real-time. Here's a step-by-step guide to help you get started with TileServer GL.

## Installation

Make sure you have Node.js installed on your system. You can download and install the latest LTS version from the official Node.js website (<https://nodejs.org>{: target=_blank}).

Open your terminal or command prompt and run the following command to install TileServer GL globally:

```sh
npm install -g tileserver-gl
```

or you can utilize Docker Container

```sh
docker pull klokantech/tileserver-gl:latest
```

## Prepare Map Data

Determine the data source you want to use for your map tiles. TileServer GL supports various data formats, including vector data in GeoJSON, Shapefile, or Mapbox Vector Tiles (MVT) formats, as well as raster data in formats like MBTiles or GeoTIFF.

If your data is not already in a compatible format, you may need to convert it using tools like [ogr2ogr](https://gdal.org/programs/ogr2ogr.html){: target=_blank}, [Tippecanoe](https://github.com/felt/tippecanoe){: target=_blank} or [Tilemaker](https://tilemaker.org){: target=_blank}. Refer to the TileServer GL documentation for specific instructions on converting your data to the required format.

## Configure TileServer GL

Create a JSON configuration file that defines your tile server's settings. This file specifies the data sources, map styles, and other server options. You can refer to the TileServer GL documentation for a detailed explanation of the configuration options.

Define the map styles you want to use for rendering your tiles. You can use Mapbox Studio, Maputnik, or other map styling tools to create your custom styles in Mapbox GL Style JSON format.

## Start TileServer GL

Open your terminal or command prompt and navigate to the directory where your configuration file is located. Run the following command to start TileServer GL:

```sh
tileserver-gl <config.json>
```

*Replace `<config.json>` with the path to your configuration file.*

Once TileServer GL is running, you can access it through your web browser or use it as a tile source in your mapping application. The server will provide endpoints for serving vector and raster tiles, which you can utilize based on your specific requirements.

## Customize and Integrate

TileServer GL allows you to customize the rendering of your map tiles by modifying the map styles and configuration settings. You can experiment with different styles, layer compositions, and interactions to achieve the desired visual representation.

You can integrate the tile server into your web or mobile application using mapping libraries like Maplibre GL JS, Leaflet, OpenLayers, or other frameworks that support Mapbox GL Style JSON or raster tile sources.

## Running server using Docker container

Install an appropriate version of Tilemaker. In case of Ubuntu 18.04 it will be

```sh
cd /opt/osm/
wget https://github.com/systemed/tilemaker/releases/download/v2.2.0/tilemaker-ubuntu-18.04.zip
```

For other operating systems, you can find the appropriate Tilemaker version on the GitHub repository: <https://github.com/systemed/tilemaker/releases>{: target=_blank}.

Use one of the regional extracts for your data, for example

```sh
wget https://download.openstreetmap.fr/extracts/europe/ukraine/kiev-latest.osm.pbf
```

You can also create your own extract in different GIS formats using services <https://extract.bbbike.org>{: target=_blank}.

Copy the downloaded OSM data (*.osm.pbf) into the `/opt/osm/tilemaker/build/` folder:

```sh
cp *.osm.pbf /opt/osm/tilemaker/build/
```

and convert `*.osm.pbf` into MBTiles format using Tilemaker:

```sh
cd /opt/osm/tilemaker/build/
./tilemaker \
    --input /opt/osm/tilemaker/build/kiev.osm.pbf \
    --output kiev.mbtiles \
    --process ../resources/process-example.lua \
    --config ../resources/config-example.json
```

Move the generated `*.mbtiles` file to the `/opt/osm/opentiles` folder:

```sh
mv kiev.mbtiles /opt/osm/opentiles/
```

and navigate back `/opt/osm/` folder

```sh
cd /opt/osm/
```

Start your tile server using Docker and the `klokantech/tileserver-gl` image:

```sh
docker run -d --rm -it -v $(pwd)/opentiles:/data -p 8080:80 klokantech/tileserver-gl:latest
```

Your tile server is now running, and you can access it at `http://[server_address]:8080/`.

TileServer GL offers a flexible and scalable solution for serving your own map tiles. By following these steps, you can set up your tile server, configure data sources and map styles, and start serving vector or raster tiles to enhance your mapping applications. Refer to the TileServer GL documentation for more detailed instructions and advanced features to further customize your tile server setup.

!!! tip
    It is also useful to mention an article ["How to deploy an OSM tile server"](https://www.blef.fr/how-to-deploy-tile-server/){: target=_blank} written by Christophe Blefari. The article provides detailed instructions and guidance on deploying your own OpenStreetMap (OSM) tile server. It covers various aspects, including software installation, data preparation, styling, and server configuration.

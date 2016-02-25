---
layout: page
title: Other Uses
permalink: /other-uses/
---

We’ve focused on tiles, but since OpenStreetMap – uniquely – gives you access to the raw map data, you can build any location or geo- application. These are the most common starting points.

## Common tools
* [Osmosis](http://wiki.openstreetmap.org/wiki/Osmosis) is an all-purpose Java application for loading OSM data into a database. Most applications of OSM data use Osmosis in some way.
* [Osmium](http://wiki.openstreetmap.org/wiki/Osmium) is a flexible framework, rapidly gaining popularity, which offers a highly configurable alternative to Osmosis.

## Geocoding
* [Nominatim](http://wiki.openstreetmap.org/wiki/Nominatim) is OpenStreetMap’s geocoding service (placename<->lat/long). It has significant hardware requirements and many people choose to use the free instance offered by [MapQuest Open](http://open.mapquestapi.com/nominatim/).
* [OpenCage](http://geocoder.opencagedata.com/) provides a public geocoding API aggregating Nominatim and other sources.

## Routing
* [OSRM](http://project-osrm.org/) is a new, fast routing engine designed for OSM data.
* [Gosmore](http://sourceforge.net/projects/gosmore/) is a long-established routing engine.
* [Graphhopper](http://graphhopper.com/) is a fast Java routing engine.
* Public routing APIs using OSM data are offered by [MapQuest Open](http://developer.mapquest.com/web/products/open/directions-service) and [CloudMade](http://developers.cloudmade.com/projects/show/routing-http-api).
* Specialist routing APIs include [CycleStreets cycle routing](http://www.cyclestreets.net/api/) (UK)

## Mobile libraries
* iPhone/iOS libraries include [Route-Me](https://github.com/route-me/route-me) and [CloudMade’s SDK](http://cloudmade.com/products/iphone-sdk).
* Android libraries include [osmdroid](http://code.google.com/p/osmdroid/).

## Vector rendering
* [Kothic-JS](https://github.com/kothic/kothic-js) is an in-development new technology which renders OSM data “on the fly” using HTML5, without the need for raster tile images.
* [Mapbox Studio](https://www.mapbox.com/mapbox-studio/) is a suite of tools to produce ‘vector tiles’ which can be rendered either server-side or client-side.

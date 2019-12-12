---
layout: page
title: Other Uses
permalink: /other-uses/
---

We’ve focused on tiles, but since OpenStreetMap – uniquely – gives you access to the raw map data, you can build any location or geo- application. These are the most common starting points; a full listing is available [at the OpenStreetMap Wiki](http://wiki.openstreetmap.org/wiki/Frameworks).

## Common tools
* [Osmosis](http://wiki.openstreetmap.org/wiki/Osmosis) is an all-purpose Java application for loading OSM data into a database. Most applications of OSM data use Osmosis in some way.
* [Osmium](http://wiki.openstreetmap.org/wiki/Osmium) is a flexible framework, rapidly gaining popularity, which offers a highly configurable alternative to Osmosis.
* [Mapbox Studio](https://www.mapbox.com/mapbox-studio/) is a suite of tools to produce ‘vector tiles’ which can be rendered either server-side or client-side.

## Geocoding services
* [Gisgraphy](https://www.gisgraphy.com) is an open source geocoder that provides API / webservices for forward and reverse geocoding with auto-completion, interpolation, location Bias, find nearby, all can be run offline or as hosted solutions. It provide some importers for Openstreetmap but also Openadresses, Geonames, and more.
* [Nominatim](https://nominatim.org) is the software behind OpenStreetMap’s geocoding service (placename<->lat/long).
* [OpenCage](https://opencagedata.com/) provides a geocoding API aggregating Nominatim and other open sources.
* [OSMNames](https://osmnames.org/) - place names from OpenStreetMap. Downloadable. Ranked. With bbox and hierarchy. Ready for geocoding.

## Routing engines and services
* [OSRM](http://project-osrm.org/) is a fast routing engine designed for OSM data.
* [Gosmore](http://sourceforge.net/projects/gosmore/) is a long-established routing engine.
* [Graphhopper](http://graphhopper.com/) is a fast Java routing engine.
* Public routing APIs using OSM data are offered by [MapQuest Open](http://open.mapquestapi.com/directions/) and [Mapbox](https://www.mapbox.com/directions/).
* Specialist routing APIs include [CycleStreets cycle routing](https://www.cyclestreets.net/api/) (UK and beyond)

## Vector map libraries (mobile)
* Android libraries include the [Mapbox Android SDK](https://www.mapbox.com/android-sdk/), [mapsforge](http://mapsforge.org/), [Nutiteq Maps SDK](https://developer.nutiteq.com/), [Skobbler Android SDK](http://developer.skobbler.com/), and [Tangram ES](https://github.com/tangrams/tangram-es/).
* iOS libraries include the [Mapbox iOS SDK](https://www.mapbox.com/ios-sdk/), [Nutiteq Maps SDK](https://developer.nutiteq.com/), [Skobbler iOS SDK](http://developer.skobbler.com/), and [Tangram ES](https://github.com/tangrams/tangram-es/).

## Vector map libraries (Web)
* [Kothic JS](https://github.com/kothic/kothic-js) renders OSM data “on the fly” using HTML5, without the need for raster tile images.
* [Mapbox GL JS](https://www.mapbox.com/mapbox-gl-js/) and [Tangram](http://tangrams.github.io/tangram/) render vector tiles based on OSM data using WebGL for better performance.

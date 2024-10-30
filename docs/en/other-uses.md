---
layout: page
title: Other Uses
lang: en
---

# {{ title }}

We’ve focused on tiles, but since OpenStreetMap – uniquely – gives you access to the raw map data, you can build any location or geo-application. These are the most common starting points; a full listing is available [at the OpenStreetMap Wiki](http://wiki.openstreetmap.org/wiki/Frameworks){: target=_blank}.

## Common tools

* [Osmosis](http://wiki.openstreetmap.org/wiki/Osmosis){: target=_blank} is an all-purpose Java application for loading OSM data into a database. Most applications of OSM data use Osmosis in some way.
* [Osmium](http://wiki.openstreetmap.org/wiki/Osmium){: target=_blank} is a flexible framework, rapidly gaining popularity, which offers a highly configurable alternative to Osmosis.
* [Mapbox Studio](https://www.mapbox.com/mapbox-studio/){: target=_blank} is a suite of tools to produce ‘vector tiles’ which can be rendered either server-side or client-side.

## Geocoding services

* [Gisgraphy](https://www.gisgraphy.com){: target=_blank} is an open source geocoder that provides API / webservices for forward and reverse geocoding with auto-completion, interpolation, location Bias, find nearby, all can be run offline or as hosted solutions. It provides some importers for Openstreetmap but also Openadresses, Geonames, and more.
* [Nominatim](https://nominatim.org){: target=_blank} is the software behind OpenStreetMap’s geocoding service (placename ↔ lat/long).
* [OpenCage](https://opencagedata.com/){: target=_blank} provides a geocoding API aggregating Nominatim and other open sources.
* [OSMNames](https://osmnames.org/){: target=_blank} - place names from OpenStreetMap. Downloadable. Ranked. With bbox and hierarchy. Ready for geocoding.

## Routing engines and services

* [OSRM](http://project-osrm.org/){: target=_blank} is a fast routing engine designed for OSM data.
* [Graphhopper](https://github.com/graphhopper/graphhopper/){: target=_blank} is a fast Java routing engine with a small memory footprint.
* [Valhalla](https://valhalla.readthedocs.io/en/latest/){: target=_blank} is a C++ routing engine for road vehicles and public transport.
* Public routing APIs using OSM data are offered by [GraphHopper](https://www.graphhopper.com/products/){: target=_blank}, [MapQuest Open](http://open.mapquestapi.com/directions/){: target=_blank} and [Mapbox](https://www.mapbox.com/directions/){: target=_blank}.
* Specialist routing APIs include [CycleStreets cycle routing](https://www.cyclestreets.net/api/){: target=_blank} (UK and beyond)

## Vector map libraries (mobile)

* Android libraries include the [MapLibre Android SDK](https://maplibre.org/projects/maplibre-native/){: target=_blank}, [Mapbox Android SDK](https://www.mapbox.com/android-sdk/){: target=_blank}, [mapsforge](http://mapsforge.org/){: target=_blank}, [Nutiteq Maps SDK](https://developer.nutiteq.com/){: target=_blank}, [Skobbler Android SDK](http://developer.skobbler.com/){: target=_blank}, and [Tangram ES](https://github.com/tangrams/tangram-es/){: target=_blank}.
* iOS libraries include the [MapLibre iOS SDK](https://maplibre.org/projects/maplibre-native/){: target=_blank}, [Mapbox iOS SDK](https://www.mapbox.com/ios-sdk/){: target=_blank}, [Nutiteq Maps SDK](https://developer.nutiteq.com/){: target=_blank}, [Skobbler iOS SDK](http://developer.skobbler.com/){: target=_blank}, and [Tangram ES](https://github.com/tangrams/tangram-es/){: target=_blank}.

## Vector map libraries (Web)

* [MapLibre GL JS](https://maplibre.org/maplibre-gl-js/docs/){: target=_blank}, [Mapbox GL JS](https://www.mapbox.com/mapbox-gl-js/){: target=_blank} and [Tangram](http://tangrams.github.io/tangram/){: target=_blank} render vector tiles based on OSM data using WebGL for better performance.

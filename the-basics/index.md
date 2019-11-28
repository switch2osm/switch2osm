---
layout: page
title: The Basics
permalink: /the-basics/
---

# The challenge
Your current map provider gives you two things:

* A set of ’tiles’ (square map images) that are placed together to make the map
* A JavaScript API, or equivalent library for mobile apps, to view them

To switch to OpenStreetMap, you’ll need to replace both of these.

# The tiles

![Tiles](tiles.png)
The map tiles, images of (usually) 256 x 256 pixels each, are drawn (“rendered”) from a map database.

If you currently use Google Maps, you’ll be using Google’s map tiles, hosted at google.com. Because the OpenStreetMap Foundation is a non-profit organisation with limited resources, you can’t just slot in the tiles from openstreetmap.org as a replacement (see the [Tile Usage Policy](https://wiki.openstreetmap.org/wiki/Tile_usage_policy)). Instead, you can:

* Generate your own tiles, by downloading the free OSM map database and rendering them;

* Or use a third-party supplier (some of whom charge, some are free)

The OSM map database is called planet.osm. The full database and regular update files are both available at [planet.openstreetmap.org](http://planet.openstreetmap.org/).

Rendering your own tiles gives you complete control over their appearance. You can customise the maps to appear any way you like. Alternatively, third-party suppliers have OSM expertise and may have ready-prepared map styles that you can use.

# The API/library

There is no single canonical library: you can choose whichever suits your needs best. The two most popular JavaScript libraries for use with OSM tiles are:

* OpenLayers – powerful and long-established

* Leaflet – lightweight and easy-to-learn

If you choose to use MapQuest Open tiles (made from OSM data), you can also use the [MapQuest Open API](http://developer.mapquest.com/web/products/open/sdk). APIs are also available for mobile platforms, such as [Route-Me](https://github.com/route-me/route-me) (iOS) and [osmdroid](http://code.google.com/p/osmdroid/) (Android).

# The licence
Unlike commercial providers’ data, OpenStreetMap is ‘open data’. The map data is available to you free-of-charge, with the freedom to copy and modify. OSM’s licence is the [Open Database Licence](http://opendatacommons.org/licenses/odbl/summary/).

Your obligations are:

* Attribution. You must credit OpenStreetMap with the same prominence that would be expected if you were using a commercial provider. See [OSM’s copyright guidelines](http://www.openstreetmap.org/copyright).

* Share-Alike. When you use any adapted version of OSM’s map data, or works produced it, you must also offer that adapted database under the ODbL.

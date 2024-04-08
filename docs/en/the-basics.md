---
layout: page
title: The Basics
lang: en
---

# {{ title }}

## The challenge

Your current map provider gives you two things:

* A set of `tiles` (square map images) that are placed together to make the map
* A JavaScript API, or equivalent library for mobile apps, to view them

To switch to OpenStreetMap, you’ll need to replace both of these.

## The tiles

![Tiles](/assets/img/tiles.png){ align=left .off-glb }
The map tiles, images of (usually) 256 x 256 pixels each, are drawn (“rendered”) from a map database.

If you currently use Google Maps, you’ll be using Google’s map tiles, hosted at google.com. Because the OpenStreetMap Foundation is a non-profit organisation with limited resources, you can’t just slot in the tiles from openstreetmap.org as a replacement (see the [Tile Usage Policy](https://operations.osmfoundation.org/policies/tiles/){: target=blank}). Instead, you can:

* Generate your own tiles, by downloading the free OSM map database and rendering them;

* Or use a third-party supplier (some of whom charge, some are free)

The OSM map database is called planet.osm. The full database and regular update files are both available at [planet.openstreetmap.org](http://planet.openstreetmap.org/){: target=blank}.

Rendering your own tiles gives you complete control over their appearance. You can customise the maps to appear any way you like. Alternatively, third-party suppliers have OSM expertise and may have ready-prepared map styles that you can use.

### Raster Tiles or Vector Tiles

Raster tiles and vector tiles are two distinct approaches to representing and serving map data. Each has its own advantages and use cases. Let's explore the differences between raster tiles and vector tiles to understand their strengths and limitations.

**Raster Tiles**

Raster tiles are essentially images or pictures of map data. They are pre-rendered at various zoom levels and stored as discrete image files. Here are some key characteristics of raster tiles:

* Raster tiles represent map data as a grid of pixels. Each tile is a static image that depicts a portion of the map at a specific zoom level.
* Raster tiles have a fixed appearance as they are generated with predefined styles. To change the map's visual representation, new tiles need to be rendered, which can be computationally intensive.
* Raster tiles can have larger file sizes compared to vector tiles because they store pixel-level details for each tile, resulting in higher storage requirements and slower download times.
* Raster tiles are well-suited for displaying complex cartographic styles, such as topographic maps or satellite imagery, where fine details are important.
* Raster tiles offer limited interactivity options, primarily limited to basic zooming and panning. Interacting with individual map features or dynamically modifying the map's appearance is challenging.

**Vector Tiles**

Vector tiles, on the other hand, represent map data as a collection of geometric features, such as points, lines, and polygons. Here are the distinguishing features of vector tiles:

* Vector tiles store map data as individual geometries and attributes. These geometries can be scaled, rotated, and restyled in real-time, providing more flexibility and customization options.
* Vector tiles allow for dynamic styling and modification of map features. Styles can be changed on the fly, including colors, line widths, label placements, and other visual properties.
* Vector tiles are generally smaller compared to raster tiles. Since they store only geometric data and attributes, they require less storage space and result in faster transfer times.
* Vector tiles require less bandwidth for transfer, since only the necessary map data is sent to the client. This is particularly advantageous for mobile applications or areas with limited internet connectivity.
* Vector tiles enable rich interactivity and real-time rendering. Users can interact with individual map features, perform dynamic queries, and apply custom styles based on attributes, offering a more interactive and personalized map experience.

### Use Cases

The choice between raster tiles and vector tiles depends on the specific use case and requirements. Here are some scenarios where each type excels:

**Raster Tiles**

* Aesthetically detailed maps, such as topographic maps or satellite imagery.
* Static maps that don't require real-time interactivity or frequent updates.
* Cases where map data is relatively stable and doesn't need frequent modifications or styling changes.

**Vector Tiles**

* Dynamic maps that require real-time customization and interactivity, such as user-driven styling or filtering.
* Mobile applications or areas with limited bandwidth or storage capacity.
* Maps with frequently changing data, where updates need to be reflected in real-time.

Both raster tiles and vector tiles have their merits depending on the use case. Raster tiles are suitable for detailed visualization and static map styles, while vector tiles excel in dynamic styling, interactivity, and efficient data transfer. By understanding the differences between these tile types, you can make an informed decision when choosing the most appropriate tile format for your specific mapping needs.

## The API/library

There is no single canonical library: you can choose whichever suits your needs best. The two most popular JavaScript libraries for displaying OSM tiles are:

* OpenLayers – powerful and long-established

* Leaflet – lightweight and easy-to-learn

APIs are also available for mobile platforms, such as [Route-Me](https://github.com/route-me/route-me){: target=blank} (iOS) and [osmdroid](https://github.com/osmdroid/osmdroid){: target=blank} (Android).

## The licence

Unlike commercial providers’ data, OpenStreetMap is ‘open data’. The map data is available to you free-of-charge, with the freedom to copy and modify. OSM’s licence is the [Open Database Licence](http://opendatacommons.org/licenses/odbl/summary/){: target=blank}.

Your obligations are:

* Attribution. You must credit OpenStreetMap with the same prominence that would be expected if you were using a commercial provider. See [OSM’s copyright guidelines](http://www.openstreetmap.org/copyright){: target=blank}.

* Share-Alike. When you use any adapted version of OSM’s map data, or works produced with it, you must also offer that adapted database under the ODbL.
  
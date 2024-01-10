---
title: Getting started with OpenLayers
lang: en
---

# {{ title }}

## Introduction

[OpenLayers](http://openlayers.org/){: target=blank} is a complete JavaScript library for embedding maps. It uses a permissive BSD open-source license so can be incorporated into any site without legal worries. Its source code is available on [GitHub](https://github.com/openlayers/ol3/){: target=blank}.

<!-- Here, we restrict ourselves to a small, self-contained example and refer to the official [tutorials](http://openlayers.org/en/latest/examples/){: target=_blank} and [API](http://openlayers.org/en/latest/apidoc/){: target=_blank} for elaborate usages. -->

## Getting started

A map deployment example using the OpenLayers library is detailed in the [Quick Start](https://openlayers.org/doc/quickstart.html){: target=blank} section of the OpenLayers documentation. It requires a bit of effort to install the [node.js](https://nodejs.org/){: target=blank} framework and install the library, so we won't go into that here.

## Further links

You want to …

* use a different background? → Openlayers natively supports [TMS](https://en.wikipedia.org/wiki/Tile_Map_Service){: target=blank}  and [WMS](https://en.wikipedia.org/wiki/Web_Map_Service){: target=blank} . See [Openlayers official examples](http://openlayers.org/en/latest/examples/){: target=blank} and [the API](http://openlayers.org/en/latest/apidoc/){: target=blank} to see which options are supported.
* add all of your company's locations? → Provide them as [GeoJSON](http://geojson.org/){: target=blank} and [include them](http://openlayers.org/en/latest/examples/select-features.html){: target=blank} in the map.
* use a different map projection? → OpenLayers support all Proj4 projections as long as you include [proj4js](http://proj4js.org/){: target=blank} JavaScript library. Moreover, [client-side raster reprojection](http://openlayers.org/en/latest/examples/reprojection-by-code.html){: target=blank} is supported, so you can use OpenStreetMap tiles in your local projection.
  
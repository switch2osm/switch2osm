---
layout: docs
title: Getting started with OpenLayers
permalink: /using-tiles/getting-started-with-openlayers/
---

## Introduction

[OpenLayers](http://openlayers.org/) is a complete JavaScript library for embedding maps. It uses a permissive BSD open-source license so can be incorporated into any site without legal worries. Its source code is available on [GitHub](https://github.com/openlayers/ol3/).

Here, we restrict ourselves to a small, self-contained example and refer to the official [tutorials](http://openlayers.org/en/latest/examples/) and [API](http://openlayers.org/en/latest/apidoc/) for elaborate usages.

## Getting started

Copy the following content to a file `openlayers.html` and open it in your browser:

{% highlight html %}
{% include openlayers.html %}
{% endhighlight %}

# Further links
You want to …

* use a different background? → Openlayers natively supports [TMS](https://en.wikipedia.org/wiki/Tile_Map_Service) and [WMS](https://en.wikipedia.org/wiki/Web_Map_Service). See [Openlayers official examples](http://openlayers.org/en/latest/examples/) and [the API](http://openlayers.org/en/latest/apidoc/) to see which options are supported.
* add all of your company's locations? → Provide them as [GeoJSON](http://geojson.org/) and [include them](http://openlayers.org/en/latest/examples/select-features.html) in the map.
* use a different map projection? → OpenLayers support all Proj4 projections as long as you include [proj4js](http://proj4js.org/) JavaScript library. Moreover, [client-side raster reprojection](http://openlayers.org/en/latest/examples/reprojection-by-code.html) is supported so you can use OpenStreetMap tiles in your local projection.

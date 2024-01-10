---
title: Getting started with Leaflet
---

# {{ title }}

## Introduction

[Leaflet](http://leafletjs.com/){: target=blank} is a lightweight JavaScript library for embedding maps. It uses a permissive BSD open-source license so can be incorporated into any site without legal worries. Its source code is available on [GitHub](http://github.com/Leaflet/Leaflet){: target=blank}.

Here, we restrict ourselves to a small, self-contained example and refer to the official [tutorials](http://leafletjs.com/examples.html){: target=blank} and [documentation](http://leafletjs.com/reference.html){: target=blank} for elaborate usages.

## Getting started

Copy the following content to a file [leaflet.html](leaflet.html){: target=_blank} and open it in your browser:

``` html title="leaflet.html"
--8<-- "docs/en/using-tiles/leaflet.html"
```

See the official website for a detailed explanation of the code. [^1]

[^1]: Quick Start&nbsp;– <https://leafletjs.com/examples/quick-start/>{: target=blank}

## Further links

You want to …

* use a different background? → Leaflet natively supports [TMS](https://en.wikipedia.org/wiki/Tile_Map_Service{: target=blank}) and [WMS](https://en.wikipedia.org/wiki/Web_Map_Service){: target=blank}. See [there](http://leafletjs.com/reference.html#tilelayer){: target=blank} which options are supported in Leaflet.
* add all of your company's locations? → Provide them as [GeoJSON](http://geojson.org/){: target=blank} and [include them](http://leafletjs.com/examples/geojson.html){: target=blank} in the map.
* use a different map projection? → Use the [Proj4Leaflet](https://github.com/kartena/Proj4Leaflet){: target=blank} plugin.

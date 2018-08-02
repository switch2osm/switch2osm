---
layout: docs
title: Getting started with Leaflet
permalink: /using-tiles/getting-started-with-leaflet/
---

# Introduction
[Leaflet](http://leafletjs.com/) is a lightweight JavaScript library for embedding maps. It uses a permissive BSD open-source license so can be incorporated into any site without legal worries. Its source code is available on [GitHub](http://github.com/Leaflet/Leaflet).

Here, we restrict ourselves to a small, self-contained example and refer to the official [tutorials](http://leafletjs.com/examples.html) and [documentation](http://leafletjs.com/reference.html) for elaborate usages.

# Getting started
Copy the following content to a file `leaflet.html` and open it in your browser:

{% highlight html %}
{% include leaflet.html %}
{% endhighlight %}

# Further links
You want to …

* use a different background? → Leaflet natively supports [TMS](https://en.wikipedia.org/wiki/Tile_Map_Service) and [WMS](https://en.wikipedia.org/wiki/Web_Map_Service). See [there](http://leafletjs.com/reference.html#tilelayer) which options are supported in Leaflet.
* add all of your company's locations? → Provide them as [GeoJSON](http://geojson.org/) and [include them](http://leafletjs.com/examples/geojson.html) in the map.
* use a different map projection? → Use the [Proj4Leaflet](https://github.com/kartena/Proj4Leaflet) plugin.

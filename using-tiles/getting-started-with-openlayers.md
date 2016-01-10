---
layout: page
title: Getting started with OpenLayers
permalink: /using-tiles/getting-started-with-openlayers/
---

OpenLayers has long been the standard choice for embedding a browsable OpenStreetMap view into a webpage. A mature and comprehensive library (over 400k of minimised JavaScript), it has a moderate learning curve but is capable of many applications beyond a simple “slippy map”: its features include full projection support, vector drawing, overview maps, and much more.
On this page we explain how to create a very simple embedded map, but there are many more examples on OpenLayers.org showing the full capabilities of the software.

# A simple embedded map

Paste the following into a new HTML file to get up and running with OpenLayers

    <!DOCTYPE HTML>
    <html>
    <head>
        <title>OpenLayers Basic Example</title>

        <script src="http://www.openlayers.org/api/OpenLayers.js"></script>
        <script>
          function init() {
            map = new OpenLayers.Map("mapdiv");
            var mapnik = new OpenLayers.Layer.OSM();
            map.addLayer(mapnik);

            var lonlat = new OpenLayers.LonLat(-1.788, 53.571).transform(
                new OpenLayers.Projection("EPSG:4326"), // transform from WGS 1984
                new OpenLayers.Projection("EPSG:900913") // to Spherical Mercator
              );

            var zoom = 13;

            var markers = new OpenLayers.Layer.Markers( "Markers" );
            map.addLayer(markers);
            markers.addMarker(new OpenLayers.Marker(lonlat));

            map.setCenter(lonlat, zoom);
          }
        </script>

        <style>
        #mapdiv { width:350px; height:250px; }
        div.olControlAttribution { bottom:3px; }
        </style>

    </head>

    <body onload="init();">
        <p>My HTML page with an embedded map</p>
        <div id="mapdiv"></div>
    </body>
    </html>

This example shows how to initialise a map object which will appear within a div on your HTML page. A LonLat object is created to represent the centre point of the map. Try playing with the latitude, longitude values. A call to ‘transform’ sorts out the projections, and we use this same location to place a marker.

# Downloading OpenLayers
The above example also shows how, with a script tag, you can reference the OpenLayers javascript hosted remotely at openlayers.org . There are advantages and disadvantages to this approach. The alternative is to download OpenLayers and host it yourself alongside your HTML.

You can download a zip file from openlayers.org which contains many files, only some of which are needed. In fact you might use only OpenLayers.js a single file of compacted javascript.

The ‘theme’ and ‘image’ directories are also needed if you wish to self-host all of the required resources. You can configure visual aspects of OpenLayers using those files. The ‘lib’ directory has the source javascript before it was compacted into a single file, but you can actually run OpenLayers in ‘multi-file’ mode from these. That can be a good idea as you develop with the OpenLayers API, since browser error reports will take you to line numbers showing something more meaningful.

However you chose to work with OpenLayers, the library is fully open-source (under a modified BSD license) and can be used for free in your projects and commercial products.
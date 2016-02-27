---
layout: page
title: Getting started with Leaflet
permalink: /using-tiles/getting-started-with-leaflet/
---

[Leaflet](http://leafletjs.com/) is a new JavaScript library for embedding maps which is quickly gaining popularity. Simpler and smaller than OpenLayers, it is a good choice for those with fairly standard embedding needs.

On this page, we explain how to create a simple embedded map with markers using Leaflet, as shown on a recent switcher to OpenStreetMap, property site PlotBrowser.com.

# Downloading Leaflet
You can download Leaflet from its own site at [leafletjs.com](http://leafletjs.com/). The source is available as a .zip, or you can fork it on GitHub.

Leaflet uses a permissive BSD open-source licence so can be incorporated into any site without legal worries.

Copy the `dist/` directory to the place on your webserver where the embedding page will be served from, and rename it `leaflet/`.

# Embedding Leaflet in your page
For ease of use, we’ll create a .js file with all our map code in it. You can of course put this inline in the main page if you like. Create this page in your leaflet/ directory and call it `leafletembed.js`.

Use the following code in `leafletembed.js`:

{% highlight javascript %}
var map;
var ajaxRequest;
var plotlist;
var plotlayers=[];

function initmap() {
  // set up the map
  map = new L.Map('map');

  // create the tile layer with correct attribution
  var osmUrl='http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  var osmAttrib='Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors';
  var osm = new L.TileLayer(osmUrl, {minZoom: 8, maxZoom: 12, attribution: osmAttrib});		

  // start the map in South-East England
  map.setView(new L.LatLng(51.3, 0.7),9);
  map.addLayer(osm);
}
{% endhighlight %}

Then include it in your embedding page like this:

{% highlight html %}
<link rel="stylesheet" type="text/css" href="leaflet/leaflet.css" />
<script type="text/javascript" src="leaflet/leaflet.js"></script>
<script type="text/javascript" src="leaflet/leafletembed.js"></script>
{% endhighlight %}

Add an appropriately-sized `div` called `map` to your embedding page; then, finally, add some JavaScript to your embedding page to initialise the map, either at the end of the page or on an `onload` event: `initmap();`

{% highlight html %}
<body>
  <div id="map"></div>
  <script>initmap();</script>
</body>
{% endhighlight %}

Congratulations; you have embedded your first map with Leaflet.

# Showing markers as the user pans around the map

There are several excellent examples on the Leaflet website. Here we’ll demonstrate one more common case: showing clickable markers on the map, where the marker locations are reloaded from the server as the user pans around.

First, we’ll add the standard AJAX code of the type you’ll have seen a thousand times before. At the top of the initmap function in leafletembed.js, add:

{% highlight javascript %}
// set up AJAX request
ajaxRequest=getXmlHttpObject();
if (ajaxRequest==null) {
  alert ("This browser does not support HTTP Request");
  return;
}
{% endhighlight %}

then add this new function elsewhere in leafletembed.js:

{% highlight javascript %}
function getXmlHttpObject() {
  if (window.XMLHttpRequest) { return new XMLHttpRequest(); }
  if (window.ActiveXObject)  { return new ActiveXObject("Microsoft.XMLHTTP"); }
  return null;
}
{% endhighlight %}

Next, we’ll add a function to request the list of markers (in JSON) for the current map viewport:

{% highlight javascript %}
function askForPlots() {
  // request the marker info with AJAX for the current bounds
  var bounds=map.getBounds();
  var minll=bounds.getSouthWest();
  var maxll=bounds.getNorthEast();
  var msg='leaflet/findbybbox.cgi?format=leaflet&bbox='+minll.lng+','+minll.lat+','+maxll.lng+','+maxll.lat;
  ajaxRequest.onreadystatechange = stateChanged;
  ajaxRequest.open('GET', msg, true);
  ajaxRequest.send(null);
}
{% endhighlight %}

This talks to a serverside script which simply returns a JSON array of the properties we want to display on the map, like this:

{% highlight json %}
[{"name":"Tunbridge Wells, Langton Road, Burnt Cottage",
  "lon":"0.213102",
  "lat":"51.1429",
  "details":"A Grade II listed five bedroom wing in need of renovation."
}]
{% endhighlight %}

When this arrives, we’ll clear the existing markers and display the new ones, creating a rudimentary pop-up window for each one:

{% highlight javascript %}
function stateChanged() {
  // if AJAX returned a list of markers, add them to the map
  if (ajaxRequest.readyState==4) {
    //use the info here that was returned
    if (ajaxRequest.status==200) {
      plotlist=eval("(" + ajaxRequest.responseText + ")");
      removeMarkers();
      for (i=0;i<plotlist.length;i++) {
        var plotll = new L.LatLng(plotlist[i].lat,plotlist[i].lon, true);
        var plotmark = new L.Marker(plotll);
        plotmark.data=plotlist[i];
        map.addLayer(plotmark);
        plotmark.bindPopup("<h3>"+plotlist[i].name+"</h3>"+plotlist[i].details);
        plotlayers.push(plotmark);
  		}
  	}
  }
}

function removeMarkers() {
  for (i=0;i<plotlayers.length;i++) {
    map.removeLayer(plotlayers[i]);
  }
  plotlayers=[];
}
{% endhighlight %}

Finally, let’s wire this into the rest of our script. After we’ve added the map in  initmap , let’s ask for the first load of markers, and set up an event to do this every time the map is panned. Add this just at the end of   initmap :

{% highlight javascript %}
function initmap() {
  // ...
  // map.addLayer(osm);
  askForPlots();
  map.on('moveend', onMapMove);
}

// then add this as a new function...
function onMapMove(e) { askForPlots(); }
{% endhighlight %}

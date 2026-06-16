---
layout: docs
title: Adding custom data with MapLibre GL
---

# {{ title }}

## Introduction

When displaying a map, you often need to show custom data. This could be data you want to highlight on a page, data that requires more detail than a standard basemap, or data that isn't included in a basemap. This tutorial shows how to add more detail than what's in a standard basemap.

## Building a page with a map

by following the instructions in the [getting started with MapLibre guide](/using-tiles/getting-started-with-maplibre.md). This will give us a starting point of a `style` directory with build scripts and a `release` directory that we can copy to our web host.

!!! info "Hosting"
    Some browser features only work if the page is served from a secure location, such as a website with HTTPS or your computer. We're assuming you have a web host for "example.com" that lets you serve files from disk and that you know how to copy files to the web host.

## Building your custom data

To add more information to our map, we'll start by creating a file that includes all the new features we want to display. In this example, we'll be working with trees and forests from OpenStreetMap.

## Downloading data

Initially, we'll load only a small amount of test data. Other download locations are available, but `download.geofabrik.de` has a wide range of options. In this example we'll download the data for England, which is currently about 1.5 GB.

```sh
cd ~/style
mkdir -p data
cd data
wget https://download.geofabrik.de/europe/united-kingdom/england-latest.osm.pbf
```

## Installing Tilemaker

[Tilemaker](https://tilemaker.org/) is software for creating DIY vector tiles from OpenStreetMap data. There are lots of different ways to run it, but we're going to follow their [Getting Started guide](https://github.com/systemed/tilemaker?tab=readme-ov-file#getting-started) and run it in Docker.

!!! warning "Building from source"
    An alternative way to install Tilemaker is from source. This is [well documented](https://github.com/systemed/tilemaker/blob/master/docs/INSTALL.md) but can be tricker to get running than docker.

### Installing Docker

If you don't already have Docker installed, there are lots of "how-tos" around - see for example [here](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-debian-10){: target=_blank}. If you are on Debian 13 or Ubuntu 22.04 or later you can install it with

```sh
sudo apt install docker.io
```

### Running Tilemaker in Docker

We'll test that Tilemaker runs correctly with

```sh
docker run -it --rm -v ~/style:/style ghcr.io/systemed/tilemaker:master --help
```

This should return a message with information about tilemaker options.

## Writing a Tilemaker configuration

Tilemaker configurations tell tilemaker what vector layers to create and what data to put in them. For more complex examples you can read [tilemaker's documentation](https://github.com/systemed/tilemaker/blob/master/docs/CONFIGURATION.md).

In our case, we want to define three layers:
1. a first layer with points that correspond to single trees,
2. a second layer with lines that are rows of trees, and
3. wooded areas.

Save the config file below as `trees.json` in the `~/style/` directory

```json title="trees.json"
--8<-- "docs/assets/using-tiles/trees.json"
```

The configuration file defines the names of the layers and what zooms they are generated for, but not what goes in them. That is the job of the process file.

### Process file

We now need to write a lua process file that defines how to look at OSM objects and put them into the vector layers we just defined.

Tilemaker lets us define what keys we are interested in as a mechanism of speeding up processing. OSM objects are only processed when they match one of these tags or keys.

```lua
node_keys = { "natural=tree" }
way_keys = { "natural=tree_row", "natural=wood", "landuse=forest" }
```

Next we need to declare `node_function`, a function that will be called for every node matching `node_keys`. It needs to check for a natural=tree tag and, if it finds it, add a point to the `tree_points` layer. We'll also add the name of the tree and the type of leaves it has.

```lua
function node_function(node)
    -- natural=tree on a node is a tree point
    if Find("natural") == "tree" then
        -- Adds the node being processed as a point
        Layer("tree_points", false)
        -- Sets the name attribute to the value of the name tag
        Attribute("name", Find("name"))
        -- Sets the leaf_type attribute to the value of the leaf_type tag
        Attribute("leaf_type", Find("leaf_type"))
    end
end
```

Tree rows and wooded areas are both found on ways so we need to write a `way_function` that handles both. We need to add lines to the lines layer where there is a `natural=tree_row` tag and when there are tags indicating a wooded area, add an area to the areas layer. The second paramater of the `Layer` function indicates if a way should be added as a line or area.

```lua
function way_function(node)
    -- Set a local variable to the value of the natural tag because it is being used multiple times
    local natural = Find("natural")
    -- natural=tree_row on a way is a line of trees
    if natural == "tree_row" then
        -- Add the way as a linestring
        Layer("tree_lines", false)
        -- Sets the leaf_type attribute to the value of the leaf_type tag
        Attribute("leaf_type", Find("leaf_type"))
    end
    if natural == "wood" or Find("landuse") == "forest" then
        -- Add the way as a polygon
        Layer("tree_areas", true)
        -- Sets the leaf_type attribute to the value of the leaf_type tag
        Attribute("leaf_type", Find("leaf_type"))
    end
end
```

Combining these results gives us a file we will save as `trees.lua` in the `~/style/` directory


```lua title="trees.lua"
--8<-- "docs/assets/using-tiles/trees.lua"
```

## Building tiles

We will now build the tiles with tilemaker

```sh
cd ~/style
docker run -it --rm -v ~/style:/style ghcr.io/systemed/tilemaker:master --config /style/trees.json --process /style/trees.lua --input /style/data/england-latest.osm.pbf --output /style/release/trees.pmtiles
```

This creates a pmtiles archive in `release/` that contains the tree tiles.

## Changing the style

To show this new data, we have to edit the style. A maplibre style consists of some metadata, a list of sources, and a list of layers. Each layer has an ID, specifies what source to use, and has styling instructions. A [full guide to MapLibre styles](https://maplibre.org/maplibre-style-spec/) is outside of the scope of this guide, so we're just going to make some simple modifications.

We're going to make these modifications to the `style.json` file in a text editor.

The first step is adding a new source. We add the following object to the `sources` list.

```json
"trees": {
  "type": "vector",
  "url": "pmtiles://https://example.com/trees.pmtiles"
}
```

Next we need to add the forests. We start by finding the layer with `"id": "land-forest"`. Because we're using our own source for trees, we remove this layer and replace it in the style.json file.

The original layer is

```json
{
    "source": "versatiles-shortbread",
    "id": "land-forest",
    "type": "fill",
    "source-layer": "land",
    "filter": [
    "all",
    [
        "in",
        "kind",
        "forest"
    ]
    ],
    "paint": {
    "fill-color": "rgb(102,170,68)",
    "fill-opacity": {
        "stops": [
        [
            7,
            0
        ],
        [
            8,
            0.1
        ]
        ]
    }
    }
}
```

We replace it with these layers

```json
{
    "source": "trees",
    "id": "tree_areas",
    "type": "fill",
    "source-layer": "tree_areas",
    "paint": {
    "fill-color": "rgb(102,170,68, 0.5)"
    }
},
{
    "source": "trees",
    "id": "tree_lines",
    "type": "line",
    "source-layer": "tree_lines",
    "paint": {
    "line-color": "rgb(102,170,68, 0.5)",
    "line-width": 4
    }
},
{
    "source": "trees",
    "id": "tree_points",
    "type": "circle",
    "source-layer": "tree_points",
    "paint": {
    "circle-color": "rgb(102,170,68, 0.5)",
    "circle-radius": 4
    }
},
{
    "source": "trees",
    "id": "tree_points-trunk",
    "type": "circle",
    "source-layer": "tree_points",
    "paint": {
    "circle-color": "rgb(145, 108, 81, 0.8)",
    "circle-radius": 1.7
    }
}
```

## Showing the results

To show the results we a HTML file that loads MapLibre and the PMTiles plugin to show the map. This file is based off of the [getting started with MapLibre](/using-tiles/getting-started-with-maplibre.md) guide.

```html title="maplibre.html"
--8<-- "docs/assets/using-tiles/maplibre-trees.html"
```

## Common Problems

### HTTP Range Requests

This web host must support HTTP Range Requests. All commonly found dedicated HTTP servers do but some tools to serve from your local computer might not.

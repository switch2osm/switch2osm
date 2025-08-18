---
layout: docs
title: Getting started with MapLibre GL
---

# {{ title }}

## Introduction

[MapLibre GL JS](https://maplibre.org/maplibre-gl-js/docs/){: target=blank} is a TypeScript library that uses WebGL for embedding maps. It uses a permissive BSD open-source license so can be incorporated into any site without legal worries. Its source code is available on [GitHub](https://github.com/maplibre/maplibre-gl-js/){: target=blank}.

Here, we restrict ourselves to a small, self-contained example and refer to the official [tutorials](https://maplibre.org/maplibre-gl-js/docs/examples/){: target=blank} and [documentation](https://maplibre.org/maplibre-gl-js/docs/API/){: target=blank} for elaborate usages.

## Getting started

Displaying a map requires three things: a data source, map style, and site to host them all. We're going to use the OpenStreetMap Foundation Shortbread tiles, the Versatiles Colorful style, and a website you'll run.

!!! info "Hosting"
    Some browser features require a page is served from a secure location. This is a website with HTTPS or your local computer. We're assuming you have a web host for "example.com" that lets you serve files from disk and that you know how to copy files to the web host.

## Software Installation

We need a recent version of node.js. If your operating system has a recent version you can use its packages, but we're going to assume you need to install it.

There's many ways to install what we need, but we'll be using nvm, a version manager for node.js. To install this, run the command

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

If your operating system does not have curl, check its instructions for how to install it.

Close and reopen your terminal to load nvm.

## Building the style

We're going to be using the VersaTiles colorful style, a basic style which uses Shortbread tiles. The Shortbread vector tile schema is a general-purpose vector tile schema for OpenStreetMap data. To get the tiles we're going to use the OpenStreetMap Foundation's Shortbread tile service. 

!!! info ""
    Usage of the vector tiles is governed by the [vector tile usage policy](https://operations.osmfoundation.org/policies/vector/). This web page will meet the requirements, but there is no SLA or guarantee with the vector tile service. If you need these you should host them yourself or use a commercial host.

A style requires a style definition, sprite files for any icons, and glyph files for any fonts. We're going to build the style definition to point to our own sprite and glyph files.

Start by making a new directory to store the files you'll be creating. We'll call it "style" in the documentation, but it can be whatever you want. Inside this directory we're going to build all the files we need and place them in a "release" subdirectory

```sh
mkdir style
cd style
mkdir release
```

Building sprites and glyphs can be a complicated process, but because we don't need to modify them we're going to use pre-built ones

```sh
curl -OL https://github.com/versatiles-org/versatiles-style/releases/download/v5.7.0/sprites.tar.gz
mkdir -p release/sprites
tar -C release/sprites -xzf sprites.tar.gz 

curl -OL https://github.com/versatiles-org/versatiles-fonts/releases/download/v2.0.0/fonts.tar.gz
mkdir -p release/fonts
tar -C release/fonts -xzf fonts.tar.gz
```

We now need to build the style so it uses our new copy of the glyphs and sprites.

Assuming you're using nvm, install and use the LTS version of node with

```sh
nvm install --lts
nvm use --lts
```

If you're using a different method of installing node, you don't need to do this.

Copy the following content to a file [build.ts](build.ts){: target=_blank}, but change "example.com" to point to your domain name

``` ts title="build.ts"
--8<-- "docs/en/using-tiles/build.ts"
```

In the same directory install TypeScript and the VersaTiles styles, then run the script above to build your style.
```sh
npm install tsx @versatiles/style@~5.7.0
node_modules/.bin/tsx build.ts
```

Copy the following content to a file [maplibre.html](maplibre.html){: target=_blank} and put it in the release directory

``` html title="maplibre.html"
--8<-- "docs/en/using-tiles/maplibre.html"
```

## Releasing the style

Upload the contents of the "release" directory to your web host. Common ways of doing this are with a scp or rsync command, or through a web interface.

## Common problems

### `node_modules/.bin/tsx build.ts` fails to run

If you have an outdated version of node, this command will fail to run. You can fix this by installing an up-to-date version with nvm as described earlier.

### Nothing loads on the web page

Open your browser's Developer Tools and look at the console. The most common cause of nothing displaying is incorrect URLs.

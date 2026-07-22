---
layout: docs
title: Self-hosting vector tiles
lang: en
---

# {{ title }}

This guide builds a small vector basemap from OpenStreetMap data, serves it
from your own machine, and displays it in a web page. It uses:

* [Planetiler](https://github.com/onthegomap/planetiler){: target=_blank} to
  turn an OpenStreetMap extract into an MBTiles archive using the
  [Shortbread](https://shortbread.geofabrik.de/){: target=_blank} tile schema;
* [Martin](https://maplibre.org/martin/){: target=_blank} to serve the archive;
* [MapLibre GL JS](https://maplibre.org/maplibre-gl-js/docs/){: target=_blank}
  and the VersaTiles style to draw the vector data in a browser.

The style relies on the Shortbread schema, not on Martin. Martin is one of
several servers that can provide compatible tiles. This separation lets you
change the tile generator, server, or map renderer independently.

This example uses Monaco so that the first build is small. Larger extracts
need substantially more disk space, memory, and processing time. Planetiler
creates a snapshot: to incorporate later OpenStreetMap edits, generate a new
archive and replace the old one.

## Requirements

Install [Docker](https://docs.docker.com/engine/install/){: target=_blank} and
make sure the daemon is running. You also need `curl`, Node.js 18 or later,
and at least 1 GB of free disk space for this example.

Create a working directory:

```sh
mkdir -p ~/vector-tiles/data
cd ~/vector-tiles
```

## Generate Shortbread tiles

Planetiler includes a maintained Shortbread profile. Download the profile so
you can inspect the schema and keep the exact version used for a build:

```sh
curl -L \
  https://raw.githubusercontent.com/onthegomap/planetiler/main/planetiler-custommap/src/main/resources/samples/shortbread.yml \
  -o shortbread.yml
```

Run Planetiler. It downloads the Monaco OpenStreetMap extract and the water
polygon data referenced by the profile, then writes an MBTiles archive:

```sh
docker run --rm \
  --user="$(id -u):$(id -g)" \
  -e JAVA_TOOL_OPTIONS="-Xmx1g" \
  -v "$PWD:/data" \
  ghcr.io/onthegomap/planetiler:latest \
  /data/shortbread.yml \
  --download \
  --area=monaco \
  --output=/data/data/shortbread.mbtiles
```

The `--area` value is a Geofabrik area name. For another region, use a name
accepted by Planetiler or replace it with `--osm-path=/data/data/your-file.osm.pbf`
after placing an extract in the `data` directory. Planetiler recommends free
disk space of five to ten times the input PBF size and free memory of at least
half its size.

Check that the archive was created:

```sh
ls -lh data/shortbread.mbtiles
```

## Serve the archive with Martin

Start Martin with the archive mounted read-only:

```sh
docker run --detach \
  --name martin \
  --restart unless-stopped \
  -p 3000:3000 \
  -v "$PWD/data:/files:ro" \
  ghcr.io/maplibre/martin:1.12.0 \
  /files/shortbread.mbtiles
```

Martin normally derives the source ID `shortbread` from the filename. Inspect
the catalog instead of assuming it when adapting this guide:

```sh
curl -s http://localhost:3000/catalog | python3 -m json.tool
curl -s http://localhost:3000/shortbread | python3 -m json.tool
```

The second URL is the source's TileJSON document. Tiles are available at
`http://localhost:3000/shortbread/{z}/{x}/{y}`.

If Martin does not start, inspect its logs with `docker logs martin`. A name
collision from an earlier attempt can be removed with `docker rm martin` after
the old container has stopped.

## Build a compatible style

Vector tiles contain geometry and attributes, not colours or labels. A style
must expect the same layer names and attributes as the tile schema. The
VersaTiles colourful style understands Shortbread.

Create the style directory and download its reproducible sprite release:

```sh
mkdir -p style/release/sprites
cd style
curl -LO https://github.com/versatiles-org/versatiles-style/releases/download/v5.10.0/sprites.tar.gz
tar -C release/sprites -xzf sprites.tar.gz
```

Create `build.ts` with the following content. The `tiles` URL is the Martin
endpoint created above.

```ts title="build.ts"
--8<-- "docs/assets/serving-tiles/self-hosted-vector-build.ts"
```

Install the style package and build `release/style.json`:

```sh
npm install tsx @versatiles/style@~5.10.0
node_modules/.bin/tsx build.ts
```

Create `release/index.html` with this content:

```html title="index.html"
--8<-- "docs/assets/serving-tiles/self-hosted-vector-map.html"
```

Serve the directory from a second terminal:

```sh
cd ~/vector-tiles/style/release
python3 -m http.server 8080
```

Open <http://localhost:8080/>. You should see Monaco rendered from the archive
on your machine. Browser developer tools will show tile requests going to
`localhost:3000`.

## Moving beyond the example

For a public deployment, place Martin behind a reverse proxy that terminates
HTTPS, sets an appropriate cache policy, and applies any authentication or
rate limits you need. Serve the web page, style, sprites, fonts, and tiles over
HTTPS to avoid mixed-content failures. Keep the OpenStreetMap attribution
visible, and review the attribution requirements of the tile schema and style.

An MBTiles or PMTiles archive is a good fit for periodic snapshot builds. If
you need changes to appear continuously, use an import and update workflow
that maintains PostGIS, then expose suitable tables or tile-producing
functions through Martin. That is a different operational model from the
static Planetiler workflow in this guide.

See the [Martin file-source documentation](https://maplibre.org/martin/sources-files/){:
target=_blank} for named sources and PMTiles, and the [Planetiler
documentation](https://github.com/onthegomap/planetiler#usage){: target=_blank}
for larger extracts and resource planning.

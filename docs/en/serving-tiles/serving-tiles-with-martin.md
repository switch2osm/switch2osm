---
layout: docs
title: Serving tiles with Martin
lang: en
---

# {{ title }}

[Martin](https://maplibre.org/martin/){: target=_blank} is an open source tile server written in Rust, optimised for speed and heavy traffic. It is a different shape of tile server from the rest of this section: instead of a rendering chain of Apache, mod_tile and Mapnik, Martin is a single binary. It can

* serve **vector tiles** generated on the fly from a [PostGIS](https://postgis.net/){: target=_blank} database, automatically discovering tables and functions with geometry columns, and
* serve tiles from pre-built **MBTiles** and **PMTiles** archives, and from GeoJSON files.

Two situations where it fits well:

* You already followed one of the "manually building a tile server" guides and have OSM data in a PostGIS database. Martin can serve vector tiles straight from that database without any re-import.
* You want to serve a pre-built tile archive (for example an extract from [Geofabrik](https://download.geofabrik.de/){: target=_blank} or tiles you generated yourself) without a rendering stack at all.

Martin is licensed under Apache-2.0 OR MIT.

## Installing Martin

Martin packages itself several ways; pick the one that suits your system.

On Ubuntu (x86_64) you can install the `.deb` from the [GitHub releases](https://github.com/maplibre/martin/releases){: target=_blank}:

```sh
wget https://github.com/maplibre/martin/releases/latest/download/debian-x86_64.deb
sudo apt install ./debian-x86_64.deb
```

On macOS, Martin is in Homebrew:

```sh
brew install martin
```

Or run it from the published Docker image instead:

```sh
docker run -p 3000:3000 ghcr.io/maplibre/martin --help
```

Check the installation:

```sh
martin --version
```

The [Martin installation documentation](https://maplibre.org/martin/installation/){: target=_blank} lists further options, including binaries for other platforms.

## Serving vector tiles from PostGIS

If you have a PostgreSQL database with PostGIS and OSM data in it — for example the `gis` database created by the manual guides in this section — point Martin at it with a connection string. Martin connects, finds every table and function with a geometry column, and publishes each one as a tile source:

```sh
martin postgres://username:password@localhost:5432/gis
```

Martin listens on port 3000 by default; use `--listen-addresses 0.0.0.0:8080` to change that. The connection string supports the usual PostgreSQL options; Martin's documentation on [PostgreSQL connections](https://maplibre.org/martin/pg-connections/){: target=_blank} covers SSL, pooling and the `DATABASE_URL` environment variable.

On startup Martin prints the sources it found. Browse `http://your.server.ip.address:3000/catalog` to list them as JSON; each source has a [TileJSON](https://github.com/mapbox/tilejson-spec){: target=_blank} endpoint at `http://your.server.ip.address:3000/SOURCE_NAME`, and tiles at:

`http://your.server.ip.address:3000/SOURCE_NAME/{z}/{x}/{y}`

To keep the configuration — for example to name sources explicitly, or to run Martin from a service unit — generate a config file from what auto-detection found:

```sh
martin postgres://username:password@localhost:5432/gis --save-config config.yaml
martin --config config.yaml
```

### Generating vector tiles in bulk

Martin ships a companion tool, `martin-cp`, which copies tiles from any of its sources into an MBTiles file. Combined with a PostGIS database this lets you build a tile archive for an area once, and serve it back from the archive afterwards — useful where you want the tiles but not a live database:

```sh
martin-cp --min-zoom 0 --max-zoom 14 --bbox=min_lon,min_lat,max_lon,max_lat \
    --output-file region.mbtiles \
    postgres://username:password@localhost:5432/gis
```

## Serving a pre-built MBTiles or PMTiles archive

With no database at all, Martin can serve a tile archive directly. Point it at the file:

```sh
martin region.mbtiles
```

and it becomes a tile source named after the file, e.g. `http://your.server.ip.address:3000/region/{z}/{x}/{y}`. The same works for `.pmtiles` files, including ones served over HTTP. The companion `mbtiles` tool can inspect, validate and copy MBTiles files:

```sh
mbtiles summary region.mbtiles
```

## Viewing your tiles

The tile URLs above work in any web mapping library. To see them on a map, follow the [Leaflet](/using-tiles/getting-started-with-leaflet.md) or [MapLibre GL](/using-tiles/getting-started-with-maplibre.md) guides, using Martin's tile URL. Vector tile sources additionally need a style to be rendered; see the notes on styles below.

## More information

* Martin [documentation](https://maplibre.org/martin/){: target=_blank}: running with the [CLI](https://maplibre.org/martin/run-with-cli/){: target=_blank} or a [configuration file](https://maplibre.org/martin/config-file/){: target=_blank}, and behind [nginx](https://maplibre.org/martin/run-with-nginx/){: target=_blank} or [Apache](https://maplibre.org/martin/run-with-apache/){: target=_blank}.
* Martin serves styles and generates sprites and font glyphs too — see the [styles documentation](https://maplibre.org/martin/sources-styles/){: target=_blank}.
* The source repository is [maplibre/martin](https://github.com/maplibre/martin){: target=_blank}.

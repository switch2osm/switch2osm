---
layout: page
title: Tilemill and OpenStreetMap-Carto on Windows
permalink: /tilemill-windows/
---

# Installing Tilemill and OpenStreetMap-Carto on Windows

## Introduction

The following step-by-step procedure can be used to install a working development environment of openstreetmap-carto exploiting Tilemill on a Windows PC. It has been tested on Windows 7 32-bit and Windows 7 64-bit.

At the time of writing, Tilemill is the most appropriate tool to be used on Windows (win32 and win64). Alternative software like Kosmtik (the preferred tool for openstreetmap-carto) needs Mapnik 3.5 and recent versions of node-mapnik, which at the moment cannot be installed on Windows. Mapbox needs customization (there is no immediate procedure to convert project.yaml of Openstreetmap-carto to a format valid for Mapbox). Command line tools are not comfortable.

Warning: Tilemill hosts a very old version of Mapnik/node-mapnik. Even if you should accomplish its installation on Windows through this manual, consider that:

- you will not be able to exploit the latest features of Mapnik;
- you might even fail to load the openstreetmap-carto project if someone meanwhile added a new Mapnik feature which is not supported by Tilemill.

## Installation

Prefer direct Internet connection for the installation, avoiding the need of a proxy. At the end of the installation procedure (and DB population), Tilemill can run openstreetmap-carto off-line.

### Check OS architecture

Before all, check whether your computer is running a 32-bit version or a 64-bit version of the Windows operating system: https://support.microsoft.com/en-us/kb/827218

When downloading the software reported in this procedure, always verify that you are selecting the appropriate Windows architecture: 32-bit (x86) or 64-bit (x64).

### Install Tilemill

Install Tilemill; the latest working version at the moment should be
http://tilemill.s3.amazonaws.com/dev/TileMill-v0.10.1-291-g31027ed-Setup.exe

Even if Tilemill has a GitHub repository (https://github.com/mapbox/tilemill) including the most recent updates, with Windows it is suggested to proceed with the standard setup, which automatically installs and configures Mapnik/node-mapnik. A procedure to upgrade Tilemill and Mapnik over Windows without recompiling is not currently documented.

### Install PostgreSQL

Download PostgreSQL (avoid using beta versions as also PostGis shall be needed (check first the PostGis compatibility with the version you are going to download):

http://www.enterprisedb.com/products-services-training/pgdownload#windows

For instance: postgresql-9.5.3-1-windows-x64.exe (for a Windows 64 bit system)

### Configure PostgreSQL

Use the following configuration steps for PostgreSQL:

- Password: postgres_007%
- Port: 5432 (default)
- Default locale
- Next (install)
- Launch StackBuilder at exit
- Select the server (PostgreSQL at port 5432)
- Expand Categories, Spatial Extensions; enable PostGIS (select the latest version for the appropriate architecture, 32 or 64 bit)

### Install PostGis

Installation of PostGis:

- Select Components to install: PostGis (don't create spatial database)
- Would you like us to register the GDAL_DATA environment variable for you? No
- Raster drivers are disabled by default? ... No
- Enable out db rasters? No

Open pgAdmin and store the above mentioned password.

Open a CMD (Command Prompt). Change directory (cd) to %programfiles%\PostgreSQL\*version*\bin (e.g., cd C:\Program Files\PostgreSQL\9.5\bin) and run these commands:

```batchfile
setx PGHOST localhost
setx PGPORT 5432
setx PGUSER postgres
setx PGPASSWORD postgres_007%
```

The above mentioned commands are needed by Tilemill to connect to the PostgreSQL db with the default settings of openstreetmap-carto.

Notice that 'setx' should be used to configure variables (defining variables with 'set' before invoking tilemill.exe will not work).

### Create the *gis* database, needed by openstreetmap-carto

```batchfile
psql --help (to verify that psql works)
psql -h localhost -U postgres -c "create database gis"
psql -h localhost -U postgres -c "\connect gis"
psql -h localhost -U postgres -d gis -c "CREATE EXTENSION postgis"
psql -h localhost -U postgres -d gis -c "CREATE EXTENSION hstore"
```

Notice that, in order to get compatibility with project.yaml, the dbname shall remain "gis" and cannot be changed via the variables.

NOTE: To drop the database, in case of full data refresh, you can perform:

`psql -h localhost -U postgres -c "drop database gis"`

Then all creation commands must be issued again.

### Download OpenStreetMap data

There are many ways to download the OSM data.

It's probably easiest to grab an PBF of OSM data from [Mapzen](https://mapzen.com/metro-extracts/) or [geofabrik](http://download.geofabrik.de/).

One method is directly with your browser. Check this page:
http://wiki.openstreetmap.org/wiki/Downloading_data#Choose_your_region

Alternatively, JOSM can be used (install it from https://josm.openstreetmap.de/. You should also have the java runtime installed and updated). Select the area to download the OSM data: JOSM menu, File, Download From OSM; tab Slippy map; drag the map with the right mouse button, zoom with the mouse wheel or Ctrl + arrow keys; drag a box with the left mouse button to select an area to download. The Continuous Download plugin is also suggested: http://wiki.openstreetmap.org/wiki/JOSM/Plugins/continuosDownload. When the desired region is locally available, select File, Save As, `<filename>.osm`. Give it a valid file name and check also the appropriate directory where this file is saved.

### Install osm2pgsql

Download osm2pgsql for Windows (http://wiki.openstreetmap.org/wiki/Osm2pgsql#Windows):

https://lists.openstreetmap.org/pipermail/dev/2013-February/026525.html

https://github.com/openstreetmap/osm2pgsql/issues/17

Check the appropriate version running on your OS architecture.

Put it to the same directory of the saved .osm file

### Install Python

Install Python 2.7 from https://www.python.org/downloads/

Run the setup: when it comes to the point of adding environment variables, say Yes.

Python is needed to convert project.yaml (from openstreetmap-carto) to project.mml (that can be opened by Tilemill). It is also needed to download the shapefiles.

### Install openstreetmap-carto

Open https://github.com/gravitystorm/openstreetmap-carto and press "Download ZIP"

Save it to `%USERPROFILE%\Documents\MapBox\project\`
(this path should conform to Tilemill Settings: `~\Documents\MapBox`)

Unzip the downloaded file (e.g., to `project\openstreetmap-carto-master`)

### osm2pgsql

Tilemill/openstreetmap-carto will render data which are stored in the *gis* database.

Use osm2pgsql to upload the locally available OpenStreetMap data to PostgreSQL. Local data could be in .osm format or .pbf, which is a compressed version of .osm.

Open a CMD

Change directory to `%USERPROFILE%\Documents\MapBox\project\openstreetmap-carto-master`

Check that Python works with: `python -V` (otherwise: `set PATH=%PATH%;<python directory>`).

To create db tables, populate them and create some index run the following:

```batchfile
cd <directory where you saved the .osm file and osm2pgsql>
osm2pgsql.exe -H localhost -d gis -U postgres -s -c -G -k -C 800 -S %USERPROFILE%\Documents\MapBox\project\openstreetmap-carto-master\openstreetmap-carto.style <filename>.osm
```

If a script file named `openstreetmap-carto.lua` is available in the openstreetmap-carto folder, add the parameter `--tag-transform-script <lua script>`. The command would become the following:

```batchfile
osm2pgsql -H localhost -d gis -U postgres -s -c -G -k -C 800 -S %USERPROFILE%\Documents\MapBox\project\openstreetmap-carto-master\openstreetmap-carto.style --tag-transform-script %USERPROFILE%\Documents\MapBox\project\openstreetmap-carto-master\openstreetmap-carto.lua <filename>.osm (or <filename>.osm.pbf)
```

Notes:

- substitute `<filename>.osm` with the saved .osm file (e.g., produced through JOSM); also `<filename>.pbf` can be used;
- to refresh the data, simply relaunch the osm2pgsql command (as the default option is to recreate the tables); anyway Tilemill shall be closed before (as well as any other client accessing the db). You can also drop the database, recreate it with the psql commands shown before and do again osm2pgsql;
- try removing the –s option when managing big .osm files, if the import operation is too slow;
- try reducing -C 800 to a smaller cache size (MB) if you verify memory errors.

If still you fail to connect to the database, try editing `%programfiles%\PostgreSQL\*version*\data\pg_hba.conf` and changing all `md5` with `trust`

Note to create the indexes (which could slightly speed up db access):

```
%USERPROFILE%\Documents\MapBox\project\openstreetmap-carto-master\scripts\indexes.py | "C:\Program Files\PostgreSQL\<version>\bin\psql" -h localhost -U postgres -d gis
```

alternatively:

```
"c:\Program Files\PostgreSQL\<version>\bin\psql" -h localhost -U postgres -d gis -f indexes.sql
```

### Install Shapeindex

Create a folder to place shapeindex.exe.

Download the Win32 ZIP package of Mapnik from http://mapnik.org/pages/downloads.html, open it with 7Zip (install it from http://www.7-zip.org) and extract `shapeindex.exe`; move this file and all related DLL files to the previously created folder. This is needed by `get-shapefiles.py` to speed-up the access to the shapefiles. Notice that the DLL files can be found in the lib directory of the ZIP file; all them have to be saved to the bin directory together with `shapeindex.exe`.

Set the PATH appropriately:

```
set PATH=%PATH;<shapeindex folder>
```

Verify that the shapeindex command works with `shapeindex –V`

Now run:

```
cd %USERPROFILE%\Documents\MapBox\project\openstreetmap-carto-master
scripts\get-shapefiles.py
```

Wait for the completion of the entire process (e.g., "done!")

OpenStreetMap Carto uses a YAML file for defining layers. TileMill does not directly support YAML, so make edits to the YAML file then run `scripts\yaml2mml.py`.

```
python -m pip install --upgrade pip
```

Check that pip works with `pip –V`. (Check also `Scripts\pip` if pip is not found).

```
pip install pyyaml
```

Now you are ready to run `scripts\yaml2mml.py` after a modification to `project.yaml`, so that a valid `project.mml` is created.

```
scripts\yaml2mml.py
```

### Final checks

Revise all points.

Check in detail the content of [INSTALL.md](https://github.com/gravitystorm/openstreetmap-carto/blob/master/INSTALL.md).

### Tilemill

Start Tilemill. The application needs a few seconds to start, so be patient.

Select project *Openstreetmap Carto*

Give Tilemill the time to render the map (this might take many seconds); zoom out to the entire world shape (zoom level 1), then progressively zoom into the region where you downloaded the map data. You might use the double click and wait for the next zoom level to appear.

On the right pane, it is normal that only the first 4 tabs are displayed; this is an issue of the installed old Tilemill version. (Check https://github.com/mapbox/tilemill/pull/2184)

You shouldn't use the text editor built-in to TileMill: it doesn't work with the number of .mss files in the style. Instead, hide the right pane and use an external text editor.

Tilemill automatically refreshes the rendering upon any file change, including all mss and project.mml (notice that also a change in project.yaml activates a new rendering; anyway, remember to also run `scripts\yaml2mml.py`).

Note: to open Tilemill with a browser:
- http://127.0.0.1:20009
- http://127.0.0.1:20009/#/project/openstreetmap-carto

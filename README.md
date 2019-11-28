# switch2osm #

This repository is the content for switch2osm.org.

See the issues for things to work on.

## Content principles ##

* Covers from first principles to technical how-tos.

  It's easy to be focused on technical guides (setting up a rendering server), but most users are more interested in how to switch their very small website from Google, so care more about how the monolithic Google Maps "API" is replaced by multiple components, and how to set up their webpage to use a free tile service.

* Avoids lock-in with specific vendors or services
* Does not require specific external services, aside from OpenStreetMap itself

  We do not promote anything which can result in lock-in to a specific vendor, so guides need to be usable without relying on a third party. It's okay to use something as an example (e.g. tile.osm.org) where there are plenty of alternatives, but not if there are few alternatives or the service being used cannot be reproduced.

  Exceptions are
  * planet.openstreetmap.org, for OSM data itself
  * openstreetmapdata.com, for coastlines and other preprocessed data
  * Natural Earth and other well-used public data sources

## Content technical needs ##

* Uses multiple steps to build understanding, rather than one shell script

  A single script which completes a long series of tasks can be useful, but builds no understanding of what is being done. As soon as someone wants to change the slightest aspect, they find they haven't gained any knowledge. These scripts also tend to be fragile.

* Does not present bad practices, even in a demo

  People will copy/paste short demos. Don't use bad practices that work just because the demo is simple.

* Avoids building from source

  Building from source adds significant complications while helping little with understanding.

* Avoids binary blobs that cannot be reproduced

  The instructions should be able to be adapted to other OSes or distributions. This means that the user should be able to build from source if they need to. OS packaging systems and PPAs meet this.

* Uses forwards-compatible portable instructions

  This is hard to do, but instructions should be crafted to work in the future, and to the extent possible, on future distributions. e.g. use output of config programs rather than hardcoding paths.

* Uses OS distribution methods for software when possible

  Use apt-get or homebrew. With PPAs, it should be possible to get all software installed this way.

## Contribute
The webpage is built using [GitHub Pages](https://pages.github.com/). To compile your changes, execute
* `bundle install --path .vendor/bundle`
* `bundle exec jekyll serve`
and open http://127.0.0.1:4000/ in the browser

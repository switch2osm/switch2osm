---
layout: page
title: Інші приклади використання
lang: uk
---

# {{ title }}

Ми зосереджувались на тайлах, проте, OpenStreetMap&nbsp;– це унікальне джерело інформації&nbsp;– дає нам доступ до ‘сирих’ даних, які можна використовувати як для створення будь-якого застосунку з геопозиціюванням, так і для роботи з просторовими даними. Ось кілька речей для початку; повний перелік доступний в [OpenStreetMap Wiki](http://wiki.openstreetmap.org/wiki/Frameworks){: target=_blank}.

## Загальні інструменти

* [Osmosis](http://wiki.openstreetmap.org/wiki/Osmosis){: target=_blank}&nbsp;– універсальний застосунок Java для завантаження даних OSM в базу даних. Більшість застосунків певним чином використовують Osmosis для завантаження даних OSM з метою подальшого використання.
* [Osmium](http://wiki.openstreetmap.org/wiki/Osmium){: target=_blank}&nbsp;– гнучкий інструмент, що швидко набув відомості, пропонує багато різних налаштувань, є альтернативою Osmosis.
* [Mapbox Studio](https://www.mapbox.com/mapbox-studio/){: target=_blank}&nbsp;– збірка інструментів для створення ‘векторних тайлів’, які можуть використовуватись як на сервері, так і на клієнті.

## Служби геокодування

* [Gisgraphy](https://www.gisgraphy.com){: target=_blank}&nbsp;– геокодер з відкритими сирцями, який надає API/вебсервіси для прямого та зворотнього геокодування з автодоповненням, інтерполяцією, з відхиленням розташування, пошуком поруч, все це можна запускати як офлайн, так і у вигляді веб-служби. Він надає можливість імпортувати дані не тільки з OpenStreetMap, але й з Openadresses, Geonames та інших джерел.
* [Nominatim](https://nominatim.org){: target=_blank}&nbsp;– програмне забезпечення, що використовується для геокодінгу на сайті OpenStreetMap (місце ↔ координати).
* [OpenCage](https://opencagedata.com/){: target=_blank}&nbsp;– надає API для геокодінгу, що агрегує дані з Nominatim та інших відкритих джерел.
* [OSMNames](https://osmnames.org/){: target=_blank} – містить перелік місць з OpenStreetMap. Доступний для завантаження. Посортований. З описом територій (bbox) та ієрархій. Придатний для геокодування.

## Рушії та сервіси прокладання маршрутів

* [OSRM](http://project-osrm.org/){: target=_blank}&nbsp;– швидкий рушій прокладання маршрутів, який працює з даними з OSM.
* [Graphhopper](https://github.com/graphhopper/graphhopper/){: target=_blank}&nbsp;– швидкий рушій прокладання маршрутів написаний на Java, що використовує невеликий обсяг памʼяті.
* [Valhalla](https://valhalla.readthedocs.io/en/latest/){: target=_blank}&nbsp;– навігаційний рушій для автомобілів та громадського транспорту написаний на C++.
* Публічні API для прокладання маршрутів на основі даних OSM від [GraphHopper](https://www.graphhopper.com/products/){: target=_blank}, [MapQuest Open](http://open.mapquestapi.com/directions/){: target=_blank} та [Mapbox](https://www.mapbox.com/directions/){: target=_blank}.
* Спеціалізовані API прокладання маршрутів, до яких належить [CycleStreets](https://www.cyclestreets.net/api/){: target=_blank} (сервіс прокладання маршрутів для велосипедистів у Великій Британії та за її межами)

## Бібліотеки для векторних мап (mobile)

* Бібліотеки для Android: [MapLibre Android SDK](https://maplibre.org/projects/maplibre-native/){: target=_blank}, [Mapbox Android SDK](https://www.mapbox.com/android-sdk/){: target=_blank}, [mapsforge](http://mapsforge.org/){: target=_blank}, [Nutiteq Maps SDK](https://developer.nutiteq.com/){: target=_blank}, [Skobbler Android SDK](http://developer.skobbler.com/){: target=_blank} та [Tangram ES](https://github.com/tangrams/tangram-es/){: target=_blank}.
* Бібліотеки для iOS: [MapLibre iOS SDK](https://maplibre.org/projects/maplibre-native/){: target=_blank}, [Mapbox iOS SDK](https://www.mapbox.com/ios-sdk/){: target=_blank}, [Nutiteq Maps SDK](https://developer.nutiteq.com/){: target=_blank}, [Skobbler iOS SDK](http://developer.skobbler.com/){: target=_blank} та [Tangram ES](https://github.com/tangrams/tangram-es/){: target=_blank}.

## Бібліотеки для векторних мап (Web)

* [MapLibre GL JS](https://maplibre.org/maplibre-gl-js/docs/){: target=_blank}, [Mapbox GL JS](https://www.mapbox.com/mapbox-gl-js/){: target=_blank} та [Tangram](http://tangrams.github.io/tangram/){: target=_blank}&nbsp;– працюють з векторними тайлами, створеними з даних OSM, використовуючи WebGL для покращення продуктивності.

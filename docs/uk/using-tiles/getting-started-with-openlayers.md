---
layout: docs
title: Використання OpenLayers
lang: uk
---

# {{ title }}

## Вступ

[OpenLayers](http://openlayers.org/){: target=blank}&nbsp;– це багатофункціональна бібліотека JavaScript для показу мап. Вона розповсюджується на умовах дозвільної Ліцензії BSD для коду з відкритими сирцями, тож її можна використовувати на будь-якому сайті без побоювань порушення юридичних норм. Сирці бібліотеки доступні на [GitHub](https://github.com/openlayers/ol3/){: target=blank}.

Радимо ознайомитись з детальними [прикладами](http://openlayers.org/en/latest/examples/){: target=blank} та [описом API](http://openlayers.org/en/latest/apidoc/){: target=blank} з офіційного сайту для детальнішого опрацювання.

## Швидкий старт

Зразок розгортання мап з використанням бібліотеки OpenLayers докладно описаний в розділі [Quick Start](https://openlayers.org/doc/quickstart.html){: target=blank} документації OpenLayers. Він вимагає докладання трохи зусиль, повʼязаних зі встановленням платформи [node.js](https://nodejs.org/){: target=blank} та встановлення на неї бібліотеки, тож ми не будемо тут на цьому зупинятись.

## Додаткові посилання

Якщо ви бажаєте:

* використовувати інше тло?&nbsp;→ Openlayers має підтримку [TMS](https://uk.wikipedia.org/wiki/Tile_Map_Service){: target=blank} та [WMS](https://uk.wikipedia.org/wiki/Web_Map_Service){: target=blank}. Ознайомтесь з [прикладами](http://openlayers.org/en/latest/examples/){: target=blank} з офіційного сайту Openlayers та [документацією до API](http://openlayers.org/en/latest/apidoc/){: target=blank}, щоб дізнатись про наявні можливості.
* додати розташування всіх офісів вашої компанії?&nbsp;→ Збережіть координати у файл [GeoJSON](http://geojson.org/){: target=blank} та [додайте їх](http://openlayers.org/en/latest/examples/select-features.html){: target=_blank} на мапу.
* використовувати іншу картографічну проєкцію?&nbsp;→ OpenLayers підтримує всі проєкції Proj4 у разі використання JavaScript бібліотеки [proj4js](http://proj4js.org/){: target=blank}. Крім того, підтримується [зміна проєкції на стороні клієнта](http://openlayers.org/en/latest/examples/reprojection-by-code.html){: target=blank} для растрових тайлів, тож ви можете використовувати тайли з OpenStreetMap у вашій власній проєкції.

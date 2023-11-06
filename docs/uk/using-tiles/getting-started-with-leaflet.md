---
title: Використання Leaflet
---

# {{ title }}

## Вступ

[Leaflet](http://leafletjs.com/){: target=blank}&nbsp;– легковісна бібліотека JavaScript для показу мап. Вона розповсюджується на умовах дозвільної Ліцензії BSD для коду з відкритими сирцями, тож її можна використовувати на будь-якому сайті без побоювань порушення юридичних норм. Сирці бібліотеки доступні на [GitHub](http://github.com/Leaflet/Leaflet){: target=blank}.

Тут, ми обмежимо себе невеличким самодостатнім прикладом, що демонструє можливості бібліотеки. Радимо ознайомитись з детальними [прикладами](http://leafletjs.com/examples.html){: target=blank} та [документацією](http://leafletjs.com/reference.html){: target=blank} з офіційного сайту для більш детального опрацювання.

## Початок роботи

Перенесіть наступний код у файл, наприклад `leaflet.html`, і відкрийте його у вашому вебоглядачі або перейдіть за посиланням, щоб відкрити файл [leaflet.html](leaflet.html){: target=_blank}:

``` html title="leaflet.html"
--8<-- "docs/uk/using-tiles/leaflet.html"
```

Докладні пояснення щодо коду дивіться на офіційному сайті. [^1]

[^1]: Швидкий старт&nbsp;– <https://leafletjs.com/examples/quick-start/>{: target=blank}

## Додаткові посилання

Якщо ви бажаєте:

* використовувати інше тло?&nbsp;→ Leaflet має підтримку [TMS](https://uk.wikipedia.org/wiki/Tile_Map_Service){: target=blank} та [WMS](https://uk.wikipedia.org/wiki/Web_Map_Service){: target=blank}. Подивіться [тут](http://leafletjs.com/reference.html#tilelayer){: target=blank}, які інші можливості має Leaflet.
* додати розташування всіх офісів вашої компанії?&nbsp;→ Збережіть координати у файл [GeoJSON](http://geojson.org/){: target=blank} та [додайте їх](http://leafletjs.com/examples/geojson.html){: target=blank} на мапу.
* використовувати іншу картографічну проєкцію?&nbsp;→ Втулок [Proj4Leaflet](https://github.com/kartena/Proj4Leaflet){: target=blank} допоможе вам в цьому.

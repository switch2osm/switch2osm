---
layout: docs
title: Оновлення бази даних правками з OpenStreetMap
lang: uk
---

# Оновлення бази даних правками з OpenStreetMap за допомогою PyOsmium

Щодня зʼявляються мільйони нових оновлень на мапі, щоб не допустити, щоб ваша мапа стала «застарілою», ви можете регулярно оновлювати дані, які використовуються для створення тайлів.

З переходом на останню версію osm2pgsql (версія 1.4.2 та свіжіше) оновлювати дані стало на багато простіше ніж раніше. Відповідні версії розповсюджується в складі Ubuntu 22.04, 24.04 та Debian 12, їх можна встановити слідуючи [інструкції з osm2pgsql.org](https://osm2pgsql.org/doc/install.html){: target=_blank}.

Простіший, але менш гнучкий метод оновлення даних,&nbsp;– використання `osm2pgsql-replication` (див [тут](/serving-tiles/updating-as-people-edit-osm2pgsql-replication.md)). Тут для оновлення даних в нашій базі ми будемо використовувати `PyOsmium` для оновлення даних, які ми отримали з Geofabrik хвилинними оновленнями з <https://planet.openstreetmap.org>{: target=_blank}.

## Переконайтесь, що ви отримуєте повідомлення для відлагодження

На цьому етапі було б дуже корисно побачити результат процесу генерації тайлів, щоб побачити, що тайли, позначені як dirty, обробляються. Типово в останніх версіях mod_tile це вимкнено. Для увімкнення відкрийте

```sh
sudo nano /usr/lib/systemd/system/renderd.service
```

Якщо цього ще немає нижче `[Service]`, додайте:

```ini
Environment=G_MESSAGES_DEBUG=all
```

Потім виконайте ці команди, щоб перезавантажити конфігурацію:

```sh
sudo systemctl daemon-reload
sudo systemctl restart renderd
sudo systemctl restart apache2
```

## Налаштування реплікації

Візьміть до уваги, скрипт що перевіряє актуальність тайлів очікує що згенеровані тайли знаходяться в `/var/cache/renderd/`. Якщо у `/etc/renderd.conf` зазначене інше місце, внесіть відповідні зміни перед початком використання скрипту. Оскільки тека "/var/cache/renderd/" майже завжди присутня, ми також будемо використовувати її для потреб `pyosmium`.

Для потреб цього керівництва ми вважатимемо, що ви завантажили дані до вашої бази наступним чином:

```sh
sudo -u _renderd \
    osm2pgsql -d gis --create --slim  -G --hstore \
    --tag-transform-script \
        ~/src/openstreetmap-carto/openstreetmap-carto.lua \
    -C 3000 --number-processes 4 \
    -S ~/src/openstreetmap-carto/openstreetmap-carto.style \
    ~/data/greater-london-latest.osm.pbf
```

Дані для завантаження були отримані зі сторінки [Greater London](http://download.geofabrik.de/europe/united-kingdom/england/greater-london.html){: target=_blank}, на якій зазначено, щось схоже на "… and contains all OSM data up to 2023-07-02T20:21:43Z" (… містить всі дані OSM станом на …). Ми будемо використовувати цю дату для налаштування реплікації:

```sh
sudo mkdir /var/cache/renderd/pyosmium
sudo chown _renderd /var/cache/renderd/pyosmium
sudo mkdir /var/log/tiles
sudo chown _renderd /var/log/tiles
cd /var/cache/renderd/pyosmium
sudo apt install pyosmium
sudo -u _renderd pyosmium-get-changes -D 2023-07-02T20:21:43Z -f sequence.state -v
```

Останній рядок створює файл `sequence.state`. Дата в цім рядку має збігатись з датою даних, завантажених раніше.

## Використання "trim_osc.py" для обмеження завантаження тільки спеціально визначеною територією

(рекомендується якщо вам потрібно оновлювати не всю планету, а тільки певний регіон)

Ми використовуватимемо скрипт `trim_osc.py` для обрізання оновлень, які ми отримуємо з OpenStreetMap.org, так щоб залишались тільки оновлення для потрібної нам території. Це потрібно, щоб наша база postgres не розросталась через дані, які нам не потрібні. Встановимо потрібні залежності використовуючи будь-який обліковий запис вашої системи (не-root).

```sh
cd ~/src
git clone https://github.com/zverik/regional
chmod u+x ~/src/regional/trim_osc.py

sudo apt install python3-shapely python3-lxml
```

## Оновлення даних

Скрипт, який виконує оновлення даних ви можете взяти [звідси](https://raw.githubusercontent.com/SomeoneElseOSM/mod_tile/switch2osm/call_pyosmium.sh){: target=_blank}. Ви можете покласти його до `/usr/local/sbin`. Але він потребує певних змін:

* Якщо ви не використовуєте `trim_osc.py`, вилучить відповідний розділ ("Trim the downloaded changes").

* Якщо ви все ж таки використовуєте `trim_osc.py`, переконайтесь що змінна TRIM_BIN вказує на цей скрипт, а TRIM_REGION_OPTIONS містить параметри потрібної вам території (в скрипті зараз це Британія разом з Ірландією).

* Параметри для `osm2pgsql --append` потрібно змінити відповідно до потужності вашого сервера (розмір пам'яті, кількість потоків й таке інше)

* Параметри, що передаються до `render_expired` також мають бути налаштовані (скільки рівнів масштабування потрібно обробляти, і що робити із `dirty` тайлами на кожному рівні)

Скрипт, що показує відмінності між поточними даними у вашій базі з даними та даними на https://planet.openstreetmap.org/ можна знайти [тут](https://raw.githubusercontent.com/SomeoneElseOSM/mod_tile/switch2osm/pyosmium_replag.sh){: target=_blank}. Цей скрипт створено зі скрипту `mod_tile`, який постачається у вигляді прикладу в сирцях mod_tile. `pyosmium_replag` показує відставання від основної бази в секундах; `pyosmium_replag -h` показує відставання від основної бази в годинах (якщо менше, то у хвилинах та секундах). Рекомендується його також покласти до `/usr/local/sbin`. Не забудьте дати скриптам дозвіл на виконання.

Для запуску скрипту вручну:

```sh
sudo -u _renderd /usr/local/sbin/call_pyosmium.sh
```

Після запуску, скрипт створить робочі файли, також ви побачите докладну інформацію про його роботу у `/var/cache/renderd/pyosmium`. По завершенню роботи ви маєте побачити такий звіт:

```log
Pyosmium update started:  Mon Jul 3 11:15:36 PM UTC 2023
Filtering newchange.osc.gz
Importing newchange.osc.gz
2023-07-03 23:17:44  osm2pgsql took 45s overall.
Expiring tiles

Total for all tiles rendered
Meta tiles rendered: Rendered 0 tiles in 1.54 seconds (0.00 tiles/s)
Total tiles rendered: Rendered 0 tiles in 1.54 seconds (0.00 tiles/s)
Total tiles in input: 2334224
Total tiles expanded from input: 305839
Total meta tiles deleted: 0
Total meta tiles touched: 0
Total tiles ignored (not on disk): 305839
Database Replication Lag: 1 day(s) and 1 hour(s)
```

Ви можете налаштувати обсяг даних, які завантажуються за один запит до сервера, параметром `-s` в `pyosmium-get-changes`. Розмір зазначається в Мб, типово скрипт завантажуватимете 20 Мб, якщо не зазначити обсяг явним чином&nbsp;– 100 Мб за раз.

Скрипт можна додати до розкладу `crontab` облікового запису `_renderd`:

```sh
sudo -u _renderd crontab -e
```

вкажіть:

```sh
*/5 *  *   *   *     /usr/local/sbin/call_pyosmium.sh >> /var/log/tiles/run.log
```

Буде виконуватись перевірка, чи працює скрипт, і якщо ні запускатись із вказаною частотою; тут кожні 5 хвилин.

Рекомендується очистити прапор "pyosmium is running" під час перезапуску `renderd`. Щоб зробити це:

 ```sh
sudo nano /usr/lib/systemd/system/renderd.service
```

додайте:

```ini
ExecStartPre=rm -f /var/cache/renderd/pyosmium/call_pyosmium.running
```

до розділу "[Service]". Та перезапустіть службу:

```sh
sudo systemctl daemon-reload
sudo systemctl restart renderd
```

Також корисно використовувати прапорець "osm2pgsql-replication is running", щоб зупинити реплікацію під час реімпорту бази даних — не починайте реімпорт, якщо прапорець встановлено, і встановіть його під час реімпорту, щоб зупинити реплікацію після цього.

## Налаштування munin

У разі використання munin для отримання звітів про активність `mod_tile` та `renderd`, ви можете налаштувати його для показу часу відставання ваших даних від даних з основної бази за допомогою `pyosmium_replag.sh`:

```sh
sudo nano /etc/munin/plugins/replication_delay
```

Сам скрипт можна взяти [тут](https://raw.githubusercontent.com/SomeoneElseOSM/mod_tile/switch2osm/munin/replication_delay_pyosmium){: target=_blank}. Тут використовується `pyosmium_replag.sh`, який ми створили раніше. Після чого перезапустіть службу:

```sh
sudo /etc/init.d/munin-node restart
```

Після деякої паузи, оновіть `http://ip.адреса.вашого.сервера/munin/renderd-day.html`, має показувати графік "Data import lag". Якщо ні, перевірте логи `/var/log/munin`. Якщо вам потрібно більше контексту для розуміння того що відбувається ознайомтесь з документацією [munin](https://guide.munin-monitoring.org/en/latest/develop/plugins/howto-write-plugins.html){: target=_blank}.

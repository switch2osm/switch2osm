---
layout: docs
title: Оновлення бази даних правками з OpenStreetMap
lang: uk
---

# Оновлення бази даних правками з OpenStreetMap за допомогою osm2pgsql

Щодня зʼявляються мільйони нових оновлень на мапі, щоб не допустити, щоб ваша мапа стала «застарілою», ви можете регулярно оновлювати дані, які використовуються для створення тайлів.

З переходом на останню версію `osm2pgsql` (версія 1.4.2 та свіжіше) оновлювати дані стало на багато простіше ніж раніш. Ця версія розповсюджується в складі Ubuntu 22.04, її можна встановити слідуючи [інструкції з osm2pgsql.org](https://osm2pgsql.org/doc/install.html){: target=_blank}. Разом з osm2pgsql йде [osm2pgsql-replication](https://osm2pgsql.org/doc/manual.html#updating-an-existing-database){: target=_blank}&nbsp;– що надає порівняно простий спосіб підтримувати дані в базі в актуальному стані. Більш гнучким способом буде безпосередній виклик `PyOsmium`, [тут докладніше](/serving-tiles/updating-as-people-edit-pyosmium/) про це.

Ви можете налаштувати отримання даних з різних джерел. OpenStreetMap надає можливість отримувати щохвилинні, щогодинні та щоденні оновлення, інші джерела можуть надавати щоденні оновлення, наприклад Geofabrik надає щоденні оновлення регіональних витягів даних, які можна отримати на [download.geofabrik.de](http://download.geofabrik.de/index.html){: target=_blank}.

## Робочий приклад використання даних з Geofabrik

Тут ми покажемо, як отримати дані для Лондона з Geofabrik, як завантажити їх в базу даних та налаштувати отримання оновлень для них. Оновлення від Geofabrik будуть обмежені лише регіоном, який ви завантажили та ці оновлення будуть надходити раз на добу.

Для початку завантажте дані. Використовуйте для цього будь-який звичайний (не root) обліковий запис:

```sh
# якщо не існує теки створіть її
mkdir ~/data
cd ~/data
wget http://download.geofabrik.de/europe/great-britain/england/greater-london-latest.osm.pbf
```

Потім, завантажте дані в базу. Кількість процесів та обсяг пам'яті залежить від потужності вашої системи:

```sh
sudo -u _renderd \
    osm2pgsql -d gis --create --slim  -G --hstore \
    --tag-transform-script \
        ~/src/openstreetmap-carto/openstreetmap-carto.lua \
    -C 3000 --number-processes 4 \
    -S ~/src/openstreetmap-carto/openstreetmap-carto.style \
    ~/data/greater-london-latest.osm.pbf
```

Важлива примітка&nbsp;– скрипт, що перевіряє актуальність даних передбачає що готові тайли знаходяться в теці `/var/cache/renderd/`. Якщо в `/etc/renderd.conf` зазначено інше місце, вам потрібно внести відповідні зміни, щоби скрипт, який ми створимо, мав змогу відстежувати актуальність даних.

Далі, ініціалізуйте реплікацію. Як йдеться [тут](https://osm2pgsql.org/doc/manual.html#updating-an-existing-database){: target=_blank}, завантажте дані з Geofabrik (або [download.openstreetmap.fr](https://download.openstreetmap.fr/){: target=_blank}) потрібні для процесу реплікації (URL, з якого будуть отримуватись оновлення та дату початку).

```sh
sudo -u _renderd \
    osm2pgsql-replication init \
    -d gis \
    --osm-file ~/data/greater-london-latest.osm.pbf
```

В ході виконання команди ви побачите такий вивід:

```log
2022-04-24 23:32:42 [INFO]: Initialised updates for service 'http://download.geofabrik.de/europe/great-britain/england/greater-london-updates'.
2022-04-24 23:32:42 [INFO]: Starting at sequence 3314 (2022-04-23 20:21:53+00:00).
```

В цьому прикладі показана дата відповідає тій, що показувалась на момент написання [на цій сторінці](http://download.geofabrik.de/europe/great-britain/england/greater-london.html){: target=_blank}, коли писався цей текст.

### Створення скрипту для оновлення даних

Тепер ми створимо файл в який ми будемо записувати час, а також скрипти, які будуть робити оновлення даних та позначати потрібні тайли для перестворення. Після того, як ми визначимо тайл що потребує оновлення, ми можемо перегенерувати його, позначивши його як `dirty` або вилучити його.

```sh
sudo mkdir /var/log/tiles
sudo chown _renderd /var/log/tiles
sudo nano /usr/local/sbin/expire_tiles.sh
```

Цей скрипт може виглядати наступним чином:

```sh title="expire_tiles.sh"
#!/bin/bash
render_expired --map=s2o --min-zoom=13 --max-zoom=20 \
    -s /run/renderd/renderd.sock < /var/cache/renderd/dirty_tiles.txt
rm /var/cache/renderd/dirty_tiles.txt
```

Перелік тайлів з ознакою `dirty` має бути доступним для запису службою `_renderd`. Дивіться [сторінку man](https://manpages.ubuntu.com/manpages/jammy/en/man1/render_expired.1.html){: target=_blank}, щоб дізнатись можливі значення для інших параметрів. У прикладі вище, скрип буде перевіряти та перегенерувати всі `dirty` тайли починаючи з масштабу z13 і докладніше. Більш реалістичним прикладом буде щось на кшталт:

```sh title="expire_tiles.sh"
#!/bin/bash
render_expired --map=s2o --min-zoom=13 --touch-from=13 --delete-from=19 --max-zoom=20 \
    -s /run/renderd/renderd.sock < /var/cache/renderd/dirty_tiles.txt
rm /var/cache/renderd/dirty_tiles.txt
```

що збігається з [типовими параметрами](https://github.com/SomeoneElseOSM/mod_tile/blob/switch2osm/openstreetmap-tiles-update-expire#L58){: target=_blank}, які використовуються в скрипті для osmosis&nbsp;- тайли до z12 ігноруються, тайли масштабів від z13 до z19 позначаються як `dirty`, а тайли на 20-у масштаби вилучаються. Приклад можна також знайти [тут](https://github.com/SomeoneElseOSM/mod_tile/blob/switch2osm/expire_tiles.sh){: target=_blank}.

Далі:

```sh
sudo nano /usr/local/sbin/update_tiles.sh
```

скрипт має містити:

```sh title="update_tiles.sh"
#!/bin/bash
osm2pgsql-replication \
    update -d gis \
    --post-processing /usr/local/sbin/expire_tiles.sh \
    --max-diff-size 10  --  \
    -G --hstore \
    --tag-transform-script \
        /home/renderaccount/src/openstreetmap-carto/openstreetmap-carto.lua \
    -C 3000 --number-processes 4 \
    -S /home/renderaccount/src/openstreetmap-carto/openstreetmap-carto.style \
    --expire-tiles=1-20 \
    --expire-output=/var/cache/renderd/dirty_tiles.txt
```

Все в рядку `osm2pgsql-replication update` після `--` є параметрами для osm2pgsql, вони всі стосуються бази даних до якої ми вносимо зміни. Параметри до `--`, `-d gis` вказує назву бази даних, `--max-diff-size 10` зазначає який обсяг даних обробляти за раз, зауважте, що `osm2pgsql-replication` буде постійно завантажувати та оновлювати дані допоки не лишиться даних які потребують обробки. Параметр `--max diff-size` визначає обсяг даних, які обробляються під час кожної ітерації.  Параметр `--post-processing /usr/local/sbin/expire_tiles.sh` викликає інший скрипт.

Надайте скриптам дозволи на виконання:

```sh
sudo chmod ugo+x /usr/local/sbin/update_tiles.sh
sudo chmod ugo+x /usr/local/sbin/expire_tiles.sh
```

### Переконайтесь, що ви отримуєте повідомлення для відлагодження

На цьому етапі було б дуже корисно побачити результат процесу генерації тайлів, щоб побачити, що тайли, позначені як `dirty`, обробляються. Типово в останніх версіях mod_tile це вимкнено. Для увімкнення відкрийте

```sh
sudo nano /usr/lib/systemd/system/renderd.service
```

Якщо немає, додайте наступний рядок

```ini
Environment=G_MESSAGES_DEBUG=all
```

після "[Service]". Далі:

```sh
sudo systemctl daemon-reload
sudo systemctl restart renderd
sudo systemctl restart apache2
```

### Перевірка

Запустіть ще одну сесію та перегляньте повідомлення в журналі:

```sh
sudo tail -f /var/log/syslog
```

ви маєте побачити повідомлення про результати обробки запитів у `mod_tile`.

Виконайте скрипт:

```sh
sudo -u _renderd /usr/local/sbin/update_tiles.sh
```

Якщо оновлень, які очікують на обробку, немає (Geofabrik надає оновлення раз на добу) ви побачите щось схоже на це:

```log
2022-06-05 16:13:48 [INFO]: Using replication service 'http://download.geofabrik.de/europe/great-britain/england/greater-london-updates'. Current sequence 3356 (2022-06-04 20:21:41+00:00).
2022-06-05 16:13:49 [INFO]: Database already up-to-date.
```

Якщо оновлення є, ви побачите таке:

```log
2022-06-05 16:29:32 [INFO]: Using replication service 'http://download.geofabrik.de/europe/great-britain/england/greater-london-updates'. Current sequence 3355 (2022-06-03 20:21:26+00:00).
2022-06-05 16:29:33  osm2pgsql version 1.6.0
2022-06-05 16:29:33  Database version: 14.3 (Ubuntu 14.3-0ubuntu0.22.04.1)
2022-06-05 16:29:33  PostGIS version: 3.2
2022-06-05 16:29:34  Setting up table 'planet_osm_point'
2022-06-05 16:29:34  Setting up table 'planet_osm_line'
2022-06-05 16:29:34  Setting up table 'planet_osm_polygon'
2022-06-05 16:29:34  Setting up table 'planet_osm_roads'
2022-06-05 16:29:51  Reading input files done in 17s.                                     
2022-06-05 16:29:51    Processed 4267 nodes in 7s - 610/s
2022-06-05 16:29:51    Processed 1108 ways in 7s - 158/s
2022-06-05 16:29:51    Processed 4 relations in 3s - 1/s
2022-06-05 16:29:52  Going over 993 pending ways (using 4 threads)
Left to process: 0.....
2022-06-05 16:29:57  Processing 993 pending ways took 5s at a rate of 198.60/s
2022-06-05 16:29:57  Going over 129 pending relations (using 4 threads)
...
```

якщо є тайли з вичерпаним строком придатності з'явиться подібний рядок:

```log
Read and expanded 42700 tiles from list.
render: file:///var/cache/renderd/tiles/s2o/18/17/245/244/200/0.meta
Read and expanded 42800 tiles from list.
```

по завершенню будуть йти підсумки:

```log
Read and expanded 121200 tiles from list.
Read and expanded 121300 tiles from list.
Waiting for rendering threads to finish

Total for all tiles rendered
Meta tiles rendered: Rendered 1 tiles in 18.19 seconds (0.05 tiles/s)
Total tiles rendered: Rendered 64 tiles in 18.19 seconds (3.52 tiles/s)
Total tiles in input: 121357
Total tiles expanded from input: 10766
Total meta tiles deleted: 0
Total meta tiles touched: 0
Total tiles ignored (not on disk): 10765
2022-06-05 16:36:58 [INFO]: Data imported until 2022-06-04 20:21:41+00:00. Backlog remaining: 20:15:17.919969
```

Лог-файл буде десь таким:

```log
Jun  5 16:36:40 ubuntuvm75 renderd[5838]: Data is available now on 1 fds
Jun  5 16:36:40 ubuntuvm75 renderd[5838]: Got incoming connection, fd 5, number 0, total conns 1, total slots 1
Jun  5 16:36:40 ubuntuvm75 renderd[5838]: Data is available now on 1 fds
Jun  5 16:36:40 ubuntuvm75 renderd[5838]: Got incoming request with protocol version 2
Jun  5 16:36:40 ubuntuvm75 renderd[5838]: Got command RenderBulk fd(5) xml(s2o), z(18), x(131008), y(87168), mime(image/png), options()
Jun  5 16:36:40 ubuntuvm75 renderd[5838]: START TILE s2o 18 131008-131015 87168-87175, age 0.04 days
Jun  5 16:36:40 ubuntuvm75 renderd[5838]: Rendering projected coordinates 18 131008 87168 -> -9783.939621|6710559.587216 -8560.947168|6711782.579668 to a 8 x 8 tile
Jun  5 16:36:58 ubuntuvm75 renderd[5838]: DONE TILE s2o 18 131008-131015 87168-87175 in 18.046 seconds
Jun  5 16:36:58 ubuntuvm75 renderd[5838]: Creating and writing a metatile to /var/cache/renderd/tiles/s2o/18/17/245/244/200/0.meta
Jun  5 16:36:58 ubuntuvm75 renderd[5838]: Sending message Done to 5
Jun  5 16:36:58 ubuntuvm75 renderd[5838]: Sending render cmd(3 s2o 18/131008/87168) with protocol version 2 to fd 5
Jun  5 16:36:58 ubuntuvm75 renderd[5838]: Data is available now on 1 fds
Jun  5 16:36:58 ubuntuvm75 renderd[5838]: Failed to read cmd on fd 5
Jun  5 16:36:58 ubuntuvm75 renderd[5838]: Connection 0, fd 5 closed, now 0 left, total slots 1
```

### Щоденне виконання

Скрипт для виконання оновлення можна додати до розкладу crontab облікового запису root. По-перше, змініть `update_tiles.sh`, щоб бачити лише підсумковий результат. Ви можете взяти код [звідси](https://github.com/SomeoneElseOSM/mod_tile/blob/switch2osm/update_tiles.sh){: target=_blank}. Знов таки ж, замініть `renderaccount` на відповідний обліковий запис (не-root), який ви використовуєте.

Додайте в crontab облікового запису root:

```sh
04 04  *   *   *     sudo -u _renderd /usr/local/sbin/update_tiles.sh
```

У цьому прикладі процес запускається о 4:40 кожного ранку. Немає сенсу запускати скрипт частіше ніж один раз на добу, Geofabrik надає оновлення саме з такою періодичністю.

## Використання щохвилинних оновлень з openstreetmap.org

Також можна використовувати оновлення з openstreetmap.org. Вони охоплюють весь світ, через що будуть більшими, ніж набір оновлень за той самий проміжок часу для якогось регіону зі, скажімо напр. Geofabrik. Налаштуємо це

```sh
sudo -u _renderd \
    osm2pgsql-replication init -d gis  \
    --server https://planet.openstreetmap.org/replication/minute
```

у відповідь побачимо

```log
2022-06-05 20:49:21 [INFO]: Initialised updates for service 'https://planet.openstreetmap.org/replication/minute'.
2022-06-05 20:49:21 [INFO]: Starting at sequence 5088118 (2022-06-04 17:11:02+00:00).
```

Дата, з якої почнуться оновлення, визначається шляхом перегляду останнього об’єкта в базі даних, яка зазвичай буде трохи раніше, ніж будь-яка гранична дата «екстракту що містить усі дані OSM». Також доступні щогодинні та щоденні оновлення, тож ви також можете запускати щогодинну або щоденну версії:

```sh
sudo -u _renderd \
    osm2pgsql-replication init -d gis  \
    --server https://planet.openstreetmap.org/replication/hour
```

```sh
sudo -u _renderd \
    osm2pgsql-replication init -d gis  \
    --server https://planet.openstreetmap.org/replication/day
```

Після ініціалізації скористайтесь скриптами з розділу "Створення скрипту для оновлення даних" вище та перевірте їх так само:

```sh
sudo -u _renderd /usr/local/sbin/update_tiles.sh
```

Знов, зауважте, що `osm2pgsql-replication` буде постійно завантажувати дані та оновлювати базу допоки вони є, параметр `--max diff-size` визначає обсяг даних який скрипт буде обробляти за одну ітерацію. По завершенні ви побачите:

```log
2022-06-05 22:30:47 [INFO]: Data imported until 2022-06-05 21:45:42+00:00. Backlog remaining: 0:45:05.948787
```

Скрипт для виконання оновлення може бути змінений, як показано вище, для виводу підсумків у logfile, а також доданий в crontab облікового запити root:

```sh
*/5 *  *   *   *     sudo -u _renderd /usr/local/sbin/update_tiles.sh >> /var/log/tiles/run.log
```

Оскільки ми виконуємо оновлення на основі щохвилинних оновлень, ми можемо запускати скрипт частіше ніж один раз на день; в цьому випадку кожні 5 хв.

Рекомендується очистити прапор "osm2pgsql-replication is running" під час перезапуску `renderd`. Щоб зробити це:

```sh
sudo nano /usr/lib/systemd/system/renderd.service
```

додайте:

```ini
ExecStartPre=rm -f /var/cache/renderd/update_tiles.sh.running
```

до розділу "[Service]". Та перезапустіть службу:

```sh
sudo systemctl daemon-reload
sudo systemctl restart renderd
```

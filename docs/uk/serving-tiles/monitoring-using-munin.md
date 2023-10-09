---
layout: docs
title: Моніторинг за допомогою Munin
lang: uk
---

# {{ title }}

Для моніторингу активності служб `renderd` та `mod_tile` можна використовувати "Munin". Munin доступний на багатьох платформах; ця інструкція була протестована на Ubuntu Linux 22.04 в червні 2022.

Встановимо потрібне програмне забезпечення:

```sh
sudo apt install munin-node munin libcgi-fast-perl libapache2-mod-fcgid
```

Якщо ви подивитесь у `/etc/apache2/conf-available`, ви побачите, що `munin.conf` є символічним посиланням на `../../munin/apache24.conf`, що насправді є `/etc/munin/apache24.conf`.

Файл `/etc/munin/apache24.conf` є конфігураційним файлом `munin` для Apache. У ньому, якщо ви бажаєте мати доступ до `munin` не тільки локально, змініть в обох випадках `Require local` на `Require all granted`.

Відредагуйте `/etc/munin/munin.conf`. Розкоментуйте наступні рядки:

```conf
dbdir /var/lib/munin
htmldir /var/cache/munin/www
logdir /var/log/munin
rundir /var/run/munin
```

Перезапустіть munin та apache:

```sh
sudo /etc/init.d/munin-node restart
sudo /etc/init.d/apache2 restart
```

Перейдіть за посиланням `http://ip.адреса.вашого.сервера/munin`. Ви маєте бачити сторінку що показує `apache`, `disk`, `munin` й так далі.

Додайте втулки з `mod_tile` та `renderd` до munin:

```sh
sudo ln -s /usr/share/munin/plugins/mod_tile* /etc/munin/plugins/
sudo ln -s /usr/share/munin/plugins/renderd* /etc/munin/plugins/
```

Має бути 4 втулки `mod_tile` та 5 `renderd`. Запустіть завдання cron для munin вручну:

```sh
sudo -u munin munin-cron
```

Перезапустіть munin та apache занов:

```sh
sudo /etc/init.d/munin-node restart
sudo /etc/init.d/apache2 restart
```

Після деякої паузи, оновіть `http://ip.адреса.вашого.сервера/munin`, тепер сторінка має показувати `mod_tile` та `renderd`.

Munin оновлює графіки кожні 5 хвилин, частота оновлення налаштовується в cron – `/etc/cron.d/munin`.

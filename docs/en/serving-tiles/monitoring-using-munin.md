---
layout: docs
title: Monitoring using Munin
lang: en
---

# {{ title }}

"Munin" can be used to monitor the activity of `renderd` and `mod_tile` on a server. Munin is available on a number of platforms; these instructions were tested on Ubuntu Linux 22.04 in June 2022.

First, install the necessary software:

```sh
sudo apt install munin-node munin libcgi-fast-perl libapache2-mod-fcgid
```

If you look at `/etc/apache2/conf-available` you should see that `munin.conf` is a symbolic link to `../../munin/apache24.conf`, which is `/etc/munin/apache24.conf`.

The file `/etc/munin/apache24.conf` is Apache's `munin` configuration file. In that file, if you want `munin` to be accessed globally rather than just locally change both instances of `Require local` to `Require all granted`.

Next edit `/etc/munin/munin.conf`. Uncomment these lines:

```conf
dbdir /var/lib/munin
htmldir /var/cache/munin/www
logdir /var/log/munin
rundir /var/run/munin
```

Restart munin and apache:

```sh
sudo /etc/init.d/munin-node restart
sudo /etc/init.d/apache2 restart
```

Browse to `http://your.server.ip.address/munin`.  You should see a page showing `apache`, `disk`, `munin`, etc.

To add the plugins from `mod_tile` and `renderd` to munin:

```sh
sudo ln -s /usr/share/munin/plugins/mod_tile* /etc/munin/plugins/
sudo ln -s /usr/share/munin/plugins/renderd* /etc/munin/plugins/
```

There should be 4 `mod_tile` plugins and 5 `renderd` ones.  Run munin's cron job manually once:

```sh
sudo -u munin munin-cron
```

Restart munin and apache again:

```sh
sudo /etc/init.d/munin-node restart
sudo /etc/init.d/apache2 restart
```

After a short delay, refreshing `http://your.server.ip.address/munin/` should now show entries for `mod_tile` and `renderd`.

Munin updates its graphs every 5 minutes, as configured by the cron file `/etc/cron.d/munin`.

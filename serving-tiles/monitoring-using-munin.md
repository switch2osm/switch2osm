---
layout: docs
title: Monitoring using Munin
permalink: /serving-tiles/monitoring-using-munin/
---

# Monitoring using Munin

"Munin" can be used to monitor the activity of "renderd" and "mod_tile" on a server.  Munin is available on a number of platforms; these instructions were tested on Ubuntu Linux 22.04 in June 2022 and Ubuntu Linux 24.04 in April 2024.

First, install the necessary software:

    sudo apt install munin-node munin libcgi-fast-perl libapache2-mod-fcgid

If you look at <code>/etc/apache2/conf-available</code> you should see that <code>munin.conf</code> is a symbolic link to <code>../../munin/apache24.conf</code>, which is <code>/etc/munin/apache24.conf</code>.

The file <code>/etc/munin/apache24.conf</code> is Apache's munin configuration file. In that file, if you want munin to be accessed globally rather than just locally change both instances of <code>Require local</code> to <code>Require all granted</code>.

Next edit <code>/etc/munin/munin.conf</code>. Uncomment these lines:

    dbdir /var/lib/munin
    htmldir /var/cache/munin/www
    logdir /var/log/munin
    rundir /var/run/munin

Restart munin and apache:

    sudo /etc/init.d/munin-node restart
    sudo /etc/init.d/apache2 restart

Browse to <code>http://yourserveripaddress/munin</code>.  You should see a page showing "apache", "disk", "munin", etc.

To add the plugins from mod_tile and renderd to munin:

    sudo ln -s /usr/share/munin/plugins/mod_tile* /etc/munin/plugins/
    sudo ln -s /usr/share/munin/plugins/renderd* /etc/munin/plugins/

There should be 4 mod_tile plugins and 5 renderd ones.  Run munin's cron job manually once:

    sudo -u munin munin-cron

Restart munin and apache again:

    sudo /etc/init.d/munin-node restart
    sudo /etc/init.d/apache2 restart

After a short delay, refreshing <code>http://yourserveripaddress/munin/</code> should now show entries for "mod_tile" and "renderd".

Munin updates its graphs every 5 minutes, as configured by the cron file <code>/etc/cron.d/munin</code>.


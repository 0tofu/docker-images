#!/bin/sh
if [ ! -f /var/www/pma/config.secret.inc.php ] ; then
    cat > /var/www/pma/config.secret.inc.php <<EOT
<?php
\$cfg['blowfish_secret'] = '`cat /dev/urandom | tr -dc 'a-zA-Z0-9~!@#$%^&*_()+}{?></";.,[]=-' | fold -w 32 | head -n 1`';
EOT
fi

if [ ! -f /config.user.inc.php ] ; then
  touch /config.user.inc.php
fi

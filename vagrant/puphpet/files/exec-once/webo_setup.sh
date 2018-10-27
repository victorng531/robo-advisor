# Force php5 version
sudo update-alternatives --set php /usr/bin/php5.6
sudo update-alternatives --set phar /usr/bin/phar5.6
sudo update-alternatives --set phar.phar /usr/bin/phar.phar5.6 
sudo update-alternatives --set phpize /usr/bin/phpize5.6
sudo update-alternatives --set php-config /usr/bin/php-config5.6
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update
sudo apt-get purge -y php7.0-common
sudo apt-get autoremove
sudo apt-get install -y php5.6
#sudo bash -c "printf \"\\n\" | pecl install mongo"
#sudo bash -c "echo \"extension=mongo.so\" >> /etc/php/5.6/cli/php.ini"
sudo bash -c "printf \"\\n\" | pecl install mongodb"
sudo bash -c "echo \"extension=mongodb.so\" >> /etc/php/5.6/cli/php.ini"
sudo apt-get install -y php5-mongo php5-apcu php5-cli  php5-intl php5-imagick php5-mcrypt php5-curl

sudo service apache2 restart


#disable default vhosts
echo .... disable default vhost 80 ....
sudo a2dissite 10-default_vhost_80.conf
echo .... disable default vhost 443 ....
sudo a2dissite 10-default_vhost_443.conf

#reload apache
sudo service apache2 reload

#update dependencies
sudo php5dismod xdebug && sudo apachectl -k graceful
cd /srv/wealthbot
export COMPOSER_PROCESS_TIMEOUT=4000
composer clear-cache
composer install --prefer-source

#create mongo user webo
echo .... creating mongo user 'webo' ....
mongo < mongo_user.js

#create mongo user for unit tests
mongo < mongo_user_test.js

#clear cache
sudo chmod -R 777 app/cache
app/console cache:clear --env=prod --no-debug
app/console cache:clear --env=dev --no-debug
sudo rm -rf app/cache/*

#setup db and load fixtures
app/console doctrine:database:drop --force
app/console doctrine:database:create
app/console doctrine:schema:create
app/console doctrine:fixtures:load
app/console assetic:dump

#warming up cache
echo .... warming up cache ....
#app/console cache:warmup --env=prod
app/console cache:warmup --env=dev

#install the assets
app/console assets:install --symlink web

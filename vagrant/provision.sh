#!/usr/bin/env bash

# install required packages
sudo apt-get -y install     \
  imagemagick               \
  libmagickwand-dev         \
  mongodb					\
  netcdf-bin				\
  libnetcdf-dev

# edit mongodb config to allow remote connection from host
ex /etc/mongodb.conf <<EOEX
  :%s/127\.0\.0\.1/0\.0\.0\.0/g
  :x
EOEX

# restart mongodb
service mongodb restart

# change to web directory
cd /home/vagrant/src/emulatorization-web

# install gems
bundle install

# load the schema & run seeds.db
rake db:setup

# start a delayed_job daemon
RAILS_ENV=development script/delayed_job start

# start the rails server in detached mode
rails server -d
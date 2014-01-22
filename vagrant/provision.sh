#!/usr/bin/env bash

# install required packages
sudo apt-get -y install     \
  imagemagick               \
  libmagickwand-dev         \
  mongodb                   \
  netcdf-bin                \
  libnetcdf-dev

# edit mongodb config to allow remote connection from host
ex /etc/mongodb.conf <<EOEX
  :%s/127\.0\.0\.1/0\.0\.0\.0/g
  :x
EOEX

# restart mongodb
service mongodb restart

# get RVM for deployment
RVM_DIR=/home/vagrant/rvm
if [ ! -d "$RVM_DIR" ]; then
  git clone git://github.com/wayneeseguin/rvm.git "$RVM_DIR"
  echo "export rvm_path=$RVM_DIR" >> /home/vagrant/.bash_profile
fi

# change to web directory
cd /home/vagrant/src/computeqi-web

# install gems
bundle install

# load the schema & run seeds.db
rake db:setup

# start the rails server in detached mode
rails server -d

# start a delayed_job daemon
RAILS_ENV=development script/delayed_job start
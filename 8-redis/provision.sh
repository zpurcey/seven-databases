#! /bin/bash

set -ex

if [ ! -f /home/vagrant/.done ]
then
  echo "Installing pre-requisites"
  apt-get -qq update
  apt-get -y install make openjdk-7-jdk curl
  gem install redis bloomfilter-rb

  echo "export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-i386/" >> /home/vagrant/.profile

  echo "Installing Redis"
  apt-get -y install redis-server

  echo "Installing Neo4J"
  tar xfz /vagrant/neo4j-enterprise-1.8-unix.tar.gz
  chown -hR vagrant.vagrant neo4j-enterprise-1.8

  echo "export NEO4J_HOME=/home/vagrant/neo4j-enterprise-1.8" >> /home/vagrant/.profile
  echo "export PATH=$PATH:${NEO4J_HOME}/bin" >> /home/vagrant/.profile
  sed -e '17 s/#//' -i /home/vagrant/neo4j-enterprise-1.8/conf/neo4j-server.properties
  sed -e '2 s/127.0.1.1/127.0.0.1/' -i /etc/hosts

  echo "Installing CouchDB"
  apt-get -y install couchdb
  sed -e 's/;bind_address = 127.0.0.1/bind_address = 0.0.0.0/' -i /etc/couchdb/local.ini
  /etc/init.d/couchdb restart

  echo "Installing node.js"
  apt-get -y install python-software-properties
  add-apt-repository ppa:chris-lea/node.js
  apt-get -qq update
  apt-get -y install nodejs nodejs-dev npm
  npm install -g hiredis redis csv bricks mustache

  touch /home/vagrant/.done
  echo "Done!"
else
  echo "Everything appears to be setup already!"
fi

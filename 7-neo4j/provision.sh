#! /bin/bash

set -ex

if [ ! -d /home/vagrant/neo4j-enterprise-1.8 ]
then
  echo "Installing pre-requisites"
  apt-get -qq update
  apt-get -y install openjdk-7-jdk curl
  echo "export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-i386/" >> /home/vagrant/.profile

  echo "Installing Neo4J"
  tar xfz /vagrant/neo4j-enterprise-1.8-unix.tar.gz
  chown -hR vagrant.vagrant neo4j-enterprise-1.8

  echo "export NEO4J_HOME=/home/vagrant/neo4j-enterprise-1.8" >> /home/vagrant/.profile
  echo "export PATH=$PATH:${NEO4J_HOME}/bin" >> /home/vagrant/.profile
  sed -e '17 s/#//' -i /home/vagrant/neo4j-enterprise-1.8/conf/neo4j-server.properties
  sed -e '2 s/127.0.1.1/127.0.0.1/' -i /etc/hosts

  echo "Done!"
else
  echo "Neo4J appears to be setup already!"
fi

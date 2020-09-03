#!/bin/bash
echo "Webhook triggered." | systemd-cat -t webhook-handler

# Work in shared folder
mkdir -p /vagrant/lib
cd /vagrant/lib

pwd
echo "Make new directory /vagrant/lib/isostore"
mkdir -p isostore
pwd

# Check out latest version of metadata
if [ -d S-ENDA-metadata ]; then
  echo "Repository exists locally, running git pull." | systemd-cat -t webhook-handler
  cd S-ENDA-metadata
  git pull
  cd ..
else
  echo "Cloning repository." | systemd-cat -t webhook-handler
  git clone https://github.com/metno/S-ENDA-metadata
fi

rm -rf /isostore/*
cd /vagrant
docker-compose -f docker-compose.yml -f docker-compose.build.yml build
docker-compose run --rm -v /vagrant/lib/isostore:/isostore -v /vagrant/S-ENDA-metadata:/mmddir iso-converter sentinel1_mmd_to_csw_iso19139.py -i /mmddir -o /isostore

# Restart catalog-service-api
docker-compose rm -sf catalog-service-api
docker-compose up -d catalog-service-api

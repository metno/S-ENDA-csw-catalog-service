#!/bin/bash
if [[ -z "${MMD_IN}" ]]; then
    echo "Please set environment variable: MMD_IN"
    exit
fi

echo "Webhook triggered." | systemd-cat -t webhook-handler

# Work in shared folder
mkdir -p /vagrant/lib
cd /vagrant/lib

echo "Make new directory /vagrant/lib/isostore"
mkdir -p isostore

if [[ "$MMD_IN" == "S-ENDA-metadata" ]]; then
  # Check out latest version of metadata (used on staging/production server)
  if [ -d S-ENDA-metadata ]; then
    echo "S-ENDA-metadata repository exists locally, running git pull." | systemd-cat -t webhook-handler
    cd S-ENDA-metadata
    git pull
    cd ..
  else
    echo "Cloning repository." | systemd-cat -t webhook-handler
    git clone https://github.com/metno/S-ENDA-metadata
  fi
fi

rm -rf /isostore/*
cd /vagrant
# add --no-cache to the end of the next line to get the latest version of MMD
docker-compose -f docker-compose.yml -f docker-compose.build.yml build
docker-compose run --rm \
    -e XSLTPATH=/usr/local/share/xslt \
    -v /vagrant/lib/isostore:/isostore \
    -v $MMD_IN:/mmddir \
    iso-converter \
    sentinel1_mmd_to_csw_iso19139.py -i /mmddir -o /isostore

# Restart catalog-service-api
docker-compose rm -sf catalog-service-api
docker-compose up -d catalog-service-api

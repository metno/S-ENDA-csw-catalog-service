#!/bin/bash
echo "WARNING: this script only works for the localtest vm. A 'staging' version exists in the prototype repos."
if [[ -z "${MMD_IN}" ]]; then
    echo "Please set environment variable: MMD_IN"
    exit
fi

# Work in shared folder
cd /vagrant/lib

if [[ "$MMD_IN" == "/vagrant/lib/s-enda-mmd-xml" ]]; then
  # Check out latest version of metadata
  if [ -d s-enda-mmd-xml ]; then
    echo "s-enda-mmd-xml repository exists locally, running git pull." | systemd-cat -t webhook-handler
    cd s-enda-mmd-xml
    git pull
    cd ..
  else
    echo "Cloning repository." | systemd-cat -t webhook-handler
    git clone git@gitlab.met.no:mmd/s-enda-mmd-xml.git
  fi
fi

rm -rf /isostore/*
cd /vagrant
export DOCKERFILE='Dockerfile.localtest'
# add --no-cache to the end of the next line to get the latest version of MMD
docker-compose -f docker-compose.yml -f docker-compose.build.yml build
docker-compose run --rm \
    -e XSLTPATH=/usr/local/share/xslt \
    -v /vagrant/lib/isostore:/isostore \
    -v $MMD_IN:/mmddir \
    iso-converter \
    xmlconverter.py -i /mmddir -o /isostore -t /usr/local/share/xslt/mmd-to-iso.xsl

# Restart catalog-service-api
docker-compose rm -sf catalog-service-api
docker-compose up -d catalog-service-api

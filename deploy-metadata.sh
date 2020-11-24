#!/bin/bash
echo "WARNING: this script only works for the localtest vm. A 'staging' version exists in the prototype repos."
if [[ -z "${MMD_IN}" ]]; then
    echo "Please set environment variable: MMD_IN"
    exit
fi

echo "debug 1"

if [[ $GET_GIT_MMD_FILES -eq 1 ]]; then
  MMD_IN=$MMD_IN ./get_latest_metadata.sh
fi

cd /vagrant/lib
# Remove old iso files
#rm isostore/*

echo "debug 2"

# Work in shared folder
cd /vagrant
#export DOCKERFILE='Dockerfile.localtest'
## add --no-cache to the end of the next line to get the latest version of MMD
#docker-compose -f docker-compose.yml -f docker-compose.build.yml build
docker-compose up -d iso-converter
docker-compose run --rm \
    -e XSLTPATH=/usr/local/share/xslt \
    -v /vagrant/lib/isostore:/isostore \
    -v $MMD_IN:/mmddir \
    iso-converter \
    xmlconverter.py -i /mmddir -o /isostore -t /usr/local/share/xslt/mmd-to-iso.xsl

echo "debug 3"
# Restart catalog-service-api
# this basically runs catalog-service/pycsw_setup.py which runs
# python3 /usr/bin/pycsw-admin.py -c load_records -f /etc/pycsw/pycsw.cfg -p "$ISO_STORE" -r -y 
#docker-compose rm -sf catalog-service-api
#docker-compose up -d catalog-service-api

# We may prefer to have a separate container for indexing in pycsw..
# The following, or a similar solution, would be preferred instead of rebuilding but I can't make it work
# Ingest metadata from ISO19139 xml files
docker-compose exec catalog-service-api bash -c 'python3 /usr/bin/pycsw-admin.py -c load_records -f /etc/pycsw/pycsw.cfg -p $ISO_STORE -r -y'

echo "debug 4"
# Clean up
#rm /vagrant/lib/isostore/*
#rm $MMD_IN/*

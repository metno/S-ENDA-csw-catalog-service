#!/bin/bash
echo "WARNING: this script only works for the localtest vm. A 'staging' version exists in the prototype repos."
if [[ -z "${MMD_IN}" ]]; then
    echo "Please set environment variable: MMD_IN"
    exit
fi

if [[ $GET_GIT_MMD_FILES -eq 1 ]]; then
  MMD_IN=$MMD_IN ./get_latest_metadata.sh
fi

# Remove old iso files
if [ -z "$(ls -A /vagrant/lib/isostore)" ]; then
  echo "Empty dir"
else
  rm /vagrant/lib/isostore/*
fi

# Work in shared folder
cd /vagrant
docker-compose run --rm \
    -e XSLTPATH=/usr/local/share/xslt \
    -v /vagrant/lib/isostore:/isostore \
    -v $MMD_IN:/mmddir \
    iso-converter \
    xmlconverter.py -i /mmddir -o /isostore -t /usr/local/share/xslt/mmd-to-iso.xsl

# We may prefer to have a separate container for indexing in pycsw..
# Ingest metadata from ISO19139 xml files
docker-compose exec -T catalog-service-api bash -c 'python3 /usr/local/bin/pycsw-admin.py -c load_records -f /etc/pycsw/pycsw.cfg -p $ISO_STORE -r -y'

# Clean up
if [ -z "$(ls -A /vagrant/lib/isostore)" ]; then
  echo "Empty dir"
else
  rm /vagrant/lib/isostore/*
fi
if [ -z "$(ls -A $MMD_IN)" ]; then
  echo "Empty dir"
else
  rm $MMD_IN/*
fi

#!/bin/bash

# Add development code
cd /vagrant

if [ ! -d lib ]; then
  mkdir lib
fi
cd lib

# Clone or pull the following git repositories to allow editing on the host machine
# NOTE: we use forks at github.com/metno
for REPO in mmd pycsw py-mmd-tools; do
  if [ -d "${REPO}" ]; then
    echo "$REPO repository exists locally, running git pull"
    cd $REPO
    git pull
    cd ..
  else
    echo "Cloning $REPO"
    git clone git@github.com:metno/$REPO.git
  fi
done

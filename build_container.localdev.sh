#!/bin/bash

# Add development code
cd /vagrant
mkdir lib
cd lib
# The following git repositories are cloned to allow editing on the host machine
git clone git@github.com:metno/mmd.git
git clone git@github.com:metno/S-ENDA-metadata.git
git clone git@github.com:metno/pycsw.git
#git clone git@github.com:metno/pycsw-container.git

# Set up environment
echo "alias l='ls -hlrt --color'" >> /home/vagrant/.bashrc
echo "alias ..='cd ..'" >> /home/vagrant/.bashrc
# Keep bash history between ups and destroys
FILE=/vagrant/lib/dot_bash_history
if [[ ! -f "$FILE" ]]; then
  touch $FILE
  chown vagrant:vagrant $FILE
fi
BHIST=/home/vagrant/.bash_history
ln -s $FILE $BHIST

# Keep python history between ups and destroys
FILE=/vagrant/lib/dot_python_history
if [[ ! -f "$FILE" ]]; then
  touch $FILE
  chown vagrant:vagrant $FILE
fi
PHIST=/home/vagrant/.python_history
ln -s $FILE $PHIST

cd /vagrant
name=catalog-dev

# Remove container (if it exists)
docker rm -f $name 2> /dev/null

# Build image
docker build -t $name -f localdev/Dockerfile.localdev .

cd /vagrant/lib/pycsw
# build container
#docker create -it -p 80:8000 --name=$name \
docker run -p 80:8000 --name=$name \
    --entrypoint "" \
    --env XSLTPATH=/home/pycsw/mmd/xslt \
    --detach \
    --volume ${PWD}/pycsw:/usr/lib/python3.8/site-packages/pycsw \
    --volume ${PWD}/tests:/home/pycsw/tests \
    --volume ${PWD}/docs:/home/pycsw/docs \
    --volume ${PWD}/VERSION.txt:/home/pycsw/VERSION.txt \
    --volume ${PWD}/LICENSE.txt:/home/pycsw/LICENSE.txt \
    --volume ${PWD}/COMMITTERS.txt:/home/pycsw/COMMITTERS.txt \
    --volume ${PWD}/CONTRIBUTING.rst:/home/pycsw/CONTRIBUTING.rst \
    --volume ${PWD}/pycsw/plugins:/home/pycsw/pycsw/plugins \
    --volume ${PWD}/requirements-dev.txt:/requirements-dev.txt \
    --volume ${PWD}/requirements.txt:/requirements.txt \
    --volume ${PWD}/requirements-standalone.txt:/requirements-standalone.txt \
    --volume /vagrant/localdev/pycsw.localdev.cfg:/etc/pycsw/pycsw.cfg \
    --volume /home/vagrant/.bashrc:/home/pycsw/.bashrc \
    --volume /home/vagrant/.bash_history:/home/pycsw/.bash_history \
    --volume /home/vagrant/.python_history:/home/pycsw/.python_history \
    --volume /vagrant/lib/mmd/bin/sentinel1_mmd_to_csw_iso19139.py:/home/pycsw/mmd/bin/sentinel1_mmd_to_csw_iso19139.py \
    --volume /vagrant/lib/mmd/xslt:/home/pycsw/mmd/xslt \
    --volume /vagrant/lib/mmd/mmd_utils:/usr/lib/python3.8/site-packages/mmd_utils \
    --volume /vagrant/lib/input_mmd_files:/home/pycsw/mmd_in \
    --volume /vagrant/lib/output_pycsw_iso_xml_files:/home/pycsw/iso_out \
    $name sleep 1d
    #$name --reload
    #$name bash

    #--volume ${PWD}/requirements-dev.txt:/home/pycsw/requirements-dev.txt \
    #--volume ${PWD}/requirements.txt:/home/pycsw/requirements.txt \
    #--volume ${PWD}/requirements-standalone.txt:/home/pycsw/requirements-standalone.txt \

# install additional dependencies used in tests and docs 
# - see pycsw docs at https://docs.pycsw.org/en/2.4.2/docker.html#setting-up-a-development-environment-with-docker
#docker exec \
#    -ti \
#    --user root \
#    $name pip3 install -r /requirements-dev.txt

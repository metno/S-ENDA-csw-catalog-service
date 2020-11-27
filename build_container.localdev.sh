#!/bin/bash

cd /vagrant
name=catalog-dev

# Remove container (if it exists)
docker rm -f $name 2> /dev/null

# Build image
docker build -t $name -f localdev/Dockerfile .

cd /vagrant/lib/pycsw
# build container
#docker create -it -p 80:8000 --name=$name \
docker run -p 80:8000 --name=$name \
    --entrypoint "" \
    --env XSLTPATH=/home/pycsw/mmd/xslt \
    --env CSW_SERVICE_URL="http://10.20.30.11:80" \
    --detach \
    --volume ${PWD}/pycsw:/usr/local/lib/python3.8/site-packages/pycsw \
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
    --volume /vagrant/lib/py-mmd-tools/script/xmlconverter.py:/home/pycsw/scripts/xmlconverter.py \
    --volume /vagrant/lib/mmd/xslt:/home/pycsw/mmd/xslt \
    --volume /vagrant/lib/py-mmd-tools/py_mmd_tools:/usr/local/lib/python3.8/site-packages/py_mmd_tools \
    --volume $MMD_IN:/home/pycsw/mmd_in \
    --volume /vagrant/lib/isostore:/home/pycsw/isostore \
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

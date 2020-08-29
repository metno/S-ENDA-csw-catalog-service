# Add development code
cd /vagrant
mkdir lib
cd lib
# The following git repositories are cloned to allow editing on the host machine
git clone git@github.com:metno/mmd.git
git clone git@github.com:metno/S-ENDA-metadata.git
git clone git@github.com:metno/pycsw.git
git clone git@github.com:metno/pycsw-container.git

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

docker build -t $name -f Dockerfile.devel .

cd /vagrant/lib/pycsw
# build container
#docker create -it -p 80:8000 --name=$name \
    #--entrypoint "" \
docker run -p 80:8000 --name=$name \
    --detach \
    --volume ${PWD}/pycsw:/usr/lib/python3.5/site-packages/pycsw \
    --volume ${PWD}/docs:/home/pycsw/docs \
    --volume ${PWD}/VERSION.txt:/home/pycsw/VERSION.txt \
    --volume ${PWD}/LICENSE.txt:/home/pycsw/LICENSE.txt \
    --volume ${PWD}/COMMITTERS.txt:/home/pycsw/COMMITTERS.txt \
    --volume ${PWD}/CONTRIBUTING.rst:/home/pycsw/CONTRIBUTING.rst \
    --volume ${PWD}/pycsw/plugins:/home/pycsw/pycsw/plugins \
    --volume /vagrant/pycsw_local.dev.cfg:/etc/pycsw/pycsw.cfg \
    -v /home/vagrant/.bashrc:/home/pycsw/.bashrc \
    -v /home/vagrant/.bash_history:/home/pycsw/.bash_history \
    -v /home/vagrant/.python_history:/home/pycsw/.python_history \
    -v /vagrant/lib/mmd:/home/pycsw/mmd \
    -v /vagrant/lib/mmd/mmd_utils:/usr/lib/python3.8/site-packages/mmd_utils \
    -v /vagrant/lib/input_mmd_xml_files:/home/pycsw/mmd_in \
    -v /vagrant/lib/output_pycsw_iso_xml_files:/home/pycsw/iso_out \
    $name --reload
    #$name bash

## install additional dependencies used in tests and docs 
## - see pycsw docs at https://docs.pycsw.org/en/2.4.2/docker.html#setting-up-a-development-environment-with-docker
#docker exec \
#    -ti \
#    --user root \
#    pycsw-dev pip3 install -r requirements-dev.txt

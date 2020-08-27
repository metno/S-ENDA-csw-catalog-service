cd /vagrant
mkdir lib
cd lib
git clone git@github.com:metno/mmd.git
git clone git@github.com:metno/S-ENDA-metadata.git
git clone git@github.com:metno/pycsw.git

cd /vagrant
name=catalog-dev
docker build -t $name -f Dockerfile.devel .

# remove container (if it exists)
docker rm $name 2> /dev/null

# build container
docker create -it --name=$name \
    --entrypoint "" \
    -v /home/vagrant/.bashrc:/home/pycsw/.bashrc \
    -v /home/vagrant/.bash_history:/home/pycsw/.bash_history \
    -v /home/vagrant/.python_history:/home/pycsw/.python_history \
    -v /vagrant/lib/mmd:/home/pycsw/mmd \
    -v /vagrant/lib/mmd/mmd_utils:/usr/lib/python3.8/site-packages/mmd_utils \
    $name bash


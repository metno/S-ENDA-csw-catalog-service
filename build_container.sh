cd /vagrant
mkdir lib
cd lib
git clone git@github.com:metno/mmd.git

cd /vagrant
name=catalog-dev
docker build -t $name -f Dockerfile.devel .

# remove container (if it exists)
docker rm $name 2> /dev/null

# build container
docker create -it --name=$name \
    --entrypoint "" \
    -v /vagrant/lib/mmd/mmd_utils:/usr/lib/python3.8/site-packages/mmd_utils \
    $name sh

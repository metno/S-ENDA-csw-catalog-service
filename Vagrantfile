# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

begin
  current_dir    = File.dirname(File.expand_path(__FILE__))
  # config.yml is ignored by git, i.e., .gitignore
  configs        = YAML.load_file("#{current_dir}/config.yml")
  vagrant_config = configs['configs'][configs['configs']['use']]
rescue StandardError => msg
  vagrant_config = {}
end

$welcome_msg = <<MSG
-----------------------------------------------------------------
S-ENDA CSW catalog service for development 

To build/re-build and start services from source run and re-run:

  BUILD=1 vagrant up

Stop and remove development environment with:

  vagrant destroy -f
-----------------------------------------------------------------
MSG

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.box_check_update = false

  config.ssh.forward_agent = true

  # To use your local .bashrc
  #config.vm.provision "file", source: "~/.bashrc", destination: "~/.bashrc"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
    vb.cpus = 4
    vb.default_nic_type = "virtio"
  end

  config.vm.provision "00-bootstrap", type: "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y git wget unattended-upgrades
    apt-get install -y docker.io docker-compose
  SHELL

  config.vm.define "localdev" do |ldev|
    ldev.vm.network "private_network", ip: "10.20.30.11"
    ldev.vm.provision "50-rebuild", type: "shell", run: "always", inline: <<-SHELL
      # This also removes docker-compose:
      apt-get remove -y golang-docker-credential-helpers
      echo -e "Host *\\n\\tStrictHostKeyChecking no" > $HOME/.ssh/config
      # Build container for local development env
      cd /vagrant
      ./build_container.localdev.sh
    SHELL
  end

  config.vm.define "localtest", primary: true do |ltest|
    ltest.vm.network "private_network", ip: "10.20.30.10"
    ltest.vm.provision "50-rebuild", type: "shell", run: "always", inline: <<-SHELL
      echo -e "Host *\\n\\tStrictHostKeyChecking no" > $HOME/.ssh/config
      export MMD_IN='/vagrant/lib/input_mmd_files'
      mkdir $MMD_IN
      # Keep bash history between ups and destroys
      FILE=/vagrant/lib/dot_bash_history
      if [[ ! -f "$FILE" ]]; then
        touch $FILE
        chown vagrant:vagrant $FILE
      fi
      BHIST=/home/vagrant/.bash_history
      ln -s $FILE $BHIST
      cd /vagrant
      if [[ -n "#{ENV['BUILD']}" ]]
      then
        export DOCKERFILE='Dockerfile.localtest'
        docker-compose -f docker-compose.yml -f docker-compose.build.yml build --pull
      fi
      ./deploy-metadata.sh
      docker-compose up -d
    SHELL
  end

  if vagrant_config != {}
    config.vm.network "public_network", ip: vagrant_config['ip'], netmask: vagrant_config['netmask'], bridge: vagrant_config['bridge']
    config.vm.provision "shell", run: "always", inline: "ip route add default via #{ vagrant_config['gateway'] } metric 10 || exit 0"
    config.vm.hostname = vagrant_config['hostname']
  end
  #config.vm.define "default" do |config|
  #  if vagrant_config != {}
  #    config.vm.network "public_network", ip: vagrant_config['ip'], netmask: vagrant_config['netmask'], bridge: vagrant_config['bridge']
  #    config.vm.provision "shell", run: "always", inline: "ip route add default via #{ vagrant_config['gateway'] } metric 10 || exit 0"
  #    config.vm.hostname = vagrant_config['hostname']
  #  end
  #end

  config.vm.post_up_message = $welcome_msg
end

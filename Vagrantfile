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
    #vb.default_nic_type = "virtio"
  end

  config.vm.provision "00-bootstrap", type: "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y git wget unattended-upgrades
    apt-get install -y docker.io docker-compose
    echo -e "Host *\\n\\tStrictHostKeyChecking no" > $HOME/.ssh/config
    # Keep bash history between ups and destroys
    cd /vagrant
    mkdir -p /vagrant/lib
    mkdir -p /vagrant/lib/input_mmd_files
    ./create_history_files.sh
  SHELL

  config.vm.define "localdev" do |ldev|
    ldev.vm.network "private_network", ip: "10.20.30.11"
    ldev.vm.provision "50-rebuild", type: "shell", run: "always", inline: <<-SHELL
      # This also removes docker-compose:
      apt-get remove -y golang-docker-credential-helpers
      # Set up environment
      echo "alias l='ls -hlrt --color'" >> /home/vagrant/.bashrc
      echo "alias ..='cd ..'" >> /home/vagrant/.bashrc
      # Set folder with input MMD files
      #export MMD_IN='/vagrant/lib/s-enda-mmd-xml'
      export MMD_IN='/vagrant/lib/input_mmd_files'
      # Build container for local development env
      cd /vagrant
      ./clone_or_update_git_repositories.sh
      ./build_container.localdev.sh
    SHELL
  end

  config.vm.define "localtest", primary: true do |ltest|
    ltest.vm.network "private_network", ip: "10.20.30.10"
    ltest.vm.provision "50-rebuild", type: "shell", run: "always", inline: <<-SHELL
      cd /vagrant
      # if BUILD is set
      if [[ -n "#{ENV['BUILD']}" ]]
      then
        export DOCKERFILE='Dockerfile'
        # "--pull" means that it pulls the base images from dockerhub if they have been updated (e.g., alpine or pycsw images)
        docker-compose -f docker-compose.yml -f docker-compose.build.yml build --pull
      fi
      docker-compose up -d
      # Set folder with input MMD files
      export MMD_IN='/vagrant/lib/input_mmd_files'
      # Get updates from gitlab repo
      export GET_GIT_MMD_FILES=1
      ## Don't get updates from gitlab repo (test your own files that you have added to $MMD_IN)
      #export GET_GIT_MMD_FILES=0
      ./deploy-metadata.sh
    SHELL
  end

  if vagrant_config != {}
    config.vm.network "public_network", ip: vagrant_config['ip'], netmask: vagrant_config['netmask'], bridge: vagrant_config['bridge']
    config.vm.provision "shell", run: "always", inline: "ip route add default via #{ vagrant_config['gateway'] } metric 10 || exit 0"
    config.vm.hostname = vagrant_config['hostname']
  end

  config.vm.post_up_message = $welcome_msg
end

# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'


VM_BOX = "generic/rhel8"
VM_MEMORY = 1024 * 8

RH_SUBSCRIPTION_FILE = '.rh-subscription.yaml'


# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = VM_BOX

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true

    # Enable, if Guest Additions are installed, whether hardware 3D acceleration should be available
    vb.customize ["modifyvm", :id, "--accelerate3d", "on"]

    # Customize the amount of memory on the VM:
    vb.memory = "#{VM_MEMORY}"
  end

  if Vagrant.has_plugin?("vagrant-vbguest")
    # set auto_update to false, if you do NOT want to check the correct 
    # additions version when booting this machine
    config.vbguest.auto_update = false
  end

  # Run provision bash script.
  config.vm.provision "shell" do |shell|
    shell.path = "provision.sh"
    rhel_subscription = get_rh_subscription()
    shell.env = {
        "SUBSCRIPTION_MANAGER_USERNAME" => rhel_subscription['username'],
        "SUBSCRIPTION_MANAGER_PASSWORD" => rhel_subscription['password'],
    }
  end

  # Run provision ansible playbook.
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "provision.yaml"
  end

end


def get_rh_subscription()
  # puts("get_rh_subscription()")
  root_dir = File.dirname(__FILE__)
  subscription_file = File.join(root_dir, RH_SUBSCRIPTION_FILE)
  subscription = load_rh_subscription(subscription_file)
  if not subscription or not subscription['password'] then
    username = subscription['username']
    IO::console.print("Enter Red Hat Subscripion username [#{username}]: ")
    STDOUT.flush()
    username = IO::console.gets().strip()
    if username then
      subscription['username'] = username
    end

    subscription['password'] = IO::console.getpass(
      "Enter Red Hat Subscripion password: ").strip()
    save_rh_subscription(subscription_file, subscription)
  end

  return subscription
end


def load_rh_subscription(subscription_file)
  # puts("get_rh_subscription(#{subscription_file})")
  if not File.exist?(subscription_file) then
    return {}
  end

  content = YAML.load_file(subscription_file)
  if not content then
    # puts("#{subscription_file}: invalid content!\n#{content}")
    return {}
  end

  # puts("#{subscription_file}:\n#{content}")
  subscription = content['subscription']
  if subscription['username'] then
    subscription['password'] = load_rh_subscription_password(
      subscription['username'])
  end

  return subscription
end


def save_rh_subscription(subscription_file, subscription)
  save_rh_subscription_password(subscription['username'],
                                subscription['password'])
  File.open(subscription_file, "w") do |file|
    output = subscription.clone
    output.delete('password')
    file.write({'subscription' => output}.to_yaml)
  end
end


def load_rh_subscription_password(username, service='rh-subscription')
  # puts("load_rh_subscription_password(#{username})")
  return `security find-generic-password -a '#{username}' -s '#{service}' -w`.strip()
end


def save_rh_subscription_password(username, password, service='rh-subscription')
  # puts("save_rh_subscription_password(#{username}, ...)")
  `security delete-generic-password -a '#{username}' -s '#{service}'`
  `security add-generic-password -a '#{username}' -s '#{service}' -w '#{password}'`
end

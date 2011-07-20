# vagrant-hosts

`vagrant-hosts` is a plugin for [Vagrant](http://vagrantup.com) which allows a developer to automatically add or remove local hosts entries when bringing up or shutting down machines with vagrant.

**NOTE:** This plugin requires Vagrant 0.6 or later.

## Installing / Getting Started

To use this plugin, first install Vagrant 0.6 or later. Next, install this gem:

    gem install vagrant-hosts

TODO explain how to configure it. Example:

    Vagrant::Config.run do |config|
      config.hosts.names = ["host.name", "another.name"]
      
      # alternatively find them indirectly by looking them up in the configuration
      # most usefull if you want to specify the configuration only once in the json
      config.hosts.find_config_via_key_paths = true
      config.hosts.names = ["config.foo.bar", "config.foo.baz"]
    end

## Caveats

- Only supports single machine setups for now
- Cannot yet do indirect hostname getting, i.e. you will have to configure the hostname twice, once in the machine and another time in the vagrant file.
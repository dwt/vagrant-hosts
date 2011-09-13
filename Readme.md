# vagrant-hosts

`vagrant-hosts` is a plugin for [Vagrant](http://vagrantup.com) which allows a developer to automatically add or remove local hosts entries when bringing up or shutting down machines with vagrant.

**NOTE:** This plugin requires Vagrant 0.8 or later.

## Installing / Getting Started

To use this plugin, first install Vagrant 0.6 or later. Next, install this gem:

    gem install vagrant-hosts

TODO explain how to configure it. Example:

    Vagrant::Config.run do |config|
      config.hosts.names = ["host.name", "another.name"]
    end

## Caveats

- Only works on Mac OS X (pre Lion) <- patches welcome!
- Only supports single machine setups for now
- Cannot yet do indirect hostname getting, i.e. you will have to configure the hostname twice, once in the machine and another time in the vagrant file.

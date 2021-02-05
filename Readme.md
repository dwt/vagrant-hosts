# Searching for maintainers

I do not use vagrant anymore, and thus this is unmaintained since quite a long time. If you care about this feature, please talk to me if you would like to maintain it.

# vagrant-hosts

`vagrant-hosts` is a plugin for [Vagrant](http://vagrantup.com) which allows a developer to automatically add or remove local hosts entries when bringing up or shutting down machines with vagrant.

**NOTE:** This plugin requires Vagrant 0.8 or later.

## Installing / Getting Started

To use this plugin, first install Vagrant 0.8 or later and ensure that you have [augeas](http://augeas.net/) installed. Next, install this gem:

    gem install vagrant-hosts

To configure it put something along these lines into your Vagrantfile:

    Vagrant::Config.run do |config|
      config.hosts.names = ["host.name", "another.name"]
    end

## Caveats

- Only works on Mac OS X (pre Lion) <- patches welcome!
  - Lion seems to ignore the configuration stored there.
- Only supports single machine setups for now
- Cannot yet do indirect hostname getting, i.e. you will have to configure the hostname twice, once in the machine and another time in the vagrant file.

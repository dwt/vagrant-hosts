#!/usr/bin/env ruby

# Inspired by http://tomafro.net/2009/07/dscl-the-easy-way-to-add-hosts-on-osx
# TODO:
# - Check whether /Local/Default/Hosts is the right OpenDirectory domain to use
#   Starting Point: http://web.archive.org/web/20070315112121/http://images.apple.com/server/pdfs/Open_Directory_v10.4.pdf

require 'vagrant'

module VagrantHosts
  class HostManager
  
    attr_accessor :hostname, :ip
  
    def initialize(hostname, ip)
      self.hostname = hostname
      self.ip = ip
    end
  
    def shell(code)
      `#{code}`
    end
  
    def add_host_entry
      shell "sudo dscl localhost -create /Local/Default/Hosts/#{hostname} IPAddress #{ip}"
      # may need shell "sudo dscacheutil -flushcache -entries host"
      # especially if this not being availeable was cached before
      # seems to work without it on Snow Leopard though
    end
  
    def remove_host_entry
      shell "sudo dscl localhost -delete /Local/Default/Hosts/#{hostname}"
    end
  
  end
  
  class HostsConfig < Vagrant::Config::Base
    configures :hosts
    attr_accessor :names#, :names_from_chef_json
    
    def hostnames()
      self.names || []
    end
    
    def validate(errors)
      check_valid_names(errors, names, ":names needs to be set to an array of strings")
#      check_valid_names(errors, names_from_chef_json, ":names_from_chef_json needs to be set to an array of strings")
    end
    
    def check_valid_names(errors, an_array, an_error_message)
      return if valid_names_array?(an_array) 
      errors.add(an_error_message)
    end
    
    def valid_names_array?(an_array)
      return true if an_array.nil?
      an_array.is_a? Array and an_array.all? { |each| each.is_a? String }
    end
  end
  
  class HostsManagingMiddleware
    def initialize(app, env)
      @app = app
    end
    
    
    def hosts()
      @env.env.config.hosts.hostnames
    end
    
    def ip()
      # is this really the right way to do it?
      @env.env.config.vm.network_options[1][:ip]
    end
    
    def managers
      hosts.map { |each| HostManager.new each, ip }
    end
    
    def call(env)
      @env = env
      @app.call(env)
    end
    
  end
  
  class HostsSetupMiddleware < HostsManagingMiddleware
    def call(env)
      super
      if not hosts.empty?
        env.ui.info "Setting up hostnames"
        managers.each { |each| each.add_host_entry }
      end
      @app.call(env)
    end
  end
  
  class HostsTeardownMiddleware < HostsManagingMiddleware
    def call(env)
      super
      if not hosts.empty?
        env.ui.info "Tearing down hostnames"
        managers.each { |each| each.remove_host_entry }
      end
      @app.call(env)
    end
  end
end

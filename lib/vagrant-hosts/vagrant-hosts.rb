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
    attr_accessor :names
    
    def hostnames()
      self.names || []
    end
    
    def validate(errors)
      return if names.nil?
      
      return if names.is_a? Array and names.all? { |each| each.is_a? String }
      
      errors.add(":names needs to be set to an array of strings")
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

# TODO: find out if this needs to be in more chains
[:start, :up, :reload, :resume].each do |each|
  Vagrant::Action[each].use VagrantHosts::HostsSetupMiddleware
end
[:destroy, :suspend].each do |each|
  Vagrant::Action[each].use VagrantHosts::HostsTeardownMiddleware
end


require "rspec"
describe VagrantHosts do
  
  before(:each) do
    # don't want accidental executions
    VagrantHosts::HostManager.any_instance.stub(:shell)
  end
  
  describe VagrantHosts::HostManager do
    
    before(:each) do
      @manager = VagrantHosts::HostManager.new("host.name", "192.168.1.2")
    end
    
    describe "setup" do
      it "should take the host to manage as initializer argument" do
        @manager.hostname.should == "host.name"
      end
      
      it "should take ip address as constructor argument" do
        @manager.ip.should == "192.168.1.2"
      end
      
    end
    
    describe "adding hostnames" do
      
      it "should be able to create hostname with dscl" do
        @manager.should_receive(:shell).with "sudo dscl localhost -create /Local/Default/Hosts/host.name IPAddress 192.168.1.2"
        @manager.add_host_entry
      end
      
    end
    
    describe "removing hostnames" do
      
      it "should description" do
        @manager.should_receive(:shell).with "sudo dscl localhost -delete /Local/Default/Hosts/host.name"
        @manager.remove_host_entry
      end
      
    end
    
  end
  
  describe VagrantHosts::HostsConfig do
    
    include Vagrant::TestHelpers
    
    before(:each) do
      @env = vagrant_env
      @config = VagrantHosts::HostsConfig.new
      @errors = Vagrant::Config::ErrorRecorder.new
    end
    
    it "should configure :hostnames" do
      @env.config.hosts.should be_kind_of VagrantHosts::HostsConfig
    end
    
    it "should allow no configuration" do
      @config.validate(@errors)
      @errors.errors.should be_empty
    end
    
    it "should allow array of names" do
      @config.names = ['example.net', 'example.com']
      
      @config.validate(@errors)
      @errors.errors.should be_empty
    end
    
    it "should allow empty array of names" do
      @config.names = []
      
      @config.validate(@errors)
      @errors.errors.should be_empty
    end
    
    it "should error on non array for hostnames" do
      @config.names = 23
      
      @config.validate(@errors)
      @errors.errors.should_not be_empty
    end
    
    it "should error on hostnames that are not strings" do
      @config.names = [23]
      
      @config.validate(@errors)
      @errors.errors.should_not be_empty, "#{@errors.inspect}"
    end
    
    it "should always return valid array from hostnames" do
      @config.hostnames.should == []
    end
    
  #  it "should allow indirection to json" # TODO: decide: special config for that?
  end
  
  describe VagrantHosts::HostsManagingMiddleware do
    include Vagrant::TestHelpers
    
    before(:each) do
      @klass = VagrantHosts::HostsManagingMiddleware
      @app, @env = action_env
      @ware = @klass.new(@app, @env)
      @env.env.config.hosts.names = ["host.name"]
      @env.env.config.vm.network "10.10.10.10"
      @ware.call(@env)
    end
    
    it "should know the hosts to create" do
      @ware.hosts.should == ["host.name"]
    end
    
    it "should know the IP to work with" do
      @ware.ip.should == "10.10.10.10"
    end
    
    it "should have a host manager ready to be called for each host" do
      @ware.managers.should be_a Array
      @ware.managers.all? do |all|
        all.should be_a VagrantHosts::HostManager
        @ware.hosts.should be_include all.hostname
      end
    end
  end
  
end
# middleware to create and remove host entries
#  add support for setting that tells Vagrant where to find the hostname (so you can only specify them once in the vhost definition in json)
# Add middleware everywhere needed so it automatically gets called when the machine boots or dies
# package as nice gem
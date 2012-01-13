require 'vagrant-hosts'

describe VagrantHosts do
  include Vagrant::TestHelpers
  
  before(:each) do
    # don't want accidental executions
    VagrantHosts::DSCLHostManager.any_instance.stub(:shell)
  end
  
  describe VagrantHosts::DSCLHostManager do
    
    before(:each) do
      @manager = VagrantHosts::DSCLHostManager.new("host.name", "192.168.1.2")
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

    # TODO: enable vagrant to get these hostnames from chef and puppet configs
    # xit "should error on non array of json_hostnames" do
    #   @config.names_from_chef_json = 23
    #   @config.validate(@errors)
    #   @errors.errors.should_not be_empty
    # end
    # 
    # xit "should error non strings in json_hostnames" do
    #   @config.names_from_chef_json = [23]
    #   @config.validate(@errors)
    #   @errors.errors.should_not be_empty
    # end
    # 
    # xit "should be able to get hosts from config json when using :chef_solo" do
    #   @env.config.vm.provision :chef_solo do |chef|
    #     chef.json.merge!(:foo => "bar")
    #   end
    #   @config.names_from_chef_json = ["foo"]
    #   @config.hostnames.should == ["bar"]
    # end
  end
  
  describe VagrantHosts::HostsManagingMiddleware do
    
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
        all.should be_a VagrantHosts::DSCLHostManager
        @ware.hosts.should be_include all.hostname
      end
    end
  end
  
end
# middleware to create and remove host entries
#  add support for setting that tells Vagrant where to find the hostname (so you can only specify them once in the vhost definition in json)
# Add middleware everywhere needed so it automatically gets called when the machine boots or dies
# package as nice gem
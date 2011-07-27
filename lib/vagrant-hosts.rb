require 'vagrant-hosts/vagrant-hosts'

# TODO: find out if this needs to be in more chains
[:start, :up, :reload, :resume].each do |each|
  Vagrant::Action[each].use VagrantHosts::HostsSetupMiddleware
end
[:destroy, :suspend].each do |each|
  Vagrant::Action[each].use VagrantHosts::HostsTeardownMiddleware
end
# -*- encoding: utf-8 -*-
require File.expand_path("../lib/vagrant-hosts/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "vagrant-hosts"
  s.version     = VagrantHosts::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Martin Häcker"]
  s.email       = ["spamfaenger@gmx.de"]
  # TODO: Missing?
  # s.homepage    = "http://rubygems.org/gems/vagrant-hosts"
  s.summary = s.description = "A Vagrant plugin to setup and teardown hosts entries automatically"

  s.required_rubygems_version = ">= 1.3.6"
  # TODO: Missing?
  # s.rubyforge_project         = "vagrant-hosts"

  s.add_dependency "virtualbox", "~> 0.9.1"
  s.add_dependency "vagrant", "~> 0.8.2"
  s.add_development_dependency "rspec", "~> 2.6.0"
  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files        = `git ls-files`.split("\n")
  # s.test_files   = TODO
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end

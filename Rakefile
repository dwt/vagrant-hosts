require 'rubygems'
require 'bundler'
require 'bundler/setup'
Bundler::GemHelper.install_tasks
require 'rspec/core/rake_task'

task :default => :spec

desc "Run the test suite."
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["-c", "-f progress"] 
  # may need later: , "-r ./spec/spec_helper.rb"
  t.pattern = 'test/**/*_spec.rb'
end

# desc "Run the test suite."
# task :test do
#   $:.unshift File.expand_path("../test", __FILE__)
# 
#   Dir["test/**/*_test.rb"].each do |f|
#     load f
#   end
# end

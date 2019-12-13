# from opsworks_ruby/recipes/setup.rb
# change ruby install
# remove Monit, debian, apache2
#
# frozen_string_literal: true

#
# Cookbook Name:: opsworks_ruby
# Recipe:: setup
#

apt_repository 'nginx' do
  uri        'http://nginx.org/packages/ubuntu/'
  components ['nginx']
  keyserver 'keyserver.ubuntu.com'
  key 'ABF5BD827BD9BF62'
  only_if { node['defaults']['webserver']['adapter'] == 'nginx' }
end

bundler2_applicable = Gem::Requirement.new('>= 3.0.0.beta1').satisfied_by?(
    Gem::Version.new(Gem::VERSION)
)
gem_package 'bundler' do
  action :install
  version '~> 1' unless bundler2_applicable
end

link '/usr/local/bin/bundle' do
  to '/opt/rbenv/shims/bundle'
end

every_enabled_application do |application|
  databases = []
  every_enabled_rds(self, application) do |rds|
    databases.push(Drivers::Db::Factory.build(self, application, rds: rds))
  end

  source = Drivers::Source::Factory.build(self, application)
  framework = Drivers::Framework::Factory.build(self, application, databases: databases)
  appserver = Drivers::Appserver::Factory.build(self, application)
  worker = Drivers::Worker::Factory.build(self, application, databases: databases)
  webserver = Drivers::Webserver::Factory.build(self, application)

  fire_hook(:setup, items: databases + [source, framework, appserver, worker, webserver])
end
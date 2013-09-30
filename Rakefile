#!/usr/bin/env rake
require 'bundler'
Bundler::GemHelper.install_tasks
Bundler.setup

desc 'Default: run specs.'
task :default => :spec

require 'rspec/core/rake_task'
desc 'Run specs'
RSpec::Core::RakeTask.new

require 'yard'
desc 'Generate API docs'
YARD::Rake::YardocTask.new

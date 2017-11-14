# frozen_string_literal: true

require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |t|
  # Vagrant does a bunch of circular requirements, so only enable warnings if
  # explicitly told to do so.
  t.ruby_opts = "-w" if ENV['VAGRANT_ENABLE_WARNINGS']
end

require "rubocop/rake_task"
RuboCop::RakeTask.new

require 'yard'
YARD::Rake::YardocTask.new

namespace :yard do
  task :server do
    desc 'Run the YARD documentation server'
    require 'yard/cli/server'
    YARD::CLI::Server.new.run('--reload')
  end
end

task default: %i[rubocop spec]

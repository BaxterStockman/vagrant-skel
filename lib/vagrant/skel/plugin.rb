# frozen_string_literal: true
module VagrantPlugins
  module Skel
    class Plugin < Vagrant.plugin(2)
      name 'skel command'
      description <<-DESC
      The `skel` command is a supercharged version of the `init` command; it
      helps you set up your working directory to be a Vagrant-managed
      environment.

      The `skel-inspect` command prints the data available to templates.
      DESC

      command 'skel' do
        require_relative 'command/skel'
        Command::Skel
      end

      command 'skel-inspect' do
        require_relative 'command/skel_inspect'
        Command::Inspect
      end
    end
  end
end


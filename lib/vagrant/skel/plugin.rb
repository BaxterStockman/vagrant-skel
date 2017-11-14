# frozen_string_literal: true

require 'vagrant'

require 'i18n'

module VagrantPlugins
  module Skel
    class Plugin < Vagrant.plugin(2)
      name 'skel command'
      description <<-DESC
      The `skel` command is a supercharged version of the `init` command.  It
      helps you set up your working directory to be a Vagrant-managed
      environment through templating files under your control.

      The `skel-inspect` command prints the data available to templates.
      DESC

      command 'skel' do
        init!
        require_relative 'command/skel'
        Command::Skel
      end

      command 'skel-inspect' do
        init!
        require_relative 'command/inspect'
        Command::Inspect
      end

      action_hook 'inject_simplecov', :environment_plugins_loaded do
        if ENV.key? 'SIMPLECOV_VAGRANT_SKEL_COMMAND_NAME'
          load VagrantPlugins::Skel.source_root.join('.simplecov').to_s
        end
      end

      def self.init!
        # i18n_path = Pathname.new("templates/locales/skel.yml").expand_path(VagrantPlugins::Skel.source_root)
        i18n_path = Pathname.new("locales/en.yml").expand_path(VagrantPlugins::Skel.source_root)
        return if I18n.load_path.include? i18n_path.to_s
        I18n.load_path << i18n_path.to_s
        I18n.reload!
      end
    end
  end
end

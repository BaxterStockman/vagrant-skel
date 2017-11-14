# frozen_string_literal: true

require 'pathname'

require 'vagrant'

require 'vagrant/skel/plugin'
require 'vagrant/skel/version'

module VagrantPlugins
  module Skel
    def self.source_root
      if ENV.key? 'SIMPLECOV_VAGRANT_SKEL_COMMAND_NAME'
        abort "---> SKEL SOURCE ROOT: #{Pathname.new('../../..').expand_path(__FILE__)}"
      end
      Pathname.new('../../..').expand_path(__FILE__)
    end
  end
end

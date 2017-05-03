require 'optparse'
require 'yaml'

require 'vagrant/util/template_renderer'

module VagrantPlugins
  module Skel
    module Command
      class Skel < Base
        def self.synopsis
          'initializes a new Vagrant environment with configurable template paths'
        end
      end
    end
  end
end


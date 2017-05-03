require 'optparse'
require 'yaml'

require 'vagrant/util/template_renderer'

module VagrantPlugins
  module Skel
    module Command
      class Inspect < Base
        def self.synopsis
          'prints the data available to templates'
        end
      end
    end
  end
end


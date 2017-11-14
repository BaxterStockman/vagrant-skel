# frozen_string_literal: true

require 'optparse'
require 'i18n'
require 'json'
require 'yaml'

require 'vagrant/util/template_renderer'

require_relative 'base'

module VagrantPlugins
  module Skel
    module Command
      class Inspect < Base
        def self.synopsis
          I18n.t('vagrant.skel.command.skel-inspect.synopsis')
        end

        def initialize(*)
          super
          @formatter = ->(t) { t }
        end

        def execute
          argv = super
          return unless argv

          metadata_map = {}
          each_template do |template_path|
            metadata_map[template_path.to_s] = merged_metadata_for(template_path).merge(@options)
          end

          @env.ui.info(@formatter.call(metadata_map), prefix: false)

          # Success, exit status 0
          0
        end

      private

        def prepare_options
          super.tap do |o|
            o.banner = I18n.t('vagrant.skel.command.skel-inspect.usage')

            o.on('--json') do
              @formatter = ->(t) { JSON.pretty_generate t }
            end

            o.on('--yaml') do
              @formatter = ->(t) { YAML.dump t }
            end

            o.on('--format FORMAT') do |format|
              @formatter = lambda do |t|
                require 'vagrant/util/template_renderer'
                begin
                  Vagrant::Util::TemplateRenderer.render_string(format, files: t)
                rescue => e
                  raise Errors::TemplateError, path: 'no', message: e.message
                end
              end
            end
          end
        end
      end
    end
  end
end

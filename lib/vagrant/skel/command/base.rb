# frozen_string_literal: true

require 'optparse'
require 'i18n'
require 'json'
require 'yaml'

require 'vagrant'
require 'vagrant/util/template_renderer'

require 'vagrant/skel/errors'
require 'vagrant/skel/version'

module VagrantPlugins
  module Skel
    module Command
      class Base < Vagrant.plugin('2', :command)
        ENV_PREFIX = 'VAGRANT_SKEL_'

        def initialize(*ary)
          super
          @source_path = VagrantPlugins::Skel.source_root.join('templates/Vagrantfile.erb')
          @options = {}
        end

        # @private
        def execute
          load_environment!
          parse_options(prepare_options)
        end

      private

        def load_environment!
          # Load all environment variables starting with ENV_PREFIX
          env_prefix_len = ENV_PREFIX.length

          ENV.each_pair do |k, v|
            next unless k.start_with? ENV_PREFIX
            @env.ui.detail(I18n.t('vagrant.skel.command.base.diag.environment', variable: k, value: v), channel: :error)

            begin
              @options[k[env_prefix_len..-1].downcase] = YAML.safe_load(v)
            rescue => e
              raise Errors::BadEnvironmentFormatError, variable: k, message: e.message
            end
          end

          @options
        end

        def prepare_options
          OptionParser.new do |o|
            o.separator ''
            o.separator 'Options:'
            o.separator ''

            o.on('--source FILE', String, I18n.t('vagrant.skel.command.base.option.source')) do |s|
              @source_path = Pathname.new(s)
            end

            o.on('--define KEY=VALUE', String, I18n.t('vagrant.skel.command.base.option.define')) do |d|
              k, v = d.split('=', 2)
              @env.ui.detail(I18n.t('vagrant.skel.command.base.diag.definition', variable: k, value: v), channel: :error)
              begin
                @options[k] = YAML.safe_load(v)
              rescue => e
                raise Errors::BadDefinitionFormatError, variable: k, message: e.message
              end
            end

            yield o if block_given?
          end
        end

        def each_template
          return enum_for(__method__) unless block_given?

          raise Errors::MissingTemplateError, path: @source_path.to_s unless @source_path.exist?

          template_paths = []
          if @source_path.directory?
            @source_path.find do |p|
              template_paths << p if p.extname == '.erb'
            end
          else
            unless @source_path.extname == '.erb'
              raise Errors::BadExtensionError
            end

            template_paths = [@source_path]
          end

          template_paths.each do |template_path|
            yield template_path.expand_path(@env.cwd)
          end
        end

        def metadata_file_for(path)
          Pathname.new(path).sub_ext('.json')
        end

        def shared_metadata_file_for(path)
          Pathname.new(path).parent.join('metadata.json')
        end

        def metadata_for(path)
          load_metadata(metadata_file_for(path))
        end

        def shared_metadata_for(path)
          load_metadata(shared_metadata_file_for(path))
        end

        def load_metadata(metadata_file)
          return {} unless metadata_file.file?
          JSON.parse(metadata_file.read)
        end

        def merged_metadata_for(path)
          @shared_metadata_map ||= {}
          @shared_metadata_map[path] ||= shared_metadata_for(path)
          metadata_for(path).merge(@shared_metadata_map[path])
        end
      end
    end
  end
end

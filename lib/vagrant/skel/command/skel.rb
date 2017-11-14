# frozen_string_literal: true

require 'optparse'
require 'i18n'
require 'yaml'

require 'vagrant/util/template_renderer'

require_relative 'base'

module VagrantPlugins
  module Skel
    module Command
      class Skel < Base
        def self.synopsis
          I18n.t('vagrant.skel.command.skel.synopsis')
        end

        def initialize(*ary)
          super
          @output_path = '-'
          @force = false
        end

        def execute
          argv = super
          return if !argv

          each_template do |template_path|
            metadata = merged_metadata_for(template_path).merge(@options)

            # Remove extension, as Vagrant automatically appends '.erb'
            begin
              contents = Vagrant::Util::TemplateRenderer.render(template_path.sub_ext(''), metadata)
            rescue => e
              raise Errors::TemplateError, message: e.message
            end

            if (save_path = save_path_for(template_path)).nil?
              @env.ui.info(contents, prefix: false)
            else
              @env.ui.detail("Saving rendered #{template_path} to #{save_path}")
              save_path.delete if save_path.exist? && @force
              save_path.parent.mkpath
              if save_path.exist?
                raise Errors::FileExistsError, src: template_path.to_s, dest: save_path.to_s
              end

              # Write out the contents
              begin
                save_path.open('w+') { |f| f.write(contents) }
              rescue Errno::EACCES
                raise Errors::WriteError, src: template_path.to_s, dest: save_path.to_s
              end

              @env.ui.success(I18n.t('vagrant.skel.command.skel.diag.success', path: save_path.to_s))
            end
          end

          # Success, exit status 0
          0
        end

      private

        def prepare_options
          super.tap do |o|
            o.banner = I18n.t('vagrant.skel.command.skel.usage')

            o.on('-f', '--force', I18n.t('vagrant.skel.command.skel.option.force')) do |f|
              @force = f
            end

            o.on('--output DIRECTORY', String, I18n.t('vagrant.skel.command.skel.option.output')) do |op|
              @output_path = Pathname.new(op)
            end
          end
        end

        def save_path_for(path)
          return if @output_path.to_s == '-'
          expanded_source = (@source_path.directory? ? @source_path : @source_path.parent).expand_path(@env.cwd)
          Pathname.new(path).sub_ext('').relative_path_from(expanded_source).expand_path(@output_path || @env.cwd)
        end
      end
    end
  end
end

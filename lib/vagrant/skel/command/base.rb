require 'optparse'
require 'yaml'

require 'vagrant/util/template_renderer'

module VagrantPlugins
  module Skel
    module Command
      class Base < Vagrant.plugin('2', :command)
        ENV_PREFIX = 'VAGRANT_SKEL_'

        def execute
          options = {}
          source_path = Pathname.new('~/.vagrant.d/templates/base')
          force = false
          output = nil

          # Load all environment variables starting with ENV_PREFIX
          env_prefix_len = ENV_PREFIX.length
          ENV.each_pair do |k, v|
            if k.start_with? ENV_PREFIX
              @env.ui.info "Processing #{k} => #{v}"
              begin
                options[k[env_prefix_len..-1].downcase.to_sym] = YAML.load(v)
              rescue => e
                @env.ui.error "Error loading environment variable #{k}: #{e.message}"
                # TODO raise a VagrantError
                abort
              end
            end
          end

          opts = OptionParser.new do |o|
            o.banner = 'Usage: vagrant skel [options] [name [url]]'
            o.separator ''
            o.separator 'Options:'
            o.separator ''

            o.on('-f', '--force', 'Overwrite existing Vagrantfile') do |f|
              force = f
            end

            o.on('--output DIRECTORY', String, "Output path for the templated files. '-' for stdout") do |op|
              output = Pathname.new(op)
            end

            o.on('--source FILE', String, 'Template source file or directory') do |s|
              source_path = Pathname.new(s)
            end

            o.on('--define KEY=VALUE', String, 'Define variables available in the template') do |d|
              k, v = d.split('=', 2)
              @env.ui.info "Processing #{k} => #{v}"
              begin
                options[k.to_sym] = YAML.load(v)
              rescue => e
                @env.ui.error "Error loading --define #{d}: #{e.message}"
                # TODO raise a VagrantError
                abort
              end
            end
          end

          # Parse the options
          argv = parse_options(opts)
          return if !argv

          template_paths = []
          if !source_path.exist?
            @env.ui.error "Template source path `#{source_path}` does not exist"
            abort
          elsif source_path.directory?
            template_paths = Dir["#{source_path}/*.erb"].map { |p| Pathname.new(p).sub_ext('') }
          else
            unless source_path.to_s.end_with? '.erb'
              @env.ui.error "Templates must end with the extension `.erb`"
              abort
            end

            template_paths = [source_path.sub_ext('')]
          end

          template_paths.each do |template_path|
            save_path = nil
            if output != '-'
              save_path = Pathname.new(template_path.basename).expand_path(output || @env.cwd)
              save_path.delete if save_path.exist? && force
              raise Vagrant::Errors::VagrantfileExistsError if save_path.exist?
            end

            contents = Vagrant::Util::TemplateRenderer.render(template_path, **options)

            if save_path
              # Write out the contents
              begin
                save_path.open('w+') do |f|
                  f.write(contents)
                end
              rescue Errno::EACCES
                raise Vagrant::Errors::VagrantfileWriteError
              end

              @env.ui.info(I18n.t('vagrant.commands.init.success'), prefix: false)
            else
              @env.ui.info(contents, prefix: false)
            end
          end

          # Success, exit status 0
          0
        end
      end
    end
  end
end


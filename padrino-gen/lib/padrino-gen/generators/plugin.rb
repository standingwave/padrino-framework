require File.expand_path(File.dirname(__FILE__) + "/runner") # FIXME: this must be require 'runner'
require 'padrino-core/cli/base' unless defined?(Padrino::Cli::Base)

module Padrino
  module Generators
    class Plugin < Thor::Group

      # Add this generator to our padrino-gen
      Padrino::Generators.add_generator(:plugin, self)

      # Define the source plugin root
      def self.source_root; File.expand_path(File.dirname(__FILE__)); end
      def self.banner; "padrino-gen plugin [plugin_name or plugin_path] [options]"; end

      # Include related modules
      include Thor::Actions
      include Padrino::Generators::Actions
      include Padrino::Generators::Runner

      desc "Description:\n\n\tpadrino-gen plugin generates a Padrino project from a plugin"

      argument :plugin_file, :desc => "The name or path of your padrino plugin", :required => false

      class_option :root, :desc => "The root destination", :aliases => '-r', :default => ".",   :type => :string
      class_option :list, :desc => "list available plugins", :aliases => '-l', :default => false, :type => :boolean
      # Show help if no argv given
      require_arguments!

      # Create the Padrino Plugin
      def setup_plugin
        if options[:list] # list method ran here
          say "showing list of plugins:", :yellow
          exit
        end
        self.destination_root, plugin_path = resolve_template_paths(:plugin, plugin_file)
        apply(plugin_path)
      end
    end # Plugins
  end # Generators
end # Padrino

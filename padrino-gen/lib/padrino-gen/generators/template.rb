require File.expand_path(File.dirname(__FILE__) + "/runner") # FIXME: this must be require 'runner'
require 'padrino-core/cli/base' unless defined?(Padrino::Cli::Base)

module Padrino
  module Generators
    class Template < Thor::Group

      # Add this generator to our padrino-gen
      Padrino::Generators.add_generator(:template, self)

      # Define the source template root
      def self.source_root; File.expand_path(File.dirname(__FILE__)); end
      def self.banner; "padrino-gen template [project_name] [template] [options]"; end

      # Include related modules
      include Thor::Actions
      include Padrino::Generators::Actions
      include Padrino::Generators::Runner

      desc "Description:\n\n\tpadrino-gen template generates a Padrino project from a template"

      argument :project_name, :desc => "The name of your padrino project"
      argument :template_file, :desc => "The location of the template file"

      class_option :root, :desc => "The root destination", :aliases => '-r', :default => ".",   :type => :string

      # Show help if no argv given
      require_arguments!

      # Create the Padrino Template
      def setup_template
        self.destination_root, template_path = resolve_template_paths(project_name, template_file)
        apply(template_path)
      end
    end # Templates
  end # Generators
end # Padrino
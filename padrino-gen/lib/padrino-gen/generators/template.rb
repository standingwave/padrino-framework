require File.dirname(__FILE__) + "/runner" # TODO: use File.expand_path because we can have some problems with ruby 1.9.2
require 'padrino-core/cli/base' unless defined?(Padrino::Cli::Base)
require 'open-uri'

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
      argument :template_path, :desc => "The location of the template file"

      class_option :root, :desc => "The root destination", :aliases => '-r', :default => ".",   :type => :string

      # Show help if no argv given
      require_arguments!

      # Create the Padrino Template
      def setup_template
        # TODO: Thor::Sandbox && download through http for gists
        self.destination_root = File.join(options[:root], project_name)
        # TODO: Check if we can use open(real_file).read i think it can work also with local files
        # TODO: Create in runner a "download" method for those that need to create from gists some libs.
        template_code = (template_path =~ /^http/ ? open(template_path).read : File.read(template_path))
        instance_eval(template_code)
      end
    end # Templates
  end # Generators
end # Padrino

require File.dirname(__FILE__) + "/runner"
module Padrino
  module Generators
    class Template < Thor::Group

      # Add this generator to our padrino-gen
      Padrino::Generators.add_generator(:template, self)

      # Define the source template root
      def self.source_root; File.expand_path(File.dirname(__FILE__)); end
      def self.banner; "padrino-gen template [name] [template] [options]"; end

      # Include related modules
      include Padrino::Generators::Actions


      desc "Description:\n\n\tpadrino-gen template generates a Padrino project from a template"

      argument :name, :desc => "The name of your padrino project"
      argument :template, :desc => "location of template file"

      class_option :root, :desc => "The root destination", :aliases => '-r', :default => ".",   :type => :string
      # Show help if no argv given
      require_arguments!

      # Create the Padrino Template
      def setup_template
        @runner = Padrino::Generators::Runner.new(name,options[:root])
        code = File.open(template, "r") { |f| f.read }
        @runner.instance_eval(code)
      end

    end # Templates  
  end # Generators
end # Padrino
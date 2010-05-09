require 'padrino-core/version'

module Padrino
  module Generators
    class Project < Thor::Group

      # Add this generator to our padrino-gen
      Padrino::Generators.add_generator(:project, self)

      # Define the source template root
      def self.source_root; File.expand_path(File.dirname(__FILE__)); end
      def self.banner; "padrino-gen project [name] [options]"; end

      # Include related modules
      include Thor::Actions
      include Padrino::Generators::Actions
      include Padrino::Generators::Components::Actions

      desc "Description:\n\n\tpadrino-gen project generates a new Padrino project"

      argument :name, :desc => "The name of your padrino project"

      class_option :run_bundle,   :desc => "Run bundle install",   :aliases => '-b', :default => false, :type => :boolean
      class_option :root,         :desc => "The root destination", :aliases => '-r', :default => ".",   :type => :string
      class_option :dev,          :desc => "Use padrino from a git checkout",        :default => false, :type => :boolean

      # Definitions for the available customizable components
      component_option :orm,        "database engine",    :aliases => '-d', :choices => [:activerecord, :datamapper, :mongomapper, :mongoid, :sequel, :couchrest, :simple_record], :default => :none
      component_option :test,       "testing framework",  :aliases => '-t', :choices => [:rspec, :shoulda, :cucumber, :bacon, :testspec, :riot], :default => :rspec
      component_option :mock,       "mocking library",    :aliases => '-m', :choices => [:mocha, :rr], :default => :none
      component_option :script,     "javascript library", :aliases => '-s', :choices => [:jquery, :prototype, :rightjs, :mootools, :extcore], :default => :none
      component_option :renderer,   "template engine",    :aliases => '-e', :choices => [:haml, :erb], :default => :haml
      component_option :stylesheet, "stylesheet engine",  :aliases => '-c', :choices => [:less, :sass], :default => :none

      # Show help if no argv given
      require_arguments!

      # Copies over the Padrino base application App
      def setup_project
        @class_name = name.gsub(/\W/, "_").underscore.classify
        self.destination_root = File.join(options[:root], name)
        directory("project/", destination_root)
        directory("app/", destination_root("app/"))
        store_component_config('.components')
        template "templates/Gemfile.tt", destination_root("Gemfile")
      end

      # For each component, retrieve a valid choice and then execute the associated generator
      def setup_components
        self.class.component_types.each do |comp|
          choice = resolve_valid_choice(comp)
          execute_component_setup(comp, choice)
        end
      end

      # Bundle all required components using bundler and Gemfile
      def bundle_dependencies
        if options[:run_bundle]
          say "Bundling application dependencies using bundler...", :yellow
          in_root { run 'bundle install' }
        end
      end

      # Finish message
      def finish
        say (<<-TEXT).gsub(/ {8}/,'')

        =================================================================
        #{name} is ready for development! Next, follow these steps:
        =================================================================
          1) cd #{name}
          2) bundle install
        =================================================================

        TEXT
      end
    end # Project
  end # Generators
end # Padrino
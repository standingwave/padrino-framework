require 'fileutils'
require 'git'

module Padrino
  module Generators
    module Runner

      # Generates project scaffold based on a given template file
      # project :test => :shoulda, :orm => :activerecord, :renderer => "haml"
      def project(options={})
        components = options.collect { |component,value| "--#{component}=#{value}" }
        params = [project_name, *components].push("-r=#{destination_root("../")}")
        Padrino::Generators::Project.start(params)
      end

      # Executes generator command for specified type with given arguments
      # generate :model, "post title:string body:text"
      # generate :controller, "posts get:index get:new post:new"
      # generate :migration, "AddEmailToUser email:string"
      def generate(type, arguments="")
        params = arguments.split(" ").push("-r=#{destination_root}")
        params.push("--app=#{@_appname}") if @_appname
        if type.to_s =~ /admin/ && !defined?(Padrino::Generators::AdminApp)
          Dir.chdir(destination_root) { require 'config/boot.rb' } # Loads the application environment
          require File.expand_path(File.dirname(__FILE__) + '/../../../../padrino-admin/lib/padrino-admin')
          Padrino::Generators.load_components!
        end
        generator = Padrino::Generators.mappings[type.to_sym]
        generator ? generator.start(params) : say("Cannot find Generator of type '#{type}'", :red)
      end

      # Executes rake command with given arguments
      # rake "custom task1 task2"
      def rake(command)
        # Dir.chdir(destination_root) { Padrino::Cli::Base.start(["rake", *command.split(" ")]) }
        Dir.chdir(destination_root) { `padrino rake #{command}` }
      end

      # Executes App generator. Accepts an optional block allowing generation inside subapp.
      # app :name
      # app :name do
      #  generate :model, "posts title:string"
      # end
      def app(name, &block)
        Padrino::Generators::App.start([name.to_s, "-r=#{destination_root}"])
        if block_given?
          @_appname = name.to_s
          block.call
          @_appname = nil
        end
      end

      # Executes git commmands in project using Grit
      # git :init
      # git :add, "."
      # git :commit, "hello world"
      def git(action, arguments=nil)
        FileUtils.cd(destination_root) do
          if action.to_s == 'init'
            Git.init(arguments || destination_root)
            say "Git repo has been initialized", :green
          else
            @_git ||= Git.open(destination_root)
            @_git.method(action).call(arguments)
          end
        end
      end

    end
  end
end
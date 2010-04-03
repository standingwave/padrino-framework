require 'fileutils'
require 'grit'

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
        "Padrino::Generators::#{type.to_s.camelize}".constantize.start(params)
      rescue NameError => e
        say "Cannot find Generator of type '#{type}'", :red
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
            arguments ||= destination_root
            say `git init #{arguments}`, :green # Grit hasn't implemented init
          else
            action = :commit_index if action == :commit # alias :commit to :commit_index
            @_git ||= Grit::Repo.new(destination_root)
            @_git.method(action).call(arguments)
          end
        end
      end

    end
  end
end
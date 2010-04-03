require 'grit'
module Padrino
  module Generators
    module Runner

      # Generates project scaffold based on template
      # project :test => :shoulda, :orm => :activerecord, :renderer => "haml"
      def project(options={})
        params = options.collect { |component,value| "--#{component}=#{value}" }
        args = [project_name, *params].push("-r=#{destination_root("../")}")
        Padrino::Generators::Project.start(args)
      end

      # Runs Generator command for designated type with given arguments
      # generate :model, "post title:string body:text"
      # generate :controller, "posts get:index get:new post:new"
      # generate :migration, "AddEmailToUser email:string"
      def generate(type,arguments="")
        params = arguments.split(" ").push("-r=#{destination_root}")
        params.push("--app=#{@_appname}") if @_appname
        "Padrino::Generators::#{type.to_s.camelize}".constantize.start(params)
      rescue NameError => e
        say "Cannot find Generator of type '#{type}'", :red
      end

      # Runs rake command with given arguments
      # rake "custom"
      def rake(command)
        # Dir.chdir(destination_root) { Padrino::Cli::Base.start(["rake", *command.split(" ")]) }
        Dir.chdir(destination_root) { `padrino rake #{command}` }
      end

      # Runs App generator
      # app :name, { }
      # app :name, do
      #  generate :model, "posts title:string"
      # end
      def app(name)
        Padrino::Generators::App.start([name.to_s, "-r=#{destination_root}"])
        if block_given?
          @_appname = name.to_s
          yield
          @_appname = nil
        end
      end

      # Runs Git commmands as wrapper to Grit
      # git :init
      # git :add, "."
      # git :commit, "hello world"
      def git(action, arguments=nil)
        Dir.chdir(destination_root) do
          if action.to_s == 'init'
            say `git init`, :green # Grit hasn't implemented init
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

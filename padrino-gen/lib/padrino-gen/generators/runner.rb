require 'fileutils'
require 'git'

module Padrino
  module Generators
    module Runner

      # Generates project scaffold based on a given template file
      # project :test => :shoulda, :orm => :activerecord, :renderer => "haml"
      def project(options={})
        components = options.collect { |component, value| "--#{component}=#{value}" }
        params = [project_name, *components].push("-r=#{destination_root("../")}")
        say "=> Generating project #{project_name} with options: #{params.join(" ")}", :yellow
        Padrino.bin_gen(*params.unshift("project"))
      end

      # Executes generator command for specified type with given arguments
      # generate :model, "post title:string body:text"
      # generate :controller, "posts get:index get:new post:new"
      # generate :migration, "AddEmailToUser email:string"
      def generate(type, arguments="")
        params = arguments.split(" ").push("-r=#{destination_root}")
        params.push("--app=#{@_app_name}") if @_app_name
        say "=> Generating #{type} with options: #{params.join(" ")}", :yellow
        Padrino.bin_gen(*params.unshift(type))
      end

      # Executes rake command with given arguments
      # rake "custom task1 task2"
      def rake(command)
        Padrino.bin("rake", command, "-c=#{destination_root}")
      end

      # Executes App generator. Accepts an optional block allowing generation inside subapp.
      # app :name
      # app :name do
      #  generate :model, "posts title:string"
      # end
      def app(name, &block)
        say "=> Generating app #{name} in #{destination_root}", :yellow
        Padrino.bin_gen("app", name, "-r=#{destination_root}")
        if block_given?
          @_app_name = name
          block.call
          @_app_name = nil
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

      private
        def padrino_gen
          File.expand_path("../../../../bin/padrino-gen", __FILE__)
        end
    end # Runner
  end # Generators
end # Padrino
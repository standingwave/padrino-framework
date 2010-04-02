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
      def generate(type,arguments)
        params = arguments.split(" ").push("-r=#{destination_root}")
        "Padrino::Generators::#{type.to_s.camelize}".constantize.start(params)
      rescue NameError => e
        say "Cannot find Generator of type '#{type}'", :red
      end
      
    end
  end
end

module Padrino
  module Generators
    class Runner
      include Thor::Actions

      attr_accessor :name,:root,:path

      def initialize(name,root)
        @name = name
        @root = root
        @path = File.join(root,name)
      end

      def project(options={})
        params = options.collect { |component,value| "--#{component}=#{value}" }
        Padrino::Generators::Project.dup.start([@name,params,"-r=#{@root}"].flatten)
      end

      def create_model(name,fields={})
        params = fields.collect { |field,type| "#{field}:#{type}" }
        Padrino::Generators::Model.dup.start([name.to_s,params,"-r=#{@path}"].flatten)
      end

      def create_controller(name,fields={})
        params = fields.collect { |field,type| "#{field}:#{type}" }
        Padrino::Generators::Controller.dup.start([name.to_s,params,"-r=#{@path}"].flatten)
      end
      
      def create_migration(name,fields={})
        params = fields.collect { |field,type| "#{field}:#{type}" }
        Padrino::Generators::Migration.dup.start([name.to_s,params,"-r=#{@path}"].flatten)
      end
      
    end
  end
end

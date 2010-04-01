module Padrino
  module Generators
    module Runner
      
      def project(options={})
        params = options.collect { |component,value| "--#{component}=#{value}" }
        Padrino::Generators::Project.dup.start([project_name,params,"-r=#{destination_root("../")}"].flatten)
      end

      def create_model(name,fields={})
        params = fields.collect { |field,type| "#{field}:#{type}" }
        Padrino::Generators::Model.dup.start([name.to_s,params,"-r=#{destination_root}"].flatten)
      end

      def create_controller(name,fields={})
        params = fields.collect { |field,type| "#{field}:#{type}" }
        Padrino::Generators::Controller.dup.start([name.to_s,params,"-r=#{destination_root}"].flatten)
      end
      
      def create_migration(name,fields={})
        params = fields.collect { |field,type| "#{field}:#{type}" }
        Padrino::Generators::Migration.dup.start([name.to_s,params,"-r=#{destination_root}"].flatten)
      end
      
    end
  end
end

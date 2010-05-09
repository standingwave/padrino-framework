SIMPLERECORD = (<<-SIMPLERECORD) unless defined?(SIMPLERECORD)

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
SimpleRecord.establish_connection(AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY, :logger => )

SIMPLERECORD

def setup_orm
  require_dependencies 'uuidtools-2.1.1', 'http_connection-1.3.0', 'xml-simple-1.0.12', 'aws-2.3.8', 'simple_record-1.2.1'
  create_file("config/database.rb", SIMPLERECORD)
  empty_directory('app/models')
end

SIMPLERECORD_MODEL = (<<-MODEL) unless defined?(SIMPLERECORD_MODEL)
class !NAME! < SimpleRecord::Base

end
MODEL

def create_model_file(name, fields)
  model_path = destination_root('app/models/', "#{name.to_s.underscore}.rb")
  model_contents = SIMPLERECORD_MODEL.gsub(/!NAME!/, name.to_s.downcase.camelize)
  create_file(model_path, model_contents)
end

def create_model_migration(filename, name, fields)
  # NO MIGRATION NEEDED
end

def create_migration_file(migration_name, name, columns)
  # NO MIGRATION NEEDED
end
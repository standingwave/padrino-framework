project :test => :rspec, :orm => :activerecord

generate :model, "post title:string body:text"
generate :controller, "posts get:index get:new post:new"
generate :migration, "AddEmailToUser email:string"
generate :fake, "AddEmailToUser email:string"

require_dependencies 'nokogiri'

inject_into_file "app/models/post.rb","#Hello", :after => "end\n"

initializer :test, "#Hello"
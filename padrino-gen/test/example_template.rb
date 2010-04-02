project :test => :rspec, :orm => :activerecord

generate :model, "post title:string body:text"
generate :controller, "posts get:index get:new post:new"
generate :migration, "AddEmailToUser email:string"
generate :fake, "foo bar"

require_dependencies 'nokogiri'

inject_into_file "app/models/post.rb","#Hello", :after => "end\n"

initializer :test, "#Hello"

=begin

  project(:test => :rspec, :orm => :activerecord) do
    generate :model, "post title:string body:text"
    app("test") do
      generate :controller, "posts get:index"
    end
  end
  
  require_dependencies 'nokogiri'
  initializer :test, "hello"

=end
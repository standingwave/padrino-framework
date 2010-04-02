project :test => :rspec, :orm => :activerecord

create_model :post, {
  :title => :string, 
  :body => :string
}

create_controller :posts, {
  :get => :index,
  :get => :new,
  :post => :new
}

create_migration :add_email_to_user, {
  :email => :string
}

require_dependencies 'nokogiri'

inject_into_file "app/models/post.rb","#Hello", :after => "end\n"

initializer :test, "#Hello"
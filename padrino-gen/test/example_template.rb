project :test => :rspec, :orm => :mongoid

create_model :post, {
  :title => :string, 
  :body => :string
}

create_controller :posts, {
  :get => :index,
  :get => :new,
  :post => :new
}
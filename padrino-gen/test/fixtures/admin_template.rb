project :test => :shoulda, :orm => :activerecord, :dev => true

generate :model, "post title:string body:text"
rake "ar:create"
generate :admin
rake "ar:migrate"
generate :admin_page, "post"
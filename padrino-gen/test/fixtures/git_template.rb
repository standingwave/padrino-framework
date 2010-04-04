project :test => :rspec, :orm => :activerecord, :dev => true
create_file destination_root('test.txt'), "hello"
git :init
git :add, "."
git :commit, "hello"
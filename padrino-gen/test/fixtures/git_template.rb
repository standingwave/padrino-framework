project :test => :rspec, :orm => :activerecord
create_file destination_root('test.txt'), "hello"
git :init
git :add, "."
git :commit, "hello"
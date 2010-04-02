require File.expand_path(File.dirname(__FILE__) + '/helper')
require 'thor/group'
require 'fakeweb'

class TestTemplateGenerator < Test::Unit::TestCase
  def setup
    FakeWeb.allow_net_connect = false
    `rm -rf /tmp/sample_project`
    @template = Padrino::Generators::Template.dup
    @output = silence_logger { @template.start(['sample_project', File.dirname(__FILE__)+ '/example_template.rb','-r=/tmp']) }
  end

  context 'the template generator' do
    should "allow template generator to generate project scaffold" do
      assert_file_exists('/tmp/sample_project')
      assert_file_exists('/tmp/sample_project/app')
      assert_file_exists('/tmp/sample_project/config/boot.rb')
      assert_file_exists('/tmp/sample_project/spec/spec_helper.rb')
      assert_file_exists('/tmp/sample_project/public/favicon.ico')
    end
    
    should "create models" do
      assert_file_exists('/tmp/sample_project/app/models/post.rb')
      assert_match_in_file(/class Post/, '/tmp/sample_project/app/models/post.rb')
    end
    
    should "create controllers" do
      assert_file_exists('/tmp/sample_project/app/controllers/posts.rb')
      assert_match_in_file(/:posts/, '/tmp/sample_project/app/controllers/posts.rb')
      assert_match_in_file(/get :index/,'/tmp/sample_project/app/controllers/posts.rb')
    end
    
    should "create migrations" do
      migration_file_path = "/tmp/sample_project/db/migrate/002_add_email_to_user.rb"
      assert_match_in_file(/class AddEmailToUser/m, migration_file_path)
      assert_match_in_file(/t.string :email/, migration_file_path)
      assert_match_in_file(/t.remove :email/, migration_file_path)
    end
    
    should "include nokogiri in gemfile" do
      assert_match_in_file(/nokogiri/, '/tmp/sample_project/Gemfile')
    end
    
    should "inject_into_file post model" do
      assert_match_in_file(/Hello/,'/tmp/sample_project/app/models/post.rb')
    end
    
    should "create TestInitializer" do
      assert_match_in_file(/TestInitializer/,'/tmp/sample_project/app/app.rb')
      assert_file_exists('/tmp/sample_project/lib/test.rb')
    end
    
    should "catch error on invalid Generator type" do
      assert_match(/Cannot find Generator of type 'fake'/,@output)
    end
    
  end

end

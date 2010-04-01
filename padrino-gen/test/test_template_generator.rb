require File.expand_path(File.dirname(__FILE__) + '/helper')
require 'thor/group'
require 'fakeweb'

class TestTemplateGenerator < Test::Unit::TestCase
  def setup
    FakeWeb.allow_net_connect = false
    `rm -rf /tmp/sample_project`
    @template = Padrino::Generators::Template.dup
  end

  context 'the template generator' do
    should "allow template generator to generate project scaffold" do
      assert_nothing_raised { silence_logger { @template.start(['sample_project', 'example_template.rb','-r=/tmp']) } }
      assert_file_exists('/tmp/sample_project')
      assert_file_exists('/tmp/sample_project/app')
      assert_file_exists('/tmp/sample_project/config/boot.rb')
      assert_file_exists('/tmp/sample_project/spec/spec_helper.rb')
      assert_file_exists('/tmp/sample_project/public/favicon.ico')
    end
    
    should "create models" do
      assert_nothing_raised { silence_logger { @template.start(['sample_project', 'example_template.rb','-r=/tmp/']) } }
      assert_file_exists('/tmp/sample_project/app/models/post.rb')
      assert_match_in_file(/class Post/, '/tmp/sample_project/app/models/post.rb')
    end
    
    should "create controllers" do
      assert_nothing_raised { silence_logger { @template.start(['sample_project', 'example_template.rb','-r=/tmp/']) } }
      assert_file_exists('/tmp/sample_project/app/controllers/posts.rb')
      assert_match_in_file(/:posts/, '/tmp/sample_project/app/controllers/posts.rb')
      assert_match_in_file(/get :index/,'/tmp/sample_project/app/controllers/posts.rb')
    end
    
  end

end

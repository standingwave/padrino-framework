require File.expand_path(File.dirname(__FILE__) + '/helper')
require 'thor/group'
require 'fakeweb'

class TestTemplateGenerator < Test::Unit::TestCase
  def setup
    FakeWeb.allow_net_connect = false
    [:sample_project, :sample_git, :sample_rake, :sample_admin].each { |proj| system("rm -rf /tmp/#{proj}") }
    @template = Padrino::Generators::Template.dup
  end

  context 'the template generator' do
    setup do
      example_template_path = File.join(File.dirname(__FILE__), 'fixtures', 'example_template.rb')
      @output = silence_logger { @template.dup.start(['sample_project', example_template_path, '-r=/tmp']) }
    end

    should "allow template generator to generate project scaffold" do
      assert_file_exists('/tmp/sample_project')
      assert_file_exists('/tmp/sample_project/app')
      assert_file_exists('/tmp/sample_project/config/boot.rb')
      assert_file_exists('/tmp/sample_project/test/test_config.rb')
      assert_file_exists('/tmp/sample_project/public/favicon.ico')
    end

    should "generate project using specified components" do
      assert_match_in_file(/ActiveRecord/, '/tmp/sample_project/config/database.rb')
      assert_match_in_file(/Test::Unit::TestCase/, '/tmp/sample_project/test/test_config.rb')
      assert_match_in_file(/shoulda/, '/tmp/sample_project/Gemfile')
    end

    should "create specified models" do
      assert_file_exists('/tmp/sample_project/app/models/post.rb')
      assert_match_in_file(/class Post/, '/tmp/sample_project/app/models/post.rb')
    end

    should "create specified controllers" do
      assert_file_exists('/tmp/sample_project/app/controllers/posts.rb')
      assert_match_in_file(/:posts/, '/tmp/sample_project/app/controllers/posts.rb')
      assert_match_in_file(/get :index/,'/tmp/sample_project/app/controllers/posts.rb')
    end

    should "create specified migrations" do
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
      assert_match_in_file(/register TestInitializer/,'/tmp/sample_project/app/app.rb')
      assert_file_exists('/tmp/sample_project/lib/test.rb')
      assert_match_in_file(/# Example/, '/tmp/sample_project/lib/test.rb')
    end

    should "catch error on invalid Generator type" do
      assert_match(/Cannot find Generator of type 'fake'/, @output)
    end

    should "generate specified app" do
      assert_file_exists('/tmp/sample_project/testapp/app.rb')
      assert_file_exists('/tmp/sample_project/testapp/controllers')
      assert_file_exists('/tmp/sample_project/testapp/controllers/users.rb')
    end
  end

  context "with git commands" do
    setup do
      git_template_path = File.join(File.dirname(__FILE__), 'fixtures', 'git_template.rb')
      @output = silence_logger { @template.start(['sample_git', git_template_path, '-r=/tmp']) }
    end

    should "git init" do
      assert_file_exists('/tmp/sample_git/.git')
      assert_match(/Initialized/i, @output)
    end

    should "git add and commit" do
      Dir.chdir("/tmp/sample_git") do
        assert_match(/nothing to commit/, `git status`)
      end
    end
  end

  context "with rake method" do
    setup do
      rake_template_path = File.join(File.dirname(__FILE__), 'fixtures', 'rake_template.rb')
      @output = silence_logger { @template.start(['sample_rake', rake_template_path, '-r=/tmp']) }
    end

    should "run rake task and list tasks" do
      assert_match_in_file(/Completed custom rake test/,'/tmp/sample_rake/tmp/custom.txt')
    end
  end

  context "with admin commands" do
    setup do
      admin_template_path = File.join(File.dirname(__FILE__), 'fixtures', 'admin_template.rb')
      @output = silence_logger { @template.dup.start(['sample_admin', admin_template_path, '-r=/tmp']) }
    end

    should "create specified models" do
      assert_file_exists('/tmp/sample_admin/app/models/post.rb')
      assert_match_in_file(/class Post/, '/tmp/sample_admin/app/models/post.rb')
    end

    should "generate admin application" do
      assert_file_exists('/tmp/sample_admin/app/models/account.rb')
      assert_file_exists('/tmp/sample_admin/admin/app.rb')
      assert_file_exists('/tmp/sample_admin/admin/views')
      assert_file_exists('/tmp/sample_admin/admin/controllers/accounts.rb')
      assert_file_exists('/tmp/sample_admin/admin/views/accounts/new.haml')
    end

    should "generate admin page for posts" do
      # assert_file_exists('/tmp/sample_admin/admin/controllers/posts.rb')
      # assert_file_exists('/tmp/sample_admin/admin/views/posts/new.haml')
    end
  end

end
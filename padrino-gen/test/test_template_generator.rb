require File.expand_path(File.dirname(__FILE__) + '/helper')

class TestTemplateGenerator < Test::Unit::TestCase
  def setup
    %w(sample_project sample_git sample_rake sample_admin).each { |proj| system("rm -rf /tmp/#{proj}") }
  end

  context 'the template generator' do
    setup do
      example_template_path = File.join(File.dirname(__FILE__), 'fixtures', 'example_template.rb')
      Padrino.bin_gen('template', 'sample_project', example_template_path, '-r=/tmp', '> /dev/null')
    end

    should "generate correctly a project with templates" do
      # Allow template generator to generate project scaffold
      assert_file_exists('/tmp/sample_project')
      assert_file_exists('/tmp/sample_project/app')
      assert_file_exists('/tmp/sample_project/config/boot.rb')
      assert_file_exists('/tmp/sample_project/test/test_config.rb')
      assert_file_exists('/tmp/sample_project/public/favicon.ico')

      # Generate project using specified components
      assert_match_in_file(/ActiveRecord/, '/tmp/sample_project/config/database.rb')
      assert_match_in_file(/Test::Unit::TestCase/, '/tmp/sample_project/test/test_config.rb')
      assert_match_in_file(/shoulda/, '/tmp/sample_project/Gemfile')

      # Create specified models
      assert_file_exists('/tmp/sample_project/app/models/post.rb')
      assert_match_in_file(/class Post/, '/tmp/sample_project/app/models/post.rb')

      # Create specified controllers
      assert_file_exists('/tmp/sample_project/app/controllers/posts.rb')
      assert_match_in_file(/:posts/, '/tmp/sample_project/app/controllers/posts.rb')
      assert_match_in_file(/get :index/,'/tmp/sample_project/app/controllers/posts.rb')

      # Create specified migrations
      migration_file_path = "/tmp/sample_project/db/migrate/002_add_email_to_user.rb"
      assert_match_in_file(/class AddEmailToUser/m, migration_file_path)
      assert_match_in_file(/t.string :email/, migration_file_path)
      assert_match_in_file(/t.remove :email/, migration_file_path)

      # Include nokogiri in gemfile
      assert_match_in_file(/nokogiri/, '/tmp/sample_project/Gemfile')

      # Inject_into_file post model
      assert_match_in_file(/Hello/,'/tmp/sample_project/app/models/post.rb')

      # Create TestInitializer
      assert_match_in_file(/register TestInitializer/,'/tmp/sample_project/app/app.rb')
      assert_match_in_file(/# Example/, '/tmp/sample_project/lib/test_init.rb')

      # Generate specified app
      assert_file_exists('/tmp/sample_project/testapp/app.rb')
      assert_file_exists('/tmp/sample_project/testapp/controllers')
      assert_file_exists('/tmp/sample_project/testapp/controllers/users.rb')
    end
  end

  context "with template generator resolving urls" do
    setup do
      @template_gen = Padrino::Generators::Template.dup
      @template_gen.any_instance.stubs(:apply).with(nil)
    end

    should "resolve generic url properly" do
      template_file = 'http://www.example.com/test.rb'
      @template_gen.any_instance.expects(:apply).with(template_file).returns(true).once
      @template_gen.start([ 'sample_project', template_file, '-r=/tmp'])
    end

    should "resolve gist url properly" do
      FakeWeb.register_uri(:get, "http://gist.github.com/357045", :body => '<a href="/raw/357045/4356/blog_template.rb">raw</a>')
      template_file = 'http://gist.github.com/357045'
      resolved_path = 'http://gist.github.com/raw/357045/4356/blog_template.rb'
      @template_gen.any_instance.expects(:apply).with(resolved_path).returns(true).once
      @template_gen.start([ 'sample_project', template_file, '-r=/tmp'])
    end

    should "resolve official plugin" do
      template_file = 'hoptoad'
      resolved_path = "http://github.com/padrino/padrino-recipes/raw/master/plugins/hoptoad_plugin.rb"
      @template_gen.any_instance.expects(:apply).with(resolved_path).returns(true).once
      @template_gen.start([ 'plugin', template_file, '-r=/tmp'])
    end

    should "resolve official template" do
      template_file = 'sampleblog'
      resolved_path = "http://github.com/padrino/padrino-recipes/raw/master/templates/sampleblog_template.rb"
      @template_gen.any_instance.expects(:apply).with(resolved_path).returns(true).once
      @template_gen.start([ 'sample_project', template_file, '-r=/tmp'])
    end

    should "resolve local file" do
      template_file = 'path/to/local/file.rb'
      @template_gen.any_instance.expects(:apply).with(File.expand_path(template_file)).returns(true).once
      @template_gen.start([ 'sample_project', template_file, '-r=/tmp'])
    end
  end

  context "with git commands" do
    setup do
      git_template_path = File.join(File.dirname(__FILE__), 'fixtures', 'git_template.rb')
      Padrino.bin_gen('template', 'sample_git', git_template_path, '-r=/tmp', '> /dev/null')
    end

    should "generate correctly a repository" do
      # Git init
      assert_file_exists('/tmp/sample_git/.git')

      # Git add and commit
      Dir.chdir("/tmp/sample_git") do
        assert_match(/nothing to commit/, `git status`)
      end
    end
  end

  context "with rake method" do
    setup do
      rake_template_path = File.join(File.dirname(__FILE__), 'fixtures', 'rake_template.rb')
      Padrino.bin_gen('template', 'sample_rake', rake_template_path, '-r=/tmp', '> /dev/null')
    end

    should "Run rake task and list tasks" do
      assert_match_in_file(/Completed custom rake test/,'/tmp/sample_rake/tmp/custom.txt')
    end
  end

  context "with admin commands" do
    setup do
      admin_template_path = File.join(File.dirname(__FILE__), 'fixtures', 'admin_template.rb')
      Padrino.bin_gen('template', 'sample_admin', admin_template_path, '-r=/tmp', '> /dev/null')
    end

    should "generate correctly an admin" do
      # Create specified models
      assert_file_exists('/tmp/sample_admin/app/models/post.rb')
      assert_match_in_file(/class Post/, '/tmp/sample_admin/app/models/post.rb')

      # Generate admin application
      assert_file_exists('/tmp/sample_admin/app/models/account.rb')
      assert_file_exists('/tmp/sample_admin/admin/app.rb')
      assert_file_exists('/tmp/sample_admin/admin/views')
      assert_file_exists('/tmp/sample_admin/admin/controllers/accounts.rb')
      assert_file_exists('/tmp/sample_admin/admin/views/accounts/new.haml')

      # Generate admin page for posts
      assert_file_exists('/tmp/sample_admin/admin/controllers/posts.rb')
      assert_file_exists('/tmp/sample_admin/admin/views/posts/new.haml')
    end
  end
end
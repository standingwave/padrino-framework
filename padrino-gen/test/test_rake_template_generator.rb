require File.expand_path(File.dirname(__FILE__) + '/helper')
require 'thor/group'
require 'fakeweb'

class TestRakeTemplateGenerator < Test::Unit::TestCase
  def setup
    FakeWeb.allow_net_connect = false
    `rm -rf /tmp/sample_rake`
    @template = Padrino::Generators::Template.dup
  end

  context "rake method" do
    setup do
      @output = silence_logger { @template.start(['sample_rake', File.dirname(__FILE__)+ '/rake_template.rb','-r=/tmp']) }
    end
  
    should "run rake task and list tasks" do
      assert_match_in_file(/Completed custom rake test/,'/tmp/sample_rake/tmp/custom')
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/helper')

class TestGenerator < Test::Unit::TestCase

  context "the generator" do
    should "have default generators" do
      %w{controller mailer migration model app plugin}.each do |gen|
        assert Padrino::Generators.mappings.has_key?(gen.to_sym), "Should have key mapping for '#{gen.to_sym}'!"
        assert_equal "Padrino::Generators::#{gen.classify}", Padrino::Generators.mappings[gen.to_sym].name
        assert Padrino::Generators.mappings[gen.to_sym].respond_to?(:start), "Generator '#{gen.to_sym}' should respond to start!"
      end
    end
  end
end
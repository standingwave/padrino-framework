ENV['PADRINO_ENV'] = 'test'
PADRINO_ROOT = File.dirname(__FILE__) unless defined? PADRINO_ROOT

require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'rack/test'
require 'sinatra/base'

# We try to load the vendored padrino-core if exist
%w(core).each do |lib|
  if File.exist?(File.dirname(__FILE__) + "/../../padrino-#{lib}/lib")
    $:.unshift File.dirname(__FILE__) + "/../../padrino-#{lib}/lib"
  end
end

require 'padrino-core'
require 'padrino-mailer'

Padrino::Mailer.defaults { delivery_method :test }

module Kernel
  # Silences the output by redirecting to stringIO
  # silence_logger { ...commands... } => "...output..."
  def silence_logger(&block)
    $stdout = log_buffer = StringIO.new
    block.call
    $stdout = STDOUT
    log_buffer.string
  end
  alias :silence_stdout :silence_logger

  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end unless respond_to?(:silence_warnings)
end

class Test::Unit::TestCase
  include Rack::Test::Methods

  # Sets up a Sinatra::Base subclass defined with the block
  # given. Used in setup or individual spec methods to establish
  # the application.
  def mock_app(base=Padrino::Application, &block)
    @app = Sinatra.new(base, &block)
  end

  def app
    Rack::Lint.new(@app)
  end

  # Asserts that a file matches the pattern
  def assert_match_in_file(pattern, file)
    assert File.exist?(file), "File '#{file}' does not exist!"
    assert_match pattern, File.read(file)
  end

  # Delegate other missing methods to response.
  def method_missing(name, *args, &block)
    if response && response.respond_to?(name)
      response.send(name, *args, &block)
    else
      super(name, *args, &block)
    end
  end

  alias :response :last_response
end
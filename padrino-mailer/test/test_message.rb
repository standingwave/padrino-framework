require File.expand_path(File.dirname(__FILE__) + '/helper')

class TestMessage < Test::Unit::TestCase

  context 'the message' do
    should "accept headers and body" do
      message = Padrino::Mailer::Message.new do
        from    'padrino@me.com'
        to      'padrino@you.com'
        subject 'Hello there Padrino'
        body    'This is a body of text'
      end

      assert_equal ['padrino@me.com'],       message.from
      assert_equal ['padrino@you.com'],      message.to
      assert_equal 'Hello there Padrino',    message.subject
      assert_equal 'This is a body of text', message.body.to_s
    end

    should "render an absolute template" do
      message = Padrino::Mailer::Message.new do
        from    'padrino@me.com'
        to      'padrino@you.com'
        subject 'Hello there Padrino'
        body    render(File.dirname(__FILE__) + '/fixtures/basic.erb')
      end

      assert_equal ['padrino@me.com'],    message.from
      assert_equal ['padrino@you.com'],   message.to
      assert_equal 'Hello there Padrino', message.subject
      assert_equal 'This is a body of text from a template', message.body.to_s
    end

    should "raise an error if template was not found" do
      assert_raise Errno::ENOENT do
        Padrino::Mailer::Message.new do
          from    'padrino@me.com'
          to      'padrino@you.com'
          subject 'Hello there Padrino'
          body    render('/foo/bar')
        end
      end
    end

    should "use views paths" do
      message = Padrino::Mailer::Message.new do
        views   File.dirname(__FILE__) + '/fixtures/views'
        from    'padrino@me.com'
        to      'padrino@you.com'
        subject 'Hello there Padrino'
        body    render('bar')
      end

      assert_equal ['padrino@me.com'],    message.from
      assert_equal ['padrino@you.com'],   message.to
      assert_equal 'Hello there Padrino', message.subject
      assert_equal 'This is a bar message in mailers dir', message.body.to_s
    end

    should "use views and mailers paths" do
      message = Padrino::Mailer::Message.new do
        views   File.dirname(__FILE__) + '/fixtures/views'
        mailer  :alternate
        from    'padrino@me.com'
        to      'padrino@you.com'
        subject 'Hello there Padrino'
        body    render('foo')
      end

      assert_equal ['padrino@me.com'],    message.from
      assert_equal ['padrino@you.com'],   message.to
      assert_equal 'Hello there Padrino', message.subject
      assert_equal 'This is a foo message in mailers/alternate dir', message.body.to_s
    end

    should "use a custom layout" do
      message = Padrino::Mailer::Message.new do
        from    'padrino@me.com'
        to      'padrino@you.com'
        subject 'Hello there Padrino'
        body    render(File.dirname(__FILE__) + '/fixtures/basic.erb', :layout => File.dirname(__FILE__) + '/fixtures/layout.erb')
      end

      assert_equal ['padrino@me.com'],    message.from
      assert_equal ['padrino@you.com'],   message.to
      assert_equal 'Hello there Padrino', message.subject
      assert_equal 'Layout Basic This is a body of text from a template', message.body.to_s
    end

    should "use the default detected layout" do
      message = Padrino::Mailer::Message.new do
        views   File.dirname(__FILE__) + '/fixtures/views'
        mailer  :sample
        from    'padrino@me.com'
        to      'padrino@you.com'
        subject 'Hello there Padrino'
        body    render('foo')
      end

      assert_equal ['padrino@me.com'],    message.from
      assert_equal ['padrino@you.com'],   message.to
      assert_equal 'Hello there Padrino', message.subject
      assert_equal 'Layout Sample This is a foo message in mailers/sample dir', message.body.to_s
    end
  end
end
require File.expand_path(File.dirname(__FILE__) + '/helper')

class TestPart < Test::Unit::TestCase

  context "the part" do
    should "use correctly parts" do
      message = Padrino::Mailer::Message.new do
        views   File.dirname(__FILE__) + '/fixtures/views'
        mailer  :sample
        to      'padrino@test.lindsaar.net'
        subject "nested multipart"
        from    "test@example.com"

        text_part do
          body 'plain text'
        end

        html_part do
          body render('foo')
        end

        part do
          body 'other'
        end
      end

      assert_equal 4, message.parts.length
      assert_equal "text/plain", message.parts[0].content_type
      assert_equal "plain text", message.parts[0].body.decoded
      assert_equal "text/html", message.parts[1].content_type
      assert_equal "Layout Sample This is a foo message in mailers/sample dir", message.parts[1].body.decoded
      assert_equal "text/plain", message.parts[2].content_type
      assert_equal "other", message.parts[2].body.decoded
    end

    should "works with multipart templates" do
      message = Padrino::Mailer::Message.new do
        views   File.dirname(__FILE__) + '/fixtures/views'
        mailer  :multipart
        to      'padrino@test.lindsaar.net'
        subject "nested multipart"
        from    "test@example.com"

        text_part do
          body render('basic.text')
        end

        html_part do
          body render('basic.html')
        end
      end

      assert_equal 2, message.parts.length
      assert_equal "text/plain", message.parts[0].content_type
      assert_equal "plain text", message.parts[0].body.decoded
      assert_equal "text/html", message.parts[1].content_type
      assert_equal "text html", message.parts[1].body.decoded
    end

    should "works with less explict multipart templates" do
      message = Padrino::Mailer::Message.new do
        views   File.dirname(__FILE__) + '/fixtures/views'
        mailer  :multipart
        to      'padrino@test.lindsaar.net'
        subject "nested multipart"
        from    "test@example.com"

        text_part render('basic.text')
        html_part render('basic.html')
      end

      assert_equal 2, message.parts.length
      assert_equal "text/plain", message.parts[0].content_type
      assert_equal "plain text", message.parts[0].body.decoded
      assert_equal "text/html", message.parts[1].content_type
      assert_equal "text html", message.parts[1].body.decoded
    end

    should "provide a way to instantiate a new part as you go down" do
      message = Padrino::Mailer::Message.new do
        to           'padrino@test.lindsaar.net'
        subject      "nested multipart"
        from         "test@example.com"
        content_type "multipart/mixed"

        part :content_type => "multipart/alternative", :content_disposition => "inline", :headers => { "foo" => "bar" } do |p|
          p.part :content_type => "text/plain", :body => "test text\nline #2"
          p.part :content_type => "text/html",  :body => "<b>test</b> HTML<br/>\nline #2"
        end
      end

      assert_equal 2, message.parts.first.parts.length
      assert_equal "text/plain", message.parts.first.parts[0][:content_type].string
      assert_equal "test text\nline #2", message.parts.first.parts[0].body.decoded
      assert_equal "text/html", message.parts.first.parts[1][:content_type].string
      assert_equal "<b>test</b> HTML<br/>\nline #2", message.parts.first.parts[1].body.decoded
    end
  end
end
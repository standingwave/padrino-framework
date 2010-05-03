require File.expand_path(File.dirname(__FILE__) + '/helper')

class TestMailer < Test::Unit::TestCase

  context 'the mailer' do
    should "be able to make a new email" do
      assert_kind_of Padrino::Mailer::Message, Padrino::Mailer.new
    end
  end

  context 'the mailer in a app' do

    should 'send a basic inline email' do
      mock_app do
        get "/" do
          email = email do
            from    'padrino@me.com'
            to      'padrino@you.com'
            subject 'Hello there Padrino'
            body    'Body'
          end
          assert_equal ['padrino@me.com'],    email.from
          assert_equal ['padrino@you.com'],   email.to
          assert_equal 'Hello there Padrino', email.subject
          assert_equal 'Body',                email.body.to_s
        end
      end
      get "/"
      assert ok?
    end

    should 'send a basic inline from hash' do
      mock_app do
        get "/" do
          email = email({
            :from    => 'padrino@me.com',
            :to      => 'padrino@you.com',
            :subject => 'Hello there Padrino',
            :body    => 'Body'
          })
          assert_equal ['padrino@me.com'],    email.from
          assert_equal ['padrino@you.com'],   email.to
          assert_equal 'Hello there Padrino', email.subject
          assert_equal 'Body',                email.body.to_s
        end
      end
      get "/"
      assert ok?
    end

    should 'send a email inline' do
      mock_app do
        get "/" do
          email = email do
            from    'padrino@me.com'
            to      'padrino@you.com'
            subject 'Hello there Padrino'
            body    render(File.dirname(__FILE__) + '/fixtures/basic.erb')
          end
          assert_equal ['padrino@me.com'],    email.from
          assert_equal ['padrino@you.com'],   email.to
          assert_equal 'Hello there Padrino', email.subject
          assert_equal 'This is a body of text from a template', email.body.to_s
        end
      end
      get "/"
      assert ok?
    end

    should 'send emails without layout' do
      mock_app do
        set :views, File.dirname(__FILE__) + '/fixtures/views'
        mailer :alternate do
          email :foo do
            from    'padrino@me.com'
            to      'padrino@you.com'
            subject 'Hello there Padrino'
            body    render('foo')
          end
        end
        get("/") { deliver(:alternate, :foo) }
      end
      get "/"
      assert ok?
      email = @app.deliver(:alternate, :foo)
      assert_equal ['padrino@me.com'],    email.from
      assert_equal ['padrino@you.com'],   email.to
      assert_equal 'Hello there Padrino', email.subject
      assert_equal 'This is a foo message in mailers/alternate dir', email.body.to_s
    end

    should 'raise an error if there are two messages with the same name' do
      assert_raise RuntimeError do
        mock_app do
          mailer :foo do
            email :bar do; end
            email :bar do; end
          end
        end
      end
    end
  end
end
require File.expand_path(File.dirname(__FILE__) + '/helper')

class TestEmail < Test::Unit::TestCase
  context 'the mailer in a app' do

    should 'send a basic inline email' do
      mock_app do
        get "/" do
          email do
            from    'padrino@me.com'
            to      'padrino@you.com'
            subject 'Hello there Padrino'
            body    'Body'
            via     :test
          end
        end
      end
      get "/"
      assert response.ok?
      email = pop_last_delivery
      assert_equal ['padrino@me.com'],    email.from
      assert_equal ['padrino@you.com'],   email.to
      assert_equal 'Hello there Padrino', email.subject
      assert_equal 'Body',                email.body.to_s
    end

    should 'send a basic inline from hash' do
      mock_app do
        get "/" do
          email({
                  :from    => 'padrino@me.com',
                  :to      => 'padrino@you.com',
                  :subject => 'Hello there Padrino',
                  :body    => 'Body',
                  :via     => :test
          })
        end
      end
      get "/"
      assert response.ok?
      email = pop_last_delivery
      assert_equal ['padrino@me.com'],    email.from
      assert_equal ['padrino@you.com'],   email.to
      assert_equal 'Hello there Padrino', email.subject
      assert_equal 'Body',                email.body.to_s
    end

    should 'send a email inline' do
      mock_app do
        get "/" do
          email do
            from    'padrino@me.com'
            to      'padrino@you.com'
            subject 'Hello there Padrino'
            body    render(File.dirname(__FILE__) + '/fixtures/basic.erb')
            via     :test
          end
        end
      end
      get "/"
      assert response.ok?
      email = pop_last_delivery
      assert_equal ['padrino@me.com'],    email.from
      assert_equal ['padrino@you.com'],   email.to
      assert_equal 'Hello there Padrino', email.subject
      assert_equal 'This is a body of text from a template', email.body.to_s
    end

    should 'send emails without layout' do
      mock_app do
        register Padrino::Mailer
        set :views, File.dirname(__FILE__) + '/fixtures/views'
        mailer :alternate do
          message :foo do
            from    'padrino@me.com'
            to      'padrino@you.com'
            subject 'Hello there Padrino'
            body    render('foo')
            via     :test
          end
        end
        get("/") { deliver(:alternate, :foo) }
      end
      get "/"
      assert response.ok?
      email = @app.deliver(:alternate, :foo)
      assert_equal ['padrino@me.com'],    email.from
      assert_equal ['padrino@you.com'],   email.to
      assert_equal 'Hello there Padrino', email.subject
      assert_equal 'This is a foo message in mailers/alternate dir', email.body.to_s
    end

    should 'raise an error if there are two messages with the same name' do
      assert_raise RuntimeError do
        mock_app do
          register Padrino::Mailer
          mailer :foo do
            message :bar do; end
            message :bar do; end
          end
        end
      end
    end
  end
end

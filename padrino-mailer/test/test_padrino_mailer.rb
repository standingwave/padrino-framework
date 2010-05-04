require File.expand_path(File.dirname(__FILE__) + '/helper')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/sinatra_app/app')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/padrino_app/app')

class TestPadrinoMailer < Test::Unit::TestCase

  context 'for mail delivery in sample sinatra application' do
    setup do
      @app = SinatraApp
      Padrino::Mailer::Base::views_path   = SinatraApp.views
      Padrino::Mailer::Base.smtp_settings = SinatraApp.smtp_settings
    end

    should "be able to deliver inline emails using the email helper" do
      post '/deliver/inline'
      assert_equal 'mail delivered', body
      assert_email_sent(:to => 'john@apple.com', :from => 'joe@smith.com', :via => :smtp,
                        :subject => 'Test Email', :body => 'Test Body', :smtp => @app.smtp_settings)
    end

    should 'be able to deliver plain text emails' do
      post '/deliver/plain'
      assert_equal 'mail delivered', body
      assert_email_sent(:to => 'john@fake.com', :from => 'noreply@birthday.com', :via => :smtp, :smtp => @app.smtp_settings,
                        :subject => "Happy Birthday!", :body => "Happy Birthday Joey!\nYou are turning 21")
    end

    should 'be able to deliver emails with custom view' do
      post '/deliver/custom'
      assert_equal 'mail delivered', body
      assert_email_sent(:template => 'mailers/sample/foo_message', :to => 'john@fake.com',
                        :from => 'noreply@custom.com', :via => :smtp, :smtp => @app.smtp_settings,
                        :subject => "Welcome Message!", :body => "Hello to Bobby")
    end

    should 'be able to deliver html emails' do
      post '/deliver/html'
      assert_equal 'mail delivered', body
      assert_email_sent(:to => 'julie@fake.com', :from => 'noreply@anniversary.com',
                        :content_type => 'text/html', :via => :smtp, :smtp => @app.smtp_settings,
                        :subject => "Happy anniversary!", :body => "<p>Yay Joey & Charlotte!</p>\n<p>You have been married 16 years</p>")

    end
  end

  context 'for mail delivery in sample padrino application' do
    setup do
      @app = PadrinoApp
      Padrino::Mailer::Base.smtp_settings = PadrinoApp.smtp_settings
    end

    should "be able to deliver inline emails using the email helper" do
      post '/deliver/inline'
      assert_equal 'mail delivered', body
      assert_email_sent(:to => 'john@apple.com', :from => 'joe@smith.com', :via => :smtp, :smtp => @app.smtp_settings,
                        :subject => 'Test Email', :body => 'Test Body')
    end

    should 'be able to deliver plain text emails' do
      post '/deliver/plain'
      assert_equal 'mail delivered', body
      assert_email_sent(:to => 'john@fake.com', :from => 'noreply@birthday.com', :via => :smtp, :smtp => @app.smtp_settings,
                        :subject => "Happy Birthday!", :body => "Happy Birthday Joey!\nYou are turning 21")
    end

    should 'be able to deliver emails with custom view' do
      post '/deliver/custom'
      assert_equal 'mail delivered', body
      assert_email_sent(:template => 'mailers/sample/foo_message', :to => 'john@fake.com',
                        :from => 'noreply@custom.com', :via => :smtp, :smtp => @app.smtp_settings,
                        :subject => "Welcome Message!", :body => "Hello to Bobby")
    end

    should 'be able to deliver html emails' do
      post '/deliver/html'
      assert_equal 'mail delivered', body
      assert_email_sent(:to => 'julie@fake.com', :from => 'noreply@anniversary.com',
                        :content_type => 'text/html', :via => :smtp, :smtp => @app.smtp_settings,
                        :subject => "Happy anniversary!", :body => "<p>Yay Joey & Charlotte!</p>\n<p>You have been married 16 years</p>")

    end
  end
end

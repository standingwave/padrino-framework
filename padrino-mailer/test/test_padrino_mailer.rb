require File.expand_path(File.dirname(__FILE__) + '/helper')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/mailer_app/app')

class TestPadrinoMailer < Test::Unit::TestCase
  def app
    MailerDemo.tap { |app| app.set :environment, :test }
  end

  context 'for mail delivery in sample application' do
    setup {
      Padrino::Mailer::Base::views_path = MailerDemo.views
      Padrino::Mailer::Base.smtp_settings = MailerDemo.smtp_settings
    }
    
    should "be able to deliver inline emails using the email helper" do
      assert_email_sent(:to => 'john@apple.com', :from => 'joe@smith.com', :via => :smtp, 
                        :subject => 'Test Email', :body => 'Test Body')
      visit '/deliver/inline', :post
      assert_equal 'mail delivered', last_response.body
    end

    should 'be able to deliver plain text emails' do
      assert_email_sent(:to => 'john@fake.com', :from => 'noreply@birthday.com', :via => :smtp,
                        :subject => "Happy Birthday!", :body => "Happy Birthday Joey!\nYou are turning 21")
      visit '/deliver/plain', :post
      assert_equal 'mail delivered', last_response.body
    end

    should 'be able to deliver emails with custom view' do
      assert_email_sent(:template => 'mailers/sample/foo_message', :to => 'john@fake.com',
                        :from => 'noreply@custom.com', :via => :smtp,
                        :subject => "Welcome Message!", :body => "Hello to Bobby")
      visit '/deliver/custom', :post
      assert_equal 'mail delivered', last_response.body
    end

    should 'be able to deliver html emails' do
      assert_email_sent(:to => 'julie@fake.com', :from => 'noreply@anniversary.com',
                        :content_type => 'text/html', :via => :smtp,
                        :subject => "Happy anniversary!", :body => "<p>Yay Joey & Charlotte!</p>\n<p>You have been married 16 years</p>")
      visit '/deliver/html', :post
      assert_equal 'mail delivered', last_response.body
    end
  end
end
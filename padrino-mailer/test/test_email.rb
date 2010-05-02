require File.expand_path(File.dirname(__FILE__) + '/helper')

class TestEmail < Test::Unit::TestCase
  include Padrino::Mailer

  context 'for #deliver method' do
    should "send mail with attributes default to sendmail no smtp" do
      email = Padrino::Mailer::Email.new(:to => "test@john.com", :from => "sender@sent.com", :body => "Hello")
      Delivery.expects(:mail).with(:to => "test@john.com", :from => "sender@sent.com", :body => "Hello", :via => :sendmail)
      email.deliver
    end

    should "send mail with attributes default to smtp if set" do
      email = Padrino::Mailer::Email.new({:to => "test@john.com", :body => "Hello"}, { :host => 'smtp.gmail.com' })
      Delivery.expects(:mail).with(:to => "test@john.com", :body => "Hello", :via => :smtp, :smtp => { :host => 'smtp.gmail.com' })
      email.deliver
    end

    should "send mail with attributes use sendmail if explicit" do
      email = Padrino::Mailer::Email.new({:to => "test@john.com", :via => :sendmail }, { :host => 'smtp.gmail.com' })
      Delivery.expects(:mail).with(:to => "test@john.com", :via => :sendmail)
      email.deliver
    end
  end
end
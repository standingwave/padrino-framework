require 'sinatra/base'
require 'haml'

class MailerDemo < Sinatra::Base
  configure do
    set :root, File.dirname(__FILE__)
    set :smtp_settings, {
      :host   => 'smtp.gmail.com',
      :port   => '587',
      :tls    => true,
      :user   => 'user',
      :pass   => 'pass',
      :auth   => :plain
    }
  end

  register Padrino::Mailer

  mailer :sample do
    message :birthday do |name, age|
      subject "Happy Birthday!"
      to   'john@fake.com'
      from 'noreply@birthday.com'
      body 'name' => name, 'age' => age
      via  :smtp
    end

    message :anniversary do |names, years_married|
      subject "Happy anniversary!"
      to   'julie@fake.com'
      from 'noreply@anniversary.com'
      body 'names' => names, 'years_married' => years_married
      content_type 'text/html'
    end

    message :welcome do |name|
      template 'mailers/sample/foo_message'
      subject "Welcome Message!"
      to   'john@fake.com'
      from 'noreply@custom.com'
      body 'name' => name
      via  :smtp
    end
  end
  
  post "/deliver/inline" do
    result = email(:to => "john@apple.com", :from => "joe@smith.com", :subject => "Test Email", :body => "Test Body", :via => :smtp)
    result ? "mail delivered" : 'mail not delivered'
  end

  post "/deliver/plain" do
    result = deliver(:sample, :birthday, "Joey", 21)
    result ? "mail delivered" : 'mail not delivered'
  end

  post "/deliver/html" do
    result = deliver(:sample, :anniversary, "Joey & Charlotte", 16)
    result ? "mail delivered" : 'mail not delivered'
  end

  post "/deliver/custom" do
    result = deliver(:sample, :welcome, "Bobby")
    result ? "mail delivered" : 'mail not delivered'
  end
end
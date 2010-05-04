require 'sinatra/base'
require 'haml'

class SinatraApp < Sinatra::Base
  register Padrino::Mailer

  set :root, File.dirname(__FILE__)
  set :delivery_method, :smtp => {
    :host   => 'smtp.gmail.com',
    :port   => '587',
    :tls    => true,
    :user   => 'user',
    :pass   => 'pass',
    :auth   => :plain
  }

  mailer :sample do
    email :birthday do |name, age|
      subject "Happy Birthday!"
      to   'john@fake.com'
      from 'noreply@birthday.com'
      body render('sample/birthday', :locals => { :name => name, :age => age })
      via  :test
    end

    email :anniversary do |names, years_married|
      subject "Happy anniversary!"
      to   'julie@fake.com'
      from 'noreply@anniversary.com'
      body render('sample/anniversary', :locals => { :names => names, :years_married => years_married })
      content_type 'text/html'
      via  :test
    end

    message :welcome do |name|
      subject "Welcome Message!"
      to   'john@fake.com'
      from 'noreply@custom.com'
      body render('sample/foo_message', :locals => {  :name => name })
      via  :test
    end
  end

  post "/deliver/inline" do
    result = email(:to => "john@apple.com", :from => "joe@smith.com", :subject => "Test Email", :body => "Test Body", :via => :test)
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
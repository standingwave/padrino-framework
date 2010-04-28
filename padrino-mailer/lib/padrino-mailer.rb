# require tilt if available; fall back on bundled version.
begin
  require 'tilt'
rescue LoadError
  require 'sinatra/tilt'
end
require 'padrino-core/support_lite'

Dir[File.dirname(__FILE__) + '/padrino-mailer/**/*.rb'].each { |file| require file }

module Padrino
  ##
  # This component uses an enhanced version of the excellent pony library (vendored) for a powerful but simple mailer
  # system within Padrino (and Sinatra).
  # There is full support for using an html content type as well as for file attachments.
  # The MailerPlugin has many similarities to ActionMailer but is much lighterweight and (arguably) easier to use.
  #
  module Mailer
    ##
    # Used Padrino::Application for register Padrino::Mailer::Base::views_path
    #
    def self.registered(app)
      Padrino::Mailer::Base::views_path << app.views
      app.helpers Padrino::Mailer::Helpers
    end

    module Helpers
      ##
      # Delivers an email with the given mail attributes (to, from, subject, cc, bcc, body, et.al)
      #
      # ==== Examples
      #
      #   email :to => @user.email, :from => "awesomeness@example.com",
      #         :subject => "Welcome to Awesomeness!", :body => haml(:some_template)
      #
      def email(mail_attributes)
        smtp_settings = Padrino::Mailer::Base.smtp_settings
        Padrino::Mailer::MailObject.new(mail_attributes, smtp_settings).deliver
      end

      ##
      # Delivers a mailer message email with the given attributes
      #
      # ==== Examples
      #
      #   deliver(:sample, :birthday, "Joey", 21)
      #   deliver(:example, :message, "John")
      #
      def deliver(mailer_name, message_name, *attributes)
        "#{self.class}::#{mailer_name.to_s.camelize}Mailer".constantize.send(:deliver, message_name, *attributes)
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        ##
        # Defines a mailer object allowing the definition of various email messages that can be delivered
        #
        # ==== Examples
        #
        #   mailer :sample do
        #     message :birthday do |name, age|
        #       subject "Happy Birthday!"
        #       to   'john@fake.com'
        #       from 'noreply@birthday.com'
        #       body 'name' => name, 'age' => age
        #     end
        #   end
        #
        def mailer(name, &block)
          mailer_klazz = class_eval("#{name.to_s.camelize}Mailer = Class.new(Padrino::Mailer::Base)")
          mailer_klazz.instance_eval(&block)
        end
      end
    end
  end # Mailer
end # Padrino
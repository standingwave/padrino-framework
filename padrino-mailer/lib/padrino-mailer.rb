# require tilt if available; fall back on bundled version.
begin
  require 'tilt'
rescue LoadError
  require 'sinatra/tilt'
end
require 'padrino-core/support_lite'

require 'net/smtp'
begin
  require 'smtp_tls'
rescue LoadError
end
require 'base64'
require 'mail'

Dir[File.dirname(__FILE__) + '/padrino-mailer/**/*.rb'].each { |file| require file }

module Padrino
  ##
  # This component uses the 'mail' library to create a powerful but simple mailer system within Padrino (and Sinatra).
  # There is full support for using plain or html content types as well as for attaching files.
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
        Padrino::Mailer::Message.new(mail_attributes, smtp_settings).deliver!
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
         self.class.deliver(mailer_name, message_name, *attributes)
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def inherited(subclass) #:nodoc:
          @_mailers ||= {}
          super(subclass)
        end

        ##
        # Returns all registered mailers
        #
        def registered_mailers
          @_mailers ||= {}
        end

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
          registered_mailers[name] = Padrino::Mailer::Base.new(name, &block)
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
          registered_mailers[mailer_name].messages[message_name].call(*attributes).deliver!
        end
      end
    end
  end # Mailer
end # Padrino

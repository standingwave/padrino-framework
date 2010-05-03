# require tilt if available; fall back on bundled version.
begin
  require 'tilt'
rescue LoadError
  require 'sinatra/tilt'
end
require 'padrino-core/support_lite'
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
      app.helpers Padrino::Mailer::Helpers
    end

    module Helpers
      ##
      # Delivers an email with the given mail attributes (to, from, subject, cc, bcc, body, et.al)
      #
      # ==== Examples
      #
      #   message do
      #          to @user.email
      #        from "awesomeness@example.com",
      #     subject "Welcome to Awesomeness!"
      #        body 'path/to/my/template', :locals => { :a => a, :b => b }
      #   end
      def message(*args, &block)
        Padrino::Mailer.deliver(args, &block)
      end
      alias :email :message

      ##
      # Delivers a mailer message email with the given attributes
      #
      # ==== Examples
      #
      #   deliver(:sample, :birthday, "Joey", 21)
      #   deliver(:example, :message, "John")
      #
      def deliver(mailer, email, *attributes)
        self.class.deliver(mailer, email, *attributes)
      end
    end

    module ClassMethods
      def inherited(subclass) #:nodoc:
        @_mailers ||= {}
        super(subclass)
      end

      ##
      # Returns all registered mailers
      #
      def mailers
        @_mailers ||= {}
      end

      ##
      # Defines a mailer object allowing the definition of various email messages that can be delivered
      #
      # ==== Examples
      #
      #   mailer :sample do
      #     email :birthday do |name, age|
      #       subject "Happy Birthday!"
      #       to   'john@fake.com'
      #       from 'noreply@birthday.com'
      #       body 'name' => name, 'age' => age
      #     end
      #   end
      #
      def mailer(name, &block)
        @_mailer = name
        instance_eval(&block)
        @_mailer = nil
      end

      ##
      # Defines a mailer object allowing the definition of various email messages that can be delivered
      #
      # ==== Examples
      #
      #   message :birthday do |name, age|
      #     subject "Happy Birthday!"
      #     to   'john@fake.com'
      #     from 'noreply@birthday.com'
      #     body 'name' => name, 'age' => age
      #   end
      #
      def message(name, &block)
        raise "You must define a mailer first!" unless @_mailer
        raise "The mail '#{name}' is already defined" if mailers[@_mailer] && mailers[@_mailer][name]
        mailers[@_mailer] = { name => block }
      end
      alias :email :message

      ##
      # Delivers a mailer message email with the given attributes
      #
      # ==== Examples
      #
      #   deliver(:sample, :birthday, "Joey", 21)
      #   deliver(:example, :message, "John")
      #
      def deliver(mailer_name, message_name, *attributes)
        raise "No Mailer '#{mailer}' or Email '#{email}' defined!" unless mailers[mailer_name][message_name]
        block = mailers[mailer_name][message_name]
        message = Padrino::Mailer::Message.new
        message.views  = views
        message.mailer = mailer_name
        message.instance_eval(&block)
        message.deliver
      end
    end
  end # Mailer
end # Padrino

##
# Extend Sinatra
#
Sinatra::Base.extend(Padrino::Mailer::ClassMethods) if defined?(Sinatra)
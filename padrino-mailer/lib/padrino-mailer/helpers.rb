module Padrino
  module Mailer
    module Helpers
      ##
      # Delivers an email with the given mail attributes (to, from, subject, cc, bcc, body, et.al)
      #
      # ==== Examples
      #
      #   email :to => @user.email, :from => "awesomeness@example.com",
      #         :subject => "Welcome to Awesomeness!", :body => haml(:some_template)
      #
      def email(mail_attributes={}, &block)
        message = Padrino::Mailer::Message.new
        message.instance_eval(&block) if block_given?
        mail_attributes.each_pair { |k, v| message.method(k).call(v) }
        message.views_path    = Padrino::Mailer::Base::views_path
        message.smtp_settings = Padrino::Mailer::Base.smtp_settings
        message.deliver
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
        # Returns all registered mailers for this application
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
          registered_mailers[mailer_name].messages[message_name].call(*attributes).deliver
        end
      end
    end
  end
end
module Padrino
  module Mailer
    ##
    # This is the abstract class that other mailers will inherit from in order to send mail
    #
    # You can set the default delivery settings through:
    #
    #   Padrino::Mailer::Base.smtp_settings = {
    #     :address         => 'smtp.yourserver.com',
    #     :port            => '25',
    #     :user_name       => 'user',
    #     :password        => 'pass',
    #     :authentication  => :plain # :plain, :login, :cram_md5, no auth by default
    #     :domain          => "localhost.localdomain" # the HELO domain provided by the client to the server
    #   }
    #
    # and then all delivered mail will use these settings unless otherwise specified.
    #
    class Base
      @@views_path = []
      cattr_accessor :smtp_settings
      cattr_accessor :views_path
      
      attr_accessor :mailer_name
      attr_accessor :messages

      def initialize(name, &block) #:nodoc:
        self.mailer_name = name
        self.messages ||= {}
        instance_eval(&block)
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
        raise "The message '#{name}' is already defined" if self.messages[name].present?
        self.messages[name] = Proc.new { |*attrs|
          m = Padrino::Mailer::Message.new
          m.views_path = self.class.views_path
          m.mailer_name = self.mailer_name
          m.smtp_settings = self.class.smtp_settings
          m.instance_exec(*attrs, &block)
          m
        }
      end
    end # Base
  end # Mailer
end # Padrino
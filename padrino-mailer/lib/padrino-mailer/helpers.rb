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
      def email(mail_attributes)
        Padrino::Mailer::MailObject.new(mail_attributes).deliver
      end
    end
  end
end
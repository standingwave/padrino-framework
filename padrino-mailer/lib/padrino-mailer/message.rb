module Padrino
  module Mailer
    ##
    # This represents a particular mail object which will need to be sent
    # An email requires the mail attributes and the delivery_settings
    #
    ##
    # Initialize a new Email
    #
    # ==== Examples
    #
    #   Padrino::Mailer::Message.new(
    #     :subject => "Hey this is my subject",
    #     :to => "info@padrinorb.org",
    #     :from => "foo@bar.com",
    #     :body => "This is my body"
    #   ).deliver
    #
    #   Padrino::Mailer::Message.new {
    #     subject "Hey this is my subject",
    #     to      "info@padrinorb.org",
    #     from    "foo@bar.com",
    #     body    render('sample/birthday', :locals => { :name => name })
    #   }.deliver
    #
    class Message < ::Mail::Message
      include Padrino::Mailer::Template

      alias :via  :delivery_method
      attr_accessor :views_path, :mailer_name

      ##
      # TODO: desc here
      #
      def views(value=nil)
        self.views_path = value if value
        self.views_path.to_s if self.views_path
      end

      ##
      # TODO: desc here
      #
      def mailer(value=nil)
        self.mailer_name = value if value
        self.mailer_name.to_s if self.mailer_name
      end

      ##
      # Accessor for html_part
      #
      def html_part(msg=nil, &block)
        if msg || block_given?
          @html_part = Padrino::Mailer::Part.new('Content-Type: text/html;')
          @html_part.views_path  = views
          @html_part.mailer_name = mailer
          @html_part.body = msg if msg.is_a?(String)
          @html_part.instance_eval(&block) if block_given?
          add_multipart_alternate_header unless html_part.blank?
          add_part(@html_part)
        else
          @html_part || find_first_mime_type('text/html')
        end
      end

      ##
      # Accessor for text_part
      #
      def text_part(msg=nil, &block)
        if msg || block_given?
          @text_part = Padrino::Mailer::Part.new('Content-Type: text/plain;')
          @text_part.views_path  = views
          @text_part.mailer_name = mailer
          @text_part.body = msg if msg.is_a?(String)
          @text_part.instance_eval(&block) if block_given?
          add_multipart_alternate_header unless html_part.blank?
          add_part(@text_part)
        else
          @text_part || find_first_mime_type('text/plain')
        end
      end

      ##
      # Helper to add a html part to a multipart/alternative email.  If this and
      # text_part are both defined in a message, then it will be a multipart/alternative
      # message and set itself that way.
      #
      def html_part=(msg=nil)
        if msg
          @html_part = msg
        else
          @html_part = Padrino::Mailer::Part.new('Content-Type: text/html;')
          @html_part.views_path  = views
          @html_part.mailer_name = mailer
        end
        add_multipart_alternate_header unless text_part.blank?
        add_part(@html_part)
      end

      ##
      # Helper to add a text part to a multipart/alternative email.  If this and
      # html_part are both defined in a message, then it will be a multipart/alternative
      # message and set itself that way.
      #
      def text_part=(msg=nil)
        if msg
          @text_part = msg
        else
          @text_part = Padrino::Mailer::Part.new('Content-Type: text/plain;')
          @text_part.views_path  = views_path
          @text_part.mailer_name = mailer_name
        end
        add_multipart_alternate_header unless html_part.blank?
        add_part(@text_part)
      end

      ##
      # Adds a part to the parts list or creates the part list
      #
      def add_part(part)
        if !body.multipart? && !self.body.decoded.blank?
           @text_part = Padrino::Mailer::Part.new('Content-Type: text/plain;')
           @text_part.body = body.decoded
           @text_part.views_path  = views
           @text_part.mailer_name = mailer
           self.body << @text_part
           add_multipart_alternate_header
        end
        add_boundary
        self.body << part
      end

      ##
      # TODO: desc here
      #
      def attributes
        {
          :from => self.from,
          :to => self.to,
          :delivery_method => self.delivery_method,
          :subject => self.subject,
          :content_type => self.content_type
        }
      end
    end # Message
  end # Mailer
end # Padrino
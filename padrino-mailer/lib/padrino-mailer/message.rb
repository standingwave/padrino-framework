module Padrino
  module Mailer
    ##
    # This represents a particular mail object which will need to be sent
    # A email requires the mail attributes and the delivery_settings
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
    #   ).deliver!
    #
    #   Padrino::Mailer::Message.new {
    #     subject "Hey this is my subject",
    #     to      "info@padrinorb.org",
    #     from    "foo@bar.com",
    #     body   "This is my body"
    #   }.deliver!
    #
    class Message < ::Mail::Message
      alias :via  :delivery_method
      attr_accessor :mailer_name
      attr_accessor :views_path

      def render(template, options={}, locals={}, &block)
        # be sure that is it a string
        template = template.to_s

        # retrive correct template path
        if File.exist?(template)
          path = template
        else
          path  = template_paths.map { |p| Dir[File.join(p, template) + ".*"][0] }.compact[0]
          raise Errno::ENOENT, "Template for '#{template}' could not be located in: #{template_paths.inspect}" unless path && File.exist?(path)
        end

        # extract generic options
        locals = options.delete(:locals) || locals || {}
        layout = options.delete(:layout)
        layout = File.join("layouts", mailer_name.to_s) if mailer_name && (layout.nil? || layout == true)

        # compile and render template
        template = Tilt.new(path)
        output   = template.render(self, locals, &block)

        # render layout
        if layout
          begin
            options = options.merge(:layout => false)
            output  = render(layout, options, locals) { output }
          rescue Errno::ENOENT
          end
        end

        output
      end

      def template_paths
        [
          [views_path.to_s, 'mailers', mailer_name.to_s],
          [views_path.to_s, 'mailers'],
        ].map { |path| File.join(*path.compact) }
      end
      
      def views_path
        @views_path || Padrino::Mailer::Base.views_path
      end
    end # Message
  end # Mailer
end # Padrino
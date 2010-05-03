module Padrino
  module Mailer
    class Message < ::Mail::Message
      attr_writer :views, :mailer
      alias :via  :delivery_method

      def views(value=nil)
        @views = value if value
        @views.to_s    if @views
      end

      def mailer(value=nil)
        @mailer = value if value
        @mailer.to_s    if @mailer
      end

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
        layout = File.join("layouts", mailer) if mailer && (layout.nil? || layout == true)

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
          [views, 'mailers', mailer],
          [views, 'mailers'],
        ].map { |path| File.join(*path.compact) }
      end
    end # Message
  end # Mailer
end # Padrino
module Padrino
  module Mailer
    ##
    # This is a module that add to Padrino::Message and Padrino::Part the ability to works with templates/layouts
    #
    module Template
      ##
      # Template rendering method
      #
      # `template` is either the name or path of the template
      #
      # Possible options are:
      #   :layout       If set to false, no layout is rendered, otherwise
      #                 the specified layout is used (Ignored for `sass` and `less`)
      #   :locals       A hash with local variables that should be available
      #                 in the template
      #
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
    end # Rendering
  end # Mailer
end # Padrino
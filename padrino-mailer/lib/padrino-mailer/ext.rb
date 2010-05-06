module Mail
  class Message
    include Sinatra::Templates
    include Padrino::Rendering if defined?(Padrino::Rendering)

    # Shortcut
    alias :via :delivery_method

    def initialize(*args, &block)
      @template_cache        = Tilt::Cache.new
      @body                  = nil
      @text_part             = nil
      @html_part             = nil
      @errors                = nil
      @header                = nil
      @charset               = 'UTF-8'
      @defaulted_charset     = true
      @perform_deliveries    = true
      @raise_delivery_errors = true
      @delivery_handler      = nil
      @delivery_method       = Mail.delivery_method.dup
      @transport_encoding    = Mail::Encodings.get_encoding('7bit')

      # Set a default view for this class
      settings.views = File.expand_path("./mailers")
      settings.reload_templates = true

      # Check if we have an app
      if args[0].respond_to?(:views) && args[0].respond_to?(:reload_templates?)
        app                       = args.shift
        settings.views            = File.join(app.views, 'mailers')
        settings.reload_templates = app.reload_templates?
      end

      if args.flatten.first.respond_to?(:each_pair)
        init_with_hash(args.flatten.first)
      else
        init_with_string(args.flatten[0].to_s.strip)
      end

      if block_given?
        instance_eval(&block)
      end

      self
    end

    # Sinatra/Padrino compatibility
    def settings
      self.class
    end
    alias :options :settings

    def views(value)
      self.class.views = value
    end

    def self.templates
      @_templates ||= {}
    end

    def self.views=(value)
      @_views = value
    end

    def self.views
      @_views
    end

    def self.reload_templates=(value)
      @_reload_templates = value
    end

    def self.reload_templates?
      @_reload_templates
    end

    private
      def render(engine, data=nil, options={}, locals={}, &block)
        # Reload templates
        @template_cache.clear if settings.reload_templates?
        # Pass arguments to Sinatra/Padrino render method
        super(engine, data, options, locals, &block)
      end
  end
end
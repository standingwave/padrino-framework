module Mail
  class Message
    include Sinatra::Templates
    include Padrino::Rendering if defined?(Padrino::Rendering)

    # Shortcut for delivery_method
    alias :via :delivery_method

    def initialize_with_app(*args, &block)
      @template_cache = Tilt::Cache.new
      # Check if we have an app
      if args[0].respond_to?(:views) && args[0].respond_to?(:reload_templates?)
        app                       = args.shift
        settings.views            = File.join(app.views, 'mailers')
        settings.reload_templates = app.reload_templates?
      else
        # Set a default view for this class
        settings.views = File.expand_path("./mailers")
        settings.reload_templates = true
      end
      
      # Run the original initialize
      initialize_without_app(*args, &block)
    end
    alias_method_chain :initialize, :app

    # Sinatra and Padrino compatibility
    def settings
      self.class
    end
    alias :options :settings

    # Sets the message defined template path to the given view path
    def views(value)
      self.class.views = value
    end

    # Returns the templates for this message
    def self.templates
      @_templates ||= {}
    end

    # Sets the message defined template path to the given view path
    def self.views=(value)
      @_views = value
    end

    # Returns the template view path defined for this message
    def self.views
      @_views
    end

    # Modify whether templates should be reloaded (for development)
    def self.reload_templates=(value)
      @_reload_templates = value
    end

    # Returns true if the templates will be reloaded; false otherwise.
    def self.reload_templates?
      @_reload_templates
    end
    
    # Modify the default attributes for this message (if not explicitly specified)
    def defaults=(attributes)
      @_defaults = attributes
      @_defaults.each_pair { |k, v| default(k.to_sym, v) } if @_defaults.is_a?(Hash)
    end

    private
    
    # Defines the render for the mailer utilizing the padrino 'rendering' module
    def render(engine, data=nil, options={}, locals={}, &block)
      # Reload templates
      @template_cache.clear if settings.reload_templates?
      # Pass arguments to Sinatra/Padrino render method
      super(engine, data, options, locals, &block)
    end
  end
end
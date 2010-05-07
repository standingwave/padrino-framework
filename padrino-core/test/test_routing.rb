require File.expand_path(File.dirname(__FILE__) + '/helper')

class TestRouting < Test::Unit::TestCase
  class RoutingApp < Sinatra::Base
    register ::Padrino::Routing
    set :environment, :test
  end

  def mock_app(base=RoutingApp, &block)
    @app = Sinatra.new(base, &block)
  end

  should 'ignore trailing delimiters for basic route' do
    mock_app do
      get("/foo"){ "okey" }
      get(:test) { "tester" }
    end
    get "/foo"
    assert_equal "okey", body
    get "/foo/"
    assert_equal "okey", body
    get "/test"
    assert_equal "tester", body
    get "/test/"
    assert_equal "tester", body
  end

  should 'fail with unrecognized route exception when not found' do
    unrecognized_app = mock_app do
      get(:index){ "okey" }
    end
    assert_nothing_raised { get unrecognized_app.url_for(:index) }
    assert_equal "okey", body
    assert_raises(Padrino::Routing::UnrecognizedException) {
      get unrecognized_app.url_for(:fake)
    }
  end

  should "parse routes with question marks" do
    mock_app do
      get("/foo/?"){ "okey" }
      post('/unauthenticated/?') { "no access" }
    end
    get "/foo"
    assert_equal "okey", body
    get "/foo/"
    assert_equal "okey", body
    post "/unauthenticated"
    assert_equal "no access", body
    post "/unauthenticated/"
    assert_equal "no access", body
  end

  should 'match correctly similar paths' do
    mock_app do
      get("/my/:foo_id"){ params[:foo_id] }
      get("/my/:bar_id/bar"){ params[:bar_id] }
    end
    get "/my/1"
    assert_equal "1", body
    get "/my/2/bar"
    assert_equal "2", body
  end

  should 'generate basic urls'do
    mock_app do
      get(:foo){ url(:foo) }
      get(:bar, :with => :id){ url(:bar, :id => 1) }
      get("/old-bar/:id"){ params[:id] }
      post(:mix, :map => "/mix-bar/:id"){ params[:id] }
      get(:mix, :map => "/mix-bar/:id"){ params[:id] }
    end
    get "/foo"
    assert_equal "/foo", body
    get "/bar/2"
    assert_equal "/bar/1", body
    get "/old-bar/3"
    assert_equal "3", body
    post "/mix-bar/4"
    assert_equal "4", body
    get "/mix-bar/4"
    assert_equal "4", body
  end

  should 'generate url with format' do
    mock_app do
      get(:a, :provides => :any){ url(:a, :format => :json) }
      get(:b, :provides => :js){ url(:b, :format => :js) }
      get(:c, :provides => [:js, :json]){ url(:c, :format => :json) }
      get(:d, :provides => [:html, :js]){ url(:d, :format => :js, :foo => :bar) }
    end
    get "/a.js"
    assert_equal "/a.json", body
    get "/b.js"
    assert_equal "/b.js", body
    get "/b.ru"
    assert_equal 404, status
    get "/c.js"
    assert_equal "/c.json", body
    get "/c.json"
    assert_equal "/c.json", body
    get "/c.ru"
    assert_equal 404, status
    get "/d.json"
    assert 404, status
    get "/d"
    assert_equal "/d.js?foo=bar", body
    get "/d.js"
    assert_equal "/d.js?foo=bar", body
  end

  should "not allow Accept-Headers it does not provide" do
    mock_app do
      get(:a, :provides => [:html, :js]){ content_type }
    end

    get "/a", {}, {"HTTP_ACCEPT" => "application/yaml"}
    assert_equal 404, status
  end

  should "not default to HTML if HTML is not provided and no type is given" do
    mock_app do
      get(:a, :provides => [:js]){ content_type }
    end

    get "/a", {}, {}
    assert_equal 404, status
  end

  should "generate routes for format simple" do
    mock_app do
      get(:foo, :provides => [:html, :rss]) { render :haml, "Test" }
    end
    get "/foo"
    assert_equal "Test\n", body
    get "/foo.rss"
    assert_equal "Test\n", body
  end

  should "generate routes for format with controller" do
    mock_app do
      controller :posts do
        get(:index, :provides => [:html, :rss, :atom, :js]) { render :haml, "Index.#{content_type}" }
        get(:show,  :with => :id, :provides => [:html, :rss, :atom]) { render :haml, "Show.#{content_type}" }
      end
    end
    get "/posts"
    assert_equal "Index.html\n", body
    get "/posts.rss"
    assert_equal "Index.rss\n", body
    get "/posts.atom"
    assert_equal "Index.atom\n", body
    get "/posts.js"
    assert_equal "Index.js\n", body
    get "/posts/show/5"
    assert_equal "Show.html\n", body
    get "/posts/show/5.rss"
    assert_equal "Show.rss\n", body
    get "/posts/show/10.atom"
    assert_equal "Show.atom\n", body
  end

  should 'map routes' do
    mock_app do
      get(:bar){ "bar" }
    end
    get "/bar"
    assert_equal "bar", body
    assert_equal "/bar", @app.url(:bar)
  end

  should 'remove index from path' do
    mock_app do
      get(:index){ "index" }
      get("/accounts/index"){ "accounts" }
    end
    get "/"
    assert_equal "index", body
    assert_equal "/", @app.url(:index)
    get "/accounts"
    assert_equal "accounts", body
  end

  should 'remove index from path with params' do
    mock_app do
      get(:index, :with => :name){ "index with #{params[:name]}" }
    end
    get "/bobby"
    assert_equal "index with bobby", body
    assert_equal "/john", @app.url(:index, :name => "john")
  end

  should 'parse named params' do
    mock_app do
      get(:print, :with => :id){ "Im #{params[:id]}" }
    end
    get "/print/9"
    assert_equal "Im 9", body
    assert_equal "/print/9", @app.url(:print, :id => 9)
  end

  should 'respond to' do
    mock_app do
      get(:a, :provides => :js){ "js" }
      get(:b, :provides => :any){ "any" }
      get(:c, :provides => [:js, :json]){ "js,json" }
      get(:d, :provides => [:html, :js]){ "html,js"}
    end
    get "/a"
    assert_equal 404, status
    get "/a.js"
    assert_equal "js", body
    get "/b"
    assert_equal "any", body
    assert_raise(RuntimeError) { get "/b.foo" }
    get "/c"
    assert_equal 404, status
    get "/c.js"
    assert_equal "js,json", body
    get "/c.json"
    assert_equal "js,json", body
    get "/d"
    assert_equal "html,js", body
    get "/d.js"
    assert_equal "html,js", body
  end

  should 'respond_to and set content_type' do
    Rack::Mime::MIME_TYPES['.foo'] = 'application/foo'
    mock_app do
      get :a, :provides => :any do
        case content_type
          when :js    then "js"
          when :json  then "json"
          when :foo   then "foo"
          when :html  then "html"
        end
      end
    end
    get "/a.js"
    assert_equal "js", body
    assert_equal 'application/javascript;charset=utf-8', response["Content-Type"]
    get "/a.json"
    assert_equal "json", body
    assert_equal 'application/json;charset=utf-8', response["Content-Type"]
    get "/a.foo"
    assert_equal "foo", body
    assert_equal 'application/foo;charset=utf-8', response["Content-Type"]
    get "/a"
    assert_equal "html", body
    assert_equal 'text/html;charset=utf-8', response["Content-Type"]
  end

  should 'use controllers' do
    mock_app do
      controller "/admin" do
        get("/"){ "index" }
        get("/show/:id"){ "show #{params[:id]}" }
      end
    end
    get "/admin"
    assert_equal "index", body
    get "/admin/show/1"
    assert_equal "show 1", body
  end

  should 'use named controllers' do
    mock_app do
      controller :admin do
        get(:index){ "index" }
        get(:show, :with => :id){ "show #{params[:id]}" }
      end
      controllers :foo, :bar do
        get(:index){ "foo_bar_index" }
      end
    end
    get "/admin"
    assert_equal "index", body
    get "/admin/show/1"
    assert_equal "show 1", body
    assert_equal "/admin", @app.url(:admin_index)
    assert_equal "/admin/show/1", @app.url(:admin_show, :id => 1)
    get "/foo/bar"
    assert_equal "foo_bar_index", body
  end

  should "ignore trailing delimiters within a named controller" do
    mock_app do
      controller :posts do
        get(:index, :provides => [:html, :js]){ "index" }
        get(:new)  { "new" }
        get(:show, :with => :id){ "show #{params[:id]}" }
      end
    end
    get "/posts"
    assert_equal "index", body
    get "/posts/"
    assert_equal "index", body
    get "/posts.js"
    assert_equal "index", body
    get "/posts.js/"
    assert_equal "index", body
    get "/posts/new"
    assert_equal "new", body
    get "/posts/new/"
    assert_equal "new", body
  end

  should "ignore trailing delimiters within a named controller for unnamed actions" do
    mock_app do
      controller :accounts do
        get("/") { "account_index" }
        get("/new") { "new" }
      end
      controller :votes do
        get("(/)") { "vote_index" }
      end
    end
    get "/accounts"
    assert_equal "account_index", body
    get "/accounts/"
    assert_equal "account_index", body
    get "/accounts/new"
    assert_equal "new", body
    get "/accounts/new/"
    assert_equal "new", body
    get "/votes"
    assert_equal "vote_index", body
    get "/votes/"
    assert_equal "vote_index", body
  end

  should 'use named controllers with array routes' do
    mock_app do
      controller :admin do
        get(:index){ "index" }
        get(:show, :with => :id){ "show #{params[:id]}" }
      end
      controllers :foo, :bar do
        get(:index){ "foo_bar_index" }
      end
    end
    get "/admin"
    assert_equal "index", body
    get "/admin/show/1"
    assert_equal "show 1", body
    assert_equal "/admin", @app.url(:admin, :index)
    assert_equal "/admin/show/1", @app.url(:admin, :show, :id => 1)
    get "/foo/bar"
    assert_equal "foo_bar_index", body
  end

  should 'reset routes' do
    mock_app do
      get("/"){ "foo" }
      router.reset!
    end
    get "/"
    assert_equal 404, status
  end

  should 'apply maps' do
    mock_app do
      controllers :admin do
        get(:index, :map => "/"){ "index" }
        get(:show, :with => :id, :map => "/show"){ "show #{params[:id]}" }
        get(:edit, :map => "/edit/:id/product"){ "edit #{params[:id]}" }
      end
    end
    get "/"
    assert_equal "index", body
    get "/show/1"
    assert_equal "show 1", body
    get "/edit/1/product"
    assert_equal "edit 1", body
  end

  should "apply parent to route" do
    mock_app do
      controllers :project do
        get(:index, :parent => :user) { "index #{params[:user_id]}" }
        get(:edit, :with => :id, :parent => :user) { "edit #{params[:id]} #{params[:user_id]}"}
        get(:show, :with => :id, :parent => [:user, :product]) { "show #{params[:id]} #{params[:user_id]} #{params[:product_id]}"}
      end
    end
    get "/user/1/project"
    assert_equal "index 1", body
    get "/user/1/project/edit/2"
    assert_equal "edit 2 1", body
    get "/user/1/product/2/project/show/3"
    assert_equal "show 3 1 2", body

  end

  should "apply parent to controller" do
    mock_app do
      controller :project, :parent => :user do
        get(:index) { "index #{params[:user_id]}"}
        get(:edit, :with => :id, :parent => :user) { "edit #{params[:id]} #{params[:user_id]}"}
        get(:show, :with => :id, :parent => :product) { "show #{params[:id]} #{params[:user_id]} #{params[:product_id]}"}
      end
    end
    get "/user/1/project"
    assert_equal "index 1", body
    get "/user/1/project/edit/2"
    assert_equal "edit 2 1", body
    get "/user/1/product/2/project/show/3"
    assert_equal "show 3 1 2", body
  end

  should "use default values" do
    mock_app do
      controller :lang => :it do
        get(:index, :map => "/:lang") { "lang is #{params[:lang]}" }
      end
      assert_equal "/it", url(:index)
      # This is only for be sure that default values
      # work only for the given controller
      get(:foo, :map => "/foo") {}
      assert_equal "/foo", url(:foo)
    end
    get "/en"
    assert_equal "lang is en", body
  end

  should "transitions to the next matching route on pass" do
    mock_app do
      get '/:foo' do
        pass
        'Hello Foo'
      end
      get '/:bar' do
        'Hello World'
      end
    end

    get '/za'
    assert_equal 'Hello World', body
  end

  should "filters by accept header" do
    mock_app do
      get '/foo', :provides => [:xml, :js] do
        request.env['HTTP_ACCEPT']
      end
    end

    get '/foo', {}, { 'HTTP_ACCEPT' => 'application/xml' }
    assert ok?
    assert_equal 'application/xml', body
    assert_equal 'application/xml;charset=utf-8', response.headers['Content-Type']

    get '/foo.xml'
    assert ok?
    assert_equal 'application/xml;charset=utf-8', response.headers['Content-Type']

    get '/foo', {}, { 'HTTP_ACCEPT' => 'application/javascript' }
    assert ok?
    assert_equal 'application/javascript', body
    assert_equal 'application/javascript;charset=utf-8', response.headers['Content-Type']

    get '/foo.js'
    assert ok?
    assert_equal 'application/javascript;charset=utf-8', response.headers['Content-Type']

    get '/foo', {}, { :accept => 'text/html' }
    assert not_found?
  end

  should "works allow global provides" do
    mock_app do
      provides :xml

      get("/foo"){ "Foo in #{content_type}" }
      get("/bar"){ raise if content_type != nil }
    end

    get '/foo', {}, { 'HTTP_ACCEPT' => 'application/xml' }
    assert_equal 'Foo in xml', body
    get '/foo'
    assert not_found?

    get '/bar', {}, { 'HTTP_ACCEPT' => 'application/xml' }
    assert 200, status
  end

  should "set content_type to :html for both empty Accept as well as Accept text/html" do
    mock_app do
      provides :html

      get("/foo"){ content_type.to_s }
    end

    get '/foo', {}, {}
    assert_equal 'html', body

    get '/foo', {}, { 'HTTP_ACCEPT' => 'text/html' }
    assert_equal 'html', body
  end

  should 'allows custom route-conditions to be set via route options' do
    protector = Module.new {
      def protect(*args)
        condition {
          unless authorize(params["user"], params["password"])
            halt 403, "go away"
          end
        }
      end
    }

    mock_app do
      register protector

      helpers do
        def authorize(username, password)
          username == "foo" && password == "bar"
        end
      end

      get "/", :protect => true do
        "hey"
      end
    end

    get "/"
    assert forbidden?
    assert_equal "go away", body

    get "/", :user => "foo", :password => "bar"
    assert ok?
    assert_equal "hey", body
  end

  should 'scope filters in the given controller' do
    mock_app do
      before { @global = 'global' }
      after { @global = nil }

      controller :foo do
        before { @foo = :foo }
        after { @foo = nil }
        get("/") { [@foo, @bar, @global].compact.join(" ") }
      end

      get("/") { [@foo, @bar, @global].compact.join(" ") }

      controller :bar do
        before { @bar = :bar }
        after { @bar = nil }
        get("/") { [@foo, @bar, @global].compact.join(" ") }
      end
    end

    get "/bar"
    assert_equal "bar global", body

    get "/foo"
    assert_equal "foo global", body

    get "/"
    assert_equal "global", body
  end

  should 'works with optionals params' do
    mock_app do
      get("/foo(/:bar)") { params[:bar] }
    end

    get "/foo/bar"
    assert_equal "bar", body

    get "/foo"
    assert_equal "", body
  end
end

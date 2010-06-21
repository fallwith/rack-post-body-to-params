require 'helper'
# ActiveSupport::JSON.backend = 'JSONGem'
ActiveSupport::JSON.backend = 'Yajl'
ActiveSupport::XmlMini.backend = 'Nokogiri'

class TestApp
  def call(env)
    return env
  end
end

module FromXml
  def from_xml(data)
    "parsed #{data}"
  end
end

class Logger
  def warn(string)
    "warning: #{string}"
  end
end

class TestPostBodyToParams < Test::Unit::TestCase
  
  context "A new app" do
    context "without further configuration" do
      setup do
        @test_app = TestApp.new
        @app = Rack::PostBodyToParams.new @test_app
      end
      should "have the default content_types" do
        assert_equal ['application/json','application/xml'], @app.instance_variable_get('@content_types').sort
      end
      should "have the default parsers" do
        assert @app.parsers.keys.include? 'application/json'
        assert @app.parsers.keys.include? 'application/xml'
        assert @app.parsers['application/json'].is_a? Proc
        assert @app.parsers['application/xml'].is_a? Proc
      end
      should "have the default error responses" do
        assert @app.error_responses.keys.include? 'application/json'
        assert @app.error_responses.keys.include? 'application/xml'
        assert @app.error_responses['application/json'].is_a? Proc
        assert @app.error_responses['application/xml'].is_a? Proc
      end
    end

    context "with further configuration" do
      should "have different content_types" do
        app = Rack::PostBodyToParams.new @test_app, :content_types => [:fu]
        assert_equal [:fu], app.instance_variable_get('@content_types')
      end
      should "have different parsers" do
        app = Rack::PostBodyToParams.new @test_app, :parsers => {'application/json' => :bar}
        assert_equal :bar, app.parsers['application/json']
      end
      should "have different error responses" do
        app = Rack::PostBodyToParams.new @test_app, :error_responses => {'application/json' => :baz}
        assert_equal :baz, app.error_responses['application/json']
      end
    end
  end
  
  context "the parsers" do
    setup do
      @test_app = TestApp.new
      @app = Rack::PostBodyToParams.new @test_app
    end
    should "return the error as xml" do
      error = 'some error occured'
      response = [400, {"Content-Type"=>"application/xml"}, ["<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>\n  <xml-syntax-error>some error occured</xml-syntax-error>\n</errors>\n"]]
      assert_equal response, @app.xml_error_response(error)
    end
    should "return the error as json" do
      error = 'some error occured'
      response = [400, {"Content-Type"=>"application/json"}, ["{\"json-syntax-error\":\"some error occured\"}"]]
      assert_equal response, @app.json_error_response(error)
    end
  end
  
  context "the error responses" do
    setup do
    end
  end
  
end

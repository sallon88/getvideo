#coding:utf-8
begin
  require 'faraday'
rescue LoadError
  raise "You don't have the 'faraday' gem installed"
end

module Getvideo
  class Video
    attr_reader :url

    def initialize(url)
      @url = url
    end

    def response
      @response ||= connection
    end

    def connection
      api_url = self.class.get_api_uri(self)
      Response.new(Faraday.get(api_url)).parsed
    end

    def id; end
    def html_url; end
    def cover; end
    def title; end
    def flash; end
    def m3u8; end
    def media; end
    def mobile;end

    def play_media
      media["mp4"][0] if media["mp4"]
    end

    def json
      {
        id: id,
        url: html_url,
        cover: cover,
        title: title,
        flash: flash,
        mobile: mobile
      }.to_json
    end

    class << self
      def set_api_uri(&block)
        return @api_uri unless block_given?
        @api_uri = block
      end

      def get_api_uri(klass)
        klass.instance_eval(&set_api_uri)
      end
    end
  end

  class Response
    attr_reader :response

    def initialize(response)
      @response = response
    end

    CONTENT_TYPE = {
      'application/json' => :json,
      'application/x-www-form-urlencoded' => :html,
      'text/html' => :html,
      'text/javascript' => :json,
      'text/xml' => :xml,
      "text/plain" => :json
    }

    PARSERS = {
      :json => lambda{ |body| MultiJson.respond_to?(:adapter) ? MultiJson.load(body) : MultiJson.decode(body) rescue body },
      :html => lambda{ |body| Nokogiri::HTML(body) },
      :xml => lambda{ |body| MultiXml.parse(body) }
    }

    def headers
      response.headers
    end

    def body
      decode(response.body)
    end

    def decode(body)
      return '' if !body
      return body if json?
      charset = body.match(/charset\s*=[\s|\W]*([\w-]+)/)
      if charset[1].downcase != "utf-8"
        begin
          body.encode! "utf-8", charset[1], {:invalid => :replace}
        rescue
          body
        end
      else
        body
      end
    end

    def status
      response.status
    end

    def content_type
      ((response.headers.values_at('content-type', 'Content-Type').compact.first || '').split(';').first || '').strip
    end

    def json?
      CONTENT_TYPE[content_type] == :json || !response.body.match(/\<html/)
    end

    def parser
      type = CONTENT_TYPE[content_type]
      type = :json if type == :html && !response.body.match(/\<html/)
      return type
    end

    def parsed
      return nil unless CONTENT_TYPE.key?(content_type)
      return nil unless PARSERS.key?(parser)
      @parsed ||= PARSERS[parser].call(body)
    end
  end
end

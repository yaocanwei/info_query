require 'net/https'
require 'rest-client'
require 'pry-rails'
require 'pry-nav'
require 'nokogiri'
require 'open-uri'
require 'json'

module Spider
  class Base
    def initialize(opts = {})
      @connection = {}
      @opts = opts
    end

    # private
    #代理hosts 
    def proxy_host
      @opts[:proxy_host]
    end

    #
    # 代理端口
    #
    def proxy_port
      @opts[:proxy_port]
    end

    def read_timeout
      @opts[:read_timeout]
    end

    def to_query(options)
      str = []
      options.each do |key, value|
        if value.is_a?(Array)
          str << value.map{ |v|
            "#{key}[]=#{v}"
          }.join('&')
        else
          str << "#{key}=#{value}"
        end
      end
      str.join("&")
    end

    def post_response(url, options={}, referer = nil)
      full_path = url.query.nil? ? url.path : "#{url.path}?#{url.query}"
      # full_path += to_query(options) unless options.blank?
      retries = 0
      opts={}
      # opts['Cookie'] = @cookie_store.to_s if @cookie_store.present? && accept_cookie?
      begin
        start = Time.now()
        response = connection(url).post(full_path, to_query(options), opts )
        finish = Time.now()
        response_time = ((finish - start) * 1000).round
        # @cookie_store.merge!(response['Set-Cookie'])
        return response, response_time
      rescue Timeout::Error, Net::HTTPBadResponse, EOFError => e
        puts e.inspect
        refresh_connection(url)
        retries += 1
        retry unless retries > 3
      end
    end

    def get_response(url, options = {})
      begin
        start = Time.now()
        url += to_query(options) unless options.empty?
        response = RestClient::Request.execute(:url => url, :method => :get, :verify_ssl => false)
        finish = Time.now()
        response_time = ((finish - start) * 1000).round
        return response, response_time
      rescue Timeout::Error, Net::HTTPBadResponse, EOFError => e
        puts e.inspect if defined?(verbose?) && verbose?
        # Rails.logger.error "#{e.message};"
      end
    end

    def connection(url)
      @connections[url.host] ||= {}
      if conn = @connections[url.host][url.port]
        return conn
      end

      refresh_connection url
    end

    def refresh_connection(url)
      http = Net::HTTP.new(url.host, url.port, proxy_host, proxy_port)

      http.read_timeout = read_timeout if !!read_timeout

      if url.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      @connections[url.host][url.port] = http.start
    end

    def domain_name
      "https://kyfw.12306.cn/"      
    end

    def abs_url(url)
      return url if url =~ /^http/
      URI::join(domain_name, url).to_s
    end
  end
end
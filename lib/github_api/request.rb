# encoding: utf-8

require 'base64'
require 'addressable/uri'
require 'multi_json'

module Github
  # Defines HTTP verbs
  module Request

    METHODS = [:get, :post, :put, :delete, :patch]
    METHODS_WITH_BODIES = [ :post, :put, :patch ]

    def get_request(path, params={}, options={})
      request(:get, path, params, options)
    end

    def patch_request(path, params={}, options={})
      request(:patch, path, params, options)
    end

    def post_request(path, params={}, options={})
      request(:post, path, params, options)
    end

    def put_request(path, params={}, options={})
      request(:put, path, params, options)
    end

    def delete_request(path, params={}, options={})
      request(:delete, path, params, options)
    end

    def request(method, path, params, options)
      if !METHODS.include?(method)
        raise ArgumentError, "unkown http method: #{method}"
      end
      _extract_mime_type(params, options)

      puts "EXECUTED: #{method} - #{path} with #{params} and #{options}" if ENV['DEBUG']

      response = connection(options).send(method) do |request|
        case method.to_sym
        when *(METHODS - METHODS_WITH_BODIES)
          request.url(path, params)
          request.body = params.delete('data') if params.has_key?('data')
        when *METHODS_WITH_BODIES
          request.path = path
          request.body = _process_params(params) unless params.empty?
        end
      end
      response.body
    end

    private

    def _process_params(params) # :nodoc:
      return params['data'] if params.has_key?('data') and !params['data'].nil?
      return params
    end

    def _extract_mime_type(params, options) # :nodoc:
      options['resource']  = params['resource'] ? params.delete('resource') : ''
      options['mime_type'] = params['resource'] ? params.delete('mime_type') : ''
    end

    # no need for this smizzle
    def formatted_path(path, options={})
      [ path, options.fetch(:format, format) ].compact.join('.')
    end

    def basic_auth(login, password) # :nodoc:
      auth = Base64.encode("#{login}:#{password}")
      auth.gsub!("\n", "")
    end

    def token_auth
    end

  end # Request
end # Github

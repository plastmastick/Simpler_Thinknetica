require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      @status_code = nil
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      set_default_headers
      send(action)
      write_response
      @response.status = @status_code unless @status_code.nil? || @response.status == 500

      @response.finish
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_default_headers
      @response['Content-Type'] = 'text/html'
    end

    def write_response
      body = render_body

      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def params
      @request.env['simpler.request_params']
    end

    def render(template)
      template = { file: template } unless template.is_a?(Hash)
      @request.env['simpler.template'] = template
    end

    def responce_status_set(code)
      @status_code = code
    end

    def responce_headers_set(headers)
      headers.each { |k, v| @response[k.to_s] = v.to_s }
    end

  end
end

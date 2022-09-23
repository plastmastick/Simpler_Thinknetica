# frozen_string_literal: true

require 'logger'

class AppLogger
  def initialize(app)
    @logger = Logger.new(Simpler.root.join('log/app.log'))
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    @logger.info(log_create(env, status, headers))
    [status, headers, response]
  end

  private

  def log_create(env, status, headers)
    {
      Request: "#{env['REQUEST_METHOD']} #{env['REQUEST_PATH']}",
      Handler: "#{env['simpler.controller'].class}##{env['simpler.action']}",
      Parameters: env['simpler.request_params'],
      Response: "#{status} [#{headers['Content-Type']}] #{env['simpler.template_path']}"
    }
  end
end

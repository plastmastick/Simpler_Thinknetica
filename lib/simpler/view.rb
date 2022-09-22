require 'erb'

module Simpler
  class View

    VIEW_BASE_PATH = 'app/views'.freeze
    RENDER_TYPE = {
      file: :file_render,
      plain: :plain_render
    }.freeze

    def initialize(env)
      @env = env
    end

    def render(binding)
      send(template ? RENDER_TYPE[template.keys.first] : :file_render, binding)
    end

    private

    def controller
      @env['simpler.controller']
    end

    def action
      @env['simpler.action']
    end

    def template
      @env['simpler.template']
    end

    def template_path
      path = template ? template[:file] : [controller.name, action].join('/')

      Simpler.root.join(VIEW_BASE_PATH, "#{path}.html.erb")
    end

    def file_render(binding)
      template = File.read(template_path)

      ERB.new(template).result(binding)
    end

    def plain_render(_binding)
      template[:plain]
    end

  end
end

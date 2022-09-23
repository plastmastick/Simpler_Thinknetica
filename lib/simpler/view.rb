# frozen_string_literal: true

require 'erb'

module Simpler
  class View
    VIEW_BASE_PATH = 'app/views'
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
      @env['simpler.template_path'] = "#{path}.html.erb"

      Simpler.root.join(VIEW_BASE_PATH, @env['simpler.template_path'])
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

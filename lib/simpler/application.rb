# frozen_string_literal: true

require 'yaml'
require 'singleton'
require 'sequel'
require_relative 'router'
require_relative 'controller'

module Simpler
  class Application
    include Singleton

    attr_reader :db, :app_routes, :router

    def initialize
      @router = Router.new
      @db = nil
    end

    def bootstrap!
      setup_database
      require_app
      require_routes
    end

    def routes(&block)
      @router.instance_eval(&block)

      route_paths = {}
      @router.routes.each { |route| route_paths[route.path] = Simpler.application }
      @app_routes = Rack::URLMap.new(route_paths)
    end

    def call(env)
      route = @router.route_for(env)
      controller = route.controller.new(env)
      action = route.action
      env['simpler.request_params'] = setup_params(route, env['REQUEST_PATH'])

      make_response(controller, action)
    end

    private

    def require_app
      Dir["#{Simpler.root}/app/**/*.rb"].each { |file| require file }
    end

    def require_routes
      require Simpler.root.join('config/routes')
    end

    def setup_database
      database_config = YAML.load_file(Simpler.root.join('config/database.yml'))
      database_config['database'] = Simpler.root.join(database_config['database'])
      @db = Sequel.connect(database_config)
    end

    def make_response(controller, action)
      controller.make_response(action)
    end

    def setup_params(route, path)
      params = {}
      self_elements = route.route_elements
      path_elements = path.split('/')

      path_elements.each do |e|
        p_index = path_elements.index(e)
        params[self_elements[p_index]] = e.to_i if e.to_i.positive? && self_elements[p_index].is_a?(Symbol)
      end

      params
    end
  end
end

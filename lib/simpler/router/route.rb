module Simpler
  class Router
    class Route

      attr_reader :controller, :action, :path

      def initialize(method, path, controller, action)
        @method = method
        @path = path
        @controller = controller
        @action = action
      end

      def match?(method, path)
        @method == method && convert_to_route_format(path).match(@path)
      end

      def route_elements
        @path.split('/').map { |e| e.start_with?(':') ? e[1..].to_sym : e }
      end

      private

      def convert_to_route_format(path)
        self_elements = route_elements
        path_elements = path.split('/')


        path_elements.map do |e|
          p_index = path_elements.index(e)
          e.to_i.positive? && self_elements[p_index].is_a?(Symbol) ? ":#{self_elements[p_index]}" : e
        end.join('/')
      end

    end
  end
end

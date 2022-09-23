# frozen_string_literal: true

require_relative 'config/environment'
require_relative 'lib/middleware/logger'

use AppLogger
run Simpler.application.app_routes

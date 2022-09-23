# frozen_string_literal: true

class TestsController < Simpler::Controller
  def index
    @time = Time.now
    @tests = Test.all
  end

  def create; end

  def show
    @params = params
  end
end

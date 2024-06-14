class HomeController < ApplicationController
  def index
    render("index.ecr")
  end

  # Exception throwing endpoint for testing.
  def kaboom
    raise "Oh nooes!"
  end
end

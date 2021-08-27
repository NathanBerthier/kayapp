class ToposController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    @topos = Topo.all
  end

  def show
    @topo = Topo.find(params[:id])
    @departure = Address.find(@topo.departure_id)
    @arrival = Address.find(@topo.arrival_id)
    comments = Comment.where(topo_id: @topo.id)
    @alerts_count = comments.where(category: "alert", active: true).count

    @data = water_data
  end

  private

  def water_data
    series_a = {
      "10": 20,
      "12": 100,
      "18": 50,
      "23": 51,
    }
    series_b = {
      "10": 2,
      "12": 10,
      "18": 50,
      "23": 51,
    }
    return [
      {name: "Station A", data: series_a, color: "orange"},
      {name: "Station B", data: series_b, color: "black"}
    ]
  end

end

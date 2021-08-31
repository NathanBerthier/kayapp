class ToposController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    if params[:query].present?
      @topos = Topo.search_by_topo_and_river(params[:query])
    else
      @topos = Topo.all
    end
  end

  def toggle_favorite
    topo = Topo.find(params[:id])

    @fav = Favorite.find_by(user_id: current_user.id, topo_id: topo.id)
    if @fav
      @fav.destroy
    else
      @fav = Favorite.create(user_id: current_user.id, topo_id: topo.id)
    end
  end

  def show
    @topo = Topo.find(params[:id])
    @departure = Address.find(@topo.departure_id)
    @arrival = Address.find(@topo.arrival_id)

    comments = Comment.where(topo_id: @topo.id)
    @alerts_count = comments.where(category: "alert", active: true).count

    @favorite = Favorite.where(user_id: current_user.id, topo_id: @topo.id).exists?

    @topo_sites_name = ApiHubeauSiteName.call(@topo.river.name)
    @topo_sites_code = ApiHubeauCodeSite.call(@topo.river.name)
    @topo_sites_info = ApiHubeauInfoSite.call(@topo.river.name)

    topo_sites_levels = []
    @topo_sites_info.each do |value|
      data = ApiHubeauDataSite.call(value[:code])
      topo_sites_levels << data
    end
    @topo_sites_levels = topo_sites_levels.flatten

    stats = StatsForRiver.call(@topo.river)

    @data = stats.each do |station|
      station[:data] = station[:data].map {|set| [set[:date], set[:level]]}.to_h
    end

  end

    private

    def rom_to_int(rom)
      roman_to_int = {  'I' => 1,
                        'II' => 2,
                        'III' => 3,
                        'IV' => 4,
                        'V' => 5,
                        'VI' => 6 }
      roman_to_int[rom]
    end
end

  # def water_data
  #   series_a = {
  #     "2021-08-31 07:05:00" => 30,
  #     "2021-08-31 08:05:00" => 100,
  #     "2021-08-31 09:05:00" => 80,
  #   }
  #   series_b = {
  #     "2021-08-31 07:05:00" => 100,
  #     "2021-08-31 08:05:00" => 10,
  #     "2021-08-31 09:05:00" => 8,
  #   }
  #   data = [
  #     {name: "Station A", data: series_a, color: "orange"},
  #     {name: "Station B", data: series_b, color: "black"}
  #   ]
  #   ap data
  #   return data
  # end

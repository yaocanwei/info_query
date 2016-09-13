class Ticket < Spider::Base
  def stations
    file = File.read('stations.json')
    stations = JSON.parse file
    binding.pry
  end

end
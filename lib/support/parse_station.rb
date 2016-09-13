class ParseStation < Spider::Base
  # 爬取车站信息存储json文件
  def handle_stations
    url = "https://kyfw.12306.cn/otn/resources/js/framework/station_name.js?"
    options = {}
    options[:station_version] = 1.8966
    path = "otn/resources/js/framework/station_name.js?"
    request_url = domain_name + path
    puts ">>>>>>>>>>>>>>>>>>>start crawler>>>>>>>>>>>>>>>>>>>"
    res, res_time = get_response(request_url, options)
    puts "<<<<<<<<<<<<<<<<<<<costs: #{res_time} <<<<<<<<<<<<"
    page = Nokogiri::HTML res
    stations = page.text().scan /([A-Z]+)\|([a-z]+)/ if page
    stations_hash = Hash[stations]
    File.open("stations.json","w") do |f|
      f.write(JSON.pretty_generate(stations_hash))
      f.close
    end
  end
end
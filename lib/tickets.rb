class Ticket < Spider::Base

  QUERY_URL = 'https://kyfw.12306.cn/otn/lcxxcx/query?'

  class Config
    @@params = %w(date from to)
    def self.params; @@params; end
  end

  def stations
    file = File.read('stations.json')
    stations = JSON.parse file
  end

  def query
    # url = 'https://kyfw.12306.cn/otn/lcxxcx/query?purpose_codes=ADULT&queryDate=2016-09-17&from_station=CBQ&to_station=GZQ'
    tmp = stations
    params = Ticket::Config.params
    puts "params: " + params.join(", ")
    options = {}
    params.map do|param|
      print "#{param}>"
      options[:purpose_codes] ||= "ADULT" 
      options[:queryDate] ||= gets.chomp.strip if param == 'date'
      options[:from_station] ||= tmp.key(gets.chomp.strip) if param == 'from'
      options[:to_station] ||= tmp.key(gets.chomp.strip) if param == 'to'
    end
    response, response_time = get_response(QUERY_URL, options)
    rows = JSON.parse(response)['data']['datas']
  end
end
require 'support/time_parser'
class Ticket < Spider::Base

  QUERY_URL = 'https://kyfw.12306.cn/otn/lcxxcx/query?'
  HEADER = %w(车次 出发/到达站 出发/到达时间 历时 一等座 二等座 软卧 硬卧 硬座)

  class Config
    @@params = %w(date from to)
    def self.params; @@params; end
  end

  def file_read
    file = File.read('stations.json')
    stations = JSON.parse file
  end

  def query
    tmp = file_read
    params = Ticket::Config.params
    puts "params: " + params.join(", ")
    options = {}
    #TODO: refactor
    params.map do|param|
      print "#{param}>"
      options[:purpose_codes] ||= "ADULT" 
      options[:queryDate] ||= gets.chomp.strip if param == 'date'
      options[:from_station] ||= tmp.key(gets.chomp.strip) if param == 'from'
      options[:to_station] ||= tmp.key(gets.chomp.strip) if param == 'to'
    end
    response, response_time = get_response(QUERY_URL, options)
    rows = JSON.parse(response)['data']['datas']
    rows_handle(rows)
  end

  def get_duration(row)
    duration = row['lishi'].gsub!(':', 'h') + "m"
    return duration
  end

  #将数据加工为能够使用terminal-table美化的格式
  def rows_handle(rows)
    options = []
    for row in rows 
      options << [
        row['station_train_code'],
        row['from_station_name']+"\n"+row['to_station_name'],
        row['start_time']+"\n"+row['arrive_time'],
        get_duration(row),
        row['zy_num'],
        row['ze_num'],
        row['rw_num'],
        row['yw_num'],
        row['yz_num']
      ]  
    end
    table = Terminal::Table.new :headings => HEADER, :rows => options
    puts table
  end

end
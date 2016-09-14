#将时间转为秒
#example: TimeParser.new('2h5m').time
#output: 7500
class TimeParser
  TOKENS = {
    "m" => (60),
    "h" => (60 * 60),
    "d" => (60 * 60 * 24)
  }

  attr_reader :time

  def initialize
    @input = input
    @time = 0
    parse
  end

  def parse
    @input.scan(/(\d+)(\w)/).each do |amount, measure|
      @time += amount.to_i * TOKENS[measure]
    end
  end

  # def formatted_duration total_seconds
  #   hours = total_seconds / (60 * 60)
  #   minutes = (total_seconds / 60) % 60
  #   seconds = total_seconds % 60
  #   "#{ hours } h #{ minutes } m #{ seconds } s"
  # end
end
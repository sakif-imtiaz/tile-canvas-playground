class Length
  def against(primitive_length)
    from_percent = (primitive_length * percent / 100.0) || 0
    total = from_percent + pixels
    total
  end

  attr_accessor :percent, :pixels

  def initialize(percent = 0, pixels = 0)
    @percent, @pixels = percent, pixels
  end

  def ==(other)
    percent == other.percent &&
      pixels == other.pixels
  end

  alias_method :eql?, :==

  def hash
    [percent, pixels].hash
  end

  def +(other)
    Length.new(percent + other.percent, pixels + other.pixels)
  end

  def -(other)
    Length.new(percent + -1 * other.percent, pixels + -1 * other.pixels)
  end

  def *(c)
    Length.new(percent * c, pixels * c)
  end

  def /(c)
    Length.new(percent/c, pixels/c)
  end

  def to_s
    "#{pixels}px #{percent}%"
  end

  ARITHMETIC = /\s*[\+\-\*\\]\s*/
  PIXELS  = /\-?\d+\.?\d*\s?px/
  PERCENT = /\-?\d+\.?\d*\%/

  TOKENIZER = Regexp.union(ARITHMETIC, PERCENT, PIXELS)

  def self.parse(str)
    current_operation = nil
    sum = px(0)
    str.scan(TOKENIZER).each do |part|
      case part
      when PERCENT
        new_len = percent(part.chomp('%').chomp(' ').to_f)
        if current_operation
          sum = sum.send(current_operation, new_len)
        else
          sum = new_len
        end
      when PIXELS
        new_len = px(part.chomp('px').chomp(' ').to_f)
        if current_operation
          sum = sum.send(current_operation, new_len)
        else
          sum = new_len
        end
      when ARITHMETIC
        current_operation = part.strip.to_sym
      end
    end
    sum
  end
end

def length(percent: 0, pixels: 0)
  Length.new(percent, pixels)
end

def percent(v); length(percent: v); end
def px(v); length(pixels: v); end

parsed_length = Length.parse('20% + 30px')
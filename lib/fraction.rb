class Fraction
  attr_reader :numerator, :denominator

  def self.parse_i(str_i)
    return nil unless str_i.to_i.to_s == str_i
    str_i.to_i
  end

  def self.parse(str)
    num_u, den_u, *others = str.split "/"
    return nil if others.any?
    return nil unless num_u && den_u
    num = parse_i num_u.strip.lstrip
    den = parse_i den_u.strip.lstrip
    return nil unless num && den
    new(num, den)
  end

  def initialize(numerator, denominator)
    raise "can't have a zero denominator" if denominator.zero?
    if numerator.zero?
      @numerator, @denominator = numerator, denominator
    else
      gcd = gcd(numerator, denominator)
      @numerator, @denominator = numerator/gcd, denominator/gcd
    end
  end

  def mult(other)
    Fraction.new(@numerator * other, @denominator)
  end

  def *(other_int)
    Fraction.new(@numerator * other_int, @denominator)
  end

  def inverse
    Fraction.new(@denominator, @numerator)
  end

  def to_f
    (@numerator.to_f/@denominator.to_f)
  end

  def to_s
    "#{@numerator}/#{@denominator}"
  end

  def serialize
    to_h
  end

  def to_h
    { numerator: @numerator, denominator: @denominator }
  end

  def gcd(num1, num2)
    if (num1 > num2)
      x = num1;
      y = num2;
    else
      x = num2;
      y = num1;
    end

    rem = x % y;

    while (rem != 0)
      x = y;
      y = rem;
      rem = x % y;
    end
    y
  end

  def ==(other)
    return false unless other.is_a?(Fraction)
    numerator == other.numerator &&
      denominator == other.denominator
  end
  alias_method :eql?, :==

  def hash
    [self.class, @numerator, @denominator].hash
  end
end

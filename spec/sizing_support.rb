require 'matrix'
require './lib/fraction.rb'

class Dimensions
  attr_reader :vec
  def initialize(vec)
    @vec = vec
  end

  def x
    vec[0]
  end

  def w
    vec[0]
  end

  def h
    vec[1]
  end

  def y
    vec[1]
  end

  def to_s
    to_h.to_s
  end

  def to_h
    { x: x, y: y }
  end

  def ==(other)
    x == other.x && y ==other.y
  end

  def clamp(rect)
    vec2(
      x.clamp(rect.x, rect.w + rect.x),
      y.clamp(rect.h, rect.h + rect.h),
    )
  end
  #
  # # TODO: move this over
  # def limit(other)
  #
  # end
end

class Point < Dimensions
  def to_h
    { w: w, h: h }
  end
end

class Asset
  attr_reader :dimensions
  def initialize(dims)
    @dimensions = dims
  end
end

module MatrixFunctions
  def vec2(a,b)
    Point.new(Vector[a,b])
  end
end

def asset(vec)
  Asset.new(vec)
end

def fraction(a, b)
  Fraction.new(a, b)
end

def dimensions(a, b)
  # Dimensions.new()
  vec2(a,b)
end

require "./smaug/arby/arby.rb"
require "./smaug/visual-primitives/lib/basic_values.rb"
require "./smaug/visual-primitives/lib/common_attributes.rb"
require "./smaug/visual-primitives/lib/label.rb"
require "./smaug/visual-primitives/lib/solid.rb"
require "./smaug/visual-primitives/lib/sprite.rb"
require "./smaug/visual-primitives/lib/border.rb"

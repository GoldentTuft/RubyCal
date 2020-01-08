# -*- encoding: utf-8 -*-

require "readline"
require "timeout"
include Math

def sind(x)
  sin(x*PI/180)
end

def cosd(x)
  cos(x*PI/180)
end

def tand(x)
  tan(x*PI/180)
end

def deg(rad)
  rad * 180 / PI
end

def rad(deg)
  deg * PI / 180
end

def asind(x)
  deg(asin(x))
end

def acosd(x)
  deg(acos(x))
end

def atand(x)
  deg(atan(x))
end

class Array
  def sum
    total = 0.0
    self.each do |item|
      total += item
    end
    total
  end

  def average
    sum() / self.size
  end

  def mean
    average()
  end

  def avg
    average()
  end

  def median
    a = self.sort
    if self.size % 2 == 0
      j = self.size / 2
      i = j - 1
      (a[i] + a[j]) / 2
    else
      i = (self.size - 1) / 2
      a[i]
    end
  end

  # データ偏差の平方和
  def devsq
    av = self.average
    dev = self.map {|item| item - av}
    (dev.map {|item| item ** 2}).sum
  end

  # 分散
  def var
    self.devsq / (self.size - 1)
  end

  # 標準偏差
  def stdev
    sqrt(self.var)
  end

  # 変動係数
  def cv
    self.stdev / self.average
  end
end

class Integer
  alias_method :old_div, :/
  def /(other)
    if self%other == 0
      self.old_div(other)
    else
      self.fdiv(other)
    end
  end
end

class SandBox
  def initialize
    @bind = binding
    eval("ans = 0; preans = 0; tempans = 0;", @bind)
  end

  def run(str)
    result = nil
    begin
      Thread.start {
        e1 = "tempans = #{str}"
        e2 = "preans = ans"
        e3 = "ans = tempans"
        $SAFE=1
        result = eval(e1, @bind)
        eval(e2, @bind)
        eval(e3, @bind)
      }.join(1)
    rescue Object => e
      return e
    end
    return result
  end
end

class History
  def initialize
    @hist = []
    @hist_size = 10
  end

  def register(a)
    raise "String only" unless a.is_a?(String)
    @hist.unshift(a)
    @hist = @hist[0...@hist_size]
  end

  def [](a)
    raise "size over" if a >= @hist_size
    @hist[a]
  end

  def size
    @hist_size
  end

  def to_s
    @hist.to_s
  end
end

def trash?(a)
  return true if a == nil
  return true if a =~ /\A[[:space:]]*\z/
  return false
end

def comment?(a)
  return a.start_with?("#")
end

MyStandard = Object.new
class << MyStandard
  @round_digit = nil

  public

  def form(a)
    if @round_digit && a.instance_of?(Float)
      a.round(@round_digit)
    else
      a
    end
  end

  def round_digit(a)
    @round_digit = a
  end
end

def main
  box = SandBox.new
  history = History.new
  MyStandard.round_digit(3)
  begin
    while buf = Readline.readline("", true)
      if trash?(buf)
        puts "=#{box.run(history[0])}"
      elsif comment?(buf)
        buf
      else
        history.register(buf)
        puts "=#{MyStandard.form(box.run(buf))}"
      end
    end
  rescue Interrupt
    puts "end!"
    exit 1
  end
end

main()

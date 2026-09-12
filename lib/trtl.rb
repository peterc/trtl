require_relative 'trtl/colors'
require_relative 'trtl/canvas'

class Trtl
  CANVAS_WIDTH = 800
  CANVAS_HEIGHT = 600
  HOME_X = CANVAS_WIDTH / 2
  HOME_Y = CANVAS_HEIGHT / 2
  COLORS = %w{red blue green white cyan pink yellow}
  DEG = Math::PI / 180.0

  attr_accessor :heading, :x, :y
  attr_writer :color, :width
  attr_reader :canvas

  def initialize(options = {})
    @color = options[:color] || COLORS.sample
    @interactive = options[:interactive]
    @canvas = options[:canvas] || self.class.canvas
    @width = options[:width] || 1
    @drawing = true
    @canvas.add_turtle(self)
    home
    draw
  end

  def self.canvas
    @canvas ||= Canvas.new(CANVAS_WIDTH, CANVAS_HEIGHT)
  end

  def title(title)
    canvas.title = title
  end

  def pen_up
    @drawing = false
  end

  def pen_down
    @drawing = true
  end

  def is_drawing?
    @drawing
  end

  # With no argument, returns the current color
  def color(color = nil)
    return @color if color.nil?
    @color = color.to_s
  end

  def width(width)
    @width = width
  end

  def forward(amount = 20)
    new_x = (@x + dx * amount)
    new_y = (@y + dy * amount)
    move(new_x, new_y)
  end

  def back(amount = 20)
    new_x = (@x - dx * amount)
    new_y = (@y - dy * amount)
    move(new_x, new_y)
  end

  def move(new_x, new_y)
    canvas.line(@x, @y, new_x, new_y, @width, @color) if @drawing
    @x, @y = new_x, new_y
    draw
  end

  def right(offset)
    @heading = (@heading + offset) % 360
    draw
  end

  def left(offset)
    @heading = (@heading - offset) % 360
    draw
  end

  def dot(size = nil)
    size ||= [@width + 4, @width * 2].max
    canvas.dot(@x, @y, size, @color)
  end

  # TODO / TOFIX: This is horribly wrong with the fewer steps due to circumference varying ;-)
  def circle(radius, extent = 360, steps = 360)
    circumference = (Math::PI * 2 * radius) * (extent / 360.0)
    steps.times do
      left extent / steps.to_f
      forward circumference / steps.to_f
    end
  end

  def position
    [@x, @y]
  end

  def home
    @x = HOME_X
    @y = HOME_Y
    @heading = 0
    draw
  end

  # Shows the window and keeps it responsive for +time+ milliseconds
  def sleep(time = 100000)
    canvas.update(time)
  end

  def ensure_drawn
    sleep 30
  end

  # Keeps the window open until it's closed or Enter is pressed
  def wait
    canvas.wait
  end

  alias :run :instance_eval

  # Compatibility aliases (with turtle.py and KidsRuby primarily)
  alias :fd :forward
  alias :bk :back
  alias :rt :right
  alias :lt :left
  alias :pu :pen_up
  alias :pd :pen_down
  alias :penup :pen_up
  alias :pendown :pen_down
  alias :up :pen_up
  alias :down :pen_down
  alias :turnright :right
  alias :turnleft :left
  alias :backward :back
  alias :pencolor :color
  alias :goto :move
  alias :setpos :move
  alias :setposition :move
  alias :pos :position

  private
  def dx
    Math.cos(@heading * DEG)
  end

  def dy
    Math.sin(@heading * DEG)
  end

  def draw
    canvas.changed
    canvas.update(60) if @interactive
    true
  end
end

module InteractiveTurtle
  DEG = Math::PI / 180.0

  Trtl.instance_methods(false).each do |meth|
    define_method meth do |*args, &p|
      (@turtle ||= ::Trtl.new(:interactive => true)).send(meth, *args, &p)
    end
  end
end

if %w{irb pry}.include?(File.basename($0))
  include InteractiveTurtle
  Trtl::Canvas.keep_responsive!
end

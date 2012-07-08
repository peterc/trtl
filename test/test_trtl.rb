require_relative 'helper'

# Note: Only very simple high level tests here. Just stretching 
#       some of the public API. One day I may care to stub out Tk ;-)

describe Trtl do
  before do
    @trtl = Trtl.new
  end

  it "gets a default canvas when none is provided" do
    @trtl.canvas.must_be_instance_of TkCanvas
  end

  it "has pen down by default" do
    @trtl.is_drawing?.must_equal true
  end

  it "can have pen moved up" do
    @trtl.pen_up
    @trtl.is_drawing?.must_equal false    
  end

  it "has default X and Y set" do
    @trtl.x.must_equal Trtl::CANVAS_WIDTH / 2
    @trtl.y.must_equal Trtl::CANVAS_HEIGHT / 2
  end

  it "can report its position" do
    @trtl.position.must_equal [@trtl.x, @trtl.y]
  end

  it "can rotate and change heading" do
    @trtl.left 20
    @trtl.heading.must_equal 340
    @trtl.right 40
    @trtl.heading.must_equal 20
  end

  it "can move in straight lines" do
    start_x, start_y = @trtl.position
    @trtl.heading = 0
    @trtl.forward 50
    @trtl.x.must_equal start_x + 50
    @trtl.heading = 90
    @trtl.forward 50
    @trtl.y.must_equal start_y + 50
    @trtl.back 50
    @trtl.y.must_equal start_y
  end

  it "can move at angles" do
    start_x, start_y = @trtl.position
    @trtl.heading = 45
    @trtl.forward 100
    @trtl.x.must_be_close_to start_x + 100 / Math.sqrt(2)
    @trtl.y.must_be_close_to start_y + 100 / Math.sqrt(2)
  end

  it "can be moved absolutely" do
    @trtl.move(310, 201)
    @trtl.position.must_equal [310, 201]
  end
end

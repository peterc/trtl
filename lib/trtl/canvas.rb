require 'libui'

class Trtl
  # A window with a drawing area, built on LibUI. LibUI areas are repainted
  # from scratch whenever the OS asks, so the canvas keeps a list of everything
  # drawn so far and replays it on each repaint.
  class Canvas
    UI = LibUI
    FRAME = 1 / 60.0
    TWO_PI = Math::PI * 2

    attr_reader :width, :height, :title

    class << self
      def canvases
        @canvases ||= []
      end

      def init_ui
        return if @ui_ready
        UI.init
        UI.main_steps
        # Cmd+Q closes the windows rather than stopping the event loop
        UI.on_should_quit do
          canvases.each(&:close)
          0
        end
        @ui_ready = true
      end

      # UI calls must not be re-entered from the signal handler used by keep_responsive!
      def busy
        was_busy, @busy = @busy, true
        yield
      ensure
        @busy = was_busy
      end

      def busy?
        @busy
      end

      # IRb and Pry spend most of their time blocked waiting for keyboard input,
      # when nothing would service the window (so it couldn't be moved, resized,
      # or even repainted). A background thread signals the process regularly
      # and the trap handler, which Ruby always runs on the main thread as the
      # UI requires, processes any pending window events. Windows has no USR2,
      # so there the window only updates when turtle commands run.
      def keep_responsive!
        return if @keeper || !Signal.list.key?('USR2')
        Signal.trap('USR2') { canvases.each(&:pump) unless busy? }
        @keeper = Thread.new do
          loop do
            Kernel.sleep(FRAME * 2)
            Process.kill('USR2', Process.pid)
          end
        end
      end
    end

    def initialize(width, height, title: 'trtl', background: 'black')
      @width, @height, @title = width, height, title
      @background = Colors.rgb(background)
      @items = []
      @turtles = []
      self.class.canvases << self
    end

    def line(x1, y1, x2, y2, width, color)
      @items << [:line, x1.to_f, y1.to_f, x2.to_f, y2.to_f, width.to_f, Colors.rgb(color)]
      changed
    end

    def dot(x, y, size, color)
      @items << [:dot, x.to_f, y.to_f, size / 2.0, Colors.rgb(color)]
      changed
    end

    def add_turtle(turtle)
      @turtles << turtle
      changed
    end

    # Marks the canvas as needing a repaint the next time events are processed
    def changed
      @dirty = true
    end

    def title=(title)
      @title = title.to_s
      UI.window_set_title(@window, @title) if open?
    end

    def open?
      !@window.nil?
    end

    # Opens the window if necessary, then processes window events for about
    # +ms+ milliseconds, which is what gets the latest drawing on screen
    def update(ms = 0)
      open unless open?
      deadline = clock + ms / 1000.0
      pump
      while (remaining = deadline - clock) > 0
        Kernel.sleep([FRAME, remaining].min)
        pump
      end
    end

    # Keeps the window responsive until it's closed or Enter is pressed
    def wait
      update
      while open?
        if IO.select([$stdin], nil, nil, FRAME)
          $stdin.gets
          break
        end
        pump
      end
    end

    def pump
      return unless open?
      self.class.busy do
        if @dirty
          UI.area_queue_redraw_all(@area)
          @dirty = false
        end
        # Each step handles at most one pending event
        20.times { UI.main_step(0) }
      end
    end

    def close
      return unless open?
      self.class.busy { UI.control_destroy(@window) }
      closed
    end

    private

    def clock
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def open
      self.class.init_ui
      self.class.busy do
        @window = UI.new_window(@title, @width, @height, 0)

        @handler = struct(UI::FFI::AreaHandler)
        # Fiddle closures are kept in instance variables so they aren't garbage collected
        @draw_callback = Fiddle::Closure::BlockCaller.new(Fiddle::TYPE_VOID, [Fiddle::TYPE_VOIDP] * 3) do |_, _, params|
          draw(UI::FFI::AreaDrawParams.new(params))
        rescue Exception => e
          warn "trtl: error while drawing: #{e.class}: #{e.message}"
        end
        @ignore_callback = Fiddle::Closure::BlockCaller.new(Fiddle::TYPE_VOID, [Fiddle::TYPE_VOIDP]) {}
        @key_callback = Fiddle::Closure::BlockCaller.new(Fiddle::TYPE_INT, [Fiddle::TYPE_VOIDP]) { 0 }
        @handler.Draw = @draw_callback
        @handler.MouseEvent = @ignore_callback
        @handler.MouseCrossed = @ignore_callback
        @handler.DragBroken = @ignore_callback
        @handler.KeyEvent = @key_callback

        @area = UI.new_area(@handler)
        UI.window_set_child(@window, @area)
        # Returning 1 lets LibUI destroy the window (and the area inside it)
        UI.window_on_closing(@window) do
          closed
          1
        end
        UI.control_show(@window)
      end
      changed
    end

    def closed
      @window = @area = nil
    end

    def struct(type)
      type.malloc.tap { |s| s.to_ptr.free = Fiddle::RUBY_FREE }
    end

    def draw(params)
      ctx = params.Context
      @brush ||= struct(UI::FFI::DrawBrush).tap { |b| b.Type = UI::DrawBrushTypeSolid }
      @stroke ||= struct(UI::FFI::DrawStrokeParams).tap do |s|
        s.Cap = UI::DrawLineCapRound
        s.Join = UI::DrawLineJoinRound
        s.MiterLimit = UI::DrawDefaultMiterLimit
        s.NumDashes = 0
        s.DashPhase = 0
      end

      fill(ctx, @background) { |path| UI.draw_path_add_rectangle(path, 0, 0, params.AreaWidth, params.AreaHeight) }

      # Keep the drawing centered if the window is resized
      @matrix ||= struct(UI::FFI::DrawMatrix)
      UI.draw_matrix_set_identity(@matrix)
      UI.draw_matrix_translate(@matrix, (params.AreaWidth - @width) / 2.0, (params.AreaHeight - @height) / 2.0)
      UI.draw_transform(ctx, @matrix)

      draw_items(ctx)
      @turtles.each { |turtle| draw_turtle(ctx, turtle) }
    end

    # Consecutive lines sharing a width and color go into a single path, joined
    # up where one starts at the end of the last, which is much faster than
    # stroking each line alone and gives cleaner joins
    def draw_items(ctx)
      path = style = last_x = last_y = nil

      @items.each do |kind, *args|
        if kind == :line
          x1, y1, x2, y2, width, rgb = args
          if path.nil? || style[0] != width || style[1] != rgb
            stroke(ctx, path, style) if path
            path = UI.draw_new_path(UI::DrawFillModeWinding)
            style = [width, rgb]
            UI.draw_path_new_figure(path, x1, y1)
          elsif x1 != last_x || y1 != last_y
            UI.draw_path_new_figure(path, x1, y1)
          end
          UI.draw_path_line_to(path, x2, y2)
          last_x, last_y = x2, y2
        else
          stroke(ctx, path, style) if path
          path = nil
          x, y, radius, rgb = args
          fill(ctx, rgb) { |p| UI.draw_path_new_figure_with_arc(p, x, y, radius, 0, TWO_PI, 0) }
        end
      end

      stroke(ctx, path, style) if path
    end

    # An arrowhead pointing in the turtle's direction of travel
    def draw_turtle(ctx, turtle)
      x, y = turtle.position
      angle = turtle.heading * DEG
      dx, dy = Math.cos(angle), Math.sin(angle)
      fill(ctx, Colors.rgb(turtle.color)) do |path|
        UI.draw_path_new_figure(path, x + dx * 10, y + dy * 10)
        UI.draw_path_line_to(path, x - dx * 2 - dy * 6, y - dy * 2 + dx * 6)
        UI.draw_path_line_to(path, x - dx * 2 + dy * 6, y - dy * 2 - dx * 6)
        UI.draw_path_close_figure(path)
      end
    end

    def stroke(ctx, path, (width, rgb))
      UI.draw_path_end(path)
      set_brush(rgb)
      @stroke.Thickness = width
      UI.draw_stroke(ctx, path, @brush, @stroke)
      UI.draw_free_path(path)
    end

    def fill(ctx, rgb)
      path = UI.draw_new_path(UI::DrawFillModeWinding)
      yield path
      UI.draw_path_end(path)
      set_brush(rgb)
      UI.draw_fill(ctx, path, @brush)
      UI.draw_free_path(path)
    end

    def set_brush((r, g, b))
      @brush.R, @brush.G, @brush.B, @brush.A = r, g, b, 1.0
    end
  end
end

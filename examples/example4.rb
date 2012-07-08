require_relative '../lib/trtl'

# Example below adapted from Ruby quiz turtle_graphics archive
# http://www.rubyquiz.com/quiz104.html

# TREE

Trtl.new(:width => 2, :color => 'brown').run do
   def tree(_size)
      if _size < 10
         forward _size; back _size; return
      end
      color 'brown'
      forward _size / 3
      color %w{green darkgreen darkolivegreen}.sample
      left 30; tree _size * 2 / 3; right 30
      forward _size / 6
      right 25; tree _size / 2; left 25
      forward _size / 3
      width rand(2) + 1
      right 25; tree _size / 2; left 25
      forward _size / 6
      back _size
      ensure_drawn
   end
   
   left 90
   back 180
   pen_down
   tree 300.0

   wait
end

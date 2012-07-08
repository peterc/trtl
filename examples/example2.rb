require_relative '../lib/trtl'

# Example of using Trtl in a more traditional fashion

t = Trtl.new

10.times do 
  t.left(24)
  t.forward(30)
  t.dot
  t.ensure_drawn
end

gets

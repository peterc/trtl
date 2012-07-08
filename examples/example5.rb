require_relative '../lib/trtl'

t = Trtl.new :color => 'blue', :width => 5

10.times do 
  t.circle rand(100), 180, rand(10) + 15
  t.dot 20
  t.forward rand(100)
  t.color %w{blue cyan yellow}.sample
end

t.wait

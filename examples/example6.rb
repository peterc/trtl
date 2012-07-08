require_relative '../lib/trtl'

Trtl.new(:color => 'blue', :width => 5).run do
	10.times do 
	  circle rand(100), 180, rand(10) + 15
	  dot 20
	  forward rand(100)
	  color %w{blue cyan yellow}.sample
	end
	
	wait
end

require_relative '../lib/trtl'

# Example of using Trtl in a 'simple' interactive fashion

# In irb or pry this isn't needed as InteractiveTurtle will be
# included by default.
include InteractiveTurtle

10.times do 
  left(24)
  forward(30)
end

wait

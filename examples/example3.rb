require_relative '../lib/trtl'

include InteractiveTurtle

# Example below taken from Ruby quiz turtle_graphics archive
# http://www.rubyquiz.com/quiz104.html

# BYZANTIUM

def byzantium(r, n)
   return if n < 1
   fd r; rt 135
   4.times {
      pd; fd 2 * r * Math.sin(45 * DEG); pu
      byzantium(r / 2, n - 1)
      rt 90
   }
   lt 135; bk r
end

byzantium(100, 4)

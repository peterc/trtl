*2020 UPDATE: Due to tk being removed from the Ruby standard library and due to changes on macOS (which I primarily use), this library is no longer as easy to use for beginners as it once was. If you can come up with solutions to resolve this issue, I am all ears. I have tagged this repo hacktoberfest if anyone wishes to take on any changes as part of that too including coming up with a new screenshot of the turtle in action as the one below has broken.*

# Trtl - Simple Ruby Turtle Graphics

![example session](http://no.gd/p/trtl-20120708-034138.jpg)

## Installation
    gem install trtl

## Description

Trtl is a simple 'turtle' system inspired by Python's turtle.py. It provides simple turtle drawing capabilities in Ruby, even if you're just at an IRB prompt. It leans on Tk (which used to be in Ruby's standard library but is now an external gem).

## Usage

If Trtl detects you're in an IRb or Pry session, it'll automatically make turtle
methods available directly at the prompt. For example:

    $ irb
    > require 'trtl'
    > forward 100
    # At this point, a window appears with the turtle

If you wish to use Trtl from a regular Ruby script, you have a few options. You
can create a Trtl instance and use it directly:

    require 'trtl'
    t = Trtl.new
    10.times { t.left(24); t.forward(30); t.ensure_drawn }
    t.wait

You can use Trtl's `run` method to use it in a more interactive fashion:

	Trtl.new.run { 10.times { left(24); forward(30); ensure_drawn } }

Or you can include InteractiveTurtle and get a similar effect as if you were in
IRb:

    include InteractiveTurtle
    10.times { left(24); forward(30) }

Note: Using InteractiveTurtle makes drawing slower as it ensures all graphics
are drawn after every action (as necessary for IRb use).

## Commands

Only a small number of commands are currently implemented, but they're enough for the major actions:

* `title(title_name)`
* `forward(distance)` - aliased as `fd`
* `back(distance)` - aliased as `bk` and `backward`
* `left(angle)` - aliased as `lt`
* `right(angle)` - aliased as `rt`
* `pen_up` - aliased as `pu` and `up` and `penup`
* `pen_down` - aliased as `pd` and `down` and `pendown`
* `color(color_name)` - aliased as `pencolor`
* `move(x, y)` - aliased as `goto`
* `position` - aliased as `pos`
* `circle(radius, extent = 360, steps = 360)`
* `dot(size)` - draws a dot, defaults to a sensible size but you can supply if you want
* `is_drawing?`
* `width(width_in_pixels)`

## Examples

The examples in the `examples` folder should be reasonably illustrative. If you
try any of them, try `example4.rb` - it renders an awesome looking tree.

![tree](http://no.gd/p/trtltree-20120708-035127.jpg)

## Credits

* turtle.py for inspiration (in the 'Ruby needs this!' sense)
* Some of the examples taken from examples for an earlier Ruby turtle found at http://www.rubyquiz.com/quiz104.html

## Copyright and License

Copyright (c) 2012-2017 Peter Cooper (other than minor parts of some samples.)

MIT licensed. See LICENSE.md

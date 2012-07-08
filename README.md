# Trtl - Simple Ruby Turtle Graphics

![example session](http://no.gd/p/trtl-20120708-034138.jpg)

## Installation
    gem install trtl

## Description

Trtl is a simple turtle system inspired by Python's turtle.py. It provides
simple turtle drawing capabilities in Ruby, even if you're just at an IRb 
prompt. It leans on Tk which is part of MRI 1.9's standard library so in theory it should
work 'out of the box' with most MRI 1.9 installs.

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

## Examples

The examples in the `examples` folder should be reasonably illustrative. If you
try any of them, try `example4.rb` - it renders an awesome looking tree.

![tree](http://no.gd/p/trtltree-20120708-035127.jpg)

## Credits

* turtle.py for inspiration
* Some of the examples taken from examples for an earlier Ruby turtle found at http://www.rubyquiz.com/quiz104.html

## Copyright and License

Copyright (c) 2012 Peter Cooper (other than minor parts of some samples.)

MIT licensed. See LICENSE.md

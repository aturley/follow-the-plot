# Follow the Plot

This is an attempt at a month-long project in October 2018 where I
will generate svg files to plot/cut on
my [Cricut](https://home.cricut.com/) cutting machine. My plan is to
develop some generative tools and processes to do it.

## Projects

### [1 (2018-10-01)](1)

Write a Pony program that draws a big circle and then some smaller
circles that follow a sine curve. Since Pony doesn't have an SVG
library I'm hand-rolling my own SVG. Maybe I'll end up with a library
at the end of this.

### [2 (2018-10-02)](2)

I decided to try to write a little drawing language. Inspired by
Postscript I went ahead and did something stack-based. It is ugly, but
it has a conditional branch so ... you can probably do some terrible
amazing things with it. Today's piece is a straight line with some zig
zag lines.

### [2.1 (2018-10-02)](2.1)

I took the drawing language and drew some mountains with the sun
overhead and a like in front of them.

### [3 (2018-10-05)](3)

I added recursive functions to the drawing language and wrote a
program that draws a grid of shapes with different numbers of sides.

### [4 (2018-10-09)](4)

I changed the language up a bit and based the drawing on SVG paths,
mostly focusing on arcs.

### [5 (2018-10-10)](5)

Changed the language name to PostSpite. Added lines and relative
movement. Drew some squares.

### [6 (2018-10-11)](6)

Created some circle patterns, played with starbursts and densities.

### [6.1 (2018-10-11)](6.1)

Added curves and some grid fun.

### [7 (2018-10-14)](7)

I added records to the the drawing language. They're basically lists,
and they're recursive, so now I'm not stuck with single values on the
stack and in dictionaries. I also added the ability to run multiple
files from the command line, so now i can basically build libraries
and then import them.

Since I have records and libraries I went ahead and wrote a "range"
function that returns a record with a given number of elements, and a
"map" function that applies a function to all of the elements of a
record. Since functions can be referenced without calling them I now
have a reasonable start to a functional programming language.

With all that excitement I just drew some simple curved lines that
intersect to form a grid.

### [8 (2018-10-15)](8)

This takes advantage of records to draw a series of cubic curves with
the same endpoints but different control points. I added a few bits
and pieces to the language like support for reflected cubic curves.

### [9 (2018-10-31)](9)

Added support for comments, drew some circles.

### [10 (2018-10-31)](10)

This one uses Pony instead of PostSpite to do the generation. I
thought I'd play around and see how it felt to work with Pony.

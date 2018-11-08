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

![project 1 -- cirles](https://pbs.twimg.com/media/DodITmdUYAEIEOJ.jpg)

### [2 (2018-10-02)](2)

I decided to try to write a little drawing language. Inspired by
Postscript I went ahead and did something stack-based. It is ugly, but
it has a conditional branch so ... you can probably do some terrible
amazing things with it. Today's piece is a straight line with some zig
zag lines.

![project 2 -- pointy lines](https://pbs.twimg.com/media/DoiQ5QkV4AAxmod.jpg)

### [2.1 (2018-10-02)](2.1)

I took the drawing language and drew some mountains with the sun
overhead and a like in front of them.

![project 2.1 -- landscape](https://pbs.twimg.com/media/DonsrULWwAA5hLB.jpg)

### [3 (2018-10-05)](3)

I added recursive functions to the drawing language and wrote a
program that draws a grid of shapes with different numbers of sides.

![project 3 -- shapes](https://pbs.twimg.com/media/DoxKVfCVsAAlntf.jpg)

### [4 (2018-10-09)](4)

I changed the language up a bit and based the drawing on SVG paths,
mostly focusing on arcs.

![project 4 -- arcs](https://pbs.twimg.com/media/DpGjsshU4AACgIr.jpg)

### [5 (2018-10-10)](5)

Changed the language name to PostSpite. Added lines and relative
movement. Drew some squares.

![project 5 -- squares](https://pbs.twimg.com/media/DpLrCTVWkAApqas.jpg)

### [6 (2018-10-11)](6)

Created some circle patterns, played with starbursts and densities.

![project 6 -- star bursts](https://pbs.twimg.com/media/DpPM_sbU8AAGqia.jpg)

### [6.1 (2018-10-11)](6.1)

Added curves and some grid fun.

![project 6.1 -- 80s lines and curves](https://pbs.twimg.com/media/DpQaxE4XcAE9n8d.jpg)

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

![project 7 -- more curves](https://pbs.twimg.com/media/DpfDqqpVsAAOana.jpg)

### [8 (2018-10-15)](8)

This takes advantage of records to draw a series of cubic curves with
the same endpoints but different control points. I added a few bits
and pieces to the language like support for reflected cubic curves.

![project 8 -- synchronized curves](https://pbs.twimg.com/media/DpkBW7WUwAATya0.jpg)

### [9 (2018-10-31)](9)

Added support for comments, drew some circles.

![project 9 -- random circles](https://pbs.twimg.com/media/Dq3Q3KiWwAIafxn.jpg)

### [10 (2018-10-31)](10)

This one uses Pony instead of PostSpite to do the generation. I
thought I'd play around and see how it felt to work with Pony.

![project 10 -- grids and circles](https://pbs.twimg.com/media/Dq3RRKrX4AAzn7Y.jpg)

### [11 (2018-11-02)](11)

More Pony work. I experimented with drawing some circles and making
some scribles that vary in intensity depending on the coordinates of
the piece of the line. I'd like to do more experiments where I vary
the texture of the image.

![project 11 -- scribbles of a ... flag?](https://pbs.twimg.com/media/DrBwxZjVYAA_Hst.jpg)

### [12 (2018-11-02)](12)

This image uses a function that creates rectangles full of scribbles
of varying densities to represent a sinusoidal field.

![project 12 -- sine wave](https://pbs.twimg.com/media/DrFxAoXV4AAW5Db.jpg)

### [13 (2018-11-05)](13)

I took a selfie and then used the scribble code from the last project
to plot it in black-and-white. There's an absolutely awful BMP reader
in here that does some of the heavy lifting.

![project 13 -- selfie](https://pbs.twimg.com/media/DrQYPOEU0AA8I6g.jpg)

### [14 (2018-11-06)](14)

I played around with some CMY (no K) drawing. I generated some random
paths through a grid and then drew different colored lines on each
path. The lines are offset a little bit to try to get some blending at
a distance without actually blending. The line separation turned out
to be less that required for plotting, so some of the lines are on top
of each other. The path generation was also a little disappointing. I
tried both paths that can cross themselves and paths that cannot cross
themselves, and neither one was completely satisfactory. I ended up
going with the non-crossing paths, but the result was that the final
paths were fairly short and each color path only overlapped slightly,
so there really wasn't much blending.

![project 14 -- CMY lines](https://pbs.twimg.com/media/DrWvit5UcAAWL76.jpg)

### [15 (2018-11-08)](15)

More CMY (no K) drawing. I wrote some code to draw a path and make
curves when the direction changed. The idea was to generate three
random paths that overlapped and make each of paths a different
color. The drawing works reasonably well, but the path generation
never made me really happ because the paths didn't overlap as much as
I wanted. I eventually settled on an image that looked OK, but if I
want to pursue this then the next challenge is finding a useful way to
generate the paths.

![project 15 -- more CMY lines](https://pbs.twimg.com/media/DrhCP5jU8AECx68.jpg)

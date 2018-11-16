use "collections"
use "random"
use "time"

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    // Draw some wiggles

    let wiggles = PathCommands

    wiggles.command(PathMove.abs(100, 100))

    for x in Range(0, 30) do
      wiggles.command(PathArc.abs(20, 20, 0, true, (x % 2) == 0, (x.f64() * 20) + 100, 100))
    end

    svg.c(SVG.path(wiggles))

    // Draw some squares

    let squares = PathCommands

    for x in Range[F64](0, 10) do
      squares.command(PathMove.abs((x * 60) + 100, 170))
      squares.command(PathLine.abs((x * 60) + 140 + x, 170))
      squares.command(PathLine.abs((x * 60) + 140 + x, 210 + x))
      squares.command(PathLine.abs((x * 60) + 100, 210 + x))
      squares.command(PathLine.abs((x * 60) + 100, 170))
    end

    svg.c(SVG.path(squares))

    // Draw a distorted grid

    let grid = PathCommands
    let w: USize = 10
    let h: USize = 3

    let g = Array[Array[(F64, F64)]]
    let rand = MT(Time.micros())

    for i in Range(0, w) do
      let r = Array[(F64, F64)]
      for j in Range(0, h) do
        r.push(((rand.real() * 0.5) - 0.25, (rand.real() * 0.5) - 0.25))
      end
      g.push(r)
    end

    let sx: F64 = 100
    let sy: F64 = 230
    let factor: F64 = 60

    for i in Range(0, w) do
      for j in Range(0, h) do
        try
          let xy = g(i)?(j)?
          let x = sx + ((i.f64() + xy._1) * factor)
          let y = sy + ((j.f64() + xy._2) * factor)
          if j == 0 then
            grid.command(PathMove.abs(x, y))
          else
            grid.command(PathLine.abs(x, y))
          end
        end
      end
    end

    for i in Range(0, h) do
      for j in Range(0, w) do
        try
          let xy = g(j)?(i)?
          let x = sx + ((j.f64() + xy._1) * factor)
          let y = sy + ((i.f64() + xy._2) * factor)
          if j == 0 then
            grid.command(PathMove.abs(x, y))
          else
            grid.command(PathLine.abs(x, y))
          end
        end
      end
    end

    svg.c(SVG.path(grid))

    env.out.print(svg.render())

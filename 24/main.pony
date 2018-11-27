use "collections"
use "random"

primitive FadeLine
  fun apply(sx: F64, sy: F64, ex: F64, ey: F64, sd: F64, ed: F64, rand: Random):
    PathCommands
  =>
    let x_len = ex - sx
    let y_len = ey - sy

    let steps = x_len.abs().max(y_len.abs())

    let x_step = x_len / steps
    let y_step = y_len / steps

    let pcs = PathCommands

    var drawing = false
    var last_x = sx
    var last_y = sy

    for s in Range[F64](0, steps + 1) do
      let thresh = (sd + ((s / steps) * (ed - sd)))
      let roll = rand.real()

      let draw = thresh > roll

      match (drawing, draw)
      | (false, false) =>
        None
      | (false, true) =>
        last_x = sx + (s * x_step)
        last_y = sy + (s * y_step)
        pcs.command(PathMove.abs(last_x, last_y))
      | (true, false) =>
        pcs.command(PathLine.abs(last_x, last_y))
      | (true, true) =>
        last_x = sx + (s * x_step)
        last_y = sy + (s * y_step)
      end
      drawing = draw
    end

    pcs

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    let rand = MT

    let black = PathCommands

    for i in Range[F64](0, 300, 2) do
      black.commands(FadeLine(i, 75, i, 210, 1, 0.6, rand))
    end

    let blue = PathCommands

    for i in Range[F64](0, 300, 5) do
      blue.command(PathMove.abs(i, 75))
      blue.command(PathLine.abs(i + 20, 20))
    end

    let pink = PathCommands

    for _ in Range[F64](0, 6) do
      let sx = (rand.real() * 75) + 6
      let sy = (rand.real() * 30) + 160
      let ex = sx + 30
      let ey: F64 = 10
      pink.command(PathMove.abs(sx, sy))
      pink.command(PathLine.abs(ex, sy))
      pink.command(PathLine.abs(sx, ey))
    end

    svg.c(SVG.path(black))
    svg.c(SVG.path(blue))
    svg.c(SVG.path(pink))

    env.out.print(svg.render())

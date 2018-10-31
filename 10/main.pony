use "collections"
use "random"

primitive HorizLinedRect
  fun apply(x: F64, y: F64, dx: F64, dy: F64, spacing: F64): PathCommands =>
    let pc = PathCommands

    for iy in Range[F64](y, y + dy + 0.01, spacing) do
      pc.command(PathMove.abs(x, iy))
      pc.command(PathLine.abs(x + dx, iy))
    end

    pc

primitive VertLinedRect
  fun apply(x: F64, y: F64, dx: F64, dy: F64, spacing: F64): PathCommands =>
    let pc = PathCommands

    for ix in Range[F64](x, x + dx + 0.01, spacing) do
      pc.command(PathMove.abs(ix, y))
      pc.command(PathLine.abs(ix, y + dy))
    end

    pc

primitive Smudge
  fun apply(x: F64, y: F64, dx: F64, dy: F64, steps: USize, density_fn: {(F64): USize}, loc_fn: {ref (F64, F64): (F64, F64)}): Array[(F64, F64)] =>
    let x_step = dx / steps.f64()
    let y_step = dy / steps.f64()

    let points = Array[(F64, F64)]

    for i in Range[F64](0, steps.f64()) do
      let cur_x = x + (i * x_step)
      let cur_y = y + (i * y_step)
      let d = density_fn(cur_x)
      for _ in Range(0, d) do
        points.push(loc_fn(cur_x, cur_y))
      end
    end

    points

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    let pc: PathCommands ref = PathCommands

    pc.commands(HorizLinedRect(100, 100, 100, 100, 10))
    pc.commands(VertLinedRect(100, 100, 100, 100, 10))

    pc.commands(VertLinedRect(128, 128, 200, 100, 5))
    pc.commands(HorizLinedRect(128, 128, 200, 100, 5))

    svg.c(SVG.path(pc))

    let mt: MT ref = MT

    for p in Smudge(50, 50, 300, 100, 20, {(_: F64) => 3},
      {ref (x: F64, y: F64) => (x + ((mt.real() - 0.5) * 50), y + ((mt.real() - 0.5) * 10))}).values()
    do
      svg.c(SVG.circle(p._1, p._2, 5))
    end

    env.out.print(svg.render())

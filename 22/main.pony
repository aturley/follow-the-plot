use "collections"

primitive ShapeInCircle
  fun apply(r: F64, d: F64, sides: USize, rot: F64, xo: F64, yo: F64):
    (Array[(F64, F64, F64, F64)] | None)
  =>
    if d > r then
      return None
    end

    let xys = Array[(F64, F64, F64, F64)]

    let f_sides = sides.f64()
    let side_angle = (2 * F64.pi()) / f_sides
    let half_s_a = side_angle / 2

    for beta in Range[F64](0, 2 * F64.pi(), side_angle) do
      if d < (half_s_a.cos() * r) then
        let x1 = (rot + beta + half_s_a).cos() * (d / half_s_a.cos())
        let y1 = (rot + beta + half_s_a).sin() * (d / half_s_a.cos())
        let x2 = ((rot + beta) - half_s_a).cos() * (d / half_s_a.cos())
        let y2 = ((rot + beta) - half_s_a).sin() * (d / half_s_a.cos())
        xys.push((x1 + xo, y1 + yo, x2 + xo, y2 + yo))
      else
        let a = (d / r).acos()
        let x1 = r * (beta + a + rot).cos()
        let y1 = r * (beta + a + rot).sin()
        let x2 = r * ((beta - a) + rot).cos()
        let y2 = r * ((beta - a) + rot).sin()
        xys.push((x1 + xo, y1 + yo, x2 + xo, y2 + yo))
      end
    end

    xys

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    let pcs = PathCommands

    for d in Range[F64](10, 100, 3) do
      match ShapeInCircle(100, d, 3, 40, 200, 200)
      | let xys: Array[(F64, F64, F64, F64)] =>
        for (x1, y1, x2, y2) in xys.values() do
          pcs
            .>command(PathMove.abs(x1, y1))
            .>command(PathLine.abs(x2, y2))
        end
      end
    end

    svg.c(SVG.path(pcs))

    let shade = PathCommands

    for x in Range[F64](150, 200, 2) do
      shade
        .>command(PathMove.abs(150, x))
        .>command(PathLine.abs(400, x))
    end

    svg.c(SVG.path(shade))

    env.out.print(svg.render())

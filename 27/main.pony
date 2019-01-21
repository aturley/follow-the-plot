use "collections"
use "random"

primitive Square
  fun apply(cx: F64, cy: F64, sz: F64): PathCommands =>
    let left = cx - (sz / 2)
    let right = cx + (sz / 2)
    let top = cy - (sz / 2)
    let bottom = cy + (sz / 2)

    PathCommands
      .>command(PathMove.abs(top, left))
      .>command(PathLine.abs(top, right))
      .>command(PathLine.abs(bottom, right))
      .>command(PathLine.abs(bottom, left))
      .>command(PathLine.abs(top, left))

actor Main
  new create(env: Env) =>
    let rand = Rand

    let svg = SVG.svg()

    let pcs = PathCommands

    for x in Range[F64](0, 10) do
      for y in Range[F64](0, 10) do
        for z in Range[F64](1, 21, 2) do
          if rand.real() > 0.4 then
            pcs.commands(Square(50 + (x * 40), 50 + (y * 40), z))
          end
        end
      end
    end

    svg.c(SVG.path(pcs))

    env.out.print(svg.render())

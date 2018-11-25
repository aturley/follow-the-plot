use "collections"
use "random"

primitive ArcByRadius
  fun apply(r: F64, cx: F64, cy: F64, sweep: F64, rot: F64):
    PathCommands
  =>
    """
    Draw part of a circle starting at the 3 o'clock position and moving
    clockwise. `sweep` and `rot` are in radians, rot is clockwise relative
    to the 3 o'clock position.
    """
    let sx = cx + (r * rot.cos())
    let sy = cy + (r * rot.sin())

    let ex = cx + (r * (rot + sweep).cos())
    let ey = cy + (r * (rot + sweep).sin())

    PathCommands
      .>command(PathMove.abs(sx, sy))
      .>command(PathArc.abs(r, r, 0, false, sweep > 0, ex, ey))

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    let arc = PathCommands

    let rand = MT

    for r in Range[F64](20, 101, 20) do
      let sweep = (F64.pi() * (5 + rand.real())) / -6
      arc.commands(ArcByRadius(r, 100, 100, sweep, (3 * F64.pi()) / 2))
    end

    for r in Range[F64](10, 101, 10) do
      let sweep = (F64.pi() * (5 + rand.real())) / -6
      arc.commands(ArcByRadius(r, 220, 100, sweep, (3 * F64.pi()) / 2))
    end

    for r in Range[F64](5, 101, 5) do
      let sweep = (F64.pi() * (5 + rand.real())) / -6
      arc.commands(ArcByRadius(r, 340, 100, sweep, (3 * F64.pi()) / 2))
    end

    svg.c(SVG.path(arc))
    env.out.print(svg.render())

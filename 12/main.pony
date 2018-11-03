use "collections"
use "random"
use "time"

primitive ScribbleRect
  fun apply(x: F64, y: F64, cx: F64, cy: F64, step_limit: F64, slack: F64, random: Random = MT):
    PathCommands
  =>
    var cur_y = y + (random.real() * step_limit)

    var side: U64 = 0

    let pcs: PathCommands ref = PathCommands.>command(PathMove.abs(x, y))

    while (cur_y < (y + cy)) do
      let cur_x = if side == 0 then
        side = 1
        x + (cx - (random.real() * slack))
      else
        side = 0
        x + (random.real() * slack)
      end

      pcs.command(PathLine.abs(cur_x, cur_y))

      cur_y = cur_y + (random.real() * step_limit)
    end

    pcs

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()
    let random = MT(Time.micros())
    let pcs: PathCommands ref = PathCommands
    for x in Range[F64](0, 1000, 10) do
      pcs.commands(ScribbleRect(x, 0, 20, 200, 36 - (((3.14 * (x / 250)).sin() + 1) * 15), 3, random))
    end
    svg.c(SVG.path(pcs))
    env.out.print(svg.render())

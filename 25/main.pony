use "collections"
use "random"
use "time"

primitive Tree
  fun apply(root_x: F64, root_y: F64, height: F64, leaves_width: F64,
    leaves_height: F64): PathCommands
  =>
    let pcs = PathCommands

    pcs
      .>command(PathMove.abs(root_x, root_y))
      .>command(PathLine.abs(root_x, root_y - height))
      .>command(PathLine.abs(root_x + leaves_width, root_y - height))
      .>command(PathLine.abs(root_x + leaves_width, (root_y - height) + leaves_height))
      .>command(PathLine.abs(root_x, (root_y - height) + leaves_height))

primitive GenTrees
  fun apply(x: F64, rand: Random): PathCommands =>
    let root_x = x
    let root_y = (rand.real() * 130) + 60
    let height: F64 = 60
    let l_width: F64 = 20
    let l_height: F64 = 20
    Tree(root_x, root_y, height, l_width, l_height)

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    let rand = MT(Time.micros())

    let black = PathCommands
    let green = PathCommands
    let red = PathCommands

    let gloc = rand.real() * 280
    let rloc = rand.real() * 280

    for x in Range[F64](20, 280, 40) do
      let c = if (gloc - x).abs() < 20 then
        green
      elseif (rloc - x).abs() < 20 then
        red
      else
        black
      end
      let x' = x + (8 * rand.real())
      c.commands(GenTrees(x', rand))
    end

    svg.c(SVG.path(black))

    svg.c(SVG.path(green))

    svg.c(SVG.path(red))

    env.out.print(svg.render())

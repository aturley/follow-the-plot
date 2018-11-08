use "collections"
use "itertools"
use "random"
use "time"

primitive Clockwise
  fun string(): String iso^ =>
    "cw".clone()

primitive CounterClockwise
  fun string(): String iso^ =>
    "ccw".clone()

primitive Straight
  fun string(): String iso^ =>
    "s".clone()

type Step is (Clockwise | CounterClockwise | Straight)

primitive Left
  fun rotate(twist: Step): Direction =>
    match twist
    | Clockwise => Up
    | CounterClockwise => Down
    | Straight => Left
    end

  fun delta(): (ISize, ISize) =>
    (-1, 0)

  fun string(): String iso^ =>
    "left".clone()

primitive Right
  fun rotate(twist: Step): Direction =>
    match twist
    | Clockwise => Down
    | CounterClockwise => Up
    | Straight => Right
    end

  fun delta(): (ISize, ISize) =>
    (1, 0)

  fun string(): String iso^ =>
    "right".clone()

primitive Up
  fun rotate(twist: Step): Direction =>
    match twist
    | Clockwise => Right
    | CounterClockwise => Left
    | Straight => Up
    end

  fun delta(): (ISize, ISize) =>
    (0, -1)

  fun string(): String iso^ =>
    "up".clone()

primitive Down
  fun rotate(twist: Step): Direction =>
    match twist
    | Clockwise => Left
    | CounterClockwise => Right
    | Straight => Down
    end

  fun delta(): (ISize, ISize) =>
    (0, 1)

  fun string(): String iso^ =>
    "up".clone()

type Direction is (Left | Right | Up | Down)

primitive DrawStep
  fun apply(old_dir: Direction, new_dir: Direction, x: F64, y: F64,
    dx: F64, dy: F64, offsets: Array[F64]): PathCommands
  =>
    let pcs = PathCommands
    match (old_dir, new_dir)
    | (Up, Up) =>
      for o in offsets.values() do
        pcs
          .>command(PathMove.abs(x + o, y + dx))
          .>command(PathLine.abs(x + o, y))
      end
    | (Down, Down) =>
      for o in offsets.values() do
        pcs
          .>command(PathMove.abs((x + dx) - o, y))
          .>command(PathLine.abs((x + dx) - o, y + dy))
      end
    | (Left, Left) =>
      for o in offsets.values() do
        pcs
          .>command(PathMove.abs(x + dx, (y + dx) - o))
          .>command(PathLine.abs(x, (y + dx) - o))
      end
    | (Right, Right) =>
      for o in offsets.values() do
        pcs
          .>command(PathMove.abs(x, y + o))
          .>command(PathLine.abs(x + dx, y + o))
      end
    | (Up, Right) =>
      for o in offsets.values() do
        pcs
          .>command(PathMove.abs(x + o, y + dx))
          .>command(PathArc.abs(dx - o, dy - o, 0, false, true,  x + dx, y + o))
      end
    | (Right, Up) =>
      for o in offsets.values() do
        pcs
          .>command(PathMove.abs(x, y + o))
          .>command(PathArc.abs(o, o, 0, false, false, x + o, y))
      end
    | (Down, Right) =>
      for o in offsets.values() do
        pcs
          .>command(PathMove.abs((x + dx) - o, y))
          .>command(PathArc.abs(o, o, 0, false, false,  x + dx, y + o))
      end
    | (Right, Down) =>
      for o in offsets.values() do
        pcs
          .>command(PathMove.abs(x, y + o))
          .>command(PathArc.abs(dx - o, dy - o, 0, false, true,  (x + dx) - o, y + dy))
      end
    | (Up, Left) =>
      for o in offsets.values() do
        pcs
          .>command(PathMove.abs(x + o, y + dx))
          .>command(PathArc.abs(o, o, 0, false, false,  x, (y + dx) - o))
      end
    | (Left, Up) =>
      for o in offsets.values() do
        pcs
          .>command(PathMove.abs(x + dx, (y + dx) - o))
          .>command(PathArc.abs(dx - o, dy - o, 0, false, true, x + o, y))
      end
    | (Down, Left) =>
      for o in offsets.values() do
        pcs
          .>command(PathMove.abs((x + dx) - o, y))
          .>command(PathArc.abs(dx - o, dx - o, 0, false, true,  x, (y + dx) - o))
      end
    | (Left, Down) =>
      for o in offsets.values() do
        pcs
          .>command(PathMove.abs(x + dx, (y + dx) - o))
          .>command(PathArc.abs(o, o, 0, false, false,  (x + dx) - o, y + dy))
      end

    end

    pcs

primitive DrawSteps
  fun apply(steps: Array[Step], sx: F64, sy: F64, factor: F64,
    offsets: Array[F64]): PathCommands
  =>
    var last_dir: Direction = Up

    let pcs = PathCommands

    var cx = sx
    var cy = sy

    let scaled_offsets = Iter[F64](offsets.values())
      .map[F64]({(x) => x * factor})
      .collect(Array[F64])

    // pcs.command(PathMove.abs(cx * factor, cy * factor))

    for step in steps.values() do
      let dir = last_dir.rotate(step)
      let delta = dir.delta()
      pcs.commands(DrawStep(last_dir, dir, cx * factor, cy * factor,
        factor, factor, scaled_offsets))
      cx = cx + delta._1.f64()
      cy = cy + delta._2.f64()
      last_dir = dir
    end

    pcs

primitive LaySteps
  fun apply(num_steps: USize, cw: F64, ccw: F64,
    random: Random): Array[Step]
  =>
    let steps = Array[Step]
    for _ in Range(0, num_steps) do
      let r = random.real()
      steps.push(if r < cw then
        Clockwise
      elseif r < ccw then
        CounterClockwise
      else
        Straight
      end)
    end

    steps

actor Main
  new create(env: Env) =>
    let random = MT(Time.micros())

    let svg = SVG.svg()

    for i in Range[F64](0, 3) do
      let steps = LaySteps(100, 0.4, 0.6, random)
      svg.c(SVG.path(DrawSteps(steps, 15 + i, 15 + i, 20, [0.4; 0.5; 0.6])))
    end

    env.out.print(svg.render())

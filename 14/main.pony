use "collections"
use "debug"
use "itertools"
use "random"
use "time"

class Grid
  let _grid: Array[Bool]
  let _x: USize
  let _y: USize

  new create(x: USize, y: USize) =>
    _grid = Array[Bool].init(false, x * y)
    _x = x
    _y = y

  fun valid(x: USize, y: USize): Bool =>
    (x >= 0) and (x < _x) and (y >= 0) and (y < _y)

  fun ref neighbors(x: USize, y: USize): Iter[(USize, USize)] =>
    Iter[(USize, USize)]([as (USize, USize): (-1, 0); (1, 0); (0, 1); (0, -1)].values())
      .map[(USize, USize)]({(dxdy) =>
        (x + dxdy._1, y + dxdy._2)})
      .filter({(xy: (USize, USize))(t = this) =>
        t.valid(xy._1, xy._2)})

  fun ref clear_neighbors(x: USize, y: USize): Array[(USize, USize)] =>
    neighbors(x, y).filter({(xy: (USize, USize)) ? =>
      _grid(xy._1 + (xy._2 * _x))? == false}).collect(Array[(USize, USize)])

  fun ref mark(x: USize, y: USize) ? =>
    _grid(x + (y * _x))? = true

primitive BounceAround
  fun apply(x: USize, y: USize, sx: USize, sy: USize, random: Random):
    Array[(USize, USize)] ?
  =>
    let path = Array[(USize, USize)]
    let grid = Grid(x, y)
    var cx = sx
    var cy = sy

    grid.mark(cx, cy)?

    while grid.clear_neighbors(cx, cy).size() > 0 do
      let cn = grid.clear_neighbors(cx, cy)
      (cx, cy) = cn(random.int(cn.size().u64()).usize())?
      grid.mark(cx, cy)?
      path.push((cx, cy))
    end
    path

primitive DrawStep
  fun apply(x: USize, y: USize, factor: F64, offset: F64): PathCommand =>
    PathLine.abs((x.f64() + 0.5 + offset) * factor, (y.f64() + 0.5 + offset) * factor)

primitive DrawSteps
  fun apply(steps: Array[(USize, USize)], offsets: Array[F64],
    start: (F64, F64), factor: F64): PathCommands
  =>
    let pcs = PathCommands

    for o in offsets.values() do

      pcs.command(PathMove.abs((0.5 + o) * factor, (0.5 + o) * factor))

      for p in steps.values() do
        pcs.command(DrawStep(p._1, p._2, factor, o))
      end
    end

    pcs

actor Main
  new create(env: Env) =>
    let random = MT(Time.micros())

    let svg = SVG.svg()

    try
      svg.c(SVG.path(DrawSteps(BounceAround(15, 9, 0, 0, random)?, [0.20; 0.10; 0; -0.10; -0.20], (0, 0), 20)))
      svg.c(SVG.path(DrawSteps(BounceAround(15, 9, 0, 0, random)?, [0.22; 0.12; 0; -0.12; -0.22], (0, 0), 20)))
      svg.c(SVG.path(DrawSteps(BounceAround(15, 9, 0, 0, random)?, [0.24; 0.14; 0; -0.14; -0.24], (0, 0), 20)))
    end

    env.out.print(svg.render())

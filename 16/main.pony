use "collections"
use "itertools"
use "random"
use "time"

class Grid
  let _grid: Array[Array[((F64, F64) | None)]]
  let _x: USize
  let _y: USize

  new create(x: USize, y: USize) =>
    _grid = _grid.create()
    _x = x
    _y = y
    for i in Range(0, x) do
      _grid.push(Array[((F64, F64) | None)].init(None, y))
    end

  fun dim(): (USize, USize) =>
    (_x, _y)

  fun ref update(x: USize, y: USize, value: ((F64, F64) | None)) ? =>
    _grid(x)?(y)? = value

  fun apply(x: USize, y: USize): ((F64, F64) | None) ? =>
    _grid(x)?(y)?

  fun neighbors(x: USize, y: USize): Array[(USize, USize)] =>
    Iter[(ISize, ISize)]([(0, 1); (1, 0); (0, -1); (-1, 0)].values())
      .map[(ISize, ISize)]({(dxdy)
        => (x.isize() + dxdy._1, y.isize() + dxdy._2)})
      .filter({(xy) =>
        (xy._1 >= 0) and (xy._2 < _x.isize()) and
          (xy._2 >= 0) and (xy._2 < _y.isize())})
      .map[(USize, USize)]({(xy)
        => (xy._1.usize(), xy._2.usize())})
      .collect(Array[(USize, USize)])

primitive Circle
  fun apply(): PathCommands =>

    let random = MT(Time.micros())

    let x: USize = 61
    let y: USize = 61
    let factor: F64 = 10
    let offset: F64 = 100

    let r: F64 = 30

    let grid = Grid(x, y)

    for i in Range(0, x) do
      for j in Range(0, y) do
        try
          let ni = (r - i.f64()).abs()
          let nj = (r - j.f64()).abs()
          let rad = ni.pow(2) + nj.pow(2)
          if (rad < r.pow(2)) and (rad > (r.pow(2) * 0.5)) and ((i % 3) > 0) then
            grid(i, j)? = (i.f64() + (random.real() * 0.7), j.f64() + (random.real() * 0.7))
          else
            grid(i, j)? = None
          end
        end
      end
    end

    let pcs = PathCommands

    for i in Range(0, x) do
      for j in Range(0, y) do
        try
          match grid(i, j)?
          | (let cx: F64, let cy: F64) =>
            let cur = (cx, cy)
            for n in grid.neighbors(i, j).values() do
              try
                match grid(n._1, n._2)?
                | (let nex: F64, let ney: F64) =>
                  let ne = (nex, ney)
                  pcs.>command(PathMove.abs((cur._1 * factor) + offset, (cur._2 * factor) + offset))
                    .>command(PathLine.abs((ne._1 * factor) + offset, (ne._2 * factor) + offset))
                end
              end
            end
          end
        end
      end
    end
    pcs

primitive Lines
  fun apply(): PathCommands =>
    let x: USize = 62
    let y: USize = 61
    let factor: F64 = 10
    let offset: F64 = 100

    let grid = Grid(x, y)

    for i in Range(0, x) do
      for j in Range(0, y) do
        try
          if (i % 3) == 0 then
            grid(i, j)? = (i.f64(), j.f64())
            grid(i + 1, j)? = (i.f64() + 1, j.f64())
          end
        end
      end
    end

    let pcs = PathCommands

    for i in Range(0, x) do
      for j in Range(0, y) do
        try
          match grid(i, j)?
          | (let cx: F64, let cy: F64) =>
            let cur = (cx, cy)
            for n in grid.neighbors(i, j).values() do
              try
                match grid(n._1, n._2)?
                | (let nex: F64, let ney: F64) =>
                  let ne = (nex, ney)
                  pcs.>command(PathMove.abs((cur._1 * factor) + offset, (cur._2 * factor) + offset))
                    .>command(PathLine.abs((ne._1 * factor) + offset, (ne._2 * factor) + offset))
                end
              end
            end
          end
        end
      end
    end
    pcs

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    svg.c(SVG.path(Circle()))
    svg.c(SVG.path(Lines()))

    env.out.print(svg.render())

use "collections"
use "random"
use "time"

class val CoordToLin
  let _width: USize
  let _height: USize

  new val create(w: USize, h: USize) =>
    _width = w
    _height = h

  fun apply(x: USize, y: USize): USize =>
    (x * _width) + y

actor Main
  new create(env: Env) =>
    let width: USize = 50
    let height: USize = 30
    let factor: F64 = 20

    let offsets = Map[USize, (F64, F64)]

    let ctl = CoordToLin(width, height)

    let rand = MT(Time.micros())
    let perlin_x = Perlin(100, 100, rand)
    let perlin_y = Perlin(100, 100, rand)

    for i in Range(0, width) do
      let x = ((i.f64() / width.f64()) * 8.109) + 0.05
      for j in Range(0, height) do
        let y = ((j.f64() / height.f64()) * 8.109) + 0.05
        offsets(ctl(i, j)) = try
          let px = perlin_x(x, y)?
          let py = perlin_y(x, y)?
          (px, py)
        else
          // If (x, y) is outside of the perlin range then just punt.
          (0, 0)
        end
      end
    end

    let x_start: F64 = 100
    let y_start: F64 = 100

    let pcs = PathCommands

    for i in Range(0, width) do
      for j in Range(0, height) do
        try
          (let dx, let dy) = offsets(ctl(i, j))?
          let x = (i.f64() * factor) + (dx * factor * 2) + x_start
          let y = (j.f64() * factor) + (dy * factor * 2) + y_start
          if j == 0 then
            pcs.command(PathMove.abs(x, y))
          else
            pcs.command(PathLine.abs(x, y))
          end
        end
      end
    end

    for i in Range(0, height) do
      for j in Range(0, width) do
        try
          (let dx, let dy) = offsets(ctl(j, i))?
          let x = (j.f64() * factor) + (dx * factor * 2) + x_start
          let y = (i.f64() * factor) + (dy * factor * 2) + y_start
          if j == 0 then
            pcs.command(PathMove.abs(x, y))
          else
            pcs.command(PathLine.abs(x, y))
          end
        end
      end
    end

    let svg = SVG.svg()
    svg.c(SVG.path(pcs))

    env.out.print(svg.render())

use "collections"
use "random"
use "time"

primitive DistortedGrid
  fun apply(rand: Random): PathCommands =>
    let grid = PathCommands
    let w: USize = 24
    let h: USize = 14

    let g = Array[Array[(F64, F64)]]

    let perlin_x = Perlin(100, 100, rand)
    let perlin_y = Perlin(100, 100, rand)

    for i in Range(0, w) do
      let r = Array[(F64, F64)]
      let x = ((i.f64() / w.f64()) * 8.109) + 0.05
      for j in Range(0, h) do
        let y = ((j.f64() / h.f64()) * 8.109) + 0.05
        try
          let px = (perlin_x(x, y)?
            + perlin_x(x / 3, y / 3)?
            + perlin_x(x / 7, y / 7)?
            + perlin_x(x / 11, y / 11)?
            + perlin_x(x / 17, y / 17)?).atan()
          let py = (perlin_y(x, y)?
            + perlin_y(x / 3, y / 3)?
            + perlin_y(x / 7, y / 7)?
            + perlin_y(x / 11, y / 11)?
            + perlin_y(x / 17, y / 17)?).atan()
          r.push((px, py))
        end
      end
      g.push(r)
    end

    let sx: F64 = 100
    let sy: F64 = 230
    let factor: F64 = 30
    let offset: F64 = 5

    for i in Range(0, w - 1) do
      for j in Range(0, h - 1) do
        try
          for (q, (ii, jj, ox, oy)) in [(i, j, offset, offset)
                                        (i + 1, j, -offset, offset)
                                        (i + 1, j + 1, -offset, -offset)
                                        (i, j + 1, offset, -offset)
                                        (i, j, offset, offset)]. pairs()
          do
            let xy = g(ii)?(jj)?
            let x = sx + ox + ((ii.f64() + xy._1) * factor)
            let y = sy + oy + ((jj.f64() + xy._2) * factor)
            if q == 0 then
              grid.command(PathMove.abs(x, y))
            else
              grid.command(PathLine.abs(x, y))
            end
          end
        end
      end
    end

    grid

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()
    let rand = MT(Time.micros())

    svg.c(SVG.path(DistortedGrid(rand)))

    env.out.print(svg.render())

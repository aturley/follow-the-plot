use "collections"
use "itertools"
use "random"
use "time"

primitive Pinwheel
  fun apply(cx: F64, cy: F64, r: F64, steps: USize): PathCommands =>
    let steps': F64 = steps.f64()
    let step_size: F64 = (2 * F64.pi()) / steps'
    let half_step_size: F64 = step_size / 2

    Iter[F64](Range[F64](0, (2 * F64.pi()), step_size)).map[PathCommands](
      {(i) =>
        PathCommands
          .>command(PathMove.abs(cx, cy))
          .>command(PathLine.abs(cx + (i.sin() * r), cy + (i.cos() * r)))
          .>command(PathLine.abs(cx + ((i + half_step_size).sin() * r),
            cy + ((i + half_step_size).cos() * r)))
          .>command(PathLine.abs(cx, cy))
    }).fold[PathCommands](PathCommands, {(acc, pcs) => acc.>commands(pcs)})

primitive WaveBlock
  fun apply(x: F64, y: F64, dx: F64, dy: F64, variation: {(F64, F64): F64},
    waves: USize, wave_steps: USize, random: Random = MT): PathCommands
  =>
    let wave_sep = dy / waves.f64()
    let wave_step_size = dx / wave_steps.f64()

    let pc: PathCommands ref = PathCommands.>command(PathMove.abs(x, y))

    pc.>commands(Iter[F64](Range[F64](y, y + dy, wave_sep))
      .map_stateful[Iter[(F64, F64)]](
        {ref (i)(variation, random, x) =>
          Iter[F64](Range[F64](x, x + dx, wave_step_size))
            .map_stateful[(F64, F64)](
              {ref (j)(variation, random) =>
                (j, i + (variation(j, i) * (random.real() - 0.5)))})})
      .fold[PathCommands](PathCommands,
        {(acc, xys) =>
          let pc: PathCommands ref = try
            let xy = xys.next()?
            PathCommands.>command(PathMove.abs(xy._1, xy._2))
          else
            PathCommands
          end
          acc.>commands(xys.fold[PathCommands](pc,
            {(acc, xy) => acc.>command(PathLine.abs(xy._1, xy._2))}))}))

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()
    let random = MT(Time.micros())

    env.out.print(svg
      .>c(SVG.path(Pinwheel(50, 50, 40, 20)))
      .>c(SVG.path(WaveBlock(10, 10, 500, 200,
        {(x, y) => ((x - 10) * (y - 10)) / 1000},
        40, 40, random)))
      .render())

use "buffered"
use "collections"
use "files"
use "random"
use "time"

class val ReadFileError
  let _message: String

  new val create(message: String) =>
    _message = message

  fun string(): String iso^ =>
    _message.clone()

primitive ReadFile
  fun apply(file_name: String, auth: AmbientAuth): (Array[U8] val | ReadFileError) =>
    let path = try
      FilePath(auth, file_name)?
    else
      return ReadFileError("Could not open '" + file_name + "'")
    end

    match OpenFile(path)
    | let file: File =>
      file.read(file.size())
    else
      ReadFileError("Error reading '" + file_name + "'")
    end

primitive WithPolarLines
  fun apply(intensity: Array[Array[F64]], pol_x: F64, pol_y: F64, a_start: F64, a_end: F64, a_step: F64, cutoff: F64, os: OutStream): PathCommands =>
    let lines = PathCommands
    try
      let w = intensity.size()
      let h = intensity(0)?.size()

      for a in Range[F64](a_start, a_end + (a_step / 10), a_step) do
        let x_dim = a.cos()
        let y_dim = a.sin()
        let max_dim = x_dim.abs().max(y_dim.abs())

        let step_size_w = x_dim / max_dim
        let step_size_h = y_dim / max_dim

        var cur_x: F64 = pol_x
        var cur_y: F64 = pol_y
        var start_x: F64 = pol_x
        var start_y: F64 = pol_y
        var last_x: F64 = pol_x
        var last_y: F64 = pol_y

        var s: F64 = 0
        var drawing = false

        while (cur_x >= 0) and (cur_x < w.f64()) and (cur_y >= 0) and (cur_y < h.f64()) do
          if drawing then
            try
              if intensity(cur_x.usize())?(cur_y.usize())? > cutoff then
                if (start_x != last_x) and (start_y != last_y) then
                  lines
                    .>command(PathMove.abs(start_x, start_y))
                    .>command(PathLine.abs(last_x, last_y))
                end
                drawing = false
              else
                last_x = cur_x
                last_y = cur_y
              end
            else
              os.print("ERROR")
              error
            end
          else
            try
              if intensity(cur_x.usize())?(cur_y.usize())? <= cutoff then
                start_x = cur_x
                start_y = cur_y
                last_x = cur_y
                last_y = cur_y
                drawing = true
              end
            else
              os.print("ERROR")
              error
            end
          end

          cur_x = cur_x + step_size_w
          cur_y = cur_y + step_size_h
        end
      end
    end

    lines

actor Main
  new create(env: Env) =>

  let file_name = try
    env.args(1)?
  else
    env.err.print("first argument must be a file name")
    return
  end

  let auth = try
    env.root as AmbientAuth
  else
    env.err.print("Could not get ambient authority")
    return
  end

  let bmp_data = match ReadFile(file_name, auth)
  | let data: Array[U8] val =>
    data
  | let e: ReadFileError =>
    env.err.print(e.string())
    return
  end

  let bm = try
    Bitmap.read_from(bmp_data)?
  else
    env.err.print("Error reading bitmap file")
    return
  end

  let intensity = bm.intensity()

  let svg = SVG.svg()

  let w = intensity.size().f64()
  let h = try intensity(0)?.size().f64() else 0 end

  let a_step: F64 = 0.03

  let pcs = PathCommands

  for pl in [
    WithPolarLines(intensity, 0, h / 2, 0, F64.pi() * 2, a_step, 0.3, env.err)
    WithPolarLines(intensity, w - 1, h / 2, 0, F64.pi() * 2, a_step, 0.3, env.err)
    WithPolarLines(intensity, w / 2, h / 2, 0, F64.pi() * 2, a_step, 0.5, env.err)
  ].values() do
    pcs.commands(pl)
  end

  svg.c(SVG.path(pcs))


  env.out.print(svg.render())

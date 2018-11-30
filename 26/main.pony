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

  let pcs = PathCommands

  let factor: F64 = 5

  for i in Range[F64](0, w - 1) do
    for j in Range[F64](0, h - 1) do
      let offset' = try intensity(i.usize())?(j.usize())? else 0 end
      let offset = offset' * offset'
      pcs
        .>command(PathMove.abs((i + offset) * factor, (j + offset)* factor))
        .>command(PathLine.abs(((i + 1) - offset) * factor, (j + offset) * factor))
        .>command(PathLine.abs(((i + 1) - offset) * factor, ((j + 1) - offset) * factor))
        .>command(PathLine.abs((i + offset) * factor, ((j + 1) - offset) * factor))
        .>command(PathLine.abs((i + offset) * factor, (j + offset) * factor))
    end
  end

  svg.c(SVG.path(pcs))

  env.out.print(svg.render())

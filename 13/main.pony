use "buffered"
use "collections"
use "files"
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

class val ReadFileError
  let _message: String

  new val create(message: String) =>
    _message = message

  fun string(): String iso^ =>
    _message.clone()

class val RGB
  let _r: U64
  let _g: U64
  let _b: U64

  new val create(r: U64, g: U64, b: U64) =>
    _r = r
    _g = g
    _b = b

  fun value(): (U64, U64, U64) =>
    (_r, _g, _b)

class Bitmap
  let _pix_array_offset: USize
  let _width: USize
  let _height: USize
  let _row_size: USize
  let _row_padding: USize

  let _pixels: Array[RGB]

  new read_from(bmp_data: Array[U8] val) ? =>
    let reader: Reader = Reader.>append(bmp_data)
    reader.skip(10)? // read to pix array offset
    _pix_array_offset = reader.u32_le()?.usize()

    reader.skip(4)?
    _width = reader.u32_le()?.usize()
    _height = reader.u32_le()?.usize()

    _pixels = Array[RGB]

    _row_size = (((3 * _width) + 3) / 4) * 4
    _row_padding = _row_size - (3 * _width)

    reader.clear()

    reader.append(bmp_data)
    reader.skip(_pix_array_offset)?

    for _ in Range(0, _height) do
      for _ in Range(0, _width) do
        let b = reader.u8()?.u64()
        let g = reader.u8()?.u64()
        let r = reader.u8()?.u64()
        _pixels.push(RGB(r, g, b))
      end
      reader.skip(_row_padding)?
    end

  fun string(): String iso^ =>
    " ".join([
      "h=" + _height.string()
      "w=" + _width.string()
      "rs=" + _row_size.string()
      ].values())

  fun bw_image(): String =>
    let rows = Array[String ref]
    for h in Range(0, _height) do
      let s = String
      for w in Range(0, _width) do
        let p = try _pixels(((_height - h - 1) *  _width) + w)?.value() else (0, 0, 0) end
        s.append(if ((0.3 * p._1.f64()) + (0.59 * p._2.f64()) + (0.11 * p._3.f64())) > 0x80 then
          " "
        else
          "X"
        end)
      end
      rows.push(s)
    end
    "\n".join(rows.values())

  fun intensity(): Array[Array[F64]] =>
    let rows = Array[Array[F64]]
    for h in Range(0, _height) do
      let s = Array[F64]
      for w in Range(0, _width) do
        let p = try _pixels(((_height - h - 1) *  _width) + w)?.value() else (0, 0, 0) end
        let i = ((0.3 * p._1.f64()) + (0.59 * p._2.f64()) + (0.11 * p._3.f64())) / 0xFF
        s.push(i)
      end
      rows.push(s)
    end
    rows

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

  // env.out.print(bm.bw_image())

  let intensity = bm.intensity()

  let svg = SVG.svg()

  let random = MT(Time.micros())

  let pcs: PathCommands ref = PathCommands

  for (i, row) in intensity.pairs() do
    for (j, ip) in row.pairs() do
      pcs.commands(ScribbleRect((j * 10).f64(), (i * 10).f64(), 10, 10, ((ip * ip * 16)) + 1, 2, random))
    end
  end

  svg.c(SVG.path(pcs))

  env.out.print(svg.render())

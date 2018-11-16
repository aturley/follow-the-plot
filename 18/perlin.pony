use "collections"
use "random"

primitive Random2Pi
  fun apply(random: Random = MT): F64 =>
    random.real() * F64.pi() * 2

primitive RandomVec
  fun apply(random: Random = MT): (F64, F64) =>
    let angle = Random2Pi(random)
    (angle.cos() * F64(2).sqrt(), angle.sin() * F64(2).sqrt())

class Perlin
  let _h: USize
  let _w: USize
  let _vectors: Array[Array[(F64, F64)]]

  new create(h: USize, w: USize, random: Random = MT) =>
    _h = h
    _w = w
    _vectors = Array[Array[(F64, F64)]]

    for i in Range(0, _h) do
      let vs = Array[(F64, F64)]
      for j in Range(0, _w) do
        vs.push(RandomVec(random))
      end
      _vectors.push(vs)
    end

  fun dist(x1: F64, y1: F64, x2: F64, y2: F64): (F64, F64) =>
    (x1 - x2, y1 - y2)

  fun dot(xy1: (F64, F64), xy2: (F64, F64)): F64 =>
    (xy1._1 * xy2._1) + (xy1._2 * xy2._2)

  fun lerp(a: F64, b: F64, frac: F64): F64 =>
    a + (frac * (b - a))

  fun apply(x: F64, y: F64): F64 ? =>
    let xl = x.floor()
    let xh = x.ceil()
    let yl = y.floor()
    let yh = y.ceil()

    let d1 = dist(x, y, xl, yl)
    let d2 = dist(x, y, xl, yh)
    let d3 = dist(x, y, xh, yl)
    let d4 = dist(x, y, xh, yh)

    let dot1 = dot(d1, _vectors(xl.usize())?(yl.usize())?)
    let dot2 = dot(d2, _vectors(xl.usize())?(yh.usize())?)
    let dot3 = dot(d3, _vectors(xh.usize())?(yl.usize())?)
    let dot4 = dot(d4, _vectors(xh.usize())?(yh.usize())?)

    let frac1 = x - xl
    let frac2 = y - yl

    lerp(lerp(dot1, dot3, frac1), lerp(dot2, dot4, frac1), frac2)

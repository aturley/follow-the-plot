use "collections"
use "itertools"

primitive SVG
  fun svg(): SVGNode =>
    SVGNode("svg").>a("version", "1.1")
      .>a("xmlns:xlink", "http://www.w3.org/1999/xlink")
      .>a("xmlns", "http://www.w3.org/2000/svg")

  fun circle(cx: F64, cy: F64, r: F64,
    stroke: String = "black", stroke_width: String = "1"): SVGNode
  =>
    SVGNode("circle")
      .>a("cx", cx.string())
      .>a("cy", cy.string())
      .>a("r", r.string())
      .>a("stroke", stroke)
      .>a("stroke-width", stroke_width)
      .>a("fill", "none")

  fun line(x1: F64, y1: F64, x2: F64, y2: F64,
    stroke: String = "black", stroke_width: String = "1"): SVGNode
  =>
    SVGNode("line")
      .>a("x1", x1.string())
      .>a("y1", y1.string())
      .>a("x2", x2.string())
      .>a("y2", y2.string())
      .>a("stroke", stroke)
      .>a("stroke-width", stroke_width)
      .>a("fill", "none")

  fun polyline(points: Iterator[(F64, F64)],
    stroke: String = "black", stroke_width: String = "1"): SVGNode
  =>
    let points_value: String = " ".join(Iter[(F64, F64)](points).map[String](
      {(p): String => p._1.string() + "," + p._2.string()}))
    SVGNode("polyline")
      .>a("points", points_value)
      .>a("stroke", stroke)
      .>a("stroke-width", stroke_width)
      .>a("fill", "none")

  fun polygon(points: Iterator[(F64, F64)],
    stroke: String = "black", stroke_width: String = "1"): SVGNode
  =>
    let points_value: String = " ".join(Iter[(F64, F64)](points).map[String](
      {(p): String => p._1.string() + "," + p._2.string()}))
    SVGNode("polygon")
      .>a("points", points_value)
      .>a("stroke", stroke)
      .>a("stroke-width", stroke_width)
      .>a("fill", "none")

  fun path(commands: PathCommands,
    stroke: String = "black", stroke_width: String = "1"): SVGNode
  =>
    SVGNode("path").>a("d", commands.render())
      .>a("stroke", stroke)
      .>a("stroke-width", stroke_width)
      .>a("fill", "none")

class SVGNode
  let svg_tag: String
  let attributes: SVGAttributes
  let children: SVGNodes

  new create(svg_tag': String) =>
    svg_tag = svg_tag'
    attributes = SVGAttributes
    children = SVGNodes

  fun render(): String =>
    "<" + svg_tag + " " + attributes.render() + ">" +
      children.render() +
      "</" + svg_tag + ">"

  fun ref a(attribute: String, value: String) =>
    attributes.add_attribute(attribute, value)

  fun ref c(node: SVGNode) =>
    children.add_child(node)

  fun ref cs(nodes: Iterator[SVGNode]) =>
    for n in nodes do
      children.add_child(n)
    end

class SVGAttributes
  let attributes: Array[(String, String)]

  new create() =>
    attributes = Array[(String, String)]

  fun ref add_attribute(attribute: String, value: String) =>
    attributes.push((attribute, value))

  fun render(): String =>
    " ".join(Iter[(String, String)](attributes.values())
      .map[String]({(x) => x._1 + "=" + "\"" + x._2 +"\""}))

class SVGNodes
  let children: Array[SVGNode]

  new create() =>
    children = Array[SVGNode]

  fun ref add_child(node: SVGNode) =>
    children.push(node)

  fun render(): String =>
    "".join(Iter[SVGNode box](children.values())
      .map[String]({(x) => x.render() }))


trait val PathCommand
  fun render(): String
  fun at(): (F64, F64) => (0, 0)
  fun test_at(xy: (F64, F64)): Bool => false

class val PathMove is PathCommand
  let _command: String
  let _x: F64
  let _y: F64

  new val abs(x: F64, y: F64) =>
    _command = "M"
    _x = x
    _y = y

  new val rel(x: F64, y: F64) =>
    _command = "m"
    _x = x
    _y = y

  fun at(): (F64, F64) =>
    (_x, _y)

  fun test_at(xy: (F64, F64)): Bool =>
    (_x == xy._1) and (_y == xy._2)

  fun render(): String =>
    _command + " " + _x.string() + " " + _y.string()

class val PathLine is PathCommand
  let _command: String
  let _x: F64
  let _y: F64

  new val abs(x: F64, y: F64) =>
    _command = "L"
    _x = x
    _y = y

  new val rel(x: F64, y: F64) =>
    _command = "l"
    _x = x
    _y = y

  fun at(): (F64, F64) =>
    (_x, _y)

  fun test_at(xy: (F64, F64)): Bool =>
    (_x == xy._1) and (_y == xy._2)

  fun render(): String =>
    _command + " " + _x.string() + " " + _y.string()

class val PathHorz is PathCommand
  let _command: String
  let _x: F64

  new val abs(x: F64) =>
    _command = "H"
    _x = x

  new val rel(x: F64, y: F64) =>
    _command = "h"
    _x = x

  fun render(): String =>
    _command + " " + _x.string()

class val PathVert is PathCommand
  let _command: String
  let _y: F64

  new val abs(y: F64) =>
    _command = "V"
    _y = y

  new val rel(y: F64) =>
    _command = "v"
    _y = y

  fun render(): String =>
    _command + " " + _y.string()

class val PathClose is PathCommand
  let _command: String

  new val create() =>
    _command = "Z"

  fun render(): String =>
    _command

class val PathBezCubic is PathCommand
  let _command: String
  let _x1: F64
  let _y1: F64
  let _x2: F64
  let _y2: F64
  let _x: F64
  let _y: F64

  new val abs(x1: F64, y1: F64, x2: F64, y2: F64, x: F64, y: F64) =>
    _command = "C"
    _x1 = x1
    _y1 = y1
    _x2 = x2
    _y2 = y2
    _x = x
    _y = y

  new val rel(x1: F64, y1: F64, x2: F64, y2: F64, x: F64, y: F64) =>
    _command = "c"
    _x1 = x1
    _y1 = y1
    _x2 = x2
    _y2 = y2
    _x = x
    _y = y

  fun at(): (F64, F64) =>
    (_x, _y)

  fun test_at(xy: (F64, F64)): Bool =>
    (_x == xy._1) and (_y == xy._2)

  fun render(): String =>
    "".join([_command
      " "
      _x1.string()
      ","
      _y1.string()
      " "
      _x2.string()
      ","
      _y2.string()
      " "
      _x.string()
      ","
      _y.string()].values())

class val PathBezCubicS is PathCommand
  let _command: String
  let _x2: F64
  let _y2: F64
  let _x: F64
  let _y: F64

  new val abs(x2: F64, y2: F64, x: F64, y: F64) =>
    _command = "S"
    _x2 = x2
    _y2 = y2
    _x = x
    _y = y

  new val rel(x2: F64, y2: F64, x: F64, y: F64) =>
    _command = "c"
    _x2 = x2
    _y2 = y2
    _x = x
    _y = y

  fun at(): (F64, F64) =>
    (_x, _y)

  fun test_at(xy: (F64, F64)): Bool =>
    (_x == xy._1) and (_y == xy._2)

  fun render(): String =>
    " ".join([_command
      _x2
      _y2
      _x
      _y].values())

class val PathBezQuad is PathCommand
  let _command: String
  let _x1: F64
  let _y1: F64
  let _x: F64
  let _y: F64

  new val abs(x1: F64, y1: F64, x: F64, y: F64) =>
    _command = "Q"
    _x1 = x1
    _y1 = y1
    _x = x
    _y = y

  new val rel(x1: F64, y1: F64, x: F64, y: F64) =>
    _command = "q"
    _x1 = x1
    _y1 = y1
    _x = x
    _y = y

  fun at(): (F64, F64) =>
    (_x, _y)

  fun test_at(xy: (F64, F64)): Bool =>
    (_x == xy._1) and (_y == xy._2)

  fun render(): String =>
    " ".join([_command
    _x1.string()
    _y1.string()
    _x.string()
    _y.string()].values())

class val PathBezQuadT is PathCommand
  let _command: String
  let _x: F64
  let _y: F64

  new val abs(x: F64, y: F64) =>
    _command = "T"
    _x = x
    _y = y

  new val rel(x: F64, y: F64) =>
    _command = "t"
    _x = x
    _y = y

  fun at(): (F64, F64) =>
    (_x, _y)

  fun test_at(xy: (F64, F64)): Bool =>
    (_x == xy._1) and (_y == xy._2)

  fun render(): String =>
    " ".join([_command
    _x.string()
    _y.string()].values())

class val PathArc is PathCommand
  let _command: String
  let _rx: F64
  let _ry: F64
  let _rot: F64
  let _large_arc: Bool
  let _sweep: Bool
  let _x: F64
  let _y: F64

  new val abs(rx: F64, ry: F64, rot: F64, large_arc: Bool, sweep: Bool, x: F64, y: F64) =>
    _command = "A"
    _rx = rx
    _ry = ry
    _rot = rot
    _large_arc = large_arc
    _sweep = sweep
    _x = x
    _y = y

  new val rel(rx: F64, ry: F64, rot: F64, large_arc: Bool, sweep: Bool, x: F64, y: F64) =>
    _command = "a"
    _rx = rx
    _ry = ry
    _rot = rot
    _large_arc = large_arc
    _sweep = sweep
    _x = x
    _y = y

  fun at(): (F64, F64) =>
    (_x, _y)

  fun test_at(xy: (F64, F64)): Bool =>
    (_x == xy._1) and (_y == xy._2)

  fun render(): String =>
    " ".join([
      _command
      _rx.string()
      _ry.string()
      _rot.string()
      if _large_arc then "1" else "0" end
      if _sweep then "1" else "0" end
      _x.string()
      _y.string()
      ].values())

class PathCommands
  let _command_list: Array[PathCommand]

  new create() =>
    _command_list = _command_list.create()

  new from_command_array(command_list: Array[PathCommand] box) =>
    _command_list = command_list.clone()

  fun ref command(c: PathCommand) =>
    _command_list.push(c)

  fun ref commands(cs: PathCommands) =>
    _command_list.append(cs._command_list)

  fun optimize(pco: PathCommandOptimizer): PathCommands =>
    PathCommands.from_command_array(pco(_command_list))

  fun render(): String =>
    " ".join(Iter[PathCommand](_command_list.values()).map[String]({(command) => command.render()}))

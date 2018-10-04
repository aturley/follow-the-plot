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

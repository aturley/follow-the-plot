use "collections"
use "itertools"

actor Main
  new create(env: Env) =>
    let svg = SVG.svg().>c(SVG.circle(50, 50, 40).>a("fill", "none"))
      .>cs(sin())
    env.out.print(svg.render())

  fun sin(): Iterator[SVGNode] =>
    Iter[F64](Range[F64](0, 3.14 * 2, 0.2))
      .map[SVGNode]({(x: F64) =>
        SVG.circle((x * 50) + 50, (x.sin() * 50) + 100, 10).>a("fill", "none")})

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

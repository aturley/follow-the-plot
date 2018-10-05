use "collections"
use "debug"
use "random"
use "time"

primitive Test
  fun is_num(token: String): Bool =>
    if token == "-" then
      return false
    end
    for c in token.values() do
      if ((c != '.') and (c != '-')) and ((c < '0') or (c > '9')) then
        return false
      end
    end
    true

primitive _StopProgram

class DrawLang
  let stack: Array[F64] = Array[F64]

  let return_stack: Array[USize] = Array[USize]

  let marks: Map[String, USize] = Map[String, USize]

  let image: SVGNode = SVG.svg()

  let random: Rand = Rand(Time.millis())

  fun ref next(token: String, cur: USize): (USize | _StopProgram) =>
    if token == "" then
      None
    elseif Test.is_num(token) then
      stack.push(token.f64())
    // STACK
    elseif token == "drop" then
      try
        stack.pop()?
      else
        Debug("drop: not enough items on stack")
      end
    elseif token == "swap" then
      try
        let x = stack.pop()?
        let y = stack.pop()?
        stack.>push(x).>push(y)
      else
        Debug("swap: not enough items on stack")
      end
    elseif token == "dup" then
      try
        let x = stack.pop()?
        stack.>push(x).>push(x)
      else
        Debug("dup: not enough items on stack")
      end
    elseif token == "rot" then
      try
        let x = stack.pop()?
        let y = stack.pop()?
        let z = stack.pop()?
        stack.>push(y).>push(x).>push(z)
      else
        Debug("rot: not enough items on stack")
      end
    elseif token == "pick" then
      try
        let i = stack.pop()?
        stack.push(stack(stack.size() - i.usize() - 1)?)
      else
        Debug("pick: not enough items on stack")
      end
    elseif token == "roll" then
      try
        let i = stack.pop()?
        stack.push(stack(stack.size() - i.usize() - 1)?)
        stack.remove(stack.size() - i.usize() - 2, 1)
      else
        Debug("roll: not enough items on stack")
      end
    //
    // MATH
    //
    elseif token == "+" then
      try
        stack.push(stack.pop()? + stack.pop()?)
      else
        Debug("+: not enough items on stack")
      end
    elseif token == "-" then
      try
        let y = stack.pop()?
        let x = stack.pop()?
        stack.push(x - y)
      else
        Debug("-: not enough items on stack")
      end
    elseif token == "*" then
      try
        stack.push(stack.pop()? * stack.pop()?)
      else
        Debug("*: not enough items on stack")
      end
    elseif token == "/" then
      try
        let y = stack.pop()?
        let x = stack.pop()?
        stack.push(x / y)
      else
        Debug("/: not enough items on stack")
      end
    elseif token == "//" then
      try
        let y = stack.pop()?
        let x = stack.pop()?
        stack.push((x.i64() / y.i64()).f64())
      else
        Debug("//: not enough items on stack")
      end
    elseif token == "%" then
      try
        let y = stack.pop()?
        let x = stack.pop()?
        stack.push(x % y)
      else
        Debug("%: not enough items on stack")
      end
    elseif token == "sin" then
      try
        let x = stack.pop()?
        stack.push(x.sin())
      else
        Debug("sin: not enough items on stack")
      end
    elseif token == "cos" then
      try
        let x = stack.pop()?
        stack.push(x.cos())
      else
        Debug("sin: not enough items on stack")
      end
    elseif token == "random" then
      stack.push(random.real())
    elseif token == ">" then
      try
        let y = stack.pop()?
        let x = stack.pop()?
        stack.push(if (x > y) then 1 else 0 end)
      end
    elseif token == "<" then
      try
        let y = stack.pop()?
        let x = stack.pop()?
        stack.push(if (x < y) then 1 else 0 end)
      end
    elseif token == "==" then
      try
        let y = stack.pop()?
        let x = stack.pop()?
        stack.push(if (x > y) then 1 else 0 end)
      end
    //
    // BRANCHING
    //
    elseif (try token(0)? else ' ' end) == '}' then
      let name: String = token.substring(1)
      try
        if 0 != stack.pop()? then
          try
            let ret = marks(name)?
            return_stack.push(cur)
            return ret
          end
        end
      else
        Debug("branch on '" + name + "': not enough arguments")
      end
    elseif token == "@" then
      try
        return return_stack.pop()? + 1
      end
    elseif token == "end" then
      return _StopProgram
    //
    // SHAPES
    //
    elseif token == "line" then
      try
        let y2 = stack.pop()?
        let x2 = stack.pop()?
        let y1 = stack.pop()?
        let x1 = stack.pop()?
        image.c(SVG.line(x1, y1, x2, y2))
      else
        Debug("line: not enough items on stack")
      end
    elseif token == "polyline" then
      try
        let pair_count = stack.pop()?
        let pairs = Array[(F64, F64)]
        for _ in Range(0, pair_count.usize()) do
          let y = stack.pop()?
          let x = stack.pop()?
          pairs.push((x, y))
        end
        image.c(SVG.polyline(pairs.>reverse_in_place().values()))
      else
        Debug("polyline: not enough items on stack")
      end
    elseif token == "polygon" then
      try
        let pair_count = stack.pop()?
        let pairs = Array[(F64, F64)]
        for _ in Range(0, pair_count.usize()) do
          let y = stack.pop()?
          let x = stack.pop()?
          pairs.push((x, y))
        end
        image.c(SVG.polygon(pairs.>reverse_in_place().values()))
      else
        Debug("polygon: not enough items on stack")
      end
    elseif token == "circle" then
      try
        let r = stack.pop()?
        let y = stack.pop()?
        let x = stack.pop()?
        image.c(SVG.circle(x, y, r))
      else
        Debug("circle: not enough items on stack")
      end
    elseif token == "?" then
      Debug(stack)
    end

    cur + 1

  fun ref run(program: String): String =>
    let tokens: Array[String] = program.split()

    for (i, token) in tokens.pairs() do
      try
        if token(0)? == '{' then
          marks(token.substring(1)) = i
        end
      end
    end

    try
      var next_inst: USize = 0
      while true do
        match next(tokens(next_inst)?, next_inst)
        | let i: USize =>
          next_inst = i
          if next_inst >= tokens.size() then
            break
          end
        else
          break
        end
      end
    end

    image.render()

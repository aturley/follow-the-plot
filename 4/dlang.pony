use "collections"
use "itertools"
use "random"
use "time"

type _StackElement is (F64 | String | DInstruction box)

class _Stack
  let _stack: Array[_StackElement] = _stack.create()

  fun ref push(x: _StackElement) =>
    _stack.push(x)

  fun ref pop(): F64 ? =>
    _stack.pop()? as F64

  fun ref pops(): String ? =>
    _stack.pop()? as String

  fun ref popi(): DInstruction box ? =>
    _stack.pop()? as DInstruction box

  fun ref popx(): _StackElement ? =>
    _stack.pop()?

  fun string(): String iso^ =>
    " ".join(_stack.values())

class _Dict
  let _dict: Array[Map[String, _StackElement]]
  var _top_dict: Map[String, _StackElement]

  new create() =>
    _top_dict = Map[String, _StackElement]
    _dict = _dict.create().>push(_top_dict)

  fun ref push() =>
    _top_dict = Map[String, _StackElement]
    _dict.push(_top_dict)

  fun ref pop() ? =>
    _dict.pop()?
    _top_dict = _dict(_dict.size() - 1)?

  fun ref update(key: String, value: _StackElement) =>
    _top_dict(key) = value

  fun ref apply(key: String): _StackElement ? =>
    for d in _dict.reverse().values() do
      if d.contains(key) then
        return d(key)?
      end
    end
    error

  fun string(): String iso^ =>
    "\n".join(Iter[Map[String, _StackElement] box](_dict.values()).map[String]({(dict) =>
      " ".join(Iter[(String, _StackElement)](dict.pairs()).map[String]({(x) => x._1 + "=" + x._2.string()}))})).clone()

class val DError
  let _message: String

  new val create(message': String) =>
    _message = message'

  fun message(): String =>
    _message

trait DInstruction
  fun exec(dmachine: DMachine): (DInstruction box | DError) ?
  fun ref set_next(next': DInstruction box) =>
    None

  fun string(): String iso^ =>
    "[subprogram]".clone()

class ConstF is DInstruction
  let _f: F64
  var _next: DInstruction box

  new create(f: F64) =>
    _f = f
    _next = Return

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box =>
    dmachine.push(_f)
    _next

class ConstS is DInstruction
  let _s: String
  var _next: DInstruction box

  new create(s: String) =>
    _s = s
    _next = Return

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box =>
    dmachine.push(_s)
    _next

class Add is DInstruction
  var _next: DInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): (DInstruction box | DError) =>
    try
      let y = dmachine.pop()?
      let x = dmachine.pop()?
      dmachine.push(x + y)
      _next
    else
      DError("+: not enough arguments on stack")
    end

class Sub is DInstruction
  var _next: DInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): (DInstruction box | DError) =>
    try
      let y = dmachine.pop()?
      let x = dmachine.pop()?
      dmachine.push(x - y)
      _next
    else
      DError("-: not enough arguments on stack")
    end

class Mult is DInstruction
  var _next: DInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box ? =>
    let y = dmachine.pop()?
    let x = dmachine.pop()?
    dmachine.push(x * y)
    _next

class Div is DInstruction
  var _next: DInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box ? =>
    let y = dmachine.pop()?
    let x = dmachine.pop()?
    dmachine.push(x / y)
    _next

class Mod is DInstruction
  var _next: DInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box ? =>
    let y = dmachine.pop()?
    let x = dmachine.pop()?
    dmachine.push(x % y)
    _next

class RandomI is DInstruction
  var _next: DInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box =>
    dmachine.push(dmachine.random())
    _next

class Drop is DInstruction
  var _next: DInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box ? =>
    dmachine.popx()?
    _next

class Swap is DInstruction
  var _next: DInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box ? =>
    let y = dmachine.popx()?
    let x = dmachine.popx()?
    dmachine.push(y)
    dmachine.push(x)
    _next

class Dup is DInstruction
  var _next: DInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box ? =>
    let x = dmachine.popx()?
    dmachine.push(x)
    dmachine.push(x)
    _next

class Rot is DInstruction
  var _next: DInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box ? =>
    let x = dmachine.pop()?
    let y = dmachine.pop()?
    let z = dmachine.pop()?
    dmachine.push(y)
    dmachine.push(x)
    dmachine.push(z)
    _next

class GreaterThan is DInstruction
  var _next: DInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box ? =>
    let y = dmachine.pop()?
    let x = dmachine.pop()?
    dmachine.push(if (x > y) then 1 else 0 end)
    _next

class If is DInstruction
  var _next: DInstruction box
  let _branch: DInstruction ref
  let _branch_finish: DInstruction ref

  new create(branch: DInstruction ref, branch_finish: DInstruction ref) =>
    _next = Return
    _branch = branch
    _branch_finish = branch_finish

  fun ref set_next(next': DInstruction box) =>
    _next = next'
    _branch_finish.set_next(next')

  fun exec(dmachine: DMachine): DInstruction box ? =>
    if dmachine.pop()? != 0 then
      return _branch
    end
    _next

class While is DInstruction
  var _next: DInstruction box
  let _branch: DInstruction ref
  let _branch_finish: DInstruction ref

  new create(branch: DInstruction ref, branch_finish: DInstruction ref) =>
    _next = Return
    _branch = branch
    _branch_finish = branch_finish
    _branch_finish.set_next(this)

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box ? =>
    if dmachine.pop()? != 0 then
      return _branch
    end
    _next

class Define is DInstruction
  var _next: DInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box ? =>
    let x = dmachine.popx()?
    let name = dmachine.pops()?
    dmachine.define(name, x)
    _next

class Lookup is DInstruction
  var _next: DInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box ? =>
    let name = dmachine.pops()?
    let v = dmachine.lookup(name)?
    dmachine.push(v)
    _next

class PushDict is DInstruction
  var _next: DInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box =>
    dmachine.pushdict()
    _next

class PopDict is DInstruction
  var _next: DInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box ? =>
    dmachine.popdict()?
    _next

class Start is DInstruction
  var _next: DInstruction box = Return

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box =>
    _next

class Stop is DInstruction
  new create() =>
    None

  fun exec(dmachine: DMachine): Stop =>
    Stop

class Return is DInstruction
  new create() =>
    None

  fun exec(dmachine: DMachine): DInstruction box ? =>
    dmachine.ret_pop()?

class Subprog is DInstruction
  let _subprog: DInstruction box
  var _next: DInstruction box = Return

  new create(subprog: DInstruction box) =>
    _subprog = subprog

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box =>
    dmachine.push(_subprog)
    _next

class Call is DInstruction
  var _next: DInstruction box = Return

  new create() =>
    None

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box ? =>
    dmachine.ret_push(_next)
    dmachine.popi()?

class Path is DInstruction
  var _next: DInstruction box = Return

  new create() =>
    None

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box =>
    dmachine.path()
    _next

class MoveAbs is DInstruction
  var _next: DInstruction box = Return

  new create() =>
    None

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box ? =>
    dmachine.dM()?
    _next

class ArcAbs is DInstruction
  var _next: DInstruction box = Return

  new create() =>
    None

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box ? =>
    dmachine.da_abs()?
    _next

class ArcRel is DInstruction
  var _next: DInstruction box = Return

  new create() =>
    None

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box ? =>
    dmachine.da_rel()?
    _next

class Debug is DInstruction
  var _next: DInstruction box = Return

  new create() =>
    None

  fun ref set_next(next': DInstruction box) =>
    _next = next'

  fun exec(dmachine: DMachine): DInstruction box =>
    _next

class DMachine
  let _svg: SVGNode = SVG.svg()

  var _path_commands: PathCommands = PathCommands

  let _stack: _Stack = _stack.create()

  let _dict: _Dict = _dict.create()

  let _return_stack: Array[DInstruction box] = _return_stack.create()

  let _random: Rand = Rand(Time.millis())

  new create() =>
    None

  fun ref push(x: _StackElement) =>
    _stack.push(x)

  fun ref pop(): F64 ? =>
    _stack.pop()?

  fun ref pops(): String ? =>
    _stack.pops()?

  fun ref popi(): DInstruction box ? =>
    _stack.popi()?

  fun ref popx(): _StackElement ? =>
    _stack.popx()?

  fun ref random(): F64 =>
    _random.real()

  fun ref rot() ? =>
    let x = _stack.pop()?
    _stack.push(x)

  fun ref add() ? =>
    let y = pop()?
    let x = pop()?
    push(x + y)

  fun ref mult() ? =>
    let y = pop()?
    let x = pop()?
    push(x * y)

  fun ref inv() ? =>
    let x = pop()?
    push(1 / x)

  fun ref sin() ? =>
    let x = pop()?
    push(x.cos())

  fun ref cos() ? =>
    let x = pop()?
    push(x.cos())

  fun ref define(name: String, x: _StackElement) =>
    _dict(name) = x

  fun ref lookup(name: String): _StackElement ? =>
    _dict(name)?

  fun ref pushdict() =>
    _dict.push()

  fun ref popdict() ? =>
    _dict.pop()?

  fun ref ret_push(inst: DInstruction box) =>
    _return_stack.push(inst)

  fun ref ret_pop(): DInstruction box ? =>
    _return_stack.pop()?

  fun ref path() =>
    _svg.c(SVG.path(_path_commands))
    _path_commands = PathCommands

  fun ref dM() ? =>
    let y = pop()?
    let x = pop()?
    _path_commands.command(PathMove.abs(x, y))

  fun ref da_abs() ? =>
    let y = pop()?
    let x = pop()?
    let sweep = (pop()? != 0)
    let large_arc = (pop()? != 0)
    let rot' = pop()?
    let ry = pop()?
    let rx = pop()?
    _path_commands.command(PathArc.abs(rx, ry, rot', large_arc, sweep, x, y))

  fun ref da_rel() ? =>
    let y = pop()?
    let x = pop()?
    let sweep = (pop()? != 0)
    let large_arc = (pop()? != 0)
    let rot' = pop()?
    let ry = pop()?
    let rx = pop()?
    _path_commands.command(PathArc.rel(rx, ry, rot', large_arc, sweep, x, y))

  fun render(): String =>
    _svg.render()

  fun debug(os: OutStream) =>
    os.print("stack: " + _stack.string())
    os.print("dict: " + _dict.string())

class DProgram
  let _program: Array[DInstruction box] = _program.create()
  let _entry: DInstruction box

  new create(entry: DInstruction box) =>
    _program.push(entry)
    _entry = entry

  fun ref add(inst: DInstruction) =>
    _program.push(inst)

  fun ref run(dmachine: DMachine, out: OutStream, err: OutStream) =>
    var next = _entry

    while true do
      match next
      | let d: Debug box =>
        dmachine.debug(out)
      end

      try
        match next.exec(dmachine)?
        | let e: DError =>
          err.print(e.message())
          break
        | let n: DInstruction box =>
          next = n
        end
      else
        break
      end
      match next
      | let _: Stop box =>
        out.print(dmachine.render())
        break
      end
    end

class DLangParser
  let _subprogram_stack: Array[(DInstruction, DInstruction)] = _subprogram_stack.create()

  fun _test_float(token: String): Bool =>
    let no_minus =
      try
        if token(0)? == '-' then
          token.substring(1)
        else
          token
        end
      else
        return false
      end

    if no_minus.size() == 0 then
      return false
    end

    for c in no_minus.values() do
      if (c != '.') and ((c < '0') or (c > '9')) then
        return false
      end
    end
    true

  fun _test_string(token: String): Bool =>
    try token(0)? == '"' else false end

  fun _strip_string(token: String): String =>
    token.substring(1)

  fun _tokenize(program: String): Array[String] =>
    program.split()

  fun ref _process_tokens(tokens: Iterator[String]): (DInstruction, DInstruction) =>
    let start: DInstruction = Start
    var inst: DInstruction = start
    for t in tokens do
      if t.size() == 0 then
        continue
      end
      if _test_float(t) then
        let new_inst = ConstF(t.f64())
        inst.set_next(new_inst)
        inst = new_inst
      elseif _test_string(t) then
        let new_inst = ConstS(_strip_string(t))
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "+" then
        let new_inst = Add
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "-" then
        let new_inst = Sub
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "*" then
        let new_inst = Mult
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "/" then
        let new_inst = Div
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "%" then
        let new_inst = Mod
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "rand" then
        let new_inst = RandomI
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "drop" then
        let new_inst = Drop
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "swap" then
        let new_inst = Swap
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "dup" then
        let new_inst = Dup
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "rot" then
        let new_inst = Rot
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == ">" then
        let new_inst = GreaterThan
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "?" then
        let new_inst = Debug
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "{" then
        (let sub_start, let sub_finish) = _process_tokens(tokens)
        _subprogram_stack.push((sub_start, sub_finish))
      elseif t == "}" then
        return (start, inst)
      elseif t == "def" then
        let new_inst = Define
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "@" then
        let new_inst = Lookup
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "pushdict" then
        let new_inst = PushDict
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "popdict" then
        let new_inst = PopDict
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "subprog" then
        try
          (let sub_start, _) = _subprogram_stack.pop()?
          let new_inst = Subprog(sub_start)
          inst.set_next(new_inst)
          inst = new_inst
        end
      elseif t == "call" then
        let new_inst = Call
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "if" then
        try
          (let sub_start, let sub_finish) = _subprogram_stack.pop()?
          let new_inst = If(sub_start, sub_finish)
          inst.set_next(new_inst)
          inst = new_inst
        end
      elseif t == "while" then
        try
          (let sub_start, let sub_finish) = _subprogram_stack.pop()?
          let new_inst = While(sub_start, sub_finish)
          inst.set_next(new_inst)
          inst = new_inst
        end
      elseif t == "path" then
        let new_inst = Path
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "dM" then
        let new_inst = MoveAbs
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "dA" then
        let new_inst = ArcAbs
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "da" then
        let new_inst = ArcRel
        inst.set_next(new_inst)
        inst = new_inst
      elseif t == "stop" then
        let new_inst = Stop
        inst.set_next(new_inst)
        inst = new_inst
      end
    end

    (start, inst)

  fun ref process(program: String): DInstruction box =>
    let tokens = _tokenize(program)
    (let prog, let _) = _process_tokens(tokens.values())
    prog

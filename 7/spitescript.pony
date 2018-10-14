use "collections"
use deb = "debug"
use "itertools"
use rand = "random"
use "time"

type _StackElement is (F64 | String | PostSpiteInstruction box | _Record ref)

class _Record
  let _items: Array[_StackElement]

  new create(items: Array[_StackElement]) =>
    _items = items

  new empty(sz: USize) =>
    _items = Array[_StackElement].init(0, sz)

  fun string(): String iso^ =>
    String.>append("[[ ").>append(" ".join(_items.values())).>append(" ]]").clone()

  fun ref append(item: _StackElement): _Record =>
    _Record(_items.clone().>push(item))

  fun ref get(idx: USize): _StackElement ? =>
    _items(idx)?

  fun ref put(item: _StackElement, idx: USize): _Record ? =>
    let items = _items.clone()
    items(idx)? = item
    _Record(items)

  fun ref size(): USize =>
    _items.size()

  fun ref values(): Iterator[_StackElement] =>
    _items.values()

class _Stack
  let _stack: Array[_StackElement] = _stack.create()

  fun ref push(x: _StackElement) =>
    _stack.push(x)

  fun ref pop(): F64 ? =>
    _stack.pop()? as F64

  fun ref pops(): String ? =>
    _stack.pop()? as String

  fun ref popi(): PostSpiteInstruction box ? =>
    _stack.pop()? as PostSpiteInstruction box

  fun ref popr(): _Record ? =>
    _stack.pop()? as _Record

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
      " ".join(Iter[(String, _StackElement box)](dict.pairs()).map[String]({(x) => x._1 + "=" + x._2.string()}))})).clone()

class val PostSpiteError
  let _message: String

  new val create(message': String) =>
    _message = message'

  fun message(): String =>
    _message

trait PostSpiteInstruction
  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) ?
  fun ref set_next(next': PostSpiteInstruction box) =>
    None

  fun string(): String iso^ =>
    "[subprogram]".clone()

class ConstF is PostSpiteInstruction
  let _f: F64
  var _next: PostSpiteInstruction box

  new create(f: F64) =>
    _f = f
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box =>
    dmachine.push(_f)
    _next

class ConstS is PostSpiteInstruction
  let _s: String
  var _next: PostSpiteInstruction box

  new create(s: String) =>
    _s = s
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box =>
    dmachine.push(_s)
    _next

class Add is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) =>
    try
      let y = dmachine.pop()?
      let x = dmachine.pop()?
      dmachine.push(x + y)
      _next
    else
      PostSpiteError("+: not enough arguments on stack")
    end

class Sub is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) =>
    try
      let y = dmachine.pop()?
      let x = dmachine.pop()?
      dmachine.push(x - y)
      _next
    else
      PostSpiteError("-: not enough arguments on stack")
    end

class Mult is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) =>
    try
      let y = dmachine.pop()?
      let x = dmachine.pop()?
      dmachine.push(x * y)
      _next
    else
      PostSpiteError("*: not enough arguments on stack")
    end

class Div is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) =>
    try
      let y = dmachine.pop()?
      let x = dmachine.pop()?
      dmachine.push(x / y)
      _next
    else
      PostSpiteError("*: not enough arguments on stack")
    end

class Mod is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) =>
    try
      let y = dmachine.pop()?
      let x = dmachine.pop()?
      dmachine.push(x % y)
      _next
    else
      PostSpiteError("%: not enough arguments on stack")
    end

class Sqrt is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) =>
    try
      let x = dmachine.pop()?
      dmachine.push(x.sqrt())
      _next
    else
      PostSpiteError("sqrt: not enough arguments on stack")
    end

class Cos is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) =>
    try
      let x = dmachine.pop()?
      dmachine.push(x.cos())
      _next
    else
      PostSpiteError("sqrt: not enough arguments on stack")
    end

class Sin is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) =>
    try
      let x = dmachine.pop()?
      dmachine.push(x.sin())
      _next
    else
      PostSpiteError("sqrt: not enough arguments on stack")
    end

class Random is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box =>
    dmachine.push(dmachine.random())
    _next

class Drop is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) =>
    try
      dmachine.popx()?
      _next
    else
      PostSpiteError("%: not enough arguments on stack")
    end

class Swap is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) =>
    try
      let y = dmachine.popx()?
      let x = dmachine.popx()?
      dmachine.push(y)
      dmachine.push(x)
      _next
    else
      PostSpiteError("swap: not enough arguments on stack")
    end

class Dup is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) =>
    try
      let x = dmachine.popx()?
      dmachine.push(x)
      dmachine.push(x)
      _next
    else
      PostSpiteError("dup: not enough arguments on stack")
    end

class Rot is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) =>
    try
      let x = dmachine.popx()?
      let y = dmachine.popx()?
      let z = dmachine.popx()?
      dmachine.push(y)
      dmachine.push(x)
      dmachine.push(z)
      _next
    else
      PostSpiteError("rot: not enough arguments on stack")
    end

class GreaterThan is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) =>
    try
      let y = dmachine.pop()?
      let x = dmachine.pop()?
      dmachine.push(if (x > y) then 1 else 0 end)
      _next
    else
      PostSpiteError("rot: not enough arguments on stack")
    end

class If is PostSpiteInstruction
  var _next: PostSpiteInstruction box
  let _branch: PostSpiteInstruction ref
  let _branch_finish: PostSpiteInstruction ref

  new create(branch: PostSpiteInstruction ref, branch_finish: PostSpiteInstruction ref) =>
    _next = Return
    _branch = branch
    _branch_finish = branch_finish

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'
    _branch_finish.set_next(next')

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) =>
    try
      if dmachine.pop()? != 0 then
        return _branch
      end
      _next
    else
      PostSpiteError("if: not enough arguments on stack")
    end

class IfElse is PostSpiteInstruction
  let _t_branch: PostSpiteInstruction ref
  let _t_branch_finish: PostSpiteInstruction ref
  let _f_branch: PostSpiteInstruction ref
  let _f_branch_finish: PostSpiteInstruction ref

  new create(t_branch: PostSpiteInstruction ref, t_branch_finish: PostSpiteInstruction ref,
    f_branch: PostSpiteInstruction ref, f_branch_finish: PostSpiteInstruction ref)
  =>
    _t_branch = t_branch
    _t_branch_finish = t_branch_finish
    _f_branch = f_branch
    _f_branch_finish = f_branch_finish

  fun ref set_next(next': PostSpiteInstruction box) =>
    _t_branch_finish.set_next(next')
    _f_branch_finish.set_next(next')

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) =>
    try
      if dmachine.pop()? != 0 then
        return _t_branch
      else
        return _f_branch
      end
    else
      PostSpiteError("ifelse: not enough arguments on stack")
    end

class While is PostSpiteInstruction
  var _next: PostSpiteInstruction box
  let _branch: PostSpiteInstruction ref
  let _branch_finish: PostSpiteInstruction ref

  new create(branch: PostSpiteInstruction ref, branch_finish: PostSpiteInstruction ref) =>
    _next = Return
    _branch = branch
    _branch_finish = branch_finish
    _branch_finish.set_next(this)

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box ? =>
    if dmachine.pop()? != 0 then
      return _branch
    end
    _next

class Define is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) =>
    try
      let x = dmachine.popx()?
      let name = dmachine.pops()?
      dmachine.define(name, x)
      _next
    else
      PostSpiteError("def: not enough arguments")
    end

class DefineX is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) =>
    try
      let name = dmachine.pops()?
      let x = dmachine.popx()?
      dmachine.define(name, x)
      _next
    else
      PostSpiteError("defx: not enough arguments")
    end

class Lookup is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError) =>
    let name = try
      dmachine.pops()?
    else
      return PostSpiteError("dict lookup: not enough arguments")
    end

    try
      let v = dmachine.lookup(name)?
      dmachine.push(v)
      _next
    else
      return PostSpiteError("dict lookup: could not find value for key '" + name + "'")
    end

class PushDict is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box =>
    dmachine.pushdict()
    _next

class PopDict is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box ? =>
    dmachine.popdict()?
    _next

class PushRecord is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError)=>
    try
      let size = dmachine.pop()?.usize()
      dmachine.push(_Record.empty(size))
      _next
    else
      PostSpiteError("record: could not pop size")
    end

class PutRecord is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError)=>
    try
      let i = dmachine.pop()?.usize()
      let x = dmachine.popx()?
      let r = dmachine.popr()?
      dmachine.push(r.put(x, i)?)
      _next
    else
      PostSpiteError("record put: not enough args")
    end

class GetRecord is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError)=>
    try
      let i = dmachine.pop()?.usize()
      let r = dmachine.popr()?
      dmachine.push(r.get(i)?)
      _next
    else
      PostSpiteError("record get: not enough args")
    end

class SizeRecord is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError)=>
    try
      let r = dmachine.popr()?
      dmachine.push(r.size().f64())
      _next
    else
      PostSpiteError("record size: not enough args")
    end

class AppendRecord is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError)=>
    try
      let x = dmachine.popx()?
      let r = dmachine.popr()?
      dmachine.push(r.append(x))
      _next
    else
      PostSpiteError("record append: not enough args")
    end

class BreakRecord is PostSpiteInstruction
  var _next: PostSpiteInstruction box

  new create() =>
    _next = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): (PostSpiteInstruction box | PostSpiteError)=>
    try
      let r = dmachine.popr()?

      for i in r.values() do
        dmachine.push(i)
      end

      _next
    else
      PostSpiteError("record append: not enough args")
    end

class Start is PostSpiteInstruction
  var _next: PostSpiteInstruction box = Return

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box =>
    _next

class Stop is PostSpiteInstruction
  new create() =>
    None

  fun exec(dmachine: PostSpiteMachine): Stop =>
    Stop

class Return is PostSpiteInstruction
  new create() =>
    None

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box ? =>
    dmachine.ret_pop()?

class Subprog is PostSpiteInstruction
  let _subprog: PostSpiteInstruction box
  var _next: PostSpiteInstruction box = Return

  new create(subprog: PostSpiteInstruction box) =>
    _subprog = subprog

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box =>
    dmachine.push(_subprog)
    _next

class Call is PostSpiteInstruction
  var _next: PostSpiteInstruction box = Return

  new create() =>
    None

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box ? =>
    dmachine.ret_push(_next)
    dmachine.popi()?

class Path is PostSpiteInstruction
  var _next: PostSpiteInstruction box = Return

  new create() =>
    None

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box =>
    dmachine.path()
    _next

class MoveAbs is PostSpiteInstruction
  var _next: PostSpiteInstruction box = Return

  new create() =>
    None

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box ? =>
    dmachine.dm_abs()?
    _next

class MoveRel is PostSpiteInstruction
  var _next: PostSpiteInstruction box = Return

  new create() =>
    None

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box ? =>
    dmachine.dm_rel()?
    _next

class LineAbs is PostSpiteInstruction
  var _next: PostSpiteInstruction box = Return

  new create() =>
    None

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box ? =>
    dmachine.dl_abs()?
    _next

class LineRel is PostSpiteInstruction
  var _next: PostSpiteInstruction box = Return

  new create() =>
    None

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box ? =>
    dmachine.dl_rel()?
    _next

class ArcAbs is PostSpiteInstruction
  var _next: PostSpiteInstruction box = Return

  new create() =>
    None

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box ? =>
    dmachine.da_abs()?
    _next

class ArcRel is PostSpiteInstruction
  var _next: PostSpiteInstruction box = Return

  new create() =>
    None

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box ? =>
    dmachine.da_rel()?
    _next

class QuadAbs is PostSpiteInstruction
  var _next: PostSpiteInstruction box = Return

  new create() =>
    None

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box ? =>
    dmachine.da_abs()?
    _next

class QuadRel is PostSpiteInstruction
  var _next: PostSpiteInstruction box = Return

  new create() =>
    None

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box ? =>
    dmachine.dq_rel()?
    _next

class Debug is PostSpiteInstruction
  var _next: PostSpiteInstruction box = Return

  new create() =>
    None

  fun ref set_next(next': PostSpiteInstruction box) =>
    _next = next'

  fun exec(dmachine: PostSpiteMachine): PostSpiteInstruction box =>
    _next

class PostSpiteMachine
  let _svg: SVGNode = SVG.svg()

  var _path_commands: PathCommands = PathCommands

  let _stack: _Stack = _stack.create()

  let _dict: _Dict = _dict.create()

  let _return_stack: Array[PostSpiteInstruction box] = _return_stack.create()

  let _random: rand.Rand = rand.Rand(Time.millis())

  new create() =>
    None

  fun ref push(x: _StackElement) =>
    _stack.push(x)

  fun ref pop(): F64 ? =>
    _stack.pop()?

  fun ref pops(): String ? =>
    _stack.pops()?

  fun ref popi(): PostSpiteInstruction box ? =>
    _stack.popi()?

  fun ref popr(): _Record ? =>
    _stack.popr()?

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

  fun ref ret_push(inst: PostSpiteInstruction box) =>
    _return_stack.push(inst)

  fun ref ret_pop(): PostSpiteInstruction box ? =>
    _return_stack.pop()?

  fun ref path() =>
    _svg.c(SVG.path(_path_commands))
    _path_commands = PathCommands

  fun ref dm_abs() ? =>
    let y = pop()?
    let x = pop()?
    _path_commands.command(PathMove.abs(x, y))

  fun ref dm_rel() ? =>
    let y = pop()?
    let x = pop()?
    _path_commands.command(PathMove.rel(x, y))

  fun ref dl_abs() ? =>
    let y = pop()?
    let x = pop()?
    _path_commands.command(PathLine.abs(x, y))

  fun ref dl_rel() ? =>
    let y = pop()?
    let x = pop()?
    _path_commands.command(PathLine.rel(x, y))

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

  fun ref dq_abs() ? =>
    let y = pop()?
    let x = pop()?
    let cy = pop()?
    let cx = pop()?
    _path_commands.command(PathBezQuad.abs(cx, cy, x, y))

  fun ref dq_rel() ? =>
    let y = pop()?
    let x = pop()?
    let cy = pop()?
    let cx = pop()?
    _path_commands.command(PathBezQuad.rel(cx, cy, x, y))

  fun render(): String =>
    _svg.render()

  fun debug(os: OutStream) =>
    os.print("stack: " + _stack.string())
    os.print("dict: " + _dict.string())
    os.print("------------------------")

class PostSpiteProgram
  let _program: Array[PostSpiteInstruction box] = _program.create()
  let _entry: PostSpiteInstruction box

  new create(entry: PostSpiteInstruction box) =>
    _program.push(entry)
    _entry = entry

  fun ref add(inst: PostSpiteInstruction) =>
    _program.push(inst)

  fun ref run(dmachine: PostSpiteMachine, out: OutStream, err: OutStream) =>
    var next = _entry

    while true do
      match next
      | let d: Debug box =>
        dmachine.debug(out)
      end

      try
        match next.exec(dmachine)?
        | let e: PostSpiteError =>
          err.print(e.message())
          break
        | let n: PostSpiteInstruction box =>
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

class PostSpiteLangParser
  let _subprogram_stack: Array[(PostSpiteInstruction, PostSpiteInstruction)] = _subprogram_stack.create()

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

  fun _add_inst(inst: PostSpiteInstruction, new_inst: PostSpiteInstruction):
    PostSpiteInstruction
  =>
    inst.set_next(new_inst)
    new_inst

  fun ref _process_tokens(tokens: Iterator[String]): ((PostSpiteInstruction, PostSpiteInstruction) | PostSpiteError) =>
    let start: PostSpiteInstruction = Start
    var inst: PostSpiteInstruction = start
    for t in tokens do
      if t.size() == 0 then
        continue
      end
      if _test_float(t) then
        inst = _add_inst(inst, ConstF(t.f64()))
      elseif _test_string(t) then
        inst = _add_inst(inst, ConstS(_strip_string(t)))
      elseif t == "+" then
        inst = _add_inst(inst, Add)
      elseif t == "-" then
        inst = _add_inst(inst, Sub)
      elseif t == "*" then
        inst = _add_inst(inst, Mult)
      elseif t == "/" then
        inst = _add_inst(inst, Div)
      elseif t == "%" then
        inst = _add_inst(inst, Mod)
      elseif t == "sqrt" then
        inst = _add_inst(inst, Sqrt)
      elseif t == "cos" then
        inst = _add_inst(inst, Cos)
      elseif t == "sin" then
        inst = _add_inst(inst, Sin)
      elseif t == "rand" then
        inst = _add_inst(inst, Random)
      elseif t == "drop" then
        inst = _add_inst(inst, Drop)
      elseif t == "swap" then
        inst = _add_inst(inst, Swap)
      elseif t == "dup" then
        inst = _add_inst(inst, Dup)
      elseif t == "rot" then
        inst = _add_inst(inst, Rot)
      elseif t == ">" then
        inst = _add_inst(inst, GreaterThan)
      elseif t == "?" then
        inst = _add_inst(inst, Debug)
      elseif t == "{" then
        match _process_tokens(tokens)
        | (let sub_start: PostSpiteInstruction, let sub_finish: PostSpiteInstruction) =>
          _subprogram_stack.push((sub_start, sub_finish))
        | let e: PostSpiteError =>
          return e
        end
      elseif t == "}" then
        return (start, inst)
      elseif t == "def" then
        inst = _add_inst(inst, Define)
      elseif t == "defx" then
        inst = _add_inst(inst, DefineX)
      elseif t == "@" then
        inst = _add_inst(inst, Lookup)
      elseif t == "pushdict" then
        inst = _add_inst(inst, PushDict)
      elseif t == "popdict" then
        inst = _add_inst(inst, PopDict)
      elseif t == "rec" then
        inst = _add_inst(inst, PushRecord)
      elseif t == "recp" then
        inst = _add_inst(inst, PutRecord)
      elseif t == "recg" then
        inst = _add_inst(inst, GetRecord)
      elseif t == "recsize" then
        inst = _add_inst(inst, SizeRecord)
      elseif t == "rec+" then
        inst = _add_inst(inst, AppendRecord)
      elseif t == "rec*" then
        inst = _add_inst(inst, BreakRecord)
      elseif t == "subprog" then
        try
          inst = _add_inst(inst, Subprog(_subprogram_stack.pop()?._1))
        else
          return PostSpiteError("subprog: subprogram stack is empty")
        end
      elseif t == "call" then
        inst = _add_inst(inst, Call)
      elseif t == "if" then
        try
          (let sub_start, let sub_finish) = _subprogram_stack.pop()?
          inst = _add_inst(inst, If(sub_start, sub_finish))
        end
      elseif t == "ifelse" then
        try
          (let f_sub_start, let f_sub_finish) = _subprogram_stack.pop()?
          (let t_sub_start, let t_sub_finish) = _subprogram_stack.pop()?
          inst = _add_inst(inst, IfElse(t_sub_start, t_sub_finish, f_sub_start, f_sub_finish))
        else
          return PostSpiteError("if: not enough arguments in the subprogram stack")
        end
      elseif t == "while" then
        try
          (let sub_start, let sub_finish) = _subprogram_stack.pop()?
          inst = _add_inst(inst, While(sub_start, sub_finish))
        else
          return PostSpiteError("while: not enough arguments in the subprogram stack")
        end
      elseif t == "path" then
        inst = _add_inst(inst, Path)
      elseif t == "dM" then
        inst = _add_inst(inst, MoveAbs)
      elseif t == "dm" then
        inst = _add_inst(inst, MoveRel)
      elseif t == "dL" then
        inst = _add_inst(inst, LineAbs)
      elseif t == "dl" then
        inst = _add_inst(inst, LineRel)
      elseif t == "dA" then
        inst = _add_inst(inst, ArcAbs)
      elseif t == "da" then
        inst = _add_inst(inst, ArcRel)
      elseif t == "dQ" then
        inst = _add_inst(inst, QuadAbs)
      elseif t == "dq" then
        inst = _add_inst(inst, QuadRel)
      elseif t == "stop" then
        inst = _add_inst(inst, Stop)
      else
        return PostSpiteError("unknown token: '" + t + "'")
      end
    end

    (start, inst)

  fun ref process(program: String): (PostSpiteInstruction box | PostSpiteError) =>
    let tokens = _tokenize(program)
    match _process_tokens(tokens.values())
    | (let prog: PostSpiteInstruction, _) =>
      prog
    | let e: PostSpiteError =>
      e
    end

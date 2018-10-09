use "cli"

actor Main
  new create(env: Env) =>
    let cs =
      try
        CommandSpec.leaf("4", "PostSpite interpreter", [
          OptionSpec.string("exec", "Text of program to execute"
            where default' = "")], [])? .> add_help()?
      else
        env.err.print("error parsing command line options and args")
        env.exitcode(-1)
        return
      end

    let cmd =
      match CommandParser(cs).parse(env.args, env.vars)
      | let c: Command => c
      | let ch: CommandHelp =>
        ch.print_help(env.out)
        env.exitcode(0)
        return
      | let se: SyntaxError =>
        env.out.print(se.string())
        env.exitcode(1)
        return
      end

    let prog = cmd.option("exec").string()

    let dm = DMachine
    let start_inst = DLangParser.process(prog)
    let dp = DProgram(start_inst)
    dp.run(dm, env.out, env.err)

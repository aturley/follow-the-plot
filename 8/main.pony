use "cli"
use f = "files"

actor Main
  new create(env: Env) =>
    let cs =
      try
        CommandSpec.leaf("5", "PostSpite interpreter", [
          OptionSpec.string("exec", "Text of program to execute"
            where default' = "")
          OptionSpec.string("files", "File name of program to execute"
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
        env.err.print(se.string())
        env.exitcode(1)
        return
      end

    let prog =
      recover val
        let prog' = String
        for file_name in cmd.option("files").string().split(",").values() do
          try
            let path = f.FilePath(env.root as AmbientAuth, file_name)?
            match f.OpenFile(path)
            | let file: f.File =>
              prog'.>append(file.read(file.size())).>append(" ")
            else
              error
            end
          else
            env.err.print("Error opening file '" + file_name + "'")
            env.exitcode(1)
            return
          end
        end
        prog'.>append(cmd.option("exec").string())
      end

    let sm = PostSpiteMachine
    match PostSpiteLangParser.process(prog)
    | let start_inst: PostSpiteInstruction box =>
      let sp = PostSpiteProgram(start_inst)
      sp.run(sm, env.out, env.err)
    | let e: PostSpiteError =>
      env.err.print("parse error")
      env.err.print(e.message())
      env.exitcode(-1)
      return
    end

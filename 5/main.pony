use "cli"
use f = "files"

actor Main
  new create(env: Env) =>
    let cs =
      try
        CommandSpec.leaf("5", "PostSpite interpreter", [
          OptionSpec.string("exec", "Text of program to execute"
            where default' = "")
          OptionSpec.string("file", "File name of program to execute"
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

    let prog = match (cmd.option("exec").string(), cmd.option("file").string())
    | (let p: String, "") =>
      p
    | ("", let file_name: String) =>
      try
        recover
          let path = f.FilePath(env.root as AmbientAuth, file_name)?
          match f.OpenFile(path)
          | let file: f.File =>
            String.>append(file.read(file.size()))
          else
            error
          end
        end
      else
        env.err.print("Error opening file '" + file_name + "'")
        env.exitcode(1)
        return
      end
    else
      env.err.print("you must specify either a filename or a program")
      env.exitcode(-1)
      return
    end

    let sm = PostSpiteMachine
    let start_inst = PostSpiteLangParser.process(prog)
    let sp = PostSpiteProgram(start_inst)
    sp.run(sm, env.out, env.err)

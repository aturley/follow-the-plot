actor Main
  new create(env: Env) =>
    try
      env.out.print(DrawLang.run(env.args(1)?))
    else
      env.err.print("enter a program as the only argument")
    end

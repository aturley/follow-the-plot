// Run this with the following argument to get a straight line and some
// polylines:
//   ./2 "50 0 50 100 line 2 {BGR 100 random * 100 random * 100 random * 100 random * 100 random * 100 random * 100 random * 100 random * 4 polyline 1 - dup }BGR" > out.svg
//
actor Main
  new create(env: Env) =>
    try
      env.out.print(DrawLang.run(env.args(1)?))
    else
      env.out.print(DrawLang.run("50 0 50 100 line 0 100 50 25 50 75 100 0 4 polyline"))
    end

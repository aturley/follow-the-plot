// Run this with the following argument to draw a landscape:
//   ./2.1 "100 30 15 circle 0 100 1 {M dup 50 * swap 100 random 50 * - swap 1 + dup 9 < }M drop 450 100 10 polyline 100 {F random 450 * swap random 100 * 100 + swap 1 - dup }F drop 100 polyline 0 100 450 100 line"
//
actor Main
  new create(env: Env) =>
    try
      env.out.print(DrawLang.run(env.args(1)?))
    end

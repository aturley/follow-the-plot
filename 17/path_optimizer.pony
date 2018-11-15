use "collections"

interface val PathCommandOptimizer
  fun apply(path_commands: Array[PathCommand] box): Array[PathCommand]

primitive OptimizeConsecutiveMoves
  fun apply(path_commands: Array[PathCommand] box): Array[PathCommand] =>
    let pcs = Array[PathCommand]

    for i in Range(0, path_commands.size() - 1) do
      try
        match (path_commands(i)?, path_commands(i + 1)?)
        | (let pm1: PathMove, let pm2: PathMove) =>
          None
        else
          try
            pcs.push(path_commands(i)?)
          end
        end
      end
    end

    try
      pcs.push(path_commands(path_commands.size() - 1)?)
    end

    pcs

primitive OptimizeConnectCommands
  fun apply(path_commands: Array[PathCommand] box): Array[PathCommand] =>
    let seen = Array[Bool].init(false, path_commands.size())
    let pcs = Array[PathCommand]

    try
      for i in Range(0, path_commands.size()) do
        if seen(i)? == false then
          let cur_command = path_commands(i)?
          var at = cur_command.at()
          pcs.push(cur_command)
          for j in Range(i + 1, path_commands.size()) do
            if seen(j)? == false then
              let candidate_command = path_commands(j)?
              match candidate_command
              | (let pm: PathMove) if pm.test_at(at) =>
                pcs.push(path_commands(j + 1)?)
                at = path_commands(j + 1)?.at()
                seen(j + 1)? = true
                seen(j)? = true
              | (let pc: PathCommand) if pc.test_at(at) =>
                pcs.push(path_commands(j)?)
                at = path_commands(j)?.at()
                seen(j)? = true
              end
            end
          end
          seen(i)? = true
        end
      end
    end

    pcs

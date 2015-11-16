

module.exports =


  run: (filepath, command) ->
    atom.notifications.addInfo "Erlang workbench: " + command
    if not filepath
      dirpath = atom.project.getDirectories()[0]?.path
    else if require('fs').lstatSync(filepath).isFile()
      dirpath = require('path').dirname(filepath)
    else
      dirpath = filepath
    return if not dirpath
    require('child_process').exec command,
      cwd: dirpath


  run_terminal: (filepath) ->
    command = atom.config.get 'atom-erlang-workbench.terminal_command'
    @run(filepath, command)

  run_eshell: (filepath) ->
    command = atom.config.get 'atom-erlang-workbench.eshell_command'
    @run(filepath, command)

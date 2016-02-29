{BufferedProcess, CompositeDisposable} = require 'atom'

module.exports =



  run_terminal: (filepath) ->
    command = atom.config.get 'atom-erlang-workbench.terminal_command'
    @run(filepath, command)

  run_eshell: (filepath) ->
    command = atom.config.get 'atom-erlang-workbench.eshell_command'
    @run(filepath, command)

  run_rebar_compile: (filepath) ->
    command = atom.config.get 'atom-erlang-workbench.rebar_command'
    @run_buffered(filepath, command, ["compile"])



  run: (filepath, a_command) ->
    if not filepath
      dirpath = atom.project.getDirectories()[0]?.path
    else if require('fs').lstatSync(filepath).isFile()
      dirpath = require('path').dirname(filepath)
    else
      dirpath = filepath
    return if not dirpath

    switch require('os').platform()
      when 'darwin'
        exec_prefix = ''
      when 'win32'
        exec_prefix = 'start /D "%cd%" '
      else
        exec_prefix = ''

    atom.notifications.addInfo "Erlang workbench run: " + exec_prefix + a_command
    require('child_process').exec(exec_prefix + a_command, {cwd:  dirpath})


  run_buffered: (filepath, a_command, a_args) ->
    if not filepath
      dirpath = atom.project.getDirectories()[0]?.path
    else if require('fs').lstatSync(filepath).isFile()
      dirpath = require('path').dirname(filepath)
    else
      dirpath = filepath
    return if not dirpath

    # atom.notifications.addInfo "Erlang workbench buffered cwd: " + dirpath
    atom.notifications.addInfo "Erlang workbench buffered command: " + a_command + ", " + a_args

    run_result = []
    exit_result = ""

    return new Promise (resolve) =>
      process = new BufferedProcess
        command: a_command
        args: a_args
        options:
          cwd: dirpath # Should use better folder perhaps
        stdout: (data) ->
          # atom.notifications.addInfo('Test stdout:', detail: data, dismissable: {})
          run_result.push data#.replace(/(\r\n|\n|\r)/gm,"")
        exit: (code) ->
          exit_result += code
          atom.notifications.addError "Erlang workbench buffered command result #{run_result}"
          # parse_erl_module_info_result("#{compile_result}")
          resolve run_result
      process.onWillThrowError ({error,handle}) ->
        atom.notifications.addError "Failed to run #{command}",
          detail: "#{error.message}"
          dismissable: true
        handle()
        resolve []

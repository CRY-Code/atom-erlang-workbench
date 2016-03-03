{BufferedProcess, CompositeDisposable} = require 'atom'
{CompositeDisposable} = require 'atom'

module.exports =
class Project
  rebar_templates  = []
  initialize: () ->
    # this.rebar_templates  = []
    @getRebarTemplates()
    # this.emitter = new Emitter();
    # this.db = new DB();
    # this.updateProps(props);
    # this.lookForUpdates();



  getRebarTemplates: () ->
    tupples = []
    parse_outputText = (text) ->
      # atom.notifications.addInfo text
      parse_line = (line) ->
        n = line.slice(line.indexOf("*")+2, line.indexOf(":"))
        l = line.slice(line.indexOf("("))
        v = l.slice(l.indexOf(': "')+3, l.indexOf('")'))
        # atom.notifications.addInfo n + ", " + v
        tupples.push({name:n, variable:v})

      tupple_pattern = ///
          \*
          ([a-zA-Z0-9_\s]*)
          \:
          (.*)
          \n
          ///g

      if (text.length > 0 && text.indexOf('*') > 0)
        lines = text.match(tupple_pattern)
        for i in lines
          parse_line(i)

    this.rebar_templates = []
    outputText = ""
    new BufferedProcess
      command: atom.config.get('atom-erlang-workbench.rebar_command')
      args: ['list-templates']
      stdout: (data) ->
        # view.addLine data.toString()
        outputText += data.toString() + "\n"
      stderr: (data) ->
        # view.addLine data.toString()
      exit: (code) ->
        # message.dismiss()
        # view.finish()
        parse_outputText("#{outputText}")
        # atom.notifications.addInfo outputText

    this.rebar_templates = tupples
    # for i in tupples
    #   # this.rebar_templates.push i
    #   # this.rebar_templates.i = tupples.i
    #   atom.notifications.addInfo i.name + ", " + i.variable

AtomErlangWorkbenchView = require './atom-erlang-workbench-view'
TerminalUtils = require './terminal-utils.coffee'
{CompositeDisposable} = require 'atom'


switch require('os').platform()
  when 'darwin'
    default_terminal_command = 'open -a Terminal.app "$PWD"'
    default_eshell_command = 'erl'
  when 'win32'
    default_terminal_command = 'start /D "%cd%" cmd'
    default_eshell_command = 'start /D "%cd%" erl'
  else
    default_terminal_command = 'x-terminal-emulator'
    default_eshell_command = 'erl'

module.exports = AtomErlangWorkbench =
  config: {
    terminal_command:
      type: 'string'
      default: default_terminal_command
    eshell_command:
      type: 'string'
      default: default_eshell_command
  },
  atomErlangWorkbenchView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomErlangWorkbenchView = new AtomErlangWorkbenchView(state.atomErlangWorkbenchViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @atomErlangWorkbenchView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-erlang-workbench:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-erlang-workbench:run_terminal': => TerminalUtils.run_terminal()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-erlang-workbench:run_eshell': => TerminalUtils.run_eshell()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomErlangWorkbenchView.destroy()

  serialize: ->
    atomErlangWorkbenchViewState: @atomErlangWorkbenchView.serialize()

  toggle: ->
    console.log 'AtomErlangWorkbench was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

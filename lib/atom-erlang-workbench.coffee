{CompositeDisposable, Disposable} = require 'atom'
AtomErlangWorkbenchView = require './atom-erlang-workbench-view'
AutosolutionView = require './views/autosolution-view.coffee'
TerminalUtils = require './terminal-utils.coffee'
{CompositeDisposable} = require 'atom'


switch require('os').platform()
  when 'darwin'
    default_terminal_command = 'open -a Terminal.app "$PWD"'
    default_eshell_command = 'erl'
    default_rebar_command = 'rebar'
  when 'win32'
    default_terminal_command = 'cmd'
    default_eshell_command = 'erl'
    default_rebar_command = 'rebar'
  else
    default_terminal_command = 'x-terminal-emulator'
    default_eshell_command = 'erl'
    default_rebar_command = 'rebar'

module.exports = AtomErlangWorkbench =
  config: {
    terminal_command:
      type: 'string'
      default: default_terminal_command
    eshell_command:
      type: 'string'
      default: default_eshell_command
    rebar_command:
      type: 'string'
      default: default_rebar_command
  },
  atomErlangWorkbenchView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomErlangWorkbenchView = new AtomErlangWorkbenchView(state.atomErlangWorkbenchViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @atomErlangWorkbenchView.getElement(), visible: false)




    @autosolutionViewsByEditor = new WeakMap
    @deactivationDisposables = new CompositeDisposable

    @deactivationDisposables.add atom.workspace.observeTextEditors (editor) =>
      return if editor.mini

      autosolutionView = new AutosolutionView(editor)
      @autosolutionViewsByEditor.set(editor, autosolutionView)

      disposable = new Disposable => autosolutionView.destroy()
      @deactivationDisposables.add editor.onDidDestroy => disposable.dispose()
      @deactivationDisposables.add disposable

    getAutosolutionView = (editorElement) =>
      @autosolutionViewsByEditor.get(editorElement.getModel())

    @deactivationDisposables.add atom.commands.add 'atom-text-editor:not([mini])',
      'autosolution:toggle': ->
        atom.notifications.addInfo('Test out:')
        getAutosolutionView(this)?.toggle()
      'autosolution:next': ->
        getAutosolutionView(this)?.selectNextItemView()
      'autosolution:previous': ->
        getAutosolutionView(this)?.selectPreviousItemView()






    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    # @subscriptions.add atom.commands.add 'atom-workspace', 'atom-erlang-workbench:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-erlang-workbench:toggle': => @toggle()

    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-erlang-workbench:run_terminal': => TerminalUtils.run_terminal()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-erlang-workbench:run_eshell': => TerminalUtils.run_eshell()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-erlang-workbench:run_rebar_compile': => TerminalUtils.run_rebar_compile()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomErlangWorkbenchView.destroy()

  serialize: ->
    atomErlangWorkbenchViewState: @atomErlangWorkbenchView.serialize()

  toggle: ->
    SaveDialog = require('./save-dialog');
    saveDialog = new SaveDialog();
    saveDialog.attach();
    # console.log 'AtomErlangWorkbench was toggled!'
    #
    # if @modalPanel.isVisible()
    #   @modalPanel.hide()
    # else
    #   @modalPanel.show()

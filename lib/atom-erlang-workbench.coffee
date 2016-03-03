{CompositeDisposable, Disposable} = require 'atom'
AtomErlangWorkbenchView = require './atom-erlang-workbench-view'
AutosolutionView = require './views/autosolution-view.coffee'
TerminalUtils = require './terminal-utils.coffee'
Project = require './project.coffee'
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
    default_eshell_command = 'x-terminal-emulator -e erl'
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
  p : null

  activate: (state) ->

    @p = new Project()
    @p.initialize()

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
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-erlang-workbench:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-erlang-workbench:test': => @test()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-erlang-workbench:run_terminal': =>
      TerminalUtils.run(null, atom.config.get('atom-erlang-workbench.terminal_command'))
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-erlang-workbench:run_eshell': =>
      TerminalUtils.run(null, atom.config.get('atom-erlang-workbench.eshell_command'))
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-erlang-workbench:run_rebar_compile': =>
      TerminalUtils.spawn(null, atom.config.get('atom-erlang-workbench.rebar_command'), ["compile"])
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-erlang-workbench:compile': =>
      r = TerminalUtils.spawn(null, 'erlc', ["-I include -o ebin src/*.erl"])
      atom.notifications.addError "Failed to run #{r}"

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
  test: ->
    atom.notifications.addInfo "Test"
    for i in @p.rebar_templates
      atom.notifications.addInfo i.name + ", " + i.variable
    # atom.notifications.addError @p.rebar_templates.toString()

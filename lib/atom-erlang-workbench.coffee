AtomErlangWorkbenchView = require './atom-erlang-workbench-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomErlangWorkbench =
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

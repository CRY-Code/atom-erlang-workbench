{Subscriber} = require 'emissary'
{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
  class OutputView extends ScrollView
    Subscriber.includeInto(this)

    message: ''
    panel: null

    @content: ->
      @div class: 'apm-publish info-view', =>
        @pre class: 'output'

    initialize: ->
      super
      @subscribe $(window), 'core:cancel', => @destroy()
      @panel ?= atom.workspace.addBottomPanel(item: this, visible: false)

    addLine: (line) -> @message += line

    reset: -> @message = ''

    finish: ->
      @find(".output").append(@message)
      @panel.show()
      setTimeout =>
        @destroy()
      , 7000

    destroy: ->
      @panel.destroy()
      @unsubscribe()

_ = require 'underscore-plus'

module.exports =
  config:
    blinkPeriod:
      type: 'integer'
      default: 800
      minimum: 1

  cssSelector: 'atom-text-editor .cursor, atom-text-editor::shadow .cursor'
  cssRule: 'transitionDuration'

  activate: (state) ->
    @setupConfigObserver()

  setupConfigObserver: ->
    atom.config.observe 'ease-blink.blinkPeriod', @changeBlinkPeriod.bind(@)

  changeBlinkPeriod: (value) ->
    ['updateEditorViews', 'updateCssRule'].forEach (method) =>
      @[method] value
      true

  updateEditorViews: (value) ->
    @textEditorsObserver?.dispose()

    @textEditorsObserver = atom.workspace.observeTextEditors (editor) =>
      @patchBlinkPeriod value, editor, true

  patchBlinkPeriod: (value, editor, retry = false) ->
    view = atom.views.getView editor
    {component} = view
    unless component?
      setImmediate _.partial(@patchBlinkPeriod, value, editor) if retry
      return
    {presenter} = component

    component.cursorBlinkPeriod = value
    presenter.cursorBlinkPeriod = value
    presenter.stopBlinkingCursors()
    presenter.startBlinkingCursors()

  updateCssRule: (value) ->
    @getCssRule().style[@cssRule] = "#{value / 2000}s"

  getCssRule: ->
    _.chain document.styleSheets
      .map (stylesheet) ->
        _.toArray stylesheet.cssRules
      .flatten()
      .find (rule) =>
        rule.selectorText == @cssSelector and rule.style[@cssRule].length > 0
      .value()

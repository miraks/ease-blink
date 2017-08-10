{ CompositeDisposable } = require 'atom'

module.exports =
  config:
    blinkPeriod:
      type: 'integer'
      default: 800
      minimum: 1

  stylesheetName: 'ease-blink.less'
  cssSelector: 'atom-text-editor .cursor'
  cssRule: 'transitionDuration'

  activate: ->
    @disposable = new CompositeDisposable
    @setupConfigObserver()

  deactivate: ->
    @disposable.dispose()

  setupConfigObserver: ->
    @disposable.add atom.config.observe('ease-blink.blinkPeriod', @changeBlinkPeriod.bind(@))

  changeBlinkPeriod: (value) ->
    @updateEditorViews value
    @updateCssRule value

  updateEditorViews: (value) ->
    @textEditorsObserver?.dispose()

    @textEditorsObserver = atom.workspace.observeTextEditors (editor) =>
      @patchBlinkPeriod value, editor, true

  patchBlinkPeriod: (value, editor, retry = false) ->
    view = atom.views.getView editor
    { component } = view

    unless component?
      setImmediate(=> @patchBlinkPeriod(value, editor)) if retry
      return

    component.props.cursorBlinkPeriod = value
    component.stopCursorBlinking()
    component.startCursorBlinking()

  updateCssRule: (value) ->
    cssRule = @getCssRule()
    return unless cssRule?
    cssRule.style[@cssRule] = "#{value / 2000}s"

  getCssRule: ->
    stylesheet = Array.from(document.styleSheets).find ({ ownerNode }) =>
      ownerNode.sourcePath.endsWith @stylesheetName

    return unless stylesheet?

    Array.from(stylesheet.cssRules).find ({ selectorText }) =>
      selectorText == @cssSelector

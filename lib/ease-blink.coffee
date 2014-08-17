_ = require 'underscore-plus'
path = require 'path'
CursorView = require path.join(atom.getLoadSettings().resourcePath, 'src/cursor-view')

module.exports =
  configDefaults:
    blinkPeriod: 800

  activate: (state) ->
    @setupConfigObserver()

  setupConfigObserver: ->
    atom.config.observe 'ease-blink.blinkPeriod', @changeBlinkPeriod.bind(@)

  changeBlinkPeriod: (value) ->
    ['updateCursorView', 'updateEditorView', 'updateCssRule'].forEach (methodName) =>
      @[methodName] value

  updateCursorView: (value) ->
    CursorView.blinkPeriod = value
    return unless CursorView.blinkInterval?
    clearInterval CursorView.blinkInterval
    CursorView.blinkInterval = setInterval CursorView.blinkCursors.bind(CursorView), CursorView.blinkPeriod / 2

  updateEditorView: (value) ->
    return unless atom.config.get 'core.useReactEditor'
    @editorViewsObserver?.off()
    @editorViewsObserver = atom.workspaceView.eachEditorView (view) =>
      view.component.props.cursorBlinkPeriod = value

  updateCssRule: (value) ->
    @getCssRule().style.transitionDuration = "#{value / 2000}s"

  getCssRule: ->
    @cssRule ||= _.chain document.styleSheets
      .map (stylesheet) ->
        Array::slice.call stylesheet.cssRules
      .flatten()
      .find (rule) ->
        rule.selectorText == '.cursor' and rule.style.transitionDuration.length > 0
      .value()

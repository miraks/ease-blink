_ = require 'underscore-plus'

module.exports =
  configDefaults:
    blinkPeriod: 800

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
    @editorViewsObserver?.off()
    @editorViewsObserver = atom.views.getView(atom.workspace).eachEditorView (view) ->
      view.component.setProps cursorBlinkPeriod: value

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

ALTERNATE_THEME_NAME = 'dark'

using_alternate_theme = ->
  localStorage.getItem('usingAlternateTheme') is 'true'

enable_alternate_theme = ->
  document.body.className = "#{ALTERNATE_THEME_NAME} #{document.body.className}"

disable_alternate_theme = ->
  document.body.className = document.body.className.replace ALTERNATE_THEME_NAME, ''

if using_alternate_theme() then enable_alternate_theme()

# allow the background color to be transitioned, but only after loading the
# file (because the class might be added by javascript, and we only want the
# transition when the user clicks the button to switch themes)
addEventListener 'load', ->
  document.body.className = "transition-background-color #{document.body.className}"

document.getElementById('theme-toggle').addEventListener 'click', ->
  usingAlternateTheme = using_alternate_theme()

  if usingAlternateTheme
    disable_alternate_theme()
  else
    enable_alternate_theme()

  localStorage.setItem 'usingAlternateTheme', !usingAlternateTheme

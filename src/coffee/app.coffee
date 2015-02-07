# helpers {{{

# toggle a css class on an element
toggle_class = (el, className) ->
  classRegexp = new RegExp '\\b' + className + '\\b'

  el.className =
    if el.className.match classRegexp
      el.className.replace classRegexp, ''
    else
      el.className + ' ' + className + ' '

toggle_alternate_theme = ->
  toggle_class document.body, 'dark'
  toggle_class document.body, 'light'

# }}} helpers

# on click {{{

document.getElementById('theme-toggle').addEventListener 'click', ->
  # allow the background to fade. adding this the first time the theme toggle
  # is clicked avoids transitioning on page load
  unless document.body.className.match /\btransition-background-color\b/
    document.body.className = document.body.className + ' transition-background-color '

  usingAlternateTheme = localStorage.getItem('use-alternate-theme') is 'true'

  localStorage.setItem 'use-alternate-theme', !usingAlternateTheme
  toggle_alternate_theme()

document.getElementById('download-links-toggle').addEventListener 'click', ->
  toggle_class document.body, 'show-download-links'

# }}} on click

# use the theme the most recently chose
if localStorage.getItem('use-alternate-theme') is 'true'
  toggle_alternate_theme()

# helper function to toggle a css class on an element
toggle_class = (el, className) ->
  classRegexp = new RegExp '\\b' + className + '\\b'

  el.className =
    if el.className.match classRegexp
      el.className.replace classRegexp, ''
    else
      el.className + ' ' + className + ' '

toggle_light_dark = ->
  toggle_class document.body, 'dark'
  toggle_class document.body, 'light'

addEventListener 'load', ->
  if localStorage.getItem('use-alternate-theme') is 'true'
    toggle_light_dark()

document.getElementById('theme-toggle').addEventListener 'click', ->
  # allow the background to fade. adding this the first time the theme toggle
  # is clicked avoids transitioning on page load
  unless document.body.className.match /\btransition-background-color\b/
    document.body.className = document.body.className + ' transition-background-color '

  usingAlternateTheme = localStorage.getItem('use-alternate-theme') is 'true'

  localStorage.setItem 'use-alternate-theme', !usingAlternateTheme
  toggle_light_dark()

document.getElementById('download-links-toggle').addEventListener 'click', ->
  toggle_class document.body, 'show-download-links'

document.getElementById('menu-toggle').addEventListener 'click', ->
  toggle_class this, 'menu-visible'

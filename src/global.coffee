# lgtm.in
lgtmAPI =
  scheme: 'http'
  endpoint: 'www.lgtm.in/g'

# Fetch json payload from lgtm.in
lgtm = ->
  url = "#{lgtmAPI.scheme}://#{lgtmAPI.endpoint}/"
  $.getJSON( url, { format: 'json' } ).done (data)->
    console.log "Got response", data.markdown
    tab = safari.application.activeBrowserWindow.tabs[getActiveTab()]
    tab.page.dispatchMessage 'lgtmPayload', data.markdown
    return
  return

# Send settings to the injected script
getSettings = ->
  settings =
    'lgtmkey' : safari.extension.settings.lgtmkey

  tab = safari.application.activeBrowserWindow.tabs[getActiveTab()]
  tab.page.dispatchMessage 'setSettings', settings
  return

# Get index of current active tab
getActiveTab = ->
 tabs = safari.application.activeBrowserWindow.tabs
 return i for tab, i in tabs when tab == safari.application.activeBrowserWindow.activeTab

# All command events are handled by this function
handleCommandEvents = (event) ->
  switch event.command
    when "do_lgtm"
      console.log 'LGTM button clicked'
      lgtm()
  return

# All settings events are handled by this function
handleSettingsEvents = (event) ->
  switch event.key
    when "lgtmkey"
      console.log "Changed settings for #{event.key} from #{event.oldValue} to #{event.newValue}"
  return

# All messages between global and injected scripts are handled by this function
handleMessageEvents = (message) ->
  switch message.name
    when 'getSettings'
      getSettings()
    when 'lgtmRequest'
      console.log "Handling shortcut event"
      lgtm()
  return

# Register corresponding handles in the global page
safari.application.addEventListener "command", handleCommandEvents, false
safari.application.addEventListener "message", handleMessageEvents, false
safari.extension.settings.addEventListener "change", handleSettingsEvents, false

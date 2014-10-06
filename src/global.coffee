# lgtm.in
lgtmAPI = {
  scheme: 'http',
  endpoint: 'www.lgtm.in/g'
}

settings = {}

# Fetch json payload from lgtm.in
lgtm = ->
  url = "#{lgtmAPI.scheme}://#{lgtmAPI.endpoint}/"
  $.getJSON( url, { format: 'json' } ).done (data)->
    console.log "Got response", data.markdown
    tab = safari.application.activeBrowserWindow.tabs[getActiveTab()]
    tab.page.dispatchMessage 'lgtmPayload', data.markdown
    return
  return

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

# Register corresponding handles in the global page
safari.application.addEventListener "command", handleCommandEvents, false
safari.extension.settings.addEventListener "change", handleSettingsEvents, false

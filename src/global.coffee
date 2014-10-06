# register do_lgtm command
performCommand = (event) ->
  if event.command == 'do_lgtm'
    console.log "===>> PERFORM LGTM ===>>"
    safari.application.activeBrowserWindow.activeTab.page.dispatchMessage("name", "data");

# register command validation
validateCommand = (event) ->
  #if event.command == 'do_lgtm'
  # console.log "Reserved for more sophisticated lgtm experience"

# register corresponding handles in the global page
safari.application.addEventListener 'command', performCommand, false
safari.application.addEventListener 'validate', validateCommand, false


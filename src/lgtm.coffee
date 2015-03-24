settings = {}

# Apply LGTM markdown to textarea and submit
appendLgtm = (msg) ->
  comment = document.getElementById("new_comment_field")

  if (msg && comment)
    comment.value += "LGTM!\n" + msg

    submit_btn_area = document.getElementById("partial-new-comment-form-actions")

    if submit_btn_area
      submit_btn_area = submit_btn_area.getElementsByClassName("btn-primary")
      submit_btn_area[0].click() if submit_btn_area.length > 0

  return

# Set settings
setSettings = (msg) ->
  settings = msg

isAltKey = (modifier) ->
  switch modifier
    when 'Alt' then true
    when 'alt' then true
    when 'Option' then true
    when 'option' then true
    else false

isCtrlKey = (modifier) ->
  switch modifier
    when 'Ctrl' then true
    when 'ctrl' then true
    else false

isShiftKey = (modifier) ->
  switch modifier
    when 'Shift' then true
    when 'shift' then true
    else false

keyCharToCode = (char) ->
  char.charCodeAt(0) if char

# Handle keyboard shortcut event
keyActionHandler = (e) ->

  [modifier, keyChar] = settings.lgtmkey.split("+")
  keyAction = false

  if modifier and keyChar
    if isAltKey(modifier) and e.altKey
      keyAction = if keyCharToCode(keyChar) is e.keyCode then true
    if isCtrlKey(modifier) and e.ctrlKey
      keyAction = if keyCharToCode(keyChar) is e.keyCode then true
    if isShiftKey(modifier) and e.shiftKey
      keyAction = if keyCharToCode(keyChar) is e.keyCode then true

  safari.self.tab.dispatchMessage 'lgtmRequest' if keyAction

  return

# Generic function to handle all incoming messages
messageHandler = (msg) ->
  switch msg.name
    when 'lgtmPayload'
      appendLgtm msg.message
    when 'setSettings'
      setSettings msg.message
  return

# Add event listener
safari.self.addEventListener "message", messageHandler, false
window.addEventListener "keydown", keyActionHandler, false

# Get settings
safari.self.tab.dispatchMessage 'getSettings', ''
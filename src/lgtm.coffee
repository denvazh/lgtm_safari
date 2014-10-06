console.log 'Loaded injected script - lgtm'

# Apply LGTM markdown to textarea
appendLgtm = (msg)->
  console.log "RECEIVED LGTM payload ==>", msg
  comment = document.getElementById("new_comment_field")
  if comment.value.length is 0
    comment.value = msg
  else
    comment.value += "\n" + msg

  return

# Generic function to handle all incoming messages
messageHandler = (msg)->
  switch msg.name
    when 'lgtmPayload' then appendLgtm msg.message
  return

safari.self.addEventListener "message", messageHandler, false
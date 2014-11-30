console.log 'Loaded injected script - lgtm'

# Apply LGTM markdown to textarea and submit
appendLgtm = (msg)->
  console.log "RECEIVED LGTM payload ==>", msg

  comment = document.getElementById("new_comment_field")

  if (msg && comment)
    comment.value += "LGTM!\n" + msg

    submit_btn_area = document.getElementById("partial-new-comment-form-actions")

    if submit_btn_area
      submit_btn_area = submit_btn_area.getElementsByClassName("primary")
      submit_btn_area[0].click() if submit_btn_area.length > 0

  return

# Generic function to handle all incoming messages
messageHandler = (msg)->
  switch msg.name
    when 'lgtmPayload' then appendLgtm msg.message
  return

safari.self.addEventListener "message", messageHandler, false
jQuery ->
  $('.show-hide-fields').click (e) ->
    e.preventDefault()
    $('.optional-fields').toggle()
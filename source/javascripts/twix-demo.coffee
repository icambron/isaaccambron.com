#= require jquery
#= require moment
#= require twix
#= require jquery.simple-dtpicker

$ ->

  start = null
  end = null
  allDay = false
  range = null

  update = ->
    return unless start? && end?
    range = moment(start).twix(end, allDay)
    console.log range

  $('#start-picker').bind('dateChange', (e, data) ->
    start = data.date
    update()
  ).dtpicker()

  $('#end-picker').bind('dateChange', (e, data) ->
    end = data.date
    update()
  ).dtpicker()

  $('#all-day').change ->
    allDay = $(@).is(':checked')
    update()

#= require vendor/jquery.min.js
#= require vendor/moment.min.js
#= require vendor/twitter-text.js
#= require vendor/timestack.js
#= require bootstrap.js

#= require showDemo

$ ->

  $('body').addClass('js-enabled')

  do ->
    dateParse = (d) ->
      text = d.text()
      m = moment d.text(), 'MMMM YYYY'
      if m.isValid() then m else moment()

    ranges = []
    $('p.date-range').each (i, p) ->
      $p = $ p
      name = $p.attr('data-name').toLowerCase()
      ranges.push
        title: $p.attr 'data-display'
        start: dateParse $p.children('.date-range-start')
        end: dateParse $p.children('.date-range-end')
        class: "timeline-#{name}"
        name: name

    $('#timeline').timestack
      span: 'year'
      dateFormats: {year: 'YYYY'}
      data: ranges
      click: (i) -> window.location.hash = "#{i.name}-job"

    $('.demo-button').showDemo(modal: '#demo-modal')

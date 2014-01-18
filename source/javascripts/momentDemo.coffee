# vi: ft=coffee

#= require jquery
#= require moment
#= require knockout

class MomentWrap
  constructor: ->
    setInterval (=> @setTime()), 1000

    @parsingInput = ko.observable ''
    @parsingOption = ko.observable()

    @parsingOptions = [
      'YYYY-MM-DD',
      'MM/DD/YY',
      'GG-[W]WW-E'
    ]

    @parsingOutput = ko.computed =>
      moment @parsingInput(), @parsingOption()

  setTime: -> @time(moment())

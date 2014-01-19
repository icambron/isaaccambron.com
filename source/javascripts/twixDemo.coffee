# vi: ft=coffee

#= require jquery.min
#= require moment.min
#= require twix
#= require knockout
#= require jquery.simple-dtpicker

class TwixWrap
  constructor: ->
    @start = ko.observable(moment().startOf('day').hours(9))
    @end = ko.observable(moment().add(1, 'days').startOf('day').hours(14))
    @allDay = ko.observable false

    @twix = ko.computed =>
      start = @start()
      end = @end()
      allDay = @allDay()
      if start? && end?
        moment(start).twix(end, allDay)
      else
        null

    @startFormatted = ko.computed =>
      moment(@start()).format("YYYY-MM-DD HH:mm")

    @endFormatted = ko.computed =>
      moment(@end()).format("YYYY-MM-DD HH:mm")

    @maker = ko.computed =>
      "var twix = moment('#{@startFormatted()}', '#{@endFormatted()}');"

class ViewModel

  constructor: ->
    @range = new TwixWrap()

    @demos = ko.computed =>
      twix = @range.twix()
      other = moment().subtract(1, 'week').twix(moment().startOf('day'))

      return [] unless twix?

      tests = [
        {
          name: 'Basic information'
          description: 'Simple information.'
          tests: [
            'twix.isValid()'
            'twix.isPast()'
            'twix.isFuture()'
            'twix.isCurrent()'
            'twix.humanizeLength()'
          ]
        }
        {
          name: 'Length'
          description: 'How long the range lasts.'
          tests: [
            "twix.length()"
            "twix.length('miliseconds')"
            "twix.length('seconds')"
            "twix.length('minutes')"
            "twix.length('hours')"
            "twix.length('days')"
            "twix.length('months')"
            "twix.length('years')"
          ]
        }
        {
          name: 'Count'
          description: 'Count the number of time periods touched by the range'
          tests: [
            "twix.count()"
            "twix.count('miliseconds')"
            "twix.count('seconds')"
            "twix.count('minutes')"
            "twix.count('hours')"
            "twix.count('days')"
            "twix.count('months')"
            "twix.count('years')"
          ]
        }
        {
          name: 'Count inner'
          description: 'Count the number time periods completely contained by the range'
          tests: [
            "twix.countInner('miliseconds')"
            "twix.countInner('seconds')"
            "twix.countInner('minutes')"
            "twix.countInner('hours')"
            "twix.countInner('days')"
            "twix.countInner('months')"
            "twix.countInner('years')"
          ]
        }
        {
          name: 'Iterate'
          description: 'Provide each time period touched by the range'
          tests: [
            "twix.iterate('miliseconds').next()"
            "twix.iterate('seconds').next()"
            "twix.iterate('minutes').next()"
            "twix.iterate('hours').next()"
            "twix.iterate('days').next()"
            "twix.iterate('months').next()"
            "twix.iterate('years').next()"
          ]
        }
        {
          name: 'Iterate Inner'
          description: 'Provide each time period completely contained by the range'
          tests: [
            "twix.iterateInner('miliseconds').next()"
            "twix.iterateInner('seconds').next()"
            "twix.iterateInner('minutes').next()"
            "twix.iterateInner('hours').next()"
            "twix.iterateInner('days').next()"
            "twix.iterateInner('months').next()"
            "twix.iterateInner('years').next()"
          ]
        }
        {
          name: 'Contains'
          description: 'Does the range contain this date?'
          tests: [
            'twix.contains(new Date())'
            "twix.contains(moment().add(20, 'minutes'))"
            "twix.contains(moment().subtract(1, 'day'))"
            "twix.contains(moment().add(1, 'day'))"
            "twix.contains('2013-11-23')"
          ]
        }
        {
          name: 'Simple formating'
          description: 'Unsophisticated range formatting.'
          tests: [
            "twix.simpleFormat()"
            "twix.simpleFormat('MMM DD, YYYY')"
            "twix.simpleFormat('MMMM DD, YYYY HH:MM')"
            "twix.simpleFormat('H:MM')"
          ]
        }
        {
          name: 'Smart formatting'
          description: 'Automatic range formatting.'
          tests: [
            "twix.format()"
            "twix.format({spaceBeforeMeridiem: true})"
            "twix.format({showDate: true})"
            "twix.format({showDayOfWeek: true})"
            "twix.format({twentyFourHour: true})"
            "twix.format({implicitMinutes: false})"
            "twix.format({implicitYears: false})"
            "twix.format({mergeMeridians: false})"
            "twix.format({yearFormat: 'YY'})"
            "twix.format({weekdayFormat: 'dd'})"
            "twix.format({monthFormat: 'MMM'})"
            "twix.format({dayFormat: 'Do'})"
            "twix.format({meridianFormat: 'a'})"
            "twix.format({hourFormat: 'hh'})"
            "twix.format({explicitAllDay: true})"
            "twix.format({lastNightEndsAt: 4})"
          ]
        }
        {
          name: 'Compare ranges'
          description: 'Compare ranges, assuming other is a range from last week until today.'
          tests: [
            'twix.overlaps(other)'
            'twix.engulfs(other)'
            'twix.equals(other)'
          ]
        }
        {
          name: 'Union and intersection'
          description: 'Assuming other is a range from last week until today.'
          tests: [
            'twix.union(other).simpleFormat()'
            'twix.intersection(other).simpleFormat()'
          ]
        }
      ]

      for section in tests
        sectionOutput = {name: section.name, description: section.description}
        sectionOutput.tests = for template in section.tests
          code: template, output: eval(template)
        sectionOutput

ko.bindingHandlers.dtPicker =
  init: (element, valueAccessor) ->
    obs = valueAccessor()
    $(element)
      .bind('dateChange', (e, data) -> obs(data.date))
      .dtpicker(calendarMouseScroll: false, current: obs().toDate())

$ ->
  viewModel = new ViewModel()
  ko.applyBindings viewModel

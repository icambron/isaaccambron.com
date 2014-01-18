# vi: ft=coffee

#= require jquery
#= require moment
#= require timestack
#= require knockout

class ViewModel
  constructor: ->
    @newPeriod = ko.observable()
    @existingPeriods = ko.observableArray()
    @spans = ['year', 'month', 'day', 'hour']

    @span = ko.observable @spans[0]
    @span.subscribe (value) => @reset()

    @reset()

  add: ->
    unless @newPeriod().error()
      @existingPeriods.push @newPeriod()
      @newPeriod Period.default(@span())

  reset: ->
    span = @span()
    @newPeriod Period.default(span)
    @existingPeriods.removeAll()
    @existingPeriods.push Period.example(span)


class Period
  @example = (span) ->
    m = moment()
    [start, end] = switch span
      when 'year'
        a  = [[m.year() - 1, 7], [m.year() + 1, 2]]
        console.log a
        a
      when 'month'
        [[m.year(), 2, 3], [m.year(), 6, 14]]
      when 'day'
        [[m.year(), m.month(), 2, 6], [m.year(), m.month(), 10, 14]]
      when 'hour'
        [[m.year(), m.month(), m.date(), 6, 45], [m.year(), m.month(), m.date(), 17, 30]]

    p = new Period span, moment(start), moment(end)
    p.clazz('demo-default')
    p.title('Demo!')
    p

  @default = (span) ->
    m = moment()
    [start, end] = switch span
      when 'year'
        [[m.year(), 9], [m.year() + 2, 5]]
      when 'month'
        [[m.year(), 5, 26], [m.year(), 11, 3]]
      when 'day'
        [[m.year(), m.month(), 16, 23], [m.year(), m.month(), 24, 12]]
      when 'hour'
        [[m.year(), m.month(), m.date(), 12, 30], [m.year(), m.month(), m.date(), 20, 0]]
    new Period span, moment(start), moment(end)

  constructor: (@span, start, end) ->
    @colors = ['red', 'blue', 'green', 'orange', 'purple']

    @start = new Time @span, start
    @end = new Time @span, end
    @color = ko.observable @colors[0]
    @title = ko.observable 'Things!'
    @clazz = ko.observable()

    @error = ko.computed => @start.value() > @end.value()

    @message = ko.computed =>
      if @error()
        'Start times must be before end times'
      else
        "Duration: #{@start.value().from(@end.value(), @span, true)}"

class Time
  constructor: (@span, t) ->

    @year = ko.observable t.years()
    @month = ko.observable t.months()
    @day = ko.observable t.date()
    @hour = ko.observable t.hour()
    @minute = ko.observable t.minute()

    simpleValues = (arr) -> {value: v, display: v} for v in arr

    @years = simpleValues [2005..2019]
    @months = ({value: m, display: moment().month(m).format('MMM')} for m in [0..11])
    @days = ko.computed =>
      days = moment([@year(), @month()]).daysInMonth()
      simpleValues [1..days]

    @hours = simpleValues [0..23]
    @minutes = simpleValues [0..59]

    @options = ko.computed =>
      year = key: 'year', xs: @years, o: @year
      month = key: 'month', xs: @months, o: @month
      day = key: 'day', xs: @days, o: @day
      hour = key: 'hour', xs: @hours, o: @hour
      minute = key: 'minute', xs: @minutes, o: @minute

      switch @span
        when 'year' then [year, month]
        when 'month' then [month, day]
        when 'day' then [day, hour]
        when 'hour' then [hour, minute]

    @value = ko.computed =>
      moment [@year(), @month(), @day(), @hour(), @minute()]

ko.bindingHandlers.timestack =
  init: (element, valueAccessor) ->
  update: (element, valueAccessor) ->

    obs = valueAccessor()

    periods =
      for v in obs.existingPeriods()
        p = {
          title: v.title()
          start: v.start.value()
          end: v.end.value()
          class: v.clazz()
        }
        p.color = v.color() unless v.clazz()
        p

    $(element).timestack(span: obs.span(), data: periods)

$ ->
  vm = new ViewModel()
  ko.applyBindings vm

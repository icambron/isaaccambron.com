class Tweet
  constructor: (data) ->
    #@text = "<span>#{twttr.txt.autoLink data.text}</span>"
    @text = data.text
    @timestamp = moment data.created_at

class Github
  constructor: (@data) ->
    @type = @data.type
    @timestamp = moment @data.created_at

window.loadExternal = ->

  rxt.importTags()
  bind = rx.bind

  tweets = rx.array()
  github = rx.array()

  update = ->
    $.getJSON "https://s3.amazonaws.com/isaac-as-a-service/isaac.json", (data) =>
      tweets.replace(new Tweet(datum) for datum in data.twitter)
      github.replace(new Github(datum) for datum in data.github)
      setTimeout update, 60 * 1000

  update()

  repo = (r) -> a {href: r.url}, r.name

  $("#twitter").append(
    div bind -> [
      h4 [
        i {class: 'icon-twitter'}
        " Latest tweets"
      ]
      if tweets.length() == 0
        h2 {class: 'icon-spinner icon-spin icon-large loader'}
      else
        ul {class: 'list-group'}, tweets.map (tweet) ->
          li {class: 'list-group-item'}, [
            p {class: 'date'}, tweet.timestamp.fromNow()
            p [
              #span rxt.rawHtml(tweet.text)
              span " " + tweet.text
            ]
          ]
    ]
  )

  $("#github").append(
    div bind -> [
      h4 [
        i {class: 'icon-github'}
        " Github activity"
      ]
      if github.length() == 0
        h2 {class: 'icon-spinner icon-spin icon-large loader'}
      else
        ul {class: 'list-group'}, github.map (github) ->
          d = github.data
          li {class: 'list-group-item'}, [
            p {class: 'date'}, github.timestamp.fromNow()
            switch github.type
              when "IssueCommentEvent"
                p [
                  span " Commented on "
                  repo d.repo
                  span " issue "
                  a {href: d.url}, "##{d.issue.number} - #{d.issue.title}"
                  "."
                ]
              when "PushEvent"
                p [
                  " Pushed #{d.commits} #{if d.commits > 1 then 'commits' else 'commit'} to "
                  repo d.repo
                  "."
                ]
              when "PullRequestEvent"
                p [
                  " Made pull request "
                  a {href: d.url}, "##{d.number} - #{d.title}"
                  span " to "
                  repo d.repo
                  "."
                ]
              else ""
          ]
    ]
  )

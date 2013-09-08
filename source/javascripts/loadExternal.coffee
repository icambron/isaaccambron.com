do ($ = jQuery) ->

  createList = (items, xform) ->
    @each ->
      $obj = $ @
      $obj.empty()

      $ul = $('<ul>').addClass 'list-group'

      for item in items
        $inside = xform item
        $li = $('<li>').addClass('list-group-item').append($inside)
        $ul.append $li

      $obj.append $ul

  date = (item) ->
    $('<p>')
      .addClass('date')
      .text(moment(item.created_at).fromNow())

  $.fn.extend

    loadTwitter: (tweets) ->
      createList.call @, tweets, (item) =>
        [
          date item
          $('<p>').html("<span>#{twttr.txt.autoLink item.text}</span>")
        ]


    loadGithub: (githubery) ->
      createList.call @, githubery, (item) =>

        repo = (r) -> $('<a>').attr('href', r.url).text(r.name)

        content = switch item.type
          when 'IssueCommentEvent'
            [
              'Commented on '
              repo item.repo
              ' issue '
              $('<a>').attr('href', item.url).text("##{item.issue.number} - #{item.issue.title}")
              '.'
            ]
          when 'PushEvent'
            [
              "Pushed #{item.commits} #{if item.commits > 1 then 'commits' else 'commit'} to "
              repo item.repo
              '.'
            ]
          when 'PullRequestEvent'
            [
              'Made pull request '
               $('<a>').attr('href', item.url).text("##{item.number} - #{item.title}")
              ' for '
              repo item.repo
              '.'
            ]
          else ''

        $('<p>').append [date(item)].concat(content)

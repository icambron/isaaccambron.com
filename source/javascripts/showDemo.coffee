do ($ = jQuery) ->

  $.fn.extend
    showDemo: (options) ->
      $modal = $ options.modal
      @each ->
        $obj = $ @

        demo = $obj.attr 'data-demo'

        $obj.click ->

          $frame = $('<iframe>')
            .attr('src', "demos/#{demo}.html")
            .attr('frameborder', '0')
            .attr('width', '100%')

          $header = $modal.find('.modal-header')

          $header.attr('class', "modal-header #{demo}-demo-header")

          $header.find('h2')
            .text("#{demo} Demo")

          $modal
            .find('.modal-body')
            .empty()
            .append($frame)
          $modal.modal('show')

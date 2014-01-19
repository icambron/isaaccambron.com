activate :livereload

activate :blog do |blog|
  blog.prefix = "blog"
  blog.layout = "blog/layout"
end

page '/demos/*', layout: false
page "/blog/feed.xml", layout: false

helpers do
  def date_range(name, starts, ends, display= name)
    "<p class='date-range' data-name='#{name}' data-display='#{display}'><span class='date-range-start'>#{starts}</span> - <span class='date-range-end'>#{ends}</span></p>"
  end

  def github_link(link)
    "<i class='fa fa-github'></i> <a href='http://github.com/icambron/#{link}'>Github</a>&nbsp;"
  end

  def docs_link(link)
    "&nbsp;<i class='fa fa-file'></i> <a href='http://icambron.github.io/#{link}'>Docs</a>"
  end
end

set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true
activate :syntax

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

sprockets.append_path "vendor/javascripts"
sprockets.append_path "vendor/stylesheets"

configure :build do
  activate :minify_css
  activate :minify_javascript
end

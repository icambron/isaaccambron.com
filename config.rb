activate :livereload

activate :blog do |blog|
  blog.prefix = "blog"
  blog.layout = "blog"
  blog.paginate = true
  @tab = "blog"
end

activate :google_analytics do |ga|
  ga.tracking_id = 'UA-52148016-1'
  ga.minify = true
end

page '/demos/*', layout: false
page "/blog/feed.xml", layout: false

page "/" do
  @tab = "about"
end

page "/resume*" do
  @tab = "resume"
end

page "/projects*" do
  @tab = "projects"
end

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

configure :build do
  activate :minify_css
  activate :minify_javascript
  set :js_compressor, Uglifier.new(compress: {loops: false})
end

ready do
  sprockets.append_path "vendor/javascripts"
  sprockets.append_path "vendor/stylesheets"
end

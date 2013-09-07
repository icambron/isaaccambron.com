###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

page '/demos/*', layout: false

# Proxy pages (http://middlemanapp.com/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
activate :livereload

helpers do
  def date_range(name, starts, ends, display= name)
    "<p class='date-range' data-name='#{name}' data-display='#{display}'><span class='date-range-start'>#{starts}</span> - <span class='date-range-end'>#{ends}</span></p>"
  end

  def github_link(link)
    "<i class='icon-github'></i> <a href='http://github.com/icambron/#{link}'>Github</a>"
  end

  def docs_link(link)
    "<i class='icon-file'></i> <a href='http://icambron.github.io/#{link}'>Docs</a>"
  end
end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

sprockets.append_path "vendor/javascripts"
sprockets.append_path "vendor/stylesheets"


# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_path, "/Content/images/"
end

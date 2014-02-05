require "rubygems"

require "rack"
require "rack/contrib/response_headers"
require "rack/contrib/static_cache"
require "rack/contrib/try_static"

require 'newrelic_rpm'

# Build the static site when the app boots
`bundle exec middleman build`

# https://docs.newrelic.com/docs/ruby/no-data-with-unicorn
NewRelic::Agent.after_fork(:force_reconnect => true)


# Properly compress the output if the client can handle it.
use Rack::Deflater

# Set the "forever expire" cache headers for these static assets. Since
# we hash the contents of the assets to determine filenames, this is safe
# to do.
use Rack::StaticCache,
  :root => "build",
  :urls => ["/images", "/javascripts", "/stylesheets"],
  :duration => 2,
  :versioning => false

# For anything that matches below this point, we set the surrogate key
# for Fastly so that we can quickly purge all the pages without touching
# the static assets.
use Rack::ResponseHeaders do |headers|
  headers["Surrogate-Key"] = "page"
end

# Attempt to serve static HTML files
use Rack::TryStatic,
    :root => "build",
    :urls => %w[/],
    :try => ['.html', 'index.html', '/index.html']

# 404 if we reached this point. Sad times.
run lambda { |env|
  [
    404,
    {
      "Content-Type"  => "text/html",
      "Cache-Control" => "public, max-age=60"
    },
    File.open("build/404/index.html", File::RDONLY)
  ]
}

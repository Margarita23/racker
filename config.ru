require "./lib/racker"
use Rack::Session::Cookie, :key => 'my_app_key',
                             :path => '/',
                             :expire_after => 2592000, # In seconds
                             :secret => 'secret_stuff'
use Rack::Static, :urls => ["/stylesheets","/javascript","/images"], :root => "public"
run Racker
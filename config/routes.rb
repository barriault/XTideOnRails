ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)
  map.connect 'tides/:lat/:lng/:year/:month/:day/',
              :controller => 'tides',
              :action     => 'show',
              :requirements => {:lat => /[-+]?([0-9]*\.[0-9]+|[0-9]+)/,
                                :lng => /[-+]?([0-9]*\.[0-9]+|[0-9]+)/,
                                :year  => /(19|20)\d\d/,
                                :month => /[01]?\d/,
                                :day   => /[0-3]?\d/},
              :lat => nil,
              :lng => nil,
              :year => nil,
              :month => nil,
              :day => nil
              
  map.connect 'webservice/tides.:format',
              :controller => 'webservice',
              :action     => 'tides'

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"
  map.connnect '', :controller => 'map'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end

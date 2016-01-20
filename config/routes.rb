Spree::Core::Engine.add_routes do
  namespace :flowlink do
    post '*path', to: 'webhook#consume', as: 'webhook'
  end
end

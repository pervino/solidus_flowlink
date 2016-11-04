Spree::Core::Engine.routes.draw do
  namespace :flowlink do
    post '*path', to: 'webhook#consume', as: 'webhook'
  end
end

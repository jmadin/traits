Traits::Application.routes.draw do
  get 'password_resets/new'

  #get '/imports/show', to: 'imports#show', :as => :show_imports
  match '/imports/approve', to: 'imports#approve', via: ['get', 'post'] , :as => :approve
  match '/imports/:name', to: 'imports#create', :via => :post, :as => :upload
  get '/imports/:name', to: 'imports#new'
  
  resources :imports
  resources :citations
  resources :searches  
  resources :synonyms

  
  get '/history', to:'versions#index'
  get '/history/:version_id', to: 'versions#show'
  post '/revert/:version_id', to: 'versions#revert_back'
  get '/corals/:id/resources', to: 'corals#show'
  get '/traits/:id/resources', to: 'traits#show'
  get '/locations/:id/resources', to: 'locations#show'
  get '/resources/:id/resources', to: 'resources#show'
  

  
  resources :imports


  resources :methodologies
  post '/methodology/:id/trait', to: 'methodologies#remove_trait', :as => :remove_methodology_trait
  resources :methodologies do
    post :export, :on => :collection
  end

  resources :password_resets



  resources :corals do
    post :export, :on => :collection
  end

  resources :corals do
    resources :traits
  end

  resources :locations do
    post :export, :on => :collection
  end

  resources :resources

  resources :standards

  resources :measurements 

  resources :observations do  
      post :update_multiple, :on => :collection
      # get :autocomplete_location_name, :on => :collection
      # get :autocomplete_coral_name, :on => :collection
      # get :autocomplete_resource_author, :on => :collection

      get :update_values, :on => :collection
      get :update_values, :on => :member
      get :update_random, :on => :collection
      get :update_random, :on => :member

  end

  #match ':controller(/:action(/:id))', via: 'get'

  resources :traits do
    post :export, :on => :collection
  end

  resources :entities

  resources :users
  
  resources :sessions,      only: [:new, :create, :destroy]

  root to: 'static_pages#home'
  match '/signup',  to: 'users#new',            via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
  match '/help',    to: 'static_pages#help',    via: 'get'
  match '/about',   to: 'static_pages#about',   via: 'get'
  match '/meta', to: 'static_pages#meta', via: 'get'
  
  


  # dynamic pull-down for trait select
  # match '/update_values', to: 'measurements#update_values', via: 'get'
  

end

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "users#dashboard"

  # for authentication
  get "/signup", to: "users#new"
  post "/signup", to: "users#create"

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  get "/dashboard", to: "users#dashboard"

  # for users
  resources :blogs do
    resources :comments, only: [ :create ]
    resources :likes, only: [ :create ]
  end
  resources :likes, only: [ :destroy ]

 # for admins
 get "admin/users", to: "admin#users", as: "admin_users"
 get "admin/users/:id", to: "admin#show_user", as: "admin_user"
 get "admin/users/:id/edit", to: "admin#edit_user", as: "edit_admin_user"
 patch "admin/users/:id", to: "admin#update_user"
 get "admin/users/:id/activity", to: "admin#user_activity", as: "admin_user_activity"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  # for 404 errors
  match "*path", to: "application#not_found", via: :all
  # match "*path", to: "application#not_found", via: :all
  # match
end

Rails.application.routes.draw do
  resources :inventories
  resources :actual_recipe_reqs
  resources :surgery_appts
  resources :surgery_recipe_reqs
  resources :surgery_types
  resources :clinics
  resources :supply_lists
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
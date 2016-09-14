require "api_constraints"

Rails.application.routes.draw do
  devise_for :users, only: [:session, :password]
  root "projects#index"

  resources :synchronizes, only: [:index, :create]
  resources :columns, only: [:create]
  resources :rows, only: [:create, :destroy]

  resources :projects, only: [:index, :show] do
    resources :product_backlogs
    resources :sprints, only: [:show, :update] do
      resources :work_performances, except: [:new, :create]
    end
  end

  namespace :api do
    resources :sprints
  end

  namespace :admin do
    root "projects#index"
    resources :phases
    resources :projects do
      resources :sprints do
        resources :work_performances, except: [:new, :create]
        resources :time_logs, only: [:create]
      end
    end
  end

  resource :update_product_backlogs

  resources :synchronizes, only: [:index, :create]
  resources :users, except: [:new, :create]
  resources :invite_users
end

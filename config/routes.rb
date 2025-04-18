Rails.application.routes.draw do
  devise_for :users, skip: [ :registrations ]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
  get "profile", to: "users#show", as: "user_profile"
  resources :groups do
    member do
      get :hours
      post :add_employee
      delete :remove_employee
    end
  end
  resources :users, except: [ :show ] do
    member do
      patch :toggle_active
    end
  end
  resources :employees do
    member do
      get :unprocessed_records
    end
    collection do
      get "search"
    end
  end
  resources :attendance_records
  resources :schedules do
    member do
      post :duplicate
    end
  end
  resources :incidents do
    member do
      patch :resolve
    end
  end
  resources :overtime_records
  resources :absences
  resources :reports do
    collection do
      get :employee_report
      get :generate_report
    end
  end

  namespace :admin do
    resource :settings
  end

  resources :payrolls
  resources :devices
  resources :events do
    collection do
      post :import
    end
  end
end

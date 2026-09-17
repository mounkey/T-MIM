Rails.application.routes.draw do
  namespace :superadmin do
    resources :system_settings do
      collection do
        patch :update_multiple
      end
    end
    resources :invoices
    resources :super_admins
    resources :cities
    resources :regions
    resources :accounts do
      member do
        patch :toggle_status
      end
    end
    get "dashboard/index"
  end
  devise_for :super_admins
  devise_for :users
  
  authenticated :user do
    root to: "home#index", as: :authenticated_root
    resources :users, path: "gestion_usuarios" do
      collection do
        get :global_login_history
      end
      member do
        get :change_password
        patch :update_password
        get :login_history
      end
    end
  end

  unauthenticated do
    devise_scope :user do
      root to: "devise/sessions#new", as: :unauthenticated_root
    end
  end

  resources :regions
  resources :cities
  resources :asset_categories
  resources :tags
  resources :providers, path: "proveedores"

  resources :clients, path: "clientes"

  # Renamed path to avoid conflict with Rails asset pipeline (/assets)
  resources :assets, path: "vehiculos" do
    resources :meters, only: [:new, :create, :edit, :update, :destroy]
  end

  resources :logbook, only: [:index, :new, :create, :show], path: "bitacora"
  resources :maintenance_plans, only: [:index, :new, :create], path: "planes_mantenimiento" do
    collection do
      get :components
      get :sub_components
    end
  end

  resources :maintenance_states, only: [:new, :create] do
    collection do
      get :edit_adjustment
      patch :update_adjustment
    end
  end
  get "mantenimiento", to: "maintenance#index", as: :maintenance
  get "reportes/proyeccion", to: "reports#maintenance_projection", as: :maintenance_projection_report

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end

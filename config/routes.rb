BiruWeb::Application.routes.draw do
  resources :biru_users


  resources :employes


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'

#  root :to => 'pages#index'
  root :to => "performances#index"

  get "repairs/index" ,:as => :repairs

  get "renters/index" ,:as => :renters

  get "owners/index" ,:as => :owners

  get "recruitments/index", :as => :recruitments

  get "managements/index", :as => :managements

  get "performances/index", :as => :performances
  get "performances/monthly", :as => :performances_monthly
  get "performances/build_age", :as => :performances_build_age
  get "performances/vacant_day", :as => :performances_vacant_day
  get "performances/tenancy_period", :as => :performances_tenancy_period
  get "login/logout", :as => :logout

#  get "managements/popup_owner/:id", :as => :popup_owner

  get "/recruitments/search_around", :as =>:search_around

  match "managements/bulk_search_file", :as => :bulk_search_file
  match "managements/bulk_search_text", :as => :bulk_search_text

  # ↓これはActiveAdmin.routesよりは下にないと、メンテナンスでeditをする際に適応されて
  # 誤動作してしまう。
  match ':controller(/:action(/:id))'

  get "pages/index"
  get "managements/index", :as => :managements
  match "managements/search_buildings"
  match "managements/search_owners"

end

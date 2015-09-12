BiruWeb::Application.routes.draw do
  get "biru_service/index"

  get "biru_service/map"

  resources :biru_user_monthlies


  get "building_rooms/index"

  resources :biru_users

  #resources :trust_managements


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
  root :to => "pages#index"
  
#  resources :owners

  get "repairs/index" ,:as => :repairs


  get "biru_service/index(/:room_all)" => 'biru_service#index'  ,:as => :biru_service
  get "biru_service/map(/:room_all)" => 'biru_service#map'
  
  get "property/index(/:neighborhood)" => 'property#index' ,:as => :property
  get "property/map(/:neighborhood)" => 'property#map'
  
  get "property/search" => 'property#search' ,:as => :property_search
  
  get "trust_rewinding/index" ,:as => :trust_rewinding

  get "renters/index(/:sakimono)" => 'renters#index' ,:as => :renters
  

  match "renters/update_all", :as =>:renters_update_all
  get "renters/pictures/:id" => "renters#pictures" , :as => :renters_pictures

  get "owners/index" ,:as => :owners

  get "recruitments/index", :as => :recruitments

  get "managements/index", :as => :managements
  get "trust_managements/index", :as => :trust_managements
  get "trust_managements/trust_user_report", :as => :trust_user_report
  get "trust_managements/owner_building_list", :as => :owner_building_list
  
  get "building_rooms/index", :as =>:building_rooms

  get "performances/index", :as => :performances
  get "performances/monthly", :as => :performances_monthly
  get "performances/build_age", :as => :performances_build_age
  get "performances/vacant_day", :as => :performances_vacant_day
  get "performances/tenancy_period", :as => :performances_tenancy_period
  get "login/logout", :as => :logout
  

  get "managements/popup_owner/:id" => 'managements#popup_owner', :as =>:popup_owner
  get "/recruitments/search_around", :as =>:search_around

  match "managements/bulk_search_file", :as => :bulk_search_file
  match "managements/bulk_search_text", :as => :bulk_search_text
  
  get "managements/popup_owner_documents_download/:document_id" => 'managements#popup_owner_documents_download', :as => :popup_owner_documents_download
  
  get "trust_managements/popup_owner_buildings/:owner_id" => 'trust_managements#popup_owner_buildings', :as => :popup_owner_buildings
  get "trust_managements/popup_owner_create" => "trust_managements#popup_owner_create", :as => :popup_owner_create
  
  # trust_management
  get "trust_managements/owner_show/:id" => 'trust_managements#owner_show' , :as => :owner_show
  get "trust_managements/building_show/:id" => 'trust_managements#building_show', :as => :building_show
  #post "trust_managements/owner_update/id" => 'trust_managements#owner_update', :as => :owner_update
  

  # ↓これはActiveAdmin.routesよりは下にないと、メンテナンスでeditをする際に適応されて
  # 誤動作してしまう。
  match ':controller(/:action(/:id))'

  get "pages/index"
  get "managements/index", :as => :managements
  match "managements/search_buildings"
  match "managements/search_owners"

end

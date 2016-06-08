Bioisis::Application.routes.draw do
  get "scatter/download"

  devise_for :users
  get 'welcome/index'
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  match '/welcome/' => 'welcome#index'
  match 'welcome/code_search/', :to => 'welcome#code_search', :as => :bid_search, :via => [:post, :get]  
  match 'welcome/attachment', :to => 'welcome#attachment', :as => :review_attachment
  match '/about/' => 'about#index', :as => :about    
  match '/search/' => 'search#index'  

  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  #
  # Experiments Admin
  #
  match 'search/search_results', :to => 'search#search_results'  
  match 'experiments/admin_list', :to => 'experiments#admin_list'
  match 'submissions/pending', :to => 'submissions#pending'  
  match 'submissions/active', :to => 'submissions#active'    
  match 'experiments/approve/:id', :to => 'experiments#approve', :as => :approve_experiments    
  #
  match 'experiments/:id', :to => 'experiments#update', :via => "put"
  match 'experiments/:id', :to => 'experiments#details'
  match 'welcome/code_search/', :to => 'welcome#code_search', :as => :bid_search  
  match 'experiments/filter/:id', :to => 'experiments#filter'
  match 'experiments/destroy/:id', :to => 'experiments#destroy'   
  match 'experiments/download/:id', :to => 'experiments#download'   
  match 'experiments/create_zip/:id', :to => 'experiments#create_zip', :as => :create_zip
  match 'submissions/code_search/:id', :to => 'submissions#code_search', :as => :code_search     
  match 'experiments/download_data/:id', :to => 'experiments#download_data' 
  match 'experiments/download_original/:id', :to => 'experiments#download_original'
  #
  # Experiments
  #
  resources :experiments
  match 'experiments/:id', :to => 'experiments#details'    
  

  match 'submissions/edit_basic_information/:id', :to => 'submissions#edit_basic_information', :as => :edit_basic_information
  match 'submissions/edit_experimental_details/:id', :to => 'submissions#edit_experimental_details', :as => :edit_experimental_details
  match 'submissions/edit_saxs_parameters/:id', :to => 'submissions#edit_saxs_parameters', :as => :edit_saxs_parameters
  match 'submissions/edit_data_files/:id', :to => 'submissions#edit_data_files', :as => :edit_data_files
  match 'submissions/edit/:id', :to => 'submissions#edit', :as => :submission_edit
  match 'submissions/edit_authors/:id', :to => 'submissions#edit_authors', :as => :edit_authors  
  match 'submissions/edit_genes/:id', :to => 'submissions#edit_genes', :as => :edit_genes
    
  match 'submissions/add_author/:id', :to => 'submissions#add_author', :as => :add_author  
  match 'submissions/add_dammin_model/:id', :to => 'submissions#add_dammin_model', :as => :add_dammin_model
  match 'submissions/add_ensemble_model/:id', :to => 'submissions#add_ensemble_model', :as => :add_ensemble_model  
  match 'submissions/add_gasbor_model/:id', :to => 'submissions#add_gasbor_model', :as => :add_gasbor_model
  match 'submissions/add_gene/:id', :to => 'submissions#add_gene', :as => :add_gene    
  match 'submissions/add_models/:id', :to => 'submissions#add_models', :as => :add_models
  match 'submissions/add_no_model/:id', :to => 'submissions#add_no_model', :as => :add_no_model
  match 'submissions/add_pdb/:id', :to => 'submissions#add_pdb', :as => :add_pdb    
  match 'submissions/add_structural_model/:id', :to => 'submissions#add_structural_model', :as => :add_structural_model

  match 'submissions/remove_file', :to => 'submissions#remove_file'  
  match 'submissions/remove_author/', :to => 'submissions#remove_author', :as => :remove_author   
  match 'submissions/remove_gene/', :to => 'submissions#remove_gene', :as => :remove_gene     

  match 'submissions/dammin_results/:id', :to => 'submissions#save_dammin', :as => :dammin_results
  match 'submissions/gasbor_results/:id', :to => 'submissions#save_gasbor', :as => :gasbor_results
  match 'submissions/structural_models/:id', :to => 'submissions#save_structural', :as => :structural_models
  
  match 'submissions/destroy/:id', :to => 'submissions#destroy_submission', :as => :destroy_submission  
  match 'submissions/destroy_dammin_model/:id', :to => 'submissions#destroy_dammin_model', :as => :destroy_dammin_model  
  match 'submissions/destroy_gasbor_model/:id', :to => 'submissions#destroy_gasbor_model', :as => :destroy_gasbor_model  
  match 'submissions/destroy_structural_model/:id', :to => 'submissions#destroy_structural_model', :as => :destroy_structural_model
  match 'submissions/destroy_ensemble_model/:id', :to => 'submissions#destroy_ensemble_model', :as => :destroy_ensemble_model  
  match 'submissions/destroy_ensemble_pdb/:id', :to => 'submissions#destroy_ensemble_pdb', :as => :destroy_ensemble_pdb
  match 'submissions/destroy_no_model/:id', :to => 'submissions#destroy_no_model', :as => :destroy_no_model  
  
  match 'submissions/save/:id', :to => 'submissions#save', :as => :deposition_save 
  match 'submissions/save_ensemble/:id', :to => 'submissions#save_ensemble', :as => :save_ensemble  
  match 'submissions/save_no_model/:id', :to => 'submissions#save_no_model', :as => :save_no_model
  match 'submissions/save_and_exit/:id', :to => 'submissions#save_and_exit', :as => :save_and_exit  
  match 'submissions/create_guinier', :to => 'submissions#create_guinier', :as => :create_guinier
  
  match 'submissions/destroy_pdb/:id', :to => 'submissions#destroy_pdb', :as => :destroy_pdb  
  resources :submissions  
  
  match 'deposition/:id', :to => 'submissions#edit', :as => :deposition
  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)
  
  match 'deposition/add_iofq_file/:data_directory', :to => 'submissions#add_iofq_file', :as => :add_iofq_file
  match 'deposition/upload_iofq_file/:id', :to => 'submissions#upload_iofq_file'  

  match 'deposition/add_pofr_file/:data_directory', :to => 'submissions#add_pofr_file', :as => :add_pofr_file      
  match 'deposition/remove_pofr_file/:data_directory', :to => 'submissions#remove_pofr_file', :as => :remove_pofr_file      
  match 'deposition/upload_pofr_file/:data_directory', :to => 'submissions#upload_pofr_file', :as => :upload_pofr_file      
  
  #
  # News
  #
  match 'news/articles/', :to => 'news#articles', :as => :news_articles
  match 'news/updates/', :to => 'news#updates', :as => :news_updates  
  match 'news/general_info/', :to => 'news#general_info', :as => :news_general_info
  match 'news/reviews/', :to => 'news#reviews', :as => :news_reviews
  resources :news  

  #
  # Tutorial
  #
  match 'tutorial', :to => 'tutorials#index'
  match 'tutorial_path/sendform', :to => 'tutorials#sendform'
  match 'tutorial/:id', :to => 'tutorials#show', :as => :tutorialshow
  #
  # Experimental Links
  #
  match 'experimental_links/destroy/:id', :to => 'experimental_links#destroy'
  match 'experimental_links/:id', :to => 'experimental_links#show'
  resources :experimental_links
  
  resources :experiments do
    member do 
      get :download_data
      get :download      
    end
  end    
  
  match 'users/index', :to => 'users#index', :as => :all_users
  match 'users/:id', :to => 'users#edit', :as => :edit_user  
  match 'users/destroy/:id', :to => 'users#destroy', :as => :destroy_user  
  match 'users/update/:id', :to => 'users#update', :as => :update_user   
  
  get 'scatter', to: 'scatter#request_download' 
  match 'scatter_downloads', :to => 'scatter#download'
  match 'scatter/thank_you', :to => 'scatter#thank_you' 
  match 'scatter/create', :to => 'scatter#create', :as => :scatter_updates
  
  resources :scatter
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
   root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

   
  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

# config/routes/api/v2.rb
Foreman::Application.routes.draw do

  namespace :api, :defaults => {:format => 'json'} do

    # routes that didn't change in v2 and point to v1
    scope :module => :v1, :constraints => ApiConstraints.new(:version => 2) do

      resources :architectures, :except => [:new, :edit]
      resources :audits, :only => [:index, :show]
      resources :auth_source_ldaps, :except => [:new, :edit]
      resources :bookmarks, :except => [:new, :edit]
      resources :common_parameters, :except => [:new, :edit]
      # add "constraint" that unconstrained and allows :id to have dot notation ex. sat.redhat.com
      constraints(:id => /[^\/]+/) do
        resources :domains, :except => [:new, :edit]
        resources :hosts, :except => [:new, :edit] do
          resources :reports       ,:only => [:index, :show] do
            get :last, :on => :collection
          end
          resources :audits        ,:only => :index
          resources :facts         ,:only => :index, :controller => :fact_values
          get :status, :on => :member
        end
        resources :compute_resources, :except => [:new, :edit] do
          resources :images, :except => [:new, :edit]
        end
      end
      resources :dashboard, :only => [:index]
      resources :statistics, :only => [:index]
      resources :environments, :except => [:new, :edit] do
        resources :smart_proxies, :only => [] do
          post :import_puppetclasses, :on => :member
        end
      end
      resources :fact_values, :only => [:index]
      resources :hostgroups, :except => [:new, :edit]
      resources :lookup_keys, :except => [:new, :edit]
      resources :media, :except => [:new, :edit]
      resources :models, :except => [:new, :edit]
      resources :operatingsystems, :except => [:new, :edit] do
        member do
          get 'bootfiles'
        end
      end
      resources :ptables, :except => [:new, :edit]
      resources :roles, :except => [:new, :edit]
      resources :reports, :only => [:index, :show, :destroy] do
        get :last, :on => :collection
      end
      resources :settings, :only => [:index, :show, :update]
      resources :smart_proxies, :except => [:new, :edit] do
        put :refresh, :on => :member
        post :import_puppetclasses, :on => :member
        resources :environments, :only => [] do
          post :import_puppetclasses, :on => :member
        end
      end
      resources :subnets, :except => [:new, :edit]
      resources :usergroups, :except => [:new, :edit]
      resources :users, :except => [:new, :edit]
      resources :template_kinds, :only => [:index]

      match '/', :to => 'home#index'
      match 'status', :to => 'home#status', :as => "status"
    end

    # new v2 routes that point to v2
    scope :module => :v2, :constraints => ApiConstraints.new(:version => 2) do

      resources :config_templates, :except => [:new, :edit] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        collection do
          get 'build_pxe_default'
          get 'revision'
        end
        resources :template_combinations, :only => [:index, :create]
      end
      resources :template_combinations, :only => [:show, :destroy]
      resources :reports, :only => [:create]

      resources :compute_resources, :only => [] do
        get :available_images, :on => :member
      end

      constraints(:id => /[^\/]+/) do
        resources :hosts, :only => [] do
          get :puppetrun, :on => :member
          post :facts, :on => :collection
          put 'power', :on => :member
          put 'boot' , :on => :member

          resources :parameters, :except => [:new, :edit] do
            collection do
              delete '/', :to => :reset
            end
          end
          resources :puppetclasses, :except => [:new, :edit]
          resources :host_classes, :path => :puppetclass_ids, :only => [:index, :create, :destroy]
          resources :interfaces, :except => [:new, :edit]
          resources :smart_variables, :except => [:new, :edit, :create] do
            resources :override_values, :except => [:new, :edit]
          end
          resources :smart_class_parameters, :except => [:new, :edit, :create] do
            resources :override_values, :except => [:new, :edit]
          end
        end

        resources :domains, :only => [] do
          (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
          (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
          resources :parameters, :except => [:new, :edit] do
            collection do
              delete '/', :to => :reset
            end
          end
        end

        resources :compute_resources, :only => [] do
          (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
          (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        end
      end

      resources :subnets, :only => [] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
      end

      resources :environments, :only => [] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        resources :smart_class_parameters, :except => [:new, :edit, :create] do
          resources :override_values, :except => [:new, :edit]
        end
        resources :puppetclasses, :except => [:new, :edit] do
          resources :smart_class_parameters, :except => [:new, :edit, :create] do
            resources :override_values, :except => [:new, :edit]
          end
        end
      end

      resources :hostgroups, :only => [] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        resources :parameters, :except => [:new, :edit] do
          collection do
            delete '/', :to => :reset
          end
        end
        resources :smart_variables, :except => [:new, :edit, :create] do
          resources :override_values, :except => [:new, :edit]
        end
        resources :smart_class_parameters, :except => [:new, :edit, :create] do
          resources :override_values, :except => [:new, :edit]
        end
        resources :puppetclasses, :except => [:new, :edit]
        resources :hostgroup_classes, :path => :puppetclass_ids, :only => [:index, :create, :destroy]
      end

      resources :smart_proxies, :only => [] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
      end

      resources :users, :only => [] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
      end

      resources :media, :only => [] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
      end

      resources :operatingsystems, :only => [] do
        resources :parameters, :except => [:new, :edit] do
          collection do
            delete '/', :to => :reset
          end
        end
      end

      resources :puppetclasses, :except => [:new, :edit] do
        resources :smart_variables, :except => [:new, :edit] do
          resources :override_values, :except => [:new, :edit]
        end
        resources :smart_class_parameters, :except => [:new, :edit, :create] do
          resources :override_values, :except => [:new, :edit]
        end
        resources :environments, :only => [] do
          resources :smart_class_parameters, :except => [:new, :edit, :create] do
            resources :override_values, :except => [:new, :edit]
          end
        end
        resources :hostgroups, :only => [:index]
      end

      resources :smart_variables, :except => [:new, :edit] do
        resources :override_values, :except => [:new, :edit]
      end
      resources :smart_class_parameters, :except => [:new, :edit, :create] do
        resources :override_values, :except => [:new, :edit]
      end
      resources :override_values, :only => [:update, :destroy]

      if SETTINGS[:locations_enabled]
        resources :locations, :except => [:new, :edit] do

          # scoped by location
          resources :domains, :only => [:index, :show]
          resources :subnets, :only => [:index, :show]
          resources :hostgroups, :only => [:index, :show]
          resources :environments, :only => [:index, :show]
          resources :users, :only => [:index, :show]
          resources :config_templates, :only => [:index, :show]
          resources :compute_resources, :only => [:index, :show]
          resources :media, :only => [:index, :show]
          resources :smart_proxies, :only => [:index, :show]

          # scoped by location AND organization
          resources :organizations, :except => [:new, :edit] do
            resources :domains, :only => [:index, :show]
            resources :subnets, :only => [:index, :show]
            resources :hostgroups, :only => [:index, :show]
            resources :environments, :only => [:index, :show]
            resources :users, :only => [:index, :show]
            resources :config_templates, :only => [:index, :show]
            resources :compute_resources, :only => [:index, :show]
            resources :media, :only => [:index, :show]
            resources :smart_proxies, :only => [:index, :show]
          end

        end
      end

      if SETTINGS[:organizations_enabled]
        resources :organizations, :except => [:new, :edit] do

          # scoped by organization
          resources :domains, :only => [:index, :show]
          resources :subnets, :only => [:index, :show]
          resources :hostgroups, :only => [:index, :show]
          resources :environments, :only => [:index, :show]
          resources :users, :only => [:index, :show]
          resources :config_templates, :only => [:index, :show]
          resources :compute_resources, :only => [:index, :show]
          resources :media, :only => [:index, :show]
          resources :smart_proxies, :only => [:index, :show]

          # scoped by location AND organization
          resources :locations, :except => [:new, :edit] do
            resources :domains, :only => [:index, :show]
            resources :subnets, :only => [:index, :show]
            resources :hostgroups, :only => [:index, :show]
            resources :environments, :only => [:index, :show]
            resources :users, :only => [:index, :show]
            resources :config_templates, :only => [:index, :show]
            resources :compute_resources, :only => [:index, :show]
            resources :media, :only => [:index, :show]
            resources :smart_proxies, :only => [:index, :show]
          end

        end
      end
    end

    match '*other', :to => 'v1/home#route_error', :constraints => ApiConstraints.new(:version => 2)
  end

end

Rails.application.routes.draw do
  get 'project/:username/:project_name/list', to: 'project#list'
  get 'project/:username/:project_name/stats', to: 'project#stats'

  get 'welcome/index'

  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

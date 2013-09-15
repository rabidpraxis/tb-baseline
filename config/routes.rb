TbBaseline::Application.routes.draw do
  resources :trace_sessions

  root to: "trace_sessions#index", only: [:index, :create, :delete]
end

Rails.application.routes.draw do
  post "webhook" => "stripe#webhook"

  get "up" => "rails/health#show", as: :rails_health_check
end

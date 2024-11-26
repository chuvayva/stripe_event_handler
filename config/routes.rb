require "sidekiq/web"

Rails.application.routes.draw do
  post "webhook" => "stripe#webhook"

  get "up" => "rails/health#show", as: :rails_health_check

  mount Sidekiq::Web => "/sidekiq"

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    "#{username}:#{password}" == Rails.application.credentials.dig(:sidekiq, :auth)
  end
end

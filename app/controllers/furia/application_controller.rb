module Furia
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    layout "furia/application"
  end
end

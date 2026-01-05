module Furia
  class Engine < ::Rails::Engine
    isolate_namespace Furia

    initializer "furia.assets.precompile" do |app|
      app.config.assets.precompile += %w[
        furia/application.css
        furia/application.js
      ]
    end
  end
end

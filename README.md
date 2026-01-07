# Furia

A tool for logging SQL requests in a part of the code

### Installation

Add this line to your application's Gemfile:
```ruby
gem 'furia'
```

Create and run the migration:
```bash
bundle exec rake furia:install:migrations
bundle exec rake db:migrate
```

Mount the engine in your `routes.rb`:
```ruby
MyApp::Application.routes.draw do
  mount Furia::Engine => "/furia" unless Rails.env.production?
end
```

### Usage

Just wrap the code you want to monitor with the `Furia.wrap`:
```ruby
Furia.wrap("users") do
  User.all
end
```

It also supports nested scopes:
```ruby
Furia.wrap("user") do
  u = User.first

  comments =
    Furia.wrap("comments") do
      u.comments
    end
end
```

Then open `http://localhost:3000/furia` and you'll see all the samples there.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Open a new Pull Request

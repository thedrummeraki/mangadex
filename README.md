[![Docker Image CI](https://github.com/thedrummeraki/mangadex/actions/workflows/docker-image.yml/badge.svg)](https://github.com/thedrummeraki/mangadex/actions/workflows/docker-image.yml)<a href="https://rubygems.org/gems/mangadex"><img src="https://badgen.net/rubygems/v/mangadex" /></a>

# Mangadex

Welcome to `mangadex`, your next favourite Ruby gem for interacting with [Mangadex](https://mangadex.org).

## Important information

**By using this gem you accept**:

- To **credit [Mangadex](https://mangadex.org)**. This gem is your friendly neighbourhood wrapper on _their_ API.
- To **credit scanlation groups**, especially if you offer the ability to read chapters.
- **Not to run any ads** on the service that will use this gem. Please do not make money off of Mangadex's services.

These are Mangadex's [rules](https://api.mangadex.org/docs.html#section/Acceptable-use-policy), please follow them.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mangadex'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mangadex

## Usage

Please note that I tried my best to follow Mangadex's naming conventions for [their documentation](https://api.mangadex.org). Track the progress [here in an issue](https://github.com/thedrummeraki/mangadex/issues/5).
Although a work a in progress, feel free to [check this out](lib/mangadex).

### Basic Usage

Here's a couple of cool things you can do with the gem:

#### Get a list of manga

```ruby
response = Mangadex::Manga.list
manga = response.data # Array of #<Mangadex::Manga>
```

#### Get a manga by id, with cover_art

```ruby
manga_id = 'd86cf65b-5f6c-437d-a0af-19a31f94ec55'
response = Mangadex::Manga.get(manga_id, includes: :cover_art)
entity = response.data # Object of #<Mangadex::Manga>

# Original size
entity.cover_art.image_url(size: :original)
entity.cover_art.image_url(size: :medium)
entity.cover_art.image_url(size: :small) # default size
```

#### Get a manga's chapter list, ordered by volume and chapter number

```ruby
manga_id = 'd86cf65b-5f6c-437d-a0af-19a31f94ec55'
manga_response = Mangadex::Manga.get(manga_id, includes: :cover_art)
entity = manga_response.data

chapter_response = Mangadex::Chapter.list(
  manga: entity.id,
  order: { volume: 'asc', chapter: 'asc' },
  translated_language: 'en',
)
chapters = chapter_response.data # Array of #<Mangadex::Chapter>
```

#### Get a chapter's pages

```ruby
chapter_id = 'e7bb1892-7f83-4a89-bccc-0d6d403a85fc'
chapter = Mangadex::Chapter.get(chapter_id).data
pages = chapter.page_urls # Data saver true by default
```

#### Search for manga by title

```ruby
response = Mangadex::Manga.list(title: 'Ijiranaide nagatoro')
found_manga = response.data
```

#### Authenticate

with a block...:

```ruby
Mangadex::Auth.login(username: 'username', password: 'password') do |user|
  # `user` is of type Mangadex::Api::User
  puts(user.mangadex_user_id)
  puts(user.session)
  puts(user.refresh)
  puts(user.session_valid_until)
end
```

...or inline...:

```ruby
# `user` is of type Mangadex::Api::User
user = Mangadex::Auth.login(username: 'username', password: 'password')

puts(user.mangadex_user_id)
puts(user.session)
puts(user.refresh)
puts(user.session_valid_until)
```

You can access the authenticated user by using context:

```ruby
user = Mangadex.context.user
```

#### Refresh the user's token

```ruby
Mangadex.context.user.refresh_session! do |user|
  # `user` is of type Mangadex::Api::User
  puts(user.mangadex_user_id)
  puts(user.session)
  puts(user.refresh)
  puts(user.session_valid_until)
end
```

#### Create an public MDList, add then remove a manga

```ruby
Mangadex::Auth.login(...)
response = Mangadex::CustomList.create(name: 'My awesome list!', visibility: 'public')
custom_list = response.data

manga_id = 'd86cf65b-5f6c-437d-a0af-19a31f94ec55'
# Add the manga
custom_list.add_manga(manga_id)

# Remove the manga
custom_list.remove_manga(manga_id)

# Get manga list
manga = custom_list.manga_details.data # Array of #<Mangadex::Manga>
```

### Are you on Rails?

This gem tries its best to be agnostic to popular frameworks like Rails. Here's however a couple of things to can do to integrate the gem to your project.

First, add the gem to your `Gemfile`.

#### Configurating the gem

Create a initilizer file to `config/initializers/mangadex.rb`. You can add the following:

```ruby
Mangadex.configure do |config|
  # Override the default content ratings
  config.default_content_ratings = %w(safe suggestive)

  # Override the Mangadex API URL (ie: proxy)
  config.mangadex_url = 'https://my-proxy-mangadex-url.com'
end
```

#### Authenticate your users

This could be useful if you want to support authentication. You will need to persist your user's session, refresh token and session expiry date.

##### Persist the user information

If you haven't done so, create your user.

```ruby
class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :mangadex_user_id, null: false
      t.string :username
      t.string :session
      t.string :refresh
      t.datetime :session_valid_until

      t.timestamps
    end
  end
end

```

Already created your `User` class? Make sure it has all of the following:

- `mangade_user_id`: ID used to identify your user on Mangadex
- `username`: Your username
- `session`: The session token (valid for 15 minutes)
- `refresh`: The refresh token, used to refresh the session (valid for 1 month)
- `session_valid_until`: The time `session` session expires at

If anything is missing, create a migration.

#### Authentication flow on the controller

Add these methods to your controller's helper (ie: `ApplicationHelper`):

```ruby
module ApplicationHelper
  def current_user
    @current_user ||= User.find_by(id: session[:id])
  end

  def logged_in?
    current_user.present?
  end

  def log_in(user)
    # `user` is an instance of your `User` class
    session[:id] = user.id6
  end

  def log_out
    # Logout from Mangadex
    Mangadex::Auth.logout

    # Remove the session
    session.delete(:id)
  end
end
```

First make sure `ApplicationController` includes the helper above

```ruby
class ApplicationController < ActionController::Base
  include ApplicationHelper

  # ...
end
```

We recommend creating a controller for authentication. Here's how you can implement the login and logout actions:

```ruby
# app/controllers/session_controller.rb
class SessionController < ApplicationController
  # GET /login
  def new
    # render the login form
  end

  # POST /login
  def create
    username = params[:username]
    password = params[:password]

    # You can also use `email` instead of `username` to log in
    user = Mangadex::Auth.login(username: username, password: password) do |mangadex_user|
      # Find the user by mangadex user id (or initialize if it doesn't exist)
      our_user = User.find_or_initialize_by(mangadex_user_id: mangadex_user.mangadex_user_id) do |new_user|
        new_user.username = mangadex_user.data.username
      end

      # Update the session info data
      our_user.session = mangadex_user.session
      our_user.refresh = mangadex_user.refresh
      our_user.session_valid_until = mangadex_user.session_valid_until

      # ...then save the user
      our_user.save!
      our_user
    end

    # `user` will be an instance of your `User` class
    # Now, we can log in then redirect to the root.
    log_in(user)
    redirect_to(root_path)
  rescue Mangadex::Errors::AuthenticationError => error
    # See https://api.mangadex.org/docs.html to learn more about errors
    Rails.logger.error(error.response.errors)

    # Handle authentication errors here
  end

  # DELETE /logout
  def destroy
    log_out

    redirect_to(root_path)
  end
end
```

Finally, add the routes.

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # ...
  get '/login' => 'session#new'
  post '/login' => 'session#create'
  delete '/logout' => 'session#destroy'
end
```

#### Protected resources

Here's an example of a controller that requires every action to be logged in. This is based on the steps above.

```ruby
class ProtectedController < ApplicationController
  before_action :ensure_logged_in!

  private

  def ensure_logged_in!
    return if logged_in?

    redirect_to(login_path) # go to /login
  end
end
```

We're going with managing (list, create, show, edit, delete) MDLists (ie: custom lists). **We're not using strong params below to keep things simple, but you should, especially when mutating data (ie: creating and editing)**.

```ruby
class CustomListsController < ProtectedController
  # GET /custom_list
  def index
    @custom_lists = Mangadex::CustomList.list
  end

  # GET /custom_list/new
  def new
    # new custom list form
  end

  # POST /custom_list
  def create
    @custom_list = Mangadex::CustomList.create(
      name: params[:name],
      visibility: params[:visibility],
      manga: params[:manga], # Manga ID
    )
  end

  # GET /custom_list/<id>
  def show
    @custom_list = Mangadex::CustomList.get(params[:id])
  end

  # GET /custom_list/<id>/edit
  def edit
    @custom_list = Mangadex::CustomList.get(params[:id])
    # edit custom list form
  end

  # PUT /custom_list/<id>
  # PATCH /custom_list/<id>
  def update
    # Note: when updating the custom list, be sure to pass in
    # the current version number!
    @custom_list = Mangadex::CustomList.update(
      params[:id],
      {
        name: params[:name],
        visibility: params[:visibility],
        manga: params[:manga],
        version: params[:version].to_i,
      }
    )
  end

  # DELETE /custom_list/<id>
  def destroy
    Mangadex::CustomList.delete(params[:id])
  end
end
```

## Development

### Docker

You can use Docker to get started with dev work on the repo. After installing Dcoker, you can build the image:

```
docker build -t mangadex .
```

Then run the ruby console with the gem loaded

```
docker run --rm -it mangadex:latest
```

You can also log in directly when setting the `MD_USERNAME` and `MD_PASSWORD` (or `MD_EMAIL`) environment variables:

```
docker run --rm -e MD_USERNAME=username -e MD_PASSWORD=password -it mangadex:latest
```

### Locally

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

You can also

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/thedrummeraki/mangadex. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mangadex project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/thedrummeraki/mangadex/blob/master/CODE_OF_CONDUCT.md).

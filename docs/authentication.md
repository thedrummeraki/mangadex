# 🔒 Authenticating with Mangadex

## Beforehand

Any actions that can be performed on the mangadex site as a non authenticated user will not require a user to be logged
in. Authentication on Mangadex, as per version
<a href="https://rubygems.org/gems/mangadex"><img src="https://badgen.net/rubygems/v/mangadex" /></a>
will need an `Authorization` HTTP header to be present.

You can check details on the Mangadex API here: https://api.mangadex.org/docs.html#section/Authentication

## Authentication & Authorization flow

The authentication flow happens as such:

1. You login with your email or username, and password.
2. Upon successfully _authenticating_ your account, you will be given a `session` and a `refresh` tokens.
3. You must use the `session` token to _authorize_ your account to perform certain actions (ie: create resources, etc.)
4. You must use the `refresh` token to refresh the `session` when expired.

> - The `session` token expires **15 minutes** after been granted.
> - The `refresh` token refreshes **1 month** after been granted.

## Authentication using `mangadex` gem

Now that the basics of authentication have been covered, let's go over how it's done on with the gem.

### Logging in

It's simple to login, whether with your email address or your email address:

```ruby
# With your username
Mangadex::Auth.login(username: username, password: password)

# With your email address
Mangadex::Auth.login(email: email, password: password)
```

Upon successful authentication, an instance of `Mangadex::Api::User` will be returned:

```ruby
user = Mangadex::Auth.login(...)

# The session token, valid for 15 minutes (String).
user.session

# The refresh token, valid for 1 month (String)
user.refresh

# The logged in user's ID (String) (formatted as a UUID)
user.mangadex_user_id

# Time at the which user.session becomes invalid (Time)
user.session_valid_until

# Miscellaneaous data. When logging in, it's an instance of Mangadex::User
# (response from the server)
user.data
```

```ruby
# Refreshes the tokens now (Boolean)
user.refresh!

# Refreshes the tokens if expired, then return user itself (Mangadex::Api::User)
user.with_valid_session

# Returns if user.session has expired (Boolean)
user.session_expired?
```

If there's an error, `Mangadex::Errors::AuthenticationError` will be raised. Here's how to handle that scenario:

```ruby
def login(email, password)
  Mangadex::Auth.login(email: email, password: password)
rescue Mangadex::Errors::AuthenticationError => error
  response = error.response

  # A list of detailed errors from Mangadex. (Array of
  # Mangadex::Api::Response::Error)
  response.errors.each do |error|
    puts error.id
    puts error.status
    puts error.title
    puts error.detail
  end
end
```

### Authenticating requests

When the user is logged in, all subsequent requests _should_ be authenticated. Here's an example to retrieve a list of manga that the logged in user is _reading_ at the moment:

```ruby
user = Mangadex::Auth.login(...)
response = Mangadex::Manga.all_reading_status('reading')
manga_ids = response['statuses'].keys

reading_now = Mangadex::Manga.list(ids: manga_ids)
```

If for whatever reason you want to a request not to be authenticated, you can do something like:

```ruby
Mangadex.context.without_user do
  # your mangadex request(s) here
end
```

When logging in, the user's session information will be persisted in the storage. See below [for more details]().

### Logging out

Logging the user out is very easy:

```ruby
Mangadex::Auth.logout
```

Here, the `user`'s session will be revoked on Mangadex. It will try to delete the user's session. `Mangadex::Auth.logout` outside of the `with_user` block will not do anything.

This action also clears the context's user and the storage info associated to this user.

## Persisting the user session: storage stragegies

### What is this?

Using this gem should help you a little bit managing tokens. By default, the gem stores the following information in memory:

- For a particular user ID:
  - User session
  - User refresh token
  - User session expiry date

### Why is this a thing?

Good question. We want to make session management with this gem as easy as possible. The session is used to retrieve a valid logged in user. Here's how it works:

- When the user logs in, the refresh token, the session token (as well as it's expired date) are stored for that user
- When requesting the tokens for the user, a `Mangadex::Api::User` is created with refreshed tokens (if expired).
- When logging out, if implemented by you, the users's session details are deleted.

Here's you retrieve a user from your storage at any point:

```ruby
mangadex_user_id = '...'
Mangadex::Api::User.from_storage(mangadex_user_id)
```

It's up to you to decide how you store the user ID. You don't need to worry about saving the storage, the gem takes care of that for you.

### Ok, ok. How can I use my own strategy?

By default, this gem ships with `Mangagex::Storage::Memory` which corresponds to the in-memory storage. This should be fine if you don't care much about persisting the user session at any point.

No assumptions can be made on which storage service you use. That is 100% up to you how the information is stored. Let's say you want to use [redis](https://github.com/redis/redis) for session instead of the default memory storage stragery:

```ruby
require 'redis'

class BasicRedisStragery < Mangadex::Storage::Basic
  # Must be implemented
  def get(mangadex_user_id, key)
    client.hget(mangadex_user_id, key)
  end

  # Must be implemented
  def set(mangadex_user_id, key, value)
    client.hset(mangadex_user_id, key, value)
  end

  # Optional - It's a nice-to-have, especially for logging out.
  def clear(mangadex_user_id)
    client.del(mangadex_user_id)
  end

  private

  def client
    @client ||= Redis.new(url: 'redis://localhost')
  end
end

# Let the gem know which strategy needs to be used
Mangadex.configuration.storage_class = BasicRedisStragery
```

> On Rails, you can put this inside an initializer. Example: `config/initializers/mangadex.rb`.

The snippet of code is an example of how a storage strategy is implemented. It's important to make sure that neither `get` nor `set` raise exceptions.

> - We recommend using redis if you're developing a web app or a bot where authentication is involed.
> - You can even use a the filesystem if you're building a CLI (command line interface).
> - We **do not** recommend using SQL at the moment. This might be hard on your app's performance...

### Can I opt-out?

Of course. Set `Mangadex::Storage::None` as the prefered strategy:

```ruby
# Either
Mangadex.configure do |config|
  config.storage_class = Mangadex::Storage::None
end

# Or
Mangadex.configuration.storage_class = Mangadex::Storage::None
```

## About content ratings

Each manga/chapter has a content rating (`safe`, `suggestive`, `erotica` and `pornographic`). It might be worth filtering certain titles depending on the audiance. By default, Mangadex filters out every `pornographic` entry.

Please note that content rating is not tied to the user at the moment on Mangadex. So it was decided **not** to add this responsiblity on this gem. Instead, the content ratings can be specified on context gem as well, like this:

```ruby
# Everything but "suggestive" content - this is an example :p
mangas = Mangadex::Api::Content.allow_content_rating('safe', 'erotica', 'pornographic') do
  response = Mangadex::Manga.list
  response.data
end
```

The advantage of this approach is that you don't have to set the `content_rating` param yourself everywhere.

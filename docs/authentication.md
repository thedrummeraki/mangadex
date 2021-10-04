# Authenticating with Mangadex

## Beforehand

Any actions that can be performed on the mangadex site as a non authenticated user will not require a user to be logged
in. Authentication on Mangadex, as per version
<a href="https://rubygems.org/gems/mangadex"><img src="https://badgen.net/rubygems/v/mangadex" /></a>
will need an `Authorization` HTTP header to be present.

You can check details on the Mangadex API here: https://api.mangadex.org/docs.html#section/Authentication

## Authentication & Authorization flow

The authentication flow happens as such:

1. You login with your email or username, and password.
2. Upon successful _authenticating_ your account, you will be given a `session` and a `refresh` tokens.
3. You must use the `session` token to _authorize_ your account to perform certain actions (ie: create resources, etc.)
4. You must use the `refresh` token to refresh the `session` when expired.

The `session` token expires 14 minutes after been granted. The `refresh` token refreshes 1 month after been granted.

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

Upon successful logging in, an instance of `Mangadex::Api::User` will be returned.

```ruby
user = Mangadex::Auth.login(...)

user.session # The session token, valid for 15 minutes (String).
user.refresh # The refresh token, valid for 1 month (String)
user.mangadex_user_id # The logged in user's ID (String) (formatted as a UUID)
user.session_valid_until # Time at the which user.session becomes invalid (Time)
user.data # Miscellaneaous data. When logging in, it's an instance of Mangadex::User (response from the server)

user.refresh! # Refreshes the tokens now (Boolean)
user.with_valid_session # Refreshes the tokens if expired, then return user itself (Mangadex::Api::User)
user.session_expired? # Returns if user.session has expired (Boolean)
```

If there's an error, `Mangadex::Errors::AuthenticationError` will be raised. Here's how to handle that scenario:

```ruby
def login(email, password)
  Mangadex::Auth.login(email: email, password: password)
rescue Mangadex::Errors::AuthenticationError => error
  response = error.response

  response.errors # A list of detailed errors from Mangadex. (Array of Mangadex::Api::Response::Error)
end
```

### Authenticating requests

Once you've succesfully logged your user in, you'll want to authenticate certain requests. Here's an
example to retrieve a list of manga that the logged in user is _reading_ at the moment:

```ruby
user = Mangadex::Auth.login(...)

reading_now = Mangadex.context.with_user(user) do
  response = Mangadex::Manga.all_reading_status('reading')
  manga_ids = response['statuses'].keys

  Mangadex::Manga.list(ids: manga_ids)
end
```

> Note: Setting `Mangadex.context.with_user(...)` will make it so that every request is authorized with that user's `session` token.

### About content ratings

Each manga/chapter has a content rating (`safe`, `suggestive`, `erotica` and `pornographic`). It might be
worth filtering certain titles depending on the audiance. By default, Mangadex filters out every
`pornographic` entry.

Please note that content rating is not tied to the user at the moment on Mangadex. So it was decided **not** to add this responsiblity on this gem. Instead, the content ratings can be specified on context gem as well, like this:

```ruby
# No suggestive content - this is an example :p
mangas = Mangadex::Api::Content.allow_content_rating('safe', 'erotica', 'pornographic') do
  response = Mangadex::Manga.list
  response.data
end
```

The advantage of this approach is that you don't have to set the `content_rating` param yourself
everywhere.

More on how content ratings work [here]().

### Logging out

Logging the user out is very easy:

```ruby
Mangadex.context.with_user(user) do
  Mangadex::Auth.logout
end
```

Here, the `user`'s session will be revoked on Mangadex. It will try to delete the user's session. `Mangadex::Auth.logout` outside of the `with_user` block will not do anything.

### Persisting the user session

Using this gem should help you a little bit managing tokens. If you use the objects returned by the gem
as they are, you will able to temporarily

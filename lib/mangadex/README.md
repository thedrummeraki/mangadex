## `Mangadex`

This is documentation for the `Mangadex` module.

### Directory
#### Sub-modules

- [`Mangadex::Api`](#)
- [`Mangadex::Internal`](#)

#### Fetchable/Resources
- [`Mangadex::Artist`](#)
- [`Mangadex::Auth`](#mangadexauth)
- [`Mangadex::Author`](#)
- [`Mangadex::Chapter`](#)
- [`Mangadex::ContentRating`](#)
- [`Mangadex::CoverArt`](#)
- [`Mangadex::CustomList`](#)
- [`Mangadex::Manga`](#)
- [`Mangadex::Relationship`](#)
- [`Mangadex::ReportReason`](#)
- [`Mangadex::ScanlationGroup`](#)
- [`Mangadex::Tag`](#)
- [`Mangadex::Upload`](#)
- [`Mangadex::User`](#)

#### Other classes
- [`Mangadex::MangadexObject`](#)
- [`Mangadex::Types`](#)
- [`Mangadex::Version`](#)

### Fetchable/Resources

These refer to the resources that live on Mangadex, or general "namespace"-like
concepts on which one can fetch information.

### `Mangadex::Artist`

> See [`Mangadex::Author`](#)

This is a sub-class of `Mangadex::Author`. It has the same attributes as an author.

### `Mangadex::Auth`

All things authentication.

#### `login`

```ruby
Mangadex::Auth.login(username, password)
```

Login with your username and password. Upon successful login, the user will be available in a context from
`Mangadex::Api::Context.user`. This variable can be used anywhere in your application. More info [here](#).

> - Returns `Mangadex::Api::Response` if request fails.
> - Returns `true` if user is logged in.
> - Returns `false` if the user was not successfully logged in.

#### `check_token`

```ruby
Mangadex::Auth.check_token
```

Check the status of your token, whether you're authenticated or not.

> - Returns a hash with the token information.

#### `logout`

```ruby
Mangadex::Auth.logout
```

Logs out the current user. Sets `Mangadex::Api::Content.user` to `nil`.

> - Returns `Mangadex::Api::Response` if request fails.
> - Returns `true` if request is considered successful.
> - Idempotent request.



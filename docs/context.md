# Mangadex contexts

There is a concept of concepts in this gem. This is there for you to access certain variables at any point in your app.

## User

```ruby
Mangadex.context.user # => #<Mangadex::Api::User ...>
```

This is set to `nil` before logging in.

When logging in, the user is stored in the context so that subsequent requests are set to be authenticated with this user.

```ruby
Mangadex::Auth.login(...)
Mangadex.context.user.nil? # => false

custom_lists = Mangadex::CustomList.list
```

If you're not logged in, `Mangadex::Errors::UnauthorizedError` will be raised for any request that requires you to be logged in and authorized to perform a certain account.

You can set the user in a temporary context:

```ruby
Mangadex.context.user # => nil

temp_user = Mangadex::Api::User.new(mangadex_user_id: 'blabla')
Mangadex.context.with_user(temp_user) do
  Mangadex.context.user # => #<Mangadex::Api::User mangadex_user_id="blabla">
end

Mangadex.context.user # => nil
```

More info on authentication [here]().

## Content rating

```ruby
Mangadex.context.allowed_content_ratings # => [#<Mangadex::ContentRating ...>, ...]
```

Content ratings are not tied to the user. When set, requests that accept a [`content_rating`](https://api.mangadex.org/docs.html#section/Static-data/Manga-content-rating) parameter, this parameter will be set to `Mangadex.context.allowed_content_ratings` if nothing is specified.

By default, `safe`, `suggestive` and `erotica` are used on Mangadex. But however, if you want to allow all content ratings, you could do something like:

```ruby
Mangadex.context.allow_content_ratings('safe', 'suggestive', 'erotica', 'pornographic')
```

Then, a query to fetch manga will make the following request:

```ruby
Mangadex::Manga.list
# GET https://api.mangadex.org/manga?contentRating%5B%5D=safe&contentRating%5B%5D=suggestive&contentRating%5B%5D=erotica&contentRating%5B%5D=pornographic
```

You can also use temporary content ratings:

```ruby
# old content ratings
Mangadex.context.allow_content_ratings('safe', 'suggestive', 'erotica', 'pornographic') do
  # temporary content ratings
  Mangadex::Manga.list
end

# back to old content ratings
```

## Tags

Get the list of possible tags on Mangadex:

```ruby
Mangadex.context.tags
```

### API version

Get the current Mangadex's latest API version

```ruby
Mangadex.context.version
```

A warning message will be printed if there's a mismatch between Mangadex's API version and the gem version. Example:

| Mangadex's API version | The gem's version | Result  |
| ---------------------- | ----------------- | ------- |
| 5.3.3                  | 5.3.3.1           | OK      |
| 5.3.4                  | 5.3.3.4           | Warning |

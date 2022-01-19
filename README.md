[![Ruby](https://github.com/thedrummeraki/mangadex/actions/workflows/ruby.yml/badge.svg)](https://github.com/thedrummeraki/mangadex/actions/workflows/ruby.yml)<a href="https://rubygems.org/gems/mangadex"><img src="https://badgen.net/rubygems/v/mangadex" /></a>

# Mangadex

Welcome to `mangadex`, your next favourite Ruby gem for interacting with [Mangadex](https://mangadex.org).

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

```ruby
user = Mangadex::Auth.login(username: 'username', password: 'password')
```

You can access the authenticated user by using context:

```ruby
user = Mangadex.context.user
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/thedrummeraki/mangadex. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mangadex project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/thedrummeraki/mangadex/blob/master/CODE_OF_CONDUCT.md).

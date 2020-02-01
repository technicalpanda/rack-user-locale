# Rack User Locale

[![Gem Version](https://badge.fury.io/rb/rack-user-locale.png)](http://badge.fury.io/rb/rack-user-locale) 
[![Build Status](https://secure.travis-ci.org/schinery/rack-user-locale.png)](http://travis-ci.org/schinery/rack-user-locale)

A Rack module for getting and setting a user's locale via a cookie or browser default language.

Credit to these gems for pointing me in the direction I wanted to go in...

- https://github.com/rack/rack-contrib/blob/master/lib/rack/contrib/locale.rb
- https://github.com/jeremyvdw/rack-locale-selector
- https://github.com/jeffersongirao/rack-locale_chooser

## Installation

```
gem install rack-user-locale
```

In a Gemfile:

```ruby
gem 'rack-user-locale'
```

## Usage

Add the following line to your Rack application

```ruby
use Rack::UserLocale
```

and thats it!!

Your application will now attempt to set the I18n.locale value based on the following:

- Whether a user has a `user-locale` cookie set
- The "HTTP_ACCEPT_LANGUAGE" value. If there are multiple values it will attempt to set the one ranked highest
- The I18n.default_locale value (basically a fallback)

**Note:**

The user locale detection is done on every Rack::Request, which would include all of the non Ruby/Rack actions like .css or .js files.

If you don't want this happen then you can use Rack::Static in your application and filter out which files Rack should serve up statically.

Something like this:

```ruby
use Rack::Static, urls: ["/css", "/js"], root: "public"
```

This would serve anything in your public folder statically and wouldn't create a Rack::Request.

See the [Rack::Static docs](http://rack.rubyforge.org/doc/classes/Rack/Static.html) for more info.

## Options

### Accepted Locales

```ruby
use Rack::UserLocale, accepted_locales: [:de, :en, :es, :fr, :ja, :pt, :zh] #(whatever codes you support)
```

If this option is supplied the users locale will either be set to one of the accepted locales in the array, otherwise it will be set to the `I18n.default_locale` value.

Should you wish to overwrite a users locale value at any point in your application, like for changing language prefs, then simple rewrite the `user-locale` cookie with a new value.

### Cookie Name

If you don't want to use the default cookie name of `user-locale`, you can set it to something else by passing a `cookie_name` option.

```ruby
use Rack::UserLocale, cookie_name: "some-cookie-name"
```

## Contributing to rack-user-locale

- Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
- Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
- Fork the project.
- Start a feature/bugfix branch.
- Commit and push until you are happy with your contribution.
- Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
- Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2020 [Stuart Chinery](https://github.com/schinery) and [Dave Hrycyszyn](https://github.com/futurechimp).

See LICENSE.txt for further details.

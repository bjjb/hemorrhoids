# Hemorrhoids

Helps create small, targeted database dumps.

## Installation

Add this line to your application's Gemfile:

    gem 'hemorrhoids'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hemorrhoids

## Usage

### Standalone

See `hemerrhoids --help` for command-line usage

### In a Ruby on Rails project

Add the file to your project, and run

`rake db:dump`

This will generate a dump file in db/dump.yml, printing out what it's doing
along the way. You will need to specify a `HEMORRHOID_ARGS` environment
variable, which contains `table_name:conditions`. For example

```
  HEMORRHOID_ARGS="user:updated_at > 2011-01-01" rake db:dump
```

To save to a different file, specify `HEMORRHOID_FILE`. Run `rake -D db:dump`
for a full list of configurable options.


## Compatability / Caveats

hemerrhoids has been tested with ActiveRecord 3.2.13 and Rails 2.3.14. Your
mileage may vary. Let me know if it works (or doesn't) with another version.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

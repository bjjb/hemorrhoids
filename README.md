
# Hemorrhoids

> This is a *work in progress*

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

## How it works

Let's say you have `users` and `products`, each of which `belongs_to :user`. You
want to dump the User with ID 1. Hemorrhoids maintains a queue (`q`) of
unvisited records, and a result set (`r`) of completed records. Say, User 1 has
2 products.

    ```ruby
    q = { :users => [1] }
    r = { }
    # :users [SELECT `products`.`id` FROM `products` WHERE `user_id` IN (1)]
    # ... process other associations
    q = { :products => [1, 2] }
    r = { :users => [1] }
    # process queue (it's not empty)
    # product [SELECT `user_id` from `products` where `products`.`id` in (1,2)]
    q = { }
    r = { :users => [1], :products => [1, 2] }
    ```

In a slightly more complicated example (though still totally trivial), say a
second user has products 3 and 4, a third user has 5 and 6, and that third user
commented on user 1's second product. Starting with user 1...

    ```ruby
    q = { :users => [1] }
    r = { }
    # :users
    # has_many :products, :comments
    q = { :products => [1, 2] }
    r = { :users => [1] }
    # :products
    q = { :comments => [1], :users => [3] }
    r = { :users => [1], :products => [1, 2] }
    # :comments
    q = { :users => [3] } # comment 1 is on product 1, which is in r already
    r = { :users => [1], :products => [1, 2], :comments => [1] }
    # :users
    q = { :products => [5, 6] }
    r = { :users => [1, 3], :products => [1, 2], :comments => [1] }
    #: products
    q = { }
    r = { :users => [1, 3], :products => [1, 3, 5, 6], :comments => [1] }
    ```

It's usually a lot more involved, but the same principles apply. The worst case
is N * N-1 selects when you have N tables, in which case you'll end up with all
the IDs in the database. But then you may as well just dump your entire
database, and there are better tools for that.

## Compatability / Caveats

hemerrhoids has been tested with ActiveRecord 3.2.13 and Rails 2.3.14. Your
mileage may vary. Let me know if it works (or doesn't) with another version.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

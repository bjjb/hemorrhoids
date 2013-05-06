
# Hemorrhoids

> This is a *work in progress*

Helps create smaller, targeted database dumps.

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

To start a dump from User#99, try

```
rails runner 'User.find(99).hemorrhoid.dump(:json)' > dump.json
```

## How it works

Let's say you have `users` and `products`, each of which `belongs_to :user`. You
want to dump the User with ID 1. Hemorrhoids maintains a queue (`q`) of
unvisited records, and a result set (`r`) of completed records. Say, User 1 has
2 products.

```ruby
q = { :users => [1] }
r = { }
# ... process associations in User#1
q = { :products => [1, 2] }
r = { :users => [1] }
# process associations for Product#1 and #2
q = { }
r = { :users => [1], :products => [1, 2] }
```

In a slightly more complicated example (though still totally trivial), say a
second user has products 3 and 4, a third user has 5 and 6, and that third user
commented on user 1's second product. Starting with user 1...

```ruby
q = { :users => [1] }
r = { }
# User#1 has products 1 and 2
q = { :products => [1, 2] }
r = { :users => [1] }
# Product#2 has a comment
q = { :comments => [1] }
r = { :users => [1], :products => [1, 2] }
# Comment#1 belongs_to User #3
q = { :users => [3] } # comment 1 is on product 1, which is in r already
r = { :users => [1], :products => [1, 2], :comments => [1] }
# User#3 has products 5 and 6
q = { :products => [5, 6] }
r = { :users => [1, 3], :products => [1, 2], :comments => [1] }
# All associated records for products 1 and 2 are already in r
q = { }
r = { :users => [1, 3], :products => [1, 3, 5, 6], :comments => [1] }
```

It's usually a lot more involved, but the same principles apply. The worst case
is N * N-1 selects when you have N tables, in which case you'll end up with all
the IDs in the database. But then you may as well just dump your entire
database, and there are better tools for that.

## Compatability / Caveats

hemerrhoids has been tested with ActiveRecord 3.2.13 and 2.3.18. Your
mileage may vary. Let me know if it works (or doesn't) with another version.

Right now, it is inefficient, in that it loads each record to get its
associations. It would obviously be many times faster if it just selected the
primary keys it needed, using the reflections. This is planned for a later
version. Having said that, it's quick enough to extract all IDs for about a
million records from a production MySQL database in 30s or so.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

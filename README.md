# pronto-querly

This is a pronto runner for Querly, a pattern based Ruby program checking tool.

* [pronto](https://github.com/prontolabs/pronto)
* [Querly](https://github.com/soutaro/querly)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pronto'
gem 'pronto-querly', require: false
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pronto-querly

## Usage

Use `pronto run` command.

    $ bundle exec pronto run
    $ bundle exec pronto run -r querly

### Configuration

There is no configuration option via `.pronto.yml`.
Define your rules in `querly.yml`.

The exceptions are ones given through `all:` section of `.pronto.yml`.

```yaml
all:
  exclude:
    - 'spec/**/*'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/soutaro/pronto-querly.

# Combine (harvester)

[![Amber Framework](https://img.shields.io/badge/using-amber_framework-orange.svg)](https://amberframework.org)

This is a project written using [Amber](https://amberframework.org).
Enjoy!

## Getting Started

These instructions will get a copy of this project running on your
machine for development and testing purposes.

## Prerequisites

This project requires [Crystal](https://crystal-lang.org/)
([installation guide](https://crystal-lang.org/docs/installation/)).

Alternatively, `docker compose up` should bring up a container based
setup (untested).

## Initial setup

The environment configuration files are encrypted in git, so to run
the project you'll need the key from 1Password:

`op read op://Shared/rasikyplntusmmbszukvobmjz4/password >.encryption_key`

## Development

To start your Amber server:

1. Install dependencies with `shards install`
2. Build executables with `shards build`
3. Create and migrate your database with `bin/amber db create migrate`.
4. Start Amber server with `bin/amber watch`

Now you can visit http://localhost:3000/ from your browser.

## Tests

To run the test suite:

```
crystal spec
```

## Contributing

1. Fork it ( https://github.com/reload/combine/fork )
2. Create your feature branch ( `git checkout -b my-new-feature` )
3. Commit your changes ( `git commit -am 'Add some feature'` )
4. Push to the branch ( `git push origin my-new-feature` )
5. Create a new Pull Request

## Contributors

- [xendk](https://github.com/xendk) Thomas Fini Hansen - creator, maintainer

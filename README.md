[![Build Status](https://github.com/joeyates/solar_edge/actions/workflows/ci.yml/badge.svg)][CI Status]
![Coverage](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/joeyates/9845bfb4ce29ec18fcb30b26611ab1cf/raw/coverage.json)

# SolarEdge

This is an Elixir client library for the [SolarEdge](https://www.solaredge.com) monitoring API.

# Setup

To use the client you need an API key.
You can get an API key from the [SolarEdge monitoring web site](https://monitoring.solaredge.com).

Go to Admin -> Site Access -> API Access.

* Accept the terms and conditions,
* Click on 'New key', then on 'Save'.

# Status

Only a few calls have been implemented.

# Development

Run tests

```
mix test
```

See test coverage

```
mix coveralls
```

Generate HTML coverage report

```
mix coveralls.html
open cover/excoveralls.html
```

* [CI Status]

[CI Status]: https://github.com/joeyates/solar_edge/actions/workflows/ci.yml

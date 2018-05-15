# Todos
[![Build Status](https://travis-ci.org/darren987469/todos.svg?branch=master)](https://travis-ci.org/darren987469/todos)
[![Maintainability](https://api.codeclimate.com/v1/badges/c21eac6d198364066a7f/maintainability)](https://codeclimate.com/github/darren987469/todos/maintainability)
[![Coverage Status](https://coveralls.io/repos/github/darren987469/todos/badge.svg?branch=master)](https://coveralls.io/github/darren987469/todos?branch=master)

Features:
* Todo list to organize your todo
* Invite others to join your list
* Changes to todo is updated through websocket, no need to reload page

# Potential bottleneck and todos

The bottleneck of this app maybe rails action cable. It has poor performance when handle a large number of client.

* Use Background job to reduce response time in controller caused by action cable broadcast.
* Separate websocket server and application server.
* If allowed, rewrite websocket server in another language such as Go, Erlang is better choice. Ruby on Rails is not fit for scalable concurrent applications. There is a open source project [AnyCable Rails](https://github.com/anycable/anycable-rails) do this.

References:
* [Action Cable 即時通訊](https://ihower.tw/rails/actioncable.html) by ihower
* [AnyCable: Action Cable on steroids](https://evilmartians.com/chronicles/anycable-actioncable-on-steroids) by Vladimir Dementyev

## Environment

Development in Ruby 2.5, PostgreSQL 10.2

## Install

```shell
bundle         # install gems
rails db:setup # create db and seed
rails s        # start server in http://localhost:300
```

## Testing

```shell
bin/rspec
```
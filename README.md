# Todos
[![Build Status](https://travis-ci.org/darren987469/todos.svg?branch=master)](https://travis-ci.org/darren987469/todos)
[![Maintainability](https://api.codeclimate.com/v1/badges/c21eac6d198364066a7f/maintainability)](https://codeclimate.com/github/darren987469/todos/maintainability)
[![Coverage Status](https://coveralls.io/repos/github/darren987469/todos/badge.svg?branch=master)](https://coveralls.io/github/darren987469/todos?branch=master)

## Features:

* Todo list to organize your todos
* Invite other people to join your list
* Changes to todo are updated through websocket, no need to reload page
* Every user action is logged and displayed

Detail spec can be found in [System Spec](system_spec.md)

## Screen shot
![Todo screenshot](/screenshots/Screen_Shot_2018-05-15.png?raw=true)

## API document

Production:  https://todos-actioncable.herokuapp.com/swagger
Development: http://localhost:3000/swagger

[How to authenticate with token guide](doc/how_to_authenticate_with_token.md)

## Environment

Development in Ruby 2.5.1, PostgreSQL 10.2, elasticsearch 6.4.2

```sh
brew cask install homebrew/cask-versions/java8 # elasticsearch dependency
brew install elasticsearch
```

## Install

```shell
bundle                # install gems
overcommit --install  # add git hook tool
overcommit --sign     # apply git hook. execute it after changing .overcommit.yml
rails db:setup        # create db and seed
rails s               # start server in http://localhost:300
```

Ignore git hook: `SKIP=RuboCop git commit`

## Development

Follow [git flow](http://nvie.com/posts/a-successful-git-branching-model/).

UI is based on [ace admin](https://github.com/bopoda/ace), [Demo website](http://ace.jeka.by/)

## Testing

```shell
bin/rspec
```

## Deploy to Heroku

```sh
# heroku remote: https://git.heroku.com/todos-actioncable.git
git push heroku master
```

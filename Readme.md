# heroku-sticky-releases

Specify release versions on `run`, `ps:scale`, and `ps:restart` commands.

## Installation

```
$ heroku plugins:install git@github.com:heroku/heroku-sticky-releases.git
```

## Usage

```
$ heroku run bash -r 3

$ heroku ps:scale web+1 -r 4

$ heroku ps:restart -r 5

$ heroku ps:restart web -r 6

$ heroku ps:restart web.1 -r 7
```
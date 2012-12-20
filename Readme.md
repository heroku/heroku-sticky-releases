# heroku-sticky-releases

Specify release versions on `run`, `ps:scale`, and `ps:restart` commands.

## Installation

```
$ heroku plugins:install git@github.com:heroku/heroku-sticky-releases.git
```

## Usage

```
$ heroku run bash -r 3             # run bash on release v3

$ heroku ps:scale web+1 -r 4       # scale web processes on release v4

$ heroku ps:restart -r 5           # restart all processes on release v5

$ heroku ps:restart web -r 6       # restart all web processes on release v6

$ heroku ps:restart web.1 -r 7     # restart web.1 process on release v7

$ heroku ps:restart web.1-3 -r 7     # restart web.1, web.2, web.3 processes on release v7
```

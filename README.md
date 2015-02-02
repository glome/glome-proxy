Glome proxy server is a lightweight proxy server that processes requests and adds application identifiers

## Setup

Copy the `config.json.example` to `config.json` and edit the contents:

- add `application.apikey` and `application.uid` provided by [Glome](http://glome.me)
- set the preferred port and SSL

Install [nodeJS](http://nodejs.org/download/) and [CoffeeScript](http://coffeescript.org/)

## Run

Run `coffee proxy.coffee`
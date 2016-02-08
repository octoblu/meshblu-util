_           = require 'lodash'
fs          = require 'fs'
path        = require 'path'
colors      = require 'colors'
Meshblu     = require 'meshblu'
commander   = require 'commander'
BaseCommand = require './base-command'

class SubscribeCommand extends BaseCommand
  parseOptions: =>
    commander
      .option '-u, --uuid <uuid>', 'Meshblu device to subscribe to (defaults to uuid from meshblu.json)'
      .option '-e, --events <event-names>', 'Comma seperated list of Meshblu events to subscribe to (defaults to "message,config")'
      .option '-t, --types <types>', 'Comma seperated list of subscription types (defaults to "broadcast,received,sent")'
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args
    @uuid = commander.uuid
    @events = (commander.events ? 'message,config').split ','
    @types = (commander.types ? 'broadcast,received,sent').split ','

  run: =>
    @parseOptions()

    @parseConfig @filename

    @meshblu = Meshblu.createConnection @config
    @meshblu.once 'ready', @afterConnect
    @meshblu.once 'disconnect', @die

  afterConnect: =>
    # return @die error if error?

    _.each @events, (eventName) =>
      @meshblu.on eventName, (event) =>
        console.log {eventName, event}

    unless @uuid?
      console.log colors.green 'subscribing to', @config.uuid
      @meshblu.unsubscribe uuid: @config.uuid
      @meshblu.subscribe uuid: @config.uuid, types: @types
      return

    console.log colors.green 'subscribing to', @uuid
    @meshblu.unsubscribe uuid: @uuid
    @meshblu.subscribe uuid: @uuid, types: @types

  die: (error) =>
    console.error error
    console.error error?.message
    console.error error?.stack
    process.exit 1

(new SubscribeCommand()).run()

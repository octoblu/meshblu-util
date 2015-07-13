_           = require 'lodash'
fs          = require 'fs'
path        = require 'path'
colors      = require 'colors'
Meshblu     = require 'meshblu-websocket'
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

    @config = @parseConfig @filename
    @config.options = transports: ['websocket']

    @meshblu = new Meshblu @config
    @meshblu.connect @afterConnect
    @meshblu.once 'notReady', @die
    @meshblu.once 'disconnect', @die

  afterConnect: =>
    _.each @events, (event) =>
      @meshblu.on event, (message) =>
        console.log JSON.stringify(message, null, 2)

    unless @uuid?
      return @meshblu.subscribe uuid: @config.uuid, types: @types

    console.log colors.green 'subscribing to', @uuid
    @meshblu.subscribe uuid: @uuid, types: @types

  die: (error) =>
    console.error error
    console.error error?.message
    console.error error?.stack
    process.exit 1

(new SubscribeCommand()).run()

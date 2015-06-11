_           = require 'lodash'
fs          = require 'fs'
path        = require 'path'
colors      = require 'colors'
Meshblu     = require './src/meshblu'
commander   = require 'commander'
BaseCommand = require './base-command'

class SubscribeCommand extends BaseCommand
  parseOptions: =>
    commander
      .option '-u, --uuid <uuid>', 'Meshblu device to subscribe to (defaults to uuid from meshblu.json)'
      .option '-e, --event <event-name>', 'Meshblu event to subscribe to (defaults to "message")'
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args
    @event = commander.event ? 'message'
    @uuid = commander.uuid

  run: =>
    @parseOptions()

    @config = @parseConfig @filename
    @meshblu = new Meshblu @config, @afterConnect

  afterConnect: =>
    if @uuid
      console.log colors.green 'subscribing to', @uuid
      @meshblu.unsubscribe @config.uuid, (error) =>
        console.error colors.red JSON.stringify error.error if error.error?

      @meshblu.subscribe @uuid, (error) =>
        console.error colors.red JSON.stringify error.error if error.error?

    console.log colors.green "Subscribed to #{@uuid ? @config.uuid}"
    @meshblu.on @event, (message) =>
      console.log JSON.stringify(message, null, 2)

(new SubscribeCommand()).run()

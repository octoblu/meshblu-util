commander = require 'commander'
colors    = require 'colors'
fs        = require 'fs'
_         = require 'lodash'
Meshblu   = require './src/meshblu'
path      = require 'path'

class SubscribeCommand
  parseConfig: (filename) =>
    try
      JSON.parse fs.readFileSync path.resolve(filename)
    catch error
      console.error colors.yellow error.message
      console.error colors.red '\n  Unable to open a valid meshblu.json file'
      commander.outputHelp()
      process.exit 1

  parseOptions: =>
    commander
      .option '-u, --uuid <uuid>', 'Meshblu device to subscribe to (defaults to uuid from meshblu.json)'
      .option '-e, --event <event-name>', 'Meshblu event to subscribe to (defaults to "message")'
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args
    @event = commander.event ? 'message'
    @uuid = commander.uuid

    unless @filename?
      console.error colors.red '\n  You must specify the path to meshblu.json.'
      commander.outputHelp()
      process.exit 1

  run: =>
    @parseOptions()

    @config = @parseConfig @filename
    @meshblu = new Meshblu @config, @afterConnect

  afterConnect: =>
    if @uuid
      console.log colors.green 'subscribing to', @uuid
      @meshblu.unsubscribe @config.uuid, (error) =>
        console.error colors.red JSON.stringify error.error if error.error?

      @meshblu.subscribe uuid: @uuid, (error) =>
        console.error colors.red JSON.stringify error.error if error.error?

    @meshblu.on @event, (message) =>
      console.log JSON.stringify(message, null, 2)

(new SubscribeCommand()).run()

commander = require 'commander'
colors    = require 'colors'
fs        = require 'fs'
_         = require 'lodash'
Meshblu   = require './src/meshblu'
path      = require 'path'

class MessageCommand
  parseConfig: (filename) =>
    try
      JSON.parse fs.readFileSync path.resolve(filename)
    catch error
      console.error colors.yellow error.message
      console.error colors.red '\n  Unable to open a valid meshblu.json file'
      commander.outputHelp()
      process.exit 1

  parseMessage: (filename) =>
    try
      JSON.parse fs.readFileSync path.resolve(filename)
    catch error
      console.error colors.yellow error.message
      console.error colors.red '\n  Unable to open a valid message.json file'
      commander.outputHelp()
      process.exit 1

  throwCommanderError: (msg) =>
    console.error colors.red "\n  #{msg}"
    commander.outputHelp()
    process.exit 1

  parseOptions: =>
    commander
      .option '-d, --data <\'{"topic":"do-something"}\'>', 'Message Data [JSON]'
      .option '-f, --file <path/to/message.json>', 'Message Data [JSON FILE]'
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args
    @data = commander.data
    @updateFileName = commander.file

    @data = @parseMessage(@updateFileName) if @updateFileName?
    @throwCommanderError('You must specify the path to meshblu.json.') unless @filename?

    return if _.isPlainObject @data
    try
      @data = JSON.parse @data
    catch e
      @throwCommanderError('You must specify valid message json.')

  run: =>
    @parseOptions()

    @config = @parseConfig @filename
    @meshblu = new Meshblu @config, @afterConnect

  afterConnect: =>
    @meshblu.message @data, =>
      process.exit 0

(new MessageCommand()).run()

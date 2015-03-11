commander = require 'commander'
colors    = require 'colors'
fs        = require 'fs'
_         = require 'lodash'
Meshblu   = require './src/meshblu'
path      = require 'path'

class GetCommand
  parseConfig: (filename) =>
    try
      JSON.parse fs.readFileSync path.resolve(filename)
    catch error
      console.error colors.yellow error.message
      console.error colors.red '\n  Unable to open a valid meshblu.json file'
      commander.outputHelp()
      process.exit 1

  throwCommanderError: (msg) =>
    console.error colors.red "\n  #{msg}"
    commander.outputHelp()
    process.exit 1

  parseOptions: =>
    commander
      .option '-d, --data \'{"name":"Some Device"}\'', 'Device Data [JSON]'
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = commander.args?[0]
    @data = commander.args?[1]
    
    @throwCommanderError('You must specify the path to meshblu.json.') unless @filename?
    @throwCommanderError('You must specify data to update the device.') unless @data?

    return if _.isPlainObject @data
    try
      @data = JSON.parse @data
    catch e
      @throwCommanderError('You must specify valid json to update the device.')

  run: =>
    @parseOptions()

    @config = @parseConfig @filename
    @meshblu = new Meshblu @config, @afterConnect

  afterConnect: =>
    baseDevice = 
      uuid: @config.uuid
      token: @config.token
    deviceUpdate = _.extend baseDevice, @data

    @meshblu.update deviceUpdate, (data) =>
      console.log JSON.stringify(data, null, 2)
      process.exit 0

(new GetCommand()).run()

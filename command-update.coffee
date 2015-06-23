_           = require 'lodash'
fs          = require 'fs'
path        = require 'path'
colors      = require 'colors'
commander   = require 'commander'
BaseCommand = require './base-command'

class UpdateCommand extends BaseCommand
  parseUpdate: (filename) =>
    try
      JSON.parse fs.readFileSync path.resolve(filename)
    catch error
      console.error colors.yellow error.message
      console.error colors.red '\n  Unable to open a valid updated-device.json file'
      commander.outputHelp()
      process.exit 1

  parseOptions: =>
    commander
      .option '-p, --put',                                'Use PUT to send the whole device state. Enables $set, $inc, etc. operators'
      .option '-d, --data <\'{"name":"Some Device"}\'>',  'Device Data [JSON]'
      .option '-f, --file <path/to/updated-device.json>', 'Device Data [JSON FILE]'
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args
    @data = commander.data
    @updateFileName = commander.file

    @usePut = commander.put
    @data = @parseUpdate(@updateFileName) if @updateFileName?

    return if _.isPlainObject @data
    try
      @data = JSON.parse @data
    catch e
      commander.outputHelp()
      @die 'You must specify valid update json.'

  run: =>
    @parseOptions()
    meshbluHttp = @getMeshbluHttp()

    updateMethod = 'update'
    updateMethod = 'updateWithPut' if @usePut

    meshbluHttp[updateMethod] @config.uuid, @data, (error, data) =>
      return @die error if error?
      process.exit 0

(new UpdateCommand()).run()

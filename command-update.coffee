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
      .option '-d, --data <\'{"name":"Some Device"}\'>', 'Device Data [JSON]'
      .option '-f, --file <path/to/updated-device.json>', 'Device Data [JSON FILE]'
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args
    @data = commander.data
    @updateFileName = commander.file

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

    baseDevice =
      uuid: @config.uuid
      token: @config.token
    deviceUpdate = _.extend baseDevice, @data

    console.log deviceUpdate
    meshbluHttp.update deviceUpdate, (error, data) =>
      return @die error if error?
      console.log JSON.stringify(data, null, 2)
      process.exit 0

(new UpdateCommand()).run()

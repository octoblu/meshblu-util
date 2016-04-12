_           = require 'lodash'
fs          = require 'fs'
path        = require 'path'
colors      = require 'colors'
Meshblu     = require 'meshblu-firehose-socket.io'
commander   = require 'commander'
BaseCommand = require './base-command'

class FirehoseCommand extends BaseCommand
  parseOptions: =>
    commander
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args

  run: =>
    @parseOptions()

    @parseConfig @filename
    @meshblu = new Meshblu meshbluConfig: @config
    @meshblu.connect uuid: @config.uuid, @afterConnect
    @meshblu.once 'disconnect', @die

  afterConnect: (error) =>
    console.log colors.red('FIREHOSE'), 'connected'
    @meshblu.on 'message', (message) =>
      console.log JSON.stringify message, null, 2

  die: (error) =>
    console.error error
    console.error error?.message
    console.error error?.stack
    process.exit 1

(new FirehoseCommand()).run()

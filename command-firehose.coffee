_               = require 'lodash'
colors          = require 'colors'
MeshbluFirehose = require 'meshblu-firehose-socket.io'
commander       = require 'commander'
BaseCommand     = require './base-command'

class FirehoseCommand extends BaseCommand
  parseOptions: =>
    commander
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args

  run: =>
    @parseOptions()

    @parseConfig()
    @meshblu = new MeshbluFirehose meshbluConfig: @config
    @meshblu.connect @afterConnect
    @meshblu.once 'disconnect', @die

  afterConnect: (error) =>
    return @die error if error?

    console.log colors.red('FIREHOSE'), 'connected'
    @meshblu.on 'message', (message) =>
      console.log JSON.stringify message, null, 2

  die: (error) =>
    console.error error
    console.error error?.message
    console.error error?.stack
    process.exit 1

(new FirehoseCommand()).run()

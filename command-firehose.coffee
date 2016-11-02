_               = require 'lodash'
colors          = require 'colors'
MeshbluFirehose = require 'meshblu-firehose-socket.io'
commander       = require 'commander'
Util            = require './src/util'

class FirehoseCommand extends Util
  constructor: ->
    {filename, @messagePath} = @parseOptions()
    meshbluConfig = Util.getMeshbluConfig {filename}
    @firehose = new MeshbluFirehose {meshbluConfig}

  parseOptions: =>
    commander
      .usage '[options] [path/to/meshblu.json]'
      .option '-p, --path <message-path>', 'path within each message to print. (defaults to the whole message)'
      .parse process.argv

    return {
      filename: _.first commander.args
      messagePath: commander.path
    }

  run: =>
    @firehose.connect @afterConnect
    @firehose.once 'disconnect', @die
    @firehose.on 'message', @onMessage

  afterConnect: (error) =>
    return @die error if error?
    console.log colors.red('FIREHOSE'), 'connected'

  onMessage: (message) =>
    output = message
    output = _.get message, @messagePath unless _.isEmpty @messagePath
    console.log JSON.stringify output, null, 2

  die: (error) =>
    console.error error
    console.error error?.message
    console.error error?.stack
    process.exit 1

(new FirehoseCommand()).run()

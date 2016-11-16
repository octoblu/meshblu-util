_               = require 'lodash'
colors          = require 'colors'
MeshbluFirehose = require 'meshblu-firehose-socket.io'
commander       = require 'commander'
Util            = require './src/util'

class FirehoseCommand extends Util
  constructor: ->
    {filename, @messagePaths} = @parseOptions()
    meshbluConfig = Util.getMeshbluConfig {filename}
    @firehose = new MeshbluFirehose {meshbluConfig}

  parseOptions: =>
    commander
      .usage '[options] [path/to/meshblu.json]'
      .option '-p, --path <message-path,message-path>', '''path within each message to print.
                                                           (defaults to the whole message)'''
      .parse process.argv

    return {
      filename: _.first commander.args
      messagePaths: _.split commander.path, ','
    }

  run: =>
    @firehose.connect @afterConnect
    @firehose.once 'disconnect', @die
    @firehose.on 'message', @onMessage

  afterConnect: (error) =>
    return @die error if error?
    console.log colors.red('FIREHOSE'), 'connected'

  onMessage: (message) =>
    console.log colors.yellow '========================='
    return console.log JSON.stringify(message, null, 2) if _.isEmpty @messagePaths
    _.each @messagePaths, (messagePath) =>
      console.log JSON.stringify(_.get(message, messagePath), null, 2)

  die: (error) =>
    console.error error
    console.error error?.message
    console.error error?.stack
    process.exit 1

(new FirehoseCommand()).run()

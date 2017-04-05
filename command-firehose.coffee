_               = require 'lodash'
colors          = require 'colors'
MeshbluFirehose = require 'meshblu-firehose-socket.io'
commander       = require 'commander'
Util            = require './src/util'
moment          = require 'moment'
prettyBytes     = require 'pretty-bytes'

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
      messagePaths: _.compact _.split commander.path, ','
    }

  run: =>
    @firehose.on 'connect', @afterConnect
    @firehose.once 'disconnect', @die
    @firehose.on 'message', @onMessage
    @firehose.connect()

  afterConnect: (error) =>
    return @die error if error?
    console.log colors.red('FIREHOSE'), 'connected'

  onMessage: (message) =>
    timestamp = colors.gray moment().format()
    route = _.first(_.get message, 'metadata.route', []) ? {}
    {from, to, type} = route
    from = colors.blue from
    to = colors.blue to
    type = colors.red type
    size = colors.green prettyBytes JSON.stringify(message).length
    console.log colors.yellow '============================================================================='
    if _.isEmpty @messagePaths
      console.log JSON.stringify(message, null, 2)
    else
      _.each @messagePaths, (messagePath) =>
        console.log JSON.stringify(_.get(message, messagePath), null, 2)

    console.log "#{timestamp} <#{type}> @#{from}=>#{to} (#{size})"

  die: (error) =>
    console.error error
    console.error error?.message
    console.error error?.stack
    process.exit 1

(new FirehoseCommand()).run()

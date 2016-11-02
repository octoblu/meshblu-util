_           = require 'lodash'
commander   = require 'commander'
Util        = require './src/util'

class SubscriptionCreateCommand
  constructor: ->
    {filename, @subscriberUuid, @emitterUuid, @type} = @parseOptions()
    @config  = Util.parseConfig {filename}
    @meshblu = Util.getMeshbluHttp {filename}

  parseOptions: =>
    commander
      .usage '[options] [path/to/meshblu.json]'
      .option '-e, --emitter <uuid>', 'Emitter device (defaults to uuid from meshblu.json)'
      .option '-s, --subscriber <uuid>', 'Subscriber device (defaults to uuid from meshblu.json)'
      .option '-t, --type <type>', 'Subscription type'
      .parse process.argv

    filename = _.first commander.args
    subscriberUuid = commander.subscriber
    emitterUuid = commander.emitter

    type = commander.type

    unless type?
      commander.outputHelp()
      Util.die new Error 'You must specify a type.'

    return {filename, subscriberUuid, emitterUuid, type}

  run: =>
    emitterUuid = @emitterUuid ? @config.uuid
    subscriberUuid = @subscriberUuid ? @config.uuid
    type = @type

    @meshblu.createSubscription { emitterUuid, subscriberUuid, type }, (error) =>
      return Util.die error if error?
      process.exit 0

(new SubscriptionCreateCommand()).run()

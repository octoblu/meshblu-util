_           = require 'lodash'
commander   = require 'commander'
BaseCommand = require './base-command'

class SubscriptionDeleteCommand extends BaseCommand
  parseOptions: =>
    commander
      .option '-e, --emitter <uuid>', 'Emitter device (defaults to uuid from meshblu.json)'
      .option '-s, --subscriber <uuid>', 'Subscriber device (defaults to uuid from meshblu.json)'
      .option '-t, --type <type>', 'Subscription type'
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args
    @subscriberUuid = commander.subscriber
    @emitterUuid = commander.emitter

    @type = commander.type

    unless @type?
      commander.outputHelp()
      @die 'You must specify a type.'

  run: =>
    @parseOptions()

    meshbluHttp = @getMeshbluHttp()
    @emitterUuid ?= @config.uuid
    @subscriberUuid ?= @config.uuid
    meshbluHttp.deleteSubscription {@subscriberUuid, @emitterUuid, @type}, (error) =>
      return @die error if error?
      process.exit 0

(new SubscriptionDeleteCommand()).run()

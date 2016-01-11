_           = require 'lodash'
fs          = require 'fs'
path        = require 'path'
colors      = require 'colors'
Meshblu     = require 'meshblu-http'
commander   = require 'commander'
BaseCommand = require './base-command'

class CreateSubscriptionCommand extends BaseCommand
  parseOptions: =>
    commander
      .option '-e, --emitter <uuid>', 'Emitter device'
      .option '-s, --subscriber <uuid>', 'Subscriber device (defaults to uuid from meshblu.json)'
      .option '-t, --type <type>', 'Subscription type'
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args
    @subscriberUuid = commander.subscriber
    @emitterUuid = commander.emitter

    @type = commander.type

  run: =>
    @parseOptions()

    meshbluHttp = @getMeshbluHttp()
    @subscriberUuid ?= @config.uuid
    meshbluHttp.createSubscription {@subscriberUuid, @emitterUuid, @type}, (error) =>
      return @die error if error?
      process.exit 0

  die: (error) =>
    console.error error
    console.error error?.message
    console.error error?.stack
    process.exit 1

(new CreateSubscriptionCommand()).run()

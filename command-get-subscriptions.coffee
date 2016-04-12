_ = require 'lodash'
commander = require 'commander'

BaseCommand   = require './base-command'


class GetCommand extends BaseCommand
  run: =>
    @parseOptions()
    meshbluHttp = @getMeshbluHttp()
    @uuid ?= @getMeshbluConfig().uuid
    meshbluHttp. @uuid, (error, data) =>
      return @die error if error?

      console.log JSON.stringify(data, null, 2)
      process.exit 0

  parseOptions: =>
    commander
      .option '-u, --uuid <uuid>', 'Meshblu device to get subscriptions for (defaults to uuid from meshblu.json)'
      .option '-t, --subscription-type <subscription-type>', 'The type of subscription to get (broadcast, config, received, or sent)'
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args
    {@subscriptionType, @uuid} = commander

    unless @subscriptionType?
      commander.outputHelp()
      process.exit 0

(new GetCommand()).run()

_ = require 'lodash'
commander = require 'commander'

BaseCommand   = require './base-command'


class SubscriptionList extends BaseCommand
  run: =>
    @parseOptions()
    meshbluHttp = @getMeshbluHttp()
    @uuid ?= @getMeshbluConfig().uuid
    meshbluHttp.subscriptions @uuid, (error, data) =>
      return @die error if error?

      console.log JSON.stringify(data, null, 2)
      process.exit 0

  parseOptions: =>
    commander
      .option '-u, --uuid <uuid>', 'Meshblu device to get (defaults to uuid from meshblu.json)'
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args
    @uuid = commander.uuid
    @events = (commander.events ? 'message,config').split ','
    @types = (commander.types ? 'broadcast,received,sent').split ','

(new SubscriptionList()).run()

_ = require 'lodash'
commander = require 'commander'

BaseCommand   = require './base-command'


class GetCommand extends BaseCommand
  run: =>
    @parseOptions()
    meshbluHttp = @getMeshbluHttp()
    @uuid ?= @getMeshbluConfig().uuid
    meshbluHttp.device @uuid, {@as}, (error, data) =>
      return @die error if error?

      console.log JSON.stringify(data, null, 2)
      process.exit 0

  parseOptions: =>
    commander
      .option '-a, --as <uuid>', 'the uuid to send the message as (defaults to meshblu.json)'
      .option '-u, --uuid <uuid>', 'Meshblu device to get (defaults to uuid from meshblu.json)'
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args
    @uuid   = commander.uuid
    @as     = commander.as
    @events = (commander.events ? 'message,config').split ','
    @types  = (commander.types ? 'broadcast,received,sent').split ','

(new GetCommand()).run()

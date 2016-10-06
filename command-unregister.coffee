_           = require 'lodash'
commander   = require 'commander'
BaseCommand = require './base-command'

class UpdateCommand extends BaseCommand
  parseOptions: =>
    commander
      .option '-u, --uuid <uuid>', 'uuid to delete'
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @uuid = commander.uuid
    @die 'one of -u, --uuid is required' unless @uuid

  run: =>
    @parseOptions()
    meshbluHttp  = @getMeshbluHttp()
    meshbluHttp.unregister {@uuid}, (error) =>
      return @die error if error?
      process.exit 0

(new UpdateCommand()).run()

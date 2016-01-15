_             = require 'lodash'
commander     = require 'commander'
BaseCommand   = require './base-command'

class GenerateToken extends BaseCommand
  parseOptions: =>
    commander
      .usage '[options] <path/to/meshblu.json>'
      .option '-u, --uuid <uuid>', 'uuid to generate-token for (defaults to meshblu.json)'
      .option '-t, --tag <tag>', 'Token Tag'
      .parse process.argv

    @filename   = _.first commander.args
    @uuid       = commander.uuid ? @getMeshbluConfig().uuid
    @filename  ?= "meshblu.json"

    @tag = commander.tag
    @parseConfig()

  run: =>
    @parseOptions()
    meshbluHttp = @getMeshbluHttp()

    meshbluHttp.generateAndStoreTokenWithOptions @uuid, {@tag}, (error, {uuid, token}) =>
      return @die error if error?
      newMeshbluConfig = _.extend {}, @getMeshbluConfig(), {uuid, token}
      console.log JSON.stringify(newMeshbluConfig, null, 2)

      process.exit 0

(new GenerateToken()).run()

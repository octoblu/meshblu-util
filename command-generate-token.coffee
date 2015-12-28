_             = require 'lodash'
commander     = require 'commander'
BaseCommand   = require './base-command'

class GenerateToken extends BaseCommand
  parseOptions: =>
    commander
      .usage '[options] <path/to/meshblu.json>'
      .option '-t, --tag <tag>', 'Token Tag'
      .parse process.argv

    @filename = _.first commander.args
    @filename ?= "meshblu.json"

    @tag = commander.tag
    @parseConfig()

  run: =>
    @parseOptions()
    meshbluHttp = @getMeshbluHttp()

    meshbluHttp.generateAndStoreTokenWithOptions @config.uuid, {@tag}, (error, data) =>
      return @die error if error?

      console.log JSON.stringify(data, null, 2)
      process.exit 0

(new GenerateToken()).run()

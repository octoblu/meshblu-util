_             = require 'lodash'
commander     = require 'commander'
BaseCommand   = require './base-command'

class GenerateToken extends BaseCommand
  parseOptions: =>
    commander
      .usage '[options] <path/to/meshblu.json>'
      .option '--token <token>', 'Token'
      .option '--tag <tag>', 'Token Tag'
      .parse process.argv

    @filename = _.first commander.args
    @filename ?= "meshblu.json"

    @tag = commander.tag
    @token = commander.token
    @parseConfig()

  run: =>
    @parseOptions()

    return @die new Error "Missing tag or token" unless @tag? or @token?
    return @revokeTokenByQuery() if @tag
    return @revokeToken() if @token

  revokeToken: =>
    meshbluHttp = @getMeshbluHttp()
    meshbluHttp.revokeToken @config.uuid, @token, (error, data) =>
      return @die error if error?

      console.log JSON.stringify(data, null, 2)
      process.exit 0

  revokeTokenByQuery: =>
    meshbluHttp = @getMeshbluHttp()
    meshbluHttp.revokeTokenByQuery @config.uuid, {@tag}, (error, data) =>
      return @die error if error?
      console.log 'Tokens deleted.'
      process.exit 0

(new GenerateToken()).run()

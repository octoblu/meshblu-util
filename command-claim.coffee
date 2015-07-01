BaseCommand   = require './base-command'
MeshbluConfig = require 'meshblu-config'
_             = require 'lodash'
open          = require 'open'
commander     = require 'commander'

DEFAULT_HOST = 'app.octoblu.com'
DEFAULT_PORT = 443

class ClaimDevice extends BaseCommand
  parseOptions: =>
    commander
      .usage '[options] <path/to/meshblu.json>'
      .option '-s, --server <host[:port]>', 'Meshblu host'
      .parse process.argv

    @filename = _.first commander.args
    @filename ?= "meshblu.json"

    @parseConfig()

  parseConfig: =>
    @meshbluConfig = new MeshbluConfig filename: @filename
    @config = @meshbluConfig.toJSON()
    _.extend @config, @parseOctobluServer()

  parseOctobluServer: =>
    unless commander.server?
      return {octobluServer: DEFAULT_HOST, octobluPort: DEFAULT_PORT}

    serverConfig = commander.server.split(':')

    {octobluServer: serverConfig[0], octobluPort: serverConfig[1]}

  run: =>
    @parseOptions()
    meshbluHttp = @getMeshbluHttp()
    {uuid, octobluServer, octobluPort} = @config

    meshbluHttp.generateAndStoreToken uuid, (error, body) =>
      return @die error if error?
      newToken = body.token
      open "http://#{octobluServer}:#{octobluPort}/node-wizard/claim/#{uuid}/#{newToken}"


(new ClaimDevice()).run()

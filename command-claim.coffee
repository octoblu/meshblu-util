BaseCommand   = require './base-command'
_             = require 'lodash'
open          = require 'open'
path          = require 'path'
commander     = require 'commander'

DEFAULT_HOST = 'app.octoblu.com'
DEFAULT_PORT = 443

class ClaimDevice extends BaseCommand
  parseOptions: =>
    commander
      .usage '[options] <path/to/meshblu.json>'
      .option '-s, --server <host[:port]>', 'Octoblu host'
      .option '-g, --gateblu', 'Claim Gateblu (Mac OS X only)'
      .parse process.argv

    @filename = _.first commander.args
    @filename ?= "meshblu.json" unless commander.gateblu?
    @filename ?= path.resolve "#{process.env.HOME}/Library/Application Support/GatebluService/meshblu.json" if commander.gateblu?

    @parseConfig()

  parseConfig: =>
    @getMeshbluConfig()
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
      path = "/node-wizard/claim/#{uuid}/#{newToken}"
      if _.contains ["443", 443], octobluPort
        return open "https://#{octobluServer}#{path}"

      if _.contains ["80", 80], octobluPort
        return open "http://#{octobluServer}#{path}"

      open "http://#{octobluServer}:#{octobluPort}#{path}"


(new ClaimDevice()).run()

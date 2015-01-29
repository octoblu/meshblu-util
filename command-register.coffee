commander = require 'commander'
_         = require 'lodash'
meshblu   = require 'meshblu'
url       = require 'url'

DEFAULT_HOST = 'meshblu.octoblu.com'
DEFAULT_PORT = 80

class KeygenCommand
  parseOptions: =>
    commander
      .option '-s, --server <host[:port]>', 'Meshblu host'
      .parse process.argv

  parseConfig: =>
    unless commander.server?
      return {server: DEFAULT_HOST, port: DEFAULT_PORT}

    server = commander.server
    unless _.startsWith server, 'ws'
      protocol = if port == 443 then 'wss://' else 'ws://'
      server = protocol + server

    {hostname, port} = url.parse server
    port ?= 80
    {server: hostname, port: port}

  run: =>
    @parseOptions()
    @config = @parseConfig()
    @config.uuid = 'wrong' # to force a notReady
    @conn = meshblu.createConnection @config
    @conn.on 'notReady', @onReady

  onReady: (credentials) =>
    @conn.register {}, (credentials) =>
      @config.uuid = credentials.uuid
      @config.token = credentials.token
      console.log JSON.stringify(@config, null, 2)
      process.exit 0

(new KeygenCommand()).run()

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
      .option '-t, --timeout <milliseconds>', 'Request timeout'
      .parse process.argv

      @data = JSON.parse(commander.data) if commander.data?
      @registerFileName = commander.file

  parseConfig: =>
    {server, port} = @parseServer()
    {server: server, port: port, timeout: commander.timeout || 10000}

  parseServer: =>
    unless commander.server?
      return {server: DEFAULT_HOST, port: DEFAULT_PORT}

    server = commander.server

    unless _.startsWith server, 'ws'
      protocol = if port == 443 then 'wss://' else 'ws://'
      server = protocol + server

    {hostname, port} = url.parse server
    port ?= DEFAULT_PORT

    {server: hostname, port: port}

  run: =>
    @parseOptions()
    @config = @parseConfig()
    @conn = meshblu.createConnection @config
    @conn.on 'ready', @onReady
    @conn.on 'notReady', @notReady
    setTimeout @notReady, @config.timeout

  onReady: =>
    console.log "online"
    process.exit 0

  notReady: =>
    console.log "offline"
    process.exit 1

(new KeygenCommand()).run()

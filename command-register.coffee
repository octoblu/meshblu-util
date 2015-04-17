commander = require 'commander'
colors    = require 'colors'
fs        = require 'fs'
_         = require 'lodash'
meshblu   = require 'meshblu'
url       = require 'url'
path      = require 'path'

DEFAULT_HOST = 'meshblu.octoblu.com'
DEFAULT_PORT = 80

class KeygenCommand
  parseOptions: =>
    commander
      .option '-s, --server <host[:port]>', 'Meshblu host'
      .option '-t, --type <device:type>', 'Device type'
      .option '-d, --data <\'{"name":"Some Device"}\'>', 'Device Data [JSON]'
      .option '-o, --open', "Make the device open to everyone"
      .option '-f, --file <path/to/updated-device.json>', 'Device Data [JSON FILE]'
      .parse process.argv

      @data = JSON.parse(commander.data) if commander.data?
      @isOpen = commander.open?
      @registerFileName = commander.file
      @data = _.defaults(@data, @parseRegister(@registerFileName)) if @registerFileName?


  parseRegister: (filename) =>
    try
      JSON.parse fs.readFileSync path.resolve(filename)
    catch error
      console.error colors.yellow error.message
      console.error colors.red '\n  Unable to open a valid register-device.json file'
      commander.outputHelp()
      process.exit 1

  parseConfig: =>
    {server, port} = @parseServer()

    {server: server, port: port, type: commander.type}

  parseServer: =>
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
    lockedDownParams =
      discoverWhitelist: [],
      configureWhitelist: [],
      receiveWhitelist: []

    openParams =
      discoverWhitelist: ['*']
      configureWhitelist: ['*']
      receiveWhitelist: ['*']

    deviceParams =
      type: @config.type

    _.extend deviceParams, lockedDownParams unless @isOpen
    _.extend deviceParams, openParams if @isOpen
    _.extend deviceParams, @data if @data?

    @conn.register deviceParams, (credentials) =>
      @config.uuid = credentials.uuid
      @config.token = credentials.token
      _.extend(@config, @data) if @data?
      console.log JSON.stringify(@config, null, 2)
      process.exit 0

(new KeygenCommand()).run()

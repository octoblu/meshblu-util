commander = require 'commander'
colors    = require 'colors'
fs        = require 'fs'
_         = require 'lodash'
MeshbluHttp   = require 'meshblu-http'
url       = require 'url'
path      = require 'path'
debug     = require('debug')('meshblu-util:register')

DEFAULT_HOST = 'meshblu.octoblu.com'
DEFAULT_PORT = 443

class KeygenCommand
  parseOptions: =>
    commander
      .option '-s, --server <host[:port]>', 'Meshblu host'
      .option '-t, --type <device:type>', 'Device type'
      .option '-d, --data <\'{"name":"Some Device"}\'>', 'Device Data [JSON]'
      .option '-o, --open', 'Make the device open to everyone'
      .option '-f, --file <path/to/updated-device.json>', 'Device Data [JSON FILE]'
      .option '-L, --legacy', 'Create a device with legacy whitelists'
      .parse process.argv

      @data = JSON.parse(commander.data) if commander.data?
      @data ?= {}
      @isOpen = commander.open?
      @registerFileName = commander.file
      @data = _.defaults(@data, @parseRegister(@registerFileName)) if @registerFileName?
      @isLegacy = commander.legacy

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

    serverConfig = commander.server.split(':')

    {server: serverConfig[0], port: serverConfig[1]}

  run: =>
    @parseOptions()
    config = @parseConfig()

    {lockedDownParams, openParams} = @getParams()

    deviceParams =
      type: config.type

    deviceParams = _.defaults deviceParams, @data if @data?

    if @isOpen
      deviceParams = _.defaults deviceParams, openParams if @isOpen
    else
      deviceParams = _.defaults deviceParams, lockedDownParams

    debug 'registering', deviceParams, config
    meshblu = new MeshbluHttp config
    meshblu.register deviceParams, (error, credentials) =>
      return console.error colors.red error if error?
      {uuid, token} = credentials
      config =_.defaults uuid: uuid, token: token, config, @data
      console.log JSON.stringify(config, null, 2)
      process.exit 0

  getParams: =>
    if @isLegacy
      lockedDownParams =
        configureWhitelist: []
        discoverWhitelist:  []
        receiveWhitelist:   []
        sendWhitelist:      []

      openParams =
        configureWhitelist: ['*']
        discoverWhitelist:  ['*']
        receiveWhitelist:   ['*']
        sendWhitelist:      ['*']

      return {lockedDownParams, openParams}

    lockedDownParams =
      meshblu:
        version: '2.0.0'
        whitelists: {}

    openParams =
      meshblu:
        version: '2.0.0'
        whitelists: {
          broadcast:
            as:       [uuid: '*']
            received: [uuid: '*']
            sent:     [uuid: '*']
          discover:
            as:       [uuid: '*']
            view:     [uuid: '*']
          configure:
            as:       [uuid: '*']
            received: [uuid: '*']
            sent:     [uuid: '*']
            update:   [uuid: '*']
          message:
            as:       [uuid: '*']
            from:     [uuid: '*']
            received: [uuid: '*']
            sent:     [uuid: '*']
        }

    return {lockedDownParams, openParams}

(new KeygenCommand()).run()

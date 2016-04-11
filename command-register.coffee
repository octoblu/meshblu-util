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
      .option '-o, --open', "Make the device open to everyone"
      .option '-f, --file <path/to/updated-device.json>', 'Device Data [JSON FILE]'
      .parse process.argv

      @data = JSON.parse(commander.data) if commander.data?
      @data ?= {}
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

    serverConfig = commander.server.split(':')

    {server: serverConfig[0], port: serverConfig[1]}

  run: =>
    @parseOptions()
    config = @parseConfig()

    lockedDownParams =
      meshblu:
        whitelists: {}

    openParams =
      meshblu:
        version: '2.0.0'
        whitelists: {
          broadcast:
            as:       {'*': {}}
            received: {'*': {}}
            sent:     {'*': {}}
          discover:
            as:       {'*': {}}
            view:     {'*': {}}
          configure:
            as:       {'*': {}}
            received: {'*': {}}
            sent:     {'*': {}}
            update:   {'*': {}}
          message:
            as:       {'*': {}}
            from:     {'*': {}}
            received: {'*': {}}
            sent:     {'*': {}}
        }

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

(new KeygenCommand()).run()

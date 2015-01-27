_         = require 'lodash'
colors    = require 'colors/safe'
commander = require 'commander'
fs        = require 'fs'
path      = require 'path'
packageJSON = require './package.json'
Meshblu     = require './src/meshblu'

class Command
  constructor: ->

  parseConfig: (filename) =>
    try
      JSON.parse fs.readFileSync path.join('.', filename)
    catch error
      console.error colors.yellow error.message
      console.error colors.red '\n  Unable to open a valid meshblu.json file'
      commander.outputHelp()
      process.exit 1

  parseOptions: =>
    commander
      .version packageJSON.version
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args

    unless @filename?
      console.error colors.red '\n  You must specify the path to meshblu.json.'
      commander.outputHelp()
      process.exit 1

  run: =>
    @parseOptions()

    @config = @parseConfig @filename
    @meshblu = new Meshblu @config, @afterConnect

  afterConnect: =>
    {@publicKey, @privateKey} = @meshblu.generateKeyPair()

    @config.privateKey = @privateKey
    fs.writeFileSync path.join('.', @filename), JSON.stringify(@config, null, 2)
    @meshblu.update publicKey: @publicKey, (response) =>
      if response.error? || response.message
        console.error colors.red(response.error ? response.message)
        process.exit 1

      process.exit 0

(new Command()).run()

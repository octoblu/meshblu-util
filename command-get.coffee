commander = require 'commander'
colors    = require 'colors'
fs        = require 'fs'
_         = require 'lodash'
Meshblu   = require './src/Meshblu'
path      = require 'path'

class GetCommand
  parseConfig: (filename) =>
    try
      JSON.parse fs.readFileSync path.resolve(filename)
    catch error
      console.error colors.yellow error.message
      console.error colors.red '\n  Unable to open a valid meshblu.json file'
      commander.outputHelp()
      process.exit 1

  parseOptions: =>
    commander
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
    @meshblu.whoami (data) =>
      console.log JSON.stringify(data, null, 2)
      process.exit 0

(new GetCommand()).run()

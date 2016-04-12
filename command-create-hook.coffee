_           = require 'lodash'
fs          = require 'fs'
path        = require 'path'
colors      = require 'colors'
commander   = require 'commander'
BaseCommand = require './base-command'

class UpdateCommand extends BaseCommand
  parseOptions: =>
    commander
      .option '-u, --uuid <uuid>', 'Meshblu device to subscribe to (defaults to uuid from meshblu.json)'
      .option '-t, --type <type>',  'the type of hook to create'
      .option '-U, --url <url>',  'the destination url of the hook'
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args
    {@type, @url, @uuid} = commander
    unless @type? && @url?
      commander.outputHelp()
      @die 'You must specify a type and url.'

  run: =>
    @parseOptions()
    @uuid ?= @getMeshbluConfig().uuid
    meshbluHttp = @getMeshbluHttp()
    meshbluHttp.createHook @uuid, @type, @url, (error) =>
      @die error.message if error?
      process.exit 0

(new UpdateCommand()).run()

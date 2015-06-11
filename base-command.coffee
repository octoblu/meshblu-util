_             = require 'lodash'
fs            = require 'fs'
colors        = require 'colors'
commander     = require 'commander'
MeshbluHttp   = require 'meshblu-http'
MeshbluConfig = require 'meshblu-config'

class BaseCommand
  getMeshbluHttp: =>
    @parseConfig()
    @die new Error "Invalid server and port. \nPlease check your meshblu configuration." unless @config.server? and @config.port?
    new MeshbluHttp @config

  parseConfig: =>
    @meshbluConfig = new MeshbluConfig filename: @filename
    @config = @meshbluConfig.toJSON()

  parseOptions: =>
    commander
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args
    @filename ?= "#{__dirname}/meshblu.json"

  die: =>
    console.error colors.red arguments...
    process.exit 1

module.exports = BaseCommand

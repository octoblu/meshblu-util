_             = require 'lodash'
fs            = require 'fs'
colors        = require 'colors'
commander     = require 'commander'
MeshbluHttp   = require 'meshblu-http'
MeshbluConfig = require 'meshblu-config'

class BaseCommand
  getMeshbluHttp: =>
    @parseConfig()
    new MeshbluHttp @config

  getMeshbluConfig: =>
    @parseConfig()
    return @config

  parseConfig: =>
    return if @meshbluConfig?
    @meshbluConfig = new MeshbluConfig filename: @filename
    @config = @meshbluConfig.toJSON()
    return if @config.resolveSrv
    @die new Error "Invalid hostname. \nPlease check your meshblu configuration." unless @config.hostname? 

  parseOptions: =>
    commander
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args
    @filename ?= "meshblu.json"

  die: (error) =>
    if 'Error' == typeof error
      console.error colors.red error.message
    else
      console.error colors.red arguments...
    process.exit 1

module.exports = BaseCommand

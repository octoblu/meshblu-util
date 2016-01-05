fs              = require 'fs'
path            = require 'path'
_               = require 'lodash'
commander       = require 'commander'
GatebluShadower = require 'gateblu-shadower'

BaseCommand   = require './base-command'
class GatebluShadowSync extends BaseCommand
  run: =>
    @parseOptions()
    meshbluHttp = @getMeshbluHttp()

    meshbluHttp.whoami (error, gateblu) =>
      return @die error if error?
      return @updateVirtualsFromReal gateblu if gateblu.shadows?
      return @updateRealFromVirtual gateblu if gateblu.shadowing?
      @die new Error "device is not virtual and has no shadows, so syncing doesn't make sense"

  updateVirtualsFromReal: (gateblu) =>
    console.log 'syncing virtual gateblus with the real one'
    gatebluShadower = new GatebluShadower @getMeshbluConfig()

    gatebluShadower.updateVirtualsFromReal gateblu, @finish

  updateRealFromVirtual: (gateblu) =>
    console.log 'syncing real gateblu with a virtual one'
    gatebluShadower = new GatebluShadower @getMeshbluConfig()

    gatebluShadower.updateRealFromVirtual gateblu, @finish

  finish: (error) =>
    @die error if error?
    console.log "synced!"
    process.exit 0

  parseOptions: =>
    commander
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args


(new GatebluShadowSync()).run()

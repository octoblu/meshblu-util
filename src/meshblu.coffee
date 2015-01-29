_       = require 'lodash'
meshblu = require 'meshblu'
url     = require 'url'

class Meshblu
  constructor: (config, callback=->) ->
    @config = config
    @connection = meshblu.createConnection @config
    @connection.on 'ready', callback
    @connection.on 'notReady', console.log

  close: =>
    @connection.close()

  generateKeyPair: =>
    @connection.generateKeyPair()

  onMessage: (callback=->) =>
    @connection.on 'message', callback

  whoami: (callback=->) =>
    @connection.whoami {uuid: @config.uuid}, callback

  update: (data, callback) =>
    query = _.defaults {uuid: @config.uuid}, data
    @connection.update query, callback

module.exports = Meshblu

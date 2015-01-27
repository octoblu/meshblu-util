meshblu = require 'meshblu'
url    = require 'url'
_ = require 'lodash'

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

  update: (data, callback) =>
    query = _.defaults {uuid: @config.uuid}, data
    @connection.update query, callback

module.exports = Meshblu

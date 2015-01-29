commander = require 'commander'
meshblu   = require 'meshblu'

class KeygenCommand
  parseOptions: =>
    commander
      .parse process.argv

  run: =>
    @parseOptions()

    @config = {server: 'meshblu.octoblu.com', port: 80, uuid: 'wrong'}
    @conn = meshblu.createConnection @config
    @conn.on 'notReady', @onReady

  onReady: (credentials) =>
    @conn.register {}, (credentials) =>
      @config.uuid = credentials.uuid
      @config.token = credentials.token
      console.log JSON.stringify(@config, null, 2)
      process.exit 0

(new KeygenCommand()).run()

BaseCommand   = require './base-command'
fs        = require 'fs'
path      = require 'path'

class KeygenCommand extends BaseCommand
  run: =>
    @parseOptions()
    meshbluHttp = @getMeshbluHttp()

    {@publicKey, @privateKey} = meshbluHttp.generateKeyPair()

    @config.privateKey = @privateKey
    fs.writeFileSync path.resolve(@filename), JSON.stringify(@config, null, 2)
    meshbluHttp.update publicKey: @publicKey, (error, response) =>
      return @die error if error?
      process.exit 0

(new KeygenCommand()).run()

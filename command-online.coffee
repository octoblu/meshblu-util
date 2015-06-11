BaseCommand   = require './base-command'

class OnlineCommand extends BaseCommand
  run: =>
    @parseOptions()
    meshbluHttp = @getMeshbluHttp()

    meshbluHttp.whoami (error, data) =>
      return @die error if error?

      console.log 'online' if data.online
      console.log 'offline' unless data.online
      process.exit 0

(new OnlineCommand()).run()

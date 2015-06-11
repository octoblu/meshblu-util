BaseCommand   = require './base-command'

class GetCommand extends BaseCommand
  run: =>
    @parseOptions()
    meshbluHttp = @getMeshbluHttp()

    meshbluHttp.whoami (error, data) =>
      return @die error if error?

      console.log JSON.stringify(data, null, 2)
      process.exit 0

(new GetCommand()).run()

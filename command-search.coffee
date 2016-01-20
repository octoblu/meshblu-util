_ = require 'lodash'
commander = require 'commander'

BaseCommand   = require './base-command'


class GetCommand extends BaseCommand
  run: =>
    @parseOptions()
    meshbluHttp = @getMeshbluHttp()
    meshbluHttp.search @query, {}, (error, data) =>
      return @die error if error?
      console.log JSON.stringify(data, null, 2)
      process.exit 0

  parseOptions: =>
    commander
      .option '-q, --query <query>', 'Meshblu device to get (defaults to uuid from meshblu.json)'
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args
    {query} = commander

    unless query?
      commander.outputHelp()
      process.exit 0

    try
      @query = JSON.parse query
    catch e
      commander.outputHelp()
      @die 'Invalid message json'

(new GetCommand()).run()

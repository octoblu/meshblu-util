_ = require 'lodash'
commander = require 'commander'

BaseCommand   = require './base-command'


class SearchCommand extends BaseCommand
  run: =>
    @parseOptions()
    meshbluHttp = @getMeshbluHttp()
    options = {}
    options.as = @as if @as?
    meshbluHttp.search @query, options, (error, data) =>
      return @die error if error?
      console.log JSON.stringify(data, null, 2)
      process.exit 0

  parseOptions: =>
    commander
      .option '-q, --query <query>', 'Meshblu device to get (defaults to uuid from meshblu.json)'
      .option '-a, --as <uuid>', 'the uuid to send the message as (defaults to meshblu.json)'
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename = _.first commander.args
    @as = commander.as

    {query} = commander

    unless query?
      commander.outputHelp()
      process.exit 0

    try
      @query = JSON.parse query
    catch e
      commander.outputHelp()
      @die 'Invalid message json'

(new SearchCommand()).run()

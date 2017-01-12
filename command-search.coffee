_ = require 'lodash'
commander = require 'commander'
fs          = require 'fs'
path        = require 'path'
colors      = require 'colors'

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

  loadQueryFile: (filename) =>
    try
      return fs.readFileSync path.resolve(filename)
    catch error
      console.error colors.yellow error.message
      console.error colors.red '\n  Unable to open a valid query.json file'
      commander.outputHelp()
      process.exit 1


  parseOptions: =>
    commander
      .option '-q, --query <query>', 'Meshblu device to get (defaults to uuid from meshblu.json)'
      .option '-a, --as <uuid>', 'the uuid to send the message as (defaults to meshblu.json)'
      .option '-f, --file <path/to/query.json>', 'query [JSON FILE]'
      .usage '[options] <path/to/meshblu.json>'
      .parse process.argv

    @filename      = _.first commander.args
    @queryFileName = commander.file
    @as            = commander.as

    {query}        = commander
    query          = @loadQueryFile(@queryFileName) if @queryFileName?

    unless query?
      commander.outputHelp()
      process.exit 0

    try
      @query = JSON.parse query
    catch e
      commander.outputHelp()
      @die 'Invalid message json'

(new SearchCommand()).run()

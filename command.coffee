commander = require 'commander'
packageJSON = require './package.json'

class Command
  run: =>
    commander
      .version packageJSON.version
      .command 'get',      'retrieve a device using a meshblu.json'
      .command 'keygen',   'generate public/private keypair, update\n' +
               '            meshblu.json with the private key, \n' +
               '            and publish the public key'
      .command 'register', 'register a new device with Meshblu'
      .parse process.argv

    unless commander.runningCommand
      commander.outputHelp()
      process.exit 1

(new Command()).run()

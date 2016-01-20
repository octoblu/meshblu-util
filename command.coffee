commander   = require 'commander'
packageJSON = require './package.json'

class Command
  run: =>
    commander
      .version packageJSON.version
      .command 'claim', 'claim Meshblu device in Octoblu'
      .command 'create-subscription', 'Create a device subscription'
      .command 'create-hook', 'Create a message hook'
      .command 'generate-token', 'generate and store token'
      .command 'get',      'retrieve a device using a meshblu.json'
      .command 'keygen',   'generate public/private keypair, update\n' +
               '            meshblu.json with the private key, \n' +
               '            and publish the public key'
      .command 'message',  'send a message with Meshblu'
      .command 'online',   'check if Meshblu device is online'
      .command 'register', 'register a new device with Meshblu'
      .command 'revoke-token', 'revoke token from device'
      .command 'server-check', 'check if Meshblu server is available'
      .command 'search', 'search for devices'
      .command 'subscribe','subscribe to messages to a Meshblu Device'
      .command 'update',   'update an existing device in Meshblu'
      .command 'gateblu-shadow-sync',   "synchronize a gateblu and it's shadows"
      .parse process.argv

    unless commander.runningCommand
      commander.outputHelp()
      process.exit 1

(new Command()).run()

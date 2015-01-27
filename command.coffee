commander = require 'commander'
packageJSON = require './package.json'

class Command
  run: =>
    commander
      .version packageJSON.version
      .command 'keygen [path/to/meshblu.json]', 'generate public/private keypair, update meshblu.json with the private key, and publish the public key'
      .parse process.argv

(new Command()).run()

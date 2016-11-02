_             = require 'lodash'
colors        = require 'colors'
MeshbluHttp   = require 'meshblu-http'
MeshbluConfig = require 'meshblu-config'

class Util
  @getMeshbluHttp: ({filename}) =>
    return new MeshbluHttp Util.parseConfig {filename}

  @getMeshbluConfig: ({filename}) =>
    return Util.parseConfig({filename})

  @parseConfig: ({filename}) =>
    return new MeshbluConfig({filename}).toJSON()

  @die: (error) =>
    process.exit 0 unless error?

    unless _.isError error
      console.error 'Received non error object.'
      console.error 'Refusing to show it until you give me a proper one'
      throw new Error 'Pouting'

    console.error colors.red error.message
    process.exit 1

module.exports = Util

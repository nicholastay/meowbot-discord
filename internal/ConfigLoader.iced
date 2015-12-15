configFile = require('path').join __dirname, '../', 'config', 'Config.iced'

exports.reloadConfig = reloadConfig = ->
    config = Meowbot.Config = {}
    delete require.cache[require.resolve(configFile)] if require.cache[require.resolve(configFile)]
    config = Meowbot.Config = require configFile
    Meowbot.Logging.modLog 'Config', 'Config (re)loaded.'
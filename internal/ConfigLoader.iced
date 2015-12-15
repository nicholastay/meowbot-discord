configPath = require('path').join __dirname, '../', 'config'

exports.reloadConfig = reloadConfig = ->
    Meowbot.Repl.context.rc = reloadConfig if not Meowbot.Config # Nothing in the config must be first time
    config = Meowbot.Config = {}
    delete require.cache[require.resolve("#{configPath}/Config")] if require.cache[require.resolve("#{configPath}/Config")]
    config = Meowbot.Config = require "#{configPath}/Config"
    Meowbot.Logging.modLog 'Config', 'Config (re)loaded.'
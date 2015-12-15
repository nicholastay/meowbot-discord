repl = require 'repl'
fs = require 'fs'

Meowbot = global.Meowbot = new class
    constructor: ->
        @Config = {}
        @Discord = null
        @HandlerSettings = {} # Persistent handler settings across reloads
        @MessageHandlers = {}
        @CommandHandlers = {}
        @HandlerIntervals = {}

# REPL Session client
replS = Meowbot.Repl = repl.start
    prompt: 'Meow> '
console.log '\n'

# Core file loader
reloadInternals = ->
    for module in fs.readdirSync './internal'
        moduleName = module.replace '.iced', ''
        if require.cache[require.resolve("./internal/#{module}")]
            delete Meowbot[moduleName]
            delete require.cache[require.resolve("./internal/#{module}")]
            if Meowbot.Logging # the module may not have been loaded at this stage lol
                Meowbot.Logging.modLog 'Internal', 'Unloaded internal module: ' + moduleName
            else
                console.log 'Unloaded internal module: ' + moduleName
        Meowbot[moduleName] = require "./internal/#{module}"
        if Meowbot.Logging
            Meowbot.Logging.modLog 'Internal', 'Loaded internal module: ' + moduleName
        else
            console.log 'Loaded internal module: ' + moduleName
    Meowbot.Logging.modLog 'Internal', 'Internal modules (re)loaded.'

reloadInternals() # Load core files
Meowbot.ConfigLoader.reloadConfig() # Also make sure loaded
Meowbot.MsgHandlers.reloadHandlers(true)
Meowbot.DiscordLoader.login(true)

replS.context.ch = Meowbot.CommandHandlers
replS.context.mh = Meowbot.MessageHandlers

Meowbot.Repl.defineCommand 'ri',
    help: 'Reload all internal modules (be careful, they are essential core functions you are relaoding.)'
    action: reloadInternals
Meowbot.Repl.defineCommand 'rc',
    help: 'Reload the config'
    action: Meowbot.ConfigLoader.reloadConfig

# Global error handler
process.on 'uncaughtException', (err) ->
    Meowbot.Logging.error 'GLOBAL ERROR STACK: \n' + err.stack
    process.exit 1
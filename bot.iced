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

unsureModLog = (mod, msg) -> # ModLog when unsure if logging module is loaded or not
    if Meowbot.Logging
        Meowbot.Logging.modLog mod, msg
    else
        console.log "[#{mod}] #{msg}"
# Core file loader
reloadInternals = ->
    for module in fs.readdirSync './internal'
        continue if require('path').extname(module) isnt '.iced'
        moduleName = module.replace '.iced', ''
        if require.cache[require.resolve("./internal/#{module}")]
            delete Meowbot[moduleName]
            delete require.cache[require.resolve("./internal/#{module}")]
            unsureModLog 'Internal', 'Unloaded internal module: ' + moduleName
        mod = Meowbot[moduleName] = require "./internal/#{module}"
        unsureModLog 'Internal', 'Loaded internal module: ' + moduleName
        if typeof mod.init is 'function'
            mod.init()
            unsureModLog 'Internal', 'Ran internal init script for: ' + moduleName
    unsureModLog 'Internal', 'Internal modules (re)loaded.'

reloadInternals() # Load core files
Meowbot.ConfigLoader.reloadConfig() # Also make sure loaded
Meowbot.MsgHandlers.reloadHandlers()
Meowbot.DiscordLoader.login()

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
    if err.code is 'ECONNRESET'
        return console.log 'Detected ECONNRESET: just like some youtube mishap or something, ignoring and continuing...'
    if err.code is 'EPIPE'
        return console.log 'Detected EPIPE: well whatever by now I\'m just annoyed, I\'ll just let it slip...'

    process.exit 1
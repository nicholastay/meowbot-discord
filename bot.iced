DiscordJS = require 'discord.js'
repl = require 'repl'
fs = require 'fs'

Meowbot = global.Meowbot = new class
    constructor: ->
        @Config = {}
        @Discord = null
        @HandlerSettings = {} # Persistent handler settings across reloads

discord = Meowbot.Discord = new DiscordJS.Client()
messageHandlers = {}
commandHandlers = {}
handlerIntervals = {}
config = {}

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
reloadInternals()

unloadHandler = (handlerName) ->
    if require.cache[require.resolve("./handlers/#{handlerName}.iced")]
        delete messageHandlers[handlerName] if messageHandlers[handlerName]
        delete commandHandlers[handlerName] if commandHandlers[handlerName]
        clearInterval i for i in handlerIntervals[handlerName] if handlerIntervals[handlerName]
        delete handlerIntervals[handlerName] if handlerIntervals[handlerName]
        delete require.cache[require.resolve("./handlers/#{handlerName}.iced")]
        Meowbot.Logging.modLog 'MsgHandlers', 'Unloaded handler: ' + handlerName

loadHandler = (handlerName) ->
    handl = require './handlers/' + handlerName
    if typeof handl.Message is 'function'
        messageHandlers[handlerName] = handl.Message
        Meowbot.Logging.modLog 'MsgHandlers', 'Loaded meowssage handler: ' + handlerName
    if typeof handl.Command is 'function'
        commandHandlers[handlerName] = handl.Command
        Meowbot.Logging.modLog 'MsgHandlers', 'Loaded comeownd handler: ' + handlerName
    if typeof handl.Init is 'function'
        handl.Init()
        Meowbot.Logging.modLog 'MsgHandlers', 'Ran inyatialization script for: ' + handlerName
    if handl.Intervals?
        handlerIntervals[handlerName] = handl.Intervals
        Meowbot.Logging.modLog 'MsgHandlers', 'Loaded intermeows for: ' + handlerName

reloadHandler = (handlerName, firstRun) ->
    unloadHandler handlerName if not firstRun # No need to do this for first run
    loadHandler handlerName

reloadHandlers = (firstRun) ->
    for handler in fs.readdirSync './handlers' then reloadHandler handler.replace('.iced', ''), firstRun
    return Meowbot.Logging.modLog 'MsgHandlers', 'Handlers successfully reloaded.' if not firstRun
    Meowbot.Logging.modLog 'MsgHandlers', 'Handlers successfully loaded.'

reloadConfig = ->
    config = Meowbot.Config = {}
    delete require.cache[require.resolve('./config/Config')] if require.cache[require.resolve('./config/Config')]
    config = Meowbot.Config = require './config/Config'
    Meowbot.Logging.modLog 'Config', 'Config (re)loaded.'

reloadConfig()
reloadHandlers(true)

discord.on 'ready', ->
    Meowbot.Logging.modLog 'Discord', 'Logged in to Discord.'
    discord.setStatus 'online', 452

discord.on 'message', (message) ->
    isPM = message.channel instanceof DiscordJS.PMChannel
    for handlerName, handler of messageHandlers then handler(message, isPM)

    tail = message.content.split ' '
    command = tail.shift().toLowerCase().trim()
    tail = tail.join ' '
    for handlerName, handler of commandHandlers then handler(command, tail, message, isPM) 

discord.on 'disconnected', ->
    Meowbot.Logging.modLog 'Discord', 'Client was disconnected from Discord. Will try to login again...'
    logInDiscord()

logInDiscord = ->
    discord.login config.discord.username, config.discord.password
    Meowbot.Logging.modLog 'Discord', 'Logging in to Discord...'

logOffDiscord = ->
    discord.logout ->
        Meowbot.Logging.modLog 'Discord', 'Logged out of Discord.'
        process.exit()
    Meowbot.Logging.modLog 'Discord', 'Logging off Discord...'

replS = repl.start
    prompt: 'Meow> '
console.log '\n'

replS.context.discord = discord
replS.context.d = discord
replS.context.ch = commandHandlers
replS.context.mh = messageHandlers
replS.context.rh = reloadHandlers
replS.context.r = reloadHandler
replS.context.rc = reloadConfig
replS.context.ri = reloadInternals
replS.context.l = loadHandler
replS.context.u = unloadHandler
replS.context.dc = logOffDiscord

# Global error handler
process.on 'uncaughtException', (err) ->
    Meowbot.Logging.error 'GLOBAL: ' + err
    Meowbot.Logging.error 'GLOBAL ERROR STACK: ' + err.stack
    process.exit 1

logInDiscord()
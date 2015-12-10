DiscordJS = require 'discord.js'
repl = require 'repl'
fs = require 'fs'

Meowbot = global.Meowbot = new class
    constructor: ->
        @Config = {}
        @Discord = null
        @Tools = {}
        @AudioQueue = []

discord = Meowbot.Discord = new DiscordJS.Client()
messageHandlers = {}
commandHandlers = {}
handlerIntervals = {}
config = {}
tools = {}

unloadHandler = (handlerName) ->
    if require.cache[require.resolve("./handlers/#{handlerName}.iced")]
        delete messageHandlers[handlerName] if messageHandlers[handlerName]
        delete commandHandlers[handlerName] if commandHandlers[handlerName]
        clearInterval i for i in handlerIntervals[handlerName] if handlerIntervals[handlerName]
        delete handlerIntervals[handlerName] if handlerIntervals[handlerName]
        delete require.cache[require.resolve("./handlers/#{handlerName}.iced")]
        console.log 'Unloaded handler: ' + handlerName

loadHandler = (handlerName) ->
    handl = require './handlers/' + handlerName
    if typeof handl.Message is 'function'
        messageHandlers[handlerName] = handl.Message
        console.log 'Loaded meowssage handler: ' + handlerName
    if typeof handl.Command is 'function'
        commandHandlers[handlerName] = handl.Command
        console.log 'Loaded comeownd handler: ' + handlerName
    if typeof handl.Init is 'function'
        handl.Init()
        console.log 'Ran inyatialization script for: ' + handlerName
    if handl.Intervals?
        handlerIntervals[handlerName] = handl.Intervals
        console.log 'Loaded intermeows for: ' + handlerName

reloadHandler = (handlerName, firstRun) ->
    unloadHandler handlerName if not firstRun # No need to do this for first run
    loadHandler handlerName

reloadHandlers = (firstRun) ->
    for handler in fs.readdirSync './handlers' then reloadHandler handler.replace('.iced', ''), firstRun
    return console.log 'Handlers successfully reloaded.' if not firstRun
    console.log 'Handlers successfully loaded.'

reloadConfig = ->
    config = Meowbot.Config = {}
    delete require.cache[require.resolve('./config')] if require.cache[require.resolve('./config')]
    config = Meowbot.Config = require './config'
    console.log 'Config (re)loaded.'

reloadTools = ->
    tools = Meowbot.Tools = {}
    delete require.cache[require.resolve('./tools')] if require.cache[require.resolve('./tools')]
    tools = Meowbot.Tools = require './tools'
    console.log 'Tools (re)loaded.'

reloadConfig()
reloadTools()
reloadHandlers(true)

discord.on 'ready', ->
    console.log 'Logged in to Discord.'
    discord.setStatus 'online', 452

discord.on 'message', (message) ->
    isPM = message.channel instanceof DiscordJS.PMChannel
    for handlerName, handler of messageHandlers then handler(message, isPM)

    tail = message.content.split ' '
    command = tail.shift().toLowerCase()
    tail = tail.join ' '
    for handlerName, handler of commandHandlers then handler(command, tail, message, isPM) 

logOffDiscord = ->
    discord.logout ->
        console.log 'Logged out of Discord.'
        process.exit()
    console.log 'Logging off Discord...'

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
replS.context.rt = reloadTools
replS.context.l = loadHandler
replS.context.u = unloadHandler
replS.context.dc = logOffDiscord

discord.login config.discord.username, config.discord.password
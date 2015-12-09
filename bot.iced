DiscordJS = require 'discord.js'
repl = require 'repl'
fs = require 'fs'
config = require './config'

discord = new DiscordJS.Client()

unloadFromNode = (fileName) ->
    delete require.cache[require.resolve(fileName)] if require.cache[require.resolve(fileName)]

messageHandlers = {}
commandHandlers = {}
reloadHandler = (handler) ->
    handlerName = handler.replace '.iced', ''
    unloadFromNode './handlers/' + handler
    handl = require './handlers/' + handler
    if typeof handl.Message is 'function'
        messageHandlers[handlerName] = handl.Message
        console.log 'Loaded meowssage handler: ' + handlerName
    if typeof handl.Command is 'function'
        commandHandlers[handlerName] = handl.Command
        console.log 'Loaded comeownd handler: ' + handlerName
    if typeof handl.Init is 'function'
        handl.Init()
        console.log 'Ran inyatialization script for: ' + handlerName

reloadHandlers = ->
    messageHandlers = {}
    commandHandlers = {}
    for handler in fs.readdirSync './handlers' then reloadHandler handler
    console.log 'Handlers successfully (re)loaded'

reloadHandlers()

discord.on 'ready', ->
    console.log 'Logged in to Discord.'
    discord.setStatus 'online', 452

discord.on 'message', (message) ->
    for handlerName, handler of messageHandlers then handler(message, discord)

    tail = message.content.split ' '
    command = tail.shift().toLowerCase()
    tail = tail.join ' '
    for handlerName, handler of commandHandlers then handler(command, tail, message, discord)

discord.login config.discord.username, config.discord.password

replS = repl.start
    prompt: 'Meow> '
console.log '\n'

logOffDiscord = ->
    discord.logout ->
        console.log 'Logged out of Discord.'
        process.exit()

replS.context.discord = discord
replS.context.ch = commandHandlers
replS.context.mh = messageHandlers
replS.context.rh = reloadHandlers
replS.context.r = reloadHandler
replS.context.dc = logOffDiscord
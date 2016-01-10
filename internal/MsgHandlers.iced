fs = require 'fs'
path = require 'path'

handlersPath = path.join __dirname, '../', 'handlers'


onMessage = (message) -> # What to do on a message. Main basic parser.
    isPM = message.channel instanceof require('discord.js').PMChannel
    for handlerName, handler of Meowbot.MessageHandlers then handler message, isPM
    if message.content[0] is (Meowbot.Config.commandPrefix or '!')
        spaceIndex = message.content.indexOf ' '
        command = message.content.toLowerCase().substr 1, (if spaceIndex is -1 then message.content.length else spaceIndex-1) # substr from without prefix to first space
        tail = if spaceIndex is -1 then '' else message.content.substr spaceIndex+1, message.content.length # substr after space to end, also check if index is -1, -1 means couldnt find, so the person just did the command with no args
        for handlerName, handler of Meowbot.CommandHandlers then handler(command, tail, message, isPM)

exports.init = ->
    # REPL command definitions
    Meowbot.Repl.defineCommand 'rh',
        help: 'Reload all message handlers'
        action: reloadHandlers
    Meowbot.Repl.defineCommand 'r',
        help: 'Reload a message handler'
        action: reloadHandler
    Meowbot.Repl.defineCommand 'l',
        help: 'Load a message handler'
        action: loadHandler
    Meowbot.Repl.defineCommand 'u',
        help: 'Unload a message handler'
        action: unloadHandler

    # Refresh main event handler
    Meowbot.Discord.removeListener 'message', onMessage
    Meowbot.Discord.on 'message', onMessage

exports.unloadHandler = unloadHandler = (handlerName) ->
    await fs.access "#{handlersPath}/#{handlerName}.iced", fs.R_OK, defer fileErr
    return Meowbot.Logging.modLog 'MsgHandlers', "Unable to unload handler '#{handlerName}', it proably was never loaded in the first place." if fileErr
    if require.cache[require.resolve("#{handlersPath}/#{handlerName}.iced")]
        delete Meowbot.MessageHandlers[handlerName] if Meowbot.MessageHandlers[handlerName]
        delete Meowbot.CommandHandlers[handlerName] if Meowbot.CommandHandlers[handlerName]
        clearInterval i for i in Meowbot.HandlerIntervals[handlerName] if Meowbot.HandlerIntervals[handlerName]
        delete Meowbot.HandlerIntervals[handlerName] if Meowbot.HandlerIntervals[handlerName]
        delete require.cache[require.resolve("#{handlersPath}/#{handlerName}.iced")]
        Meowbot.Logging.modLog 'MsgHandlers', 'Unloaded handler: ' + handlerName


exports.loadHandler = loadHandler = (handlerName) ->
    # Check if file exists first
    await fs.access "#{handlersPath}/#{handlerName}.iced", fs.R_OK, defer fileErr
    return Meowbot.Logging.modLog 'MsgHandlers', "Unable to load handler '#{handlerName}', maybe it doesn't exist or have other permission issues." if fileErr

    handl = require "#{handlersPath}/#{handlerName}"
    if typeof handl.Message is 'function'
        Meowbot.MessageHandlers[handlerName] = handl.Message
        Meowbot.Logging.modLog 'MsgHandlers', 'Loaded meowssage handler: ' + handlerName
    if typeof handl.Command is 'function'
        Meowbot.CommandHandlers[handlerName] = handl.Command
        Meowbot.Logging.modLog 'MsgHandlers', 'Loaded comeownd handler: ' + handlerName
    if typeof handl.Init is 'function'
        handl.Init()
        Meowbot.Logging.modLog 'MsgHandlers', 'Ran inyatialization script for: ' + handlerName
    if handl.Intervals?
        Meowbot.HandlerIntervals[handlerName] = handl.Intervals
        Meowbot.Logging.modLog 'MsgHandlers', 'Loaded intermeows for: ' + handlerName


exports.reloadHandler = reloadHandler = (handlerName) ->
    return Meowbot.Logging.modLog 'MsgHandlers', 'No handler name specified for reload' if not handlerName
    unloadHandler handlerName
    loadHandler handlerName


exports.reloadHandlers = reloadHandlers = ->   
    for handler in fs.readdirSync handlersPath
        continue if path.extname(handler) isnt '.iced'
        reloadHandler handler.replace '.iced', ''
    Meowbot.Logging.modLog 'MsgHandlers', 'Message handlers (re)loaded.'
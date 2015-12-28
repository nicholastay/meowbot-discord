fs = require 'fs'
path = require 'path'

handlersPath = path.join __dirname, '../', 'handlers'


exports.unloadHandler = unloadHandler = (handlerName) ->
    if require.cache[require.resolve("#{handlersPath}/#{handlerName}.iced")]
        delete Meowbot.MessageHandlers[handlerName] if Meowbot.MessageHandlers[handlerName]
        delete Meowbot.CommandHandlers[handlerName] if Meowbot.CommandHandlers[handlerName]
        clearInterval i for i in Meowbot.HandlerIntervals[handlerName] if Meowbot.HandlerIntervals[handlerName]
        delete Meowbot.HandlerIntervals[handlerName] if Meowbot.HandlerIntervals[handlerName]
        delete require.cache[require.resolve("#{handlersPath}/#{handlerName}.iced")]
        Meowbot.Logging.modLog 'MsgHandlers', 'Unloaded handler: ' + handlerName


exports.loadHandler = loadHandler = (handlerName) ->
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


exports.reloadHandler = reloadHandler = (handlerName, firstRun) ->
    unloadHandler handlerName if not firstRun # No need to do this for first run
    loadHandler handlerName


exports.reloadHandlers = reloadHandlers = (firstRun) ->
    if firstRun
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
            
    for handler in fs.readdirSync handlersPath
        continue if path.extname(handler) isnt '.iced'
        reloadHandler handler.replace('.iced', ''), firstRun
    return Meowbot.Logging.modLog 'MsgHandlers', 'Handlers successfully reloaded.' if not firstRun
    Meowbot.Logging.modLog 'MsgHandlers', 'Handlers successfully loaded.'
path = require 'path'
fs = require 'fs'

commands = {}
commandsSaveFile = path.join __dirname, '../', '/config', 'Commands.json'

init = exports.Init = ->
    if fs.existsSync commandsSaveFile # If file exists
        commands = JSON.parse fs.readFileSync commandsSaveFile
        Meowbot.Logging.modLog 'Commands', 'Commands (re)loaded from file.'

handler = exports.Command = (command, tail, message) ->
    if commands[command] and message.author.id isnt Meowbot.Discord.user.id then return Meowbot.Discord.sendMessage message, commands[command].output

    switch command
        when '~addcom'
            return Meowbot.Discord.reply message, 'you\'re not one of my masters, you can\'t tell me what to do! >.<' if not Meowbot.Tools.userIsMod message
            return if not tail
            output = tail.split ' '
            return if output.length < 2
            commandToAdd = output.shift().toLowerCase()
            if commands[commandToAdd] then return Meowbot.Discord.reply message, 'that command already exists! ;)'
            commands[commandToAdd] =
                output: output.join ' '
                addedBy: message.author.id
                addedByName: message.author.username
                addedAt: Date.now()
            saveCommands()
            Meowbot.Discord.reply message, 'command most likely has been added...'

        when '~delcom'
            return Meowbot.Discord.reply message, 'you\'re not one of my masters, you can\'t tell me what to do! >.<' if not Meowbot.Tools.userIsMod message
            return if not tail
            output = tail.split ' '
            return if output.length < 1
            commandToDel = output.shift().toLowerCase()
            if not commands[commandToDel] then return Meowbot.Discord.reply message, 'that command doesn\'t exist, so I can\'t really delete it...'
            delete commands[commandToDel]
            saveCommands()
            Meowbot.Discord.reply message, 'command most likely has been removed...'

saveCommands = -> fs.writeFileSync commandsSaveFile, JSON.stringify(commands), 'utf8'
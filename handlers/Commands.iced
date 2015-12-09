path = require 'path'
fs = require 'fs'
config = require '../config'

commands = {}
commandsSaveFile = path.join __dirname, '../', 'commands.json'

init = exports.Init = ->
    if fs.statSync commandsSaveFile # If file exists
        commands = JSON.parse fs.readFileSync commandsSaveFile

handler = exports.Command = (command, tail, message, client) ->
    if commands[command] and message.author.id isnt client.user.id then return client.sendMessage message, commands[command].output

    switch command
        when '~addcom'
            return client.reply message, 'you\'re not one of my masters, you can\'t tell me what to do! >.<' if not userIsMod message
            return if not tail
            output = tail.split ' '
            return if output.length < 2
            commandToAdd = output.shift().toLowerCase()
            if commands[commandToAdd] then return client.reply message, 'that command already exists! ;)'
            commands[commandToAdd] =
                output: output.join ' '
                addedBy: message.author.id
                addedByName: message.author.username
                addedAt: Date.now()
            saveCommands()
            client.reply message, 'command most likely has been added...'

        when '~delcom'
            return client.reply message, 'you\'re not one of my masters, you can\'t tell me what to do! >.<' if not userIsMod message
            return if not tail
            output = tail.split ' '
            return if output.length < 1
            commandToDel = output.shift().toLowerCase()
            if not commands[commandToDel] then return client.reply message, 'that command doesn\'t exist, so I can\'t really delete it...'
            delete commands[commandToDel]
            saveCommands()
            client.reply message, 'command most likely has been removed...'

userIsMod = (message) ->
    if message.author.id in config.admins or message.author.id in config.mods then return true
    return false

saveCommands = -> fs.writeFileSync commandsSaveFile, JSON.stringify(commands), 'utf8'
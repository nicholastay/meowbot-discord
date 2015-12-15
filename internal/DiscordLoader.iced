DiscordJS = require 'discord.js'

discord = new DiscordJS.Client()

exports.login = login = (firstLogin) ->
    if firstLogin # Create event handlers and assign stuff
        discord.on 'ready', ->
            Meowbot.Logging.modLog 'Discord', 'Logged in to Discord.'
            discord.setStatus 'online', 452

        discord.on 'message', (message) ->
            isPM = message.channel instanceof DiscordJS.PMChannel
            for handlerName, handler of Meowbot.MessageHandlers then handler(message, isPM)

            tail = message.content.split ' '
            command = tail.shift().toLowerCase().trim()
            tail = tail.join ' '
            for handlerName, handler of Meowbot.CommandHandlers then handler(command, tail, message, isPM) 

        discord.on 'disconnected', ->
            Meowbot.Logging.modLog 'Discord', 'Client was disconnected from Discord. Will try to login again in a minute...'
            Meowbot.Tools.delay 60 * 1000, -> logInDiscord()

        Meowbot.Discord = discord
        Meowbot.Repl.context.discord = discord
        Meowbot.Repl.context.d = discord
        Meowbot.Repl.context.dc = logout

    discord.login Meowbot.Config.discord.username, Meowbot.Config.discord.password
    Meowbot.Logging.modLog 'Discord', 'Logging in to Discord...'


exports.logout = logout = ->
    Meowbot.Logging.modLog 'Discord', 'Logging off Discord...'
    discord.logout ->
        Meowbot.Logging.modLog 'Discord', 'Logged out of Discord.'
        process.exit()
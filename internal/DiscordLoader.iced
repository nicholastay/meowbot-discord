DiscordJS = require 'discord.js'

discord = new DiscordJS.Client
    revive: true

exports.login = login = (firstLogin) ->
    if firstLogin # Create event handlers and assign stuff
        discord.on 'ready', ->
            Meowbot.Logging.modLog 'Discord', 'Logged in to Discord.'
            discord.setStatus 'online', 'with Nexerq :3'

        discord.on 'message', (message) ->
            isPM = message.channel instanceof DiscordJS.PMChannel
            for handlerName, handler of Meowbot.MessageHandlers then handler(message, isPM)

            if message.content[0] is (Meowbot.Config.commandPrefix or '!')
                spaceIndex = message.content.indexOf(' ')
                command = message.content.toLowerCase().substr 1, (if spaceIndex is -1 then message.content.length else spaceIndex-1) # substr from without prefix to first space
                tail = if spaceIndex is -1 then '' else message.content.substr spaceIndex+1, message.content.length # substr after space to end, also check if index is -1, -1 means couldnt find, so the person just did the command with no args
                for handlerName, handler of Meowbot.CommandHandlers then handler(command, tail, message, isPM)

        discord.on 'disconnected', ->
            Meowbot.Logging.modLog 'Discord', 'Client was disconnected from Discord. Will try to relogin...'

        discord.on 'autoRevive', ->
            Meowbot.Logging.modLog 'Discord', 'Client reconnected to Discord.'

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
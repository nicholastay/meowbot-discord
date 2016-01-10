DiscordJS = require 'discord.js'

discord = new DiscordJS.Client
    revive: true

onDisconnect = -> Meowbot.Logging.modLog 'Discord', 'Client was disconnected from Discord. Will try to relogin...'
onRevive = -> Meowbot.Logging.modLog 'Discord', 'Client reconnected to Discord.'
onReady = ->
    Meowbot.Logging.modLog 'Discord', 'Logged in to Discord.'
    discord.setStatus 'online', 'Neko Atsume: Kitty Collector'

exports.init = ->
    # REPL handlers
    Meowbot.Discord = discord
    Meowbot.Repl.context.discord = discord
    Meowbot.Repl.context.d = discord
    Meowbot.Repl.context.dc = logout

    # Refresh event emitters
    discord.removeListener 'ready', onReady
    discord.removeListener 'disconnected', onDisconnect
    discord.removeListener 'autoRevive', onRevive
    discord.on 'ready', onReady
    discord.on 'disconnected', onDisconnect
    discord.on 'autoRevive', onRevive

exports.login = login = ->
    discord.login Meowbot.Config.discord.username, Meowbot.Config.discord.password
    Meowbot.Logging.modLog 'Discord', 'Logging in to Discord...'


exports.logout = logout = ->
    Meowbot.Logging.modLog 'Discord', 'Logging off Discord...'
    discord.logout ->
        Meowbot.Logging.modLog 'Discord', 'Logged out of Discord.'
        process.exit()
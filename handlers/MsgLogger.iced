chalk = require 'chalk'

handler = exports.Message = (message, isPM) ->
    return Meowbot.Logging.modLog 'Discord Chat', chalk.yellow("PrivMsg") + chalk.blue(" #{message.author.username} -> #{if message.author.username is Meowbot.Discord.user.username then message.channel.recipient.username else Meowbot.Discord.user.username}: ") + message.content if isPM
    Meowbot.Logging.modLog 'Discord Chat', chalk.yellow("#{message.channel.server.name}") + chalk.green(" ##{message.channel.name}") + chalk.blue(" #{message.author.username}: ") + message.content
chalk = require 'chalk'
includes = require 'lodash.includes'

handler = exports.Message = (message, isPM) ->
    msg = if includes message.content, '\n' then message.content.split('\n')[0] + '...' else message.content # Shorten the message if more than a line (if message includes a newline char)
    return Meowbot.Logging.modLog 'Discord Chat', chalk.yellow("PrivMsg") + chalk.blue(" #{message.author.username} -> #{if message.author.username is Meowbot.Discord.user.username then message.channel.recipient.username else Meowbot.Discord.user.username}: ") + msg if isPM
    Meowbot.Logging.modLog 'Discord Chat', chalk.yellow("#{message.channel.server.name}") + chalk.green(" ##{message.channel.name}") + chalk.blue(" #{message.author.username}: ") + msg
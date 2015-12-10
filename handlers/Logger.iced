strftime = require 'fast-strftime'
chalk = require 'chalk'

handler = exports.Message = (message, isPM) ->
    return console.log chalk.magenta("[#{strftime '%l:%M%P'}]") + chalk.yellow(" PrivMsg") + chalk.blue(" #{message.author.username} -> #{if message.author.username is Meowbot.Discord.user.username then message.channel.recipient.username else Meowbot.Discord.user.username}: ") + chalk.white(message.content) if isPM
    console.log chalk.magenta("[#{strftime '%l:%M%P'}]") + chalk.yellow(" #{message.channel.server.name}") + chalk.green(" ##{message.channel.name}") + chalk.blue(" #{message.author.username}: ") + chalk.white(message.content)
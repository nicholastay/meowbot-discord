strftime = require 'fast-strftime'
chalk = require 'chalk'

handler = exports.Message = (message) ->
    console.log chalk.magenta("[#{strftime '%l:%M%P'}]") + chalk.yellow(" #{message.channel.server.name}") + chalk.green(" ##{message.channel.name}") + chalk.blue(" #{message.author.username}: ") + chalk.white(message.content)
seedrandom = require 'seedrandom'

handler = exports.Command = (command, tail, message, client) ->
    switch command
        when '~love'
            return if not tail
            return client.sendMessage message, "Well <@#{message.author.id}> sure loves themselves too much Keepo" if tail is message.author.username
            love = Math.floor(seedrandom("#{message.author.username} <3 #{tail}")() * 100)
            return client.reply message, "the love between you and #{tail} is #{love}%! <3"
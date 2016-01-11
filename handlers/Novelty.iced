seedrandom = require 'seedrandom'

ballResponses = ['it is certain',
                 'it is decidedly so',
                 'without a doubt',
                 'yes, definitely',
                 'you may rely on it',
                 'as I see it, yes',
                 'most likely',
                 'outlook good',
                 'yes',
                 'the signs point to yes',
                 'the reply is hazy, try again',
                 'ask again later',
                 'better to not tell you now',
                 'cannot predict now',
                 'concentrate and ask again',
                 'don\'t count on it',
                 'my reply is no',
                 'my sources say no',
                 'outlook not so good',
                 'very doubtful']

handler = exports.Commands =
    'love':
        description: 'Checks the love between you and someone(or -thing) else!'
        forceTailContent: true
        handler: (command, tail, message) ->
            return Meowbot.Discord.sendMessage message, "Well <@#{message.author.id}> sure loves themselves too much Keepo" if tail is message.author.username
            love = Math.floor(seedrandom("#{message.author.username} <3 #{tail}")() * 100)
            return Meowbot.Discord.reply message, "the love between you and #{tail} is #{love}%! <3"

    'flove':
        description: 'Checks the love between two pairs.'
        forceTailContent: true
        hidden: true
        permissionLevel: 'mod'
        handler: (command, tail, message) ->
            names = tail.split '\n'
            return Meowbot.Discord.sendMessage message, "Not enough people mentioned" if names.length < 2
            love = Math.floor(seedrandom("#{names[0]} <3 #{names[1]}")() * 100)
            return Meowbot.Discord.sendMessage message, "#{names[0]} <-> #{names[1]} = #{love}% <3"

    '8ball':
        description: 'I will look into my magic 8ball and tell you what I can see...'
        forceTailContent: true
        handler: (command, tail, message) ->
            return Meowbot.Discord.reply message, "my magic 8-ball says... #{ballResponses[Meowbot.Tools.getRandomInt 0, ballResponses.length]}."
handler = exports.Message = (message) ->
    switch message.content.toLowerCase()
        when '~meow'
            Meowbot.Discord.sendMessage message, 'meow~', {tts: true}

        when '~meowbot'
            Meowbot.Discord.reply message, 'hello! Did you call me? :P'
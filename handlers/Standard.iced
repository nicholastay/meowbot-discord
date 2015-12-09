handler = exports.Message = (message, client) ->
    switch message.content.toLowerCase()
        when '~meow'
            client.sendMessage message, 'meow~', {tts: true}

        when '~meowbot'
            client.reply message, 'hello! Did you call me? :P'
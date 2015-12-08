handler = exports.Command = (command, tail, message, client) ->
    switch command
        when '~joinvoice'
            return if not tail
            voiceChannels = client.channels.filter (channel) -> return channel.name is tail
            return client.reply message, 'that is an invalid channel, don\'t force me into dark alleyways please.' if not voiceChannels.length > 0
            channel = voiceChannels[0]
            return client.reply message, "#{tail} is not a voice channel. I can't scream in a text channel now, can I? :P" if channel.type isnt 'voice'
            client.joinVoiceChannel channel
            return client.reply message, "joined voice channel #{tail}."

        when '~leavevoice'
            return client.reply message, 'you baka baka, I\'m not currently in a voice channel q.q' if not client.voiceConnection
            client.leaveVoiceChannel()
            return client.reply message, 'I left voice on your request.'

        when '~stopplaying'
            return client.reply message, 'you baka baka, I\'m not currently in a voice channel q.q' if not client.voiceConnection
            client.voiceConnection.stopPlaying()
            return client.reply message, 'if there was any music, I stopped it.'
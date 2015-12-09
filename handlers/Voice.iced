handler = exports.Command = (command, tail, message) ->
    switch command
        when '~joinvoice'
            return if not tail
            voiceChannels = Meowbot.Discord.channels.filter (channel) -> return channel.name is tail
            return Meowbot.Discord.reply message, 'that is an invalid channel, don\'t force me into dark alleyways please.' if not voiceChannels.length > 0
            channel = voiceChannels[0]
            return Meowbot.Discord.reply message, "#{tail} is not a voice channel. I can't scream in a text channel now, can I? :P" if channel.type isnt 'voice'
            Meowbot.Discord.joinVoiceChannel channel
            return Meowbot.Discord.reply message, "joined voice channel #{tail}."

        when '~leavevoice'
            return Meowbot.Discord.reply message, 'you baka baka, I\'m not currently in a voice channel q.q' if not Meowbot.Discord.voiceConnection
            Meowbot.Discord.leaveVoiceChannel()
            return Meowbot.Discord.reply message, 'I left voice on your request.'

        when '~stopplaying'
            return Meowbot.Discord.reply message, 'you baka baka, I\'m not currently in a voice channel q.q' if not Meowbot.Discord.voiceConnection
            Meowbot.Discord.voiceConnection.stopPlaying()
            return Meowbot.Discord.reply message, 'if there was any music, I stopped it.'
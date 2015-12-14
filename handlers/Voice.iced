handler = exports.Command = (command, tail, message, isPM) ->
    switch command
        when '~joinvoice'
            return if not tail
            return Meowbot.Discord.sendMessage message, 'This command can only be used in the context of a server.' if isPM
            return Meowbot.Discord.reply message, 'you\'re not one of my masters, please don\'t force me to join a voice channel...' if not Meowbot.Tools.userIsMod message
            voiceChannels = message.channel.server.channels.filter (channel) -> return channel.name is tail
            return Meowbot.Discord.reply message, 'that is an invalid channel, don\'t force me into dark alleyways please.' if not voiceChannels.length > 0
            channel = voiceChannels[0]
            return Meowbot.Discord.reply message, "#{tail} is not a voice channel. I can't scream in a text channel now, can I? :P" if channel.type isnt 'voice'
            Meowbot.HandlerSettings.Audio.OriginalMessageCtx = message.channel.id
            Meowbot.Discord.reply message, "joining voice channel #{tail}, and also all updates like now playing will be sent to this channel."
            try
                Meowbot.Discord.joinVoiceChannel channel
            catch e
                Meowbot.Discord.sendMessage message, "There was an **error** with the Discord voice server, I don\'t know exactly why though... (please forward this error message to Nexerq: #{e})"
                Meowbot.HandlerSettings.Audio.OriginalMessageCtx = null
                Meowbot.HandlerSettings.Audio.NowPlaying = null if Meowbot.HandlerSettings.Audio.NowPlaying
                Meowbot.HandlerSettings.Audio.Queue = [] if Meowbot.HandlerSettings.Audio.Queue.length > 0

        when '~leavevoice'
            return Meowbot.Discord.reply message, 'you baka baka, I\'m not currently in a voice channel q.q' if not Meowbot.Discord.voiceConnection
            return Meowbot.Discord.reply message, 'you\'re not one of my masters, please don\'t force me into the open where people can do all kinds of things to me... >.<' if not Meowbot.Tools.userIsMod message
            Meowbot.Discord.leaveVoiceChannel()
            return Meowbot.Discord.reply message, 'I left voice on your request.'

        # when '~stopplaying'
        #     return Meowbot.Discord.reply message, 'you\'re not one of my masters, I can scream whenever I want.\n (hint: just mute me if you\'re that much of a bitch)' if not Meowbot.Tools.userIsMod message
        #     return Meowbot.Discord.reply message, 'you baka baka, I\'m not currently in a voice channel q.q' if not Meowbot.Discord.voiceConnection
        #     Meowbot.Discord.voiceConnection.stopPlaying()
        #     return Meowbot.Discord.reply message, 'if there was any music, I stopped it.'
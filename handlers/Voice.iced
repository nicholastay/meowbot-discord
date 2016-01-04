handler = exports.Command = (command, tail, message, isPM) ->
    switch command
        when 'joinvoice'
            return if not tail
            return Meowbot.Discord.sendMessage message, 'This command can only be used in the context of a server.' if isPM
            return Meowbot.Discord.reply message, 'you\'re not one of my masters, please don\'t force me to join a voice channel...' if not Meowbot.Tools.userIsMod message
            return Meowbot.Discord.reply message, 'I\'m already in another voice channel, please disconnect me first to confirm this change please.' if Meowbot.Discord.voiceConnection
            voiceChannels = message.channel.server.channels.filter (channel) -> return channel.name is tail and channel.type is 'voice'
            return Meowbot.Discord.reply message, 'that is an invalid voice channel, don\'t force me into dark alleyways please.' if voiceChannels.length < 1
            voiceChannel = voiceChannels[0]
            Meowbot.HandlerSettings.Voice.UpdatesContext = message
            Meowbot.Discord.reply message, "joining voice channel #{tail}, and also all updates like now playing will be sent to this channel."
            Meowbot.Discord.joinVoiceChannel voiceChannel, (err) ->
                Meowbot.Discord.sendMessage message, "There was an **error** with the Discord voice server, I don\'t know exactly why though... (please forward this error message to Nexerq: #{err})" if err

        when 'leavevoice'
            return Meowbot.Discord.reply message, 'you baka baka, I\'m not currently in a voice channel q.q' if not Meowbot.Discord.voiceConnection
            return Meowbot.Discord.reply message, 'you\'re not one of my masters, please don\'t force me into the open where people can do all kinds of things to me... >.<' if not Meowbot.Tools.userIsMod message
            Meowbot.Discord.voiceConnection.stopPlaying()
            Meowbot.Discord.leaveVoiceChannel()
            Meowbot.HandlerSettings.Voice.UpdatesContext = null
            return Meowbot.Discord.reply message, 'I left voice on your request.'
            

init = exports.Init = ->
    Meowbot.HandlerSettings.Voice = {} if not Meowbot.HandlerSettings.Voice
    Meowbot.HandlerSettings.Voice.UpdatesContext = null if not Meowbot.HandlerSettings.Voice.UpdatesContext
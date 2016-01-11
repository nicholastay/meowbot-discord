DiscordIO = require 'discord.io'
path = require 'path'
strftime = require 'fast-strftime'
fs = require 'fs-extra'
sanitize = require 'sanitize-filename'
lame = require 'lame'

recordTo = path.resolve __dirname, '../', 'recordings'


handler = exports.Command = (command, tail, message, isPM) ->
    switch command
        when 'rec'
            return if not tail or isPM
            return if not Meowbot.Tools.userIsMod message
            voiceChannels = message.channel.server.channels.filter (channel) -> return channel.name is tail and channel.type is 'voice'
            return Meowbot.Discord.reply message, 'that is an invalid voice channel, don\'t force me into dark alleyways please.' if voiceChannels.length < 1
            voiceChannel = voiceChannels[0]
            if Meowbot.Discord.voiceConnection
                Meowbot.Logging.modLog 'Recorder', 'Was already in a voice channel, leaving it with discord.js...'
                await Meowbot.Discord.leaveVoiceChannel defer()
                Meowbot.HandlerSettings.Voice.UpdatesContext = null
            Meowbot.HandlerSettings.Audio.Stopped = true if Meowbot.HandlerSettings.Audio?.Stopped # just force this to avoid fuckups
            Meowbot.Logging.modLog 'Recorder', 'Got request to start recording, trying to login with DiscordIO...'
            recordClient = Meowbot.HandlerSettings.Recorder.Client = new DiscordIO
                autorun: false
                email: Meowbot.Config.discord.username
                password: Meowbot.Config.discord.password
            recordClient.on 'ready', ->
                await recordClient.joinVoiceChannel voiceChannel.id, defer()
                await recordClient.getAudioContext {channel: voiceChannel.id, stereo: true}, defer stream
                Meowbot.Logging.modLog 'Recorder', 'Starting recording with DiscordIO...'
                dioSendMsg message.author.id, "Started a recording session in #{voiceChannel.name}. [#{voiceChannel.server.name}]"
                baseFileName = "#{voiceChannel.name} [#{voiceChannel.server.name}] #{strftime '%Y-%m-%d_%H-%M-%S'}"
                fileName = sanitize baseFileName.replace(new RegExp(' ', 'g'), '_'), {replacement: '_'}
                wstream = fs.createWriteStream path.join recordTo, (fileName + '.rawpcm')
                Meowbot.HandlerSettings.Recorder.Recording = {context: message.author.id, filename: fileName, wstream: wstream}
                stream.on 'incoming', (ssrc, buffer) -> wstream.write buffer
            recordClient.connect()

        when 'stoprec'
            return if not Meowbot.HandlerSettings.Recorder.Recording
            return if not Meowbot.Tools.userIsMod message
            Meowbot.Logging.modLog 'Recorder', 'Stopping recording and logging out DiscordIO client...'
            Meowbot.HandlerSettings.Recorder.Client.disconnect()
            Meowbot.HandlerSettings.Recorder.Client.on 'disconnected', ->
                Meowbot.HandlerSettings.Recorder.Client = null
                Meowbot.Logging.modLog 'Recorder', 'Encoding raw PCM dumped stream to Lame MP3...'
                encoder = new lame.Encoder
                    # In settings
                    channels: 2
                    bitDepth: 16
                    sampleRate: 44100

                    # Out settings
                    bitRate: 128
                    outSampleRate: 22050
                    mode: lame.STEREO
                rstream = fs.createReadStream path.join recordTo, (Meowbot.HandlerSettings.Recorder.Recording.filename + '.rawpcm')
                wstream = fs.createWriteStream path.join recordTo, (Meowbot.HandlerSettings.Recorder.Recording.filename + '.mp3')
                rstream.pipe encoder
                encoder.pipe wstream
                encoder.on 'end', ->
                    Meowbot.Logging.modLog 'Recorder', 'Finished encoding file to Lame MP3, now will clean up the raw file.'
                    fs.removeSync path.resolve(recordTo, (Meowbot.HandlerSettings.Recorder.Recording.filename + '.rawpcm')), (err) ->
                        Meowbot.Logging.modLog 'Recorder', 'There was an error deleting the raw dumped file, you probably have to clean it up yourself.' if err
                    Meowbot.HandlerSettings.Recorder.Recording.wstream.end()
                    Meowbot.HandlerSettings.Recorder.Recording = null


init = exports.Init = ->
    Meowbot.HandlerSettings.Recorder = {} if not Meowbot.HandlerSettings.Recorder
    Meowbot.HandlerSettings.Recorder.Client = null if not Meowbot.HandlerSettings.Recorder.Client
    Meowbot.HandlerSettings.Recorder.Recording = null if not Meowbot.HandlerSettings.Recorder.Recording

# Send a message with discord.io
# For some reason discord.js crashes when sendMessage(message.author) so...
dioSendMsg = (to, message, cb) ->
    return if not Meowbot.HandlerSettings.Recorder?.Client
    Meowbot.HandlerSettings.Recorder.Client.sendMessage
        to: to
        message: message
    , cb
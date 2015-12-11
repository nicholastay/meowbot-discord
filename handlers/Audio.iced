ytVidRegex = /((youtube\.com\/watch\?v=)|(youtu\.be\/))([A-Za-z0-9-_]+)/i
ytdl = require 'ytdl-core'
fs = require 'fs'
path = require 'path'

delay = (ms, cb) -> setTimeout cb, ms # convenience flip func

init = exports.Init = ->
    Meowbot.HandlerSettings.Audio = {} if not Meowbot.HandlerSettings.Audio
    Meowbot.HandlerSettings.Audio.Queue = [] if not Meowbot.HandlerSettings.Audio.Queue?
    Meowbot.HandlerSettings.Audio.LastMS = -1 if not Meowbot.HandlerSettings.Audio.LastMS?
    Meowbot.HandlerSettings.Audio.Stopped = true if not Meowbot.HandlerSettings.Audio.Stopped?

handler = exports.Command = (command, tail, message) ->
    switch command
        when '~mp3'
            songs = []
            for file in fs.readdirSync './music' then if path.extname(file) is '.mp3' then songs.push(file.replace('.mp3', ''))
            return Meowbot.Discord.reply message, "the available s-songs that N-N-Nexerq-k-k-k-kun put in his f-folder are: #{songs.join ', '}"

        when '~playmp3'
            return Meowbot.Discord.reply message, 'you baka baka, I\'m not currently in a voice channel q.q' if not Meowbot.Discord.voiceConnection
            songs = fs.readdirSync './music'
            return Meowbot.Discord.reply message, 'I don\'t currently have that song, but if you... ano... k-kindly a-ask N-N-Nexerq-k-k-k-kun he might just give you a hand.' if tail + '.mp3' not in songs
            addToQueue "#{tail} (MP3)", message, fs.createReadStream("./music/#{tail}.mp3")
            startTrackingStopped(message)

        when '~playyt'
            return Meowbot.Discord.reply message, 'you baka baka, I\'m not currently in a voice channel q.q' if not Meowbot.Discord.voiceConnection
            ytVidMatch = ytVidRegex.exec tail
            return Meowbot.Discord.reply message, 'you gave me a link that is not a youtube link...' if not ytVidMatch
            videoId = ytVidMatch[4]
            addToQueue "YouTube video [ID: #{videoId}]", message, getYtStream(videoId)
            startTrackingStopped(message)

        when '~fskip' # Force skip by admins
            return Meowbot.Discord.reply message, 'you\'re not one of my masters, you can\'t tell me what to do! >.<' if not Meowbot.Tools.userIsMod message
            Meowbot.Discord.reply message, 'forcing skip on current song due to your demand...'
            Meowbot.Discord.voiceConnection.stopPlaying() # This will trigger skipSong without hitting it twice

checkIfStoppedPlaying = ->
    return if not Meowbot.Discord.voiceConnection or Meowbot.HandlerSettings.Audio.Stopped is true
    if Meowbot.HandlerSettings.Audio.LastMS is Meowbot.Discord.voiceConnection.streamTime
        Meowbot.HandlerSettings.Audio.LastMS = -1
        Meowbot.HandlerSettings.Audio.Stopped = true
        return onStoppedPlaying()
    Meowbot.HandlerSettings.Audio.LastMS = Meowbot.Discord.voiceConnection.streamTime # if the streamTime is equal to LastMS then it stopped playing, so we have to store it and check

startTrackingStopped = (message) ->
    delay 3000, ->
        Meowbot.HandlerSettings.Audio.Stopped = false
        Meowbot.HandlerSettings.Audio.OriginalMessageCtx = message

getYtStream = (videoId) ->
   return ytdl("http://www.youtube.com/watch?v=#{videoId}", {quality: 140})

intervals = exports.Intervals = [setInterval((-> checkIfStoppedPlaying()), 1000)]

# Queueing stuff
addToQueue = (friendlyName, message, stream) ->
    Meowbot.HandlerSettings.Audio.Queue.push
        name: friendlyName
        requestBy: "<@#{message.author.id}>"
        stream: stream
    Meowbot.Discord.reply message, "I have added #{friendlyName} to the listening queue."
    skipSong() if Meowbot.HandlerSettings.Audio.Stopped is true

onStoppedPlaying = ->
    skipSong()

skipSong = ->
    Meowbot.Discord.voiceConnection.stopPlaying()
    return Meowbot.Discord.sendMessage Meowbot.HandlerSettings.Audio.OriginalMessageCtx, 'There are no more items in the queue, playblack has now stopped.' if Meowbot.HandlerSettings.Audio.Queue < 1
    nowPlaying = Meowbot.HandlerSettings.Audio.Queue.shift()
    delay 1500, -> Meowbot.Discord.sendMessage Meowbot.HandlerSettings.Audio.OriginalMessageCtx, "**Now Playing**: #{nowPlaying.name} (requested by: #{nowPlaying.requestBy})"
    startTrackingStopped(Meowbot.HandlerSettings.Audio.OriginalMessageCtx)
    Meowbot.Discord.voiceConnection.playRawStream nowPlaying.stream
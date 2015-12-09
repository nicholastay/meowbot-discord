ytVidRegex = /((youtube\.com\/watch\?v=)|(youtu\.be\/))([A-Za-z0-9-_]+)/i
ytdl = require 'ytdl-core'
fs = require 'fs'

handler = exports.Command = (command, tail, message) ->
    switch command
        when '~playyt'
            return Meowbot.Discord.reply message, 'you baka baka, I\'m not currently in a voice channel q.q' if not Meowbot.Discord.voiceConnection
            ytVidMatch = ytVidRegex.exec tail
            return Meowbot.Discord.reply message, 'you gave me a link that is not a youtube link...' if not ytVidMatch
            videoId = ytVidMatch[4]

            Meowbot.Discord.reply message, 'got your YouTube link, gonna try start playing it! :)'
            playYTLink videoId, Meowbot.Discord


playYTLink = (videoId) ->
    Meowbot.Discord.voiceConnection.stopPlaying()
    videoData = ytdl("http://www.youtube.com/watch?v=#{videoId}", {quality: 140})
    Meowbot.Discord.voiceConnection.playRawStream videoData
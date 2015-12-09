ytVidRegex = /((youtube\.com\/watch\?v=)|(youtu\.be\/))([A-Za-z0-9-_]+)/i
ytdl = require 'ytdl-core'
fs = require 'fs'

handler = exports.Command = (command, tail, message, client) ->
    switch command
        when '~playyt'
            return client.reply message, 'you baka baka, I\'m not currently in a voice channel q.q' if not client.voiceConnection
            ytVidMatch = ytVidRegex.exec tail
            return client.reply message, 'you gave me a link that is not a youtube link...' if not ytVidMatch
            videoId = ytVidMatch[4]

            client.reply message, 'got your YouTube link, gonna try start playing it! :)'
            playYTLink videoId, client


playYTLink = (videoId, client) ->
    client.voiceConnection.stopPlaying()
    videoData = ytdl("http://www.youtube.com/watch?v=#{videoId}", {quality: 140})
    client.voiceConnection.playRawStream videoData
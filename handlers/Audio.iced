fs = require 'fs'
path = require 'path'
ytdl = require 'ytdl-core'

musicPath = path.join __dirname, '../', 'music'
ytVidRegex = /((youtube\.com\/watch\?v=)|(youtu\.be\/))([A-Za-z0-9-_]+)/i

handler = exports.Command = (command, tail, message) ->
    switch command
        when '~mp3'
            songs = []
            for song in fs.readdirSync musicPath
                continue if path.extname(song) isnt '.mp3'
                songs.push song.replace '.mp3', ''
            Meowbot.Discord.reply message, 'the available songs that Nexerq has put in his music library for me are: ' + songs.join ', '

        when '~playmp3'
            return Meowbot.Discord.reply message, 'you baka, I\'m not currently in a voice channel :3' if not Meowbot.Discord.voiceConnection
            toPlaySong = tail + '.mp3'
            songs = fs.readdirSync musicPath
            return Meowbot.Discord.reply message, 'this song is currently not in Nexerq\'s music library. You can ask him or try to play a song via YouTube.' if toPlaySong not in songs
            addToQueue message,
                name: tail
                stream: fs.createReadStream path.join musicPath, toPlaySong
                requester: message.author
            # Meowbot.Discord.voiceConnection.playFile path.join musicPath, toPlaySong

        when '~fskip'
            return Meowbot.Discord.reply message, 'you baka, I\'m not currently in a voice channel :3' if not Meowbot.Discord.voiceConnection
            return Meowbot.Discord.reply message, 'you are not one of my masters, you can\'t tell me what to do!' if not Meowbot.Tools.userIsMod message
            Meowbot.Discord.voiceConnection.stopPlaying() # this will trigger the onStoppedPlaying() handler by default
            Meowbot.Discord.reply message, 'forcefully skipped the current playing track.'

        when '~np'
            return Meowbot.Discord.reply message, 'you baka, I\'m not currently in a voice channel :3' if not Meowbot.Discord.voiceConnection
            return Meowbot.Discord.reply message, "the song that is currently playing is: #{Meowbot.HandlerSettings.Audio.NP.name} *(requested by: #{Meowbot.HandlerSettings.Audio.NP.requester.username})*" if Meowbot.HandlerSettings.Audio.NP
            Meowbot.Discord.reply message, 'there is no music currently playing, baka!'

        when '~queue'
            return Meowbot.Discord.reply message, 'you baka, I\'m not currently in a voice channel :3' if not Meowbot.Discord.voiceConnection
            return Meowbot.Discord.reply message, 'there is no music or queue currently playing, baka!' if not Meowbot.HandlerSettings.Audio.NP
            formattedStr = "**NP**: #{Meowbot.HandlerSettings.Audio.NP.name} *(requested by: #{Meowbot.HandlerSettings.Audio.NP.requester.username})*"
            if Meowbot.HandlerSettings.Audio.Queue.length < 1
                formattedStr += '\n*(there is no queue afterwards, feel free to request more!)*'
            else
                formattedStr += "\n**#{i+1}**: #{track.name} *(requested by: #{track.requester.username})*" for track, i in Meowbot.HandlerSettings.Audio.Queue
            return Meowbot.Discord.reply message, "the queue is as follows:\n#{formattedStr}"

        when '~playyt'
            return Meowbot.Discord.reply message, 'you baka, I\'m not currently in a voice channel :3' if not Meowbot.Discord.voiceConnection
            ytVidReg = ytVidRegex.exec tail
            return Meowbot.Discord.reply message, 'that is not a valid YouTube link, what are you trying to do to me...' if not ytVidReg
            ytVidID = ytVidReg[4]
            await ytdl.getInfo "http://www.youtube.com/watch?v=#{ytVidID}", defer err, info
            return Meowbot.Discord.reply message, 'invalid YouTube video link (in which case, why -_-), or I am having trouble connecting to YouTube.' if err
            friendlyName = if info.title and info.author then "#{info.title} (uploaded by #{info.author})" else "YouTube video ID #{ytVidID} [Was unable to retrieve metadata]"
            addToQueue message,
                name: friendlyName
                stream: ytdl.downloadFromInfo info, {quality: 140} # quality 140, code for audio
                requester: message.author

init = exports.Init = ->
    Meowbot.HandlerSettings.Audio = {} if not Meowbot.HandlerSettings.Audio
    Meowbot.HandlerSettings.Audio.Stopped = true if not Meowbot.HandlerSettings.Audio.Stopped
    Meowbot.HandlerSettings.Audio.NP = null if not Meowbot.HandlerSettings.Audio.NP
    Meowbot.HandlerSettings.Audio.Queue = [] if not Meowbot.HandlerSettings.Audio.Queue

intervals = exports.Intervals = [setInterval((-> checkIfStoppedPlaying()), 2000)]

checkIfStoppedPlaying = ->
    return if not Meowbot.Discord.voiceConnection # not connected to voice chan
    return if not Meowbot.Discord.voiceConnection.playing and Meowbot.HandlerSettings.Audio.Stopped # ok, we know its stopped and internally is stopped.
    return if Meowbot.Discord.voiceConnection.playing and not Meowbot.HandlerSettings.Audio.Stopped # yep, its fine, we know its playing and not stopped.
    return Meowbot.HandlerSettings.Audio.Stopped = false if Meowbot.Discord.voiceConnection.playing and Meowbot.HandlerSettings.Audio.Stopped # something changed - stuff started playing.
    if not Meowbot.Discord.voiceConnection.playing and not Meowbot.HandlerSettings.Audio.Stopped # woah, ok something changed here. it stopped playing.
        Meowbot.HandlerSettings.Audio.Stopped = true # it has stopped.
        return onStoppedPlaying() # we can run the stopped playing callback.

onStoppedPlaying = ->
    Meowbot.Logging.modLog 'Audio', 'A track has now stopped playing.'
    return playNextTrack() if Meowbot.HandlerSettings.Audio.Queue.length > 0
    Meowbot.HandlerSettings.Audio.NP = null
    Meowbot.Discord.sendMessage Meowbot.HandlerSettings.Voice.UpdatesContext, "Playback has now stopped, there are no more songs in the queue."

addToQueue = (message, trackdata) ->
    return Meowbot.Discord.reply message, 'There\'s already 10 tracks or more in the queue, please wait and try again later.' if Meowbot.HandlerSettings.Audio.Queue.length >= 10
    Meowbot.HandlerSettings.Audio.Queue.push trackdata
    Meowbot.Discord.reply message, "I have added the song #{trackdata.name} to the queue. ^-^"
    playNextTrack() if Meowbot.HandlerSettings.Audio.Queue.length is 1 and not Meowbot.HandlerSettings.Audio.NP # Only song in the queue, nothing playing, play it right away

playNextTrack = -> # This assumes there are songs in the queue!
    toPlay = Meowbot.HandlerSettings.Audio.NP = Meowbot.HandlerSettings.Audio.Queue.shift()
    Meowbot.Discord.voiceConnection.playRawStream toPlay.stream
    Meowbot.Discord.sendMessage Meowbot.HandlerSettings.Voice.UpdatesContext, "**Now Playing**: #{toPlay.name} *(requested by: #{toPlay.requester.username})*" if Meowbot.HandlerSettings.Voice.UpdatesContext
fs = require 'fs'
path = require 'path'
ytdl = require 'ytdl-core'
request = require 'request'

musicPath = path.join __dirname, '../', 'music'
ytVidRegex = /((youtube\.com\/watch\?v=)|(youtu\.be\/))([A-Za-z0-9-_]+)/i
scUrlRegex = /soundcloud\.com\/([\w-]+\/[\w-]+)/i

handler = exports.Command = (command, tail, message, isPM) ->
    switch command
        when 'mp3'
            songs = []
            for song in fs.readdirSync musicPath
                continue if path.extname(song) isnt '.mp3'
                songs.push song.replace '.mp3', ''
            Meowbot.Discord.reply message, 'the available songs that Nexerq has put in his music library for me are: ' + songs.join ', '

        when 'playmp3'
            if isPM then if not Meowbot.Tools.userIsMod message then return # Do not allow other users to add songs privately via PM, just silently return. Check for PM first then check for Mod so dont have to check user as mod every msg
            return Meowbot.Discord.reply message, 'you baka, I\'m not currently in a voice channel :3' if not Meowbot.Discord.voiceConnection
            toPlaySong = tail + '.mp3'
            songs = fs.readdirSync musicPath
            return Meowbot.Discord.reply message, 'this song is currently not in Nexerq\'s music library. You can ask him or try to play a song via YouTube.' if toPlaySong not in songs
            addToQueue message,
                name: '[MP3] ' + tail
                stream: fs.createReadStream path.join musicPath, toPlaySong
                requester: message.author
            # Meowbot.Discord.voiceConnection.playFile path.join musicPath, toPlaySong

        when 'fskip'
            if isPM then if not Meowbot.Tools.userIsMod message then return
            return Meowbot.Discord.reply message, 'you baka, I\'m not currently in a voice channel :3' if not Meowbot.Discord.voiceConnection
            return Meowbot.Discord.reply message, 'you are not one of my masters, you can\'t tell me what to do!' if not Meowbot.Tools.userIsMod message
            Meowbot.Discord.voiceConnection.stopPlaying() # this will trigger the onStoppedPlaying() handler by default
            Meowbot.Discord.reply message, 'forcefully skipped the current playing track.'

        when 'volume'
            if isPM then if not Meowbot.Tools.userIsMod message then return
            return Meowbot.Discord.reply message, 'you are not one of my masters, you can\'t tell me what to do!' if not Meowbot.Tools.userIsMod message
            return Meowbot.Discord.reply message, 'you have specified an invalid volume (percentage).' if not /^(\d{1,2}|100)%?$/.test tail # Testing for two digit numbers/100 and optional %
            toVolume = parseInt tail.replace('%', '')
            Meowbot.HandlerSettings.Audio.Volume = toVolume / 100 # divide 100 as percentage to decimal
            Meowbot.Logging.modLog 'Audio', "Audio encoder volume set to #{toVolume}%"
            Meowbot.Discord.reply message, "the volume has been set to #{toVolume}%. *(Changes will be applied on the next track's playback.)*"

        when 'np'
            return Meowbot.Discord.reply message, 'you baka, I\'m not currently in a voice channel :3' if not Meowbot.Discord.voiceConnection
            return Meowbot.Discord.reply message, "the song that is currently playing is: **#{Meowbot.HandlerSettings.Audio.NP.name}** *(requested by: #{Meowbot.HandlerSettings.Audio.NP.requester.username})*" if Meowbot.HandlerSettings.Audio.NP
            Meowbot.Discord.reply message, 'there is no music currently playing, baka!'

        when 'queue'
            return Meowbot.Discord.reply message, 'you baka, I\'m not currently in a voice channel :3' if not Meowbot.Discord.voiceConnection
            return Meowbot.Discord.reply message, 'there is no music or queue currently playing, baka!' if not Meowbot.HandlerSettings.Audio.NP
            formattedStr = "***NP***: **#{Meowbot.HandlerSettings.Audio.NP.name}** *(requested by: #{Meowbot.HandlerSettings.Audio.NP.requester.username})*"
            if Meowbot.HandlerSettings.Audio.Queue.length < 1
                formattedStr += '\n*(there is no queue afterwards, feel free to request more!)*'
            else
                formattedStr += "\n***#{i+1}***: **#{track.name}** *(requested by: #{track.requester.username})*" for track, i in Meowbot.HandlerSettings.Audio.Queue
            return Meowbot.Discord.reply message, "the queue is as follows:\n#{formattedStr}"

        when 'playyt'
            if isPM then if not Meowbot.Tools.userIsMod message then return
            return Meowbot.Discord.reply message, 'you baka, I\'m not currently in a voice channel :3' if not Meowbot.Discord.voiceConnection
            ytVidReg = ytVidRegex.exec tail
            return Meowbot.Discord.reply message, 'that is not a valid YouTube link, what are you trying to do to me...' if not ytVidReg
            ytVidID = ytVidReg[4]
            await ytdl.getInfo "http://www.youtube.com/watch?v=#{ytVidID}", defer err, info
            return Meowbot.Discord.reply message, 'invalid YouTube video link (in which case, why -_-), or I am having trouble connecting to YouTube.' if err
            friendlyName = if info.title and info.author then "#{info.title} (uploaded by #{info.author})" else "YouTube video ID #{ytVidID} [Was unable to retrieve metadata]"
            addToQueue message,
                name: '[YT] ' + friendlyName
                stream: ytdl.downloadFromInfo info, {quality: 140} # quality 140, code for audio
                requester: message.author

        when 'playsc'
            return if not Meowbot.Config.soundcloud?.clientId # SoundCloud not setup, assume disabled.
            if isPM then if not Meowbot.Tools.userIsMod message then return
            return Meowbot.Discord.reply message, 'you baka, I\'m not currently in a voice channel :3' if not Meowbot.Discord.voiceConnection
            scUrlReg = scUrlRegex.exec tail
            return Meowbot.Discord.reply message, 'invalid SoundCloud link, please...' if not scUrlReg
            scUrlToResolve = scUrlReg[1]
            await request "http://api.soundcloud.com/resolve?url=http://soundcloud.com/#{scUrlToResolve}&client_id=#{Meowbot.Config.soundcloud.clientId}", defer err, resp, body
            return Meowbot.Discord.reply message, 'I could not reach SoundCloud\'s servers. Maybe try again later, or if it keeps happening ping Nexerq about it?' if err
            return Meowbot.Discord.reply message, "there was a problem when I tried to reach SoundCloud. Please try again later, or maybe you\'ve tried too much and SoundCloud doesn\'t like us? (Error code: #{resp.statusCode})" if resp.statusCode isnt 200
            scData = JSON.parse body
            return Meowbot.Discord.reply message, "there was an error with finding the track data for your song. Maybe you spelt it wrong? (Error: #{if scData.errors[0] then scData.errors[0]['error_message'] else 'Unknown'})" if scData.errors
            return Meowbot.Discord.reply message, 'for some reason, the track is not streamable off SoundCloud. Try a different song, or when it is able to be?' if not scData.streamable or not scData['stream_url']
            addToQueue message,
                name: '[SC] ' + "#{scData.title} (posted by #{scData.user.username})"
                stream: request "#{scData['stream_url']}?client_id=#{Meowbot.Config.soundcloud.clientId}"
                requester: message.author

init = exports.Init = ->
    Meowbot.HandlerSettings.Audio = {} if not Meowbot.HandlerSettings.Audio
    Meowbot.HandlerSettings.Audio.Stopped = true if not Meowbot.HandlerSettings.Audio.Stopped
    Meowbot.HandlerSettings.Audio.NP = null if not Meowbot.HandlerSettings.Audio.NP
    Meowbot.HandlerSettings.Audio.Queue = [] if not Meowbot.HandlerSettings.Audio.Queue
    Meowbot.HandlerSettings.Audio.Volume = 0.35 if not Meowbot.HandlerSettings.Audio.Volume # 35% default volume

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
    await Meowbot.Discord.reply message, "I have added the track **#{trackdata.name}** to the queue. ^-^", defer() # This msg should show up first?
    playNextTrack() if Meowbot.HandlerSettings.Audio.Queue.length is 1 and not Meowbot.HandlerSettings.Audio.NP # Only song in the queue, nothing playing, play it right away

playNextTrack = -> # This assumes there are songs in the queue!
    toPlay = Meowbot.HandlerSettings.Audio.NP = Meowbot.HandlerSettings.Audio.Queue.shift()
    Meowbot.Discord.voiceConnection.playRawStream toPlay.stream, {volume: Meowbot.HandlerSettings.Audio.Volume}
    Meowbot.Discord.sendMessage Meowbot.HandlerSettings.Voice.UpdatesContext, "***Now Playing***: **#{toPlay.name}** *(requested by: #{toPlay.requester.username})*" if Meowbot.HandlerSettings.Voice.UpdatesContext
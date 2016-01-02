fs = require 'fs'
path = require 'path'

musicPath = path.join __dirname, '../', 'music'

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
            Meowbot.Discord.voiceConnection.playFile path.join musicPath, toPlaySong
            Meowbot.Discord.reply message, "now playing #{tail} on your request."

        when '~stopplaying'
            return Meowbot.Discord.reply message, 'you baka, I\'m not currently in a voice channel :3' if not Meowbot.Discord.voiceConnection
            Meowbot.Discord.voiceConnection.stopPlaying()
            Meowbot.Discord.reply message, 'forcefully stopped playing the current track.'

init = exports.Init = ->
    Meowbot.HandlerSettings.Audio = {} if not Meowbot.HandlerSettings.Audio
    Meowbot.HandlerSettings.Audio.Stopped = true if not Meowbot.HandlerSettings.Stopped

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
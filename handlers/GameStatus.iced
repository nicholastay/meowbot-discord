gameIds = ['NEKOPARA VOL. 1', 'NEKOPARA VOL. 0', 'osu!', 'Sakura Clicker', 'Sakura Spirit']

intervals = exports.Intervals = [setInterval((-> changePlayingGameRand()), 10 * 60 * 1000)] # per 10 min change

changePlayingGame = (gameId) -> Meowbot.Discord.setStatus 'online', gameId
changePlayingGameRand = ->
    randomGame = gameIds[Meowbot.Tools.getRandomInt(0, gameIds.length)]
    changePlayingGame randomGame
    Meowbot.Logging.modLog 'Game Status', "Game randomly (out of the predefined) changed to: #{randomGame}"

handler = exports.Command = (command, tail, message) ->
    switch command
        when 'changegame'
            return Meowbot.Discord.reply message, 'you\'re not one of my masters, you can\'t tell me what to do! >.<' if not Meowbot.Tools.userIsMod message
            return if not tail
            switch tail
                when 'random'
                    changePlayingGameRand()
                    return Meowbot.Discord.reply message, "I've changed my playing game to a random game within the ones predefined."
                else
                    Meowbot.Discord.setStatus 'online', tail
                    Meowbot.Discord.reply message, "I've attempted to set my playing game to #{tail}."
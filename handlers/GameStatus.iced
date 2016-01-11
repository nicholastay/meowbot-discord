gameIds = ['NEKOPARA VOL. 1', 'NEKOPARA VOL. 0', 'osu!', 'Sakura Santa', 'Neko Atsume: Kitty Collector']

intervals = exports.Intervals = [setInterval((-> changePlayingGameRand()), 10 * 60 * 1000)] # per 10 min change

changePlayingGame = (gameId) -> Meowbot.Discord.setStatus 'online', gameId
changePlayingGameRand = ->
    randomGame = gameIds[Meowbot.Tools.getRandomInt(0, gameIds.length)]
    changePlayingGame randomGame
    Meowbot.Logging.modLog 'Game Status', "Game randomly (out of the predefined) changed to: #{randomGame}"

handler = exports.Commands = 
    'changegame':
        description: 'Changes the game that I am now playing.'
        forceTailContent: true
        permissionLevel: 'mod'
        handler: (command, tail, message) ->
            switch tail
                when 'random'
                    changePlayingGameRand()
                    return Meowbot.Discord.reply message, "I've changed my playing game to a random game within the ones predefined."
                else
                    Meowbot.Discord.setStatus 'online', tail
                    Meowbot.Discord.reply message, "I've attempted to set my playing game to #{tail}."
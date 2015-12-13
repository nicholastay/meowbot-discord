gameIds = [452, 453, 305, 514, 515]
# nekopara 1, 0, osu!, sakura clicker, spirit

gameList = require __dirname + '/../node_modules/discord.js/ref/gameMap' # just have to reference like this... not sure how reliable.

intervals = exports.Intervals = [setInterval((-> changePlayingGameRand()), 10 * 60 * 1000)] # per 10 min change

changePlayingGame = (gameId) -> Meowbot.Discord.setStatus 'online', gameId
changePlayingGameRand = -> changePlayingGame gameIds[Meowbot.Tools.getRandomInt(0, gameIds.length)]

handler = exports.Command = (command, tail, message) ->
    switch command
        when '~changegame'
            return Meowbot.Discord.reply message, 'you\'re not one of my masters, you can\'t tell me what to do! >.<' if not Meowbot.Tools.userIsMod message
            return if not tail
            switch tail
                when 'random'
                    changePlayingGameRand()
                    return Meowbot.Discord.reply message, "I've changed my playing game to a random game within the ones predefined."
                when 'randomall'
                    changePlayingGame Meowbot.Tools.getRandomInt(0, 751)
                    return Meowbot.Discord.reply message, "I've changed my playing game to a random game out of all Discord-supported games."
                else
                    if /^\d+$/.test tail # If numbers only
                        foundGames = gameList.filter (game) -> return game.id is parseInt tail
                        return Meowbot.Discord.reply message, 'invalid game ID, could not find it within the predefined Discord database.' if foundGames.length < 1
                        Meowbot.Discord.setStatus 'online', tail
                        return Meowbot.Discord.reply message, "I've set my playing game to #{foundGames[0].name}. (game ID #{tail})"
                    else
                        # reverse name lookup
                        foundGames = gameList.filter (game) -> return game.name is tail
                        return Meowbot.Discord.reply message, 'invalid game name, could not find it within the predefined Discord database.' if foundGames.length < 1
                        Meowbot.Discord.setStatus 'online', foundGames[0].id
                        return Meowbot.Discord.reply message, "I've set my playing game to #{tail}. (game ID #{foundGames[0].id})"
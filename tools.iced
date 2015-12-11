module.exports =
    userIsMod: (message) ->
        if message.author.id in Meowbot.Config.admins or message.author.id in Meowbot.Config.mods then return true
        return false

    getRandomInt: (min, max) -> return Math.floor(Math.random() * (max - min)) + min # https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/random
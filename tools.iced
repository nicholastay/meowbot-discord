module.exports =
    userIsMod: (message) ->
        if message.author.id in Meowbot.Config.admins or message.author.id in Meowbot.Config.mods then return true
        return false
module.exports =
    userIsMod: (message) ->
        if message.author.id in Meowbot.Config.admins or message.author.id in Meowbot.Config.mods then return true
        return false

    getRandomInt: (min, max) -> return Math.floor(Math.random() * (max - min)) + min # https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/random

    strRightBack: (str, seperator) -> # http://ozinisle.blogspot.com.au/2010/03/strrightback-in-javascript.html
        pos = str.lastIndexOf seperator
        return str.substring pos+1, str.length
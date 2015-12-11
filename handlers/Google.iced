google = require 'google'

handler = exports.Command = (command, tail, message) ->
    switch command
        when '~search'
            return if not tail
            google.resultsPerPage = 5
            await google tail, defer err, next, links
            return Meowbot.Discord.reply message, 'there was a problem with contacting Google right now, please try again later.' if err
            validLinks = links.filter (link) -> return link.href isnt null # Sometimes there's like a 'images for whatever' or some type of card thing that doesnt actually have a link
            return Meowbot.Discord.reply message, 'there was a problem with contacting Google right now, please try again later.' if not validLinks[0] # well just give up lol
            Meowbot.Discord.sendMessage message, """Here is the first result on Google for ***\'#{tail}\'***:

                                                    **#{validLinks[0].title}**
                                                    #{validLinks[0].href if validLinks[0].href}"""
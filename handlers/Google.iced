{RateLimiter} = require 'limiter'
google = require 'google'
limiter = new RateLimiter 3, 'minute' # just calm down, allow 3 a minute to make sure no like problems with captcha

handler = exports.Commands = 
    'search':
        description: 'Performs a Google search on the given query.'
        forceTailContent: true
        handler: (command, tail, message) ->
            return Meowbot.Discord.reply message, 'please calm down on the Google searches, try again in about a minute.' if not limiter.tryRemoveTokens 1
            google.resultsPerPage = 5
            await google tail, defer err, next, links
            return Meowbot.Discord.reply message, 'there was a problem with contacting Google right now, please try again later.' if err
            validLinks = links.filter (link) -> return link.href isnt null # Sometimes there's like a 'images for whatever' or some type of card thing that doesnt actually have a link
            return Meowbot.Discord.reply message, 'there was a problem with contacting Google right now, please try again later.' if not validLinks[0] # well just give up lol
            Meowbot.Discord.sendMessage message, """Here is the first result on Google for ***\'#{tail}\'***:

                                                    **#{validLinks[0].title}**
                                                    #{validLinks[0].href if validLinks[0].href}"""
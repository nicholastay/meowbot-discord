# Weather powered by Yahoo Dev Network
request = require 'request'
table = require 'text-table'

apiUrl = 'https://query.yahooapis.com/v1/public/yql?format=json&q=' # q=sqlQuery

init = exports.Init = ->
    Meowbot.HandlerSettings.Weather = {} if not Meowbot.HandlerSettings.Weather
    Meowbot.HandlerSettings.Weather.UserForecasts = {} if not Meowbot.HandlerSettings.Weather.UserForecasts # My first try at contextual stuff

handler = exports.Commands =
    'weather':
        description: 'Checks the weather for the given location. (defaults to Melbourne, Australia)'
        handler: (command, tail, message) ->
            place = if tail then tail else 'Melbourne, Australia'
            await request apiUrl + makeSqlQuery(place), defer err, resp, body
            return Meowbot.Discord.reply message, 'there was a problem with contacting Yahoo Weather right now, please try again later.' if err or resp.statusCode isnt 200
            data = JSON.parse body
            return Meowbot.Discord.reply message, 'invalid location given, I can\'t grab weather data for a place that doesn\'t exist or have data for >.<' if data.query.count < 1
            placeData = data.query.results.channel
            friendlyTitle = placeData.item.title
            friendlyTitle[0] = friendlyTitle[0].toLowerCase() # formatting
            temperature = placeData.item.condition.temp
            friendlyText = placeData.item.condition.text.toLowerCase()

            # Store forecast data if user wants to access it later
            Meowbot.HandlerSettings.Weather.UserForecasts[message.author.id] = {} if not Meowbot.HandlerSettings.Weather.UserForecasts[message.author.id]
            Meowbot.HandlerSettings.Weather.UserForecasts[message.author.id] = placeData.item.forecast

            Meowbot.Discord.reply message, "the current weather #{friendlyTitle} is that it's #{friendlyText} with a temperature of #{temperature}°C.\n*(If you would like the forecast for the next five days, use #{(Meowbot.Config.commandPrefix or '!')}forecast.)*"


    'forecast':
        description: 'Checks the forecast contexually. (You must check the weather first)'
        handler: (command, tail, message) ->
            return Meowbot.Discord.reply message, "there is no forecast data for you. Please request the weather (with #{(Meowbot.Config.commandPrefix or '!')}weather [location]) first." if not Meowbot.HandlerSettings.Weather.UserForecasts[message.author.id]?
            generateTable = [['Day', 'Description', 'Low', 'Top']]
            generateTable.push [day.day, day.text, day.low, day.high] for day in Meowbot.HandlerSettings.Weather.UserForecasts[message.author.id]
            displayTable = table generateTable,
                align: [ 'c', 'c', 'c', 'c' ] # centered
                hsep: '     ' # bit more spacing for discord
            Meowbot.Discord.reply message, "The weather forecast is:\n#{displayTable}\n*(the forecast data has also been cleared for you)*"
            Meowbot.HandlerSettings.Weather.UserForecasts[message.author.id] = null

makeSqlQuery = (place) -> return "select * from weather.forecast where u='c' and woeid in (select woeid from geo.places(1) where text=\"#{place}\")"
# u='c' is for metric celsius data (because what is farenheit amirite)
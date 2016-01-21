repl = require 'repl'
stream = require 'stream'
lostartswith = require 'lodash.startswith'
loendswith = require 'lodash.endswith'
moment = require 'moment'

mHandler = exports.Message = (message) ->
    return if not Meowbot.Tools.userIsMod message
    return if not Meowbot.HandlerSettings.Admin.REPLInstances[message.author.id] or lostartswith(message.content, "#{(Meowbot.Config.commandPrefix or '!')}repl")
    Meowbot.HandlerSettings.Admin.REPLInstances[message.author.id].bufferedText += "Meow> #{message.content}\n" # For fanciness
    Meowbot.HandlerSettings.Admin.REPLInstances[message.author.id].rstream.push message.content + '\n' # New line for 'enter' key

cHandler = exports.Commands = 
    'repl':
        description: 'Toggles a usable REPL client in a Discord PM'
        hidden: true
        permissionLevel: 'admin'
        handler: (command, tail, message, isPM) ->
            return if not isPM
            if Meowbot.HandlerSettings.Admin.REPLInstances[message.author.id]
                # REPL client exists, terminate it
                delete Meowbot.HandlerSettings.Admin.REPLInstances[message.author.id]
                Meowbot.Discord.reply message, 'Your REPL session has been terminated.'
            else
                # Create the REPL client and init a session
                wstream = new stream.Writable()
                wstream._write = (chunk, enc, cb) ->
                    return if not chunk
                    txt = chunk.toString()
                    Meowbot.HandlerSettings.Admin.REPLInstances[message.author.id].bufferedText += (if not loendswith txt, '\n' then txt + '\n' else txt)
                    if lostartswith txt, 'Meow>'
                        # Back at the prompt, write to discord and clear buffer
                        # Turn into code block
                        Meowbot.Discord.sendMessage message, '```\n' + Meowbot.HandlerSettings.Admin.REPLInstances[message.author.id].bufferedText + '\n```'
                        Meowbot.HandlerSettings.Admin.REPLInstances[message.author.id].bufferedText = ''
                    cb()
                rstream = new stream.Readable()
                rstream._read = ->
                userSession = Meowbot.HandlerSettings.Admin.REPLInstances[message.author.id] =
                    wstream: wstream
                    rstream: rstream
                Meowbot.HandlerSettings.Admin.REPLInstances[message.author.id].client =
                    repl.start
                        prompt: 'Meow> '
                        bufferedText: '' # Hold text until we reach the prompt again.
                        input: Meowbot.HandlerSettings.Admin.REPLInstances[message.author.id].rstream
                        output: Meowbot.HandlerSettings.Admin.REPLInstances[message.author.id].wstream
                        terminal: false
                Meowbot.Discord.reply message, 'Started a new Admin REPL session for you. Any message you send now will be run through the REPL.'
                # Meowbot.HandlerSettings.Admin.REPLInstances[message.author.id].rstream.push 'console.log(\'hello world from rstream!\');\n'
    
    'tempprefix':
        description: 'Temporarily changes the prefix of commands'
        forceTailContent: true
        permissionLevel: 'mod'
        handler: (command, tail, message) ->
            Meowbot.Config.commandPrefix = tail
            Meowbot.Discord.reply message, "the command prefix was changed to '#{tail}' for as long as I am online."

    'uptime':
        description: 'Gets the uptime of the bot'
        handler: (command, tail, message) ->
            diff = moment().diff(moment(Meowbot.HandlerSettings.Admin.Uptime))
            duration = moment.duration diff
            # ok so this is some possibly 'closed api internal' stuff but it seems to work so... (_data)
            formatted = ''
            for k, v of duration._data # k = measure (seconds, milliseconds etc), v = length
                continue if k is 'milliseconds' # dont care, too exact
                if k is 'seconds' # first time, dont need the comma thing
                    formatted = "#{v} #{k}"
                    continue
                if v is 0 and k is 'days' then break # 0 days, we dont need to go further, just h/m/s
                formatted = "#{v} #{k}, " + formatted
            Meowbot.Discord.sendMessage message, 'I have been up for: ' + formatted

init = exports.Init = ->
    Meowbot.HandlerSettings.Admin = {} if not Meowbot.HandlerSettings.Admin
    Meowbot.HandlerSettings.Admin.REPLInstances = {} if not Meowbot.HandlerSettings.Admin.REPLInstances
    Meowbot.HandlerSettings.Admin.Uptime = Date.now() if not Meowbot.HandlerSettings.Admin.Uptime
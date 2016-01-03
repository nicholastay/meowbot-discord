endsWith = require 'lodash.endswith'
userTagRegex = /<@([0-9]+)>/

handler = exports.Command = (command, tail, message, isPM) ->
    switch command
        when 'setcolor'
            return Meowbot.Discord.sendMessage message, 'This command can only be used in the context of a server.' if isPM
            return Meowbot.Discord.reply message, 'you\'re not one of my masters, you\'re not special enough (^:' if not Meowbot.Tools.userIsMod message

            tailSplit = tail.split ' '
            color = tailSplit[0]
            userToLookup = tailSplit[1]
            return Meowbot.Discord.reply message, 'invalid color (should be a hex color code, for example #FF0000).' if tail[0] isnt '#' or color.length isnt 7
            server = message.channel.server
            if not userToLookup
                # didnt define a user
                user = message.author
            else
                # defined a user
                userTagMatch = userTagRegex.exec userToLookup
                return Meowbot.Discord.reply message, 'invalid user, please define user with the @tag in Discord. :)' if not userTagMatch
                userLookup = server.members.get 'id', userTagMatch[1] # Get by ID the user
                return Meowbot.Discord.reply message, 'invalid user of this server. >.<' if not userLookup # returns null if not found
                user = userLookup[0]

            baseRoleName = 'customcolor_' + user.id
            existingRole = server.roles.get 'name', baseRoleName # Get role by name
            if existingRole
                # Role already exists
                role = existingRole[0]
                await Meowbot.Discord.updateRole role,
                    color: parseInt(color.replace '#', '0x')
                , defer err
                return Meowbot.Discord.reply message, 'there was an error updating the color, please try again later. :(' if err
                return Meowbot.Discord.reply message, "you have updated <@#{user.id}>'s color. :P" if userToLookup
                Meowbot.Discord.reply message, 'your color has been updated :D'
            else
                # Create the role
                await Meowbot.Discord.createRole server,
                    color: parseInt(color.replace '#', '0x')
                    name: user.username + '#' + baseRoleName
                    permissions: []
                , defer err, role
                return Meowbot.Discord.reply message, 'there was an error setting the new color, please try again later. :(' if err
                Meowbot.Discord.addMemberToRole user, role
                return Meowbot.Discord.reply message, "you have set <@#{user.id}>'s color. :P" if userToLookup
                Meowbot.Discord.reply message, 'your new color has been set! Welcome to the kool kids kawaii gang! :D'



        when 'setrolecolor'
            return Meowbot.Discord.sendMessage message, 'This command can only be used in the context of a server.' if isPM
            return Meowbot.Discord.reply message, 'you\'re not one of my masters, you\'re not special enough (^:' if not Meowbot.Tools.userIsMod message

            roleName = tail.split ' '
            color = roleName.shift()
            roleName = roleName.join ' '
            return Meowbot.Discord.reply message, 'invalid color (should be a hex color code, for example #FF0000).' if tail[0] isnt '#' or color.length isnt 7
            server = message.channel.server
            role = server.roles.get 'name', roleName
            return Meowbot.Discord.reply message, 'invalid role for this server.' if not role
            role = role[0]

            await Meowbot.Discord.updateRole role,
                color: parseInt(color.replace '#', '0x')
            , defer err
            return Meowbot.Discord.reply message, 'there was an error updating the role\'s color, please try again later. :(' if err
            Meowbot.Discord.reply message, 'the role\'s color has been updated :D'
endsWith = require 'lodash.endswith'
userTagRegex = /<@([0-9]+)>/

handler = exports.Commands =
    'setcolor':
        description: 'Sets the color of a person.'
        blockPM: true
        forceTailContent: true
        permissionLevel: 'mod'
        handler: (command, tail, message) ->
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
                user = server.members.get 'id', userTagMatch[1] # Get by ID the user
                return Meowbot.Discord.reply message, 'invalid user of this server. >.<' if not user # returns null if not found

            baseRoleName = 'customcolor_' + user.id
            existingRole = server.roles.get 'name', baseRoleName # Get role by name
            if existingRole
                # Role already exists
                await Meowbot.Discord.updateRole existingRole,
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


    'setrolecolor':
        description: 'Sets the color of a role.'
        blockPM: true
        forceTailContent: true
        permissionLevel: 'mod'
        handler: (command, tail, message) ->
            roleName = tail.split ' '
            color = roleName.shift()
            roleName = roleName.join ' '
            return Meowbot.Discord.reply message, 'invalid color (should be a hex color code, for example #FF0000).' if tail[0] isnt '#' or color.length isnt 7
            server = message.channel.server
            role = server.roles.get 'name', roleName
            return Meowbot.Discord.reply message, 'invalid role for this server.' if not role
            
            await Meowbot.Discord.updateRole role,
                color: parseInt(color.replace '#', '0x')
            , defer err
            return Meowbot.Discord.reply message, 'there was an error updating the role\'s color, please try again later. :(' if err
            Meowbot.Discord.reply message, 'the role\'s color has been updated :D'
localtunnel = require 'localtunnel'
githubhook = require 'githubhook'
fs = require 'fs'

saveFile = require('path').join __dirname, '../', '/config', 'GithubWebhook.json'

init = exports.Init = ->
    return if Meowbot.Config.githubwebhook.disabled
    Meowbot.HandlerSettings.GithubWebhook = {} if not Meowbot.HandlerSettings.GithubWebhook

    await fs.access saveFile, fs.R_OK, defer fileErr
    if not Meowbot.HandlerSettings.GithubWebhook.messageCtx and not fileErr # If file exists and theres no message context
        Meowbot.HandlerSettings.GithubWebhook.messageCtx = JSON.parse(fs.readFileSync saveFile).messageCtx
        Meowbot.Logging.modLog 'GitHub Webhook', 'Message context (re)loaded from file.'

    port = Meowbot.Config.localtunnel.port or 27369

    # Tunnel client
    createTunnel port if not Meowbot.HandlerSettings.GithubWebhook.tunnel

    # The actual webhook
    if not Meowbot.HandlerSettings.GithubWebhook.hook
        logger =
            log: (data) -> Meowbot.Logging.modLog 'GitHub Webhook', 'GithubHook: ' + data
            error: (data) -> Meowbot.Logging.modLog 'GitHub Webhook', 'GithubHook <ERROR>: ' + data
        github = Meowbot.HandlerSettings.GithubWebhook.hook = githubhook
            port: Meowbot.Config.localtunnel.port
            path: '/'
            secret: Meowbot.Config.githubwebhook.secret
            logger: logger
        github.listen()
        Meowbot.Logging.modLog 'GitHub Webhook', 'Now listening for GitHub webhook events on port: ' + port
        github.on 'push', (repo, ref, data) ->
            return if not Meowbot.HandlerSettings.GithubWebhook.messageCtx # No channel aka message context to send updates to
            branch = Meowbot.Tools.strRightBack ref, '/'
            repo_fullname = data.repository['full_name']
            output_msg = "**GitHub:#{repo_fullname}) -- #{data.commits.length} commit(s)**"
            output_msg += "\n`#{branch}##{commit.id.substring 0, 7}` #{commit.message.split('\n')[0]} *~ #{commit.author.username} (#{commit.author.name})*" for commit in data.commits
            Meowbot.Discord.sendMessage Meowbot.HandlerSettings.GithubWebhook.messageCtx, output_msg


createTunnel = (port) ->
    localtunnel port,
        host: 'http://localtunnel.me'
        port: port
        subdomain: Meowbot.Config.localtunnel.subdomain
    , (err, tunnel) ->
        return Meowbot.Logging.modLog 'GitHub Webhook', 'error opening tunnel to localtunnel.me, error msg: ' + err if err
        Meowbot.HandlerSettings.GithubWebhook.tunnel = tunnel # store tunnel in case we need it or something, also to detect if already have a client
        Meowbot.Logging.modLog 'GitHub Webhook', 'localtunnel.me tunnel open, url at: ' + tunnel.url
        tunnel.on 'error', (err) ->
            try
                tunnel.close()
            catch e
                # whatever
            Meowbot.HandlerSettings.GithubWebhook.tunnel = null
            Meowbot.Logging.modLog 'GitHub Webhook', 'localtunnel.me tunnel error, ' + err
            Meowbot.Logging.modLog 'GitHub Webhook', 'Will try to reconnect in a minute...'
            Meowbot.Tools.delay 60 * 1000, -> createTunnel()
            

handler = exports.Commands = 
    'gitupdates':
        description: 'Changes the channel that GitHub updates from the webhook are sent to.'
        blockPM: true
        permissionLevel: 'admin'
        handler: (command, tail, message) ->
            return if Meowbot.Config.githubwebhook.disabled
            Meowbot.HandlerSettings.GithubWebhook.messageCtx = message.channel.id
            fs.writeFileSync saveFile, JSON.stringify({messageCtx: message.channel.id}), 'utf8'
            Meowbot.Discord.reply message, 'All GitHub commit updates will now be sent to this channel.'
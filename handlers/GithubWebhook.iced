localtunnel = require 'localtunnel'
githubhook = require 'githubhook'

init = exports.Init = ->
    return if Meowbot.Config.githubwebhook.disabled
    Meowbot.HandlerSettings.GithubWebhook = {} if not Meowbot.HandlerSettings.GithubWebhook

    # Tunnel client
    if not Meowbot.HandlerSettings.GithubWebhook.tunnel
        port = Meowbot.Config.localtunnel.port or 27369
        localtunnel port,
            host: 'http://localtunnel.me'
            port: port
            subdomain: Meowbot.Config.localtunnel.subdomain
        , (err, tunnel) ->
            return Meowbot.Logging.modLog 'GitHub Webhook', 'error opening tunnel to localtunnel.me, error msg: ' + err if err
            Meowbot.HandlerSettings.GithubWebhook.tunnel = tunnel # store tunnel in case we need it or something, also to detect if already have a client
            Meowbot.Logging.modLog 'GitHub Webhook', 'localtunnel.me tunnel open, url at: ' + tunnel.url
            tunnel.on 'error', (err) ->
                Meowbot.HandlerSettings.GithubWebhook.tunnel = null
                Meowbot.Logging.modLog 'GitHub Webhook', 'localtunnel.me tunnel error, error: ' + err

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
            output_msg = "**Updates from GitHub (#{repo_fullname}) - #{data.commits.length} commits pushed**"
            output_msg += "\n**[#{repo}/#{branch} #{commit.id.substring 0, 7}]** #{commit.message.split('\n')[0]} ~ #{commit.author.username} (#{commit.author.name})" for commit in data.commits
            output_msg += "\n***(you can view the full commit history for branch #{branch} here: http://github.com/#{repo_fullname}/commits/#{branch})***"
            Meowbot.Discord.sendMessage Meowbot.HandlerSettings.GithubWebhook.messageCtx, output_msg

handler = exports.Command = (command, tail, message, isPM) ->
    return if Meowbot.Config.githubwebhook.disabled

    switch command
        when '~gitupdates'
            return Meowbot.Discord.sendMessage message, 'This command can only be used in the context of a server.' if isPM
            Meowbot.HandlerSettings.GithubWebhook.messageCtx = message
            Meowbot.Discord.reply message, 'All GitHub commit updates will now be sent to this channel.'
strftime = require 'fast-strftime'
chalk = require 'chalk'

exports.log = log = (data...) -> console.log chalk.magenta("[#{strftime '%l:%M%P'}]") + data.join(' ')
exports.error = error = (data...) -> console.log chalk.magenta("[#{strftime '%l:%M%P'}]") + chalk.red(' [ERROR] ') + data.join(' ')
exports.info = info = (data...) -> console.log chalk.magenta("[#{strftime '%l:%M%P'}]") + chalk.cyan(' [info] ') + data.join(' ')
exports.success = success = (data...) -> console.log chalk.magenta("[#{strftime '%l:%M%P'}]") + chalk.green(' [success] ') + data.join(' ')

exports.modLog = modLog = (moduleName, data...) -> console.log chalk.magenta("[#{strftime '%l:%M%P'}]") + chalk[if moduleDefinitions[moduleName] then moduleDefinitions[moduleName] else 'cyan'](" <#{moduleName}> ") + data.join(' ')

# Here we define if a moduleName that is recognized is passed we can color it specially
exports.moduleDefinitions = moduleDefinitions =
    'Commands': 'green'
    'GitHub Webhook': 'yellow'
    'Internal': 'green'
    'MsgHandlers': 'blue'
    'Config': 'yellow'
    'Discord': 'green'
    'Discord Chat': 'cyan'
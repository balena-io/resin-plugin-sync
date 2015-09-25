var chalk, resin, rsync, shell, _;

_ = require('lodash');

chalk = require('chalk');

resin = require('resin-sdk');

rsync = require('./rsync');

shell = require('./shell');

module.exports = {
  signature: 'sync <uuid> [source]',
  description: 'sync your changes with a device',
  permission: 'user',
  options: [
    {
      signature: 'ignore',
      parameter: 'paths',
      description: 'comma delimited paths to ignore when syncing',
      alias: 'i'
    }, {
      signature: 'before',
      parameter: 'command',
      description: 'execute a command before syncing',
      alias: 'b'
    }, {
      signature: 'progress',
      boolean: true,
      description: 'show progress',
      alias: 'p'
    }
  ],
  action: function(params, options, done) {
    if (options.ignore != null) {
      options.ignore = _.words(options.ignore);
    }
    _.defaults(params, {
      source: process.cwd()
    });
    process.chdir(params.source);
    console.info("Connecting with: " + params.uuid);
    return resin.models.device.isOnline(params.uuid).tap(function(isOnline) {
      if (!isOnline) {
        throw new Error('Device is not online');
      }
    }).then(function() {
      if (options.before != null) {
        return shell.runCommand(options.before, params.source);
      }
    }).then(function() {
      var command;
      command = rsync.getCommand(_.merge(params, options));
      console.log(chalk.cyan(command));
      return shell.runCommand(command);
    }).tap(function() {
      return console.info('Synced, restarting device');
    }).then(function() {
      return resin.models.device.restart(params.uuid);
    }).nodeify(done);
  }
};

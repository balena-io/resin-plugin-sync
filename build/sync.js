var Promise, chalk, resin, rsync, shell, ssh, tree, _;

Promise = require('bluebird');

_ = require('lodash');

chalk = require('chalk');

resin = require('resin-sdk');

rsync = require('./rsync');

shell = require('./shell');

tree = require('./tree');

ssh = require('./ssh');

module.exports = {
  signature: 'sync <uuid> [source]',
  description: 'sync your changes with a device',
  help: 'Use this command to sync your local changes to a certain device on the fly.\n\nExamples:\n\n	$ resin sync 7cf02a62a3a84440b1bb5579a3d57469148943278630b17e7fc6c4f7b465c9\n	$ resin sync 7cf02a62a3a84440b1bb5579a3d57469148943278630b17e7fc6c4f7b465c9 --ignore foo,bar\n	$ resin sync 7cf02a62a3a84440b1bb5579a3d57469148943278630b17e7fc6c4f7b465c9 --watch --delay 4000',
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
      signature: 'exec',
      parameter: 'command',
      description: 'execute a command after syncing (on the device)',
      alias: 'x'
    }, {
      signature: 'progress',
      boolean: true,
      description: 'show progress',
      alias: 'p'
    }, {
      signature: 'watch',
      boolean: true,
      description: 'watch files',
      alias: 'w'
    }, {
      signature: 'delay',
      parameter: 'ms',
      description: 'watch debouce delay',
      alias: 'd'
    }
  ],
  action: function(params, options, done) {
    var performSync;
    if (options.ignore != null) {
      options.ignore = _.words(options.ignore);
    }
    _.defaults(params, {
      source: process.cwd()
    });
    process.chdir(params.source);
    console.info("Connecting with: " + params.uuid);
    performSync = function() {
      return Promise["try"](function() {
        if (options.before != null) {
          return shell.runCommand(options.before);
        }
      }).then(function() {
        var command;
        command = rsync.getCommand(_.merge(params, options));
        console.log(chalk.cyan(command));
        return shell.runCommand(command);
      }).then(function() {
        var command;
        if (options.exec != null) {
          console.info('Synced, running command');
          command = ssh.getConnectCommand({
            uuid: params.uuid,
            command: options.exec
          });
          console.log(chalk.cyan(command));
          return shell.runCommand(command);
        } else {
          console.info('Synced, restarting device');
          return resin.models.device.restart(params.uuid);
        }
      });
    };
    return resin.models.device.isOnline(params.uuid).tap(function(isOnline) {
      if (!isOnline) {
        throw new Error('Device is not online');
      }
    }).then(performSync).then(function() {
      var watch;
      if (options.watch) {
        watch = tree.watch(params.source, {
          ignore: options.ignore,
          delay: options.delay
        });
        watch.on('watching', function(watcher) {
          return console.info("Watching path: " + watcher.path);
        });
        watch.on('change', function(type, filePath) {
          console.info("- " + (type.toUpperCase()) + ": " + filePath);
          return performSync()["catch"](done);
        });
        return watch.on('error', done);
      }
    }).nodeify(done);
  }
};

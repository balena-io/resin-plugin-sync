###
The MIT License

Copyright (c) 2015 Resin.io, Inc. https://resin.io.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
###

Promise = require('bluebird')
_ = require('lodash')
chalk = require('chalk')
resin = require('resin-sdk')
rsync = require('./rsync')
shell = require('./shell')
tree = require('./tree')
ssh = require('./ssh')

module.exports =
	signature: 'sync <uuid> [source]'
	description: 'sync your changes with a device'
	help: '''
		Use this command to sync your local changes to a certain device on the fly.

		Examples:

			$ resin sync 7cf02a62a3a84440b1bb5579a3d57469148943278630b17e7fc6c4f7b465c9
			$ resin sync 7cf02a62a3a84440b1bb5579a3d57469148943278630b17e7fc6c4f7b465c9 --ignore foo,bar
			$ resin sync 7cf02a62a3a84440b1bb5579a3d57469148943278630b17e7fc6c4f7b465c9 --watch --delay 4000
	'''
	permission: 'user'
	options: [
			signature: 'ignore'
			parameter: 'paths'
			description: 'comma delimited paths to ignore when syncing'
			alias: 'i'
		,
			signature: 'before'
			parameter: 'command'
			description: 'execute a command before syncing'
			alias: 'b'
		,
			signature: 'exec'
			parameter: 'command'
			description: 'execute a command after syncing (on the device)'
			alias: 'x'
		,
			signature: 'progress'
			boolean: true
			description: 'show progress'
			alias: 'p'
		,
			signature: 'watch'
			boolean: true
			description: 'watch files'
			alias: 'w'
		,
			signature: 'delay'
			parameter: 'ms'
			description: 'watch debouce delay'
			alias: 'd'
	]
	action: (params, options, done) ->

		# TODO: Add comma separated options to Capitano
		if options.ignore?
			options.ignore = _.words(options.ignore)

		_.defaults params,
			source: process.cwd()

		# Change directory to allow child processes inherit
		# the correct working directory automatically
		process.chdir(params.source)

		console.info("Connecting with: #{params.uuid}")

		performSync = ->
			Promise.try ->
				return shell.runCommand(options.before) if options.before?
			.then ->
				command = rsync.getCommand(_.merge(params, options))
				console.log(chalk.cyan(command))
				return shell.runCommand(command)
			.then ->
				if options.exec?
					console.info('Synced, running command')
					command = ssh.getConnectCommand
						uuid: params.uuid
						command: options.exec
					console.log(chalk.cyan(command))
					return shell.runCommand(command)
				else
					console.info('Synced, restarting device')
					return resin.models.device.restart(params.uuid)

		resin.models.device.isOnline(params.uuid).tap (isOnline) ->
			throw new Error('Device is not online') if not isOnline
		.then(performSync)
		.then ->
			if options.watch
				watch = tree.watch params.source,
					ignore: options.ignore
					delay: options.delay

				watch.on 'watching', (watcher) ->
					console.info("Watching path: #{watcher.path}")

				# tree automatically throttles changes
				watch.on 'change', (type, filePath) ->
					console.info("- #{type.toUpperCase()}: #{filePath}")
					performSync().catch(done)

				watch.on('error', done)
		.nodeify(done)

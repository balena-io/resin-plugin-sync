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
resin = require('resin-sdk')
rsync = require('./rsync')
utils = require('./utils')
shell = require('./shell')
tree = require('./tree')
ssh = require('./ssh')
config = require('./config')

module.exports =
	signature: 'sync <uuid>'
	description: 'sync your changes with a device'
	help: '''
		Use this command to sync your local changes to a certain device on the fly.

		You can save all the options mentioned below in a `resin-sync.yml` file, by using the same option names as keys. For example:

			$ cat $PWD/resin-sync.yml
			source: src/
			before: 'echo Hello'
			exec: 'python main.py'
			ignore:
				- .git
				- node_modules/
			progress: true
			watch: true
			delay: 2000

		Notice that explicitly passed command options override the ones set in the configuration file.

		Examples:

			$ resin sync 7cf02a6
			$ resin sync 7cf02a6 --port 8080
			$ resin sync 7cf02a6 --ignore foo,bar
			$ resin sync 7cf02a6 --watch --delay 4000
	'''
	permission: 'user'
	options: [
			signature: 'source'
			parameter: 'path'
			description: 'custom source path'
			alias: 's'
		,
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
		,
			signature: 'port'
			parameter: 'port'
			description: 'ssh port'
			alias: 't'
	]
	action: (params, options, done) ->

		# TODO: Add comma separated options to Capitano
		if options.ignore?
			options.ignore = options.ignore.split(',')

		options = _.merge(config.load(), options)

		_.defaults options,
			source: process.cwd()

		utils.validateObject options,
			properties:
				ignore:
					description: 'ignore'
					type: 'array'
					message: 'The ignore option should be an array'
				before:
					description: 'before'
					type: 'string'
					message: 'The before option should be a string'
				exec:
					description: 'exec'
					type: 'string'
					message: 'The exec option should be a string'
				progress:
					description: 'progress'
					type: 'boolean'
					message: 'The progress option should be a boolean'
				watch:
					description: 'watch'
					type: 'boolean'
					message: 'The watch option should be a boolean'
				delay:
					description: 'delay'
					type: 'number'
					dependencies: 'watch'
					messages:
						type: 'The delay option should be a number'
						dependencies: 'The delay option should only be used with watch'

		console.info("Connecting with: #{params.uuid}")

		performSync = (fullUUID) ->
			Promise.try ->
				return shell.runCommand(options.before) if options.before?
			.then ->
				command = rsync.getCommand(fullUUID, options)
				return shell.runCommand(command)
			.then ->
				if options.exec?
					console.info('Synced, running command')
					command = ssh.getConnectCommand
						uuid: fullUUID
						command: options.exec
						port: options.port
					return shell.runCommand(command)
				else
					console.info('Synced, restarting device')
					return resin.models.device.restart(params.uuid)

		resin.models.device.isOnline(params.uuid).tap (isOnline) ->
			throw new Error('Device is not online') if not isOnline
		.then ->
			return resin.models.device.hasDeviceUrl(params.uuid)
		.then (hasDeviceUrl) ->
			throw new Error('Device URL not enabled') if not hasDeviceUrl
			return resin.models.device.get(params.uuid).get('uuid').then(performSync)
		.then ->
			return if not options.watch

			watch = tree.watch(options.source, options)

			watch.on 'watching', (watcher) ->
				console.info("Watching path: #{watcher.path}")

			# tree automatically throttles changes
			watch.on 'change', (type, filePath) ->
				console.info("- #{type.toUpperCase()}: #{filePath}")
				performSync().catch(done)

			watch.on('error', done)
		.nodeify(done)

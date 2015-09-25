_ = require('lodash')
chalk = require('chalk')
resin = require('resin-sdk')
rsync = require('./rsync')
shell = require('./shell')

module.exports =
	signature: 'sync <uuid> [source]'
	description: 'sync your changes with a device'
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
			signature: 'progress'
			boolean: true
			description: 'show progress'
			alias: 'p'
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

		resin.models.device.isOnline(params.uuid).tap (isOnline) ->
			throw new Error('Device is not online') if not isOnline
		.then ->
			return shell.runCommand(options.before, params.source) if options.before?
		.then ->
			command = rsync.getCommand(_.merge(params, options))
			console.log(chalk.cyan(command))
			return shell.runCommand(command)
		.tap ->
			console.info('Synced, restarting device')
		.then ->
			return resin.models.device.restart(params.uuid)
		.nodeify(done)

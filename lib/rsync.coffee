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

_ = require('lodash')
revalidator = require('revalidator')
path = require('path')
rsync = require('rsync')
ssh = require('./ssh')

###*
# @summary Get rsync command
# @function
# @protected
#
# @param {Object} options - rsync options
# @param {String} options.source - source path
# @param {String} options.uuid - device uuid
# @param {Boolean} [options.progress] - show progress
# @param {String|String[]} [options.ignore] - pattern/s to ignore
#
# @returns {String} rsync command
#
# @example
# command = rsync.getCommand
# 	source: 'foo/bar'
# 	uuid: '1234567890'
###
exports.getCommand = (options) ->

	validation = revalidator.validate options,
		properties:
			source:
				description: 'source'
				type: 'string'
				required: true
			uuid:
				description: 'uuid'
				type: 'string'
				required: true
				allowEmpty: false
			progress:
				description: 'progress'
				type: 'boolean'
			ignore:
				description: 'ignore'
				type: [ 'string', 'array' ]

	if not validation.valid
		error = _.first(validation.errors)
		throw new Error("#{error.property} #{error.message}")

	args =

		# A trailing slash on the source avoids creating
		# an additional directory level at the destination.
		source: path.join(options.source, path.sep)

		destination: "root@#{options.uuid}.resin:/data/.resin-watch"
		progress: options.progress
		shell: ssh.getConnectCommand()

		# a = archive mode.
		# This makes sure rsync synchronizes the
		# files, and not just copies them blindly.
		#
		# z = compress during transfer
		# r = recursive
		flags: 'azr'

	if _.isEmpty(options.source.trim())
		args.source = '.'

	# For some reason, adding `exclude: undefined` adds an `--exclude`
	# with nothing in it right before the source, which makes rsync
	# think that we want to ignore the source instead of transfer it.
	if options.ignore?
		args.exclude = options.ignore

	return rsync.build(args).command()

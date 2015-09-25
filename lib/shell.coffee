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

child_process = require('child_process')
os = require('os')
Promise = require('bluebird')

###*
# @summary Run a command in a subshell
# @function
# @protected
#
# @description
# stdin is inherited from the parent process.
#
# @param {String} command - command
# @returns {Promise}
#
# @example
# shell.runCommand('echo hello').then ->
# 	console.log('Done!')
###
exports.runCommand = (command) ->
	options =
		stdio: 'inherit'

	if os.platform() is 'win32'
		spawn = child_process.spawn('cmd.exe', [ '/s', '/c', "\"#{command}\"" ], options)
	else
		spawn = child_process.spawn('/bin/sh', [ '-c', command ], options)

	return new Promise (resolve, reject) ->
		spawn.on('error', reject)
		spawn.on 'close', (code) ->
			return resolve() if code is 0
			return reject(new Error("Child process exited with code #{code}"))

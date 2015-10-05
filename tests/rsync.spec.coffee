m = require('mochainon')
_ = require('lodash')
path = require('path')
os = require('os')
rsync = require('../lib/rsync')

assertCommand = (command, options) ->
	expected = 'rsync -azr'

	if options.progress
		expected += ' --progress'

	expected += ' --rsh=\"ssh -p 80 -o \\\"ProxyCommand nc -X connect -x vpn.resin.io:3128 %h %p\\\" -o StrictHostKeyChecking=no\"'

	if options.exclude?
		expected += ' ' + _.map options.exclude, (pattern) ->
			return "--exclude=#{pattern}"
		.join(' ')

	if os.platform() is 'win32' and options.source isnt '.'
		expected += " \"#{options.source}\""
	else
		expected += " #{options.source}"

	expected += " root@#{options.uuid}.resin:/data/.resin-watch"

	m.chai.expect(command).to.equal(expected)

describe 'Rsync:', ->

	it 'should throw if no source', ->
		m.chai.expect ->
			rsync.getCommand('1234')
		.to.throw('Missing source')

	it 'should throw if source is not a string', ->
		m.chai.expect ->
			rsync.getCommand '1234',
				source: [ 'foo', 'bar' ]
		.to.throw('Not a string: source')

	it 'should throw if progress is not a boolean', ->
		m.chai.expect ->
			rsync.getCommand '1234',
				source: 'foo/bar'
				progress: 'true'
		.to.throw('Not a boolean: progress')

	it 'should throw if ignore is not a string nor array', ->
		m.chai.expect ->
			rsync.getCommand '1234',
				source: 'foo/bar'
				ignore: 1234
		.to.throw('Not a string or array: ignore')

	it 'should interpret an empty source as .', ->
		command = rsync.getCommand '1234',
			source: ''

		m.chai.expect(command).to.equal [
			'rsync'
			'-azr'
			'--rsh=\"ssh -p 80 -o \\\"ProxyCommand nc -X connect -x vpn.resin.io:3128 %h %p\\\" -o StrictHostKeyChecking=no\"'
			'.'
			'root@1234.resin:/data/.resin-watch'
		].join(' ')

	it 'should interpret an source containing only blank spaces as .', ->
		command = rsync.getCommand '1234',
			source: '      '

		assertCommand command,
			source: '.'
			uuid: '1234'

	it 'should automatically append a slash at the end of source', ->
		command = rsync.getCommand '1234',
			source: 'foo'

		assertCommand command,
			source: "foo#{path.sep}"
			uuid: '1234'

	it 'should not append a slash at the end of source is there is one already', ->
		command = rsync.getCommand '1234',
			source: "foo#{path.sep}"

		assertCommand command,
			source: "foo#{path.sep}"
			uuid: '1234'

	it 'should be able to set progress to true', ->
		command = rsync.getCommand '1234',
			source: "foo#{path.sep}bar#{path.sep}"
			progress: true

		assertCommand command,
			source: "foo#{path.sep}bar#{path.sep}"
			uuid: '1234'
			progress: true

	it 'should be able to set progress to false', ->
		command = rsync.getCommand '1234',
			source: "foo#{path.sep}bar#{path.sep}"
			progress: false

		assertCommand command,
			source: "foo#{path.sep}bar#{path.sep}"
			uuid: '1234'

	it 'should be able to exclute a single pattern', ->
		command = rsync.getCommand '1234',
			source: "foo#{path.sep}bar#{path.sep}"
			ignore: '.git'

		assertCommand command,
			source: "foo#{path.sep}bar#{path.sep}"
			uuid: '1234'
			exclude: [ '.git' ]

	it 'should be able to exclute a multiple patterns', ->
		command = rsync.getCommand '1234',
			source: "foo#{path.sep}bar#{path.sep}"
			ignore: [ '.git', 'node_modules' ]

		assertCommand command,
			source: "foo#{path.sep}bar#{path.sep}"
			uuid: '1234'
			exclude: [ '.git', 'node_modules' ]

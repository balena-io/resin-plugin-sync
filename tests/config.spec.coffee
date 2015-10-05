m = require('mochainon')
path = require('path')
mockFs = require('mock-fs')
config = require('../lib/config')

describe 'Config:', ->

	describe '.getPath()', ->

		it 'should be an absolute path', ->
			configPath = config.getPath()
			isAbsolute = configPath is path.resolve(configPath)
			m.chai.expect(isAbsolute).to.be.true

		it 'should point to a yaml file', ->
			configPath = config.getPath()
			m.chai.expect(path.extname(configPath)).to.equal('.yml')

	describe '.load()', ->

		describe 'given the file contains valid yaml', ->

			it 'should return the parsed contents', ->
				filesystem = {}
				filesystem[config.getPath()] = '''
					source: 'src/'
					before: 'echo Hello'
				'''
				mockFs(filesystem)

				options = config.load()
				m.chai.expect(options).to.deep.equal
					source: 'src/'
					before: 'echo Hello'

				mockFs.restore()

		describe 'given the file contains invalid yaml', ->

			it 'should return the parsed contents', ->
				filesystem = {}
				filesystem[config.getPath()] = '''
					1234
				'''
				mockFs(filesystem)

				m.chai.expect(config.load).to.throw('Invalid configuration file')

				mockFs.restore()

		describe 'given the file does not exist', ->

			it 'should return an empty object', ->
				mockFs({})

				options = config.load()
				m.chai.expect(options).to.deep.equal({})

				mockFs.restore()

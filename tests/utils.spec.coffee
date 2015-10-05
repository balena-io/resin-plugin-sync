m = require('mochainon')
EventEmitter = require('events').EventEmitter
utils = require('../lib/utils')

describe 'Utils:', ->

	describe '.validateObject()', ->

		it 'should not throw if object is valid', ->
			m.chai.expect ->
				utils.validateObject
					foo: 'bar'
				,
					properties:
						foo:
							description: 'foo'
							type: 'string'
							required: true
			.to.not.throw(Error)

		it 'should throw if object is invalid', ->
			m.chai.expect ->
				utils.validateObject
					foo: 'bar'
				,
					properties:
						foo:
							description: 'foo'
							type: 'number'
							required: true
							message: 'Foo should be a number'
			.to.throw('Foo should be a number')

		it 'should throw the first error if object has multiple validation issues', ->
			m.chai.expect ->
				utils.validateObject
					foo: 'bar'
				,
					properties:
						foo:
							description: 'foo'
							type: 'number'
							required: true
							message: 'Foo should be a number'
						bar:
							description: 'bar'
							type: 'string'
							required: true
							message: 'Bar should be a string'
			.to.throw('Foo should be a number')

	describe '.waitStream()', ->

		describe 'given a stream that emits a close event', ->

			beforeEach ->
				@stream = new EventEmitter()
				setTimeout =>
					@stream.emit('close')
				, 100

			it 'should resolve the promise', ->
				promise = utils.waitStream(@stream)
				m.chai.expect(promise).to.eventually.be.undefined

		describe 'given a stream that emits an error event', ->

			beforeEach ->
				@stream = new EventEmitter()
				setTimeout =>
					@stream.emit('error', new Error('stream error'))
				, 100

			it 'should be rejected with the error message', ->
				promise = utils.waitStream(@stream)
				m.chai.expect(promise).to.be.rejectedWith('stream error')

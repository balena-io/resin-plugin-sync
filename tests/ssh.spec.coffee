m = require('mochainon')
ssh = require('../lib/ssh')

describe 'SSH:', ->

	describe '.getConnectCommand()', ->

		describe 'given no options', ->

			it 'should return a standard command', ->
				command = ssh.getConnectCommand()
				m.chai.expect(command).to.equal('ssh -p 80 -o \"ProxyCommand nc -X connect -x vpn.resin.io:3128 %h %p\" -o StrictHostKeyChecking=no')

		describe 'given a uuid', ->

			it 'should use the correct device host', ->
				command = ssh.getConnectCommand(uuid: '1234')
				m.chai.expect(command).to.equal('ssh -p 80 -o \"ProxyCommand nc -X connect -x vpn.resin.io:3128 %h %p\" -o StrictHostKeyChecking=no root@1234.resin')

		describe 'given a command', ->

			it 'should send the command surrounded by quotes', ->
				command = ssh.getConnectCommand(command: 'ls -la')
				m.chai.expect(command).to.equal('ssh -p 80 -o \"ProxyCommand nc -X connect -x vpn.resin.io:3128 %h %p\" -o StrictHostKeyChecking=no \"ls -la\"')

		describe 'given both a uuid and a command', ->

			it 'should send the command after the host', ->
				command = ssh.getConnectCommand
					uuid: '1234'
					command: 'ls -la'

				m.chai.expect(command).to.equal('ssh -p 80 -o \"ProxyCommand nc -X connect -x vpn.resin.io:3128 %h %p\" -o StrictHostKeyChecking=no root@1234.resin \"ls -la\"')

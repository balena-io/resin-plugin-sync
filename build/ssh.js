
/*
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
 */
var _;

_ = require('lodash');


/**
 * @summary Get SSH connection command for a device
 * @function
 * @protected
 *
 * @param {Object} [options] - options
 * @param {String} [options.uuid] - device uuid
 * @param {String} [options.command] - command to execute
 * @param {Number} [options.port] - ssh port
 *
 * @returns {String} ssh command
 *
 * @example
 * ssh.getConnectCommand
 * 	uuid: '1234'
 * 	command: 'date'
 */

exports.getConnectCommand = function(options) {
  var result;
  if (options == null) {
    options = {};
  }
  _.defaults(options, {
    port: 80
  });
  result = "ssh -p " + options.port + " -o \"ProxyCommand nc -X connect -x vpn.resin.io:3128 %h %p\" -o StrictHostKeyChecking=no";
  if (options.uuid != null) {
    result += " root@" + options.uuid + ".resin";
  }
  if (options.command != null) {
    result += " \"" + options.command + "\"";
  }
  return result;
};

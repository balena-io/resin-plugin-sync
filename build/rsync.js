
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
var path, revalidator, rsync, ssh, utils, _;

_ = require('lodash');

_.str = require('underscore.string');

revalidator = require('revalidator');

path = require('path');

rsync = require('rsync');

utils = require('./utils');

ssh = require('./ssh');


/**
 * @summary Get rsync command
 * @function
 * @protected
 *
 * @param {String} uuid - uuid
 * @param {Object} options - rsync options
 * @param {String} options.source - source path
 * @param {Boolean} [options.progress] - show progress
 * @param {String|String[]} [options.ignore] - pattern/s to ignore
 *
 * @returns {String} rsync command
 *
 * @example
 * command = rsync.getCommand '...',
 * 	source: 'foo/bar'
 * 	uuid: '1234567890'
 */

exports.getCommand = function(uuid, options) {
  var args, result;
  if (options == null) {
    options = {};
  }
  utils.validateObject(options, {
    properties: {
      source: {
        description: 'source',
        type: 'string',
        required: true,
        messages: {
          type: 'Not a string: source',
          required: 'Missing source'
        }
      },
      progress: {
        description: 'progress',
        type: 'boolean',
        message: 'Not a boolean: progress'
      },
      ignore: {
        description: 'ignore',
        type: ['string', 'array'],
        message: 'Not a string or array: ignore'
      }
    }
  });
  if (!_.str.isBlank(options.source) && _.last(options.source) !== '/') {
    options.source += '/';
  }
  args = {
    source: options.source,
    destination: "root@" + uuid + ".resin:/data/.resin-watch",
    progress: options.progress,
    shell: ssh.getConnectCommand(),
    flags: 'azr'
  };
  if (_.isEmpty(options.source.trim())) {
    args.source = '.';
  }
  if (options.ignore != null) {
    args.exclude = options.ignore;
  }
  result = rsync.build(args).command();
  result = result.replace(/\\\\/g, '\\');
  return result;
};

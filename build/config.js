
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
var fs, jsYaml, path, _;

fs = require('fs');

_ = require('lodash');

path = require('path');

jsYaml = require('js-yaml');


/**
 * @summary Get config path
 * @function
 * @private
 *
 * @returns {String} config path
 *
 * @example
 * configPath = config.getPath()
 */

exports.getPath = function() {
  return path.join(process.cwd(), 'resin-sync.yml');
};


/**
 * @summary Load configuration file
 * @function
 * @protected
 *
 * @description
 * If no configuration file is found, return an empty object.
 *
 * @returns {Object} configuration
 *
 * @example
 * options = config.load()
 */

exports.load = function() {
  var config, configPath, error, result;
  configPath = exports.getPath();
  try {
    config = fs.readFileSync(configPath, {
      encoding: 'utf8'
    });
    result = jsYaml.safeLoad(config);
  } catch (_error) {
    error = _error;
    if (error.code === 'ENOENT') {
      return {};
    }
    throw error;
  }
  if (!_.isPlainObject(result)) {
    throw new Error("Invalid configuration file: " + configPath);
  }
  return result;
};

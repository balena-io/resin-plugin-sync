
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
var EventEmitter, watchr,
  __slice = [].slice;

EventEmitter = require('events').EventEmitter;

watchr = require('watchr');


/**
 * @summary Watch file system
 * @function
 * @protected
 *
 * @param {String} directory - directory path
 * @param {Object} [options] - options
 * @param {String[]} [options.ignore] - ignore paths
 * @param {Number} [options.delay] - watch delay
 *
 * @emits change
 * @emits log
 * @emits error
 * @emits watching
 * @emits next
 *
 * @returns {EventEmitter} watcher
 *
 * @example
 * watch = tree.watch('foo/bar', ignore: [ 'node_modules' ])
 *
 * watch.on 'watching', (watcher) ->
 * 	console.info("Watching path: #{watcher.path}")
 *
 * 	watch.on 'change', (type, filePath) ->
 * 		console.log(type, filePath)
 *
 * 	watch.on 'error', (error) ->
 * 		throw error
 */

exports.watch = function(directory, options) {
  var emitter;
  if (options == null) {
    options = {};
  }
  emitter = new EventEmitter();
  watchr.watch({
    path: directory,
    ignoreCommonPatterns: true,
    ignoreCustomPatterns: options.ignore,
    catchupDelay: options.delay,
    listeners: {
      change: function() {
        return emitter.emit.apply(emitter, ['change'].concat(__slice.call(arguments)));
      },
      log: function() {
        return emitter.emit.apply(emitter, ['log'].concat(__slice.call(arguments)));
      },
      error: function(error) {
        return emitter.emit('error', error);
      },
      watching: function(error, watcherInstance, isWatching) {
        if (error != null) {
          return emitter.emit('error', error);
        }
        return emitter.emit('watching', watcherInstance, isWatching);
      }
    },
    next: function(error, watchers) {
      if (error != null) {
        return emitter.emit('error', error);
      }
      return emitter.emit('next', watchers);
    }
  });
  return emitter;
};

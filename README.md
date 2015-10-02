resin-plugin-sync
-----------------

[![npm version](https://badge.fury.io/js/resin-plugin-sync.svg)](http://badge.fury.io/js/resin-plugin-sync)
[![dependencies](https://david-dm.org/resin-io/resin-plugin-sync.png)](https://david-dm.org/resin-io/resin-plugin-sync.png)
[![Build Status](https://travis-ci.org/resin-io/resin-plugin-sync.svg?branch=master)](https://travis-ci.org/resin-io/resin-plugin-sync)
[![Build status](https://ci.appveyor.com/api/projects/status/e0sth5805p3jdved?svg=true)](https://ci.appveyor.com/project/resin-io/resin-plugin-sync)

Watch a local project directory and sync it on the fly.

Requirements
------------

This plugin depends on `rsync` to be available from the command line.

If running Windows, see [cwRsync](https://www.itefix.net/content/cwrsync-free-edition).

Installation
------------

Install `resin-plugin-sync` by running:

```sh
$ npm install -g resin-cli resin-plugin-sync
```

You can then access the `resin sync` command from your terminal.

Documentation
-------------

Run `resin help sync` for documentation.

Support
-------

If you're having any problem, please [raise an issue](https://github.com/resin-io/resin-plugin-sync/issues/new) on GitHub and the Resin.io team will be happy to help.

Tests
-----

Run the test suite by doing:

```sh
$ gulp test
```

Contribute
----------

- Issue Tracker: [github.com/resin-io/resin-plugin-sync/issues](https://github.com/resin-io/resin-plugin-sync/issues)
- Source Code: [github.com/resin-io/resin-plugin-sync](https://github.com/resin-io/resin-plugin-sync)

Before submitting a PR, please make sure that you include tests, and that [coffeelint](http://www.coffeelint.org/) runs without any warning:

```sh
$ gulp lint
```

License
-------

The project is licensed under the MIT license.

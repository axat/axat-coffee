assert = require 'assert'
axat = require 'axat'
i64r = axat.i64r


# Code coverage must be done manually because expresso does not understand C++.

# Testing is a bit awkward because i64r is thought as prototype for an object
# inheriting from Buffer. So this here is mininmal. Most tests are in i64.

module.exports =

  Illegals: ->
    assert.equal i64r.zero.bind(0) null
    assert.equal i64r.zero.bind(8) null
    assert.equal i64r.zero.bind('a') null
    assert.equal i64r.zero.bind('12345678') null
    assert.equal i64r.zero.bind(1.5) null
    assert.equal i64r.zero.bind({}) null
    assert.equal i64r.zero.bind([]) null
    assert.equal i64r.zero.bind((->)) null
    assert.equal i64r.zero.bind(new Buffer 7) null



if require.main is module
  module.exports.Illegals()




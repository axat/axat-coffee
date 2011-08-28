assert = require 'assert'
axat = require 'axat'
i64r = axat.i64r


module.exports =

  Illegals: ->
    assert.equal i64r.zero 0, null
    assert.equal i64r.zero 8, null
    assert.equal i64r.zero 'a', null
    assert.equal i64r.zero '12345678', null
    assert.equal i64r.zero 1.5, null
    assert.equal i64r.zero {}, null
    assert.equal i64r.zero [], null
    assert.equal i64r.zero (->), null
    assert.equal i64r.zero new Buffer 7, null


  Conversions: ->
    i = new Buffer 8
    values = '0 -1 1 -2 2 127 -127 128 -128 1024 65536 -65536
      4294967296 -4294967296 1099511627776 -1099511627776
      4296947296 -4929467296 1016279951776 -1099627511776
      281474976710656 -281474976710656 281474934576710656
      844424930131968 72057594037927940 184467440737095520
      884467440737095520 -884467440737095520'.split /\s+/
    assert.equal i64r.lltoa(i64r.atoll i, v), v for v in values

  SomeOperations: ->
    i1 = new Buffer 8
    i2 = new Buffer 8
    i64r.zero i1
    assert.equal i64r.lltoa(i1), '0'
    i64r.zero i2
    assert.equal i64r.lltoa(i2), '0'
    i64r.i32low i1, 17
    assert.equal i64r.lltoa(i1), '17'
    i64r.i32low i2, 42
    assert.equal i64r.lltoa(i2), '42'
    assert.equal i64r.lltoa(i64r.add i1, i1, i2), '59'
    assert.equal i64r.lltoa(i1), '59'
    assert.equal i64r.lltoa(i2), '42'

# todo some tests with buffer.write('base64')


if require.main is module
  module.exports.Illegals()
  module.exports.Conversions()
  module.exports.SomeOperations()

# Thinking about it: I see the 64 bit integer in Axat as a value type, but
# in Javascript with node addon it's a reference type. This must be carefully
# hidden that's not really a value type. It's a bit awkward because Javascript
# does not have a 64 bit integer value type.

# Also, code coverage must be done manually because expresso does not
# understand C++.


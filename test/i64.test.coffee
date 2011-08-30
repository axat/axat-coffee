assert = require 'assert'
axat = require 'axat'
i64 = axat.i64


# Note: code coverage must be done manually because C++ code is not understood.

module.exports =
  Conversions: ->
    i = new i64
    i.atoll '2344560'
    assert.equal i.lltoa(), '2344560'

    values = '0 -1 1 -2 2 127 -127 128 -128 1024 65536 -65536
      4294967296 -4294967296 1099511627776 -1099511627776
      4296947296 -4929467296 1016279951776 -1099627511776
      281474976710656 -281474976710656 281474934576710656
      844424930131968 72057594037927940 184467440737095520
      884467440737095520 -884467440737095520'.split /\s+/
    assert.equal (i.atoll v; i.lltoa()), v for v in values

  SomeOperations: ->
    i1 = new i64
    i2 = new i64
    i1.zero()
    assert.equal i1.lltoa(), '0'
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
  module.exports.Conversions()
  module.exports.SomeOperations()




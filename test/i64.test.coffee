assert = require 'assert'
axat = require 'axat'
i64 = axat.i64


# Note: code coverage must be done manually because C++ code is not understood.

module.exports =
  Conversions: ->
    i = i64.create '2344560'
    assert.equal i.asString, '2344560'

    values = '0 -1 1 -2 2 127 -127 128 -128 1024 65536 -65536
      4294967296 -4294967296 1099511627776 -1099511627776
      4296947296 -4929467296 1016279951776 -1099627511776
      281474976710656 -281474976710656 281474934576710656
      844424930131968 72057594037927940 184467440737095520
      884467440737095520 -884467440737095520'.split /\s+/
    assert.equal (i = i64.create v; i.asString), v for v in values

  SomeOperations: ->
    i1 = i64.create()
    i2 = i64.create()
    assert.equal i1.asString, '0'
    assert.equal i2.asString, '0'
    i1.low = 17
    assert.equal i1.asString, '17'
    i2.low = 42
    assert.equal i2.asString, '42'
    assert.equal i1.add(i1, i2).asString, '59'
    assert.equal i1.asString, '59'
    assert.equal i2.asString, '42'
    assert.equal i1.low, 59
    assert.equal i1.zero().asString, '0'
    i1.high = 1
    assert.equal i1.asString, '4294967296'


if require.main is module
  module.exports.Conversions()
  module.exports.SomeOperations()




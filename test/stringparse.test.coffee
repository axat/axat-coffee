unescape = require('axat').parse.stringparse.unescape
assert = require('assert')

module.exports =
  Strings: ->
    strings = [
      [ '',           0,                         ]
      [ 'a',          1, 0x61,                   ]
      [ '$',          1, 0x24,                   ]
      [ 'ä',          2, 0xc3, 0xa4,             ]
      [ '李',          3, 0xe6, 0x9d, 0x8e,       ]
      [ '\\n',        1, 0x0a,                   ]
      [ '\\r',        1, 0x0d,                   ]
      [ '\\t',        1, 0x09,                   ]
      [ '\\s',        1, 0x20,                   ]
      [ '\\"',        1, 0x22                    ]
      [ '\\\\',       1, 0x5c,                   ]
      [ '\\x00',      1, 0x00,                   ]
      [ '\\x40',      1, 0x40,                   ]
      [ '\\x7f',      1, 0x7f,                   ]
      [ '\\x80',      1, 0x80,                   ]
      [ '\\xff',      1, 0xff,                   ]
      [ 'a\\xff',     2, 0x61, 0xff,             ]
      [ '\\xff\\x7f', 2, 0xff, 0x7f,             ]
      [ '\\u0000',    2, 0xc0, 0x80,             ]
      [ '\\u0001',    1, 0x01,                   ]
      [ '\\u007f',    1, 0x7f,                   ]
      [ '\\u0080',    2, 0xc2, 0x80,             ]
      [ '\\u0xff',    2, 0xc3, 0xbf,             ]
      [ '\\u0800',    3, 0xe0, 0xa0, 0x80,       ]
      [ '\\uffff',    3, 0xef, 0xbf, 0xbf,       ]
      [ '\\U010000',  4, 0xf0, 0x90, 0x80, 0x80, ]
      [ '\\U10ffFF',  4, 0xf4, 0x8f, 0xbf, 0xbf, ]
      [ '\\xCD',      1, 0xcd,                   ]
      [ '\\xEF',      1, 0xef,                   ]
      [ '\\uabcd',    3, 0xea, 0xaf, 0x8d,       ]
      [ '\\uABCD',    3, 0xea, 0xaf, 0x8d,       ]
      [ '\\uefEF',    3, 0xee, 0xbf, 0xaf,       ]
      [ '\\U0abcde',  4, 0xf2, 0xab, 0xb3, 0x9e, ]
      [ '\\U0ABCDE',  4, 0xf2, 0xab, 0xb3, 0x9e, ]
    ]

    asserter = (item) ->
      buffer = unescape '"' + item[0] + '"'
      console.log "==>", buffer
      length = item[1]
      bytes = item.slice 2

      assert.equal buffer.length, length
      if length > 0
        assert.equal buffer[i], bytes[i] for i in [0 .. length - 1]

    asserter item for item in strings


if require.main is module
  module.exports.Strings()

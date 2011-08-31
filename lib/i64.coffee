###

64 bit Integer for Axat.

Javascript does not have a 64 bit integer. With a Node addon and Node Buffers
for storage the functionality of the Axat Integer value type is replicated.
Do not use any operators, not even the assign operator. Javascript does not
have operator overloading. Assign does not work correctly because Axat Integer
is a value type, but Javascript objects are reference types. Using the assign
operator would have the same effect as the C++ reference operator (&).

Most operations are in a Node addon because many 64 bit operations are

###

i64r = require './i64r'
inspect = require('util').inspect

module.exports =
  create: ->
    b = new Buffer 8
    b.__proto__ = i64r
    if arguments.length is 0 then b.zero()
    else if arguments.length is 1 then b.atoll arguments[0]
    else
      b.setLow arguments[0]
      b.setHigh arguments[0]

Object.defineProperties i64r,
  inspect:
    value: (args...) ->
      if @ is i64r then inspect.call @, args else @toString()
  assign:
    value: (src) -> src.copy @
  asString:
    get: () -> @lltoa()
    set: (s) -> @atoll s
  toString:
    value: (src) -> @lltoa() + 'L'
  low:
    get: () -> @getLow()
    set: (i) -> @setLow i
  high:
    get: () -> @getHigh()
    set: (i) -> @setHigh i


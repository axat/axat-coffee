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

module.exports =
  create: ->
    b = new Buffer 8
    b.__proto__ = i64r
    if arguments.length is 0 then zero()
    else if arguments.length is 1 then @atoll arguments[0]
    else
      @i32low arguments[0]
      @i32high arguments[0]

i64.create = -> new i64 8

i64::prototype = require './i64r'

i64::prototype.assign = (src) -> src.copy @

i64::prototype.toString = (src) -> @.lltoa()


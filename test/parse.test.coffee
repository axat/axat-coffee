assert = require 'assert'
axat = require 'axat'
parse = axat.parse
STOP = axat.lex.STOP

i64 = (v) -> axat.i64.create().atoll v


module.exports =

  Parse: ->
    parseIndex = 0
    parseItems =
      '(a) 1L 2.1 false (b) (c) "string" false false (d) false null'.split ' '
    itemChecker = (item) -> assert.equal item + '', parseItems[parseIndex++]

    stream = parse.createParser itemChecker
    stream '(a 1 2.1) (b (c "string")) (d)'
    stream STOP
    assert.equal parseIndex, parseItems.length

    # Parser is dead: should not throw
    stream.cb = (item) -> assert.fail 'but has', 'cb should not be called'
    stream '(dead)'

    # Falsificate the test with reset parser: should throw
    stream.reset()
    assert.throws (-> stream '(live)'), (err) ->
      err.name is 'AssertionError' and err.actual is 'but has'


  Error1: ->
    parseIndex = 0
    parseItems = [
      new parse.ParseError 'Parse Error: expected OPEN CLOSE EOT but had ID'
    ]
    stream = parse.createParser (item) ->
      assert.deepEqual item, parseItems[parseIndex++]

    stream 'invalid'


  # todo: syntax error, unexpected eot, unexpected close, for each state
  # unexpected token (Start, Open, Axiom)


  # todo: 64 bit integer, real string


  RedefineCallback: ->
    cb = (item) -> item    # dummy
    cb2 = (item2) -> token2 # different dummy
    stream = parse.createParser cb
    assert.strictEqual(stream.cb, cb)
    stream.cb = cb2
    assert.strictEqual(stream.cb, cb2)


  ResetParser: ->
    parseIndex = 0
    parseItems = '(a) false null (b) false null'.split ' '
    itemChecker = (item) -> assert.equal item + '', parseItems[parseIndex++]

    stream = parse.createParser itemChecker
    stream '('
    stream.reset()
    stream '(a)'
    stream STOP

    # Parser is dead: should not throw
    stream.cb = (item) -> assert.fail 'but has', 'cb should not be called'
    stream '(dead)'

    stream.reset()
    stream.cb = itemChecker
    stream '(b)'
    stream STOP
    assert.equal parseIndex, parseItems.length


if require.main is module
  module.exports.Parse()
  module.exports.Error1()
  module.exports.RedefineCallback()
  module.exports.ResetParser()

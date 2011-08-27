assert = require 'assert'
axat = require 'axat'
lex = axat.lex


module.exports =

  TextStream: ->
    tokenIndex = 0
    tokenSequence = [
      lex.createToken 'OPEN',    '('
      lex.createToken 'ID',      'identifier'
      lex.createToken 'IGNORE',  ' '
      lex.createToken 'INTEGER', '0123456789'
      lex.createToken 'IGNORE',  ' '
      lex.createToken 'DOUBLE',  '-12.34'
      lex.createToken 'CLOSE',   ')'
      lex.createToken 'EMPTY',   ''
      lex.EOT
    ]
    stream = lex.createLexer (token) ->
      assert.deepEqual token, tokenSequence[tokenIndex++]

    stream '(identifier 0123456789 -12.34)'
    stream lex.STOP
    assert.equal tokenIndex, tokenSequence.length

    # Send another STOP to verify that EOT is sent again
    stream.cb = (token) ->
      assert.deepEqual token, lex.EOT
    stream lex.STOP

    # Falsificate the test: should throw
    assert.throws (-> stream 'not_eot'), (err) ->
      err.name is 'AssertionError' and err.actual.value is 'not_eot'


  SomeErrors: ->
    errorProducer = (text) ->
      stream = lex.createLexer (token) ->
        assert.deepEqual token, lex.ERROR
      stream text

    invalidChars = '!#$%&\'*+,-./:;<=>?@\'[\\]^`{|}~\t'
      .split(/(.)/).filter (s) -> s isnt ''
    errorProducer text for text in invalidChars


  Many: ->
    text = ([0..10000].reduce (prev) -> prev + '(')[1..]
    stream = lex.createLexer (token) -> assert.equal token.type, 'OPEN'
    assert.throws (-> stream text), (err) ->
      err.name is 'AssertionError' and err.actual is 'EMPTY'

  RedefineCallback: ->
    cb = (token) -> token    # dummy
    cb2 = (token2) -> token2 # different dummy
    stream = lex.createLexer cb
    assert.strictEqual(stream.cb, cb)
    stream.cb = cb2
    assert.strictEqual(stream.cb, cb2)


if require.main is module
  module.exports.TextStream()
  module.exports.SomeErrors()
  module.exports.Many()
  module.exports.RedefineCallback()


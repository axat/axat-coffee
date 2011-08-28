keys = Object.keys


lex = require './lex'


exports.ParseError = class ParseError
  constructor: (@message) ->

exports.Tag = class Tag
  constructor: (@name) ->


table =
  ERROR:     'SyntaxError'
  IGNORE:    'Ignore'
  EMPTY:     'Ignore'
  Start:
    OPEN:    'Open'
    CLOSE:   'Start'
    EOT:     'End'
  Open:
    ID:      'Axiom'
  Axiom:
    OPEN:    'Open'
    CLOSE:   'Start'
    INTEGER: 'Axiom'
    DOUBLE:  'Axiom'
    STRING:  'Axiom'


###

Create a streaming parser. createParser expects a callback which receives tags,
literal values, false for closing axioms and a final null. After the null or
errors the parser is dead, but can reset. An interpreting callback uses the
tags to know which axiom is to be interpreted and false values when an axiom is
closed. createParser returns a streaming function which you pass chunks
(Strings or Buffers as parts of source code). If you receive an end of input
condition, pass STOP to the streaming function. For examples see tests.

@param {Function} cb Callback, for example an interpreting callback
@return {Funtion} Function which you pass source code chunks

A special feature is the streaming function's property getter and setter cb.
Use it to replace the callback in mid-parse. Also see tests for examples.

###
createParser = exports.createParser = (cb) ->
  dead = false
  depth = 1
  oldState = state = 'Start'

  createError = (msg) -> dead = true; new ParseError msg
  createParseError = (msg) -> createError 'Parse Error: ' + msg

  handlers =
    ParseError: (token)  -> cb createParseError 'expected ' \
      + keys(table[oldState] ? [undefined]).join(" ") + ' but had ' + token?.type
    SyntaxError: (token) -> cb createError 'Syntax Error'
    Ignore: (token)      -> state = oldState
    Open: (token)        -> depth++
    Start: (token)       ->
      cb if depth-- is 1 then createParseError 'unexpected CLOSE' else false
    End: (token)         ->
      dead = true
      cb if depth > 1 then createParseError 'unexpected EOT' else null
    Axiom: (token)       ->
      cb do (
        ID: -> new Tag token.value
        INTEGER: -> token.value | 0
        DOUBLE: -> +token.value
        STRING: -> token.value # todo convert
      )[token.type]

  parser = (token) ->
    type = token?.type
    oldState = state
    state = table[type] or table[state]?[type] or 'ParseError'
    #console.log type + ":", oldState, "->", state
    handlers[state] token

  stream = lex.createLexer (token) -> parser token if not dead

  # You can redefine the callback or reset the parser. For examples see tests.
  Object.defineProperties stream,
    cb:
      get: -> cb
      set: (newCb) -> cb = newCb if newCb?
    reset:
      get: -> -> dead = false; depth = 1; oldState = state = 'Start'


  # Return the streaming function
  stream


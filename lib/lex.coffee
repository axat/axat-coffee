keys = Object.keys


terminals = do () ->
  S =          "[\x20\n\r]"
  D =          "[0-9]"
  H =          "[0-9a-f-A-F]"
  EXP =        "(?:[eE]-?[0-9]+)"

  IGNORE:    ///^    #{S}+                                             ///
  OPEN:      ///^    \(                                                ///
  CLOSE:     ///^    \)                                                ///
  DOUBLE:    ///^    -? ( #{D}+ #{EXP} | #{D}* \. #{D}+ #{EXP}? )      ///
  INTEGER:   ///^    #{D}+                                             ///
  ID:        ///^    [a-zA-Z0-9_]+                                     ///
  STRING:    ///^    "
    (?:      [^"\\]                              # all chars except " and \ 
    |        \\                                  # start backslash escape
      (?:    ["\\nrts]                           # usual backslash sequences
      |      x #{H}{2}                           # \xff and the like
      |      u #{D}{4}                           # unicode escape 4 digits
      |      U ( 10 #{D}{4} | 0 #{D}{5} )        # unicode escape 6 digits
      |      \[ ( #{S}* #{D}{2} )* #{S}* \]      # hexadecimal byte array
      )
    )*
   "///
  EMPTY:     /^$/

tokenTypes = exports.tokenTypes = {}
tokenTypes.all        = keys(terminals).concat('EOT ERROR'.split ' ')
tokenTypes.stopping   = tokenTypes.all[-3..]
tokenTypes.active     = tokenTypes.all[1..-4]

createToken = exports.createToken = (tokenType, tokenValue) ->
  type: tokenType
  value: tokenValue ? ''

EOT   = exports.EOT   = createToken 'EOT'   # end of text
ERROR = exports.ERROR = createToken 'ERROR' # syntax error
STOP  = exports.STOP  = null                # passed into stream => EOT


###

Create a streaming lexer. createLexer expects a token-receiving callback (for
tokens see createToken() and returns a streaming function which you pass chunks
(Strings or Buffers as parts of source code). If you receive an end of input
condition, pass STOP to the streaming function. For examples see tests.

@param {Function} cb Token-receiving callback
@return {Funtion} Function which you pass source code chunks

A special feature is the streaming function's property getter and setter cb.
Use it to replace the callback in mid-lex. Also see tests for examples.

###
createLexer = exports.createLexer = (cb) ->
  data = ''

  consume = (n) ->
    [consumed, data] = [data.substring(0, n), data.substring n]
    consumed

  matchOneOfTheRegexes = ->
    (return lastToken = createToken tokenType, consume match[0].length \
      for tokenType, regex of terminals when match = regex.exec data)
    ERROR # None of the terminals matched ==> error.


  isStopping = (token) -> token?.type in tokenTypes.stopping

  stream = (chunk) ->
    return cb lastToken = EOT if chunk is STOP
    data += chunk
    cb lastToken = matchOneOfTheRegexes() while not isStopping lastToken

  # You can manage the callback. For examples see tests.
  Object.defineProperty stream, 'cb',
    get: -> cb
    set: (newCb) -> cb = newCb if newCb?
    configurable: true

  # Return the streaming function
  stream


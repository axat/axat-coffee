assert = require 'assert'
axat = require './axat'
inspect = require('util').inspect
ParseError = axat.parse.ParseError
Tag = axat.parse.Tag
Frame = axat.Frame
axioms = axat.axioms.axioms
nil = axat.axioms.nil

RED = '\x1b[31;1m'
GREEN = '\x1b[32;1m'
BLUE = '\x1b[34;1m'
GRAY = '\x1b[37;1m'
NORMAL = '\x1b[m'
W = console.log
E = (msg) -> console.log RED + msg + NORMAL; process.exit -1
I = (what, args) ->
  s = ''
  s += GRAY + k + ' ' + GREEN + (inspect v) + NORMAL + ' ' for k, v of args
  console.log BLUE + what + NORMAL, s

# Todo: delay must extract the relevant part of the frame stack
# force must also work correctly...
# and the top frame get lost somewhere...


exports.createInterpreter = ->
  env =
    frame: new Frame axioms.sequence
    lazy: undefined
    evaluate: ->
      axiom = @frame.axiom
      I 'evaluate', { axiom: axiom.tag, lazy: @lazy?.axiom.tag }

      if @lazy and @lazy isnt @frame
        @frame.link.lazy = @frame.lazy or @frame
        @frame = @frame.link
        I 'lazy', { lazy: @frame.lazy?.toString() }
      else
        result = axiom.implementation @
        if @push
          I 'push', { push: @push.toString() }
          @frame = @frame.link.push @push
          delete @push
        else if @overwrite
          I 'overwrite', { overwrite: @overwrite.toString() }
          @frame = @overwrite
          delete @overwrite
        else if @frame.link
          @frame.link.param = result
          @frame = @frame.link
          I 'eager', { result: @frame.param }
        else
          console.log "END", result
          env.ended = true

  interpret = (item) ->
    frame = env.frame
    assert.notEqual frame, null
    axiom = frame.axiom

    I 'interpret', {item: item, axiom: axiom.tag, lazy: env.lazy?.axiom.tag}
    W GRAY + 'frames', frame, NORMAL

    # End of image
    if item is null
      env.evaluate()
      interpret null unless env.ended

    # End of axiom
    else if item is false
      env.evaluate()

    # Parse error
    else if item.constructor is ParseError
      E item.message

    # Axiom arity check
    else if axiom.arity > -1 and frame.paramIndex > axiom.arity
      E "Axiom #{axiom.tag} takes #{axiom.arity} parameter(s)"

    # Start of axiom
    else if item.constructor is Tag
      unless item.name of axioms
        E "Unknown axiom #{item.name}"
      axiom = axioms[item.name]
      if frame.axiom.literal? and frame.axiom.literal isnt axiom.literal
        E "Axiom #{frame.axiom.tag} expects #{frame.axiom.literal} literal(s)"
      env.frame = new Frame axiom, frame
      env.lazy = env.lazy or if axiom.lazy then env.frame

    # Literal
    else if literal = getLiteralType item
      if axiom.literal isnt literal
        what = if axiom.literal?
          "takes only #{axiom.literal}"
        else
          "does not take"
        E "Axiom #{axiom.tag} #{what} literals"
      frame.params[++frame.paramIndex] = item

    # Should not happen
    else assert.ok false, 'Should not have happened'

  axat.parse.createParser interpret


exports.getLiteralType = getLiteralType = (item) ->
  if 'number' is typeof item then 'double'
  else if axat.i64r is item.__proto__ then 'integer'
  else if Buffer is item.__proto__ then 'buffer'
  else false


if require.main is module
  interpret = exports.createInterpreter()
  interpret '(print (force (print (delay (print (i 3))))))'
  interpret axat.lex.STOP



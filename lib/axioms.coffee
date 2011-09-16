exports.nil = nil = Object.freeze {}

exports.axioms = axioms =
  sequence: (env) ->
    last = env.frame.params.length - 1
    if last is -1 then nil else env.frame.params[last]

  nil: (env) -> nil

  print: (env) ->
    console.log env.frame.params[0].toString()
    env.frame.params[0]

  delay: (env) ->
    frame = env.frame.lazy
    frame = frame.link while frame.link? and frame.link isnt env.lazy
    delete frame.link
    delete env.lazy
    env.frame.lazy

  force: (env) ->
    if env.frame.params[0].isFrame
      env.push = env.frame.params[0]
    else
      env.frame.params[0]

  i: (env) -> env.frame.params[0]

  d: (env) -> env.frame.params[0]

  b: (env) -> env.frame.params[0]

  add: (env) ->
    env.frame.params[0].add env.frame.params[0], env.frame.params[1]


exports.types = types =
  nullary: 'nil'
  unary:   'print delay force i d b'
  binary:  'add'
  ternary: 'set'
  nary:    'sequence'
  lazy:    'delay'

types[type] = types[type].split /\s+/ for type of types

arities =
  nullary:  0
  unary:    1
  binary:   2
  ternary:  3
  nary:    -1

literalTypes =
  i: 'integer'
  d: 'double'
  b: 'buffer'

arity = (tag) ->
  return arities[arity] for arity of arities when tag in types[arity]

setTypes = (axiom, tag) ->
  axiom[type] = true for type of types when tag in types[type]
  undefined

define = (axiom, tag) ->
  axioms[tag] =
    implementation: axiom
    tag: tag
    arity: arity tag
  setTypes axioms[tag], tag
  axioms[tag].literal = literalTypes[tag] if tag of literalTypes

define axiom, tag for tag, axiom of axioms


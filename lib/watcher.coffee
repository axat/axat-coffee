# Needs node.js > 0.5.x of some x (because of Harmony Proxies)
# However Coffeescript is not completely compatible with 0.5.x
# because there are some require.paths uses in Coffeescript.

# The watcher proxy is nice: it writes all accesses as stack traces... Very
# illuminating how an object can be accessed.

# Todo: allow freeze() & Co. - now they throw TypeError, see comment below.


Object.defineProperty Object::, 'getPropertyDescriptor',
  value: (object, key) ->
    own = object
    while 'object' is typeof own
      descriptor = Object.getOwnPropertyDescriptor object, key
      return descriptor if descriptor isnt undefined
      own = Object.getPrototypeOf own
    undefined

Object.defineProperty Object::, 'getPropertyNames',
  value: (object) ->
    names = []
    own = object
    while 'object' is typeof own
      prototypeNames = Object.getOwnPropertyNames own
      names.push name for name of names when name not in names
      own = Object.getPrototypeOf own
    names

$ =
  $opd: 'getOwnPropertyDescriptor'
  $pd:  'getPropertyDescriptor'
  $opd: 'getOwnPropertyDescriptor'
  $opn: 'getOwnPropertyNames'
  $pn:  'getPropertyNames'
  $dp:  'defineProperty'
  $del: 'delete'
  $fx:  'fix'
  $h:   'has'
  $ho:  'hasOwn'
  $gt:  'get'
  $st:  'set'

red = '\x1b[31m'
green = '\x1b[32;1m'
blue = '\x1b[34;1m'
normal = '\x1b[0m'
stackTrace = (name, key) ->
  text = new Error().stack.replace /Error/, red + 'Watcher: ' + green + name +
    (if key is $ then '' else blue + ' key=' + key) + normal
  stack = text.split /\r?\n/
  [stack[0]].concat(stack.slice 4).join '\n'

# Define $.opd, etc. as debugger helpers. $.opd $ dumps the stack trace with
# 'getOwnPropertyDescriptor' and $.opd k also dumps the key.
(do (k, v) -> $[k.slice(1)] = (key) ->
  console.log stackTrace v, key
) for k, v of $

expandKeys = (map) ->
  result = {}
  result[$[k]] = map[k] for k of map
  result

module.exports.createWatcher = (object) ->
  module.exports.watcher = expandKeys {
    $opd:  (k) ->       $.opd k;  Object.getOwnPropertyDescriptor object, k
    $pd:   (k) ->       $.pd k;   Object.getPropertyDescriptor object, k
    $opn:  () ->        $.opn $;  Object.getOwnPropertyNames object
    $pn:   () ->        $.pn $;   Object.getPropertyNames object
    $dp:   (k, desc) -> $.dp k;   Object.defineProperty object, k, desc
    $del:  (k) ->       $.del $;  delete object[k]
    $fix:  () ->        $.fix $;  undefined   # ==> TypeError for freeze() etc.
    $h:    (k) ->       $.h k;    k of object
    $ho:   (k) ->       $.ho k;   ({}).hasOwnProperty.call object, k
    $gt:   (r, k) ->    $.gt k;   object[k]
    $st:   (r, k, v) -> $.st k;   object[k] = v
  }
  Proxy.create module.exports.watcher


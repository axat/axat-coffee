# Assumes that s has been correctly lexed. Will fail in undefined ways if there
# are illegal escapes. Only the most glaring illegal escapes are catched.
exports.unescape = (s) ->
  s = s.slice 1, -1
  result = []

  collect = (stuff) ->
    if typeof stuff is 'number' then result.push stuff
    else if typeof stuff is 'string' then collect toByteArray stuff
    else if Array.isArray then result.push stuff...
    else assert.ok false, 'collect did not understand stuff'

  while -1 isnt pos = s.indexOf '\\'
    collect s.slice 0, pos
    s = s.slice pos + 1

    inc = 1
    if      s[0] is 't'  then collect 0x09
    else if s[0] is 'n'  then collect 0x0a
    else if s[0] is 'r'  then collect 0x0d
    else if s[0] is 's'  then collect 0x20
    else if s[0] is '"'  then collect 0x22
    else if s[0] is '\\' then collect 0x5c
    else if s[0] is 'x'  then inc = 3; collect hexUnescape s.slice 1, 3
    else if s[0] is 'u'  then inc = 5; collect utf8Unescape s.slice 1, 5
    else if s[0] is 'U'  then inc = 7; collect utf8Unescape s.slice 1, 7
    else if s[0] is '['
      collect arrayUnescape s.slice 1, inc = s.indexOf ']'
      inc++
    else assert.ok false, 'illegal escape \\U+' + s.charCodeAt(0).toString 16
    s = s.slice inc

  collect s
  Buffer result


hexUnescape = (esc) ->
  parseInt esc, 16


# Do not use the unescape(encodeURITComponent(s)) trick, it does not work with
# astral planes. Ignore surrogates.
utf8Unescape = (esc) ->
  #console.log "*** esc", esc
  toUtf8 parseInt esc, 16

# Code point U+0 to U+10ffff to UTF8 (modified UTF8: U+0 as 0xc080)
toUtf8 = (c) ->
  #console.log "*** c", c
  if c == 0x00 then return [0xc0, 0x80]

  if c < 0x80 then return [0x00 | c]

  c0 = 0x80 | (c & 0x3f)
  c6 = c >> 6
  if c < 0x800 then return [0xc0 | c6, c0]

  c6 = 0x80 | (c6 & 0x3f)
  c12 = c >> 12
  if c < 0x10000 then return [0xe0 | c12, c6, c0]

  c12 = 0x80 | (c12 & 0x3f)
  c18 = c >> 18
  if c < 0x110000 then return [0xf0 | c18, c12, c6, c0]

  assert.ok false, 'illegal unicode code point U+' + c.toString 16


arrayUnescape = (esc) ->
  esc = esc.replace /\s/g, ''
  result = []
  while esc isnt ''
    hex = esc.slice 0, 2
    esc = esc.slice 2
    result.push parseInt hex, 16
  result


toByteArray = (s) ->
  result = []
  return result if s.length is 0
  result = result.concat toUtf8 s.charCodeAt i for i in [0 .. s.length - 1]
  result



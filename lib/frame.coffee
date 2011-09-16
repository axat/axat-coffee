module.exports = class Frame
  constructor: (@axiom, @link = null) ->
    @paramIndex = -1
    @params = []

Object.defineProperties Frame::
  inspect:
    value: -> [
        '\n\x1b[37;1m' + @depth + '\t(' + @axiom.tag
        if @params.length then ' ' + @params.join ' ' else ''
        if @paramIndex isnt -1 then ' #' + @paramIndex else ''
        ')'
        if @link? then @link.inspect() else '' # recursive inspect stack
      ].join ''

  depth:
    get: ->
      depth = 1
      frame = @
      depth++ while frame = frame.link
      depth

  toString:
    value: ->
      link = ''
      if @link?
         link = ',' + @link.axiom.tag
         if @link.link?
           link += ',' + @link.link.axiom.tag
           if @link.link.link?
             link += ',...'
      "[Frame##{@depth} #{@axiom.tag}#{link}]"

  isFrame:
    value: true

  push:
    value: (frame) ->
      link = frame
      link = link.link while link.link
      link.link = @
      frame

  param:
    get: -> @paramIndex + ":" + @params[@paramIndex]
    set: (param) -> @params[++@paramIndex] = param


(function() {
  var ParseError, Tag, createParser, i64, keys, lex, table;
  keys = Object.keys;
  lex = require('./lex');
  i64 = require('./i64');
  exports.ParseError = ParseError = (function() {
    function ParseError(message) {
      this.message = message;
    }
    return ParseError;
  })();
  exports.Tag = Tag = (function() {
    function Tag(name) {
      this.name = name;
    }
    return Tag;
  })();
  table = {
    ERROR: 'SyntaxError',
    IGNORE: 'Ignore',
    EMPTY: 'Ignore',
    Start: {
      OPEN: 'Open',
      CLOSE: 'Start',
      EOT: 'End'
    },
    Open: {
      ID: 'Axiom'
    },
    Axiom: {
      OPEN: 'Open',
      CLOSE: 'Start',
      INTEGER: 'Axiom',
      DOUBLE: 'Axiom',
      STRING: 'Axiom'
    }
  };
  /*
  
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
  
  */
  createParser = exports.createParser = function(cb) {
    var createError, createParseError, dead, depth, handlers, oldState, parser, state, stream;
    dead = false;
    depth = 1;
    oldState = state = 'Start';
    createError = function(msg) {
      dead = true;
      return new ParseError(msg);
    };
    createParseError = function(msg) {
      return createError('Parse Error: ' + msg);
    };
    handlers = {
      ParseError: function(token) {
        var _ref;
        return cb(createParseError('expected ' + keys((_ref = table[oldState]) != null ? _ref : [void 0]).join(" ") + ' but had ' + (token != null ? token.type : void 0)));
      },
      SyntaxError: function(token) {
        return cb(createError('Syntax Error'));
      },
      Ignore: function(token) {
        return state = oldState;
      },
      Open: function(token) {
        return depth++;
      },
      Start: function(token) {
        return cb(depth-- === 1 ? createParseError('unexpected CLOSE') : false);
      },
      End: function(token) {
        dead = true;
        return cb(depth > 1 ? createParseError('unexpected EOT') : null);
      },
      Axiom: function(token) {
        return cb({
          ID: function() {
            return new Tag(token.value);
          },
          INTEGER: function() {
            return i64r.atoll(new Buffer(8, token.value));
          },
          DOUBLE: function() {
            return +token.value;
          },
          STRING: function() {
            return token.value;
          }
        }[token.type]());
      }
    };
    parser = function(token) {
      var type, _ref;
      type = token != null ? token.type : void 0;
      oldState = state;
      state = table[type] || ((_ref = table[state]) != null ? _ref[type] : void 0) || 'ParseError';
      return handlers[state](token);
    };
    stream = lex.createLexer(function(token) {
      if (!dead) {
        return parser(token);
      }
    });
    Object.defineProperties(stream, {
      cb: {
        get: function() {
          return cb;
        },
        set: function(newCb) {
          if (newCb != null) {
            return cb = newCb;
          }
        }
      },
      reset: {
        get: function() {
          return function() {
            dead = false;
            depth = 1;
            return oldState = state = 'Start';
          };
        }
      }
    });
    return stream;
  };
}).call(this);

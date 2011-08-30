(function() {
  var EOT, ERROR, STOP, createLexer, createToken, keys, terminals, tokenTypes;
  var __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
  keys = Object.keys;
  terminals = (function() {
    var D, EXP, H, S;
    S = "[\x20\n\r]";
    D = "[0-9]";
    H = "[0-9a-f-A-F]";
    EXP = "(?:[eE]-?[0-9]+)";
    return {
      IGNORE: RegExp("^" + S + "+"),
      OPEN: /^\(/,
      CLOSE: /^\)/,
      DOUBLE: RegExp("^-?(" + D + "+" + EXP + "|" + D + "*\\." + D + "+" + EXP + "?)"),
      INTEGER: RegExp("^" + D + "+"),
      ID: /^[a-zA-Z0-9_]+/,
      STRING: RegExp("^\"(?:[^\"\\\\]|\\\\(?:[\"\\\\nrts]|x" + H + "{2}|u" + D + "{4}|U(10" + D + "{4}|0" + D + "{5})|\\[(" + S + "*" + D + "{2})*" + S + "*\\]))*\""),
      EMPTY: /^$/
    };
  })();
  tokenTypes = exports.tokenTypes = {};
  tokenTypes.all = keys(terminals).concat('EOT ERROR'.split(' '));
  tokenTypes.stopping = tokenTypes.all.slice(-3);
  tokenTypes.active = tokenTypes.all.slice(1, -3);
  createToken = exports.createToken = function(tokenType, tokenValue) {
    return {
      type: tokenType,
      value: tokenValue != null ? tokenValue : ''
    };
  };
  EOT = exports.EOT = createToken('EOT');
  ERROR = exports.ERROR = createToken('ERROR');
  STOP = exports.STOP = null;
  /*
  
  Create a streaming lexer. createLexer expects a token-receiving callback (for
  tokens see createToken() and returns a streaming function which you pass chunks
  (Strings or Buffers as parts of source code). If you receive an end of input
  condition, pass STOP to the streaming function. For examples see tests.
  
  @param {Function} cb Token-receiving callback
  @return {Funtion} Function which you pass source code chunks
  
  A special feature is the streaming function's property getter and setter cb.
  Use it to replace the callback in mid-lex. Also see tests for examples.
  
  */
  createLexer = exports.createLexer = function(cb) {
    var consume, data, isStopping, matchOneOfTheRegexes, stream;
    data = '';
    consume = function(n) {
      var consumed, _ref;
      _ref = [data.substring(0, n), data.substring(n)], consumed = _ref[0], data = _ref[1];
      return consumed;
    };
    matchOneOfTheRegexes = function() {
      var lastToken, match, regex, tokenType;
      for (tokenType in terminals) {
        regex = terminals[tokenType];
        if (match = regex.exec(data)) {
          return lastToken = createToken(tokenType, consume(match[0].length));
        }
      }
      return ERROR;
    };
    isStopping = function(token) {
      var _ref;
      return _ref = token != null ? token.type : void 0, __indexOf.call(tokenTypes.stopping, _ref) >= 0;
    };
    stream = function(chunk) {
      var lastToken, _results;
      if (chunk === STOP) {
        return cb(lastToken = EOT);
      }
      data += chunk;
      _results = [];
      while (!isStopping(lastToken)) {
        _results.push(cb(lastToken = matchOneOfTheRegexes()));
      }
      return _results;
    };
    Object.defineProperty(stream, 'cb', {
      get: function() {
        return cb;
      },
      set: function(newCb) {
        if (newCb != null) {
          return cb = newCb;
        }
      },
      configurable: true
    });
    return stream;
  };
}).call(this);

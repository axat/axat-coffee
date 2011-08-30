(function() {
  /*
  
  64 bit Integer for Axat.
  
  Javascript does not have a 64 bit integer. With a Node addon and Node Buffers
  for storage the functionality of the Axat Integer value type is replicated.
  Do not use any operators, not even the assign operator. Javascript does not
  have operator overloading. Assign does not work correctly because Axat Integer
  is a value type, but Javascript objects are reference types. Using the assign
  operator would have the same effect as the C++ reference operator (&).
  
  Most operations are in a Node addon because many 64 bit operations are
  
  */
  var i64;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  module.exports = i64 = (function() {
    var constructor;
    __extends(i64, Buffer);
    function i64() {
      i64.__super__.constructor.apply(this, arguments);
    }
    constructor = function() {
      i64.__super__.constructor.call(this, 8);
      if (arguments.length === 0) {
        return this.zero();
      } else if (arguments.length === 1) {
        return this.atoll(arguments[0]);
      } else {
        this.i32low(arguments[0]);
        return this.i32high(arguments[0]);
      }
    };
    return i64;
  })();
  i64.prototype.prototype = require('./i64r');
  i64.prototype.prototype.assign = function(src) {
    return src.copy(this);
  };
  i64.prototype.prototype.toString = function(src) {
    return this.lltoa();
  };
}).call(this);

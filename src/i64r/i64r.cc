#include <stdint.h>
#include <stdlib.h>
#include <v8.h>
#include <node.h>
#include <node_buffer.h>

#define NAME(s) do { \
  Local<Function> f##s = FunctionTemplate::New(s)->GetFunction(); \
  Persistent<String> n##s = Persistent<String>::New(String::NewSymbol(#s)); \
  f##s->SetName(n##s); \
  target->Set(n##s, f##s, DontDelete); \
} while(0)


using namespace v8;
using namespace node;

namespace i64r {
  class I64r {

    static inline size_t _bufferLength(Local<Value> v) {
      return Buffer::Length(Handle<Object>::Cast(v));
    }

    static inline char* _bufferData(Local<Value> v) {
      return Buffer::Data(Handle<Object>::Cast(v));
    }

    static inline bool _isBuffer(Local<Value> v) {
      if (!v->IsObject()) return false;

      return Buffer::HasInstance(v) && _bufferLength(v) >= 8;
    }

    static inline char* _asBytes(Local<Value> v) {
      return _isBuffer(v) ? _bufferData(v) : 0;
    }

    static inline int64_t* _asInt64(Local<Value> v) {
      return _isBuffer(v) ? reinterpret_cast<int64_t*>(_bufferData(v)) : 0;
    }

    static inline int32_t* _asInt32(Local<Value> v) {
      return _isBuffer(v) ? reinterpret_cast<int32_t*>(_bufferData(v)) : 0;
    }


    static Handle<Value> zero(const Arguments& args) {
      int64_t *p = _asInt64(args[0]);
      if (!p) return Null();

      *p = 0;

      return args[0];
    }


    static Handle<Value> atoll(const Arguments& args) {
      int64_t *p = _asInt64(args[0]);
      if (!p) return Null();

      String::Utf8Value s(args[1]);
      const char* sz = *s ? *s : "0";
      *p = ::atoll(sz);

      return args[0];
    }


    static Handle<Value> lltoa(const Arguments &args) {
      int64_t *p = _asInt64(args[0]);
      if (!p) return Null();

      char buf[30];
      snprintf(buf, 30, "%lld", *p);

      return String::New(buf);
    }


    static Handle<Value> i32low(const Arguments &args) {
      int32_t* p = _asInt32(args[0]);
      if (!p) return Null();

      p[0] = (int32_t)args[1]->ToInt32()->Value();

      return args[0];
    }


    static Handle<Value> i32high(const Arguments &args) {
      int32_t* p = _asInt32(args[0]);
      if (!p) return Null();

      p[1] = args[1]->ToInt32()->Value();

      return args[0];
    }


    // Todo try the curiously recurring pattern
    static Handle<Value> add(const Arguments &args) {
      int64_t *result = _asInt64(args[0]);
      int64_t *a1 = _asInt64(args[1]);
      int64_t *a2 = _asInt64(args[2]);
      if (!result || !a1 || !a2) return Null();

      *result = *a1 + *a2;

      return args[0];
    }



  public:
    static void Init(Handle<Object> target) {
      HandleScope scope;

      NAME(zero);
      NAME(atoll);
      NAME(lltoa);
      NAME(i32low);
      NAME(i32high);
      NAME(add);
    }
  };
}


extern "C" void init(Handle<Object> target) {
  i64r::I64r::Init(target);
}


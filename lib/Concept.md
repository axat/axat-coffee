# Eval apply cycle with continuations

## Terminology Callable / Frame / Promise

A callable is something which can be forced or invoked. This is a frame stack
which suddenly gets used as a value or parameter in an axiom or a frame. CallCC
for example copies the current frame stack and returns it as a parameter. These
values are also called promises. A promise is unevaluated code, that means a
frame stack ready to be evaluated. In short, a callable, a promise and a frame
stack are the same thing. When it is forced, it is copied onto the current
stack and then evaluated. When it is invoked, it replaces the current stack.

So, what is the difference?

- A frame stack is an implementation detail. Whenever I discuss how frames,
  axioms and parameters are organized, I use the term frame stack.
- A promise is a value which can be forced or invoked. It is a frame stack but
  this is a detail. Important is only that it is passed as a parameter and that
  it can be forced or invoked.
- A callable is the high-level Axat concept of a value used to define functions
  and continuations.

They all are really the same thing but it is the aspect which is different.

## Definitions
- A continuation is a frame stack waiting to be evaluated.
- A complication is that the frame stack is not yet completely populated, when
  the eval-apply-cycle starts.
- A frame is an axiom with its partially evaluated arguments.
- Evaluated arguments are Axat values: integer, double, buffer, table, etc.
- An empty frame stack is the finis continuation: the end of the program.
- Frames are chained downwards.
- Functions are invoked with predefined scopes. A return value is a
  continuation capturing the running state of just being returned from the
  function. To return from the function, invoke the return value.

## Eval
- Scope corresponds to the activation object of Javascript
- Next is the continuation to be invoked after evaluation of current frame
- Item is passed from the parser, one of:
  - End is the end marker, that means there are no more items
  - Close means that the current axiom is now to be evaluated
  - ParseError is the error passed from the parser
  - Tag is the axiom tag
  - Literal is an integer, double or buffer literal
- Algorithm:
  - Item is passed to Eval()
  - Item is End: Do nothing
  - Item is Tag: Create new frame and push.
  - Item is Close:
    - Eager: Evaluate current axiom. For a non-control axiom remove top frame,
      replace the n-th parameter with result and increment parameter index. For
      a control axiom the new frame is the result.
    - Lazy: Add the current frame to the promise or create a new promise.
      Remove top frame, replace the n-th parameter with result and increment
      parameter index, as for eager non-control axioms.

## Some operations
- Print:
  - Print parameter 0 and return it
- Sequence:
  - Return last parameter
- Nil:
  - Return nil
- Scope:
  - Return current scope
- Delay:
  - Turn on lazy
- Force:
  - If parameter 0 is a promise, stack it on the current frame and evaluate.
  - Else return parameter 0.
- CallCC:
  - Copy current frame stack and return it as a promise.
    (problem how to use callcc for function return continuations?)
- Invoke:
  - If parameter 0 is a promise:
    - Next := parameter 0
    - Scope := parameter 1
  - else return parameter 0


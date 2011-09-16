# Axat Programming Language over CoffeeScript

Cryptic and occult lispy and operator-precedency programming language concepts.
Not really for public use.

Because I am a cheapskate I am not using a private repository. I just hope that
this little hobby programming language does not attract too much attention.
Really. I am not ready to discuss design decisions, deal with posted issues and
accept pull requests. In short, I am a MDFL about a most irrelevant realm.

I freely admit I am not without ego. I also realize you are free to take these
meek words with a grain of salt. You are also free to fork or not to fork, as
always.

## The name

- Inspired by Perl and Ruby. Agate is a gem stone.
- I prefer a name which is far ahead in the alphabet.
- Also inspired by LaTeX. Pronounce x like ch in Loch Ness.
- Agate in Modern Greek is αχάτη.
- Incidentally pronounced same as Agate in German («Achat»).
- Uses something I call «axioms». It is nice that Axat and axioms start with
  the same two letters.

## What is special?

- Freeform programmable operator syntax with a lispy soul
- Bytecode and s-expression hybrid as binary storage (so called axioms)
- Mutability and other metadata (like Ecmascript properties)
- Continuations
- Objects (not ab initio, but built upon a core data type, the table)

## Downsides

- No standard syntax since everybody can develop an operator database
- Performance
- Vaporware
- Implementation in Javascript difficult because Javascript does not have
  continuations and tail calls and 64 bit integers neither.

## Concept ramblings

- Lexer to recognize integer, number, string literals; separators, identifiers
(sequences of printable characters not a separator, literals nor white space),
white space, indent and dedent. Only printable characters (i. e. a character
must produce at least a speck of ink when printed) are allowed, and also
additionally space, linefeed and carriage return.

- Programmable operator database to parse the token stream to a lispy form. The
parser treats non-literals like identifiers, that means, a separator or a space
is just a special name. The parser is inspired by the paper «Top Down Operator
Precedence» by Vaughan R. Pratt at Massachusetts Institute of Technology 1974.

- The lispy form is evaluated eagerly using definitions in the current scope
(i. e. a table, see below) - this is the compilation phase. The result is
another lispy form: the low level axiom form. The axioms are saved in a binary
form and are interpreted later. The axiom image is a hybrid between byte-code
and lisp s-expressions.

- Axat knows three processing times: compile time, running time and evaluation
time. Lazy evaluation is possible through encapsulation of the delay axiom.

- The core data types are: table (like Lua tables or JavaScript array), buffer
(like Node.js buffer), symbol, integer (64 bit), double, callable (more or less
just continuations) and void (with the sole value nil).

- Axat defines metadata: is a value hidden, replaceable, resizable and/or
mutable? Not all metadata combinations make sense for all types, for example
void, symbol and callable are always immutable. Also: only tables and buffers
can change their size and therefore be true for metadata «resizable».

- All Values are reachable directly and indirectly from an image root table.

- Scopes and objects are tables. Lookups delegate only one level deep. That
means closure lookups stop at the outer scope and class lookups at the object's
class. This limitation is not really a limitation, because deeper lookups can
be replaced by copying of values.

- Objects can overload some axioms.

- Buffer and Table are reference types. Copying means shallow cloning. All
other values are independently copied.

- The string is an object which uses a buffer whose bytes are the utf-8
encoding of the string.

- Compilable to C with the help of a core type and garbage collection library.
Type und metadata is saved in a byte tag in the table for the entry (except for
reference types which carry their own resizability and mutability metadata).


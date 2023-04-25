# Catan Backend Logic

The state of the game is summarized in a Lua table whose schema is specified in `schema.lua`.
This file uses an internal library for defining structs, enums, arrays, optionals and mappings.
As an user of the library, you can abstract the inner workings of the `schema` library entirely.
You can infer the semantics of most of these constructions from mainstream programming languages.

# Settlers of Catan implemented in Lua

## Dependencies

For end-users and developers:

* [Lua] 5.4

For developers:

* [Serpent] 0.30-2
* [LDoc] 1.4.6

If you have [LuaRocks] on your machine, you can run the following command.

```sh
luarocks install serpent ldoc
```

## Documentation

Please make sure you have [LDoc] installed on your machine. Then, run the following command on the root of this repository:

```sh
ldoc .
```

This should load the configurations from the `config.ld` file. You can tinker with the configuration however you like.

[Lua]: https://www.lua.org/
[Serpent]: https://luarocks.org/modules/paulclinger/serpent
[LDoc]: https://stevedonovan.github.io/ldoc/
[LuaRocks]: https://luarocks.org/

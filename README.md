# Settlers of Catan implemented in Lua

## Dependencies

For end-users and developers:

* [Lua] 5.4
* [LÖVE] 11.4

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

## User Resources

* [Catan 5th Edition Base Rules (2020)](https://www.catan.com/sites/default/files/2021-06/catan_base_rules_2020_200707.pdf)

## Developer Resources

* [Article "Hexagonal Grids" by Red Blob Games (2021)](https://www.redblobgames.com/grids/hexagons)
* [Article "Grid parts and relationships" by Red Blob Games (2021)](https://www.redblobgames.com/grids/parts/)
* [Article "Amit's Thoughts on Grids" by Amit Patel (2006)](http://www-cs-students.stanford.edu/~amitp/game-programming/grids/)

[Lua]: https://www.lua.org/
[LÖVE]: https://love2d.org/
[Serpent]: https://luarocks.org/modules/paulclinger/serpent
[LDoc]: https://stevedonovan.github.io/ldoc/
[LuaRocks]: https://luarocks.org/

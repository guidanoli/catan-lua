# Settlers of Catan implemented in Lua

## Dependencies

For users:

* [LÖVE] 11.4
* [Serpent] 0.30-2

For developers:

* [Lua] 5.4
* [GNU Make] 4.3
* [LDoc] 1.5.0-1
* [argparse] 0.7.1-1
* [LuaCov] 0.15.0-1
* [LuaCov-HTML] 1.0.0-1

If you have [LuaRocks] on your machine, you can install the Lua modules with the following command.

```sh
luarocks install serpent 0.30-2
luarocks install ldoc 1.5.0-1
luarocks install argparse 0.7.1-1
luarocks install luacov 0.15.0-1
luarocks install luacov-html 1.0.0-1
```

## Tests

The tests reside in the `test/` folder, and can be run with the following command. Make sure you have all the developer dependencies installed!

```
make test
```

If you want to check the test coverage, you may want to run the following command.

```
make luacov
```

This will create an HTML page on the `luacov-html/` directory, so you can more easily inspect the coverage report.
Feel free to change value of `--ncalls` and `--ngames` in the `FUZZYOPT` variable in the `Makefile` if you wish to have a more thorough coverage on the `catan` module.
You can also remove any output from the test coverage suite by running...

```
make clean
```

## Documentation

### Deployment

You can see the latest version of the documentation [here](https://guidanoli.github.io/catan-lua/).

### Local

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
[LDoc]: https://luarocks.org/modules/lunarmodules/ldoc
[LuaRocks]: https://luarocks.org/
[argparse]: https://luarocks.org/modules/argparse/argparse
[LuaCov]: https://luarocks.org/modules/hisham/luacov
[LuaCov-HTML]: https://luarocks.org/modules/wesen1/luacov-html
[GNU Make]: https://www.gnu.org/software/make/

# Settlers of Catan implemented in Lua

LuaCatan is an implementation of the famous board game "Settlers of Catan" in Lua.
This repository is divided into the following directories:

* `catan`: Lua modules for the back-end and front-end of the application
* `images`: Images used by the front-end
* `layers`: GIMP project files for the images used by the front-end
* `style`: CSS stylesheets for the HTML version of the documentation
* `test`: Tests for the Lua modules
* `util`: Lua modules for utilities used in `catan`

## User Dependencies

* [LÖVE](https://love2d.org/) 11.4
* [Serpent](https://luarocks.org/modules/paulclinger/serpent) 0.30-2

If you have [LuaRocks](https://luarocks.org/) on your machine, you can install Serpent with the following command.

```sh
luarocks install serpent 0.30-2
```

## Tutorial

Please consult the `TUTORIAL.md` file.

## Developer Dependencies

* [GNU Make](https://www.gnu.org/software/make/) 4.3
* [Lua](https://www.lua.org/) 5.4
* [LDoc](https://luarocks.org/modules/lunarmodules/ldoc) 1.5.0-1
* [argparse](https://luarocks.org/modules/argparse/argparse) 0.7.1-1
* [LuaCov](https://luarocks.org/modules/hisham/luacov) 0.15.0-1
* [LuaCov-HTML](https://luarocks.org/modules/wesen1/luacov-html) 1.0.0-1

If you have [LuaRocks](https://luarocks.org/) on your machine, you can install the Lua modules above with the following commands.

```sh
luarocks install ldoc 1.5.0-1
luarocks install argparse 0.7.1-1
luarocks install luacov 0.15.0-1
luarocks install luacov-html 1.0.0-1
```

## Tests

The tests reside in the `test/` folder, and can be run with the following command.

```
make test
```

If you want to check the test coverage, you may want to run the following command.

```
make test-coverage
```

This will generate a stats report. You may want an HTML page, so you can more easily inspect the coverage report. Simply run this command.

```
make html-coverage-report
```

You can also remove any output from the test coverage suite by running...

```
make clean
```

## Documentation

### Hosted

You can see the latest version of the documentation [here](https://guidanoli.github.io/catan-lua/).

### Local

You can also build the documentation locally by running the following command.

```sh
make docs
```

This should load the configurations from the `config.ld` file. You can tinker with the configuration however you like.

## User Resources

* [Catan 5th Edition Base Rules (2020)](https://www.catan.com/sites/default/files/2021-06/catan_base_rules_2020_200707.pdf)

## Developer Resources

* [Article "Hexagonal Grids" by Red Blob Games (2021)](https://www.redblobgames.com/grids/hexagons)
* [Article "Grid parts and relationships" by Red Blob Games (2021)](https://www.redblobgames.com/grids/parts/)
* [Article "Amit's Thoughts on Grids" by Amit Patel (2006)](http://www-cs-students.stanford.edu/~amitp/game-programming/grids/)

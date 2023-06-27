.PHONY: test test-utils test-catan test-coverage html-coverage-report docs clean

test-utils:
	lua $(LUAOPT) test/util/safe.lua
	EMULATE_LUA_51=yes lua $(LUAOPT) test/util/safe.lua
	lua $(LUAOPT) test/util/platform.lua
	lua $(LUAOPT) test/util/schema.lua
	lua $(LUAOPT) test/util/table.lua

test-catan:
	lua $(LUAOPT) test/catan/logic/grid.lua
	lua $(LUAOPT) test/catan/logic/constants.lua
	lua $(LUAOPT) test/catan/logic/game.lua
	lua $(LUAOPT) test/catan/logic/fuzzy.lua -vv --ncalls 100
	lua $(LUAOPT) test/catan/logic/fuzzy.lua -v --state-file test/catan/states/emptyBank.lua --ngames 100 --ncalls 5
	lua $(LUAOPT) test/catan/logic/fuzzy.lua -v --state-file test/catan/states/maximalRoadNetwork.lua --ngames 100 --ncalls 5
	lua $(LUAOPT) test/catan/logic/fuzzy.lua -v

test: test-utils test-catan

test-coverage: LUAOPT=-lluacov
test-coverage: test

html-coverage-report:
	luacov util/ catan/

docs:
	ldoc .

clean:
	rm -f luacov.*
	rm -rf luacov-html

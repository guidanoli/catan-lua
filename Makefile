.PHONY: test test-utils test-catan luacov clean

test-utils:
	lua $(LUAOPT) test/util/safe.lua
	EMULATE_LUA_51=yes lua $(LUAOPT) test/util/safe.lua
	lua $(LUAOPT) test/util/platform.lua
	lua $(LUAOPT) test/util/schema.lua
	lua $(LUAOPT) test/util/table.lua

test-catan:
	lua $(LUAOPT) test/catan/logic/game.lua
	lua $(LUAOPT) test/catan/logic/fuzzy.lua -v --ncalls 2000

test: test-utils test-catan

luacov:
	luacov util/ catan/

clean:
	rm -f luacov.*
	rm -rf luacov-html

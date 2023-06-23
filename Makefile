.PHONY: test test-with-luacov run-luacov luacov clean

test:
	lua $(LUAOPT) test/util/safe.lua
	EMULATE_LUA_51=yes lua $(LUAOPT) test/util/safe.lua
	lua $(LUAOPT) test/util/platform.lua
	lua $(LUAOPT) test/util/schema.lua
	lua $(LUAOPT) test/util/table.lua
	lua $(LUAOPT) test/catan/logic/game.lua
	lua $(LUAOPT) test/catan/logic/fuzzy.lua -v --ncalls 2000

test-with-luacov: LUAOPT=-lluacov
test-with-luacov: test

run-luacov:
	luacov util/ catan/

luacov: test-with-luacov run-luacov

clean:
	rm -f luacov.*

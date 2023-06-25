.PHONY: test test-utils test-catan test-coverage html-coverage-report docs clean

test-utils:
	lua $(LUAOPT) test/util/safe.lua
	EMULATE_LUA_51=yes lua $(LUAOPT) test/util/safe.lua
	lua $(LUAOPT) test/util/platform.lua
	lua $(LUAOPT) test/util/schema.lua
	lua $(LUAOPT) test/util/semver.lua
	lua $(LUAOPT) test/util/table.lua

test-catan:
	lua $(LUAOPT) test/catan/logic/game.lua
	lua test/catan/logic/fuzzy.lua -v --ngames 10 --validate
	lua -lluacov test/catan/logic/fuzzy.lua -v

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

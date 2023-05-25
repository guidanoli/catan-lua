docs:
	ldoc -c config.lua .

run:
	love .

.PHONY: docs run

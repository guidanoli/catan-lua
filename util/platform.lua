---
-- Defines platform-specific constants.
--
-- @module util.platform

local platform = {}

---
-- Path separator
platform.PATH_SEPARATOR = package.config:sub(1, 1)

return platform

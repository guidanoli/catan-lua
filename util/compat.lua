---
-- Creates a compatibility layer for Lua 5.1
--
-- Defines the following variables:
--
-- * `table.unpack` (from `unpack`)
--
-- @module util.compat

table.unpack = table.unpack or unpack

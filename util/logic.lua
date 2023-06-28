---
-- Propositional logic operations.
--
-- @module util.logic

local LogicUtils = {}

---
-- Get truth value of `x`.
-- @param x
-- @treturn boolean truth value of `x`
function LogicUtils:tobool (x)
    return not not x
end

---
-- Material implication `a -> b`
-- @tparam boolean a
-- @tparam boolean b
-- @treturn boolean `a -> b`
function LogicUtils:implies (a, b)
    return not self:tobool(a) or self:tobool(b)
end

---
-- Logical equivalence `a <-> b`
-- @tparam boolean a
-- @tparam boolean b
-- @treturn boolean `a <-> b`
function LogicUtils:iff (a, b)
    local a = self:tobool(a)
    local b = self:tobool(b)
    return a and b or not b
end

return LogicUtils

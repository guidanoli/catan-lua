---
-- Semantic version
--
-- @module util.semver

local Class = require "util.class"

local SemanticVersion = Class "SemanticVersion"

function SemanticVersion:new (major, minor, patch)
    return self:__new{
        major = major or 0,
        minor = minor or 0,
        patch = patch or 0,
    }
end

function SemanticVersion:tostring ()
    return self.major .. '.' .. self.minor .. '.' .. self.patch
end

function SemanticVersion:compatibleWith (other)
    return self.major == other.major
end

return SemanticVersion

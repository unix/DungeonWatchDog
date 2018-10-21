local ADDON_NAME = GetAddOnMetadata(..., 'Title')
local addon = LibStub('AceAddon-3.0'):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
local Utils = addon:NewModule('Utils')

function Utils:encode(s)
    local next = string.gsub(s, "([^%w%.%- ])", function(c) 
        return string.format("%%%02X", string.byte(c)) 
    end)
    return string.gsub(next, " ", "+") 
end

function Utils:decode(s)
    local next = string.gsub(s, '%%(%x%x)', function(h) 
        return string.char(tonumber(h, 16)) 
    end)
    return next
end

function Utils:split(str, reps)
    local next = {}
    string.gsub(str, '[^'..reps..']+', function(w)
        table.insert(next,w)
    end)
    return next
end

function Utils:tableLength(t)
    if not t then return 0 end
    local count = 0
    for _, _ in pairs(t) do 
        count = count + 1
    end
    return count
end


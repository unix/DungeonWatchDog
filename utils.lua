local INFO = WATCHDOG_VARS.INFOS
local L = LibStub("AceLocale-3.0"):GetLocale(INFO.ADDON_BASE_NAME, false)
local utils = {}

utils.encode = function(s)
    local next = string.gsub(s, "([^%w%.%- ])", function(c) 
        return string.format("%%%02X", string.byte(c)) 
    end)
    return string.gsub(next, " ", "+") 
end

utils.decode = function(s)
    local next = string.gsub(s, '%%(%x%x)', function(h) 
        return string.char(tonumber(h, 16)) 
    end)
   return next
end

utils.split = function(str, reps)
    local next = {}
    string.gsub(str, '[^'..reps..']+', function(w)
        table.insert(next,w)
    end)
    return next
end







Utils = utils



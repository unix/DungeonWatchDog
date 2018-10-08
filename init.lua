local addon = LibStub('AceAddon-3.0'):NewAddon('DungeonWatchDog')
local Init = addon:NewModule('Init')

function Init:vars()
    if not WATCHDOG_VARS then WATCHDOG_VARS = {} end
    if not _G then _G = {} end
end

function Init:DB()
    if not WATCHDOG_DB then WATCHDOG_DB = {} end
    if not WATCHDOG_DB.players then WATCHDOG_DB.players = {} end
end

function Init:new()
    self:vars()
    self:DB()
end



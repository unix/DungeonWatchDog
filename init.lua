local ADDON_NAME = GetAddOnMetadata(..., 'Title')
local addon = LibStub('AceAddon-3.0'):NewAddon(ADDON_NAME)
local Init = addon:NewModule('Init')

function Init:vars()
    if not WATCHDOG_VARS then WATCHDOG_VARS = {} end
    if not _G then _G = {} end
end

function Init:DB()
    if not WATCHDOG_DB then WATCHDOG_DB = {} end
    if not WATCHDOG_DB.players then WATCHDOG_DB.players = {} end
    if WATCHDOG_DB.defaultFilterToggle == nil then 
        WATCHDOG_DB.defaultFilterToggle = true
    end
    if WATCHDOG_DB.versionMessageToggle == nil then 
        WATCHDOG_DB.versionMessageToggle = true
    end
end

function Init:OnInitialize()
    self:vars()
    self:DB()
end



local ADDON_NAME = GetAddOnMetadata(..., 'Title')
local addon = LibStub('AceAddon-3.0'):NewAddon(ADDON_NAME, 'AceEvent-3.0')
local Init = addon:NewModule('Init')

function Init:getDefaultSettings()
    return {
        version = 7,
        players = {},
        defaultFilterToggle = true,
        versionMessageToggle = true,
        shareToggle = true,
        shareGuildToggle = true,
        shareLimit = 500,
        ignoreTimeLimit = 259200,
    }
end

function Init:vars()
    if not WATCHDOG_VARS then WATCHDOG_VARS = {} end
    if not _G then _G = {} end
end

function Init:DB()
    if not WATCHDOG_DB then WATCHDOG_DB = {} end
    local requireUpgrade = not WATCHDOG_DB.version or WATCHDOG_DB.version < self.DEFAULT_SETTINGS.version
    for k, v in pairs(self.DEFAULT_SETTINGS) do
        -- mandatory upgrade, do not modify ignore list
        if requireUpgrade then
            if  k ~= 'players' then
                WATCHDOG_DB[k] = v
            end
        else
            if WATCHDOG_DB[k] == nil then
                WATCHDOG_DB[k] = v
            end
        end
    end
    if not WATCHDOG_DB.players then WATCHDOG_DB.players = {} end
end

function Init:OnInitialize()
    self.DEFAULT_SETTINGS = self:getDefaultSettings()
    self:vars()
    self:DB()
end



local ADDON_NAME = GetAddOnMetadata(..., 'Title')
local addon = LibStub('AceAddon-3.0'):GetAddon(ADDON_NAME)
local AceComm = LibStub('AceComm-3.0')
local L = LibStub('AceLocale-3.0'):GetLocale(ADDON_NAME, false)
local Share = addon:NewModule('Share', 'AceEvent-3.0')
local infos = addon:GetModule('Constants'):GetInfos()
local Utils = addon:GetModule('Utils')
local Actions = addon:GetModule('Actions')


function Share:OnInitialize()
    self:RegisterMessage('NETWORKS_CONNECTION_CREATION', 'OnConnectionCreation')

    if not WATCHDOG_DB.shareToggle then return end
    
    self.friends = {}
    self.BNCount = 0
    self.SocialCount = 0
    self.ignoreCount = Utils:tableLength(WATCHDOG_DB.players)
    self.faction = UnitFactionGroup('player')

    self:checkIgnoreCount()
    self:updateBNCount()
    self:updateBNNames()
    self:updateSocialNames()
    self:updateIgnoreList()
end

function Share:checkIgnoreCount()
    if not WATCHDOG_DB.shareToggle then return end
    if self.ignoreCount < WATCHDOG_DB.shareLimit then return end
    Actions:log(string.format(L.SHARE_IGNORE_LIMIT, WATCHDOG_DB.shareLimit))
end

function Share:updateBNCount()
    self.BNCount = BNGetNumFriends()
    local _, online = GetNumFriends()
    self.SocialCount = online
end

function Share:updateBNNames()
    local updateHandle = function(friend)
        if friend[3] ~= 'WoW' then return end
        if friend[6] ~= self.faction then return end

        if friend[2] then
            local name = friend[2]..'-'..friend[4]
            self.friends[name] = 1
        end
    end

    local accounts = 0
    for i = 1, self.BNCount do
        accounts = BNGetNumFriendGameAccounts(i)
        if accounts ~= 0 then
            for k = 1, accounts do
                updateHandle({ BNGetFriendGameAccountInfo(i, k) })
            end
        end
        accounts = 0
    end
end

function Share:updateSocialNames()
    local realm = '-'..GetRealmName()
    for i = 1, self.SocialCount do
        local name, _, _, _, isOnline = GetFriendInfo(i)
        if name and isOnline then
            self.friends[name..realm] = 1
        end
    end
end

function Share:updateIgnoreList()
    for name, v in pairs(self.friends) do
        if name and name ~= '' then
            self:sendIgnoreList(name)
        end
    end
end

function Share:sendIgnoreList(name, once)
    if not WATCHDOG_DB.shareToggle then return end
    if self.ignoreCount > WATCHDOG_DB.shareLimit then return end

    local str = Actions:ExportSettings()
    local type = (once and infos.ADDON_COMM_IGNORE_SHARE_ONCE) or infos.ADDON_COMM_IGNORE_SHARE
    if not str or str == '' then str = infos.DEFAULT_EXPORT_SEP end
    AceComm:SendCommMessage(type, Utils:encodeCommMessages(str), 'WHISPER', name)
end

function Share:OnConnectionCreation(e, text, once)
    if not WATCHDOG_DB.shareToggle then return end
    if self.ignoreCount > WATCHDOG_DB.shareLimit then return end
    local name, version, content = Utils:decodeCommMessages(text)
    if not name then return end

    Actions:importSettings(content, true)
    self:updateShareCount()
    
    if not once then
        self:sendIgnoreList(name, true)
    end
end

function Share:updateShareCount()
    local t = time()
    if not WATCHDOG_DB.shareCountTime then 
        WATCHDOG_DB.shareCountTime = t
    end
    if (t - WATCHDOG_DB.shareCountTime) > WATCHDOG_DB.shareCountTimeLimit then
        WATCHDOG_DB.shareCountTime = t
        WATCHDOG_DB.shareCount = 0
    end

    WATCHDOG_DB.shareCount = WATCHDOG_DB.shareCount + 1
end

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

    ChatFrame_AddMessageEventFilter('CHAT_MSG_SYSTEM', function(_, _, msg)
        if self:isUnkownMessage(msg) then return true end
        return false
    end)
end

function Share:init()
    if not WATCHDOG_DB.shareToggle then return end
    
    self.friends = {}
    self.BNCount = 0
    self.socialCount = 0
    self.shareCount = 0
    self.ignoreCount = Utils:tableLength(WATCHDOG_DB.players)
    self.faction = UnitFactionGroup('player')

    self:checkIgnoreCount()
    self:updateBNCount()
    self:updateBNNames()
    self:updateSocialNames()
    if WATCHDOG_DB.shareGuildToggle then
        self:sendIgnoreListToGuild()
    end
end

function Share:checkIgnoreCount()
    if not WATCHDOG_DB.shareToggle then return end
    if self.ignoreCount < WATCHDOG_DB.shareLimit then return end
    Actions:log(string.format(L.SHARE_IGNORE_LIMIT, WATCHDOG_DB.shareLimit))
end

function Share:updateBNCount()
    self.BNCount = BNGetNumFriends()
    local _, online = GetNumFriends()
    self.socialCount = online
end

function Share:updateBNNames()
    local updateHandle = function(friend)
        if friend[3] ~= 'WoW' then return end
        if friend[6] ~= self.faction then return end

        -- sometimes there are deplays in BN, name and realm must be checked.
        if Utils:notEmptyStr(friend[2], friend[4]) then
            local name = friend[2]..'-'..friend[4]

            -- update only once.
            if not self.friends[name] then 
                self:sendIgnoreList(name)
                self.friends[name] = 1
            end
        end
    end

    local accounts = 0
    for i = 1, self.BNCount do
        accounts = BNGetNumFriendGameAccounts(i)
        if accounts and accounts ~= 0 then
            for k = 1, accounts do
                updateHandle({ BNGetFriendGameAccountInfo(i, k) })
            end
        end
        accounts = 0
    end
end

function Share:updateSocialNames()
    local realm = '-'..GetRealmName()
    for i = 1, self.socialCount do
        local name, _, _, _, isOnline = GetFriendInfo(i)
        if isOnline and Utils:notEmptyStr(name) then
            local full = name..realm
            if Utils:notEmptyStr(full) and not self.friends[full] then
                self:sendIgnoreList(full)
                self.friends[full] = 1
            end
        end
    end
end

function Share:sendIgnoreList(name, once)
    if not WATCHDOG_DB.shareToggle then return end
    if self.ignoreCount > WATCHDOG_DB.shareLimit then return end
    if self:isUnkownPlayer(name) then return end

    local str = (once and Actions:ExportSettings()) or ''
    local type = (once and infos.ADDON_COMM_IGNORE_SHARE_ONCE) or infos.ADDON_COMM_IGNORE_SHARE
    if not Utils:notEmptyStr(str) then str = infos.DEFAULT_EXPORT_SEP end
    AceComm:SendCommMessage(type, Utils:encodeCommMessages(str), 'WHISPER', name)
end

function Share:sendIgnoreListToGuild()
    if not WATCHDOG_DB.shareToggle then return end
    if not WATCHDOG_DB.shareGuildToggle then return end
    if self.ignoreCount > WATCHDOG_DB.shareLimit then return end
    AceComm:SendCommMessage(infos.ADDON_COMM_IGNORE_SHARE, Utils:encodeCommMessages(infos.DEFAULT_EXPORT_SEP), 'GUILD')
end

function Share:OnConnectionCreation(e, text, once)
    if not WATCHDOG_DB.shareToggle then return end
    if self.ignoreCount > WATCHDOG_DB.shareLimit then return end
    local name, version, content = Utils:decodeCommMessages(text)
    if self:isUnkownPlayer(name) then return end

    Actions:importSettings(content, true)
    self:updateShareCount()
    
    if not once then
        self:sendIgnoreList(name, true)
    end
end

function Share:updateShareCount()
    self.shareCount = self.shareCount + 1
end

function Share:getShareCount()
    return self.shareCount or 0
end

function Share:isUnkownPlayer(name)
    if not name or name == '' then return true end
    if string.find(name, '未知') then return true end
    if string.find(name, 'Unkown') then return true end
    if not self.username then 
        self.username = UnitName('player')
    end
    if string.find(name, self.username) then return true end
    return false
end

function Share:isUnkownMessage(msg)
    if not msg or msg == '' then return false end
    if string.find(msg, '未找到名') then return true end
    if string.find(msg, 'No player named') then return true end
    return false
end

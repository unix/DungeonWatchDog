local ADDON_NAME = GetAddOnMetadata(..., 'Title')
local AceComm = LibStub("AceComm-3.0")
local addon = LibStub('AceAddon-3.0'):GetAddon(ADDON_NAME)
local Actions = addon:NewModule('Actions')
local Utils = addon:GetModule('Utils')
local infos = addon:GetModule('Constants'):GetInfos()
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)

function Actions:initSlash()
    SLASH_WATCHDOG1 = "/watchdog"
    SLASH_WATCHDOG2 = "/wd"
    SLASH_WATCHDOG3 = "/WD"
    SlashCmdList['WATCHDOG'] = function(param)
        local Settings = addon:GetModule('Settings', true)
        return Settings and Settings:Open()
    end
end

function Actions:initAddonMessage()
    local addonMessageFrame = CreateFrame('FRAME')
    addonMessageFrame:RegisterEvent('READY_CHECK')
    addonMessageFrame:SetScript('OnEvent', function()
        local versionString = 'version:' .. infos.VERSION
        local type = (IsInGuild() and 'GUILD')
                or (IsInRaid() and 'RAID')
                or (IsInGroup() and 'PARTY')
                or (IsInInstance() and 'INSTANCE_CHAT')
                or nil
        if not type then return end
        AceComm:SendCommMessage(infos.ADDON_BASE_NAME, versionString, type)
    end)
    AceComm:RegisterComm(infos.ADDON_BASE_NAME, function(prefix, text)
        if prefix ~= infos.ADDON_BASE_NAME or not text then return end
        if not string.find(text, 'version') then return end
        local major, minor, revision = string.match(text, 'version:(%d).(%d).(%d)')
        if not major or not minor or not revision then return end
        self:compareVersion(major, minor, revision)
    end)
end

function Actions:banPlayerWithID(id)
    if not id then return end
    local info = { C_LFGList.GetSearchResultInfo(id) }
    local leaderName = info[13]
    if leaderName == nil then return SendSystemMessage(L.NOT_FOUND_PLAYER_NAME) end

    if not WATCHDOG_DB.players[leaderName] then 
        WATCHDOG_DB.players[leaderName] = { status = 1, name = leaderName }
        C_LFGList.ReportSearchResult(id, 'lfglistname')
        self:log(leaderName..' '..L.ACTION_BAN_MESSAGE)
    end
end

function Actions:isBannedPlayer(name)
    if not name then return nil end
    return WATCHDOG_DB.players[name]
end

function Actions:banPlayerWithName(name)
    if not name then return end
    if WATCHDOG_DB.players[name] then return end
    WATCHDOG_DB.players[name] = { status = 1, name = name }
    self:log(name..' '..L.ACTION_BAN_MESSAGE)
end

function Actions:unbanPlayerWithName(name)
    local next = {}
    for k, v in pairs(WATCHDOG_DB.players) do
        if k ~= name then 
            next[k] = v
        end
    end
    WATCHDOG_DB.players = next
    self:log(name..' '..L.ACTION_UNBAN_MESSAGE)
end

function Actions:banAllPlayers()
    local players = WATCHDOG_VARS.LAST_SEARCH_RESULTS
    if not players or #players == 0 then 
        return self:log(L.IGNORE_ALL_NOT_FOUND_PLAYER)
    end
    for i = 1, #players do
        self:banPlayerWithName(players[i].name)
        C_LFGList.ReportSearchResult(players[i].id, 'lfglistname')
    end
    self:log(string.format(L.IGNORE_ALL_COMPLETED, #players))
end

function Actions:unbanAllplayers()
    WATCHDOG_DB.players = {}
    self:log(L.CLEAR_BAN_LIST_SUCCESS)
end

function Actions:importSettings(text, type)
    if not text then return self:log(L.EXPORT_TEXT_EMPTY) end
    local index = string.match(text, infos.DEFAULT_EXPORT_SEP)
    if not index then return self:log(L.EXPORT_TEXT_ERROR) end

    local str = Utils:decode(text)
    local names = Utils:split(str, infos.DEFAULT_EXPORT_SEP)
    local players = {}
    local count = 0

    for i = 1, #names do
        local name = names[i]
        if name and string.len(name) > 1 then 
            if not players[name] then count = count + 1 end
            
            players[name] = { status = 1, name = name }
            if infos.EXPORT_TYPE_MERGE == type then 
                WATCHDOG_DB.players[name] = { status = 1, name = name }
            end
        end
    end

    if INFO.EXPORT_TYPE_COVER == type then
        WATCHDOG_DB.players = players
        self:log(L.EXPORT_TIPS_WITH_TYPE_COVER)
    end
    if INFO.EXPORT_TYPE_MERGE == type then
        self:log(L.EXPORT_TIPS_WITH_TYPE_MERGE)
    end
    
    self:log(string.format(L.EXPORT_SUCCESS, count))
    _G[infos.ADDON_BASE_NAME].Components.Export.close()
end

function Actions:findLimitItemLevel()
    local selfLevel = GetAverageItemLevel()
    if not selfLevel or selfLevel < 10 then
        return 2
    end
    if selfLevel < 50 then return selfLevel - 10 end
    return selfLevel - 50
end

function Actions:checkListInfo(id, limitLevel)
    
    local passed, lastPlayer = false, nil
    local info = { C_LFGList.GetSearchResultInfo(id) }
    if not info then return passed, lastPlayer end
    local ilvl, minutes, leaderName, members = info[6], (info[8] or 0) / 60, info[13], info[14]
    
    -- ilvl == 0 or nil is not set
    local ilvlPassed = (not ilvl and true) or (ilvl == 0 and true) or (ilvl > limitLevel and true) or nil
    local memberPassed = not (minutes > 20 and members <= 1)
    local defaultFilter = (not WATCHDOG_DB.defaultFilterToggle and true) or (ilvlPassed and memberPassed)

    -- default filter 
    if not defaultFilter then return passed, lastPlayer end

    if not leaderName then return true, nil end

    if not self:isBannedPlayer(leaderName) then
        passed = true

        -- not includes BNetFriends / CharFriends / GuildMates
        if info[9] == 0 and info[10] == 0 and info[11] == 0 then
            lastPlayer = { name = leaderName, id = id }
        end
    end
    return passed, lastPlayer
end

function Actions:meetingStoneMixin()
    local GUI = LibStub('NetEaseGUI-2.0')
    local MeetingStone = LibStub('AceAddon-3.0'):GetAddon('MeetingStone') 
    local LfgService, BrowsePanel = MeetingStone:GetModule('LfgService', true), MeetingStone:GetModule('BrowsePanel', true)
    if not LfgService or not BrowsePanel then return end
    local _cacheCopy = LfgService._CacheActivity
    local limitLevel = self:findLimitItemLevel()

    LfgService._CacheActivity = function(s, id)
        if not id then return end
        local passed = self:checkListInfo(id, limitLevel)
        if not passed then return end
        return _cacheCopy(s, id)
    end
    
    local _toggleMenuCopy = BrowsePanel.ToggleActivityMenu
    BrowsePanel.ToggleActivityMenu = function(s, anchor, activity)
        local usable, reason = s:CheckSignUpStatus(activity)
        _toggleMenuCopy(s, anchor, activity)
        GUI:CloseMenu()
        GUI:ToggleMenu(anchor, {
            {
                text = activity:GetName(),
                isTitle = true,
                notCheckable = true,
            },
            {
                text = L.MEETINGSTONE_APPLY_TEXT,
                func = function() s:SignUp(activity) end,
                disabled = not usable or activity:IsDelisted() or activity:IsApplication(),
                tooltipTitle = not (activity:IsDelisted() or activity:IsApplication()) and L.MEETINGSTONE_APPLY_TEXT,
                tooltipText = reason,
                tooltipWhileDisabled = true,
                tooltipOnButton = true,
            },
            {
                text = L.MEETINGSTONE_IGNORE_TITLE,
                func = function() self:banPlayerWithName(activity:GetLeader()) end,
                disabled = not activity:GetLeader(),
                tooltipTitle = L.MEETINGSTONE_IGNORE_TOOLTIP_TITLE,
                tooltipText = L.MEETINGSTONE_IGNORE_TOOLTIP_DESC,
                tooltipWhileDisabled = true,
                tooltipOnButton = true,
            },
            {
                text = WHISPER_LEADER,
                func = function() ChatFrame_SendTell(activity:GetLeader()) end,
                disabled = not activity:GetLeader() or not activity:IsApplication(),
                tooltipTitle = not activity:IsApplication() and WHISPER,
                tooltipText = not activity:IsApplication() and LFG_LIST_MUST_SIGN_UP_TO_WHISPER,
                tooltipOnButton = true,
                tooltipWhileDisabled = true,
            },
            {
                text = CANCEL,
            },
        }, 'cursor')
    end
end

function Actions:sendVersionMessage()
    if not WATCHDOG_DB then return end
    if not WATCHDOG_DB.nextVersion then return end
    if not WATCHDOG_DB.versionMessageToggle then return end

    local major1, minor1, revision1 = string.match(WATCHDOG_DB.nextVersion, '(%d).(%d).(%d)')
    local major2, minor2, revision2 = string.match(infos.VERSION, '(%d).(%d).(%d)')
    local resetVersion = function()
        WATCHDOG_DB.nextVersion = nil
    end
    if not major1 or not minor1 or not revision1 then return resetVersion() end
    if major1 < major2 then return resetVersion() end
    if major1 == major2 and minor1 < minor2 then return resetVersion() end
    if major1 == major2 and minor1 == minor2 and revision1 < revision2 then return resetVersion() end 

    if WATCHDOG_DB.nextVersion == infos.VERSION then return resetVersion() end
    self:log(L.VERSION_EXPIRED)
end

function Actions:log(text)
    local prefix = format("|CFF00FFFF%s: |r", L.ADDON_SHOW_NAME)
    SendSystemMessage(prefix..text)
end

function Actions:compareVersion(major1, minor1, revision1)
    local major2, minor2, revision2 = string.match(infos.VERSION, '(%d).(%d).(%d)')
    local recordNextVersion = function()
        WATCHDOG_DB.nextVersion = major1..'.'..minor1..'.'..revision1
    end
    if major1 > major2 then return recordNextVersion() end
    if major1 == major2 and minor1 > minor2 then return recordNextVersion() end
    if major1 == major2 and minor1 == minor2 and revision1 > revision2 then return recordNextVersion() end
end

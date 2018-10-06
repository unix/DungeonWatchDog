local INFO = WATCHDOG_VARS.INFOS
local L = LibStub("AceLocale-3.0"):GetLocale(INFO.ADDON_BASE_NAME, false)
local AceComm = LibStub("AceComm-3.0")
local actions = {}

actions.initDB = function()
    if not WATCHDOG_DB then WATCHDOG_DB = {} end
    if not WATCHDOG_DB.players then WATCHDOG_DB.players = {} end
end

actions.initSlash = function()
    SLASH_WATCHDOG1 = "/watchdog"
    SLASH_WATCHDOG2 = "/wd"
    SLASH_WATCHDOG3 = "/WD"
    SlashCmdList['WATCHDOG'] = function(param)
        param = string.lower(param)
        if param == 'show' then 
            return _G[INFO.ADDON_BASE_NAME].Components.Ignores.open()
        end
        if param == 'export' then
            return _G[INFO.ADDON_BASE_NAME].Components.Export.open()
        end
        if param == 'clear' then
            actions.unbanAllplayers()
            return _G[INFO.ADDON_BASE_NAME].Components.Ignores.close()
        end
        if param == 'version' then
            return actions.log('v'..INFO.VERSION)
        end
        actions.log("Usage:")
        actions.log('/wd show  '..L.SLASH_TIPS_SHOW)
        actions.log('/wd export  '..L.SLASH_TIPS_EXPORT)
        actions.log('/wd clear  '..L.SLASH_TIPS_CLEAR)
        actions.log('/wd version  '..L.SLASH_TIPS_VERSION)
    end
end

actions.initAddonMessage = function()
    local addonMessageFrame = CreateFrame('FRAME')
    addonMessageFrame:RegisterEvent('READY_CHECK')
    addonMessageFrame:SetScript('OnEvent', function()
        local versionString = 'version:' .. INFO.VERSION
        local type = (IsInGuild() and 'GUILD')
                or (IsInRaid() and 'RAID')
                or (IsInGroup() and 'PARTY')
                or (IsInInstance() and 'INSTANCE_CHAT')
                or nil
        if not type then return end
        AceComm:SendCommMessage(INFO.ADDON_BASE_NAME, versionString, type)
    end)
    AceComm:RegisterComm(INFO.ADDON_BASE_NAME, function(prefix, text)
        if prefix ~= INFO.ADDON_BASE_NAME or not text then return end
        if not string.find(text, 'version') then return end
        local major, minor, revision = string.match(text, 'version:(%d).(%d).(%d)')
        if not major or not minor or not revision then return end
        actions.compareVersion(major, minor, revision)
    end)
end

actions.banPlayerWithID = function(id)
    if not id then return end
    local info = {C_LFGList.GetSearchResultInfo(id)}
    local leaderName = info[13]
    if leaderName == nil then return SendSystemMessage(L.NOT_FOUND_PLAYER_NAME) end

    if not WATCHDOG_DB.players[leaderName] then 
        WATCHDOG_DB.players[leaderName] = { status = 1, name = leaderName }
        C_LFGList.ReportSearchResult(id, 'lfglistname')
        actions.log(leaderName..' '..L.ACTION_BAN_MESSAGE)
    end
end

actions.isBannedPlayer = function(name)
    if not name then return nil end
    return WATCHDOG_DB.players[name]
end

actions.banPlayerWithName = function(name)
    if not name then return end
    if WATCHDOG_DB.players[name] then return end
    WATCHDOG_DB.players[name] = { status = 1, name = name }
    actions.log(name..' '..L.ACTION_BAN_MESSAGE)
end

actions.unbanPlayerWithName = function(name)
    local next = {}
    for k, v in pairs(WATCHDOG_DB.players) do
        if k ~= name then 
            next[k] = v
        end
    end
    WATCHDOG_DB.players = next
    actions.log(name..' '..L.ACTION_UNBAN_MESSAGE)
end

actions.banAllPlayers = function()
    local players = WATCHDOG_VARS.LAST_SEARCH_RESULTS
    if not players or #players == 0 then 
        return actions.log(L.IGNORE_ALL_NOT_FOUND_PLAYER)
    end
    for i = 1, #players do
        actions.banPlayerWithName(players[i].name)
        C_LFGList.ReportSearchResult(players[i].id, 'lfglistname')
    end
    actions.log(string.format(L.IGNORE_ALL_COMPLETED, #players))
end 

actions.unbanAllplayers = function()
    WATCHDOG_DB.players = {}
    actions.log(L.CLEAR_BAN_LIST_SUCCESS)
end

actions.importSettings = function(text, type)
    if not text then return actions.log(L.EXPORT_TEXT_EMPTY) end
    local index = string.match(text, INFO.DEFAULT_EXPORT_SEP)
    if not index then return actions.log(L.EXPORT_TEXT_ERROR) end

    local str = Utils.decode(text)
    local names = Utils.split(str, INFO.DEFAULT_EXPORT_SEP)
    local players = {}
    local count = 0

    for i = 1, #names do
        local name = names[i]
        if name and string.len(name) > 1 then 
            if not players[name] then count = count + 1 end
            
            players[name] = { status = 1, name = name }
            if INFO.EXPORT_TYPE_MERGE == type then 
                WATCHDOG_DB.players[name] = { status = 1, name = name }
            end
        end
    end

    if INFO.EXPORT_TYPE_COVER == type then
        WATCHDOG_DB.players = players
        actions.log(L.EXPORT_TIPS_WITH_TYPE_COVER)
    end
    if INFO.EXPORT_TYPE_MERGE == type then
        actions.log(L.EXPORT_TIPS_WITH_TYPE_MERGE)
    end
    
    actions.log(string.format(L.EXPORT_SUCCESS, count))
    _G[INFO.ADDON_BASE_NAME].Components.Export.close()
end

actions.findLimitItemLevel = function()
    local selfLevel = GetAverageItemLevel()
    if not selfLevel or selfLevel < 10 then
        return 2
    end
    if selfLevel < 50 then return selfLevel - 10 end
    return selfLevel - 50
end

actions.checkListInfo = function(id, limitLevel)
    local passed, lastPlayer = false, nil
    local info = { C_LFGList.GetSearchResultInfo(id) }
    local ilvl, minutes, leaderName, members = info[6], info[8] / 60, info[13], info[14]
    -- ilvl == 0 is not set
    local ilvlPassed = (ilvl == 0 and true) or (ilvl > limitLevel and true) or nil
    local memberPassed = not (minutes > 20 and members <= 1)

    if not actions.isBannedPlayer(leaderName) and ilvlPassed and memberPassed then
        passed = true

        -- not includes BNetFriends / CharFriends / GuildMates
        if info[9] == 0 and info[10] == 0 and info[11] == 0 then
            lastPlayer = { name = leaderName, id = id }
        end
    end
    return passed, lastPlayer
end

actions.meetingStoneMixin = function()
    local GUI = LibStub('NetEaseGUI-2.0')
    local MeetingStone = LibStub('AceAddon-3.0'):GetAddon('MeetingStone') 
    local LfgService = MeetingStone:GetModule('LfgService')
    local _cacheCopy = LfgService._CacheActivity
    local limitLevel = actions.findLimitItemLevel()

    LfgService._CacheActivity = function(self, id)
        if not id then return end
        local passed = actions.checkListInfo(id, limitLevel)
        if not passed then return end
        return _cacheCopy(self, id)
    end

    local BrowsePanel = MeetingStone:GetModule('BrowsePanel')
    local _toggleMenuCopy = BrowsePanel.ToggleActivityMenu
    BrowsePanel.ToggleActivityMenu = function(self, anchor, activity)
        local usable, reason = self:CheckSignUpStatus(activity)
        _toggleMenuCopy(self, anchor, activity)
        GUI:CloseMenu()
        GUI:ToggleMenu(anchor, {
            {
                text = activity:GetName(),
                isTitle = true,
                notCheckable = true,
            },
            {
                text = L.MEETINGSTONE_APPLY_TEXT,
                func = function() self:SignUp(activity) end,
                disabled = not usable or activity:IsDelisted() or activity:IsApplication(),
                tooltipTitle = not (activity:IsDelisted() or activity:IsApplication()) and L.MEETINGSTONE_APPLY_TEXT,
                tooltipText = reason,
                tooltipWhileDisabled = true,
                tooltipOnButton = true,
            },
            {
                text = L.MEETINGSTONE_IGNORE_TITLE,
                func = function() actions.banPlayerWithName(activity:GetLeader()) end,
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

actions.sendVersionMessage = function()
    if not WATCHDOG_DB then return end
    if not WATCHDOG_DB.nextVersion then return end

    if WATCHDOG_DB.nextVersion == INFO.VERSION then
        WATCHDOG_DB.nextVersion = nil
        return
    end
    actions.log(L.VERSION_EXPIRED)
end

actions.log = function(text)
    local prefix = format("|CFF00FFFF%s: |r", L.ADDON_SHOW_NAME)
    SendSystemMessage(prefix..text)
end

actions.compareVersion = function(major1, minor1, revision1)
    local major2, minor2, revision2 = string.match(INFO.VERSION, '(%d).(%d).(%d)')
    local recordNextVersion = function()
        WATCHDOG_DB.nextVersion = major1..'.'..minor1..'.'..revision1
    end
    if major1 > major2 then return recordNextVersion() end
    if major1 == major2 and minor1 > minor2 then return recordNextVersion() end
    if major1 == major2 and minor1 == minor2 and revision1 > revision2 then return recordNextVersion() end
end

_G[INFO.ADDON_BASE_NAME].Actions = actions


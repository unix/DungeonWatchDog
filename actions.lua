local INFO = WATCHDOG_VARS.INFOS
local L = LibStub("AceLocale-3.0"):GetLocale(INFO.ADDON_BASE_NAME, false)
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


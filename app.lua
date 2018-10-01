local INFO = WATCHDOG_VARS.INFOS
local Actions = _G[INFO.ADDON_BASE_NAME].Actions
local Components = _G[INFO.ADDON_BASE_NAME].Components
local L = LibStub("AceLocale-3.0"):GetLocale(INFO.ADDON_BASE_NAME, false)
local frame = CreateFrame('FRAME')
frame:RegisterEvent('ADDON_LOADED')

local replaceSearchResult = function()
    local _searchCopy = C_LFGList.GetSearchResults
    local limitLevel = Actions.findLimitItemLevel()

    C_LFGList.GetSearchResults = function()
        local total, searchResults = _searchCopy()
        local players = {}
        local lastSearchPlayers = {}
        for _, id in pairs(searchResults) do
            local info = { C_LFGList.GetSearchResultInfo(id) }
            local ilvl, minutes, leaderName, members = info[6], info[8] / 60, info[13], info[14]
            -- ilvl == 0 is not set
            local ilvlPassed = (ilvl == 0 and true) or (ilvl > limitLevel and true) or nil
            local memberPassed = not (minutes > 20 and members <= 1)

            if not Actions.isBannedPlayer(leaderName) and ilvlPassed and memberPassed then
                table.insert(players, id)

                -- not includes BNetFriends / CharFriends / GuildMates
                if info[9] == 0 and info[10] == 0 and info[11] == 0 then
                    table.insert(lastSearchPlayers, { name = leaderName, id = id })
                end
            end
        end

        -- record the results of the previous search
        WATCHDOG_VARS.LAST_SEARCH_RESULTS = lastSearchPlayers
        return total, players
    end
end

local findLastFuncPosition = function(list)
    local t
    for i = 1, #list do
        local item = list[i]
        if item ~= nil and item.text ~= nil and item.text == L.SEARCH_MENU_TEXT then
            t = i
        end
    end
    return t
end

local replaceNativeUtilWithMenu = function()
    local _menuCopy = LFGListUtil_GetSearchEntryMenu
    LFGListUtil_GetSearchEntryMenu = function(id)
        local list = _menuCopy(id)
        local setPosition = #list
        local lastPosition = findLastFuncPosition(list)
        if lastPosition ~= nil then
            setPosition = lastPosition
            table.remove(list, lastPosition)
        end
        table.insert(list, setPosition, {
            text = L.SEARCH_MENU_TEXT,
            func = function()
                Actions.banPlayerWithID(id)
                Components.Ignores.updateCountInShow()
            end,
            notCheckable = true,
            disabled = nil,
            tooltipOnButton = 1,
            tooltipTitle = L.SEARCH_MENU_TOOLIP_TITLE,
            tooltipText = L.SEARCH_MENU_TOOLIP_TEXT,
        })
        return list
    end
end

local watchDogInit = function(_, eventName, alias)
    if eventName ~= 'ADDON_LOADED' or alias ~= INFO.ADDON_BASE_NAME then
        return
    end
    Actions.initDB()
    Actions.initSlash()
    Actions.sendVersionMessage()
    Actions.initAddonMessage()

    replaceNativeUtilWithMenu()
    replaceSearchResult()
    Components.init()
end

frame:SetScript('OnEvent', watchDogInit)


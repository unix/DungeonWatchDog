local INFO = WATCHDOG_VARS.INFOS
local L = LibStub("AceLocale-3.0"):GetLocale(INFO.ADDON_BASE_NAME, false)
local frame = CreateFrame('FRAME')
frame:RegisterEvent('ADDON_LOADED')

local replaceSearchResult = function(e, name)
    local _searchCopy = C_LFGList.GetSearchResults 
    
    C_LFGList.GetSearchResults = function() 
        local total, searchResults = _searchCopy()
        local bannedPlayers = Actions.findBannedPlayers()
        local players = {}
        local count = 0
        for k,id in pairs(searchResults) do 
            local info = {C_LFGList.GetSearchResultInfo(id)}
            local leaderName = info[13]
            if (bannedPlayers[leaderName] ~= 1) then
                table.insert(players, id)
            end
        end 
        return total, players
    end
end

local findLastFuncPosition = function(list)
    local t = nil
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
            func = function() Actions.banPlayerWithID(id) end,
            notCheckable = true,
            disabled = nil,
            tooltipTitle = L.SEARCH_MENU_TOOLIP_TITLE,
        })
        return list
    end
end

local watchDogInit = function(_, eventName, alias)
    if eventName ~= 'ADDON_LOADED' or alias ~= INFO.ADDON_BASE_NAME then 
        return
    end
    if WATCHDOG_DB == nil then WATCHDOG_DB = {} end
    replaceNativeUtilWithMenu()
    replaceSearchResult()
end

frame:SetScript('OnEvent', watchDogInit) 


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
        local players, lastSearchPlayers = {}, {}
        local passed, lastPlayer = false, nil

        for _, id in pairs(searchResults) do
            passed, lastPlayer = Actions.checkListInfo(id, limitLevel)
            if passed then table.insert(players, id) end
            if lastPlayer then table.insert(lastSearchPlayers, lastPlayer) end
            passed, lastPlayer = false, nil
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
    if eventName == 'ADDON_LOADED' and alias == 'MeetingStone' then
        Actions.meetingStoneMixin()
    end

    if eventName ~= 'ADDON_LOADED' or alias == INFO.ADDON_BASE_NAME then
        Actions.initDB()
        Actions.initSlash()
        Actions.sendVersionMessage()
        Actions.initAddonMessage()

        replaceNativeUtilWithMenu()
        replaceSearchResult()
        Components.init()
    end

end

frame:SetScript('OnEvent', watchDogInit)


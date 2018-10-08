local L = LibStub("AceLocale-3.0"):GetLocale('DungeonWatchDog', false)
local addon = LibStub('AceAddon-3.0'):GetAddon('DungeonWatchDog')
local infos = addon:GetModule('Constants'):GetInfos()
local Actions = addon:GetModule('Actions')


local replaceSearchResult = function()
    local _searchCopy = C_LFGList.GetSearchResults
    local limitLevel = Actions:findLimitItemLevel()

    C_LFGList.GetSearchResults = function()
        local total, searchResults = _searchCopy()
        local players, lastSearchPlayers = {}, {}
        local passed, lastPlayer = false, nil

        for _, id in pairs(searchResults) do
            passed, lastPlayer = Actions:checkListInfo(id, limitLevel)
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
                Actions:banPlayerWithID(id)
                local Components = addon:GetModule('Components', true)
                if Components then 
                    local Ignores = Components:get('Ignores')
                    Ignores:updateCountInShow()
                end
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


function addon:OnEnable()
    Actions:initSlash()
    Actions:sendVersionMessage()
    Actions:initAddonMessage()

    replaceNativeUtilWithMenu()
    replaceSearchResult()

    local MeetingStone = LibStub('AceAddon-3.0'):GetAddon('MeetingStone', true)
    if MeetingStone then Actions:meetingStoneMixin() end
end

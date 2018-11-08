local ADDON_NAME = GetAddOnMetadata(..., 'Title')
local L = LibStub('AceLocale-3.0'):GetLocale(ADDON_NAME, false)
local addon = LibStub('AceAddon-3.0'):GetAddon(ADDON_NAME)
local AceComm = LibStub('AceComm-3.0')
local infos = addon:GetModule('Constants'):GetInfos()
local Actions = addon:GetModule('Actions')
local Share = addon:GetModule('Share')
local pairs = pairs

local replaceSearchResult = function()
    local _searchCopy = C_LFGList.GetSearchResults
    local limitLevel = Actions:findLimitItemLevel()
    local defaultFilterToggle = WATCHDOG_DB.defaultFilterToggle

    C_LFGList.GetSearchResults = function()
        local _, searchResults = _searchCopy()
        local players, lastSearchPlayers = {}, {}
        local passed, lastPlayer, count, lastCount = nil, nil, 0, 0

        for _, id in pairs(searchResults) do
            if id then
                passed, lastPlayer = Actions:checkListInfo(id, limitLevel, defaultFilterToggle)
                if passed then
                    count = count + 1
                    players[count] = id
                end
                if lastPlayer then
                    lastCount = lastCount + 1
                    lastSearchPlayers[lastCount] = lastPlayer
                end
                passed, lastPlayer = nil, nil
            end
        end
        
        -- record the results of the previous search
        WATCHDOG_VARS.LAST_SEARCH_RESULTS = lastSearchPlayers
        lastSearchPlayers, searchResults, count, lastCount = nil, nil, nil, nil
        return count, players
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
                    local IgnoreList = Components:get('IgnoreList')
                    IgnoreList:updateWhenOpened()
                end
                Components = nil
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

function addon:OnInitialize()
    local f = CreateFrame('Frame')
    f:RegisterEvent('ADDON_LOADED')
    f:RegisterEvent('PLAYER_LOGIN')
    f:SetScript('OnEvent', function (s, event, name)
        if event == 'PLAYER_LOGIN' then
            Share:init()
            f:UnregisterEvent('ADDON_LOADED')
            return f:UnregisterEvent('PLAYER_LOGIN')
        end
        if event ~= 'ADDON_LOADED' then return end
        if name ~= 'MeetingStone' then return end
        if LibStub('AceAddon-3.0'):GetAddon('MeetingStone', true) then 
            Actions:meetingStoneMixin() 
        end
    end)
end

function addon:OnEnable()
    Actions:initSlash()
    Actions:sendVersionMessage()
    Actions:initAddonMessage()

    replaceNativeUtilWithMenu()
    replaceSearchResult()
end

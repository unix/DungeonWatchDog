local ADDON_NAME = GetAddOnMetadata(..., 'Title')
local addon = LibStub('AceAddon-3.0'):GetAddon(ADDON_NAME)
local L = LibStub('AceLocale-3.0'):GetLocale(ADDON_NAME, false)
local IgnoreList = addon:NewModule('IgnoreList')
local infos = addon:GetModule('Constants'):GetInfos()
local Utils = addon:GetModule('Utils')
local Actions = addon:GetModule('Actions')
local AceGUI = LibStub('AceGUI-3.0')

function IgnoreList:OnInitialize()
    self.len = 0
    self.scrollValue = 0
    self.lastSearchText = ''
    self.dropdown = CreateFrame('Frame', 'TouchDogDropMenu', nil, 'UIDropDownMenuTemplate')
    self.options = {
        {
            text = ' ',
            isTitle = true,
            notCheckable = true,
        },
        {
            text = L.BANNED_LIST_CANCEL,
            notCheckable = true,
            arg1 = nil,
            func = function(_, name)
                Actions:unbanPlayerWithName(name)
                -- self:updateScrollValue()
                self:updatePlayersWithKeyWord('')
                -- self:updateScrollPosition()

                if self.lastSearchText then
                    self:updatePlayersWithKeyWord(self.lastSearchText)
                end
            end,
        },
        {
            text = CANCEL,
            notCheckable = true,
        },
    }
end

function IgnoreList:initOptions(name)
    local options = self.options
    options[1].text = name
    options[2].arg1 = name
    return options
end

function IgnoreList:initItem(name)
    local s, dropdown = self, self.dropdown
    local label = AceGUI:Create('InteractiveLabel')
    label:SetText(' '..name)
    label:SetColor(0.871, 0.777, 0.3)
    label:SetHeight(25)
    label.label:SetHeight(25)
    label:SetJustifyV('CENTER')
    label:SetCallback('OnEnter', function (self)
        self:SetColor(0.5, 0.5, 0.07)
    end)
    label:SetCallback('OnLeave', function (self)
        self:SetColor(0.871, 0.777, 0.3)
    end)
    label:SetCallback('OnClick', function (s, e, btn)
        if btn ~= 'RightButton' then return end
        EasyMenu(self:initOptions(name), dropdown, s.frame, 170, 5, 'MENU')
    end)
    return label
end

function IgnoreList:updatePlayerCount(len)
    self.frame:SetStatusText(L.BANNED_LIST_COUNT..len)
    self.len = len
end

function IgnoreList:update(players)
    self.scrollContainer:ReleaseChildren()
    self.scroll = nil
    local scroll = AceGUI:Create('ScrollFrame')
    scroll:SetLayout('Flow')

    for name, player in pairs(players) do
        if name then 
            scroll:AddChild(self:initItem(name))
        end
    end
    self.scroll = scroll
    self.scrollContainer:AddChild(scroll)
end

function IgnoreList:render()
    self.frame = AceGUI:Create('Frame')
    local f = self.frame
    f:Hide()
    f:ReleaseChildren()
    f:SetTitle(L.BANNED_LIST_TITLE)
    f:SetLayout('Flow')
    f:SetWidth(260)
    f:SetHeight(460)
    f:EnableResize(false)
    local search = AceGUI:Create('EditBox')
    search:SetFullWidth(true)
    search:SetCallback('OnEnterPressed', function (s, e, text)
        self.lastSearchText = text
        self:updatePlayersWithKeyWord(text)
    end)
    f:AddChild(search)
    self.scrollContainer = AceGUI:Create('SimpleGroup')
    self.scrollContainer:SetFullWidth(true)
    self.scrollContainer:SetFullHeight(true)
    self.scrollContainer:SetLayout('Fill')
    f:Show()
    f:AddChild(self.scrollContainer)
end

function IgnoreList:open()
    self:render()
    self:updatePlayersWithKeyWord('')
end

function IgnoreList:updatePlayersWithKeyWord(text)
    local players, result, count = WATCHDOG_DB.players, {}, 0
    for name, player in pairs(players) do 
        if name and string.find(name, text) then
            result[name] = player
            count = count + 1
        end
    end
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    self:updatePlayerCount(count)
    return self:update(result)
end

function IgnoreList:updateScrollValue()
    if self.scroll then 
        self.scrollValue = self.scroll.scrollbar:GetValue()
    end
end

function IgnoreList:updateScrollPosition()
    if self.scrollValue and self.scroll then
        self.scroll:SetScroll(self.scrollValue)
    end
end

function IgnoreList:updateWhenOpened()
    if self.frame and self.frame:IsShown() then
        self:updatePlayersWithKeyWord(self.lastSearchText)
    end
end

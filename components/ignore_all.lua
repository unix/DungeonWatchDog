local addon = LibStub('AceAddon-3.0'):GetAddon('DungeonWatchDog')
local L = LibStub("AceLocale-3.0"):GetLocale('DungeonWatchDog', false)
local IgnoreAll = addon:NewModule('IgnoreAll')
local infos = addon:GetModule('Constants'):GetInfos()
local Utils = addon:GetModule('Utils')
local Actions = addon:GetModule('Actions')

function IgnoreAll:OnInitialize()
    local panel = LFGListFrame.SearchPanel
    panel.IgnoreAllBtn = CreateFrame('Button', nil, panel, 'UIMenuButtonStretchTemplate')
    panel.IgnoreAllBtn:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', -52, -28)
    panel.IgnoreAllBtn:SetSize(90, 26)
    panel.IgnoreAllBtn:SetText(L.IGNORE_ALL_BTN_TEXT)
    panel.IgnoreAllBtn:SetNormalFontObject('GameFontNormal')
    panel.IgnoreAllBtn:SetHighlightFontObject('GameFontHighlight')
    panel.IgnoreAllBtn:SetScript('OnClick', function() self:showConfirm() end)

    StaticPopupDialogs['WATCH_DOG_IGNORE_ALL_CONFIRM'] = {
        text = L.IGNORE_ALL_CONFIRM_TEXT,
        button1 = OKAY,
        button2 = NO,
        hideOnEscape = true,
        timeout = 0,
        exclusive = true,
        showAlert = true,
        OnAccept = function(s) self:banAllPlayers() end,
        OnCancel = function(s) self:hideConfirm() end,
    }
end

function IgnoreAll:banAllPlayers()
    Actions:banAllPlayers()
    local Components = addon:GetModule('Components', true)
    if Components then 
        Components:get('IgnoreList'):updateWhenOpened()
    end
    collectgarbage('collect')
end

function IgnoreAll:showConfirm()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    StaticPopup_Show('WATCH_DOG_IGNORE_ALL_CONFIRM')
end

function IgnoreAll:hideConfirm()
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    StaticPopup_Hide('WATCH_DOG_IGNORE_ALL_CONFIRM')
end

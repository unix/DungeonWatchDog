local ADDON_NAME = GetAddOnMetadata(..., 'Title')
local addon = LibStub('AceAddon-3.0'):GetAddon(ADDON_NAME)
local L = LibStub('AceLocale-3.0'):GetLocale(ADDON_NAME, false)
local IgnoreAll = addon:NewModule('IgnoreAll')
local infos = addon:GetModule('Constants'):GetInfos()
local Utils = addon:GetModule('Utils')
local Actions = addon:GetModule('Actions')

function IgnoreAll:OnInitialize()
    local panel = LFGListFrame.SearchPanel
    local btn = CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')
    local showTooltip = function(title, desc)
        GameTooltip:SetOwner(btn, 'ANCHOR_NONE')
        GameTooltip:SetPoint('BOTTOMLEFT', btn, 'TOPRIGHT', 0, 0)
        GameTooltip:AddLine(title)
        GameTooltip:Show()
    end
    local hideTooltip = function()
        GameTooltip:SetText(' ')
        GameTooltip:Hide()
    end

    btn:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', -50, -27)
    btn:SetSize(50, 27)
    btn:SetText(L.IGNORE_ALL_BTN_TEXT)
    btn:SetNormalFontObject('GameFontNormal')
    btn:SetHighlightFontObject('GameFontHighlight')

    btn:SetScript('OnClick', function() self:showConfirm() end)
    btn:SetScript('OnEnter', function()
        showTooltip(L.IGNORE_ALL_BTN_TOOLTIP_TITLE)
    end)
    btn:SetScript('OnLeave', function() hideTooltip() end)
    btn:SetScript('OnShow', function()
        local _, _, _, loadable = GetAddOnInfo(infos.PGF_NAME)
        if loadable then 
            btn:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', -102, -27)
        end
    end)

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

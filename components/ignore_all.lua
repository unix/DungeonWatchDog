local INFO = WATCHDOG_VARS.INFOS
local L = LibStub("AceLocale-3.0"):GetLocale(INFO.ADDON_BASE_NAME, false)
local IgnoreAll = {}

IgnoreAll.init = function()
    local panel = LFGListFrame.SearchPanel
    panel.IgnoreAllBtn = CreateFrame('Button', nil, panel, 'UIMenuButtonStretchTemplate')
    panel.IgnoreAllBtn:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', -52, -28)
    panel.IgnoreAllBtn:SetSize(90, 26)
    panel.IgnoreAllBtn:SetText(L.IGNORE_ALL_BTN_TEXT)
    panel.IgnoreAllBtn:SetNormalFontObject('GameFontNormal')
    panel.IgnoreAllBtn:SetHighlightFontObject('GameFontHighlight')
    panel.IgnoreAllBtn:SetScript('OnClick', function() IgnoreAll.showConfirm() end)

    StaticPopupDialogs['WATCH_DOG_IGNORE_ALL_CONFIRM'] = {
        text = L.IGNORE_ALL_CONFIRM_TEXT,
        button1 = OKAY,
        button2 = NO,
        hideOnEscape = true,
        timeout = 0,
        exclusive = true,
        showAlert = true,
        OnAccept = function(self) IgnoreAll.banAllPlayers() end,
        OnCancel = function(self) IgnoreAll.hideConfirm() end,
        OnUpdate = function(self, elapsed)
        end,
    }
end

IgnoreAll.banAllPlayers = function()
    _G[INFO.ADDON_BASE_NAME].Actions.banAllPlayers()
    _G[INFO.ADDON_BASE_NAME].Components.Ignores.updateCountInShow()
    collectgarbage('collect')
end

IgnoreAll.showConfirm = function()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    StaticPopup_Show('WATCH_DOG_IGNORE_ALL_CONFIRM')
end

IgnoreAll.hideConfirm = function()
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    StaticPopup_Hide('WATCH_DOG_IGNORE_ALL_CONFIRM')
end




_G[INFO.ADDON_BASE_NAME].Components.IgnoreAll = IgnoreAll



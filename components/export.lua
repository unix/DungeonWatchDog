local INFO = WATCHDOG_VARS.INFOS
local L = LibStub("AceLocale-3.0"):GetLocale(INFO.ADDON_BASE_NAME, false)
local Export = {}

Export.init = function()
    local planel = CreateFrame('Frame', INFO.EXPORT_PLANEL_FRAME, UIParent, 'GlowBoxTemplate')
    planel:Hide()
    planel:SetSize(500, 150)
    planel:SetPoint('CENTER', 'UIParent', 'CENTER', 0, 250)
    planel:SetToplevel(true)
    
    planel.title = planel:CreateFontString(nil, 'overlay')
    planel.title:SetFont(DEFAULT_CHAT_FRAME:GetFont(), 16)
    planel.title:SetPoint('TOP', planel, 'TOP', 0, 0)
    planel.title:SetSize(INFO.DEFAULT_PLANEL_WIDTH, 38)
    planel.title:SetText(L.EXPORT_TITLE_TEXT)
    planel.title:SetTextColor(225, 225, 225, 1)

    planel.editBox = CreateFrame('EditBox', nil, planel, 'InputBoxTemplate')
    planel.editBox:SetSize(400, 100)
    planel.editBox:SetPoint('TOP', planel, 'TOP', 0, -10)
    planel.editBox:SetMovable(false)
    planel.editBox:SetMultiLine(false)

    planel.editBtn0 = CreateFrame('Button', nil, planel, 'GameMenuButtonTemplate')
    planel.editBtn0:SetPoint('LEFT', planel, 'BOTTOM', -200, 40)
    planel.editBtn0:SetSize(120, 30)
    planel.editBtn0:SetText(L.EXPORT_COVER_BTN_TEXT)
    planel.editBtn0:SetNormalFontObject('GameFontNormal')
    planel.editBtn0:SetHighlightFontObject('GameFontHighlight')

    planel.editBtn1 = CreateFrame('Button', nil, planel, 'GameMenuButtonTemplate')
    planel.editBtn1:SetPoint('CENTER', planel, 'BOTTOM', 0, 40)
    planel.editBtn1:SetSize(120, 30)
    planel.editBtn1:SetText(L.EXPORT_MERGE_BTN_TEXT)
    planel.editBtn1:SetNormalFontObject('GameFontNormal')
    planel.editBtn1:SetHighlightFontObject('GameFontHighlight')

    planel.editBtn2 = CreateFrame('Button', nil, planel, 'GameMenuButtonTemplate')
    planel.editBtn2:SetPoint('RIGHT', planel, 'BOTTOM', 200, 40)
    planel.editBtn2:SetSize(120, 30)
    planel.editBtn2:SetText(L.EXPORT_CLOSE_BTN_TEXT)
    planel.editBtn2:SetNormalFontObject('GameFontNormal')
    planel.editBtn2:SetHighlightFontObject('GameFontHighlight')

    planel.editBtn0:SetScript('OnClick', function() 
        _G[INFO.ADDON_BASE_NAME].Actions.importSettings(planel.editBox:GetText(), INFO.EXPORT_TYPE_COVER)
    end)
    planel.editBtn1:SetScript('OnClick', function() 
        _G[INFO.ADDON_BASE_NAME].Actions.importSettings(planel.editBox:GetText(), INFO.EXPORT_TYPE_MERGE)
    end)
    planel.editBtn2:SetScript('OnClick', function() Export.close() end)

    Export.planel = planel
end


Export.open = function(text)
    local planel = Export.planel
    local players = WATCHDOG_DB.players
    local str = INFO.DEFAULT_EXPORT_SEP
    local len = 0

    for k, v in pairs(players) do
        len = len + 1
        str = str..k..INFO.DEFAULT_EXPORT_SEP
    end
    if len == 0 then str = '' end

    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    planel.editBox:SetText(Utils.encode(str))
    planel:Show()
    planel.editBox:SetAutoFocus()
end

Export.close = function(text)
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    Export.planel:Hide()
    Export.planel.editBox:SetText('')
    collectgarbage('collect')
end

_G[INFO.ADDON_BASE_NAME].Components.Export = Export

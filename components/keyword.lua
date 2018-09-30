local INFO = WATCHDOG_VARS.INFOS
local L = LibStub("AceLocale-3.0"):GetLocale(INFO.ADDON_BASE_NAME, false)
local Keyword = {}

Keyword.init = function( ... )
    local planel = CreateFrame('Frame', INFO.KEYWORD_PLANEL_FRAME, UIParent, 'TranslucentFrameTemplate')
    planel:SetSize(500, 400)
    planel:SetPoint('CENTER', 'UIParent', 'CENTER', 0, 250)
    planel:SetToplevel(true)


end

_G[INFO.ADDON_BASE_NAME].Components.Keyword = Export

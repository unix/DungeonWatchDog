local addon = LibStub('AceAddon-3.0'):GetAddon('DungeonWatchDog')
local Constants = addon:NewModule('Constants')

local infos = {
    ADDON_BASE_NAME = 'DungeonWatchDog',
    VERSION = '2.2.1',
    EXPORT_PLANEL_FRAME = 'exportPanelFrame',
    KEYWORD_PLANEL_FRAME = 'keywordPanelFrame',
    DEFAULT_EXPORT_SEP = '0Z0',
    EXPORT_TYPE_COVER = 'cover',
    EXPORT_TYPE_MERGE = 'merge',
}

function Constants:GetInfos()
    return infos
end

local ADDON_NAME = GetAddOnMetadata(..., 'Title')
local ADDON_VERSION = GetAddOnMetadata(..., 'Version')
local addon = LibStub('AceAddon-3.0'):GetAddon(ADDON_NAME)
local Constants = addon:NewModule('Constants')

local infos = {
    ADDON_BASE_NAME = ADDON_NAME,
    VERSION = ADDON_VERSION,
    EXPORT_PLANEL_FRAME = 'exportPanelFrame',
    KEYWORD_PLANEL_FRAME = 'keywordPanelFrame',
    DEFAULT_EXPORT_SEP = '0Z0',
    EXPORT_TYPE_COVER = 'cover',
    EXPORT_TYPE_MERGE = 'merge',
    PGF_NAME = 'PremadeGroupsFilter',
    ADDON_COMM_BASE = ADDON_NAME,
    ADDON_COMM_IGNORE_SHARE = 'WATCH_DOG_IG',
    ADDON_COMM_IGNORE_SHARE_ONCE = 'WATCH_DOG_IG_O',
}

function Constants:GetInfos()
    return infos
end

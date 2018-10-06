
local infos = {
    ADDON_BASE_NAME = 'DungeonWatchDog',
    VERSION = '2.0.0',
    IGNORE_PLANEL_FRAME = 'ignorePanelFrame',
    EXPORT_PLANEL_FRAME = 'exportPanelFrame',
    KEYWORD_PLANEL_FRAME = 'keywordPanelFrame',
    BACKDROP_PLANEL = {
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    },
    TEXTURE_PLANEL_TITLE = 'Interface\\ChatFrame\\ChatFrameBackground',
    BACKDROP_PLANEL_SCROLL_ITEM_LAYER = {
        bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    },
    DEFAULT_PLANEL_WIDTH = 270,
    COLOR_PLANEL_SCROLL_ITEM_TEXT = {
        R = 0.137,
        G = 0.453,
        B = 0.777,
        A = 1,
    },
    DEFAULT_EXPORT_SEP = '0Z0',
    EXPORT_TYPE_COVER = 'cover',
    EXPORT_TYPE_MERGE = 'merge',
}

WATCHDOG_VARS.INFOS = infos

_G[infos.ADDON_BASE_NAME] = {}

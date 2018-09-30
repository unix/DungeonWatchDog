local INFO = WATCHDOG_VARS.INFOS
local L = LibStub("AceLocale-3.0"):GetLocale(INFO.ADDON_BASE_NAME, false)
local Ignores = {}

Ignores.init = function()
    -- local planel = CreateFrame('Frame', INFO.EXPORT_PLANEL_FRAME, UIParent, 'TranslucentFrameTemplate')
    local planel = CreateFrame('Frame', INFO.IGNORE_PLANEL_FRAME, UIParent)
    planel:Hide()
    planel:SetSize(INFO.DEFAULT_PLANEL_WIDTH, 450)
    planel:ClearAllPoints()
    planel:SetPoint('CENTER', 'UIParent', 'CENTER', 0, 0)
    planel:SetBackdrop(INFO.BACKDROP_PLANEL)
    planel:SetBackdropColor(0, 0, 0, 0.5)
    planel:SetMovable(true)
    planel:EnableMouse(true)
    planel:SetToplevel(true)

    local showTooltip = function(title, desc)
        GameTooltip:SetOwner(planel, 'ANCHOR_NONE')
        GameTooltip:SetPoint('BOTTOMLEFT', planel, 'BOTTOMRIGHT', 1, 0)
        GameTooltip:AddLine(title,
        INFO.COLOR_PLANEL_SCROLL_ITEM_TEXT.R,
        INFO.COLOR_PLANEL_SCROLL_ITEM_TEXT.G,
        INFO.COLOR_PLANEL_SCROLL_ITEM_TEXT.B)
        GameTooltip:AddLine(' ', 1, 1, 1)
        GameTooltip:AddLine(desc, 1, 1, 1)
        GameTooltip:Show()
    end
    local hideTooltip = function()
        GameTooltip:SetText(' ')
        GameTooltip:Hide()
    end

    local titleBarDragLayer = CreateFrame('Frame', INFO.IGNORE_PLANEL_FRAME, planel)
    titleBarDragLayer:SetSize(INFO.DEFAULT_PLANEL_WIDTH, 38)
    titleBarDragLayer:SetPoint('TOP', planel, 'TOP', 0, 0)

    titleBarDragLayer:SetMovable(true)
    titleBarDragLayer:EnableMouse(true)
    titleBarDragLayer:RegisterForDrag('LeftButton')
    titleBarDragLayer:SetScript('OnDragStart', function(s, b) planel:StartMoving() end)
    titleBarDragLayer:SetScript('OnDragStop', function(s, b) planel:StopMovingOrSizing() end)

    local titleBg = titleBarDragLayer:CreateTexture('BagBuddy_Icon', 'BACKGROUND')
    titleBg:SetSize(INFO.DEFAULT_PLANEL_WIDTH, 38)
    titleBg:SetPoint('TOP', planel, 'TOP', 0, 0)
    titleBg:SetTexture(INFO.TEXTURE_PLANEL_TITLE)
    titleBg:SetVertexColor(0, 0, 0, 0.5)

    planel.title = titleBarDragLayer:CreateFontString(nil, 'overlay')
    planel.title:SetFont(DEFAULT_CHAT_FRAME:GetFont(), 16)
    planel.title:SetPoint('TOP', planel, 'TOP', 0, 0)
    planel.title:SetSize(INFO.DEFAULT_PLANEL_WIDTH, 38)
    planel.title:SetText(L.BANNED_LIST_TITLE)
    planel.title:SetTextColor(225, 225, 225, 1)

    -- planel.closeBtn = CreateFrame('Button', nil, planel)
    -- planel.closeBtn:SetPoint('BOTTOM', planel, 'BOTTOM', 0, 0)
    -- planel.closeBtn:SetSize(INFO.DEFAULT_PLANEL_WIDTH, 40)
    -- planel.closeBtn:SetText(L.BANNED_LIST_CLOSE)
    -- planel.closeBtn:SetNormalFontObject('GameFontHighlightHuge')
    -- planel.closeBtn:SetScript('OnClick', function() Ignores.close() end)

    planel.exportBtn = CreateFrame('Button', nil, planel)
    planel.exportBtn:SetPoint('BOTTOMLEFT', planel, 'BOTTOMLEFT', 0, 0)
    planel.exportBtn:SetSize(INFO.DEFAULT_PLANEL_WIDTH / 2, 40)
    planel.exportBtn:SetText(L.EXPORT_TITLE_TEXT)
    planel.exportBtn:SetNormalFontObject('GameFontNormal')
    planel.exportBtn:SetScript('OnEnter', function()
        showTooltip(L.BANNED_LIST_EXPORT_BTN_TIPS_TITLE, L.BANNED_LIST_EXPORT_BTN_TIPS_DESC)
    end)
    planel.exportBtn:SetScript('OnLeave', function() hideTooltip() end)
    planel.exportBtn:SetScript('OnClick', function()
        Ignores.close()
        _G[INFO.ADDON_BASE_NAME].Components.Export.open()
    end)

    planel.closeBtn = CreateFrame('Button', nil, planel)
    planel.closeBtn:SetPoint('BOTTOMRIGHT', planel, 'BOTTOMRIGHT', 0, 0)
    planel.closeBtn:SetSize(INFO.DEFAULT_PLANEL_WIDTH / 2, 40)
    planel.closeBtn:SetText(L.BANNED_LIST_CLOSE)
    planel.closeBtn:SetNormalFontObject('GameFontNormal')
    planel.closeBtn:SetScript('OnClick', function() Ignores.close() end)

    -- planel.filterBtn = CreateFrame('Button', nil, planel)
    -- planel.filterBtn:SetPoint('BOTTOMRIGHT', planel, 'BOTTOMRIGHT', 0, 0)
    -- planel.filterBtn:SetSize(INFO.DEFAULT_PLANEL_WIDTH / 2, 40)
    -- planel.filterBtn:SetText('过滤')
    -- planel.filterBtn:SetNormalFontObject('GameFontNormal')
    -- planel.filterBtn:SetScript('OnEnter', function()
    --     showTooltip('过滤名单', '清理屏蔽列表内最近 5 天没有发起活动的玩家。这可以精简列表的大小。')
    -- end)
    -- planel.filterBtn:SetScript('OnLeave', function() hideTooltip() end)


    local updateScrollContainer = function()
        if Ignores.planel.scrollContainer then 
            Ignores.planel.scrollContainer:Hide()
            Ignores.planel.scrollContainer:UnregisterAllEvents()
            Ignores.planel.scrollContainer:SetID(0)
            Ignores.planel.scrollContainer:ClearAllPoints()
            Ignores.planel.scrollContainer = nil
            collectgarbage('collect')
        end
        local planel = Ignores.planel

        local scrollContainer = CreateFrame('ScrollFrame', nil, planel, 'UIPanelScrollFrameTemplate1')
        scrollContainer:SetPoint('TOPLEFT', planel, 'TOPLEFT', 0, -39)
        scrollContainer:SetSize(planel:GetWidth(), planel:GetHeight() - 82)
    
        local scrollBg = scrollContainer:CreateTexture(nil, 'BACKGROUND') 
        scrollBg:SetSize(scrollContainer:GetWidth(), scrollContainer:GetHeight())
        scrollBg:SetPoint('TOP', scrollContainer, 'TOP', 0, 0)
        scrollBg:SetTexture(INFO.TEXTURE_PLANEL_TITLE)
        scrollBg:SetVertexColor(0, 0, 0, 0.2)
        scrollContainer:EnableMouseWheel(true)
        Ignores.planel.scrollContainer = scrollContainer
    end

    local updateScrollChilds = function(players)
        local content = CreateFrame('Frame', nil, scrollframea)
        content:SetSize(planel.scrollContainer:GetWidth(), planel.scrollContainer:GetHeight())

        local resetPoints = function(elements)
            local i = 1
            for k = 1, #elements do 
                if not elements[k].removed then 
                    elements[k]:SetPoint('TOPLEFT', content, 0, -40 * (i - 1))
                    i = i + 1
                end
            end
        end

        local items = {}
        local i = 0
        for k, player in pairs(players) do 
            i = i + 1
            local width = content:GetWidth()
            local item = CreateFrame('Frame', nil, content)
            item:SetSize(width, 32)
            item:SetPoint('TOPLEFT', content, 0, -40 * (i - 1))
            item:SetScript('OnEnter', function(self) self.layer:Show() end)
            item:SetScript('OnLeave', function(self) self.layer:Hide() end)

            item.layer = CreateFrame('Frame', nil, item)
            item.layer:SetSize(width, 32)
            item.layer:SetPoint('TOPLEFT', item, 'TOPLEFT', 0, 0)
            item.layer:SetBackdrop(INFO.BACKDROP_PLANEL_SCROLL_ITEM_LAYER)
            item.layer:SetAlpha(0.4)
            item.layer:Hide()

            local itemStr = item:CreateFontString(nil)
            itemStr:SetFont(DEFAULT_CHAT_FRAME:GetFont(), 14)
            itemStr:SetJustifyH('LEFT')
            itemStr:SetPoint('TOPLEFT', item, 'TOPLEFT', 20, 0)
            itemStr:SetSize(width - 20, item:GetHeight())
            itemStr:SetText(player.name)
            itemStr:SetTextColor(
                INFO.COLOR_PLANEL_SCROLL_ITEM_TEXT.R,
                INFO.COLOR_PLANEL_SCROLL_ITEM_TEXT.G,
                INFO.COLOR_PLANEL_SCROLL_ITEM_TEXT.B,
                INFO.COLOR_PLANEL_SCROLL_ITEM_TEXT.A)

            local itemBtn = CreateFrame('Button', nil, item)
            itemBtn:SetPoint('RIGHT', item, 'RIGHT', -24, 0)
            itemBtn:SetSize(20, 20)
            itemBtn:SetText(L.BANNED_LIST_CANCEL)
            itemBtn:SetNormalFontObject('GameTooltipTextSmall')
            itemBtn:SetScript('OnClick', function() 
                _G[INFO.ADDON_BASE_NAME].Actions.unbanPlayerWithName(player.name)
                item:SetSize(width, 0)
                item.layer:SetSize(width, 0)
                item.removed = true
                resetPoints(Ignores.planel.scrollContainer.childs)
                Ignores.updatePlayerCount(Ignores.lastPlayerCount - 1)
                Ignores.planel.scrollContainer:UpdateScrollChildRect()
            end)
            table.insert(items, item)
        end
        Ignores.planel.scrollContainer.childs = items
        Ignores.planel.scrollContainer:SetScrollChild(content)
    end
    
    Ignores.planel = planel
    Ignores.update = function(palyers, len) 
        updateScrollContainer()
        updateScrollChilds(palyers) 
    end
end

Ignores.updatePlayerCount = function(next)
    if next < 0 then return end
    Ignores.lastPlayerCount = next
    Ignores.planel.title:SetText(string.format(L.BANNED_LIST_TITLE, next))
end

Ignores.close = function()
    Ignores.isShow = false
    Ignores.planel:Hide()
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    collectgarbage('collect')
end

Ignores.open = function()
    local planel = Ignores.planel
    local players = WATCHDOG_DB.players
    local len = 0
    for k, v in pairs(players) do 
        len = len + 1
    end
    if not players or len == 0 then 
        return _G[INFO.ADDON_BASE_NAME].Actions.log(L.BANNED_LIST_NOTFOUND)
    end
    Ignores.updatePlayerCount(len)
    Ignores.update(players, len)
    Ignores.isShow = true
    Ignores.planel:Show()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
end

Ignores.updateCountInShow = function()
    if Ignores.isShow then Ignores.open() end
end

Ignores.isShow = false

_G[INFO.ADDON_BASE_NAME].Components.Ignores = Ignores

local addon = LibStub('AceAddon-3.0'):GetAddon('DungeonWatchDog')
local L = LibStub("AceLocale-3.0"):GetLocale('DungeonWatchDog', false)
local AceConfig, AceConfigDialog, AceGUI  = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0'), LibStub('AceGUI-3.0')
local Settings = addon:NewModule('Settings')
local infos = addon:GetModule('Constants'):GetInfos()
local Utils = addon:GetModule('Utils')
local Actions = addon:GetModule('Actions')
local options = {}

options = {
    type = 'group',
    args = {
        portalOptions = {
            name = L.SETTINGS_PORTAL_NAME,
            type = 'group',
            order = 1,
            args = {
                portalHander = {
                    name = L.SETTINGS_PORTAL_HEADER,
                    type = 'header',
                    order = 1,
                },
                portalDesc = {
                    name = L.SETTINGS_PORTAL_DESC,
                    type = 'description',
                    order = 2,
                },
                portalToggle1 = {
                    name = L.SETTINGS_PORTAL_TOGGLE1,
                    type = 'toggle',
                    order = 3,
                    width = '0.5',
                    tristate = false,
                    get = function (info)
                        local count = Utils:tableLength(WATCHDOG_DB.players)
                        info.options.args.portalOptions.args.portalStatusAll.name = L.SETTINGS_PORTAL_STATUS_ALL..count
                        info.options.args.portalOptions.args.portalVersion.name = L.SETTINGS_PORTAL_VERSION..infos.VERSION
                        return (WATCHDOG_DB.defaultFilterToggle and true) or false
                    end,
                    set = function (info, t)
                        WATCHDOG_DB.defaultFilterToggle = t
                    end
                },
                portalSep = {
                    name = ' ',
                    type = 'description',
                    order = 4,
                },
                portalToggle2 = {
                    name = L.SETTINGS_PORTAL_TOGGLE2,
                    type = 'toggle',
                    order = 5,
                    width = '0.5',
                    tristate = false,
                    get = function (info)
                        return (WATCHDOG_DB.versionMessageToggle and true) or false
                    end,
                    set = function (info, t)
                        WATCHDOG_DB.versionMessageToggle = t
                    end
                },
                portalStatusAll = {
                    name = ' ',
                    type = 'description',
                    order = 6,
                },
                portalVersion = {
                    name = ' ',
                    type = 'description',
                    order = 7,
                },
            },
        },
        ignoreListOptions = {
            name = L.SETTINGS_IGNORE_LIST_NAME,
            type = 'group',
            order = 2,
            args = {
                ignoreListHander = {
                    name = L.SETTINGS_IGNORE_LIST_HEADER,
                    type = 'header',
                    order = 1,
                },
                ignoreListDesc = {
                    name = L.SETTINGS_IGNORE_LIST_DESC,
                    type = 'description',
                    order = 2,
                },
                ignoreListBtn1 = {
                    name = L.SETTINGS_IGNORE_LIST_BTN1,
                    descStyle = 'online',
                    type = 'execute',
                    width = '0.5',
                    hidden = false,
                    func = function (info)
                        -- reset export string
                        info.options.args.exportOptions.args.exportInput.get = function()
                            return ''
                        end

                        local Components = addon:GetModule('Components', true)
                        if not Components then return end
                        Components:get('IgnoreList'):open()
                        AceConfigDialog:Close(L.ADDON_SHOW_NAME)
                    end
                },
            },
        },
        exportOptions={
            name = L.SETTINGS_EXPORT_NAME,
            type = 'group',
            order = 3,
            args = {
                exportHander = {
                    name = L.SETTINGS_EXPORT_HEADER,
                    type = 'header',
                    order = 1,
                },
                exportDesc = {
                    name = L.SETTINGS_EXPORT_DESC,
                    type = 'description',
                    order = 2,
                },
                exportBtn1 = {
                    name = L.SETTINGS_EXPORT_BTN1,
                    type = 'execute',
                    width = '0.5',
                    order = 4,
                    func = function(info)
                        local players, str, len = WATCHDOG_DB.players, infos.DEFAULT_EXPORT_SEP, 0
                    
                        for k, v in pairs(players) do
                            len = len + 1
                            str = str..k..infos.DEFAULT_EXPORT_SEP
                        end
                        if len == 0 then str = '' end
                    
                        info.options.args.exportOptions.args.exportInput.get = function()
                            return Utils:encode(str)
                        end
                    end,
                },
                exportInput = {
                    name = ' ',
                    desc = L.SETTINGS_EXPORT_INPUT,
                    type = 'input',
                    width = 'full',
                    order = 5,
                    multiline = true,
                    set = function(info, val) 
                        Actions:importSettings(val, infos.EXPORT_TYPE_COVER)
                    end,
                },
            }
        },
        ignoreClearOptions = {
            name = L.SETTINGS_CLEAR_NAME,
            type = 'group',
            order = 10,
            args = {
                ignoreClearHander = {
                    name = L.SETTINGS_CLEAR_HEADER,
                    type = 'header',
                    order = 1,
                },
                ignoreClearDesc = {
                    name = L.SETTINGS_CLEAR_DESC,
                    type = 'description',
                    order = 2,
                },
                ignoreClearBtn1 = {
                    name = L.SETTINGS_CLEAR_BTN1,
                    type = 'execute',
                    width = '0.5',
                    func = function()
                        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
                        StaticPopup_Show('WATCH_DOG_CANCEL_ALL_CONFIRM')
                    end
                },
            },
        },
    }

}

function Settings:OnInitialize()
    StaticPopupDialogs['WATCH_DOG_CANCEL_ALL_CONFIRM'] = {
        text = L.SETTINGS_CLEAR_CONFIR,
        button1 = OKAY,
        button2 = NO,
        hideOnEscape = true,
        timeout = 0,
        exclusive = true,
        showAlert = true,
        OnAccept = function(self)
            PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
            Actions:unbanAllplayers()
        end,
        OnCancel = function(self)
            PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
            StaticPopup_Hide('WATCH_DOG_CANCEL_ALL_CONFIRM')
        end,
    }

    local AceFrame = AceGUI:Create('Frame')
    AceFrame:Hide()
    AceFrame:SetCallback('OnClose', function (w) 
        AceGUI:Release(w) 
    end)
    AceConfig:RegisterOptionsTable(L.ADDON_SHOW_NAME, options)
    AceFrame:SetTitle(L.ADDON_SHOW_NAME)
    AceFrame:SetStatusText(' ')
    AceFrame:SetLayout('Flow')
    AceFrame:Hide()
    AceConfigDialog:AddToBlizOptions(L.ADDON_SHOW_NAME, L.ADDON_SHOW_NAME)
    AceConfigDialog:SetDefaultSize(L.ADDON_SHOW_NAME, 600, 500)
end

function Settings:Open()
    AceConfigDialog:Open(L.ADDON_SHOW_NAME, AceFrame)
end

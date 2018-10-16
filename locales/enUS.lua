local addon = LibStub('AceAddon-3.0'):GetAddon('DungeonWatchDog')
local infos = addon:GetModule('Constants'):GetInfos()
local L = LibStub("AceLocale-3.0"):NewLocale(infos.ADDON_BASE_NAME, "enUS", true)


L['ADDON_SHOW_NAME'] = 'DUNGEON WATCH DOG'
L['SEARCH_MENU_TEXT'] = 'ignore player'
L['SEARCH_MENU_TOOLIP_TITLE'] = 'Ignore the player'
L['SEARCH_MENU_TOOLIP_TEXT'] = 'After ignoring, you will not see any team from this player.'
L['NOT_FOUND_PLAYER_NAME'] = 'Not found player name'
L['NOT_FOUND_PLAYER_NAME_FROM_BANNEDS'] = 'Unknown'
L['VERSION_EXPIRED'] = 'current version expired'
L['WELCOME_MESSAGE'] = 'Thank you for using, you can click the right button in the Dungeon Finder Panel to ignore the player. Input “/wd” in chat bar to learn more commands.'
L['BANNED_LIST_TITLE'] = 'Ignore list'
L['BANNED_LIST_CANCEL'] = 'Cancel Ignore'
L['BANNED_LIST_COUNT'] = 'Count: '

L['BANNED_LIST_EXPORT_BTN'] = 'Import/Export'
L['BANNED_LIST_EXPORT_BTN_TIPS_TITLE'] = 'Import / Export'
L['BANNED_LIST_EXPORT_BTN_TIPS_DESC'] = 'Import / Export ignore list，you can choose to overwrite or merge existing ignored list.'
L['ACTION_BAN_MESSAGE'] = 'has been ignored'
L['ACTION_UNBAN_MESSAGE'] = 'has been removed from ignore list'
L['EXPORT_TEXT_EMPTY'] = 'no player found'
L['EXPORT_TEXT_ERROR'] = 'error setting string'
L['EXPORT_SUCCESS'] = 'Import has finished, a total of %s players'
L['EXPORT_TIPS_WITH_TYPE_COVER'] = 'Importing data is overriding the original ignore list.'
L['EXPORT_TIPS_WITH_TYPE_MERGE'] = 'Importing data is merging in the original ignore list.'
L['EXPORT_TITLE_TEXT'] = 'Import / Export'
L['EXPORT_COVER_BTN_TEXT'] = 'Cover import'
L['EXPORT_MERGE_BTN_TEXT'] = 'Merge import'
L['EXPORT_CLOSE_BTN_TEXT'] = 'Close'
L['SLASH_TIPS_SHOW'] = 'show control panel'
L['SLASH_TIPS_EXPORT'] = 'show export panel'
L['SLASH_TIPS_CLEAR'] = 'clear all ignore lists'
L['SLASH_TIPS_VERSION'] = 'show addon version'
L['CLEAR_BAN_LIST_SUCCESS'] = 'all ignore lists have been cleared'
L['IGNORE_ALL_NOT_FOUND_PLAYER'] = 'no player found in search results'
L['IGNORE_ALL_COMPLETED'] = '%s players have been ignored'
L['IGNORE_ALL_BTN_TEXT'] = 'ignore all'
L['IGNORE_ALL_CONFIRM_TEXT'] = 'WatchDog: This will ignore all players of the current search results. Are you sure ?'

L['MEETINGSTONE_APPLY_TEXT'] = 'APPLY'
L['MEETINGSTONE_IGNORE_TITLE'] = 'IGNORE [WATCH_DOG]'
L['MEETINGSTONE_IGNORE_TOOLTIP_TITLE'] = 'Ignore this player'
L['MEETINGSTONE_IGNORE_TOOLTIP_DESC'] = 'After ignoring, you will not see any team from this player.'


L['SETTINGS_PORTAL_NAME'] = 'Global'
L['SETTINGS_PORTAL_HEADER'] = 'Global'
L['SETTINGS_PORTAL_DESC'] = '\nGlobal Settings\n\n'
L['SETTINGS_PORTAL_TOGGLE1'] = 'Enable default filter'
L['SETTINGS_PORTAL_TOGGLE2'] = 'Remind me when version updated'
L['SETTINGS_PORTAL_STATUS_ALL'] = '\n\n\nIgnore list count: '
L['SETTINGS_PORTAL_VERSION'] = '\nCurrent version: v'
L['SETTINGS_IGNORE_LIST_NAME'] = 'Ignore list'
L['SETTINGS_IGNORE_LIST_HEADER'] = 'Ignore list'
L['SETTINGS_IGNORE_LIST_DESC'] = '\nClick to open the ignore list to see details.\n\n'
L['SETTINGS_IGNORE_LIST_BTN1'] = 'Show ignore list'
L['SETTINGS_EXPORT_NAME'] = 'Improt/Export'
L['SETTINGS_EXPORT_HEADER'] = 'Improt / Export'
L['SETTINGS_EXPORT_DESC'] = '\nYou can share your list with others by Export, and you can also import a string.\n\nImporting a string will cover your ignore list.\n'
L['SETTINGS_EXPORT_BTN1'] = 'Generate export string'
L['SETTINGS_EXPORT_INPUT'] = 'Export string'
L['SETTINGS_CLEAR_NAME'] = 'Clean'
L['SETTINGS_CLEAR_HEADER'] = 'Clean up all'
L['SETTINGS_CLEAR_DESC'] = '\nThis clears all ignore lists and is not recoverable.\n\n'
L['SETTINGS_CLEAR_BTN1'] = 'Clear up'
L['SETTINGS_CLEAR_CONFIR'] = 'This operation will empty ignore list and cannot be resumed. Are you sure you want to do that?'



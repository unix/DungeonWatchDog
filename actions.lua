local INFO = WATCHDOG_VARS.INFOS
local L = LibStub("AceLocale-3.0"):GetLocale(INFO.ADDON_BASE_NAME, false)
local actions = {}

actions.banPlayerWithID = function(id)
    local info = {C_LFGList.GetSearchResultInfo(id)}
    local leaderName = info[13]
    if leaderName == nil then return SendSystemMessage(L.NOT_FOUND_PLAYER_NAME) end
    AddIgnore(leaderName)
end

actions.findBannedPlayers = function()
    local players = {}
    local count = GetNumIgnores()
    if count == 0 then return players end

    for i = 1, count do
        local name = GetIgnoreName(i)
        if name ~= nil and name ~= L.NOT_FOUND_PLAYER_NAME_FROM_BANNEDS then
            players[name] = 1
        end
    end
    return players
end

Actions = actions



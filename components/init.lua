local INFO = WATCHDOG_VARS.INFOS
if not _G[INFO.ADDON_BASE_NAME].Components then _G[INFO.ADDON_BASE_NAME].Components = {} end

_G[INFO.ADDON_BASE_NAME].Components.init = function()
    for k, v in pairs(_G[INFO.ADDON_BASE_NAME].Components) do
        if k ~= 'init' and type(v.init) == 'function' then
            v.init()
        end
    end
end

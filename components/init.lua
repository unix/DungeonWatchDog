local addon = LibStub('AceAddon-3.0'):GetAddon('DungeonWatchDog')
local Components = addon:NewModule('Components')
local Ignores = addon:GetModule('Ignores')
local Settings = addon:GetModule('Settings')
local IgnoreAll = addon:GetModule('IgnoreAll')

function Components:OnInitialize()
    self.refs = {
        ['Ignores'] = Ignores,
        ['Settings'] = Settings,
        ['IgnoreAll'] = IgnoreAll,
    }
end

function Components:get(name)
    if not self.refs[name] then return nil end
    return self.refs[name]
end

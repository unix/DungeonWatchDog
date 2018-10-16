local addon = LibStub('AceAddon-3.0'):GetAddon('DungeonWatchDog')
local Components = addon:NewModule('Components')
local Settings = addon:GetModule('Settings')
local IgnoreAll = addon:GetModule('IgnoreAll')
local IgnoreList = addon:GetModule('IgnoreList')

function Components:OnInitialize()
    self.refs = {
        ['Settings'] = Settings,
        ['IgnoreAll'] = IgnoreAll,
        ['IgnoreList'] = IgnoreList,
    }
end

function Components:get(name)
    if not self.refs[name] then return nil end
    return self.refs[name]
end

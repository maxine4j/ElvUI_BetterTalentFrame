local E, L, V, P, G = unpack(ElvUI) -- Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local BTF = E:NewModule("BetterTalentsFrame_Config", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")
local EP = LibStub("LibElvUIPlugin-1.0")
local addonName, addonTable = ...

-- defaults
P["BetterTalentsFrame"] = {
	["AutoHidePvPTalents"] = false,
}

function BTF:InsertOptions()
	E.Options.args.BetterTalentsFrame = {
		order = 100,
		type = "group",
		name = "|cfffe7b2cBetterTalentsFrame|r",
		args = {
			AutoHidePvPTalents = {
				order = 1,
				type = "toggle",
				name = "Auto Hide PvP Talents",
				get = function(info)
					return E.db.BetterTalentsFrame.AutoHidePvPTalents
				end,
				set = function(info, value)
					E.db.BetterTalentsFrame.AutoHidePvPTalents = value
					BetterTalentsFrame:Update()
				end,
			},
		},
	}
end

function BTF:Initialize()
	EP:RegisterPlugin(addonName, BTF.InsertOptions)
end

E:RegisterModule(BTF:GetName())
--[[
    ElvUI_BetterTalentFrame
    Copyright (C) Arwic-Frostmourne, All rights reserved.
]]--

-- ElvUI
local E, L, V, P, G = unpack(ElvUI) -- Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")
local TP = E:NewModule("BetterTalentsFrame_TalentProfiles", "AceHook-3.0", "AceEvent-3.0")
local TFR = E:GetModule("BetterTalentsFrame_TalentFrameRework")

-- Config
local btn_sepX = 10
local btn_width = 80
local btn_height = 23

---------- Helpers ----------

function TP:Print(s)
    print("|cfffe7b2cElvUI BetterTalentFrame:|r " .. s)
end

-- Returns the talent info for each talent the user currently has available
function TP:GetTalentInfos()
    local talentInfos = {}
    local k = 1
    for i = 1, GetMaxTalentTier() do
        for j = 1, 3 do
            local talentID, name, texture, selected, available, spellid, tier, column = GetTalentInfo(i, j, GetActiveSpecGroup())
            talentInfos[k] = {}
            talentInfos[k].talentID = talentID
            talentInfos[k].name = name
            talentInfos[k].texture = texture
            talentInfos[k].selected = selected
            talentInfos[k].available = available
            talentInfos[k].spellid = spellid
            talentInfos[k].tier = tier
            talentInfos[k].column = column
            k = k + 1
        end
    end
    return talentInfos
end

-- Returns the talent info for each talent the user currently has available
function TP:GetPvpTalentInfos()
    return C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
end

---------- Database ----------

-- ensures the db is valid
function TP:VerifyDB()
    -- Make sure the base DB table exists
    if ElvUI_BetterTalentFrameGlobalDB == nil then ElvUI_BetterTalentFrameGlobalDB = {} end
    -- Make sure the current class DB exists
    if ElvUI_BetterTalentFrameGlobalDB[self.playerClass] == nil then ElvUI_BetterTalentFrameGlobalDB[self.playerClass] = {} end
    -- Make sure the current class' specs table exists
    if ElvUI_BetterTalentFrameGlobalDB[self.playerClass].specs == nil then ElvUI_BetterTalentFrameGlobalDB[self.playerClass].specs = {} end
    -- Make sure each spec exists
    for i = 1, GetNumSpecializations() do
        -- Make sure the current spec's table exists
        if ElvUI_BetterTalentFrameGlobalDB[self.playerClass].specs[i] == nil then ElvUI_BetterTalentFrameGlobalDB[self.playerClass].specs[i] = {} end
        -- Make sure the profiles DB exists
        if ElvUI_BetterTalentFrameGlobalDB[self.playerClass].specs[i].profiles == nil then ElvUI_BetterTalentFrameGlobalDB[self.playerClass].specs[i].profiles = {} end
    end
end

-- Returns a profile at the given index
function TP:GetProfile(index)
    return ElvUI_BetterTalentFrameGlobalDB[self.playerClass].specs[GetSpecialization()].profiles[index]
end

-- Returns a list of all profiles for the current spec
function TP:GetAllProfiles()
    return ElvUI_BetterTalentFrameGlobalDB[self.playerClass].specs[GetSpecialization()].profiles
end

-- Inserts a new profile into the current spec's DB
function TP:InsertProfile(profile)
    table.insert(ElvUI_BetterTalentFrameGlobalDB[self.playerClass].specs[GetSpecialization()].profiles, profile)
end

-- Removes the profile at the given index from the current spec's DB
function TP:RemoveProfile(index)
    table.remove(ElvUI_BetterTalentFrameGlobalDB[self.playerClass].specs[GetSpecialization()].profiles, index)
end

---------- Action Buttons (Add, Apply, Save, Remove) ----------

-- Dialogue that enables the user to name a new profile
StaticPopupDialogs["TALENTPROFILES_ADD_PROFILE"] = {
    text = "Enter Profile Name:",
    button1 = "Save",
    button2 = "Cancel",
    enterClicksFirstButton = true,
    OnAccept = function(sender)
        local name = sender.editBox:GetText()
        -- Ensure the database is ready
        TP:VerifyDB()
        -- Get basic info
        local talentInfos = TP:GetTalentInfos()
        local profile = {}
        profile.name = name
        profile.talents = {}
        profile.pvpTalents = TP:GetPvpTalentInfos()
        -- Get the currently selected talents
        local i = 1
        for k, v in pairs(talentInfos) do
            if v.selected == true then
                profile.talents[i] = v.talentID
                i = i + 1
            end
        end
        -- Make sure the data is valid
        if i > 8 then
            TP:Print("Error: Too many talents selected")
        end
        -- Save the profile to the database
        TP:InsertProfile(profile)
        -- Rebuild the frame with the new data
        TP:BuildFrame()
        -- Inform the user a profile was added
        TP:Print("Added a new profile: '" .. profile.name .. "'")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    hasEditBox = true,
}
function TP:StaticPopupShow_Add()
    StaticPopup_Show("TALENTPROFILES_ADD_PROFILE")
end

-- Activates the profile at the given index
function TP:ActivateProfile(index)
    -- Don't activate the placeholder profile
    if index ~= "new" then
        -- Get the profile, checking for errors on the way
        local profile = self:GetProfile(index)
        if profile == nil or profile.talents == nil then
            self:Print("Unable to load talent configuration for the selected profile")
            return
        end
        for i = 1, GetMaxTalentTier() do
            LearnTalent(profile.talents[i])
        end
        -- make sure pvp talents table exists
        if profile.pvpTalents == nil then
            profile.pvpTalents = {}
        end
        -- only attempt to learn pvp talents if the profile has any
        if table.length(profile.pvpTalents) == 4 then
            for i = 1, 4 do
                LearnPvpTalent(profile.pvpTalents[i], i)
            end
        end
        -- Inform the user a profile was activated
        self:Print("Activated profile: '" .. profile.name .. "'")
    end
end
function ARWICTP_ActivateProfile(index) -- global for macros
    TP:ActivateProfile(index)
end

-- Saves the current talent configuration to the current profile
function TP:SaveProfile(index)
    -- Don't try and save a profile that doesn't exist
    if table.length(self:GetAllProfiles()) == 0 then
        return
    end
    -- Don't activate the placeholder profile
    if index ~= "new" then
        -- Get the profile, checking for errors on the way
        local profile = self:GetProfile(index)
        if profile == nil then
            self:Print("Unable to load the selected profile")
            return
        end
        -- Update the selected talents
        local talentInfos = self:GetTalentInfos()
        profile.pvpTalents = TP:GetPvpTalentInfos()
        local i = 1
        for k, v in pairs(talentInfos) do
            if v.selected == true then
                profile.talents[i] = v.talentID
                i = i + 1
            end
        end
        -- Inform the user a profile was activated
        self:Print("Saved profile: '" .. profile.name .. "'")
    end
end

-- Dialogue that enables the user to confirm the removal of a profile
StaticPopupDialogs["TALENTPROFILES_REMOVE_PROFILE"] = {
    text = "Do you want to remove the profile '%s'?",
    button1 = "Yes",
    button2 = "No",
    enterClicksFirstButton = true,
    OnAccept = function(sender)
        local key = nil
        local i = 1
        for k, v in pairs(TP:GetProfile(TalentProfiles_profilesDropDown.selectedID)) do
            if i == TalentProfiles_profilesDropDown.selectedID then
                key = k
            end
            i = i + 1
        end
        -- Cache the name
        local name = TP:GetProfile(TalentProfiles_profilesDropDown.selectedID).name
        -- Remove the profile
        TP:RemoveProfile(TalentProfiles_profilesDropDown.selectedID)
        TP:BuildFrame()
        -- Inform the user a profile was removed
        TP:Print("Removed a profile: '" .. name .. "'")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
function TP:StaticPopupShow_Remove()
    local index = TalentProfiles_profilesDropDown.selectedID
    local name = self:GetProfile(index).name
    StaticPopup_Show("TALENTPROFILES_REMOVE_PROFILE", name)
end

-------------------- Initialisation --------------------

function TP:BuildFrame()
    -- Set up main frame, if it doesnt already exist
    local mainFrame = TalentProfiles_main
    if TalentProfiles_main == nil then
        mainFrame = CreateFrame("Frame", "TalentProfiles_main", PlayerTalentFrame)
        mainFrame:SetSize(PlayerTalentFrame.NineSlice:GetWidth(), PlayerTalentFrame.NineSlice:GetHeight())
        mainFrame:SetPoint("CENTER", PlayerTalentFrame.NineSlice, "CENTER", 0, -20)
    end

    -- Set up profiles dropdown, if it doesnt already exist
    local dropdown = TalentProfiles_profilesDropDown
    if TalentProfiles_profilesDropDown == nil then
        dropdown = CreateFrame("Button", "TalentProfiles_profilesDropDown", TalentProfiles_main, "UIDropDownMenuTemplate")
        dropdown:SetPoint("TOPLEFT", TalentProfiles_main, "TOPLEFT", 100, -13)
        -- elvui dropdown skinning is bugged and makes the arrow button far too wide
        S:HandleDropDownBox(dropdown)
        -- so make it the correct size
        TalentProfiles_profilesDropDownButton:SetWidth(TalentProfiles_profilesDropDownButton:GetHeight())
        -- and allow the user to open the dropdown by clicking anywhere on the control
        TalentProfiles_profilesDropDown:SetScript("OnClick", function(...) TalentProfiles_profilesDropDownButton:Click() end)
        -- make the dropdown the same height as the buttons
        TalentProfiles_profilesDropDown:SetHeight(btn_height)
    end
    -- Repopulate the dropdown, even if it already exists
    UIDropDownMenu_Initialize(dropdown, function(sender, level)
        TP:VerifyDB()
        local items = TP:GetAllProfiles()
        local i = 1
        for k, v in pairs(items) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = v.name
            info.value = i
            info.func = function(sender)
                UIDropDownMenu_SetSelectedID(TalentProfiles_profilesDropDown, sender:GetID())
            end
            UIDropDownMenu_AddButton(info, level)
            i = i + 1
        end
        -- Add the new profile item
        local info = UIDropDownMenu_CreateInfo()
        info.text = "Add new profile"
        info.value = "new"
        info.func = function(sender)
            TP:StaticPopupShow_Add()
        end
        info.rgb = { 0.0, 0.0, 1.0, 1.0 }
        UIDropDownMenu_AddButton(info, level)
    end)
    UIDropDownMenu_SetSelectedID(dropdown, 1)
    UIDropDownMenu_JustifyText(dropdown, "LEFT")
    dropdown:Show()

    -- Set up the action buttons
    local btnApply = TalentProfiles_btnApply
    if TalentProfiles_btnApply == nil then
        btnApply = CreateFrame("Button", "TalentProfiles_btnApply", TalentProfiles_main, "UIPanelButtonTemplate")
        btnApply:SetSize(btn_width, btn_height)
        btnApply:SetText("Apply")
        btnApply:SetPoint("TOPLEFT", dropdown, "TOPRIGHT", btn_sepX + 107, -2)
        S:HandleButton(btnApply)
        btnApply:SetScript("OnClick", function(sender)
            TP:VerifyDB()
            -- Check if any profiles exists
            if table.length(TP:GetAllProfiles()) == 0 then
                return
            end
            -- Activate the profile
            TP:ActivateProfile(TalentProfiles_profilesDropDown.selectedID)
        end)
        btnApply:Show()
    end
    local btnSave = TalentProfiles_btnSave
    if TalentProfiles_btnSave == nil then
        btnSave = CreateFrame("Button", "TalentProfiles_btnSave", TalentProfiles_main, "UIPanelButtonTemplate")
        btnSave:SetSize(btn_width, btn_height) -- was w100
        btnSave:SetText("Save")
        btnSave:SetPoint("TOPLEFT", btnApply, "TOPRIGHT", btn_sepX, 0)
        S:HandleButton(btnSave)
        btnSave:SetScript("OnClick", function(sender)
            TP:SaveProfile(TalentProfiles_profilesDropDown.selectedID)
        end)
        btnSave:Show()
    end
    local btnRemove = TalentProfiles_btnRemove
    if TalentProfiles_btnRemove == nil then
        btnRemove = CreateFrame("Button", "TalentProfiles_btnRemove", TalentProfiles_main, "UIPanelButtonTemplate")
        btnRemove:SetSize(btn_width, btn_height)
        btnRemove:SetText("Remove")
        btnRemove:SetPoint("TOPLEFT", btnSave, "TOPRIGHT", btn_sepX, 0)
        S:HandleButton(btnRemove)
        btnRemove:SetScript("OnClick", function(sender)
            TP:VerifyDB()
            -- Check if any profiles exists
            if table.length(TP:GetAllProfiles()) == 0 then
                return
            end
            TP:StaticPopupShow_Remove()
        end)
        btnRemove:Show()
    end

    local enabled = TFR.selectedSpec == GetSpecialization()
    btnApply:SetEnabled(enabled)
    btnSave:SetEnabled(enabled)
    btnRemove:SetEnabled(enabled)
    dropdown:SetEnabled(enabled)
    TalentProfiles_profilesDropDownButton:SetEnabled(enabled)
end

-------------------- Events/Hooks -------------------- 

function TP:TryDisplay()
    -- Don't continue if the player doesn't have a talent frame yet (under level 10)
    if PlayerTalentFrame == nil then
        return
    end
    local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame)
    if selectedTab == 2 then -- Only show when the talents tab is open
        self:BuildFrame()
        TalentProfiles_main:Show()
    else
        if TalentProfiles_main ~= nil then
            TalentProfiles_main:Hide()
        end
    end
end

function TP:ARWIC_BTF_SPEC_SELECTION_CHANGED()
    self:TryDisplay()
end

function TP:PLAYER_SPECIALIZATION_CHANGED()
    self:TryDisplay()
end

function TP:PLAYER_ENTERING_WORLD()
    if not self.hasRunOneTime then
        TalentFrame_LoadUI() -- make sure the talent frame is loaded
        self.playerClass = select(2, UnitClass("player")) -- get player class
        self:VerifyDB() -- Load DB
        -- Hook functions
        self:SecureHook("ToggleTalentFrame", "TryDisplay", true)
        self:SecureHook("PanelTemplates_SetTab", "TryDisplay", true)
        self.hasRunOneTime = true
    end
end

---------- MAIN ----------

function TP:Initialize()
    -- register events
    self:RegisterMessage("ARWIC_BTF_SPEC_SELECTION_CHANGED")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

E:RegisterModule(TP:GetName())
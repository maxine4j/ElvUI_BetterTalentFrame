--[[
    ElvUI_BetterTalentFrame
    Copyright (C) Arwic-Frostmourne, All rights reserved.
]]--

-------------------- Vars -------------------- 

local ElvUI_E, ElvUI_L, ElvUI_V, ElvUI_P, ElvUI_G, ElvUI_S
TalentProfiles = {}
TalentProfiles.Events = {}
TalentProfiles.DB = {}
local const__numTalentCols = 3
local playerClass

-------------------- LUA Extensions -------------------- 

-- Prints all the key value pairs in the given table (See python's dir() function)
function dir(t)
    for k, v in pairs(t) do
        print(k, v)
    end
end

-- Returns the length of the given table
function table.length(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

---------- Helpers ----------

function TalentProfiles:Print(s)
    print("|cfffe7b2cElvUI BetterTalentFrame:|r " .. s)
end

---------- Database ----------

-- Ensure the database is valid
function TalentProfiles.DB:Verify()
    -- Make sure the base DB table exists
    if ElvUI_BetterTalentFrameGlobalDB == nil then ElvUI_BetterTalentFrameGlobalDB = {} end
    -- Make sure the current class DB exists
    if ElvUI_BetterTalentFrameGlobalDB[playerClass] == nil then ElvUI_BetterTalentFrameGlobalDB[playerClass] = {} end
    -- Make sure the current class' specs table exists
    if ElvUI_BetterTalentFrameGlobalDB[playerClass].specs == nil then ElvUI_BetterTalentFrameGlobalDB[playerClass].specs = {} end
    -- Make sure each spec exists
    for i = 1, GetNumSpecializations() do
        -- Make sure the current spec's table exists
        if ElvUI_BetterTalentFrameGlobalDB[playerClass].specs[i] == nil then ElvUI_BetterTalentFrameGlobalDB[playerClass].specs[i] = {} end
        -- Make sure the profiles DB exists
        if ElvUI_BetterTalentFrameGlobalDB[playerClass].specs[i].profiles == nil then ElvUI_BetterTalentFrameGlobalDB[playerClass].specs[i].profiles = {} end
    end
end

-- Returns a profile at the given index
function TalentProfiles.DB:GetProfile(index)
    return ElvUI_BetterTalentFrameGlobalDB[playerClass].specs[GetSpecialization()].profiles[index]
end

-- Returns a list of all profiles for the current spec
function TalentProfiles.DB:GetAllProfiles()
    return ElvUI_BetterTalentFrameGlobalDB[playerClass].specs[GetSpecialization()].profiles
end

-- Inserts a new profile into the current spec's DB
function TalentProfiles.DB:InsertProfile(profile)
    table.insert(ElvUI_BetterTalentFrameGlobalDB[playerClass].specs[GetSpecialization()].profiles, profile)
end

-- Removes the profile at the given index from the current spec's DB
function TalentProfiles.DB:RemoveProfile(index)
    table.remove(ElvUI_BetterTalentFrameGlobalDB[playerClass].specs[GetSpecialization()].profiles, index)
end

-- Returns the talent info for each talent the user currently has available
function TalentProfiles:GetTalentInfos()
    local talentInfos = {}
    local k = 1
    for i = 1, GetMaxTalentTier() do
        for j = 1, const__numTalentCols do
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

-- Adds a new profile to the database
function TalentProfiles:AddProfile(name)
    -- Ensure the database is ready
    TalentProfiles.DB:Verify()
    -- Get basic info
    local talentInfos = TalentProfiles:GetTalentInfos()
    local profile = {}
    profile.name = name
    profile.talents = {}
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
        TalentProfiles:Print("Error: Too many talents selected")
    end
    -- Save the profile to the database
    TalentProfiles.DB:InsertProfile(profile)
    -- Rebuild the frame with the new data
    TalentProfiles:BuildFrame()
    -- Inform the user a profile was added
    TalentProfiles:Print("Added a new profile: '" .. profile.name .. "'")
end

-- Saves the current talent configuration to the current profile
function TalentProfiles:SaveProfile(index)
    -- Don't try and save a profile that doesn't exist
    if table.length(TalentProfiles.DB:GetAllProfiles()) == 0 then
        return
    end
    -- Don't activate the placeholder profile
    if index ~= "new" then
        -- Get the profile, checking for errors on the way
        local profile = TalentProfiles.DB:GetProfile(index)
        if profile == nil then
            TalentProfiles:Print("Unable to load the selected profile")
            return
        end
        -- Update the selected talents
        local talentInfos = TalentProfiles:GetTalentInfos()
        local i = 1
        for k, v in pairs(talentInfos) do
            if v.selected == true then
                profile.talents[i] = v.talentID
                i = i + 1
            end
        end
        -- Inform the user a profile was activated
        TalentProfiles:Print("Saved profile: '" .. profile.name .. "'")
    end
end

function TalentProfiles.PopupHandler_AddProfile(sender)
    TalentProfiles:AddProfile(sender.editBox:GetText())
end

-- Remove a profile from the database
function TalentProfiles:RemoveProfile(index)
    local key = nil
    local i = 1
    for k, v in pairs(TalentProfiles.DB:GetProfile(index)) do
        if i == index then
            key = k
        end
        i = i + 1
    end
    -- Cache the name
    local name = TalentProfiles.DB:GetProfile(index).name
    -- Remove the profile
    TalentProfiles.DB:RemoveProfile(index)
    TalentProfiles:BuildFrame()
    -- Inform the user a profile was removed
    TalentProfiles:Print("Removed a profile: '" .. name .. "'")
end

function TalentProfiles.PopupHandler_RemoveProfile(sender)
    TalentProfiles:RemoveProfile(TalentProfiles_profilesDropDown.selectedID)
end

-- Dialogue that enables the user to name a new profile
StaticPopupDialogs["TALENTPROFILES_ADD_PROFILE"] = {
    text = "Enter Profile Name:",
    button1 = "Save",
    button2 = "Cancel",
    OnAccept = TalentProfiles.PopupHandler_AddProfile,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    hasEditBox = true,
}
function TalentProfiles:StaticPopupShow_Add()
    StaticPopup_Show("TALENTPROFILES_ADD_PROFILE")
end

-- Dialogue that enables the user to confirm the removal of a profile
StaticPopupDialogs["TALENTPROFILES_REMOVE_PROFILE"] = {
    text = "Do you want to remove the profile '%s'?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = TalentProfiles.PopupHandler_RemoveProfile,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
function TalentProfiles:StaticPopupShow_Remove()
    local index = TalentProfiles_profilesDropDown.selectedID
    local name = TalentProfiles.DB:GetProfile(index).name
    StaticPopup_Show("TALENTPROFILES_REMOVE_PROFILE", name)
end

-- Activates the profile at the given index. Global for macro use
function ARWICTP_ActivateProfile(index)
    -- Don't activate the placeholder profile
    if index ~= "new" then
        -- Get the profile, checking for errors on the way
        local profile = TalentProfiles.DB:GetProfile(index)
        if profile == nil or profile.talents == nil then
            TalentProfiles:Print("Unable to load talent configuration for the selected profile")
            return
        end
        for i = 1, GetMaxTalentTier() do
            LearnTalent(profile.talents[i])
        end
        -- Inform the user a profile was activated
        TalentProfiles:Print("Activated profile: '" .. profile.name .. "'")
    end
end

-------------------- TalentProfiles Event Handlers --------------------

-- Fired when the "Activate" button is clicked
function TalentProfiles:Handler_ActivateProfile(sender)
    TalentProfiles.DB:Verify()
    -- Check if any profiles exists
    if table.length(TalentProfiles.DB:GetAllProfiles()) == 0 then
        return
    end
    -- Activate the profile
    ARWICTP_ActivateProfile(TalentProfiles_profilesDropDown.selectedID)
end

-- Fired when the "Save" button is clicked
function TalentProfiles:Handler_SaveProfile(sender)
    TalentProfiles:SaveProfile(TalentProfiles_profilesDropDown.selectedID)
end

-- Fired when the "Remove" button is clicked
function TalentProfiles:Handler_RemoveProfile(sender)
    TalentProfiles.DB:Verify()
    -- Check if any profiles exists
    if table.length(TalentProfiles.DB:GetAllProfiles()) == 0 then
        return
    end
    TalentProfiles:StaticPopupShow_Remove()
end

-------------------- Dropdown functions --------------------

function TalentProfiles.ProfilesDropDown_OnClick(sender)
    UIDropDownMenu_SetSelectedID(TalentProfiles_profilesDropDown, sender:GetID())
end

function TalentProfiles.ProfilesDropDown_OnClick_NewProfile(sender)
    TalentProfiles:StaticPopupShow_Add()
end

function TalentProfiles.ProfilesDropDown_Initialise(sender, level)
    TalentProfiles.DB:Verify()
    local items = TalentProfiles.DB:GetAllProfiles()
    local i = 1
    for k, v in pairs(items) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = v.name
        info.value = i
        info.func = TalentProfiles.ProfilesDropDown_OnClick
        UIDropDownMenu_AddButton(info, level)
        i = i + 1
    end
    -- Add the new profile item
    local info = UIDropDownMenu_CreateInfo()
    info.text = "Add new profile"
    info.value = "new"
    info.func = TalentProfiles.ProfilesDropDown_OnClick_NewProfile
    info.rgb = { 1.0, 0.0, 1.0, 1.0 }
    UIDropDownMenu_AddButton(info, level)
end

function TalentProfiles:BuildFrame()
    local btn_sepX = 10
    local btn_width = 80
    local btn_height = 23

    -- Set up main frame, if it doesnt already exist
    local mainFrame = TalentProfiles_main
    if TalentProfiles_main == nil then
        mainFrame = CreateFrame("Frame", "TalentProfiles_main", PlayerTalentFrame)
        mainFrame:SetSize(PlayerTalentFrameTopTileStreaks:GetWidth(), PlayerTalentFrameTopTileStreaks:GetHeight())
        mainFrame:SetPoint("CENTER", PlayerTalentFrameTopTileStreaks, "CENTER", 0, 0)
    end

    -- Set up profiles dropdown, if it doesnt already exist
    local dropdown = TalentProfiles_profilesDropDown
    if TalentProfiles_profilesDropDown == nil then
        dropdown = CreateFrame("Button", "TalentProfiles_profilesDropDown", TalentProfiles_main, "UIDropDownMenuTemplate")
        dropdown:SetPoint("TOPLEFT", TalentProfiles_main, "TOPLEFT", 100, -13)
        -- elvui dropdown skinning is bugged and makes the arrow button far too wide
        ElvUI_S:HandleDropDownBox(dropdown)
        -- so make it the correct size
        TalentProfiles_profilesDropDownButton:SetWidth(TalentProfiles_profilesDropDownButton:GetHeight())
        -- and allow the user to open the dropdown by clicking anywhere on the control
        TalentProfiles_profilesDropDown:SetScript("OnClick", function(...) TalentProfiles_profilesDropDownButton:Click() end)
        -- make the dropdown the same height as the buttons
        TalentProfiles_profilesDropDown:SetHeight(btn_height)
    end
    -- Repopulate the dropdown, even if it already exists
    UIDropDownMenu_Initialize(dropdown, TalentProfiles.ProfilesDropDown_Initialise)
    UIDropDownMenu_SetSelectedID(dropdown, 1)
    UIDropDownMenu_JustifyText(dropdown, "LEFT")
    dropdown:Show()

    -- Set up the action buttons
    local btnApply = TalentProfiles_btnApply
    if TalentProfiles_btnApply == nil then
        btnApply = CreateFrame("Button", "TalentProfiles_btnApply", TalentProfiles_main, "UIPanelButtonTemplate")
        btnApply:SetSize(btn_width, btn_height)
        btnApply:SetText("Apply")
        btnApply:SetPoint("TOPLEFT", dropdown, "TOPRIGHT", btn_sepX, -2)
        ElvUI_S:HandleButton(btnApply)
        btnApply:SetScript("OnClick", TalentProfiles.Handler_ActivateProfile)
        btnApply:Show()
    end
    local btnSave = TalentProfiles_btnSave
    if TalentProfiles_btnSave == nil then
        btnSave = CreateFrame("Button", "TalentProfiles_btnSave", TalentProfiles_main, "UIPanelButtonTemplate")
        btnSave:SetSize(btn_width, btn_height) -- was w100
        btnSave:SetText("Save")
        btnSave:SetPoint("TOPLEFT", btnApply, "TOPRIGHT", btn_sepX, 0)
        ElvUI_S:HandleButton(btnSave)
        btnSave:SetScript("OnClick", TalentProfiles.Handler_SaveProfile)
        btnSave:Show()
    end
    local btnRemove = TalentProfiles_btnRemove
    if TalentProfiles_btnRemove == nil then
        btnRemove = CreateFrame("Button", "TalentProfiles_btnRemove", TalentProfiles_main, "UIPanelButtonTemplate")
        btnRemove:SetSize(btn_width, btn_height)
        btnRemove:SetText("Remove")
        btnRemove:SetPoint("TOPLEFT", btnSave, "TOPRIGHT", btn_sepX, 0)
        ElvUI_S:HandleButton(btnRemove)
        btnRemove:SetScript("OnClick", TalentProfiles.Handler_RemoveProfile)
        btnRemove:Show()
    end

    local enabled = ARWICUIR_selectedSpec == GetSpecialization()
    btnApply:SetEnabled(enabled)
    btnSave:SetEnabled(enabled)
    btnRemove:SetEnabled(enabled)
    dropdown:SetEnabled(enabled)
    TalentProfiles_profilesDropDownButton:SetEnabled(enabled)
end

-------------------- Events/Hooks -------------------- 

-- Fired when talent the talent frame is toggled
function TalentProfiles:OnToggleTalentFrame()
    -- Don't continue if the player doesn't have a talent frame yet (under level 10)
    if PlayerTalentFrame == nil then
        return
    end

    local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame)
    if selectedTab == 2 then -- Only show when the talents tab is open
        -- Build the frame
        TalentProfiles:BuildFrame()
        -- Set the visibility of the profile selector to that of the talent frame
        TalentProfiles_main:SetShown(PlayerTalentFrame:IsVisible())
    end
end

function TalentProfiles:OnPanelTemplates_SetTab(...)
    -- Don't continue if the player doesn't have a talent frame yet (under level 10)
    if PlayerTalentFrame == nil then
        return
    end
    local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame)
    if selectedTab == 2 then -- Only show when the talents tab is open
        -- Build the frame
        TalentProfiles:BuildFrame()
        -- Set the visibility of the profile selector to that of the talent frame
        TalentProfiles_main:Show()
    else
        if TalentProfiles_main ~= nil then
            TalentProfiles_main:Hide()
        end
    end
end

function TalentProfiles.Events:PLAYER_LOGIN()
    -- Init Vars
    _, playerClass, _ = UnitClass("player"); -- playerClass is localisation independent

    -- Load DB
    TalentProfiles.DB:Verify()

    -- Hook functions
    hooksecurefunc("ToggleTalentFrame", TalentProfiles.OnToggleTalentFrame)
    hooksecurefunc("PanelTemplates_SetTab", TalentProfiles.OnPanelTemplates_SetTab)

    -- Get ElvIU
    ElvUI_E, ElvUI_L, ElvUI_V, ElvUI_P, ElvUI_G = unpack(ElvUI)
    ElvUI_S = ElvUI_E:GetModule("Skins")
end

---------- MAIN ----------

local function Main()
    -- register events
    local eventFrame = CreateFrame("FRAME", "ARWICTP_eventFrame")
    eventFrame:SetScript("OnEvent", function(self, event, ...)
        TalentProfiles.Events[event](self, ...)
    end)
    for k, v in pairs(TalentProfiles.Events) do
        eventFrame:RegisterEvent(k)
    end
end

Main()
--[[
    Arwic UI Rework - Copyright (C) Arwic-Frostmourne
]]--

---------- VARS ----------

-- the currently selected spec
local selectedSpec = GetSpecialization()
local events = {}

---------- HELPERS ----------

-- returns the pve talent info for a given spec at the given row and column
local function GetCache_PveTalent(specIndex, row, col)
    return ArwicUIReworkDB["talents"]["pve"][specIndex][row][col]
end

-- returns the pvp talent info for a given spec at the given row and column
local function GetCache_PvpTalent(specIndex, row, col)
    return ArwicUIReworkDB["talents"]["pvp"][specIndex][row][col]
end

-- returns the given talent button
local function GetFrame_TalentButton(row, col)
    return _G["PlayerTalentFrameTalentsTalentRow" .. row .. "Talent" .. col]
end

-- returns the texture widget of the given talent button
local function GetFrame_TalentButtonIconTexture(row, col)
    return _G["PlayerTalentFrameTalentsTalentRow" .. row .. "Talent" .. col .. "IconTexture"]
end

-- returns the given talent button
local function GetFrame_PvpTalentButton(row, col)
    return PlayerTalentFramePVPTalents.Talents["Tier" .. row]["Talent" .. col]
end

-- returns the texture widget of the given talent button
local function GetFrame_PvpTalentButtonIconTexture(row, col)
    return GetFrame_PvpTalentButton(row, col).Icon
end

-- caches the current specs talent configuration
local function UpdateTalentCache()
    -- only create these if they dont exists
    if ArwicUIReworkDB == nil then ArwicUIReworkDB = {} end
    if ArwicUIReworkDB["talents"] == nil then ArwicUIReworkDB["talents"] = {} end
    if ArwicUIReworkDB["talents"]["pve"] == nil then ArwicUIReworkDB["talents"]["pve"] = {} end
    if ArwicUIReworkDB["talents"]["pvp"] == nil then ArwicUIReworkDB["talents"]["pvp"] = {} end
    -- always recreate this
    ArwicUIReworkDB["talents"]["pve"][GetSpecialization()] = {}
    ArwicUIReworkDB["talents"]["pvp"][GetSpecialization()] = {}

    -- cache talent infos
    local curSpec = ArwicUIReworkDB["talents"]["pve"][GetSpecialization()]
    for i = 1, 7, 1 do
        curSpec[i] = {}
        for j = 1, 3, 1 do
            curSpec[i][j] = {}
            curSpec[i][j].talentID, 
            curSpec[i][j].name, 
            curSpec[i][j].texture, 
            curSpec[i][j].selected, 
            curSpec[i][j].available, 
            curSpec[i][j].spellid, 
            curSpec[i][j].tier, 
            curSpec[i][j].column = GetTalentInfo(i, j, GetActiveSpecGroup())
        end
    end
    -- cache honor talent infos
    local curPvpSpec = ArwicUIReworkDB["talents"]["pvp"][GetSpecialization()]
    for i = 1, 6, 1 do
        curPvpSpec[i] = {}
        for j = 1, 3, 1 do
            curPvpSpec[i][j] = {}
            curPvpSpec[i][j].talentID, 
            curPvpSpec[i][j].name, 
            curPvpSpec[i][j].texture, 
            curPvpSpec[i][j].selected, 
            curPvpSpec[i][j].available, 
            curPvpSpec[i][j].spellid, 
            curPvpSpec[i][j].tier, 
            curPvpSpec[i][j].column = GetPvpTalentInfo(i, j, GetActiveSpecGroup())
        end
    end
end

---------- UPDATE ----------

local function Update_Global()
    PlayerTalentFrameSpecializationLearnButton:SetEnabled(selectedSpec ~= GetSpecialization())
    
    for i = 1, GetNumSpecializations(), 1 do
        if _G["AUIR_SpecTab" .. i] and _G["AUIR_SpecTab" .. i].overlay then
            _G["AUIR_SpecTab" .. i].overlay:SetShown(selectedSpec == i)
        end
    end
end

local function UpdateTab_Specialization()
    PlayerTalentFrame_UpdateSpecFrame(PlayerTalentFrameSpecialization, selectedSpec)
end

local function UpdateTab_Talents()
    UpdateTalentCache()
    -- replace the current talent buttons with the selected specs talents
    for i = 1, 7, 1 do
        for j = 1, 3, 1 do
            -- get vars
            local btn = GetFrame_TalentButton(i, j)
            local talentInfo = GetCache_PveTalent(selectedSpec, i, j)
            local btnTexture = GetFrame_TalentButtonIconTexture(i, j)

            -- update the talent buttons
            btn.name:SetText(talentInfo.name)
            btn.icon:SetTexture(talentInfo.texture)
            -- select the correct buttons
            btnTexture:SetDesaturated(not (talentInfo.selected and selectedSpec == GetSpecialization()))
            -- setup tooltip
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                GameTooltip:SetTalent(talentInfo.talentID)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function(self)
                GameTooltip_Hide()
            end)

            if selectedSpec == GetSpecialization() then
                -- enable the buttons click event as this is the currently active spec
                btn:SetScript("OnClick", PlayerTalentButton_OnClick)
                -- active specs have green highlighs
                btn.bg.SelectedTexture:SetColorTexture(23/255, 49/255, 23/255, 1.0)
                btn.bg.SelectedTexture:SetShown(talentInfo.selected)
            else
                -- disable the buttons click event as this is not the currently active spec
                btn:SetScript("OnClick", function(...) end)
                -- non active specs have grey highlighs
                btn.bg.SelectedTexture:SetColorTexture(55/255, 55/255, 55/255, 1.0)
                btn.bg.SelectedTexture:SetShown(talentInfo.selected)
            end
        end
    end
end

local function UpdateTab_HonorTalents()
    UpdateTalentCache()
    -- replace the current talent buttons with the selected specs talents
    for i = 1, 6, 1 do
        for j = 1, 3, 1 do
            -- get vars
            local btn = GetFrame_PvpTalentButton(i, j)
            local talentInfo = GetCache_PvpTalent(selectedSpec, i, j)
            local btnTexture = GetFrame_PvpTalentButtonIconTexture(i, j)
            
            -- update the talent buttons
            btn.Name:SetText(talentInfo.name)
            btn.Icon:SetTexture(talentInfo.texture)
            -- select the correct buttons
            btnTexture:SetDesaturated(not (talentInfo.selected and selectedSpec == GetSpecialization()))
            -- setup tooltip
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                GameTooltip:SetPvpTalent(talentInfo.talentID)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function(self)
                GameTooltip_Hide()
            end)

            if selectedSpec == GetSpecialization() then
                -- enable the buttons click event as this is the currently active spec
                btn:SetScript("OnClick", PlayerPVPTalentButton_OnClick)
                -- active specs have green highlighs
                btn.bg.SelectedTexture:SetColorTexture(23/255, 49/255, 23/255, 1.0)
                btn.bg.SelectedTexture:SetShown(talentInfo.selected)
            else
                -- disable the buttons click event as this is not the currently active spec
                btn:SetScript("OnClick", function(...) end)
                -- non active specs have grey highlighs
                btn.bg.SelectedTexture:SetColorTexture(55/255, 55/255, 55/255, 1.0)
                btn.bg.SelectedTexture:SetShown(talentInfo.selected)
            end
        end
    end
end

local function UpdateTab_Pet()
end

function UpdateAll()
    Update_Global()
    UpdateTab_Specialization()
    UpdateTab_Talents()
    UpdateTab_HonorTalents()
    UpdateTab_Pet()
end

---------- INIT ----------

local function Init_Global()
    -- make the activate button appear on every tab
    local activateButtonWidth = 200
    local activateButtonHeight = 20
    if PlayerTalentFrameSpecializationLearnButton ~= nil then
        PlayerTalentFrameSpecializationLearnButton:SetText("Activate Specialization")
        PlayerTalentFrameSpecializationLearnButton:SetSize(activateButtonWidth, activateButtonHeight)
        PlayerTalentFrameSpecializationLearnButton:SetParent(PlayerTalentFrame)
        PlayerTalentFrameSpecializationLearnButton:SetScript("OnClick", function(self, button) 
            SetSpecialization(selectedSpec)
        end)
        PlayerTalentFrameSpecializationLearnButton:SetEnabled(selectedSpec ~= GetSpecialization())
    end

    -- add new spec spellbook tabs to the top right of the talent frame
    local tabDim = 30
    local tabSep = 10
    local tabXOffset = 2
    for i = 1, GetNumSpecializations(), 1 do
        local specID, specName, specDesc, specIcon, specRole, specPriStat = GetSpecializationInfo(i)
        -- create the button
        btn = CreateFrame("Button", "AUIR_SpecTab" .. i, PlayerTalentFrame)
        btn:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPRIGHT", tabXOffset, -((tabSep + tabDim) * i))
        btn:SetSize(tabDim, tabDim)
        btn:CreateBackdrop("Default") -- ElvUI func
        -- set a tooltip
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
            GameTooltip:SetText(specName, 1, 1, 1) -- This sets the top line of text, in gold.
            GameTooltip:AddLine(specDesc, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        -- set a click action
        btn:SetScript("OnClick", function(self, button)
            selectedSpec = i
            UpdateAll()
        end)
        -- give it an icon
        if btn.icon == nil then
            btn.icon = btn:CreateTexture()
            btn.icon:SetSize(tabDim, tabDim)
            btn.icon:SetPoint("TOPLEFT")
            btn.icon:SetTexture(specIcon)
            btn.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        end
        btn.icon:SetShown(true)
        -- give the icon an overlay
        if btn.overlay == nil then
            btn.overlay = btn:CreateTexture(nil, "OVERLAY")
            btn.overlay:SetSize(tabDim, tabDim)
            btn.overlay:SetPoint("TOPLEFT")
            btn.overlay:SetColorTexture(1.0, 1.0, 1.0, 0.51) -- Needs to be over 0.5?
        end
        btn.overlay:SetShown(selectedSpec == i)
    end

    Update_Global()
end

local function InitTab_Specialization()
    -- center spec info
    PlayerTalentFrameSpecializationSpellScrollFrame:ClearAllPoints()
    PlayerTalentFrameSpecializationSpellScrollFrame:SetPoint("CENTER", PlayerTalentFrameSpecialization, "CENTER", 0, 0)
    -- remove spec buttons
    for i = 1, GetNumSpecializations(), 1 do
        local btn = _G["PlayerTalentFrameSpecializationSpecButton" .. i]
        btn:Hide()
    end

    UpdateTab_Specialization()
end

local function InitTab_Talents()
    local offsetX = 4
    local offsetY = 16
    local buttonWidth = 210
    local buttonHeight = 42
    local buttonSepX = 0
    local buttonSepY = 9
    for i = 1, 7, 1 do
        for j = 1, 3, 1 do
            local t = _G["PlayerTalentFrameTalentsTalentRow" .. i .. "Talent" .. j]
            t:SetPoint("TOPLEFT", PlayerTalentFrameTalents, "TOPLEFT", 
            offsetX + ((j - 1) * (buttonWidth + buttonSepX)), -(offsetY + ((i - 1) * (buttonHeight + buttonSepY))))
            t:SetSize(buttonWidth, buttonHeight)
        end
    end

    UpdateTab_Talents()
end

local function InitTab_HonorTalents()
    UpdateTab_HonorTalents()
end

local function InitTab_Pet()
    local _, playerClass = UnitClass("player");
	if (playerClass == "HUNTER") then
        -- centers the pet spec info
        PlayerTalentFramePetSpecializationSpellScrollFrame:ClearAllPoints()
        PlayerTalentFramePetSpecializationSpellScrollFrame:SetPoint("CENTER", PlayerTalentFrameSpecialization, "CENTER", 0, 0)
        -- positions the pet spec buttons
        PlayerTalentFramePetSpecializationSpecButton1:ClearAllPoints()
        PlayerTalentFramePetSpecializationSpecButton1:SetPoint("CENTER", PlayerTalentFramePetSpecialization, "BOTTOMLEFT", 100, 70)
        PlayerTalentFramePetSpecializationSpecButton2:ClearAllPoints()
        PlayerTalentFramePetSpecializationSpecButton2:SetPoint("CENTER", PlayerTalentFramePetSpecialization, "BOTTOM", -8, 70)
        PlayerTalentFramePetSpecializationSpecButton3:ClearAllPoints()
        PlayerTalentFramePetSpecializationSpecButton3:SetPoint("CENTER", PlayerTalentFramePetSpecialization, "BOTTOMRIGHT", -115, 70)
        -- rename pet button avoid confusion with the player spec activate button
        local activateButtonWidth = 200
        local activateButtonHeight = 20
        PlayerTalentFramePetSpecializationLearnButton:SetText("Activate Pet Specialization")
        PlayerTalentFramePetSpecializationLearnButton:SetSize(activateButtonWidth, activateButtonHeight)
        -- move the pet activate button otherwise the player activate button will cover it
        PlayerTalentFramePetSpecializationLearnButton:ClearAllPoints()
        PlayerTalentFramePetSpecializationLearnButton:SetPoint("CENTER", PlayerTalentFrameSpecializationLearnButton, "CENTER", 0, 30)
    end

    UpdateTab_Pet()
end

---------- EVENTS ----------

function events:PLAYER_SPECIALIZATION_CHANGED(...)
    UpdateTalentCache()
end

function events:PLAYER_LOGIN(...)
    UpdateTalentCache()

    ToggleTalentFrame() -- initialize the default talent frame

    Init_Global()
    InitTab_Specialization()
    InitTab_Talents()
    InitTab_HonorTalents()
    InitTab_Pet()
end

function events:PLAYER_LOGOUT(...)
    UpdateTalentCache()
end

---------- MAIN ----------

function AUIR_Talents_Init()
    -- init db
    if ArwicUIReworkDB == nil then
        ArwicUIReworkDB = {}
        ArwicUIReworkDB["talents"] = {}
        ArwicUIReworkDB["talents"]["pve"] = {}
        ArwicUIReworkDB["talents"]["pvp"] = {}
    end

    -- register events
    local eventFrame = CreateFrame("FRAME", "AUIR_eventFrame")
    eventFrame:SetScript("OnEvent", function(self, event, ...)
        events[event](self, ...)
    end)
    for k, v in pairs(events) do
        eventFrame:RegisterEvent(k)
    end

    -- hook functions
    local shouldHook = true
    hooksecurefunc("PanelTemplates_SetTab", function()
        if shouldHook then
            hooksecurefunc("PVPTalentFrame_Update", UpdateAll)
            hooksecurefunc("PlayerTalentFrame_Update", UpdateAll)
            shouldHook = false
        end
    end)
end

AUIR_Talents_Init()

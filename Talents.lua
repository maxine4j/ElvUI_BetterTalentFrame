--[[
    Arwic UI Rework - Copyright (C) Arwic-Frostmourne
]]--

---------- VARS ----------

-- the currently selected spec
local selectedSpec = GetSpecialization()

---------- HELPERS ----------

-- returns the pve talent info for a given spec at the given row and column
local function GetCache_PveTalent(specIndex, row, col)
    return ArwicUIReworkDB["talents"]["pve"][selectedSpec][row][col]
end

-- returns the pvp talent info for a given spec at the given row and column
local function GetCache_PvpTalent(specIndex, row, col)
    return ArwicUIReworkDB["talents"]["pvp"][selectedSpec][row][col]
end

-- returns the given talent button
local function GetFrame_TalentButton(row, col)
    return _G["PlayerTalentFrameTalentsTalentRow" .. row .. "Talent" .. col]
end

-- returns the texture widget of the given talent button
local function GetFrame_TalentButtonIconTexture(row, col)
    return _G["PlayerTalentFrameTalentsTalentRow" .. row .. "Talent" .. col .. "IconTexture"]
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
    for i = 1, GetMaxTalentTier(), 1 do
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
            curPvpSpec[i][j].column = GetTalentInfo(i, j, GetActiveSpecGroup())
        end
    end
end

---------- REWORKS ----------

-- remove the spec selection buttons from the left side of the main spec tab
local function HideSpecButtons()
    for i = 1, GetNumSpecializations(), 1 do
        local btn = _G["PlayerTalentFrameSpecializationSpecButton" .. i]
        btn:Hide()
    end
end

-- centers the spec info frame
local function CenterSpecInfo()
    PlayerTalentFrameSpecializationSpellScrollFrame:ClearAllPoints()
    PlayerTalentFrameSpecializationSpellScrollFrame:SetPoint("CENTER", PlayerTalentFrameSpecialization, "CENTER", 0, 0)
end

-- replace the current talent buttons with the selected specs talents
local function UpdatePveTalentGrid()
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
            btnTexture:SetDesaturated(talentInfo.selected == false)
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

-- positions the pve talent grid so it lines up with the pvp talent grid
local function PositionPveTalentGrid()
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
end

-- centers the pet spec info
local function CenterPetSpecInfo()
    PlayerTalentFramePetSpecializationSpellScrollFrame:ClearAllPoints()
    PlayerTalentFramePetSpecializationSpellScrollFrame:SetPoint("CENTER", PlayerTalentFrameSpecialization, "CENTER", 0, 0)
end

-- positions the pet spec buttons
local function PositionPetSpecButtons()
    PlayerTalentFramePetSpecializationSpecButton1:ClearAllPoints()
    PlayerTalentFramePetSpecializationSpecButton1:SetPoint("CENTER", PlayerTalentFramePetSpecialization, "BOTTOMLEFT", 100, 70)
    PlayerTalentFramePetSpecializationSpecButton2:ClearAllPoints()
    PlayerTalentFramePetSpecializationSpecButton2:SetPoint("CENTER", PlayerTalentFramePetSpecialization, "BOTTOM", -8, 70)
    PlayerTalentFramePetSpecializationSpecButton3:ClearAllPoints()
    PlayerTalentFramePetSpecializationSpecButton3:SetPoint("CENTER", PlayerTalentFramePetSpecialization, "BOTTOMRIGHT", -115, 70)
end

-- reworks pets activate spec button
local function ReworkPetSpecActivateSpecButton()
    local activateButtonWidth = 200
    local activateButtonHeight = 20
    -- avoid confusion with the player spec activate button
    PlayerTalentFramePetSpecializationLearnButton:SetText("Activate Pet Specialization")
    PlayerTalentFramePetSpecializationLearnButton:SetSize(activateButtonWidth, activateButtonHeight)
    -- move the pet activate button as the player activate button will now cover it
    PlayerTalentFramePetSpecializationLearnButton:ClearAllPoints()
    PlayerTalentFramePetSpecializationLearnButton:SetPoint("CENTER", PlayerTalentFrameSpecializationLearnButton, "CENTER", 0, 30)
end

-- reworks the activate spec button
local function ReworkActivateSpecButton()
    -- make the activate button appear on every frame
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
end

-- creates the top right spec tabs
local function UpdateSpecTabs()
    local tabDim = 30
    local tabSep = 10
    local tabXOffset = 2
    for i = 1, GetNumSpecializations(), 1 do
        local specID, specName, specDesc, specIcon, specRole, specPriStat = GetSpecializationInfo(i)
        -- dont duplicate a button
        local btn = _G["ARWICUIR_btnSpec" .. i]
        if btn == nil then
            -- create the button
            btn = CreateFrame("Button", "ARWICUIR_btnSpec" .. i, PlayerTalentFrame)
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
                -- update the overlay
                local btnOld = _G["ARWICUIR_btnSpec" .. selectedSpec]
                local btnNew = _G["ARWICUIR_btnSpec" .. i]
                btnOld.overlay:SetShown(false)
                btnNew.overlay:SetShown(true)
                -- remember which tab is selected
                selectedSpec = i
                -- update the activate button
                PlayerTalentFrameSpecializationLearnButton:SetEnabled(selectedSpec ~= GetSpecialization())
                -- refresh the talent frame
                UpdatePveTalentGrid()
                -- update the spec tab
                PlayerTalentFrame_UpdateSpecFrame(PlayerTalentFrameSpecialization, selectedSpec)
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
            -- show the overlay only if the tab is selected
            btn.overlay:SetShown(selectedSpec == i)
        end
    end
end

-- re applies all the reworks
local function RefreshAll()
    if PlayerTalentFrame ~= nil then
        -- global reworks
        UpdateSpecTabs()
        ReworkActivateSpecButton()
        -- tab specific reworks
        local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame)
        if selectedTab == 1 then -- specialization
            HideSpecButtons()
            CenterSpecInfo()
        elseif selectedTab == 2 then -- talents
            PositionPveTalentGrid()
            UpdatePveTalentGrid()
        elseif selectedTab == 3 then -- honor talents
        elseif selectedTab == 4 then -- pet
            CenterPetSpecInfo()
            PositionPetSpecButtons()
            ReworkPetSpecActivateSpecButton()
        end
    end
end

---------- HOOKS/EVENTS ----------

local function Hook_ToggleTalentFrame(...)
    RefreshAll()
end

local function Hook_PanelTemplates_SetTab(...)
    RefreshAll()
end

-- handle events
local function EventHandler(self, event, ...)
    if event == "PLAYER_SPECIALIZATION_CHANGED" then
        UpdateTalentCache()
    elseif event == "PLAYER_LOGIN" then
        UpdateTalentCache()
    elseif event == "PLAYER_LOGOUT" then
        UpdateTalentCache()
    end
end

---------- INIT ----------

-- initialises the db
local function InitDB()
    -- check if the db already exists
    if ArwicUIReworkDB == nil then
        -- if it doesnt, create it
        ArwicUIReworkDB = {}
        ArwicUIReworkDB["talents"] = {}
        ArwicUIReworkDB["talents"]["pve"] = {}
        ArwicUIReworkDB["talents"]["pvp"] = {}
    end
end


-- hooks funcs, registers events
local function RegisterEvents()
    -- hooks
    hooksecurefunc("ToggleTalentFrame", Hook_ToggleTalentFrame)
    hooksecurefunc("PanelTemplates_SetTab", Hook_PanelTemplates_SetTab)
    -- events
    local eventFrame = CreateFrame("FRAME", "ARWICUIR_eventFrame")
    eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    eventFrame:RegisterEvent("PLAYER_LOGIN")
    eventFrame:RegisterEvent("PLAYER_LOGOUT")
    eventFrame:SetScript("OnEvent", EventHandler);
end


-- applies the talents rework
local function Apply()
    -- init db
    InitDB()
    -- init vars
    selectedSpec = GetSpecialization()
    -- hook funcs, register events
    RegisterEvents()
end

Apply()

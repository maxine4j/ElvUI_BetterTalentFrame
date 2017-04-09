--[[
    Arwic UI Rework - Copyright (C) Arwic-Frostmourne
    ArwicUIRework.lua
]]--

local outputPrefix
local selectedSpec
local eventFrame

local function ReworkSpellBook()
    -- vars
    local horiMargin = 30
    local vertMargin = 40
    local itemWidth = 200
    local itemHeight = 80
    local itemXCount = 2
    local itemYCount = 6
    local frameWidth = itemWidth * itemXCount + horiMargin * 2
    local frameHeight = itemHeight * itemYCount
    -- resize frame
    SpellButton1:SetPoint("TOPLEFT", horiMargin, -vertMargin)
    -- reposition content
    SpellBookFrame:SetSize(frameWidth, frameHeight)
end

local function ReworkProfessions()
    -- vars
    local horiMargin = 15
    local vertMargin = 40
    -- resize frame
    PrimaryProfession1:SetPoint("TOPLEFT", horiMargin, -vertMargin)
end

local function CacheTalents()
    -- only create these if they dont exists
    if ArwicUIReworkDB == nil then ArwicUIReworkDB = {} end
    if ArwicUIReworkDB["talents"] == nil then ArwicUIReworkDB["talents"] = {} end
    -- always recreate this
    ArwicUIReworkDB["talents"][GetSpecialization()] = {}
    local curSpec = ArwicUIReworkDB["talents"][GetSpecialization()]
    -- save talent infos to file
    for i = 1, GetMaxTalentTier(), 1 do
        curSpec[i] = {}
        for j = 1, 3, 1 do
            curSpec[i][j] = {}
            local talentID, name, texture, selected, available, spellid, tier, column = GetTalentInfo(i, j, GetActiveSpecGroup())
            curSpec[i][j].talentID = talentID
            curSpec[i][j].name = name
            curSpec[i][j].texture = texture
            curSpec[i][j].selected = selected
            curSpec[i][j].available = available
            curSpec[i][j].spellid = spellid
            curSpec[i][j].tier = tier
            curSpec[i][j].column = column
        end
    end
end

local function ReworkTalents()
    -- reset the talent frame
    PlayerTalentFrame_Refresh()
    if selectedSpec == nil then
        selectedSpec = GetSpecialization()
    end
    local activateButtonWidth = 200
    local activateButtonHeight = 20

    if PlayerTalentFrameSpecialization ~= nil then
        -- remove the spec selection buttons from the left side of the main spec tab
        for i = 1, GetNumSpecializations(), 1 do
            local btn = _G["PlayerTalentFrameSpecializationSpecButton" .. i]
            btn:Hide()
        end
         -- center the spec info frame
        PlayerTalentFrameSpecializationSpellScrollFrame:ClearAllPoints()
        PlayerTalentFrameSpecializationSpellScrollFrame:SetPoint("CENTER", PlayerTalentFrameSpecialization, "CENTER", 0, 0)
    end

    if PlayerTalentFrameTalents ~= nil then
        -- reposition the talent buttons so they line up with the honour talent buttons
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

    if PlayerTalentFramePetSpecialization ~= nil then
        -- repostion the pet talents frame
        PlayerTalentFramePetSpecializationSpecButton1:ClearAllPoints()
        PlayerTalentFramePetSpecializationSpecButton2:ClearAllPoints()
        PlayerTalentFramePetSpecializationSpecButton3:ClearAllPoints()
        PlayerTalentFramePetSpecializationSpecButton1:SetPoint("CENTER", PlayerTalentFramePetSpecialization, "BOTTOMLEFT", 100, 70)
        PlayerTalentFramePetSpecializationSpecButton2:SetPoint("CENTER", PlayerTalentFramePetSpecialization, "BOTTOM", -8, 70)
        PlayerTalentFramePetSpecializationSpecButton3:SetPoint("CENTER", PlayerTalentFramePetSpecialization, "BOTTOMRIGHT", -115, 70)
        PlayerTalentFramePetSpecializationSpellScrollFrame:ClearAllPoints()
        PlayerTalentFramePetSpecializationSpellScrollFrame:SetPoint("CENTER", PlayerTalentFrameSpecialization, "CENTER", 0, 0)
    end

    if PlayerTalentFramePetSpecializationLearnButton ~= nil then
        -- move the pet activate button as the player activate button will now cover it
        PlayerTalentFramePetSpecializationLearnButton:SetText("Activate Pet Specialization")
        PlayerTalentFramePetSpecializationLearnButton:SetSize(activateButtonWidth, activateButtonHeight)
        PlayerTalentFramePetSpecializationLearnButton:ClearAllPoints()
        PlayerTalentFramePetSpecializationLearnButton:SetPoint("CENTER", PlayerTalentFrameSpecializationLearnButton, "CENTER", 0, 30)
    end

    if PlayerTalentFrameSpecializationLearnButton ~= nil then
        -- make the activate button appear on every frame
        PlayerTalentFrameSpecializationLearnButton:SetText("Activate Specialization")
        PlayerTalentFrameSpecializationLearnButton:SetSize(activateButtonWidth, activateButtonHeight)
        PlayerTalentFrameSpecializationLearnButton:SetParent(PlayerTalentFrame)
        PlayerTalentFrameSpecializationLearnButton:SetScript("OnClick", function(self, button) 
            SetSpecialization(selectedSpec)
        end)
        PlayerTalentFrameSpecializationLearnButton:SetEnabled(selectedSpec ~= GetSpecialization())
    end
    
    -- replace the current talent buttons with the selected specs talents
    for i = 1, 7, 1 do
        for j = 1, 3, 1 do
            -- get vars
            local talentButton = _G["PlayerTalentFrameTalentsTalentRow" .. i .. "Talent" .. j]
            local talentInfo = ArwicUIReworkDB["talents"][selectedSpec][i][j]
            local talentButtonIconTexture = _G["PlayerTalentFrameTalentsTalentRow" .. i .. "Talent" .. j .. "IconTexture"]
            if selectedSpec ~= GetSpecialization() then
                -- local talentID, name, texture, selected, available, spellid, tier, column
                -- update the talent buttons
                talentButton.name:SetText(talentInfo.name)
                talentButton.icon:SetTexture(talentInfo.texture)
                --[[
                talentButton.bg.SelectedTexture:SetColorTexture(23/255, 23/255, 49/255, 1.0) -- ElvUI active green
                talentButton.bg.SelectedTexture:SetColorTexture(49/255, 49/255, 23/255, 1.0) -- ElvUI selection yellow
                talentButton.bg.SelectedTexture:SetColorTexture(85/255, 85/255, 85/255, 1.0) -- grey
                talentButton.bg.SelectedTexture:SetColorTexture(128/255, 128/255, 128/255, 1.0) -- ElvUI disabled button text grey
                ]]--
                talentButton.bg.SelectedTexture:SetColorTexture(55/255, 55/255, 55/255, 1.0) -- dark grey
                -- select the correct buttons
                talentButton.bg.SelectedTexture:SetShown(talentInfo.selected)
                talentButtonIconTexture:SetDesaturated(talentInfo.selected == false)
                -- FIXME: buggy, old tooltip still appears? 
                -- setup tooltip
                talentButton:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                    GameTooltip:SetTalent(talentInfo.talentID)
                    GameTooltip:Show()
                end)
                talentButton:SetScript("OnLeave", function(self)
                    GameTooltip_Hide()
                end)
                -- disable the buttons as this is not the currently active spec
                talentButton:SetScript("OnClick", function(...) end)
            else
                talentButton:SetScript("OnClick", PlayerTalentButton_OnClick)
                talentButton:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                    GameTooltip:SetTalent(talentInfo.talentID)
                    GameTooltip:Show()
                end)
                talentButton:SetScript("OnLeave", function(self)
                    GameTooltip_Hide()
                end)
            end
        end
    end

    -- top right spec tabs
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
                ReworkTalents()
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
            btn.overlay:SetShown(selectedSpec == i)
        end
    end
end

local function EventHandler(self, event, ...)
    if event == "PLAYER_SPECIALIZATION_CHANGED" then
        CacheTalents()
        ReworkTalents()
    elseif event == "PLAYER_LOGIN" then
        CacheTalents()
    elseif event == "PLAYER_LOGOUT" then
        CacheTalents()
    end
end

local function InitDB()
    if ArwicUIReworkDB ~= nil then
        return
    end
    ArwicUIReworkDB = {}
    ArwicUIReworkDB["talents"] = {}
end

local function Init()
    -- init vars
    outputPrefix = "ArwicUIRework: "
    selectedSpec = GetSpecialization()
    -- init db
    InitDB()
    -- hook funcs, register events
    hooksecurefunc("ToggleTalentFrame", ReworkTalents)
    eventFrame = CreateFrame("FRAME", "ARWICUIR_eventFrame")
    eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    eventFrame:RegisterEvent("PLAYER_LOGIN")
    eventFrame:RegisterEvent("PLAYER_LOGOUT")
    eventFrame:SetScript("OnEvent", EventHandler);
    -- apply reworks
    ReworkSpellBook()
    ReworkProfessions()
    -- done!
    print(outputPrefix .. "Loaded")
end

Init()

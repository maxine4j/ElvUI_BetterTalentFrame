local outputPrefix = "ArwicUIRework: "
local selectedSpec = GetSpecialization()

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

local function ReworkTalents()
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
        local offsetX = 4
        local offsetY = -322
        local buttonWidth = 210
        local buttonHeight = 42
        local buttonSepX = 0
        local buttonSepY = 9
        for i = 1, 7, 1 do
            for j = 1, 3, 1 do
                local t = _G["PlayerTalentFrameTalentsTalentRow" .. i .. "Talent" .. j]
                t:SetPoint("TOPLEFT", PlayerTalentFrameTalents, "TOPLEFT", 
                offsetX + ((j - 1) * (buttonWidth + buttonSepX)), offsetY + ((i - 1) * (buttonHeight + buttonSepY)))
                t:SetSize(buttonWidth, buttonHeight)
            end
        end
    end
    if PlayerTalentFramePetSpecialization ~= nil then
        PlayerTalentFramePetSpecializationSpecButton1:ClearAllPoints()
        PlayerTalentFramePetSpecializationSpecButton2:ClearAllPoints()
        PlayerTalentFramePetSpecializationSpecButton3:ClearAllPoints()
        PlayerTalentFramePetSpecializationSpecButton1:SetPoint("CENTER", PlayerTalentFramePetSpecialization, "BOTTOMLEFT", 100, 70)
        PlayerTalentFramePetSpecializationSpecButton2:SetPoint("CENTER", PlayerTalentFramePetSpecialization, "BOTTOM", -8, 70)
        PlayerTalentFramePetSpecializationSpecButton3:SetPoint("CENTER", PlayerTalentFramePetSpecialization, "BOTTOMRIGHT", -115, 70)
        PlayerTalentFramePetSpecializationSpellScrollFrame:ClearAllPoints()
        PlayerTalentFramePetSpecializationSpellScrollFrame:SetPoint("CENTER", PlayerTalentFrameSpecialization, "CENTER", 0, 0)
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
    if PlayerTalentFramePetSpecializationLearnButton ~= nil then
        -- move the pet activate button as the player activate button will now cover it
        PlayerTalentFramePetSpecializationLearnButton:SetText("Activate Pet Specialization")
        PlayerTalentFramePetSpecializationLearnButton:SetSize(activateButtonWidth, activateButtonHeight)
        PlayerTalentFramePetSpecializationLearnButton:ClearAllPoints()
        PlayerTalentFramePetSpecializationLearnButton:SetPoint("CENTER", PlayerTalentFrameSpecializationLearnButton, "CENTER", 0, 30)
    end

    local tabDim = 35
    local tabSep = 10
    local tabXOffset = 2
    for i = 1, GetNumSpecializations(), 1 do
        local specID, specName, specDesc, specIcon, specRole, specPriStat = GetSpecializationInfo(i)
        local btn = _G["ARWICUIR_btnSpec" .. i]
        if btn == nil then
            btn = CreateFrame("Button", "ARWICUIR_btnSpec" .. i, PlayerTalentFrame)
            btn:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPRIGHT", tabXOffset, -((tabSep + tabDim) * i))
            btn:SetSize(tabDim, tabDim)
            btn:CreateBackdrop("Default") -- ElvUI func
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
                GameTooltip:SetText(specName, 1, 1, 1) -- This sets the top line of text, in gold.
                GameTooltip:AddLine(specDesc, nil, nil, nil, true)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
            if btn.icon == nil then
                btn.icon = btn:CreateTexture()
                btn.icon:SetSize(tabDim, tabDim)
                btn.icon:SetPoint("TOPLEFT")
                btn.icon:SetTexture(specIcon)
                btn.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            end
            btn.icon:SetShown(true)
            if btn.overlay == nil then
                btn.overlay = btn:CreateTexture()
                btn.overlay:SetSize(tabDim, tabDim)
                btn.overlay:SetPoint("TOPLEFT")
                btn.overlay:SetColorTexture(1.0, 1.0, 1.0, 0.51) -- Needs to be over 0.5?
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
                end)
            end
            btn.overlay:SetShown(selectedSpec == i)
        end
    end
end

function Init()
    hooksecurefunc("ToggleTalentFrame", ReworkTalents)
    
    ReworkSpellBook()
    ReworkProfessions()
    
    print(outputPrefix .. "Loaded")
end

Init()

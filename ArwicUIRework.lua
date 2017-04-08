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
    PlayerTalentFrameSpecializationLearnButton:SetParent(PlayerTalentFrame)
    PlayerTalentFrameSpecializationLearnButton:SetScript("OnClick", function(self, button) 
        SetSpecialization(selectedSpec)
    end)
    PlayerTalentFrameSpecializationLearnButton:Enable()

    local tabDim = 35
    local tabSep = 10
    local tabYOffset = 35
    local tabXOffset = 2
    local numSpecs = GetNumSpecializations()
    for i = 1, numSpecs, 1 do
        local specID, specName, specDesc, specIcon, specRole, specPriStat = GetSpecializationInfo(i)
        local btn = _G["ARWICUIR_btnSpec" .. i]
        if btn == nil then
            btn = CreateFrame("Button", "ARWICUIR_btnSpec" .. i, PlayerTalentFrame)
            btn:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPRIGHT", tabXOffset, -(tabYOffset + ((tabSep + tabDim) * i)))
            btn:SetSize(tabDim, tabDim)
            btn:CreateBackdrop("Default") -- ElvUI func
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

function ReworkAll()
    ReworkSpellBook()
    ReworkProfessions()
end

function Init()
    hooksecurefunc("ToggleTalentFrame", ReworkTalents)

    ReworkAll()
    print(outputPrefix .. "Loaded")
end

Init()
local outputPrefix = "ArwicUIRework: "
local selectedSpec = GetSpecialization()

local function Apply_SpellBook()
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

local function Apply_Professions()
    -- vars
    local horiMargin = 15
    local vertMargin = 40
    -- resize frame
    PrimaryProfession1:SetPoint("TOPLEFT", horiMargin, -vertMargin)
end

local function Apply_Talents()
    --PlayerTalentFrameSpecializationLearnButton

    local btnActivate = PlayerTalentFrameSpecializationLearnButton
    btnActivate:SetParent(PlayerTalentFrame)
    btnActivate:SetScript("OnClick", function(self, button) 
        SetSpecialization(selectedTalentSpec)
    end)
    btnActivate:Enable()

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
        end
        btn:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPRIGHT", tabXOffset, -(tabYOffset + ((tabSep + tabDim) * i)))
        btn:SetSize(tabDim, tabDim)
        btn:CreateBackdrop("asasd", true)
        btn:SetBackdrop("Interface\\Icons\\" .. specIcon)
        btn:Show()
        btn:SetScript("OnClick", function(self, button)
            selectedTalentSpec = i
        end)
    end
end

function ApplyAll()
    Apply_SpellBook()
    Apply_Professions()
    Apply_Talents()
end

ApplyAll()

print(outputPrefix .. "Loaded")
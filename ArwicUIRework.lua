local outputPrefix = "ArwicUIRework: "

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

function ApplyAll()
    Apply_SpellBook()
    Apply_Professions()
end

ApplyAll()

print(outputPrefix .. "Loaded")
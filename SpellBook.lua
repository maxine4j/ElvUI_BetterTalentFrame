--[[
    Arwic UI Rework - Copyright (C) Arwic-Frostmourne
]]--



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


local function Apply()
    -- apply reworks
    ReworkSpellBook()
    ReworkProfessions()
end

Apply()
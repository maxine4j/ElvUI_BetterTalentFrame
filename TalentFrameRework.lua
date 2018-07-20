--[[
    ElvUI_BetterTalentFrame
    Copyright (C) Arwic-Frostmourne, All rights reserved.
]]--

---------- VARS ----------

-- the currently selected spec
ARWICUIR_selectedSpec = 1
local events = {}

---------- HELPERS ----------

-- returns the pve talent info for a given spec at the given row and column
local function GetCache_PveTalent(specIndex, row, col)
    if ElvUI_BetterTalentFrameDB["talents"]["pve"][specIndex] == nil then
        return nil
    end
    return ElvUI_BetterTalentFrameDB["talents"]["pve"][specIndex][row][col]
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
    if ElvUI_BetterTalentFrameDB == nil then ElvUI_BetterTalentFrameDB = {} end
    if ElvUI_BetterTalentFrameDB["talents"] == nil then ElvUI_BetterTalentFrameDB["talents"] = {} end
    if ElvUI_BetterTalentFrameDB["talents"]["pve"] == nil then ElvUI_BetterTalentFrameDB["talents"]["pve"] = {} end
    -- always recreate this
    ElvUI_BetterTalentFrameDB["talents"]["pve"][GetSpecialization()] = {}

    -- cache talent infos
    local curSpec = ElvUI_BetterTalentFrameDB["talents"]["pve"][GetSpecialization()]
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
end

---------- UPDATE ----------

local function Update_Global()
    PlayerTalentFrameSpecializationLearnButton:SetEnabled(ARWICUIR_selectedSpec ~= GetSpecialization())
    
    for i = 1, GetNumSpecializations(), 1 do
        if _G["AUIR_SpecTab" .. i] and _G["AUIR_SpecTab" .. i].overlay then
            _G["AUIR_SpecTab" .. i].overlay:SetShown(ARWICUIR_selectedSpec == i)
        end
    end
end

local function UpdateTab_Specialization()
    PlayerTalentFrame_UpdateSpecFrame(PlayerTalentFrameSpecialization, ARWICUIR_selectedSpec)
    --PlayerTalentFrameTab1:Hide()
    --PlayerTalentFrameTab2:SetPoint("TOPLEFT", PlayerTalentFrame, "BOTTOMLEFT", 15, -4)
    --PlayerTalentFrameTab2:SetPoint("TOPLEFT", PlayerTalentFrame, "BOTTOMLEFT", 15, -4)
end

local function UpdateTab_Talents()
    UpdateTalentCache()
    -- replace the current talent buttons with the selected specs talents
    for i = 1, 7, 1 do
        for j = 1, 3, 1 do
            -- get vars
            local btn = GetFrame_TalentButton(i, j)
            local talentInfo = GetCache_PveTalent(ARWICUIR_selectedSpec, i, j)
            local btnTexture = GetFrame_TalentButtonIconTexture(i, j)
            if btn.ShadowedTexture ~= nil then
                btn.ShadowedTexture:Hide()
            end

            if talentInfo ~= nil then
                -- update the talent buttons
                btn.name:SetText(talentInfo.name)
                btn.icon:SetTexture(talentInfo.texture)
                -- select the correct buttons
                btnTexture:SetDesaturated(not (talentInfo.selected and ARWICUIR_selectedSpec == GetSpecialization()))
                -- setup tooltip
                btn:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                    GameTooltip:SetTalent(talentInfo.talentID)
                    GameTooltip:Show()
                end)
                btn:SetScript("OnLeave", function(self)
                    GameTooltip_Hide()
                end)

                if ARWICUIR_selectedSpec == GetSpecialization() then
                    -- enable the buttons click event as this is the currently active spec
                    btn:SetScript("OnClick", PlayerTalentButton_OnClick)
                    -- active specs have green highlighs
                    if IsAddOnLoaded("ElvUI_MerathilisUI") then
                        local _, classId = UnitClass("player")
                        local color = RAID_CLASS_COLORS[classId]
                        btn.bg.SelectedTexture:SetColorTexture(color.r, color.g, color.b, 1.0)
                    else
                        btn.bg.SelectedTexture:SetColorTexture(23/255, 49/255, 23/255, 1.0)
                    end
                    btn.bg.SelectedTexture:SetShown(talentInfo.selected)
                else
                    -- disable the buttons click event as this is not the currently active spec
                    btn:SetScript("OnClick", function(...) end)
                    -- non active specs have grey highlighs
                    btn.bg.SelectedTexture:SetColorTexture(75/255, 75/255, 75/255, 1.0)
                    btn.bg.SelectedTexture:SetShown(talentInfo.selected)
                end
            else
                -- Unknown message
                btn.name:SetText("Unknown Talent")
                btn.icon:SetTexture(0)
                btn.bg.SelectedTexture:SetShown(false)
                btn:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                    GameTooltip:SetText("Unknown Talent", 1, 0, 0)
                    GameTooltip:AddLine("Activate this specialization to update this talent.", nil, nil, nil, true)
                    GameTooltip:Show()
                end)
                btn:SetScript("OnLeave", function(self)
                    GameTooltip_Hide()
                end)
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
            SetSpecialization(ARWICUIR_selectedSpec)
        end)
        PlayerTalentFrameSpecializationLearnButton:SetEnabled(ARWICUIR_selectedSpec ~= GetSpecialization())
    end

    -- add new spec spellbook tabs to the top right of the talent frame
    local tabDim = 30
    local tabSep = 10
    local tabXOffset = 2
    for i = 1, GetNumSpecializations(), 1 do
        local specID, specName, specDesc, specIcon, specRole, specPriStat = GetSpecializationInfo(i)
        -- create the button
        btn = CreateFrame("Button", "AUIR_SpecTab" .. i, PlayerTalentFrame)
        btn:SetFrameStrata("LOW")
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
            ARWICUIR_selectedSpec = i
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
        btn.overlay:SetShown(ARWICUIR_selectedSpec == i)
    end

    Update_Global()
end

local function InitTab_Specialization()
    UpdateTab_Specialization()
    PlayerTalentFrameTab2:Click()
end

local function InitTab_Talents()
    UpdateTab_Talents()
end

local function InitTab_Pet()
    UpdateTab_Pet()
end

---------- EVENTS ----------

function events:PLAYER_SPECIALIZATION_CHANGED(...)
    UpdateTalentCache()
end

function events:PLAYER_LOGIN(...)
    UpdateTalentCache()
    ARWICUIR_selectedSpec = GetSpecialization()
    ToggleTalentFrame() -- initialize the default talent frame
    Init_Global()
    InitTab_Specialization()
    InitTab_Talents()
    InitTab_Pet()
    hooksecurefunc("PlayerTalentFrame_Update", UpdateAll)
end

function events:PLAYER_LOGOUT(...)
    UpdateTalentCache()
end

---------- MAIN ----------

function AUIR_Talents_Init()
    -- init db
    if ElvUI_BetterTalentFrameDB == nil then
        ElvUI_BetterTalentFrameDB = {}
        ElvUI_BetterTalentFrameDB["talents"] = {}
        ElvUI_BetterTalentFrameDB["talents"]["pve"] = {}
    end

    -- register events
    local eventFrame = CreateFrame("FRAME", "AUIR_eventFrame")
    eventFrame:SetScript("OnEvent", function(self, event, ...)
        events[event](self, ...)
    end)
    for k, v in pairs(events) do
        eventFrame:RegisterEvent(k)
    end
end

AUIR_Talents_Init()

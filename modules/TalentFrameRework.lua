--[[
    ElvUI_BetterTalentFrame
    Copyright (C) Arwic-Frostmourne, All rights reserved.
]]--

-- ElvUI
local E, L, V, P, G = unpack(ElvUI) -- Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TFR = E:NewModule("BetterTalentsFrame_TalentFrameRework", "AceHook-3.0", "AceEvent-3.0")

-- Config
local activateButtonWidth = 200
local activateButtonHeight = 20
local tabDim = 30
local tabSep = 10
local tabXOffset = 2
local specTabPrefix = "ARWIC_TFR_SpecTab"
local talentRowCount = 7
local talentColCount = 3

-- ensures the db is valid
function TFR:VerifyDB()
    if ElvUI_BetterTalentFrameDB == nil then
        ElvUI_BetterTalentFrameDB = {}
    end
    if ElvUI_BetterTalentFrameDB["talents"] == nil then
        ElvUI_BetterTalentFrameDB["talents"] = {}
    end
    if ElvUI_BetterTalentFrameDB["talents"]["pve"] == nil then
        ElvUI_BetterTalentFrameDB["talents"]["pve"] = {}
    end
end

-- returns the pve talent info for a given spec at the given row and column
function TFR:GetCachedTalentInfo(specIndex, row, col)
    -- VerifyDB only guarantees us ["talents"]["pve"], not our spec table
    if ElvUI_BetterTalentFrameDB["talents"]["pve"][specIndex] == nil then
        return nil
    end
    return ElvUI_BetterTalentFrameDB["talents"]["pve"][specIndex][row][col]
end

-- returns the talent button frame at the given row and column
function TFR:GetTalentButtonFrame(row, col)
    return _G["PlayerTalentFrameTalentsTalentRow" .. row .. "Talent" .. col]
end

-- returns the texture widget of the talent button at the given row and column
function TFR:GetTalentButtonTexture(row, col)
    return _G["PlayerTalentFrameTalentsTalentRow" .. row .. "Talent" .. col .. "IconTexture"]
end

-- caches the current specs talent configuration
function TFR:UpdateTalentCache()
    -- always recreate the currents specs talent table
    self:VerifyDB()
    ElvUI_BetterTalentFrameDB["talents"]["pve"][GetSpecialization()] = {}

    -- save the current specs talents
    local curSpec = ElvUI_BetterTalentFrameDB["talents"]["pve"][GetSpecialization()]
    for i = 1, talentRowCount do
        curSpec[i] = {}
        for j = 1, talentColCount do
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

function TFR:GetSpecTabIcon(index)
    return _G[specTabPrefix .. index]
end

---------- UPDATE ----------

function TFR:UpdateActivateButton()
    PlayerTalentFrame_UpdateSpecFrame(PlayerTalentFrameSpecialization, TFR.selectedSpec)
    for i = 1, GetNumSpecializations() do
        _G["PlayerTalentFrameSpecializationSpecButton"..i]:SetScript("OnClick", function()
            TFR.selectedSpec = i
            self:Update()
        end)
    end
end

function TFR:UpdateSpecTab()
    -- enable the activate button if the selected spec is not currently active
    PlayerTalentFrameSpecializationLearnButton:SetEnabled(TFR.selectedSpec ~= GetSpecialization())
    for i = 1, GetNumSpecializations(), 1 do
        local icon = self:GetSpecTabIcon(i)
        if icon and icon.overlay then
            icon.overlay:SetShown(TFR.selectedSpec == i)
        end
    end
end

function TFR:UpdateTalentsTab()
    -- update the talent cache
    self:UpdateTalentCache()
    -- replace the talent buttons with the selected specs talents
    for i = 1, talentRowCount do
        for j = 1, talentColCount do
            -- get vars
            local btn = self:GetTalentButtonFrame(i, j)
            local talentInfo = self:GetCachedTalentInfo(TFR.selectedSpec, i, j)
            local btnTexture = self:GetTalentButtonTexture(i, j)

            -- this is new in BFA and it messes with how we display non active spec talents
            if btn.ShadowedTexture ~= nil then
                btn.ShadowedTexture:Hide()
            end

            if talentInfo ~= nil then
                -- we have a talent cached for this button
                -- update the button with new talent info
                btn.name:SetText(talentInfo.name)
                btn.icon:SetTexture(talentInfo.texture)
                -- highlight the button if it is for a selected talent
                btnTexture:SetDesaturated(not (talentInfo.selected and TFR.selectedSpec == GetSpecialization()))
                -- update the button's tooltip
                btn:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                    GameTooltip:SetTalent(talentInfo.talentID)
                    GameTooltip:Show()
                end)
                btn:SetScript("OnLeave", function(self)
                    GameTooltip_Hide()
                end)

                if TFR.selectedSpec == GetSpecialization() then
                    -- this is the currently active spec, we need to enable full functionality so the user can select talents
                    -- enable the buttons click event
                    btn:SetScript("OnClick", PlayerTalentButton_OnClick)
                    if IsAddOnLoaded("ElvUI_MerathilisUI") then
                        -- support for ElvUI_MerathilisUI
                        local _, classId = UnitClass("player")
                        local color = RAID_CLASS_COLORS[classId]
                        btn.bg.SelectedTexture:SetColorTexture(color.r, color.g, color.b, 1.0)
                    else
                        -- normal green ElvUI highlight
                        btn.bg.SelectedTexture:SetColorTexture(23/255, 49/255, 23/255, 1.0)
                    end
                    -- show the selected texture if the talent is selected
                    btn.bg.SelectedTexture:SetShown(talentInfo.selected)
                else 
                    -- we arnt viewing the active spec
                    -- disable the buttons click event
                    btn:SetScript("OnClick", function(...) end)
                    -- non active specs have light grey highlighs
                    btn.bg.SelectedTexture:SetColorTexture(75/255, 75/255, 75/255, 1.0)
                    -- show the selected texture if the talent is selected
                    btn.bg.SelectedTexture:SetShown(talentInfo.selected)
                end
            else
                -- we dont have a talent cached for this button
                -- show unknown message and advise user to switch spec to update their data
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

function TFR:Update()
    self:UpdateActivateButton()
    self:UpdateSpecTab()
    self:UpdateTalentsTab()
end

---------- INIT ----------

function TFR:InitActivateButton()
    -- make the activate button appear on every tab
    local btn = PlayerTalentFrameSpecializationLearnButton
    if btn ~= nil then
        btn:SetText("Activate Specialization")
        btn:SetSize(activateButtonWidth, activateButtonHeight)
        btn:SetParent(PlayerTalentFrame)
        btn:SetScript("OnClick", function(self, button) 
            SetSpecialization(TFR.selectedSpec)
        end)
        btn:SetEnabled(TFR.selectedSpec ~= GetSpecialization())
    end
end

function TFR:InitSpecIcons()
    -- add new spec spellbook style tabs to the top right of the talent frame
    for i = 1, GetNumSpecializations() do
        local spedID, specName, specDesc, specIcon = GetSpecializationInfo(i)
        -- create the button
        btn = CreateFrame("Button", specTabPrefix .. i, PlayerTalentFrame)
        btn:SetFrameStrata("LOW")
        btn:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPRIGHT", tabXOffset, -((tabSep + tabDim) * i))
        btn:SetSize(tabDim, tabDim)
        btn:CreateBackdrop("Default") -- ElvUI func
        -- add a tooltip containing the specs description
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(specName, 1, 1, 1) -- This sets the top line of text, in gold.
            GameTooltip:AddLine(specDesc, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        -- set a click action
        btn:SetScript("OnClick", function(self, button)
            TFR.selectedSpec = i
            TFR:SendMessage("ARWIC_BTF_SPEC_SELECTION_CHANGED", TFR.selectedSpec)
            TFR:Update()
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
        -- give the icon an overlay to indicate the currently selected spec
        if btn.overlay == nil then
            btn.overlay = btn:CreateTexture(nil, "OVERLAY")
            btn.overlay:SetSize(tabDim, tabDim)
            btn.overlay:SetPoint("TOPLEFT")
            btn.overlay:SetColorTexture(1.0, 1.0, 1.0, 0.51) -- Needs to be over 0.5?
        end
        btn.overlay:SetShown(TFR.selectedSpec == i)
    end
end

function TFR:PLAYER_SPECIALIZATION_CHANGED()
    self:UpdateTalentCache()
end

function TFR:PLAYER_LOGOUT()
    self:UpdateTalentCache()
end

function TFR:PLAYER_ENTERING_WORLD()
    if not self.hasRunOneTime then
        TalentFrame_LoadUI() -- make sure the talent frame is loaded
        self:VerifyDB() -- make sure the db exists
        self:UpdateTalentCache() -- update the currently selected spec and talents
        TFR.selectedSpec = GetSpecialization() -- select the players current spec by default
        self:InitActivateButton() -- initialise the activate button
        self:InitSpecIcons() -- initialise the spec spellbook icons
        self:SecureHook("PlayerTalentFrame_Update", "Update")
        self.hasRunOneTime = true
    end

    -- default to talents tab if required
    if E.db.BetterTalentsFrame.DefaultToTalentsTab then
        PlayerTalentFrameTab2:Click()
    end
    -- hide the pvp talents flyout if required
    if E.db.BetterTalentsFrame.AutoHidePvPTalents then
        PlayerTalentFrameTalentsPvpTalentButton:Click()
    end
end

---------- MAIN ----------

function TFR:Initialize()
    -- register events
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("PLAYER_LOGOUT")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

E:RegisterModule(TFR:GetName())
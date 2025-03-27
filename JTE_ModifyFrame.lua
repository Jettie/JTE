local _G = _G
local addonName, JTE = ...

JTE.ModifyFrame = JTE.ModifyFrame or {}
local MF = JTE.ModifyFrame
local JTE_Print = JTE_Print or print
local ModifyFrame, ModifyFrameEvents = CreateFrame("Frame"), {};

local ENABLE_TEXT = "|cff00FF00启用|r"
local DISABLE_TEXT = "|cFFFF0000关闭|r"

local SV
local LoadSavedVariables = function()
	-- SavedVariables: db
	local db = JTEDB or {}
	db.Config = db.Config or {}
	SV = db.Config

    SV.ModifyMacro = SV.ModifyMacro or false
    SV.ModifyTalent = SV.ModifyTalent or false
end

local original = {}
local ModifyMacroFrame = function()
    local AddSelectHeight = 100
    local AddTextHeight = 150
    local tempScrollPer = nil
    local ChangeMacroFrame = function()
        -- hooksecurefunc(MacroFrame, "SelectMacro", function(self, index)
        --     if tempScrollPer then
        --         MacroFrame.MacroSelector.ScrollBox:SetScrollPercentage(tempScrollPer)
        --         tempScrollPer = nil
        --     end
        -- end)
        if not original.MacroFrame then
            original.MacroFrame = {
                MacroSelectorHeight = MacroFrame.MacroSelector:GetHeight(),
                MacroHorizontalBarLeftX = select(4,MacroHorizontalBarLeft:GetPoint()),
                MacroHorizontalBarLeftY = select(5,MacroHorizontalBarLeft:GetPoint()),
                MacroFrameSelectedMacroBackgroundX = select(4,MacroFrameSelectedMacroBackground:GetPoint()),
                MacroFrameSelectedMacroBackgroundY = select(5,MacroFrameSelectedMacroBackground:GetPoint()),
                MacroFrameTextBackgroundX = select(4,MacroFrameTextBackground:GetPoint()),
                MacroFrameTextBackgroundY = select(5,MacroFrameTextBackground:GetPoint()),
                MacroFrameHeight = MacroFrame:GetHeight(),
                MacroFrameScrollFrameHeight = MacroFrameScrollFrame:GetHeight(),
                MacroFrameTextHeight = MacroFrameText:GetHeight(),
                MacroFrameTextButtonHeight = MacroFrameTextButton:GetHeight(),
                MacroFrameTextBackgroundHeight = MacroFrameTextBackground:GetHeight()
            }
        end

        if SV and SV.ModifyMacro then
            MacroFrame.MacroSelector:SetHeight(146 + AddSelectHeight) -- 146 原值
            MacroHorizontalBarLeft:SetPoint("TOPLEFT", 2, -210 - AddSelectHeight) -- 2, -210 原值
            MacroFrameSelectedMacroBackground:SetPoint("TOPLEFT", 2, -218 - AddSelectHeight) -- 5, -218 原值
            MacroFrameTextBackground:SetPoint("TOPLEFT", 6, -289 - AddSelectHeight) -- 6, -289 原值
            local h = MacroFrame:GetHeight() -- 424 原值
            MacroFrame:SetHeight(h + AddTextHeight + AddSelectHeight)
            MacroFrameScrollFrame:SetHeight(85 + AddTextHeight)
            MacroFrameText:SetHeight(85 + AddTextHeight)
            MacroFrameTextButton:SetHeight(85 + AddTextHeight)
            MacroFrameTextBackground:SetHeight(95 + AddTextHeight)
        else
            MacroFrame.MacroSelector:SetHeight(original.MacroFrame.MacroSelectorHeight)
            MacroHorizontalBarLeft:SetPoint("TOPLEFT", original.MacroFrame.MacroHorizontalBarLeftX, original.MacroFrame.MacroHorizontalBarLeftY)
            MacroFrameSelectedMacroBackground:SetPoint("TOPLEFT", original.MacroFrame.MacroFrameSelectedMacroBackgroundX, original.MacroFrame.MacroFrameSelectedMacroBackgroundY)
            MacroFrameTextBackground:SetPoint("TOPLEFT", original.MacroFrame.MacroFrameTextBackgroundX, original.MacroFrame.MacroFrameTextBackgroundY)
            MacroFrame:SetHeight(original.MacroFrame.MacroFrameHeight)
            MacroFrameScrollFrame:SetHeight(original.MacroFrame.MacroFrameScrollFrameHeight)
            MacroFrameText:SetHeight(original.MacroFrame.MacroFrameTextHeight)
            MacroFrameTextButton:SetHeight(original.MacroFrame.MacroFrameTextButtonHeight)
            MacroFrameTextBackground:SetHeight(original.MacroFrame.MacroFrameTextBackgroundHeight)
        end
    end
    if MacroFrame then
        ChangeMacroFrame()
    else
        local f = CreateFrame("Frame");
        f:SetScript("OnEvent", function(self, event, addon)
            if event == "ADDON_LOADED" then
                if addon == "Blizzard_MacroUI" then
                    ChangeMacroFrame()
                    f:UnregisterEvent("ADDON_LOADED");
                end
            elseif MacroFrame then
                tempScrollPer = MacroFrame.MacroSelector.ScrollBox.scrollPercentage
            end
        end)
        f:RegisterEvent("ADDON_LOADED")
        --MacroFrame会在每次显示的时候注册UPDATE_MACROS，所以肯定比我们执行的要晚
        --这一切前提建立在这个条件上
        f:RegisterEvent("UPDATE_MACROS")
    end
end
ModifyMacroFrame()

local ModifyMacroToggle = function()
    SV.ModifyMacro = not SV.ModifyMacro
    local statusText = SV.ModifyMacro and ENABLE_TEXT or DISABLE_TEXT
    local text = "宏界面拉长 "..statusText
    ModifyMacroFrame()
    JTE_Print(text)
end
JTE.ModifyMacroToggle = ModifyMacroToggle

local ModifyTalentFrame = function()
    local changeTalentFrame = function()
        if not original.PlayerTalentFrame then
            original.PlayerTalentFrame = {
                Height = PlayerTalentFrame:GetHeight()
            }
        end
        if SV and SV.ModifyTalent then
            PlayerTalentFrame:SetHeight(900) -- 512 原值 PlayerTalentFrame:GetHeight()
        else
            PlayerTalentFrame:SetHeight(original.PlayerTalentFrame.Height)
        end
    end

	if PlayerTalentFrame then
		changeTalentFrame()
	else
		local f = CreateFrame("Frame");
        f:SetScript("OnEvent", function(self, event, addon)
            if event == "ADDON_LOADED" then
                if addon == "Blizzard_TalentUI" then
                    changeTalentFrame()
                    f:UnregisterEvent("ADDON_LOADED");
                end
            end
        end)
        f:RegisterEvent("ADDON_LOADED")
	end

    local changeGlyphFrame = function()
        if not original.GlyphFrame then
            original.GlyphFrame = {
                GlyphFrameBackgroundX = select(4,GlyphFrameBackground:GetPoint()),
                GlyphFrameBackgroundY = select(5,GlyphFrameBackground:GetPoint()),
                GlyphFrameGlyph1X = select(4,GlyphFrameGlyph1:GetPoint()),
                GlyphFrameGlyph1Y = select(5,GlyphFrameGlyph1:GetPoint()),
                GlyphFrameGlyph2X = select(4,GlyphFrameGlyph2:GetPoint()),   
                GlyphFrameGlyph2Y = select(5,GlyphFrameGlyph2:GetPoint()),
                GlyphFrameGlyph3X = select(4,GlyphFrameGlyph3:GetPoint()),
                GlyphFrameGlyph3Y = select(5,GlyphFrameGlyph3:GetPoint()),
                GlyphFrameGlyph4X = select(4,GlyphFrameGlyph4:GetPoint()),
                GlyphFrameGlyph4Y = select(5,GlyphFrameGlyph4:GetPoint()),
                GlyphFrameGlyph5X = select(4,GlyphFrameGlyph5:GetPoint()),
                GlyphFrameGlyph5Y = select(5,GlyphFrameGlyph5:GetPoint()),
                GlyphFrameGlyph6X = select(4,GlyphFrameGlyph6:GetPoint()),
                GlyphFrameGlyph6Y = select(5,GlyphFrameGlyph6:GetPoint()),
            }
        end
        if SV and SV.ModifyTalent then
            GlyphFrameBackground:SetPoint("TOPLEFT",14,-226)
            GlyphFrameGlyph1:SetPoint("CENTER", -15, 155)
            GlyphFrameGlyph2:SetPoint("CENTER", -14, -87)
            GlyphFrameGlyph3:SetPoint("TOPLEFT", 28, -313)
            GlyphFrameGlyph4:SetPoint("BOTTOMRIGHT", -56, 378)
            GlyphFrameGlyph5:SetPoint("TOPRIGHT", -56, -313)
            GlyphFrameGlyph6:SetPoint("BOTTOMLEFT", 26, 378)
        else
            GlyphFrameBackground:SetPoint("TOPLEFT",original.GlyphFrame.GlyphFrameBackgroundX,original.GlyphFrame.GlyphFrameBackgroundY)
            GlyphFrameGlyph1:SetPoint("CENTER", original.GlyphFrame.GlyphFrameGlyph1X, original.GlyphFrame.GlyphFrameGlyph1Y)
            GlyphFrameGlyph2:SetPoint("CENTER", original.GlyphFrame.GlyphFrameGlyph2X, original.GlyphFrame.GlyphFrameGlyph2Y)
            GlyphFrameGlyph3:SetPoint("TOPLEFT", original.GlyphFrame.GlyphFrameGlyph3X, original.GlyphFrame.GlyphFrameGlyph3Y)
            GlyphFrameGlyph4:SetPoint("BOTTOMRIGHT", original.GlyphFrame.GlyphFrameGlyph4X, original.GlyphFrame.GlyphFrameGlyph4Y)
            GlyphFrameGlyph5:SetPoint("TOPRIGHT", original.GlyphFrame.GlyphFrameGlyph5X, original.GlyphFrame.GlyphFrameGlyph5Y)
            GlyphFrameGlyph6:SetPoint("BOTTOMLEFT", original.GlyphFrame.GlyphFrameGlyph6X, original.GlyphFrame.GlyphFrameGlyph6Y)
        end
    end

    if GlyphFrame then
        changeGlyphFrame()
    else
		local f = CreateFrame("Frame");
        f:SetScript("OnEvent", function(self, event, addon)
            if event == "ADDON_LOADED" then
                if addon == "Blizzard_GlyphUI" then
                    changeGlyphFrame()
                    f:UnregisterEvent("ADDON_LOADED");
                end
            end
        end)
        f:RegisterEvent("ADDON_LOADED")
	end
end
ModifyTalentFrame()

local ModifyTalentToggle = function()
    SV.ModifyTalent = not SV.ModifyTalent
    local statusText = SV.ModifyTalent and ENABLE_TEXT or DISABLE_TEXT
    local text = "天赋加长功能 "..statusText
    ModifyTalentFrame()
    JTE_Print(text)
end
JTE.ModifyTalentToggle = ModifyTalentToggle

function ModifyFrameEvents:PLAYER_ENTERING_WORLD(...)
	LoadSavedVariables()
	ModifyFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

ModifyFrame:SetScript("OnEvent", function(self, event, ...)
	ModifyFrameEvents[event](self, ...); -- call one of the functions above
end);

for k, v in pairs(ModifyFrameEvents) do
	ModifyFrame:RegisterEvent(k); -- Register all ModifyFrameEvents for which handlers have been defined
end
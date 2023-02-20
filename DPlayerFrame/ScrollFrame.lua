local ADDON_NAME, namespace = ...
local L = namespace.L
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local addoninfo = "v" ..version
local _, class = UnitClass("player")
local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]

local addon = LibStub("AceAddon-3.0"):NewAddon("DPlayerFrame", "AceConsole-3.0")
local Media = LibStub("LibSharedMedia-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")



--------------------------
-- SavedVariables Setup --
--------------------------
local _, addon = ...
local DPlayerFrame, gdbprivate = ...

gdbprivate.gdbdefaults = {
}
gdbprivate.gdbdefaults.gdbdefaults = {
}

----------------------------
-- Saved Variables Loader --
----------------------------
local loader = CreateFrame("Frame")
	loader:RegisterEvent("ADDON_LOADED")
	loader:SetScript("OnEvent", function(self, event, arg1)
		if event == "ADDON_LOADED" and arg1 == "DPlayerFrame" then
			local function initDB(gdb, gdbdefaults)
				if type(gdb) ~= "table" then gdb = {} end
				if type(gdbdefaults) ~= "table" then return gdb end
				for k, v in pairs(gdbdefaults) do
					if type(v) == "table" then
						gdb[k] = initDB(gdb[k], v)
					elseif type(v) ~= type(gdb[k]) then
						gdb[k] = v
					end
				end
				return gdb
			end

			DPCoreDBPC = initDB(DPCoreDBPC, gdbprivate.gdbdefaults) --the first per account saved variable. The second per-account variable dpf_ClassSpecDB is handled in dpf_Layouts.lua
			gdbprivate.gdb = DPCoreDBPC --fast access for checkbox states
			self:UnregisterEvent("ADDON_LOADED")
		end
	end)

local DPlayerFrame, private = ...

private.defaults = {
}
private.defaults.dpfdefaults = {
}

DPlayerFrame = {}

----------------------------
-- Saved Variables Loader --
----------------------------
local loader = CreateFrame("Frame")
	loader:RegisterEvent("ADDON_LOADED")
	loader:SetScript("OnEvent", function(self, event, arg1)
		if event == "ADDON_LOADED" and arg1 == "DPlayerFrame" then
			local function initDB(db, defaults)
				if type(db) ~= "table" then db = {} end
				if type(defaults) ~= "table" then return db end
				for k, v in pairs(defaults) do
					if type(v) == "table" then
						db[k] = initDB(db[k], v)
					elseif type(v) ~= type(db[k]) then
						db[k] = v
					end
				end
				return db
			end

			DPCoreDBPCPC = initDB(DPCoreDBPCCPC, private.defaults) --saved variable per character, currently not used.
			private.db = DPCoreDBPCPC

			self:UnregisterEvent("ADDON_LOADED")
		end
	end)



---------------------
-- dpf Slash Setup --
---------------------
local RegisteredEvents = {}
local dpfslash = CreateFrame("Frame", "DPlayerFrameSlash", UIParent)

dpfslash:SetScript("OnEvent", function (self, event, ...) 
	if (RegisteredEvents[event]) then 
	return RegisteredEvents[event](self, event, ...) 
	end
end)

function RegisteredEvents:ADDON_LOADED(event, addon, ...)
	if (addon == "DPlayerFrame") then
		--SLASH_DPlayerFrame1 = (L["/dpftats"])
		SLASH_DPlayerFrame1 = "/dp"
		SlashCmdList["DPlayerFrame"] = function (msg, editbox)
			DPlayerFrame.SlashCmdHandler(msg, editbox)	
	end
	--	DEFAULT_CHAT_FRAME:AddMessage("DPlayerFrame loaded successfully. For options: Esc>Interface>AddOns or type /dpftats.",0,192,255)
	end
end

for k, v in pairs(RegisteredEvents) do
	dpfslash:RegisterEvent(k)
end

function DPlayerFrame.ShowHelp()
	print(addoninfo)
	print(L["DPlayerFrame Slash commands (/dpframe):"])
	print(L["  /dp config: Opens the DPlayerFrame addon config menu."])
	print(L["  /dp toggle: Enables/Disables view of the display."])
	print(L["  /dp reset:  Resets DPlayerFrame options to default."])
end

function DPlayerFrame.SlashCmdHandler(msg, editbox)
    msg = string.lower(msg)
	--print("command is " .. msg .. "\n")
	--if (string.lower(msg) == L["config"]) then --I think string.lowermight not work for Russian letters
	if (msg == "config") then
		InterfaceOptionsFrame_OpenToCategory("DPlayerFrame")
		InterfaceOptionsFrame_OpenToCategory("DPlayerFrame")
		InterfaceOptionsFrame_OpenToCategory("DPlayerFrame")
	elseif (msg == "toggle") and statFrame:IsVisible() then
		statFrame:Hide()
	elseif (msg == "toggle") and not statFrame:IsVisible() then
		statFrame:Show()
	elseif (msg == "reset") then
		--DPlayerFrameDBPCPC = private.defaults
		gdbprivate.gdb.gdbdefaults = gdbprivate.gdbdefaults.gdbdefaults
		ReloadUI()
	else
		DPlayerFrame.ShowHelp()
	end
end
	SlashCmdList["DPlayerFrame"] = DPlayerFrame.SlashCmdHandler


-----------------------
-- dpf Options Panel --
-----------------------
DPlayerFrame.panel = CreateFrame( "Frame", "DPlayerFramePanel", UIParent )
DPlayerFrame.panel.name = "DPlayerFrame"
InterfaceOptions_AddCategory(DPlayerFrame.panel)


local dpftitle=CreateFrame("Frame", "DPFTitle", DPlayerFramePanel)
	dpftitle:SetPoint("TOPLEFT", 10, -10)
	--dpftitle:SetScale(2.0)
	dpftitle:SetWidth(300)
	dpftitle:SetHeight(100)
	dpftitle:Show()

local dpftitleFS = dpftitle:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	dpftitleFS:SetText('|cfff1c232DPlayerFrame|r')
	dpftitleFS:SetPoint("TOPLEFT", 0, 0)
	dpftitleFS:SetFont("Fonts\\FRIZQT__.TTF", 20)

local dpfversionFS = DPlayerFramePanel:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	dpfversionFS:SetText('|cff00c0ff' .. addoninfo .. '|r')
	dpfversionFS:SetPoint("BOTTOMRIGHT", -10, 10)
	dpfversionFS:SetFont("Fonts\\FRIZQT__.TTF", 12)
	
local dpfresetcheck = CreateFrame("Button", "DPFResetButton", DPlayerFramePanel, "UIPanelButtonTemplate")
	dpfresetcheck:ClearAllPoints()
	dpfresetcheck:SetPoint("BOTTOMLEFT", 5, 5)
	dpfresetcheck:SetScale(1.25)

	--local LOCALE = GetLocale()
	local LOCALE = namespace.locale
		--print (LOCALE)
	local altWidth = {
		["ptBR"] = {},
		["frFR"] = {},
		["deDE"] = {},
		["ruRU"] = {},
	}
	local altWidth2 = {
		["esES"] = {},
	}

	if altWidth[LOCALE] then
		LOCALE = 175
	elseif altWidth2[LOCALE] then
		LOCALE = 200
	else
		--print ("enUS = 125")
		LOCALE = 125
	end
	dpfresetcheck:SetWidth(LOCALE)

	dpfresetcheck:SetHeight(30)
	_G[dpfresetcheck:GetName() .. "Text"]:SetText(L["Save & Close"])
	dpfresetcheck:SetScript("OnClick", function(self, button, down)
		ReloadUI()
	end)


	----------------------
	-- Panel Categories --
	----------------------
	
	-- Defaults
	local DPFItemsPanelCategoryFS = DPlayerFramePanel:CreateFontString("DPFItemsPanelCategoryFS", "OVERLAY", "GameTooltipText")
	DPFItemsPanelCategoryFS:SetText('|cffffffff' .. L["Defaults:"] .. '|r')
	DPFItemsPanelCategoryFS:SetPoint("TOPLEFT", 25, -40)
	DPFItemsPanelCategoryFS:SetFontObject("GameTooltipText") --Use instead of SetFont("Fonts\\FRIZQT__.TTF", 15) or Russian, Korean and Chinese characters won't work.
	
	local DPFDefaultDescriptionFS = DPlayerFramePanel:CreateFontString("DPFDefaultDescriptionFS", "OVERLAY", "GameTooltipText")
	DPFDefaultDescriptionFS:SetText('|cffffff00' .. L["These options require a /reload or \n press the save button at the bottom."] .. '|r')
	DPFDefaultDescriptionFS:SetPoint("TOPLEFT", 25, -180)
	DPFDefaultDescriptionFS:SetFontObject("GameTooltipTextSmall")

	-- --Miscellaneous
	local DPFMiscPanelCategoryFS = DPlayerFramePanel:CreateFontString("DPFMiscPanelCategoryFS", "OVERLAY", "GameTooltipText")
	DPFMiscPanelCategoryFS:SetText('|cffffffff' .. L["Miscellaneous:"] .. '|r')
	DPFMiscPanelCategoryFS:SetPoint("LEFT", 25, 0)
	DPFMiscPanelCategoryFS:SetFontObject("GameTooltipText") --Use instead of SetFont("Fonts\\FRIZQT__.TTF", 15) or Russian, Korean and Chinese characters won't work.

	--Show/Hide Headers
	local DPFItemsPanelHeadersFS = DPlayerFramePanel:CreateFontString("DPFItemsPanelHeadersFS", "OVERLAY", "GameTooltipText")
	DPFItemsPanelHeadersFS:SetText('|cffffffff' .. L["Categories:"] .. '|r')
	DPFItemsPanelHeadersFS:SetPoint("TOPLEFT", 225, -40)
	DPFItemsPanelHeadersFS:SetFontObject("GameTooltipText") --Use instead of SetFont("Fonts\\FRIZQT__.TTF", 15) or Russian, Korean and Chinese characters won't work.


	local SettingsLogo = CreateFrame("Frame", "DPLogo", DPlayerFramePanel)
	SettingsLogo:SetPoint("BOTTOMRIGHT", -30, -10)
	SettingsLogo:SetSize(130, 95)

local t=SettingsLogo:CreateTexture(nil,"ARTWORK")
		t:SetAllPoints(SettingsLogo)
		-- t:SetColorTexture(1, 1, 1, 0)
		t:SetTexture"Interface\\Addons\\DPlayerFrame\\Textures\\BigLogo.tga"
		t:SetVertexColor(1, 1, 1)

---------------
-- Font Size --
---------------

	local info = {}
	local fontDropdown = CreateFrame("Frame", "DPlayerFrameFont", DPlayerFramePanel, "UIDropDownMenuTemplate")
	fontDropdown:SetPoint("TOPLEFT", "DPFItemsPanelCategoryFS", 7, -75)
	fontDropdown.initialize = function()
		wipe(info)
		local fonts = {"Fonts\\ARIALN.TTF",
			           "Interface\\Addons\\DPlayerFrame\\Fonts\\DPF.TTF",
					   "Fonts\\FRIZQT__.TTF",
					   "Fonts\\2002.TTF",
					   "Fonts\\2002B.TTF",
					   "Fonts\\MORPHEUS.TTF",
					   "Fonts\\NIM_____.ttf",
					   "Fonts\\SKURRI.TTF",
					   "Interface\\Addons\\DPlayerFrame\\Fonts\\FiraMono-Medium.TTF",
					   "Interface\\Addons\\DPlayerFrame\\Fonts\\PTSandsNarrow.TTF",
					   "Interface\\Addons\\DPlayerFrame\\Fonts\\Accidental Presidency.TTF",
					   "Interface\\Addons\\DPlayerFrame\\Fonts\\FORCED SQUARE.TTF",
					   "Interface\\Addons\\DPlayerFrame\\Fonts\\HARRYP__.TTF",
					   "Interface\\Addons\\DPlayerFrame\\Fonts\\Nueva Std Cond.TTF",
					   "Interface\\Addons\\DPlayerFrame\\Fonts\\Oswald-Regular.TTF",
					   "Interface\\Addons\\DPlayerFrame\\Fonts\\ActionMan.TTF",
					   "Interface\\Addons\\DPlayerFrame\\Fonts\\ContinuumMedium.TTF",
					   "Interface\\Addons\\DPlayerFrame\\Fonts\\DieDieDie.TTF",
					   "Interface\\Addons\\DPlayerFrame\\Fonts\\Expressway.TTF",
					   "Interface\\Addons\\DPlayerFrame\\Fonts\\Homespun.TTF",

					}
		local names = {L["Default Font"], L["DP"], L["FrizQT"], L["2002"], L["2002 Bold"], L["Morpheus"], L["Nimrod MT"], L["Skurri"], L["FiraMono"], L["Sans"], 
		               L["Accidental Presidency"], L["Square"], L["Harry Potter"], L["NSC"], L["Oswald"], L["Action Man"], L["Continuum"], L["DieDieDie"],
					   L["Expressway"], L["Homespun"]} 
		for i, font in next, fonts do
			info.text = names[i]
			info.value = font
			info.func = function(self)
				gdbprivate.gdb.gdbdefaults.font = self.value
				if _G[DPlayerFrame:GetName() .. "Font"] then
					_G[DPlayerFrame:GetName() .. "Font"]:SetFont(_G[self.value], 12, "OUTLINE")
				end
				DPlayerFrameFontText:SetText(self:GetText())
			end
			info.checked = font == gdbprivate.gdb.gdbdefaults.font
			UIDropDownMenu_AddButton(info)
		end
	end
	DPlayerFrameFontText:SetText(L["Font"])



	local info = {}
	local styleDropdown = CreateFrame("Frame", "DPlayerFrameStyle", DPlayerFramePanel, "UIDropDownMenuTemplate")
	styleDropdown:SetPoint("TOPLEFT", "DPFItemsPanelCategoryFS", 7, -105)
	styleDropdown.initialize = function()
		wipe(info)
		local styles = {"NONE", "OUTLINE", "THICKOUTLINE", "MONOCHROME"}
		local names = {L["None"], L["Outline"], L["Thickoutline"], L["Monochrome"]} 
		for i, style in next, styles do
			info.text = names[i]
			info.value = style
			info.func = function(self)
				gdbprivate.gdb.gdbdefaults.style = self.value
				if _G[DPlayerFrame:GetName() .. "Text"] then
					_G[DPlayerFrame:GetName() .. "Text"]:SetFont("", 12, _G[self.value])
				end
				DPlayerFrameStyleText:SetText(self:GetText())
			end
			info.checked = style == gdbprivate.gdb.gdbdefaults.style
			UIDropDownMenu_AddButton(info)
		end
	end
	DPlayerFrameStyleText:SetText(L["Style"])


----------------
-- Local Vars --
----------------
local ShowDefaultStats 
local DefaultResistances
local ShowModelRotation
local ShowPrimary
local ShowMelee
local ShowRanged
local ShowSpell
local ShowDefense


-------------------
-- Frame Offsets --
-------------------


local stat_FrameWidth, stat_FrameHeight = 150, 424
local stat_HeaderWidth, stat_HeaderHeight = 172, 28
local stat_RframeInset = 25
local stat_HeaderInsetX = 2.5
local stat_StatScale = 1.25

local function statHeaderYOffsets()
	local primaryYoffset = -10
	local meleeYoffset = -168
	local rangedYoffset = -382
	local spellYoffset = -527
	local defenseYoffset = -727

	ShowPrimary = gdbprivate.gdb.gdbdefaults.DPlayerFrameShowPrimaryChecked.ShowPrimarySetChecked
	ShowMelee = gdbprivate.gdb.gdbdefaults.DPlayerFrameShowMeleeChecked.ShowMeleeSetChecked
	ShowRanged = gdbprivate.gdb.gdbdefaults.DPlayerFrameShowRangedChecked.ShowRangedSetChecked
	ShowSpell = gdbprivate.gdb.gdbdefaults.DPlayerFrameShowSpellChecked.ShowSpellSetChecked
	ShowDefense = gdbprivate.gdb.gdbdefaults.DPlayerFrameShowDefenseChecked.ShowDefenseSetChecked

	if ShowPrimary then 
		primaryYoffset = primaryYoffset
		DPFPrimaryStatsHeader:Show()
	else 
		defenseYoffset = defenseYoffset - meleeYoffset + primaryYoffset
		spellYoffset = spellYoffset - meleeYoffset + primaryYoffset
		rangedYoffset = rangedYoffset - meleeYoffset + primaryYoffset
		meleeYoffset = meleeYoffset - meleeYoffset + primaryYoffset
		DPFPrimaryStatsHeader:Hide()
	end
	if ShowMelee then 
		meleeYoffset = meleeYoffset
		DPFMeleeEnhancementsStatsHeader:Show()
	else 
		defenseYoffset = defenseYoffset - rangedYoffset + meleeYoffset
		spellYoffset = spellYoffset - rangedYoffset + meleeYoffset
		rangedYoffset = rangedYoffset - rangedYoffset + meleeYoffset
		meleeYoffset = meleeYoffset - rangedYoffset + meleeYoffset
		DPFMeleeEnhancementsStatsHeader:Hide()
	end
	if ShowRanged then 
		rangedYoffset = rangedYoffset
		DPFRangedStatsHeader:Show()
	else
		defenseYoffset = defenseYoffset - spellYoffset + rangedYoffset
		spellYoffset = spellYoffset - spellYoffset + rangedYoffset
		rangedYoffset = rangedYoffset - spellYoffset + rangedYoffset
		meleeYoffset = meleeYoffset - spellYoffset + rangedYoffset
		DPFRangedStatsHeader:Hide()
	end
	if ShowSpell then 
		spellYoffset = spellYoffset
		DPFSpellEnhancementsStatsHeader:Show()
	else 
		defenseYoffset = defenseYoffset - defenseYoffset + spellYoffset
		spellYoffset = spellYoffset - defenseYoffset + spellYoffset
		rangedYoffset = rangedYoffset - defenseYoffset + spellYoffset
		meleeYoffset = meleeYoffset - defenseYoffset + spellYoffset
		DPFSpellEnhancementsStatsHeader:Hide()
	end
	if ShowDefense then 
		defenseYoffset = defenseYoffset
		DPFDefenseStatsHeader:Show()
	else
		DPFDefenseStatsHeader:Hide()
	end

	-- primaryYoffset = primaryYoffset
	-- meleeYoffset = meleeYoffset + primaryYoffset
	-- rangedYoffset = rangedYoffset + meleeYoffset + primaryYoffset
	-- spellYoffset = spellYoffset + rangedYoffset + meleeYoffset + primaryYoffset
	-- defenseYoffset = defenseYoffset + spellYoffset + rangedYoffset + meleeYoffset + primaryYoffset

	DPFPrimaryStatsHeader:ClearAllPoints()
	DPFPrimaryStatsHeader:SetPoint("TOPLEFT", "DPlayerFrameFrame", "TOPLEFT", stat_HeaderInsetX, primaryYoffset)
	DPFMeleeEnhancementsStatsHeader:ClearAllPoints()
	DPFMeleeEnhancementsStatsHeader:SetPoint("TOPLEFT", "DPlayerFrameFrame", "TOPLEFT", stat_HeaderInsetX, meleeYoffset)
	DPFRangedStatsHeader:ClearAllPoints()
	DPFRangedStatsHeader:SetPoint("TOPLEFT", "DPlayerFrameFrame", "TOPLEFT", stat_HeaderInsetX, rangedYoffset)
	DPFSpellEnhancementsStatsHeader:ClearAllPoints()
	DPFSpellEnhancementsStatsHeader:SetPoint("TOPLEFT", "DPlayerFrameFrame", "TOPLEFT", stat_HeaderInsetX, spellYoffset)
	DPFDefenseStatsHeader:ClearAllPoints()
	DPFDefenseStatsHeader:SetPoint("TOPLEFT", "DPlayerFrameFrame", "TOPLEFT", stat_HeaderInsetX, defenseYoffset)
end



local statFrame = CreateFrame("Frame", "statFrame", UIParent, "BackdropTemplate")
	statFrame.width 	= 200
	statFrame.height	= 35
	statFrame:SetFrameStrata("BACKGROUND")
	statFrame:SetClampedToScreen(true)	
	statFrame:ClearAllPoints()
	statFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	statFrame:SetSize(184 , 27)

	--statFrame:SetSize(statFrameTextureXinsets , statFrameTextureYinsets)	
	statFrame:SetBackdrop({
		bgFile 		=  "Interface\\Addons\\DPlayerFrame\\Textures\\White8x8.tga",                   --  "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile	= "Interface\\Addons\\DPlayerFrame\\Textures\\1pixel.tga",
		tile 		= true,
		tileSize 	= 18,
		edgeSize 	= 4,
		insets 		= { left = 1, right = 1, top = 1, bottom = 1 }
	}) 
				  
	statFrame:SetBackdropColor(0, 0, 0, .65)
	statFrame:SetBackdropBorderColor( .25, .25, .25)
	statFrame:EnableMouse(true)
	statFrame:EnableMouseWheel(true)

	
	-- Make movable/resizable	
	statFrame:SetMovable(true)
	statFrame:SetResizable(true)
	--statFrame:SetMinResize(100, 100)
	statFrame:RegisterForDrag("LeftButton")
	statFrame:SetScript("OnDragStart", statFrame.StartMoving)
	statFrame:SetScript("OnDragStop", statFrame.StopMovingOrSizing)
	statFrame:SetScript("OnLoad", function(self) print(self:GetName()) end)
	--tinsert(UISpecialFrames, statFrame)


--------------------
-- Main Header --
--------------------
local logochecked

gdbprivate.gdbdefaults.gdbdefaults.dplayerframeLogoChecked = {
	LogoSetChecked = true,
}

local MainFrameHeader = CreateFrame("Frame", "MainFrameHeader", statFrame)
MainFrameHeader:SetPoint("TOP", 37, 10)
MainFrameHeader:SetSize(90, 55)

local t=MainFrameHeader:CreateTexture(nil,"ARTWORK")
		t:SetAllPoints(MainFrameHeader)
		-- t:SetColorTexture(1, 1, 1, 0)
		t:SetTexture"Interface\\Addons\\DPlayerFrame\\Textures\\SmallLogo.tga"
		t:SetVertexColor(1, 1, 1)

		local function stat_SetLogo()		
			if logochecked then
				MainFrameHeader:Show()
			else
				MainFrameHeader:Hide()
			end
		end


	
	-- Minimize/Maximize Button
	local minimizebutton = CreateFrame("Button", nil, statFrame, "UIPanelButtonTemplate")
	minimizebutton:SetPushedTexture("Interface\\Addons\\DPlayerFrame\\Textures\\MinimizeButtonNormal.tga")
	minimizebutton:SetHighlightTexture("Interface\\Addons\\DPlayerFrame\\Textures\\MinimizeButtonHighlight.tga")
	minimizebutton:SetNormalTexture("Interface\\Addons\\DPlayerFrame\\Textures\\MinimizeButtonNormal.tga")
	minimizebutton:SetScript("OnClick", function(self, button, down)
		if StatScrollFrame:IsVisible() then
			minimizebutton:SetPushedTexture("Interface\\Addons\\DPlayerFrame\\Textures\\MaximizeButtonHighlight.tga")
			minimizebutton:SetHighlightTexture("Interface\\Addons\\DPlayerFrame\\Textures\\MinimizeButtonHighlight.tga")
			minimizebutton:SetNormalTexture("Interface\\Addons\\DPlayerFrame\\Textures\\MaximizeButtonHighlight.tga")
			--closebutton:SetFormattedText("|cff00ff00+|r")
			StatScrollFrame:Hide()
			StatScrollFrameWideBackdrop:Hide()
			StatScrollFrameBackdrop:Hide()
		else
			minimizebutton:SetPushedTexture("Interface\\Addons\\DPlayerFrame\\Textures\\MinimizeButtonNormal.tga")
			minimizebutton:SetHighlightTexture("Interface\\Addons\\DPlayerFrame\\Textures\\MinimizeButtonHighlight.tga")
			minimizebutton:SetNormalTexture("Interface\\Addons\\DPlayerFrame\\Textures\\MinimizeButtonNormal.tga")
			StatScrollFrame:Show()
			StatScrollFrameBackdrop:Show()
		end
	 end)
	 minimizebutton:SetPoint("TOP", -60, -5)
	 minimizebutton:SetHeight(17)
	 minimizebutton:SetWidth(17)
	--closebutton:SetFormattedText("|cff00ff00+|r")


	-- Close Button

	local closebutton = CreateFrame("Button", nil, statFrame, "UIPanelButtonTemplate")
	closebutton:SetPushedTexture("Interface\\Addons\\DPlayerFrame\\Textures\\CloseButton.tga")
	closebutton:SetHighlightTexture("Interface\\Addons\\DPlayerFrame\\Textures\\MinimizeButtonHighlight.tga")
	closebutton:SetNormalTexture("Interface\\Addons\\DPlayerFrame\\Textures\\CloseButton.tga")
	closebutton:SetScript("OnClick", function(self, button, down)
		if StatScrollFrame:IsVisible() then
			closebutton:SetPushedTexture("Interface\\Addons\\DPlayerFrame\\Textures\\CloseButton.tga")
			closebutton:SetHighlightTexture("Interface\\Addons\\DPlayerFrame\\Textures\\MinimizeButtonHighlight.tga")
			closebutton:SetNormalTexture("Interface\\Addons\\DPlayerFrame\\Textures\\CloseButton.tga")
			--closebutton:SetFormattedText("|cff00ff00+|r")
			StatScrollFrame:Hide()
			statFrame:Hide()
			StatScrollFrameBackdrop:Hide()
			StatScrollFrameWideBackdrop:Hide()
		end
	 end)
	closebutton:SetPoint("TOP", -80, -5)
	closebutton:SetHeight(17)
	closebutton:SetWidth(17)

------------------
-- Scroll Frame --
------------------
local scrollbarchecked

gdbprivate.gdbdefaults.gdbdefaults.dplayerframeScrollbarChecked = {
	ScrollbarSetChecked = false,
}

	-- ScrollingFrameFrame
	local statScrollingFrame = CreateFrame("ScrollFrame", "StatScrollFrame", statFrame, "UIPanelScrollFrameTemplate")
	statScrollingFrame:ClearAllPoints()
	statScrollingFrame:SetSize( 178, 200 )
	statScrollingFrame:SetPoint("BOTTOM", "statFrame", "BOTTOM", 0, -200) -- This is (-40, -14) for Classic, different for dry development
	statScrollingFrame:SetFrameStrata("BACKGROUND")
	statScrollingFrame.ScrollBar:Show()
	statScrollingFrame.ScrollBar:ClearAllPoints()
	statScrollingFrame.ScrollBar:SetPoint("TOPLEFT", statScrollingFrame, "TOPRIGHT", 0, -16)
	statScrollingFrame.ScrollBar:SetPoint("BOTTOMLEFT", statScrollingFrame, "BOTTOMRIGHT", 0, 16)

	local t=statScrollingFrame:CreateTexture(nil,"ARTWORK")
	t:SetAllPoints(statScrollingFrame)
	t:SetColorTexture(0, 0, 0, 1)

	local stat_TopTexture=statScrollingFrame:CreateTexture(nil,"ARTWORK")
	local stat_TopRightTexture=statScrollingFrame:CreateTexture(nil,"ARTWORK")
	local stat_LeftTexture=statScrollingFrame:CreateTexture(nil,"ARTWORK")
	local stat_RightTexture=statScrollingFrame:CreateTexture(nil,"ARTWORK")
	local stat_BottomRightTexture=statScrollingFrame:CreateTexture(nil,"ARTWORK")
	local stat_BottomTexture=statScrollingFrame:CreateTexture(nil,"ARTWORK")


	--[[stat_TopTexture:SetPoint("TOPLEFT", statScrollingFrame, "TOPLEFT", -34, 86)
	stat_TopTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
	stat_TopTexture:SetTexCoord(1, 0, 1, 0)
	stat_TopTexture:SetVertexColor(1,1,1)

	stat_TopRightTexture:SetPoint("TOPRIGHT", statScrollingFrame, "TOPRIGHT", scrollFrameTextureXinsets, 86)
	stat_TopRightTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
	-- (ULx,ULy,LLx,LLy,URx,URy,LRx,LRy)
	stat_TopRightTexture:SetTexCoord(0, 1, 1, 0)
	--stat_TopRightTexture:SetTexCoord(0, 0, 0, 0, 0, 0, 0, 0)

	stat_LeftTexture:SetPoint("BOTTOM", statScrollingFrame, "BOTTOM", 0, -86)
	stat_LeftTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
	stat_LeftTexture:SetTexCoord(0, 0, 0, 1)                     ---(0, 0.6, 0.6, 0)

	stat_RightTexture:SetPoint("TOP", statScrollingFrame, "TOP", 0, 86)
	stat_RightTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
	stat_RightTexture:SetTexCoord(0, 0, 1, 0)    

	stat_BottomRightTexture:SetPoint("BOTTOMRIGHT", statScrollingFrame, "BOTTOMRIGHT", scrollFrameTextureXinsets, -86)
	stat_BottomRightTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")

	stat_BottomTexture:SetPoint("BOTTOMLEFT", statScrollingFrame, "BOTTOMLEFT", -34, -86)
	stat_BottomTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
	stat_BottomTexture:SetTexCoord(1, 0, 0, 1)]]--

	local t=statScrollingFrame.ScrollBar:CreateTexture(nil,"ARTWORK")
		t:SetAllPoints(statScrollingFrame.ScrollBar)
		t:SetColorTexture(0, 0, 0, 1)

	statScrollingFrame:HookScript("OnScrollRangeChanged", function(self, xrange, yrange)
		self.ScrollBar:SetShown(floor(yrange) ~= 0)
		-- self.ScrollBar:Hide() -- This is what will hide the ScrollBar
		if scrollbarchecked then
			self.ScrollBar:SetShown(floor(yrange) ~= 0)
			self.ScrollBar:Show()
		else
			self.ScrollBar:Hide()
		end
	end)

local DPlayerFrameFrame = CreateFrame("Frame", "DPlayerFrameFrame", statScrollingFrame)
	DPlayerFrameFrame:RegisterEvent("PLAYER_LOGIN")
	DPlayerFrameFrame:SetFrameStrata("BACKGROUND")

	DPlayerFrameFrame:SetScript("OnEvent", function(self, event, ...)
		DPlayerFrameFrame:SetSize( stat_FrameWidth, 800 )
		DPlayerFrameFrame:ClearAllPoints()
		DPlayerFrameFrame:SetAllPoints(statScrollingFrame, -40, -14) -- This is (-40, -14) for Classic, different for dry development
		-- DPlayerFrameFrame:SetFrameStrata("BACKGROUND")
		DPlayerFrameFrame:Show()

		statScrollingFrame:SetScrollChild(DPlayerFrameFrame)
	end)

	local function stat_SetScrollBackdrop()		
		if scrollbarchecked then
			StatScrollFrameWideBackdrop:Show()
			StatScrollFrameBackdrop:Hide()
			statScrollingFrame.ScrollBar:Show()
		else
			StatScrollFrameWideBackdrop:Hide()
			StatScrollFrameBackdrop:Show()
			statScrollingFrame.ScrollBar:Hide()
		end
		end

---------------------------
-- Scroll Frame Backdrop --
---------------------------

local statScrollingFrameWideBackdrop = CreateFrame("Frame", "StatScrollFrameWideBackdrop", statFrame, "BackdropTemplate")
statScrollingFrameWideBackdrop:SetFrameStrata("BACKGROUND")
statScrollingFrameWideBackdrop:ClearAllPoints()
statScrollingFrameWideBackdrop:SetPoint("BOTTOM", "statFrame", "BOTTOM", 8, -203)
statScrollingFrameWideBackdrop:SetSize(200 , 206)

	--statFrame:SetSize(statFrameTextureXinsets , statFrameTextureYinsets)	
	statScrollingFrameWideBackdrop:SetBackdrop({
		bgFile 		= "Interface\\Addons\\DPlayerFrame\\Textures\\White8x8.tga", --"Interface\\GLUES\\MODELS\\UI_MainMenu_Legion\\7an_rocks_02.blp",
		edgeFile	= "Interface\\Addons\\DPlayerFrame\\Textures\\1pixel.tga",
		tile 		= true,
		tileSize 	= 28,
		edgeSize 	= 4,
		insets 		= { left = 1, right = 1, top = 1, bottom = 1 }
	}) 
				  
	statScrollingFrameWideBackdrop:SetBackdropColor(0, 0, 0, .65)
	statScrollingFrameWideBackdrop:SetBackdropBorderColor( .25, .25, .25)
	statScrollingFrameWideBackdrop:Hide()



local statScrollingFrameBackdrop = CreateFrame("Frame", "StatScrollFrameBackdrop", statFrame, "BackdropTemplate")
	statScrollingFrameBackdrop:SetFrameStrata("BACKGROUND")
    statScrollingFrameBackdrop:ClearAllPoints()
	statScrollingFrameBackdrop:SetPoint("BOTTOM", "statFrame", "BOTTOM", 0, -203)
	statScrollingFrameBackdrop:SetSize(184 , 206)

	--statFrame:SetSize(statFrameTextureXinsets , statFrameTextureYinsets)	
	statScrollingFrameBackdrop:SetBackdrop({
		bgFile 		=  "Interface\\Addons\\DPlayerFrame\\Textures\\White8x8.tga",                   --  "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile	= "Interface\\Addons\\DPlayerFrame\\Textures\\1pixel.tga",
		tile 		= true,
		tileSize 	= 28,
		edgeSize 	= 4,
		insets 		= { left = 1, right = 1, top = 1, bottom = 1 }
	}) 
				  
	statScrollingFrameBackdrop:SetBackdropColor(0, 0, 0, .65)
	statScrollingFrameBackdrop:SetBackdropBorderColor( .25, .25, .25)




------------------
--Text Change
------------------

--[[if statScrollingFrame:IsVisible() then
	closebutton:SetFormattedText("|cffff0000-|r")
else 
	closebutton:SetText("+")
	closebutton:SetVertexColor(0.00, 1.00, 0.60)
end]]--


local framelockchecked

gdbprivate.gdbdefaults.gdbdefaults.dplayerframeFrameLockChecked = {
	FrameLockSetChecked = false,
}


-------------------------
-- Frame lock Function --
-------------------------
local function stat_FrameLock()
	if framelockchecked then
		statFrame:SetMovable(false)
	else
		statFrame:SetMovable(true)
	end
end


-----------------
-- Frame lock --
-----------------


local DPF_FrameLockCheck = CreateFrame("CheckButton", "DPF_FrameLockCheck", DPlayerFramePanel, "InterfaceOptionsCheckButtonTemplate")
	DPF_FrameLockCheck:RegisterEvent("PLAYER_LOGIN")
	DPF_FrameLockCheck:ClearAllPoints()
	DPF_FrameLockCheck:SetPoint("TOPLEFT", "DPFMiscPanelCategoryFS", 7, -155)
	DPF_FrameLockCheck:SetScale(1)
	_G[DPF_FrameLockCheck:GetName() .. "Text"]:SetText(L["Frame Lock"])
	DPF_FrameLockCheck.tooltipText = L["Prevents DP-Frame from being dragged on screen."] --Creates a tooltip on mouseover.

DPF_FrameLockCheck:SetScript("OnEvent", function(self, event)
	framelockchecked = gdbprivate.gdb.gdbdefaults.dplayerframeFrameLockChecked.FrameLockSetChecked
	self:SetChecked(framelockchecked)
	stat_FrameLock()
end)

DPF_FrameLockCheck:SetScript("OnClick", function(self)
	framelockchecked = not framelockchecked
	gdbprivate.gdb.gdbdefaults.dplayerframeFrameLockChecked.FrameLockSetChecked = framelockchecked
	stat_FrameLock()
end)




----------------------
-- Colors and Fonts --
----------------------
local function stat_SetClassColor()
	if classcolorchecked then
		statScrollingFrameWideBackdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		statScrollingFrameBackdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		statFrame:SetBackdropBorderColor(color.r, color.g, color.b)
	else
		statScrollingFrameWideBackdrop:SetBackdropBorderColor( .25, .25, .25)
		statScrollingFrameBackdrop:SetBackdropBorderColor( .25, .25, .25)
		statFrame:SetBackdropBorderColor( .25, .25, .25)
	end
end


	---------------------------------------
-- Class Color all text --
---------------------------------------


local DPF_ClassColorAllCheck = CreateFrame("CheckButton", "DPF_ClassColorAllCheck", DPlayerFramePanel, "InterfaceOptionsCheckButtonTemplate")
	DPF_ClassColorAllCheck:RegisterEvent("PLAYER_LOGIN")
	DPF_ClassColorAllCheck:ClearAllPoints()
	DPF_ClassColorAllCheck:SetPoint("TOPLEFT", "DPFMiscPanelCategoryFS", 7, -55)
	DPF_ClassColorAllCheck:SetScale(1)
	_G[DPF_ClassColorAllCheck:GetName() .. "Text"]:SetText(L["Class Colored Border"])
	DPF_ClassColorAllCheck.tooltipText = L["Displays border color according to player class."] --Creates a tooltip on mouseover.

DPF_ClassColorAllCheck:SetScript("OnEvent", function(self, event)
	classcolorchecked = gdbprivate.gdb.gdbdefaults.dplayerframeClassColorChecked.ClassColorSetChecked
	self:SetChecked(classcolorchecked)
	stat_SetClassColor()	
end)

DPF_ClassColorAllCheck:SetScript("OnClick", function(self)
	classcolorchecked = not classcolorchecked
	gdbprivate.gdb.gdbdefaults.dplayerframeClassColorChecked.ClassColorSetChecked = classcolorchecked
	stat_SetClassColor()
end)

-----------------------
-- Logo Check Button --
-----------------------


local DPF_LogoCheck = CreateFrame("CheckButton", "DPF_LogoCheck", DPlayerFramePanel, "InterfaceOptionsCheckButtonTemplate")
	DPF_LogoCheck:RegisterEvent("PLAYER_LOGIN")
	DPF_LogoCheck:ClearAllPoints()
	--DPF_ScrollbarCheck:SetPoint("LEFT", 30, -225)
	DPF_LogoCheck:SetPoint("TOPLEFT", "DPFMiscPanelCategoryFS", 7, -135)
	DPF_LogoCheck:SetScale(1)
	DPF_LogoCheck.tooltipText = L["Displays the DP-Frame Logo."] --Creates a tooltip on mouseover.
	_G[DPF_LogoCheck:GetName() .. "Text"]:SetText(L["Logo"])
	
	DPF_LogoCheck:SetScript("OnEvent", function(self, event)
		logochecked = gdbprivate.gdb.gdbdefaults.dplayerframeLogoChecked.LogoSetChecked
		self:SetChecked(logochecked)
		stat_SetLogo()	
	end)

	DPF_LogoCheck:SetScript("OnClick", function(self) 
		logochecked = not logochecked
		gdbprivate.gdb.gdbdefaults.dplayerframeLogoChecked.LogoSetChecked = logochecked
		stat_SetLogo()
	end)



----------------------------
-- Scrollbar Check Button --
----------------------------
local HideScrollBar

local DPF_ScrollbarCheck = CreateFrame("CheckButton", "DPF_ScrollbarCheck", DPlayerFramePanel, "InterfaceOptionsCheckButtonTemplate")
	DPF_ScrollbarCheck:RegisterEvent("PLAYER_LOGIN")
	DPF_ScrollbarCheck:ClearAllPoints()
	--DPF_ScrollbarCheck:SetPoint("LEFT", 30, -225)
	DPF_ScrollbarCheck:SetPoint("TOPLEFT", "DPFMiscPanelCategoryFS", 7, -115)
	DPF_ScrollbarCheck:SetScale(1)
	DPF_ScrollbarCheck.tooltipText = L["Displays the DPF scrollbar."] --Creates a tooltip on mouseover.
	_G[DPF_ScrollbarCheck:GetName() .. "Text"]:SetText(L["Scrollbar"])
	
	DPF_ScrollbarCheck:SetScript("OnEvent", function(self, event)
		scrollbarchecked = gdbprivate.gdb.gdbdefaults.dplayerframeScrollbarChecked.ScrollbarSetChecked
		self:SetChecked(scrollbarchecked)
		stat_SetScrollBackdrop()	
	end)

	DPF_ScrollbarCheck:SetScript("OnClick", function(self) 
		scrollbarchecked = not scrollbarchecked
		gdbprivate.gdb.gdbdefaults.dplayerframeScrollbarChecked.ScrollbarSetChecked = scrollbarchecked
		stat_SetScrollBackdrop()
	end)

	------------------
-- Class Colors --
------------------
local className, classFilename, classID = UnitClass("player") --Players Class Color (In case I want to use it)
local rPerc, gPerc, bPerc, argbHex = GetClassColor(classFilename)


local classcolorchecked

gdbprivate.gdbdefaults.gdbdefaults.dplayerframeClassColorChecked = {
	ClassColorSetChecked = true,
}

--------------------
-- Primary Header --
--------------------
local DPFPrimaryStatsHeader = CreateFrame("Frame", "DPFPrimaryStatsHeader", DPlayerFrameFrame)
	DPFPrimaryStatsHeader:SetSize( stat_HeaderWidth, stat_HeaderHeight )
	-- DPFPrimaryStatsHeader:SetPoint("TOPLEFT", "DPlayerFrameFrame", "TOPLEFT", DPF_HeaderInsetX, primaryYoffset)
	-- DPFPrimaryStatsHeader:SetFrameStrata("BACKGROUND")
	-- DPFPrimaryStatsHeader:Hide()

local DPFPrimaryStatsFS = DPFPrimaryStatsHeader:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	DPFPrimaryStatsFS:SetText(L["Primary"])
	DPFPrimaryStatsFS:SetPoint("CENTER", 0, 0)
	DPFPrimaryStatsFS:SetFont("Interface\\Addons\\DPlayerFrame\\Fonts\\DPF.TTF", 12, "THINOUTLINE")
	DPFPrimaryStatsFS:SetJustifyH("CENTER")

local t=DPFPrimaryStatsHeader:CreateTexture(nil,"ARTWORK")
		t:SetAllPoints(DPFPrimaryStatsHeader)
		-- t:SetColorTexture(1, 1, 1, 0)
		t:SetTexture("Interface\\Addons\\DPlayerFrame\\Textures\\Asphyxia.blp")
		t:SetVertexColor(.25, .25, .25)
		--t:SetTexture("Interface\\PaperDollInfoFrame\\PaperDollInfoPart1")
		--t:SetTexCoord(0, 0.193359375, 0.69921875, 0.736328125)


-------------------------------
-- Melee Enhancements Header --
-------------------------------
local DPFMeleeEnhancementsStatsHeader = CreateFrame("Frame", "DPFMeleeEnhancementsStatsHeader", DPlayerFrameFrame)
	DPFMeleeEnhancementsStatsHeader:SetSize( stat_HeaderWidth, stat_HeaderHeight )
	-- DPFMeleeEnhancementsStatsHeader:SetPoint("TOPLEFT", "DPlayerFrameFrame", "TOPLEFT", DPF_HeaderInsetX, meleeYoffset)
	-- DPFMeleeEnhancementsStatsHeader:SetFrameStrata("BACKGROUND")
	-- DPFMeleeEnhancementsStatsHeader:Hide()

local DPFMeleeEnhancementsStatsFS = DPFMeleeEnhancementsStatsHeader:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	DPFMeleeEnhancementsStatsFS:SetText(L["Melee"])
	DPFMeleeEnhancementsStatsFS:SetTextColor(1, 1, 1)
	DPFMeleeEnhancementsStatsFS:SetPoint("CENTER", 0, 0)
	DPFMeleeEnhancementsStatsFS:SetFont("Interface\\Addons\\DPlayerFrame\\Fonts\\DPF.TTF", 12, "THINOUTLINE")
	DPFMeleeEnhancementsStatsFS:SetJustifyH("CENTER")

local t=DPFMeleeEnhancementsStatsHeader:CreateTexture(nil,"ARTWORK")
		t:SetAllPoints(DPFMeleeEnhancementsStatsHeader)
		-- t:SetColorTexture(1, 1, 1, 0)
		t:SetTexture("Interface\\Addons\\DPlayerFrame\\Textures\\Asphyxia.blp")
		t:SetVertexColor(.25, .25, .25)
		--t:SetTexture("Interface\\PaperDollInfoFrame\\PaperDollInfoPart1")
		--t:SetTexCoord(0, 0.193359375, 0.69921875, 0.736328125)


-------------------------------
-- Ranged Header --
-------------------------------
local DPFRangedStatsHeader = CreateFrame("Frame", "DPFRangedStatsHeader", DPlayerFrameFrame)
	DPFRangedStatsHeader:SetSize( stat_HeaderWidth, stat_HeaderHeight )
	-- DPFRangedStatsHeader:SetPoint("TOPLEFT", "DPlayerFrameFrame", "TOPLEFT", DPF_HeaderInsetX, rangedYoffset)
	-- DPFRangedStatsHeader:SetFrameStrata("BACKGROUND")
	-- DPFRangedStatsHeader:Hide()

local DPFRangedStatsFS = DPFRangedStatsHeader:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	DPFRangedStatsFS:SetText(L["Ranged"])
	DPFRangedStatsFS:SetTextColor(1, 1, 1)
	DPFRangedStatsFS:SetPoint("CENTER", 0, 0)
	DPFRangedStatsFS:SetFont("Interface\\Addons\\DPlayerFrame\\Fonts\\DPF.TTF", 12, "THINOUTLINE")
	DPFRangedStatsFS:SetJustifyH("CENTER")

local t=DPFRangedStatsHeader:CreateTexture(nil,"ARTWORK")
		t:SetAllPoints(DPFRangedStatsHeader)
		-- t:SetColorTexture(1, 1, 1, 0)
		t:SetTexture("Interface\\Addons\\DPlayerFrame\\Textures\\Asphyxia.blp")
		t:SetVertexColor(.25, .25, .25)


-------------------------------
-- Spell Enhancements Header --
-------------------------------
local DPFSpellEnhancementsStatsHeader = CreateFrame("Frame", "DPFSpellEnhancementsStatsHeader", DPlayerFrameFrame)
	DPFSpellEnhancementsStatsHeader:SetSize( stat_HeaderWidth, stat_HeaderHeight )
	-- DPFSpellEnhancementsStatsHeader:SetPoint("TOPLEFT", "DPlayerFrameFrame", "TOPLEFT", DPF_HeaderInsetX, spellYoffset)
	-- DPFSpellEnhancementsStatsHeader:SetFrameStrata("BACKGROUND")
	-- DPFSpellEnhancementsStatsHeader:Hide()

local DPFSpellEnhancementsStatsFS = DPFSpellEnhancementsStatsHeader:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	DPFSpellEnhancementsStatsFS:SetText(L["Spell"])
	DPFSpellEnhancementsStatsFS:SetTextColor(1, 1, 1)
	DPFSpellEnhancementsStatsFS:SetPoint("CENTER", 0, 0)
	DPFSpellEnhancementsStatsFS:SetFont("Interface\\Addons\\DPlayerFrame\\Fonts\\DPF.TTF", 12, "THINOUTLINE")
	DPFSpellEnhancementsStatsFS:SetJustifyH("CENTER")

local t=DPFSpellEnhancementsStatsHeader:CreateTexture(nil,"ARTWORK")
		t:SetAllPoints(DPFSpellEnhancementsStatsHeader)
		-- t:SetColorTexture(1, 1, 1, 0)
		t:SetTexture("Interface\\Addons\\DPlayerFrame\\Textures\\Asphyxia.blp")
		t:SetVertexColor(.25, .25, .25)


-----------
--Defense--
-----------
local DPFDefenseStatsHeader = CreateFrame("Frame", "DPFDefenseStatsHeader", DPlayerFrameFrame)
	DPFDefenseStatsHeader:SetSize( stat_HeaderWidth, stat_HeaderHeight )
	--DPFDefenseStatsHeader:SetPoint("TOPLEFT", "DPlayerFrameFrame", 20, 0)
	-- DPFDefenseStatsHeader:SetFrameStrata("BACKGROUND")
	-- DPFDefenseStatsHeader:Hide()

local DPFDefenseStatsFS = DPFDefenseStatsHeader:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	DPFDefenseStatsFS:SetText(L["Defense"])
	DPFDefenseStatsFS:SetTextColor(1, 1, 1) 
	DPFDefenseStatsFS:SetPoint("CENTER", 0, 0) --This is -2 to center the header "Offense" better.
	DPFDefenseStatsFS:SetFont("Interface\\Addons\\DPlayerFrame\\Fonts\\DPF.TTF", 12, "THINOUTLINE")
	DPFDefenseStatsFS:SetJustifyH("CENTER")

local t=DPFDefenseStatsHeader:CreateTexture(nil,"ARTWORK")
	t:SetAllPoints(DPFDefenseStatsHeader)
	--t:SetColorTexture(1, 1, 1, 0)
	t:SetTexture("Interface\\Addons\\DPlayerFrame\\Textures\\Asphyxia.blp")
	t:SetVertexColor(.25, .25, .25)





---------------------
-- Primary/General --
---------------------
local function DPF_SetBlizzPrimaryStats(statindex)
	local DPFstatindex = statindex
	local DPFstatFrame = _G["PlayerStatFrameLeft"..DPFstatindex];
	local DPFstat;
	local DPFeffectiveStat;
	local DPFposBuff;
	local DPFnegBuff;
	local DPFstatName = getglobal("SPELL_STAT"..DPFstatindex.."_NAME");
	local DPFstat, DPFeffectiveStat, DPFposBuff, DPFnegBuff = UnitStat("player", DPFstatindex);
	local t = DPFstatFrame:CreateFontString(DPFstatFrame:GetName(), "OVERLAY", "GameTooltipText")
	-- Set the tooltip text
	local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..DPFstatName.." ";

	if ( ( DPFposBuff == 0 ) and ( DPFnegBuff == 0 ) ) then
		t:SetText(DPFeffectiveStat);
		DPFstatFrame.tooltip = tooltipText..DPFeffectiveStat..FONT_COLOR_CODE_CLOSE;
	else 
		tooltipText = tooltipText..DPFeffectiveStat;
		if ( DPFposBuff > 0 or DPFnegBuff < 0 ) then
			tooltipText = tooltipText.." ("..(DPFstat - DPFposBuff - DPFnegBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( DPFposBuff > 0 ) then
			tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..DPFposBuff..FONT_COLOR_CODE_CLOSE;
		end
		if ( DPFnegBuff < 0 ) then
			tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..DPFnegBuff..FONT_COLOR_CODE_CLOSE;
		end
		if ( DPFposBuff > 0 or DPFnegBuff < 0 ) then
			tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
		end
		DPFstatFrame.tooltip = tooltipText;

		--If there are any negative buffs then show the main number in red even if there are
		--positive buffs. Otherwise show in green.
		if ( DPFnegBuff < 0 ) then
			t:SetText(RED_FONT_COLOR_CODE..DPFeffectiveStat..FONT_COLOR_CODE_CLOSE);
		else
			t:SetText(GREEN_FONT_COLOR_CODE..DPFeffectiveStat..FONT_COLOR_CODE_CLOSE);
		end
	end
	DPFstatFrame.tooltip2 = getglobal("DEFAULT_STAT"..DPFstatindex.."_TOOLTIP");
	local _, unitClass = UnitClass("player");
	unitClass = strupper(unitClass);
	
	if ( DPFstatindex == 1 ) then
		local attackPower = GetAttackPowerForStat(DPFstatindex,DPFeffectiveStat);
		DPFstatFrame.tooltip2 = format(DPFstatFrame.tooltip2, attackPower);
		if ( unitClass == "WARRIOR" or unitClass == "SHAMAN" or unitClass == "PALADIN" ) then
			DPFstatFrame.tooltip2 = DPFstatFrame.tooltip2 .. "\n" .. format( STAT_BLOCK_TOOLTIP, DPFeffectiveStat*BLOCK_PER_STRENGTH );
		end
	elseif ( DPFstatindex == 3 ) then
		local baseStam = min(20, DPFeffectiveStat);
		local moreStam = DPFeffectiveStat - baseStam;
		DPFstatFrame.tooltip2 = format(DPFstatFrame.tooltip2, (baseStam + (moreStam*HEALTH_PER_STAMINA))*GetUnitMaxHealthModifier("player"));
		local petStam = ComputePetBonus("PET_BONUS_STAM", DPFeffectiveStat );
		if( petStam > 0 ) then
			DPFstatFrame.tooltip2 = DPFstatFrame.tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_STAMINA,petStam);
		end
	elseif ( DPFstatindex == 2 ) then
		local attackPower = GetAttackPowerForStat(DPFstatindex,DPFeffectiveStat);
		if ( attackPower > 0 ) then
			DPFstatFrame.tooltip2 = format(STAT_ATTACK_POWER, attackPower) .. format(DPFstatFrame.tooltip2, GetCritChanceFromAgility("player"), DPFeffectiveStat*ARMOR_PER_AGILITY);
		else
			DPFstatFrame.tooltip2 = format(DPFstatFrame.tooltip2, GetCritChanceFromAgility("player"), DPFeffectiveStat*ARMOR_PER_AGILITY);
		end
	elseif ( DPFstatindex == 4 ) then
		local baseInt = min(20, DPFeffectiveStat);
		local moreInt = DPFeffectiveStat - baseInt
		if ( UnitHasMana("player") ) then
			DPFstatFrame.tooltip2 = format(DPFstatFrame.tooltip2, baseInt + moreInt*MANA_PER_INTELLECT, GetSpellCritChanceFromIntellect("player"));
		else
			DPFstatFrame.tooltip2 = nil;
		end
		local petInt = ComputePetBonus("PET_BONUS_INT", DPFeffectiveStat );
		if( petInt > 0 ) then
			if ( not DPFstatFrame.tooltip2 ) then
				DPFstatFrame.tooltip2 = "";
			end
			DPFstatFrame.tooltip2 = DPFstatFrame.tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_INTELLECT,petInt);
		end
	elseif ( DPFstatindex == 5 ) then
		-- All mana regen stats are displayed as mana/5 sec.
		DPFstatFrame.tooltip2 = format(DPFstatFrame.tooltip2, GetUnitHealthRegenRateFromSpirit("player"));
		if ( UnitHasMana("player") ) then
			local regen = GetUnitManaRegenRateFromSpirit("player");
			regen = floor( regen * 5.0 );
			DPFstatFrame.tooltip2 = DPFstatFrame.tooltip2.."\n"..format(MANA_REGEN_FROM_SPIRIT, regen);
		end
	end
	return "", DPFeffectiveStat, DPFstatFrame.tooltip, DPFstatFrame.tooltip2, "", ""
end
-- Strength
local function DPF_Strength()
	local statindex = 1
	return DPF_SetBlizzPrimaryStats(statindex)
end
-- Agility
local function DPF_Agility()
	local statindex = 2
	return DPF_SetBlizzPrimaryStats(statindex)
end
-- Stamina
local function DPF_Stamina()
	local statindex = 3
	return DPF_SetBlizzPrimaryStats(statindex)
end
-- Intellect
local function DPF_Intellect()
	local statindex = 4
	return DPF_SetBlizzPrimaryStats(statindex)
end
-- Spirit
local function DPF_Spirit()
	local statindex = 5
	return DPF_SetBlizzPrimaryStats(statindex)
end
-- Armor
local function DPF_Armor()
	if ( not unit ) then
		unit = "player";
	end
	local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");
	local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitLevel("player"));
	local tooltip2 = format(DEFAULT_STATARMOR_TOOLTIP, armorReduction);
	
	if ( unit == "player" ) then
		local petBonus = ComputePetBonus("PET_BONUS_ARMOR", effectiveArmor );
		if( petBonus > 0 ) then
			tooltip2 = tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_ARMOR, petBonus);
		end
	end
return "", format(" %.0f", effectiveArmor), tooltip2, "", "", ""
end
-- Player Movement Speed
local function MovementSpeed()
	local currentSpeed, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
	-- print(currentSpeed, runSpeed, flightSpeed, swimSpeed)
	local playerSpeed
	if IsSwimming() then
		playerSpeed = (swimSpeed)
	elseif IsFlying() then
		playerSpeed = flightSpeed
	elseif UnitOnTaxi("player") then
		playerSpeed = currentSpeed
	else
		playerSpeed = runSpeed
	end
	local TooltipLine1 = L["Your current movement speed including items, buffs, enchants, forms, and mounts."]
    return "", format("%.0f%%", ((playerSpeed/7)*100)), TooltipLine1, "", "", ""
end
local function DPF_Durability()
	DURABILITY_SLOT_NAME = {
		[1] = { slot = "HeadSlot"},
		[2] = { slot = "ShoulderSlot"},
		[3] = { slot = "ChestSlot"},
		[4] = { slot = "WaistSlot"},
		[5] = { slot = "WristSlot"},
		[6] = { slot = "HandsSlot"},
		[7] = { slot = "LegsSlot"},
		[8] = { slot = "FeetSlot"},
		[9] = { slot = "MainHandSlot"},
		[10] = { slot = "SecondaryHandSlot"},
		[11] = { slot = "RangedSlot"},
	}
	local slotInfo = { }
	local minVal = 100
for i = 1, 11 do
	if ( not slotInfo[i] ) then 
		tinsert(slotInfo, i, { equip, value, max, perc }) 
	end
	local slotID = GetInventorySlotInfo(DURABILITY_SLOT_NAME[i].slot)
	local itemLink = GetInventoryItemLink("player", slotID)
	local value, maximum = 0, 0
	if ( itemLink ~= nil ) then
		slotInfo[i].equip = true
        value, maximum = GetInventoryItemDurability(slotID)
    else
        slotInfo[i].equip = false
    end
	if ( slotInfo[i].equip and maximum ~= nil ) then
		slotInfo[i].value = value
        slotInfo[i].max = maximum
        slotInfo[i].perc = floor((slotInfo[i].value/slotInfo[i].max)*100)
    end
end
for i = 1, 11 do
    if ( slotInfo[i].equip and slotInfo[i].max ~= nil ) then
        if ( slotInfo[i].perc < minVal ) then minVal = slotInfo[i].perc 
		end
	end
end
	displayDura = format("%0.1f%%", minVal)
	local TooltipLine1 = L["The average durability of all equipped items."]
	return "", displayDura, TooltipLine1, "", "", ""
end
local function DPF_RepairTotal()
	if (not DPlayerFrameFrame.scanTooltip) then
		DPlayerFrameFrame.scanTooltip = CreateFrame("GameTooltip", "StatRepairCostTooltip", DPlayerFrameFrame, "GameTooltipTemplate")
		DPlayerFrameFrame.scanTooltip:SetOwner(DPlayerFrameFrame, "ANCHOR_NONE")
	end
	local totalCost = 0
	local _, repairCost
	for _, index in ipairs({1,3,5,6,7,8,9,10,16,17}) do
		_, _, repairCost = DPlayerFrameFrame.scanTooltip:SetInventoryItem("player", index)
		if (repairCost and repairCost > 0) then
			totalCost = totalCost + repairCost
		end
	end
	-- totalCost = 7890 -- Debugging
	local totalRepairCost = GetCoinTextureString(totalCost)
	local TooltipLine1 = L["The total repair cost of all equipped items."]
	return "", totalRepairCost, TooltipLine1, "", "", ""
end
---------------------------
-- Melee/Ranged/Physical --
---------------------------
-- Main Hand Attack(Weapon Skill)
local function MHWeaponSkill()
	local mainBase, mainMod, offBase, offMod = UnitAttackBothHands("player");
	local effective = mainBase + mainMod;
	-- local TooltipLine1 = L["Your attack rating affects your chance to hit a target, and is based on the weapon skill of the weapon you are currently wielding in your main hand. (Weapon Skill)"]
	return "", format("%.0f/", effective)..(UnitLevel("player")*5), "(Weapon Skill): "..ATTACK_TOOLTIP_SUBTEXT, "", "", ""
end
-- Main Hand Attack Power
local function MeleeAP()
	local base, posBuff, negBuff = UnitAttackPower("player");
	local effective = base + posBuff + negBuff;
	return L["Power: "]..format("%.0f", effective).." ("..base.." |cff00ff00+ "..(posBuff + negBuff).."|r)", format("%.0f", effective), format(MELEE_ATTACK_POWER_TOOLTIP, max((base+posBuff+negBuff), 0)/ATTACK_POWER_MAGIC_NUMBER), "", "", ""
end
-- Main Hand Damage
local function MHDamage()
	local speed = UnitAttackSpeed("player");
	local minDamage, maxDamage, _, _, physicalBonusPos, physicalBonusNeg, percent = UnitDamage("player");
	local damageSpread = format("%.0f", minDamage).." - "..format("%.0f", maxDamage);
	local damageSpread2f = format("%.2f", minDamage).." - "..format("%.2f", maxDamage)
	
	local baseDamage = (minDamage + maxDamage) * 0.5;
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
	local damagePerSecond = (max(fullDamage,1) / speed);
	local avgdamage = format("%.2f", damagePerSecond*speed)

	local TooltipLine1 = L["Attack Speed (seconds): "]..format("%.2f", speed)
	local TooltipLine2 = L["Average Damage: "]..avgdamage
	local TooltipLine3 = L["Damage per Second: "]..format("%.2f", damagePerSecond)

	return L["MH Damage: "]..damageSpread2f, damageSpread, TooltipLine1, TooltipLine2, TooltipLine3, ""
end
-- Main Hand Speed
local function MHSpeed()
	local speed, offhandSpeed = UnitAttackSpeed("player");

	local TooltipLine1 = L["Attack Speed (seconds): "]..format("%.2f", speed)

	return L["Main Hand Attack Speed: "]..format("%.2f", speed), format("%.2f", speed), TooltipLine1, "", "", ""
end
-- Main Hand DPS
local function MHDPS()
	local speed = UnitAttackSpeed("player");
	local minDamage, maxDamage, _, _, physicalBonusPos, physicalBonusNeg, percent = UnitDamage("player");
	local damageSpread = format("%.1f", minDamage).." - "..format("%.1f", maxDamage);
	local damageSpread2f = format("%.2f", minDamage).." - "..format("%.2f", maxDamage)
	
	local baseDamage = (minDamage + maxDamage) * 0.5;
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
	local damagePerSecond = format("%.2f", (max(fullDamage,1) / speed) );
	local avgdamage = format("%.2f", damagePerSecond*speed)

	local TooltipLine1 = L["Attack Speed (seconds): "]..format("%.2f", speed)
	local TooltipLine2 = L["Average Damage: "]..avgdamage
	local TooltipLine3 = L["Damage per Second: "]..format("%.2f", damagePerSecond)

	return L["Main Hand DPS: "]..damagePerSecond, damagePerSecond, TooltipLine1, TooltipLine2, TooltipLine3, ""
end
-- Off Hand Attack(Weapon Skill)
local function OHWeaponSkill()
	local _, offhandSpeed = UnitAttackSpeed("player");
	if ( offhandSpeed) then
		local mainBase, mainMod, offBase, offMod = UnitAttackBothHands("player");
		local effective = offBase + offMod;
		-- local TooltipLine1 = L["Your attack rating affects your chance to hit a target, and is based on the weapon skill of the weapon you are currently wielding in your off hand."]
		return "", format("%.0f/", effective)..(UnitLevel("player")*5), "(Weapon Skill): "..ATTACK_TOOLTIP_SUBTEXT, "", "", ""
	else
		return L["Off Hand: "].."N/A", "N/A", "", "", "", ""
	end
end
-- Off Hand Damage
local function OHDamage()
	local _, offhandSpeed = UnitAttackSpeed("player");
	if ( offhandSpeed) then
		local _, _, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage("player");
		local damageSpread = format("%.0f", minOffHandDamage).." - "..format("%.0f", maxOffHandDamage);
		local damageSpread2f = format("%.2f", minOffHandDamage).." - "..format("%.2f", maxOffHandDamage)
		
		local baseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5;
		local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		local damagePerSecond = format("%.2f", (max(fullDamage,1) / offhandSpeed) );
		local avgdamage = format("%.2f", damagePerSecond*offhandSpeed)
		local TooltipLine1 = L["Attack Speed (seconds): "]..format("%.2f", offhandSpeed)
		local TooltipLine2 = L["Average Damage: "]..avgdamage
		local TooltipLine3 = L["Damage per Second: "]..format("%.2f", damagePerSecond)
	
		return L["OH Damage: "]..damageSpread2f, damageSpread, TooltipLine1, TooltipLine2, TooltipLine3, ""
	else
		return L["OH Damage: "].."N/A", "N/A", "", "", "", ""
	end
end
-- Off Hand Speed
local function OHSpeed()
	local speed, offhandSpeed = UnitAttackSpeed("player");
	local _, offhandSpeed = UnitAttackSpeed("player");
	if ( offhandSpeed) then
		local TooltipLine1 = L["Attack Speed (seconds): "]..format("%.2f", offhandSpeed)
		return L["Off Hand Attack Speed: "]..format("%.2f", offhandSpeed), format("%.2f", offhandSpeed), TooltipLine1, "", "", ""
	else
		return L["Off Hand Attack Speed: "].."N/A", "N/A", "", "", "", ""
	end
end
-- Off Hand DPS
local function OHDPS()
	local _, offhandSpeed = UnitAttackSpeed("player");
	if ( offhandSpeed) then
		local _, _, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage("player");		
		local baseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5;
		local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		local damagePerSecond = format("%.2f", (max(fullDamage,1) / offhandSpeed) );
		local avgdamage = format("%.2f", damagePerSecond*offhandSpeed)
		local TooltipLine1 = L["Attack Speed (seconds): "]..format("%.2f", offhandSpeed)
		local TooltipLine2 = L["Average Damage: "]..avgdamage
		local TooltipLine3 = L["Damage per Second: "]..format("%.2f", damagePerSecond)	
		return L["Off Hand DPS: "]..damagePerSecond, damagePerSecond, TooltipLine1, TooltipLine2, TooltipLine3, ""
	else
		return L["Off Hand DPS: "].."N/A", "N/A", "", "", "", ""
	end
end
-- Melee Critical Strike Chance
local function MeleeCrit()
	local chance = GetCritChance();
	local critRating = GetCombatRatingBonus(CR_CRIT_MELEE)
	local crit = GetCombatRating(CR_CRIT_MELEE)

	local TooltipLine1 = L["Crit Chance: "]..(format( "%.2f%%", chance)).."\n ("..crit.." Rating adds "..(format( "%.2f%%", critRating) ).." Crit)"
	-- local TooltipLine2 = L["Crit Rating: "]..crit.."\n ("..crit.." Rating adds "..(format( "%.2f", defenseRating) ).." Defense\n   which adds "..defensePercent.."% Crit)"

	-- local TooltipLine3 = L["Total Crit: "]..(format( "%.2f%%", chance) )
	local total = ""

	return "", "("..crit..") "..(format( "%.2f%%", chance) ), TooltipLine1, "", "", total
end
-- Ranged Attack(Weapon Skill)
local function RangedWeaponSkill()
	local rangedAttackBase, rangedAttackMod = UnitRangedAttack("player");
	local effective = rangedAttackBase + rangedAttackMod;
	-- local TooltipLine1 = L["Your attack rating affects your chance to hit a target, and is based on the weapon skill of the weapon you are currently wielding in your main hand."]
	return "", format("%.0f/", effective)..(UnitLevel("player")*5), "(Weapon Skill): "..ATTACK_TOOLTIP_SUBTEXT, "", "", ""
end
-- Ranged Attack Power
local function RangedAP()
	local base, posBuff, negBuff = UnitRangedAttackPower("player");
	local effective = base + posBuff + negBuff;
	local name = UnitName("pet")
	if name then name = name else name = "your pet's"	end
	local totalAP = base+posBuff+negBuff;
	local TooltipLine1 = format(RANGED_ATTACK_POWER_TOOLTIP, max((totalAP), 0)/ATTACK_POWER_MAGIC_NUMBER);
	local petAPBonus = ComputePetBonus( "PET_BONUS_RAP_TO_AP", totalAP );
	if( petAPBonus > 0 ) then
		TooltipLine1 = TooltipLine1 .. "\n\n" .. "Increases "..name.." AP by "..math.floor(petAPBonus)
	end
	
	local petSpellDmgBonus = ComputePetBonus( "PET_BONUS_RAP_TO_SPELLDMG", totalAP );
	if( petSpellDmgBonus > 0 ) then
		TooltipLine1 = TooltipLine1 .. "\n\n" .. "Increases "..name.." Spell Damage by "..math.floor(petSpellDmgBonus);
	end
	-- .." |cff00c0ff+ "..(format( "%.1f", defenseRating) ).."|r)
	return L["Ranged AP: "]..format("%.0f", effective).." ("..base.." |cff00ff00+ "..(posBuff + negBuff).."|r)", format("%.0f", effective), TooltipLine1, "", "", ""
end
-- Ranged Damage
local function RangedDamage()
	local rangedAttackSpeed, minDamage, maxDamage, physicalBonusPos, physicalBonusNeg, percent = UnitRangedDamage("player");
	if rangedAttackSpeed == 0 then
		local damageSpread = "0 - 0";
		local TooltipLine1 = L["Attack Speed (seconds): "].."0"
		local TooltipLine2 = L["Damage per Second: "].."0"
		return L["Ranged Damage: "].."N/A", "N/A", "", "", "", ""
	else
		local damageSpread = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);
		local baseDamage = (minDamage + maxDamage) * 0.5;
		local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		local totalBonus = (fullDamage - baseDamage);
		local damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed);
		local TooltipLine1 = L["Attack Speed (seconds): "]..format("%.2f", rangedAttackSpeed)
		local TooltipLine2 = L["Damage per Second: "]..format("%.2f", damagePerSecond)
		return L["Ranged Damage: "]..damageSpread, damageSpread, TooltipLine1, TooltipLine2, "", ""
	end
end
-- Ranged Speed
local function RangedSpeed()
	local rangedAttackSpeed, minDamage, maxDamage, physicalBonusPos, physicalBonusNeg, percent = UnitRangedDamage("player");
	if rangedAttackSpeed == 0 then
		local damageSpread = "0 - 0";
		local TooltipLine1 = L["Attack Speed (seconds): "].."0"
		local TooltipLine2 = L["Damage per Second: "].."0"
		return L["Ranged Attack Speed: "].."N/A", "N/A", "", "", "", ""
	else
		local damageSpread = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);
		local baseDamage = (minDamage + maxDamage) * 0.5;
		local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		local totalBonus = (fullDamage - baseDamage);
		local damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed);
		local TooltipLine1 = L["Attack Speed (seconds): "]..format("%.2f", rangedAttackSpeed)
		local TooltipLine2 = L["Damage per Second: "]..format("%.2f", damagePerSecond)
		return L["Ranged Attack Speed: "]..format("%.2f", rangedAttackSpeed), format("%.2f", rangedAttackSpeed), TooltipLine1, "", "", ""
	end
end
-- Ranged DPS
local function RangedDPS()
	local rangedAttackSpeed = UnitRangedDamage("player");
	if rangedAttackSpeed == 0 then
		local damageSpread = "0 - 0";
		local TooltipLine1 = L["Attack Speed (seconds): "].."0"
		local TooltipLine2 = L["Damage per Second: "].."0"
		return L["Ranged DPS: "].."N/A", "N/A", "", "", "", ""
	else
		local _, minDamage, maxDamage, physicalBonusPos, physicalBonusNeg, percent = UnitRangedDamage("player");
		local damageSpread = format("%.1f", minDamage).." - "..format("%.1f", maxDamage);
		local damageSpread2f = format("%.2f", minDamage).." - "..format("%.2f", maxDamage)
		
		local baseDamage = (minDamage + maxDamage) * 0.5;
		local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		local damagePerSecond = format("%.2f", (max(fullDamage,1) / rangedAttackSpeed) );
		local avgdamage = format("%.2f", damagePerSecond*rangedAttackSpeed)

		local TooltipLine1 = L["Attack Speed (seconds): "]..format("%.2f", rangedAttackSpeed)
		local TooltipLine2 = L["Average Damage: "]..avgdamage
		local TooltipLine3 = L["Damage per Second: "]..format("%.2f", damagePerSecond)

		return L["Ranged DPS: "]..damagePerSecond, damagePerSecond, TooltipLine1, TooltipLine2, TooltipLine3, ""
	end
end
-- Ranged Critical Strike Chance
local function RangedCrit()
	local chance = GetRangedCritChance();
	local critRating = GetCombatRatingBonus(CR_CRIT_RANGED)
	local crit = GetCombatRating(CR_CRIT_RANGED)

	local TooltipLine1 = L["Crit Chance: "]..(format( "%.2f%%", chance)).."\n ("..crit.." Rating adds "..(format( "%.2f%%", critRating) ).." Crit)"
	-- local TooltipLine2 = L["Crit Rating: "]..crit.."\n ("..crit.." Rating adds "..(format( "%.2f", defenseRating) ).." Defense\n   which adds "..defensePercent.."% Crit)"

	-- local TooltipLine3 = L["Total Crit: "]..(format( "%.2f%%", chance) )
	local total = ""

	return "", "("..crit..") "..(format( "%.2f%%", chance) ), TooltipLine1, TooltipLine2, TooltipLine3, total
end
-- Bonus Melee Hit Chance Modifier
local function HitModifier()
	local hitRating = GetCombatRatingBonus(CR_HIT_MELEE)
	local hit = GetCombatRating(CR_HIT_MELEE)

	local TooltipLine1 = L["Hit Chance: "]..(format( "%.2f%%", hitRating)).."\n ("..hit.." Rating adds "..(format( "%.2f%%", hitRating) ).." Hit)"
	local TooltipLine2 = "\n"..( format(CR_HIT_MELEE_TOOLTIP, UnitLevel("player"), hitRating, hit, GetArmorPenetration()) );
	-- local TooltipLine3 = L["Total Hit: "]..(format( "%.2f%%", hitRating) )
	local total = ""

	return "", "("..hit..") "..(format( "%.2f%%", hitRating) ), TooltipLine1, TooltipLine2, TooltipLine3, total
end
local function MeleeHaste()
	local hasteRating = GetCombatRatingBonus(CR_HASTE_MELEE)
	local haste = GetCombatRating(CR_HASTE_MELEE)

	local TooltipLine1 = L["Melee Haste: "]..(format( "%.2f%%", hasteRating)).."\n ("..haste.." Rating adds "..(format( "%.2f%%", hasteRating) ).." Haste)\n\n"
	-- local TooltipLine2 = "\n"..( format(CR_HASTE_RATING_TOOLTIP, haste, hasteRating) );
	local TooltipLine2 = "Increases your melee attack speed by "..format( "%.2f%%", hasteRating);

	-- local TooltipLine3 = L["Total Hit: "]..(format( "%.2f%%", hasteRating) )
	local total = ""

	return "", "("..haste..") "..(format( "%.2f%%", hasteRating) ), TooltipLine1, TooltipLine2, TooltipLine3, total
end
-- Bonus Ranged Hit Chance Modifier
local function RangedHitModifier()
	hasBiznicks = addon.hasBiznicks
	local hitRating = GetCombatRatingBonus(CR_HIT_RANGED)
	local hit = GetCombatRating(CR_HIT_RANGED)
	if hit == nil then hit = 0 end
	if hasBiznicks then 
		hit = hit + 3
	end

	local TooltipLine1 = L["Hit Chance: "]..(format( "%.2f%%", hitRating)).."\n ("..hit.." Rating adds "..(format( "%.2f%%", hitRating) ).." Hit)"
	local TooltipLine2 = "\n"..( format(CR_HIT_RANGED_TOOLTIP, UnitLevel("player"), hitRating, hit, GetArmorPenetration()) );
	-- local TooltipLine3 = L["Total Hit: "]..(format( "%.2f%%", hitRating) )
	local total = ""

	return "", "("..hit..") "..(format( "%.2f%%", hitRating) ), TooltipLine1, TooltipLine2, TooltipLine3, total
end
local function RangedHaste()
	local hasteRating = GetCombatRatingBonus(CR_HASTE_RANGED)
	local haste = GetCombatRating(CR_HASTE_RANGED)

	local TooltipLine1 = L["Ranged Haste: "]..(format( "%.2f%%", hasteRating)).."\n ("..haste.." Rating adds "..(format( "%.2f%%", hasteRating) ).." Haste)\n\n"
	-- local TooltipLine2 = "\n"..( format(CR_HASTE_RATING_TOOLTIP, haste, hasteRating) );
	local TooltipLine2 = "Increases your ranged attack speed by "..format( "%.2f%%", hasteRating)

	-- local TooltipLine3 = L["Total Hit: "]..(format( "%.2f%%", hasteRating) )
	local total = ""

	return "", "("..haste..") "..(format( "%.2f%%", hasteRating) ), TooltipLine1, TooltipLine2, TooltipLine3, total
end
local function Expertise()
	if ( not unit ) then
		unit = "player";
	end
	local expertiseRatingBonus = GetCombatRatingBonus(CR_EXPERTISE)
	local expertiseRating = GetCombatRating(CR_EXPERTISE)
	local expertise, offhandExpertise = GetExpertise();

	-- Is each weapon independent?
	-- local speed, offhandSpeed = UnitAttackSpeed(unit);
	-- local text;
	-- if( offhandSpeed ) then
	-- 	text = expertise.." / "..offhandExpertise;
	-- else
	-- 	text = expertise;
	-- end
	
	local expertisePercent, offhandExpertisePercent = GetExpertisePercent();
	expertisePercent = format("%.2f%%", expertisePercent);
	-- if( offhandSpeed ) then
	-- 	offhandExpertisePercent = format("%.2f", offhandExpertisePercent);
	-- 	text = expertisePercent.."% / "..offhandExpertisePercent.."%";
	-- else
	-- 	text = expertisePercent.."%";
	-- end
	local TooltipLine1 = HIGHLIGHT_FONT_COLOR_CODE..getglobal("COMBAT_RATING_NAME"..CR_EXPERTISE).." ("..expertise..") "..expertisePercent..FONT_COLOR_CODE_CLOSE;
	local TooltipLine2 = L["Expertise: "]..(format( "%.2f%%", expertiseRatingBonus)).."\n ("..expertiseRating.." Rating adds "..(format( "%.2f%%", expertiseRatingBonus) ).." Expertise)"
	local TooltipLine3 = "\n"..( format(CR_EXPERTISE_TOOLTIP, expertisePercent.."\n", expertiseRating, expertiseRatingBonus) );

	return "", "("..expertise..") "..expertisePercent, TooltipLine1, TooltipLine2, TooltipLine3, ""
end
-------------
-- Defense --
-------------
local baseDefense
local bonusDefense
local defensePercent
local defenseRating
local defense
local function getDefenseStats()
	if ( not unit ) then
		unit = "player";
	end
	baseDefense, bonusDefense = UnitDefense(unit);
	defensePercent = GetDodgeBlockParryChanceFromDefense() -- Blizzard function
	defenseRating = GetCombatRatingBonus(CR_DEFENSE_SKILL) -- Defense Rating converted to Defense Stat
	defense = GetCombatRating(CR_DEFENSE_SKILL) -- Actual Defense Rating
end
-- Dodge Chance
local function Dodge()
	getDefenseStats()
	local chance = GetDodgeChance();
	local dodgeRating = GetCombatRatingBonus(CR_DODGE)
	local dodge = GetCombatRating(CR_DODGE)

	local TooltipLine1 = L["Dodge Rating: "]..dodge.."\n ("..dodge.." Rating adds "..(format( "%.2f%%", dodgeRating) ).." Dodge)\n\n"
	local TooltipLine2 = L["Defense Rating: "]..defense.."\n ("..defense.." Rating adds "..(format( "%.2f", defenseRating) ).." Defense\n   which adds "..defensePercent.."% Dodge)\n\n"

	local TooltipLine3 = L["Total Dodge: "]..(format( "%.2f%%", chance) )
	local total = ""

	return "", "("..dodge..") "..(format( "%.2f%%", chance) ), TooltipLine1, TooltipLine2, TooltipLine3, total
end
-- Parry Chance
local function Parry()
	getDefenseStats()
	local chance = GetParryChance();
	local parryRating = GetCombatRatingBonus(CR_PARRY)
	local parry = GetCombatRating(CR_PARRY)

	local TooltipLine1 = L["Parry Rating: "]..parry.."\n ("..parry.." Rating adds "..(format( "%.2f%%", parryRating) ).." Parry)\n\n"
	local TooltipLine2 = L["Defense Rating: "]..defense.."\n ("..defense.." Rating adds "..(format( "%.2f", defenseRating) ).." Defense\n   which adds "..defensePercent.."% Parry)\n\n"

	local TooltipLine3 = L["Total Parry: "]..(format( "%.2f%%", chance) )
	local total = ""

	return "", "("..parry..") "..(format( "%.2f%%", chance) ), TooltipLine1, TooltipLine2, TooltipLine3, total
end
-- Block Chance
local function BlockChance()
	getDefenseStats()
	local chance = GetBlockChance();
	local blockRating = GetCombatRatingBonus(CR_BLOCK)
	local block = GetCombatRating(CR_BLOCK)

	local TooltipLine1 = L["Block Rating: "]..block.."\n ("..block.." Rating adds "..(format( "%.2f%%", blockRating) ).." Block)\n\n"
	local TooltipLine2 = L["Defense Rating: "]..defense.."\n ("..defense.." Rating adds "..(format( "%.2f", defenseRating) ).." Defense\n   which adds "..defensePercent.."% Block)\n\n"

	local TooltipLine3 = L["Total Block: "]..(format( "%.2f%%", chance) )
	local total = ""

	return "", "("..block..") "..(format( "%.2f%%", chance) ), TooltipLine1, TooltipLine2, TooltipLine3, total
end
-- Block Value
local function BlockValue()
	local BlockValue = GetShieldBlock()
	local TooltipLine1 = L["Your blocks mitigate "]..BlockValue..L[" melee and ranged damage."]
	return "", format("%.0f", BlockValue), TooltipLine1, "", "", ""
end
-- Defense
local function Defense()
	getDefenseStats()
	local TooltipLine1 = L["Base Defense: "]..baseDefense.."\n\n"
	local TooltipLine2 = L["Defense Rating: "]..defense.." ("..defense.." Rating adds "..(format( "%.2f", defenseRating) ).." Defense)\n\n"
	local TooltipLine3 = L["Total Defense: "]..(format( "%.2f", baseDefense + defenseRating) ).."\n\nIncreases your chance to Dodge, Parry, and Block & Decreases your chance to be Hit or Crit by "..(format( "%.2f%%", defensePercent) )
	-- local total = "("..baseDefense.." |cff00c0ff+ "..(format( "%.1f", defenseRating) ).."|r)"
	local total = ""

	return "", format( "%.0f", (baseDefense + defenseRating) ).." ("..defense..") "..(format( "%.2f%%", defensePercent) ), TooltipLine1, TooltipLine2, TooltipLine3, total
end
-- Resilience
local function Resilience()
	local resilience = GetCombatRating(CR_RESILIENCE_CRIT_TAKEN);
	local bonus = GetCombatRatingBonus(CR_RESILIENCE_CRIT_TAKEN);

	local DPFstatFrametooltip = HIGHLIGHT_FONT_COLOR_CODE..STAT_RESILIENCE.." "..resilience..FONT_COLOR_CODE_CLOSE;
	local DPFstatFrametooltip2 = format(RESILIENCE_TOOLTIP, bonus, min(bonus * 2, 25.00), bonus);
	return "", resilience, DPFstatFrametooltip, DPFstatFrametooltip2, "", ""
end
-- Avoidance
local function Avoidance()
	getDefenseStats()
	-- print("baseDefense: ", baseDefense)
	-- print("bonusDefense: ", bonusDefense)
	-- print("defensePercent: ", defensePercent)
	-- print("defenseRating: ", defenseRating)
	-- print("defense: ", defense)
	local playerLevel = UnitLevel("player")
	local AttackerSkill = ( (playerLevel + 3) * 5 )
	local PDefvsAtkWSkill = ( AttackerSkill - (defenseRating + baseDefense) ) * 0.04
	local MissChance = 5 - PDefvsAtkWSkill
	local DodgeChance = GetDodgeChance()
	local ParryChance = GetParryChance()
	local BlockChance = GetBlockChance()
	local ReslCritChance = GetCombatRatingBonus(CR_RESILIENCE_CRIT_TAKEN)
	local CritChance = 5.6 - (defensePercent + ReslCritChance)

	local Avoidance = (MissChance + DodgeChance + ParryChance + BlockChance)
	local Crushing = 102.4 - Avoidance

	-- print("AttackerSkill: ", AttackerSkill)
	-- print("PDefvsAtkWSkill: ", PDefvsAtkWSkill)
	-- print("MissChance: ", MissChance)
	-- print("DodgeChance: ", DodgeChance)
	-- print("ParryChance: ", ParryChance)
	-- print("BlockChance: ", BlockChance)
	-- print("CritChance: ", CritChance)
	-- print("Avoidance: ", Avoidance)
	-- print("Crushing: ", 102.4 - Avoidance)

local TooltipLine1 = L["Avoidance: "]..format( "%.2f", Avoidance).."\n\n"
local TooltipLine1 = L["Crushing: "]..format( "%.2f", Crushing).."\n\n"

	return "", format( "%.2f", Avoidance), TooltipLine1, TooltipLine2, "", ""
end

-- Set the tooltip text
------------------
-- Spellcasting --
------------------
-- Current Mana Regen
-- local function ManaRegenCurrent() --This appears to be power regen like rage, energy, runes, focus, etc.
-- return "", format("%.0f", GetPowerRegen()), TooltipLine1, "", "", ""
-- end
-- local MP5Modifier = 0 --Only needed if NOT using TBC API
-- MP5
local function MP5()
	-- local mp5 = 0 --Only needed if NOT using TBC API
	-- MP5 from items, doesn't include gems, using API for TBC
	-- for i=1,18 do
	-- 	local itemLink = GetInventoryItemLink("player", i)
	-- 	if itemLink then
	-- 		local stats = GetItemStats(itemLink)
	-- 		if stats then
	-- 			local statMP5 = stats["ITEM_MOD_POWER_REGEN0_SHORT"]
	-- 			if (statMP5) then
	-- 				mp5 = mp5 + statMP5 + 1
	-- 			end
	-- 		end
	-- 	end
	-- end
	local _, casting = GetManaRegen();
	-- All mana regen stats are displayed as mana/5 sec.
	casting = ( casting * 5.0 );
	-- Default Tooltips:
	-- TooltipLine1 = HIGHLIGHT_FONT_COLOR_CODE .. MANA_REGEN .. FONT_COLOR_CODE_CLOSE;
	-- TooltipLine2 = format(MANA_REGEN_TOOLTIP, base, casting);

	-- Ticks are every 2 seconds, or 2/5 (0.4) of MP5 stat per tick.
	local MPT = (casting * 0.4)
	local TooltipLine1 = format("%.1f", casting).." "..L["Mana points regenerated every five seconds (MP5) while CASTING and inside the five second rule.\n\n"]
	local TooltipLine2 = format("%.1f", (casting * 0.4)).." "..L["Mana points regenerated every TICK (2 sec) while CASTING and inside the five second rule."]
	return "", format("%.1f", casting).."/"..format("%.1f", MPT), TooltipLine1, TooltipLine2, "", ""
end
-- Mana Regen while not casting
gdbprivate.gdbdefaults.gdbdefaults.DPlayerFrameManaRegenNotCasting = {
	DPFnotcasting = 0,
}
local function ManaRegenNotCasting()
	DPFnotcasting = gdbprivate.gdb.gdbdefaults.DPlayerFrameManaRegenNotCasting.DPFnotcasting 
	local base, casting = GetManaRegen();
	if base == casting then
		if DPFnotcasting then
			base = DPFnotcasting
		end
	else
		gdbprivate.gdb.gdbdefaults.DPlayerFrameManaRegenNotCasting.DPFnotcasting = base
	end

	-- All mana regen stats are displayed as mana/5 sec.
	base = format("%.1f", base * 5);
	-- Default Tooltips:
	-- TooltipLine1 = HIGHLIGHT_FONT_COLOR_CODE .. MANA_REGEN .. FONT_COLOR_CODE_CLOSE;
	-- TooltipLine2 = format(MANA_REGEN_TOOLTIP, base, casting);

	-- Ticks are every 2 seconds, or 2/5 (0.4) of MP5 stat per tick.
	local MPT = (base * 0.4)
	local TooltipLine1 = base.." "..L["Mana points regenerated every five seconds (MP5) while NOT casting and outside the five second rule.\n\n"]
	local TooltipLine2 = format("%.1f", MPT).." "..L["Mana points regenerated every TICK (2 sec) while NOT casting and outside the five second rule."]
	return "", format("%.1f", base).."/"..format("%.1f", MPT), TooltipLine1, TooltipLine2, "", ""
end
-- Spell Critical Strike Chance
local function SpellCrit()
	local holySchool = 2;
	local minCrit = GetSpellCritChance(holySchool);
	local spellCritTab = {}

	spellCritTab[holySchool] = minCrit;
	local spellCrit;
	for i=(holySchool+1), MAX_SPELL_SCHOOLS do
		spellCrit = GetSpellCritChance(i);
		minCrit = min(minCrit, spellCrit);
		spellCritTab[i] = spellCrit;
	end
	minCrit = format("%.2f%%", minCrit);
	DPFstatFrameminCrit = minCrit;
	local critRating = GetCombatRatingBonus(CR_CRIT_SPELL)
	local crit = GetCombatRating(CR_CRIT_SPELL)

	local TooltipLine1 = L["Crit Chance: "]..(DPFstatFrameminCrit).."\n ("..crit.." Rating adds "..(format( "%.2f%%", critRating) ).." Crit)"
	-- local TooltipLine2 = L["Crit Rating: "]..crit.."\n ("..crit.." Rating adds "..(format( "%.2f", defenseRating) ).." Defense\n   which adds "..defensePercent.."% Crit)"
	-- local TooltipLine3 = L["Total Crit: "]..(format( "%.2f%%", chance) )
	local total = ""

	return "", "("..crit..") "..(DPFstatFrameminCrit), TooltipLine1, "", "", total
end
-- Bonus Spell Hit Chance Modifier
local function SpellHitModifier()
	local hitRating = GetCombatRatingBonus(CR_HIT_SPELL)
	local hit = GetCombatRating(CR_HIT_SPELL)

	local TooltipLine1 = L["Hit Chance: "]..(format( "%.2f%%", hitRating)).."\n ("..hit.." Rating adds "..(format( "%.2f%%", hitRating) ).." Hit)"
	local TooltipLine2 = "\n"..( format(CR_HIT_SPELL_TOOLTIP, UnitLevel("player"), hitRating, GetArmorPenetration()) );
	-- local TooltipLine3 = L["Total Hit: "]..(format( "%.2f%%", hitRating) )
	local total = ""

	return "", "("..hit..") "..(format( "%.2f%%", hitRating) ), TooltipLine1, TooltipLine2, TooltipLine3, total
end
-- SpellPenetration Modifier
-- local function SpellPenetration()
-- 	local ratingBonus = GetCombatRatingBonus(CR_HIT_SPELL);

-- 	TooltipLine2 = format(CR_HIT_SPELL_TOOLTIP, UnitLevel("player"), ratingBonus, GetSpellPenetration(), GetSpellPenetration());

-- 	return "", format("%.2f%%", GetSpellPenetration()), "", TooltipLine2, "", ""
-- end
local function SpellHaste()
	local hasteRating = GetCombatRatingBonus(CR_HASTE_SPELL)
	local haste = GetCombatRating(CR_HASTE_SPELL)

	local TooltipLine1 = L["Spell Haste: "]..(format( "%.2f%%", hasteRating)).."\n ("..haste.." Rating adds "..(format( "%.2f%%", hasteRating) ).." Haste)\n\n"
	-- local TooltipLine2 = "\n"..( format(CR_HASTE_RATING_TOOLTIP, haste, hasteRating) );
	local TooltipLine2 = "Increases your spellcasting speed by "..format( "%.2f%%", hasteRating)

	-- local TooltipLine3 = L["Total Hit: "]..(format( "%.2f%%", hasteRating) )
	local total = ""

	return "", "("..haste..") "..(format( "%.2f%%", hasteRating) ), TooltipLine1, TooltipLine2, TooltipLine3, total
end
-- Bonus Healing
local function PlusHealing()
	return "", format("%.0f", GetSpellBonusHealing()), "", "", "", ""
end
-- Holy Plus Damage Bonus
local function HolyPlusDamage()
	return "", format("%.0f", GetSpellBonusDamage(2)), "", "", "", ""
end
-- Arcane Plus Damage Bonus
local function ArcanePlusDamage()
	return "", format("%.0f", GetSpellBonusDamage(7)), "", "", "", ""
end
-- Fire Plus Damage Bonus
local function FirePlusDamage()
	return "", format("%.0f", GetSpellBonusDamage(3)), "", "", "", ""
end
-- Nature Plus Damage Bonus
local function NaturePlusDamage()
	return "", format("%.0f", GetSpellBonusDamage(4)), "", "", "", ""
end
-- Frost Plus Damage Bonus
local function FrostPlusDamage()
	return "", format("%.0f", GetSpellBonusDamage(5)), "", "", "", ""
end
-- Shadow Plus Damage Bonus
local function ShadowPlusDamage()
	return "", format("%.0f", GetSpellBonusDamage(6)), "", "", "", ""
end

DPF_STAT_DATA = {
	---------------------
	-- Primary/General --
	---------------------
	DPF_Strength ={
		statName = "DPF_Strength",
		StatValue = 0,
		isShown = true,
		Label = L["Strength: "],
		statFunction = DPF_Strength,
		relativeTo = DPFPrimaryStatsHeader,
	},
	DPF_Agility ={
		statName = "DPF_Agility",
		StatValue = 0,
		isShown = true,
		Label = L["Agility: "],
		statFunction = DPF_Agility,
		relativeTo = DPFPrimaryStatsHeader,
	},
	DPF_Stamina ={
		statName = "DPF_Stamina",
		StatValue = 0,
		isShown = true,
		Label = L["Stamina: "],
		statFunction = DPF_Stamina,
		relativeTo = DPFPrimaryStatsHeader,
	},
	DPF_Intellect ={
		statName = "DPF_Intellect",
		StatValue = 0,
		isShown = true,
		Label = L["Intellect: "],
		statFunction = DPF_Intellect,
		relativeTo = DPFPrimaryStatsHeader,
	},
	DPF_Spirit ={
		statName = "DPF_Spirit",
		StatValue = 0,
		isShown = true,
		Label = L["Spirit: "],
		statFunction = DPF_Spirit,
		relativeTo = DPFPrimaryStatsHeader,
	},
	DPF_Armor ={
		statName = "DPF_Armor",
		StatValue = 0,
		isShown = true,
		Label = L["Armor: "],
		statFunction = DPF_Armor,
		relativeTo = DPFPrimaryStatsHeader,
	},
	MovementSpeed ={
		statName = "MovementSpeed",
		StatValue = 0,
		isShown = true,
		Label = L["Travel Speed: "],
		statFunction = MovementSpeed,
		relativeTo = DPFPrimaryStatsHeader,
	},
	DPF_Durability ={
		statName = "DPF_Durability",
		StatValue = 0,
		isShown = true,
		Label = L["Durability: "],
		statFunction = DPF_Durability,
		relativeTo = DPFPrimaryStatsHeader,
	},
	DPF_RepairTotal ={
		statName = "DPF_RepairTotal",
		StatValue = 0,
		isShown = true,
		Label = L["Repairs: "],
		statFunction = DPF_RepairTotal,
		relativeTo = DPFPrimaryStatsHeader,
	},
	---------------------------
	-- Melee/Ranged/Physical --
	---------------------------
	MHWeaponSkill ={
		statName = "MHWeaponSkill",
		StatValue = 0,
		isShown = true,
		Label = L["Main Hand: "],
		statFunction = MHWeaponSkill,
		relativeTo = DPFMeleeEnhancementsStatsHeader,
	},
	MHDamage ={
		statName = "MHDamage",
		StatValue = 0,
		isShown = true,
		Label = "   "..L["Damage: "], --Indented to show as a sublisting under Main Hand
		statFunction = MHDamage,
		relativeTo = DPFMeleeEnhancementsStatsHeader,
	},
	MHSpeed ={
		statName = "MHSpeed",
		StatValue = 0,
		isShown = true,
		Label = "   "..L["Speed: "], --Indented to show as a sublisting under Main Hand
		statFunction = MHSpeed,
		relativeTo = DPFMeleeEnhancementsStatsHeader,
	},
	MHDPS ={
		statName = "MHDPS",
		StatValue = 0,
		isShown = true,
		Label = "   "..L["DPS: "], --Indented to show as a sublisting under Main Hand
		statFunction = MHDPS,
		relativeTo = DPFMeleeEnhancementsStatsHeader,
	},
	MeleeAP ={
		statName = "MeleeAP",
		StatValue = 0,
		isShown = true,
		Label = L["Power: "], --Indented to show as a sublisting under Main Hand
		statFunction = MeleeAP,
		relativeTo = DPFMeleeEnhancementsStatsHeader,
	},
	OHWeaponSkill ={
		statName = "OHWeaponSkill",
		StatValue = 0,
		isShown = true,
		Label = L["Off Hand: "],
		statFunction = OHWeaponSkill,
		relativeTo = DPFMeleeEnhancementsStatsHeader,
	},
	OHDamage ={
		statName = "OHDamage",
		StatValue = 0,
		isShown = true,
		Label = "   "..L["Damage: "], --Indented to show as a sublisting under Off Hand
		statFunction = OHDamage,
		relativeTo = DPFMeleeEnhancementsStatsHeader,
	},
	OHSpeed ={
		statName = "OHSpeed",
		StatValue = 0,
		isShown = true,
		Label = "   "..L["Speed: "], --Indented to show as a sublisting under Main Hand
		statFunction = OHSpeed,
		relativeTo = DPFMeleeEnhancementsStatsHeader,
	},
	OHDPS ={
		statName = "OHDPS",
		StatValue = 0,
		isShown = true,
		Label = "   "..L["DPS: "], --Indented to show as a sublisting under Main Hand
		statFunction = OHDPS,
		relativeTo = DPFMeleeEnhancementsStatsHeader,
	},
	MeleeCrit ={
		statName = "MeleeCrit",
		StatValue = 0,
		isShown = true,
		Label = L["Crit: "],
		statFunction = MeleeCrit,
		relativeTo = DPFMeleeEnhancementsStatsHeader,
	},
	MeleeHitChance ={
		statName = "MeleeHitChance",
		StatValue = 0,
		isShown = true,
		Label = L["Hit: "],
		statFunction = HitModifier,
		relativeTo = DPFMeleeEnhancementsStatsHeader,
	},
	MeleeHaste ={
		statName = "MeleeHaste",
		StatValue = 0,
		isShown = true,
		Label = L["Haste: "],
		statFunction = MeleeHaste,
		relativeTo = DPFMeleeEnhancementsStatsHeader,
	},
	Expertise ={
		statName = "Expertise",
		StatValue = 0,
		isShown = true,
		Label = L["Expertise: "],
		statFunction = Expertise,
		relativeTo = DPFMeleeEnhancementsStatsHeader,
	},
	RangedWeaponSkill ={
		statName = "RangedWeaponSkill",
		StatValue = 0,
		isShown = true,
		Label = L["Ranged: "],
		statFunction = RangedWeaponSkill,
		relativeTo = DPFRangedStatsHeader,
	},
	RangedAP ={
		statName = "RangedAP",
		StatValue = 0,
		isShown = true,
		Label = L["Power: "], --Indented to show as a sublisting under Ranged
		statFunction = RangedAP,
		relativeTo = DPFRangedStatsHeader,
	},
	RangedDamage ={
		statName = "RangedDamage",
		StatValue = 0,
		isShown = true,
		Label = "   "..L["Damage: "], --Indented to show as a sublisting under Ranged
		statFunction = RangedDamage,
		relativeTo = DPFRangedStatsHeader,
	},
	RangedSpeed ={
		statName = "RangedSpeed",
		StatValue = 0,
		isShown = true,
		Label = "   "..L["Speed: "], --Indented to show as a sublisting under Main Hand
		statFunction = RangedSpeed,
		relativeTo = DPFRangedStatsHeader,
	},
	RangedDPS ={
		statName = "RangedDPS",
		StatValue = 0,
		isShown = true,
		Label = "   "..L["DPS: "], --Indented to show as a sublisting under Main Hand
		statFunction = RangedDPS,
		relativeTo = DPFRangedStatsHeader,
	},
	RangedCrit = {
		statName = "RangedCrit",
		StatValue = 0,
		isShown = true,
		Label = L["Crit: "],	
		statFunction = RangedCrit,
		relativeTo = DPFRangedStatsHeader,
	},
	RangedHitChance ={
		statName = "RangedHitChance",
		StatValue = 0,
		isShown = true,
		Label = L["Hit: "],
		statFunction = RangedHitModifier,
		relativeTo = DPFRangedStatsHeader,
	},
	RangedHaste ={
		statName = "RangedHaste",
		StatValue = 0,
		isShown = true,
		Label = L["Haste: "],
		statFunction = RangedHaste,
		relativeTo = DPFRangedStatsHeader,
	},
	DodgeChance = {
		isShown = true,
		Label = L["Dodge: "],	
		statFunction = Dodge,
		relativeTo = DPFDefenseStatsHeader,
	},
	Defense = {
		isShown = true,
		Label = L["Defense: "],	
		statFunction = Defense,
		relativeTo = DPFDefenseStatsHeader,
		Description = "Defense, baby!",
	},
	ParryChance = {
		isShown = true,
		Label = L["Parry: "],	
		statFunction = Parry,
		relativeTo = DPFDefenseStatsHeader,
	},
	BlockChance = {
		isShown = true,
		Label = L["Block: "],	
		statFunction = BlockChance,
		relativeTo = DPFDefenseStatsHeader,
	},
	BlockValue = {
		isShown = true,
		Label = L["Block Value: "],	
		statFunction = BlockValue,
		relativeTo = DPFDefenseStatsHeader,
	},
	Resilience ={
		statName = "Resilience",
		StatValue = 0,
		isShown = true,
		Label = L["Resilience: "],
		statFunction = Resilience,
		relativeTo = DPFDefenseStatsHeader,
	},
	Avoidance ={
		statName = "Avoidance",
		StatValue = 0,
		isShown = true,
		Label = L["Avoidance: "],
		statFunction = Avoidance,
		relativeTo = DPFDefenseStatsHeader,
	},
	-- ManaRegenCurrent = { --This appears to be power regen like rage, energy, runes, focus, etc.
	-- 	isShown = true,
	-- 	Label = L["Mana Regen Current: "],	
	-- 	statFunction = ManaRegenCurrent,
	-- 	relativeTo = DPFSpellEnhancementsStatsHeader,
	-- },
	ManaRegenNotCasting = {
		isShown = true,
		Label = L["Mana Regen: "],	
		statFunction = ManaRegenNotCasting,
		relativeTo = DPFSpellEnhancementsStatsHeader,
	},
	MP5 = {
		isShown = true,
		Label = L["MP5: "],	
		statFunction = MP5,
		relativeTo = DPFSpellEnhancementsStatsHeader,
	},
	SpellCritChance = {
		isShown = true,
		Label = L["Crit: "],	
		statFunction = SpellCrit,
		relativeTo = DPFSpellEnhancementsStatsHeader,
	},
	SpellHitChance = {
		isShown = true,
		Label = L["Hit: "],	
		statFunction = SpellHitModifier,
		relativeTo = DPFSpellEnhancementsStatsHeader,
	},
	-- SpellPenetration = {
	-- 	isShown = true,
	-- 	Label = L["Spell Pen: "],	
	-- 	statFunction = SpellPenetration,
	-- 	relativeTo = DPFSpellEnhancementsStatsHeader,
	-- },
		SpellHaste = {
		isShown = true,
		Label = L["Haste: "],	
		statFunction = SpellHaste,
		relativeTo = DPFSpellEnhancementsStatsHeader,
	},
	PlusHealing = {
		isShown = true,
		Label = L["+ Healing: "],	
		statFunction = PlusHealing,
		relativeTo = DPFSpellEnhancementsStatsHeader,
	},
	HolyPlusDamage ={
		isShown = true,
		Label = L["+ Holy: "],	
		statFunction = HolyPlusDamage,
		relativeTo = DPFSpellEnhancementsStatsHeader,
	},
	ArcanePlusDamage ={
		isShown = true,
		Label = L["+ Arcane: "],	
		statFunction = ArcanePlusDamage,
		relativeTo = DPFSpellEnhancementsStatsHeader,
	},
	FirePlusDamage ={
		isShown = true,
		Label = L["+ Fire: "],	
		statFunction = FirePlusDamage,
		relativeTo = DPFSpellEnhancementsStatsHeader,
	},
	NaturePlusDamage ={
		isShown = true,
		Label = L["+ Nature: "],	
		statFunction = NaturePlusDamage,
		relativeTo = DPFSpellEnhancementsStatsHeader,
	},
	FrostPlusDamage ={
		isShown = true,
		Label = L["+ Frost: "],	
		statFunction = FrostPlusDamage,
		relativeTo = DPFSpellEnhancementsStatsHeader,
	},
	ShadowPlusDamage ={
		isShown = true,
		Label = L["+ Shadow: "],	
		statFunction = ShadowPlusDamage,
		relativeTo = DPFSpellEnhancementsStatsHeader,
	},
}

gdbprivate.gdbdefaults.gdbdefaults.DPF_MASTER_STAT_LIST = {
	DPF_PRIMARY_STAT_LIST = {
		"DPF_Strength",
		"DPF_Agility",
		"DPF_Stamina",
		"DPF_Intellect",
		"DPF_Spirit",
		"DPF_Armor",
		"MovementSpeed",
		"DPF_Durability",
		"DPF_RepairTotal",
	},	
	DPF_OFFENSE_STAT_LIST = {
	},	
	DPF_MELEE_STAT_LIST = {
		"MHWeaponSkill",
		"MHDamage",
		"MHSpeed",
		"MHDPS",
		"OHWeaponSkill",
		"OHDamage",
		"OHSpeed",
		"OHDPS",
		"MeleeAP",
		"MeleeHitChance",
		"MeleeCrit",
		"MeleeHaste",
		"Expertise",
	},
	DPF_RANGED_STAT_LIST = {
		"RangedWeaponSkill",
		"RangedDamage",
		"RangedSpeed",
		"RangedDPS",
		"RangedAP",
		"RangedHitChance",
		"RangedCrit",
		"RangedHaste",
	},	
	DPF_SPELL_STAT_LIST = {
		-- "ManaRegenCurrent", --This appears to be power regen like rage, energy, runes, focus, etc.
		"ArcanePlusDamage",
		"FirePlusDamage",
		"FrostPlusDamage",
		"PlusHealing",
		"HolyPlusDamage",
		"NaturePlusDamage",
		"ShadowPlusDamage",
		"SpellHitChance",
		"SpellCritChance",
		-- "SpellPenetration",
		"SpellHaste",
		"MP5",
		"ManaRegenNotCasting",
	},	
	DPF_DEFENSE_STAT_LIST = {
		"Defense",
		"DodgeChance",
		"ParryChance",
		"BlockChance",
		"BlockValue",
		"Resilience",
		"Avoidance",
	},
  }

  local function DPF_CreateStatText(StatKey, StatValue, XoffSet, YoffSet, ShowHideStats)
	local isDPFFrameCreated = _G["DPF"..StatKey.."StatFrame"]
	if (isDPFFrameCreated == nil) then
		DPlayerFrameFrame.statFrame = CreateFrame("Frame", "DPF"..StatKey.."StatFrame", DPF_STAT_DATA[StatKey].relativeTo)
		DPlayerFrameFrame.statFrame:SetPoint("TOPLEFT", DPF_STAT_DATA[StatKey].relativeTo, "BOTTOMLEFT", (5 + XoffSet), ( (-14 * (YoffSet - 1)) -2) )
		DPlayerFrameFrame.statFrame:SetSize(160, 16)

		DPlayerFrameFrame.stat = DPlayerFrameFrame.statFrame:CreateFontString(StatKey.."NameFS", "OVERLAY", "GameTooltipText")
		DPlayerFrameFrame.stat:SetPoint("LEFT", DPlayerFrameFrame.statFrame, "LEFT")
		if (namespace.locale == "zhCN") or (namespace.locale == "zhTW") or (namespace.locale == "koKR") then
			DPlayerFrameFrame.stat:SetFontObject("GameTooltipText")
		else
			DPlayerFrameFrame.stat:SetFontObject("GameTooltipText")
		end	
		DPlayerFrameFrame.stat:SetJustifyH("LEFT")
		DPlayerFrameFrame.stat:SetShadowOffset(1, -1) 
		DPlayerFrameFrame.stat:SetShadowColor(0, 0, 0)
		DPlayerFrameFrame.stat:SetTextColor(1, 0.8, 0.1)
		DPlayerFrameFrame.stat:SetFont(gdbprivate.gdb.gdbdefaults.font, 12, gdbprivate.gdb.gdbdefaults.style)
		DPlayerFrameFrame.stat:SetText("")

		DPlayerFrameFrame.value = DPlayerFrameFrame.statFrame:CreateFontString(StatKey.."ValueFS", "OVERLAY", "GameTooltipText")
		DPlayerFrameFrame.value:SetPoint("RIGHT", DPlayerFrameFrame.statFrame, "RIGHT")
		if (namespace.locale == "zhCN") or (namespace.locale == "zhTW") or (namespace.locale == "koKR") then
			DPlayerFrameFrame.value:SetFontObject("GameTooltipText")
		else
			DPlayerFrameFrame.value:SetFontObject("GameTooltipText")
		end
		DPlayerFrameFrame.value:SetJustifyH("RIGHT")
		DPlayerFrameFrame.value:SetShadowOffset(1, -1) 
		DPlayerFrameFrame.value:SetShadowColor(0, 0, 0)
		DPlayerFrameFrame.value:SetTextColor(1,1,1,1)
		DPlayerFrameFrame.value:SetFont(gdbprivate.gdb.gdbdefaults.font, 12, "THINOUTLINE")
		DPlayerFrameFrame.value:SetText("")
	else
		isDPFFrameCreated:ClearAllPoints()
		isDPFFrameCreated:SetPoint("TOPLEFT", DPF_STAT_DATA[StatKey].relativeTo, "BOTTOMLEFT", (5 + XoffSet), ( (-14 * (YoffSet - 1)) -2) )
	end

	if ShowHideStats then
		_G["DPF"..StatKey.."StatFrame"]:Show()
	else
		_G["DPF"..StatKey.."StatFrame"]:Hide()
	end	
end

local function DPF_SetStatText(StatKey, StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5, XoffSet, YoffSet)
	if (StatValue1 == "") then
		_G[StatKey.."NameFS"]:SetText("")
	else

		_G[StatKey.."NameFS"]:SetText(DPF_STAT_DATA[StatKey].Label)
	end
	_G[StatKey.."ValueFS"]:SetText(StatValue1)
	
	local tooltipheader

	if (StatLabel == "") then
		tooltipheader = DPF_STAT_DATA[StatKey].Label..StatValue1
	else
		tooltipheader = StatLabel
	end

	_G["DPF"..StatKey.."StatFrame"]:Show()
	_G["DPF"..StatKey.."StatFrame"]:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(_G["DPF"..StatKey.."StatFrame"], "ANCHOR_RIGHT");
		GameTooltip:SetText(tooltipheader.." "..StatValue5, 1, 1, 1, 1, true)
		GameTooltip:AddLine(StatValue2, 1, 0.8, 0.1, true)
		GameTooltip:AddLine(StatValue3, 1, 0.8, 0.1, true)
		GameTooltip:AddLine(StatValue4, 1, 0.8, 0.1, true)
		GameTooltip:Show()
	end)

	_G["DPF"..StatKey.."StatFrame"]:SetScript("OnLeave", function(self)
		GameTooltip_Hide()
	end)	
end

local function DPF_CREATE_STATS()
	local table = gdbprivate.gdb.gdbdefaults.DPF_MASTER_STAT_LIST
	for k, v in ipairs(table.DPF_PRIMARY_STAT_LIST) do
		local XoffSet = (0) 
		local YoffSet = (0 + k)
		DPF_CreateStatText(v, 0, XoffSet, YoffSet, ShowPrimary)
	end
	for k, v in ipairs(table.DPF_OFFENSE_STAT_LIST) do
		DPF_CreateStatText(v, 0, 0, k, ShowMelee)
	end
	for k, v in ipairs(table.DPF_MELEE_STAT_LIST) do
		DPF_CreateStatText(v, 0, 0, k, ShowMelee)
	end
	for k, v in ipairs(table.DPF_RANGED_STAT_LIST) do
		DPF_CreateStatText(v, 0, 0, k, ShowRanged)
	end
	for k, v in ipairs(table.DPF_SPELL_STAT_LIST) do
		DPF_CreateStatText(v, 0, 0, k, ShowSpell)
	end
	for k, v in ipairs(table.DPF_DEFENSE_STAT_LIST) do
		local YoffSet = (2.2 + k)
		if DefaultResistances then
			YoffSet = k
		end
		DPF_CreateStatText(v, 0, 0, YoffSet, ShowDefense)	
	end
end

local function DPF_SET_STATS_TEXT()
	local table = gdbprivate.gdb.gdbdefaults.DPF_MASTER_STAT_LIST
	for k, v in ipairs(table.DPF_PRIMARY_STAT_LIST) do
		if ShowPrimary then
			local StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5 = DPF_STAT_DATA[v].statFunction()
			if (v=="DPF_Strength") or (v=="DPF_Agility") or (v=="DPF_Stamina") or (v=="DPF_Intellect") or (v=="DPF_Spirit") then 
				DPF_SetStatText(v, StatValue2, StatValue1, StatValue3, StatValue4, StatValue5, "", 0, 0)
			else
				if (v == "DPF_Durability") then
				DPF_SetStatText(v, StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5, 0, 0)
				else
					DPF_SetStatText(v, StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5, 0, 0)
				end
			end
		 else
		 	DPF_SetStatText(v, "", "", "", "", "", "", 0, 0)
		end
	end
	for k, v in ipairs(table.DPF_OFFENSE_STAT_LIST) do
		if ShowMelee then
			local StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5 = DPF_STAT_DATA[v].statFunction()
			if (v=="Expertise") then 
				DPF_SetStatText(v, StatValue2, StatValue1, StatValue3, StatValue4, StatValue5, "", 0, 0)
			else
				DPF_SetStatText(v, StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5, 0, 0)
			end
		-- else
		-- 	DPF_SetStatText(v, "", "", "", "", "", "", 0, 0)
		end
	end
	for k, v in ipairs(table.DPF_MELEE_STAT_LIST) do
		if ShowMelee then
			local StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5 = DPF_STAT_DATA[v].statFunction()
			DPF_SetStatText(v, StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5, 0, 0)
		-- else
		-- 	DPF_SetStatText(v, "", "", "", "", "", "", 0, 0)
		end
	end
	for k, v in ipairs(table.DPF_RANGED_STAT_LIST) do
		if ShowRanged then
			local StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5 = DPF_STAT_DATA[v].statFunction()
			DPF_SetStatText(v, StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5, 0, 0)
		-- else
		-- 	DPF_SetStatText(v, "", "", "", "", "", "", 0, 0)
		end
	end
	for k, v in ipairs(table.DPF_SPELL_STAT_LIST) do
		if ShowSpell then
			local StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5 = DPF_STAT_DATA[v].statFunction()
			DPF_SetStatText(v, StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5, 0, 0)
		-- else
		-- 	DPF_SetStatText(v, "", "", "", "", "", "", 0, 0)
		end
	end
	for k, v in ipairs(table.DPF_DEFENSE_STAT_LIST) do
		if ShowDefense then
			local StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5 = DPF_STAT_DATA[v].statFunction()
			if (v=="Resilience") then 
				DPF_SetStatText(v, StatValue2, StatValue1, StatValue3, StatValue4, StatValue5, "", 0, 0)
			else
				DPF_SetStatText(v, StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5, 0, 0)
			end
		-- else
		-- 	DPF_SetStatText(v, "", "", "", "", "", "", 0, 0)
		end
	end
end

DPF_CLASSIC_SPECS = { -- These are not default UI/API positions organized to attatch specs to appropriate headings (Primary, Offense, Defense)
	DEATHKNIGHT = {
		spec = {
			tree1 = "DeathKnightBlood",
			tree2 = "DeathKnightFrost",
			tree3 = "DeathKnightUnholy",
		},
	},
	DRUID = {
		spec = {
			tree1 = "DruidBalance",
			tree2 = "DruidFeralCombat",
			tree3 = "DruidRestoration",
		},
	},
	HUNTER = {
		spec = {
			tree1 = "HunterBeastMastery",
			tree2 = "HunterMarksmanship",
			tree3 = "HunterSurvival",
		},
	},
	MAGE = {
		spec = {
			tree1 = "MageArcane",
			tree2 = "MageFire",
			tree3 = "MageFrost",
		},
	},
	PALADIN = {
		spec = {
			tree1 = "PaladinHoly",
			tree2 = "PaladinProtection",
			tree3 = "PaladinCombat",
		},
	},
	PRIEST = {
		spec = {
			tree1 = "PriestDiscipline",
			tree2 = "PriestHoly",
			tree3 = "PriestShadow",
		},
	},
	ROGUE = {
		spec = {
			tree1 = "RogueAssassination",
			tree2 = "RogueCombat",
			tree3 = "RogueSubtlety",
		},
	},
	SHAMAN = {
		spec = {
			tree1 = "ShamanElementalCombat",
			tree2 = "ShamanEnhancement",
			tree3 = "ShamanRestoration",
		},
	},
	WARLOCK = {
		spec = {
			tree1 = "WarlockCurses",
			tree2 = "WarlockSummoning",
			tree3 = "WarlockDestruction",
		},
	},
	WARRIOR = {
		spec = {
			tree1 = "WarriorArms",
			tree2 = "WarriorFury",
			tree3 = "WarriorProtection",
		},
	},
}

DPF_CATEGORIES = { --Talent art categories
	"Primary",
	"Offense",
	"Defense",
}


---------------------------------------------------
-- Get Talent Points Spent Set Top Art As Primary--
---------------------------------------------------
local DPF_PrimaryTalentSpec, DPF_OffenseTalentSpec, DPF_DefenseTalentSpec

local function DPF_GetTalents()
	local numTabs = GetNumTalentTabs();
	local tab1, tab2, tab3
	for t=1, numTabs do
		local _, _, pointsSpent = GetTalentTabInfo(t)
		if t==1 then
			tab1 = pointsSpent
		elseif t==2 then
			tab2 = pointsSpent
		elseif t==3 then
			tab3 = pointsSpent
		end
	end
	local tbl = {tab1, tab2, tab3}
	local function indexsort(tbl)
		local idx = {}
		for i = 1, #tbl do idx[i] = i end -- build a table of indexes
		-- sort the indexes, but use the values as the sorting criteria
		table.sort(idx, function(a, b) return tbl[a] > tbl[b] end)
		-- return the sorted indexes
		return (table.unpack or unpack)(idx)
	end
	DPF_PrimaryTalentSpec, DPF_OffenseTalentSpec, DPF_DefenseTalentSpec = indexsort(tbl)
	--   print(DPF_PrimaryTalentSpec, DPF_OffenseTalentSpec, DPF_DefenseTalentSpec)
end


-----------------------
-- Talent Scroll Art --
-----------------------
gdbprivate.gdbdefaults.gdbdefaults.DPlayerFrameShowHideScrollArtBackground = {
	ShowHideScrollArtBackgroundChecked = true,
}

local TalentArtScale = 0.55
local TalentArtoffsetX, TalentArtoffsetY = 25, 20
local ShowHideScrollArt
local DesaturateScrollArtBackground

local function DPF_TalentArtFrames(v, frameTL, frameTR, frameBL, frameBR, drawLayer, DPF_TalentSpec, TLAnchorframePoint, frameTLrelativeTo, relativePoint, xOffset, yOffset)
	ShowHideScrollArt = gdbprivate.gdb.gdbdefaults.DPlayerFrameShowHideScrollArtBackground.ShowHideScrollArtBackgroundChecked
	DesaturateScrollArtBackground = gdbprivate.gdb.gdbdefaults.DPlayerFrameDesaturateScrollArtBackground.DesaturateScrollArtBackgroundChecked
	local frameexists = _G[frameTL.."Frame"]
	if (frameexists) then --Check for first frame, assume others unless errors occur
		if (ShowHideScrollArt == false) then
			_G[frameTL.."Frame"]:Hide()
			_G[frameTR.."Frame"]:Hide()
			_G[frameBL.."Frame"]:Hide()
			_G[frameBR.."Frame"]:Hide()
			_G[frameTL.."Frame"]:SetDesaturated(DesaturateScrollArtBackground);
			_G[frameTR.."Frame"]:SetDesaturated(DesaturateScrollArtBackground);
			_G[frameBL.."Frame"]:SetDesaturated(DesaturateScrollArtBackground);
			_G[frameBR.."Frame"]:SetDesaturated(DesaturateScrollArtBackground);
		end
		if (ShowHideScrollArt == true) then
			_G[frameTL.."Frame"]:Show()
			_G[frameTR.."Frame"]:Show()
			_G[frameBL.."Frame"]:Show()
			_G[frameBR.."Frame"]:Show()
			_G[frameTL.."Frame"]:SetDesaturated(DesaturateScrollArtBackground);
			_G[frameTR.."Frame"]:SetDesaturated(DesaturateScrollArtBackground);
			_G[frameBL.."Frame"]:SetDesaturated(DesaturateScrollArtBackground);
			_G[frameBR.."Frame"]:SetDesaturated(DesaturateScrollArtBackground);
		end
	else 
		local frameTL=DPlayerFrameFrame:CreateTexture(frameTL.."Frame","ARTWORK", nil, drawLayer)
		-- print(v, drawLayer, DPF_TalentSpec)
		frameTL:ClearAllPoints()
		frameTL:SetScale(TalentArtScale)
		frameTL:SetTexture("Interface\\TALENTFRAME\\"..DPF_CLASSIC_SPECS[classFilename].spec["tree"..DPF_TalentSpec].."-TopLeft")
		frameTL:SetDesaturated(DesaturateScrollArtBackground);
		frameTL:SetPoint(TLAnchorframePoint, frameTLrelativeTo, relativePoint, xOffset, yOffset)
		local frameTR=DPlayerFrameFrame:CreateTexture(frameTR.."Frame","ARTWORK", nil, drawLayer)
		frameTR:ClearAllPoints()
		frameTR:SetScale(TalentArtScale)
		frameTR:SetTexture("Interface\\TALENTFRAME\\"..DPF_CLASSIC_SPECS[classFilename].spec["tree"..DPF_TalentSpec].."-TopRight")
		frameTR:SetDesaturated(DesaturateScrollArtBackground);
		frameTR:SetPoint("TOPLEFT", frameTL, "TOPRIGHT")
		local frameBL=DPlayerFrameFrame:CreateTexture(frameBL.."Frame","ARTWORK", nil, drawLayer)
		frameBL:ClearAllPoints()
		frameBL:SetScale(TalentArtScale)
		frameBL:SetTexture("Interface\\TALENTFRAME\\"..DPF_CLASSIC_SPECS[classFilename].spec["tree"..DPF_TalentSpec].."-BottomLeft")
		frameBL:SetDesaturated(DesaturateScrollArtBackground);
		frameBL:SetPoint("TOPLEFT", frameTL, "BOTTOMLEFT")
		local frameBR=DPlayerFrameFrame:CreateTexture(frameBR.."Frame","ARTWORK", nil, drawLayer)
		frameBR:ClearAllPoints()
		frameBR:SetScale(TalentArtScale)
		frameBR:SetTexture("Interface\\TALENTFRAME\\"..DPF_CLASSIC_SPECS[classFilename].spec["tree"..DPF_TalentSpec].."-BottomRight")
		frameBR:SetDesaturated(DesaturateScrollArtBackground);
		frameBR:SetPoint("TOPLEFT", frameTL, "BOTTOMRIGHT")
		if (ShowHideScrollArt == false) then
			frameTL:Hide()
			frameTR:Hide()
			frameBL:Hide()
			frameBR:Hide()
		end
	end
end

local function DPF_SetTalentArtFrames()
	DPF_GetTalents()
	for k, v in pairs(DPF_CATEGORIES) do
		local DPF_TalentSpec
		local frameTLrelativeTo = DPlayerFrameFrame
		local TLAnchorframePoint
		local relativePoint
		local xOffset
		local yOffset
		if (v == "Primary") then
			DPF_TalentSpec = DPF_PrimaryTalentSpec
			TLAnchorframePoint = "TOPLEFT"
			frameTLrelativeTo = DPlayerFrameFrame
			relativePoint = "TOPLEFT"
			xOffset = 25
			yOffset = -35
		elseif (v == "Offense") then
			DPF_TalentSpec = DPF_OffenseTalentSpec
			TLAnchorframePoint = "TOPLEFT"
			frameTLrelativeTo = "PrimaryBottomLeftTalentTextureFrame"
			relativePoint = "BOTTOMLEFT"
			xOffset = 0
			yOffset = 60
		elseif (v == "Defense") then
			DPF_TalentSpec = DPF_DefenseTalentSpec			
			TLAnchorframePoint = "TOPLEFT"
			frameTLrelativeTo = "OffenseBottomLeftTalentTextureFrame"
			relativePoint = "BOTTOMLEFT"
			xOffset = 0
			yOffset = 60
		end
		-- Old relativeto is to attatch to the stat headers.
		-- DPF_TalentArtFrames(v, v.."TopLeftTalentTexture", v.."TopRightTalentTexture", v.."BottomLeftTalentTexture", v.."BottomRightTalentTexture", k, DPF_TalentSpec, "DPF"..v.."StatsHeader", "BOTTOMLEFT")
		--New is to attatch to the scroll pane top, center and bottom.
		DPF_TalentArtFrames(v, v.."TopLeftTalentTexture", v.."TopRightTalentTexture", v.."BottomLeftTalentTexture", v.."BottomRightTalentTexture", k, DPF_TalentSpec, TLAnchorframePoint, frameTLrelativeTo, relativePoint, xOffset, yOffset)
	end
end

	

--------------------------------------
-- Show/Hide Talents Background Art --
--------------------------------------
local DPF_ShowHideScrollArtBackgroundCheckedCheck = CreateFrame("CheckButton", "DPF_ShowHideScrollArtBackgroundCheckedCheck", DPlayerFramePanel, "InterfaceOptionsCheckButtonTemplate")
	DPF_ShowHideScrollArtBackgroundCheckedCheck:RegisterEvent("PLAYER_LOGIN")
	DPF_ShowHideScrollArtBackgroundCheckedCheck:ClearAllPoints()
	--DPF_ShowHideScrollArtBackgroundCheckedCheck:SetPoint("TOPLEFT", 30, -255)
	DPF_ShowHideScrollArtBackgroundCheckedCheck:SetPoint("TOPLEFT", "DPFMiscPanelCategoryFS", 7, -15)
	DPF_ShowHideScrollArtBackgroundCheckedCheck:SetScale(1)
	_G[DPF_ShowHideScrollArtBackgroundCheckedCheck:GetName() .. "Text"]:SetText(L["Background Art"])
	DPF_ShowHideScrollArtBackgroundCheckedCheck.tooltipText = L["Displays the class talents background art."] --Creates a tooltip on mouseover.

DPF_ShowHideScrollArtBackgroundCheckedCheck:SetScript("OnEvent", function(self, event, ...)
	ShowHideScrollArt = gdbprivate.gdb.gdbdefaults.DPlayerFrameShowHideScrollArtBackground.ShowHideScrollArtBackgroundChecked
	self:SetChecked(ShowHideScrollArt)
	DPF_SetTalentArtFrames()
end)

DPF_ShowHideScrollArtBackgroundCheckedCheck:SetScript("OnClick", function(self)
	ShowHideScrollArt = not ShowHideScrollArt
	gdbprivate.gdb.gdbdefaults.DPlayerFrameShowHideScrollArtBackground.ShowHideScrollArtBackgroundChecked = ShowHideScrollArt
	DPF_SetTalentArtFrames()
end)


---------------------------------------
-- Desaturate Talents Background Art --
---------------------------------------
gdbprivate.gdbdefaults.gdbdefaults.DPlayerFrameDesaturateScrollArtBackground = {
	DesaturateScrollArtBackgroundChecked = false,
}
local DesaturateScrollArtBackground --alternate display position of item repair cost, durability, and ilvl

local DPF_DesaturateScrollArtBackgroundCheckedCheck = CreateFrame("CheckButton", "DPF_DesaturateScrollArtBackgroundCheckedCheck", DPlayerFramePanel, "InterfaceOptionsCheckButtonTemplate")
	DPF_DesaturateScrollArtBackgroundCheckedCheck:RegisterEvent("PLAYER_LOGIN")
	DPF_DesaturateScrollArtBackgroundCheckedCheck:ClearAllPoints()
	--DPF_DesaturateScrollArtBackgroundCheckedCheck:SetPoint("TOPLEFT", 30, -255)
	DPF_DesaturateScrollArtBackgroundCheckedCheck:SetPoint("TOPLEFT", "DPFMiscPanelCategoryFS", 7, -35)
	DPF_DesaturateScrollArtBackgroundCheckedCheck:SetScale(1)
	_G[DPF_DesaturateScrollArtBackgroundCheckedCheck:GetName() .. "Text"]:SetText(L["Monochrome Background Art"])
	DPF_DesaturateScrollArtBackgroundCheckedCheck.tooltipText = L["Displays black and white class talents background art."] --Creates a tooltip on mouseover.

DPF_DesaturateScrollArtBackgroundCheckedCheck:SetScript("OnEvent", function(self, event, ...)
	DesaturateScrollArtBackground = gdbprivate.gdb.gdbdefaults.DPlayerFrameDesaturateScrollArtBackground.DesaturateScrollArtBackgroundChecked
	self:SetChecked(DesaturateScrollArtBackground)
end)

DPF_DesaturateScrollArtBackgroundCheckedCheck:SetScript("OnClick", function(self)
	DesaturateScrollArtBackground = not DesaturateScrollArtBackground
	gdbprivate.gdb.gdbdefaults.DPlayerFrameDesaturateScrollArtBackground.DesaturateScrollArtBackgroundChecked = DesaturateScrollArtBackground
	DPF_SetTalentArtFrames()
end)




----------------------------------------
-- Show/Hide/Move Default Stats Frame --
----------------------------------------

gdbprivate.gdbdefaults.gdbdefaults.DPlayerFrameShowDefaultStats = {
	ShowDefaultStatsChecked = false,
}

local function Default_SetResistances()
	for i=1, 5, 1 do
		local frame = _G["MagicResFrame"..i]
		frame:SetParent(CharacterModelFrame)
		frame:ClearAllPoints()
		if ShowDefaultStats then
			if (i==1) then
				frame:SetPoint("TOPRIGHT", CharacterModelFrame, "TOPRIGHT", -1, 1)
			else
				frame:SetPoint("TOP", _G["MagicResFrame"..(i-1)], "BOTTOM", 0,0)
			end
		else
			if (i==1) then
				frame:SetPoint("TOPRIGHT", CharacterModelFrame, "TOPRIGHT", -9, -3)
			else
				frame:SetPoint("TOP", _G["MagicResFrame"..(i-1)], "BOTTOM", 0,0)
			end
		end
	end
end

local function DPF_SetResistances()
	DefaultResistances = gdbprivate.gdb.gdbdefaults.DPlayerFrameDefaultResistances.DefaultResistancesChecked
	if DefaultResistances then
		Default_SetResistances()
	else
		for i=1, 5, 1 do 
			local frame = _G["MagicResFrame"..i]
			frame:SetParent(DPlayerFrameFrame)
			frame:ClearAllPoints()
			frame:Show()
			if ShowDefense then
				if (i==1) then
					frame:SetPoint("TOPLEFT", DPFDefenseStatsHeader, "BOTTOMLEFT", 12, 0)
				else
					frame:SetPoint("TOPLEFT", _G["MagicResFrame"..(i-1)], "TOPRIGHT", 2,0)
				end
			else
				frame:Hide()
			end
		end
	end
end

local function DPF_SetAllStatFrames()
	if ShowDefaultStats then
		CharacterModelFrame:SetPoint("TOPLEFT", CharacterHeadSlot, "TOPRIGHT", 7, -4)
		CharacterModelFrame:SetPoint("BOTTOMRIGHT", CharacterTrinket1Slot, "BOTTOMLEFT", -8, 96)
		CharacterAttributesFrame:Show()
		DPF_SetResistances()
	else
		CharacterModelFrame:SetPoint("TOPLEFT", CharacterHeadSlot, "TOPRIGHT")
		CharacterModelFrame:SetPoint("BOTTOMRIGHT", CharacterTrinket1Slot, "BOTTOMLEFT")
		CharacterAttributesFrame:Hide()
		DPF_SetResistances()
	end
end

local DPF_ShowDefaultStatsCheckedCheck = CreateFrame("CheckButton", "DPF_ShowDefaultStatsCheckedCheck", DPlayerFramePanel, "InterfaceOptionsCheckButtonTemplate")
	DPF_ShowDefaultStatsCheckedCheck:RegisterEvent("PLAYER_LOGIN")
	DPF_ShowDefaultStatsCheckedCheck:ClearAllPoints()
	--DPF_ShowDefaultStatsCheckedCheck:SetPoint("TOPLEFT", 30, -255)
	DPF_ShowDefaultStatsCheckedCheck:SetPoint("TOPLEFT", "DPFItemsPanelCategoryFS", 7, -25)
	DPF_ShowDefaultStatsCheckedCheck:SetScale(1)
	_G[DPF_ShowDefaultStatsCheckedCheck:GetName() .. "Text"]:SetText(L["Default Stats"])
	DPF_ShowDefaultStatsCheckedCheck.tooltipText = L["Displays the default stat frames."] --Creates a tooltip on mouseover.

DPF_ShowDefaultStatsCheckedCheck:SetScript("OnEvent", function(self, event, ...)
	ShowDefaultStats = gdbprivate.gdb.gdbdefaults.DPlayerFrameShowDefaultStats.ShowDefaultStatsChecked
	self:SetChecked(ShowDefaultStats)
	DPF_SetAllStatFrames()
end)

DPF_ShowDefaultStatsCheckedCheck:SetScript("OnClick", function(self)
	ShowDefaultStats = not ShowDefaultStats
	gdbprivate.gdb.gdbdefaults.DPlayerFrameShowDefaultStats.ShowDefaultStatsChecked = ShowDefaultStats
	DPF_SetAllStatFrames()
	hideDPFRB()
end)

gdbprivate.gdbdefaults.gdbdefaults.DPlayerFrameDefaultResistances = {
	DefaultResistancesChecked = false,
}

local DPF_DefaultResistancesCheck = CreateFrame("CheckButton", "DPF_DefaultResistancesCheck", DPlayerFramePanel, "InterfaceOptionsCheckButtonTemplate")
	DPF_DefaultResistancesCheck:RegisterEvent("PLAYER_LOGIN")
	DPF_DefaultResistancesCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    DPF_DefaultResistancesCheck:RegisterEvent("PLAYER_REGEN_DISABLED")
    DPF_DefaultResistancesCheck:RegisterEvent("PLAYER_REGEN_ENABLED")
    DPF_DefaultResistancesCheck:RegisterEvent("PLAYER_STARTED_MOVING")
	DPF_DefaultResistancesCheck:ClearAllPoints()
	--DPF_DefaultResistancesCheck:SetPoint("TOPLEFT", 30, -255)
	DPF_DefaultResistancesCheck:SetPoint("TOPLEFT", "DPFItemsPanelCategoryFS", 7, -45)
	DPF_DefaultResistancesCheck:SetScale(1)
	_G[DPF_DefaultResistancesCheck:GetName() .. "Text"]:SetText(L["Default Resistances"])
	DPF_DefaultResistancesCheck.tooltipText = L["Displays the default resistance frames."] --Creates a tooltip on mouseover.

DPF_DefaultResistancesCheck:SetScript("OnEvent", function(self, event, ...)
	DefaultResistances = gdbprivate.gdb.gdbdefaults.DPlayerFrameDefaultResistances.DefaultResistancesChecked
	self:SetChecked(DefaultResistances)
	DPF_SetResistances()
end)

DPF_DefaultResistancesCheck:SetScript("OnClick", function(self)
	DefaultResistances = not DefaultResistances
	gdbprivate.gdb.gdbdefaults.DPlayerFrameDefaultResistances.DefaultResistancesChecked = DefaultResistances
	DPF_SetResistances()
	DPF_CREATE_STATS()
end)

gdbprivate.gdbdefaults.gdbdefaults.DPlayerFrameShowModelRotation = {
	ShowModelRotationChecked = false,
}



local DPlayerFrameEventFrame = CreateFrame("Frame", "DPlayerFrameEventFrame", UIParent)
-- DPlayerFrameEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
DPlayerFrameEventFrame:RegisterEvent("ADDON_LOADED")
DPlayerFrameEventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
DPlayerFrameEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
DPlayerFrameEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
DPlayerFrameEventFrame:RegisterEvent("PLAYER_STARTED_MOVING")

	DPlayerFrameEventFrame:SetScript("OnEvent", function(self, event, arg1)
		if event == "ADDON_LOADED" and arg1 == "DPlayerFrame" then
			DPF_SetAllStatFrames()
			DPF_CREATE_STATS()
			DPF_SET_STATS_TEXT()
			DPF_SetResistances()
			DPF_RepairTotal()
			self:UnregisterEvent("ADDON_LOADED")
		end
	end)

	hooksecurefunc("PaperDollFrame_UpdateStats", function()
		DPF_CREATE_STATS()
		DPF_SET_STATS_TEXT()
		DPF_RepairTotal()
	end)

gdbprivate.gdbdefaults.gdbdefaults.DPlayerFrameShowPrimaryChecked = {
	ShowPrimarySetChecked = true,
}

local DPF_ShowPrimaryCheck = CreateFrame("CheckButton", "DPF_ShowPrimaryCheck", DPlayerFramePanel, "InterfaceOptionsCheckButtonTemplate")
DPF_ShowPrimaryCheck:RegisterEvent("PLAYER_LOGIN")
DPF_ShowPrimaryCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
DPF_ShowPrimaryCheck:RegisterEvent("PLAYER_REGEN_DISABLED")
DPF_ShowPrimaryCheck:RegisterEvent("PLAYER_REGEN_ENABLED")
DPF_ShowPrimaryCheck:RegisterEvent("PLAYER_STARTED_MOVING")

DPF_ShowPrimaryCheck:ClearAllPoints()
	DPF_ShowPrimaryCheck:SetPoint("TOPLEFT", "DPFItemsPanelHeadersFS", 7, -15)
	DPF_ShowPrimaryCheck:SetScale(1)
	DPF_ShowPrimaryCheck.tooltipText = L["Show primary stats."] --Creates a tooltip on mouseover.
	_G[DPF_ShowPrimaryCheck:GetName() .. "Text"]:SetText(L["Primary Stats"])
	
DPF_ShowPrimaryCheck:SetScript("OnEvent", function(self, event, ...)
	ShowPrimary = gdbprivate.gdb.gdbdefaults.DPlayerFrameShowPrimaryChecked.ShowPrimarySetChecked
	self:SetChecked(ShowPrimary)
	statHeaderYOffsets()
	DPF_CREATE_STATS()
	DPF_SET_STATS_TEXT()
end)

DPF_ShowPrimaryCheck:SetScript("OnClick", function(self)
	ShowPrimary = not ShowPrimary
	DPF_CREATE_STATS()
	DPF_SET_STATS_TEXT()
	gdbprivate.gdb.gdbdefaults.DPlayerFrameShowPrimaryChecked.ShowPrimarySetChecked = ShowPrimary
	statHeaderYOffsets()
end)

gdbprivate.gdbdefaults.gdbdefaults.DPlayerFrameShowMeleeChecked = {
	ShowMeleeSetChecked = true,
}

local DPF_ShowMeleeCheck = CreateFrame("CheckButton", "DPF_ShowMeleeCheck", DPlayerFramePanel, "InterfaceOptionsCheckButtonTemplate")
DPF_ShowMeleeCheck:RegisterEvent("PLAYER_LOGIN")
DPF_ShowMeleeCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
DPF_ShowMeleeCheck:RegisterEvent("PLAYER_STARTED_MOVING")

DPF_ShowMeleeCheck:ClearAllPoints()
	DPF_ShowMeleeCheck:SetPoint("TOPLEFT", "DPFItemsPanelHeadersFS", 7, -35)
	DPF_ShowMeleeCheck:SetScale(1)
	DPF_ShowMeleeCheck.tooltipText = L["Show melee stats."] --Creates a tooltip on mouseover.
	_G[DPF_ShowMeleeCheck:GetName() .. "Text"]:SetText(L["Melee Stats"])
	
DPF_ShowMeleeCheck:SetScript("OnEvent", function(self, event, ...)
	ShowMelee = gdbprivate.gdb.gdbdefaults.DPlayerFrameShowMeleeChecked.ShowMeleeSetChecked
	self:SetChecked(ShowMelee)
	DPF_CREATE_STATS()
	DPF_SET_STATS_TEXT()
	statHeaderYOffsets()
end)

DPF_ShowMeleeCheck:SetScript("OnClick", function(self)
	ShowMelee = not ShowMelee
	DPF_CREATE_STATS()
	DPF_SET_STATS_TEXT()
	gdbprivate.gdb.gdbdefaults.DPlayerFrameShowMeleeChecked.ShowMeleeSetChecked = ShowMelee
	statHeaderYOffsets()
end)

gdbprivate.gdbdefaults.gdbdefaults.DPlayerFrameShowRangedChecked = {
	ShowRangedSetChecked = true,
}

local DPF_ShowRangedCheck = CreateFrame("CheckButton", "DPF_ShowRangedCheck", DPlayerFramePanel, "InterfaceOptionsCheckButtonTemplate")
DPF_ShowRangedCheck:RegisterEvent("PLAYER_LOGIN")
DPF_ShowRangedCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
DPF_ShowRangedCheck:RegisterEvent("PLAYER_STARTED_MOVING")

DPF_ShowRangedCheck:ClearAllPoints()
	DPF_ShowRangedCheck:SetPoint("TOPLEFT", "DPFItemsPanelHeadersFS", 7, -55)
	DPF_ShowRangedCheck:SetScale(1)
	DPF_ShowRangedCheck.tooltipText = L["Show ranged stats."] --Creates a tooltip on mouseover.
	_G[DPF_ShowRangedCheck:GetName() .. "Text"]:SetText(L["Ranged Stats"])
	
DPF_ShowRangedCheck:SetScript("OnEvent", function(self, event, ...)
	-- ShowPrimary = gdbprivate.gdb.gdbdefaults.DPlayerFrameShowPrimaryChecked.ShowPrimarySetChecked
	ShowRanged = gdbprivate.gdb.gdbdefaults.DPlayerFrameShowRangedChecked.ShowRangedSetChecked
	self:SetChecked(ShowRanged)
	DPF_CREATE_STATS()
	DPF_SET_STATS_TEXT()
	statHeaderYOffsets()
end)

DPF_ShowRangedCheck:SetScript("OnClick", function(self)
	ShowRanged = not ShowRanged
	DPF_CREATE_STATS()
	DPF_SET_STATS_TEXT()
	gdbprivate.gdb.gdbdefaults.DPlayerFrameShowRangedChecked.ShowRangedSetChecked = ShowRanged
	statHeaderYOffsets()
end)

gdbprivate.gdbdefaults.gdbdefaults.DPlayerFrameShowSpellChecked = {
	ShowSpellSetChecked = true,
}

local DPF_ShowSpellCheck = CreateFrame("CheckButton", "DPF_ShowSpellCheck", DPlayerFramePanel, "InterfaceOptionsCheckButtonTemplate")
DPF_ShowSpellCheck:RegisterEvent("PLAYER_LOGIN")
DPF_ShowSpellCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
DPF_ShowSpellCheck:RegisterEvent("PLAYER_STARTED_MOVING")


DPF_ShowSpellCheck:ClearAllPoints()
	DPF_ShowSpellCheck:SetPoint("TOPLEFT", "DPFItemsPanelHeadersFS", 7, -75)
	DPF_ShowSpellCheck:SetScale(1)
	DPF_ShowSpellCheck.tooltipText = L["Show spell stats."] --Creates a tooltip on mouseover.
	_G[DPF_ShowSpellCheck:GetName() .. "Text"]:SetText(L["Spell Stats"])
	
DPF_ShowSpellCheck:SetScript("OnEvent", function(self, event, ...)
	ShowSpell = gdbprivate.gdb.gdbdefaults.DPlayerFrameShowSpellChecked.ShowSpellSetChecked
	self:SetChecked(ShowSpell)
	DPF_CREATE_STATS()
	DPF_SET_STATS_TEXT()
	statHeaderYOffsets()
end)

DPF_ShowSpellCheck:SetScript("OnClick", function(self)
	ShowSpell = not ShowSpell
	DPF_CREATE_STATS()
	DPF_SET_STATS_TEXT()
	gdbprivate.gdb.gdbdefaults.DPlayerFrameShowSpellChecked.ShowSpellSetChecked = ShowSpell
	statHeaderYOffsets()
end)

gdbprivate.gdbdefaults.gdbdefaults.DPlayerFrameShowDefenseChecked = {
	ShowDefenseSetChecked = true,
}

local DPF_ShowDefenseCheck = CreateFrame("CheckButton", "DPF_ShowDefenseCheck", DPlayerFramePanel, "InterfaceOptionsCheckButtonTemplate")
DPF_ShowDefenseCheck:RegisterEvent("PLAYER_LOGIN")
DPF_ShowDefenseCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
DPF_ShowDefenseCheck:RegisterEvent("PLAYER_STARTED_MOVING")

DPF_ShowDefenseCheck:ClearAllPoints()
	DPF_ShowDefenseCheck:SetPoint("TOPLEFT", "DPFItemsPanelHeadersFS", 7, -95)
	DPF_ShowDefenseCheck:SetScale(1)
	DPF_ShowDefenseCheck.tooltipText = L["Show defense stats."] --Creates a tooltip on mouseover.
	_G[DPF_ShowDefenseCheck:GetName() .. "Text"]:SetText(L["Defense Stats"])
	
DPF_ShowDefenseCheck:SetScript("OnEvent", function(self, event, ...)
	ShowDefense = gdbprivate.gdb.gdbdefaults.DPlayerFrameShowDefenseChecked.ShowDefenseSetChecked
	self:SetChecked(ShowDefense)
	DPF_CREATE_STATS()
	DPF_SET_STATS_TEXT()
	DPF_SetResistances()
	statHeaderYOffsets()
end)

DPF_ShowDefenseCheck:SetScript("OnClick", function(self)
	ShowDefense = not ShowDefense
	DPF_CREATE_STATS()
	DPF_SET_STATS_TEXT()
	DPF_SetResistances()
	gdbprivate.gdb.gdbdefaults.DPlayerFrameShowDefenseChecked.ShowDefenseSetChecked = ShowDefense
	statHeaderYOffsets()
end)


local addonName, addon = ...
local L = addon.L
local _, class = UnitClass("player")
local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]

local ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)
if not ldb then return end

local plugin = ldb:NewDataObject(addonName, {
	type = "data source",
	text = "0",
	icon = "Interface\\AddOns\\"..addonName.."\\Textures\\SmallLogo.tga",
})


function plugin.OnClick(self, button)
	if button == "RightButton" then
		InterfaceOptionsFrame_OpenToCategory("DPlayerFrame")
		InterfaceOptionsFrame_OpenToCategory("DPlayerFrame")
		InterfaceOptionsFrame_OpenToCategory("DPlayerFrame")
	elseif button == "LeftButton" then
		if statFrame:IsVisible() then
			statFrame:Hide()
		else
			statFrame:Show()
		end
		if IsShiftKeyDown() then
			LibStub("LibDBIcon-1.0"):Hide(addonName)
		end
        if IsAltKeyDown() then
            ReloadUI()
        end
	end
end
function plugin.OnTooltipShow(tooltip)
    if not tooltip or not tooltip.AddLine then return end
    tooltip:AddLine("DP-Frame")
    tooltip:AddLine("|cffff7E40Left Click:|r Toggle DP-Frame display.", color.r, color.g, color.b)
    tooltip:AddLine("|cffff7E40Right Click:|r Options display.", color.r, color.g, color.b)
    tooltip:AddLine("|cffff7E40Shift+Left Click:|r Hide minimap button.", color.r, color.g, color.b)
    tooltip:AddLine("Alt+Left Click: ReloadUI.", 1, 0, 0, 0.5)
    tooltip:Show()
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function()
	local icon = LibStub("LibDBIcon-1.0", true)
	if not icon then return end
	if not DPlayerFrameLDBIconDB then DPlayerFrameLDBIconDB = {} end
	icon:Register(addonName, plugin, DPlayerFrameLDBIconDB)
end)
f:RegisterEvent("PLAYER_LOGIN")

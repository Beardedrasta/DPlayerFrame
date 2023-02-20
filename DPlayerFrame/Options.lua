local addonName, addon = ...
local L = addon.L

local frame = DPlayerFramePanel

DPlayerFramePanel:SetScript("OnShow", function (frame)
    local function newCheckbox(label, description, onClick)
        local check = CreateFrame("CheckButton", "DPlayerCheck" .. label, DPlayerFramePanel, "InterfaceOptionsCheckButtonTemplate")
        check:SetScript("OnClick", function(self)
        local tick = self:GetChecked()
        onClick(self, tick and true or false)
        if tick then
            PlaySound(856)
        else
            PlaySound(857)
        end
    end)
    check.label = _G[check:GetName() .. "Text"]
    check.label:SetText(label)
    check.tooltipText = label
    check.tooltipRequirement = description
    return check
end

local minimap = newCheckbox(
    L["Minimap Icon"],
    L.minimapDesc,
    function(self, value)
        DPlayerFrameLDBIconDB.hide = not value
			if DPlayerFrameLDBIconDB.hide then
				LibStub("LibDBIcon-1.0"):Hide(addonName)
			else
				LibStub("LibDBIcon-1.0"):Show(addonName)
			end
		end)
        minimap:SetPoint("TOPLEFT", "DPFMiscPanelCategoryFS", 7, -175)
        minimap:SetChecked(not DPlayerFrameLDBIconDB.hide)
    end)
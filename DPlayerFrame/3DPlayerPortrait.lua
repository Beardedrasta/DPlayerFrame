--[[local function OnSizeChanged(self)
	if not DPlayerFrame then return end
	DPlayerFrameDB.Width = self.GetWidth() -- Save the new width
	DPlayerFrameDB.Height = self:GetHeight() -- and height to SavedVariables
end]]--


local Player3D = CreateFrame("PlayerModel", "RastaPlayerD", UIParent)
Player3D:SetSize(100, 100)
Player3D:SetUnit("player")
Player3D:SetPoint("CENTER", -200, 0)
Player3D:SetPortraitZoom(1)
Player3D:SetMovable(true)
Player3D:SetClampedToScreen( true )
Player3D:SetResizable(true)
Player3D:EnableMouse(true)
Player3D:RegisterEvent("PLAYER_LOGIN")
Player3D:RegisterForDrag("LeftButton")
Player3D:RegisterForDrag("RightButton")
Player3D:SetAlpha(0.2)
Player3D:SetAttribute("toggleForVehicle", true)

Player3D:SetScript("OnEvent", function(self)
	self:SetUnit("player")
end)



Player3D:SetScript("OnMouseDown", function(self, button)
	if ( IsShiftKeyDown() ) then
		print("|cFFEE82EE Moving Character Frame|r")
		self:StartMoving()
		self.isMoving = true
		self:SetUserPlaced(true)
	end
end)

Player3D:SetScript("OnMouseUp", function(self, button)
		self:StopMovingOrSizing()
end)


--[[local Player2D = CreateFrame("Frame", "FizzlePlayer2D", UIParent)
Player2D:SetSize(100, 100)
Player2D.Portrait = Player2D:CreateTexture()
Player2D.Portrait:SetAllPoints()
SetPortraitTexture(Player2D.Portrait, "player")
Player2D:SetPoint("CENTER", 200, 0)
Player2D:SetScript("OnEvent", function(self)
	SetPortraitTexture(self.Portrait, "player")
end)]]--

Player3D:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", "player")
--Player2D:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", "player")

local resizeButton = CreateFrame("Button", nil, Player3D)
resizeButton:SetSize(16, 16)
resizeButton:SetPoint("BOTTOMRIGHT")
resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
 
resizeButton:SetScript("OnMouseDown", function(self, button)
	print("|cFFEE82EE Sizing Character Frame|r")
    Player3D:StartSizing("BOTTOMRIGHT")
    Player3D:SetUserPlaced(true)
end)
 
resizeButton:SetScript("OnMouseUp", function(self, button)
    Player3D:StopMovingOrSizing()
end)
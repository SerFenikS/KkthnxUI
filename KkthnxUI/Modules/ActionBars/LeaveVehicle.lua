local K, C = unpack(select(2, ...))
if C["ActionBar"].Enable ~= true then
	return
end

local Module = K:NewModule("LeaveVehicle", "AceEvent-3.0")

local _G = _G

local CanExitVehicle = _G.CanExitVehicle
local GameTooltip_Hide = _G.GameTooltip_Hide
local InCombatLockdown = _G.InCombatLockdown
local MainMenuBarVehicleLeaveButton_OnEnter = _G.MainMenuBarVehicleLeaveButton_OnEnter
local TaxiRequestEarlyLanding = _G.TaxiRequestEarlyLanding
local UnitOnTaxi = _G.UnitOnTaxi
local VehicleExit = _G.VehicleExit

local Vehicle_CallOnEvent -- so we can call the local function inside of itself
local function Vehicle_OnEvent(self, event)
	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent(event)
	elseif InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", Vehicle_CallOnEvent)
		return
	end

	if (CanExitVehicle()) then
		self:Show()
		self:GetNormalTexture():SetVertexColor(1, 1, 1)
		self:EnableMouse(true)
	else
		self:Hide()
	end
end
Vehicle_CallOnEvent = Vehicle_OnEvent

local function Vehicle_OnClick(self)
	if (UnitOnTaxi("player")) then
		TaxiRequestEarlyLanding()
		self:GetNormalTexture():SetVertexColor(1, 0, 0)
		self:EnableMouse(false)
	else
		VehicleExit()
	end
end

function Module:UpdateVehicleLeave()
	local button = LeaveVehicleButton

	if not button then
		return
	end

	button:ClearAllPoints()
	button:SetPoint("CENTER", VehicleButtonAnchor, "CENTER")
	button:SetSize(C["ActionBar"].ButtonSize, C["ActionBar"].ButtonSize)
end

function Module:OnEnable()
	local VehicleButtonAnchor = CreateFrame("Frame", "VehicleButtonAnchor", UIParent)
	VehicleButtonAnchor:SetPoint("BOTTOMRIGHT", "ActionButton1", "BOTTOMLEFT", -6, 0)
	VehicleButtonAnchor:SetSize(C["ActionBar"].ButtonSize, C["ActionBar"].ButtonSize)
	K.Movers:RegisterFrame(VehicleButtonAnchor)

	local vehicle = CreateFrame("Button", "LeaveVehicleButton", UIParent)
	vehicle:SetSize(C["ActionBar"].ButtonSize, C["ActionBar"].ButtonSize)
	vehicle:SetFrameStrata("HIGH")
	vehicle:SetPoint("CENTER", VehicleButtonAnchor, "CENTER")
	vehicle:StyleButton()
	vehicle:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	vehicle:GetNormalTexture():SetTexCoord(0.2, 0.8, 0.2, 0.8)
	vehicle:GetNormalTexture():SetAllPoints()
	vehicle:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
	vehicle:GetPushedTexture():SetTexCoord(0.2, 0.8, 0.2, 0.8)
	vehicle:GetPushedTexture():SetAllPoints()
	vehicle:CreateBorder()
	vehicle:RegisterForClicks("AnyUp")

	vehicle:SetScript("OnClick", Vehicle_OnClick)
	vehicle:SetScript("OnEnter", MainMenuBarVehicleLeaveButton_OnEnter)
	vehicle:SetScript("OnLeave", GameTooltip_Hide)
	vehicle:RegisterEvent("PLAYER_ENTERING_WORLD")
	vehicle:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	vehicle:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
	vehicle:RegisterEvent("UNIT_ENTERED_VEHICLE")
	vehicle:RegisterEvent("UNIT_EXITED_VEHICLE")
	vehicle:RegisterEvent("VEHICLE_UPDATE")
	vehicle:SetScript("OnEvent", Vehicle_OnEvent)

	self:UpdateVehicleLeave()

	vehicle:Hide()
end
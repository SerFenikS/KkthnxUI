local K, C, L = unpack(select(2, ...))
if C["ActionBar"].Enable ~= true or C["ActionBar"].ToggleMode ~= true then
	return
end

-- Lua API
local _G = _G

-- Wow API
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local InCombatLockdown = _G.InCombatLockdown
local UIParent = _G.UIParent
local CreateFrame = _G.CreateFrame

local ToggleBar = CreateFrame("Frame", "ToggleActionbar", UIParent)
local ToggleButtonSize = C["ActionBar"].ButtonSize
local ToggleButtonSpace = C["ActionBar"].ButtonSpace

local function ToggleBarText(i, text, plus, neg)
	if plus then
		ToggleBar[i].Text:SetText(text)
		ToggleBar[i].Text:SetTextColor(0.33, 0.59, 0.33)
	elseif neg then
		ToggleBar[i].Text:SetText(text)
		ToggleBar[i].Text:SetTextColor(0.85, 0.27, 0.27)
	end
end

local function MainBars()
	if C["ActionBar"].RightBars > 2 then
		if KkthnxUIData[K.Realm][K.Name].BottomBars == 1 then
			ActionBarAnchor:SetHeight(ToggleButtonSize)
			ToggleBarText(1, "+ + +", true)
			Bar2Holder:Hide()
		elseif KkthnxUIData[K.Realm][K.Name].BottomBars == 2 then
			ActionBarAnchor:SetHeight(ToggleButtonSize * 2 + ToggleButtonSpace)
			ToggleBarText(1, "- - -", false, true)
			Bar2Holder:Show()
		end
	elseif C["ActionBar"].RightBars < 3 and C["ActionBar"].SplitBars ~= true then
		if KkthnxUIData[K.Realm][K.Name].BottomBars == 1 then
			ActionBarAnchor:SetHeight(ToggleButtonSize)
			ToggleBarText(1, "+ + +", true)
			Bar2Holder:Hide()
			Bar5Holder:Hide()
		elseif KkthnxUIData[K.Realm][K.Name].BottomBars == 2 then
			ActionBarAnchor:SetHeight(ToggleButtonSize * 2 + ToggleButtonSpace)
			ToggleBarText(1, "+ + +", true)
			Bar2Holder:Show()
			Bar5Holder:Hide()
		elseif KkthnxUIData[K.Realm][K.Name].BottomBars == 3 then
			ActionBarAnchor:SetHeight((ToggleButtonSize * 3) + (ToggleButtonSpace * 2))
			ToggleBarText(1, "- - -", false, true)
			Bar2Holder:Show()
			Bar5Holder:Show()
		end
	elseif C["ActionBar"].RightBars < 3 and C["ActionBar"].SplitBars == true then
		if KkthnxUIData[K.Realm][K.Name].BottomBars == 1 then
			ActionBarAnchor:SetHeight(ToggleButtonSize)
			ToggleBarText(1, "+ + +", true)
			Bar2Holder:Hide()
			ToggleBar[3]:SetHeight(ToggleButtonSize)
			ToggleBar[4]:SetHeight(ToggleButtonSize)

			for i = 1, 3 do
				local b = _G["MultiBarBottomRightButton" .. i]
				b:SetAlpha(0)
				b:SetScale(0.000001)
			end

			for i = 7, 9 do
				local b = _G["MultiBarBottomRightButton" .. i]
				b:SetAlpha(0)
				b:SetScale(0.000001)
			end
		elseif KkthnxUIData[K.Realm][K.Name].BottomBars == 2 then
			ActionBarAnchor:SetHeight(ToggleButtonSize * 2 + ToggleButtonSpace)
			ToggleBarText(1, "- - -", false, true)
			Bar2Holder:Show()
			ToggleBar[3]:SetHeight(ToggleButtonSize * 2 + ToggleButtonSpace)
			ToggleBar[4]:SetHeight(ToggleButtonSize * 2 + ToggleButtonSpace)

			for i = 1, 3 do
				local b = _G["MultiBarBottomRightButton" .. i]
				b:SetAlpha(1)
				b:SetScale(1)
			end

			for i = 7, 9 do
				local b = _G["MultiBarBottomRightButton" .. i]
				b:SetAlpha(1)
				b:SetScale(1)
			end
		end
	end
end

local function RightBars()
	if C["ActionBar"].RightBars > 2 then
		if KkthnxUIData[K.Realm][K.Name].RightBars == 1 then
			RightActionBarAnchor:SetWidth(ToggleButtonSize)

			if not C["ActionBar"].PetBarHorizontal == true then
				PetActionBarAnchor:ClearAllPoints()
				PetActionBarAnchor:SetPoint("RIGHT", RightActionBarAnchor, "LEFT", 0, 0)
			end

			ToggleBar[2]:SetWidth(ToggleButtonSize)
			ToggleBarText(2, "> > >", false, true)
			Bar3Holder:Hide()
			Bar4Holder:Hide()
		elseif KkthnxUIData[K.Realm][K.Name].RightBars == 2 then
			RightActionBarAnchor:SetWidth(ToggleButtonSize * 2 + ToggleButtonSpace)

			if not C["ActionBar"].PetBarHorizontal == true then
				PetActionBarAnchor:ClearAllPoints()
				PetActionBarAnchor:SetPoint("RIGHT", RightActionBarAnchor, "LEFT", 0, 0)
			end

			ToggleBar[2]:SetWidth(ToggleButtonSize * 2 + ToggleButtonSpace)
			ToggleBarText(2, "> > >", false, true)
			Bar3Holder:Hide()
			Bar4Holder:Show()
		elseif KkthnxUIData[K.Realm][K.Name].RightBars == 3 then
			RightActionBarAnchor:SetWidth((ToggleButtonSize * 3) + (ToggleButtonSpace * 2))

			if not C["ActionBar"].PetBarHorizontal == true then
				PetActionBarAnchor:ClearAllPoints()
				PetActionBarAnchor:SetPoint("RIGHT", RightActionBarAnchor, "LEFT", 0, 0)
			end

			ToggleBar[2]:SetWidth((ToggleButtonSize * 3) + (ToggleButtonSpace * 2))
			ToggleBarText(2, "> > >", false, true)
			RightActionBarAnchor:Show()
			Bar3Holder:Show()
			Bar4Holder:Show()

			if C["ActionBar"].RightBars > 2 then
				Bar5Holder:Show()
			end
		elseif KkthnxUIData[K.Realm][K.Name].RightBars == 0 then
			if not C["ActionBar"].PetBarHorizontal == true then
				PetActionBarAnchor:ClearAllPoints()
				PetActionBarAnchor:SetPoint("BOTTOMRIGHT", ToggleBar[2], "TOPRIGHT", 3, 3)
			end

			ToggleBar[2]:SetWidth(ToggleButtonSize)
			ToggleBarText(2, "< < <", true)
			RightActionBarAnchor:Hide()
			Bar3Holder:Hide()
			Bar4Holder:Hide()

			if C["ActionBar"].RightBars > 2 then
				Bar5Holder:Hide()
			end
		end
	elseif C["ActionBar"].RightBars < 3 then
		if KkthnxUIData[K.Realm][K.Name].RightBars == 1 then
			RightActionBarAnchor:SetWidth(ToggleButtonSize)

			if not C["ActionBar"].PetBarHorizontal == true then
				PetActionBarAnchor:ClearAllPoints()
				PetActionBarAnchor:SetPoint("RIGHT", RightActionBarAnchor, "LEFT", 0, 0)
			end

			ToggleBar[2]:SetWidth(ToggleButtonSize)
			ToggleBarText(2, "> > >", false, true)
			Bar3Holder:Show()
			Bar4Holder:Hide()

		elseif KkthnxUIData[K.Realm][K.Name].RightBars == 2 then
			RightActionBarAnchor:SetWidth(ToggleButtonSize * 2 + ToggleButtonSpace)

			if not C["ActionBar"].PetBarHorizontal == true then
				PetActionBarAnchor:ClearAllPoints()
				PetActionBarAnchor:SetPoint("RIGHT", RightActionBarAnchor, "LEFT", 0, 0)
			end

			ToggleBar[2]:SetWidth(ToggleButtonSize * 2 + ToggleButtonSpace)
			ToggleBarText(2, "> > >", false, true)
			RightActionBarAnchor:Show()
			Bar3Holder:Show()
			Bar4Holder:Show()

		elseif KkthnxUIData[K.Realm][K.Name].RightBars == 0 then
			if not C["ActionBar"].PetBarHorizontal == true then
				PetActionBarAnchor:ClearAllPoints()
				PetActionBarAnchor:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -18, 320)
			end

			ToggleBar[2]:SetWidth(ToggleButtonSize)
			ToggleBarText(2, "< < <", true)
			RightActionBarAnchor:Hide()
			Bar3Holder:Hide()
			Bar4Holder:Hide()

			if C["ActionBar"].RightBars > 2 then
				Bar5Holder:Hide()
			end
		end
	end
end

local function SplitBars()
	if C["ActionBar"].SplitBars == true and C["ActionBar"].RightBars ~= 3 then
		if KkthnxUIData[K.Realm][K.Name].SplitBars == true then
			ToggleBar[3]:ClearAllPoints()
			ToggleBar[3]:SetPoint("BOTTOMLEFT", SplitBarRight, "BOTTOMRIGHT", ToggleButtonSpace, 0)
			ToggleBar[4]:ClearAllPoints()
			ToggleBar[4]:SetPoint("BOTTOMRIGHT", SplitBarLeft, "BOTTOMLEFT", -ToggleButtonSpace, 0)
			VehicleButtonAnchor:ClearAllPoints()
			VehicleButtonAnchor:SetPoint("BOTTOMRIGHT", SplitBarLeft, "BOTTOMLEFT", -ToggleButtonSpace, 0)

			if KkthnxUIData[K.Realm][K.Name].BottomBars == 2 then
				ToggleBarText(3, "<\n<\n<", false, true)
				ToggleBarText(4, ">\n>\n>", false, true)
			else
				ToggleBarText(3, "<\n<", false, true)
				ToggleBarText(4, ">\n>", false, true)
			end

			Bar5Holder:Show()
		elseif KkthnxUIData[K.Realm][K.Name].SplitBars == false then
			ToggleBar[3]:ClearAllPoints()
			ToggleBar[3]:SetPoint("BOTTOMLEFT", ActionBarAnchor, "BOTTOMRIGHT", ToggleButtonSpace, 0)
			ToggleBar[4]:ClearAllPoints()
			ToggleBar[4]:SetPoint("BOTTOMRIGHT", ActionBarAnchor, "BOTTOMLEFT", -ToggleButtonSpace, 0)
			VehicleButtonAnchor:ClearAllPoints()
			VehicleButtonAnchor:SetPoint("BOTTOMRIGHT", ActionBarAnchor, "BOTTOMLEFT", -ToggleButtonSpace, 0)

			if KkthnxUIData[K.Realm][K.Name].BottomBars == 2 then
				ToggleBarText(3, ">\n>\n>", true)
				ToggleBarText(4, "<\n<\n<", true)
			else
				ToggleBarText(3, ">\n>", true)
				ToggleBarText(4, "<\n<", true)
			end

			Bar5Holder:Hide()
			SplitBarLeft:Hide()
			SplitBarRight:Hide()
		end
	end
end

for i = 1, 5 do
	ToggleBar[i] = CreateFrame("Frame", "ToggleBar" .. i, ToggleBar)
	ToggleBar[i]:EnableMouse(true)
	ToggleBar[i]:SetAlpha(0)
	ToggleBar[i].Text = ToggleBar[i]:CreateFontString(nil, "OVERLAY")
	ToggleBar[i].Text:SetFont(C["Media"].Font, C["Media"].FontSize, C["Media"].FontStyle)
	ToggleBar[i].Text:SetPoint("CENTER", 2, 0)

	if i == 1 then
		ToggleBar[i]:SetSize(ActionBarAnchor:GetWidth(), ToggleButtonSize / 1.5)
		ToggleBar[i]:SetPoint("BOTTOM", ActionBarAnchor, "TOP", 0, ToggleButtonSpace)

		ToggleBar[i].Background = ToggleBar[i]:CreateTexture(nil, "BACKGROUND", -1)
		ToggleBar[i].Background:SetAllPoints()
		ToggleBar[i].Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		ToggleBar[i].Border = CreateFrame("Frame", nil, ToggleBar[i])
		ToggleBar[i].Border:SetAllPoints()
		K.CreateBorder(ToggleBar[i].Border)

		ToggleBarText(i, "- - -", false, true)

		ToggleBar[i]:SetScript("OnMouseDown", function()
			if InCombatLockdown() then
				K.Print("|cffffff00" .. ERR_NOT_IN_COMBAT .. "|r")
				return
			end
			KkthnxUIData[K.Realm][K.Name].BottomBars = KkthnxUIData[K.Realm][K.Name].BottomBars + 1

			if C["ActionBar"].RightBars > 2 then
				if KkthnxUIData[K.Realm][K.Name].BottomBars > 2 then
					KkthnxUIData[K.Realm][K.Name].BottomBars = 1
				end
			elseif C["ActionBar"].RightBars < 3 and C["ActionBar"].SplitBars ~= true then
				if KkthnxUIData[K.Realm][K.Name].BottomBars > 3 then
					KkthnxUIData[K.Realm][K.Name].BottomBars = 1
				elseif KkthnxUIData[K.Realm][K.Name].BottomBars > 2 then
					KkthnxUIData[K.Realm][K.Name].BottomBars = 3
				elseif KkthnxUIData[K.Realm][K.Name].BottomBars < 1 then
					KkthnxUIData[K.Realm][K.Name].BottomBars = 3
				end
			elseif C["ActionBar"].RightBars < 3 and C["ActionBar"].SplitBars == true then
				if KkthnxUIData[K.Realm][K.Name].BottomBars > 2 then
					KkthnxUIData[K.Realm][K.Name].BottomBars = 1
				end
			end

			MainBars()
		end)
		ToggleBar[i]:SetScript("OnEvent", MainBars)
	elseif i == 2 then
		ToggleBar[i]:SetSize(RightActionBarAnchor:GetWidth(), ToggleButtonSize / 1.5)
		ToggleBar[i]:SetPoint("TOPRIGHT", RightActionBarAnchor, "BOTTOMRIGHT", 0, -ToggleButtonSpace)
		ToggleBar[i]:SetFrameStrata("LOW")

		ToggleBar[i].Background = ToggleBar[i]:CreateTexture(nil, "BACKGROUND", -1)
		ToggleBar[i].Background:SetAllPoints()
		ToggleBar[i].Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		ToggleBar[i].Border = CreateFrame("Frame", nil, ToggleBar[i])
		ToggleBar[i].Border:SetAllPoints()
		K.CreateBorder(ToggleBar[i].Border)

		ToggleBarText(i, "> > >", false, true)

		ToggleBar[i]:SetScript("OnMouseDown", function()
			if InCombatLockdown() then
				K.Print("|cffffff00" .. ERR_NOT_IN_COMBAT .. "|r")
				return
			end
			KkthnxUIData[K.Realm][K.Name].RightBars = KkthnxUIData[K.Realm][K.Name].RightBars - 1

			if C["ActionBar"].RightBars > 2 then
				if KkthnxUIData[K.Realm][K.Name].RightBars > 3 then
					KkthnxUIData[K.Realm][K.Name].RightBars = 2
				elseif KkthnxUIData[K.Realm][K.Name].RightBars > 2 then
					KkthnxUIData[K.Realm][K.Name].RightBars = 1
				elseif KkthnxUIData[K.Realm][K.Name].RightBars < 0 then
					KkthnxUIData[K.Realm][K.Name].RightBars = 3
				end
			elseif C["ActionBar"].RightBars < 3 then
				if KkthnxUIData[K.Realm][K.Name].RightBars > 2 then
					KkthnxUIData[K.Realm][K.Name].RightBars = 1
				elseif KkthnxUIData[K.Realm][K.Name].RightBars < 0 then
					KkthnxUIData[K.Realm][K.Name].RightBars = 2
				end
			end

			RightBars()
		end)
		ToggleBar[i]:SetScript("OnEvent", RightBars)
	elseif i == 3 then
		if C["ActionBar"].SplitBars == true and C["ActionBar"].RightBars ~= 3 then
			ToggleBar[i]:SetSize(ToggleButtonSize / 1.5, ActionBarAnchor:GetHeight())
			ToggleBar[i]:SetPoint("BOTTOMLEFT", SplitBarRight, "BOTTOMRIGHT", ToggleButtonSpace, 0)

			ToggleBar[i].Backgrounds = ToggleBar[i]:CreateTexture(nil, "BACKGROUND", -2)
			ToggleBar[i].Backgrounds:SetAllPoints()
			ToggleBar[i].Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

			K.CreateBorder(ToggleBar[i])

			ToggleBarText(i, "<\n<", false, true)
			ToggleBar[i]:SetFrameLevel(SplitBarRight:GetFrameLevel() + 1)
		end
	elseif i == 4 then
		if C["ActionBar"].SplitBars == true and C["ActionBar"].RightBars ~= 3 then
			ToggleBar[i]:SetSize(ToggleButtonSize / 1.5, ActionBarAnchor:GetHeight())
			ToggleBar[i]:SetPoint("BOTTOMRIGHT", SplitBarLeft, "BOTTOMLEFT", -ToggleButtonSpace, 0)

			ToggleBar[i].Backgrounds = ToggleBar[i]:CreateTexture(nil, "BACKGROUND", -2)
			ToggleBar[i].Backgrounds:SetAllPoints()
			ToggleBar[i].Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

			K.CreateBorder(ToggleBar[i])

			ToggleBarText(i, ">\n>", false, true)
			ToggleBar[i]:SetFrameLevel(SplitBarLeft:GetFrameLevel() + 1)
		end
	end

	if i == 3 or i == 4 then
		ToggleBar[i]:SetScript("OnMouseDown", function()
			if InCombatLockdown() then
				K.Print("|cffffff00" .. ERR_NOT_IN_COMBAT .. "|r")
				return
			end

			if KkthnxUIData[K.Realm][K.Name].SplitBars == false then
				KkthnxUIData[K.Realm][K.Name].SplitBars = true
			elseif KkthnxUIData[K.Realm][K.Name].SplitBars == true then
				KkthnxUIData[K.Realm][K.Name].SplitBars = false
			end

			SplitBars()
		end)

		ToggleBar[i]:SetScript("OnEvent", SplitBars)
	end

	ToggleBar[i]:RegisterEvent("PLAYER_ENTERING_WORLD")
	ToggleBar[i]:RegisterEvent("PLAYER_REGEN_DISABLED")
	ToggleBar[i]:RegisterEvent("PLAYER_REGEN_ENABLED")

	ToggleBar[i]:SetScript("OnEnter", function()
		if InCombatLockdown() then
			return
		end

		if i == 2 then
			ToggleBar[i]:SetFadeIn()
		elseif i == 3 or i == 4 then
			ToggleBar[3]:SetFadeIn()
			ToggleBar[4]:SetFadeIn()
			VehicleButtonAnchor:ClearAllPoints()
			VehicleButtonAnchor:SetPoint("BOTTOMRIGHT", ToggleBar[4], "BOTTOMLEFT", -ToggleButtonSpace, 0)
		else
			ToggleBar[i]:SetFadeIn()
		end
	end)

	ToggleBar[i]:SetScript("OnLeave", function()
		if i == 2 then
			ToggleBar[i]:SetFadeOut()
		elseif i == 3 or i == 4 then
			if InCombatLockdown() then
				return
			end

			ToggleBar[3]:SetFadeOut()
			ToggleBar[4]:SetFadeOut()
			VehicleButtonAnchor:ClearAllPoints()

			if KkthnxUIData[K.Realm][K.Name].SplitBars == true then
				VehicleButtonAnchor:SetPoint("BOTTOMRIGHT", SplitBarLeft, "BOTTOMLEFT", -ToggleButtonSpace, 0)
			else
				VehicleButtonAnchor:SetPoint("BOTTOMRIGHT", ActionBarAnchor, "BOTTOMLEFT", -ToggleButtonSpace, 0)
			end
		else
			ToggleBar[i]:SetFadeOut()
		end
	end)

	ToggleBar[i]:SetScript("OnUpdate", function()
		if InCombatLockdown() then
			return
		end

		if KkthnxUIData[K.Realm][K.Name].BarsLocked == true then
			for i = 1, 4 do
				ToggleBar[i]:EnableMouse(false)
			end
		elseif KkthnxUIData[K.Realm][K.Name].BarsLocked == false then
			for i = 1, 4 do
				ToggleBar[i]:EnableMouse(true)
			end
		end
	end)
end
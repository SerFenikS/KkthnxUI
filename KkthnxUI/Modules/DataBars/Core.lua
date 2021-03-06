local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("DataBars", "AceHook-3.0", "AceEvent-3.0")

local _G = _G
local math_floor = math.floor
local pairs = pairs
local string_format = string.format
local select = select

local ARTIFACT_POWER = _G.ARTIFACT_POWER
local backupColor = _G.FACTION_BAR_COLORS[1]
local C_AzeriteItem_FindActiveAzeriteItem = _G.C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = _G.C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = _G.C_AzeriteItem.GetPowerLevel
local C_Reputation_GetFactionParagonInfo = _G.C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = _G.C_Reputation.IsFactionParagon
local CreateFrame = _G.CreateFrame
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local FactionStandingLabelUnknown = _G.UNKNOWN
local GameTooltip = _G.GameTooltip
local GetExpansionLevel = _G.GetExpansionLevel
local GetFactionInfo = _G.GetFactionInfo
local GetFriendshipReputation = _G.GetFriendshipReputation
local GetNumFactions = _G.GetNumFactions
local GetPetExperience = _G.GetPetExperience
local GetRestrictedAccountData = _G.GetRestrictedAccountData
local GetWatchedFactionInfo = _G.GetWatchedFactionInfo
local GetXPExhaustion = _G.GetXPExhaustion
local HONOR = _G.HONOR
local IsXPUserDisabled = _G.IsXPUserDisabled
local LEVEL = _G.LEVEL
local MAX_PLAYER_LEVEL_TABLE = _G.MAX_PLAYER_LEVEL_TABLE
local MAX_REPUTATION_REACTION = _G.MAX_REPUTATION_REACTION
local REPUTATION = _G.REPUTATION
local STANDING = _G.STANDING
local UnitHonor = _G.UnitHonor
local UnitHonorLevel = _G.UnitHonorLevel
local UnitHonorMax = _G.UnitHonorMax
local UnitIsPVP = _G.UnitIsPVP
local UnitLevel = _G.UnitLevel
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax

local function GetUnitXP(unit)
	if (unit == "pet") then
		return GetPetExperience()
	else
		return UnitXP(unit), UnitXPMax(unit)
	end
end

local function IsPlayerMaxLevel()
	local maxLevel = GetRestrictedAccountData()
	if (maxLevel == 0) then
		maxLevel = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]
	end

	return maxLevel == UnitLevel("player")
end

function Module:SetupExperience()
	local expbar = CreateFrame("StatusBar", "KkthnxUI_ExperienceBar", self.Container)
	expbar:SetStatusBarTexture(self.DatabaseTexture)
	expbar:SetStatusBarColor(self.Database.ExperienceColor[1], self.Database.ExperienceColor[2], self.Database.ExperienceColor[3])
	expbar:SetSize(self.Database.Width, self.Database.Height)
	expbar:CreateBorder()

	local restbar = CreateFrame("StatusBar", "KkthnxUI_RestBar", self.Container)
	restbar:SetStatusBarTexture(self.DatabaseTexture)
	restbar:SetStatusBarColor(self.Database.RestedColor[1], self.Database.RestedColor[2], self.Database.RestedColor[3])
	restbar:SetFrameLevel(3)
	restbar:SetSize(self.Database.Width, self.Database.Height)
	restbar:SetAlpha(0.5)
	restbar:SetAllPoints(expbar)

	local espark = expbar:CreateTexture(nil, "OVERLAY")
	espark:SetTexture(C["Media"].Spark_16)
	espark:SetHeight(self.Database.Height)
	espark:SetBlendMode("ADD")
	espark:SetPoint("CENTER", expbar:GetStatusBarTexture(), "RIGHT", 0, 0)

	local etext = expbar:CreateFontString(nil, "OVERLAY")
	etext:SetFontObject(self.DatabaseFont)
	etext:SetFont(select(1, etext:GetFont()), 11, select(3, etext:GetFont()))
	etext:SetPoint("CENTER")

	self.Bars.Experience = expbar
	expbar.RestBar = restbar
	expbar.Spark = espark
	expbar.Text = etext
end

function Module:SetupReputation()
	local reputation = CreateFrame("StatusBar", "KkthnxUI_ReputationBar", self.Container)
	reputation:SetStatusBarTexture(self.DatabaseTexture)
	reputation:SetStatusBarColor(1, 1, 1)
	reputation:SetSize(self.Database.Width, self.Database.Height)
	reputation:CreateBorder()

	local rspark = reputation:CreateTexture(nil, "OVERLAY")
	rspark:SetTexture(C["Media"].Spark_16)
	rspark:SetHeight(self.Database.Height)
	rspark:SetBlendMode("ADD")
	rspark:SetPoint("CENTER", reputation:GetStatusBarTexture(), "RIGHT", 0, 0)

	local rtext = reputation:CreateFontString(nil, "OVERLAY")
	rtext:SetFontObject(self.DatabaseFont)
	rtext:SetFont(select(1, rtext:GetFont()), 11, select(3, rtext:GetFont()))
	rtext:SetWidth(self.Database.Width - 6)
	rtext:SetWordWrap(false)
	rtext:SetPoint("CENTER")

	self.Bars.Reputation = reputation
	reputation.Spark = rspark
	reputation.Text = rtext
end

function Module:SetupAzerite()
	local azerite = CreateFrame("Statusbar", "KkthnxUI_AzeriteBar", self.Container)
	azerite:SetStatusBarTexture(self.DatabaseTexture)
	azerite:SetStatusBarColor(self.Database.AzeriteColor[1], self.Database.AzeriteColor[2], self.Database.AzeriteColor[3])
	azerite:SetSize(self.Database.Width, self.Database.Height)
	azerite:CreateBorder()

	local aspark = azerite:CreateTexture(nil, "OVERLAY")
	aspark:SetTexture(C["Media"].Spark_16)
	aspark:SetHeight(self.Database.Height)
	aspark:SetBlendMode("ADD")
	aspark:SetPoint("CENTER", azerite:GetStatusBarTexture(), "RIGHT", 0, 0)

	local atext = azerite:CreateFontString(nil, "OVERLAY")
	atext:SetFontObject(self.DatabaseFont)
	atext:SetFont(select(1, atext:GetFont()), 11, select(3, atext:GetFont()))
	atext:SetPoint("CENTER")

	self.Bars.Azerite = azerite
	azerite.Spark = aspark
	azerite.Text = atext
end

function Module:SetupHonor()
	local honor = CreateFrame("StatusBar", "KkthnxUI_HonorBar", self.Container)
	honor:SetStatusBarTexture(self.DatabaseTexture)
	honor:SetStatusBarColor(240/255, 114/255, 65/255)
	honor:SetSize(self.Database.Width, self.Database.Height)
	honor:CreateBorder()

	local hspark = honor:CreateTexture(nil, "OVERLAY")
	hspark:SetTexture(C["Media"].Spark_16)
	hspark:SetHeight(self.Database.Height)
	hspark:SetBlendMode("ADD")
	hspark:SetPoint("CENTER", honor:GetStatusBarTexture(), "RIGHT", 0, 0)

	local htext = honor:CreateFontString(nil, "OVERLAY")
	htext:SetFontObject(self.DatabaseFont)
	htext:SetFont(select(1, htext:GetFont()), 11, select(3, htext:GetFont()))
	htext:SetWidth(self.Database.Width - 6)
	htext:SetWordWrap(false)
	htext:SetPoint("CENTER")

	self.Bars.Honor = honor
	honor.Spark = hspark
	honor.Text = htext
end

function Module:UpdateReputation()
	local ID, isFriend, friendText, standingLabel
	local isCapped
	local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()

	if factionID and C_Reputation_IsFactionParagon(factionID) then
		local currentValue, threshold, _, hasRewardPending = C_Reputation_GetFactionParagonInfo(factionID)
		if currentValue and threshold then
			min, max = 0, threshold
			value = currentValue % threshold
			if hasRewardPending then
				value = value + threshold
			end
		end
	else
		if reaction == MAX_REPUTATION_REACTION then
			-- max rank, make it look like a full bar
			min, max, value = 0, 1, 1
			isCapped = true
		end

	end

	local numFactions = GetNumFactions()

	if name then
		local color = FACTION_BAR_COLORS[reaction] or backupColor
		self.Bars.Reputation:SetStatusBarColor(color.r, color.g, color.b)
		self.Bars.Reputation:SetMinMaxValues(min, max)
		self.Bars.Reputation:SetValue(value)

		for i = 1, numFactions do
			local factionName, _, standingID, _, _, _, _, _, _, _, _, _, _, factionID = GetFactionInfo(i)
			local friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID)
			if factionName == name then
				if friendID ~= nil then
					isFriend = true
					friendText = friendTextLevel
				else
					ID = standingID
				end
			end
		end

		if ID then
			standingLabel = K.ShortenString(_G["FACTION_STANDING_LABEL" .. ID], 1, false) -- F = Friendly, N = Neutral and so on.
		else
			standingLabel = FactionStandingLabelUnknown
		end

		local maxMinDiff = max - min
		if (maxMinDiff == 0) then
			maxMinDiff = 1
		end

		local text = ""

		if self.Database.Text then
			if isCapped then
				text = string_format("%s: [%s]", name, isFriend and friendText or standingLabel)
			else
				text = string_format("%s: %d%% [%s]", name, ((value - min) / (maxMinDiff) * 100), isFriend and friendText or standingLabel)
			end

			self.Bars.Reputation.Text:SetText(text)
		end

		self.Bars.Reputation:Show()
	else
		self.Bars.Reputation:Hide()
	end
end

function Module:UpdateExperience()
	if (not IsPlayerMaxLevel() and not IsXPUserDisabled()) then
		local cur, max = GetUnitXP("player")
		local rested = GetXPExhaustion()

		if max <= 0 then
			max = 1
		end

		self.Bars.Experience:SetMinMaxValues(0, max)
		self.Bars.Experience:SetValue(cur - 1 >= 0 and cur - 1 or 0)
		self.Bars.Experience:SetValue(cur)

		if rested and rested > 0 then
			self.Bars.Experience.RestBar:SetMinMaxValues(0, max)
			self.Bars.Experience.RestBar:SetValue(min(cur + rested, max))

			if self.Database.Text then
				self.Bars.Experience.Text:SetText(string_format("%d%% R:%d%%", cur / max * 100, rested / max * 100))
			end
		else
			self.Bars.Experience.RestBar:SetMinMaxValues(0, 1)
			self.Bars.Experience.RestBar:SetValue(0)

			if self.Database.Text then
				self.Bars.Experience.Text:SetText(string_format("%d%%", cur / max * 100))
			end
		end

		self.Bars.Experience:Show()
	else
		self.Bars.Experience:Hide()
	end
end

function Module:UpdateAzerite(event, unit)
	if (event == "UNIT_INVENTORY_CHANGED" and unit ~= "player") then
		return
	end

	local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()

	if azeriteItemLocation then
		local xp, totalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
		local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)

		self.Bars.Azerite:SetMinMaxValues(0, totalLevelXP)
		self.Bars.Azerite:SetValue(xp)

		if self.Database.Text then
			self.Bars.Azerite.Text:SetText(string_format("%s%% [%s]", math_floor(xp / totalLevelXP * 100), currentLevel))
		end

		self.Bars.Azerite:Show()
	else
		self.Bars.Azerite:Hide()
	end
end

function Module:UpdateHonor(event, unit)
	if not self.Database.TrackHonor then
		self.Bars.Honor:Hide()
		return
	end

	if event == "PLAYER_FLAGS_CHANGED" and unit ~= "player" then
		return
	end

	if IsPlayerMaxLevel() and UnitIsPVP("player") then
		local current = UnitHonor("player")
		local max = UnitHonorMax("player")

		if max == 0 then
			max = 1
		end

		self.Bars.Honor:SetMinMaxValues(0, max)
		self.Bars.Honor:SetValue(current)

		if self.Database.Text then
			self.Bars.Honor.Text:SetText(string_format("%d%%", current / max * 100))
		end

		self.Bars.Honor:Show()
	else
		self.Bars.Honor:Hide()
	end
end

function Module:OnEnter()
	GameTooltip_SetDefaultAnchor(GameTooltip, self.Container)
	-- GameTooltip:ClearLines()

	if self.Database.MouseOver then
		K.UIFrameFadeIn(self.Container, 0.25, self.Container:GetAlpha(), 1)
	end

	if (not IsPlayerMaxLevel() and not IsXPUserDisabled()) then
		local cur, max = GetUnitXP("player")
		local rested = GetXPExhaustion()

		GameTooltip:AddLine(L["Databars"].Experience)
		GameTooltip:AddDoubleLine(L["Databars"].XP, string_format("%s / %s (%d%%)", K.ShortValue(cur), K.ShortValue(max), math_floor(cur / max * 100)), 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Databars"].Remaining, string_format("%s (%s%% - %s "..L["Databars"].Bars..")", K.ShortValue(max - cur), math_floor((max - cur) / max * 100), math_floor(20 * (max - cur) / max)), 1, 1, 1)

		if rested then
			GameTooltip:AddDoubleLine(L["Databars"].Rested, string_format("+%s (%s%%)", K.ShortValue(rested), math_floor(rested / max * 100)), 1, 1, 1)
		end
		GameTooltip:AddDoubleLine("|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:118:218|t "..L["ConfigButton"].MiddleClick, "Share Your Experience", 1, 1, 1)
	end

	if GetWatchedFactionInfo() then
		if (not IsPlayerMaxLevel() and not IsXPUserDisabled()) then
			GameTooltip:AddLine(" ")
		end

		local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()
		if factionID and C_Reputation_IsFactionParagon(factionID) then
			local currentValue, threshold, _, hasRewardPending = C_Reputation_GetFactionParagonInfo(factionID)
			if currentValue and threshold then
				min, max = 0, threshold
				value = currentValue % threshold
				if hasRewardPending then
					value = value + threshold
				end
			end
		end

		if name then
			GameTooltip:AddLine(name)

			local friendID, friendTextLevel, _
			if factionID then
				friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID)
			end

			GameTooltip:AddDoubleLine(STANDING..":", (friendID and friendTextLevel) or _G["FACTION_STANDING_LABEL" .. reaction], 1, 1, 1)
			if reaction ~= MAX_REPUTATION_REACTION or C_Reputation_IsFactionParagon(factionID) then
				GameTooltip:AddDoubleLine(REPUTATION..":", string_format("%d / %d (%d%%)", value - min, max - min, (value - min) / ((max - min == 0) and max or (max - min)) * 100), 1, 1, 1)
			end
			GameTooltip:AddDoubleLine("|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:218:318|t "..L["ConfigButton"].LeftClick, "Toggle Reputation UI", 1, 1, 1)
		end
	end

	if C_AzeriteItem_FindActiveAzeriteItem() then
		if (not IsPlayerMaxLevel() and not IsXPUserDisabled()) or GetWatchedFactionInfo() then
			GameTooltip:AddLine(" ")
		end

		local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
		local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation)
		local xp, totalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
		local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)
		local xpToNextLevel = totalLevelXP - xp

		self.itemDataLoadedCancelFunc = azeriteItem:ContinueWithCancelOnItemLoad(function()
			local azeriteItemName = azeriteItem:GetItemName()

			GameTooltip:AddDoubleLine(ARTIFACT_POWER, azeriteItemName.." ("..currentLevel..")", nil, nil, nil, 0.90, 0.80, 0.50) -- Temp Locale
			GameTooltip:AddDoubleLine(L["Databars"].AP, string_format(" %d / %d (%d%%)", xp, totalLevelXP, xp / totalLevelXP * 100), 1, 1, 1)
			GameTooltip:AddDoubleLine(L["Databars"].Remaining, string_format(" %d (%d%% - %d "..L["Databars"].Bars..")", xpToNextLevel, xpToNextLevel / totalLevelXP * 100, 10 * xpToNextLevel / totalLevelXP), 1, 1, 1)
		end)
	end

	if self.Database.TrackHonor then
		if IsPlayerMaxLevel() and UnitIsPVP("player") then
			GameTooltip:AddLine(" ")

			local current = UnitHonor("player")
			local max = UnitHonorMax("player")
			local level = UnitHonorLevel("player")

			GameTooltip:AddDoubleLine(HONOR.." "..LEVEL, level)
			GameTooltip:AddDoubleLine(L["Databars"].Honor_XP, string_format(" %d / %d (%d%%)", current, max, current/max * 100), 1, 1, 1)
			GameTooltip:AddDoubleLine(L["Databars"].Honor_Remaining, string_format(" %d (%d%% - %d "..L["Databars"].Bars..")", max - current, (max - current) / max * 100, 20 * (max - current) / max), 1, 1, 1)
			GameTooltip:AddDoubleLine("|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:321:421|t "..L["ConfigButton"].Right_Click, "Toggle PvP UI", 1, 1, 1)
		end
	end

	GameTooltip:Show()
end

function Module:OnLeave()
	if self.Database.MouseOver then
		K.UIFrameFadeOut(self.Container, 1, self.Container:GetAlpha(), 0.25)
	end

	GameTooltip:Hide()
end

function Module:OnClick(_, clicked)
	if K.CodeDebug then
		K.Print("|cFFFF0000DEBUG:|r |cFF808080Line 430 - KkthnxUI|Modules|DataBars|Core -|r |cFFFFFF00" .. clicked .. " Clicked|r")
	end

	if clicked == "LeftButton" then
		if GetWatchedFactionInfo() then
			ToggleCharacter("ReputationFrame")
		end
	elseif clicked == "RightButton" then
		if self.Database.TrackHonor then
			if IsPlayerMaxLevel() and UnitIsPVP("player") then
				TogglePVPUI()
			end
		end
	elseif clicked == "MiddleButton" then
		if not IsPlayerMaxLevel() and not IsXPUserDisabled() then
			local cur, max = GetUnitXP("player")

			if IsInGroup(LE_PARTY_CATEGORY_HOME) then
				SendChatMessage(L["Databars"].XP .." ".. string_format("%s / %s (%d%%)", K.ShortValue(cur), K.ShortValue(max), math.floor(cur / max * 100)), "PARTY")
				SendChatMessage(L["Databars"].Remaining .." ".. string_format("%s (%s%% - %s "..L["Databars"].Bars..")", K.ShortValue(max - cur), math.floor((max - cur) / max * 100), math.floor(20 * (max - cur) / max)), "PARTY")
			end
		end
	end
end

function Module:Update()
	self:UpdateExperience()
	self:UpdateReputation()
	self:UpdateAzerite()
	self:UpdateHonor()

	if self.Database.MouseOver then
		self.Container:SetAlpha(0.25)
	else
		self.Container:SetAlpha(1)
	end

	local num_bars = 0
	local prev
	for _, bar in pairs(self.Bars) do
		if bar:IsShown() then
			num_bars = num_bars + 1

			bar:ClearAllPoints()
			if prev then
				bar:SetPoint("TOP", prev, "BOTTOM", 0, -6)
			else
				bar:SetPoint("TOP", self.Container)
			end
			prev = bar
		end
	end

	self.Container:SetHeight(num_bars * (self.Database.Height + 6) - 6)
end

function Module:OnEnable()
	self.Database = C["DataBars"]
	self.DatabaseTexture = K.GetTexture(self.Database.Texture)
	self.DatabaseFont = K.GetFont(self.Database.Font)

	if self.Database.Enable ~= true then
		return
	end

	local container = CreateFrame("button", "KkthnxUI_Databars", K.PetBattleHider)
	container:SetWidth(Minimap:GetWidth() or self.Database.Width)
	container:SetPoint("TOP", "Minimap", "BOTTOM", 0, -6)
	container:RegisterForClicks("RightButtonUp", "LeftButtonUp", "MiddleButtonUp")

	self:HookScript(container, "OnEnter")
	self:HookScript(container, "OnLeave")
	self:HookScript(container, "OnClick")
	self.Container = container

	self.Bars = {}
	self:SetupExperience()
	self:SetupReputation()
	self:SetupAzerite()
	self:SetupHonor()
	self:Update()

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update")
	self:RegisterEvent("PLAYER_LEVEL_UP", "Update")
	self:RegisterEvent("PLAYER_XP_UPDATE", "Update")
	self:RegisterEvent("UPDATE_EXHAUSTION", "Update")
	self:RegisterEvent("DISABLE_XP_GAIN", "Update")
	self:RegisterEvent("ENABLE_XP_GAIN", "Update")
	self:RegisterEvent("UPDATE_FACTION", "Update")
	self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED", "Update")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "Update")
	self:RegisterEvent("HONOR_XP_UPDATE", "Update")
	self:RegisterEvent("PLAYER_FLAGS_CHANGED", "Update")

	K.Movers:RegisterFrame(container)
end

function Module:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("PLAYER_LEVEL_UP")
	self:UnregisterEvent("PLAYER_XP_UPDATE")
	self:UnregisterEvent("UPDATE_EXHAUSTION")
	self:UnregisterEvent("DISABLE_XP_GAIN")
	self:UnregisterEvent("ENABLE_XP_GAIN")
	self:UnregisterEvent("UPDATE_FACTION")
	self:UnregisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	self:UnregisterEvent("HONOR_XP_UPDATE")
	self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
end
local K, C = unpack(select(2, ...))
if K.CheckAddOnState("OmniCC") or K.CheckAddOnState("ncCooldown") or K.CheckAddOnState("CooldownCount") or C["ActionBar"].Cooldowns ~= true then
	return
end

local _G = _G
local floor = math.floor
local pairs = pairs
local select = select
local tonumber = tonumber

local CreateFrame = _G.CreateFrame
local GetActionCharges = _G.GetActionCharges
local GetActionCooldown = _G.GetActionCooldown
local GetTime = _G.GetTime
local hooksecurefunc = _G.hooksecurefunc

OmniCC = true
local ICON_SIZE = 36
local DAY, HOUR, MINUTE = 86400, 3600, 60
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY / 2 + 0.5, HOUR / 2 + 0.5, MINUTE / 2 + 0.5

local CooldownFont = K.GetFont(C["ActionBar"].Font)
local CooldownFontSize = 20
local CooldownMinScale = 0.5
local CooldownMinDuration = 2

local EXPIRING_DURATION = 8
local EXPIRING_FORMAT = K.RGBToHex(1, 0, 0) .. "%.1f|r"
local SECONDS_FORMAT = K.RGBToHex(1, 1, 0) .. "%d|r"
local MINUTES_FORMAT = K.RGBToHex(1, 1, 1) .. "%dm|r"
local HOURS_FORMAT = K.RGBToHex(0.4, 1, 1) .. "%dh|r"
local DAYS_FORMAT = K.RGBToHex(0.4, 0.4, 1) .. "%dh|r"

local function GetFormattedTime(s)
	if not s then
		if K.CodeDebug then
			K.Print("|cFFFF0000DEBUG:|r |cFF808080Line 36 - KkthnxUI|Modules|ActionBars|Cooldowns -|r |cFFFFFF00" .. s .. " doesn't exsit|r")
		end
		return
	end

	if s < MINUTEISH then
		local seconds = tonumber(K.Round(s))
		if seconds > EXPIRING_DURATION then
			return SECONDS_FORMAT, seconds, s - (seconds - .51)
		else
			return EXPIRING_FORMAT, s, .051
		end
	elseif s < HOURISH then
		local minutes = tonumber(K.Round(s / MINUTE))
		return MINUTES_FORMAT, minutes, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
	elseif s < DAYISH then
		local hours = tonumber(K.Round(s / HOUR))
		return HOURS_FORMAT, hours, hours > 1 and (s - (hours * HOUR - HALFHOURISH)) or (s - HOURISH)
	else
		local days = tonumber(K.Round(s / DAY))
		return DAYS_FORMAT, days, days > 1 and (s - (days * DAY - HALFDAYISH)) or (s - DAYISH)
	end
end

local function Timer_Stop(self)
	if self:IsForbidden() then
		if K.CodeDebug then
			K.Print("|cFFFF0000DEBUG:|r |cFF808080Line 63 - KkthnxUI|Modules|ActionBars|Cooldowns -|r |cFFFFFF00" .. self .. " is forbidden|r")
		end
		return
	end

	self.enabled = nil
	self:Hide()
end

local function Timer_ForceUpdate(self)
	if self:IsForbidden() then
		if K.CodeDebug then
			K.Print("|cFFFF0000DEBUG:|r |cFF808080Line 75 - KkthnxUI|Modules|ActionBars|Cooldowns -|r |cFFFFFF00" .. self .. " is forbidden|r")
		end
		return
	end

	self.nextUpdate = 0
	self:Show()
end

local function Timer_OnSizeChanged(self, width)
	if self:IsForbidden() then
		if K.CodeDebug then
			K.Print("|cFFFF0000DEBUG:|r |cFF808080Line 87 - KkthnxUI|Modules|ActionBars|Cooldowns -|r |cFFFFFF00" .. self .. " is forbidden|r")
		end
		return
	end

	local fontScale = width and (floor(width + .5) / ICON_SIZE)

	if fontScale and (fontScale == self.fontScale) then
		return
	end

	self.fontScale = fontScale

	if fontScale and (fontScale < CooldownMinScale) then
		self:Hide()
	else
		self.text:SetFontObject(CooldownFont)
		self.text:SetFont(select(1, self.text:GetFont()), fontScale * CooldownFontSize, select(3, self.text:GetFont()))
		if self.enabled then
			Timer_ForceUpdate(self)
		end
	end
end

local function Timer_OnUpdate(self, elapsed)
	if self:IsForbidden() then
		if K.CodeDebug then
			K.Print("|cFFFF0000DEBUG:|r |cFF808080Line 114 - KkthnxUI|Modules|ActionBars|Cooldowns -|r |cFFFFFF00" .. self .. " is forbidden|r")
		end
		return
	end

	if self.text:IsShown() then
		if self.nextUpdate > 0 then
			self.nextUpdate = self.nextUpdate - elapsed
		else
			if self.fontScale and ((self.fontScale * self:GetEffectiveScale() / UIParent:GetScale()) < CooldownMinScale) then
				self.text:SetText("")
				self.nextUpdate = 500
			else
				local remain = self.duration - (GetTime() - self.start)
				if remain > 0.05 then
					local formatString, time, nextUpdate = GetFormattedTime(remain)
					self.text:SetFormattedText(formatString, time)
					self.nextUpdate = nextUpdate
				else
					Timer_Stop(self)
				end
			end
		end
	end
end

local function Timer_Create(self)
	if self:IsForbidden() then
		if K.CodeDebug then
			K.Print("|cFFFF0000DEBUG:|r |cFF808080Line 143 - KkthnxUI|Modules|ActionBars|Cooldowns -|r |cFFFFFF00" .. self .. " is forbidden|r")
		end
		return
	end

	local scaler = CreateFrame("Frame", nil, self)
	scaler:SetAllPoints()

	local timer = CreateFrame("Frame", nil, scaler)
	timer:Hide()
	timer:SetAllPoints()

	local text = timer:CreateFontString(nil, "OVERLAY")
	text:SetPoint("CENTER", 1, 0)
	text:SetJustifyH("CENTER")
	timer.text = text

	Timer_OnSizeChanged(timer, scaler:GetSize())
	scaler:SetScript("OnSizeChanged", function(_, ...)
		Timer_OnSizeChanged(timer, ...)
	end)

	-- keep this after Timer_OnSizeChanged
	timer:SetScript("OnUpdate", Timer_OnUpdate)

	self.timer = timer
	return timer
end

local function Timer_Start(self, start, duration, charges)
	if self:IsForbidden() then
		if K.CodeDebug then
			K.Print("|cFFFF0000DEBUG:|r |cFF808080Line 175 - KkthnxUI|Modules|ActionBars|Cooldowns -|r |cFFFFFF00" .. self .. " is forbidden|r")
		end
		return
	end

	local remainingCharges = charges or 0

	if self:GetName() and string.find(self:GetName(), "ChargeCooldown") then
		return
	end

	if start > 0 and duration > CooldownMinDuration and remainingCharges < CooldownMinDuration and (not self.noOCC) then
		local timer = self.timer or Timer_Create(self)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0

		if timer.fontScale and (timer.fontScale >= CooldownMinScale) then

			timer:Show()
		end
	elseif self.timer then
		Timer_Stop(self.timer)
	end
end

hooksecurefunc(getmetatable(_G["ActionButton1Cooldown"]).__index, "SetCooldown", Timer_Start)

if not _G["ActionBarButtonEventsFrame"] then
	return
end

local active = {}
local hooked = {}

local function cooldown_OnShow(self)
	active[self] = true
end

local function cooldown_OnHide(self)
	active[self] = nil
end

local function cooldown_ShouldUpdateTimer(self, start, duration, charges, maxCharges)
	local timer = self.timer
	return not (timer and timer.start == start and timer.duration == duration and timer.charges == charges and timer.maxCharges == maxCharges)
end

local function cooldown_Update(self)
	local button = self:GetParent()
	local action = button.action
	local start, duration = GetActionCooldown(action)
	local charges, maxCharges = GetActionCharges(action)

	if cooldown_ShouldUpdateTimer(self, start, duration, charges, maxCharges) then
		Timer_Start(self, start, duration, charges, maxCharges)
	end
end

local EventWatcher = CreateFrame("Frame")
EventWatcher:Hide()
EventWatcher:SetScript("OnEvent", function()
	for cooldown in pairs(active) do
		cooldown_Update(cooldown)
	end
end)
EventWatcher:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")

local function actionButton_Register(frame)
	local cooldown = frame.cooldown
	if not hooked[cooldown] then
		cooldown:HookScript("OnShow", cooldown_OnShow)
		cooldown:HookScript("OnHide", cooldown_OnHide)
		hooked[cooldown] = true
	end
end

if _G["ActionBarButtonEventsFrame"].frames then
	for _, frame in pairs(_G["ActionBarButtonEventsFrame"].frames) do
		actionButton_Register(frame)
	end
end

hooksecurefunc("ActionBarButtonEventsFrame_RegisterFrame", actionButton_Register)
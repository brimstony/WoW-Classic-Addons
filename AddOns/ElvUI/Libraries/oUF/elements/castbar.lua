--[[
# Element: Castbar

Handles the visibility and updating of spell castbars.

## Widget

Castbar - A `StatusBar` to represent spell cast/channel progress.

## Sub-Widgets

.Icon     - A `Texture` to represent spell icon.
.SafeZone - A `Texture` to represent latency.
.Shield   - A `Texture` to represent if it's possible to interrupt or spell steal.
.Spark    - A `Texture` to represent the castbar's edge.
.Text     - A `FontString` to represent spell name.
.Time     - A `FontString` to represent spell duration.

## Notes

A default texture will be applied to the StatusBar and Texture widgets if they don't have a texture or a color set.

## Options

.timeToHold      - Indicates for how many seconds the castbar should be visible after a _FAILED or _INTERRUPTED
                   event. Defaults to 0 (number)
.hideTradeSkills - Makes the element ignore casts related to crafting professions (boolean)

## Attributes

.castID           - A globally unique identifier of the currently cast spell (string?)
.casting          - Indicates whether the current spell is an ordinary cast (boolean)
.channeling       - Indicates whether the current spell is a channeled cast (boolean)
.notInterruptible - Indicates whether the current spell is interruptible (boolean)
.spellID          - The spell identifier of the currently cast/channeled spell (number)

## Examples

    -- Position and size
    local Castbar = CreateFrame('StatusBar', nil, self)
    Castbar:SetSize(20, 20)
    Castbar:SetPoint('TOP')
    Castbar:SetPoint('LEFT')
    Castbar:SetPoint('RIGHT')

    -- Add a background
    local Background = Castbar:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints(Castbar)
    Background:SetTexture(1, 1, 1, .5)

    -- Add a spark
    local Spark = Castbar:CreateTexture(nil, 'OVERLAY')
    Spark:SetSize(20, 20)
    Spark:SetBlendMode('ADD')
    Spark:SetPoint('CENTER', Castbar:GetStatusBarTexture(), 'RIGHT', 0, 0)

    -- Add a timer
    local Time = Castbar:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    Time:SetPoint('RIGHT', Castbar)

    -- Add spell text
    local Text = Castbar:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    Text:SetPoint('LEFT', Castbar)

    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, 'OVERLAY')
    Icon:SetSize(20, 20)
    Icon:SetPoint('TOPLEFT', Castbar, 'TOPLEFT')

    -- Add Shield
    local Shield = Castbar:CreateTexture(nil, 'OVERLAY')
    Shield:SetSize(20, 20)
    Shield:SetPoint('CENTER', Castbar)

    -- Add safezone
    local SafeZone = Castbar:CreateTexture(nil, 'OVERLAY')

    -- Register it with oUF
    Castbar.bg = Background
    Castbar.Spark = Spark
    Castbar.Time = Time
    Castbar.Text = Text
    Castbar.Icon = Icon
    Castbar.Shield = Shield
    Castbar.SafeZone = SafeZone
    self.Castbar = Castbar
--]]

local _, ns = ...
local oUF = ns.oUF

local DEFAULT_ICON = [[Interface\ICONS\INV_Misc_QuestionMark]]
local LibClassicCasterino = LibStub('LibClassicCasterino', true)
local UnitCastingInfo = CastingInfo
local UnitChannelInfo = ChannelInfo
local EventFunctions = {}

local tradeskillCurrent, tradeskillTotal, mergeTradeskill = 0, 0, false
local UNIT_SPELLCAST_SENT = function (self, event, unit, target, castID, spellID)
	local castbar = self.Castbar
	castbar.curTarget = (target and target ~= "") and target or nil

	if castbar.isTradeSkill then
		castbar.tradeSkillCastId = castID
	end
end

local function resetAttributes(self)
	self.castID = nil
	self.casting = nil
	self.channeling = nil
	self.notInterruptible = nil
	self.spellID = nil
	self.spellName = nil -- ElvUI
end

local function CastStart(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.Castbar

	local name, _, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(unit)
	event = 'UNIT_SPELLCAST_START'
	if(not name) then
		name, _, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID = UnitChannelInfo(unit)
		event = 'UNIT_SPELLCAST_CHANNEL_START'
	end

	if(not name or (isTradeSkill and element.hideTradeSkills)) then
		resetAttributes(element)
		element:Hide()

		return
	end

	endTime = endTime / 1000
	startTime = startTime / 1000

	element.max = endTime - startTime
	element.startTime = startTime
	element.delay = 0
	element.casting = event == 'UNIT_SPELLCAST_START'
	element.channeling = event == 'UNIT_SPELLCAST_CHANNEL_START'
	element.notInterruptible = notInterruptible
	element.holdTime = 0
	element.castID = castID
	element.spellID = spellID
	element.spellName = name -- ElvUI

	if(element.casting) then
		element.duration = GetTime() - startTime
	else
		element.duration = endTime - GetTime()
	end

	element:SetMinMaxValues(0, element.max)
	element:SetValue(element.duration)

	if texture == 136235 then
		texture = DEFAULT_ICON
	end

	if(element.Icon) then element.Icon:SetTexture(texture or DEFAULT_ICON) end
	if(element.Shield) then element.Shield:SetShown(notInterruptible) end
	if(element.Spark) then element.Spark:Show() end
	if(element.Text) then element.Text:SetText(name) end
	if(element.Time) then element.Time:SetText() end

	local safeZone = element.SafeZone
	if(safeZone) then
		local isHoriz = element:GetOrientation() == 'HORIZONTAL'

		safeZone:ClearAllPoints()
		safeZone:SetPoint(isHoriz and 'TOP' or 'LEFT')
		safeZone:SetPoint(isHoriz and 'BOTTOM' or 'RIGHT')

		if(element.casting) then
			safeZone:SetPoint(element:GetReverseFill() and (isHoriz and 'LEFT' or 'BOTTOM') or (isHoriz and 'RIGHT' or 'TOP'))
		else
			safeZone:SetPoint(element:GetReverseFill() and (isHoriz and 'RIGHT' or 'TOP') or (isHoriz and 'LEFT' or 'BOTTOM'))
		end

		local ratio = (select(4, GetNetStats()) / 1000) / element.max
		if(ratio > 1) then
			ratio = 1
		end

		safeZone[isHoriz and 'SetWidth' or 'SetHeight'](safeZone, element[isHoriz and 'GetWidth' or 'GetHeight'](element) * ratio)
	end

	--[[ Callback: Castbar:PostCastStart(unit)
	Called after the element has been updated upon a spell cast start.

	* self - the Castbar widget
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PostCastStart) then
		element:PostCastStart(unit)
	end

	element:Show()
end

local function CastUpdate(self, event, unit, castID, spellID)
	if(self.unit ~= unit) then return end

	local element = self.Castbar
	if unit == 'player' then
		if(not element:IsShown() or element.castID ~= castID or element.spellID ~= spellID) then
			return
		end
	else
		if(not element:IsShown()) then
			return
		end
	end

	local name, startTime, endTime, _
	if(event == 'UNIT_SPELLCAST_DELAYED') then
		name, _, _, startTime, endTime = UnitCastingInfo(unit)
	else
		name, _, _, startTime, endTime = UnitChannelInfo(unit)
	end

	if(not name) then return end

	endTime = endTime / 1000
	startTime = startTime / 1000

	local delta
	if(element.casting) then
		delta = startTime - element.startTime

		element.duration = GetTime() - startTime
	else
		delta = element.startTime - startTime

		element.duration = endTime - GetTime()
	end

	if(delta < 0) then
		delta = 0
	end

	element.max = endTime - startTime
	element.startTime = startTime
	element.delay = element.delay + delta

	element:SetMinMaxValues(0, element.max)
	element:SetValue(element.duration)

	--[[ Callback: Castbar:PostCastUpdate(unit)
	Called after the element has been updated when a spell cast has been updated.

	* self - the Castbar widget
	* unit - the unit that the update has been triggered (string)
	--]]
	if(element.PostCastUpdate) then
		return element:PostCastUpdate(unit)
	end
end

local function CastStop(self, event, unit, castID, spellID)
	if(self.unit ~= unit) then return end

	local element = self.Castbar
	if unit == 'player' then
		if(not element:IsShown() or element.castID ~= castID or element.spellID ~= spellID) then
			return
		end
	else
		if(not element:IsShown()) then
			return
		end
	end

	resetAttributes(element)

	--[[ Callback: Castbar:PostCastStop(unit, spellID)
	Called after the element has been updated when a spell cast has stopped.

	* self    - the Castbar widget
	* unit    - the unit for which the update has been triggered (string)
	* spellID - the ID of the spell (number)
	--]]
	if(element.PostCastStop) then
		return element:PostCastStop(unit, spellID)
	end
end

local function CastFail(self, event, unit, castID, spellID)
	if(self.unit ~= unit) then return end

	local element = self.Castbar
	if unit == 'player' then
		if(not element:IsShown() or element.castID ~= castID or element.spellID ~= spellID) then
			return
		end
	else
		if(not element:IsShown()) then
			return
		end
	end

	if(element.Text) then
		element.Text:SetText(event == 'UNIT_SPELLCAST_FAILED' and FAILED or INTERRUPTED)
	end

	if(element.Spark) then element.Spark:Hide() end

	element.holdTime = element.timeToHold or 0

	resetAttributes(element)
	element:SetValue(element.max)

	--[[ Callback: Castbar:PostCastFail(unit, spellID)
	Called after the element has been updated upon a failed spell cast.

	* self    - the Castbar widget
	* unit    - the unit for which the update has been triggered (string)
	* spellID - the ID of the spell (number)
	--]]
	if(element.PostCastFail) then
		return element:PostCastFail(unit, spellID)
	end
end

local function onUpdate(self, elapsed)
	if(self.casting or self.channeling) then
		local isCasting = self.casting
		if(isCasting) then
			self.duration = self.duration + elapsed
			if(self.duration >= self.max) then
				local spellID = self.spellID

				resetAttributes(self)
				self:Hide()

				if(self.PostCastStop) then
					self:PostCastStop(self.__owner.unit, spellID)
				end

				return
			end
		else
			self.duration = self.duration - elapsed
			if(self.duration <= 0) then
				local spellID = self.spellID

				resetAttributes(self)
				self:Hide()

				if(self.PostCastStop) then
					self:PostCastStop(self.__owner.unit, spellID)
				end

				return
			end
		end

		if(self.Time) then
			if(self.delay ~= 0) then
				if(self.CustomDelayText) then
					self:CustomDelayText(self.duration)
				else
					self.Time:SetFormattedText('%.1f|cffff0000%s%.2f|r', self.duration, isCasting and '+' or '-', self.delay)
				end
			else
				if(self.CustomTimeText) then
					self:CustomTimeText(self.duration)
				else
					self.Time:SetFormattedText('%.1f', self.duration)
				end
			end
		end

		self:SetValue(self.duration)
	elseif(self.holdTime > 0) then
		self.holdTime = self.holdTime - elapsed
	else
		resetAttributes(self)
		self:Hide()
	end
end

local function Update(...)
	CastStart(...)
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.Castbar
	if(element and unit and not unit:match('%wtarget$')) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if LibClassicCasterino then
			local CastbarEventHandler = function(event, ...)
				return EventFunctions[event](self, event, ...)
			end

			LibClassicCasterino.RegisterCallback(self, 'UNIT_SPELLCAST_START', CastbarEventHandler)
			LibClassicCasterino.RegisterCallback(self, 'UNIT_SPELLCAST_DELAYED', CastbarEventHandler)
			LibClassicCasterino.RegisterCallback(self, 'UNIT_SPELLCAST_STOP', CastbarEventHandler)
			LibClassicCasterino.RegisterCallback(self, 'UNIT_SPELLCAST_FAILED', CastbarEventHandler)
			LibClassicCasterino.RegisterCallback(self, 'UNIT_SPELLCAST_INTERRUPTED', CastbarEventHandler)
			LibClassicCasterino.RegisterCallback(self, 'UNIT_SPELLCAST_CHANNEL_START', CastbarEventHandler)
			LibClassicCasterino.RegisterCallback(self, 'UNIT_SPELLCAST_CHANNEL_UPDATE', CastbarEventHandler)
			LibClassicCasterino.RegisterCallback(self, 'UNIT_SPELLCAST_CHANNEL_STOP', CastbarEventHandler)
		else
			self:RegisterEvent('UNIT_SPELLCAST_START', CastStart)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START', CastStart)
			self:RegisterEvent('UNIT_SPELLCAST_STOP', CastStop)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', CastStop)
			self:RegisterEvent('UNIT_SPELLCAST_DELAYED', CastUpdate)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', CastUpdate)
			self:RegisterEvent('UNIT_SPELLCAST_FAILED', CastFail)
			self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED', CastFail)
		end
		-- ElvUI block
		self:RegisterEvent('UNIT_SPELLCAST_SENT', UNIT_SPELLCAST_SENT, true)
		-- end block

		element.holdTime = 0

		element:SetScript('OnUpdate', element.OnUpdate or onUpdate)

		if(self.unit == 'player' and not (self.hasChildren or self.isChild or self.isNamePlate)) then
			CastingBarFrame_SetUnit(CastingBarFrame, nil)
			CastingBarFrame_SetUnit(PetCastingBarFrame, nil)
		end

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		local spark = element.Spark
		if(spark and spark:IsObjectType('Texture') and not spark:GetTexture()) then
			spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
		end

		local shield = element.Shield
		if(shield and shield:IsObjectType('Texture') and not shield:GetTexture()) then
			shield:SetTexture([[Interface\CastingBar\UI-CastingBar-Small-Shield]])
		end

		local safeZone = element.SafeZone
		if(safeZone and safeZone:IsObjectType('Texture') and not safeZone:GetTexture()) then
			safeZone:SetColorTexture(1, 0, 0)
		end

		element:Hide()

		return true
	end
end

local function Disable(self)
	local element = self.Castbar
	if(element) then
		element:Hide()

		if LibClassicCasterino then
			LibClassicCasterino.UnregisterCallback(self, 'UNIT_SPELLCAST_START')
			LibClassicCasterino.UnregisterCallback(self, 'UNIT_SPELLCAST_DELAYED')
			LibClassicCasterino.UnregisterCallback(self, 'UNIT_SPELLCAST_STOP')
			LibClassicCasterino.UnregisterCallback(self, 'UNIT_SPELLCAST_FAILED')
			LibClassicCasterino.UnregisterCallback(self, 'UNIT_SPELLCAST_INTERRUPTED')
			LibClassicCasterino.UnregisterCallback(self, 'UNIT_SPELLCAST_CHANNEL_START')
			LibClassicCasterino.UnregisterCallback(self, 'UNIT_SPELLCAST_CHANNEL_UPDATE')
			LibClassicCasterino.UnregisterCallback(self, 'UNIT_SPELLCAST_CHANNEL_STOP')
		else
			self:UnregisterEvent('UNIT_SPELLCAST_START', CastStart)
			self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_START', CastStart)
			self:UnregisterEvent('UNIT_SPELLCAST_DELAYED', CastUpdate)
			self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', CastUpdate)
			self:UnregisterEvent('UNIT_SPELLCAST_STOP', CastStop)
			self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', CastStop)
			self:UnregisterEvent('UNIT_SPELLCAST_FAILED', CastFail)
			self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTED', CastFail)
		end

		element:SetScript('OnUpdate', nil)

		if(self.unit == 'player' and not (self.hasChildren or self.isChild or self.isNamePlate)) then
			CastingBarFrame_OnLoad(CastingBarFrame, 'player', true, false)
			PetCastingBarFrame_OnLoad(PetCastingBarFrame)
		end
	end
end

if LibClassicCasterino then
	UnitCastingInfo = function(unit)
		return LibClassicCasterino:UnitCastingInfo(unit)
	end

	UnitChannelInfo = function(unit)
		return LibClassicCasterino:UnitChannelInfo(unit)
	end

	EventFunctions["UNIT_SPELLCAST_START"] = CastStart
	EventFunctions["UNIT_SPELLCAST_FAILED"] = CastFail
	EventFunctions["UNIT_SPELLCAST_INTERRUPTED"] = CastFail
	EventFunctions["UNIT_SPELLCAST_DELAYED"] = CastUpdate
	EventFunctions["UNIT_SPELLCAST_STOP"] = CastStop
	EventFunctions["UNIT_SPELLCAST_CHANNEL_START"] = CastStart
	EventFunctions["UNIT_SPELLCAST_CHANNEL_UPDATE"] = CastUpdate
	EventFunctions["UNIT_SPELLCAST_CHANNEL_STOP"] = CastStop
end

oUF:AddElement('Castbar', Update, Enable, Disable)

local HonorTracker = select(2, ...)

local Display = HonorTracker:RegisterModule("Display")
local Tracking = HonorTracker:GetModule("Tracking")
local Stats = HonorTracker:GetModule("Stats")
local L = HonorTracker.L

local MAX_RANK_VALUE = {199, 210, 221, 233, 246, 260, 274, 288, 305, 321, 339, 357, 377, 398}
local honorChatFrameFilter

-- Cache a map of the rank name (localized) to the rank number
function Display:OnLoad()
	self.ranksMap = {}

	for i=5, 18 do
		local hordeName, rankNumber = GetPVPRankInfo(i, 0)
		self.ranksMap[hordeName] = rankNumber

		local allianceName, rankNumber = GetPVPRankInfo(i, 1)
		self.ranksMap[allianceName] = rankNumber
	end

	-- Inject our filter at the start to override what other addons are attempting to do.
	local filters = ChatFrame_GetMessageEventFilters("CHAT_MSG_COMBAT_HONOR_GAIN")
	if( not filters ) then
		ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_HONOR_GAIN", honorChatFrameFilter)
	else
		table.insert(filters, 1, honorChatFrameFilter)
	end
end

-- Replace DKs text with estimated honor 
hooksecurefunc("HonorFrame_Update", function(updateAll) Display:UpdatePVPFrame() end)
HonorFrame:SetScript("OnShow", function() Display:UpdatePVPFrame() end)

-- Add our tooltips
GameTooltip:HookScript("OnTooltipSetUnit", function(self, unit)
	if (not Display.db or not Display.db.config.tooltips) then return end

	local name, unit = self:GetUnit()
	if (not unit or not name) then return end

	if (UnitIsPlayer(unit) and UnitFactionGroup(unit) ~= UnitFactionGroup("player")) then
		local server = select(2, UnitName(unit))
		if( server ) then name = string.format("%s-%s", name, server) end

		local trackingData = Display.db.today.kills[name]
		if (not trackingData) then return end

		local killColor = "|cFFFF0000"
		if (trackingData.kills == 1) then
			killColor = "|cFF00FF00"
		elseif (trackingData.kills == 2) then
			killColor = "|cFFFFF468"
		elseif (trackingData.kills == 3) then
			killColor = "|cFFFF7C0A"
		elseif (trackingData.kills >= 4) then
			killColor = "|cFFFF0000"
		end

		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(string.format(L["|cFFFFFFFFKilled:|r %s%d|r |cFFFFFFFF(honor: %d)|r"], killColor, trackingData.kills, trackingData.honor))
		GameTooltip:Show()
	end
end)

-- Filter out HonorSpy spam
ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", function(chatFrame, event, text, ...)
	if( HonorTracker.db and HonorTracker.db.config.spam and string.match(text, L["- HonorSpy"]) ) then
		return true, text, ...
	end

	return false, text, ...
end)

-- Make honor gain messages useful
honorChatFrameFilter = function(chatFrame, event, text, ...)
	if( Display.db.config.batchHonor and Display.snapshottedHonor ) then
		return true, text, ...
	end

	local name, _other = string.split(" ", text, 2)

	local rank = string.match(text, L["honorable kill Rank: (.+) %("])
	name = Tracking:ConvertNameToQualified(name, rank)

	local estimateHonor = tonumber(string.match(text, L["Estimated Honor Points: (%d+)"]))
	if( estimateHonor ) then
		local actualHonor = math.ceil(Stats:CalculateModifiedHonor(name, estimateHonor) or 0)

		-- Only show contribution for people at 60, where we can calculate the maximum honor easily.
		local maximumHonor = rank and Display.ranksMap[rank] and MAX_RANK_VALUE[Display.ranksMap[rank]] or 0
		if( UnitLevel("player") == 60 and maximumHonor ) then
			-- Record rank worth to sort out if we have rounding errors somewhere
			if( Display.db.config.debugMode ) then
				Display.db.rankValue = Display.db.rankValue or {}
				if( math.abs(maximumHonor - estimateHonor) <= 10 ) then
					Display.db.rankValue[Display.ranksMap[rank]] = Display.db.rankValue[Display.ranksMap[rank]] or {}
					Display.db.rankValue[Display.ranksMap[rank]][estimateHonor] = true
				end
			end

			text = string.gsub(
				text,
				L["Estimated Honor Points: (%d+)"],
				string.format(
					L["Actual Honor: %d, Kills: %d, Share: %.1f%%"],
					actualHonor,
					(Display.db.today.kills[name] and Display.db.today.kills[name].kills or "??"),
					(estimateHonor / maximumHonor) * 100
				-- Due to weirdness with string.format, we need to double escape %% in the format then
				-- do another % to get it fully escaped through the gsub too.
				) .. "%"
			)

			-- Strip ".0" when reporting %.1f%%
			text = string.gsub(text, ".0%%%)", "%%%)")
		else
			text = string.gsub(
				text,
				L["Estimated Honor Points: (%d+)"],
				string.format(
					L["Actual Honor: %d, Kills: %d"],
					actualHonor,
					(Display.db.today.kills[name] and Display.db.today.kills[name].kills or "??")
				)
			)
		end
	end

	return false, text, ...
end

local function addColumnLine(line1, line2, color)
	color = color or HIGHLIGHT_FONT_COLOR
	GameTooltip:AddDoubleLine(line1, line2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, color.r, color.g, color.b)
end	

local function addSingleLine(line, color)
	color = color or NORMAL_FONT_COLOR
	GameTooltip:AddLine(line, color.r, color.g, color.b)
end

HonorFrameRankButton:SetScript("OnEnter", function(self)
	local rankName, rank = GetPVPRankInfo(UnitPVPRank("player"))
	local rankProgress = GetPVPRankProgress()
	local rankPoints = Stats:CalculatePlayerRankPoints()
	local decayRankPoints = math.ceil(rankPoints * 0.8)

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	addSingleLine(string.format(L["%s (Rank %d, %d%% in)"], rankName, rank, rankProgress * 100))
	addSingleLine(" ")
	addColumnLine(L["Rank Points:"], rankPoints)
	addColumnLine(L["Decayed Points:"], decayRankPoints)
	addColumnLine(L["Decayed Rank:"], Stats:RankPointsToRank(decayRankPoints))
	addSingleLine(" ")
	addSingleLine(L["Estimated Rank by Bracket"])

	for bracket=14, 1, -1 do
		local bracketPoints = 0
		if( bracket >= 3 ) then
			bracketPoints = ((bracket - 2) * 1000)
		elseif( bracket == 2 ) then
			bracketPoints = 400
		end

		local estRankPoints = decayRankPoints + bracketPoints
		local color = HIGHLIGHT_FONT_COLOR
		if( estRankPoints <= rankPoints ) then
			color = RED_FONT_COLOR
		elseif( (math.floor(estRankPoints / 5000) + 2) > rank ) then
			color = GREEN_FONT_COLOR
		end

		addColumnLine(string.format(L["Bracket %d:"], bracket), Stats:RankPointsToRank(estRankPoints), color)
	end

	GameTooltip:Show()
end)

function Display:SetupDailyTooltipData(overall, stats)
	addSingleLine(L["Overall"], HIGHLIGHT_FONT_COLOR)
	addColumnLine(L["Objective Honor:"], overall.honor.objectives)
	addColumnLine(L["Kill Honor:"], overall.honor.total - overall.honor.objectives)
	addColumnLine(L["Recorded Kills:"], string.format(L["%d (%.2f/kill)"], stats.recordedKills, stats.avgHonorPerKill))
	addColumnLine(L["Players Killed:"], string.format(L["%d (%.2f/kill)"], stats.uniquePlayers, stats.avgHonorPerPlayer))

	if( stats.battlegrounds ) then
		for name, bgStats in pairs(stats.battlegrounds) do
			if( name ~= "OVERALL" ) then
				addSingleLine(" ")
				addSingleLine(name, HIGHLIGHT_FONT_COLOR)
				addColumnLine(L["Games:"], string.format(L["%d (%.2f%% win rate)"], bgStats.total, bgStats.winPercent * 100))
				addColumnLine(L["Objective Honor:"], bgStats.honor.objectives)
				addColumnLine(L["Kill Honor:"], bgStats.honor.total - bgStats.honor.objectives)

				if( bgStats.totalRuntime ) then
					addColumnLine(L["Sum Duration:"], SecondsToTime(bgStats.totalRuntime))
				end
				addColumnLine(L["Avg Duration:"], SecondsToTime(bgStats.runtime))

				if( bgStats.totalQueueDuration and bgStats.totalQueueDuration > 0 ) then
					addColumnLine(L["Sum Queue:"], SecondsToTime(bgStats.totalQueueDuration))
				end
				if( bgStats.queueDuration and bgStats.queueDuration > 0 ) then
					addColumnLine(L["Avg Queue:"], SecondsToTime(bgStats.queueDuration))
				end
			end
		end
	end

	return text
end

function Display:SetupWeeklyTooltipData(stats)
	local firstRow = true
	for id, stats in pairs(stats) do
		if( not firstRow ) then
			addSingleLine(" ")
		end
		firstRow = false

		addSingleLine(date("%A", stats.time), HIGHLIGHT_FONT_COLOR)
		addColumnLine(L["Honor:"], stats.honor.actual)
		addColumnLine(L["Kills:"], stats.recordedKills)
	end
end

-- Today
HonorFrameCurrentDK:SetScript("OnEnter", function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	GameTooltip:ClearLines()
	GameTooltip:SetText(L["Today's Estimated Honor"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)

	if( not Display.db.today.honor or Display.db.today.honor.total == 0 ) then
		GameTooltip:AddLine(L["You must gain honor first for estimations."], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
	else
		Display:SetupDailyTooltipData(Display.db.today, Stats:CalculateToday())
	end

	GameTooltip:Show()
end)

-- Yesterday
HonorFrameYesterdayContribution:SetScript("OnEnter", function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	GameTooltip:ClearLines()
	GameTooltip:SetText(L["Yesterday's Estimated Honor"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)

	if( not Display.db.yesterday ) then
		GameTooltip:AddLine(L["Data available on the next daily honor reset."], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
	else
		Display:SetupDailyTooltipData(Display.db.yesterday, Display.db.yesterday.stats)
	end

	GameTooltip:Show()
end)

-- This Week
HonorFrameThisWeekContribution:SetScript("OnEnter", function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	GameTooltip:ClearLines()
	GameTooltip:SetText(L["This Weeks Daily Stats"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)

	if( #(Display.db.thisWeek) == 0 ) then
		GameTooltip:AddLine(L["Data available on the next daily honor reset."])
	else
		Display:SetupWeeklyTooltipData(Display.db.thisWeek)
	end

	GameTooltip:Show()
end)

-- Last Week
HonorFrameLastWeekContribution:SetScript("OnEnter", function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	GameTooltip:ClearLines()
	GameTooltip:SetText(L["Last Weeks Daily Stats"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)

	if( #(Display.db.lastWeek) == 0 ) then
		GameTooltip:AddLine(L["Data available on the next daily honor reset."])
	else
		Display:SetupWeeklyTooltipData(Display.db.lastWeek)
	end

	GameTooltip:Show()
end)

function Display:OnBattlefieldFinished(battlefield)
	-- We have a winner and so left the batltefield finished
	if( battlefield.winner ) then
		self:Print(
			string.format(
				L["Finished %s after %s (%s in queue), gaining %d honor, %d from objectives and %d from kills"],
				battlefield.map,
				HonorTracker:FormatPeriod(battlefield.runtime),
				battlefield.queueDuration and HonorTracker:FormatPeriod(battlefield.queueDuration) or "??",
				battlefield.honor.total,
				battlefield.honor.objectives,
				battlefield.honor.total - battlefield.honor.objectives
			)
		)
	-- We left by getting AFK'd out
	else
		self:Print(
			string.format(
				L["Left %s after %s (%s in queue), gaining %d honor, %d from objectives and %d from kills"],
				battlefield.map,
				HonorTracker:FormatPeriod(battlefield.runtime),
				battlefield.queueDuration and HonorTracker:FormatPeriod(battlefield.queueDuration) or "??",
				battlefield.honor.total,
				battlefield.honor.objectives,
				battlefield.honor.total - battlefield.honor.objectives
			)
		)
	end
end

Display.OnHonor = Display.UpdatePVPFrame

-- Reworking the main honor page
function Display:UpdatePVPFrame()
	if( not HonorFrameCurrentDKValue:IsVisible() ) then return end

	-- Today
	HonorFrameCurrentDKText:SetText(L["Estimated Honor"])
	HonorFrameCurrentDKValue:SetText(self.db.today.honor.total)
	HonorFrameCurrentDKValue:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
end

-- Batching honor messages together
function Display:PLAYER_REGEN_DISABLED()
	if( not self.db.config.batchHonor ) then return end

	local kills = 0
	for _, data in pairs(self.db.today.kills) do
		kills = kills + data.kills
	end

	self.snapshottedHonor = {
		objectives = self.db.today.honor.objectives,
		total = self.db.today.honor.total,
		kills = kills
	}
end

function Display:PLAYER_REGEN_ENABLED()
	if( not self.db.config.batchHonor or not self.snapshottedHonor ) then return end

	local kills = 0
	for _, data in pairs(self.db.today.kills) do
		kills = kills + data.kills
	end

	local gained = {
		objectives = self.db.today.honor.objectives - self.snapshottedHonor.objectives,
		total = self.db.today.honor.total - self.snapshottedHonor.total,
		kills = kills - self.snapshottedHonor.kills,
	}
	self.snapshottedHonor = nil

	for i=1, NUM_CHAT_WINDOWS do
		local chatFrame = Chat_GetChatFrame(i)
		if( ChatFrame_ContainsMessageGroup(chatFrame, "COMBAT_HONOR_GAIN") ) then
			local color = ChatTypeInfo["COMBAT_HONOR_GAIN"]

			if( gained.kills == 0 and gained.total == gained.objectives ) then
				chatFrame:AddMessage(
					string.format(L["Gained %d honor from objectives, no kills made."], gained.objectives),
					color.r,
					color.g,
					color.b
				)
			else
				chatFrame:AddMessage(
					string.format(L["Killed %d |4player:players;, gaining %d honor from kills and %d honor from objectives."], gained.kills, gained.total - gained.objectives, gained.objectives),
					color.r,
					color.g,
					color.b
				)
			end
		end
	end
end

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, ...)
	if( Display[event] ) then
		Display[event](Display, ...)
	end
end)

eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

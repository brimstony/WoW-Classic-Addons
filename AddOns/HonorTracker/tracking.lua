local HonorTracker = select(2, ...)

local Tracking = HonorTracker:RegisterModule("Tracking")
Tracking.serverMapping = {}

local ResetTime = HonorTracker:GetModule("ResetTime")
local Stats = HonorTracker:GetModule("Stats")
local L = HonorTracker.L

function Tracking:ConvertNameToQualified(name, rank)
	if( not self.serverMapping or not rank ) then return name end

	local fullName = self.serverMapping[name .. rank]
	return fullName or name
end

function Tracking:CHAT_MSG_COMBAT_HONOR_GAIN(text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, chanenlIndex, channelBaseName, unused, lineID, guid, bnSenderID, isMobile, isSubtitel, hideSenderInLetterbox, suppressRaidIcons)
	local directHonor = tonumber(string.match(text, L["been awarded (%d+) honor points"]))
	if( directHonor and directHonor > 0 ) then
		self.db.today.honor.objectives = (self.db.today.honor.objectives or 0) + directHonor
		self.db.today.honor.total = (self.db.today.honor.total or 0) + directHonor

		if( self.activeBattlefield ) then
			self.activeBattlefield.honor.total = self.activeBattlefield.honor.total + directHonor
			self.activeBattlefield.honor.objectives = self.activeBattlefield.honor.objectives + directHonor
		end

		HonorTracker:Trigger("OnHonor")
		return
	end

	local name, _other = string.split(" ", text, 2)
	name = self:ConvertNameToQualified(name, string.match(text, L["honorable kill Rank: (.+) %("]))

	self.db.today.kills[name] = self.db.today.kills[name] or {kills = 0, honor = 0}
	self.db.today.kills[name].kills = self.db.today.kills[name].kills + 1

	local honor = tonumber(string.match(text, L["Estimated Honor Points: (%d+)"]))
	local actualHonor = Stats:CalculateModifiedHonor(name, honor)

	self.db.today.honor.total = (self.db.today.honor.total or 0) + actualHonor
	self.db.today.kills[name].honor = self.db.today.kills[name].honor + actualHonor

	if( self.activeBattlefield ) then
		self.activeBattlefield.honor.total = self.activeBattlefield.honor.total + actualHonor
	end

	HonorTracker:Trigger("OnHonor", name)
end

function Tracking:CheckDayChange()
	local stateTags = {
		yesterday = string.join(", ", GetPVPYesterdayStats()),
		thisWeek = string.join(", ", GetPVPThisWeekStats()),
		lastWeek = string.join(", ", GetPVPLastWeekStats()),
	}

	-- By default, we attempt to hinge off of yesterday/last week stats.
	-- If we've gained no honor though, then will do it off of the timings since we can't detect
	-- a standing change otherwise.

	-- Check for daily reset
	local yesterdayHonor = select(3, GetPVPYesterdayStats())
	if( ( self.db.stateTags.yesterday and self.db.stateTags.yesterday ~= stateTags.yesterday )
		or ( yesterdayHonor == 0 and self.db.resetTime.dailyStart ~= ResetTime:DailyWindow(true) )
	) then
		-- Record our daily stats
		local stats = Stats:CalculateToday()
		stats.time = self.db.resetTime.dailyStart
		stats.honor = CopyTable(self.db.today)
		stats.honor.actual = yesterdayHonor
		table.insert(self.db.thisWeek, stats)

		-- Reset our stats for today
		self.db.yesterday = CopyTable(self.db.today)
		self.db.yesterday.stats = Stats:CalculateToday()
		self.db.today = {}

		self.db.resetTime.dailyStart, self.db.resetTime.dailyEnd = ResetTime:DailyWindow(true)
		self.db.resetTime.warnedToday = nil

		HonorTracker:CheckDB()
		HonorTracker:Trigger("OnDailyReset")
	end

	-- Check for weekly reset
	local lastWeekHonor = select(3, GetPVPLastWeekStats())
	if( ( self.db.stateTags.lastWeek and self.db.stateTags.lastWeek ~= stateTags.lastWeek )
		or ( lastWeekHonor == 0 and self.db.resetTime.weeklyStart ~= ResetTime:WeeklyWindow(true) ) 
	) then
		self.db.lastWeek = CopyTable(self.db.thisWeek)
		self.db.thisWeek = {}

		self.db.rankPoints.lastWeek = self.db.rankPoints.thisWeek
		self.db.rankPoints.thisWeek = Stats:CalculatePlayerRankPoints()

		self.db.resetTime.weeklyStart, self.db.resetTime.weeklyEnd = ResetTime:WeeklyWindow(true)
		self.db.resetTime.warnedToday = nil

		HonorTracker:CheckDB()
		HonorTracker:Trigger("OnWeeklyReset")
	end

	self.db.stateTags = stateTags
end

function Tracking:CacheServerMapping()
	if( not InActiveBattlefield() ) then
		self.serverMapping = {}
		return
	end

	-- 1 is Alliance and 0 is Horde
	local otherFaction
	if( UnitFactionGroup("player") == "Horde" ) then
		otherFaction = 1
	else
		otherFaction = 0
	end

	self.serverMapping = {}
	for i=1, GetNumBattlefieldScores() do
		local name, _, _, _, _, faction, rank = GetBattlefieldScore(i);
		if( faction == otherFaction ) then
			local nameWithoutServer, server = string.split("-", name, 2)
			if( server and server ~= "" ) then
				-- Everyone without a rank defaults to #5 as far as the honorable kill message is concerned
				local rankName = GetPVPRankInfo(rank, faction) or GetPVPRankInfo(5, faction)
				self.serverMapping[nameWithoutServer .. rankName] = name
			end
		end
	end
end

function Tracking:UPDATE_BATTLEFIELD_STATUS()
	self.enteredQueueAt = self.enteredQueueAt or {}

	local hasActive = false
	for i=1, MAX_BATTLEFIELD_QUEUES do
		local status, map, instanceID, isRegistered, suspendedQueue, queueType, gameType, role = GetBattlefieldStatus(i)
		if( status == "active" ) then
			hasActive = true

			if( self.activeBattlefieldID ~= instanceID ) then
				self.activeBattlefieldMap = map
				self.activeBattlefieldID = instanceID

				if( self.enteredQueueAt[i] ) then
					self.activeBattlefieldQueueDuration = GetServerTime() - self.enteredQueueAt[i]
				end

				self:Debug(3, "Entered %s (instance ID %d), spent %s seconds in queue", map, instanceID, self.activeBattlefieldQueueDuration or -1)
			end

		elseif( status == "queued" ) then
			self.enteredQueueAt[i] = GetServerTime() - math.floor(GetBattlefieldTimeWaited(i) / 1000)
		-- Once we hit confirm, the GetBattlefieldTimeWaited value turns into the time left to join
		-- so we need to only reset it once we're in "none".
		elseif( status ~= "confirm" ) then
			self.enteredQueueAt[i] = nil
		end
	end

	-- Active battlefield but no active one created yet
	if( not self.activeBattlefield and self.activeBattlefieldID ) then
		-- Find an active battlefield to restore data for
		for _, data in pairs(self.db.today.battlegrounds) do
			if( not data.finished ) then
				-- Found an existing one
				if( data.map == self.activeBattlefieldMap and data.instanceID == self.activeBattlefieldID ) then
					self.activeBattlefield = data
				-- Bugged or we AFKed out by logging out. We have data, but no idea what happened
				elseif( data.instanceID ) then
					data.partial = true
					-- Don't persist runtime since it will be inaccurate
					data.started = nil

					self:FinishUpBattlefield(data)
				end
			end
		end

		-- Didn't find an existing one to restore
		if( not self.activeBattlefield ) then
			self.activeBattlefield = {
				map = self.activeBattlefieldMap,
				instanceID = self.activeBattlefieldID,
				queueDuration = self.activeBattlefieldQueueDuration,
				started = GetServerTime(),
				honor = {
					total = 0,
					objectives = 0
				}
			}

			table.insert(self.db.today.battlegrounds, self.activeBattlefield)
		end
	end
	
	if( self.activeBattlefield and (self.activeBattlefield.started or self.activeBattlefield.runtime) and not hasActive ) then
		-- We left by getting AFK'd out
		if( not self.activeBattlefield.winner ) then
			self:FinishUpBattlefield(self.activeBattlefield)
			self.activeBattlefield.partial = true
		end

		HonorTracker:Trigger("OnBattlefieldFinished", self.activeBattlefield)
		self.activeBattlefield = nil
	end

	-- We're done with our battlefield
	if( not hasActive ) then
		self.activeBattlefieldMap = nil
		self.activeBattlefieldID = nil
	end
end

function Tracking:PLAYER_ENTERING_WORLD()
	HonorTracker:CheckDB()

	self:CacheServerMapping()
	self:CheckDayChange()
	self:CheckForResetWarning()
end

function Tracking:CheckForResetWarning()
	-- Don't bother warning if there was no PVPing done
	if( GetPVPThisWeekStats() == 0 or GetPVPSessionStats() == 0 ) then
		return
	-- Already bugged people
	elseif( self.db.resetTime.warnedToday ) then
		return
	-- We believe the day has reset
	elseif( GetServerTime() >= self.db.resetTime.dailyEnd ) then
		self.eventFrame:SetScript("OnUpdate", nil)
		self.db.resetTime.warnedToday = true

		self:Print(L["Warning! We believe honor has reset for the day. We recommend logging in/out to ensure your estimates are accurate."])
		self:Print(string.format(L["If this is incorrect, post on CurseForge with '%s UTC' as the date we thought a reset happened, and what you believe the proper one is."], date("!%x %X", self.db.resetTime.dailyEnd)))
		return
	end

	-- Once we're within 2 hours of the reset, we will monitor for it resetting to show the warning properly.
	local timeLeft = (self.db.resetTime.dailyEnd - GetServerTime())
	if( timeLeft >= 7200 ) then return end

	self.eventFrame:SetScript("OnUpdate", function(self, elapsed)
		timeLeft = timeLeft - elapsed
		if( timeLeft >= 0 ) then return end

		Tracking:CheckForResetWarning()
	end)
end

function Tracking:UPDATE_BATTLEFIELD_SCORE()
	self:CacheServerMapping()
		
	-- Ordering is a bit weird here, and we actually update winner here
	-- and then output once we get kicked out based on queue state
	if( self.activeBattlefield and GetBattlefieldWinner() ) then
		self:FinishUpBattlefield(self.activeBattlefield)

		if( GetBattlefieldWinner() == 0 ) then
			self.activeBattlefield.winner = "Horde"
		else
			self.activeBattlefield.winner = "Alliance"
		end
	end
end

function Tracking:FinishUpBattlefield(battlefield)
	if( battlefield.started ) then
		battlefield.runtime = GetServerTime() - battlefield.started
	elseif( not battlefield.runtime ) then
		battlefield.runtime = 0
	end

	battlefield.instanceID = nil
	battlefield.started = nil
	battlefield.finished = true
end

Tracking.PLAYER_ENTERING_BATTLEGROUND = Tracking.CacheServerMapping

-- Event handler
local eventFrame = CreateFrame("Frame")
Tracking.eventFrame = eventFrame

eventFrame:SetScript("OnEvent", function(self, event, ...)
	if( Tracking[event] ) then
		Tracking[event](Tracking, ...)
	end

	if( event == "CHAT_MSG_COMBAT_HONOR_GAIN" or event == "PLAYER_PVP_KILLS_CHANGED" or event == "PLAYER_PVP_RANK_CHANGED" or event == "PLAYER_ENTERING_WORLD" ) then
		Tracking:CheckDayChange()
	end
end)

eventFrame:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
eventFrame:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
eventFrame:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")
eventFrame:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
eventFrame:RegisterEvent("PLAYER_PVP_RANK_CHANGED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")

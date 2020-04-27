HonorTracker = select(2, ...)
HonorTracker.modules = {}
HonorTracker.moduleList = {}

local L = HonorTracker.L

function HonorTracker:Trigger(name, ...)
	for _, obj in pairs(self.moduleList) do
		if( obj[name] ) then
			obj[name](obj, ...)
		end
	end
end

function HonorTracker:RegisterModule(name)
	assert(not self.modules[name], string.format("Module '%s' already registered", name))

	local obj = {
		Print = self.Print,
		Debug = self.Debug,
		DedupDebug = self.DedupDebug,
	}

	table.insert(self.moduleList, obj)
	self.modules[name] = obj

	return obj
end

function HonorTracker:GetModule(name)
	assert(self.modules[name], string.format("Cannot find module '%s'", name))
	return self.modules[name]
end

function HonorTracker:FormatPeriod(seconds)
	if( seconds >= 86400 ) then
		local days = math.ceil(seconds / 86400)
		return string.format(hours == 1 and L["%d day"] or L["%d days"], days)
	elseif( seconds >= 3600 ) then
		local hours = math.ceil(seconds / 3600)
		return string.format(hours == 1 and L["%d hour"] or L["%d hours"], hours)
	elseif( seconds >= 60 ) then
		local minutes = math.ceil(seconds / 60)
		return string.format(minutes == 1 and L["%d min"] or L["%d mins"], minutes)
	end

	return string.format(seconds == 1 and L["%d sec"] or L["%d secs"], seconds)
end

function HonorTracker:Percentile(percentile)
	if( percentile == 0 ) then
		return tostring(percentile)
	elseif( percentile == 1 ) then
		return string.format(L["%dst"], percentile)
	elseif( percentile == 2 ) then
		return string.format(L["%dnd"], percentile)
	elseif( percentile == 3 ) then
		return string.format(L["%drd"], percentile)
	else
		return string.format(L["%dth"], percentile)
	end
end

function HonorTracker:Print(msg, skipPrefix)
	if( skipPrefix ) then
		DEFAULT_CHAT_FRAME:AddMessage(msg)
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99Honor Tracker|r: " .. msg)
	end
end

function HonorTracker:Debug(level, msg, ...)
	if( not self.db.config.debugMode ) then return end
	if( level > HonorTracker.db.config.debugMode ) then return end
	
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99HT Debug|r: " .. string.format(msg, ...))
end

function HonorTracker:DedupDebug(level, msg, ...)
	if( not self.db.config.debugMode ) then return end
	if( level > HonorTracker.db.config.debugMode ) then return end

	self.dedupedMessages = self.dedupedMessages or {}

	msg = string.format(msg, ...)
	if( self.dedupedMessages[msg] ) then return end
	self.dedupedMessages[msg] = true

	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99HT Debug|r: " .. msg)
end

function HonorTracker:CheckDB()
	HonorTrackerDB = HonorTrackerDB or {}
	HonorTrackerGlobalDB = HonorTrackerGlobalDB or {}

	-- Global DB
	self.globalDB = HonorTrackerGlobalDB
	
	self.globalDB.brackets = self.globalDB.brackets or {}
	self.globalDB.brackets[GetRealmName()] = self.globalDB.brackets[GetRealmName()] or {}
	self.realmBracketDB = self.globalDB.brackets[GetRealmName()]

	self.globalDB.brackets[GetRealmName()].lastWeek = self.globalDB.brackets[GetRealmName()].lastWeek or {}

	self.globalDB.brackets[GetRealmName()].players = self.globalDB.brackets[GetRealmName()].players or {}
	self.globalDB.brackets[GetRealmName()].playersMeta = self.globalDB.brackets[GetRealmName()].playersMeta or {}
	self.globalDB.brackets[GetRealmName()].senderBlacklist = self.globalDB.brackets[GetRealmName()].senderBlacklist or {}
	self.globalDB.brackets[GetRealmName()].bootstrapIgnored = self.globalDB.brackets[GetRealmName()].bootstrapIgnored or {}
	self.globalDB.brackets[GetRealmName()].bootstrapThrottled = self.globalDB.brackets[GetRealmName()].bootstrapThrottled or {}

	-- Local per character DB
	local Stats = self:GetModule("Stats")

	self.db = HonorTrackerDB
	self.db.config = self.db.config or {tooltips = true, spam = true, internalComms = false, batchHonor = false} 
	self.db.config.minimap = self.db.config.minimap or {}
	
	self.db.stateTags = self.db.stateTags or {}

	-- Save initial reset time or force a new version in cases where we're fixing bugs
	local ResetTime = self:GetModule("ResetTime")
	if( not self.db.resetTime or self.db.resetTime.version ~= ResetTime.VERSION ) then
		local dailyStart, dailyEnd = ResetTime:DailyWindow(true)
		local weeklyStart, weeklyEnd = ResetTime:WeeklyWindow(true)

		self.db.resetTime = {
			dailyStart = dailyStart,
			dailyEnd = dailyEnd,
			weeklyStart = weeklyStart,
			weeklyEnd = weeklyEnd,
			version = ResetTime.VERSION
		}
	end

	if( self.db.config.spam == nil ) then
		self.db.config.spam = true
	end

	if( type(self.db.today) == "number" ) then self.db.today = nil end
	self.db.today = self.db.today or {}
	self.db.today.start = self.db.today.start or GetServerTime()
	self.db.today.honor = self.db.today.honor or {total = 0, objectives = 0}
	self.db.today.kills = self.db.today.kills or {}
	self.db.today.battlegrounds = self.db.today.battlegrounds or {}

	self.db.rankPoints = self.db.rankPoints or {}
	self.db.rankPoints.thisWeek = self.db.rankPoints.thisWeek or Stats:CalculatePlayerRankPoints()

	self.db.thisWeek = self.db.thisWeek or {}
	self.db.lastWeek = self.db.lastWeek or {}

	-- Convert from our old DB format ot the new one
	if( self.db.tracking ) then
		self.db.today.honor.total = self.db.tracking.today
		self.db.today.honor.objectives = self.db.tracking.todayObjectives
		self.db.today.kills = self.db.tracking.players

		if( self.db.tracking.yesterdayData ) then
			self.db.yesterday = {
				honor = {
					total = self.db.tracking.yesterdayData.honor,
					objectives = self.db.tracking.yesterdayData.honorObjectives,
					actual = self.db.tracking.yesterdayData.honor
				},
				stats = self.db.tracking.yesterdayData.stats,
			}
		end

		if( self.db.tracking.yesterday ) then
			self.db.stateTags.yesterday = self.db.tracking.yesterday
			self.db.stateTags.lastWeek = self.db.tracking.lastWeek
		end

		if( self.db.tracking.lastWeekRankPoints ) then
			self.db.rankPoints.lastWeek = self.db.tracking.lastWeekRankPoints
		end
		
		-- Copy this weeks data to the new format
		if( self.db.tracking.thisWeekStats ) then
			self.db.thisWeek = {}
			for _, stats in pairs(self.db.tracking.thisWeekStats) do
				local newStats = CopyTable(stats)
				newStats.honor = {
					total = stats.estimatedHonor,
					objectives = stats.estimatedObjectHonor,
					actual = stats.actualHonor
				}
				
				newStats.estimatedHonor = nil
				newStats.estimatedObjectHonor = nil
				newStats.actualHonor = nil

				table.insert(self.db.thisWeek, newStats)
			end
		end

		if( self.db.tracking.lastWeeksStats ) then
			self.db.lastWeek = {}
			for _, stats in pairs(self.db.tracking.lastWeeksStats) do
				local newStats = CopyTable(stats)
				newStats.honor = {
					total = stats.estimatedHonor,
					objectives = stats.estimatedObjectHonor,
					actual = stats.actualHonor
				}
				
				newStats.estimatedHonor = nil
				newStats.estimatedObjectHonor = nil
				newStats.actualHonor = nil

				table.insert(self.db.lastWeek, newStats)
			end
		end

		-- Converted successfully
		self.db.tracking = nil
	end

	-- Convert from inline meta to separate
	for name, data in pairs(self.globalDB.brackets[GetRealmName()].players) do
		if( not self.globalDB.brackets[GetRealmName()].playersMeta[name] ) then
			local metadata = {}
			metadata.seenToday = data.seenToday
			metadata.lastSent = data.lastSent

			data.seenToday = nil
			data.lastSent = nil

			self.globalDB.brackets[GetRealmName()].playersMeta[name] = metadata
		end
	end

	for _, obj in pairs(HonorTracker.moduleList) do
		obj.db = HonorTrackerDB
		obj.globalDB = HonorTrackerGlobalDB
		obj.realmBracketDB = self.globalDB.brackets[GetRealmName()]
	end
end

-- Associate the DB for all of our modules
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("VARIABLES_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, ...)
	if( event == "VARIABLES_LOADED" ) then
		if( #(HonorTracker.moduleList) == 0 ) then
			HonorTracker:Print(L["WARNING! You need to restart WoW to pick up changes for HonorTracker to work properly."])
			return
		end

		-- If we're already logged in, wait for VARIABLES_LOADED to ensure our modules can register themselves.
		HonorTracker:CheckDB()
		HonorTracker:Trigger("OnLoad")
	end
end)

local HonorTracker = select(2, ...)
local Stats = HonorTracker:RegisterModule("Stats")
local L = HonorTracker.L

-- Figure out how much actual honor we got from someone
function Stats:CalculateModifiedHonor(name, honor)
	local killsLeft = 11 - (self.db.today.kills[name] and self.db.today.kills[name].kills or 0)
	if( killsLeft >= 10 ) then
		return honor
	elseif( killsLeft <= 0 ) then
		return 0
	end

	local diminish = killsLeft * 0.1
	return math.floor((honor * diminish) + 0.5)
end

-- Calculate their actual rank off of the points
function Stats:RankPointsToRank(rankPoints)
	if( rankPoints < 2000 ) then
		local progress = rankPoints / 2000
		return string.format(L["Rank %d (%d%% in)"], 1, math.floor(progress * 100))
	elseif( rankPoints < 5000 ) then
		local progress = (rankPoints - 2000) / 3000
		return string.format(L["Rank %d (%d%% in)"], 2, math.floor(progress * 100))
	elseif( rankPoints >= 60000 ) then
		return string.format(L["Rank 14"])
	end

	local rank = math.floor(rankPoints / 5000)
	local progress = math.floor(((rankPoints - rank * 5000) / 5000) * 100)
	return string.format(L["Rank %d (%d%% in)"], rank + 2, progress)
end

-- Calculate a players rank points
function Stats:CalculatePlayerRankPoints()
	local rankName, rank = GetPVPRankInfo(UnitPVPRank("player"))
	local rankProgress = GetPVPRankProgress()
	return self:CalculateRankPoints(rank, rankProgress)
end

function Stats:CalculateRankPoints(rank, rankProgress)
	-- Rank 1 requires 15 HK, Rank 2 requires 2000 RP, and then 5000 after
	local rankPoints = 0
	if( rank >= 3 ) then
		rankPoints = math.ceil(((rank - 2) * 5000) + (rankProgress * 5000))
	elseif( rank == 2 ) then
		rankPoints = math.ceil((rankProgress * 3000) + 2000)
	elseif( rank == 1 ) then
		rankPoints = math.ceil((rankProgress * 2000))
	end

	return rankPoints
end

-- Show daily reset messages
function Stats:OnDailyReset()
	local actualHonor = select(3, GetPVPYesterdayStats())
	-- Don't show anything if we didn't PVP
	if( actualHonor == 0 ) then return end

	local offBy
	if( actualHonor > self.db.yesterday.honor.total ) then
		offBy = self.db.yesterday.honor.total / actualHonor
	else
		offBy = actualHonor / self.db.yesterday.honor.total
	end

	self:Print(
		string.format(
			L["Estimated Honor: %d, Actual: %d, Off By: %.2f%%"],
			self.db.yesterday.honor.total,
			actualHonor,
			(1 - offBy) * 100
		)
	)

	local stats = self.db.yesterday.stats
	self:Print(
		string.format(L["Recorded %d kills (avg %.2f honor per kill) across %d players (%.2f honor per player)"],
			stats.recordedKills,
			stats.avgHonorPerKill,
			stats.uniquePlayers,
			stats.avgHonorPerPlayer
		)
	)
end

function Stats:CalculateBracketFromGain(rankPoints)
	local bracket, bracketPercentile
	if( rankPoints <= 400 ) then
		bracket = 2
		bracketPercentile = math.floor(((rankPoints / 400) + 0.5) * 100)
	else
		bracket = math.floor(rankPoints / 1000) + 2
		bracketPercentile = math.floor(((rankPoints % 1000) / 999) * 100)
	end

	return bracket, bracketPercentile
end

-- Show weekly reset messages
function Stats:OnWeeklyReset()
	self:DumpWeeklyBracket(
		self.db.rankPoints.thisWeek,
		math.ceil((self.db.rankPoints.lastWeek or 0) * 0.8)
	)
end

function Stats:DumpDailySummary(stats)
	for id, stats in pairs(stats) do
		DEFAULT_CHAT_FRAME:AddMessage(
			string.format(
				L["|cFFFFF468%s:|r %d honor (%d estimated), %d kills (avg %.2f honor/kill), %d players (%.2f honor/player)"],
				date("%A", stats.time),
				stats.honor.actual,
				stats.honor.total,
				stats.recordedKills,
				stats.avgHonorPerKill,
				stats.uniquePlayers,
				stats.avgHonorPerPlayer
			)
		)
	end
end

function Stats:DumpWeeklyBracket(thisWeek, lastWeek)
	if( thisWeek < lastWeek ) then
		self:Print(string.format(L["Lost %d rank points, decayed to %s this week."], (lastWeek - thisWeek), self:RankPointsToRank(thisWeek)))
		return
	end

	local diff = thisWeek - lastWeek
	local bracket, bracketPercentile = self:CalculateBracketFromGain(diff)

	self:Print(
		string.format(
			L["Gained %d rank points, %s percentile of bracket %d, now %s."],
			diff,
			HonorTracker:Percentile(bracketPercentile),
			bracket,
			self:RankPointsToRank(thisWeek)
		)
	)
end

function Stats:DumpStanding(name)
	if( name == "%t" ) then
		if( not UnitExists("target") ) then
			HonorTracker:Print(L["You do not have a target."])
			return
		end

		name = UnitName("target")
	elseif( not name or name == "" ) then
        name = UnitName("player")
	end
	
	if( UnitExists(name) and UnitRealmRelationship(name) ~= 1 ) then
		HonorTracker:Print(L["You cannot view data for %s, since they are on a different realm."])
		return
	end

    local sumAges = 0
	local totalPlayers = 0
	local foundName = nil
    for checkName, checkData in pairs(self.realmBracketDB.players) do
        sumAges = sumAges + (GetServerTime() - checkData.lastChecked)
		totalPlayers = totalPlayers + 1
		
		if( string.lower(checkName) == string.lower(name) ) then
			foundName = checkName
		end
    end

    if( totalPlayers == 0 ) then
        HonorTracker:Print(L["No data found yet. If the week just reset, you need to wait until other players start logging in."])
		return
	elseif( not foundName ) then
		HonorTracker:Print(string.format(L["|cff33ff99%s|r: Cannot find any data"], name), true)
		return
    end

    local estimate = HonorTracker:GetModule("Brackets"):Estimate(foundName)
	if( not estimate ) then
		HonorTracker:Print(string.format(L["|cff33ff99%s|r: Cannot find any data"], foundName), true)
		return
	end

	local existingData = self.realmBracketDB.players[foundName]
	HonorTracker:Print(
		string.format(
			L["|cff33ff99%s|r: Estimated standing %d (bracket %d), going from %s -> %s, pool size %d |4player:players;."],
			foundName,
			estimate.standing,
			estimate.bracket,
			Stats:RankPointsToRank(existingData.rankPoints),
			Stats:RankPointsToRank(estimate.rankPoints),
			totalPlayers
		),
		true
	)
end

function Stats:CalculateToday()
	local stats = {
		recordedKills = 0,
		uniquePlayers = 0,
		avgKillsPerPlayer = 0,
		avgHonorPerPlayer = 0,
		avgHonorPerKill = 0
	}

	for name, data in pairs(self.db.today.kills) do
		stats.uniquePlayers = stats.uniquePlayers + 1
		stats.recordedKills = stats.recordedKills + data.kills
	end

	if( stats.recordedKills > 0 ) then
		stats.avgKillsPerPlayer = math.floor((stats.recordedKills / stats.uniquePlayers) * 100) / 100
	end

	if( self.db.today.honor.total and self.db.today.honor.objectives ) then
		local todayHonor = self.db.today.honor.total - self.db.today.honor.objectives
		if( todayHonor > 0 ) then
			stats.avgHonorPerKill = math.floor((todayHonor / stats.recordedKills) * 100) / 100
			stats.avgHonorPerPlayer = math.floor((todayHonor / stats.uniquePlayers) * 100) / 100
		end
	end

	if( #(self.db.today.battlegrounds) > 0 ) then
		stats.battlegrounds = {}

		local finishedGame = false

		local playerFaction = UnitFactionGroup("player")
		for _, data in pairs(self.db.today.battlegrounds) do
			if( data.finished ) then
				finishedGame = true

				stats.battlegrounds[data.map] = stats.battlegrounds[data.map] or {
					total = 0,
					wins = 0,
					runtime = 0,
					queueDuration = 0,
					honor = {
						total = 0,
						objectives = 0
					}
				}
				
				local bgStats = stats.battlegrounds[data.map]
				bgStats.honor.total = bgStats.honor.total + data.honor.total
				bgStats.honor.objectives = bgStats.honor.objectives + data.honor.objectives

				bgStats.runtime = bgStats.runtime + (data.runtime or 0)
				bgStats.queueDuration = bgStats.queueDuration + (data.queueDuration or 0)

				bgStats.total = bgStats.total + 1
				if( data.winner == playerFaction ) then
					bgStats.wins = bgStats.wins + 1
				end
			end
		end

		local overall = {total = 0, wins = 0, runtime = 0, queueDuration = 0, honor = {total = 0, objectives = 0}}
		for _, bgStats in pairs(stats.battlegrounds) do
			overall.total = overall.total + bgStats.total
			overall.wins = overall.wins + bgStats.wins
			overall.runtime = overall.runtime + bgStats.runtime
			overall.queueDuration = overall.queueDuration + (bgStats.queueDuration or 0)

			overall.honor.total = overall.honor.total + bgStats.honor.total
			overall.honor.objectives = overall.honor.objectives + bgStats.honor.objectives
		end

		stats.battlegrounds.OVERALL = overall

		for _, bgStats in pairs(stats.battlegrounds) do
			bgStats.winPercent = (bgStats.wins > 0) and (bgStats.wins / bgStats.total) or 0

			bgStats.totalRuntime = bgStats.runtime
			bgStats.totalQueueDuration = bgStats.queueDuration

			bgStats.runtime = math.floor((bgStats.runtime / bgStats.total) + 0.5)
			bgStats.queueDuration = math.floor((bgStats.queueDuration / bgStats.total) + 0.5)

			bgStats.avgHonor = {
				total = math.floor((bgStats.honor.total / bgStats.total) + 0.5),
				objectives = math.floor((bgStats.honor.objectives / bgStats.total) + 0.5)
			}
		end

		if( not finishedGame ) then
			stats.battlegrounds = nil
		end
	end

	return stats
end

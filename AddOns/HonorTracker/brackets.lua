local HonorTracker = select(2, ...)
local Brackets = HonorTracker:RegisterModule("Brackets")
local Stats = HonorTracker:GetModule("Stats")
local Comms = HonorTracker:GetModule("Comms")
local L = HonorTracker.L
local alreadyScanned = {}
local PLAYER_NAME = UnitName("player")
local MAX_BOOTSTRAP_REQUEST_TIME = 3600 * 3

Brackets.bracketToPoints = {0, 400} -- Rank points for each bracket
Brackets.pointsToRanks = {0, 2000} -- Rank points for each rank
Brackets.lastSeenInspect = {}

for i=3, 14 do
    Brackets.bracketToPoints[i] = (i - 2) * 1000
    Brackets.pointsToRanks[i] = (i - 2) * 5000
end

function Brackets:OnLoad()
    self:RefreshPlayerData()
    self:ConvertFromHonorSpy()
end

function Brackets:OnWeeklyReset()
    self.realmBracketDB.lastWeek.players = CopyTable(self.realmBracketDB.players)
    self.realmBracketDB.lastWeek.playersMeta = CopyTable(self.realmBracketDB.playersMeta)

    self.realmBracketDB.players = {}
    self.realmBracketDB.playersMeta = {}

    -- Prevent us from syncing or receiving bugged data for one day.
    -- since everyone should have no relevant data to sync.
    self.realmBracketDB.disableDataSyncing = true
end

function Brackets:OnDailyReset()
    -- All data should be good now
    self.realmBracketDB.disableDataSyncing = nil

    -- Once OnDailyReset is called, dailyStart is whenever today started (e.g on Wednesday reset this is now Wednesday not Tuesday).
    -- This trick works because honor data is always a day behind. On Wednesday, we have Tuesday data, on Thursday we have Wednesday data and so on.
    -- However, because this triggers on OUR daily reset it's always two days behind.
    --
    -- E.g on Wednesday reset, we will have no data on people yet, because everyone else will just be getting their Tuesday data in.
    -- On Thursday reset, we will have final numbers for everyones Tuesday reset (based on recorded data).
    -- and so by subtracting two days, we timeshift everything to the proper period.
    local yesterdayReset = self.db.resetTime.dailyStart - (86400 * 2)

    -- Reset whether we inspected somebody today
    for name, metadata in pairs(self.realmBracketDB.playersMeta) do
        metadata.seenToday = nil
        metadata.trustedSource = nil

        local playerData = self.realmBracketDB.players[name]
        if( playerData and playerData.thisWeek.honor > 0 ) then
            metadata.weeklySummary = metadata.weeklySummary or {}
            metadata.weeklySummary[yesterdayReset] = playerData.thisWeek.honor
        end
    end

    self:RefreshPlayerData()
end

-- Save our personal data and send it off to others
function Brackets:RefreshPlayerData()
    local rank = select(2, GetPVPRankInfo(UnitPVPRank("player")))
    -- Calculate rank progress.
    local rankProgress = GetPVPRankProgress()
    -- Figure out last weeks info, which is what we really care about.
    local lastWeekHonor, lastWeekStanding = select(3, GetPVPLastWeekStats())
    -- This should be zero, but I don't trust Blizzard so will be paranoid.
    local thisWeekKills, thisWeekHonor = GetPVPThisWeekStats()
    
    -- Don't save our own data until we see 15 kills
    if( thisWeekKills < 15 ) then return end

    self.realmBracketDB.playersMeta[PLAYER_NAME] = self.realmBracketDB.playersMeta[PLAYER_NAME] or {}
    self.realmBracketDB.playersMeta[PLAYER_NAME].seenToday = true
    self.realmBracketDB.playersMeta[PLAYER_NAME].sourcedFromSender = true
    self.realmBracketDB.playersMeta[PLAYER_NAME].sender = PLAYER_NAME

    self.realmBracketDB.players[PLAYER_NAME] = {
        class = select(2, UnitClass("player")),
        lastChecked = GetServerTime(),
        rankPoints = Stats:CalculateRankPoints(rank, rankProgress),
        rankProgress = rankProgress,
        rank = rank,
        thisWeek = {
            honor = thisWeekHonor,
            kills = thisWeekKills,
        },
        lastWeek = {
            standing = lastWeekStanding,
            honor = lastWeekHonor,
        }
    }

    Comms:SendPlayerData(PLAYER_NAME)
    HonorTracker:Trigger("OnBracketDBUpdate", playerName)
end

-- Purge any data from blacklisted players
function Brackets:PurgeBlacklistedData()
    local purged = 0

    for playerName, metadata in pairs(self.realmBracketDB.playersMeta) do
        if( metadata.sender and Comms:IsBlacklisted(metadata.sender) ) then
            purged = purged + 1

            self.realmBracketDB.playersMeta[playerName] = nil
            self.realmBracketDB.players[playerName] = nil
        end
    end

    self:Print(string.format(L["Purged %d |4record:records; which were from a player on the blacklist."], purged))
end

-- Estimate rank progression data
function Brackets:Estimate(playerName)
    local data = self.realmBracketDB.players[playerName]
    if( not data ) then return end
   
    -- Figure out where the players current standing is
    local currentStanding = 0
    for _, checkData in pairs(self.realmBracketDB.players) do
        if( checkData.thisWeek.honor >= data.thisWeek.honor ) then
            currentStanding = currentStanding + 1
        end
    end

    -- Calculate bracket and bracket progress
    local bracketSizes = self:CalculateBrackets()

    local bracket = 1
    local innerBracketProgress = 0
    local rankAward = nil

    -- If you're standing 1 and bracket 14, you will always be 100%
    if( currentStanding == 1 and bracketSizes[14] > 0 ) then
        bracket = 14
        innerBracketProgress = 1

        -- Top of bracket 14 gets 13000 points
        rankAward = 13000

    -- Otherwise try and calculate it
    else
        for i=14, 2, -1 do
            if( currentStanding <= bracketSizes[i] ) then
                -- If the bracket sizes are 4, 8, 18 then currentStanding of 4 puts us at 14, 5 puts us at 13 and so on.
                bracket = i

                local priorBracket = (bracketSizes[i + 1] or 0)
                local totalSize = bracketSizes[i] - priorBracket
                innerBracketProgress = 1 - ((currentStanding - priorBracket - 1) / (totalSize - 1))
                break
            end
        end

        -- Figure out the awarded amount of points
        rankAward = self.bracketToPoints[bracket] + (999 * innerBracketProgress)
    end

    -- Now factor in diminishing returns
    local estimatedRankPoints = math.floor((data.rankPoints * 0.8) + rankAward + 0.5)

    return {
        rankPoints = estimatedRankPoints,
        standing = currentStanding,
        bracket = bracket,
        bracketProgress = innerBracketProgress
    }
end

-- Calculate the players in each bracket
function Brackets:CalculateBrackets()
    local poolSize = 0
    for name, data in pairs(self.realmBracketDB.players) do
        poolSize = poolSize + 1
    end
    
    -- Brackets 1 -> 14
    local brackets = {1, 0.845, 0.697, 0.566, 0.436, 0.327, 0.228, 0.159, 0.100, 0.060, 0.035, 0.020, 0.008, 0.003} 
    for i=1, 14 do
        brackets[i] = math.floor((brackets[i] * poolSize) + 0.5)
    end

    return brackets
end

function Brackets:ScanEligibleUnit(unit)
    -- Skip if we're not going to check the data anyway yet
    if( self.realmBracketDB.disableDataSyncing ) then return end
    -- Skip in combat
    if( InCombatLockdown() ) then return end
    -- Skip if inspect frame is open
    if( InspectFrame and InspectFrame:IsVisible() ) then return end
    -- Skip in a battlefield
    if( select(2, IsInInstance()) == "pvp" ) then return end

    -- Skip if we have an inspect queued
    if( self.queuedInspectData or self.queuedHonorInspect ) then return end

    -- Skip if we've already scanned them today
    local name = UnitName(unit)
    if( self.realmBracketDB.playersMeta[name] and self.realmBracketDB.playersMeta[name].seenToday ) then
        return
    -- In case we don't record the person, filter it out locally this way too
    elseif( alreadyScanned[name] ) then
        return
    end

    -- Skip if generally not eligible
    if( UnitRealmRelationship(unit) ~= 1) then return end
    if( UnitLevel(unit) < 10 ) then return end
    if( not UnitIsPlayer(unit) ) then return end
    if( not UnitIsFriend("player", unit) ) then return end
    if( not CheckInteractDistance(unit, 1) ) then return end
    if( not CanInspect(unit) ) then return end

    alreadyScanned[name] = true

    NotifyInspect(unit)
    RequestInspectHonorData()
end

function Brackets:PLAYER_ENTERING_WORLD()
    self.queuedInspectData = nil
    self.queuedHonorInspect = nil
    self.skipHonorEvent = nil    
end

function Brackets:PLAYER_TARGET_CHANGED()
    self:ScanEligibleUnit("target")
end

function Brackets:UPDATE_MOUSEOVER_UNIT()
    self:ScanEligibleUnit("mouseover")
end

function Brackets:INSPECT_HONOR_UPDATE()
    if( not self.queuedHonorInspect or not self.queuedHonorInspect.name or self.realmBracketDB.disableDataSyncing ) then
        return
    elseif( self.skipHonorEvent ) then
        self.skipHonorEvent = nil
        return
    end
    
    -- Attempt to filter out inspects which look potentially buggy
    local rankProgress = GetInspectPVPRankProgress()
    local inspectTag = string.join(",", GetInspectHonorData()) .. rankProgress
    if( self.lastSeenInspect[inspectTag] ) then return end

    local now = GetServerTime()
    self.lastSeenInspect[inspectTag] = now

    -- Expire out tags after 10 minutes
    for tag, addedAt in pairs(self.lastSeenInspect) do
        if( (now - addedAt) >= 600 ) then
            self.lastSeenInspect[tag] = nil
        end
    end

    local todayHK, todayDK, yesterdayHK, yesterdayHonor, thisWeekHK, thisWeekHonor, lastWeekHK, lastWeekHonor, lastWeekStanding, lifetimeHK, lifetimeDK, lifetimeHighestRank = GetInspectHonorData()
    -- Filter out people who are not eligible yet
    if( thisWeekHK < 15 ) then
        self.queuedHonorInspect = nil
        return
    end

    local inspectData = self.queuedHonorInspect
    local rankPoints = Stats:CalculateRankPoints(inspectData.rank, rankProgress)

    self.realmBracketDB.playersMeta[inspectData.name] = self.realmBracketDB.playersMeta[inspectData.name] or {}
    self.realmBracketDB.playersMeta[inspectData.name].seenToday = true
    self.realmBracketDB.playersMeta[inspectData.name].sourcedFromSender = true
    self.realmBracketDB.playersMeta[inspectData.name].sender = PLAYER_NAME

    self.realmBracketDB.players[inspectData.name] = {
        class = inspectData.class,
        lastChecked = now,
        rankPoints = rankPoints,
        rankProgress = rankProgress,
        rank = inspectData.rank,
        thisWeek = {
            honor = thisWeekHonor,
            kills = thisWeekHK,
        },
        lastWeek = {
            standing = lastWeekStanding,
            honor = lastWeekHonor,
        }
    }

    Comms:SendPlayerData(inspectData.name)
    HonorTracker:Trigger("OnBracketDBUpdate", playerName)
    
    self.queuedHonorInspect = nil
end

function Brackets:ConvertFromHonorSpy()
    -- Otherwise check for HonorSpy carry over
    if( not IsAddOnLoaded("HonorSpy") ) then return end
    if( self.globalDB.notifiedHonorSpy and self.globalDB.notifiedHonorSpy[GetRealmName()] ) then return end

    self.globalDB.notifiedHonorSpy = self.globalDB.notifiedHonorSpy or {}
    self.globalDB.notifiedHonorSpy[GetRealmName()] = true

    -- Filter out any data older than 3 days, as a rough estimation of whether it's fresh or not.
    local maxAge = 3600 * 24 * 3
    local carriedOver = 0
    for playerName, data in pairs(HonorSpy.db.factionrealm.currentStandings) do
        local existingData = self.realmBracketDB.players[playerName]
        local age = (GetServerTime() - data.last_checked)
        if( (not existingData or existingData.lastChecked < data.last_checked) and age < maxAge ) then
            carriedOver = carriedOver + 1

            self.realmBracketDB.playersMeta[playerName] = {
                lastSent = GetServerTime()
            }

            self.realmBracketDB.players[playerName] = {
                class = data.class,
                lastChecked = data.last_checked,
                rankPoints = data.RP,
                rankProgress = data.rankProgress,
                rank = data.rank,
                thisWeek = {
                    honor = data.thisWeekHonor,
                    kills = 15, -- We know HonorSpy only syncs on >15 kills
                },
                lastWeek = {
                    standing = data.standing,
                    honor = data.lastWeekHonor,
                }
            }        
        end
    end

    HonorTracker:Print(L["HonorSpy was detected. HonorTracker is able to do the equivalent more efficiently now, and it's recommended you disable HonorSpy."])
    HonorTracker:Print(string.format(L["We carried over %d |4player:players; over to HonorTracker, and HonorTracker will sync with other HonorTracker and HonorSpy users automatically."], carriedOver), true)
end

hooksecurefunc("RequestInspectHonorData", function() 
    Brackets.queuedHonorInspect = Brackets.queuedInspectData
    Brackets.queuedInspectData = nil
    Brackets.skipHonorEvent = true
end)

hooksecurefunc("NotifyInspect", function(unit)
    -- Ignore cross realm inspect
    if( UnitRealmRelationship(unit) ~= 1) then
        Brackets.queuedInspectData = {}
        return
    end

    Brackets.queuedInspectData = {
        name = UnitName(unit),
        class = select(2, UnitClass(unit)),
        rank = select(2, GetPVPRankInfo(UnitPVPRank(unit))),
    }
end)

hooksecurefunc("ClearInspectPlayer", function()
    Brackets.queuedInspectData = nil
    Brackets.queuedHonorInspect = nil
end)

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("INSPECT_HONOR_UPDATE")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    Brackets[event](Brackets, ...)
end)

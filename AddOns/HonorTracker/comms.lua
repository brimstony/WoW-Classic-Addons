local HonorTracker = select(2, ...)
local Comms = HonorTracker:RegisterModule("Comms")
local AceSerializer = LibStub("AceSerializer-3.0")
local AceComm = LibStub("AceComm-3.0")

local HONORSPY_COMM_PREFIX = "HonorSpy4"
local HONORTRACKER_COMM_PREFIX = "HonorTracker"
local PLAYER_NAME = UnitName("player")
local PLAYER_SERVER = GetRealmName()
local FULL_PLAYER_NAME = PLAYER_NAME .. "-" .. PLAYER_SERVER
local CTL = _G.ChatThrottleLib
local SERIALIZE_VERSION_FORMAT = 1

local detectedHonorTracker = {}
local detectedInGuild = {}

function Comms:IsBlacklisted(targetName)
    targetName = string.lower(targetName)
    for senderName, _ in pairs(self.realmBracketDB.senderBlacklist) do
        if( string.lower(senderName) == targetName ) then
            return senderName
        end
    end

    return nil
end

function Comms:OnLoad()
    -- Setup handling HonorSpy data
    local HonorSpy = {}
    HonorSpy.OnMessage = function(self, prefix, msg, distributionType, sender)
        -- Filter out our own messages
        if( sender == PLAYER_NAME or sender == FULL_PLAYER_NAME ) then return end

        -- Filter out people from other realms, or if they are on ours then strip the server name
        local name, server = string.split("-", sender)
        if( server and server ~= PLAYER_SERVER ) then
            -- Comms:DedupDebug(1, "Filtering HonorSpy data from %s as they are on another realm.", sender)
            return
        else
            sender = name
        end

        -- Filter out our duplicate messages
        if( detectedHonorTracker[sender] ) then
            Comms:DedupDebug(3, "Skipping HonorSpy data from %s since they have HonorTracker", sender)
            return
        end

        -- Blacklisted
        if( Comms:IsBlacklisted(sender) ) then
            Comms:DedupDebug(1, "Skipped HonorSpy data from %s, blacklisted.", sender)
            return
        end

        local ok, playerName, playerData = AceSerializer:Deserialize(msg)
        if( not ok ) then return end

        HonorTracker:Trigger("OnMessage", sender, distributionType, "HonorSpy", playerName, playerData)
    end

    AceComm:Embed(HonorSpy)
    HonorSpy:RegisterComm(HONORSPY_COMM_PREFIX, "OnMessage")

    C_ChatInfo.RegisterAddonMessagePrefix(HONORTRACKER_COMM_PREFIX)
end

-- Handle our own data
function Comms:HandleRawData(sender, distributionType, msg)
    local messageType, unparsedData = string.split(",", msg, 3)

    local data
    if( unparsedData and unparsedData ~= "" ) then
        data = {AceSerializer:Deserialize(unparsedData)}
        local ok = table.remove(data, 1)
        if( not ok ) then return end
    else
        data = {}
    end

    HonorTracker:Trigger("OnMessage", sender, distributionType, messageType, unpack(data))
end

function Comms:CHAT_MSG_ADDON(prefix, msg, distributionType, sender)
    -- Filter out other messages not relevant to us
    if( prefix ~= HONORTRACKER_COMM_PREFIX ) then return end

    -- Filter out our own messages
    if( sender == PLAYER_NAME or sender == FULL_PLAYER_NAME ) then return end
    -- Filter out people from other realms, or if they are on ours then strip the server name
    local name, server = string.split("-", sender)

    if( server and server ~= PLAYER_SERVER ) then
        self:DedupDebug(4, "Filtering HonorTracker data from %s as they are on another realm.", sender)
        return
    else
        sender = name
    end

    detectedHonorTracker[sender] = true

    -- Blacklisted
    if( self:IsBlacklisted(sender) ) then
        self:DedupDebug(1, "Skipped HonorSpy data from %s, blacklisted.", sender)
        return
    end

    -- Don't duplicate parse the same message in guild and non-guild channels
    if( distributionType == "GUILD" ) then
        detectedInGuild[sender] = true
    elseif( detectedInGuild[sender] and distributionType ~= "WHISPER" ) then
        self:DedupDebug(4, "Filtering HonorTracker data from %s (via %s) as they are in our guild", sender, distributionType)
        return
    end
    
    -- Parse HonorTracker messages
    self:HandleRawData(sender, distributionType, msg)
end

-- Send messages
function Comms:SendPrivateMessage(target, type, data)
    local msg = AceSerializer:Serialize(data)
    CTL:SendAddonMessage("BULK", HONORTRACKER_COMM_PREFIX, type .. "," .. msg, "WHISPER", target)
end

function Comms:SendMessage(type, data)
    local msg = AceSerializer:Serialize(data)
    if( IsInGuild() ) then
        CTL:SendAddonMessage("BULK", HONORTRACKER_COMM_PREFIX, type .. "," .. msg, "GUILD")
    end

    if( not self.db.config.internalComms ) then
        if( select(2, IsInInstance()) == "pvp") then
            CTL:SendAddonMessage("BULK", HONORTRACKER_COMM_PREFIX, type .. "," .. msg, "INSTANCE_CHAT")
        else
            CTL:SendAddonMessage("BULK", HONORTRACKER_COMM_PREFIX, type .. "," .. msg, "YELL")
        end
    end
end

-- Handle compressing and decompressing player data
function Comms:SerializePlayerData(data, metadata)
    local serialized = {
        SERIALIZE_VERSION_FORMAT, -- 1
        data.class, -- 2
        data.lastChecked, -- 3
        data.rankPoints, -- 4
        data.rankProgress, -- 5
        data.rank, -- 6
        data.thisWeek.honor, -- 7
        data.thisWeek.kills, -- 8
        data.lastWeek.standing, -- 9
        data.lastWeek.honor, -- 10
        metadata.sourcedFromSender == true and "true" or metadata.sourcedFromSender == false and "false" or "nil", -- 11
    }

    return table.concat(serialized, "/")
end

function Comms:DeserializePlayerData(msg)
    local raw = {string.split("/", msg)}
    local data = {
        class = raw[2],
        lastChecked = tonumber(raw[3]),
        rankPoints = tonumber(raw[4]),
        rankProgress = tonumber(raw[5]),
        rank = tonumber(raw[6]),
        thisWeek = {
            honor = tonumber(raw[7]),
            kills = tonumber(raw[8]),
        },
        lastWeek = {
            standing = tonumber(raw[9]),
            honor = tonumber(raw[10]),
        },
        metadata = {
            sourcedFromSender = raw[11] == "true" and true or raw[11] == "false" and false or nil
        }
    }

    if( type(data) ~= "table" ) then return end
    if( type(data.class) ~= "string" or not RAID_CLASS_COLORS[data.class] ) then return end
    if( type(data.lastChecked) ~= "number" or type(data.rankPoints) ~= "number" or type(data.rankProgress) ~= "number" or type(data.rank) ~= "number") then return end
    if( type(data.thisWeek) ~= "table" or type(data.thisWeek.honor) ~= "number" or type(data.thisWeek.kills) ~= "number" ) then return end
    if( type(data.lastWeek) ~= "table" or type(data.lastWeek.standing) ~= "number" or type(data.lastWeek.honor) ~= "number" ) then return end
    -- Prevent getting a lastChecked too far into the future
    if( data.lastChecked > (GetServerTime() + 30) ) then return end

    return data
end

function Comms:SendPrivatePlayerData(sender, name)
    self:SendPrivateMessage(
        sender,
        "push",
        {name, self:SerializePlayerData(self.realmBracketDB.players[name], self.realmBracketDB.playersMeta[name])}
    )
end

function Comms:SendPlayerData(name)
    local data = self.realmBracketDB.players[name]
    local metadata = self.realmBracketDB.playersMeta[name]

    -- If we've sent the data in the 10 minutes, avoid sending it again to reduce spam
    if( metadata and metadata.lastSent and (GetServerTime() - metadata.lastSent) <= 600) then return end
    metadata.lastSent = GetServerTime()

    self:Debug(2, "Sending updated data on %s, RP = %d, HK = %d, Honor = %d", name, data.rankPoints, data.thisWeek.kills, data.thisWeek.honor)
    self:SendMessage("push", {name, self:SerializePlayerData(data, metadata)})
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")
eventFrame:SetScript("OnEvent", function(self, event, ...) Comms[event](Comms, ...) end)

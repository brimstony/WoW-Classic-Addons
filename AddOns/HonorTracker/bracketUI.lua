local HonorTracker = select(2, ...)
local BracketUI = HonorTracker:RegisterModule("BracketUI")
local Brackets = HonorTracker:GetModule("Brackets")
local Stats = HonorTracker:GetModule("Stats")
local L = HonorTracker.L

local TOTAL_SCROLL_ROWS = 22
local TOTAL_COLUMNS = 8
local PLAYER_NAME = UnitName("player")

-- Defaults to keep sorting sane when we have zero values
local DEFAULT_SORT_VALUE = {
    ["lastWeek.honor"] = 0,
    ["lastWeek.standing"] = 99999999
}

function BracketUI:Toggle()
    if( not self.frame or not self.frame:IsVisible() ) then
        self:Show()
    else
        self.frame:Hide()
    end
end

function BracketUI:Show()
    self.sortingBy = "thisWeek.honor"
    self.sortingDirection = true

    self:Setup()
    self.frame:Show()
end

function BracketUI:Update()
    if( not self.frame:IsVisible() ) then return end
    self:UpdateStats()
    self:UpdateTable()
end

function BracketUI:OnHonor(name)
    self.cachedStats = nil

    if( not name ) then return end
    if( not self.frame or not self.frame:IsVisible() ) then return end
    self:UpdateStats()
end

-- Reset our cache
function BracketUI:OnBracketDBUpdate(playerName)
    self.cachedSortedRows = nil
    self.cachedStats = nil
end

function BracketUI:OnHide()
    self.cachedSortedRows = nil
    self.cachedStats = nil
end

function BracketUI:UpdateStats()
    if( self.cachedStats ) then return end
    self.cachedStats = true

    local sumAges = 0
    local totalPlayers = 0
    for checkName, checkData in pairs(self.realmBracketDB.players) do
        sumAges = sumAges + (GetServerTime() - checkData.lastChecked)
        totalPlayers = totalPlayers + 1
    end

    local playerName = UnitName("player")
    if( GetPVPThisWeekStats() >= 15 and self.realmBracketDB.players[playerName] ) then
        local playerData = self.realmBracketDB.players[playerName]
        local estimate = Brackets:Estimate(playerName)

        local text
        if( estimate.rankPoints < playerData.rankPoints ) then
            text = L["|cFFFFFFFFThis Week: Estimated to go from|r %s |cFFFFFFFFback to|r |cFFFF0000%s|r|cFFFFFFFF,|r %s |cFFFFFFFFpercentile of bracket|r %d"]
        else
            text = L["|cFFFFFFFFThis Week: Estimated to go from|r %s |cFFFFFFFFup to|r |cFF00FF00%s|r|cFFFFFFFF,|r %s |cFFFFFFFFpercentile of bracket|r %d"]
        end

        self.statsFrame.thisWeekText:SetFormattedText(text,
            Stats:RankPointsToRank(playerData.rankPoints),
            Stats:RankPointsToRank(estimate.rankPoints),
            HonorTracker:Percentile(estimate.bracketProgress * 100),
            estimate.bracket
        )
    else
        self.statsFrame.thisWeekText:SetFormattedText(L["|cFFFFFFFFThis Week: Need|r %d |cFFFFFFFFmore HKs to be eligible for ranking"], 15 - GetPVPThisWeekStats())
    end

    if( self.db.rankPoints.lastWeek ) then
        local diff = self.db.rankPoints.thisWeek - math.ceil((self.db.rankPoints.lastWeek or 0) * 0.8)
        if( diff > 0 ) then
            local bracket, bracketPercentile = Stats:CalculateBracketFromGain(diff)
            self.statsFrame.lastWeekText:SetFormattedText(L["|cFFFFFFFFLast Week: Gained|r %d |cFFFFFFFFrank points,|r %s |cFFFFFFFFpercentile of bracket|r %d"],
                diff,
                HonorTracker:Percentile(bracketPercentile),
                bracket
            )
        else
            self.statsFrame.lastWeekText:SetFormattedText(L["|cFFFFFFFFLast Week: Lost|r %d |cFFFFFFFFrank points|r"],
                diff
            )
        end
    else
        self.statsFrame.lastWeekText:SetText(L["|cFFFFFFFFLast Week: No ranking data yet, wait until next week."])
    end

    if( self.db.resetTime.weeklyStart == self.db.resetTime.dailyStart ) then
        self.statsFrame.generalText:SetFormattedText("|cffff1919%s|r", L["Weekly reset just happened. You need to wait one daily reset for info to appear."])
    else
        self.statsFrame.generalText:SetFormattedText(L["|cFFFFFFFFEligible Pool Size:|r %d |cFFFFFFFF(Players with >=15 HKs)|r"], totalPlayers)
    end
end

function BracketUI:SortBy(field)
    if( self.sortingBy ~= field ) then
        self.sortingDirection = true
        self.sortingBy = field
    else
        self.sortingDirection = not self.sortingDirection
    end

    self.cachedSortedRows = nil
    self:UpdateTable()
end

function BracketUI:UpdateTable()
    local selfName = UnitName("player")

    -- Figure out players and their current standings
    local sortedTableRows = self.cachedSortedRows

    if( not sortedTableRows ) then
        sortedTableRows = {}
        self.cachedSortedRows = sortedTableRows

        for playerName, data in pairs(self.realmBracketDB.players) do
            table.insert(sortedTableRows, {playerName, -1, data})
        end
        
        local sortParent, sortKey = string.split(".", self.sortingBy)
        if( not sortKey ) then
            sortKey = sortParent
            sortParent = nil
        end

        table.sort(sortedTableRows,
            function(a, b)
                if( not b ) then return false end
                local aData = a[3]
                local bData = b[3]

                local aSortValue
                local bSortValue

                if( sortKey == "name" ) then
                    aSortValue = a[1]
                    bSortValue = b[1]
                elseif( sortParent ) then
                    aSortValue = aData[sortParent][sortKey]
                    bSortValue = bData[sortParent][sortKey]

                    if( aSortValue == 0 ) then
                        aSortValue = DEFAULT_SORT_VALUE[self.sortingBy] or aSortValue
                    end
                    
                    if( bSortValue == 0 ) then
                        bSortValue = DEFAULT_SORT_VALUE[self.sortingBy] or bSortValue
                    end
                else
                    aSortValue = aData[sortKey]
                    bSortValue = bData[sortKey]
                end

                if( aSortValue == bSortValue ) then
                    local aStanding = aData.lastWeek.standing
                    if( aStanding == 0 ) then aStanding = 999999 end

                    local bStanding = bData.lastWeek.standing
                    if( bStanding == 0 ) then bStanding = 999999 end

                    return aStanding < bStanding
                end

                if( self.sortingDirection ) then
                    return aSortValue > bSortValue
                else
                    return aSortValue < bSortValue
                end
            end
        )
        
        local currentRank = 1
        for _, row in pairs(sortedTableRows) do
            row[2] = currentRank
            currentRank = currentRank + 1
        end

        -- Add our bracket markers once we have 10 players in the database
        -- to avoid showing semi-wonky data early on.
        local totalEntries = #(sortedTableRows)
        if( totalEntries > 10 ) then
            local bracketSizes = Brackets:CalculateBrackets()
            local shift = 1

            -- 2, 7, 19, 34, 58, 97, 154, 221, 318, 424, 550, 678, 822, 973
            for bracket=14, 1, -1 do
                local size = bracketSizes[bracket] - (bracketSizes[bracket + 1] or 0)
                if( size > 0 ) then
                    table.insert(sortedTableRows, shift, {bracket, size})
                    shift = shift + size + 1
                end
            end
        end
    end

    FauxScrollFrame_Update(self.bracketScroll, #(sortedTableRows), TOTAL_SCROLL_ROWS, 20)
    
    if( self.setToPlayer ) then
        for i, row in pairs(sortedTableRows) do
            if( #(row) == 3 and row[1] == PLAYER_NAME and i > TOTAL_SCROLL_ROWS ) then
                local scrollBar = FauxScrollFrame_GetChildFrames(self.bracketScroll)
                scrollBar:SetValue((i - 10) * 20)

                FauxScrollFrame_SetOffset(self.bracketScroll, i - 10)
                break
            end
        end

        self.setToPlayer = nil
    end

    local currentTime = GetServerTime()
    local offset = FauxScrollFrame_GetOffset(self.bracketScroll)
    local zebraIndex = 0
    for i=1, TOTAL_SCROLL_ROWS do
        local index = offset + i

        local row = self.rows[i]
        local frame = self.highlightRows[i]  
        frame:SetAlpha(1.0)

        local data = sortedTableRows[index]
        frame.rowData = data

        for i, fontString in pairs(row) do
            fontString:SetText("")
            fontString:SetAlpha(1.0)
        end

        -- No data
        if( not data) then
            frame:SetBackdropColor(0, 0, 0, 0)
            frame:Hide()

        -- Bracket text
        elseif( #(data) == 2 ) then
            zebraIndex = 1
            frame:SetBackdropColor(1, 1, 1, 0.12)

            row[2]:SetWidth(140)
            row[2]:SetFormattedText(L["Bracket %d |cFFFFFFFF(%d |4player:players;)|r"], data[1], data[2])
            row[2]:SetTextColor(GameFontNormal:GetTextColor())
            frame:Show()

        -- Player row
        else
            local playerName = data[1]
            local playerEstRank = data[2]
            local playerData = data[3]
            local playerMeta = self.realmBracketDB.playersMeta[playerName]
    
            row[1]:SetText(self.sortingBy == "thisWeek.honor" and self.sortingDirection and playerEstRank or "--")
            row[2]:SetText(playerName)
            row[2]:SetWidth(80)
            row[2]:SetTextColor(RAID_CLASS_COLORS[playerData.class]:GetRGBA())
            row[3]:SetText(playerData.thisWeek.honor)
            row[4]:SetText(playerMeta.sourceType == "HonorSpy" and "--" or playerData.thisWeek.kills)
            row[5]:SetText(playerData.rank)
            row[6]:SetText(playerData.lastWeek.standing == 0 and "---" or playerData.lastWeek.standing)
            row[7]:SetText(playerData.lastWeek.honor == 0 and "---" or playerData.lastWeek.honor)
            
            if( playerName == selfName ) then
                frame:SetBackdropColor(1, 1, 1, 0.20)
                row[8]:SetText("---")
            else
                if( zebraIndex == 0 ) then
                    zebraIndex = 1
                    frame:SetBackdropColor(0.5, 0.5, 0.5, 0.15)
                elseif( zebraIndex == 1 ) then
                    zebraIndex = 0
                    frame:SetBackdropColor(0, 0, 0, 0)
                end

                row[8]:SetText(HonorTracker:FormatPeriod(currentTime - playerData.lastChecked))
            end

            for _, fontString in pairs(row) do
                if( self.db.resetTime.dailyStart <= playerData.lastChecked ) then
                    fontString:SetAlpha(1.0)
                else
                    fontString:SetAlpha(0.80)
                end
            end

            frame:Show()
        end
    end
end

function BracketUI:HandleClick(row, button)
    if( not row.rowData ) then return end
    if( #(row.rowData) == 2 ) then return end

    local playerName = row.rowData[1]
    if( playerName == PLAYER_NAME ) then return end

    if( button == "RightButton" ) then
        if( IsAltKeyDown() ) then
            self.realmBracketDB.players[playerName] = nil
            self.realmBracketDB.playersMeta[playerName] = nil
            self.cachedSortedRows = nil
            self.cachedStats = nil
        
            self:Update()

            self:Print(string.format(L["Deleted '%s' from your database until you see them again."], playerName))
        elseif( IsControlKeyDown() ) then
            local metadata = self.realmBracketDB.playersMeta[playerName]
            if( metadata.sender and metadata.sender ~= PLAYER_NAME ) then
                self.realmBracketDB.senderBlacklist[metadata.sender] = true
                self:Print(string.format(L["Blacklisting data sent from '%s' from now on, use '/ht del-blacklist %s' to undo."], metadata.sender, metadata.sender))
                
                Brackets:PurgeBlacklistedData()

                self.cachedSortedRows = nil
                self.cachedStats = nil
                self:Update()
            end
        end
    end
end

function BracketUI:ShowTooltip(row)
    if( not row.rowData ) then return end

    GameTooltip:SetOwner(row, "ANCHOR_LEFT", -12, 0)
    GameTooltip:ClearLines()

    -- Bracket data
    if( #(row.rowData) == 2 ) then
        GameTooltip:SetText(string.format(L["Bracket %d |cFFFFFFFF(%d |4player:players;)|r"], row.rowData[1], row.rowData[2]), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        GameTooltip:AddLine(L["Rank points are awarded based on how how far into a bracket you are."], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)

    -- Player data
    elseif( #(row.rowData) == 3 ) then
        local playerName = row.rowData[1]
        local playerEstRank = row.rowData[2]
        local playerData = row.rowData[3]
        local playerMeta = self.realmBracketDB.playersMeta[playerName] or {}

        GameTooltip:SetText(playerName, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)



        if( self.db.resetTime.dailyStart <= playerData.lastChecked ) then
            GameTooltip:AddDoubleLine(L["Data Age"], L["Seen Today"], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
        else
            GameTooltip:AddDoubleLine(L["Data Age"], HonorTracker:FormatPeriod(GetServerTime() - playerData.lastChecked), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
        end
        
        if( playerMeta.sender == PLAYER_NAME ) then
            GameTooltip:AddDoubleLine(L["Data Source"], L["Yourself"], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
        elseif( playerMeta.sender ) then
            if( playerMeta.trustedSource ) then
                GameTooltip:AddDoubleLine(L["Data Source"], string.format("%s |cFFFFFFFF(%s)|r", playerMeta.sender, L["Trusted"]), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
            else
                GameTooltip:AddDoubleLine(L["Data Source"], playerMeta.sender, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            end
        else
            GameTooltip:AddDoubleLine(L["Data Source"], L["Unknown"], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
        end

        if( playerMeta.sender ~= PLAYER_NAME ) then
            if( playerMeta.sourcedFromSender == true ) then
                GameTooltip:AddDoubleLine(L["Accuracy"], L["Sender Inspected"], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
            elseif( playerMeta.sourcedFromSender == false ) then
                GameTooltip:AddDoubleLine(L["Accuracy"], L["Synced from Others"])
            end
        end

        if( playerName ~= PLAYER_NAME ) then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(L["Hold ALT + Right Click to delete this record."], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)

            if( playerMeta.sender and playerMeta.sender ~= PLAYER_NAME ) then
                GameTooltip:AddLine(string.format(L["Hold CTRL + Right Click to blacklist data from %s."], playerMeta.sender), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)
            end
        end
    end

    GameTooltip:Show()
end

function BracketUI:Setup()
    if( self.frame ) then return end
    local wrappedUpdate = function(self) BracketUI:Update() end

    self.frame = CreateFrame("Frame", "HonorTrackerUI", UIParent)
	self.frame:SetWidth(640)
	self.frame:SetHeight(524)
	self.frame:SetMovable(true)
	self.frame:EnableMouse(true)
	self.frame:SetFrameStrata("HIGH")
	self.frame:SetToplevel(true)
	self.frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 26,
		insets = {left = 9, right = 9, top = 9, bottom = 9},
	})
    self.frame:SetScript("OnShow", wrappedUpdate)
    self.frame:SetScript("OnHide", function()
        BracketUI:OnHide()
    end)
    self.frame:SetPoint("CENTER")
    self.frame:Hide()
    
    table.insert(UISpecialFrames, self.frame:GetName())
	
	-- Create the title/movy thing
	local texture = self.frame:CreateTexture(nil, "ARTWORK")
	texture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
	texture:SetPoint("TOP", 0, 12)
	texture:SetWidth(250)
	texture:SetHeight(60)
	
	local title = CreateFrame("Button", nil, self.frame)
	title:SetPoint("TOP", 0, 4)
	title:SetText(L["Honor Tracker"])
	title:SetPushedTextOffset(0, 0)

	title:SetNormalFontObject(GameFontNormal)
	title:SetHeight(20)
	title:SetWidth(200)
	title:RegisterForDrag("LeftButton")
	title:SetScript("OnDragStart", function(self)
		self.isMoving = true
		BracketUI.frame:StartMoving()
	end)
	
	title:SetScript("OnDragStop", function(self)
		if( self.isMoving ) then
            self.isMoving = nil
            BracketUI.frame:StopMovingOrSizing()
		end
	end)
	
	-- Close button, this needs more work not too happy with how it looks
	local button = CreateFrame("Button", nil, self.frame, "UIPanelCloseButton")
	button:SetHeight(27)
	button:SetWidth(27)
	button:SetPoint("TOPRIGHT", -2, -2)
	button:SetScript("OnClick", function() HideUIPanel(BracketUI.frame) end)
	
	local backdrop = {
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 3, right = 3, top = 4, bottom = 3 }
    }

    -- Core progress frame
	self.statsFrame = CreateFrame("Frame", self.frame:GetName() .. "Bracket", self.frame)
	self.statsFrame:SetHeight(52)
	self.statsFrame:SetWidth(self.frame:GetWidth() - 16)
	self.statsFrame:SetBackdrop(backdrop)
	self.statsFrame:SetBackdropColor(0, 0, 0, 1)
	self.statsFrame:SetBackdropBorderColor(0.75, 0.75, 0.75, 1)
    self.statsFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 8, -22)

    self.statsFrame.thisWeekText = self.statsFrame:CreateFontString(nil, nil, "GameFontNormalSmall")
    self.statsFrame.thisWeekText:SetHeight(18)
    self.statsFrame.thisWeekText:SetPoint("TOPLEFT", self.statsFrame, "TOPLEFT", 8, -2)

    self.statsFrame.lastWeekText = self.statsFrame:CreateFontString(nil, nil, "GameFontNormalSmall")
    self.statsFrame.lastWeekText:SetHeight(18)
    self.statsFrame.lastWeekText:SetPoint("TOPLEFT", self.statsFrame.thisWeekText, "BOTTOMLEFT", 0, 4)

    self.statsFrame.generalText = self.statsFrame:CreateFontString(nil, nil, "GameFontNormalSmall")
    self.statsFrame.generalText:SetHeight(18)
    self.statsFrame.generalText:SetPoint("TOPLEFT", self.statsFrame.lastWeekText, "BOTTOMLEFT", 0, 4)

    self.statsFrame.scrollToSelf = CreateFrame("Button", nil, self.statsFrame, "GameMenuButtonTemplate")
    self.statsFrame.scrollToSelf:SetHeight(16)
    self.statsFrame.scrollToSelf:SetWidth(80)
    self.statsFrame.scrollToSelf:SetText(L["Scroll to Self"])
    self.statsFrame.scrollToSelf:SetNormalFontObject(GameFontHighlightSmall)    
    self.statsFrame.scrollToSelf:SetHighlightFontObject(GameFontHighlightSmall)    
    self.statsFrame.scrollToSelf:SetPoint("BOTTOMRIGHT", self.statsFrame, "BOTTOMRIGHT", -4, 4)
    self.statsFrame.scrollToSelf:SetScript("OnClick", function(self)
        BracketUI.setToPlayer = true
        BracketUI:Update()
    end)
    self.statsFrame.scrollToSelf:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
        GameTooltip:ClearLines()
        GameTooltip:SetText(L["Scroll to wherever you are on the ranking list."])
        GameTooltip:Show()
    end)
    self.statsFrame.scrollToSelf:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Core ranking frame
	self.bracketFrame = CreateFrame("Frame", self.frame:GetName() .. "Bracket", self.frame)
	self.bracketFrame:SetHeight(self.frame:GetHeight() - self.statsFrame:GetHeight() - 28)
	self.bracketFrame:SetWidth(self.frame:GetWidth() - 16)
	self.bracketFrame:SetBackdrop(backdrop)
	self.bracketFrame:SetBackdropColor(0, 0, 0, 1)
	self.bracketFrame:SetBackdropBorderColor(0.75, 0.75, 0.75, 1)
    self.bracketFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 8, -72)
    self.bracketFrame:EnableMouse()
	
	-- Scroll frame
	self.bracketScroll = CreateFrame("ScrollFrame", self.bracketFrame:GetName() .. "Scroll", self.bracketFrame, "FauxScrollFrameTemplate")
	self.bracketScroll:SetWidth(self.bracketFrame:GetWidth())
	self.bracketScroll:SetHeight(self.bracketFrame:GetHeight() - 9)
	self.bracketScroll:SetPoint("TOPRIGHT", self.bracketFrame, "TOPRIGHT", -26, -5)
	self.bracketScroll:SetScript("OnVerticalScroll", function(self, step)
		FauxScrollFrame_OnVerticalScroll(self, step, 20, wrappedUpdate)
	end)

	FauxScrollFrame_SetOffset(self.bracketScroll, 0)

	local texture = self.bracketScroll:CreateTexture(nil, "ARTWORK")
	texture:SetWidth(31)
	texture:SetHeight(256)
	texture:SetPoint("TOPLEFT", self.bracketScroll, "TOPRIGHT", -2, 5)
	texture:SetTexCoord(0, 0.484375, 0, 1.0)

	texture = self.bracketScroll:CreateTexture(nil, "ARTWORK")
	texture:SetWidth(31)
	texture:SetHeight(256)
	texture:SetPoint("BOTTOMLEFT", self.bracketScroll, "BOTTOMRIGHT", -2, -2)
	texture:SetTexCoord(0.515625, 1.0, 0, 0.4140625)
	
    -- Basic bracket frame
    self.sortColumns = {}

	for i=1, TOTAL_COLUMNS do
        local button = CreateFrame("Button", nil, self.bracketFrame)
		button:SetHeight(20)
		button:SetNormalFontObject(GameFontNormal)
		button:SetDisabledFontObject(GameFontNormal)
        button:SetHighlightFontObject(GameFontHighlight)
        button:SetScript("OnClick", function(self)
            BracketUI:SortBy(self.sortField)

            for _, row in pairs(BracketUI.sortColumns) do
                if( row == self and ( BracketUI.sortingBy ~= "thisWeek.honor" or not BracketUI.sortingDirection ) ) then
                    row:LockHighlight()
                else
                    row:UnlockHighlight()
                end
            end
        end)
        button:Show()
        
        self.sortColumns[i] = button
    end
    
    self.sortColumns[1]:SetText("#")
    self.sortColumns[1]:SetWidth(30)
    self.sortColumns[1]:SetPoint("TOPLEFT", self.bracketFrame, "TOPLEFT", 10, -2)
    self.sortColumns[1].sortField = "thisWeek.honor"

    self.sortColumns[2]:SetText(L["Name"])
    self.sortColumns[2]:SetWidth(80)
    self.sortColumns[2]:SetPoint("TOPLEFT", self.sortColumns[1], "TOPRIGHT", 10, 0)
    self.sortColumns[2].sortField = "name"

    self.sortColumns[3]:SetText(L["Honor"])
    self.sortColumns[3]:SetWidth(50)
    self.sortColumns[3]:SetPoint("TOPLEFT", self.sortColumns[2], "TOPRIGHT", 10, 0)
    self.sortColumns[3].sortField = "thisWeek.honor"

    self.sortColumns[4]:SetText(L["Kills"])
    self.sortColumns[4]:SetWidth(50)
    self.sortColumns[4]:SetPoint("TOPLEFT", self.sortColumns[3], "TOPRIGHT", 10, 0)
    self.sortColumns[4].sortField = "thisWeek.kills"

    self.sortColumns[5]:SetText(L["Rank"])
    self.sortColumns[5]:SetWidth(50)
    self.sortColumns[5]:SetPoint("TOPLEFT", self.sortColumns[4], "TOPRIGHT", 10, 0)
    self.sortColumns[5].sortField = "rankPoints"
    
    self.sortColumns[6]:SetText(L["Final Standing"])
    self.sortColumns[6]:SetWidth(90)
    self.sortColumns[6]:SetPoint("TOPLEFT", self.sortColumns[5], "TOPRIGHT", 28, 0)
    self.sortColumns[6].sortField = "lastWeek.standing"

    self.sortColumns[7]:SetText(L["Final Honor"])
    self.sortColumns[7]:SetWidth(80)
    self.sortColumns[7]:SetPoint("TOPLEFT", self.sortColumns[6], "TOPRIGHT", 10, 0)
    self.sortColumns[7].sortField = "lastWeek.honor"

    self.sortColumns[8]:SetText(L["Last Seen"])
    self.sortColumns[8]:SetWidth(80)
    self.sortColumns[8]:SetPoint("TOPLEFT", self.sortColumns[7], "TOPRIGHT", 10, 0)
    self.sortColumns[8].sortField = "lastChecked"

    for i, button in pairs(self.sortColumns) do
        local fontString = button:GetFontString()
        fontString:SetWidth(button:GetWidth())

        if( i <= 2 ) then
            fontString:SetJustifyH("LEFT")
        end
    end

    local backdrop = {
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		tile = true,
		tileSize = 16,
		insets = {left = -4, right = 6, top = 1, bottom = 1},
    }
    
    self.rows = {}
    self.highlightRows = {}
    for i=1, TOTAL_SCROLL_ROWS do
        self.rows[i] = {}

        local frame = CreateFrame("Button", nil, self.bracketFrame)
        frame:Hide()

		for j=1, TOTAL_COLUMNS do
            local text = frame:CreateFontString(nil, nil, "GameFontHighlightSmall")
            text:SetHeight(20)
            text:SetWidth(self.sortColumns[j]:GetWidth())            
            text:Show()

			if( i > 1 ) then
				text:SetPoint("TOPLEFT", self.rows[i - 1][j], "TOPLEFT", 0, -19)
			else
				text:SetPoint("TOPLEFT", self.sortColumns[j], "BOTTOMLEFT", 0, 0)
			end

            if( j <= 2 ) then
                text:SetJustifyH("LEFT")
            end

            self.rows[i][j] = text
        end

        frame:SetHeight(20)
        frame:SetWidth(self.bracketFrame:GetWidth())
        frame:SetPoint("TOPLEFT", self.rows[i][1])
        frame:SetPoint("TOPRIGHT", self.rows[i][TOTAL_COLUMNS])
        frame:SetBackdrop(backdrop)
        frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        frame:SetScript("OnClick", function(self, button)
            BracketUI:HandleClick(self, button)
        end)
        frame:SetScript("OnEnter", function(self)
            self.startingBackdropColor = {self:GetBackdropColor()}
            self:SetBackdropColor(1, 1, 1, 0.3)

            BracketUI:ShowTooltip(self)
        end)

        frame:SetScript("OnLeave", function(self)
            self:SetBackdropColor(unpack(self.startingBackdropColor))
            GameTooltip:Hide()
        end)

        self.highlightRows[i] = frame
    end
end

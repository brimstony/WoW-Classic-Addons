local addonName, twc = ...
local ver = GetAddOnMetadata(addonName, "Version")
local label = string.format("%s v%s",addonName, ver)
local L = twc.L
_G[addonName] = twc
------- Config & Setup -------

function twc.OnLoad(self) 
	print("|cffffff00"..label.." - Use /tankwarnings or /twc for more options.")
	--load default values if they don't exist
	TankWarningsClassicSV = TankWarningsClassicSV or {
--	TankWarningsClassicSV = {
		["firstTime"] = true,
		["raidDoNothing"] = true,
		["raidWarning"] = true,
		["raidChat"] = true,
		["raidYell"] = true,
		["raidSay"] = true,
		["partyDoNothing"] = true,
		["partyChat"] = true,
		["partyYell"] = true,
		["partySay"] = true,
		["noGrpDoNothing"] = true,
		["noGrpYell"] = true,
		["noGrpSay"] = true,
		["showExpirations"] = true,
		["abilities"] = {
			[L["Last Stand"]] = true,
			[L["Shield Wall"]] = true,
			[L["Challenging Shout"]] = true,
			[L["Taunt"]] = true,
			[L["Mocking Blow"]] = true,
			[L["Challenging Roar"]] = true,
			[L["Growl"]] = true,
			[L["Frenzied Regeneration"]] = true,
		},
	}
	
	--Custom messages were introduced in version 1.1.2 - make sure we load them properly
	if TankWarningsClassicSV.messages == nil then
		TankWarningsClassicSV.messages = {}
		TankWarningsClassicSV.messages["%s activated!"] = L["%s activated!"]
		TankWarningsClassicSV.messages["%s will expire in 3 seconds!"] = L["%s will expire in 3 seconds!"]
		TankWarningsClassicSV.messages["%s resisted!"] = L["%s resisted!"]
	end
	
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	if TankWarningsClassicSV.firstTime == true then 
		TankWarningsClassicConfigFrame:Show()
		TankWarningsClassicSV.firstTime = nil
	end

end

function TankWarningsClassic_OnConfigFrameLoaded(self)
	self.name = addonName
	self.okay = function(self)
		self:Show()
	end
	self.cancel = function(self)
		self:Hide()
	end
	--InterfaceOptions_AddCategory(self)
end
function TankWarningsClassic_OnConfigFrameShow(self)
	local configWidgets = {self:GetChildren()}
	-- refresh gui from sv
	for _, widget in pairs(configWidgets) do
		if widget._option then
			local value = (TankWarningsClassicSV[widget._option]~=nil and TankWarningsClassicSV[widget._option])
				or (TankWarningsClassicSV.abilities[widget._option]~=nil and TankWarningsClassicSV.abilities[widget._option])
				or nil
			if value ~= nil then
				widget:SetChecked(value)
			end
		elseif widget._content then
			_G[widget:GetName()]:SetText(TankWarningsClassicSV.messages[widget._content])
		end
	end
	if TankWarningsClassicSV["raidDoNothing"] == false then
		TankWarningsClassicConfigFrameShowRaidWarningButton:Disable()
		TankWarningsClassicConfigFrameShowRaidChatButton:Disable()
		TankWarningsClassicConfigFrameShowRaidYellButton:Disable()
		TankWarningsClassicConfigFrameShowRaidSayButton:Disable()
	end
	if TankWarningsClassicSV["partyDoNothing"] == false then
		TankWarningsClassicConfigFrameShowPartyChatButton:Disable()
		TankWarningsClassicConfigFrameShowPartyYellButton:Disable()
		TankWarningsClassicConfigFrameShowPartySayButton:Disable()
	end
	if TankWarningsClassicSV["noGrpDoNothing"] == false then
		TankWarningsClassicConfigFrameShowNoGrpYellButton:Disable()
		TankWarningsClassicConfigFrameShowNoGrpSayButton:Disable()
	end
end
function TankWarningsClassic_OnConfigFrameClose(self) 
	self:GetParent():Hide()
end

------- Checkmark options -------
function TankWarningsClassic_OnConfigCheckButtonClicked(self)
	if self._option then
		if TankWarningsClassicSV[self._option]~=nil then
			TankWarningsClassicSV[self._option] = not TankWarningsClassicSV[self._option]
		elseif TankWarningsClassicSV.abilities[self._option]~=nil then
			TankWarningsClassicSV.abilities[self._option] = not TankWarningsClassicSV.abilities[self._option]
		end
		if self._option == "raidDoNothing" then
			if TankWarningsClassicSV["raidDoNothing"] == false then
				TankWarningsClassicConfigFrameShowRaidWarningButton:Disable()
				TankWarningsClassicConfigFrameShowRaidChatButton:Disable()
				TankWarningsClassicConfigFrameShowRaidYellButton:Disable()
				TankWarningsClassicConfigFrameShowRaidSayButton:Disable()
			elseif TankWarningsClassicSV["raidDoNothing"] == true then
				TankWarningsClassicConfigFrameShowRaidWarningButton:Enable()
				TankWarningsClassicConfigFrameShowRaidChatButton:Enable()
				TankWarningsClassicConfigFrameShowRaidYellButton:Enable()
				TankWarningsClassicConfigFrameShowRaidSayButton:Enable()
			end
		end
		if self._option == "partyDoNothing" then
			if TankWarningsClassicSV["partyDoNothing"] == false then
				TankWarningsClassicConfigFrameShowPartyChatButton:Disable()
				TankWarningsClassicConfigFrameShowPartyYellButton:Disable()
				TankWarningsClassicConfigFrameShowPartySayButton:Disable()
			elseif TankWarningsClassicSV["partyDoNothing"] == true then
				TankWarningsClassicConfigFrameShowPartyChatButton:Enable()
				TankWarningsClassicConfigFrameShowPartyYellButton:Enable()
				TankWarningsClassicConfigFrameShowPartySayButton:Enable()
			end
		end
		if self._option == "noGrpDoNothing" then
			if TankWarningsClassicSV["noGrpDoNothing"] == false then
				TankWarningsClassicConfigFrameShowNoGrpYellButton:Disable()
				TankWarningsClassicConfigFrameShowNoGrpSayButton:Disable()
			elseif TankWarningsClassicSV["noGrpDoNothing"] == true then
				TankWarningsClassicConfigFrameShowNoGrpYellButton:Enable()
				TankWarningsClassicConfigFrameShowNoGrpSayButton:Enable()
			end
		end

	end
end

------- Messages panel -------
function TankWarningsClassic_EditBoxEventHandler(self, event, ...)
	TankWarningsClassicSV.messages[self._content] = self:GetText()
end

------- Movable (seph) -------
function TankWarningsClassic_OnMouseDown()
	TankWarningsClassicConfigFrame:StartMoving()
end
function TankWarningsClassic_OnMouseUp()
	TankWarningsClassicConfigFrame:StopMovingOrSizing()
end
------- Main logic -------

local playerGUID = UnitGUID("player")
local language = GetLocale()

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self,event,...)
end)
f:RegisterEvent("ADDON_LOADED")

function f:ADDON_LOADED(event, ...)
	if event == "ADDON_LOADED" and ... == addonName then
		twc.OnLoad(self)
		self:UnregisterEvent("ADDON_LOADED")
	end
end

function f:COMBAT_LOG_EVENT_UNFILTERED(event)
	local timestamp, spellType, hideCaster, sourceGUID, sourceName, sourceflags, sourceflags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool = CombatLogGetCurrentEventInfo()
	if sourceGUID == playerGUID then
		--Go out if ability is deactivated
		if not TankWarningsClassicSV.abilities[spellName] then
			return
		end
		
		if spellType == "SPELL_CAST_SUCCESS" then
			--Casts with critical expirations
			if spellName == L["Last Stand"] or spellName == L["Shield Wall"] then
				f:TWC_SendChatMessage(string.format(TankWarningsClassicSV.messages["%s activated!"], spellName))
				if TankWarningsClassicSV.showExpirations == true then
					for i=1,40 do
						local name,icon,count,debuffType,duration,expirationTime = UnitBuff("player",i)
						if name == spellName then
							C_Timer.After(duration-3, function()
									if UnitIsDeadOrGhost("player") ~= true then
										f:TWC_SendChatMessage(string.format(TankWarningsClassicSV.messages["%s will expire in 3 seconds!"], spellName))
									end
								end)
							break
						end
					end
				end
			--Casts without critical expirations
			elseif spellName == L["Challenging Shout"] or spellName == L["Challenging Roar"] or spellName == L["Frenzied Regeneration"] then
				f:TWC_SendChatMessage(string.format(TankWarningsClassicSV.messages["%s activated!"], spellName))
			end
		--Failures
		elseif spellType == "SPELL_MISSED" then
			--We COULD look for the 15th argument of ... here for the type, but we'll just declare any miss as "resisted"
			if spellName == L["Taunt"] or spellName == L["Mocking Blow"] or spellName == L["Growl"] then
				f:TWC_SendChatMessage(string.format(TankWarningsClassicSV.messages["%s resisted!"], spellName))
			end
		end
	end
end

function f:TWC_SendChatMessage(message)
	if IsInRaid() == true then
		if TankWarningsClassicSV.raidDoNothing == true then
			if TankWarningsClassicSV.raidWarning == true then
				SendChatMessage(message, "RAID_WARNING", "Common")
			end
			if TankWarningsClassicSV.raidChat == true then
				SendChatMessage(message, "RAID", "Common")
			end
			if TankWarningsClassicSV.raidYell == true then
				SendChatMessage(message, "YELL", "Common")
			end
			if TankWarningsClassicSV.raidSay == true then
				SendChatMessage(message, "SAY", "Common")
			end
		end
	elseif IsInRaid() ~= true and IsInGroup() == true then
		if TankWarningsClassicSV.partyDoNothing == true then
			if TankWarningsClassicSV.partyChat == true then
				SendChatMessage(message, "PARTY", "Common")
			end
			if TankWarningsClassicSV.partyYell == true then
				SendChatMessage(message, "YELL", "Common")
			end
			if TankWarningsClassicSV.partySay == true then
				SendChatMessage(message, "SAY", "Common")
			end
		end
	elseif IsInRaid() ~= true and IsInGroup() ~= true then
		if TankWarningsClassicSV.noGrpDoNothing == true then
			if TankWarningsClassicSV.noGrpYell == true then
				SendChatMessage(message, "YELL", "Common")
			end
			if TankWarningsClassicSV.noGrpSay == true then
				SendChatMessage(message, "SAY", "Common")
			end
		end
	end
end

SLASH_TWC1 = "/twc"
SLASH_TWC2 = "/tankwarnings"
SLASH_TWC3 = "/tankwarningsclassic"

function SlashCmdList.TWC(msg,editbox)
	if not TankWarningsClassicConfigFrame:IsShown() then
    TankWarningsClassicConfigFrame:Show()
  else 
		TankWarningsClassicConfigFrame:Hide()
  end
end
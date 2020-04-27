local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local D = E:GetModule('Distributor')
local LibCompress = E.Libs.Compress
local LibBase64 = E.Libs.Base64

--Lua functions
local _G = _G
local tonumber, type, gsub, pcall, loadstring = tonumber, type, gsub, pcall, loadstring
local len, format, split, find = strlen, format, strsplit, strfind
--WoW API / Variables
local CreateFrame = CreateFrame
local IsInRaid, UnitInRaid = IsInRaid, UnitInRaid
local IsInGroup, UnitInParty = IsInGroup, UnitInParty
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local ACCEPT, CANCEL, YES, NO = ACCEPT, CANCEL, YES, NO
-- GLOBALS: ElvDB, ElvPrivateDB

----------------------------------
-- CONSTANTS
----------------------------------

local REQUEST_PREFIX = 'ELVUI_REQUEST'
local REPLY_PREFIX = 'ELVUI_REPLY'
local TRANSFER_PREFIX = 'ELVUI_TRANSFER'
local TRANSFER_COMPLETE_PREFIX = 'ELVUI_COMPLETE'

-- The active downloads
local Downloads = {}
local Uploads = {}

function D:Initialize()
	self.Initialized = true
	self:RegisterComm(REQUEST_PREFIX)
	self:RegisterEvent('CHAT_MSG_ADDON')

	self.statusBar = CreateFrame('StatusBar', 'ElvUI_Download', E.UIParent)
	E:RegisterStatusBar(self.statusBar)
	self.statusBar:CreateBackdrop()
	self.statusBar:SetStatusBarTexture(E.media.normTex)
	self.statusBar:SetStatusBarColor(0.95, 0.15, 0.15)
	self.statusBar:Size(250, 18)
	self.statusBar.text = self.statusBar:CreateFontString(nil, 'OVERLAY')
	self.statusBar.text:FontTemplate()
	self.statusBar.text:Point('CENTER')
	self.statusBar:Hide()
end

-- Used to start uploads
function D:Distribute(target, otherServer, isGlobal)
	local profileKey, data
	if not isGlobal then
		if ElvDB.profileKeys then
			profileKey = ElvDB.profileKeys[E.myname..' - '..E.myrealm]
		end

		data = ElvDB.profiles[profileKey]
	else
		profileKey = 'global'
		data = ElvDB.global
	end

	if not data or not profileKey then return end

	local serialData = self:Serialize(data)
	local length = len(serialData)
	local message = format('%s:%d:%s', profileKey, length, target)

	Uploads[profileKey] = {
		serialData = serialData,
		target = target,
	}

	if otherServer then
		if IsInRaid() and UnitInRaid('target') then
			self:SendCommMessage(REQUEST_PREFIX, message, (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and 'INSTANCE_CHAT' or 'RAID')
		elseif IsInGroup() and UnitInParty('target') then
			self:SendCommMessage(REQUEST_PREFIX, message, (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and 'INSTANCE_CHAT' or 'PARTY')
		else
			E:Print(L["Must be in group with the player if he isn\'t on the same server as you."])
			return
		end
	else
		self:SendCommMessage(REQUEST_PREFIX, message, 'WHISPER', target)
	end
	self:RegisterComm(REPLY_PREFIX)
	E:StaticPopup_Show('DISTRIBUTOR_WAITING')
end

function D:CHAT_MSG_ADDON(_, prefix, message, _, sender)
	if prefix ~= TRANSFER_PREFIX or not Downloads[sender] then return end
	local cur = len(message)
	local max = Downloads[sender].length
	Downloads[sender].current = Downloads[sender].current + cur

	if Downloads[sender].current > max then
		Downloads[sender].current = max
	end

	self.statusBar:SetValue(Downloads[sender].current)
end

function D:OnCommReceived(prefix, msg, dist, sender)
	if prefix == REQUEST_PREFIX then
		local profile, length, sendTo = split(':', msg)

		if dist ~= 'WHISPER' and sendTo ~= E.myname then
			return
		end

		if self.statusBar:IsShown() then
			self:SendCommMessage(REPLY_PREFIX, profile..':NO', dist, sender)
			return
		end

		local textString = format(L["%s is attempting to share the profile %s with you. Would you like to accept the request?"], sender, profile)
		if profile == 'global' then
			textString = format(L["%s is attempting to share his filters with you. Would you like to accept the request?"], sender)
		end

		E.PopupDialogs.DISTRIBUTOR_RESPONSE = {
			text = textString,
			OnAccept = function()
				self.statusBar:SetMinMaxValues(0, length)
				self.statusBar:SetValue(0)
				self.statusBar.text:SetFormattedText(L["Data From: %s"], sender)
				E:StaticPopupSpecial_Show(self.statusBar)
				self:SendCommMessage(REPLY_PREFIX, profile..':YES', dist, sender)
			end,
			OnCancel = function()
				self:SendCommMessage(REPLY_PREFIX, profile..':NO', dist, sender)
			end,
			button1 = ACCEPT,
			button2 = CANCEL,
			timeout = 32,
			whileDead = 1,
			hideOnEscape = 1,
		}
		E:StaticPopup_Show('DISTRIBUTOR_RESPONSE')

		Downloads[sender] = {
			current = 0,
			length = tonumber(length),
			profile = profile,
		}

		self:RegisterComm(TRANSFER_PREFIX)
	elseif prefix == REPLY_PREFIX then
		self:UnregisterComm(REPLY_PREFIX)
		E:StaticPopup_Hide('DISTRIBUTOR_WAITING')

		local profileKey, response = split(':', msg)
		if response == 'YES' then
			self:RegisterComm(TRANSFER_COMPLETE_PREFIX)
			self:SendCommMessage(TRANSFER_PREFIX, Uploads[profileKey].serialData, dist, Uploads[profileKey].target)
			Uploads[profileKey] = nil
		else
			E:StaticPopup_Show('DISTRIBUTOR_REQUEST_DENIED')
			Uploads[profileKey] = nil
		end
	elseif prefix == TRANSFER_PREFIX then
		self:UnregisterComm(TRANSFER_PREFIX)
		E:StaticPopupSpecial_Hide(self.statusBar)

		local profileKey = Downloads[sender].profile
		local success, data = self:Deserialize(msg)

		if success then
			local textString = format(L["Profile download complete from %s, would you like to load the profile %s now?"], sender, profileKey)

			if profileKey == 'global' then
				textString = format(L["Filter download complete from %s, would you like to apply changes now?"], sender)
			else
				if not ElvDB.profiles[profileKey] then
					ElvDB.profiles[profileKey] = data
				else
					textString = format(L["Profile download complete from %s, but the profile %s already exists. Change the name or else it will overwrite the existing profile."], sender, profileKey)
					E.PopupDialogs.DISTRIBUTOR_CONFIRM = {
						text = textString,
						button1 = ACCEPT,
						hasEditBox = 1,
						editBoxWidth = 350,
						maxLetters = 127,
						OnAccept = function(popup)
							ElvDB.profiles[popup.editBox:GetText()] = data
							E.Libs.AceAddon:GetAddon('ElvUI').data:SetProfile(popup.editBox:GetText())
							E:StaggeredUpdateAll(nil, true)
							Downloads[sender] = nil
						end,
						OnShow = function(popup) popup.editBox:SetText(profileKey) popup.editBox:SetFocus() end,
						timeout = 0,
						exclusive = 1,
						whileDead = 1,
						hideOnEscape = 1,
						preferredIndex = 3
					}

					E:StaticPopup_Show('DISTRIBUTOR_CONFIRM')
					self:SendCommMessage(TRANSFER_COMPLETE_PREFIX, 'COMPLETE', dist, sender)
					return
				end
			end

			E.PopupDialogs.DISTRIBUTOR_CONFIRM = {
				text = textString,
				OnAccept = function()
					if profileKey == 'global' then
						E:CopyTable(ElvDB.global, data)
						E:StaggeredUpdateAll(nil, true)
					else
						E.Libs.AceAddon:GetAddon('ElvUI').data:SetProfile(profileKey)
					end
					Downloads[sender] = nil
				end,
				OnCancel = function()
					Downloads[sender] = nil
				end,
				button1 = YES,
				button2 = NO,
				whileDead = 1,
				hideOnEscape = 1,
			}

			E:StaticPopup_Show('DISTRIBUTOR_CONFIRM')
			self:SendCommMessage(TRANSFER_COMPLETE_PREFIX, 'COMPLETE', dist, sender)
		else
			E:StaticPopup_Show('DISTRIBUTOR_FAILED')
			self:SendCommMessage(TRANSFER_COMPLETE_PREFIX, 'FAILED', dist, sender)
		end
	elseif prefix == TRANSFER_COMPLETE_PREFIX then
		self:UnregisterComm(TRANSFER_COMPLETE_PREFIX)
		if msg == 'COMPLETE' then
			E:StaticPopup_Show('DISTRIBUTOR_SUCCESS')
		else
			E:StaticPopup_Show('DISTRIBUTOR_FAILED')
		end
	end
end

--Keys that should not be exported
local blacklistedKeys = {
	profile = {
		general = {
			numberPrefixStyle = true,
		},
		chat = {
			hideVoiceButtons = true,
		},
	},
	private = {},
	global = {
		general = {
			UIScale = true,
			locale = true,
			version = true,
			eyefinity = true,
			disableTutorialButtons = true,
			showMissingTalentAlert = true,
		},
		chat = {
			classColorMentionExcludedNames = true,
		},
		nameplate = {
			effectiveHealth = true,
			effectivePower = true,
			effectiveAura = true,
			effectiveHealthSpeed = true,
			effectivePowerSpeed = true,
			effectiveAuraSpeed = true,
			filters = true,
		},
		unitframe = {
			effectiveHealth = true,
			effectivePower = true,
			effectiveAura = true,
			effectiveHealthSpeed = true,
			effectivePowerSpeed = true,
			effectiveAuraSpeed = true,
			spellRangeCheck = true,
		},
	},
}

--Keys that auto or user generated tables.
D.GeneratedKeys = {
	profile = {
		customTexts = true,
		movers = true
	},
	private = {},
	global = {}
}

local function SetCustomVars(data, keys)
	if not data then return end

	local vars = E:CopyTable({}, keys)
	for key in pairs(data) do
		if type(key) ~= 'table' then
			vars[key] = true
		end
	end

	return vars
end

local function GetProfileData(profileType)
	if not profileType or type(profileType) ~= 'string' then
		E:Print('Bad argument #1 to "GetProfileData" (string expected)')
		return
	end

	local profileKey
	local profileData = {}

	if profileType == 'profile' then
		profileKey = ElvDB.profileKeys and ElvDB.profileKeys[E.myname..' - '..E.myrealm]

		local data = ElvDB.profiles[profileKey]
		local vars = SetCustomVars(data, D.GeneratedKeys.profile)

		--Copy current profile data
		profileData = E:CopyTable(profileData, data)
		--This table will also hold all default values, not just the changed settings.
		--This makes the table huge, and will cause the WoW client to lock up for several seconds.
		--We compare against the default table and remove all duplicates from our table. The table is now much smaller.
		profileData = E:RemoveTableDuplicates(profileData, P, vars)
		profileData = E:FilterTableFromBlacklist(profileData, blacklistedKeys.profile)

	elseif profileType == 'private' then
		profileKey = 'private'

		local privateKey = ElvPrivateDB.profileKeys and ElvPrivateDB.profileKeys[E.myname..' - '..E.myrealm]
		local data = ElvPrivateDB.profiles[privateKey]
		local vars = SetCustomVars(data, D.GeneratedKeys.private)

		profileData = E:CopyTable(profileData, data)
		profileData = E:RemoveTableDuplicates(profileData, V, vars)
		profileData = E:FilterTableFromBlacklist(profileData, blacklistedKeys.private)

	elseif profileType == 'global' then
		profileKey = 'global'

		local data = ElvDB.global
		local vars = SetCustomVars(data, D.GeneratedKeys.global)

		profileData = E:CopyTable(profileData, data)
		profileData = E:RemoveTableDuplicates(profileData, G, vars)
		profileData = E:FilterTableFromBlacklist(profileData, blacklistedKeys.global)

	elseif profileType == 'filters' then
		profileKey = 'filters'

		profileData.unitframe = {}
		profileData.unitframe.aurafilters = {}
		profileData.unitframe.aurafilters = E:CopyTable(profileData.unitframe.aurafilters, ElvDB.global.unitframe.aurafilters)
		profileData.unitframe.buffwatch = {}
		profileData.unitframe.buffwatch = E:CopyTable(profileData.unitframe.buffwatch, ElvDB.global.unitframe.buffwatch)
		profileData = E:RemoveTableDuplicates(profileData, G)
	elseif profileType == 'styleFilters' then
		profileKey = 'styleFilters'

		profileData.nameplate = {}
		profileData.nameplate.filters = {}
		profileData.nameplate.filters = E:CopyTable(profileData.nameplate.filters, ElvDB.global.nameplate.filters)
		profileData = E:RemoveTableDuplicates(profileData, G)
	end

	return profileKey, profileData
end

local function GetProfileExport(profileType, exportFormat)
	local profileExport, exportString
	local profileKey, profileData = GetProfileData(profileType)

	if not profileKey or not profileData or (profileData and type(profileData) ~= 'table') then
		E:Print('Error getting data from "GetProfileData"')
		return
	end

	if exportFormat == 'text' then
		local serialData = D:Serialize(profileData)
		exportString = D:CreateProfileExport(serialData, profileType, profileKey)
		local compressedData = LibCompress:Compress(exportString)
		local encodedData = LibBase64:Encode(compressedData)
		profileExport = encodedData

	elseif exportFormat == 'luaTable' then
		exportString = E:TableToLuaString(profileData)
		profileExport = D:CreateProfileExport(exportString, profileType, profileKey)

	elseif exportFormat == 'luaPlugin' then
		profileExport = E:ProfileTableToPluginFormat(profileData, profileType)
	end

	return profileKey, profileExport
end

function D:CreateProfileExport(dataString, profileType, profileKey)
	local returnString

	if profileType == 'profile' then
		returnString = format('%s::%s::%s', dataString, profileType, profileKey)
	else
		returnString = format('%s::%s', dataString, profileType)
	end

	return returnString
end

function D:GetImportStringType(dataString)
	local stringType = ''

	if LibBase64:IsBase64(dataString) then
		stringType = 'Base64'
	elseif find(dataString, '{') then --Basic check to weed out obviously wrong strings
		stringType = 'Table'
	end

	return stringType
end

function D:Decode(dataString)
	local profileInfo, profileType, profileKey, profileData
	local stringType = self:GetImportStringType(dataString)

	if stringType == 'Base64' then
		local decodedData = LibBase64:Decode(dataString)
		local decompressedData, decompressedMessage = LibCompress:Decompress(decodedData)

		if not decompressedData then
			E:Print('Error decompressing data:', decompressedMessage)
			return
		end

		local serializedData, success
		serializedData, profileInfo = E:SplitString(decompressedData, '^^::') -- '^^' indicates the end of the AceSerializer string

		if not profileInfo then
			E:Print('Error importing profile. String is invalid or corrupted!')
			return
		end

		serializedData = format('%s%s', serializedData, '^^') --Add back the AceSerializer terminator
		profileType, profileKey = E:SplitString(profileInfo, '::')
		success, profileData = D:Deserialize(serializedData)

		if not success then
			E:Print('Error deserializing:', profileData)
			return
		end
	elseif stringType == 'Table' then
		local profileDataAsString
		profileDataAsString, profileInfo = E:SplitString(dataString, '}::') -- '}::' indicates the end of the table

		if not profileInfo then
			E:Print('Error extracting profile info. Invalid import string!')
			return
		end

		if not profileDataAsString then
			E:Print('Error extracting profile data. Invalid import string!')
			return
		end

		profileDataAsString = format('%s%s', profileDataAsString, '}') --Add back the missing '}'
		profileDataAsString = gsub(profileDataAsString, '\124\124', '\124') --Remove escape pipe characters
		profileType, profileKey = E:SplitString(profileInfo, '::')

		local profileMessage
		local profileToTable = loadstring(format('%s %s', 'return', profileDataAsString))
		if profileToTable then profileMessage, profileData = pcall(profileToTable) end

		if profileMessage and (not profileData or type(profileData) ~= 'table') then
			E:Print('Error converting lua string to table:', profileMessage)
			return
		end
	end

	return profileType, profileKey, profileData
end

local function SetImportedProfile(profileType, profileKey, profileData, force)
	D.profileType = nil
	D.profileKey = nil
	D.profileData = nil

	if profileType == 'profile' then
		profileData = E:FilterTableFromBlacklist(profileData, blacklistedKeys.profile) --Remove unwanted options from import
		if not ElvDB.profiles[profileKey] or force then
			if force and E.data.keys.profile == profileKey then
				--Overwriting an active profile doesn't update when calling SetProfile
				--So make it look like we use a different profile
				local tempKey = profileKey..'_Temp'
				E.data.keys.profile = tempKey
			end

			ElvDB.profiles[profileKey] = profileData

			--Calling SetProfile will now update all settings correctly
			E.data:SetProfile(profileKey)
		else
			D.profileType = profileType
			D.profileKey = profileKey
			D.profileData = profileData
			E:StaticPopup_Show('IMPORT_PROFILE_EXISTS')

			return
		end
	elseif profileType == 'private' then
		local privateKey = ElvPrivateDB.profileKeys and ElvPrivateDB.profileKeys[E.myname..' - '..E.myrealm]
		if privateKey then
			profileData = E:FilterTableFromBlacklist(profileData, blacklistedKeys.private) --Remove unwanted options from import
			ElvPrivateDB.profiles[privateKey] = profileData
		end

		E:StaticPopup_Show('IMPORT_RL')
	elseif profileType == 'global' then
		profileData = E:FilterTableFromBlacklist(profileData, blacklistedKeys.global) --Remove unwanted options from import
		E:CopyTable(ElvDB.global, profileData)
		E:StaticPopup_Show('IMPORT_RL')
	elseif profileType == 'filters' then
		E:CopyTable(ElvDB.global.unitframe, profileData.unitframe)
	elseif profileType == 'styleFilters' then
		E:CopyTable(ElvDB.global.nameplate, profileData.nameplate)
	end

	--Update all ElvUI modules
	E:StaggeredUpdateAll(nil, true)
end

function D:ExportProfile(profileType, exportFormat)
	if not profileType or not exportFormat then
		E:Print('Bad argument to "ExportProfile" (string expected)')
		return
	end

	local profileKey, profileExport = GetProfileExport(profileType, exportFormat)

	return profileKey, profileExport
end

function D:ImportProfile(dataString)
	local profileType, profileKey, profileData = self:Decode(dataString)

	if not profileData or type(profileData) ~= 'table' then
		E:Print('Error: something went wrong when converting string to table!')
		return
	end

	if profileType and ((profileType == 'profile' and profileKey) or profileType ~= 'profile') then
		SetImportedProfile(profileType, profileKey, profileData)
	end

	return true
end

E.PopupDialogs.DISTRIBUTOR_SUCCESS = {
	text = L["Your profile was successfully recieved by the player."],
	whileDead = 1,
	hideOnEscape = 1,
	button1 = _G.OKAY,
}

E.PopupDialogs.DISTRIBUTOR_WAITING = {
	text = L["Profile request sent. Waiting for response from player."],
	whileDead = 1,
	hideOnEscape = 1,
	timeout = 35,
}

E.PopupDialogs.DISTRIBUTOR_REQUEST_DENIED = {
	text = L["Request was denied by user."],
	whileDead = 1,
	hideOnEscape = 1,
	button1 = _G.OKAY,
}

E.PopupDialogs.DISTRIBUTOR_FAILED = {
	text = L["Lord! It's a miracle! The download up and vanished like a fart in the wind! Try Again!"],
	whileDead = 1,
	hideOnEscape = 1,
	button1 = _G.OKAY,
}

E.PopupDialogs.DISTRIBUTOR_RESPONSE = {}
E.PopupDialogs.DISTRIBUTOR_CONFIRM = {}

E.PopupDialogs.IMPORT_PROFILE_EXISTS = {
	text = L["The profile you tried to import already exists. Choose a new name or accept to overwrite the existing profile."],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	editBoxWidth = 350,
	maxLetters = 127,
	OnAccept = function(self)
		local profileType = D.profileType
		local profileKey = self.editBox:GetText()
		local profileData = D.profileData
		SetImportedProfile(profileType, profileKey, profileData, true)
	end,
	EditBoxOnTextChanged = function(self)
		if self:GetText() == '' then
			self:GetParent().button1:Disable()
		else
			self:GetParent().button1:Enable()
		end
	end,
	OnShow = function(self) self.editBox:SetText(D.profileKey) self.editBox:SetFocus() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3
}

E.PopupDialogs.IMPORT_RL = {
	text = L["You have imported settings which may require a UI reload to take effect. Reload now?"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = _G.ReloadUI,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
}

E:RegisterModule(D:GetName())

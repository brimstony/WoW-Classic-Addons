local ADDON_NAME, HonorTracker = ...
local Config = HonorTracker:RegisterModule("Config")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceRegistry = LibStub("AceConfigRegistry-3.0")
local Brackets = HonorTracker:GetModule("Brackets")
local ResetTime = HonorTracker:GetModule("ResetTime")
local ADDON_VERSION = GetAddOnMetadata(ADDON_NAME, "Version")

local L = HonorTracker.L
local initialOptionsFrame, options

function Config:OnLoad()
	local LDI = LibStub("LibDBIcon-1.0", true)
	local LDB = LibStub("LibDataBroker-1.1", true)
	if( not LDI or not LDB ) then return end
	
	local brokerData = LDB:NewDataObject("HonorTracker",
		{
			type = "data source",
			text = "HonorTracker",
			icon = "Interface\\Icons\\spell_nature_bloodlust",
			OnClick = function(self, button) 
				if( button == "LeftButton" ) then
					HonorTracker:GetModule("BracketUI"):Toggle()
				elseif( button == "MiddleButton" ) then
					if( InterfaceOptionsFrame and InterfaceOptionsFrame:IsVisible() ) then
						InterfaceOptionsFrame:Hide()
					else
						Config:Show()
					end
				elseif( button == "RightButton" ) then
					HonorTracker:GetModule("Stats"):DumpStanding("%t")
				end
			end,
			OnTooltipShow = function(tooltip)
				color = color or HIGHLIGHT_FONT_COLOR
				GameTooltip:AddDoubleLine(line1, line2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
			

				tooltip:AddDoubleLine("HonorTracker", string.format("|cff33ff99%s|r", ADDON_VERSION))
				tooltip:AddDoubleLine(L["Left Click:"], L["Show Standings"],
					NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
				tooltip:AddDoubleLine(L["Right Click:"], L["Show Target Standing"],
					NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
				tooltip:AddDoubleLine(L["Middle Click:"], L["Show Config"],
					NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
			end
		}
	)

	LDI:Register("HonorTracker", brokerData, self.db.config.minimap)
end

function Config:UpdateOptions()
	local totalBlacklisted = 0
	for name, _ in pairs(self.realmBracketDB.senderBlacklist) do
		totalBlacklisted = totalBlacklisted + 1

		options.args.blacklist.args.list.args[name] = {
			order = 1,
			type = "execute",
			name = name,
			func = function(info)
				Config.realmBracketDB.senderBlacklist[name] = nil
				Config:UpdateOptions()
			end,
		}
	end

	for name, _ in pairs(options.args.blacklist.args.list.args) do
		if( name ~= "_help" and not self.realmBracketDB.senderBlacklist[name] ) then
			options.args.blacklist.args.list.args[name] = nil
		end
	end

	if( totalBlacklisted == 0 ) then
		options.args.blacklist.args.list.args._help.name = L["You have not blacklisted data from anyone yet."]
	else
		options.args.blacklist.args.list.args._help.name = string.format(L["Below is the %d |4player:players; you have blacklisted receiving data from."], totalBlacklisted)
	end

	AceRegistry:NotifyChange("HonorTracker")
end

function Config:Show()
	if( not InterfaceOptionsFrame:IsVisible() ) then
		InterfaceOptionsFrame_Show()
	end

	self:UpdateOptions()
	InterfaceOptionsFrame_OpenToCategory(initialOptionsFrame)
end

-- Setup the options frame parent
local containerFrame = CreateFrame("Frame", nil, InterfaceOptionsFrame)
containerFrame.name = "HonorTracker"
containerFrame:SetScript("OnShow", function() Config:Show() end)
containerFrame:Hide()
InterfaceOptions_AddCategory(containerFrame)

local currentRegionText
if( GetCurrentRegion() == 1 ) then
	currentRegionText = L["US, Brazil, and Oceania"]
elseif( GetCurrentRegion() == 2 ) then
	currentRegionText = L["Korea"]
elseif( GetCurrentRegion() == 3 ) then
	currentRegionText = L["Europe and Russia"]
elseif( GetCurrentRegion() == 4 ) then
	currentRegionText = L["Taiwan"]
elseif( GetCurrentRegion() == 5 ) then
	currentRegionText = L["China"]
end

-- Create the options menu child frames
options = {
	type = "group",
    args = {
		general = {
			type = "group",
			name = L["General"],
			set = function(info, value)
				HonorTracker.db.config[info[#(info)]] = value
			end,
			get = function(info)
				return HonorTracker.db.config[info[#(info)]]
			end,
			args = {
				tooltips = {
					order = 1,
					type = "toggle",
					name = L["Show DR Tooltips"],
					desc = L["Displays how many times you have killed someone on mouseover tooltips."],
					width = "full",
				},				
				internalComms = {
					order = 2,
					type = "toggle",
					name = L["Sync using only guild channels"],
					desc = L["Only syncs new player data using guild channels, useful when random people are spamming bad data."],
					width = "full",
				},
				batchHonor = {
					order = 3,
					type = "toggle",
					name = L["Batch honor gain messages together in combat"],
					desc = L["While in combat, you will not see any honor gain messages, and once you leave combat you'll get a summary of honor gained."],
					width = "full",
				},
				hideMinimap = {
					order = 4,
					type = "toggle",
					name = L["Hide minimap button"],
					desc = L["Hide the minimap button."],
					width = "full",
					set = function(info, value)
						HonorTracker.db.config.minimap.hide = not HonorTracker.db.config.minimap.hide

						local LDI = LibStub("LibDBIcon-1.0", true)
						if( LDI ) then
							if( HonorTracker.db.config.minimap.hide ) then
								LDI:Hide("HonorTracker")
							else
								LDI:Show("HonorTracker")
							end
						end
					end,
					get = function(info)
						return HonorTracker.db.config.minimap.hide
					end,
				}
			}
		},
		dailyReset = {
			type = "group",
			name = L["Daily Reset"],
			args = {
				help = {
					order = 0,
					type = "group",
					inline = true,
					name = L["Help"],
					args = {
						help1 = {
							order = 0,
							type = "description",
							name = L["Blizzard periodically has problems during their resets, and they will have happened without the in-game values updating."],
						},
						help2 = {
							order = 0,
							type = "description",
							name = L["In some areas we will use the actual time it's supposed to roll over, as a way of detecting a day change without relying on 'Yesterday' data updating."],
						},
					},
				},
				override = {
					order = 1,
					type = "group",
					inline = true,
					name = L["Region Override"],
					args = {
						help1 = {
							order = 0,
							type = "description",
							name = L["In some scenarios, the client region will be incorrect. You can override the region we use to calculate reset times, which will ensure you don't have premature resets."]
						},
						help2 = {
							order = 0.5,
							type = "description",
							name = "",
						},
						override = {
							order = 1,
							type = "select",
							name = "",
							values = {
								[""] = string.format(L["Client Default (%s)"], currentRegionText),
								[1] = L["US, Brazil, and Oceania"],
								[2] = L["Korea"],
								[3] = L["Europe and Russia"],
								[4] = L["Taiwan"],
								[5] = L["China"],
							},
							set = function(info, value)
								HonorTracker.db.config.regionOverride = tonumber(value)

								local dailyStart, dailyEnd = ResetTime:DailyWindow(true)
								local weeklyStart, weeklyEnd = ResetTime:WeeklyWindow(true)
								HonorTracker.db.resetTime = {
									dailyStart = dailyStart,
									dailyEnd = dailyEnd,
									weeklyStart = weeklyStart,
									weeklyEnd = weeklyEnd,
									version = ResetTime.VERSION
								}
							end,
							get = function()
								return HonorTracker.db.config.regionOverride or ""
							end,
						}
					},
				},
				timing = {
					order = 2,
					type = "group",
					inline = true,
					name = L["Reset Window"],
					args = {
						now = {
							order = 0,
							type = "description",
							name = function()
								return string.format(L["Your Time: |cffffd100%s|r\nNext Daily Reset: |cffffd100%s|r\nNext Weekly Reset: |cffffd100%s|r"],
									date("%x %X", GetServerTime()),
									date("%x %X", HonorTracker.db.resetTime.dailyEnd),
									date("%x %X", HonorTracker.db.resetTime.weeklyEnd)
								)
							end,
						},
						help = {
							order = 1,
							type = "description",
							name = string.format(L["If the values for the above are not correct, please let us know on CurseForge and give your region ID of '%d'."], ResetTime:GetCurrentRegion())
						}
					},
				},
			}
		},
		blacklist = {
			type = "group",
			name = L["Blacklist"],
			set = function(info, value)
				HonorTracker.db.config[info[#(info)]] = value
			end,
			get = function(info)
				return HonorTracker.db.config[info[#(info)]]
			end,
			args = {
				help = {
					order = 0,
					type = "group",
					inline = true,
					name = L["Help"],
					args = {
						help = {
							order = 0,
							type = "description",
							name = L["On some servers, people will send fake data which corrupts your database. You can ignore their data here, which will also automatically delete any recorded data from them."],
						},
					},
				},
				add = {
					order = 1,
					name = L["Add to Blacklist"],
					inline = true,
					type = "group",
					set = function(info, value) Config.addToBlacklistName = value end,
					get = function(info) return Config.addToBlacklistName end,
					args = {
						name = {
							order = 0,
							type = "input",
							name = L["Player name"],
							desc = L["The player name to blacklist receiving data from."],
						},
						add = {
							order = 1,
							type = "execute",
							name = L["Add"],
							disabled = function() return not Config.addToBlacklistName or Config.addToBlacklistName == "" or Config.addToBlacklistName == UnitName("player") end,
							func = function(info)
								name = string.trim(Config.addToBlacklistName)
								name = name ~= "" and name or nil

								Config.realmBracketDB.senderBlacklist[name] = true
								Config.addToBlacklistName = nil

								Brackets:PurgeBlacklistedData()
								Config:UpdateOptions()
							end,
						},
					},
				},
				list = {
					order = 2,
					name = L["Blacklist"],
					inline = true,
					type = "group",
					args = {
						_help = {
							order = 0,
							type = "description",
							name = "",
						}
					}
				}
			}
		}
    }
}

AceConfig:RegisterOptionsTable("HonorTracker", options)
initialOptionsFrame = AceConfigDialog:AddToBlizOptions("HonorTracker", options.args.general.name, "HonorTracker", "general")
AceConfigDialog:AddToBlizOptions("HonorTracker", options.args.dailyReset.name, "HonorTracker", "dailyReset")
AceConfigDialog:AddToBlizOptions("HonorTracker", options.args.blacklist.name, "HonorTracker", "blacklist")

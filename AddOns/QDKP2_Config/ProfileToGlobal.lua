--used to translates the variable names used in the profile with the global name of the configuration variables used in the QDKP2 and QDKP2_GUI code.
--This file should be deleted when QDKP will be modified to use configuration profiles

QDKP2_Config.TransTable={

	--GUI
	GUI_ClassBased="QDKP2_USE_CLASS_BASED_COLORS",
	GUI_DefaultColor="QDKP2GUI_Roster.PlayersColor.Default",
	GUI_ModifiedColor="QDKP2GUI_Roster.PlayersColor.Modified",
	GUI_StandbyColor="QDKP2GUI_Roster.PlayersColor.Standby",
	GUI_AltColor="QDKP2GUI_Roster.PlayersColor.Alt",
	GUI_ExtColor="QDKP2GUI_Roster.PlayersColor.External",
	GUI_NoGuildColor="QDKP2GUI_Roster.PlayersColor.NoGuild",
	GUI_NoClassColor="QDKP2GUI_Roster.PlayersColor.NoClass",

	--On Demand
	ODS_Enable="QDKP2_ODS_ENABLE",
	ODS_EnDKP="QDKP2_NOD",
	ODS_EnREPORT="QDKP2_ROD",
	ODS_EnPRICE="QDKP2_POD",
	ODS_EnBOSS="QDKP2_AOD",
	ODS_EnCLASS="QDKP2_COD",
	ODS_EnRANK="QDKP2_KOD",
	ODS_ViewWhisp="QDKP2_OS_VIEWWHSP",
	ODS_ReqAll="QDKP2_IOD_REQALL",
	ODS_LetExt="QDKP_OD_EXT",
	ODS_TopTenLen="QDKP2_POD_MINKEYWORD",
	ODS_PriceLen="QDKP2_POD_MAXRESULTS",
	ODS_BossLen="QDKP2_AOD_MAXRESULTS",
	ODS_PricesKWLen="QDKP2_POD_MINKEYWORD",
	ODS_BossKWLen="QDKP2_AOD_MINKEYWORD",

	--Bid Manager
	BM_Keywords="QDKP2_BidM_Keywords",
	BM_AnnounceStart="QDKP2_BidM_AnnounceStart",
	BM_AnnounceWinner="QDKP2_BidM_AnnounceWinner",
	BM_AnnounceCancel="QDKP2_BidM_AnnounceCancel",
	BM_AnnounceStartChannel="QDKP2_BidM_ChannelStart",
	BM_AnnounceWinnerChannel="QDKP2_BidM_ChannelWin",
	BM_AnnounceCancelChannel="QDKP2_BidM_ChannelCanc",
	BM_Countdown="QDKP2_BidM_CountStop",
	BM_CountdownChannel="QDKP2_BidM_ChannelCount",
	BM_CountdownLen="QDKP2_BidM_CountAmount",
	BM_AnnounceStartText="QDKP2_BidM_StartString",
	BM_AnnounceWinnerDKPText="QDKP2_BidM_WinnerString",
	BM_AnnounceWinnerText="QDKP2_BidM_WinnerStringNoDKP",
	BM_AnnounceCancelText="QDKP2_BidM_CancelString",
	BM_AllowMultiple="QDKP2_BidM_AllowMultipleBid",
	BM_AllowLesser="QDKP2_BidM_AllowLesserBid",
	BM_OverBid="QDKP2_BidM_OverBid",
	BM_TestBets="QDKP2_BidM_RefreshBets",
	BM_OutGuild="QDKP2_BidM_CanOutGuild",
	BM_AutoRoll="QDKP2_BidM_AutoRoll",
	BM_MinBid="QDKP2_BidM_MinBid",
	BM_MaxBid="QDKP2_BidM_MaxBid",
	BM_CatchRolls='QDKP2_BidM_CatchRoll',
	BM_HideWhisp='QDKP2_BidM_HideWispBids',
	BM_GetWhispers='QDKP2_BidM_GetFromWhisper',
	BM_GetGroup='QDKP2_BidM_GetFromGroup',
	BM_GiveToWinner='QDKP2_BidM_GiveItemToWinner',
	BM_AckBets='QDKP2_BidM_AckBids',
	BM_AckBetsChannel='QDKP2_BidM_ChannelAck',
	BM_AckReject='QDKP2_BidM_AckRejBids',
	BM_AckRejectChannel='QDKP2_BidM_ChannelReject',
	BM_ConfirmWinner='QDKP2_BidM_ConfirmWin',
	BM_LogBets='QDKP2_BidM_LogBids',
	BM_RoundValue = 'QDKP2_BidM_RoundValue',

	--Awarding
	Boss_Instance='QDKP2_Instances',
	Boss_Names='QDKP2_Bosses',
	AW_ZS_UseAsCharge='QDKP2_CHARGEWITHZS',
	AW_ZS_GiveZS2Payer='QDKP_GIVEZSTOLOOTER',
	AW_TIM_Period='QDKP2_TIME_UNTIL_UPLOAD',
	AW_TIM_ShowAward='QDKP_TIMER_SHOW_AWARDS',
	AW_TIM_RaidLogTicks='QDKP_TIMER_RAIDLOG_TICK',
	AW_IM_PercReq='QDKP2_IRONMAN_PER_REQ',
	AW_IM_InWhenStarts='QDKP2_IRONMAN_INWHENSTARTS',
	AW_IM_InWhenEnds='QDKP2_IRONMAN_INWHENENDS',
	AW_BA_OfflineCtl='QDKP2_AWARD_OFFLINE_RAIDAWARD',
	AW_TIM_OfflineCtl='QDKP2_AWARD_OFFLINE_TIMER',
	AW_ZS_OfflineCtl='QDKP2_AWARD_OFFLINE_ZEROSUM',
	AW_IM_OfflineCtl='QDKP2_AWARD_OFFLINE_IRONMAN',
	AW_BA_ZoneCtl='QDKP2_AWARD_ZONE_RAIDAWARD',
	AW_TIM_ZoneCtl='QDKP2_AWARD_ZONE_TIMER',
	AW_ZS_ZoneCtl='QDKP2_AWARD_ZONE_ZEROSUM',
	AW_IM_ZoneCtl='QDKP2_AWARD_ZONE_IRONMAN',
	AW_BA_RankCtl='QDKP2_AWARD_RANK_RAIDAWARD',
	AW_TIM_RankCtl='QDKP2_AWARD_RANK_TIMER',
	AW_ZS_RankCtl='QDKP2_AWARD_RANK_ZEROSUM',
	AW_IM_RankCtl='QDKP2_AWARD_RANK_IRONMAN',
	AW_BA_AltCtl='QDKP2_AWARD_ALT_RAIDAWARD',
	AW_TIM_AltCtl='QDKP2_AWARD_ALT_TIMER',
	AW_ZS_AltCtl='QDKP2_AWARD_ALT_ZEROSUM',
	AW_IM_AltCtl='QDKP2_AWARD_ALT_IRONMAN',
	AW_BA_StandbyCtl='QDKP2_AWARD_STANDBY_RAIDAWARD',
	AW_TIM_StandbyCtl='QDKP2_AWARD_STANDBY_TIMER',
	AW_ZS_StandbyCtl='QDKP2_AWARD_STANDBY_ZEROSUM',
	AW_IM_StandbyCtl='QDKP2_AWARD_STANDBY_IRONMAN',
	AW_BA_ExternalCtl='QDKP2_AWARD_EXTERNAL_RAIDAWARD',
	AW_TIM_ExternalCtl='QDKP2_AWARD_EXTERNAL_TIMER',
	AW_ZS_ExternalCtl='QDKP2_AWARD_EXTERNAL_ZEROSUM',
	AW_IM_ExternalCtl='QDKP2_AWARD_EXTERNAL_IRONMAN',

	--Announcements
	AN_AnAwards="QDKP2_AnnounceAwards",
	AN_AnIM="QDKP2_AnnounceIronman",
	AN_AnPlChange="QDKP2_AnnounceDKPChange",
	AN_AnNegative="QDKP2_AnnounceNegative",
	AN_AnTimerTick="QDKP2_AnnounceTimertick",
	AN_AnChannel="QDKP2_AnnounceChannel",
	AN_PushChanges="QDKP2_AnnounceWhisper",
	AN_PushFailAw="QDKP2_AnnounceFailAw",
	AN_PushFailHo="QDKP2_AnnounceFailHo",
	AN_PushFailIM="QDKP2_AnnounceFailIM",
	AN_PushModText="QDKP2_AnnounceWhisperTxt",
	AN_PushModReasText="QDKP2_AnnounceWhisperRes",
	AN_PushRevText="QDKP2_AnnounceWhisperRev",

	--Guild Notes
	FOR_OfficerOrPublic='QDKP2_OfficerOrPublic',
	FOR_TotalOrSpent='QDKP2_TotalOrSpent',
	FOR_CompactNote='QDKP2_CompactNoteMode',
	FOR_StoreHours='QDKP2_StoreHours',
	FOR_ImportAlts='QDKP2_AutoLinkAlts',

	--Looting
	LOOT_OpenToolbox='QDKP2_AlwaysOpenToolbox',
	LOOT_Qual_RaidLog='MIN_LOGGED_RAID_LOOT_QUALITY',
	LOOT_Qual_PlayerLog='MIN_LOGGED_LOOT_QUALITY',
	LOOT_Qual_ChargeKey='MIN_CHARGABLE_LOOT_QUALITY',
	LOOT_Qual_ChargeChat='MIN_CHARGABLE_CHAT_QUALITY',
	LOOT_Qual_ReasonHist='MIN_LISTABLE_QUALITY',
	LOOT_Qual_PopupTB='MIN_POPUP_TOOLBOX_Q',
	LOOT_LogBadge='QDKP2_LogBadges',
	LOOT_LogDisench='QDKP2_LogShards',
	LOOT_ItemPrices='QDKP2_ChargeLoots',
	LOOT_LootsLog='QDKP2_LogLoots',
	LOOT_LootsNoLog='QDKP2_NotLogLoots',

--Misc
	MISC_MaxNetDKP='QDKP2_MAXIMUM_NET',
	MISC_MinNetDKP='QDKP2_MINIMUM_NET',
	AW_SpecialRanks='QDKP2_UNDKPABLE_RANK',
	MISC_HidRanks='QDKP2_HIDE_RANK',
	MISC_MinLevel='QDKP2_MINIMUM_LEVEL',
	MISC_UploadOn_Raid='QDKP2_SENDTRIG_RAIDAWARD',
	MISC_UploadOn_Tick='QDKP2_SENDTRIG_TIMER_TICK',
	MISC_UploadOn_Hourly='QDKP2_SENDTRIG_TIMER_AWARD',
	MISC_UploadOn_IronMan='QDKP2_SENDTRIG_IRONMAN',
	MISC_UploadOn_Payment='QDKP2_SENDTRIG_CHARGE',
	MISC_UploadOn_Modif='QDKP2_SENDTRIG_MODIFY',
	MISC_UploadOn_ZS='QDKP2_SENDTRIG_ZS',
	MISC_PromptWinDetect='QDKP2_PROMPT_AWDS',
	MISC_DetectWinTrig='QDKP2_WinTrigger',
	LOG_MaxRaid='QDKP2_LOG_RAIDMAXSIZE',
	LOG_MaxPlayer='QDKP2_LOG_MAXSIZE',
	LOG_MaxSession='QDKP2_LOG_MAXSESSIONS',
	MISC_Inf_WentNeg='QDKP2_CHANGE_NOTIFY_WENT_NEGATIVE',
	MISC_Inf_IsNeg='QDKP2_CHANGE_NOTIFY_NEGATIVE',
	MISC_Inf_NewMember='QDKP2_REPORT_NEW_GUILDMEMBER',
	MISC_Inf_NoInGuild='QDKP2_ALERT_NOT_IN_GUILD',
	MISC_Report_Header='QDKP2_Reports_Header',
	MISC_Report_Tail='QDKP2_Reports_Tail',
	MISC_Export_Header='QDKP2_Export_TXT_Header',
	MISC_NotifyText='QDKP2_LOC_NotifyString',
	MISC_NotifyText3rd='QDKP2_LOC_NotifyString_u3p',
	MISC_TimeInHours='QDKP2_DATE_TIME_TO_HOURS',
	MISC_TimeInDOW='QDKP2_DATE_TIME_TO_DAYS',
	MISC_TimeZoneCtl='QDKP2_LOCALTIME_MANUALDELTA',

	
	--Dummies. Used to block exceptions when modifing vars used only by QDKP2_Config
	BRC_AutoSendEn='a',
	BRC_AutoSendTime='a',
	BRC_OverrideBroadcast='a',

}
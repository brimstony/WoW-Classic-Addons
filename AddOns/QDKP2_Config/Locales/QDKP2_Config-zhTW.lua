-- Traditional Chinese (BY Miruido) 感謝 其實我不是小泡泡 漢化推薦

local L = LibStub("AceLocale-3.0"):NewLocale("QDKP2_Config", "zhTW")

if L then

--Generic strings
L.QDKP2="Quick DKP V2"
L.Instance10 = "10 普通"
L.Instance10H = "10 英雄"
L.Instance25 = "25 普通"
L.Instance25H = "25 英雄"
L.Roster = "名單"
L.Log = "記錄"
L.Success="成功!"
L.Confirm="請確認"

--GUI tree
L.GUI=	"控制台選項"
L.GUI_ClassBased = "按職業著色"
L.GUI_ClassBased_d = "在名單中按職業著色"
L.GUI_DefaultColor = "默認顏色"
L.GUI_DefaultColor_d = "默認染色"
L.GUI_ModifiedColor = "未上傳的改動"
L.GUI_ModifiedColor_d = "未上傳的改動"
L.GUI_StandbyColor = "替補人員"
L.GUI_StandbyColor_d = "為替補人員染色"
L.GUI_AltColor = "關聯小號"
L.GUI_AltColor_d = "為關聯小號染色"
L.GUI_ExtColor = "會外編制人員"
L.GUI_ExtColor_d = "為會外編制染色"
L.GUI_NoGuildColor = "會外非臨時編制人員"
L.GUI_NoGuildColor_d = "為會外非臨時編制人員染色"
L.GUI_NoClassColor = "未知職業"
L.GUI_NoClassColor_d = "為未知職業染色"

L.ODS="問詢系統"
L.ODS_Enable = "啟用"
L.ODS_Enable_d = "啟用禁用需求系統"
L.KWHeaders = "關鍵字"
L.ODS_EnDKP = '啟用 "?dkp"'
L.ODS_EnDKP_d = "啟用這個關鍵字來問DKP"
L.ODS_EnREPORT = '啟用 "?report"'
L.ODS_EnREPORT_d = "啟用這個關鍵字來問統計記錄。"
L.ODS_EnPRICE = '啟用 "?price"'
L.ODS_EnPRICE_d = "啟用這個關鍵字來問物品需要的DKP"
L.ODS_EnBOSS = '啟用 "?boss"'
L.ODS_EnBOSS_d = "啟用這個關鍵字來問BOSS加分。"
L.ODS_EnCLASS = '啟用 "?classdkp 職業"'
L.ODS_EnCLASS_d = "啟用這個關鍵字來問職業DKP清單"
L.ODS_EnRANK = '啟用 "?rank"'
L.ODS_EnRANK_d = "啟用這個關鍵字來問某會階DKP列表"
L.OptionHeaders = "選項"
L.ODS_ViewWhisp = "查看密語"
L.ODS_ViewWhisp_d = "顯示問詢的密語"
L.ODS_ReqAll = "允許問詢其他公共玩家的DKP"
L.ODS_ReqAll_d = "允許玩家問詢其他公會成員的資料。"
L.ODS_LetExt = "允許其他公會的玩家問詢DKP"
L.ODS_LetExt_d = "允許其他公會的玩家問詢DKP。"
L.ODS_TopTenLen = "排行榜人數"
L.ODS_TopTenLen_d = "職業DKP排行榜的數量"
L.ODS_PriceLen = "詢問物品數量"
L.ODS_PriceLen_d = "當問詢物品DKP時，顯示的物品數量。"
L.ODS_BossLen = "詢問BOSS擊殺加分"
L.ODS_BossLen_d =  "當問詢BOSS擊殺加分時，顯示的BOSS數量。"
L.ODS_PricesKWLen = "詢問物品DKP的最少關鍵字長度"
L.ODS_PricesKWLen_d = "當問詢物品DKP時，關鍵字的最短字數。"
L.ODS_BossKWLen = "詢問BOSS擊殺DKP的最少關鍵字長度"
L.ODS_BossKWLen_d = "當問詢BOSS擊殺DKP時，關鍵字的最短字數。"

L.BidManager="競價助手"
L.BidOptions="常規出價設置"
L.AnnouceHeader = "通報選項"
L.BM_AnnounceStart = "通報開始"
L.BM_AnnounceStart_d = "在指定頻道中通報競標開始。"
L.BM_AnnounceWinner = "通報獲勝者。"
L.BM_AnnounceWinner_d = "在指定頻道中通報競獲勝者。"
L.BM_AnnounceCancel = "通報取消"
L.BM_AnnounceCancel_d = "在指定頻道中通報競標取消。"
L.BM_AnnounceStartChannel = "開始頻道"
L.BM_AnnounceWinnerChannel = "獲勝者頻道"
L.BM_AnnounceCancelChannel = "取消頻道"
L.BM_AnnounceChannel_d = '發送通報的頻道。按照你所在的隊伍類型自動調整。'
L.BM_Countdown = "啟用倒計時"
L.BM_Countdown_d = "當你宣佈獲勝者時啟用一個倒計時，如果在倒計時時有人出分，則倒計時會被取消。"
L.BM_CountdownChannel = "倒計時頻道"
L.BM_CountdownLen = "倒計時長度"
L.BM_AnnounceStartText = "開始文本"
L.BM_AnnounceStartText_d = "宣佈競分開始的文本。$ITEM代表物品名字。"
L.BM_AnnounceWinnerDKPText = "獲勝者(含DKP)文本"
L.BM_AnnounceWinnerDKPText_d = "宣佈競分獲勝者的文本。$ITEM代表物品名字。$NAME代表獲勝者名字。"
L.BM_AnnounceWinnerText = "獲勝者(不含DKP)文本"
L.BM_AnnounceWinnerText_d = "宣佈競分獲勝者的文本。$ITEM代表物品名字。$NAME代表獲勝者名字。"
L.BM_AnnounceCancelText = "取消文本"
L.BM_AnnounceCancelText_d = "宣佈競分取消的文本。$ITEM代表物品名字。"
L.BiddingOptionHeader = "競分選項"
L.BM_AllowMultiple = "允許多次出分"
L.BM_AllowMultiple_d = "如果禁用，則只允許出一次分。ROLL點的話，則始終只允許ROLL一次。"
L.BM_AllowLesser = "允許比當前分數低的出分"
L.BM_AllowLesser_d = "允許比當前分數低的出分"
L.BM_OverBid = "允許超額出分"
L.BM_OverBid_d = "允許超過當前DKP出分"
L.BM_TestBets = "取消無效競分"
L.BM_TestBets_d = "這會檢查每一次出分是否有效。"
L.BM_OutGuild = "允許公會外人員出分"
L.BM_OutGuild_d = "允許公會外收編人員出分。"
L.BM_AutoRoll = "自動ROLL"
L.BM_AutoRoll_d = "如果啟用，當實行ROLL點+DKP分配模式時，如果一個成員沒有ROLL點就出分，外掛程式生成一個亂數作為其ROLL點，禁用這個選項則會提醒他先ROLL點。"
L.BM_MinBid = "出分下限"
L.BM_MinBid_d="出分下限"
L.BM_MaxBid = "出分上限"
L.BM_MaxBid_d="出分上限"
L.MiscHeader="其他選項"
L.BM_CatchRolls="偵測 /roll"
L.BM_CatchRolls_d="偵測 /roll，並且要求團員在出價時/roll。"
L.BM_HideWhisp="隱藏競分密語"
L.BM_HideWhisp_d="隱藏聊天框中競分的密語"
L.BM_GetWhispers="密語競分"
L.BM_GetWhispers_d="允許密語競分"
L.BM_GetGroup="團隊競分"
L.BM_GetGroup_d="允許在團隊，小隊，戰場頻道競分。"
L.BM_GiveToWinner="把裝備分給獲得競標的玩家。"
L.BM_GiveToWinner_d='當宣佈裝備獲勝者時，嘗試自動分配這個裝備。\n注意:\n-分配方式必須為“隊長分配”\n-競拍主持者是拾取人\n-拾取視窗打開並且物品依然在拾取視窗內。\n獲勝者必須有權利獲得該物品。'
L.BM_AckBets="確認有效競分。"
L.BM_AckBets_d="當收到有效競分時通知。"
L.BM_AckReject="標注無效競分。"
L.BM_AckReject_d="當競分無效時通知，並說明原因。"
L.BM_AckRejectChannel="無效競分通知頻道"
L.BM_AckBetsChannel="有效精分通知頻道"
L.BM_AckChannel_d='發送通知的頻道。'
L.BM_ConfirmWinner="確認獲勝者"
L.BM_ConfirmWinner_d="在宣佈獲勝者之前確認"
L.BM_LogBets = "記錄競拍"
L.BM_LogBets_d = "在玩家記錄中記錄競拍。"
L.BM_RoundValue = "數值取整"
L.BM_RoundValue_d = '數值取整。DKP分數無視這個選項總是取整。'
L.BidKeywords='關鍵字編輯'
L.BM_KW_Keyword='關鍵字'
L.BM_KW_Keyword_d='輸入關鍵字，多個關鍵字用逗號隔開。'
L.BM_KW_Value='競價標識'
L.BM_KW_Value_d='輸入競價關鍵字. 如果省略, 任何數位都會被看做競分。'
L.BM_KW_DKP='DKP標識'
L.BM_KW_DKP_d='如果想與競分關鍵字不同, 請另外輸入一個關鍵字。'
L.BM_KW_Min='最小值'
L.BM_KW_Min_d='如果與競分下限不同，請注明。'
L.BM_KW_Max='最大值'
L.BM_KW_Max_d='如果與競分上限不同，請注明。'
L.BM_KW_Eligible='資格'
L.BM_KW_Eligible_d='如果需要，在此輸入一個關鍵字來確認競拍資格。'
L.BM_KW_Test="測試關鍵字"
L.BM_KW_Test_d="測試當前關鍵字。 "
L.BM_KW_Del='刪除關鍵字'
L.DefaultKWProfile='當前模式'
L.DefaultKWProfile_d=
'改變後不可還原之前的設置。'


L.DefaultKWProfile_c="改變關鍵字模式會替換你之前所有的關鍵字。"

L.Awarding="加分"
L.BA="擊殺獎勵"
L.ByInstance="按副本設置"
L.InstHelpText='在此你可以設置在特定的副本中每當一個BOSS被擊殺時的加分。'
L.ByName="按名字設置"
L.AddNewBoss="增加一個新首領"
L.TIM="時間獎勵"
L.AW_TIM_Period="記錄頻率"
L.AW_TIM_Period_d="兩次時間記錄的間隔，必須是6的倍數。"
L.AW_TIM_ShowAward="通報時間加分。"
L.AW_TIM_ShowAward_d="當團隊成員獲得時間加分時通報。"
L.AW_TIM_RaidLogTicks="記錄時間加分。"
L.AW_TIM_RaidLogTicks_d="在團隊記錄中記錄每一次時間加分。"
L.IM='全程獎勵'
L.AW_IM_PercReq="參加要求"
L.AW_IM_PercReq_d="參加全程獎勵的出勤率"
L.AW_IM_InWhenStarts="加入時在場"
L.AW_IM_InWhenStarts_d="啟用時，玩家必須從全程獎勵開始在團隊中線上才能獲得獎勵。"
L.AW_IM_InWhenEnds="結束時在場"
L.AW_IM_InWhenEnds_d="啟用時，玩家必須從全程獎勵結束時在團隊中線上才能獲得獎勵。"
L.ZS="平分加分"
L.AW_ZS_UseAsCharge="啟用平分加分"
L.AW_ZS_UseAsCharge_d="把平分加分設為預設消費方式。而不是純粹的DKP消費。"
L.AW_ZS_GiveZS2Payer="含出分玩家"
L.AW_ZS_GiveZS2Payer_d="啟用時，出分的玩家也會被算在平分加分的列表中。"
L.AW_CtlHeader = "加分規則"
L.AW_OfflineCtl = "離線"
L.AW_ZoneCtl = "不在區域內"
L.AW_RankCtl = "特定會階"
L.AW_AltCtl = "關聯小號"
L.AW_StandbyCtl = "替補"
L.AW_ExternalCtl = "會外編制"
L.AW_OfflineCtl_d = "調整離線團員的DKP獲取百分比。"
L.AW_ZoneCtl_d = "調整區域外團員的DKP獲取百分比。"
L.AW_RankCtl_d = "調整在選項中指定會階團隊的DKP獲取百分比。"
L.AW_AltCtl_d = "調整關聯小號的DKP獲取百分比。 "
L.AW_StandbyCtl_d = "調整手動添加到團隊列表中的替補人員的DKP獲取百分比。"
L.AW_ExternalCtl_d = "調整會外編制人員的DKP獲取百分比。"
L.AW_Boss_CustomAmount = "自訂數量"
L.AW_Boss_RemoveBoss = "取消首領條目"
L.AW_Boss_SelectBoss10 = "10-man 人數"
L.AW_Boss_SelectBoss25 = "25-man 人數"
L.AW_Boss_SelectBoss_d = '設置擊殺這個首領的加分。'
L.AW_Boss_Name = "首領名稱"
L.AW_Boss_Name_d = "請輸入BOSS名稱。"
L.AW_Boss_UseTarget="輸入當前目標的名稱。"

L.Misc="其他"
L.MISC_MaxNetDKP="最高當前DKP"
L.MISC_MinNetDKP="最低當前DKP"
L.AW_SpecialRanks="特殊會階"
L.MISC_HidRanks="隱藏會階"
L.MISC_MinLevel="最低等級"
L.MISC_UploadOn_Raid="在團隊加分時"
L.MISC_UploadOn_Tick="在計時時"
L.MISC_UploadOn_Hourly="在計時完成時"
L.MISC_UploadOn_IronMan="在全程獎勵時"
L.MISC_UploadOn_Payment="在消費時"
L.MISC_UploadOn_Modif="在編輯時"
L.MISC_UploadOn_ZS="在平分加分時"
L.MISC_PromptWinDetect="提示獲勝者細節。"
L.MISC_DetectWinTrig="獲勝者資訊觸發器"
L.LOG_MaxRaid="團隊記錄長度上限"
L.LOG_MaxPlayer="個人記錄長度上限"
L.LOG_MaxSession="活動數量上限"
L.MISC_Inf_WentNeg="通知進入負分"
L.MISC_Inf_IsNeg="當負分時通知"
L.MISC_Inf_NewMember="提示新公會成員"
L.MISC_Inf_NoInGuild="提示不在公會裡的收編成員"
L.MISC_Report_Header="通報首領"
L.MISC_Report_Tail="通報細節"
L.MISC_Export_Header="匯出首領"
L.MISC_NotifyText="注意文字"
L.MISC_NotifyText3rd="注意文字 (第三項)"
L.MISC_TimeInHours="小時數"
L.MISC_TimeInDOW="天數"
L.MISC_TimeZoneCtl="時間細節"

L.MISC_MaxNetDKP_d='玩家當前DKP上限，超過上限的部分無效。'
L.MISC_MinNetDKP_d='玩家當前DKP下限，超過下限的部分無效。'
L.AW_SpecialRanks_d='獲得DKP的最低會階。'
L.MISC_HidRanks_d="選中的會階會從DKP列表中移出。"
L.MISC_MinLevel_d="低於此等級的玩家會從DKP列表中移出。"

L.MISCUploadHeader="自動同步"
L.MISC_UploadOn_Raid_d="當團隊加分，如果BOSS擊殺時觸發。"
L.MISC_UploadOn_Tick_d="當全團計時加分時觸發。"
L.MISC_UploadOn_Hourly_d="當某人獲得時間加分時觸發。"
L.MISC_UploadOn_IronMan_d="當開啟鐵人獎勵時觸發。"
L.MISC_UploadOn_Payment_d="當獲取裝備消費DKP時觸發。"
L.MISC_UploadOn_Modif_d="當某人DKP因某種原因被加減時觸發。"
L.MISC_UploadOn_ZS_d="在平分加分時觸發。"
L.MISC_PromptWinDetect_d="每當首領被擊殺時，彈出一個視窗提醒啟用競拍獲勝者偵測功能。如果使用競分助手無需此功能。"
L.MISC_DetectWinTrig_d="觸發競拍獲勝者偵測功能的關鍵字。如果使用競分助手無需此功能。"
L.MISCLogHeader="記錄"
L.LOG_MaxRaid_d="每次活動記錄的最大行數。"
L.LOG_MaxPlayer_d="每個玩家每次活動記錄的最大行數。"
L.LOG_MaxSession_d="記錄活動的次數的上限。"
L.MISCInfHeader="警告"
L.MISC_Inf_WentNeg_d="當一個玩家的當前DKP變為負分時發出警告。"
L.MISC_Inf_IsNeg_d="每次DKP改變時，如果有玩家是負分則發出警告。可能會刷屏。"
L.MISC_Inf_NewMember_d="當外掛程式偵測到新的公會成員是，在聊天框顯示他的名字。 "
L.MISC_Inf_NoInGuild_d="當啟用時,外掛程式會提示團隊中是否存在不在公會裡的玩家。"
L.MISCTextHeader="標題和資訊"
L.MISC_Report_Header_d="記錄報告的標題。$NAME表示玩家名字，$TYPE表示報告類型。"
L.MISC_Report_Tail_d="記錄報告的結尾。"
L.MISC_Export_Header_d="TXT和HTML的標題"
L.MISC_NotifyText_d="當通告主題發出的提示資訊"
L.MISC_NotifyText3rd_d="Notification message sent when the subject of the notification is differend from the messagge receipt"
L.MISC_TimeInHours_d="Max time from now, in hours, for a date to be printed with time only, like HH:MM:SS"
L.MISC_TimeInDOW_d="Max time from now, in days, for a date to be printed with Day of Week instead of the full date"
L.MISC_TimeZoneCtl_d="Quick DKP tries to guess your time zone calculating the difference between your local time and the server time. You can override this by setting here the timezone delta, in hours."


L.Announce = "通報"
L.AN_AnAwards = "通報拾取"
L.AN_AnAwards_d ="開團隊成員拾取通報，包括BOSS拾取。"
L.AN_AnIM = "通報全程獎勵"
L.AN_AnIM_d ="啟用全程獎勵通報"
L.AN_AnPlChange = "通報人員改變"
L.AN_AnPlChange_d ="啟用玩家基本DKP改動，例如拾取消費和自訂獎懲等。"
L.AN_AnNegative = "通告負分"
L.AN_AnNegative_d ="當團員DKP變為負分時通報"
L.AN_AnTimerTick = "通報計時器"
L.AN_AnTimerTick_d ="啟用計時器計時時通報"
L.AN_AnChannel = "通報頻道"
L.PushHeader = "提示"
L.AN_PushChanges = "編輯提示"
L.AN_PushChanges_d ="當DKP變化時，通報相關成員。"
L.AN_PushFailAw = "提示拾取戰利品失敗"
L.AN_PushFailAw_d ="當一個隊員無法獲得裝備時發出提示。"
L.AN_PushFailHo = "提示擊殺失敗"
L.AN_PushFailHo_d ="當一個隊員無法獲得擊殺加分時發出提示。"
L.AN_PushFailIM = "提示鐵人失敗"
L.AN_PushFailIM_d ="當一個隊員全程獎勵中失敗時發出提示。"
L.AN_PushModText = "DKP改變的文本"
L.AN_PushModReasText = "標注了原因的DKP增減的顯示文本。"
L.AN_PushRevText = "取消修改的文本。"

L.BrcDesc1="The Guild Master may use this feature to send his active profile to one or all of the guildmembers. He can set QDKP to automatically broadcast his profile every given minutes."
L.BrcDesc2=
"Regular guiidmembers' Quick DKP addon will automatically set the config profile to the one sent by the Guild Master. DKP Officers can avoid this by setting an option in this tab, so they can have a custom profile. The profile sent by the GM will be received and imported anyway, but the addon wont switch automatically to it. Please mind that this override can lead to different configuration in basilar settings like the boss awards amount or in the bid manager. If you disable the automatic profile, you're on your own.\
Only the Guild Master can set the automatic broadcast of the addon configuration, DKP officers can only send their active profile to the Guild Master, on permission. This is intended to be a way for them to take care of the DKP rules for the GM, but still giving him control over what is being broadcast to the guild.\n"
L.BRC_AutoSendEn = "Automatic broadcast"
L.BRC_ActiveProf = "Active profile: %q"
L.BRC_GuildProf = "Guild (broadcast) profile: %q"
L.BRC_SendGM='Send config to GM'
L.BRC_SendGM_d='Sends the active profile to the Guild Master. He will be asked for confirmation to import your settings, and they will be stored in the same profile name you are using.'
L.BRC_SendToAll = 'Send to Guild now'
L.BRC_SendToAll_d = 'Broadcasts the current configuration profile to every online guild member with QDKP active now.'
L.BRC_SendToName='Send to'
L.BRC_SendToName_d = "Sends the active profile to the given guild member. Can't be used if the automatic broadcast is active"
L.BRC_AutoSendTime = 'Time between broadcasts'
L.BRC_AutoSendTime_d = 'Time interval, in minutes, between broadcasts of the current setting profile.'
L.BRC_OverrideBroadcast = 'Override broadcast'
L.BRC_OverrideBroadcast_d = "If set, the settings broadcasts by the Guild Master will be imported but they WON'T be set as active profile. Enable this if you want to run QDKP with a different ruleset than the one used by your guild"

L.GuildNotes="公會備註"
L.ChangeNotesDesc1="QDKP可以在公會備註或者官員備註上顯示DKP。\n"
L.ChangeNotesDesc2="注意!"
L.FOR_OfficerOrPublic = "記錄DKP於"
L.FOR_OfficerOrPublic_d= '選擇在公會備註還是官員備註上顯示DKP。'
L.FOR_OfficerOrPublic_c="你將改變DKP儲存方式。請確認你按照指定步驟操作，以免資料丟失。"
L.Formatting="格式化"
L.FOR_TotalOrSpent="總量記錄"
L.FOR_TotalOrSpent_d="為了正常運作，QDKP需要知道每個角色DKP獲得和消費的總量。因此，DKP獲得或者消費的總量必須被記錄在公會備註或者官員備註中。你可以在這裡任選其一。"
L.FOR_CompactNote="簡易標籤"
L.FOR_CompactNote_d='讓QDK用"N"，"T"和"H"而不是"Net"，"Tot"和"Hrs"來作為在備註中記錄DKP各數量的變遷。'
L.FOR_StoreHours="記錄總時間"
L.FOR_StoreHours_d="記錄累積的活動時間。"
L.FOR_ImportAlts="導入關聯小號"
L.FOR_ImportAlts_d="啟用時，會導入關聯小號的記錄。"
L.ChangeNotesDesc3=
'通過以下不走DKP會被重置。如果需要儲存資料請嚴格按照以下步驟操作：\
1-創建一個備份\
2-改變這個選項\
3-點擊主視窗中的“還原”按鈕。查看名單中的DKP是否都清零了。\
4-還原你剛剛做的備份\
5-上傳改動，等待驗證\
6-如果你是公會管理員，請公告你做出的改動。如果你不是，把你的配置發送給GM，請求他幫你立刻在公會中通告。\
最好在其他DKP管理員也線上時進行以上操作，進行時注意所有管理員都不要進行DKP操作。'


L.Looting="拾取"
L.LOOTOptions='拾取選項'
L.LOOTQualTresh="物品品質閾值"
L.LOOT_Qual_RaidLog="按活動記錄"
L.LOOT_Qual_RaidLog_d="在活動記錄中物品的最低品質。"
L.LOOT_Qual_PlayerLog="按玩家記錄"
L.LOOT_Qual_PlayerLog_d="在玩家記錄中物品的最低品質"
L.LOOT_Qual_ChargeKey='鍵位記憶'
L.LOOT_Qual_ChargeKey_d='允許你設定一個快速鍵來配置需要隊長分配的最低品質。'
L.LOOT_Qual_ChargeChat="聊天記憶"
L.LOOT_Qual_ChargeChat_d='使用"Charge chat"功能的最低品質。這被用做偵測競拍獲勝功能或者"\dkp charge chat"命令。'
L.LOOT_Qual_ReasonHist="原因歷史"
L.LOOT_Qual_ReasonHist_d="需要記錄原因的最低品質。"
L.LOOT_Qual_PopupTB="彈出工具列"
L.LOOT_Qual_PopupTB_d='當拾取物品時會自動打開工具列的最低品質。只在"拾取時彈出"啟用時生效。'
L.LOOTSettingsHeader="設置"
L.LOOT_OpenToolbox='拾取時彈出'
L.LOOT_OpenToolbox_d="當啟用時, 當有人拾取物品時外掛程式會彈出工具列。"
L.LOOT_LogBadge="記錄徽章"
L.LOOT_LogBadge_d="記錄勇氣點數，正義點數等。"
L.LOOT_LogDisench="記錄分解"
L.LOOT_LogDisench_d="當分解物品是記錄分解出來的材料"
L.LOOTToLog="記錄的物品"
L.LOOT_Item_Add="添加物品"
L.LOOT_Item_Name = "物品名稱"
L.LOOT_Item_Name_d="輸入物品名稱或貼入連結。"
L.LOOT_Item_SelectP="固定價格"
L.LOOT_Item_SelectP_d='設置拾取這個物品的DKP.你可以通過副本分類設置預設值，你可以取消固定DKP，設置自訂DKP。'
L.LOOT_Item_CustomP=""
L.LOOT_Item_NotifyLoot="拾取記錄和警報"
L.LOOT_Item_NotifyLoot_d="你可以以各種方式設置QDKP通報拾取資訊。你可以強制記錄某個裝備品質，會在聊天中通報。你可以用這個功能防止預設根據拾取資訊自動記錄。"
L.LOOT_Item_Cancel="移出物品"
L.LOOTPriceInst="按副本列出價格"
L.LOOTPriceItem="按物品列出價格"

--Messages

L.MESS_AllowImport=
"%s 想要同步DKP資料到公會備註\
內容: %q\
如果拒絕請不要點yes。\
你允許他上傳DKP資料嗎？"

end
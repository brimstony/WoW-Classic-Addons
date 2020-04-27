-- Simplified Chinese (BY Miruido) 感谢 其实我不是小泡泡 汉化推荐

local L = LibStub("AceLocale-3.0"):NewLocale("QDKP2_Config", "zhCN")

if L then

--Generic strings
L.QDKP2="Quick DKP V2"
L.Instance10 = "10 普通"
L.Instance10H = "10 英雄"
L.Instance25 = "25 普通"
L.Instance25H = "25 英雄"
L.Roster = "名单"
L.Log = "记录"
L.Success="成功!"
L.Confirm="请确认"

--GUI tree
L.GUI=	"控制台选项"
L.GUI_ClassBased = "按职业着色"
L.GUI_ClassBased_d = "在名单中按职业着色"
L.GUI_DefaultColor = "默认颜色"
L.GUI_DefaultColor_d = "默认染色"
L.GUI_ModifiedColor = "未上传的改动"
L.GUI_ModifiedColor_d = "未上传的改动"
L.GUI_StandbyColor = "替补人员"
L.GUI_StandbyColor_d = "为替补人员染色"
L.GUI_AltColor = "关联小号"
L.GUI_AltColor_d = "为关联小号染色"
L.GUI_ExtColor = "会外编制人员"
L.GUI_ExtColor_d = "为会外编制染色"
L.GUI_NoGuildColor = "会外非临时编制人员"
L.GUI_NoGuildColor_d = "为会外非临时编制人员染色"
L.GUI_NoClassColor = "未知职业"
L.GUI_NoClassColor_d = "为未知职业染色"

L.ODS="问询系统"
L.ODS_Enable = "启用"
L.ODS_Enable_d = "启用禁用需求系统"
L.KWHeaders = "关键词"
L.ODS_EnDKP = '启用 "?dkp"'
L.ODS_EnDKP_d = "启用这个关键词来问DKP"
L.ODS_EnREPORT = '启用 "?report"'
L.ODS_EnREPORT_d = "启用这个关键词来问统计记录。"
L.ODS_EnPRICE = '启用 "?price"'
L.ODS_EnPRICE_d = "启用这个关键词来问物品需要的DKP"
L.ODS_EnBOSS = '启用 "?boss"'
L.ODS_EnBOSS_d = "启用这个关键词来问BOSS加分。"
L.ODS_EnCLASS = '启用 "?classdkp 职业"'
L.ODS_EnCLASS_d = "启用这个关键词来问职业DKP列表"
L.ODS_EnRANK = '启用 "?rank"'
L.ODS_EnRANK_d = "启用这个关键词来问某会阶DKP列表"
L.OptionHeaders = "选项"
L.ODS_ViewWhisp = "查看密语"
L.ODS_ViewWhisp_d = "显示问询的密语"
L.ODS_ReqAll = "允许问询其他公共玩家的DKP"
L.ODS_ReqAll_d = "允许玩家问询其他公会成员的数据。"
L.ODS_LetExt = "允许其他公会的玩家问询DKP"
L.ODS_LetExt_d = "允许其他公会的玩家问询DKP。"
L.ODS_TopTenLen = "排行榜人数"
L.ODS_TopTenLen_d = "职业DKP排行榜的数量"
L.ODS_PriceLen = "询问物品数量"
L.ODS_PriceLen_d = "当问询物品DKP时，显示的物品数量。"
L.ODS_BossLen = "询问BOSS击杀加分"
L.ODS_BossLen_d =  "当问询BOSS击杀加分时，显示的BOSS数量。"
L.ODS_PricesKWLen = "询问物品DKP的最少关键词长度"
L.ODS_PricesKWLen_d = "当问询物品DKP时，关键词的最短字数。"
L.ODS_BossKWLen = "询问BOSS击杀DKP的最少关键词长度"
L.ODS_BossKWLen_d = "当问询BOSS击杀DKP时，关键词的最短字数。"

L.BidManager="竞价助手"
L.BidOptions="常规出价设置"
L.AnnouceHeader = "通报选项"
L.BM_AnnounceStart = "通报开始"
L.BM_AnnounceStart_d = "在指定频道中通报竞标开始。"
L.BM_AnnounceWinner = "通报获胜者。"
L.BM_AnnounceWinner_d = "在指定频道中通报竞获胜者。"
L.BM_AnnounceCancel = "通报取消"
L.BM_AnnounceCancel_d = "在指定频道中通报竞标取消。"
L.BM_AnnounceStartChannel = "开始频道"
L.BM_AnnounceWinnerChannel = "获胜者频道"
L.BM_AnnounceCancelChannel = "取消频道"
L.BM_AnnounceChannel_d = '发送通报的频道。按照你所在的队伍类型自动调整。'
L.BM_Countdown = "启用倒计时"
L.BM_Countdown_d = "当你宣布获胜者时启用一个倒计时，如果在倒计时时有人出分，则倒计时会被取消。"
L.BM_CountdownChannel = "倒计时频道"
L.BM_CountdownLen = "倒计时长度"
L.BM_AnnounceStartText = "开始文本"
L.BM_AnnounceStartText_d = "宣布竞分开始的文本。$ITEM代表物品名字。"
L.BM_AnnounceWinnerDKPText = "获胜者(含DKP)文本"
L.BM_AnnounceWinnerDKPText_d = "宣布竞分获胜者的文本。$ITEM代表物品名字。$NAME代表获胜者名字。"
L.BM_AnnounceWinnerText = "获胜者(不含DKP)文本"
L.BM_AnnounceWinnerText_d = "宣布竞分获胜者的文本。$ITEM代表物品名字。$NAME代表获胜者名字。"
L.BM_AnnounceCancelText = "取消文本"
L.BM_AnnounceCancelText_d = "宣布竞分取消的文本。$ITEM代表物品名字。"
L.BiddingOptionHeader = "竞分选项"
L.BM_AllowMultiple = "允许多次出分"
L.BM_AllowMultiple_d = "如果禁用，则只允许出一次分。ROLL点的话，则始终只允许ROLL一次。"
L.BM_AllowLesser = "允许比当前分数低的出分"
L.BM_AllowLesser_d = "允许比当前分数低的出分"
L.BM_OverBid = "允许超额出分"
L.BM_OverBid_d = "允许超过当前DKP出分"
L.BM_TestBets = "取消无效竞分"
L.BM_TestBets_d = "这会检查每一次出分是否有效。"
L.BM_OutGuild = "允许公会外人员出分"
L.BM_OutGuild_d = "允许公会外收编人员出分。"
L.BM_AutoRoll = "自动ROLL"
L.BM_AutoRoll_d = "如果启用，当实行ROLL点+DKP分配模式时，如果一个成员没有ROLL点就出分，插件生成一个随机数作为其ROLL点，禁用这个选项则会提醒他先ROLL点。"
L.BM_MinBid = "出分下限"
L.BM_MinBid_d="出分下限"
L.BM_MaxBid = "出分上限"
L.BM_MaxBid_d="出分上限"
L.MiscHeader="其他选项"
L.BM_CatchRolls="侦测 /roll"
L.BM_CatchRolls_d="侦测 /roll，并且要求团员在出价时/roll。"
L.BM_HideWhisp="隐藏竞分密语"
L.BM_HideWhisp_d="隐藏聊天框中竞分的密语"
L.BM_GetWhispers="密语竞分"
L.BM_GetWhispers_d="允许密语竞分"
L.BM_GetGroup="团队竞分"
L.BM_GetGroup_d="允许在团队，小队，战场频道竞分。"
L.BM_GiveToWinner="把装备分给获得竞标的玩家。"
L.BM_GiveToWinner_d='当宣布装备获胜者时，尝试自动分配这个装备。\n注意:\n-分配方式必须为“队长分配”\n-竞拍主持者是拾取人\n-拾取窗口打开并且物品依然在拾取窗口内。\n获胜者必须有权利获得该物品。'
L.BM_AckBets="确认有效竞分。"
L.BM_AckBets_d="当收到有效竞分时通知。"
L.BM_AckReject="标注无效竞分。"
L.BM_AckReject_d="当竞分无效时通知，并说明原因。"
L.BM_AckRejectChannel="无效竞分通知频道"
L.BM_AckBetsChannel="有效精分通知频道"
L.BM_AckChannel_d='发送通知的频道。'
L.BM_ConfirmWinner="确认获胜者"
L.BM_ConfirmWinner_d="在宣布获胜者之前确认"
L.BM_LogBets = "记录竞拍"
L.BM_LogBets_d = "在玩家记录中记录竞拍。"
L.BM_RoundValue = "数值取整"
L.BM_RoundValue_d = '数值取整。DKP分数无视这个选项总是取整。'
L.BidKeywords='关键词编辑'
L.BM_KW_Keyword='关键词'
L.BM_KW_Keyword_d='输入关键词，多个关键词用逗号隔开。'
L.BM_KW_Value='竞价标识'
L.BM_KW_Value_d='输入竞价关键词. 如果省略, 任何数字都会被看做竞分。'
L.BM_KW_DKP='DKP标识'
L.BM_KW_DKP_d='如果想与竞分关键词不同, 请另外输入一个关键词。'
L.BM_KW_Min='最小值'
L.BM_KW_Min_d='如果与竞分下限不同，请注明。'
L.BM_KW_Max='最大值'
L.BM_KW_Max_d='如果与竞分上限不同，请注明。'
L.BM_KW_Eligible='资格'
L.BM_KW_Eligible_d='如果需要，在此输入一个关键词来确认竞拍资格。'
L.BM_KW_Test="测试关键词"
L.BM_KW_Test_d="测试当前关键词。 "
L.BM_KW_Del='删除关键词'
L.DefaultKWProfile='当前模式'
L.DefaultKWProfile_d=
'改变后不可还原之前的设置。'


L.DefaultKWProfile_c="改变关键词模式会替换你之前所有的关键词。"

L.Awarding="加分"
L.BA="击杀奖励"
L.ByInstance="按副本设置"
L.InstHelpText='在此你可以设置在特定的副本中每当一个BOSS被击杀时的加分。'
L.ByName="按名字设置"
L.AddNewBoss="增加一个新首领"
L.TIM="时间奖励"
L.AW_TIM_Period="记录频率"
L.AW_TIM_Period_d="两次时间记录的间隔，必须是6的倍数。"
L.AW_TIM_ShowAward="通报时间加分。"
L.AW_TIM_ShowAward_d="当团队成员获得时间加分时通报。"
L.AW_TIM_RaidLogTicks="记录时间加分。"
L.AW_TIM_RaidLogTicks_d="在团队记录中记录每一次时间加分。"
L.IM='全程奖励'
L.AW_IM_PercReq="参加要求"
L.AW_IM_PercReq_d="参加全程奖励的出勤率"
L.AW_IM_InWhenStarts="加入时在场"
L.AW_IM_InWhenStarts_d="启用时，玩家必须从全程奖励开始在团队中在线才能获得奖励。"
L.AW_IM_InWhenEnds="结束时在场"
L.AW_IM_InWhenEnds_d="启用时，玩家必须从全程奖励结束时在团队中在线才能获得奖励。"
L.ZS="平分加分"
L.AW_ZS_UseAsCharge="启用平分加分"
L.AW_ZS_UseAsCharge_d="把平分加分设为默认消费方式。而不是纯粹的DKP消费。"
L.AW_ZS_GiveZS2Payer="含出分玩家"
L.AW_ZS_GiveZS2Payer_d="启用时，出分的玩家也会被算在平分加分的列表中。"
L.AW_CtlHeader = "加分规则"
L.AW_OfflineCtl = "离线"
L.AW_ZoneCtl = "不在区域内"
L.AW_RankCtl = "特定会阶"
L.AW_AltCtl = "关联小号"
L.AW_StandbyCtl = "替补"
L.AW_ExternalCtl = "会外编制"
L.AW_OfflineCtl_d = "调整离线团员的DKP获取百分比。"
L.AW_ZoneCtl_d = "调整区域外团员的DKP获取百分比。"
L.AW_RankCtl_d = "调整在选项中指定会阶团队的DKP获取百分比。"
L.AW_AltCtl_d = "调整关联小号的DKP获取百分比。 "
L.AW_StandbyCtl_d = "调整手动添加到团队列表中的替补人员的DKP获取百分比。"
L.AW_ExternalCtl_d = "调整会外编制人员的DKP获取百分比。"
L.AW_Boss_CustomAmount = "自定义数量"
L.AW_Boss_RemoveBoss = "取消首领条目"
L.AW_Boss_SelectBoss10 = "10-man 人数"
L.AW_Boss_SelectBoss25 = "25-man 人数"
L.AW_Boss_SelectBoss_d = '设置击杀这个首领的加分。'
L.AW_Boss_Name = "首领名称"
L.AW_Boss_Name_d = "请输入BOSS名称。"
L.AW_Boss_UseTarget="输入当前目标的名称。"

L.Misc="其他"
L.MISC_MaxNetDKP="最高当前DKP"
L.MISC_MinNetDKP="最低当前DKP"
L.AW_SpecialRanks="特殊会阶"
L.MISC_HidRanks="隐藏会阶"
L.MISC_MinLevel="最低等级"
L.MISC_UploadOn_Raid="在团队加分时"
L.MISC_UploadOn_Tick="在计时时"
L.MISC_UploadOn_Hourly="在计时完成时"
L.MISC_UploadOn_IronMan="在全程奖励时"
L.MISC_UploadOn_Payment="在消费时"
L.MISC_UploadOn_Modif="在编辑时"
L.MISC_UploadOn_ZS="在平分加分时"
L.MISC_PromptWinDetect="提示获胜者细节。"
L.MISC_DetectWinTrig="获胜者信息触发器"
L.LOG_MaxRaid="团队记录长度上限"
L.LOG_MaxPlayer="个人记录长度上限"
L.LOG_MaxSession="活动数量上限"
L.MISC_Inf_WentNeg="通知进入负分"
L.MISC_Inf_IsNeg="当负分时通知"
L.MISC_Inf_NewMember="提示新公会成员"
L.MISC_Inf_NoInGuild="提示不在公会里的收编成员"
L.MISC_Report_Header="通报首领"
L.MISC_Report_Tail="通报细节"
L.MISC_Export_Header="导出首领"
L.MISC_NotifyText="注意文字"
L.MISC_NotifyText3rd="注意文字 (第三项)"
L.MISC_TimeInHours="小时数"
L.MISC_TimeInDOW="天数"
L.MISC_TimeZoneCtl="时间细节"

L.MISC_MaxNetDKP_d='玩家当前DKP上限，超过上限的部分无效。'
L.MISC_MinNetDKP_d='玩家当前DKP下限，超过下限的部分无效。'
L.AW_SpecialRanks_d='获得DKP的最低会阶。'
L.MISC_HidRanks_d="选中的会阶会从DKP列表中移出。"
L.MISC_MinLevel_d="低于此等级的玩家会从DKP列表中移出。"

L.MISCUploadHeader="自动同步"
L.MISC_UploadOn_Raid_d="当团队加分，如果BOSS击杀时触发。"
L.MISC_UploadOn_Tick_d="当全团计时加分时触发。"
L.MISC_UploadOn_Hourly_d="当某人获得时间加分时触发。"
L.MISC_UploadOn_IronMan_d="当开启铁人奖励时触发。"
L.MISC_UploadOn_Payment_d="当获取装备消费DKP时触发。"
L.MISC_UploadOn_Modif_d="当某人DKP因某种原因被加减时触发。"
L.MISC_UploadOn_ZS_d="在平分加分时触发。"
L.MISC_PromptWinDetect_d="每当首领被击杀时，弹出一个窗口提醒启用竞拍获胜者侦测功能。如果使用竞分助手无需此功能。"
L.MISC_DetectWinTrig_d="触发竞拍获胜者侦测功能的关键词。如果使用竞分助手无需此功能。"
L.MISCLogHeader="记录"
L.LOG_MaxRaid_d="每次活动记录的最大行数。"
L.LOG_MaxPlayer_d="每个玩家每次活动记录的最大行数。"
L.LOG_MaxSession_d="记录活动的次数的上限。"
L.MISCInfHeader="警告"
L.MISC_Inf_WentNeg_d="当一个玩家的当前DKP变为负分时发出警告。"
L.MISC_Inf_IsNeg_d="每次DKP改变时，如果有玩家是负分则发出警告。可能会刷屏。"
L.MISC_Inf_NewMember_d="当插件侦测到新的公会成员是，在聊天框显示他的名字。 "
L.MISC_Inf_NoInGuild_d="当启用时,插件会提示团队中是否存在不在公会里的玩家。"
L.MISCTextHeader="标题和信息"
L.MISC_Report_Header_d="记录报告的标题。$NAME表示玩家名字，$TYPE表示报告类型。"
L.MISC_Report_Tail_d="记录报告的结尾。"
L.MISC_Export_Header_d="TXT和HTML的标题"
L.MISC_NotifyText_d="当通告主题发出的提示信息"
L.MISC_NotifyText3rd_d="Notification message sent when the subject of the notification is differend from the messagge receipt"
L.MISC_TimeInHours_d="Max time from now, in hours, for a date to be printed with time only, like HH:MM:SS"
L.MISC_TimeInDOW_d="Max time from now, in days, for a date to be printed with Day of Week instead of the full date"
L.MISC_TimeZoneCtl_d="Quick DKP tries to guess your time zone calculating the difference between your local time and the server time. You can override this by setting here the timezone delta, in hours."


L.Announce = "通报"
L.AN_AnAwards = "通报拾取"
L.AN_AnAwards_d ="开团队成员拾取通报，包括BOSS拾取。"
L.AN_AnIM = "通报全程奖励"
L.AN_AnIM_d ="启用全程奖励通报"
L.AN_AnPlChange = "通报人员改变"
L.AN_AnPlChange_d ="启用玩家基本DKP改动，例如拾取消费和自定义奖惩等。"
L.AN_AnNegative = "通告负分"
L.AN_AnNegative_d ="当团员DKP变为负分时通报"
L.AN_AnTimerTick = "通报计时器"
L.AN_AnTimerTick_d ="启用计时器计时时通报"
L.AN_AnChannel = "通报频道"
L.PushHeader = "提示"
L.AN_PushChanges = "编辑提示"
L.AN_PushChanges_d ="当DKP变化时，通报相关成员。"
L.AN_PushFailAw = "提示拾取战利品失败"
L.AN_PushFailAw_d ="当一个队员无法获得装备时发出提示。"
L.AN_PushFailHo = "提示击杀失败"
L.AN_PushFailHo_d ="当一个队员无法获得击杀加分时发出提示。"
L.AN_PushFailIM = "提示铁人失败"
L.AN_PushFailIM_d ="当一个队员全程奖励中失败时发出提示。"
L.AN_PushModText = "DKP改变的文本"
L.AN_PushModReasText = "标注了原因的DKP增减的显示文本。"
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

L.GuildNotes="公会备注"
L.ChangeNotesDesc1="QDKP可以在公会备注或者官员备注上显示DKP。\n"
L.ChangeNotesDesc2="注意!"
L.FOR_OfficerOrPublic = "记录DKP于"
L.FOR_OfficerOrPublic_d= '选择在公会备注还是官员备注上显示DKP。'
L.FOR_OfficerOrPublic_c="你将改变DKP储存方式。请确认你按照指定步骤操作，以免数据丢失。"
L.Formatting="格式化"
L.FOR_TotalOrSpent="总量记录"
L.FOR_TotalOrSpent_d="为了正常运作，QDKP需要知道每个角色DKP获得和消费的总量。因此，DKP获得或者消费的总量必须被记录在公会备注或者官员备注中。你可以在这里任选其一。"
L.FOR_CompactNote="简易标签"
L.FOR_CompactNote_d='让QDK用"N"，"T"和"H"而不是"Net"，"Tot"和"Hrs"来作为在备注中记录DKP各数量的变迁。'
L.FOR_StoreHours="记录总时间"
L.FOR_StoreHours_d="记录累积的活动时间。"
L.FOR_ImportAlts="导入关联小号"
L.FOR_ImportAlts_d="启用时，会导入关联小号的记录。"
L.ChangeNotesDesc3=
'通过以下不走DKP会被重置。如果需要储存数据请严格按照以下步骤操作：\
1-创建一个备份\
2-改变这个选项\
3-点击主窗口中的“还原”按钮。查看名单中的DKP是否都清零了。\
4-还原你刚刚做的备份\
5-上传改动，等待验证\
6-如果你是公会管理员，请公告你做出的改动。如果你不是，把你的配置发送给GM，请求他帮你立刻在公会中通告。\
最好在其他DKP管理员也在线时进行以上操作，进行时注意所有管理员都不要进行DKP操作。'


L.Looting="拾取"
L.LOOTOptions='拾取选项'
L.LOOTQualTresh="物品品质阈值"
L.LOOT_Qual_RaidLog="按活动记录"
L.LOOT_Qual_RaidLog_d="在活动记录中物品的最低品质。"
L.LOOT_Qual_PlayerLog="按玩家记录"
L.LOOT_Qual_PlayerLog_d="在玩家记录中物品的最低品质"
L.LOOT_Qual_ChargeKey='键位记忆'
L.LOOT_Qual_ChargeKey_d='允许你设定一个快捷键来配置需要队长分配的最低品质。'
L.LOOT_Qual_ChargeChat="聊天记忆"
L.LOOT_Qual_ChargeChat_d='使用"Charge chat"功能的最低品质。这被用做侦测竞拍获胜功能或者"\dkp charge chat"命令。'
L.LOOT_Qual_ReasonHist="原因历史"
L.LOOT_Qual_ReasonHist_d="需要记录原因的最低品质。"
L.LOOT_Qual_PopupTB="弹出工具栏"
L.LOOT_Qual_PopupTB_d='当拾取物品时会自动打开工具栏的最低品质。只在"拾取时弹出"启用时生效。'
L.LOOTSettingsHeader="设置"
L.LOOT_OpenToolbox='拾取时弹出'
L.LOOT_OpenToolbox_d="当启用时, 当有人拾取物品时插件会弹出工具栏。"
L.LOOT_LogBadge="记录徽章"
L.LOOT_LogBadge_d="记录勇气点数，正义点数等。"
L.LOOT_LogDisench="记录分解"
L.LOOT_LogDisench_d="当分解物品是记录分解出来的材料"
L.LOOTToLog="记录的物品"
L.LOOT_Item_Add="添加物品"
L.LOOT_Item_Name = "物品名称"
L.LOOT_Item_Name_d="输入物品名称或贴入链接。"
L.LOOT_Item_SelectP="固定价格"
L.LOOT_Item_SelectP_d='设置拾取这个物品的DKP.你可以通过副本分类设置默认值，你可以取消固定DKP，设置自定义DKP。'
L.LOOT_Item_CustomP=""
L.LOOT_Item_NotifyLoot="拾取记录和警报"
L.LOOT_Item_NotifyLoot_d="你可以以各种方式设置QDKP通报拾取信息。你可以强制记录某个装备品质，会在聊天中通报。你可以用这个功能防止默认根据拾取信息自动记录。"
L.LOOT_Item_Cancel="移出物品"
L.LOOTPriceInst="按副本列出价格"
L.LOOTPriceItem="按物品列出价格"

--Messages

L.MESS_AllowImport=
"%s 想要同步DKP数据到公会备注\
内容: %q\
如果拒绝请不要点yes。\
你允许他上传DKP数据吗？"

end

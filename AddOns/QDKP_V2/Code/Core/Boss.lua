-- Copyright 2014 Akhaan & Honesty Hyj (www.quickdkp.com)
-- This file is a part of QDKP_V2 (see about.txt in the Addon's root folder)

--             ## CORE FUNCTIONS ##
--             Boss Award Functions
--
--      Function to detect, qualify and award boss kills
--
-- API Documentation:
-- QDKP2_BossKilled(boss): This should be called whenever a boss mob is killed. It's bulletproof aganist double calls.
-- QDKP2_GetBossAward(boss,[zone]): returns the award for killing <boss> in the instance <zone>. <zone> is set to GetRealZoneText() if not provided.
-- QDKP2_BossBonusSet(todo) -- Activate/deactivate the boss award. todo can be 'on', 'off' or 'toggle'
-- QDKP2_IsInBossTable(boss) -- retruns true if boss is in the boss award table
-- QDKP_InstanceDiff()  --  Returns instance difficulty index and dkp tag

----------- Boss Kill ----------------------

local boss_translator={}
boss_translator["Archavon the Stone Watcher"] = "Archavon"
boss_translator["Emalon the Storm Watcher"] = "Emalon"
boss_translator["Koralon the Flame Watcher"] = "Koralon"
boss_translator["Toravon the Ice Watcher"] = "Toravon"



function QDKP2_BossKilled(boss, instDiff)
-- called mainly by event, triggers a boss award if <boss> is in QDKP2_Bosses table.
-- uses libBabble-Bosses for locales.
  QDKP2_Debug(3,"Core",boss.." has died")
  if not QDKP2_ManagementMode() then
    QDKP2_Debug(3,"Core","Quitting Boss award because you aren't in management mode")
    return
  end
  if not boss or type(boss)~='string' then
    QDKP2_Debug(1,"Core","Calling QDKP2_BossKilled with invalid boss: "..tostring(boss))
    return
  end

  boss=boss_translator[boss] or boss

  if QDKP2_BossKilledTime and time() - QDKP2_BossKilledTime < 60 then
    --this sets a 1 minute "cooldown" between boss awards to avoid multiple awards
    --coming for various sources (DBM, BigWigs or simple slain detector)
    QDKP2_Debug(2,"Core","Got "..boss.." kill trigger, but BossKill is in cooldown.")
    return
  else
    QDKP2_BossKilledTime = time()
  end

  local award=QDKP2_GetBossAward(boss)

  if award then
    QDKP2log_Entry("RAID",boss,QDKP2LOG_BOSS)
    if QDKP2_GuildData.AutoBossEarn then --if the Boss Award is on
      local mess=string.gsub(QDKP2_LOC_BossKill, '$BOSS', boss)
      QDKP2_Msg(mess,"AWARD",QDKP2_COLOR_BLUE)  --QDKP2_Msg(QDKP2_COLOR_BLUE..mess)  revised 6.01, didn't have a type
      local reason=string.gsub(QDKP2_LOC_Kill, '$BOSS', boss)
      QDKP2_RaidAward(award, reason) --give DKP to the raid
    end
    if QDKP2_PROMPT_AWDS and not QDKP2_GuildData.DetectBids then
      QDKP2_AskUser(QDKP2_LOC_WinDetect_Q,QDKP2_DetectBidSet,'on')
    end
  end
  QDKP2_Events:Fire("DATA_UPDATED","log")
end

function QDKP2_GetBossAward(boss, zone)
  if not boss or type(boss)~='string' then
    QDKP2_Debug(1,"Core","Calling QDKP2_BossKilled with invalid boss: "..tostring(boss))
    return
  end

  local instDiff, DKPType, award
  --local instDiff=GetRaidDifficultyID()  --4:10-normal, 5:25-normal, 6:10-heroic, 7:25-heroic
  zone=zone or GetRealZoneText()
  local zoneEng=QDKP2zoneEnglish[zone] or zone
  zone=string.lower(zone)
  zoneEng=string.lower(zoneEng)
  instDiff, DKPType = QDKP2_InstanceDiff()
  if (instDiff < 7) then DKPType = "DKP_"..DKPType end  --for legacy zone sizes pre-SoO

  --searching for specific boss award
  award=QDKP2_IsInBossTable(boss,instDiff)
  if award then
    QDKP2_Debug(2,"Core","Specific DKP award for "..boss.."("..DKPType..") is "..tostring(award))
    return award
  end

  --searching for default award for instance
  for i,InstanceDKP in ipairs(QDKP2_Instances) do
    local DKPzone=string.lower(InstanceDKP.name or '-')
    if DKPzone==zone or DKPzone==zoneEng then
      award=InstanceDKP[DKPType]
      QDKP2_Debug(2,"Core","Instance default DKP award for "..boss.."("..DKPType..") is "..tostring(award))
      return award
    end
  end
end


function QDKP2_IsInBossTable(boss,instDiff)

  
  local DKPType
  
  instDiff, DKPType = QDKP2_InstanceDiff()
  if (instDiff < 7) then DKPType = "DKP_"..DKPType end

  boss=boss_translator[boss] or boss
  local bossEng = QDKP2bossEnglish[boss] or boss
  boss=string.lower(boss)
  bossEng=string.lower(boss_translator[bossEng] or bossEng)
  for i,BossDKP in ipairs(QDKP2_Bosses) do
    local DKPboss=string.lower(BossDKP.name or '-')
    if DKPboss == boss or DKPboss == bossEng then
      return BossDKP[DKPType]
    end
  end
end

function QDKP2_BossBonusSet(todo)
  if todo == "toggle" then
    if QDKP2_GuildData.AutoBossEarn then QDKP2_BossBonusSet("off")
    else QDKP2_BossBonusSet("on")
    end
  elseif todo==true or todo == "on" then
    QDKP2_GuildData.AutoBossEarn = true
    QDKP2_Events:Fire("BOSSBONUS_ON")
    QDKP2_Msg(QDKP2_COLOR_YELLOW.."Auto Boss Award enabled")
  elseif not todo or todo == "off" then
    QDKP2_GuildData.AutoBossEarn = false
    QDKP2_Events:Fire("BOSSBONUS_OFF")
    QDKP2_Msg(QDKP2_COLOR_YELLOW.."Auto Boss Award disabled")
  end
end

function QDKP2_InstanceDiff()

  local instDiff = 14 --Classic mod GetRaidDifficultyID()
  local instType = "None"
  if     instDiff==3 then instType="10"
  elseif instDiff==5 then instType="10H"
  elseif instDiff==4 then instType="25"
  elseif instDiff==6 then instType="25H"
  elseif instDiff==7 then instType="LFR"
  elseif instDiff==9 then instType="40"
  elseif instDiff==14 then instType="Normal"
  elseif instDiff==15 then instType="Heroic"
  elseif instDiff==16 then instType="Mythic"
  elseif instDiff==17 then instType="LFRFlex"
  end
  
  return instDiff, instType
end

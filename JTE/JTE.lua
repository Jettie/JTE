
local _G = getfenv(0)
local LIDL = LibStub("LibItemLevel-1.0")

JTSLOTSTART = {}
JTSLOTCD = {}
JTSLOTUSABLE = {}

JTTEST = true

--
--TEXT
--
CHICKENNAME ="侏儒作战小鸡"
JTE_TEXT_UI_MISSING = "需要安装插件: "
JTE_TEXT_UIMISSING_ITEMRACK = "ITEMRACK"
JTE_TEXT_FUNCTION_NOT_WORKING = "依赖功能缺失: "
JTE_TEXT_ITEMRACK_SETS_TOGGLE = "ItemRack_Sets_Toggle"
JTE_TEXT_UIMISSING_TRINKETMENU = "TrinketMenu"

--Skill and Buff names
JTE_TEXT_BUFF_CRUSADER = "神圣力量"
JTE_TEXT_SKILL_BLADE_FLURRY = "剑刃乱舞"
JTE_TEXT_SKILL_ADRENALINE_RUSH = "冲动"
JTE_TEXT_SKILL_SLICEDICE = "切割"
JTE_TEXT_SKILL_SPRINT = "疾跑"
JTE_TEXT_SKILL_EVASION = "闪避"
JTE_TEXT_USEITEM_GOBLINSAPPERCHARGE = "地精工兵炸药"
JTE_TEXT_USEITEM_DENSEDYNAMITE = "致密炸弹"

--Parry count function text
JTE_PARRYCOUNTHEADER = "JTE找背工具(打脸了) "
JTE_PARRYCOUNTLASTCOMBAT = "本次招架: "
JTE_TEXT_PARRYCOUNTPERFECT = "完美！"
JTE_TEXT_PARRYCOUNTNORMAL = "还阔以！"
JTE_TEXT_PARRYCOUNTBAD = "有点多……"
JTE_TEXT_PARRYCOUNTTERRIBLE = "疯狂打脸！"
JTE_TEXT_PARRYCOUNTDETAILSSPELL = "技能: "
JTE_TEXT_PARRYCOUNTDETAILSSWING = "普攻: "
JTE_TEXT_PARRYCOUNTDETAILSTIMES = " 次 "
JTE_TEXT_PARRYCOUNTDETAILSCOMBATTIME = "用时 "

--bindings support
BINDING_HEADER_JTE_BINDINGS = "JTE HotKeys"
BINDING_NAME_JTE_ITEMRACK_SET_TOGGLE = "显示/隐藏 ItemRack"
BINDING_NAME_JTE_TRINKETMENU_TOGGLE = "显示/隐藏 TrinketMenu"
BINDING_NAME_JTE_DPSMATE_MAIN_TOGGLE = "显示/隐藏 DPSMate主窗口"
BINDING_NAME_JTE_DPSMATE_OTHER_TOGGLE = "显示/隐藏 DPSMate其他窗口"
BINDING_NAME_JTE_COMBATLOG_TOGGLE = "开启/关闭战斗记录"
BINDING_NAME_JTE_NAME_TOGGLE = "显示/隐藏名字(主城防卡)"
BINDING_NAME_JTE_TRADE = "交易目标"
BINDING_NAME_JTE_INSPECT = "观察目标"
BINDING_NAME_JTE_LEAVEPARTY = "离开队伍"

if (GetLocale() ~= "zhCN") then
	CHICKENNAME ="Gnomish Battle Chicken"
	JTE_TEXT_UI_MISSING = "AddOn Require: "
	JTE_TEXT_UIMISSING_ITEMRACK = "ITEMRACK"
	JTE_TEXT_FUNCTION_NOT_WORKING = "Missing dependency function: "
	JTE_TEXT_ITEMRACK_SETS_TOGGLE = "ItemRack_Sets_Toggle"
	JTE_TEXT_UIMISSING_TRINKETMENU = "TrinketMenu"

	JTE_TEXT_BUFF_CRUSADER = "Holy Strength"
	JTE_TEXT_SKILL_BLADE_FLURRY = "Blade Flurry"
	JTE_TEXT_SKILL_ADRENALINE_RUSH = "Adrenaline Rush"
	JTE_TEXT_SKILL_SLICEDICE = "Slice and Dice"
	JTE_TEXT_SKILL_SPRINT = "Sprint"
	JTE_TEXT_SKILL_EVASION = "Evasion"
	JTE_TEXT_USEITEM_GOBLINSAPPERCHARGE = "Goblin Sapper Charge"
	JTE_TEXT_USEITEM_DENSEDYNAMITE = "Dense Dynamite"
	JTE_PARRYCOUNTHEADER = "JTE-Backfinder "
	JTE_PARRYCOUNTLASTCOMBAT = "Total Parried: "
	JTE_TEXT_PARRYCOUNTPERFECT = "Perfect!"
	JTE_TEXT_PARRYCOUNTNORMAL = "Pretty Good!"
	JTE_TEXT_PARRYCOUNTBAD = "A little bit LAME?"
	JTE_TEXT_PARRYCOUNTTERRIBLE = "You are FACE BITBER!"
	JTE_TEXT_PARRYCOUNTDETAILSSPELL = "Skill: "
	JTE_TEXT_PARRYCOUNTDETAILSSWING = "Swing: "
	JTE_TEXT_PARRYCOUNTDETAILSTIMES = " times. "
	JTE_TEXT_PARRYCOUNTDETAILSCOMBATTIME = "Time: "

	BINDING_HEADER_JTE_BINDINGS = "JTE HotKeys"
	BINDING_NAME_JTE_ITEMRACK_SET_TOGGLE = "Toggle ItemRack"
	BINDING_NAME_JTE_TRINKETMENU_TOGGLE = "Toggle TrinketMenu"
	BINDING_NAME_JTE_DPSMATE_MAIN_TOGGLE = "Toggle DPSMate 1st Window"
	BINDING_NAME_JTE_DPSMATE_OTHER_TOGGLE = "Toggle DPSMate other Windows"
	BINDING_NAME_JTE_COMBATLOG_TOGGLE = "Start/Finish Combat Log"
	BINDING_NAME_JTE_NAME_TOGGLE = "Toggle Names (avoid fps drop)"
	BINDING_NAME_JTE_TRADE = "Trade Target"
	BINDING_NAME_JTE_INSPECT = "Inspect Target"
	BINDING_NAME_JTE_LEAVEPARTY = "Leave Party/Raid"
end


local JTE_PlayerName = UnitName("player")
local _, JTE_PlayerClass = UnitClass("player")




--AI声音 晓晓 +3强度

-- 团队判断if( GetNumRaidMembers() > 0 ) then
--[[
	COMBAT_TEXT_UPDATE 的arg1
"DAMAGE"
"SPELL_DAMAGE"
"DAMAGE_CRIT"
"HEAL"
"PERIODIC_HEAL"
"HEAL_CRIT"
"MISS"
"DODGE"
"PARRY"
"BLOCK"
"RESIST"
"SPELL_RESISTED"
"ABSORB"
"SPELL_ABSORBED"
"MANA"
"ENERGY"
"RAGE"
"FOCUS"
"SPELL_ACTIVE"
"COMBO_POINTS"
"AURA_START"
"AURA_END"
"AURA_START_HARMFUL"
"AURA_END_HARMFUL"
"HONOR_GAINED"
"FACTION"

]]




--加载时，注册事件
function JTE_OnLoad()
	this:RegisterEvent("UNIT_INVENTORY_CHANGED");
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("COMBAT_TEXT_UPDATE")
	this:RegisterEvent("PLAYER_REGEN_DISABLED")
	this:RegisterEvent("PLAYER_REGEN_ENABLED")
	this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
	this:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
	this:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
	this:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")

	DEFAULT_CHAT_FRAME:AddMessage("JTE loaded.");
	SLASH_JTE1 = "/jte";
	SlashCmdList["JTE"] = function(msg)
		JTE_SlashCommandHandler(msg);
	end
	JTE_CheckEquip()
	_G.LoggingCombat(true)
end

--招架统计初始化
local JTE_CombatStartTime = time()
local JTE_CombatEndTime = time()
local JTE_SwingParryCount = 0
local JTE_SkillParryCount = 0
function JTE_ParryCountInit()
	JTE_CombatStartTime = time()
	JTE_SwingParryCount = 0
	JTE_SkillParryCount = 0
end
--招架统计战斗结束时

function JTE_ParryCountWhenCombatEnd()
	JTE_CombatEndTime = time()
	local total = JTE_SwingParryCount + JTE_SkillParryCount
    local rate
    if total <= 0 then
        rate = JTE_TEXT_PARRYCOUNTPERFECT
    else 
        if total <=3 then
            rate = JTE_TEXT_PARRYCOUNTNORMAL
        else 
            if total <=6 then
                rate = JTE_TEXT_PARRYCOUNTBAD
            else
                rate = JTE_TEXT_PARRYCOUNTTERRIBLE
            end
        end
    end

	if JTE_CombatEndTime > 0 and JTE_CombatStartTime > 0 then
		local combatTime = JTE_CombatEndTime - JTE_CombatStartTime
		local msgtext = JTE_PARRYCOUNTHEADER..JTE_PARRYCOUNTLASTCOMBAT..total..JTE_TEXT_PARRYCOUNTDETAILSTIMES.." - "..rate.." ( "..JTE_TEXT_PARRYCOUNTDETAILSSPELL..JTE_SkillParryCount.." "..JTE_TEXT_PARRYCOUNTDETAILSSWING..JTE_SwingParryCount.." "..JTE_TEXT_PARRYCOUNTDETAILSCOMBATTIME..combatTime.." ) "
		if combatTime > 120 then
			--团队通报
			if GetNumRaidMembers() > 0 then
				SendChatMessage(msgtext, "RAID")
			else
				--DEFAULT_CHAT_FRAME:AddMessage(msgtext)
				SendChatMessage(msgtext, "SAY")
			end
		elseif combatTime > 0 then
			--DEFAULT_CHAT_FRAME:AddMessage(msgtext)
			SendChatMessage(msgtext, "SAY")
		elseif combatTime <= 0 then
			jtprint("Combat Time error".."Start:"..JTE_CombatStartTime.." End:"..JTE_CombatEndTime)
		end
		
	end

end

function JTE_OnEvent()
	if (event == "UNIT_INVENTORY_CHANGED") then
		JTE_CheckEquip()
	elseif (event == "VARIABLES_LOADED") then
		JTE_CheckEquip()
	elseif (event == "PLAYER_REGEN_DISABLED") then
		--开始战斗
		--招架统计初始化
		JTE_ParryCountInit()
		
	elseif (event == "PLAYER_REGEN_ENABLED") then
		--自身BUFF音效
		JTE_ParryCountWhenCombatEnd()
	elseif (event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS") then
		--自身BUFF音效
		JTE_SelfBuffSoundEffect(arg1)
	elseif (event == "COMBAT_TEXT_UPDATE") then
		--通用战斗记录音效
		if arg1 == "AURA_END" then
			JTE_AuraEndSoundEffect(arg2)
		end
		if arg1 == "ENERGY" then
			JTE_EnergyRestoreSoundEffect(arg2)
		end
	elseif (event == "CHAT_MSG_SPELL_SELF_DAMAGE") then
		JTE_SkillSoundEffect(arg1)
	elseif (event == "CHAT_MSG_COMBAT_SELF_HITS") then
		JTE_SwingHitSoundEffect(arg1)
	elseif (event == "CHAT_MSG_COMBAT_SELF_MISSES") then
		JTE_SwingMissSoundEffect(arg1)
	end
end

function JTE_OnUpdate()

end

function JTE_SlashCommandHandler(msg)
	if( msg ) then
		local command = string.lower(msg);
		if( command == "log" or command == "combatlog") then
			JTE_CombatLog()
		elseif( command == "t" ) then
			jttest()
		elseif( command == "test" ) then
			if JTTEST then
				DEFAULT_CHAT_FRAME:AddMessage('JTE test message : Off')
				JTTEST = false
			else
				DEFAULT_CHAT_FRAME:AddMessage('JTE test message : ON')
				JTTEST = true
			end
		elseif( command == "i" or command == "ilvl") then
			JTE_MyItemLevel()
		else
			JTE_help();
		end
	end
end


function jtprint(msg)
	if JTTEST then
		DEFAULT_CHAT_FRAME:AddMessage('JTE: '..msg)
	end
end

--输出自身iLvl，需要S_ItemTip插件,因为看不到自身iLvl
function JTE_MyItemLevel()
	local myilvl = JTE_ScanUnit("player")
	local name = UnitName("player")
	jtprint(name.."'s ItemLevel :d "..myilvl)
end


function JTE_Calculate(rarity, ilvl)
	if not rarity then return nil end
	return ilvl
end

function JTE_ScanUnit(unit)
	if not UnitIsPlayer(unit) then return nil end

	local count, score, r, g, b = 0, 0, 1, 1, 0
  
	for i=1,19 do
		if GetInventoryItemLink(unit, i) then
			--/run _, _, itemID = string.find(GetInventoryItemLink("player", 13), "item:(%d+):%d+:%d+:%d+") DEFAULT_CHAT_FRAME:AddMessage('c:'..itemID)
			local _, _, itemID = string.find(GetInventoryItemLink(unit, i), "item:(%d+):%d+:%d+:%d+")
			local _, _, itemLink = string.find(GetInventoryItemLink(unit, i), "(item:%d+:%d+:%d+:%d+)");

			local n = tonumber(itemID)
			local itemLevel = n and LIDL.Item_Level[n] or 0
			local itemName, _, itemRarity = GetItemInfo(itemLink)
			
			if itemName and (itemLevel > 0) then
				score = score + JTE_Calculate(itemRarity, itemLevel)
				count = count + 1
			end
		end
	end

	if count <= 0 then count = 1 end
	score = tonumber(string.format("%0.1f", (score / count)))
  
	if score ~= 0 then return score, r, g, b else return nil end
end

--Name on/off Avoid reducing FPS in the city
function JTE_NameToggle()
	if ( GetCVar("UnitNamePlayer") == "1" ) then
		SetCVar("UnitNamePlayer",0);
	else
		SetCVar("UnitNamePlayer",1);
	end
end

--CombatLog on/off 
function JTE_CombatLog()
	if _G.LoggingCombat()  then
		jtprint("|cFFFFF569战斗记录 |R-> |cFFFF5555关闭")
		_G.LoggingCombat(false)
	else
		jtprint("|cFFFFF569战斗记录 |R-> |cFF55FF55开启")
		_G.LoggingCombat(true)
	end
end

--根据名字检查buff,return isActive, index
function JTE_IsBuffActive(buffname, unit)
	JTEIsBuffActiveTooltip:SetOwner(UIParent, "ANCHOR_NONE");
	if (not buffname) then
		return;
	end;
	if (not unit) then
		unit="player";
	end;
	if string.lower(unit) == "mainhand" then
		JTEIsBuffActiveTooltip:ClearLines();
		JTEIsBuffActiveTooltip:SetInventoryItem("player",GetInventorySlotInfo("MainHandSlot"));
		for i = 1,JTEIsBuffActiveTooltip:NumLines() do
			if string.find((getglobal("JTEIsBuffActiveTooltipTextLeft"..i):GetText() or ""),buffname) then
				return true
			end;
		end
		return false
	end
	if string.lower(unit) == "offhand" then
		JTEIsBuffActiveTooltip:ClearLines();
		JTEIsBuffActiveTooltip:SetInventoryItem("player",GetInventorySlotInfo("SecondaryHandSlot"));
		for i=1,JTEIsBuffActiveTooltip:NumLines() do
			if string.find((getglobal("JTEIsBuffActiveTooltipTextLeft"..i):GetText() or ""),buffname) then
				return true
			end;
		end
		return false
	end
  local i = 1;
  while UnitBuff(unit, i) do 
		JTEIsBuffActiveTooltip:ClearLines();
		JTEIsBuffActiveTooltip:SetUnitBuff(unit,i);
    if string.find(JTEIsBuffActiveTooltipTextLeft1:GetText() or "", buffname) then
      return true, i
    end;
    i = i + 1;
  end;
  local i = 1;
  while UnitDebuff(unit, i) do 
		JTEIsBuffActiveTooltip:ClearLines();
		JTEIsBuffActiveTooltip:SetUnitDebuff(unit,i);
    if string.find(JTEIsBuffActiveTooltipTextLeft1:GetText() or "", buffname) then
      return true, i
    end;
    i = i + 1;
  end;
end

--时间格式
function formatTime(t)
	local h = floor(t / 3600)
	local m = floor((t - h * 3600) / 60)
	local s = t - (h * 3600 + m * 60)
	if h > 0 then
		return format('%d:%02d:02d', h, m, s)
	elseif m > 0 then
		return format('%d:%02d', m, s)
	elseif s < 10 then
		return format('%.1f', s)
	else
		return format('%.0f', s)
	end
end

--根据名字获取物品ID，用对比名字的办法

--根据物品ID获取物品名字
--/run id=JTE_GetNameByID("10725:0:0") jtprint(id)
function JTE_GetNameByID(itemID)
	local name,texture
	local _,_,id = string.find(itemID or "","(%d+):%d+:%d+")
	name,_,_,_,_,_,_,_,texture = GetItemInfo(id or "")
	if itemID==0 then
		name = "(empty)"
		texture = "Interface\\PaperDoll\\UI-Backpack-EmptySlot"
	end
	return name,texture
end

--检查全身装备
function JTE_CheckEquip()
--	s = 13 start,cd,d = GetInventoryItemCooldown("player",s) c=start+cd-GetTime() DEFAULT_CHAT_FRAME:AddMessage('CD:'..cd..' C:'..c..' D:'..d)
	for i=0,19 do
		local start, cd, usable = GetInventoryItemCooldown("player",i)
		local timeleft = start + cd - GetTime()
--		DEFAULT_CHAT_FRAME:AddMessage('Slot('..i..') START:'..start..' CD:'..cd..' TimeLeft:'..timeleft..' Usable:'..usable)
		JTSLOTSTART[i] = start
		JTSLOTCD[i] = cd
		JTSLOTUSABLE[i] = usable
	end
end

function jtSlotCD(s)
	JTE_CheckEquip()
	local usable = JTSLOTUSABLE[s]
	local start = JTSLOTSTART[s]
	local cd = JTSLOTCD[s]
	local cdleft = start + cd - GetTime()
	if cdleft < 0 then
		cdleft = 0
	end
	DEFAULT_CHAT_FRAME:AddMessage('Slot('..s..') START:'..start..' CD:'..cd..' CDLeft:'..cdleft..' Usable:'..usable)
	return usable, start, cdleft
end

--For DPSMate HotKeys
local _GL = getglobal
function JTE_DPSMateToggleAll()
	if ( DPSMate ) then
		local frame = _GL("DPSMate_"..DPSMateSettings["windows"][1]["name"])
		if DPSMateSettings["windows"][2] then
			if DPSMateSettings["windows"][2]["hidden"] then
				for _, val in DPSMateSettings["windows"] do DPSMate.Options:Show(getglobal("DPSMate_"..val["name"])) end
			else
				for _, val in DPSMateSettings["windows"] do DPSMate.Options:Hide(getglobal("DPSMate_"..val["name"])) end
				if frame then
					DPSMate.Options:Show(frame)
				end
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage('DPSMate没有其他窗口')
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage('JTE: DPSMate UI required');
	end

end

function JTE_DPSMateToggleDPS()
	if ( DPSMate ) then

		local frame = _GL("DPSMate_"..DPSMateSettings["windows"][1]["name"])
		if frame then
			if DPSMateSettings["windows"][1] then

				if DPSMateSettings["windows"][1]["hidden"] then
					DPSMate.Options:Show(frame)
				else
					DPSMate.Options:Hide(frame)
				end
			else
				DEFAULT_CHAT_FRAME:AddMessage('请在DPSMate中创建窗口/dps config')
			end
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage('JTE: DPSMate UI required');
	end
end

--For ItemRack Set Toggle HotKey
function JTE_ItemrackSetToggle()
	if ( ItemRack ) then
		local suc = pcall(ItemRack_Sets_Toggle);
		if not suc then
			DEFAULT_CHAT_FRAME:AddMessage(JTE_TEXT_FUNCTION_NOT_WORKING..JTE_TEXT_ITEMRACK_SETS_TOGGLE);
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage(JTE_TEXT_UI_MISSING..JTE_TEXT_UIMISSING_ITEMRACK);
	end
end

--For TrinketMenu Config Toggle
function JTE_TrinketMenuToggle()
	if ( TrinketMenu ) then
		TrinketMenu.ToggleFrame(TrinketMenu_OptFrame);
	else
		DEFAULT_CHAT_FRAME:AddMessage(JTE_TEXT_UI_MISSING..JTE_TEXT_UIMISSING_TRINKETMENU);
	end
end

--招架统计

--音效间隔
local lastCrusaderSoundTime = 0

--普攻命中音效
function JTE_SwingHitSoundEffect(arg1)
	--打脸了
	if UnitName("targettarget") and UnitName("targettarget") ~= JTE_PlayerName then
		--mute boss 待完工、
		--格挡部分
		local blocktext = string.sub(BLOCK_TRAILER, 6)
		if string.find(arg1,blocktext) then
			PlaySoundFile('Interface\\addons\\JTE\\Sounds\\dalianle.mp3')
		end
	end
end
--普攻未命中音效
function JTE_SwingMissSoundEffect(arg1)
	--打脸了
	if UnitName("targettarget") and UnitName("targettarget") ~= JTE_PlayerName then
		--mute boss 待完工、
		--招架部分
		if string.find(arg1,PARRY) then
			JTE_SwingParryCount = JTE_SwingParryCount + 1
			PlaySoundFile('Interface\\addons\\JTE\\Sounds\\dalianle.mp3')
		end
	end
end



--技能音效
function JTE_SkillSoundEffect(arg1)
	--打脸了
	if UnitName("targettarget") and UnitName("targettarget") ~= JTE_PlayerName then
		--mute boss 待完工、
		--格挡部分
		local blocktext = string.sub(BLOCK_TRAILER, 6)
		if string.find(arg1,blocktext) then
			PlaySoundFile('Interface\\addons\\JTE\\Sounds\\dalianle.mp3')
		end
		--招架部分
		if string.find(arg1,PARRY) then
			JTE_SkillParryCount = JTE_SkillParryCount + 1
			PlaySoundFile('Interface\\addons\\JTE\\Sounds\\dalianle.mp3')
		end
	end

	--地精工兵炸弹和致密炸弹释放
	if string.find(arg1,JTE_TEXT_USEITEM_GOBLINSAPPERCHARGE) then
		PlaySoundFile('Interface\\addons\\JTE\\Sounds\\boom.mp3')
	elseif string.find(arg1,JTE_TEXT_USEITEM_DENSEDYNAMITE) then
		PlaySoundFile('Interface\\addons\\JTE\\Sounds\\boom.mp3')
	end

end

--SelfBuff音效
function JTE_SelfBuffSoundEffect(arg1)
	--判断职业，大写，判断图标内容，播放声音
	
	--盗贼职业部分
	if JTE_PlayerClass == "ROGUE" then
		if string.find(arg1,JTE_TEXT_SKILL_BLADE_FLURRY) then
			PlaySoundFile('Interface\\addons\\JTE\\Sounds\\OW\\genji.mp3')
		elseif string.find(arg1,JTE_TEXT_SKILL_ADRENALINE_RUSH) then
			PlaySoundFile('Interface\\addons\\JTE\\Sounds\\OW\\hanzolong.mp3')
		elseif string.find(arg1,JTE_TEXT_SKILL_SPRINT) then
			PlaySoundFile('Interface\\addons\\JTE\\Sounds\\OW\\luciospeed.mp3')
		end
	end
	--通用提醒
	if string.find(arg1,JTE_TEXT_BUFF_CRUSADER) and time() - lastCrusaderSoundTime > 7 then
		PlaySoundFile('Interface\\addons\\JTE\\Sounds\\OW\\lucioheal.mp3')
		lastCrusaderSoundTime = time()
	end

	--战斗中提醒的部分，切割切割
end

--Buff结束音效
function JTE_AuraEndSoundEffect(buffname)
	if JTE_PlayerClass == "ROGUE" then
		--在团队战斗时
		if UnitAffectingCombat("player") and GetNumRaidMembers() > 0 then
			if buffname == JTE_TEXT_SKILL_SLICEDICE then
				PlaySoundFile('Interface\\addons\\JTE\\Sounds\\slicedice.ogg')
			end
		end
		--随时提醒
		if buffname == JTE_TEXT_SKILL_EVASION then
			PlaySoundFile('Interface\\addons\\JTE\\Sounds\\evasionend.mp3')
		end

	end

end

--回能音效
function JTE_EnergyRestoreSoundEffect(energynum)
	if JTE_PlayerClass == "ROGUE" then
		local tierzero = 35
		local charmoftrickery = 60
		local en = tonumber(energynum)
		if en == tierzero then
			PlaySoundFile('Interface\\addons\\JTE\\Sounds\\swordecho.ogg')
		elseif en == charmoftrickery then
			PlaySoundFile('Interface\\addons\\JTE\\Sounds\\OW\\annago.mp3')
		end
	end

end



function JTE_checkSnd()
	
	local i = 0
	local timeleft = 0
	local checktime = GetTime()
	local sndfound = false

	while GetPlayerBuffTexture(i) ~= nil do

		if GetPlayerBuffTexture(i) == "Interface\\Icons\\Ability_Rogue_SliceDice" then
			timeleft = GetPlayerBuffTimeLeft(i)
--			DEFAULT_CHAT_FRAME:AddMessage('Slice snd found!!')
			sndfound = true
			SND_IS_ACTIVE = true
			return i, checktime, timeleft
		else
			i = i + 1
		end
	end

--	DEFAULT_CHAT_FRAME:AddMessage('No snd!!')
	SND_IS_ACTIVE = false
	return -1, 0, 0

end



--这部分部分功能基本都被TrinketMenu替代了，无视好了。
--使用主动饰品，脱战切换下一个饰品的宏，依赖ItemRack插件的更换排序功能

--/run c=Rack.GetNameByID("13523:0:0") DEFAULT_CHAT_FRAME:AddMessage('C:'..c)
--/run c=Rack.GetItemID("毒性图腾") if not c then c="noitem" end DEFAULT_CHAT_FRAME:AddMessage('C:'..c)
--/run Rack.AddToCombatQueue(13,"19342:0:0")
--/run local itemTexture, itemID, itemName, itemSlot = Rack.GetItemInfo(13) DEFAULT_CHAT_FRAME:AddMessage('C:'..itemName)
--/run local inv,bag,slot = Rack.FindItem(itemID,itemName,passive)
--/run jttq(13,"雷纳塔基的狡诈护符","毒性图腾")
--/run jttq(13,"黎明之印","雷纳塔基的狡诈护符")
--/run jttq(13,"埃雷萨拉斯皇家徽记","雷纳塔基的狡诈护符")
--/run jttq(13,"雷纳塔基的狡诈护符")
--/run jttq(13,"毒性图腾")
--/run jttq(13,"尼雷米乌斯的馈赠")
--IsShiftKeyDown() 写在宏里，插件里不管

function jttq(slot,aftertrinket,maintrinket)
	--尝试更换成主饰品，没有主饰品就不处理
	local itemTexture, itemID, itemName, itemSlot = Rack.GetItemInfo(13)
	local s = slot
	local atid = Rack.GetItemID(aftertrinket)
	local incombatchangetime = 30
	local outcombatchangetime = 120

	JTE_CheckEquip()
	local start = JTSLOTSTART[s]
	local cd = JTSLOTCD[s]
	local cdleft = start + cd - GetTime()
	local usable = JTSLOTUSABLE[s]

	local ms, mcd, mu
	local mcdleft

	local as, acd, au
--	as, acd, au = GetItemCooldown(aftertrinket)
--	jtprint("au: "..au)
	local acdleft

	if maintrinket then
		local mtid = Rack.GetItemID(maintrinket)

		if mtid == itemID then
			UseInventoryItem(s)

			JTE_CheckEquip()
			start = JTSLOTSTART[s]
			cd = JTSLOTCD[s]
			cdleft = start + cd - GetTime()

			ms, mcd, mu = GetItemCooldown(maintrinket)
			mcdleft = math.max(ms + mcd - GetTime(),0)

			as, acd, au = GetItemCooldown(aftertrinket)
			acdleft = math.max(as + acd - GetTime(),0)

			if cdleft > 30 then
				if atid and acdleft <= mcdleft then
					if UnitAffectingCombat("player") then
						Rack.AddToCombatQueue(s,atid)
						jtprint("脱战后更换: "..aftertrinket)
					else
						Equipslot(s,aftertrinket)
						jtprint("饰品切换为: "..aftertrinket)
					end
				end
			elseif cdleft > 0 then
				jtprint("饰品即将可以使用"..math.floor(cdleft).."秒")
			end
		else
			--判断身上的饰品能不能用
			if usable == 1 and start == 0 then
				UseInventoryItem(s)
			else

				ms, mcd, mu = GetItemCooldown(maintrinket)
				mcdleft = math.max(ms + mcd - GetTime(),0)

				as, acd, au = GetItemCooldown(aftertrinket)
				acdleft = math.max(as + acd - GetTime(),0)

				if UnitAffectingCombat("player") then
					if mcdleft < incombatchangetime then
						Rack.AddToCombatQueue(s,mtid)
						jtprint("脱战后更换: "..maintrinket.." ("..math.floor(mcdleft).."秒)")
					else
						jtprint(maintrinket.."的剩余CD还有("..math.floor(mcdleft).."秒) 战斗中需要在 "..incombatchangetime.." 秒之内更换")
					end
				else
					if mcdleft < outcombatchangetime then
						Equipslot(s,maintrinket)
						jtprint("饰品切换为: "..maintrinket.." ("..math.floor(mcdleft).."秒)")
					else
						jtprint(maintrinket.."的剩余CD还有("..math.floor(mcdleft).."秒) 战斗外低于"..outcombatchangetime.."秒更换")
					end
				end
			end
		end
	else

		if usable == 1 and start == 0 then

			UseInventoryItem(s)

		else

			JTE_CheckEquip()
			start = JTSLOTSTART[s]
			cd = JTSLOTCD[s]
			cdleft = start + cd - GetTime()	

			as, acd, au = GetItemCooldown(aftertrinket)
			acdleft = math.max(as + acd - GetTime(),0)

			if usable == 0 or cdleft > 30 then
				if atid then
					if UnitAffectingCombat("player") then
					if acdleft < incombatchangetime then
							Rack.AddToCombatQueue(s,atid)
							jtprint("脱战后更换: "..aftertrinket)
						else
							jtprint(aftertrinket.."的剩余CD还有("..math.floor(acdleft).."秒) 战斗中需要在 "..incombatchangetime.." 秒之内更换")
						end
					else
						if acdleft < outcombatchangetime then
							Equipslot(s,aftertrinket)
							jtprint("饰品切换为: "..aftertrinket)
						else
							jtprint(aftertrinket.."的剩余CD还有("..math.floor(acdleft).."秒) 战斗外低于"..outcombatchangetime.."秒更换")
						end
					end
				end
			elseif cdleft > 0 then
				jtprint("饰品即将可以使用"..math.floor(cdleft).."秒")
			end
		end
	end
end


--已经被TrinketMenu取代，这个功能可以用作穿上/使用小鸡的快捷键。穿戴的30秒CD没好的时候使用会快速换饰品，避免卡饰品
--/run jtChicken(14,"黑手饰物")
function jtChicken(slot,aftertrinket)
	local chickenid = 10725 
	if UnitAffectingCombat("player") then
		jtprint("战斗中无法更换饰品")
		return
	end
	JTE_CheckEquip()
	local s = slot
	--修正slot为13和14
	if s == 2 or s == 14 then
		s = 14
	else
		s = 13
	end

	local start = JTSLOTSTART[s]
	local usable = JTSLOTUSABLE[s]
	local cd = JTSLOTCD[s]
	local cdleft = start + cd - GetTime()

	--拿到小鸡当前的状态,CD小于等于31就可以用
	--/run local chickenstart, chickencd, chickenusable = GetItemCooldown(CHICKENNAME) DEFAULT_CHAT_FRAME:AddMessage("JTE: "..chickenstart)
	
	local chickenstart, chickencd, chickenusable = GetItemCooldown(CHICKENNAME)
	local chickencdleft = chickenstart + chickencd - GetTime()
	--starttime大于0，是cd中，判断时间。小于等于0是cd好了
	
	--身上slot是被动就穿小鸡，否则需要手动换小鸡
	if chickencdleft > 120 and start ~= chickenstart then
		jtprint("小鸡剩余CD: "..math.floor(chickencdleft).." 秒，大于 120 秒时小鸡宏不会更换饰品")	
		return
	end
	if usable == 0 then
		Equipslot(s, CHICKENNAME)
		if chickencdleft > 30 then
			jtprint("**********小鸡剩余CD大于30秒，请注意CD时间**********")
		end
		
	else
		if cd > 30 then
			--cd了，并且判断时间跟小鸡时间重合（判定是小鸡），换饰品
			if start == chickenstart then
				Equipslot(s,aftertrinket)
			else
				if chickencdleft > 30 then
					jtprint("**********小鸡剩余CD大于30秒，请注意CD时间**********")
				end
			end
		else
			--穿一次小鸡，已经穿了就不会替换
			Equipslot(s, CHICKENNAME)
			--刷新一下状态
			JTE_CheckEquip()

			start = JTSLOTSTART[s]
			usable = JTSLOTUSABLE[s]
			cd = JTSLOTCD[s]
			cdleft = start + cd - GetTime()

			--拿到小鸡当前的状态,CD小于等于31就可以用
			chickenstart, chickencd, chickenusable = GetItemCooldown("CHICKENNAME")

			if start == 0 then
				UseInventoryItem(s)
				JTE_CheckEquip()
				start = JTSLOTSTART[s]
				if start > 0 then
					Equipslot(s,aftertrinket)
					jtprint("释放，切换为"..aftertrinket)
				end
			else
				Equipslot(s,aftertrinket)
				jtprint("小鸡更换不足30秒，切换为"..aftertrinket)
			end
		end
	end

end

function jttest(arg1)
	--判断职业，大写，判断图标内容，播放声音
	local bfname = "剑刃乱舞"
	local arname = "冲动"
	if string.find(arg1,bfname) then
		PlaySoundFile('Interface\\addons\\JTE\\Sounds\\OW\\genji.mp3')
	elseif string.find(arg1,arname) then
		PlaySoundFile('Interface\\addons\\JTE\\Sounds\\OW\\henzolong.mp3')
	end
	
end



function JTE_help()
	DEFAULT_CHAT_FRAME:AddMessage(" JTE  : Usage - /jte option");
	DEFAULT_CHAT_FRAME:AddMessage(" options:");
	DEFAULT_CHAT_FRAME:AddMessage("  ilvl    : Display player itemlevel (Need S_ItemTip)");
	DEFAULT_CHAT_FRAME:AddMessage("  log     : Enable/Disable CombatLogging");

end
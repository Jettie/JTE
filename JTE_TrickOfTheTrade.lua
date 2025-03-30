local _G = _G
local addonName, JTE = ...

-- 嫁祸恢复为初始鼠标指向宏？ 但是宏仍然是旧的

JTE.TOT = {}
local TOT = JTE.TOT
local JTE_Print = JTE_Print or print
local TOTFrame, TOTFrameEvents = CreateFrame("Frame"), {};

local myName = JTE.MyName
local myGUID = JTE.MyGUID
local myClassName, myClass = UnitClass("player")
local locale = GetLocale()
local classColorName = JTE.ClassColorName
local coloredMyName = classColorName(myName)
local colorNameByClass = JTE.ColorNameByClass
local MAX_NUM_MACROS = 4

local commonDefaltMacroTextStr = ([[#showtooltip %s
/cast [@mouseover,help,exists,nodead][@target,help,exists,nodead][@targettarget,help,nodead]%s
/stopspelltarget]])

local showtooltipTextStr = ([[#showtooltip %s
]])
-- local macroTextOnlyTarget = ([[/cast [@%s,help,exists,nodead][@targettarget,help,nodead]%s
-- /stopspelltarget]])
local commonMacroTextOnlyTargetStr = ([[/cast [@%s,help,exists,nodead][@targettarget,help,nodead]%s
/stopspelltarget]])

-- local macroTextWithMouseover = ([[/cast [@mouseover,help,exists,nodead][@%s,help,exists,nodead][@targettarget,help,nodead]%s
-- /stopspelltarget]])

local commonMacroTextWithMouseoverStr = ([[/cast [@mouseover,help,exists,nodead][@%s,help,exists,nodead][@targettarget,help,nodead]%s
/stopspelltarget]])

local whisperMacroStr = ([[/run if JTE and JTE.WTOT then JTE.WTOT("%s","%s")end
]])

local sendToTOORmessage = function(spellName, unitName)
	if IsSpellInRange(spellName,unitName) == 0 and GetSpellCooldown(spellName) == 0 then
		local msg = " (:o): 太远了，"..(spellName or "").."不到你"
		SendChatMessage(msg, "WHISPER", nil, unitName)
	end
end
JTE.WTOT = sendToTOORmessage

local spellListForAllClasses = {
	["ROGUE"] = {
		spellId = 57934,
		shortName = "嫁祸",
		macroTextStr = commonDefaltMacroTextStr,
		macroTextOnlyTargetStr = commonMacroTextOnlyTargetStr,
		macroTextWithMouseoverStr = commonMacroTextWithMouseoverStr,
	},
	["HUNTER"] = {
		spellId = 34477,
		shortName = "误导",
		macroTextStr = ([[#showtooltip %s
/cast [mod:alt,@pet,exists,nodead][@mouseover,help,exists,nodead][@target,help,exists,nodead][@targettarget,help,nodead]%s
/stopspelltarget]]),
		macroTextOnlyTargetStr = ([[/cast [mod:alt,@pet,exists,nodead][@%s,help,exists,nodead][@targettarget,help,nodead]%s
/stopspelltarget]]),
		macroTextWithMouseoverStr = ([[/cast [mod:alt,@pet,exists,nodead][@mouseover,help,exists,nodead][@%s,help,exists,nodead][@targettarget,help,nodead]%s
/stopspelltarget]]),
		canTargetMyPet = true,
	},
	["DEATHKNIGHT"] = {
		spellId = 49016,
		shortName = "狂热",
		macroTextStr = ([[#showtooltip %s
/cast [mod:alt,@player][@mouseover,help,exists,nodead][@target,help,exists,nodead][@targettarget,help,nodead]%s
/stopspelltarget]]),
		macroTextOnlyTargetStr = ([[/cast [mod:alt,@player][@%s,help,exists,nodead][@targettarget,help,nodead]%s
/stopspelltarget]]),
		macroTextWithMouseoverStr = ([[/cast [mod:alt,@player][@mouseover,help,exists,nodead][@%s,help,exists,nodead][@targettarget,help,nodead]%s
/stopspelltarget]]),
		isTalentSkill = true,
		allowSelfTarget = true,
		-- canTargetMyPet = true, -- JT测试宠物目标用的
	},
	["PRIEST"] = {
		spellId = 10060,
		shortName = "灌注",
		macroTextStr = ([[#showtooltip %s
/cast [mod:alt,@player][@mouseover,help,exists,nodead][@target,help,exists,nodead][@targettarget,help,nodead]%s
/stopspelltarget]]),
		macroTextOnlyTargetStr = ([[/cast [mod:alt,@player][@%s,help,exists,nodead][@targettarget,help,nodead]%s
/stopspelltarget]]),
		macroTextWithMouseoverStr = ([[/cast [mod:alt,@player][@mouseover,help,exists,nodead][@%s,help,exists,nodead][@targettarget,help,nodead]%s
/stopspelltarget]]),
		isTalentSkill = true,
		allowSelfTarget = true,
	},
	["MAGE"] = {
		spellId = 54646,
		shortName = "专注",
		macroTextStr = commonDefaltMacroTextStr,
		macroTextOnlyTargetStr = commonMacroTextOnlyTargetStr,
		macroTextWithMouseoverStr = commonMacroTextWithMouseoverStr,
		isTalentSkill = true,
	},
	["DRUID"] = {
		spellId = 29166,
		shortName = "激活",
		macroTextStr = ([[#showtooltip %s
/cast [mod:alt,@player][@mouseover,help,exists,nodead][@target,help,exists,nodead][@targettarget,help,nodead]%s
/stopspelltarget]]),
		macroTextOnlyTargetStr = ([[/cast [mod:alt,@player][@%s,help,exists,nodead][@targettarget,help,nodead]%s
/stopspelltarget]]),
		macroTextWithMouseoverStr = ([[/cast [mod:alt,@player][@mouseover,help,exists,nodead][@%s,help,exists,nodead][@targettarget,help,nodead]%s
/stopspelltarget]]),
		allowSelfTarget = true,
	}
}

local theSpellId = 57934 -- 嫁祸诀窍
local theSpellShortName = "嫁祸"
local theSpellName, _, theSpellIcon = GetSpellInfo(theSpellId)

local GetSpellLinkWithIcon = function(spellId)
	local _, _, icon = GetSpellInfo(spellId)
	return icon and (JTE.iconStr(icon) or "")..GetSpellLink(spellId) or ""
end
local theSpellLink = GetSpellLinkWithIcon(theSpellId)
local ICON = theSpellIcon
local totHeader = "|CFFFFFFFF[|R"..theSpellShortName.."|CFFFFFFFF]|R "

local IsJTToTWAEnabled = false
local meInGroup = false

local SV
local IsToTEnabledForMe = function()
	if myClass == "ROGUE" or (SV and SV.EnableAllClasses and spellListForAllClasses[myClass]) then
		return true
	else
		return false
	end
end

-- 只是为了天赋技能的判断，非天赋技能哪怕低级没学也一样true
local skillAviable = true
local OnPlayerTalentUpdate = function()
	if spellListForAllClasses[myClass] and spellListForAllClasses[myClass].isTalentSkill then
		if not IsSpellKnown(spellListForAllClasses[myClass].spellId) then
			if IsToTEnabledForMe() then
				JTE_Print(totHeader.."没有激活"..theSpellLink.."天赋 |cff94EF00A|r|cffEF573EB|r|cff28ABE0X|r|cffF4D81EY|r按钮|CFFFF0000自动隐藏|R")
			end
			skillAviable = false
			return
		end
	end
	skillAviable = true
	if IsToTEnabledForMe() then
		JTE_Print(totHeader..theSpellLink.."天赋已激活 |cff94EF00A|r|cffEF573EB|r|cff28ABE0X|r|cffF4D81EY|r按钮|CFF00FF00自动激活|R")
	end
end

local LoadSavedVariables = function()
	-- SavedVariables: db
	local db = JTEDB or {}

	db.TOT = db.TOT or {}
	db.TOT[myName] = db.TOT[myName] or {}
	SV = db.TOT[myName]

	if not SV.macros then
		SV.macros = {}
	end

	if not SV.mouseOverDisabled then
		SV.mouseOverDisabled = {
			[1] = true,
			[2] = true,
			[3] = true,
			[4] = true,
		}
	end

	SV.oorWhisper = (SV.oorWhisper == nil) and true or SV.oorWhisper

	SV.ExtraButtonBB = SV.ExtraButtonBB or false
	SV.ExtraButtonDY = SV.ExtraButtonDY or false

	SV.EnableAllClasses = SV.EnableAllClasses or false

	if not SV.enableNumMacros or SV.enableNumMacros < 1 or SV.enableNumMacros > MAX_NUM_MACROS then
		if IsToTEnabledForMe() then
			JTE_Print(totHeader.."当前"..theSpellLink.."宏数量为 |CFFFF53A22|R 个")
		end
		SV.enableNumMacros = 2
	end
end

local ReactivateButton = function(id)
	if IsToTEnabledForMe() then
		if id <= SV.enableNumMacros then
			if skillAviable then
				WeakAuras.ScanEvents("JT_TOT_BUTTON_SHOW", id)
				return
			end
		end
	end
	WeakAuras.ScanEvents("JT_TOT_BUTTON_HIDE", id)
end
JTE.ToTReactivateButton = ReactivateButton

local RebuildSpellInfo = function()
	if not SV.EnableAllClasses then
		return
	end
	if not spellListForAllClasses[myClass] then
		return
	end
	theSpellId = spellListForAllClasses[myClass].spellId
	theSpellName, _, theSpellIcon = GetSpellInfo(theSpellId)
	theSpellShortName = (locale == "zhCN") and spellListForAllClasses[myClass].shortName or theSpellName
	theSpellLink = theSpellIcon and (JTE.iconStr(theSpellIcon) or "")..GetSpellLink(theSpellId)
	ICON = theSpellIcon
	totHeader = "|CFFFFFFFF[|R"..theSpellShortName.."|CFFFFFFFF]|R "

	-- 快捷键显示文字修改
	BINDING_NAME_JTE_ROGUE_TOT_SET_TARGET_A = JTE.iconStr(theSpellIcon).."设置"..theSpellShortName.."目标|CFF94EF00JTA"
	BINDING_NAME_JTE_ROGUE_TOT_SET_TARGET_B = JTE.iconStr(theSpellIcon).."设置"..theSpellShortName.."目标|CFFEF573EJTB"
	BINDING_NAME_JTE_ROGUE_TOT_SET_TARGET_X = JTE.iconStr(theSpellIcon).."设置"..theSpellShortName.."目标|CFF28ABE0JTX"
	BINDING_NAME_JTE_ROGUE_TOT_SET_TARGET_Y = JTE.iconStr(theSpellIcon).."设置"..theSpellShortName.."目标|CFFF4D81EJTY"
end

TOT.IsToTWALoaded = false
TOT.version = 0
local ToTWALoaded = function(version)
	TOT.IsToTWALoaded = true
	if version then
		TOT.version = version
	end
end
JTE.ToTWALoaded = ToTWALoaded

TOT.waitOOC = {}

TOT.MacroNames = {
	"JTA",
	"JTB",
	"JTX",
	"JTY",
}

local macroSymbol = {
	[1] = "|cff94EF00JTA|r",
	[2] = "|cffEF573EJTB|r",
	[3] = "|cff28ABE0JTX|r",
	[4] = "|cffF4D81EJTY|r",
}

local defaultMacroText = commonDefaltMacroTextStr:format((theSpellName or theSpellShortName),(theSpellName or theSpellShortName))

local RebuildDefaultMacroText = function()
	local myClassMacroTextStr = spellListForAllClasses[myClass] and spellListForAllClasses[myClass].macroTextStr or commonDefaltMacroTextStr
	defaultMacroText = myClassMacroTextStr:format((theSpellName or theSpellShortName),(theSpellName or theSpellShortName))
end
RebuildDefaultMacroText()

TOT.DefaultMacroData = {}

local BuildDefaultMacroData = function()
	TOT.DefaultMacroData = {
		[1] = {
			id = 1,
			name = "JTA",
			coloredMacroName = "|cff94EF00JTA|r",
			icon = ICON,
			macroText = defaultMacroText,
		},
		[2] = {
			id = 2,
			name = "JTB",
			coloredMacroName = "|cffEF573EJTB|r",
			icon = ICON,
			macroText = defaultMacroText,
		},
		[3] = {
			id = 3,
			name = "JTX",
			coloredMacroName = "|cff28ABE0JTX|r",
			icon = ICON,
			macroText = defaultMacroText,
		},
		[4] = {
			id = 4,
			name = "JTY",
			coloredMacroName = "|cffF4D81EJTY|r",
			icon = ICON,
			macroText = defaultMacroText,
		},
	}
end
BuildDefaultMacroData()

local UpdateWaitOOC = function(id, macroData, silent)
	TOT.waitOOC[id] = macroData
	if TOT.waitOOC[id] then
		TOT.waitOOC[id].silent = silent
	end
	if not next(TOT.waitOOC) then
		TOTFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
	else
		TOTFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
end

local CreateOrEditMacro = function(macroData, silent)
	if IsToTEnabledForMe() then
		local id = macroData.id
		local macroName = macroData.name
		local coloredMacroName = macroData.coloredMacroName
		local icon = macroData.icon
		local macroText = macroData.macroText
		local unitName = macroData.unitName -- 有没有unitName表示是设置宏的，没有则表示是初始化宏的

		if id <= SV.enableNumMacros then

			if GetMacroIndexByName(macroName) ~= 0 then
				EditMacro(macroName, macroName, icon, macroText)
			else
				if (GetNumMacros() + 1) > MAX_ACCOUNT_MACROS then
					JTE_Print(totHeader.."通用宏数量不足 建议先清理出一些空位")
					return
				else
					CreateMacro(macroName, icon, macroText)
				end
			end
			-- 修改成功后把数据存起来
			SV.macros[id] = macroData.unitName and macroData or nil

			-- 处理WA的显示
			local WA_ButtonName = macroData and macroData.name or "CLEAR"
			local WA_Name = macroData and macroData.unitName or ""
			-- /dump WeakAuras.GetRegion("JT虚拟焦点按钮")
			if JTE and JTE.IsAddOnLoaded and JTE.IsAddOnLoaded["WeakAuras"] then
				if TOT.IsToTWALoaded then
					if skillAviable then
					-- 按钮显示
						WeakAuras.ScanEvents("JT_TOT_BUTTON_SHOW", id)
					else
						-- 按钮隐藏
						WeakAuras.ScanEvents("JT_TOT_BUTTON_HIDE", id)
					end
					-- WA的事件放这里
					WeakAuras.ScanEvents("JT_TOT_UPDATE_TARGET", id, theSpellShortName, WA_Name)
				end
			end
			if SV.macros[id] then
				SV.macros[id].macroMade = unitName
			end

			if TOT.waitOOC[id] then
				UpdateWaitOOC(id, nil)
			end

			local text = unitName and (theSpellLink.."宏(" .. coloredMacroName .. ")更新目标为 -> " .. classColorName(unitName)) or (theSpellLink.."宏(" .. coloredMacroName .. ")刷新成功")
			JTE_Print(totHeader..text)
		else
			-- 暂定不自动删除宏，避免多角色使用不同数量的宏，换号会来回增伤宏，动作条里的宏会消失，所以还是手动删除吧
			-- if GetMacroIndexByName(macroName) ~= 0 then
			-- 	DeleteMacro(macroName)
			-- end
			WeakAuras.ScanEvents("JT_TOT_BUTTON_HIDE", id)
		end
	else
		if not spellListForAllClasses[myClass] then
			JTE_Print(totHeader.."当前职业 >"..colorNameByClass(myClassName, myClass).."< 没有类嫁祸的技能")
			return
		elseif myClass ~= "ROGUE" and not (SV and SV.EnableAllClasses) then
			JTE_Print(totHeader.."当前职业 >"..colorNameByClass(myClassName, myClass).."< 可开启技能宏: "..GetSpellLinkWithIcon(spellListForAllClasses[myClass].spellId))
			return
		end
	end
end

-- 数量判断好好想想
local InitializeMacros = function(silent)
	if IsToTEnabledForMe() then
		if IsInGroup() then
			meInGroup = true

			local initializeIds = {}
			for i = 1, SV.enableNumMacros do
				initializeIds[i] = true
			end

			local initializedCount = 0
			if next(SV.macros) then
				local waitingMacroNames = ""
				for id, macroData in pairs(SV.macros) do
					if macroData.unitName and UnitExists(macroData.unitName) and (UnitInRaid(macroData.unitName) or UnitInParty(macroData.unitName) or (spellListForAllClasses[myClass] and spellListForAllClasses[myClass].canTargetMyPet and UnitIsUnit(macroData.unitName, "pet"))) then
						if InCombatLockdown() then
							UpdateWaitOOC(id, macroData, silent)
							waitingMacroNames = waitingMacroNames..macroData.coloredMacroName.." "
							
						else
							if (GetNumMacros() + SV.enableNumMacros) > MAX_ACCOUNT_MACROS then
								if not silent then
									JTE_Print(totHeader.."通用宏数量不足 |CFFFF53A2"..SV.enableNumMacros.."|R 个 需要在清理空位后输入: |CFFFFFFFF /jtet |R |CFFFF53A2重新初始化|R")
								end
								return
							else
								CreateOrEditMacro(macroData, silent)
							end
						end
					else
						if not silent then
							local coloredUnitName = macroData.unitName and (macroData.unitClass and colorNameByClass(macroData.unitName, macroData.unitClass) or macroData.unitName) or macroData.unitName
							JTE_Print(totHeader.."> "..coloredUnitName.." < 不在队伍中 "..theSpellLink.."宏("..macroData.coloredMacroName..")重置为初始鼠标悬浮指向宏")
						end
						CreateOrEditMacro(TOT.DefaultMacroData[id], silent)
					end
					initializedCount = initializedCount + 1
					initializeIds[id] = nil
				end
				
				if waitingMacroNames ~= "" then
					JTE_Print(totHeader.."战斗中……稍后更新"..theSpellLink.."宏: "..waitingMacroNames)
				end
			end
			
			-- SV.macros里面没有补齐初始化宏的个数时，需要补齐
			-- if initializedCount < SV.enableNumMacros then
			if next(initializeIds) then
				for id, _ in pairs(initializeIds) do
					if id <= SV.enableNumMacros then
						-- if not silent then
						-- 	JTE_Print(totHeader.."初始化"..theSpellLink.."宏("..TOT.DefaultMacroData[i].coloredMacroName..")")
						-- end
						CreateOrEditMacro(TOT.DefaultMacroData[id], silent)
					end
				end
			end
		else
			if InCombatLockdown() then
				for i = 1, SV.enableNumMacros do
					UpdateWaitOOC(i, TOT.DefaultMacroData[i], silent)
				end
				--JTE_Print(totHeader.."战斗中……稍后更新"..theSpellLink.."宏")
			else
				for i = 1, SV.enableNumMacros do
					CreateOrEditMacro(TOT.DefaultMacroData[i], silent)
				end
				if meInGroup then
					if not silent then
						JTE_Print(totHeader.."所有"..theSpellLink.."宏已恢复初始鼠标悬浮指向宏")
					end
					meInGroup = false
				end
			end
		end
	else
		for id = 1, MAX_NUM_MACROS do
			WeakAuras.ScanEvents("JT_TOT_BUTTON_HIDE", id)
		end
	end
end

-- 数量判断好好想想
local manuallyInitializeAllMacros = function(silent)
	if InCombatLockdown() then
		for i = 1, MAX_NUM_MACROS do
			if SV.macros[i] then
				UpdateWaitOOC(i, SV.macros[i], silent)
			else
				UpdateWaitOOC(i, TOT.DefaultMacroData[i], silent)
			end
		end
		JTE_Print(totHeader.."战斗中……稍后更新"..theSpellLink.."宏")
	else
		for i = 1, MAX_NUM_MACROS do
			if SV.macros[i] then
				CreateOrEditMacro(SV.macros[i], silent)
			else
				CreateOrEditMacro(TOT.DefaultMacroData[i], silent)
			end
		end
		if not silent then
			JTE_Print(totHeader.."所有"..theSpellLink.."宏已刷新")
		end
	end
end
JTE.ToTManuallyInitializeAllMacros = manuallyInitializeAllMacros

local SetToTMacroNum = function(codeText)
	local baseNum = 2
	local extra1 = SV.ExtraButtonBB and 1 or 0
	local extra2 = SV.ExtraButtonDY and 1 or 0
	local num = baseNum + extra1 + extra2
	if num > MAX_NUM_MACROS then
		num = MAX_NUM_MACROS
	elseif num < 2 then
		num = 2
	end
	SV.enableNumMacros = num
	JTE_Print("当前"..theSpellLink.."宏数量为 |CFFFF53A2"..num.."|R 个")
	manuallyInitializeAllMacros() -- 防止连续刷屏
end

local handleCode = function(code)
	local codeList = {
		[1] = "|CFFFF53A2关注抖音领虎冲|R",
		[2] = "|CFFFF53A2关注B站领虎冲|R",
	}
	JTE_Print(totHeader.."暗号 >"..codeList[code].."< 正确!")

	if not spellListForAllClasses[myClass] then
		JTE_Print(totHeader.."当前职业 >"..colorNameByClass(myClassName, myClass).."< 没有类嫁祸的技能")
		return
	elseif myClass ~= "ROGUE" and not (SV and SV.EnableAllClasses) then
		JTE_Print(totHeader.."当前职业 >"..colorNameByClass(myClassName, myClass).."< 可开启技能宏: "..GetSpellLinkWithIcon(spellListForAllClasses[myClass].spellId).." 开启后再输入暗号")
		return
	end

	local enableReceiveCodeText = "收到暗号: "
	local disableReceiveCodeText = "再次收到暗号: "
	local enableText = " |CFF00FF00启用|R额外宏 "
	local disableText = " |CFFFF0000关闭|R额外宏 "
	local codeText = ""
	-- 1 for BB 2 for DY
	if code == 1 then
		if SV.ExtraButtonBB then
			SV.ExtraButtonBB = false
			codeText = disableReceiveCodeText .. codeList[code] .. disableText
		else
			SV.ExtraButtonBB = true
			codeText = enableReceiveCodeText .. codeList[code] .. enableText
		end
	elseif code == 2 then
		if SV.ExtraButtonDY then
			SV.ExtraButtonDY = false
			codeText = disableReceiveCodeText .. codeList[code] .. disableText
		else
			SV.ExtraButtonDY = true
			codeText = enableReceiveCodeText .. codeList[code] .. enableText
		end
	end
	PlaySound(SOUNDKIT.IG_PLAYER_INVITE)
	SetToTMacroNum(codeText)
end
JTE.ToTHandleCode = handleCode

local GetValidUnitName = function(id, isButtonClicked)
	local coloredMacroName = ""
	if id and type(id) == "number" and ( id >= 1 and id <= MAX_NUM_MACROS ) then
		coloredMacroName = TOT.DefaultMacroData[id].coloredMacroName
	end

	-- 未开启的宏
	if SV and SV.enableNumMacros and id > SV.enableNumMacros then
		local classData = (RAID_CLASS_COLORS)[myClass]
		local coloredMyClassName = ("|c%s%s|r"):format(classData.colorStr, myClassName)
		JTE_Print(totHeader.."请先启用("..coloredMacroName..")宏之后再尝试设置目标")
		return
	end

    if not UnitInParty("player") then
		JTE_Print(totHeader.."当前不在队伍中"..theSpellLink.."宏("..coloredMacroName..")需要队友为目标")
        return
    end

	local mouseOverGUID = UnitGUID("mouseover")
    if mouseOverGUID then
        if mouseOverGUID == myGUID then
			if not (spellListForAllClasses[myClass] and spellListForAllClasses[myClass].allowSelfTarget) then
				JTE_Print(totHeader..theSpellLink.."宏("..coloredMacroName..")不能设置自己为目标")
				return
			end
        else
			if UnitInRaid("mouseover") or UnitInParty("mouseover") or (spellListForAllClasses[myClass] and spellListForAllClasses[myClass].canTargetMyPet and UnitIsUnit("mouseover", "pet")) then
			-- if UnitInRaid("mouseover") or UnitInParty("mouseover") or true then --测试时用true
				local unitName, unitRealm = UnitName("mouseover")
				local unitClass = select(2, UnitClass("mouseover"))
				return unitName, unitRealm, unitClass
			else
				JTE_Print(totHeader..theSpellLink.."宏("..coloredMacroName..")只能设置队友为目标")
				return
			end
        end
    else
		local targetGUID = UnitGUID("target")
        if targetGUID then
            if targetGUID == myGUID then
				if not (spellListForAllClasses[myClass] and spellListForAllClasses[myClass].allowSelfTarget) then
					JTE_Print(totHeader..theSpellLink.."宏("..coloredMacroName..")不能设置自己为目标")
					return
				end
            else
				if UnitInRaid("target") or UnitInParty("target") or (spellListForAllClasses[myClass] and spellListForAllClasses[myClass].canTargetMyPet and UnitIsUnit("target", "pet")) then
				-- if UnitInRaid("target") or UnitInParty("target") or true then -- 测试时用true
					local unitName, unitRealm = UnitName("target")
					local unitClass = select(2, UnitClass("target"))
					return unitName, unitRealm, unitClass
				else
					JTE_Print(totHeader..theSpellLink.."宏("..coloredMacroName..")只能设置队友为目标")
					return
				end
            end
        end
    end
	local text = isButtonClicked and ("|CFFFF53A2选中队友为目标|R后点击按钮 可以为"..theSpellLink.."宏("..coloredMacroName..")设置目标") or ("|CFFFF53A2鼠标悬浮|R或者|CFFFF53A2选中队友|R后 按快捷键为"..theSpellLink.."宏("..coloredMacroName..")设置目标")
	JTE_Print(totHeader..text)
end

local SetTOTMacroTarget = function(id, isButtonClicked)
	local unitName, unitRealm, unitClass = GetValidUnitName(id, isButtonClicked)

	if not unitName then
		--没有有效的名字，设置失败
        return
	else
		local mySpellData = spellListForAllClasses[myClass]

		local disableMouseOver = SV.mouseOverDisabled[id] or false
		local showtooltipText = showtooltipTextStr:format(theSpellName)
		local thisUnitMacroText = (disableMouseOver and (mySpellData.macroTextOnlyTargetStr or commonMacroTextOnlyTargetStr) or (mySpellData.macroTextWithMouseoverStr or commonMacroTextWithMouseoverStr))
		local thisMacroText = thisUnitMacroText:format(unitName, theSpellName)
		local whisperName = ( unitRealm and unitRealm ~= "" ) and unitName.."-"..unitRealm or unitName
		local thisWhisperMacroStr = whisperMacroStr:format(theSpellName, whisperName)
		
		if SV.oorWhisper then
			--有密语加不上#showtooltip 太长了
			thisMacroText = thisWhisperMacroStr..thisMacroText
		else
			-- 没有密语可以加#showtooltip
			thisMacroText = showtooltipText..thisMacroText
		end

		local macroData = {}
		for k, v in pairs(TOT.DefaultMacroData[id]) do
			macroData[k] = v
		end

		macroData.unitName = unitName
		macroData.unitRealm = unitRealm
		macroData.unitClass = unitClass
		macroData.macroText = string.format(thisMacroText, unitName, theSpellName)

		if InCombatLockdown() then
			UpdateWaitOOC(id, macroData)
			JTE_Print(totHeader.."正在战斗……稍后后更新"..theSpellLink.."目标("..macroData.coloredMacroName..") -> "..classColorName(unitName))
		else
			CreateOrEditMacro(macroData)
		end
		PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
    end
end
JTE.SetToTMacroTarget = SetTOTMacroTarget

local MouseOverToggle = function(macroId)
	if not macroId then
		-- 没有id，全设置
		if SV.mouseOverDisabled[1] then
			for i = 1, MAX_NUM_MACROS do
				SV.mouseOverDisabled[i] = false
			end
			JTE_Print(totHeader.."设置目标之后 鼠标指向优先功能已全部|CFF00FF00开启|R")
		else
			for i = 1, MAX_NUM_MACROS do
				SV.mouseOverDisabled[i] = true
			end
			JTE_Print(totHeader.."设置目标之后 鼠标指向优先功能已全部|CFFFF0000禁用|R")
		end
	else
		local cmdToId = {
			["1"] = 1,
			["a"] = 1,
			["jta"] = 1,
			["2"] = 2,
			["b"] = 2,
			["jtb"] = 2,
			["3"] = 3,
			["x"] = 3,
			["jtx"] = 3,
			["4"] = 4,
			["y"] = 4,
			["jty"] = 4,
		}
		local thisId = cmdToId[macroId] or ""
		if thisId ~= "" then
			if SV.mouseOverDisabled[thisId] then
				SV.mouseOverDisabled[thisId] = false
				JTE_Print(totHeader..theSpellLink.."宏("..TOT.DefaultMacroData[thisId].coloredMacroName..")在设置目标之后 鼠标指向优先功能|CFF00FF00启用|R")
			else
				SV.mouseOverDisabled[thisId] = true
				JTE_Print(totHeader..theSpellLink.."宏("..TOT.DefaultMacroData[thisId].coloredMacroName..")在设置目标之后 鼠标指向优先功能|CFFFF0000禁用|R")
			end
		else
			JTE_Print(totHeader.."无效的"..theSpellLink.."宏 #编号")
			JTE_Print(totHeader.."命令格式: |CFFFFFFFF/jte 嫁祸鼠标指向 宏名称或按钮名或序号|R")
			JTE_Print(totHeader.."例如: |CFFFFFFFF/jte 嫁祸鼠标指向 1|R 开关 |cff94EF00JTA|r 的鼠标指向功能")
			JTE_Print(totHeader.."例如: |CFFFFFFFF/jte 嫁祸鼠标指向 B|R 开关 |cffEF573EJTB|r 的鼠标指向功能")
			JTE_Print(totHeader.."例如: |CFFFFFFFF/jte 嫁祸鼠标指向|R 所有宏 开关 的鼠标指向功能")
			return
		end
	end
	-- 刷新一下各个宏
	if next(SV.macros) then
		for id, macroData in pairs(SV.macros) do
			if macroData and macroData.macroText then
				local unitName = macroData.unitName or ""
				local unitRealm = macroData.unitRealm

				local mySpellData = spellListForAllClasses[myClass]

				local disableMouseOver = SV.mouseOverDisabled[id] or false
				local showtooltipText = showtooltipTextStr:format(theSpellName)
				local thisUnitMacroText = (disableMouseOver and (mySpellData.macroTextOnlyTargetStr or commonMacroTextOnlyTargetStr) or (mySpellData.macroTextWithMouseoverStr or commonMacroTextWithMouseoverStr))
				local thisMacroText = thisUnitMacroText:format(unitName, theSpellName)
				local whisperName = ( unitRealm and unitRealm ~= "" ) and unitName.."-"..unitRealm or unitName
				local thisWhisperMacroStr = whisperMacroStr:format(theSpellName, whisperName)

				if SV.oorWhisper then
					--有密语加不上#showtooltip 太长了
					thisMacroText = thisWhisperMacroStr..thisMacroText
				else
					-- 没有密语可以加#showtooltip
					thisMacroText = showtooltipText..thisMacroText
				end

				macroData.macroText = string.format(thisMacroText, unitName, theSpellName)
				if InCombatLockdown() then
					UpdateWaitOOC(id, macroData)
					JTE_Print(totHeader.."正在战斗……稍后后更新"..theSpellLink.."目标("..macroData.coloredMacroName..") 鼠标指向优先 -> "..(disableMouseOver and "|CFFFF0000禁用|R" or "|CFF00FF00启用|R"))
				else
					CreateOrEditMacro(macroData)
				end
			end
		end
	end
end
JTE.ToTMouseOverToggle = MouseOverToggle

local SetOORWhisperToggle = function()
	if SV.oorWhisper then
		SV.oorWhisper = false
		JTE_Print(totHeader.."超出"..theSpellLink.."技能范围密语功能已|CFFFF0000禁用|R")
	else
		SV.oorWhisper = true
		JTE_Print(totHeader.."超出"..theSpellLink.."技能范围密语功能已|CFF00FF00启用|R")
	end
	-- 刷新一下各个宏
	if next(SV.macros) then
		for id, macroData in pairs(SV.macros) do
			if macroData and macroData.macroText then
				local unitName = macroData.unitName or ""
				local unitRealm = macroData.unitRealm

				local mySpellData = spellListForAllClasses[myClass]

				local disableMouseOver = SV.mouseOverDisabled[id] or false
				local showtooltipText = showtooltipTextStr:format(theSpellName)
				local thisUnitMacroText = (disableMouseOver and (mySpellData.macroTextOnlyTargetStr or commonMacroTextOnlyTargetStr) or (mySpellData.macroTextWithMouseoverStr or commonMacroTextWithMouseoverStr))
				local thisMacroText = thisUnitMacroText:format(unitName, theSpellName)
				local whisperName = ( unitRealm and unitRealm ~= "" ) and unitName.."-"..unitRealm or unitName
				local thisWhisperMacroStr = whisperMacroStr:format(theSpellName, whisperName)

				if SV.oorWhisper then
					--有密语加不上#showtooltip 太长了
					thisMacroText = thisWhisperMacroStr..thisMacroText
				else
					-- 没有密语可以加#showtooltip
					thisMacroText = showtooltipText..thisMacroText
				end
				
				macroData.macroText = string.format(thisMacroText, unitName, theSpellName)
				if InCombatLockdown() then
					UpdateWaitOOC(id, macroData)
					JTE_Print(totHeader.."正在战斗……稍后后更新"..theSpellLink.."目标("..macroData.coloredMacroName..") 密语 -> "..(SV.oorWhisper and "|CFF00FF00启用|R" or "|CFFFF0000禁用|R"))
				else
					CreateOrEditMacro(macroData)
				end
			end
		end
	end
end
JTE.ToTOORWhisperToggle = SetOORWhisperToggle

local EnableMyClass = function()
	local classData = (RAID_CLASS_COLORS)[myClass]
	local coloredMyClassName = ("|c%s%s|r"):format(classData.colorStr, myClassName)

	if myClass == "ROGUE" then
		JTE_Print(totHeader..theSpellLink.." 宏对 >"..coloredMyClassName.."< 职业始终开启无需激活")
		return
	end

	if not spellListForAllClasses[myClass] then
		JTE_Print(totHeader..">"..coloredMyClassName.."< 职业没有可支持的技能")
		return
	end

	PlaySound(SOUNDKIT.IG_PLAYER_INVITE)
	JTE_Print(totHeader.."暗号 >|CFFFF53A2领虎冲不是令狐冲|R< 正确!")


	if not SV.EnableAllClasses then
		SV.EnableAllClasses = true
	else
		SV.EnableAllClasses = false
	end
	RebuildSpellInfo()
	RebuildDefaultMacroText()
	BuildDefaultMacroData()
	InitializeMacros()
	OnPlayerTalentUpdate()
	local text = SV.EnableAllClasses and "恭喜您找到了|CFF00FF00开启|R >"..coloredMyClassName.."< 职业的"..theSpellLink.."技能的方法!" or "再次收到暗号将|CFFFF0000关闭|R >"..coloredMyClassName.."< 职业的"..theSpellLink.."技能 设置功能!"
	JTE_Print(totHeader..text)
end
JTE.ToTEnableMyClass = EnableMyClass

local ShowCurrentStatus = function()
	-- 各个宏鼠标指向优先开启情况
	JTE_Print(totHeader.."各个"..theSpellLink.."宏鼠标指向优先功能情况:")
	for i = 1, SV.enableNumMacros do
		if SV.mouseOverDisabled[i] then
			JTE_Print(totHeader.." -> "..theSpellLink.."宏("..TOT.DefaultMacroData[i].coloredMacroName..") - |CFFFF0000禁用|R")
		else
			JTE_Print(totHeader.." -> "..theSpellLink.."宏("..TOT.DefaultMacroData[i].coloredMacroName..") - |CFF00FF00启用|R")
		end
	end
	-- 密语开启情况
	if SV.oorWhisper then
		JTE_Print(totHeader.."超出"..theSpellLink.."技能范围密语功能已|CFF00FF00启用|R")
	else
		JTE_Print(totHeader.."超出"..theSpellLink.."技能范围密语功能已|CFFFF0000禁用|R")
	end
	-- 开启宏个数
	if SV.enableNumMacros > 2 then
		JTE_Print(totHeader.."当前"..theSpellLink.."宏数量为 |CFFFF53A2"..SV.enableNumMacros.."|R 个")
	end
end
JTE.ToTShowCurrentStatus = ShowCurrentStatus

local CallHelp = function()
	JTE_Print(totHeader.."===|CFF1785D1JTE|R(|CFFFF53A2"..JTE.version.."|R)==|CFFFFF569JT嫁祸WA|R(|CFFFF53A2"..TOT.version.."|R)===")
	JTE_Print(totHeader.."输入 |CFFFFFFFF/jte 嫁祸鼠标指向|R 可以 |CFF00FF00开启|R/|CFFFF0000关闭|R |CFFFF53A2所有宏|R的鼠标指向功能")
	JTE_Print(totHeader.."输入 |CFFFFFFFF/jte 嫁祸鼠标指向 宏名称|R 可以单独 |CFF00FF00开启|R/|CFFFF0000关闭|R |CFFFFF569指定宏|R的鼠标指向功能")
	JTE_Print(totHeader.."输入 |CFFFFFFFF/jte 嫁祸超出距离密语|R 可以 |CFF00FF00开启|R/|CFFFF0000关闭|R |CFFFF53A2所有宏|R的超出距离密语功能")
	JTE_Print(totHeader.."输入 |CFFFFFFFF/jte 嫁祸状态|R 可以|CFFFFF569查询当前的设置情况|R")
	JTE_Print(totHeader.."其他功能请咨询其他玩家 祝游戏愉快 (|CFFFFFFFFJettie@SMTH|R - 字)")
end
JTE.ToTCallHelp = CallHelp

local OnPlayerRegenEnabled = function()
	if next(TOT.waitOOC) then
		for id, macroData in pairs(TOT.waitOOC) do
			CreateOrEditMacro(macroData, macroData.silent)
			TOT.waitOOC[id] = nil
		end
		if not next(TOT.waitOOC) then
			TOTFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
	end
end

TOT.alerted = {}
local OnGroupRosterUpdate = function()
	if IsToTEnabledForMe() then
		if IsInGroup() then
			meInGroup = true
			
			local freshIds = {}
			for i = 1, SV.enableNumMacros do
				freshIds[i] = true
			end

			for id, macroData in pairs(SV.macros) do
				if macroData then
					local WA_Name = macroData.unitName or ""
					if not (macroData.unitName and UnitExists(macroData.unitName) and (UnitInRaid(macroData.unitName) or UnitInParty(macroData.unitName) or (spellListForAllClasses[myClass] and spellListForAllClasses[myClass].canTargetMyPet and UnitIsUnit(macroData.unitName, "pet")))) then
						if not TOT.alerted[id] then
							local coloredUnitName = macroData.unitName and (macroData.unitClass and colorNameByClass(macroData.unitName, macroData.unitClass) or macroData.unitName) or macroData.unitName
							JTE_Print(totHeader..theSpellLink.."宏("..macroData.coloredMacroName..")的目标 > "..coloredUnitName.." < 不在 请及时更新目标")
							TOT.alerted[id] = true
							WeakAuras.ScanEvents("JT_TOT_UPDATE_TARGET", id, theSpellShortName, WA_Name, true)
						end
					elseif TOT.alerted[id] then
						-- 又在了就恢复
						WeakAuras.ScanEvents("JT_TOT_UPDATE_TARGET", id, theSpellShortName, WA_Name)
						TOT.alerted[id] = nil
					else
						TOT.alerted[id] = nil
					end
					if id <= SV.enableNumMacros and skillAviable then
						-- JTE_Print("has SV Set button"..id.." to show")
						WeakAuras.ScanEvents("JT_TOT_BUTTON_SHOW", id)
					else
						-- JTE_Print("has SV Set button"..id.." to hide")
						WeakAuras.ScanEvents("JT_TOT_BUTTON_HIDE", id)
					end
					freshIds[id] = nil
				end
			end
			if next(freshIds) then
				for id, _ in pairs(freshIds) do
					-- 需要刷新这些没有设置的按钮
					if id <= SV.enableNumMacros and skillAviable then
						-- JTE_Print("Set button"..id.." to show")
						WeakAuras.ScanEvents("JT_TOT_BUTTON_SHOW", id)
					else
						-- JTE_Print("Set button"..id.." to hide")
						WeakAuras.ScanEvents("JT_TOT_BUTTON_HIDE", id)
					end
					freshIds[id] = nil
				end
			end
		else
			InitializeMacros()
		end
	end
end

function TOTFrameEvents:PLAYER_REGEN_ENABLED()
	OnPlayerRegenEnabled()
end

function TOTFrameEvents:GROUP_ROSTER_UPDATE()
	OnGroupRosterUpdate()
end

function TOTFrameEvents:PLAYER_TALENT_UPDATE()
	-- SV 读取结束后才触发 登录的时候 天赋比PLAYER_ENTERING_WORLD先触发
	if SV then
		OnPlayerTalentUpdate()
		OnGroupRosterUpdate() -- 触发一次团队变化
	end
end

function TOTFrameEvents:PLAYER_ENTERING_WORLD(...)
	local isInitialLogin, isReloadingUi = ...
	LoadSavedVariables()
	RebuildSpellInfo()
	RebuildDefaultMacroText()
	BuildDefaultMacroData()
	
	if IsToTEnabledForMe() then
		-- 需要delay一下，否则会认为自己不在队伍导致无法读取SV里的设置，导致一直重置所有宏
		-- 测试是delay 0 也能正常显示，但保险起见还是加上0.5
		local delayTime = isInitialLogin and 0.5 or 0
		C_Timer.After(delayTime, function()
			InitializeMacros()
			JTE_Print(totHeader.."使用|CFF1785D1JTE|R自动生成的宏(|cff94EF00JTA|r/|cffEF573EJTB|r"..(SV.enableNumMacros > 2 and "/|cff28ABE0JTX|r" or "")..(SV.enableNumMacros > 3 and "/|cffF4D81EJTY|r" or "")..")来释放"..theSpellLink.."技能")
			OnPlayerTalentUpdate()
		end)
	else
		if not spellListForAllClasses[myClass] then
			JTE_Print(totHeader.."当前职业 >"..colorNameByClass(myClassName, myClass).."< 没有类嫁祸的技能")
		elseif myClass ~= "ROGUE" and not (SV and SV.EnableAllClasses) then
			JTE_Print(totHeader.."当前职业 >"..colorNameByClass(myClassName, myClass).."< 可开启技能宏: "..GetSpellLinkWithIcon(spellListForAllClasses[myClass].spellId))
		end
		for id = 1, MAX_NUM_MACROS do
			WeakAuras.ScanEvents("JT_TOT_BUTTON_HIDE", id)
		end
	end
	TOTFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

TOTFrame:SetScript("OnEvent", function(self, event, ...)
	TOTFrameEvents[event](self, ...); -- call one of the functions above
end);

for k, v in pairs(TOTFrameEvents) do
	TOTFrame:RegisterEvent(k); -- Register all TOTFrameEvents for which handlers have been defined
end

-- 设置成功后需要通知WA刷新显示，也要靠WA做密语的

local JTETOTSlashCommandHandler = function(msg)
	InitializeMacros()
end

SLASH_JTETOT1 = "/jtet";
SlashCmdList["JTETOT"] = function(msg)
	JTETOTSlashCommandHandler(msg)
end


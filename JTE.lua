local _G = _G or getfenv(0)
local addonName, addonTable = ...

JTE = addonTable
JTE.addonName = addonName
JTE.version = C_AddOns.GetAddOnMetadata(addonName, "Version")

JTE.MissingDependency = {}
JTE.Spam = {}
JTE.IsAddOnLoaded = {}

local JTE_IsAddOnLoaded = function()
	local addonList = {
		"ElvUI",
		"tdInspect",
		"WeakAuras",
		"MRT",
	}
	for i = 1, #addonList do
		local loaded = IsAddOnLoaded(addonList[i])
		JTE.IsAddOnLoaded[addonList[i]] = loaded
	end
end

--装备自动换回的数据
JTE.previousEquipmentId = {}
JTE.waitToSwitchBack = {}

JTE.MyName = UnitName("player")
JTE.MyGUID = UnitGUID("player")

local iconStr = function(iconId)
	if iconId and type(iconId) == "number" then
		return "|T"..iconId..":12:12:0:0:64:64:4:60:4:60|t"
	else
		return ""
	end
end
JTE.iconStr = iconStr

--Bindings文本
BINDING_CATEGORY_JTE_TOOL = "|CFF1785D1JTE|R - JT的小工具合集 "..iconStr(135451)

BINDING_CATEGORY_JTE_GRAPHICSQUALITY = "|CFF1785D1JTE|R - 画质快速切换 "..iconStr(135451)

BINDING_HEADER_JTE_GRAPHICSQUALITY = "JTE 画质快速切换"
BINDING_NAME_JTE_GRAPHICS_QUALITY_1 = "切换画质1"
BINDING_NAME_JTE_GRAPHICS_QUALITY_2 = "切换画质2"
BINDING_NAME_JTE_GRAPHICS_QUALITY_3 = "切换画质3"
BINDING_NAME_JTE_GRAPHICS_QUALITY_4 = "切换画质4"
BINDING_NAME_JTE_GRAPHICS_QUALITY_5 = "切换画质5"
BINDING_NAME_JTE_GRAPHICS_QUALITY_6 = "切换画质6"
BINDING_NAME_JTE_GRAPHICS_QUALITY_7 = "切换画质7"
BINDING_NAME_JTE_GRAPHICS_QUALITY_8 = "切换画质8"
BINDING_NAME_JTE_GRAPHICS_QUALITY_9 = "切换画质9"
BINDING_NAME_JTE_GRAPHICS_QUALITY_10 = "切换画质10"

BINDING_HEADER_JTE_SYSTEM = "系统工具"
BINDING_NAME_JTE_SWITCH_MONITOR = iconStr(136034).."主副显示器切换"
BINDING_NAME_JTE_RESTART_SOUND = iconStr(134228).."修复耳机音箱切换声音"

BINDING_HEADER_JTE_SETTINGS = "其他设置"
BINDING_NAME_JTE_MACRO_FRAME_TOGGLE = iconStr(132181).."宏界面开关"
BINDING_NAME_JTE_FRIENDLY_PLAYER_NAME_TOGGLE = iconStr(135934).."友方玩家姓名开关"

BINDING_HEADER_JTE_INGAME = "游戏设置"
BINDING_NAME_JTE_SUMMON_TRAVELERS_TUNDRA_MAMMOTH = iconStr(236240).."召唤修理大象"
BINDING_NAME_JTE_SUMMON_FAVORITE_MOUNT = iconStr(134010).."召唤随机偏好坐骑"
BINDING_NAME_JTE_SWAP_TRINKET = iconStr(133434).."饰品对换重置ICD"
BINDING_NAME_JTE_INSPECT = iconStr(132311).."鼠标悬浮查看天赋"
BINDING_NAME_JTE_INITIATE_TRADE = iconStr(133784).."向目标发起交易"
BINDING_NAME_JTE_LEAVE_PARTY = iconStr(132328).."退出队伍"
BINDING_NAME_JTE_SWITCH_COMBAT_LOG = iconStr(133734).."战斗记录开关"
BINDING_NAME_JTE_MRT_FIGHT_LOG_TOGGLE = iconStr(133739).."MRT-显示战斗分析"
BINDING_NAME_JTE_TEXTURE_ATLAS_VIEWER_TOGGLE = iconStr(133739).."TAV-浏览材质界面"

BINDING_HEADER_JTE_CLASS_KEYS = "联动设置"
BINDING_NAME_JTE_ROGUE_TOT_SET_TARGET_A = iconStr(236283).."设置嫁祸目标|CFF94EF00JTA"
BINDING_NAME_JTE_ROGUE_TOT_SET_TARGET_B = iconStr(236283).."设置嫁祸目标|CFFEF573EJTB"
BINDING_NAME_JTE_ROGUE_TOT_SET_TARGET_X = iconStr(236283).."设置嫁祸目标|CFF28ABE0JTX"
BINDING_NAME_JTE_ROGUE_TOT_SET_TARGET_Y = iconStr(236283).."设置嫁祸目标|CFFF4D81EJTY"

local showCommandArgs = false
local checkresponse = nil

--命令登记
SLASH_JTE1 = "/jte";
SlashCmdList["JTE"] = function(msg)
	JTE_SlashCommandHandler(msg);
end

local CallHelp = function()
	JTE_Print("========|CFF1785D1JTE|R玩具包(|CFFFF53A2"..JTE.version.."|R)========")
	JTE_Print("是|RJettie@SMTH|CFF8FFFA2为了自己方便做的小工具")
	JTE_Print("在|R ESC-选项-快捷键 |CFF8FFFA2中可以看到 |CFF1785D1JTE|R 相关的一些快捷键优化")
	JTE_Print("输入 |CFFFFFFFF/jte 宏界面拉长|R 可以 |CFF00FF00开启|R/|CFFFF0000关闭|R 宏界面拉长功能")
	JTE_Print("输入 |CFFFFFFFF/jte 天赋界面拉长|R 可以 |CFF00FF00开启|R/|CFFFF0000关闭|R 天赋界面拉长功能")
	JTE_Print("输入 |CFFFFFFFF/jte 嫁祸|R 可以获取JT嫁祸WA的相关帮助信息")
end

--玩家名字染色
local ClassColorName = function(unitName)
	if unitName and UnitExists(unitName) then
		local name = UnitName(unitName)
		local _, class = UnitClass(unitName)
		if not class then
			return name or unitName
		else
			local classData = (RAID_CLASS_COLORS)[class]
			local coloredName = ("|c%s%s|r"):format(classData.colorStr, name)
			return coloredName
		end
	else
		return unitName
	end
end
JTE.ClassColorName = ClassColorName

--重写职业名字染色，WA_ClassColorName会返回空置
local ColorNameByClass = function(unitName, classIdOrStr)
    if not unitName then return "" end
    if not classIdOrStr then return unitName end

	local classStr = classIdOrStr
	if type(classIdOrStr) == "number" then
        classStr = select(2,GetClassInfo(classIdOrStr))
	end

    if classStr then
        local classData = (RAID_CLASS_COLORS)[classStr]
        local coloredName = ("|c%s%s|r"):format(classData.colorStr, unitName)
        return coloredName
    elseif UnitExists(unitName) then
        local name = UnitName(unitName)
        local _, class = UnitClass(unitName)
        if not class then
            return name
        else
            local classData = (RAID_CLASS_COLORS)[class]
            local coloredName = ("|c%s%s|r"):format(classData.colorStr, name)
            return coloredName
        end
    else
        return unitName
    end
end
JTE.ColorNameByClass = ColorNameByClass

local JTEFrame, JTEFrameEvents = CreateFrame("Frame"), {};

local initializeSavedVariablesForJTE = function()
	if type(JTEDB) ~= "table" then JTEDB = {} end

	-- Checking features
	if type(JTEDB.ResponseMax) ~= "number" then JTEDB.ResponseMax = 200 end
	if type(JTEDB.showCommandArgs) ~="boolean" then JTEDB.showCommandArgs = false end
	if type(JTEDB.CheckResponse) ~= "table" then JTEDB.CheckResponse = {} end
	while #JTEDB.CheckResponse > JTEDB.ResponseMax do
		table.remove(JTEDB.CheckResponse, 1)
	end
end

function JTEFrameEvents:ADDON_LOADED(...)
	local addOnName, containsBindings = ...
	if addOnName == JTE.addonName then
		DEFAULT_CHAT_FRAME:AddMessage("JTE是Jettie为了自己方便做的小工具")
		-- JTE 在ADDON_LOADED事件中初始化变量 其他子功能在PLAYER_ENTERING_WORLD事件中初始化
		if initializeSavedVariablesForJTE then
			initializeSavedVariablesForJTE()
		end
		-- 装备管理器
		if GetCVar("equipmentManager") == "0" then
			SetCVar("equipmentManager", 1)
		end

		-- 插件运行监测 -- /dump C_AddOnProfiler.IsEnabled()
		local addonProfilerEnabled = C_CVar.GetCVar("addonProfilerEnabled")
		if not addonProfilerEnabled then
			C_CVar.RegisterCVar("addonProfilerEnabled", "1")
			C_CVar.SetCVar("addonProfilerEnabled", "0")
		elseif addonProfilerEnabled == "1" then 
			C_CVar.SetCVar("addonProfilerEnabled", "0")
		end
		
		checkresponse = JTEDB.CheckResponse
		showCommandArgs = JTEDB.showCommandArgs
	end
	-- JTE_ReApplySkin()
end

local showCommandArgsToggle = function()
	showCommandArgs = not showCommandArgs
	JTEDB.showCommandArgs = showCommandArgs
	JTE_Print("|CFF1785D1JTE|R 显示命令参数: "..(showCommandArgs and "|CFF00FF00开启|R" or "|CFFFF0000关闭|R"))
end

function JTEFrameEvents:CHAT_MSG_ADDON(...)
	local prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID = ...
	if prefix == "JTECHECKRESPONSE" then
		local sourceName = JTE_SplitString(sender,"-") and JTE_SplitString(sender,"-") or sender
		local msg = text
		local channel = channel
		local t = "|CFFFF0000In: |R"..channel.." ["..ClassColorName(sourceName).."] |CFF40FF40Res: |R"..msg
		JTE_Print(t)

		--最多100条
		if checkresponse and #checkresponse >= JTEDB.ResponseMax then
			table.remove(checkresponse, 1)
		end
		checkresponse[#checkresponse + 1] = {
			name = sourceName,
			msg = msg
		}
	end
end

function JTEFrameEvents:PLAYER_ENTERING_WORLD(...)
	JTE_Print("是|CFFFFFFFFJettie@SMTH|R为了自己方便做的小工具: |CFFFFFFFF/JTE|R")
	-- initVariables()
	JTE_IsAddOnLoaded()
	JTEFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

JTEFrame:SetScript("OnEvent", function(self, event, ...)
	JTEFrameEvents[event](self, ...); -- call one of the functions above
end);

for k, v in pairs(JTEFrameEvents) do
	JTEFrame:RegisterEvent(k); -- Register all JTEFrameEvents for which handlers have been defined
end

--命令判断
function JTE_SlashCommandHandler(msg)
	if( msg ) then
		local command = string.lower(msg);
		--先用空格拆分指令
		PlaySound(SOUNDKIT.TUTORIAL_POPUP)
		if JTE_SplitString(command," ") then
			--有前缀指令
			local cmd, pre1, pre2, pre3 = JTE_CmdSplit(command)
			if showCommandArgs then
				JTE_Print("|CFFFF0000Arg1: |R"..tostring(pre1).." |CFFFF0000Arg2: |R"..(pre2 or ("|CFF7D7D7D"..tostring(pre2).."|R")).." |CFFFF0000Arg3: |R"..(pre3 or ("|CFF7D7D7D"..tostring(pre3).."|R")).." |CFFFF0000Cmd: |R"..command)
			end
			if pre1 == "s" or pre1 == "g" or pre1 == "r" or pre1 == "p" then
				JTE_SendStealthMessage(cmd, pre1, pre2, pre3)
			elseif( pre1 == "嫁祸鼠标指向" or pre1 == "嫁祸鼠标悬浮" or pre1 == "嫁祸鼠标" ) and not pre2 and cmd and cmd ~= "" then
				JTE.ToTMouseOverToggle(cmd)
			elseif pre1 == "c" then
				JTE_StealthCheck(cmd, pre1, pre2, pre3)
			elseif pre1 == "d" then
				JTE_ForToggleDebugShit(cmd)
			elseif pre1 == "e" then
				JTE_FakeWeakAurasEvent(cmd)
			elseif pre1 == "link" or "itemlink" then
				JTE.ItemLink(cmd)
			elseif pre1 == "listmax" then
				JTE_ListResponseMax(cmd)
			elseif pre1 == "ins" or pre1 == "inspect" then
				JTE_Inspect(cmd)
			elseif pre1 == "irc" or pre1 == "itemrangecheck" then
				JTE_ItemRangeCheck((pre2 or cmd), (pre2 and cmd))
			elseif pre1 == "gq" or pre1 == "graphicsquality" then
				JTE_SetGraphicsQuality(cmd)
			else
				JTE_Print("Wrong cmd")
			end
		else
			--无前缀指令
			if( command == "log" or command == "combatlog") then
				JTE_CombatLog()
			elseif( command == "showcommand" or command == "showcommandargs" ) then
				showCommandArgsToggle()
			elseif( command == "关注抖音领虎冲" ) then
				JTE.ToTHandleCode(1)
			elseif( command == "关注b站领虎冲" ) then
				JTE.ToTHandleCode(2)
			elseif( command == "领虎冲不是令狐冲" ) then
				JTE.ToTEnableMyClass()
			elseif( command == "嫁祸" ) then
				JTE.ToTCallHelp()
			elseif( command == "嫁祸状态" ) then
				JTE.ToTShowCurrentStatus()
			elseif( command == "嫁祸鼠标指向" or command == "嫁祸鼠标悬浮" or command == "嫁祸鼠标" ) then
				JTE.ToTMouseOverToggle()
			elseif( command == "嫁祸距离" or command == "嫁祸范围" or command == "嫁祸超距离" or command == "嫁祸超范围" or command == "嫁祸超出" or command == "嫁祸超出范围" or command == "嫁祸超出距离" or command == "嫁祸距离密语" or command == "嫁祸范围密语" or command == "嫁祸超出范围密语" or command == "嫁祸超出距离密语" ) then
				JTE.ToTOORWhisperToggle()
			elseif command == "d" then
				JTE_ForToggleDebugShitCommandList()
			elseif command == "e" then
				JTE_FakeWeakAurasEventCommandList()
			elseif command == "ins" or command == "inspect" then
				JTE_Inspect()
			elseif command == "listmax" then
				JTE_ListResponseMax()
			elseif command == "iorc" then
				JTE_ItemOutRangeCheck()
			elseif command == "listirs" then
				JTE_ListItemRangeSaved()
			elseif( command == "listr" or command == "listresponse" ) then
				JTE_ListResponse()
			elseif( command == "listreset" or command == "listreset" ) then
				JTE_ListResponseReset()
			elseif( command == "largemacro" or command == "bigmacro" or command == "宏界面拉长" or command == "拉长宏界面" ) then
				JTE.ModifyMacroToggle()
			elseif( command == "largetalent" or command == "bigtalent" or command == "天赋界面拉长" or command == "拉长天赋界面" or command == "拉长天赋" ) then
				JTE.ModifyTalentToggle()
			elseif( command == "rs" or command == "restartsound" ) then
				JTE_RestartSound()
			elseif( command == "t" ) then
				JTE.ToTManuallyInitializeMacros()
			elseif( command == "test" ) then
				DEFAULT_CHAT_FRAME:AddMessage('JTE testing')
				-- |T iconpath/iconid : width : height : posX : posY : scaleX : scaleY :4:60:4:60 --后4别动，边框和资源管理移位用的
			else
				CallHelp();
			end
		end
	end
end

--StealthMSG
local sendChannelList = {
	["s"] = "SAY",
	["g"] = "GUILD",
	["r"] = "RAID",
	["p"] = "PARTY"
}
local msgChanncelList = {
	["s"] = "JTESAY",
	["g"] = "JTEGUILD",
	["r"] = "JTERAID",
	["p"] = "JTEPARTY",
	["t"] = "JTETTS"
}

function JTE_SendStealthMessage(command,pre1,pre2,pre3)
	--pre1:传输频道 pre2:发言频道 pre3:谁
	if not command or not sendChannelList[pre1] then return end
	if pre1 == "r" and not IsInRaid() then
		pre1 = "p"
	end
	if command and sendChannelList[pre1] and msgChanncelList[pre2] then
		local name = pre3 or "all"
		local nameAndMSG = name..":"..command
		C_ChatInfo.SendAddonMessage(msgChanncelList[pre2], nameAndMSG, sendChannelList[pre1],nil)
		local convertJTEChannel = {
			["JTESAY"] = "|RSAY",
			["JTEGUILD"] = "|CFF40FF40GUILD",
			["JTERAID"] = "|CFFFF7F00RAID",
			["JTEPARTY"] = "|CFFAAAAFFPARTY",
			["JTETTS"] = "|CFF1785D1TTS"
		}
		JTE_Print("who: "..(name == "all" and "|CFFFFFFFFAll|R" or ClassColorName(name) ).." will say: |CFFFF53A2"..command.."|R in "..convertJTEChannel[msgChanncelList[pre2]])
	end
	
	return
end

--JTE Checking
function JTE_StealthCheck(command, pre1, pre2, pre3)
	if not command then return end
	if pre1 == "c" then
		local checkCmd = {
			["yogg"] = "yogg:yogg",
			["dalianle"] = "dalianle",
			["dll"] = "dalianle",
			["soundpack"] = "soundpack",
			["sp"] = "soundpack",
			["csr"] = "csr",
			["trinketsound"] = "trinketsound",
			["ts"] = "trinketsound",
		}
		
		if checkCmd[command] then
			local channel = sendChannelList[pre2] and sendChannelList[pre2] or ( IsInGroup() and (IsInRaid() and "RAID" or "PARTY" ) or "GUILD" )
			C_ChatInfo.SendAddonMessage("JTECHECK", checkCmd[command], channel, nil)
			JTE_Print("Checking: |CFFFF53A2"..checkCmd[command])
		end

	end
end


function JTE_Test(arg1)
	--判断职业，大写，判断图标内容，播放声音
	if not JTE.addonName then
		JTE_Print("name is nil")
	else
		JTE_Print("name is "..JTE.addonName)
	end
end

--字符串拆分处理
function JTE_SplitString(str, separator)
	local index = string.find(str, separator)
	if index then
		local part1 = string.sub(str, 1, index - 1)
		local part2 = string.sub(str, index + 1)
		return part1, part2
	else
		return
	end
end

--命令参数拆分
function JTE_CmdSplit(str) --最多3参数
	local msg, pre1, pre2, pre3
	if JTE_SplitString(str," ") then
		pre1, msg = JTE_SplitString(str," ")
		if JTE_SplitString(msg," ") then
			pre2, msg = JTE_SplitString(msg," ")

			if JTE_SplitString(msg," ") then
				pre3, msg = JTE_SplitString(msg," ")
				return msg, pre1, pre2, pre3
			else
				return msg, pre1, pre2
			end
		else
			return msg, pre1
		end
	else
		return false
	end
end

--FakeEvent指令部分
function JTE_FakeEventScan(event, ...)
	if event and event ~= "" then
		local fakeEvent = string.upper(event)
		WeakAuras.ScanEvents(fakeEvent, ...)
		JTE_Print("Fake '|CFFC29080"..fakeEvent.."|R' fired.")
	else
		JTE_Print("Fake event can NOT be \"\" or nil")
	end
end

local eventCommand = {
	["voteslapper"] = {
		func = function()
			JTE_FakeEventScan("JT_VOTESLAPPER", math.random(100))
		end,
		desc = "|CFF1785D1(WA)|R |CFFFFFFFF[|RJT找背WA|CFFFFFFFF]|R 打脸王 触发投票3秒后发言",
	},
	["vs"] = {
		func = function()
			JTE_FakeEventScan("JT_VOTESLAPPER", math.random(100))
		end,
		desc = "|CFF1785D1(WA)|R |CFFFFFFFF[|RJT找背WA|CFFFFFFFF]|R 打脸王 触发投票3秒后发言",
	},
	["ks"] = {
		func = function()
			JTE_FakeEventScan("JT_KILLINGSPREE_STARTCHECK",1)
		end,
		desc = "|CFF1785D1(WA)|R |CFFFFFFFF[|RJT杀戮WA|CFFFFFFFF]|R 开始检测杀戮目标数量和距离",
	},
	["kss"] = {
		func = function()
			JTE_FakeEventScan("JT_KILLINGSPREE_STOPCHECK")
		end,
		desc = "|CFF1785D1(WA)|R |CFFFFFFFF[|RJT杀戮WA|CFFFFFFFF]|R 停止检测杀戮目标数量和距离",
	},
	["v"] = {
		func = function()
			JTE_FakeEventScan("JT_TEST_MSG", "JT说了一句什么话，胡扯了半天？", "冰吼")
		end,
		desc = "|CFF1785D1(WA)|R |CFFFFFFFF[|RJT消失躲一切WA|CFFFFFFFF]|R 发言触发器测试",
	},
}

function JTE_FakeWeakAurasEvent(command)
	if eventCommand[command] then
		eventCommand[command].func()
	else
		JTE_FakeEventScan(strsplit(",", command))
	end
end

function JTE_FakeWeakAurasEventCommandList()
	JTE_Print("目前可用的|CFFFFFFFFFake Event|R开关如下: ")
	for k, v in pairs(eventCommand) do
		JTE_Print("Cmd : |CFFFF53A2"..k.."|R - "..(v.desc or "没有说明"))
	end
end

--JT系列的Debug开关
local debugCommand = {
	["slapper"] = {
		func = 	function()
			JTE_FakeEventScan("JT_D_SLAPPER")
		end,
		desc = "|CFF1785D1(WA)|R |CFFFFFFFF[|RJT找背WA|CFFFFFFFF]|R 打脸王 Debug 开关(打开后含3条测试数据)",
	},
	["slap"] = {
		func = 	function()
			JTE_FakeEventScan("JT_D_SLAPPER")
		end,
		desc = "|CFF1785D1(WA)|R |CFFFFFFFF[|RJT找背WA|CFFFFFFFF]|R 打脸王 Debug 开关(打开后含3条测试数据)",
	},
	["dalian"] = {
		func = 	function()
			JTE_FakeEventScan("JT_D_DALIAN")
		end,
		desc = "|CFF1785D1(WA)|R |CFFFFFFFF[|RJT找背WA|CFFFFFFFF]|R 找背WA Debug 开关",
	},
	["ks"] = {
		func = 	function()
			JTE_FakeEventScan("JT_D_KILLINGSPREE")
		end,
		desc = "|CFF1785D1(WA)|R |CFFFFFFFF[|RJT找背WA|CFFFFFFFF]|R 杀戮WA Debug 开关",
	},
}

function JTE_ForToggleDebugShit(command)

	if debugCommand[command] then
		debugCommand[command].func()
	else
		JTE_Print("Wrong ommand : |CFFFFFFFF"..(command or "nil").."|R - Use |CFFFF53A2/jte d|R for command list")
	end
end

function JTE_ForToggleDebugShitCommandList()
	JTE_Print("目前可用的|CFFFFFFFFDebug|R开关如下: ")
	for k, v in pairs(debugCommand) do
		JTE_Print("Cmd : |CFFFF53A2"..k.."|R - "..(v.desc or "没有说明"))
	end
end

--JTE反馈相关
function JTE_ListResponseMax(max)
	max = tonumber(max)
	if not max then
		JTE_Print("|CFF1785D1Response maximum is : |CFFFFFFFF"..JTEDB.ResponseMax.."|R")
	else
		if max < 1 then
			JTE_Print("The maximum response cap must be higher than 10")
			JTEDB.ResponseMax = 10
			JTE_ListResponseMax()
		elseif max > 999 then
			JTE_Print("The maximum response cap must be less than 999")
			JTEDB.ResponseMax = 999
			JTE_ListResponseMax()
		else
			JTEDB.ResponseMax = max
			JTE_ListResponseMax()
		end
	end
end

function JTE_ListResponse()
	if checkresponse and #checkresponse > 0 then
		JTE_Print("==== "..date("%H:%M:%S %Y").." ====")
		for i = 1, #checkresponse do
			local l = "|CFFFF0000History: |R"..i.." ["..ClassColorName(checkresponse[i].name).."] |CFF40FF40Res: |R"..checkresponse[i].msg
			print(l)
		end
		JTE_Print("==== =======Total: "..#checkresponse.."======= ====")
	else
		JTE_Print("No response message now.")
	end
end

function JTE_ListResponseReset()
	checkresponse = {}
	JTE_Print("|CFF1785D1Response is reset. |CFFFFFFFF"..#checkresponse.."/"..JTEDB.ResponseMax.."|R")
end

--双显示器用户，快速互相切换
function JTE_SwitchMonitor()
	--only switch monitor 1 / 2
	--/run local m=GetCVar("gxMonitor");if m==1 then m=2 else m=1 end;SetCVar("gxWindow",1);SetCVar("gxMaximize",1);SetCVar("gxMonitor",m);RestartGx()
	local monitor = GetCVar("gxMonitor")
	if monitor == "1" then monitor = "2" else monitor = "1" end
	SetCVar("gxWindow",1)
	SetCVar("gxMaximize",1)
	SetCVar("gxMonitor",monitor)
	RestartGx()
end

--切换声音设备，解决windows换设备而游戏没换的问题/run GetCVar(“Sound_OutputDriverIndex”)
function JTE_RestartSound()
	Sound_GameSystem_RestartSoundSystem()
end

--宏界面开关
function JTE_ToggleMacroFrame()
	if MacroFrame and MacroFrame:IsShown() and MacroExitButton and MacroExitButton:IsShown() then
		MacroExitButton:Click()
	else
		ShowMacroFrame()
	end
end

--显示/隐藏友方玩家姓名（隐藏后主城防掉帧）
function JTE_ToggleFriendlyPlayerName()
	if GetCVar("UnitNameFriendlyPlayerName") == "1" then
		SetCVar("UnitNameFriendlyPlayerName",0)
	else
		SetCVar("UnitNameFriendlyPlayerName",1)
	end
end

-- MRT 战斗分析开关
function JTE_MRTFightLogToggle()
	if JTE.IsAddOnLoaded["MRT"] then
		if GMRTBWInterfaceFrame and GMRTBWInterfaceFrame:IsShown() then
			GMRTBWInterfaceFrame:Hide()
		else
			GMRT.F.FightLog_Open()
		end
	else
		JTE_Print("战斗分析开关快捷键需要安装MRT插件")
	end
end

-- TextureAtlasViewer开关
function JTE_ToggleTextureAtlasViewer()
	if IsAddOnLoaded("TextureAtlasViewer") then
		TAV_CoreFrame:SetShown(not TAV_CoreFrame:IsShown())
	else
		JTE_Print("|CFF8FFFA2没有检测到TextureAtlasViewer插件")
	end
end

--鼠标悬浮查看天赋
function JTE_Inspect(inspectName, inspectRealm)
	local unit = inspectName
	if UnitIsPlayer('mouseover') and UnitIsConnected('mouseover') and UnitFactionGroup('mouseover') == UnitFactionGroup('player') then
		unit = 'mouseover'
	elseif UnitIsPlayer('target') and UnitIsConnected('target') and UnitFactionGroup('target') == UnitFactionGroup('player') then
		unit = 'target'
	end

	-- TalentEmu部分暂时停用了
	-- if not unit then return end

	-- if not __ala_meta__ or not __ala_meta__.emu then

	-- 	if not JTE.MissingDependency["__ala_meta__"] then
	-- 		JTE_Print("鼠标悬浮查看天赋功能建议搭配|R TalentEmu |CFF8FFFA2插件使用更方便")
	-- 		JTE.MissingDependency["__ala_meta__"] = true
	-- 	end
		InspectUnit(unit)
	-- 	return
	-- else
	-- 	local function tryInspect(unit)
	-- 		local name, realm = UnitName(unit);
	-- 		if name then
	-- 		   __ala_meta__.emu.MT.SendQueryRequest(name, realm, true, true, true)
	-- 		end
	-- 	end
	-- 	if inspectName then
	-- 		__ala_meta__.emu.MT.SendQueryRequest(inspectName, inspectRealm, true, true, true)
	-- 	else
	-- 		tryInspect(unit)
	-- 		return
	-- 	end
	-- end
end

--for addonmsg
local regPrefix = function()
    local prefixList = {
        ["JTESAY"] = true,
        ["JTEGUILD"] = true,
        ["JTERAID"] = true,
        ["JTEPARTY"] = true,
        ["JTETTS"] = true,
        ["JTECHECK"] = true,
        ["JTECHECKRESPONSE"] = true,
    }
    for k,v in pairs(prefixList) do
        local successfulRequest = C_ChatInfo.RegisterAddonMessagePrefix(k)
    end
end
regPrefix()

--开启关闭战斗记录
function JTE_CombatLog()
	if LoggingCombat() then
		LoggingCombat(false)
		JTE_Print("|cFFFFF569战斗记录 |R-> |cFFFF5555关闭|R")
	else
		LoggingCombat(true)
		JTE_Print("|cFFFFF569战斗记录 |R-> |cFF55FF55开启|R")
	end
end

--带前缀的JTE_Print()
function JTE_Print(msg, ...)
	local header = iconStr(135451).."[|CFF8FFFA2JTE|R]|CFF8FFFA2 : "
	if type(msg) ~= "string" and type(msg) ~= "number" then
		msg = tostring(msg) or ""
	end

	local arg = {...}
	if #arg > 0 then
		for i = 1, #arg do
			if type(arg[i]) ~= "string" and type(arg[i]) ~= "number" then
				arg[i] = tostring(arg[i]) or ""
			end
		end
	end

	print(header..msg, unpack(arg))
end

--Spell Check 
--/run JTE_SpellCheck("冲锋", 60000, 70000, 132226)
--/run JTE_SpellCheck("碎盾", 60000, 70000)
--/run JTE_SpellCheck("防御", 1, 100000)
local SpellCheckSaved = {}
function JTE_SpellCheck(checkName, startNum, endNum, checkIcon)
	if not startNum or type(startNum) ~= "number" then return end

	endNum = endNum or startNum + 1000
	SpellCheckSaved = {}
	for i = startNum, endNum do
		local name, rank, icon, castTime, minRange, maxRange, spellId, originalIcon = GetSpellInfo(i)
		if (not checkName or checkName == "" or name == checkName) and (not checkIcon or icon == checkIcon) then
			SpellCheckSaved[#SpellCheckSaved+1] = {
				spellId = spellId,
				name = name,
				rank = rank,
				icon = icon,
				castTime = castTime,
				minRange = minRange,
				maxRange = maxRange,
				originalIcon = originalIcon,
			}
			print("#|CFFFF53A2"..#SpellCheckSaved.."|R ID=|CFFFFFFFF"..(spellId or "NOID").."|R name=|CFFFFFFFF"..(name or "NONAME").."|R icon=|CFFFFFFFF"..(icon or "0").."|R L="..(spellId and GetSpellLink(spellId) or "NOLINK"))
		end
	end
	JTE_Print("Item(|CFFFFFFFF"..startNum.."|R-|CFFFFFFFF"..endNum.."|R) range check done #|CFFFFFFFF"..#SpellCheckSaved.."|R ids in range.")
end


--Item Range Check
local ItemRangeSaved = {}
function JTE_ItemRangeCheck(startNum, endNum)
	if not UnitExists("target") then
		JTE_Print("JTE_ItemRangeCheck No target last result remains.")
		return
	end

	endNum = endNum or startNum + 1000
	ItemRangeSaved = {}
	for i = startNum, endNum do
		if IsItemInRange(i, "target") == true then
			ItemRangeSaved[#ItemRangeSaved+1] = i
		end
	end
	JTE_Print("Item(|CFFFFFFFF"..startNum.."|R-|CFFFFFFFF"..endNum.."|R) range check done #|CFFFFFFFF"..#ItemRangeSaved.."|R ids in range.")
end

function JTE_ItemOutRangeCheck()
	JTE_Print("#ItemRangeSaved= |CFFFFFFFF"..#ItemRangeSaved)
	if not UnitExists("target") then
		JTE_Print("JTE_ItemOutRangeCheck No target last result remains.")
		return
	end
	if #ItemRangeSaved >= 1 then
		for i = #ItemRangeSaved, 1, -1  do
			if IsItemInRange(ItemRangeSaved[i], "target") then
				table.remove(ItemRangeSaved, i)
			else
				if #ItemRangeSaved <= 10 then
					JTE_Print("ItemRangeSaved["..i.."] = "..ItemRangeSaved[i])
				end
			end
		end
	end
	JTE_Print("ItemOutRange check done #|CFFFFFFFF"..#ItemRangeSaved.."|R remain."..(#ItemRangeSaved > 10 and " shows when <10."))
end

function JTE_ListItemRangeSaved()
	if #ItemRangeSaved >= 1 then
		for i = 1, #ItemRangeSaved do
			JTE_Print("#"..i.." id = "..ItemRangeSaved[i])
		end
		JTE_Print("ItemRangeSaved total #|CFFFFFFFF"..#ItemRangeSaved)
	end
end

local MakeItemLink = function(itemId)
	local _, itemLink = GetItemInfo(itemId)
	JTE_Print(itemLink)
	return itemLink
end
JTE.ItemLink = MakeItemLink

local GetVersion = function()
	return JTE.Version
end
JTE.GetVersion = GetVersion
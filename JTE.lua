local _G = getfenv(0)
local addonName, addonTable = ...

JTE = {}
JTE.addonName = addonName
JTE.version = C_AddOns.GetAddOnMetadata(addonName, "Version")

JTE.MissingDependency = {}
JTE.Spam = {}
JTE.IsAddOnLoaded = {}

local JTE_IsAddOnLoaded = function()
	local addonList = {
		"ElvUI",
		"tdInspect",
		"BiaoGe",
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

local iconStr = function(iconId)
	if iconId and type(iconId) == "number" then
		return "|T"..iconId..":12:12:0:0:64:64:4:60:4:60|t"
	else
		return ""
	end
end

--Bindings文本
BINDING_CATEGORY_JTE = "|CFF1785D1JTE|R - JT的小工具合集 "..iconStr(135451)

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
BINDING_NAME_JTE_MACRO_FRAME_TOGGLE = iconStr(132181).."显示/隐藏宏界面"
BINDING_NAME_JTE_FRIENDLY_PLAYER_NAME_TOGGLE = iconStr(135934).."显示/隐藏友方玩家姓名"

BINDING_HEADER_JTE_INGAME = "游戏设置"
BINDING_NAME_JTE_SUMMON_TRAVELERS_TUNDRA_MAMMOTH = iconStr(236240).."召唤修理大象"
BINDING_NAME_JTE_SUMMON_FAVORITE_MOUNT = iconStr(134010).."召唤随机偏好坐骑"
BINDING_NAME_JTE_SWAP_TRINKET = iconStr(133434).."饰品对换重置ICD"
BINDING_NAME_JTE_INSPECT = iconStr(132311).."鼠标悬浮查看天赋"
BINDING_NAME_JTE_INITIATE_TRADE = iconStr(133784).."向目标发起交易"
BINDING_NAME_JTE_LEAVE_PARTY = iconStr(132328).."退出队伍"
BINDING_NAME_JTE_SWITCH_COMBAT_LOG = iconStr(133734).."开启/关闭战斗记录"

BINDING_HEADER_JTE_CLASS_KEYS = "联动设置"
BINDING_NAME_JTE_ROGUE_TOT_SET_TARGET_A = iconStr(236283).."JT嫁祸WA-设置嫁祸|CFF94EF00A"
BINDING_NAME_JTE_ROGUE_TOT_SET_TARGET_B = iconStr(236283).."JT嫁祸WA-设置嫁祸|CFFEF573EB"
BINDING_NAME_JTE_BIAOGE_CD_FRAME_TOGGLE = iconStr(132149).."BiaoGe-显示副本CD"
BINDING_NAME_JTE_MRT_FIGHT_LOG_TOGGLE = iconStr(133739).."MRT-显示战斗分析"

local checkresponse = nil

--命令登记
SLASH_JTE1 = "/jte";
SlashCmdList["JTE"] = function(msg)
	JTE_SlashCommandHandler(msg);
end

SLASH_JTEMOUNT1 = "/jtem";
SlashCmdList["JTEMOUNT"] = function(msg)
	JTE_MountSlashCommandHandler(msg);
end

local JTEFrame, events = CreateFrame("Frame"), {};

local initDB = function()
	if type(JTEDB) ~= "table" then JTEDB = {} end
	if type(JTEDB.ResponseMax) ~= "number" then JTEDB.ResponseMax = 200 end
	if type(JTEDB.CheckResponse) ~= "table" then JTEDB.CheckResponse = {} end
	while #JTEDB.CheckResponse > JTEDB.ResponseMax do
		table.remove(JTEDB.CheckResponse, 1)
	end
end

local initVariables = function()
	--装备记录
	JTE_SaveInventoryItemId()
end

function events:ADDON_LOADED(...)
	local addOnName, containsBindings = ...
	if addOnName == JTE.addonName then
		DEFAULT_CHAT_FRAME:AddMessage("JTE是Jettie为了自己方便做的小工具")
		if initDB then
			initDB()
		end
		checkresponse = JTEDB.CheckResponse
	end
	JTE_ReApplySkin()
end

function events:CHAT_MSG_ADDON(...)
	local prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID = ...
	if prefix == "JTECHECKRESPONSE" then
		local sourceName = JTE_SplitString(sender,"-") and JTE_SplitString(sender,"-") or sender
		local msg = text
		local channel = channel
		local t = "|CFFFF0000In: |R"..channel.." ["..JTE_ClassColorName(sourceName).."] |CFF40FF40Res: |R"..msg
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

function events:UNIT_SPELLCAST_SUCCEEDED(...)
	JTE_OnSpellCastSucceeded(...)
end

function events:PLAYER_EQUIPMENT_CHANGED(...)
	JTE_OnEquipmentChanged(...)
	-- local equipmentSlot, hasCurrent = ...
	-- --换饰品的换回来功能
	-- JTE_SwapTrinketsBack(equipmentSlot, hasCurrent)
end

function events:PLAYER_ENTERING_WORLD(...)
	JTE_Print("是|RJettie@SMTH|CFF8FFFA2为了自己方便做的小工具")
	initVariables()
	JTE_IsAddOnLoaded()
	JTEFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

JTEFrame:SetScript("OnEvent", function(self, event, ...)
	events[event](self, ...); -- call one of the functions above
end);

for k, v in pairs(events) do
	JTEFrame:RegisterEvent(k); -- Register all events for which handlers have been defined
end

-- ElvUI Reskin
function JTE_ReApplySkin()
	if JTE.IsAddOnLoaded["ElvUI"] then
		if JTE.IsAddOnLoaded["tdInspect"] then
			if not InspectFrame then
				local f = CreateFrame("Frame");
				f:SetScript("OnEvent", function(self, evnet, addon)
					if evnet == "ADDON_LOADED" then
						if addon == "Blizzard_InspectUI" then
							local E=unpack(ElvUI)
							local S=E:GetModule('Skins')
							if InspectFrameTab4 then
								S:HandleTab(_G['InspectFrameTab4'])
								InspectFrameTab4:SetPoint('LEFT', _G['InspectFrameTab3'], 'RIGHT', -19, 0)
								S:HandleFrame(_G.InspectFrame.GlyphFrame, true, nil, 11, -12, -32, 76)
							end
							f:UnregisterEvent("ADDON_LOADED");
						end
					end
				end)
				f:RegisterEvent("ADDON_LOADED")
			end
		end
	end
end

-- BiaoGe 副本CD界面快捷键
function JTE_BiaoGeCDFrameToggle()
	if JTE.IsAddOnLoaded["BiaoGe"] then
		if BG and BG.FBCDFrame and BG.FBCDFrame:IsShown() then
			BG.FBCDFrame:Hide()
		else
			BG.SetFBCD(nil, nil, true)
		end
	else
		JTE_Print("副本CD显示快捷键需要安装BiaoGe插件")
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

--命令判断
function JTE_SlashCommandHandler(msg)
	if( msg ) then
		local command = string.lower(msg);
		--先用空格拆分指令
		if JTE_SplitString(command," ") then
			--有前缀指令
			local command, pre1, pre2, pre3 = JTE_CmdSplit(command)
			JTE_Print("|CFFFF0000Pre1: |R"..tostring(pre1).." |CFFFF0000Pre2: |R"..(pre2 or ("|CFF7D7D7D"..tostring(pre2).."|R")).." |CFFFF0000Pre3: |R"..(pre3 or ("|CFF7D7D7D"..tostring(pre3).."|R")).." |CFFFF0000Cmd: |R"..command)
			if pre1 == "s" or pre1 == "g" or pre1 == "r" or pre1 == "p" then
				JTE_SendStealthMessage(command, pre1, pre2, pre3)
			elseif pre1 == "c" then
				JTE_StealthCheck(command, pre1, pre2, pre3)
			elseif pre1 == "d" then
				JTE_ForToggleDebugShit(command)
			elseif pre1 == "e" then
				JTE_FakeWeakAurasEvent(command)
			elseif pre1 == "link" then
				JTE_ItemLink(command)
			elseif pre1 == "listmax" then
				JTE_ListResponseMax(command)
			elseif pre1 == "ins" or pre1 == "inspect" then
				JTE_Inspect(command)
			elseif pre1 == "irc" or pre1 == "itemrangecheck" then
				JTE_ItemRangeCheck((pre2 or command), (pre2 and command))
			elseif pre1 == "gq" or pre1 == "graphicsquality" then
				JTE_SetGraphicsQuality(command)
			else
				JTE_Print("Wrong cmd")
			end
		else
			--无前缀指令
			if( command == "log" or command == "combatlog") then
				JTE_CombatLog()
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
			elseif( command == "rs" or command == "restartsound" ) then
				JTE_RestartSound()
			elseif( command == "st" or command == "swaptrinket" ) then
				JTE_SwapTrinkets()
			elseif( command == "t" ) then
				JTE_Test()
			elseif( command == "test" ) then
				DEFAULT_CHAT_FRAME:AddMessage('JTE testing')
				-- |T iconpath/iconid : width : height : posX : posY : scaleX : scaleY :4:60:4:60 --后4别动，边框和资源管理移位用的
			else
				JTE_help();
			end
		end
	end
end
function JTE_MountSlashCommandHandler(msg)
	if( msg ) then
		--local command = string.lower(msg);
		--先用空格拆分指令
		JTE_Mount(JTE_MountCmdSplit(msg))

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
		JTE_Print("who: "..(name == "all" and "|CFFFFFFFFAll|R" or JTE_ClassColorName(name) ).." will say: |CFFFF53A2"..command.."|R in "..convertJTEChannel[msgChanncelList[pre2]])
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
		JTE_Print("name"..JTE.addonName)
	end
end

function JTE_help()
	JTE_Print("是|RJettie@SMTH|CFF8FFFA2为了自己方便做的小工具")
	JTE_Print("命令为: |R/jte");
	JTE_Print("在|R ESC-选项-快捷键 |CFF8FFFA2中可以看到 |CFF1785D1JTE|R 相关的一些快捷键优化");

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
function JTE_MountCmdSplit(str) --最多3参数
	if not str or str == "" then
		return nil
	end
	local groundMountName, flyMountName, swimMountName
	if JTE_SplitString(str," ") then
		groundMountName, flyMountName = JTE_SplitString(str," ")
		if JTE_SplitString(flyMountName," ") then
			flyMountName, swimMountName = JTE_SplitString(flyMountName," ")
			return groundMountName, flyMountName, swimMountName
		else
			return groundMountName, flyMountName
		end
	else
		return str
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
			local l = "|CFFFF0000History: |R"..i.." ["..JTE_ClassColorName(checkresponse[i].name).."] |CFF40FF40Res: |R"..checkresponse[i].msg
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

--10个档位的画质参数
local graphicsQuality = {
	["graphicsSunshafts"] = { 0, 0, 0, 0, 1, 2, 2, 2, 2, 2 },
	["particleDensity"] = { 10, 10, 25, 50, 80, 80, 100, 100, 100, 100 },
	["lodObjectMinSize"] = { 0, 0, 0, 0, 0, 0, 0, 0, 30, 20 },
	["graphicsProjectedTextures"] = { 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 },
	["componentTextureLevel"] = { 1, 1, 0, 0, 0, 0, 0, 0, 0, 0 },
	["lodObjectFadeScale"] = { 50, 80, 90, 91, 92, 93, 100, 101, 125, 150 },
	["groundEffectAnimation"] = { 0, 0, 0, 1, 1, 1, 1, 1, 1, 1 },
	["rippleDetail"] = { 0, 0, 0, 0, 1, 1, 1, 1, 1, 2 },
	["graphicsLiquidDetail"] = { 0, 0, 0, 1, 2, 2, 2, 2, 2, 3 },
	["graphicsShadowQuality"] = { 0, 0, 0, 1, 2, 3, 3, 4, 5, 5 },
	["shadowTextureSize"] = { 1024, 1024, 1024, 1024, 1024, 2048, 2048, 2048, 2048, 2048 },
	["graphicsSpellDensity"] = { 0, 1, 2, 3, 4, 4, 4, 4, 4, 5 },
	["reflectionMode"] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 3 },
	["sunShafts"] = { 0, 0, 0, 0, 1, 2, 2, 2, 2, 2 },
	["lodObjectCullSize"] = { 35, 25, 20, 20, 20, 19, 18, 18, 16, 14 },
	["graphicsGroundClutter"] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 },
	["shadowMode"] = { 0, 0, 0, 1, 2, 3, 3, 3, 4, 4 },
	["groundEffectDensity"] = { 16, 32, 64, 64, 64, 80, 80, 128, 128, 256 },
	["waterDetail"] = { 0, 0, 0, 1, 2, 2, 2, 2, 2, 3 },
	["projectedTextures"] = { 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 },
	["groundEffectDist"] = { 70, 70, 70, 110, 160, 185, 200, 260, 300, 320 },
	["graphicsParticleDensity"] = { 1, 1, 2, 3, 4, 5, 6, 6, 6, 6 },
	["spellClutter"] = { 100, 75, 50, 25, -1, -1, -1, -1, -1, 0 },
	["shadowBlendCascades"] = { 0, 0, 0, 0, 0, 1, 1, 1, 1, 1 },
	["graphicsSSAO"] = { 0, 0, 0, 1, 2, 3, 3, 4, 4, 4 },
	["worldBaseMip"] = { 1, 1, 0, 0, 0, 0, 0, 0, 0, 0 },
	["shadowSoft"] = { 0, 0, 0, 0, 0, 0, 0, 1, 1, 1 },
	["SSAO"] = { 0, 0, 0, 1, 2, 3, 3, 4, 4, 4 },
	["graphicsQuality"] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 },
	["particleMTDensity"] = { 33, 33, 50, 80, 80, 100, 100, 100, 100, 100 },
	["weatherDensity"] = { 0, 1, 1, 1, 3, 3, 3, 3, 3, 3 },
	["graphicsEnvironmentDetail"] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 },
	["terrainMipLevel"] = { 1, 1, 0, 0, 0, 0, 0, 0, 0, 0 },
	["doodadLodScale"] = { 50, 50, 75, 75, 100, 100, 100, 125, 150, 150 },
	["graphicsTextureResolution"] = { 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 }
	
}
--查看画质参数，用于读取当前数据
function JTE_GetGraphicsQuality()
	--画质1
	JTE_Print("---------")
	for k, v in pairs(graphicsQuality) do
		if k then
			local cur = GetCVar(k)
			print("[\""..k.."\"] = "..cur..",")
			--SetCVar(k,v)
		else
			JTE_Print("|CFF8FFFA2GQ:Get "..k.." failed.")
			return
		end
	end
end

--设置画质
function JTE_SetGraphicsQuality(qualitylevel)
	if type(qualitylevel) ~= "number" then qualitylevel = tonumber(qualitylevel) end
	if not qualitylevel or qualitylevel <= 0 or qualitylevel > 10 then return end
	local table = graphicsQuality
	for k, v in pairs(table) do
		if k then
			SetCVar(k,v[qualitylevel])
		else
			JTE_Print("|CFF8FFFA2Set |CFFFF0000failed|R")
		end
	end
	RestartGx()
	JTE_Print("|CFF8FFFA2Set GraphicsQuality to : |R"..qualitylevel)
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

--坐骑检测
JTE.Mount = {}
local JTE_isMountCollected = function(mountNameOrId) --return name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID
	-- local mountIDs = C_MountJournal.GetMountIDs()
	if not JTE.Mount.MountIDs then return end
	for _, v in pairs(JTE.Mount.MountIDs) do
		local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(v)
		if spellID == mountNameOrId or name == mountNameOrId then
			if isCollected then
				return true, name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID
			else
				return false, name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID
			end
		end
	end
end
local JTE_UpdateMountIDs = function()
	if not JTE.Mount.MountIDs then
		JTE.Mount.MountIDs = C_MountJournal.GetMountIDs()
	else
		local newMountIDs = C_MountJournal.GetMountIDs()
		if #JTE.Mount.MountIDs ~= #newMountIDs then
			JTE.Mount.MountIDs = newMountIDs
		end
	end
end
--Traveler's Tundra Mammoth
function JTE_TravelersTundraMammoth()
	JTE_UpdateMountIDs()

	if not InCombatLockdown() then
		local TravelersTundraMammothSpellID = UnitFactionGroup("player") == "Alliance" and 61425 or 61447;
		local _, itemLink = GetItemInfo(UnitFactionGroup("player") == "Alliance" and 44235 or 44234);
		local isCollected, name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID = JTE_isMountCollected(TravelersTundraMammothSpellID)
		if mountID and isCollected then
			C_MountJournal.SummonByID(mountID)
			return
		else
			JTE_Print("达拉然的<特殊坐骑商人>梅尔·弗兰希斯可以购买"..itemLink)
		end
	end
end

--坐骑宏 /run JTE_Mount("奥的灰烬","迅捷幽灵虎","迅捷幽灵虎")
function JTE_Mount(groundMountNameArray,flyMountNameArray,swimMountNameArray)
	JTE_UpdateMountIDs()

	local getMountNames = function(namesString)
		if not namesString then return end

		local nameTable = {}
		local splitByComma = strsplittable(",", namesString)

		for i = 1, #splitByComma do
			local splitBySemicolon = {}
			splitBySemicolon[i] = strsplittable(";", splitByComma[i])
			for j = 1, #splitBySemicolon[i] do
				local splitByMinus = {}
				splitByMinus[j] = strsplittable("-", splitBySemicolon[i][j])
				for k = 1, #splitByMinus[j] do
					if splitByMinus[j][k] and splitByMinus[j][k] ~= "" then
						tinsert(nameTable, splitByMinus[j][k])
					end
				end
			end
		end
		for l = #nameTable, 1, -1 do
			if not JTE_isMountCollected(nameTable[l]) then
				tremove(nameTable, l)
			end
		end
		return nameTable
	end

	local gmMountNames = getMountNames(groundMountNameArray)
	local groundMountName
	if gmMountNames and #gmMountNames > 0 then
		groundMountName = gmMountNames[math.random(#gmMountNames)]
	else
		groundMountName = nil
	end

	local flyMountNames = getMountNames(flyMountNameArray)
	local flyMountName
	if flyMountNames and #flyMountNames > 0 then
		flyMountName = flyMountNames[math.random(#flyMountNames)]
	else
		flyMountName = nil
	end

	local swimMountNames = getMountNames(swimMountNameArray)
	local swimMountName
	if swimMountNames and #swimMountNames > 0 then
		swimMountName = swimMountNames[math.random(#swimMountNames)]
	else
		swimMountName = nil
	end

	--在达拉然且不在平台时使用陆地坐骑
	local gmSpellID, gmIsCollected, gmMountID, fmSpellID, fmIsCollected, fmMountID, smSpellID, smIsCollected, smMountID
	if groundMountName then
		local _, _, spellID, _, _, _, _, _, _, _, _, isCollected, mountID = JTE_isMountCollected(groundMountName)
		gmSpellID, gmIsCollected, gmMountID = spellID, isCollected, mountID
	else
		JTE_Print("自动适应达拉然的坐骑宏，格式为:")
		JTE_Print("|R/JTEM 陆地坐骑名 飞行坐骑名 水中坐骑名(选填)")
		JTE_Print("例如:")
		JTE_Print("|R/JTEM 迅捷幽灵虎 奥的灰烬 骑乘乌龟")
		return
	end
	if flyMountName then
		local _, _, spellID, _, _, _, _, _, _, _, _, isCollected, mountID = JTE_isMountCollected(flyMountName)
		fmSpellID, fmIsCollected, fmMountID = spellID, isCollected, mountID
	else
		fmSpellID, fmIsCollected, fmMountID = gmSpellID, gmIsCollected, gmMountID
		flyMountName = groundMountName
	end
	if swimMountName then
		local _, _, spellID, _, _, _, _, _, _, _, _, isCollected, mountID = JTE_isMountCollected(swimMountName)
		smSpellID, smIsCollected, smMountID = spellID, isCollected, mountID
	else
		smSpellID, smIsCollected, smMountID = fmSpellID, fmIsCollected, fmMountID
		swimMountName = flyMountName
	end
	local unknownMount = function(mountName)
		JTE_Print("你还没有学会 |R"..mountName)
	end
	if ( C_Map.GetBestMapForUnit("player")==125 and GetSubZoneText()~="克拉苏斯平台" ) or ( C_Map.GetBestMapForUnit("player")==126 and GetSubZoneText()=="达拉然下水道" ) then
		if gmMountID and gmIsCollected then
			C_MountJournal.SummonByID(gmMountID)
		else
			unknownMount(groundMountName)
		end
	elseif IsSubmerged() and not IsMounted() then
		if smMountID and smIsCollected then
			C_MountJournal.SummonByID(smMountID)
		else
			unknownMount(swimMountName)
		end
	elseif IsFlyableArea() then
		if fmMountID and fmIsCollected then
			C_MountJournal.SummonByID(fmMountID)
		else
			unknownMount(flyMountName)
		end
	else
		if gmMountID and gmIsCollected then
			C_MountJournal.SummonByID(gmMountID)
		else
			unknownMount(groundMountName)
		end
	end
end

--随机偏好坐骑
function JTE_SummonRandomFavoriteMount()
	C_MountJournal.SummonByID(0)
end

--嫁祸宏设置嫁祸目标
function JTE_ToTSetTarget(setAorB)
	if not ( setAorB == "A" or setAorB == "a" or setAorB == "B" or setAorB == "b" or setAorB == 1 or setAorB == 2 ) then
		JTE_Print(iconStr(236283)..'设置嫁祸目标只可以是 |CFFFFFFFF"A"|R 或者 |CFFFFFFFF"B"|R')
		return
	end
	local playerClassName, playerClass = UnitClass("player")
	if playerClass ~= "ROGUE" then
		JTE_Print(iconStr(236283)..''..GetSpellLink(57934)..'是 |CFFFFF569盗贼|R 的限定技能 |C'..select(4, GetClassColor(playerClass))..playerClassName..' |R无法使用')
		return
	end

	--检测有没有WA插件
	if JTE.IsAddOnLoaded["WeakAuras"] then
		--检测有没有嫁祸WA
		if WeakAuras.GetRegion("宏看右边-自定义选项") or WeakAuras.GetRegion("宏看右边-自定义选项 2") then
			--有嫁祸WA
			if IsInGroup() then
				if setAorB == "A" or setAorB == "a" or setAorB == 1 then
					WeakAuras.ScanEvents('SETJHTARGETA')
				elseif setAorB == "B" or setAorB == "b" or setAorB == 2 then
					WeakAuras.ScanEvents('SETJHTARGETB')
				end
			else
				if not JTE.Spam["ToTNotInGroup"] then
					JTE.Spam["ToTNotInGroup"] = GetTime() - 1
				end
				if JTE.Spam["ToTNotInGroup"] < GetTime() then
					JTE_Print(iconStr(236283).."|CFFFFFFFF[|RJT嫁祸WA|CFFFFFFFF]|R 组队时才能使用嫁祸哟 (;P)")
					JTE.Spam["ToTNotInGroup"] = GetTime() + 0.5
				end
			end
		else
			JTE_Print("没有检测到 "..iconStr(236283).."|CFFFFFFFF[|RJT嫁祸WA|CFFFFFFFF]|R 请先导入嫁祸WA")
		end
	else
		JTE_Print("设置嫁祸虚拟焦点需要安装插件 |CFFFFFFFFWeakAuras|R 并导入 "..iconStr(236283).."|CFFFFFFFF[|RJT嫁祸WA|CFFFFFFFF]|R 才能使用")
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

local kirinTorTeleportId = 54406
--local kirinTorTeleportId = 51723 --扰乱测试
local kirinTorRings = {
	--ilv 200
	[40585] = true,
	[40586] = true,
	[44934] = true,
	[44935] = true,
	--ilv 213
	[45688] = true,
	[45689] = true,
	[45690] = true,
	[45691] = true,
	--ilv 226
	[48954] = true,
	[48955] = true,
	[48956] = true,
	[48957] = true,
	--ilv 251
	-- [51557] = true,
	-- [51558] = true,
	-- [51559] = true,
	-- [51560] = true,
}
--测试物品名字，等ICC更新后再测一次删除
function JTE_PrintItemNames()
	local count = 0
	for k, v in pairs(kirinTorRings) do
		local name = GetItemInfo(k)
		JTE_Print("id="..k.." name="..(name or "NONAME"))
		if name then
			count = count + 1
		end
	end
	JTE_Print("Total #|CFFFFFFFF"..count.." rings.")
end

function JTE_SaveInventoryItemId()
	--装备记录
	for i = 1, 19 do
		local itemId = GetInventoryItemID("player", i)
		if itemId then
			JTE.previousEquipmentId[i] = itemId
		end
	end
end

function JTE_OnEquipmentChanged(equipmentSlot, hasCurrent)
	--肯瑞托传送戒指换回来功能,穿戴肯瑞托戒指时记录
	if equipmentSlot == 11 or equipmentSlot ==12 then
		local newId = GetInventoryItemID("player", equipmentSlot)
		if kirinTorRings[newId] then
			for k, v in pairs(JTE.waitToSwitchBack) do
				if v == newId then
					JTE.waitToSwitchBack[k] = nil
				end
			end
			JTE.waitToSwitchBack[equipmentSlot] = (JTE.previousEquipmentId[equipmentSlot] ~= newId) and JTE.previousEquipmentId[equipmentSlot] or nil
			JTEFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		else
			if JTE.waitToSwitchBack[equipmentSlot] then
				JTE.waitToSwitchBack[equipmentSlot] = nil
			end
		end
	end
	if not next(JTE.waitToSwitchBack) then
		JTEFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	end

	JTE_SaveInventoryItemId()
	--换饰品的换回来功能
	JTE_SwapTrinketsBack(equipmentSlot, hasCurrent)
end

function JTE_OnSpellCastSucceeded(...)
	local unitTarget, castGUID, spellId = ...
	--肯瑞托戒指传送释放成功
	if unitTarget == "player" and spellId == kirinTorTeleportId then
		if next(JTE.waitToSwitchBack) then
			for k, v in pairs(JTE.waitToSwitchBack) do
				EquipItemByName(v, k)
				local _, itemLink = GetItemInfo(v)
				JTE_Print("肯瑞托戒指"..(GetSpellLink(kirinTorTeleportId) or "传送").."后自动换回之前的: "..(itemLink or v))
			end
			JTE.waitToSwitchBack = {}
		end
	end
end

--鼠标悬浮查看天赋
function JTE_Inspect(inspectName, inspectRealm)
	local unit
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

--交换饰品重置内置ICD
JTE.TrinketsSwapping = false
JTE.TrinketsSwapWait = false
function JTE_SwapTrinkets()
	if not InCombatLockdown() then
		local trinket0SlotId, trinket1SlotId = GetInventoryItemID("player", 13), GetInventoryItemID("player", 14)
		local Trinket0, Trinket1  = INVSLOT_TRINKET1, INVSLOT_TRINKET2
		if not trinket0SlotId and trinket1SlotId then
			Trinket0, Trinket1 = Trinket1, Trinket0
		elseif not trinket0SlotId and not trinket1SlotId then
			JTE_Print("没有装备任何饰品")
			return
		end
		ClearCursor();
		PickupInventoryItem(Trinket0);
		if CursorHasItem() then
			EquipCursorItem(Trinket1);
		end
		JTE.TrinketsSwapping = true
		JTE.TrinketsSwapWait = true
	end
end
function JTE_SwapTrinketsBack(equipmentSlot, hasCurrent)
	if JTE.TrinketsSwapping and JTE.TrinketsSwapWait then
		JTE.TrinketsSwapWait = false
		--print("Wait JTE.TrinketsSwapping="..JTE.TrinketsSwapping)
		return
	elseif JTE.TrinketsSwapping and not JTE.TrinketsSwapWait then
		local trinket0SlotId, trinket1SlotId = GetInventoryItemID("player", 13), GetInventoryItemID("player", 14)
		local Trinket0, Trinket1  = INVSLOT_TRINKET1, INVSLOT_TRINKET2
		if not trinket0SlotId and trinket1SlotId then
			Trinket0, Trinket1 = Trinket1, Trinket0
		elseif not trinket0SlotId and not trinket1SlotId then
			JTE_Print("没有装备任何饰品")
			return
		end
		if not InCombatLockdown() then
			ClearCursor()
			PickupInventoryItem(Trinket0)
			if CursorHasItem() then
				EquipCursorItem(Trinket1)
			end
		end
		JTE.TrinketsSwapping = false
	end
end

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

--玩家名字染色
function JTE_ClassColorName(unit)
	if unit and UnitExists(unit) then
		local name = UnitName(unit)
		local _, class = UnitClass(unit)
		if not class then
			return name or unit
		else
			local classData = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
			local coloredName = ("|c%s%s|r"):format(classData.colorStr, name)
			return coloredName
		end
	else
		return unit
	end
end
JTE.ClassColorName = JTE_ClassColorName

--带前缀的JTE_Print()
function JTE_Print(msg)
	local header = iconStr(135451).."[|CFF8FFFA2JTE|R]|CFF8FFFA2 : "
	if type(msg) ~= "string" and type(msg) ~= "number" then
		msg = tostring(msg)
	end
	print(header..msg)
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

function JTE_ItemLink(itemId)
	local _, itemLink = GetItemInfo(itemId)
	JTE_Print(itemLink)
	return itemLink
end

--宏界面拉长，天赋界面拉长
do
    --宏界面
    local AddSelectHeight = 100
    local AddTextHeight = 150
    local tempScrollPer = nil
    local Init = function()
        hooksecurefunc(MacroFrame, "SelectMacro", function(self, index)
            if tempScrollPer then
                MacroFrame.MacroSelector.ScrollBox:SetScrollPercentage(tempScrollPer)
                tempScrollPer = nil
            end
        end)
        MacroFrame.MacroSelector:SetHeight(146 + AddSelectHeight)
        MacroHorizontalBarLeft:SetPoint("TOPLEFT", 2, -210 - AddSelectHeight)
        MacroFrameSelectedMacroBackground:SetPoint("TOPLEFT", 2, -218 - AddSelectHeight)
        MacroFrameTextBackground:SetPoint("TOPLEFT", 6, -289 - AddSelectHeight)
        local h = MacroFrame:GetHeight()
        MacroFrame:SetHeight(h + AddTextHeight + AddSelectHeight)
        MacroFrameScrollFrame:SetHeight(85 + AddTextHeight)
        MacroFrameText:SetHeight(85 + AddTextHeight)
        MacroFrameTextButton:SetHeight(85 + AddTextHeight)
        MacroFrameTextBackground:SetHeight(95 + AddTextHeight)
    end
    if MacroFrame then
        Init()
    else
        local f = CreateFrame("Frame");
        f:SetScript("OnEvent", function(self, evnet, addon)
            if evnet == "ADDON_LOADED" then
                if addon == "Blizzard_MacroUI" then
                    Init()
                    f:UnregisterEvent("ADDON_LOADED");
                end
            elseif MacroFrame then
                tempScrollPer = MacroFrame.MacroSelector.ScrollBox.scrollPercentage
            end
        end)
        f:RegisterEvent("ADDON_LOADED")
        --MacroFrame会在每次显示的时候注册UPDATE_MACROS，所以肯定比我们执行的要晚
        --这一切前提建立在这个条件上
        f:RegisterEvent("UPDATE_MACROS")
    end
	--调整天赋界面高度
	if PlayerTalentFrame then
		--PlayerTalentFrame:GetHeight()=512
		PlayerTalentFrame:SetHeight(900)
	else
		local f = CreateFrame("Frame");
        f:SetScript("OnEvent", function(self, evnet, addon)
            if evnet == "ADDON_LOADED" then
                if addon == "Blizzard_TalentUI" then
                    PlayerTalentFrame:SetHeight(900)

                    f:UnregisterEvent("ADDON_LOADED");
                end
            end
        end)
        f:RegisterEvent("ADDON_LOADED")
	end
	if not GlyphFrame then
		local f = CreateFrame("Frame");
        f:SetScript("OnEvent", function(self, evnet, addon)
            if evnet == "ADDON_LOADED" then
                if addon == "Blizzard_GlyphUI" then
					local yOffset = -180
					GlyphFrameBackground:SetPoint("TOPLEFT",14,-46 + yOffset)
					GlyphFrameGlyph1:SetPoint("CENTER", -15, 335 + yOffset)
					GlyphFrameGlyph2:SetPoint("CENTER", -14, 93 + yOffset)
					GlyphFrameGlyph3:SetPoint("TOPLEFT", 28, -133 + yOffset)
					GlyphFrameGlyph4:SetPoint("BOTTOMRIGHT", -56, 558 + yOffset)
					GlyphFrameGlyph5:SetPoint("TOPRIGHT", -56, -133 + yOffset)
					GlyphFrameGlyph6:SetPoint("BOTTOMLEFT", 26, 558 + yOffset)
                    f:UnregisterEvent("ADDON_LOADED");
                end
            end
        end)
        f:RegisterEvent("ADDON_LOADED")
	end
end


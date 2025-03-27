local _G = _G
local addonName, JTE = ...

JTE.Mount = {}
local MT = JTE.Mount
local JTE_Print = JTE_Print or print

--坐骑检测
MT = {}
local IsMountCollected = function(mountNameOrId) --return name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID
	-- local mountIDs = C_MountJournal.GetMountIDs()
	if not MT.MountIDs then return end
	for _, v in pairs(MT.MountIDs) do
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

local UpdateMountIDs = function()
	if not MT.MountIDs then
		MT.MountIDs = C_MountJournal.GetMountIDs()
	else
		local newMountIDs = C_MountJournal.GetMountIDs()
		if #MT.MountIDs ~= #newMountIDs then
			MT.MountIDs = newMountIDs
		end
	end
end

--Traveler's Tundra Mammoth
local TravelersTundraMammoth = function()
	UpdateMountIDs()

	if not InCombatLockdown() then
		local TravelersTundraMammothSpellID = UnitFactionGroup("player") == "Alliance" and 61425 or 61447;
		local _, itemLink = GetItemInfo(UnitFactionGroup("player") == "Alliance" and 44235 or 44234);
		local isCollected, name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID = IsMountCollected(TravelersTundraMammothSpellID)
		if mountID and isCollected then
			C_MountJournal.SummonByID(mountID)
			return
		else
			JTE_Print("达拉然的<特殊坐骑商人>梅尔·弗兰希斯可以购买"..itemLink)
		end
	end
end
JTE.TravelersTundraMammoth = TravelersTundraMammoth

--坐骑宏 /run GoMount("奥的灰烬","迅捷幽灵虎","迅捷幽灵虎")
local GoMount = function(groundMountNameArray,flyMountNameArray,swimMountNameArray)
	UpdateMountIDs()

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
			if not IsMountCollected(nameTable[l]) then
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
		local _, _, spellID, _, _, _, _, _, _, _, _, isCollected, mountID = IsMountCollected(groundMountName)
		gmSpellID, gmIsCollected, gmMountID = spellID, isCollected, mountID
	else
		JTE_Print("自动适应达拉然的坐骑宏，格式为:")
		JTE_Print("|R/JTEM 陆地坐骑名 飞行坐骑名 水中坐骑名(选填)")
		JTE_Print("例如:")
		JTE_Print("|R/JTEM 迅捷幽灵虎 奥的灰烬 骑乘乌龟")
		return
	end
	if flyMountName then
		local _, _, spellID, _, _, _, _, _, _, _, _, isCollected, mountID = IsMountCollected(flyMountName)
		fmSpellID, fmIsCollected, fmMountID = spellID, isCollected, mountID
	else
		fmSpellID, fmIsCollected, fmMountID = gmSpellID, gmIsCollected, gmMountID
		flyMountName = groundMountName
	end
	if swimMountName then
		local _, _, spellID, _, _, _, _, _, _, _, _, isCollected, mountID = IsMountCollected(swimMountName)
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
local SummonRandomFavoriteMount = function()
	C_MountJournal.SummonByID(0)
end
JTE.SummonRandomFavoriteMount = SummonRandomFavoriteMount

local MountCmdSplit = function(str) --最多3参数
	if not str or type(str) ~= "string" or str == "" then
		return nil
	end
	local cleanStr = strtrim(str, " ")
	if cleanStr == "" then
		return nil
	end
	local groundMountName, flyMountName, swimMountName
	if strfind(cleanStr," ") then
		local tbl = {}
		for v in string.gmatch(cleanStr, "[^ ]+") do
			tinsert(tbl, v)
		end
		return tbl[1], tbl[2], tbl[3]

	else
		return str
	end
end

local MountSlashCommandHandler = function(msg)
	if( msg ) then
		--local command = string.lower(msg);
		--先用空格拆分指令
		GoMount(MountCmdSplit(msg))
	end
end

SLASH_JTEMOUNT1 = "/jtem";
SlashCmdList["JTEMOUNT"] = function(msg)
	MountSlashCommandHandler(msg);
end

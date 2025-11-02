local _G = _G
local addonName, JTE = ...

JTE.KTR = {}
local KTR = JTE.KTR
local JTE_Print = JTE_Print or print
local KTRFrame, KTRFrameEvents = CreateFrame("Frame"), {};

--装备自动换回的数据
KTR.previousEquipmentId = {}
KTR.waitToSwitchBack = {}

local kirinTorTeleportId = 54406
--local kirinTorTeleportId = 51723 -- 刀扇测试
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
	[51557] = true,
	[51558] = true,
	[51559] = true,
	[51560] = true,
}

--测试物品名字，等ICC更新后再测一次删除
local PrintKTRItemNames = function()
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
JTE.PrintKTRItemNames = PrintKTRItemNames

local SavedPreviousEquipmentId = function()
	--装备记录
	for i = 11, 12 do
		local itemId = GetInventoryItemID("player", i)
		if itemId then
			KTR.previousEquipmentId[i] = itemId
		end
	end
end

local secondsToTimeStr = function(seconds)
    -- 计算小时
    local hours = math.floor(seconds / 3600)
    -- 计算剩余的分钟数
    local minutes = math.floor((seconds % 3600) / 60)
    -- 计算剩余的秒数
    local secs = seconds % 60
    -- 格式化输出，确保小时、分钟和秒都是两位数
    local timeString = string.format("%02d:%02d:%02d", hours, minutes, secs)
    return timeString
end

local OnUIErrorMessage = function(event, message)
	if message == ERR_ITEM_COOLDOWN then
		-- 物品冷却中
		-- 肯瑞托戒指
		local itemIdFinger1 = GetInventoryItemID("player", INVSLOT_FINGER1)
		local itemIdFinger2 = GetInventoryItemID("player", INVSLOT_FINGER2)

		local thisItemId = kirinTorRings[itemIdFinger1] and itemIdFinger1 or (kirinTorRings[itemIdFinger2] and itemIdFinger2 or nil)
		local thisSlot = kirinTorRings[itemIdFinger1] and INVSLOT_FINGER1 or (kirinTorRings[itemIdFinger2] and INVSLOT_FINGER2 or nil)

		if thisSlot then
			local start, duration, enable = GetInventoryItemCooldown("player", thisSlot)
			local now = GetTime()
			if enable == 1 and start > 0 and start + duration - 1 > now then
				local timeLeft = start + duration - GetTime()
				local kirinLink = thisItemId and GetItemInfo(thisItemId) or "[肯瑞托戒指]"
				if KTR.waitToSwitchBack[thisSlot] then
					EquipItemByName(KTR.waitToSwitchBack[thisSlot], thisSlot)
					local previousItemLink = select(2, GetItemInfo(KTR.waitToSwitchBack[thisSlot]))
					JTE_Print(kirinLink.."冷却中，剩余时间: |CFFFFFFFF"..secondsToTimeStr(timeLeft).."|R 秒, 已自动换回之前的"..previousItemLink)
					KTR.waitToSwitchBack[thisSlot] = nil
				end
			end
		end
	end
end

local OnSpellCastSucceeded = function(...)
	local unitTarget, castGUID, spellId = ...
	--肯瑞托戒指传送释放成功
	if unitTarget == "player" and spellId == kirinTorTeleportId then
		if next(KTR.waitToSwitchBack) then
			local itemIdFinger1 = GetInventoryItemID("player", INVSLOT_FINGER1)
			local itemIdFinger2 = GetInventoryItemID("player", INVSLOT_FINGER2)

			local thisSlot = kirinTorRings[itemIdFinger1] and INVSLOT_FINGER1 or (kirinTorRings[itemIdFinger2] and INVSLOT_FINGER2 or nil)
			if thisSlot then
				for k, v in pairs(KTR.waitToSwitchBack) do
					if k == thisSlot then
						EquipItemByName(v, k)
						local _, itemLink = GetItemInfo(v)
						JTE_Print("肯瑞托戒指"..(GetSpellLink(kirinTorTeleportId) or "传送").."后自动换回之前的: "..(itemLink or v))
						KTR.waitToSwitchBack[k] = nil
					end
				end
			end
		end
	end
end

local OnEquipmentChanged = function(equipmentSlot, hasCurrent)
	-- 戒指
	if equipmentSlot == INVSLOT_FINGER1 or equipmentSlot == INVSLOT_FINGER2 then
		--肯瑞托传送戒指换回来功能,穿戴肯瑞托戒指时记录
		local newId = GetInventoryItemID("player", equipmentSlot)
		if kirinTorRings[newId] then
			for k, v in pairs(KTR.waitToSwitchBack) do
				if v == newId then
					KTR.waitToSwitchBack[k] = nil
				end
			end
			KTR.waitToSwitchBack[equipmentSlot] = (KTR.previousEquipmentId[equipmentSlot] ~= newId) and KTR.previousEquipmentId[equipmentSlot] or nil
			local itemLink = select(2, GetItemInfo(newId))
			local previousItemLink = select(2, GetItemInfo(KTR.waitToSwitchBack[equipmentSlot]))
			JTE_Print("已佩戴 "..(itemLink or "[肯瑞托戒指]").. " 等待传送后换回 "..(previousItemLink or "之前的戒指"))

            if GetItemCooldown(newId) > 0 and not IsAltKeyDown() then
				-- 物品冷却中
				-- 肯瑞托戒指
				local itemIdFinger1 = GetInventoryItemID("player", INVSLOT_FINGER1)
				local itemIdFinger2 = GetInventoryItemID("player", INVSLOT_FINGER2)

				local thisItemId = kirinTorRings[itemIdFinger1] and itemIdFinger1 or (kirinTorRings[itemIdFinger2] and itemIdFinger2 or nil)
				local thisSlot = kirinTorRings[itemIdFinger1] and INVSLOT_FINGER1 or (kirinTorRings[itemIdFinger2] and INVSLOT_FINGER2 or nil)

				if thisSlot then
					local start, duration, enable = GetInventoryItemCooldown("player", thisSlot)
						if enable == 1 and start > 0 then
							local timeLeft = start + duration - GetTime()
							local kirinLink = thisItemId and GetItemInfo(thisItemId) or "[肯瑞托戒指]"
						if KTR.waitToSwitchBack[thisSlot] then
							EquipItemByName(KTR.waitToSwitchBack[thisSlot], thisSlot)
							JTE_Print(kirinLink.."冷却中，剩余时间: |CFFFFFFFF"..secondsToTimeStr(timeLeft).."|R 秒, 已自动换回之前的"..previousItemLink.."(按住 |CFFFFFFFFAlt|R 键拖到装备栏强制穿戴)")
							KTR.waitToSwitchBack[thisSlot] = nil
						end
					end
				end
            end

			KTRFrame:RegisterEvent("UI_ERROR_MESSAGE")
			-- ERR_ITEM_COOLDOWN = "物品还没有准备好。"
			KTRFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		else
			if KTR.waitToSwitchBack[equipmentSlot] then
				KTR.waitToSwitchBack[equipmentSlot] = nil
			end
		end
	end
	if not KTR.waitToSwitchBack[INVSLOT_FINGER1] and not KTR.waitToSwitchBack[INVSLOT_FINGER2] then
		KTRFrame:UnregisterEvent("UI_ERROR_MESSAGE")
		KTRFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	end
	SavedPreviousEquipmentId()
end

function KTRFrameEvents:UNIT_SPELLCAST_SUCCEEDED(...)
	OnSpellCastSucceeded(...)
end

function KTRFrameEvents:UI_ERROR_MESSAGE(...)
	OnUIErrorMessage(...)
end

function KTRFrameEvents:PLAYER_EQUIPMENT_CHANGED(...)
	OnEquipmentChanged(...)
end

function KTRFrameEvents:PLAYER_ENTERING_WORLD(...)
	SavedPreviousEquipmentId()
	KTRFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

KTRFrame:SetScript("OnEvent", function(self, event, ...)
	KTRFrameEvents[event](self, ...); -- call one of the functions above
end);

for k, v in pairs(KTRFrameEvents) do
	KTRFrame:RegisterEvent(k); -- Register all KTRFrameEvents for which handlers have been defined
end








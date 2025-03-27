local _G = _G
local addonName, JTE = ...

JTE.TSB = {}
local TSB = JTE.TSB
local JTE_Print = JTE_Print or print
local TSBFrame, TSBFrameEvents = CreateFrame("Frame"), {};

--交换饰品重置内置ICD
TSB.TrinketsSwapping = false
TSB.TrinketsSwapWait = false
local SwapTrinkets = function()
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
		TSB.TrinketsSwapping = true
		TSB.TrinketsSwapWait = true
	end
end
JTE.SwapTrinkets = SwapTrinkets

local SwapTrinketsBack = function()
	if TSB.TrinketsSwapping and TSB.TrinketsSwapWait then
		TSB.TrinketsSwapWait = false
		--print("Wait TSB.TrinketsSwapping="..TSB.TrinketsSwapping)
		return
	elseif TSB.TrinketsSwapping and not TSB.TrinketsSwapWait then
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
		TSB.TrinketsSwapping = false
	end
end

local OnEquipmentChanged = function(equipmentSlot, hasCurrent)
	SwapTrinketsBack()
end

function TSBFrameEvents:PLAYER_EQUIPMENT_CHANGED(...)
	OnEquipmentChanged(...)
end

TSBFrame:SetScript("OnEvent", function(self, event, ...)
	TSBFrameEvents[event](self, ...); -- call one of the functions above
end);

for k, v in pairs(TSBFrameEvents) do
	TSBFrame:RegisterEvent(k); -- Register all TSBFrameEvents for which handlers have been defined
end








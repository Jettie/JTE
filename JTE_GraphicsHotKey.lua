local enable = false

local JTE_Print = JTE_Print or print

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
    if not enable then
        JTE_Print("|CFF8FFFA2Set GraphicsQuality is disabled.")
        return
    end
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
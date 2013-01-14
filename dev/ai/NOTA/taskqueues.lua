--[[
 Task Queues!
]]--

require "unitlists"

local DebugEnabled = false

local function EchoDebug(inStr)
	if DebugEnabled then
		game:SendToConsole(inStr)
	end
end


math.randomseed( os.time() + game:GetTeamID() )
math.random(); math.random(); math.random()

local needAA = false
local needAntinuke = false

local lastCheckFrame = 0

-- build ranges to check for things
local BaseBuildRange = 1500
local ExpansionBuildRange = 940

function CheckForDangers()
	-- don't check if both are already true
	if needAA and needAntinuke then
		return
	end
	-- don't check too soon after previous check
	if (lastCheckFrame + 30) < game:Frame() then
		local enemies = game:GetEnemies()
		for _, enemyUnit in pairs(enemies) do
			un = enemyUnit:Name()
			if not needAA then
				for _, ut in pairs(airFacList) do
					if un == ut then
						needAA = true
						EchoDebug("Spotted "..un.." enemy unit, now I need AA")
						break
					end
				end
			end
			if not needAntinuke then
				for _, ut in pairs(nukeList) do
					if un == ut then
						needAntinuke = true
						EchoDebug("Spotted "..un.." enemy unit, now I need antinukes!")
						break
					end
				end
			end
			if needAA or needAntinuke then
				break
			end
		end
		lastCheckFrame = game:Frame()
	end
end

function IsAANeeded()
	CheckForDangers()
	return needAA
end

function IsAntinukeNeeded()
	CheckForDangers()
	return needAntinuke
end

function BuildWindSolarIfNeeded()
	-- check if we need power
	res = game:GetResourceByName("Energy")
	if res.income < res.usage then
		retVal = CoreWindSolar
		EchoDebug("BuildWindSolarIfNeeded: income "..res.income..", usage "..res.usage..", building more energy")
	else
		retVal = DummyUnitName
	end

	return retVal
end

function BuildTidalIfNeeded()
	return BuildEnergyIfNeeded("cortide")
end

function BuildEnergyIfNeeded(unitName)
	res = game:GetResourceByName("Energy")
	if res.income < (1.2 * res.usage + 100) then
		EchoDebug("BuildEnergyIfNeeded: income "..res.income..", usage "..res.usage..", building more energy")
		return unitName
	else
		return DummyUnitName
	end
end

-- do something useful for the economy:
-- build energy or storage
function DoSomethingForTheEconomy(self)
	-- 1. check for low energy
	unitName = BuildWindSolarIfNeeded()
	-- 2. maybe we need storage?
	if unitName == DummyUnitName then
		resE = game:GetResourceByName("Energy")
		if resE.reserves >= 0.9 * resE.capacity then
			unitName = BuildWithLimitedNumber("corestor", 10)
		end
	end
	if unitName == DummyUnitName then
		resM = game:GetResourceByName("Metal")
		if resM.reserves >= 0.9 * resM.capacity then
			unitName = BuildWithLimitedNumber("cormstor", 10)
		end
	end

	return unitName
end

function BuildAAIfNeeded(unitName)
	if IsAANeeded() then
		return unitName
	else
		return DummyUnitName
	end
end

function CoreWindSolar()
	if map:AverageWind() > 15 then
		return "corwin"
	else
		return "corsolar"
	end
end

function BuildWithLimitedNumber(tmpUnitName, minNumber)
	ownUnits = game:GetFriendlies()
	unitCount = 0
	for _, u in pairs(ownUnits) do
		un = u:Name()
		if un == tmpUnitName then
			unitCount = unitCount + 1
		end
		if unitCount >= minNumber then
			break
		end
	end
	if unitCount >= minNumber then
		return DummyUnitName
	else
		return tmpUnitName
	end
end

function BuildWithMinimalMetalIncome(unitName, minNumber)
	res = game:GetResourceByName("Metal")
	if res.income < minNumber then
		return DummyUnitName
	else
		return unitName
	end
end

function BuildWithMinimalEnergyIncome(unitName, minNumber)
	res = game:GetResourceByName("Energy")
	if res.income - res.usage < minNumber then
		return DummyUnitName
	else
		return unitName
	end
end

function BuildWithExtraMetalIncome(unitName, minNumber)
	res = game:GetResourceByName("Metal")
	EchoDebug("BuildWithExtraMetalIncome: income "..res.income..", usage "..res.usage..", threshold "..minNumber)
	if res.income - res.usage < minNumber then
		return DummyUnitName
	else
		return unitName
	end
end

function BuildWithNoExtraMetal(unitName)
	res = game:GetResourceByName("Metal")
	if res.income - res.usage < 1 then
		return unitName
	else
		return DummyUnitName
	end
end

function CoreMetalMaker()
	-- check that we have energy surplus and not a metal surplus
	return BuildWithLimitedNumber(BuildWithMinimalEnergyIncome(BuildWithNoExtraMetal("cormakr"), 75), 10)
end

local function corLvl1Fac()
	local r = math.random(0, 1)
	if r == 0 then
		ret = "corlab"
	else
		ret = "corvp"
	end
	ret = BuildWithLimitedNumber(ret, 1)
	return ret
end

local function SolarIfNeeded()
	return BuildEnergyIfNeeded("corsolar")
end

-- If more energy needed:
-- build fusion if have enough metal income
-- if not, build a solar
local function SolarOrFusion()
	unitName = BuildWithMinimalMetalIncome(BuildEnergyIfNeeded("corfus"), 50)
	if unitName == DummyUnitName then
		unitName = BuildEnergyIfNeeded("corsolar")
	end
	return unitName
end

local function CorHLTIfNeeded()
	return BuildWithMinimalMetalIncome( "corhlt", 20)
end

local function CorLLTIfNeeded()
	return BuildWithMinimalMetalIncome( "corllt", 15)
end

local function CorFuryIfAffordable()
	return BuildWithExtraMetalIncome( "corfury", 5)
end

local function LightAAIfNeeded()
	return BuildAAIfNeeded("dca")
end

local function HeavyAAIfNeeded()
	return BuildAAIfNeeded("corflak")
end

local function LightAAIfNeeded4()
	return BuildWithLimitedNumber(BuildAAIfNeeded("dca"), 4)
end

local function HeavyAAIfNeeded4()
	return BuildWithLimitedNumber(BuildAAIfNeeded("corflak"), 4)
end

local function CorLabMinimum1()
	return BuildWithLimitedNumber("corlab", 1)
end

local function CorVPMinimum1()
	return BuildWithLimitedNumber("corvp", 1)
end

local function CorLabMinimum2WithIncomeCheck()
	return BuildWithLimitedNumber(BuildWithExtraMetalIncome("corlab", 10), 2)
end

local function CorVPMinimum2WithIncomeCheck()
	return BuildWithLimitedNumber(BuildWithExtraMetalIncome("corvp", 10), 2)
end

local function CorLvl1Fac_Extra()
	r = math.random(0, 1)
	if r == 0 then
		facName = "corvp"
	else
		facName = "corlab"
	end
	return BuildWithExtraMetalIncome(facName, 10)
end

local function CorLvl1Fac_Extra()
	r = math.random(0, 1)
	if r == 0 then
		facName = "corvp"
	else
		facName = "corlab"
	end
	facName = BuildWithLimitedNumber(facName, 2)
	return BuildWithExtraMetalIncome(facName, 10)
end

local function CorGeoIfNeeded()
	return BuildWithExtraMetalIncome(BuildEnergyIfNeeded("corgeo"), 5)
end

local function CorFusionIfNeeded()
	return BuildWithExtraMetalIncome(BuildEnergyIfNeeded("corfus"), 15)
end

local function CorExpansionMinimum3()
	return BuildWithLimitedNumber("corntow", 3)
end

local function CorAABot()
	return BuildAAIfNeeded("corcrash")
end

local function CorAAVeh()
	return BuildAAIfNeeded("corsent")
end

local function CorAdvBotTowerIfCanAfford()
	return BuildWithExtraMetalIncome(BuildWithLimitedNumber("cor2kbot", 1), 15)
end

local function CorAdvBotTowerIfHighIncome()
	return BuildWithMinimalMetalIncome(BuildWithLimitedNumber("cor2kbot", 1), 40)
end

local function CorLvl2TowerIfCanAfford()
	return BuildWithExtraMetalIncome(BuildWithLimitedNumber("corlvl2", 1), 30)
end

local function CorAdvBotLabMinimum1()
	return BuildWithLimitedNumber("coralab", 1)
end

local function CorAdvBotLab_Extra()
	return BuildWithExtraMetalIncome("coralab", 20)
end

local function CorConVehicle()
	return BuildWithLimitedNumber("corcv", ConUnitPerTypeLimit)
end

local function CorConBot()
	return BuildWithLimitedNumber("cornecro", ConUnitPerTypeLimit)
end

-- how many of our own unitName there are in a radius around a position
function CountOwnUnitsInRadius(unitName, pos, radius, maxCount)
	local ownUnits = game:GetFriendlies()
	local unitCount = 0
	for _, u in pairs(ownUnits) do
		if u:Name() == unitName then
			upos = u:GetPosition()
			if distance(pos, upos) < radius then
				unitCount = unitCount + 1
			end
			-- optimisation: if the limit is already exceeded, don't count further
			if unitCount >= maxCount then
				break
			end
		end
	end
	return unitCount
end

local function CheckAreaLimit(unitName, builder, unitLimit)
	-- this is special case, it means the unit will not be built anyway
	if unitName == DummyUnitName then
		return unitName
	end
	pos = builder:GetPosition()
	buildRange = buildRanges[builder:Name()] or ExpansionBuildRange
	-- now check how many of the wanted unit is nearby
	NumberOfUnits = CountOwnUnitsInRadius(unitName, pos, buildRange, unitLimit)
	AllowBuilding = NumberOfUnits < unitLimit
	EchoDebug(""..unitName.." wanted, with range limit of "..unitLimit..", with "..NumberOfUnits.." already there. The check is: "..tostring(AllowBuilding))
	if AllowBuilding then
		return unitName
	else
		return DummyUnitName
	end
end

function BuildAntinuke(self)
	if IsAntinukeNeeded() then
		unitName = BuildAAIfNeeded("corfmd")
		unit = self.unit:Internal()
		return CheckAreaLimit(unitName, unit, AntinukeAreaLimit)
	end
	return DummyUnitName
end

-- build AA in area only if there's not enough of it there already
local function AreaLimit_LightAA(self)
	unitName = BuildAAIfNeeded("dca")
	unit = self.unit:Internal()
	return CheckAreaLimit(unitName, unit, AreaAALimit)
end

local function AreaLimit_HeavyAA(self)
	unitName = BuildAAIfNeeded("corflak")
	-- our unit type and coords
	unit = self.unit:Internal()
	pos = unit:GetPosition()
	mult = 1
	buildRange = buildRanges[unit:Name()] or ExpansionBuildRange
	if buildRange > ExpansionBuildRange then
		mult = 1.5
	end
	return CheckAreaLimit(unitName, unit, AreaAALimit * mult)
end

local function AreaLimit_Radar(self)
	unitName = "corrad"
	unit = self.unit:Internal()
	return CheckAreaLimit(unitName, unit, 1)
end

local function AreaLimit_HLT(self)
	unitName = CorHLTIfNeeded()
	unit = self.unit:Internal()
	return CheckAreaLimit(unitName, unit, AreaAALimit)
end

local function AreaLimit_LLT(self)
	unitName = CorLLTIfNeeded()
	unit = self.unit:Internal()
	return CheckAreaLimit(unitName, unit, AreaAALimit)
end

local function AreaLimit_Expansion(self)
	unitName = "corntow"
	unit = self.unit:Internal()
	-- check that there aren't any of that under construction already
	-- under construction = GetMaxHealth() > GetHealth() (no better way currently)
	ownUnit = game:GetFriendlies()
	countUnderConstruction = 0
	for _, u in pairs(ownUnits) do
		if u:Name() == unitName then
			if u:GetHealth() < (0.9 * u:GetMaxHealth()) then
				countUnderConstruction = countUnderConstruction + 1
			end
		end
		if countUnderConstruction > 1 then
			break
		end
	end
	if countUnderConstruction > 1 then
		unitName = DummyUnitName
	end
	-- check that we have at least a bit of free metal to use on expansion
	unitName = BuildWithExtraMetalIncome(unitName, 1)
	return CheckAreaLimit(unitName, unit, 1)
end

local function CorMohoEngineer()
	return BuildWithLimitedNumber("corack", ConUnitPerTypeLimit)
end

local function corDebug()
	tmp = game:GetResources()
	for name, _ in pairs(tmp) do
		EchoDebug(name)
	end
	return ""
end

local corMainBuilding = {
	--corDebug,
	--SolarOrFusion,
	AreaLimit_HLT,
	AreaLimit_HeavyAA,
	AreaLimit_LightAA,
	"cormex",
	"cormex",
	"cormex",
	SolarOrFusion,
	SolarOrFusion,
	SolarOrFusion,
	SolarOrFusion,
	AreaLimit_LightAA,
	AreaLimit_LightAA,
	corLvl1Fac,
	SolarOrFusion,
	"cormex",
	"cormex",
	SolarOrFusion,
	"cormex",
	"cormex",
	SolarOrFusion,
	CorLabMinimum1,
	CorVPMinimum1,
	SolarOrFusion,
	SolarOrFusion,
	AreaLimit_Radar,
	"cormex",
	"cormex",
	CoreMetalMaker,
	CoreMetalMaker,
	CorLabMinimum2WithIncomeCheck,
	CorVPMinimum2WithIncomeCheck,
	{action = "cleanup", frames = 128},
	AreaLimit_HeavyAA,
	AreaLimit_HeavyAA,
	"cormex",
	"cormex",
	CorFusionIfNeeded,
	CorAdvBotTowerIfCanAfford,
	CorAdvBotTowerIfHighIncome,
	BuildAntinuke,
	DoSomethingForTheEconomy,
	{action = "cleanup", frames = 128},
	{action = "wait", frames = 30},
}

local corExpansionBase = {
	"cormex",
	"cormex",
	AreaLimit_LLT,
	AreaLimit_Radar,
	SolarIfNeeded,
	SolarIfNeeded,
	CorLvl1Fac_Extra,
	AreaLimit_LightAA,
	AreaLimit_HeavyAA,
	"cormex",
	"cormex",
	CoreMetalMaker,
	CorLvl2TowerIfCanAfford,
	BuildAntinuke,
	DoSomethingForTheEconomy,
	{action = "cleanup", frames = 128},
	{action = "wait", frames = 30},
}

local corAdvBotTower = {
	CorMohoEngineer,
	CorFusionIfNeeded,
	AreaLimit_HLT,
	CorAdvBotLabMinimum1,
	CorAdvBotLab_Extra,
	BuildAntinuke,
	DoSomethingForTheEconomy,
	CorMohoEngineer,
	{action = "wait", frames = 30},
}

local corConUnit = {
	"cormex",
	BuildWindSolarIfNeeded,
	"cormex",
	CorFuryIfAffordable,
	BuildWindSolarIfNeeded,
	"cormex",
	CorGeoIfNeeded,
	CorFuryIfAffordable,
	CorFuryIfAffordable,
	LightAAIfNeeded,
	"cormex",
	BuildWindSolarIfNeeded,
	AreaLimit_Expansion,
}

taskqueues = {
	corcom = corMainBuilding,
	corntow = corExpansionBase,
	cor2kbot = corAdvBotTower,
	corlvl2 = corAdvBotTower,
	corbase = corMainBuilding,
	cornecro = corConUnit,
	corcv = corConUnit,
	corch = corConUnit,
	corca = corConUnit,
	corlab = {
		CorConBot,
		"corak",
		"corstorm",
		"corstorm",
		CorAABot,
		"corthud",
		"corthud",
		"corthud",
		"corthud",
		CorConBot,
		"sprint",
		"sprint",
		"corak",
		"corak",
		"corak",
		"corak",
		"corthud",
		"corthud",
		"corstorm",
		"corstorm",
		CorAABot,
		"corthud",
		"corthud",
		"corthud",
		"corthud",
		"sprint",
		"sprint",
		--"corpyro",
		--"corpyro",
		--"corpyro",
		--"corpyro",
	},
	corvp = {
		CorConVehicle,
		"corraid",
		"corgator",
		"corgator",
		"corraid",
		"corraid",
		"corraid",
		"corraid",
		"cormart",
		--"corfav",
		--"corfav",
		CorAAVeh,
		"corlevlr",
		--"correap",
		--"correap",
		CorConVehicle,
		"corgator",
		"corgator",
		--"corfav",
		--"corfav",
		--"correap",
		CorAAVeh,
	},
	coralab = {
		"corcan",
		"corsumo",
		"corcrabe",
		"corcrabe",
		"corcrabe",
	},
}

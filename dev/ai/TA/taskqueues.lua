--[[
Task Queues!
]]--

-- this unit is not buildable, but valid, so it's used when we need to tell the AI to NOT build what it wants
DummyUnitName = "armcom"

local DebugEnabled = false

local function EchoDebug(inStr)
	if DebugEnabled then
		game:SendToConsole(inStr)
	end
end

math.randomseed( os.time() + game:GetTeamID() )
math.random(); math.random(); math.random()

local lastCheckFrame = 0
local hasRC = ""


function BuildWindSolarIfNeeded()
	-- check if we need power
	res = game:GetResourceByName("Energy")
	if res.income < res.usage then
		retVal = ArmWindSolar
		EchoDebug("BuildWindSolarIfNeeded: income "..res.income..", usage "..res.usage..", building more energy")
	else
		retVal = DummyUnitName
	end

	return retVal
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
			unitName = BuildWithLimitedNumber("armestor", 10)
		end
	end
	if unitName == DummyUnitName then
		resM = game:GetResourceByName("Metal")
		if resM.reserves >= 0.9 * resM.capacity then
			unitName = BuildWithLimitedNumber("armmstor", 10)
		end
	end

	return unitName
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

function BuildIfAlreadyOwn(UnitName,RCname)
	hasRC = DummyUnitName
	ownUnits = game:GetFriendlies()
	for _, u in pairs(ownUnits) do
		un = u:Name()
			if un == RCname and un:IsBeingBuilt() then
			hasRC = UnitName
			break
			end
	end
	return hasRC
end

function BuildIfDontAlreadyOwn(UnitName,RCname)
	hasRC = UnitName
	ownUnits = game:GetFriendlies()
	for _, u in pairs(ownUnits) do
		un = u:Name()
			if un == RCname then
			hasRC = DummyUnitName
			break
			end
	end
	return hasRC
end

function RandomBuild(Unitone,Unittwo)
	local r = math.random(0,1)
	if r == 0 then
		return Unitone
	else
		return Unittwo
	end
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

function ArmWindSolar()
	if map:AverageWind() > 15 then
		return "armwin"
	else
		return "armsolar"
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

function ArmMetalMaker()
	-- check that we have energy surplus and not a metal surplus
	return BuildWithLimitedNumber(BuildWithMinimalEnergyIncome("armmakr", 75), 10)
end

local function SolarIfNeeded()
	return BuildEnergyIfNeeded("armsolar")
end

local function Buildonly1RC()
	return BuildWithLimitedNumber("armrech3", 1)
end

local function BuildAdvUnitAexxec()
	return BuildIfAlreadyOwn("aexxec","armrech3")
end

local function BuildAdvPw()
	return BuildIfAlreadyOwn("armpw1","armrech3")
end

local function BuildBasicDefense()
	return BuildWithExtraMetalIncome("armllt",5)
end

local function BuildBasicAADefense()
	return BuildWithExtraMetalIncome("armrl",5)
end

local function BuildAdvArmcrack()
	return BuildIfAlreadyOwn("armcrack","armrech3")
end

local function BuildBasicPw()
	return BuildIfDontAlreadyOwn("armpw","armrech3")
end

local function BuildRandomPwOrArmham()
	return RandomBuild("armpw","armham")
end

taskqueues = {
-- arm units
	armcom = { -- commander
		"armmex",
		ArmWindSolar,
		ArmWindSolar,
		"armmex",
		ArmWindSolar,
		--armlab",
		(function()
			local r = math.random(0,5)
			if r < 2 then
				return "armlab"
			elseif r > 2 and r < 4 then
				return "armlab"
			else
				return "armlab"
			end
		end),
		"armmex",
		ArmWindSolar,
		"armllt",
		"armrad",
		"armmex",
		BuildBasicAADefense,
		"armmex",
		ArmWindSolar,
		ArmMetalMaker,
		"armmex",
		"armmex",
		ArmWindSolar,
		DoSomethingForTheEconomy,
		"armmex",
		ArmWindSolar,
		ArmMetalMaker,
		ArmMetalMaker,
		"armmex",
		BuildBasicDefense,
		"armmex",
		BuildBasicDefense,
		"armrad",
		DoSomethingForTheEconomy,
		ArmWindSolar,
		ArmWindSolar,
		ArmWindSolar,
		ArmMetalMaker,
		ArmMetalMaker,
		ArmMetalMaker,

	},
	armvp = {
		  "armcv",
	},
	armap = {
		  "armca",
	},     
	armlab = { -- arm kbot lab
		    BuildAdvArmcrack,
		--"armrectr",
		"armflea",
		"armflea",
		"armflea",
		"armflea",
		"armck",
		"armck",
		BuildRandomPwOrArmham,
		BuildRandomPwOrArmham,
		--"armrectr",
		--"armrectr",
		BuildBasicPw,
		BuildBasicPw,
		"armwar",
		"armrock",
		BuildBasicPw,
		BuildBasicPw,
		BuildBasicPw,
		BuildBasicPw,
		BuildBasicPw,
		BuildBasicPw,
		BuildBasicPw,
		--"armrectr",
		--"armrectr",
		BuildBasicPw,
		BuildBasicPw,
		--BuildAdvUnitAexxec, testing
		BuildBasicPw,
		BuildBasicPw,
		"armham",
		"armham",
		"armham",
		BuildBasicPw,
		BuildBasicPw,
		"armrock",
		"armrock",
		"armrock",
		BuildBasicPw,
		BuildBasicPw,
		BuildBasicPw,
		BuildBasicPw,
		"armham",
		"armham",
		"armham",
		"armjeth",
		"armjeth",
		"armrock",
		"armrock",
		"armrock",
		--BuildAdvUnitAexxec,
		BuildAdvPw,
		BuildAdvPw,
		BuildAdvPw,
		BuildAdvPw,
		BuildAdvArmcrack,
		BuildAdvArmcrack,
		BuildAdvArmcrack,
		BuildAdvPw,
		BuildAdvPw,
		BuildAdvPw,
		BuildAdvPw,
		BuildAdvArmcrack,
		BuildAdvArmcrack,
		BuildAdvArmcrack,
		BuildAdvPw,
		BuildAdvPw,
		BuildAdvPw,
		BuildAdvPw,
		BuildAdvArmcrack,
		BuildAdvArmcrack,
		BuildAdvArmcrack,
		BuildAdvPw,
		BuildAdvPw,
		BuildAdvPw,
		BuildAdvPw,
		BuildAdvArmcrack,
		BuildAdvArmcrack,
		BuildAdvArmcrack,
	},
	armck = { -- arm construction kbot
		Buildonly1RC,
		ArmWindSolar,
		"armmex",
		BuildBasicDefense,
		BuildBasicAADefense,
		ArmWindSolar,
		ArmMetalMaker,
		"armmex",
		"tawf001",
		"armmex",
		--"armllt",
		"armrad",
		ArmWindSolar,
		ArmWindSolar,
		Buildonly1RC,
		ArmWindSolar,
		ArmWindSolar,
		ArmMetalMaker,
		ArmMetalMaker,
		"armmex",
		"armmex",
		BuildBasicDefense,
		BuildBasicAADefense,

		"tawf001",
		--"armnanotc", -- nano tower TODO: when build, set to patrol
		"armrad",
		"armadvsol", -- advanced solar
		"armadvsol", -- advanced solar
		"armhlt",
		"armadvsol", -- advanced solar
		"armalab", -- advanced kbot lab
		--"armnanotc", -- nano tower
		--"armnanotc",  -- nano tower
		"armadvsol", -- advanced solar
		"tawf001",
	},
	armcv = { -- arm construction kbot
		ArmWindSolar,
		"armmex",
		"armllt",
		"armrl",
		ArmWindSolar,
		"armmex",
		"tawf001",
		"armmex",
		"armllt",
		"armrad",
		ArmWindSolar,
		ArmWindSolar,
		ArmWindSolar,
		ArmWindSolar,
		--"armrech3",
		ArmWindSolar,
		"armmex",
		"armmex",
		"armllt",
		"armhlt",
		--"armnanotc", -- nano tower TODO: when build, set to patrol
		"armrad",
		"armadvsol", -- advanced solar
		"armadvsol", -- advanced solar
		"armhlt",
		"armadvsol", -- advanced solar
		"armalab", -- advanced kbot lab
		--"armnanotc", -- nano tower
		--"armnanotc",  -- nano tower
		"armadvsol", -- advanced solar
		"tawf001",
	},
	armca = { -- arm construction kbot
		ArmWindSolar,
		"armmex",
		"armllt",
		"armrl",
		ArmWindSolar,
		"armmex",
		"tawf001",
		"armmex",
		"armllt",
		"armrad",
		ArmWindSolar,
		ArmWindSolar,
		ArmWindSolar,
		ArmWindSolar,
		--"armrech3",
		ArmWindSolar,
		"armmex",
		"armmex",
		"armllt",
		"armhlt",
		--"armnanotc", -- nano tower TODO: when build, set to patrol
		"armrad",
		"armadvsol", -- advanced solar
		"armadvsol", -- advanced solar
		"armhlt",
		"armadvsol", -- advanced solar
		"armalab", -- advanced kbot lab
		--"armnanotc", -- nano tower
		--"armnanotc",  -- nano tower
		"armadvsol", -- advanced solar
		"tawf001",
	},
	armalab = { -- advanced kbot lab
		"armack", -- advanced construction kbot
		"armzeus",
		"armzeus",
		"armzeus",
		"armsnipe", --sniper
		"armaak", -- anti air
		"armmark", -- radar
		"armaser", -- radar jammer
		"armaak", -- anti air
		"armzeus",
		"armzeus",
		"armzeus",
		"armaak", -- anti air
		"armfboy", -- heavy plasma kbot
		"armfast",
		"armfast",
		"armfast",
		"armfast",
		"armfast",
	},
	armack = { -- advanced construction kbot
		"armfus", -- fusion reactor
		"armmmkr", -- moho energy converter
		"armmmkr", -- moho energy converter
	},
-- core units
	corcom = {
		"corsolar",
		"cormex",
		"corsolar",
		"corllt",
		"cormex",
		"cormex",
		--"corlab",
		(function()
			local r = math.random(0,5)
			if r < 2 then
				return "corlab"
			elseif r > 2 and r < 5 then
				return "corvp"
			else
				return "corap"
			end
		end),
		"corsolar",
		"corllt",
		"corrad",
		"corsolar",
		"corllt",
		"corsolar",
		"cormakr",
		"corsolar",
		"cormex",
		"corllt",
		"cormex",
		"corsolar",
		"cormakr",
		"corllt",
		"cornanotc",
		"corsolar",
	},
	corck = {
		"corsolar",
		"cormex",
		"cormex",
		"corllt",
		"corrad",
		"corllt",
		"corsolar",
		"corllt",
		"corsolar",
		"cormex",
		"corhlt",
		"corech3",
		"cornanotc",
		"corllt",
	},

	corca = {
		"corsolar",
		"cormex",
		"corsolar",
		"cormex",
		"cormex",
		"corllt",
		"corrad",
		"corllt",
		"corsolar",
		"corsolar",
		"corllt",
		"corsolar",
		"cormex",
		"corhlt",
		"cornanotc",
		"corllt",
		"corsolar",
	},

	corcv = {
		"corsolar",
		"cormex",
		"corsolar",
		"cormex",
		"cormex",
		"corllt",
		"corrad",
		"corllt",
		"corsolar",
		"corsolar",
		"corllt",
		"corsolar",
		"cormex",
		"corhlt",
		"cornanotc",
		"corllt",
		"corsolar",
	},

	cormlv = {
		"cormine1",
		"cormine1",
		"cormine1",
		"cormine1",
		"cormine2",
		"cormine3",
	},
	corlab = {
		"corck",
		"corck",
		"corak",
		"corak",
		"corak",
		"corak",
		"corck",
		"corak",
		"corck",
		"corthud",
		"corthud",
		"corthud",
	},
	corvp = {
		"corcv",
		"cormlv",
		"corgator",
		"corgator",
		"corgator",
		"corraid",
		"corcv",
		"corraid",
		"corraid",
		"corgator",
		"corraid",
		"corraid",
		"corcv",
		"corcv",
		"corraid",
		"corgator",
		"corgator",
		"corgator",
		"corraid",
		"corraid",
	},
	corap = {
		"corca",
		"corveng",
		"corveng",
		"bladew",
		"bladew",
		"corca",
		"bladew",
		"bladew",
		"corca",
		"corveng",
		"corveng",
		"corshad",
		"corshad",
		"corshad",
	},
}

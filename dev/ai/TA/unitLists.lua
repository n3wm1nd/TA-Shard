--[[
-- list of construction projects which should NOT be paused due to low resources

-- these will not be delayed when low on resources
-- NOT IMPLEMENTED YET, need to be able to give Wait orders
priorityBuildList = {
	"cormex",
	"corsolar",
	"corwin",
	"cormoho",
	"corfusion",
	"corgeo",
}

-- if any of these is found among enemy units, AA units will be built
 = {
	"armap",
	"armaap",
	"corap",
	"coraap",
	"corvalkfac",
	"armplat",
	"corplat",
}

-- if any of these is found among enemy units, antinukes will be built
nukeList = {
	"armsilo",
	"corsilo",
	"armemp",
	"cortron",
}	

-- these units will be used to raid weakly defended spots
-- this is different from attacking in that raiders use Move, not MoveAndFire (and so will not delay to fight occasional enemy units encountered on the way)
raiderList = {
	"corfav",
	"armfav",
	"armflea",
	"armfast",
	"sprint",
	"corgator",
	"armflash",
}

-- build ranges for stationary constructors
-- for use until a way to get those automatically is provided
buildRanges = {
	corbase = 1500,
	armbase = 1500,
	corntow = 940,
	armntow = 940,
	corlvl2 = 1050,
	armlvl2 = 1050,
	cor2air = 950,
	arm2air = 950,
	cor2veh = 950,
	arm2veh = 950,
	cor2kbot = 950,
	arm2kbot = 950,
	cor2def = 950,
	arm2def = 950,
}

-- limits for how many AA there should be in an area
AreaAALimit = 4
AntinukeAreaLimit = 1

-- how many mobile con units of one type is allowed
ConUnitPerTypeLimit = 4
]]--
-- this unit is not buildable, but valid, so it's used when we need to tell the AI to NOT build what it wants
DummyUnitName = "armcom"

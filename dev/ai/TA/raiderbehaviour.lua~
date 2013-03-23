require "unitlists"

function IsRaider(unit)
	for i,name in ipairs(raiderList) do
		if name == unit:Internal():Name() then
			return true
		end
	end
	return false
end

RaiderBehaviour = class(Behaviour)

function RaiderBehaviour:Init()
	--game:SendToConsole("Raider!")
end

function RaiderBehaviour:UnitBuilt(unit)
	if unit.engineID == self.unit.engineID then
		self.Raiding = false
		ai.raidhandler:AddRecruit(self)
	end
end


function RaiderBehaviour:UnitDead(unit)
	if unit.engineID == self.unit.engineID then
		ai.raidhandler:RemoveRecruit(self)
	end
end

function RaiderBehaviour:UnitIdle(unit)
	if unit.engineID == self.unit.engineID then
		self.Raiding = false
		ai.raidhandler:AddRecruit(self)
	end
end

function RaiderBehaviour:RaidCell(cell)
	p = api.Position()
	p.x = cell.posx
	p.z = cell.posz
	p.y = 0
	self.target = p
	self.Raiding = true
	if self.active then
		self.unit:Internal():Move(self.target)
	else
		self.unit:ElectBehaviour()
	end
end

function RaiderBehaviour:Priority()
	if not self.Raiding then
		return 0
	else
		return 100
	end
end

function RaiderBehaviour:Activate()
	self.active = true
	if self.target then
		self.unit:Internal():MoveAndFire(self.target)
		self.target = nil
	else
		ai.raidhandler:AddRecruit(self)
	end
end

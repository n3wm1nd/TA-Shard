local DebugEnabled = 1

local function EchoDebug(inStr)
	if DebugEnabled then
		game:SendToConsole(inStr)
	end
end

RunFromAttackBehaviour = class(Behaviour)

function RunFromAttackBehaviour:Init()
	self.active = false
	self.underfire = false
	-- this is where we will retreat
	self.initialLocation = self.unit:Internal():GetPosition()
	EchoDebug("RunFromAttackBehaviour: added to unit "..self.unit:Internal():Name())
end

function RunFromAttackBehaviour:UnitCreated(unit)
end

function RunFromAttackBehaviour:UnitIdle(unit)
	if unit:Internal():ID() == self.unit:Internal():ID() then
		if self:IsActive() then
			self.unit:ElectBehaviour()
		end
	end
end

function RunFromAttackBehaviour:Update()
end

function RunFromAttackBehaviour:Activate()
	EchoDebug("RunFromAttackBehaviour: active on unit "..self.unit:Internal():Name())
	self.underfire = false

	-- can we move at all?
	if self.unit:Internal():CanMove() then
		-- try to find a friendly base and run there
		ownUnits = game:GetFriendlies()
		s = false

		utype = self.unit:Internal():Type()
		for _, u in pairs(ownUnits) do
			if (u:Name() == "corbase") or (u:Name() == "armbase") then
				destination = u:GetPosition()
				EchoDebug("RunFromAttackBehaviour: found a base at x:"..destination.x.."; y:"..destination.y)
				-- try to find a free spot for our unit there
				p = map:FindClosestBuildSite(utype, destination, 500, 2)
				EchoDebug("RunFromAttackBehaviour: found a free spot at x:"..p.x.."; y:"..p.y)
				s = self.unit:Internal():Move(p)
				--s = self.unit:Internal():Move(destination)
				break
			end
		end
		
		if s then
			self.active = true
			EchoDebug("RunFromAttackBehaviour: unit "..self.unit:Internal():Name().." runs away from danger")
		else
			EchoDebug("RunFromAttackBehaviour: unit "..self.unit:Internal():Name().." failed to run away from danger")
			self.unit:ElectBehaviour()
		end
	end
end

function RunFromAttackBehaviour:Deactivate()
	self.active = false
	self.underfire = false
end

function RunFromAttackBehaviour:Priority()
	if self.underfire == true  then
		return 110
	end
	return 0
end

function RunFromAttackBehaviour:UnitDead(unit)
end

function RunFromAttackBehaviour:UnitDamaged(unit,attacker)
	if unit:Internal():ID() == self.unit:Internal():ID() then
		if not self:IsActive() then
			self.underfire = true
			self.unit:ElectBehaviour()
		end
	end
end


local DebugEnabled = false

local function EchoDebug(inStr)
	if DebugEnabled then
		game:SendToConsole(inStr)
	end
end

MexUpgradeBehaviour = class(Behaviour)

function MexUpgradeBehaviour:Init()
	self.active = false
	self.mohoStarted = false
	self.mexPos = nil
	self.lastFrame = game:Frame()
	EchoDebug("MexUpgradeBehaviour: added to unit "..self.unit:Internal():Name())
end

function MexUpgradeBehaviour:UnitCreated(unit)
end

function MexUpgradeBehaviour:UnitIdle(unit)
	if unit:Internal():ID() == self.unit:Internal():ID() then
		if self:IsActive() then
			EchoDebug("MexUpgradeBehaviour: unit "..self.unit:Internal():Name().." is idle")
			-- maybe we've just finished a moho?
			if self.mohoStarted then
				self.mohoStarted = false
				self.mexPos = nil
			end
			-- maybe we've just finished reclaiming?
			if self.mexPos ~= nil and not self.mohoStarted then
				-- maybe we're ARM and not CORE?
				mohoName = "cormoho"
				tmpType = game:GetTypeByName("armmoho")
				if self.unit:Internal():CanBuild(tmpType) then
					mohoName = "armmoho"
				end
				s = self.unit:Internal():Build(mohoName, self.mexPos)
				if s then
					self.mohoStarted = true
					self.mexPos = nil
					EchoDebug("MexUpgradeBehaviour: unit "..self.unit:Internal():Name().." starts building a Moho")
				else
					self.mexPos = nil
					self.mohoStarted = false
					EchoDebug("MexUpgradeBehaviour: unit "..self.unit:Internal():Name().." failed to start building a Moho")
				end
			end

			if not self.mohoStarted and (self.mexPos == nil) then
				EchoDebug("MexUpgradeBehaviour: unit "..self.unit:Internal():Name().." restarts mex upgrade routine")
				StartUpgradeProcess(self)
			end
		end
	end
end

function MexUpgradeBehaviour:Update()
	if not self.active then
		if (self.lastFrame or 0) + 30 < game:Frame() then
			StartUpgradeProcess(self)
		end
	end
end

function MexUpgradeBehaviour:Activate()
	EchoDebug("MexUpgradeBehaviour: active on unit "..self.unit:Internal():Name())
	
	StartUpgradeProcess(self)
end

function MexUpgradeBehaviour:Deactivate()
	self.active = false
	self.mexPos = nil
	self.mohoStarted = false
end

function MexUpgradeBehaviour:Priority()
	return 101
end

function MexUpgradeBehaviour:UnitDead(unit)
end

function MexUpgradeBehaviour:UnitDamaged(unit,attacker)
end

function StartUpgradeProcess(self)
	-- try to find nearest mex
	local ownUnits = game:GetFriendlies()
	local enemyUnits = game:GetEnemies()
	local tooClose = 1000
	selfPos = self.unit:Internal():GetPosition()
	mexUnit = nil
	closestDistance = 999999
	
	for _, unit in pairs(ownUnits) do
		if (unit:Name() == "cormex") or (unit:Name() == "armmex") then
			distMod = 0
			-- if it's not 100% HP, then don't touch it (unless there's REALLY no better choice)
			-- this prevents a situation when engineer reclaims a mex that is still being built by someone else
			if unit:GetHealth() < unit:GetMaxHealth() then
				distMod = 5000
			end
			-- if there are enemies nearby, don't go there as well
			for _, enemyUnit in pairs(enemyUnits) do
				-- only check for armed units, we don't fear mexes
				if enemyUnit:WeaponCount() > 0 then
					enemyPos = enemyUnit:GetPosition()
					if distance(selfPos, enemyPos) < tooClose then
						distMod = distMod + 500
					end
				end
				-- if already worse then some other distance, abort
				if distMod > closestDistance then
					break
				end
			end

			pos = unit:GetPosition()
			dist = distance(pos, selfPos) + distMod
			if dist < closestDistance then
				mexUnit = unit
				closestDistance = dist
			end
		end
	end

	s = false
	if mexUnit ~= nil then
		-- command the engineer to reclaim the mex
		s = self.unit:Internal():Reclaim(mexUnit)
		if s then
			-- we'll build the moho here
			self.mexPos = mexUnit:GetPosition()
		end
	end
	
	if s then
		self.active = true
		EchoDebug("MexUpgradeBehaviour: unit "..self.unit:Internal():Name().." goes to reclaim a mex")
	else
		mexUnit = nil
		self.active = false
		self.lastFrame = game:Frame()
		EchoDebug("MexUpgradeBehaviour: unit "..self.unit:Internal():Name().." failed to start reclaiming")
	end
end
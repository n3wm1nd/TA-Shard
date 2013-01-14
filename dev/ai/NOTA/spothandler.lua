require "unitlists"

MetalSpotHandler = class(Module)


function MetalSpotHandler:Name()
	return "MetalSpotHandler"
end

function MetalSpotHandler:internalName()
	return "metalspothandler"
end

function MetalSpotHandler:Init()
	self.spots = game.map:GetMetalSpots()
end

function distance(pos1,pos2)
	local xd = pos1.x-pos2.x
	local yd = pos1.z-pos2.z
	dist = math.sqrt(xd*xd + yd*yd)
	return dist
end

function MetalSpotHandler:ClosestFreeSpot(unittype,position)
	local pos = nil
	local bestDistance = 10000

 	-- check for armed enemy units nearby
	local enemyUnits = game:GetEnemies()
	local tooClose = 1000
	spotCount = game.map:SpotCount()
	for i,v in ipairs(self.spots) do
		local p = v
		local dist = distance(position,p)
		-- now check how many enemy units there are nearby
		-- modify distance for every enemy unit found
		local enemyCount = 0
		for _, enemyUnit in pairs(enemyUnits) do
			-- only check for armed units, we don't fear mexes
			if enemyUnit:WeaponCount() > 0 then
				enemyPos = enemyUnit:GetPosition()
				if distance(p, enemyPos) < tooClose then
					dist = dist + tooClose
				end
			end
			-- if already worse then some other distance, abort
			if dist > bestDistance then
				break
			end
		end
		if dist < bestDistance then
			if game.map:CanBuildHere(unittype,p) then
				bestDistance = dist
				pos = p
			end
		end
	end
	return pos
end

function MetalSpotHandler:ClosestFreeSpotImmobileBuilder(builder, unittype, position)
	local pos = nil
	local bestDistance = 10000

	-- now check how far our immobile builder can build
	unitName = builder:Name()
	bestDistance = buildRanges[unitName] or 940
	spotCount = game.map:SpotCount()
	for i,v in ipairs(self.spots) do
		local p = v
		local dist = distance(position, p)
		if dist < bestDistance then
			if game.map:CanBuildHere(unittype,p) then
				bestDistance = dist
				pos = p
			end
		end
	end
	return pos
end

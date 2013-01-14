local function round(num) 
	if num >= 0 then
		return math.floor(num+.5) 
	else
		return math.ceil(num-.5)
	end
end

RaidHandler = class(Module)

function RaidHandler:Name()
	return "RaidHandler"
end

function RaidHandler:internalName()
	return "raidhandler"
end

function RaidHandler:Init()
	self.recruits = {}
	self.counter = 2
end

function RaidHandler:Update()
	local f = game:Frame()
	if math.mod(f, 9) == 0 then
		self:DoTargetting()
	end
end

function RaidHandler:GameEnd()
	--
end

function RaidHandler:UnitCreated(engineunit)
	--
end

function RaidHandler:UnitBuilt(engineunit)
	--
end

function RaidHandler:UnitDead(engineunit)
	if engineunit:Team() == game:GetTeamID() then
		self.counter = self.counter - 0.05
		self.counter = math.max(self.counter, 1)
	end
end


function RaidHandler:UnitIdle(engineunit)
	--
end

function RaidHandler:DoTargetting()
	if #self.recruits > self.counter then
		-- this defines cell size. Greater size = lower grid resolution, size should be larger than attack range of most common units (so raiders get in danger less often)
		local cellSize = 600
		-- find somewhere to Raid
		local cells = {}
		local celllist = {}
		local mapdimensions = game.map:MapDimensions()
		--enemies = game:GetEnemies()
		local enemies = game:GetEnemies()

		if #enemies > 0 then
			-- figure out where all the enemies are!
			-- count armed units separately
			for i=1,#enemies do
				local e = enemies[i]

				if e ~= nil then
					pos = e:GetPosition()
					px = pos.x - math.fmod(pos.x, cellSize)
					pz = pos.z - math.fmod(pos.z, cellSize)
					px = round(px / cellSize)
					pz = round(pz / cellSize)
					if cells[px] == nil then
						cells[px] = {}
					end
					if cells[px][pz] == nil then
						local newcell = {count = 0, countArmed = 0, posx = 0, posz=0, x = px, z = pz}
						cells[px][pz] = newcell
						table.insert(celllist,newcell)
					end
					cell = cells[px][pz]
					cell.count = cell.count + 1
					if e:WeaponCount() > 0 then
						cell.countArmed = cell.countArmed + 1
					end
					
					-- we dont want to target the center of the cell encase its a ledge with nothing
					-- on it etc so target this units position instead
					cell.posx = pos.x
					cell.posz = pos.z
				end

			end
			
			local bestCell = nil
			-- now find the smallest nonvacant cell to go lynch!
			bestArmedCount = 99999
			for i=1,#celllist do
				local cell = celllist[i]
				if bestCell == nil then
					bestCell = cell
				else
					-- count armed units in cell itself, and also in neighbouring cells
					local tmpArmedCount = 0
					x = cell.x
					z = cell.z
					for ix = -1, 1 do
						for iz = -1, 1 do
							tmpx = x + ix
							tmpz = z + iz
							tcellsx = cells[tmpx]
							if tcellsx ~= nil then
								tcellsxz = tcellsx[tmpz]
								if tcellsxz ~= nil then
									tmpArmedCount = tmpArmedCount + cells[tmpx][tmpz].countArmed
								end
							end
						end
					end
					if tmpArmedCount < bestArmedCount then
						bestCell = cell
						bestArmedCount = tmpArmedCount
					end
				end
			end
			
			-- if we have a cell then lets go Raid it!
			if bestCell ~= nil then
				for i,recruit in ipairs(self.recruits) do
					recruit:RaidCell(bestCell)
				end
				
				self.counter = self.counter + 0.05
				
				-- remove all our recruits!
				self.recruits = {}
			end
		end
		
		-- cleanup
		cellist = nil
		cells = nil
		mapdimensions = nil
		
	end
end

function RaidHandler:IsRecruit(attkbehaviour)
	for i,v in ipairs(self.recruits) do
		if v == attkbehaviour then
			return true
		end
	end
	return false
end

function RaidHandler:AddRecruit(attkbehaviour)
	if not self:IsRecruit(attkbehaviour) then
		table.insert(self.recruits,attkbehaviour)
	end
end

function RaidHandler:RemoveRecruit(attkbehaviour)
	for i,v in ipairs(self.recruits) do
		if v == attkbehaviour then
			table.remove(self.recruits,i)
			return true
		end
	end
	return false
end

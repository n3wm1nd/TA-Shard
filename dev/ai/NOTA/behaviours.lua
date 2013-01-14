require "taskqueues"
require "taskqueuebehaviour"
require "attackerbehaviour"
require "raiderbehaviour"
require "autoreclaimbehaviour"
require "runfromattack"
require "mexupgradebehaviour"

behaviours = {
	corbase = {
		TaskQueueBehaviour,
	},
	corlab = {
		TaskQueueBehaviour,
	},
	corvp = {
		TaskQueueBehaviour,
	},
	corcv = {
		TaskQueueBehaviour,
		--RunFromAttackBehaviour,
	},
	cornecro = {
		TaskQueueBehaviour,
		--RunFromAttackBehaviour,
	},
	corack = {
		MexUpgradeBehaviour,
		--RunFromAttackBehaviour,
	},
}

function defaultBehaviours(unit)
	b = {}
	
	u = unit:Internal()
	if u:CanBuild() then
		-- moho engineer doesn't need the queue!
		if u:Name() ~= "corack" then
			table.insert(b,TaskQueueBehaviour)
		end
		if u:CanMove() then
			local utype = game:GetTypeByName("cormex")
			if u:CanBuild(utype) then
				--table.insert(b, RunFromAttackBehaviour)
			end
		end
	else
		if IsAttacker(unit) then
			table.insert(b, AttackerBehaviour)
		end
		if IsRaider(unit) then
			table.insert(b, RaiderBehaviour)
		end
	end
	
	return b
end

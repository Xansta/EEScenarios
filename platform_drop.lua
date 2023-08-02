--- Script for platform drop.
--
-- @script platform_drop

function init()
	my_ship = CpuShip():setTemplate("Flavia"):setCommsScript(""):setCommsFunction(commsPlatformDrop):setFactionId(faction_id):setPosition(freighter_x, freighter_y):setTemplate("Flavia"):setScanned(true):orderFlyTowardsBlind(target_x, target_y)
	my_ship:setJumpDrive(true):setJumpDriveRange(5000,25000):setJumpDriveCharge(20000)
	state = 0
end
function commsPlatformDrop()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	if comms_source:isFriendly(comms_target) then
		return friendlyPlatformComms(comms_target.comms_data)
	end
	if comms_source:isEnemy(comms_target) then
		return false
	end
	return neutralPlatformComms(comms_target.comms_data)
end
function neutralPlatformComms(comms_data)
	if comms_data.friendlyness < 20 then
		setCommsMessage("We have nothing for you")
		return false
	else
		setCommsMessage("What do you want?");
	end
	addCommsReply("What is your cargo and destination?",function()
		local target_x, target_y = comms_target:getOrderTargetLocation()
		local va = VisualAsteroid():setSize(10):setPosition(target_x,target_y)
		local sector_name = va:getSectorName()
		va:destroy()
		setCommsMessage(string.format("We are carrying specialized equipment to sector %s",sector_name))
		addCommsReply("Back",commsPlatformDrop)
	end)
end
function friendlyPlatformComms(comms_data)
	if comms_data.friendlyness < 20 then
		setCommsMessage("What do you want?");
	else
		setCommsMessage("Sir, how can we assist?");
	end
	addCommsReply("What is your cargo and destination?",function()
		local target_x, target_y = comms_target:getOrderTargetLocation()
		local va = VisualAsteroid():setSize(10):setPosition(target_x,target_y)
		local sector_name = va:getSectorName()
		va:destroy()
		setCommsMessage(string.format("We are carrying a defense platform to sector %s as requested",sector_name))
		addCommsReply("Back",commsPlatformDrop)
	end)
	addCommsReply("Report status", function()
		msg = "Hull: " .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
		local shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = msg .. "Shield: " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
		elseif shields == 2 then
			msg = msg .. "Front Shield: " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			msg = msg .. "Rear Shield: " .. math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100) .. "%\n"
		else
			for n=0,shields-1 do
				msg = msg .. "Shield " .. n .. ": " .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
			end
		end
		local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for i, missile_type in ipairs(missile_types) do
			if comms_target:getWeaponStorageMax(missile_type) > 0 then
					msg = msg .. missile_type .. " Missiles: " .. math.floor(comms_target:getWeaponStorage(missile_type)) .. "/" .. math.floor(comms_target:getWeaponStorageMax(missile_type)) .. "\n"
			end
		end
		setCommsMessage(msg);
		addCommsReply("Back", commsPlatformDrop)
	end)
end

function update(delta)
	if not my_ship:isValid() then
		destroyScript()
		return
	end
	local x, y = my_ship:getPosition()
	if state == 0 then
		if math.abs(x - target_x) < 300 and math.abs(y - target_y) < 300 then
			CpuShip():setTemplate("Defense platform"):setFactionId(faction_id):setPosition(target_x + random(-300,300), target_y + random(-300,300)):orderRoaming()
			my_ship:orderFlyTowardsBlind(freighter_x, freighter_y)
			state = 1
		end
	elseif state == 1 then
		if math.abs(x - freighter_x) < 1500 and math.abs(y - freighter_y) < 1500 then
			my_ship:destroy()
			destroyScript()
			return
		end
	end
end

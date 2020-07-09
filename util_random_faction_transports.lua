function vectorFromAngle(angle, length)
	return math.cos(angle / 180 * math.pi) * length, math.sin(angle / 180 * math.pi) * length
end
function init()
	transport_list = {}
	spawn_delay = 0
	freighter_name = {"Personnel","Goods","Garbage","Equipment","Fuel"}
--	table.insert(freighter_name,"Personnel")
--	table.insert(freighter_name,"Goods")
--	table.insert(freighter_name,"Garbage")
--	table.insert(freighter_name,"Equipment")
--	table.insert(freighter_name,"Fuel")
	buildStationList()
end
function buildStationList()
	station_list = {}
	local position_reference = SupplyDrop()
	for _, obj in ipairs(position_reference:getObjectsInRange(100000)) do
		if obj.typeName == "SpaceStation" then
			table.insert(station_list, obj)
		end
	end
	position_reference:destroy()
end
function chooseTransportTarget(transport,faction_irrelevant)
	local candidate = nil
	local attempts = 0
	local valid_candidate = false
	repeat
		candidate = station_list[math.random(1,#station_list)]
		if candidate ~= nil then
			if candidate:isValid() then
				if faction_irrelevant then
					transport:setFaction(candidate:getFaction())
					valid_candidate = true
				else
					if not candidate:isEnemy(transport) then
						valid_candidate = true
					end
				end
			else
				buildStationList()	--rebuild list if bad station found
			end
		else
			buildStationList()	--rebuild list if bad station found
		end
		attempts = attempts + 1
	until(valid_candidate or attempts > 50)
	if valid_candidate then
		transport.target = candidate
	end
end
function update(delta)
	local valid_transport_count = 0
	for index, transport in ipairs(transport_list) do
		if transport ~= nil then
			if transport:isValid() then
				valid_transport_count = valid_transport_count + 1
				if transport.target:isValid() then
					if transport:isDocked(transport.target) then
						if transport.undock_delay == nil then
							transport.undock_delay = delta + random(5,30)
						end
						transport.undock_delay = transport.undock_delay - delta
						if transport.undock_delay < 0 then
							chooseTransportTarget(transport,false)
							transport:orderDock(transport.target)
							transport.undock_delay = nil
						end
					end
				else
					chooseTransportTarget(transport,false)
					transport:orderDock(transport.target)
				end
			else	--transport destroyed
				table.remove(transport_list,index)
				break
			end
		else	--transport destroyed
			table.remove(transport_list,index)
			break
		end
	end
	if valid_transport_count < #station_list then
		spawn_delay = spawn_delay - delta
		if spawn_delay < 0 then
			local name = "Freighter"
			if random(1,100) < 15 then
				name = string.format("%s Jump %s %i",freighter_name[math.random(1,#freighter_name)],name,math.random(3,5))
			else
				name = string.format("%s %s %i",freighter_name[math.random(1,#freighter_name)],name,math.random(1,5))
			end
			local new_transport = CpuShip():setTemplate(name)
			chooseTransportTarget(new_transport,true)
			if new_transport.target ~= nil and new_transport.target:isValid() then
				new_transport:orderDock(new_transport.target)
				local x, y = new_transport.target:getPosition()
				local xd, yd = vectorFromAngle(random(0, 360), random(25000, 40000))
				new_transport:setPosition(x + xd, y + yd)
				table.insert(transport_list, new_transport)
				spawn_delay = random(30, 50) + delta
			else
				new_transport:destroy()
			end
		end
	end
end

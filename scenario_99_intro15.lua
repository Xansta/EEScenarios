-- Name: Intro 15
-- Description: Introduction to scenario scripting
-- Type: Development
-- Setting[Level]: Sets how hard the scenario will be
-- Level[Easy]: Destroy Kraylor station
-- Level[Normal|Default]: Destroy Kraylor stations and ships
-- Level[Hard]: Destroy kraylor station and ships. Station protected by defense platforms
require("utils.lua")

function init()
	constructEnvironment()
	onNewPlayerShip(setPlayer)
end
function setPlayer(p)
	string.format("")
	p:setPosition(10000,10000)
	if getScenarioSetting("Level") == "Easy" then
		p:addToShipLog(_("goal-shipLog","Destroy the Kraylor station"),"Magenta")
	else
		p:addToShipLog(_("goal-shipLog","Destroy the Kraylor station and ships"),"Magenta")
	end
end
function constructEnvironment()
	enemy_ships = {}
	table.insert(enemy_ships,CpuShip():setFaction("Kraylor"):setTemplate("Adder MK5"):setCallSign("CSS2"):setPosition(2331, 1917):orderRoaming():setWeaponStorage("HVLI", 3))
	Asteroid():setPosition(1524, 5030):setSize(117)
	Asteroid():setPosition(3049, 3049):setSize(129)
	Asteroid():setPosition(3963, 5488):setSize(126)
	Asteroid():setPosition(5335, 1524):setSize(116)
	Asteroid():setPosition(4573, 4573):setSize(117)
	Asteroid():setPosition(5945, 2287):setSize(117)
	Asteroid():setPosition(4421, 3201):setSize(121)
	Asteroid():setPosition(2439, 5945):setSize(123)
	Asteroid():setPosition(-305, 6860):setSize(124)
	Asteroid():setPosition(762, 3963):setSize(110)
	Asteroid():setPosition(5793, -457):setSize(128)
	Asteroid():setPosition(8079, 1982):setSize(123)
	Asteroid():setPosition(6402, 3811):setSize(123)
	Asteroid():setPosition(7927, 152):setSize(122)
	Asteroid():setPosition(9451, -2439):setSize(122)
	Asteroid():setPosition(6707, -1829):setSize(110)
	Asteroid():setPosition(-2439, 7012):setSize(115)
	Asteroid():setPosition(305, 7622):setSize(110)
	Asteroid():setPosition(-1524, 9146):setSize(126)
	Asteroid():setPosition(1677, 8689):setSize(127)
	Asteroid():setPosition(1982, 7165):setSize(123)
	Nebula():setPosition(-457, 7774)
	Nebula():setPosition(3049, 2591)
	Nebula():setPosition(7622, -2134)
	Mine():setPosition(7012, -3659)
	Mine():setPosition(8689, -1067)
	Mine():setPosition(4573, -1524)
	Mine():setPosition(-1677, 5335)
	Mine():setPosition(-915, 7622)
	Mine():setPosition(610, 9756)
	home_station = SpaceStation():setTemplate("Huge Station"):setFaction("Human Navy"):setCallSign("DS231"):setPosition(22713, 21646)
	enemy_station_angle = random(0,360)
	enemy_station_x, enemy_station_y = vectorFromAngle(enemy_station_angle,random(50000,80000))
	enemy_station = SpaceStation():setTemplate("Large Station"):setFaction("Kraylor"):setPosition(enemy_station_x, enemy_station_y)
	if getScenarioSetting("Level") == "Hard" then
		local angle = 0
		for i=1,5 do
			local dp_x, dp_y = vectorFromAngle(angle,2500)
			dp_x = dp_x + enemy_station_x
			dp_y = dp_y + enemy_station_y
			CpuShip():setFaction("Kraylor"):setTemplate("Defense platform"):setPosition(dp_x, dp_y):orderRoaming()
			angle = angle + (360/5)
		end
	end
	distressed_freighter = CpuShip():setFaction("Arlenians"):setTemplate("Personnel Freighter 1")
	distressed_freighter_angle = enemy_station_angle + random(120,240)
	distressed_freighter_x, distressed_freighter_y = vectorFromAngle(distressed_freighter_angle,random(50000,80000),true)
	distressed_freighter:setPosition(distressed_freighter_x, distressed_freighter_y):orderIdle()
	stations = {}
	table.insert(stations,SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("DS238"):setPosition(15848, 31096))
	table.insert(stations,SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("DS239"):setPosition(28239, 27499))
	table.insert(stations,SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("DS240"):setPosition(30637, 9113))
	table.insert(stations,SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("DS241"):setPosition(36832, 15508))
	table.insert(stations,SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("DS242"):setPosition(860, 26700))
	table.insert(stations,SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("DS243"):setPosition(-23122, 5716))
	table.insert(stations,SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("DS244"):setPosition(-18526, -8074))
	table.insert(stations,SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("DS245"):setPosition(-13130, -3277))
	table.insert(stations,SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("DS246"):setPosition(-5136, -21863))
	table.insert(stations,SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCallSign("DS247"):setPosition(-15728, 3917))
	table.insert(stations,SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCallSign("DS248"):setPosition(-23522, -4476))
	table.insert(stations,SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCallSign("DS249"):setPosition(-13529, -11871))
	table.insert(stations,SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCallSign("DS250"):setPosition(29838, -280))
	table.insert(stations,SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCallSign("DS251"):setPosition(17047, -14469))
	table.insert(stations,SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCallSign("DS252"):setPosition(27040, -22463))
	table.insert(stations,SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCallSign("DS253"):setPosition(41229, -19465))
	table.insert(stations,SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCallSign("DS254"):setPosition(-9333, 25701))
	table.insert(stations,SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCallSign("DS255"):setPosition(-19924, 31896))
	table.insert(enemy_ships,CpuShip():setFaction("Kraylor"):setTemplate("Adder MK5"):setCallSign("NC8"):setPosition(15521, -11619):orderRoaming():setWeaponStorage("HVLI", 3))
	table.insert(enemy_ships,CpuShip():setFaction("Kraylor"):setTemplate("Adder MK5"):setCallSign("S9"):setPosition(20380, -7411):orderRoaming():setWeaponStorage("HVLI", 3))
	table.insert(enemy_ships,CpuShip():setFaction("Kraylor"):setTemplate("Adder MK5"):setCallSign("VS10"):setPosition(23189, -6039):orderRoaming():setWeaponStorage("HVLI", 3))
	table.insert(enemy_ships,CpuShip():setFaction("Kraylor"):setTemplate("Adder MK5"):setCallSign("CCN11"):setPosition(19494, -3475):orderRoaming():setWeaponStorage("HVLI", 3))
	table.insert(enemy_ships,CpuShip():setFaction("Kraylor"):setTemplate("Adder MK5"):setCallSign("S12"):setPosition(14927, -7500):orderRoaming():setWeaponStorage("HVLI", 3))
	transports = {}
	for i=1,10 do
		local transport = randomTransportType()
		transport:setPosition(random(-40000,40000),random(-40000,40000)):setFaction("Independent")
		transport:orderDock(tableSelectRandom(stations))
		transport:setDescriptionForScanState("simplescan",_("scienceDescription","Ship log present"))
		transport:setDescriptionForScanState("fullscan",_("scienceDescription","Ship log shows that freighter visited Independent stations"))
		table.insert(transports,transport)
	end
	local black_sheep = tableSelectRandom(transports)
--	print("black sheep:",black_sheep:getCallSign(),black_sheep:getSectorName())
	black_sheep:setDescriptionForScanState("fullscan",string.format(_("scienceDescription","Ship log shows that freighter visited Independent stations and Kraylor station in %s"),enemy_station:getSectorName()))
    CpuShip():setFaction("Human Navy"):setTemplate("Dreadnought"):setCallSign("Elan (flagship)"):setPosition(27276, 20092):orderDefendTarget(home_station):setCanBeDestroyed(false):setCommsFunction(commsFlagship):setScanned(true)
--	set up planet
	local mid_x = (enemy_station_x + distressed_freighter_x)/2
	local mid_y = (enemy_station_y + distressed_freighter_y)/2
	local avg_angle = (enemy_station_angle + distressed_freighter_angle)/2
	local pc_1_x, pc_1_y = vectorFromAngle(avg_angle,50000,true)
	local pc_2_x, pc_2_y = vectorFromAngle(avg_angle + 180,50000,true)
	if distance(pc_1_x, pc_1_y, mid_x, mid_y) > distance(pc_2_x, pc_2_y, mid_x, mid_y) then
		planet_angle = avg_angle
		planet_x = pc_1_x
		planet_y = pc_1_y
	else
		planet_angle = avg_angle + 180
		planet_x = pc_2_x
		planet_y = pc_2_y
	end
	the_planet = Planet():setPosition(planet_x,planet_y):setPlanetRadius(5000)
	the_planet:setPlanetSurfaceTexture("planets/planet-1.png")
	the_planet:setDistanceFromMovementPlane(-1000)
	the_planet:setAxialRotationTime(500)
	the_planet:setPlanetAtmosphereColor(.5,.5,.9)
	the_planet:setPlanetAtmosphereTexture("planets/atmosphere.png")
	the_planet:setPlanetCloudTexture("planets/clouds-2.png")
	the_planet:setPlanetCloudRadius(5200)
	the_planet:setCallSign("Gralmond")
--	set up star
	local star_x, star_y = vectorFromAngle(planet_angle,100000,true)
	the_star = Planet():setPosition(star_x,star_y):setPlanetRadius(1000)
	the_star:setDistanceFromMovementPlane(-500)
	the_star:setPlanetAtmosphereTexture("planets/star-1.png")
	the_star:setPlanetAtmosphereColor(.9,.9,.4)
	the_star:setCallSign("Twinkle")
--	set up moon
	local moon_x, moon_y = vectorFromAngle(planet_angle,70000,true)
	the_moon = Planet():setPosition(moon_x,moon_y):setPlanetRadius(1000)
	the_moon:setDistanceFromMovementPlane(-500)
	the_moon:setAxialRotationTime(400)
	the_moon:setPlanetSurfaceTexture("planets/moon-1.png")
	the_moon:setCallSign("Betty")
--	set orbits
	the_planet:setOrbit(the_star,4000)
	the_moon:setOrbit(the_planet,2000)
	research_vessel = CpuShip():setPosition(moon_x,moon_y):setFaction("Independent"):setTemplate("Garbage Freighter 2")
	research_vessel:setTypeName("Research Vessel"):setImpulseMaxSpeed(120)
	research_vessel:orderDefendTarget(the_moon):setCommsFunction(commsResearchVessel)
	mehklar_keywords = {
		_("scienceDescription-artifact","bread"),
		_("scienceDescription-artifact","bisect"),
		_("scienceDescription-artifact","court"),
		_("scienceDescription-artifact","naught"),
		_("scienceDescription-artifact","gargle"),
		_("scienceDescription-artifact","strap"),
		_("scienceDescription-artifact","natural"),
		_("scienceDescription-artifact","blink"),
		_("scienceDescription-artifact","scupper"),
		_("scienceDescription-artifact","turn"),
		_("scienceDescription-artifact","flap"),
		_("scienceDescription-artifact","retest"),
	}
	mehklar_changes = {
		_("ship-comms","power"),
		_("ship-comms","impulse"),
		_("ship-comms","maneuver"),
		_("ship-comms","shield"),
		_("ship-comms","hull"),
	}
	mehklar_artifacts = {}
	local scan_bounds = {
		["Easy"] =		{complex_hi = 2,	depth_hi = 2},
		["Normal"] =	{complex_hi = 3,	depth_hi = 3},
		["Hard"] =		{complex_hi = 4,	depth_hi = 8},
	}
	local c_hi = scan_bounds[getScenarioSetting("Level")].complex_hi
	local d_hi = scan_bounds[getScenarioSetting("Level")].depth_hi
	for i=1,5 do
		local a = Artifact():setPosition(random(-40000,40000),random(-40000,40000))
		a:setModel("artifact1")
		a:setDescriptionForScanState("notscanned",_("scienceDescription-artifact","Mehklar technical artifact"))
		a.keyword = tableRemoveRandom(mehklar_keywords)
		a.change = tableRemoveRandom(mehklar_changes)
		a.damage = random(1,100) < 22
		a:setDescriptionForScanState("fullscan",string.format(_("scienceDescription-artifact","Mehklar technical artifact. Limited translation software picked out '%s' on exterior"),a.keyword))
		a:allowPickup(true)
		a:setScanningParameters(math.random(1,c_hi),math.random(1,d_hi))
		a:onPickUp(mehklarArtifactPickup)
		table.insert(mehklar_artifacts,a)
	end
end
function mehklarArtifactPickup(self, retriever)
	string.format("")
	if self.damage or not self:isScannedBy(retriever) or retriever.investigated == nil or not retriever.investigated[self.keyword] then
		if self.change == _("ship-comms","power") then
			retriever:setMaxEnergy(retriever:getMaxEnergy()*.5)
			retriever:addToShipLog(_("shipLog","Battery capacity has been reduced"),"Red")
		elseif self.change == _("ship-comms","impulse") then
			retriever:setImpulseMaxSpeed(retriever:getImpulseMaxSpeed()*.5)
			retriever:addToShipLog(_("shipLog","Impulse speed has been reduced"),"Red")
		elseif self.change == _("ship-comms","maneuver") then
			retriever:setRotationMaxSpeed(retriever:getRotationMaxSpeed()*.5)
			retriever:addToShipLog(_("shipLog","Maneuverability has been reduced"),"Red")
		elseif self.change == _("ship-comms","shield") then
			if retriever:getShieldCount() == 2 then
				retriever:setShieldsMax(retriever:getShieldMax(0)*.5,retriever:getShieldMax(1)*.5)
			elseif retriever:getShieldCount() == 1 then
				retriever:setShieldsMax(retriever:getShieldMax(0)*.5)
			end
			retriever:addToShipLog(_("shipLog","Shield capacity has been reduced"),"Red")
		elseif self.change == _("ship-comms","hull") then
			retriever:setHullMax(retriever:getHullMax()*.5)
			retriever:addToShipLog(_("shipLog","Hull strength has been reduced"),"Red")
		end
	else	--improve
		if self.change == _("ship-comms","power") then
			retriever:setMaxEnergy(retriever:getMaxEnergy()*1.5)
			retriever:setEnergy(retriever:getMaxEnergy())
			retriever:addToShipLog(_("shipLog","Battery capacity has been increased"),"Green")
		elseif self.change == _("ship-comms","impulse") then
			retriever:setImpulseMaxSpeed(retriever:getImpulseMaxSpeed()*1.5)
			retriever:addToShipLog(_("shipLog","Impulse speed has been increased"),"Green")
		elseif self.change == _("ship-comms","maneuver") then
			retriever:setRotationMaxSpeed(retriever:getRotationMaxSpeed()*1.5)
			retriever:addToShipLog(_("shipLog","Maneuverability has been increased"),"Green")
		elseif self.change == _("ship-comms","shield") then
			if retriever:getShieldCount() == 2 then
				retriever:setShieldsMax(retriever:getShieldMax(0)*1.5,retriever:getShieldMax(1)*1.5)
				retriever:setShields(retriever:getShieldMax(0),retriever:getShieldMax(1))
			elseif retriever:getShieldCount() == 1 then
				retriever:setShieldsMax(retriever:getShieldMax(0)*1.5)
				retriever:setShields(retriever:getShieldMax(0))
			end
			retriever:addToShipLog(_("shipLog","Shield capacity has been increased"),"Green")
		elseif self.change == _("ship-comms","hull") then
			retriever:setHullMax(retriever:getHullMax()*1.5)
			retriever:setHull(retriever:getHullMax())
			retriever:addToShipLog(_("shipLog","Hull strength has been increased"),"Green")
		end
	end
end
function maintainMehklarArtifacts()
	local clean_list = true
	for i,a in ipairs(mehklar_artifacts) do
		if a == nil or not a:isValid() then
			table.remove(mehklar_artifacts,i)
			clean_list = false
			break
		end
	end
	if clean_list then
		for i,a in ipairs(mehklar_artifacts) do
			for j,p in ipairs(getActivePlayerShips()) do
				if a:isScannedBy(p) then
					p.mehklar_artifact_scanned = true
					break
				end
			end
		end
	end
end
function commsFlagship()
	setCommsMessage(_("goal-comms","I am the admiral's relay officer. How can I help you?"))
	addCommsReply(_("goal-comms","What is our mission?"),function()
		if comms_source.distressed_freighter_message == nil then
			setCommsMessage(_("goal-comms","Your mission is to destroy the Kraylor station."))
		else
			setCommsMessage(_("goal-comms","Your mission is to destroy the Kraylor station. You have also been asked to help a distressed Arlenian freighter."))
		end
	end)
	addCommsReply(_("goal-comms","Where is the Kraylor station?"),function()
		setCommsMessage(_("goal-comms","We don't have that kind of intel for this region."))
		addCommsReply(_("goal-comms","How do we get that information?"),function()
			setCommsMessage(_("goal-comms","I suggest the following courses of action: fly around using the scanners available to your science officer, send out probes to find the station, or check the logs of freighters in the region since they are supposed to keep their ship logs updated, maybe they've been to the Kraylor station."))
		end)
	end)
	if comms_source.distressed_freighter_message ~= nil then
		addCommsReply(_("goal-comms","Where is the distressed Arlenian freighter?"),function()
			local bearing_to_freighter = math.floor(angleHeading(home_station,distressed_freighter))
			local bearing_to_player = math.floor(angleHeading(home_station,comms_source))
			setCommsMessage(string.format(_("goal-comms","The signal from the distressed Arlenian freighter came to %s on bearing %s. You are currently on bearing %s from %s."),home_station:getCallSign(),bearing_to_freighter,bearing_to_player,home_station:getCallSign()))
		end)
	end
	if comms_source.mehklar_artifact_scanned then
		addCommsReply(_("goal-comms","What are Mehklar technical artifacts?"),function()
			setCommsMessage(string.format(_("goal-comms","Little is known about the Mehklar. However, the artifacts that have been found either damage or improve a ship system when picked up. The best known expert is currently studying Mehklar traces on %s, currently in sector %s. His ship, %s, is in orbit around %s."),the_moon:getCallSign(),the_moon:getSectorName(),research_vessel:getCallSign(),the_moon:getCallSign()))
		end)
	end
end
function commsResearchVessel()
	setCommsMessage(string.format(_("ship-comms","These Mehklar traces are fascinating! Did you know that their civilization has been around for approximately 400,000 years longer than ours? Anyway, what brings you to %s?"),the_moon:getCallSign()))
	addCommsReply(_("ship-comms","We need your help with Mehklar artifacts."),function()
		setCommsMessage(_("ship-comms","You came to the right place. Send me the results of your scans."))
		for i,a in ipairs(mehklar_artifacts) do
			if a:isScannedBy(comms_source) then
				addCommsReply(string.format(_("ship-comms","Send scan data on Mehklar artifact showing '%s'"),a.keyword),function()
					local impact = _("ship-comms","positive")
					if a.damage then
						impact = _("ship-comms","negative")
					end
					setCommsMessage(string.format(_("ship-comms","Looks like this Mehklar artifact relates to a ship's %s. Picking it up will have a %s impact."),a.change,impact))
					if comms_source.investigated == nil then
						comms_source.investigated = {}
					end
					comms_source.investigated[a.keyword] = true
				end)
			end
		end
	end)
end
function randomTransportType()
	local transport_type = {"Personnel","Goods","Garbage","Equipment","Fuel"}
	local freighter_engine = "Freighter"
	local freighter_size = math.random(1,5)
	if random(1,100) < 30 then
		freighter_engine = "Jump Freighter"
		freighter_size = math.random(3,5)
	end
	return CpuShip():setTemplate(string.format("%s %s %i",tableSelectRandom(transport_type),freighter_engine,freighter_size)):setCommsScript(""):setCommsFunction(commsShip), freighter_size
end
function tableSelectRandom(array)
	local array_item_count = #array
    if array_item_count == 0 then
        return nil
    end
	return array[math.random(1,#array)]	
end
function tableRemoveRandom(array)
--	Remove random element from array and return it.
	-- Returns nil if the array is empty,
	-- analogous to `table.remove`.
    local array_item_count = #array
    if array_item_count == 0 then
        return nil
    end
    local selected_item = math.random(array_item_count)
    local temp = array[selected_item]
    array[selected_item] = array[array_item_count]
    array[array_item_count] = temp
    return table.remove(array)
end
function maintainTransports()
	for i,ship in ipairs(transports) do
		if ship ~= nil and ship:isValid() then
			local docked_with_station = ship:getDockedWith()
			if docked_with_station ~= nil then
				repeat
					target = tableSelectRandom(stations)
				until(target ~= nil and target:isValid() and target ~= docked_with_station)
				ship:orderDock(target)
			end
		else
			table.remove(transports,i)
			break
		end
	end
end
function bugThePlayer()
	local clean_list = true
	for i,ship in ipairs(enemy_ships) do
		if ship == nil or not ship:isValid() then
			table.remove(enemy_ships,i)
			clean_list = false
			break
		end
	end
	if clean_list and #enemy_ships < 1 then
		if bug_time == nil then
			bug_time = getScenarioTime() + 120	--3 is for test, final: 120 (2 minutes)
		end
		if getScenarioTime() > bug_time then
			bug_time = nil
			local bug_count = math.random(1,10)
			for i=1,bug_count do
				local bug_x, bug_y = vectorFromAngle(360/bug_count*i,1400,true)
				local bug = CpuShip()
					:setTemplate(string.format("Adder MK%s",math.random(3,9)))
					:setPosition(enemy_station_x + bug_x,enemy_station_y + bug_y)
					:setHeading(360/bug_count*i)
					:orderRoaming()
				table.insert(enemy_ships,bug)
			end
		end
	end
end
function distressedFreighter()
	if distressed_freighter_time == nil then
		distressed_freighter_time = getScenarioTime() + 5	--5 is test, final: 300 (5 minutes)
	end
	if getScenarioTime() > distressed_freighter_time then
		for i,p in ipairs(getActivePlayerShips()) do
			if p.distressed_freighter_message == nil then
				local bearing_to_freighter = math.floor(angleHeading(home_station,distressed_freighter))
				p:addToShipLog(string.format(_("goal-shipLog","Faint distress call from Arlenian freighter detected on bearing %s. Please investigate and help if you can."),bearing_to_freighter),"Magenta")
				p.distressed_freighter_message = "sent"
			end
			if p.render_aid_button_rel == nil then
				p.render_aid_button_rel = "render_aid_button_rel"
				p:addCustomButton("Relay",p.render_aid_button_rel,_("buttonRelay","Render Aid"),function()
					string.format("")
					renderAid(p,"Relay")
				end)
			end
			if p.render_aid_button_ops == nil then
				p.render_aid_button_ops = "render_aid_button_ops"
				p:addCustomButton("Operations",p.render_aid_button_ops,_("buttonOperations","Render Aid"),function()
					string.format("")
					renderAid(p,"Operations")
				end)
			end
		end
	end
end
function renderAid(p,console)
	string.format("")
	if distance(p,distressed_freighter) < 5000 then
		p:removeCustom(p.render_aid_button_rel)
		p:removeCustom(p.render_aid_button_ops)
		p:addCustomMessage(console,"aid_success",string.format(_("msgRelay&Operations","You have successfully rendered aid to %s, the distressed Arlenian freighter. They are grateful. You receive 100 reputation points."),distressed_freighter:getCallSign()))
		p:addReputationPoints(100)
	else
		p:addCustomMessage(console,"aid_failure",_("msgRelay&Operations","You must be within 5 units of the distressed freighter to render aid"))
	end
end
function update(delta)
	if delta == 0 then
		--paused
		return
	end
	maintainTransports()
	bugThePlayer()
	distressedFreighter()
	maintainMehklarArtifacts()
	if #getActivePlayerShips() < 1 then
		globalMessage(_("msgMainscreen","The Kraylor have destroyed you"))
		victory("Kraylor")
	end
	if enemy_station == nil or not enemy_station:isValid() then
		if getScenarioSetting("Level") == "Easy" then
			globalMessage(_("msgMainscreen","You took out the Kraylor station"))
			victory("Human Navy")
		else
			local ship_count = 0
			for i,ship in ipairs(enemy_ships) do
				if ship ~= nil and ship:isValid() then
					ship_count = ship_count + 1
				end
			end
			if ship_count == 0 then
				globalMessage(_("msgMainscreen","You took out the Kraylor station and ships"))
				victory("Human Navy")
			end
		end
	end
end

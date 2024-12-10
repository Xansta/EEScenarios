-- Name: Intro 10
-- Description: Introduction to scenario scripting
-- Type: Development
-- Setting[Level]: Sets how hard the scenario will be
-- Level[Easy]: Destroy Kraylor station
-- Level[Normal|Default]: Destroy Kraylor stations and ships
-- Level[Hard]: Destroy kraylor station and ships. Station protected by defense platforms
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
	enemy_station = SpaceStation():setTemplate("Large Station"):setFaction("Kraylor"):setPosition(-22713,-25000)
    if getScenarioSetting("Level") == "Hard" then
		CpuShip():setFaction("Kraylor"):setTemplate("Defense platform"):setCallSign("CSS3"):setPosition(-22019, -23113):orderRoaming()
		CpuShip():setFaction("Kraylor"):setTemplate("Defense platform"):setCallSign("CV4"):setPosition(-23915, -23332):orderRoaming()
		CpuShip():setFaction("Kraylor"):setTemplate("Defense platform"):setCallSign("SS5"):setPosition(-24206, -26321):orderRoaming()
		CpuShip():setFaction("Kraylor"):setTemplate("Defense platform"):setCallSign("CSS6"):setPosition(-22748, -26977):orderRoaming()
		CpuShip():setFaction("Kraylor"):setTemplate("Defense platform"):setCallSign("SS7"):setPosition(-21144, -25227):orderRoaming()
	end
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
end
function commsFlagship()
	setCommsMessage(_("goal-comms","I am the admiral's relay officer. How can I help you?"))
	addCommsReply(_("goal-comms","What is our mission?"),function()
		setCommsMessage(_("goal-comms","Your mission is to destroy the Kraylor station."))
	end)
	addCommsReply(_("goal-comms","Where is the Kraylor station?"),function()
		setCommsMessage(_("goal-comms","We don't have that kind of intel for this region."))
		addCommsReply(_("goal-comms","How do we get that information?"),function()
			setCommsMessage(_("goal-comms","I suggest the following courses of action: fly around using the scanners available to your science officer, send out probes to find the station, or check the logs of freighters in the region since they are supposed to keep their ship logs updated, maybe they've been to the Kraylor station."))
		end)
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
function update(delta)
	if delta == 0 then
		--paused
		return
	end
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

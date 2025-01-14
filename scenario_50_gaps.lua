-- Name: Close the Gaps
-- Description: Using Nautilus class mine layer, lay mines across the space lanes expected to be used by invading enemies
---
--- Version 2 - Jan2025
---
--- Mission advice: It's better to hit an asteroid than a mine
-- Type: Mission
-- Setting[Enemies]: Configures strength and/or number of enemies in this scenario
-- Enemies[Easy]: Fewer or weaker enemies
-- Enemies[Normal|Default]: Normal number or strength of enemies
-- Enemies[Hard]: More or stronger enemies
-- Enemies[Extreme]: Much stronger, many more enemies
-- Enemies[Quixotic]: Insanely strong and/or inordinately large numbers of enemies
-- Setting[Murphy]: Configures the perversity of the universe according to Murphy's law
-- Murphy[Easy]: Random factors or puzzle difficulties are easier than normal
-- Murphy[Normal|Default]: Random factors or puzzle difficulties are normal
-- Murphy[Hard]: Random factors or puzzle difficulties are more challenging than normal
-- Setting[Timed]: Sets whether or not the scenario has a time limit. Default is no time limit
-- Timed[None|Default]: No time limit
-- Timed[30]: Scenario ends in 30 minutes
-- Timed[40]: Scenario ends in 40 minutes
-- Timed[45]: Scenario ends in 45 minutes
-- Timed[50]: Scenario ends in 50 minutes
-- Timed[55]: Scenario ends in 55 minutes
-- Timed[60]: Scenario ends in 60 minutes
-- Timed[70]: Scenario ends in 70 minutes
-- Timed[80]: Scenario ends in 80 minutes
-- Timed[90]: Scenario ends in 90 minutes

require("utils.lua")
require("place_station_scenario_utility.lua")

function init()
	scenario_version = "2.0.3"
	ee_version = "2024.12.08"
	print(string.format("    ----    Scenario: Close the Gaps    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
	if _VERSION ~= nil then
		print("Lua version:",_VERSION)
	end
	setVariations()
	setConstants()
	setGlobals()
	mainGMButtons()
	buildStations()
	spawnPlayer()
	plot1 = initialInstructions
	initialOrderTimer = 3
	buildAsteroids()
	if not diagnostic then
		createRandomAlongArc(Nebula, difficulty*10, 50000, 50000, 70000, 180, 270, 35000)
	end
	wfv = "end of init"
end
function setConstants()
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	--Ship Template Name List
	stnl = {"MT52 Hornet","MU52 Hornet","Adder MK5","Adder MK4","WX-Lindworm","Adder MK6","Phobos T3","Phobos M3","Piranha F8","Piranha F12","Ranus U","Nirvana R5A","Stalker Q7","Stalker R7","Atlantis X23","Starhammer II","Odin","Fighter","Cruiser","Missile Cruiser","Strikeship","Adv. Striker","Dreadnought","Battlestation","Blockade Runner","Ktlitan Fighter","Ktlitan Breaker","Ktlitan Worker","Ktlitan Drone","Ktlitan Feeder","Ktlitan Scout","Ktlitan Destroyer","Storm"}
	--Ship Template Score List
	stsl = {5            ,5            ,7          ,6          ,7            ,8          ,15         ,16         ,15          ,15           ,25       ,20           ,25          ,25          ,50            ,70             ,250   ,6        ,18       ,14               ,30          ,27            ,80           ,100            ,65               ,6                ,45               ,40              ,4              ,48              ,8              ,50                 ,22}
	-- square grid deployment
	fleetPosDelta1x = {0,1,0,-1, 0,1,-1, 1,-1,2,0,-2, 0,2,-2, 2,-2,2, 2,-2,-2,1,-1, 1,-1,0, 0,3,-3,1, 1,3,-3,-1,-1, 3,-3,2, 2,3,-3,-2,-2, 3,-3,3, 3,-3,-3,4,0,-4, 0,4,-4, 4,-4,-4,-4,-4,-4,-4,-4,4, 4,4, 4,4, 4, 1,-1, 2,-2, 3,-3,1,-1,2,-2,3,-3,5,-5,0, 0,5, 5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,5, 5,5, 5,5, 5,5, 5, 1,-1, 2,-2, 3,-3, 4,-4,1,-1,2,-2,3,-3,4,-4}
	fleetPosDelta1y = {0,0,1, 0,-1,1,-1,-1, 1,0,2, 0,-2,2,-2,-2, 2,1,-1, 1,-1,2, 2,-2,-2,3,-3,0, 0,3,-3,1, 1, 3,-3,-1,-1,3,-3,2, 2, 3,-3,-2,-2,3,-3, 3,-3,0,4, 0,-4,4,-4,-4, 4, 1,-1, 2,-2, 3,-3,1,-1,2,-2,3,-3,-4,-4,-4,-4,-4,-4,4, 4,4, 4,4, 4,0, 0,5,-5,5,-5, 5,-5, 1,-1, 2,-2, 3,-3, 4,-4,1,-1,2,-2,3,-3,4,-4,-5,-5,-5,-5,-5,-5,-5,-5,5, 5,5, 5,5, 5,5, 5}
	-- rough hexagonal deployment
	fleetPosDelta2x = {0,2,-2,1,-1, 1,-1,4,-4,0, 0,2,-2,-2, 2,3,-3, 3,-3,6,-6,1,-1, 1,-1,3,-3, 3,-3,4,-4, 4,-4,5,-5, 5,-5,8,-8,4,-4, 4,-4,5,5 ,-5,-5,2, 2,-2,-2,0, 0,6, 6,-6,-6,7, 7,-7,-7,10,-10,5, 5,-5,-5,6, 6,-6,-6,7, 7,-7,-7,8, 8,-8,-8,9, 9,-9,-9,3, 3,-3,-3,1, 1,-1,-1,12,-12,6,-6, 6,-6,7,-7, 7,-7,8,-8, 8,-8,9,-9, 9,-9,10,-10,10,-10,11,-11,11,-11,4,-4, 4,-4,2,-2, 2,-2,0, 0}
	fleetPosDelta2y = {0,0, 0,1, 1,-1,-1,0, 0,2,-2,2,-2, 2,-2,1,-1,-1, 1,0, 0,3, 3,-3,-3,3,-3,-3, 3,2,-2,-2, 2,1,-1,-1, 1,0, 0,4,-4,-4, 4,3,-3, 3,-3,4,-4, 4,-4,4,-4,2,-2, 2,-2,1,-1, 1,-1, 0,  0,5,-5, 5,-5,4,-4, 4,-4,3,-3, 3,-7,2,-2, 2,-2,1,-1, 1,-1,5,-5, 5,-5,5,-5, 5,-5, 0,  0,6, 6,-6,-6,5, 5,-5,-5,4, 4,-4,-4,3, 3,-3,-3, 2,  2,-2, -2, 1,  1,-1, -1,6, 6,-6,-6,6, 6,-6,-6,6,-6}
end
function setGlobals()
	--list of goods available to buy, sell or trade (sell still under development)
	goodsList = {	
		{"food",0},
		{"medicine",0},
		{"nickel",0},
		{"platinum",0},
		{"gold",0},
		{"dilithium",0},
		{"tritanium",0},
		{"luxury",0},
		{"cobalt",0},
		{"impulse",0},
		{"warp",0},
		{"shield",0},
		{"tractor",0},
		{"repulsor",0},
		{"beam",0},
		{"optic",0},
		{"robotic",0},
		{"filament",0},
		{"transporter",0},
		{"sensor",0},
		{"communication",0},
		{"autodoc",0},
		{"lifter",0},
		{"android",0},
		{"nanites",0},
		{"software",0},
		{"circuit",0},
		{"battery",0}	
	}
	diagnostic = false
	interwave_delay_name = _("buttonGM","Normal")
	interWave = 150
	goods = {}					--overall tracking of goods
	stationList = {}			--friendly and neutral stations
	enemyStationList = {}
	tradeFood = {}				--stations that will trade food for other goods
	tradeLuxury = {}			--stations that will trade luxury for other goods
	tradeMedicine = {}			--stations that will trade medicine for other goods
	--Player ship name lists to supplant standard randomized call sign generation
	playerShipNamesForMP52Hornet = {"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"}
	playerShipNamesForPiranha = {"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"}
	playerShipNamesForFlaviaPFalcon = {"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"}
	playerShipNamesForPhobosM3P = {"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"}
	playerShipNamesForAtlantis = {"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"}
	playerShipNamesForCruiser = {"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"}
	playerShipNamesForMissileCruiser = {"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"}
	playerShipNamesForFighter = {"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"}
	playerShipNamesForBenedict = {"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"}
	playerShipNamesForKiriya = {"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"}
	playerShipNamesForStriker = {"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"}
	playerShipNamesForLindworm = {"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"}
	playerShipNamesForRepulse = {"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"}
	playerShipNamesForEnder = {"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"}
	playerShipNamesForNautilus = {"October", "Abdiel", "Manxman", "Newcon", "Nusret", "Pluton", "Amiral", "Amur", "Heinkel", "Dornier"}
	playerShipNamesForHathcock = {"Hayha", "Waldron", "Plunkett", "Mawhinney", "Furlong", "Zaytsev", "Pavlichenko", "Pegahmagabow", "Fett", "Hawkeye", "Hanzo"}
	playerShipNamesForLeftovers = {"Foregone","Righteous","Masher"}
	primaryOrders = ""
	secondaryOrders = ""
	optionalOrders = ""
	transportList = {}
	transportSpawnDelay = 10
	healthCheckTimer = 5
	healthCheckTimerInterval = 5
	northMineCount = -1
	southMineCount = -1
	eastMineCount = -1
	westMineCount = -1
	northObjCount = -1
	southObjCount = -1
	eastObjCount = -1
	westObjCount = -1
	northClosed = false
	southClosed = false
	eastClosed = false
	westClosed = false
	northMet = false
	southMet = false
	eastMet = false
	westMet = false
end
function mainGMButtons()
	clearGMFunctions()
	addGMFunction(string.format(_("buttonGM","Diagnostic %s"),diagnostic),function()
		if diagnostic then
			diagnostic = false
			mainGMButtons()
		else
			diagnostic = true
			mainGMButtons()
		end
	end)
	addGMFunction(string.format(_("buttonGM","+Delay %s"),interwave_delay_name),setDelay)
end
function setDelay()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main from delay"),mainGMButtons)
	--Slow is used for testing when the tester does not want constant enemy ships spawned while testing
	local button_label = _("buttonGM","Slow")
	if interwave_delay_name == _("buttonGM","Slow") then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		interwave_delay_name = _("buttonGM","Slow")
		interWave = 600
		setDelay()
	end)
	--Normal is the normal amount of time between enemy ship spawns
	button_label = _("buttonGM","Normal")
	if interwave_delay_name == _("buttonGM","Normal") then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		interwave_delay_name = _("buttonGM","Normal")
		interWave = 150
		setDelay()
	end)
	--Fast is for testing of the enemy ship spawn routine
	button_label = _("buttonGM","Fast")
	if interwave_delay_name == _("buttonGM","Fast") then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		interwave_delay_name = _("buttonGM","Fast")
		interWave = 20
		setDelay()
	end)
end
function setVariations()
	local enemy_config = {
		["Easy"] =		{number = .5},
		["Normal"] =	{number = 1},
		["Hard"] =		{number = 2},
		["Extreme"] =	{number = 3},
		["Quixotic"] =	{number = 5},
	}
	enemy_power =	enemy_config[getScenarioSetting("Enemies")].number
	local murphy_config = {
		["Easy"] =		{number = .5,	gap = 5,	},
		["Normal"] =	{number = 1,	gap = 10,	},
		["Hard"] =		{number = 2,	gap = 15,	},
	}
	difficulty =			murphy_config[getScenarioSetting("Murphy")].number
	gapCheckDelayTimer = 	murphy_config[getScenarioSetting("Murphy")].gap
	gapCheckInterval = gapCheckDelayTimer
	local timed_config = {
		["None"] =	{limit = 0,	limited = false,	},
		["30"] =	{limit = 30,limited = true,		},
		["40"] =	{limit = 40,limited = true,		},
		["45"] =	{limit = 45,limited = true,		},
		["50"] =	{limit = 50,limited = true,		},
		["55"] =	{limit = 55,limited = true,		},
		["60"] =	{limit = 60,limited = true,		},
		["70"] =	{limit = 70,limited = true,		},
		["80"] =	{limit = 80,limited = true,		},
		["90"] =	{limit = 90,limited = true,		},
	}
	playWithTimeLimit =				timed_config[getScenarioSetting("Timed")].limited
	defaultGameTimeLimitInMinutes =	timed_config[getScenarioSetting("Timed")].limit
	gameTimeLimit =					defaultGameTimeLimitInMinutes*60
end
function createRandomAlongArc(object_type, amount, x, y, distance, startArc, endArcClockwise, randomize)
-- Create amount of objects of type object_type along arc
-- Center defined by x and y
-- Radius defined by distance
-- Start of arc between 0 and 360 (startArc), end arc: endArcClockwise
-- Use randomize to vary the distance from the center point. Omit to keep distance constant
-- Example:
--   createRandomAlongArc(Asteroid, 100, 500, 3000, 65, 120, 450)
	if randomize == nil then randomize = 0 end
	if amount == nil then amount = 1 end
	arcLen = endArcClockwise - startArc
	if startArc > endArcClockwise then
		endArcClockwise = endArcClockwise + 360
		arcLen = arcLen + 360
	end
	if amount > arcLen then
		for ndex=1,arcLen do
			radialPoint = startArc+ndex
			pointDist = distance + random(-randomize,randomize)
			object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)			
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)			
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)
		end
	end
end
function buildStations()
	stationFaction = "Human Navy"
	psx = 0		--place station x coordinate
	psy = 0		--place station y coordinate
	homeStation = placeStation(0,0,"RandomHumanNeutral","Human Navy")
	table.insert(stationList,homeStation)
	table.insert(stationList,placeStation(31000,31000,"RandomHumanNeutral","Independent"))
	table.insert(stationList,placeStation(-31000,31000,"RandomHumanNeutral","Independent"))
	table.insert(stationList,placeStation(31000,-31000,"RandomHumanNeutral","Independent"))
	table.insert(stationList,placeStation(-31000,-31000,"RandomHumanNeutral","Independent"))
	local placed_station = placeStation(0,-60000,"Sinister","Kraylor")
	table.insert(enemyStationList,placed_station)
	local fleet = spawnEnemies(0,-60000,10,"Kraylor")
	for i,ship in ipairs(fleet) do
		ship:orderDefendTarget(placed_station)
	end
	placed_station = placeStation(0,60000,"Sinister","Ghosts")
	table.insert(enemyStationList,placed_station)
	fleet = spawnEnemies(0,60000,10,"Ghosts")
	for i,ship in ipairs(fleet) do
		ship:orderDefendTarget(placed_station)
	end
	placed_station = placeStation(60000,0,"Sinister","Exuari")
	table.insert(enemyStationList,placed_station)
	fleet = spawnEnemies(60000,0,10,"Exuari")
	for i,ship in ipairs(fleet) do
		ship:orderDefendTarget(placed_station)
	end
	placed_station = placeStation(-60000,0,"Sinister","Ktlitans")
	table.insert(enemyStationList,placed_station)
	fleet = spawnEnemies(-60000,0,10,"Ktlitans")
	for i,ship in ipairs(fleet) do
		ship:orderDefendTarget(placed_station)
	end
end
function spawnPlayer()
	local px, py = vectorFromAngle(random(0,360),random(2500,3000))
	player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Nautilus"):setPosition(px,py)
	ni = math.random(1,#playerShipNamesForNautilus)
	player:setCallSign(playerShipNamesForNautilus[ni])
	table.remove(playerShipNamesForNautilus,ni)
	player.nameAssigned = true
	player.shipScore = 12
	player.maxCargo = 7
	player.cargo = 7
	player.maxRepairCrew = player:getRepairCrewCount()
	player.healthyShield = 1.0
	player.prevShield = 1.0
	player.healthyReactor = 1.0
	player.prevReactor = 1.0
	player.healthyManeuver = 1.0
	player.prevManeuver = 1.0
	player.healthyImpulse = 1.0
	player.prevImpulse = 1.0
	player.healthyBeam = 1.0
	player.prevBeam = 1.0
	player.healthyMissile = 1.0
	player.prevMissile = 1.0
	player.healthyJump = 1.0
	player.prevJump = 1.0
	player.healthyWarp = 1.0
	player.prevWarp = 1.0
	goods[player] = goodsList
	player:addReputationPoints(100)
	player.initialRep = true
	allowNewPlayerShips(false)
end
function buildAsteroids()
	local lowerDensity = 70
	local upperDensity = 150
	local thickness = 2000
	--Arcs
	createRandomAlongArc(Asteroid, random(lowerDensity,upperDensity), 0, 0, 20000,   5,  85, thickness)
	createRandomAlongArc(Asteroid, random(lowerDensity,upperDensity), 0, 0, 20000,  95, 175, thickness)
	createRandomAlongArc(Asteroid, random(lowerDensity,upperDensity), 0, 0, 20000, 185, 265, thickness)
	createRandomAlongArc(Asteroid, random(lowerDensity,upperDensity), 0, 0, 20000, 275, 355, thickness)
	--Bulges
	local ax, ay = vectorFromAngle(random(20,70),20000)
	placeRandomAroundPoint(Asteroid,40,1,5000,ax,ay)
	ax, ay = vectorFromAngle(random(110,160),20000)
	placeRandomAroundPoint(Asteroid,40,1,5000,ax,ay)
	ax, ay = vectorFromAngle(random(200,250),20000)
	placeRandomAroundPoint(Asteroid,40,1,5000,ax,ay)
	ax, ay = vectorFromAngle(random(290,340),20000)
	placeRandomAroundPoint(Asteroid,40,1,5000,ax,ay)
end
--	Transport ship generation and handling 
function nearStations(station, compareStationList)
	remainingStations = {}
	if compareStationList[1]:isValid() then
		if station:getCallSign() ~= compareStationList[1]:getCallSign() then
			closest = compareStationList[1]
		else
			if compareStationList[2]:isValid() then
				closest = compareStationList[2]
			end
		end
	end
	for ri, obj in ipairs(compareStationList) do
		if obj:isValid() then
			if station:getCallSign() ~= obj:getCallSign() then
				table.insert(remainingStations,obj)
				if distance(station,obj) < distance(station,closest) then
					closest = obj
				end
			end
		else
			table.remove(compareStationList,ri)
		end
	end
	for ri, obj in ipairs(remainingStations) do
		if obj:getCallSign() == closest:getCallSign() then
			table.remove(remainingStations,ri)
		end
	end
	return closest, remainingStations
end
function randomNearStation5(nobj)
	distanceStations = {}
	cs, rs1 = nearStations(nobj,stationList)
	table.insert(distanceStations,cs)
	cs, rs2 = nearStations(nobj,rs1)
	table.insert(distanceStations,cs)
	cs, rs3 = nearStations(nobj,rs2)
	table.insert(distanceStations,cs)
	cs, rs4 = nearStations(nobj,rs3)
	table.insert(distanceStations,cs)
	cs, rs5 = nearStations(nobj,rs4)
	table.insert(distanceStations,cs)
	return distanceStations[irandom(1,5)]
end
function transportPlot(delta)
	if transportSpawnDelay > 0 then
		transportSpawnDelay = transportSpawnDelay - delta
	end
	if transportSpawnDelay < 0 then
		transportSpawnDelay = delta + random(5,15)
		transportCount = 0
		for tidx, obj in ipairs(transportList) do
			if obj:isValid() then
				if obj:isDocked(obj.target) then
					if obj.undock_delay > 0 then
						obj.undock_delay = obj.undock_delay - 1
					else
						obj.target = randomNearStation5(obj)
						obj.undock_delay = irandom(1,4)
						obj:orderDock(obj.target)
					end
				end
				transportCount = transportCount + 1
			end
		end
		lastTransportCount = transportCount
		if transportCount < #transportList then
			tempTransportList = {}
			for _, obj in ipairs(transportList) do
				if obj:isValid() then
					table.insert(tempTransportList,obj)
				end
			end
			transportList = tempTransportList
		end
		if #transportList < #stationList then
			target = nil
			repeat
				candidate = stationList[math.random(1,#stationList)]
				if candidate:isValid() then
					target = candidate
				end
			until(target ~= nil)
			rnd = irandom(1,5)
			if rnd == 1 then
				name = "Personnel"
			elseif rnd == 2 then
				name = "Goods"
			elseif rnd == 3 then
				name = "Garbage"
			elseif rnd == 4 then
				name = "Equipment"
			else
				name = "Fuel"
			end
			if irandom(1,100) < 30 then
				name = name .. " Jump Freighter " .. irandom(3, 5)
			else
				name = name .. " Freighter " .. irandom(1, 5)
			end
			obj = CpuShip():setTemplate(name):setFaction('Independent'):setCommsScript(""):setCommsFunction(commsShip)
			obj.target = target
			obj.undock_delay = irandom(1,4)
			rifl = math.floor(random(1,#goodsList))	-- random item from list
			goodsType = goodsList[rifl][1]
			if goodsType == nil then
				goodsType = "nickel"
			end
			rcoi = math.floor(random(30,90))	-- random cost of item
			goods[obj] = {{goodsType,1,rcoi}}
			obj:orderDock(obj.target)
			x, y = obj.target:getPosition()
			xd, yd = vectorFromAngle(random(0, 360), random(25000, 40000))
			obj:setPosition(x + xd, y + yd)
			table.insert(transportList, obj)
		end
	end
end
--	Station communication 
function commsStation()
    if comms_target.comms_data == nil then
        comms_target.comms_data = {}
    end
    mergeTables(comms_target.comms_data, {
        friendlyness = random(0.0, 100.0),
        weapons = {
            Homing = "neutral",
            HVLI = "neutral",
            Mine = "neutral",
            Nuke = "friend",
            EMP = "friend"
        },
        weapon_cost = {
            Homing = math.random(1,4),
            HVLI = math.random(1,3),
            Mine = math.random(2,5),
            Nuke = math.random(12,18),
            EMP = math.random(7,13)
        },
        services = {
            supplydrop = "friend",
            reinforcements = "friend",
        },
        service_cost = {
            supplydrop = math.random(80,120),
            reinforcements = math.random(125,175)
        },
        reputation_cost_multipliers = {
            friend = 1.0,
            neutral = 3.0
        },
        max_weapon_refill_amount = {
            friend = 1.0,
            neutral = 0.5
        }
    })
    comms_data = comms_target.comms_data
	setPlayers()
	for p3idx=1,8 do
		p3obj = getPlayerShip(p3idx)
		if p3obj ~= nil and p3obj:isValid() then
			if p3obj:isCommsOpening() then
				player = p3obj
			end
		end
	end
    if player:isEnemy(comms_target) then
        return false
    end
    if comms_target:areEnemiesInRange(5000) then
        setCommsMessage(_("station-comms", "We are under attack! No time for chatting!"));
        return true
    end
    if not player:isDocked(comms_target) then
        handleUndockedState()
    else
        handleDockedState()
    end
    return true
end
function handleDockedState()
    if player:isFriendly(comms_target) then
		oMsg = _("station-comms", "Good day, officer!\nWhat can we do for you today?\n")
    else
		oMsg = _("station-comms", "Welcome to our lovely station.\n")
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. _("station-comms", "Forgive us if we seem a little distracted. We are carefully monitoring the enemies nearby.")
	end
	setCommsMessage(oMsg)
	missilePresence = 0
	for _, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + player:getWeaponStorageMax(missile_type)
	end
	if missilePresence > 0 then
		if comms_target.nukeAvail == nil then
			if math.random(1,10) <= (4 - difficulty) then
				comms_target.nukeAvail = true
			else
				comms_target.nukeAvail = false
			end
			if math.random(1,10) <= (5 - difficulty) then
				comms_target.empAvail = true
			else
				comms_target.empAvail = false
			end
			if math.random(1,10) <= (6 - difficulty) then
				comms_target.homeAvail = true
			else
				comms_target.homeAvail = false
			end
			if comms_target == homeStation then
				comms_target.mineAvail = true
			else
				if math.random(1,10) <= (7 - difficulty) then
					comms_target.mineAvail = true
				else
					comms_target.mineAvail = false
				end
			end
			if math.random(1,10) <= (9 - difficulty) then
				comms_target.hvliAvail = true
			else
				comms_target.hvliAvail = false
			end
		end
		if comms_target.nukeAvail or comms_target.empAvail or comms_target.homeAvail or comms_target.mineAvail or comms_target.hvliAvail then
			addCommsReply(_("ammo-comms", "I need ordnance restocked"), function()
				setCommsMessage(_("ammo-comms", "What type of ordnance?"))
				if player:getWeaponStorageMax("Nuke") > 0 then
					if comms_target.nukeAvail then
						if math.random(1,10) <= 5 then
							nukePrompt = _("ammo-comms", "Can you supply us with some nukes? (")
						else
							nukePrompt = _("ammo-comms", "We really need some nukes (")
						end
						addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), nukePrompt, getWeaponCost("Nuke")), function()
							handleWeaponRestock("Nuke")
						end)
					end
				end
				if player:getWeaponStorageMax("EMP") > 0 then
					if comms_target.empAvail then
						if math.random(1,10) <= 5 then
							empPrompt = _("ammo-comms", "Please re-stock our EMP missiles. (")
						else
							empPrompt = _("ammo-comms", "Got any EMPs? (")
						end
						addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), empPrompt, getWeaponCost("EMP")), function()
							handleWeaponRestock("EMP")
						end)
					end
				end
				if player:getWeaponStorageMax("Homing") > 0 then
					if comms_target.homeAvail then
						if math.random(1,10) <= 5 then
							homePrompt = _("ammo-comms", "Do you have spare homing missiles for us? (")
						else
							homePrompt = _("ammo-comms", "Do you have extra homing missiles? (")
						end
						addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), homePrompt, getWeaponCost("Homing")), function()
							handleWeaponRestock("Homing")
						end)
					end
				end
				if player:getWeaponStorageMax("Mine") > 0 then
					if comms_target.mineAvail then
						minePromptChoice = math.random(1,5)
						if minePromptChoice == 1 then
							minePrompt = _("ammo-comms", "We could use some mines. (")
						elseif minePromptChoice == 2 then
							minePrompt = _("ammo-comms", "How about mines? (")
						elseif minePromptChoice == 3 then
							minePrompt = _("ammo-comms", "More mines (")
						elseif minePromptChoice == 4 then
							minePrompt = _("ammo-comms", "All the mines we can take. (")
						else
							minePrompt = _("ammo-comms", "Mines! What else? (")
						end
						addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), minePrompt, getWeaponCost("Mine")), function()
							handleWeaponRestock("Mine")
						end)
					end
				end
				if player:getWeaponStorageMax("HVLI") > 0 then
					if comms_target.hvliAvail then
						if math.random(1,10) <= 5 then
							hvliPrompt = _("ammo-comms", "What about HVLI? (")
						else
							hvliPrompt = _("ammo-comms", "Could you provide HVLI? (")
						end
						addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), hvliPrompt, getWeaponCost("HVLI")), function()
							handleWeaponRestock("HVLI")
						end)
					end
				end
			end)
		end
	end
	if player:isFriendly(comms_target) then
		addCommsReply(_("orders-comms", "What are my current orders?"), function()
			setOptionalOrders()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format(_("orders-comms", "\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply(_("minefield-comms", "What is a minefield?"), function()
				mMsg = string.format(_("minefield-comms", "For the automated sensors on station %s to register a minefield as completed across a gap, it must meet the following criteria:"),homeStation:getCallSign())
				mMsg = mMsg .. _("minefield-comms", "\n   1. Must contain at least 12 mines: Nautilus class standard load")
				mMsg = mMsg .. _("minefield-comms", "\n   2. Must be within a 1.5U radius of sector corner in gap")
				if difficulty > .5 then
					mMsg = mMsg .. _("minefield-comms", "\n   3. Must be centered: 6 on one side and 6 on the other")
				end
				if difficulty > 1 then
					mMsg = mMsg .. _("minefield-comms", "\n   4. Must be along 20U distance from station line connecting asteroids")
				end
				setCommsMessage(mMsg)
				if not northMet then
					addCommsReply(_("minefield-comms", "What do the sensors show for the north gap?"), function()
						if difficulty < 1 then
							cMsg = string.format(_("minefield-comms", "Count within radius: %i"),northObjCount)
						elseif difficulty > 1 then
							cMsg = string.format(_("minefield-comms", "Count near middle on the right: %i"),ndiv2s1)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near middle on the left: %i"),ndiv2s2)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near asteroids on the left: %i"),ndiv2s3)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near asteroids on the right: %i"),ndiv2s4)
							cMsg = cMsg .. _("minefield-comms", "\n\nYou need three in each sensor scan area")
						else
							cMsg = string.format(_("minefield-comms", "Count on the right: %i"),ndiv1s1)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount on the left: %i"),ndiv1s2)
							cMsg = cMsg .. _("minefield-comms", "\n\nYou need six in each sensor scan area")
						end
						cMsg = cMsg .. string.format(_("minefield-comms", "\nSensors refresh every %i seconds"),gapCheckInterval)
						setCommsMessage(cMsg)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if not southMet then
					addCommsReply(_("minefield-comms", "What do the sensors show for the south gap?"), function()
						if difficulty < 1 then
							cMsg = string.format(_("minefield-comms", "Count within radius: %i"),southObjCount)
						elseif difficulty > 1 then
							cMsg = string.format(_("minefield-comms", "Count near middle on the right: %i"),sdiv2s1)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near middle on the left: %i"),sdiv2s2)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near asteroids on the left: %i"),sdiv2s3)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near asteroids on the right: %i"),sdiv2s4)
							cMsg = cMsg .. _("minefield-comms", "\n\nYou need three in each sensor scan area")
						else
							cMsg = string.format(_("minefield-comms", "Count on the right: %i"),sdiv1s1)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount on the left: %i"),sdiv1s2)
							cMsg = cMsg .. _("minefield-comms", "\n\nYou need six in each sensor scan area")
						end
						cMsg = cMsg .. string.format(_("minefield-comms", "\nSensors refresh every %i seconds"),gapCheckInterval)
						setCommsMessage(cMsg)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if not eastMet then
					addCommsReply(_("minefield-comms", "What do the sensors show for the east gap?"), function()
						if difficulty < 1 then
							cMsg = string.format(_("minefield-comms", "Count within radius: %i"),eastObjCount)
						elseif difficulty > 1 then
							cMsg = string.format(_("minefield-comms", "Count near middle below: %i"),ediv2s1)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near middle above: %i"),ediv2s2)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near asteroids above: %i"),ediv2s3)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near asteroids below: %i"),ediv2s4)
							cMsg = cMsg .. _("minefield-comms", "\n\nYou need three in each sensor scan area")
						else
							cMsg = string.format(_("minefield-comms", "Count below: %i"),ediv1s1)	--was 2432: applies to normal difficulty
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount above: %i"),ediv1s2)	--was 2433: applies to normal difficulty
							cMsg = cMsg .. _("minefield-comms", "\n\nYou need six in each sensor scan area")
						end
						cMsg = cMsg .. string.format(_("minefield-comms", "\nSensors refresh every %i seconds"),gapCheckInterval)
						setCommsMessage(cMsg)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if not westMet then
					addCommsReply(_("minefield-comms", "What do the sensors show for the west gap?"), function()
						if difficulty < 1 then
							cMsg = string.format(_("minefield-comms", "Count within radius: %i"),westObjCount)
						elseif difficulty > 1 then
							cMsg = string.format(_("minefield-comms", "Count near middle below: %i"),wdiv2s1)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near middle above: %i"),wdiv2s2)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near asteroids above: %i"),wdiv2s3)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near asteroids below: %i"),wdiv2s4)
							cMsg = cMsg .. _("minefield-comms", "\n\nYou need three in each sensor scan area")
						else
							cMsg = string.format(_("minefield-comms", "Count below: %i"),wdiv1s1)	--was 2452: applies to normal difficulty
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount above: %i"),wdiv1s2)	--was 2453: applies to normal difficulty
							cMsg = cMsg .. _("minefield-comms", "\n\nYou need six in each sensor scan area")
						end
						cMsg = cMsg .. string.format(_("minefield-comms", "\nSensors refresh every %i seconds"),gapCheckInterval)
						setCommsMessage(cMsg)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("Back"), commsStation)
		end)
		if math.random(1,6) <= (4 - difficulty) then
			if player:getRepairCrewCount() < player.maxRepairCrew then
				hireCost = math.random(30,60)
			else
				hireCost = math.random(45,90)
			end
			addCommsReply(string.format(_("trade-comms", "Recruit repair crew member for %i reputation"),hireCost), function()
				if not player:takeReputationPoints(hireCost) then
					setCommsMessage(_("needRep-comms", "Insufficient reputation"))
				else
					player:setRepairCrewCount(player:getRepairCrewCount() + 1)
					setCommsMessage(_("trade-comms", "Repair crew member hired"))
				end
			end)
		end
	else
		if math.random(1,6) <= (4 - difficulty) then
			if player:getRepairCrewCount() < player.maxRepairCrew then
				hireCost = math.random(45,90)
			else
				hireCost = math.random(60,120)
			end
			addCommsReply(string.format(_("trade-comms", "Recruit repair crew member for %i reputation"),hireCost), function()
				if not player:takeReputationPoints(hireCost) then
					setCommsMessage(_("needRep-comms", "Insufficient reputation"))
				else
					player:setRepairCrewCount(player:getRepairCrewCount() + 1)
					setCommsMessage(_("trade-comms", "Repair crew member hired"))
				end
			end)
		end
	end
	if comms_target.publicRelations then
		addCommsReply(_("station-comms", "Tell me more about your station"), function()
			setCommsMessage(_("station-comms", "What would you like to know?"))
			addCommsReply(_("stationGeneralInfo-comms", "General information"), function()
				setCommsMessage(comms_target.generalInformation)
				addCommsReply(_("Back"), commsStation)
			end)
			if comms_target.stationHistory ~= nil then
				addCommsReply(_("stationStory-comms", "Station history"), function()
					setCommsMessage(comms_target.stationHistory)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if player:isFriendly(comms_target) then
				if comms_target.gossip ~= nil then
					if random(1,100) < 50 then
						addCommsReply(_("gossip-comms", "Gossip"), function()
							setCommsMessage(comms_target.gossip)
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
			end
		end)
	end
	if goods[comms_target] ~= nil then
		addCommsReply(_("trade-comms", "Buy, sell, trade"), function()
			oMsg = string.format(_("trade-comms", "Station %s:\nGoods or components available: quantity, cost in reputation\n"),comms_target:getCallSign())
			gi = 1		-- initialize goods index
			repeat
				goodsType = goods[comms_target][gi][1]
				goodsQuantity = goods[comms_target][gi][2]
				goodsRep = goods[comms_target][gi][3]
				oMsg = oMsg .. string.format(_("trade-comms", "     %s: %i, %i\n"),goodsType,goodsQuantity,goodsRep)
				gi = gi + 1
			until(gi > #goods[comms_target])
			oMsg = oMsg .. _("trade-comms", "Current Cargo:\n")
			gi = 1
			cargoHoldEmpty = true
			repeat
				playerGoodsType = goods[player][gi][1]
				playerGoodsQuantity = goods[player][gi][2]
				if playerGoodsQuantity > 0 then
					oMsg = oMsg .. string.format(_("trade-comms", "     %s: %i\n"),playerGoodsType,playerGoodsQuantity)
					cargoHoldEmpty = false
				end
				gi = gi + 1
			until(gi > #goods[player])
			if cargoHoldEmpty then
				oMsg = oMsg .. _("trade-comms", "     Empty\n")
			end
			playerRep = math.floor(player:getReputationPoints())
			oMsg = oMsg .. string.format(_("trade-comms", "Available Space: %i, Available Reputation: %i\n"),player.cargo,playerRep)
			setCommsMessage(oMsg)
			-- Buttons for reputation purchases
			gi = 1
			repeat
				local goodsType = goods[comms_target][gi][1]
				local goodsQuantity = goods[comms_target][gi][2]
				local goodsRep = goods[comms_target][gi][3]
				addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
					oMsg = string.format(_("trade-comms", "Type: %s, Quantity: %i, Rep: %i"),goodsType,goodsQuantity,goodsRep)
					if player.cargo < 1 then
						oMsg = oMsg .. _("trade-comms", "\nInsufficient cargo space for purchase")
					elseif goodsRep > playerRep then
						oMsg = oMsg .. _("needRep-comms", "\nInsufficient reputation for purchase")
					elseif goodsQuantity < 1 then
						oMsg = oMsg .. _("trade-comms", "\nInsufficient station inventory")
					else
						if not player:takeReputationPoints(goodsRep) then
							oMsg = oMsg .. _("needRep-comms", "\nInsufficient reputation for purchase")
						else
							player.cargo = player.cargo - 1
							decrementStationGoods(goodsType)
							incrementPlayerGoods(goodsType)
							oMsg = oMsg .. _("trade-comms", "\npurchased")
						end
					end
					setCommsMessage(oMsg)
					addCommsReply(_("Back"), commsStation)
				end)
				gi = gi + 1
			until(gi > #goods[comms_target])
			-- Buttons for food trades
			if tradeFood[comms_target] ~= nil then
				gi = 1
				foodQuantity = 0
				repeat
					if goods[player][gi][1] == "food" then
						foodQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if foodQuantity > 0 then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						addCommsReply(string.format(_("trade-comms", "Trade food for %s"),goods[comms_target][gi][1]), function()
							oMsg = string.format(_("trade-comms", "Type: %s,  Quantity: %i"),goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. _("trade-comms", "\nInsufficient station inventory")
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("food")
								oMsg = oMsg .. _("trade-comms", "\nTraded")
							end
							setCommsMessage(oMsg)
							addCommsReply(_("Back"), commsStation)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
			-- Buttons for luxury trades
			if tradeLuxury[comms_target] ~= nil then
				gi = 1
				luxuryQuantity = 0
				repeat
					if goods[player][gi][1] == "luxury" then
						luxuryQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if luxuryQuantity > 0 then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						addCommsReply(string.format(_("trade-comms", "Trade luxury for %s"),goods[comms_target][gi][1]), function()
							oMsg = string.format(_("trade-comms", "Type: %s,  Quantity: %i"),goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. _("trade-comms", "\nInsufficient station inventory")
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("luxury")
								oMsg = oMsg .. _("trade-comms", "\nTraded")
							end
							setCommsMessage(oMsg)
							addCommsReply(_("Back"), commsStation)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
			-- Buttons for medicine trades
			if tradeMedicine[comms_target] ~= nil then
				gi = 1
				medicineQuantity = 0
				repeat
					if goods[player][gi][1] == "medicine" then
						medicineQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if medicineQuantity > 0 then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						addCommsReply(string.format(_("trade-comms", "Trade medicine for %s"),goods[comms_target][gi][1]), function()
							oMsg = string.format(_("trade-comms", "Type: %s,  Quantity: %i"),goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. _("trade-comms", "\nInsufficient station inventory")
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("medicine")
								oMsg = oMsg .. _("trade-comms", "\nTraded")
							end
							setCommsMessage(oMsg)
							addCommsReply(_("Back"), commsStation)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
			addCommsReply(_("Back"), commsStation)
		end)
		gi = 1
		cargoHoldEmpty = true
		repeat
			playerGoodsType = goods[player][gi][1]
			playerGoodsQuantity = goods[player][gi][2]
			if playerGoodsQuantity > 0 then
				cargoHoldEmpty = false
			end
			gi = gi + 1
		until(gi > #goods[player])
		if not cargoHoldEmpty then
			addCommsReply(_("trade-comms", "Jettison cargo"), function()
				setCommsMessage(string.format(_("trade-comms", "Available space: %i\nWhat would you like to jettison?"),player.cargo))
				gi = 1
				repeat
					local goodsType = goods[player][gi][1]
					local goodsQuantity = goods[player][gi][2]
					if goodsQuantity > 0 then
						addCommsReply(goodsType, function()
							decrementPlayerGoods(goodsType)
							player.cargo = player.cargo + 1
							setCommsMessage(string.format(_("trade-comms", "One %s jettisoned"),goodsType))
							addCommsReply(_("Back"), commsStation)
						end)
					end
					gi = gi + 1
				until(gi > #goods[player])
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
end
function setOptionalOrders()
	optionalOrders = ""
	optionalOrdersPresent = false
	if plot2reminder ~= nil then
		if plot2reminder == _("upgradeOrders-comms", "Get ship maneuver upgrade") then	--not available this scenario
			if spinReveal == 0 then
				optionalOrders = _("upgradeOrders-comms", "\nOptional:\n") .. plot2reminder
			elseif spinReveal == 1 then
				optionalOrders = string.format(_("upgradeOrders-comms", "\nOptional:\nGet ship maneuver upgrade from %s for %s"),spinBase:getCallSign(),spinGood)
			elseif spinReveal == 2 then
				optionalOrders = string.format(_("upgradeOrders-comms", "\nOptional:\nGet ship maneuver upgrade from %s in sector %s for %s"),spinBase:getCallSign(),spinBase:getSectorName(),spinGood)
			elseif spinReveal == 3 then
				optionalOrders = string.format(_("upgradeOrders-comms", "\nOptional:\nGet ship maneuver upgrade from %s in sector %s for %s.\n    You might find %s at %s"),spinBase:getCallSign(),spinBase:getSectorName(),spinGood,spinGood,spinGoodBase:getCallSign())
			else
				optionalOrders = string.format(_("upgradeOrders-comms", "\nOptional:\nGet ship maneuver upgrade from %s in sector %s for %s.\n    You might find %s at %s in sector %s"),spinBase:getCallSign(),spinBase:getSectorName(),spinGood,spinGood,spinGoodBase:getCallSign(),spinGoodBase:getSectorName())
			end
		else
			optionalOrders = _("upgradeOrders-comms", "\nOptional:\n") .. plot2reminder
		end
		optionalOrdersPresent = true
	end
	if plot4reminder ~= nil then
		if optionalOrdersPresent then
			ifs = "\n"
		else
			ifs = _("upgradeOrders-comms", "\nOptional:\n")
			optionalOrdersPresent = true
		end
		if plot4reminder == string.format(_("upgradeOrders-comms", "Upgrade %s to rotate"),homeStation:getCallSign()) then
			if rotateReveal == 0 then
				optionalOrders = optionalOrders .. ifs .. plot4reminder
			elseif rotateReveal == 1 then
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Upgrade %s to auto-rotate by taking %s to %s"),homeStation:getCallSign(),rotateGood,rotateBase:getCallSign())
			elseif rotateReveal == 2 then
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Upgrade %s to auto-rotate by taking %s to %s in %s"),homeStation:getCallSign(),rotateGood,rotateBase:getCallSign(),rotateBase:getSectorName()) 
			elseif rotateReveal == 3 then
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Upgrade %s to auto-rotate by taking %s to %s in %s.\n    %s may bave %s"),homeStation:getCallSign(),rotateGood,rotateBase:getCallSign(),rotateBase:getSectorName(),rotateGoodBase:getCallSign(),rotateGood)
			else
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Upgrade %s to auto-rotate by taking %s to %s in %s.\n    %s in %s may bave %s"),homeStation:getCallSign(),rotateGood,rotateBase:getCallSign(),rotateBase:getSectorName(),rotateGoodBase:getCallSign(),rotateGoodBase:getSectorName(),rotateGood)
			end
		elseif plot4reminder == _("upgradeOrders-comms", "Get beam cycle time upgrade") then
			if beamTimeReveal == 0 then
				optionalOrders = optionalOrders .. ifs .. plot4reminder
			elseif beamTimeReveal == 1 then
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Get beam cycle time upgrade from %s for %s"),beamTimeBase:getCallSign(),beamTimeGood)
			elseif beamTimeReveal == 2 then
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Get beam cycle time upgrade from %s in %s for %s"),beamTimeBase:getCallSign(),beamTimeBase:getSectorName(),beamTimeGood)
			elseif beamTimeReveal == 3 then
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Get beam cycle time upgrade from %s in %s for %s\n    You might find %s at %s"),beamTimeBase:getCallSign(),beamTimeBase:getSectorName(),beamTimeGood,beamTimeGood,beamTimeGoodBase:getCallSign())
			else
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Get beam cycle time upgrade from %s in %s for %s\n    You might find %s at %s in %s"),beamTimeBase:getCallSign(),beamTimeBase:getSectorName(),beamTimeGood,beamTimeGood,beamTimeGoodBase:getCallSign(),beamTimeGoodBase:getSectorName())
			end
		elseif plot4reminder == _("upgradeOrders-comms", "Get hull upgrade") then
			if hullReveal == 0 then
				optionalOrders = optionalOrders .. ifs .. plot4reminder
			elseif hullReveal == 1 then
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Get %s to upgrade hull for %s"),hullBase:getCallSign(),hullGood)
			elseif hullReveal == 2 then
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Get %s in %s to upgrade hull for %s"),hullBase:getCallSign(),hullBase:getSectorName(),hullGood)
			elseif hullReveal == 3 then
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Get %s in %s to upgrade hull for %s\n    %s might have %s"),hullBase:getCallSign(),hullBase:getSectorName(),hullGood,hullGoodBase:getCallSign(),hullGood)
			else
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Get %s in %s to upgrade hull for %s\n    %s in %s might have %s"),hullBase:getCallSign(),hullBase:getSectorName(),hullGood,hullGoodBase:getCallSign(),hullGoodBase:getSectorName(),hullGood)
			end
		else
			optionalOrders = optionalOrders .. ifs .. plot4reminder
		end
	end
end
function isAllowedTo(state)
    if state == "friend" and player:isFriendly(comms_target) then
        return true
    end
    if state == "neutral" and not player:isEnemy(comms_target) then
        return true
    end
    return false
end
function handleWeaponRestock(weapon)
    if not player:isDocked(comms_target) then 
		setCommsMessage(_("station-comms", "You need to stay docked for that action."))
		return
	end
    if not isAllowedTo(comms_data.weapons[weapon]) then
        if weapon == "Nuke" then setCommsMessage(_("ammo-comms", "We do not deal in weapons of mass destruction."))
        elseif weapon == "EMP" then setCommsMessage(_("ammo-comms", "We do not deal in weapons of mass disruption."))
        else setCommsMessage(_("ammo-comms", "We do not deal in those weapons.")) end
        return
    end
    local points_per_item = getWeaponCost(weapon)
    local item_amount = math.floor(player:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - player:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage(_("ammo-comms", "All nukes are charged and primed for destruction."));
        else
            setCommsMessage(_("ammo-comms", "Sorry, sir, but you are as fully stocked as I can allow."));
        end
        addCommsReply(_("Back"), commsStation)
    else
        if not player:takeReputationPoints(points_per_item * item_amount) then
            setCommsMessage(_("needRep-comms", "Not enough reputation."))
            return
        end
        player:setWeaponStorage(weapon, player:getWeaponStorage(weapon) + item_amount)
        if player:getWeaponStorage(weapon) == player:getWeaponStorageMax(weapon) then
            setCommsMessage(_("ammo-comms", "You are fully loaded and ready to explode things."))
        else
            setCommsMessage(_("ammo-comms", "We generously resupplied you with some weapon charges.\nPut them to good use."))
        end
        addCommsReply(_("Back"), commsStation)
    end
end
function getWeaponCost(weapon)
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function handleUndockedState()
    --Handle communications when we are not docked with the station.
    if player:isFriendly(comms_target) then
        oMsg = _("station-comms", "Good day, officer.\nIf you need supplies, please dock with us first.")
    else
        oMsg = _("station-comms", "Greetings.\nIf you want to do business, please dock with us first.")
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. _("station-comms", "\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you.")
	end
	if comms_target.nukeAvail == nil then
		if math.random(1,10) <= (4 - difficulty) then
			comms_target.nukeAvail = true
		else
			comms_target.nukeAvail = false
		end
		if math.random(1,10) <= (5 - difficulty) then
			comms_target.empAvail = true
		else
			comms_target.empAvail = false
		end
		if math.random(1,10) <= (6 - difficulty) then
			comms_target.homeAvail = true
		else
			comms_target.homeAvail = false
		end
		if comms_target == homeStation then
			comms_target.mineAvail = true
		else
			if math.random(1,10) <= (7 - difficulty) then
				comms_target.mineAvail = true
			else
				comms_target.mineAvail = false
			end
		end
		if math.random(1,10) <= (9 - difficulty) then
			comms_target.hvliAvail = true
		else
			comms_target.hvliAvail = false
		end
	end
	setCommsMessage(oMsg)
 	addCommsReply(_("station-comms", "I need information"), function()
		setCommsMessage(_("station-comms", "What kind of information do you need?"))
		addCommsReply(_("ammo-comms", "What ordnance do you have available for restock?"), function()
			missileTypeAvailableCount = 0
			oMsg = ""
			if comms_target.nukeAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. _("ammo-comms", "\n   Nuke")
			end
			if comms_target.empAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. _("ammo-comms", "\n   EMP")
			end
			if comms_target.homeAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. _("ammo-comms", "\n   Homing")
			end
			if comms_target.mineAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. _("ammo-comms", "\n   Mine")
			end
			if comms_target.hvliAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. _("ammo-comms", "\n   HVLI")
			end
			if missileTypeAvailableCount == 0 then
				oMsg = _("ammo-comms", "We have no ordnance available for restock")
			elseif missileTypeAvailableCount == 1 then
				oMsg = string.format(_("ammo-comms", "We have the following type of ordnance available for restock:%s"), oMsg)
			else
				oMsg = string.format(_("ammo-comms", "We have the following types of ordnance available for restock:%s"), oMsg)
			end
			setCommsMessage(oMsg)
			addCommsReply(_("Back"), commsStation)
		end)
		goodsQuantityAvailable = 0
		gi = 1
		repeat
			if goods[comms_target][gi][2] > 0 then
				goodsQuantityAvailable = goodsQuantityAvailable + goods[comms_target][gi][2]
			end
			gi = gi + 1
		until(gi > #goods[comms_target])
		if goodsQuantityAvailable > 0 then
			addCommsReply(_("trade-comms", "What goods do you have available for sale or trade?"), function()
				oMsg = string.format(_("trade-comms", "Station %s:\nGoods or components available: quantity, cost in reputation\n"),comms_target:getCallSign())
				gi = 1		-- initialize goods index
				repeat
					goodsType = goods[comms_target][gi][1]
					goodsQuantity = goods[comms_target][gi][2]
					goodsRep = goods[comms_target][gi][3]
					oMsg = oMsg .. string.format(_("trade-comms", "   %14s: %2i, %3i\n"),goodsType,goodsQuantity,goodsRep)
					gi = gi + 1
				until(gi > #goods[comms_target])
				setCommsMessage(oMsg)
				addCommsReply(_("Back"), commsStation)
			end)
		end
		addCommsReply(_("helpfullWarning-comms", "See any enemies in your area?"), function()
			if player:isFriendly(comms_target) then
				enemiesInRange = 0
				for _, obj in ipairs(comms_target:getObjectsInRange(30000)) do
					if obj:isEnemy(player) then
						enemiesInRange = enemiesInRange + 1
					end
				end
				if enemiesInRange > 0 then
					if enemiesInRange > 1 then
						setCommsMessage(string.format(_("helpfullWarning-comms", "Yes, we see %i enemies within 30U"),enemiesInRange))
					else
						setCommsMessage(_("helpfullWarning-comms", "Yes, we see one enemy within 30U"))						
					end
					player:addReputationPoints(2.0)					
				else
					setCommsMessage(_("helpfullWarning-comms", "No enemies within 30U"))
					player:addReputationPoints(1.0)
				end
				addCommsReply(_("Back"), commsStation)
			else
				setCommsMessage(_("helpfullWarning-comms", "Not really"))
				player:addReputationPoints(1.0)
				addCommsReply(_("Back"), commsStation)
			end
		end)
		addCommsReply(_("trade-comms", "Where can I find particular goods?"), function()
			gkMsg = _("trade-comms", "Friendly stations generally have food or medicine or both. Neutral stations often trade their goods for food, medicine or luxury.")
			if comms_target.goodsKnowledge == nil then
				gkMsg = gkMsg .. _("trade-comms", " Beyond that, I have no knowledge of specific stations.\n\nCheck back later, someone else may have better knowledge")
				setCommsMessage(gkMsg)
				addCommsReply(_("Back"), commsStation)
				fillStationBrains()
			else
				if #comms_target.goodsKnowledge == 0 then
					gkMsg = gkMsg .. _("trade-comms", " Beyond that, I have no knowledge of specific stations")
				else
					gkMsg = gkMsg .. _("trade-comms", "\n\nWhat goods are you interested in?\nI've heard about these:")
					for gk=1,#comms_target.goodsKnowledge do
						addCommsReply(comms_target.goodsKnowledgeType[gk],function()
							setCommsMessage(string.format(_("trade-comms", "Station %s in sector %s has %s%s"),comms_target.goodsKnowledge[gk],comms_target.goodsKnowledgeSector[gk],comms_target.goodsKnowledgeType[gk],comms_target.goodsKnowledgeTrade[gk]))
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				setCommsMessage(gkMsg)
				addCommsReply(_("Back"), commsStation)
			end
		end)
		if comms_target.publicRelations then
			addCommsReply(_("stationGeneralInfo-comms", "General station information"), function()
				setCommsMessage(comms_target.generalInformation)
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end)
	if player:isFriendly(comms_target) then
		addCommsReply(_("orders-comms", "What are my current orders?"), function()
			setOptionalOrders()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format(_("orders-comms", "\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply(_("minefield-comms", "What is a minefield?"), function()
				mMsg = string.format(_("minefield-comms", "For the automated sensors on station %s to register a minefield as completed across a gap, it must meet the following criteria:"),homeStation:getCallSign())
				mMsg = mMsg .. _("minefield-comms", "\n   1. Must contain at least 12 mines: Nautilus class standard load")
				mMsg = mMsg .. _("minefield-comms", "\n   2. Must be within a 1.5U radius of sector corner in gap")
				if difficulty > .5 then
					mMsg = mMsg .. _("minefield-comms", "\n   3. Must be centered: 6 on one side and 6 on the other")
				end
				if difficulty > 1 then
					mMsg = mMsg .. _("minefield-comms", "\n   4. Must be along 20U distance from station line connecting asteroids")
				end
				setCommsMessage(mMsg)
				if not northMet then
					addCommsReply(_("minefield-comms", "What do the sensors show for the north gap?"), function()
						if difficulty < 1 then
							cMsg = string.format(_("minefield-comms", "Count within radius: %i"),northObjCount)
						elseif difficulty > 1 then
							cMsg = string.format(_("minefield-comms", "Count near middle on the right: %i"),ndiv2s1)	--was 3010: bad argument #2 format: number expected, got nil
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near middle on the left: %i"),ndiv2s2)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near asteroids on the left: %i"),ndiv2s3)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near asteroids on the right: %i"),ndiv2s4)
							cMsg = cMsg .. _("minefield-comms", "\n\nYou need three in each sensor scan area")
						else
							cMsg = string.format(_("minefield-comms", "Count on the right: %i"),ndiv1s1)	--was 3016: bad argument format: number expected, got nil
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount on the left: %i"),ndiv1s2)
							cMsg = cMsg .._("minefield-comms",  "\n\nYou need six in each sensor scan area")
						end
						cMsg = cMsg .. string.format(_("minefield-comms", "\nSensors refresh every %i seconds"),gapCheckInterval)
						setCommsMessage(cMsg)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if not southMet then
					addCommsReply(_("minefield-comms", "What do the sensors show for the south gap?"), function()
						if difficulty < 1 then
							cMsg = string.format(_("minefield-comms", "Count within radius: %i"),southObjCount)
						elseif difficulty > 1 then
							cMsg = string.format(_("minefield-comms", "Count near middle on the right: %i"),sdiv2s1)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near middle on the left: %i"),sdiv2s2)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near asteroids on the left: %i"),sdiv2s3)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near asteroids on the right: %i"),sdiv2s4)
							cMsg = cMsg .. _("minefield-comms", "\n\nYou need three in each sensor scan area")
						else
							cMsg = string.format(_("minefield-comms", "Count on the right: %i"),sdiv1s1)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount on the left: %i"),sdiv1s2)
							cMsg = cMsg .. _("minefield-comms", "\n\nYou need six in each sensor scan area")
						end
						cMsg = cMsg .. string.format(_("minefield-comms", "\nSensors refresh every %i seconds"),gapCheckInterval)
						setCommsMessage(cMsg)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if not eastMet then
					addCommsReply(_("minefield-comms", "What do the sensors show for the east gap?"), function()
						if difficulty < 1 then
							cMsg = string.format(_("minefield-comms", "Count within radius: %i"),eastObjCount)
						elseif difficulty > 1 then
							cMsg = string.format(_("minefield-comms", "Count near middle below: %i"),ediv2s1)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near middle above: %i"),ediv2s2)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near asteroids above: %i"),ediv2s3)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near asteroids below: %i"),ediv2s4)
							cMsg = cMsg .. _("minefield-comms", "\n\nYou need three in each sensor scan area")
						else
							cMsg = string.format(_("minefield-comms", "Count above: %i"),ediv1s1)	--was 3056: bad argument #2 to format: number expected, got nil
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount below: %i"),ediv1s2)	--was 3057: text "inversion"
							cMsg = cMsg .. _("minefield-comms", "\n\nYou need six in each sensor scan area")
						end
						cMsg = cMsg .. string.format(_("minefield-comms", "\nSensors refresh every %i seconds"),gapCheckInterval)
						setCommsMessage(cMsg)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if not westMet then
					addCommsReply(_("minefield-comms", "What do the sensors show for the west gap?"), function()
						if difficulty < 1 then
							cMsg = string.format(_("minefield-comms", "Count within radius: %i"),westObjCount)
						elseif difficulty > 1 then
							cMsg = string.format(_("minefield-comms", "Count near middle below: %i"),wdiv2s1)	--was 3070: bad argument #2 to format: number expected, got nil
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near middle above: %i"),wdiv2s2)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near asteroids above: %i"),wdiv2s3)
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount near asteroids below: %i"),wdiv2s4)
							cMsg = cMsg .. _("minefield-comms", "\n\nYou need three in each sensor scan area")
						else
							cMsg = string.format(_("minefield-comms", "Count above: %i"),wdiv1s1)	--was 3076: text "inversion"
							cMsg = cMsg .. string.format(_("minefield-comms", "\nCount below: %i"),wdiv1s2)	--was 3077: text "inversion"
							cMsg = cMsg .. _("minefield-comms", "\n\nYou need six in each sensor scan area")
						end
						cMsg = cMsg .. string.format(_("minefield-comms", "\nSensors refresh every %i seconds"),gapCheckInterval)
						setCommsMessage(cMsg)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("Back"), commsStation)
		end)
	end
	--Diagnostic data is used to help test and debug the script while it is under construction
	if diagnostic then
		addCommsReply("Diagnostic data", function()
			oMsg = string.format("Difficulty: %.1f",difficulty)
			if playWithTimeLimit then
				oMsg = oMsg .. string.format("  time remaining: %.1f",gameTimeLimit)
			end
			if plot1name == nil or plot1 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot1: " .. plot1name
				oMsg = oMsg .. string.format("\nobject count N: %i, S: %i, E: %i, W: %i",northObjCount,southObjCount,eastObjCount,westObjCount)
				oMsg = oMsg .. string.format("\nCheck Timer: %.1f wave timer: %.1f",gapCheckDelayTimer,waveTimer)
				oMsg = oMsg .. string.format("\nInterwave: %i",interWave)
			end
			oMsg = oMsg .. "\n" .. wfv
			setCommsMessage(oMsg)
			addCommsReply(_("Back"), commsStation)
		end)
	end
	if isAllowedTo(comms_target.comms_data.services.supplydrop) then
        addCommsReply(string.format(_("stationAssist-comms", "Can you send a supply drop? (%d rep)"), getServiceCost("supplydrop")), function()
            if player:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms", "You need to set a waypoint before you can request backup."));
            else
                setCommsMessage(_("stationAssist-comms", "To which waypoint should we deliver your supplies?"));
                for n=1,player:getWaypointCount() do
                    addCommsReply(string.format(_("stationAssist-comms", "WP %d"), n), function()
                        if player:takeReputationPoints(getServiceCost("supplydrop")) then
                            local position_x, position_y = comms_target:getPosition()
                            local target_x, target_y = player:getWaypoint(n)
                            local script = Script()
                            script:setVariable("position_x", position_x):setVariable("position_y", position_y)
                            script:setVariable("target_x", target_x):setVariable("target_y", target_y)
                            script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
                            setCommsMessage(string.format(_("stationAssist-comms", "We have dispatched a supply ship toward WP %d"), n));
                        else
                            setCommsMessage(_("needRep-comms", "Not enough reputation!"));
                        end
                        addCommsReply(_("Back"), commsStation)
                    end)
                end
            end
            addCommsReply(_("Back"), commsStation)
        end)
    end
    if isAllowedTo(comms_target.comms_data.services.reinforcements) then
        addCommsReply(string.format(_("stationAssist-comms", "Please send reinforcements! (%d rep)"), getServiceCost("reinforcements")), function()
            if player:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms", "You need to set a waypoint before you can request reinforcements."));
            else
                setCommsMessage(_("stationAssist-comms", "To which waypoint should we dispatch the reinforcements?"));
                for n=1,player:getWaypointCount() do
                    addCommsReply(string.format(_("stationAssist-comms", "WP %d"), n), function()
                        if player:takeReputationPoints(getServiceCost("reinforcements")) then
                            ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(player:getWaypoint(n))
                            setCommsMessage(string.format(_("stationAssist-comms", "We have dispatched %s to assist at WP %d"), ship:getCallSign(), n));
                        else
                            setCommsMessage(_("needRep-comms", "Not enough reputation!"));
                        end
                        addCommsReply(_("Back"), commsStation)
                    end)
                end
            end
            addCommsReply(_("Back"), commsStation)
        end)
    end
end
function getServiceCost(service)
-- Return the number of reputation points that a specified service costs for
-- the current player.
    return math.ceil(comms_data.service_cost[service])
end
function fillStationBrains()
	comms_target.goodsKnowledge = {}
	comms_target.goodsKnowledgeSector = {}
	comms_target.goodsKnowledgeType = {}
	comms_target.goodsKnowledgeTrade = {}
	knowledgeCount = 0
	knowledgeMax = 10
	for sti=1,#stationList do
		if stationList[sti] ~= nil and stationList[sti]:isValid() then
			if distance(comms_target,stationList[sti]) < 75000 then
				brainCheck = 3
			else
				brainCheck = 1
			end
			for gi=1,#goods[stationList[sti]] do
				if random(1,10) <= brainCheck then
					table.insert(comms_target.goodsKnowledge,stationList[sti]:getCallSign())
					table.insert(comms_target.goodsKnowledgeSector,stationList[sti]:getSectorName())
					table.insert(comms_target.goodsKnowledgeType,goods[stationList[sti]][gi][1])
					tradeString = ""
					stationTrades = false
					if tradeMedicine[stationList[sti]] ~= nil then
						tradeString = _("trade-comms", " and will trade it for medicine")
						stationTrades = true
					end
					if tradeFood[stationList[sti]] ~= nil then
						if stationTrades then
							tradeString = tradeString .. _("trade-comms", " or food")
						else
							tradeString = tradeString .. _("trade-comms", " and will trade it for food")
							stationTrades = true
						end
					end
					if tradeLuxury[stationList[sti]] ~= nil then
						if stationTrades then
							tradeString = tradeString .. _("trade-comms", " or luxury")
						else
							tradeString = tradeString .. _("trade-comms", " and will trade it for luxury")
						end
					end
					table.insert(comms_target.goodsKnowledgeTrade,tradeString)
					knowledgeCount = knowledgeCount + 1
					if knowledgeCount >= knowledgeMax then
						return
					end
				end
			end
		end
	end
end
function getFriendStatus()
    if player:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
--	Ship communication 
function commsShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	if goods[comms_target] == nil then
		goods[comms_target] = {goodsList[irandom(1,#goodsList)][1], 1, random(20,80)}
	end
	comms_data = comms_target.comms_data
	setPlayers()
	for p4idx=1,8 do
		p4obj = getPlayerShip(p4idx)
		if p4obj ~= nil and p4obj:isValid() then
			if p4obj:isCommsOpening() then
				player = p4obj
			end
		end
	end	
	if player:isFriendly(comms_target) then
		return friendlyComms(comms_data)
	end
	if player:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentifiedBy(player) then
		return enemyComms(comms_data)
	end
	return neutralComms(comms_data)
end
function friendlyComms(comms_data)
	if comms_data.friendlyness < 20 then
		setCommsMessage(_("shipAssist-comms", "What do you want?"));
	else
		setCommsMessage(_("shipAssist-comms", "Sir, how can we assist?"));
	end
	addCommsReply(_("shipAssist-comms", "Defend a waypoint"), function()
		if player:getWaypointCount() == 0 then
			setCommsMessage(_("shipAssist-comms", "No waypoints set. Please set a waypoint first."));
			addCommsReply(_("Back"), commsShip)
		else
			setCommsMessage(_("shipAssist-comms", "Which waypoint should we defend?"));
			for n=1,player:getWaypointCount() do
				addCommsReply(string.format(_("shipAssist-comms", "Defend WP %d"), n), function()
					comms_target:orderDefendLocation(player:getWaypoint(n))
					setCommsMessage(string.format(_("shipAssist-comms", "We are heading to assist at WP %d."), n));
					addCommsReply(_("Back"), commsShip)
				end)
			end
		end
	end)
	if comms_data.friendlyness > 0.2 then
		addCommsReply(_("shipAssist-comms", "Assist me"), function()
			setCommsMessage(_("shipAssist-comms", "Heading toward you to assist."));
			comms_target:orderDefendTarget(player)
			addCommsReply(_("Back"), commsShip)
		end)
	end
	addCommsReply(_("shipAssist-comms", "Report status"), function()
		msg = string.format(_("shipAssist-comms", "Hull: %d%%\n"), math.floor(comms_target:getHull() / comms_target:getHullMax() * 100))
		shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = msg .. string.format(_("shipAssist-comms", "Shield: %d%%\n"), math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
		elseif shields == 2 then
			msg = msg .. string.format(_("shipAssist-comms", "Front Shield: %d%%\n"), math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
			msg = msg .. string.format(_("shipAssist-comms", "Rear Shield: %d%%\n"), math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100))
		else
			for n=0,shields-1 do
				msg = msg .. string.format(_("shipAssist-comms", "Shield %s: %d%%\n"), n, math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100))
			end
		end

		missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for i, missile_type in ipairs(missile_types) do
			if comms_target:getWeaponStorageMax(missile_type) > 0 then
					msg = msg .. string.format(_("shipAssist-comms", "%s Missiles: %d/%d\n"), missile_type, math.floor(comms_target:getWeaponStorage(missile_type)), math.floor(comms_target:getWeaponStorageMax(missile_type)))
			end
		end
		
		setCommsMessage(msg);
		addCommsReply(_("Back"), commsShip)
	end)
	for idx, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			addCommsReply(string.format(_("shipAssist-comms", "Dock at %s"), obj:getCallSign()), function()
				setCommsMessage(string.format(_("shipAssist-comms", "Docking at %s."), obj:getCallSign()));
				comms_target:orderDock(obj)
				addCommsReply(_("Back"), commsShip)
			end)
		end
	end
	return true
end
function enemyComms(comms_data)
	if comms_data.friendlyness > 50 then
		faction = comms_target:getFaction()
		taunt_option = _("shipEnemy-comms", "We will see to your destruction!")
		taunt_success_reply = _("shipEnemy-comms", "Your bloodline will end here!")
		taunt_failed_reply = _("shipEnemy-comms", "Your feeble threats are meaningless.")
		if faction == "Kraylor" then
			setCommsMessage(_("shipEnemy-comms", "Ktzzzsss.\nYou will DIEEee weaklingsss!"));
		elseif faction == "Arlenians" then
			setCommsMessage(_("shipEnemy-comms", "We wish you no harm, but will harm you if we must.\nEnd of transmission."));
		elseif faction == "Exuari" then
			setCommsMessage(_("shipEnemy-comms", "Stay out of our way, or your death will amuse us extremely!"));
		elseif faction == "Ghosts" then
			setCommsMessage(_("shipEnemy-comms", "One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted."));
			taunt_option = _("shipEnemy-comms", "EXECUTE: SELFDESTRUCT")
			taunt_success_reply = _("shipEnemy-comms", "Rogue command received. Targeting source.")
			taunt_failed_reply = _("shipEnemy-comms", "External command ignored.")
		elseif faction == "Ktlitans" then
			setCommsMessage(_("shipEnemy-comms", "The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition."));
			taunt_option = _("shipEnemy-comms", "<Transmit 'The Itsy-Bitsy Spider' on all wavelengths>")
			taunt_success_reply = _("shipEnemy-comms", "We do not need permission to pluck apart such an insignificant threat.")
			taunt_failed_reply = _("shipEnemy-comms", "The hive has greater priorities than exterminating pests.")
		else
			setCommsMessage(_("shipEnemy-comms", "Mind your own business!"));
		end
		comms_data.friendlyness = comms_data.friendlyness - random(0, 10)
		addCommsReply(taunt_option, function()
			if random(0, 100) < 30 then
				comms_target:orderAttack(player)
				setCommsMessage(taunt_success_reply);
			else
				setCommsMessage(taunt_failed_reply);
			end
		end)
		return true
	end
	return false
end
function neutralComms(comms_data)
	shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		if comms_data.friendlyness > 66 then
			setCommsMessage(_("trade-comms", "Yes?"))
			-- Offer destination information
			addCommsReply(_("trade-comms", "Where are you headed?"), function()
				setCommsMessage(comms_target.target:getCallSign())
				addCommsReply(_("Back"), commsShip)
			end)
			-- Offer to trade goods if goods or equipment freighter
			if distance(player,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					gi = 1
					luxuryQuantity = 0
					repeat
						if goods[player][gi][1] == "luxury" then
							luxuryQuantity = goods[player][gi][2]
						end
						gi = gi + 1
					until(gi > #goods[player])
					if luxuryQuantity > 0 then
						gi = 1
						repeat
							local goodsType = goods[comms_target][gi][1]
							local goodsQuantity = goods[comms_target][gi][2]
							addCommsReply(string.format(_("trade-comms", "Trade luxury for %s"),goods[comms_target][gi][1]), function()	--was 3394: up value of function is not a table
								if goodsQuantity < 1 then
									setCommsMessage(_("trade-comms", "Insufficient inventory on freighter for trade"))
								else
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									decrementPlayerGoods("luxury")
									setCommsMessage(_("trade-comms", "Traded"))
								end
								addCommsReply(_("Back"), commsShip)
							end)
							gi = gi + 1
						until(gi > #goods[comms_target])
					else
						setCommsMessage(_("trade-comms", "Insufficient luxury to trade"))
					end
					addCommsReply(_("Back"), commsShip)
				else
					-- Offer to sell goods
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]
						addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
							if player.cargo < 1 then
								setCommsMessage(_("trade-comms", "Insufficient cargo space for purchase"))
							elseif goodsQuantity < 1 then
								setCommsMessage(_("trade-comms", "Insufficient inventory on freighter"))
							else
								if not player:takeReputationPoints(goodsRep) then
									setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
								else
									player.cargo = player.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage(_("trade-comms", "Purchased"))
								end
							end
							addCommsReply(_("Back"), commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		elseif comms_data.friendlyness > 33 then
			setCommsMessage(_("shipAssist-comms", "What do you want?"))
			-- Offer to sell destination information
			destRep = random(1,5)
			addCommsReply(string.format(_("trade-comms", "Where are you headed? (cost: %f reputation)"),destRep), function()	--was 3443: make reputation integer
				if not player:takeReputationPoints(destRep) then
					setCommsMessage(_("needRep-comms", "Insufficient reputation"))
				else
					setCommsMessage(comms_target.target:getCallSign())
				end
				addCommsReply(_("Back"), commsShip)
			end)
			-- Offer to sell goods if goods or equipment freighter
			if distance(player,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]
						addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
							if player.cargo < 1 then
								setCommsMessage(_("trade-comms", "Insufficient cargo space for purchase"))
							elseif goodsQuantity < 1 then
								setCommsMessage(_("trade-comms", "Insufficient inventory on freighter"))
							else
								if not player:takeReputationPoints(goodsRep) then
									setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
								else
									player.cargo = player.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage(_("trade-comms", "Purchased"))
								end
							end
							addCommsReply(_("Back"), commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				else
					-- Offer to sell goods double price
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]*2
						addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),goods[comms_target][gi][1],goods[comms_target][gi][3]*2), function()
							if player.cargo < 1 then
								setCommsMessage(_("trade-comms", "Insufficient cargo space for purchase"))
							elseif goodsQuantity < 1 then
								setCommsMessage(_("trade-comms", "Insufficient inventory on freighter"))
							else
								if not player:takeReputationPoints(goodsRep) then
									setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
								else
									player.cargo = player.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage(_("trade-comms", "Purchased"))
								end
							end
							addCommsReply(_("Back"), commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		else
			setCommsMessage(_("trade-comms", "Why are you bothering me?"))
			-- Offer to sell goods if goods or equipment freighter double price
			if distance(player,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]*2
						addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),goods[comms_target][gi][1],goods[comms_target][gi][3]*2), function()
							if player.cargo < 1 then
								setCommsMessage(_("trade-comms", "Insufficient cargo space for purchase"))
							elseif goodsQuantity < 1 then
								setCommsMessage(_("trade-comms", "Insufficient inventory on freighter"))
							else
								if not player:takeReputationPoints(goodsRep) then
									setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
								else
									player.cargo = player.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage(_("trade-comms", "Purchased"))
								end
							end
							addCommsReply(_("Back"), commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		end
	else
		if comms_data.friendlyness > 50 then
			setCommsMessage(_("ship-comms", "Sorry, we have no time to chat with you.\nWe are on an important mission."));
		else
			setCommsMessage(_("ship-comms", "We have nothing for you.\nGood day."));
		end
	end
	return true
end
--	Cargo management 
function incrementPlayerGoods(goodsType)
	local gi = 1
	repeat
		if goods[player][gi][1] == goodsType then
			goods[player][gi][2] = goods[player][gi][2] + 1
		end
		gi = gi + 1
	until(gi > #goods[player])
end
function decrementPlayerGoods(goodsType)
	local gi = 1
	repeat
		if goods[player][gi][1] == goodsType then
			goods[player][gi][2] = goods[player][gi][2] - 1
		end
		gi = gi + 1
	until(gi > #goods[player])
end
function decrementStationGoods(goodsType)
	local gi = 1
	repeat
		if goods[comms_target][gi][1] == goodsType then
			goods[comms_target][gi][2] = goods[comms_target][gi][2] - 1
		end
		gi = gi + 1
	until(gi > #goods[comms_target])
end
function decrementShipGoods(goodsType)
	local gi = 1
	repeat
		if goods[comms_target][gi][1] == goodsType then
			goods[comms_target][gi][2] = goods[comms_target][gi][2] - 1
		end
		gi = gi + 1
	until(gi > #goods[comms_target])
end
--set up players with name, goods, cargo space, reputation and either a warp drive or a jump drive if applicable
function setPlayers()
	concurrentPlayerCount = 0
	for p1idx=1,8 do
		pobj = getPlayerShip(p1idx)
		if pobj ~= nil and pobj:isValid() then
			concurrentPlayerCount = concurrentPlayerCount + 1
			if goods[pobj] == nil then
				goods[pobj] = goodsList
			end
			if pobj.initialRep == nil then
				pobj:addReputationPoints(250-(difficulty*6))
				pobj.initialRep = true
			end
			if not pobj.nameAssigned then
				pobj.nameAssigned = true
				pobj.spinUpgrade = false
				pobj.beamTimeUpgrade = false
				pobj.hullUpgrade = false
				tempPlayerType = pobj:getTypeName()
				if tempPlayerType == "MP52 Hornet" then
					if #playerShipNamesForMP52Hornet > 0 then
						ni = math.random(1,#playerShipNamesForMP52Hornet)
						pobj:setCallSign(playerShipNamesForMP52Hornet[ni])
						table.remove(playerShipNamesForMP52Hornet,ni)
					end
					pobj.shipScore = 7
					pobj.maxCargo = 3
					pobj.autoCoolant = false
					pobj:setWarpDrive(true)
				elseif tempPlayerType == "Piranha" then
					if #playerShipNamesForPiranha > 0 then
						ni = math.random(1,#playerShipNamesForPiranha)
						pobj:setCallSign(playerShipNamesForPiranha[ni])
						table.remove(playerShipNamesForPiranha,ni)
					end
					pobj.shipScore = 16
					pobj.maxCargo = 8
				elseif tempPlayerType == "Flavia P.Falcon" then
					if #playerShipNamesForFlaviaPFalcon > 0 then
						ni = math.random(1,#playerShipNamesForFlaviaPFalcon)
						pobj:setCallSign(playerShipNamesForFlaviaPFalcon[ni])
						table.remove(playerShipNamesForFlaviaPFalcon,ni)
					end
					pobj.shipScore = 13
					pobj.maxCargo = 15
				elseif tempPlayerType == "Phobos M3P" then
					if #playerShipNamesForPhobosM3P > 0 then
						ni = math.random(1,#playerShipNamesForPhobosM3P)
						pobj:setCallSign(playerShipNamesForPhobosM3P[ni])
						table.remove(playerShipNamesForPhobosM3P,ni)
					end
					pobj.shipScore = 19
					pobj.maxCargo = 10
					pobj:setWarpDrive(true)
				elseif tempPlayerType == "Atlantis" then
					if #playerShipNamesForAtlantis > 0 then
						ni = math.random(1,#playerShipNamesForAtlantis)
						pobj:setCallSign(playerShipNamesForAtlantis[ni])
						table.remove(playerShipNamesForAtlantis,ni)
					end
					pobj.shipScore = 52
					pobj.maxCargo = 6
				elseif tempPlayerType == "Player Cruiser" then
					if #playerShipNamesForCruiser > 0 then
						ni = math.random(1,#playerShipNamesForCruiser)
						pobj:setCallSign(playerShipNamesForCruiser[ni])
						table.remove(playerShipNamesForCruiser,ni)
					end
					pobj.shipScore = 40
					pobj.maxCargo = 6
				elseif tempPlayerType == "Player Missile Cr." then
					if #playerShipNamesForMissileCruiser > 0 then
						ni = math.random(1,#playerShipNamesForMissileCruiser)
						pobj:setCallSign(playerShipNamesForMissileCruiser[ni])
						table.remove(playerShipNamesForMissileCruiser,ni)
					end
					pobj.shipScore = 45
					pobj.maxCargo = 8
				elseif tempPlayerType == "Player Fighter" then
					if #playerShipNamesForFighter > 0 then
						ni = math.random(1,#playerShipNamesForFighter)
						pobj:setCallSign(playerShipNamesForFighter[ni])
						table.remove(playerShipNamesForFighter,ni)
					end
					pobj.shipScore = 7
					pobj.maxCargo = 3
					pobj.autoCoolant = false
					pobj:setJumpDrive(true)
					pobj:setJumpDriveRange(3000,40000)
				elseif tempPlayerType == "Benedict" then
					if #playerShipNamesForBenedict > 0 then
						ni = math.random(1,#playerShipNamesForBenedict)
						pobj:setCallSign(playerShipNamesForBenedict[ni])
						table.remove(playerShipNamesForBenedict,ni)
					end
					pobj.shipScore = 10
					pobj.maxCargo = 9
				elseif tempPlayerType == "Kiriya" then
					if #playerShipNamesForKiriya > 0 then
						ni = math.random(1,#playerShipNamesForKiriya)
						pobj:setCallSign(playerShipNamesForKiriya[ni])
						table.remove(playerShipNamesForKiriya,ni)
					end
					pobj.shipScore = 10
					pobj.maxCargo = 9
				elseif tempPlayerType == "Striker" then
					if #playerShipNamesForStriker > 0 then
						ni = math.random(1,#playerShipNamesForStriker)
						pobj:setCallSign(playerShipNamesForStriker[ni])
						table.remove(playerShipNamesForStriker,ni)
					end
					pobj.shipScore = 8
					pobj.maxCargo = 4
					pobj:setJumpDrive(true)
					pobj:setJumpDriveRange(3000,40000)
				elseif tempPlayerType == "ZX-Lindworm" then
					if #playerShipNamesForLindworm > 0 then
						ni = math.random(1,#playerShipNamesForLindworm)
						pobj:setCallSign(playerShipNamesForLindworm[ni])
						table.remove(playerShipNamesForLindworm,ni)
					end
					pobj.shipScore = 8
					pobj.maxCargo = 3
					pobj.autoCoolant = false
					pobj:setWarpDrive(true)
				elseif tempPlayerType == "Repulse" then
					if #playerShipNamesForRepulse > 0 then
						ni = math.random(1,#playerShipNamesForRepulse)
						pobj:setCallSign(playerShipNamesForRepulse[ni])
						table.remove(playerShipNamesForRepulse,ni)
					end
					pobj.shipScore = 14
					pobj.maxCargo = 12
				elseif tempPlayerType == "Ender" then
					if #playerShipNamesForEnder > 0 then
						ni = math.random(1,#playerShipNamesForEnder)
						pobj:setCallSign(playerShipNamesForEnder[ni])
						table.remove(playerShipNamesForEnder,ni)
					end
					pobj.shipScore = 100
					pobj.maxCargo = 20
				elseif tempPlayerType == "Nautilus" then
					if #playerShipNamesForNautilus > 0 then
						ni = math.random(1,#playerShipNamesForNautilus)
						pobj:setCallSign(playerShipNamesForNautilus[ni])
						table.remove(playerShipNamesForNautilus,ni)
					end
					pobj.shipScore = 12
					pobj.maxCargo = 7
				elseif tempPlayerType == "Hathcock" then
					if #playerShipNamesForHathcock > 0 then
						ni = math.random(1,#playerShipNamesForHathcock)
						pobj:setCallSign(playerShipNamesForHathcock[ni])
						table.remove(playerShipNamesForHathcock,ni)
					end
					pobj.shipScore = 30
					pobj.maxCargo = 6
				else
					if #playerShipNamesForLeftovers > 0 then
						ni = math.random(1,#playerShipNamesForLeftovers)
						pobj:setCallSign(playerShipNamesForLeftovers[ni])
						table.remove(playerShipNamesForLeftovers,ni)
					end
					pobj.shipScore = 24
					pobj.maxCargo = 5
					pobj:setWarpDrive(true)
				end
				if pobj.cargo == nil then
					pobj.cargo = pobj.maxCargo
					pobj.maxRepairCrew = pobj:getRepairCrewCount()
					pobj.healthyShield = 1.0
					pobj.prevShield = 1.0
					pobj.healthyReactor = 1.0
					pobj.prevReactor = 1.0
					pobj.healthyManeuver = 1.0
					pobj.prevManeuver = 1.0
					pobj.healthyImpulse = 1.0
					pobj.prevImpulse = 1.0
					if pobj:getBeamWeaponRange(0) > 1 then
						pobj.healthyBeam = 1.0
						pobj.prevBeam = 1.0
					end
					if pobj:getWeaponTubeCount() > 0 then
						pobj.healthyMissile = 1.0
						pobj.prevMissile = 1.0
					end
					if pobj:hasWarpDrive() then
						pobj.healthyWarp = 1.0
						pobj.prevWarp = 1.0
					end
					if pobj:hasJumpDrive() then
						pobj.healthyJump = 1.0
						pobj.prevJump = 1.0
					end
				end
			end
		end
	end
	setConcurrenetPlayerCount = concurrentPlayerCount
end
function healthCheck(delta)
	healthCheckTimer = healthCheckTimer - delta
	if healthCheckTimer < 0 then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p:getRepairCrewCount() > 0 then
					fatalityChance = 0
					if p:getShieldCount() > 1 then
						cShield = (p:getSystemHealth("frontshield") + p:getSystemHealth("rearshield"))/2
					else
						cShield = p:getSystemHealth("frontshield")
					end
					fatalityChance = fatalityChance + (p.prevShield - cShield)
					p.prevShield = cShield
					fatalityChance = fatalityChance + (p.prevReactor - p:getSystemHealth("reactor"))
					p.prevReactor = p:getSystemHealth("reactor")
					fatalityChance = fatalityChance + (p.prevManeuver - p:getSystemHealth("maneuver"))
					p.prevManeuver = p:getSystemHealth("maneuver")
					fatalityChance = fatalityChance + (p.prevImpulse - p:getSystemHealth("impulse"))
					p.prevImpulse = p:getSystemHealth("impulse")
					if p:getBeamWeaponRange(0) > 1 then
						if p.healthyBeam == nil then
							p.healthyBeam = 1.0
							p.prevBeam = 1.0
						end
						fatalityChance = fatalityChance + (p.prevBeam - p:getSystemHealth("beamweapons"))
						p.prevBeam = p:getSystemHealth("beamweapons")
					end
					if p:getWeaponTubeCount() > 0 then
						if p.healthyMissile == nil then
							p.healthyMissile = 1.0
							p.prevMissile = 1.0
						end
						fatalityChance = fatalityChance + (p.prevMissile - p:getSystemHealth("missilesystem"))
						p.prevMissile = p:getSystemHealth("missilesystem")
					end
					if p:hasWarpDrive() then
						if p.healthyWarp == nil then
							p.healthyWarp = 1.0
							p.prevWarp = 1.0
						end
						fatalityChance = fatalityChance + (p.prevWarp - p:getSystemHealth("warp"))
						p.prevWarp = p:getSystemHealth("warp")
					end
					if p:hasJumpDrive() then
						if p.healthyJump == nil then
							p.healthyJump = 1.0
							p.prevJump = 1.0
						end
						fatalityChance = fatalityChance + (p.prevJump - p:getSystemHealth("jumpdrive"))
						p.prevJump = p:getSystemHealth("jumpdrive")
					end
					if p:getRepairCrewCount() == 1 then
						fatalityChance = fatalityChance/2	-- increase chances of last repair crew standing
					end
					if fatalityChance > 0 then
						crewFate(p,fatalityChance)
					end
				end
			end
		end
		healthCheckTimer = delta + healthCheckTimerInterval
	end
end
function crewFate(p, fatalityChance)
	if math.random() < (fatalityChance) then
		p:setRepairCrewCount(p:getRepairCrewCount() - 1)
		if p:hasPlayerAtPosition("Engineering") then
			repairCrewFatality = "repairCrewFatality"
			p:addCustomMessage("Engineering",repairCrewFatality,_("repairCrew-msgEngineer", "One of your repair crew has perished"))
		end
		if p:hasPlayerAtPosition("Engineering+") then
			repairCrewFatalityPlus = "repairCrewFatalityPlus"
			p:addCustomMessage("Engineering+",repairCrewFatalityPlus,_("repairCrew-msgEngineer+", "One of your repair crew has perished"))
		end
	end
end
function initialInstructions(delta)
	plot1name = "initialInstructions"
	initialOrderTimer = initialOrderTimer - delta
	if initialOrderTimer < 0 then
		player:addToShipLog(string.format(_("goal-shiplog", "Since %s is so isolated and so close to enemy territory, we need you to lay a minefield across each gap in the surrounding asteroids"),homeStation:getCallSign()),"Magenta")
		primaryOrders = _("goal-comms", "Lay minefield across each gap in surrounding asteroids.")
		plot1 = checkGaps
		plot1name = "checkGaps"
		waveTimer = interWave
		plot2 = waves
		plot2name = "waves"
	end
end
function checkGaps(delta)
	gapCheckDelayTimer = gapCheckDelayTimer - delta
	if gapCheckDelayTimer < 0 then
		if not southMet then
			prevSouthClosed = southClosed
			southMineCount = 0
			southClosed = checkSouthernGap()
			if prevSouthClosed and southClosed then
				southMet = true
				player:addToShipLog(string.format(_("minefieldOrder-shiplog", "Congratulations, You've closed the gap at heading 180 from %s"),homeStation:getCallSign()),"Magenta")
				primaryOrders = primaryOrders .. _("minefieldOrders-comms", " South gap closed.")
				player:addReputationPoints(20-(difficulty*6))
			end
		end
		if not northMet then
			prevNorthClosed = northClosed
			northMineCount = 0
			northClosed = checkNorthernGap()
			if prevNorthClosed and northClosed then
				northMet = true
				player:addToShipLog(string.format(_("minefieldOrders-shiplog", "Congratulations, You've closed the gap at heading 0 from %s"),homeStation:getCallSign()),"Magenta")
				primaryOrders = primaryOrders .. _("minefieldOrders-comms", " North gap closed.")
				player:addReputationPoints(20-(difficulty*6))
			end
		end
		if not westMet then
			prevWestClosed = westClosed
			westMineCount = 0
			westClosed = checkWesternernGap()
			if prevWestClosed and westClosed then
				westMet = true
				player:addToShipLog(string.format(_("minefieldOrders-shiplog", "Congratulations, You've closed the gap at heading 270 from %s"),homeStation:getCallSign()),"Magenta")
				primaryOrders = primaryOrders .. _("minefieldOrders-comms", " West gap closed.")
				player:addReputationPoints(20-(difficulty*6))
			end
		end
		if not eastMet then
			prevEastClosed = eastClosed
			eastMineCount = 0
			eastClosed = checkEasternernGap()
			if prevEastClosed and eastClosed then
				eastMet = true
				player:addToShipLog(string.format(_("minefieldOrders-shiplog", "Congratulations, You've closed the gap at heading 90 from %s"),homeStation:getCallSign()),"Magenta")
				primaryOrders = primaryOrders .. _("minefieldOrders-comms", " East gap closed.")
				player:addReputationPoints(20-(difficulty*6))
			end
		end
		if southMet and northMet and westMet and eastMet then
			if playWithTimeLimit then
				for pidx=1,8 do
					p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						p:addReputationPoints(100)
						p:addToShipLog(string.format(_("minefieldOrders-shiplog", "You've closed the gaps. Now for the Quixotic part: go destroy the enemy bases surrounding us while keeping %s alive. You'll find them straight out from the gaps"),homeStation:getCallSign()),"Magenta")
						primaryOrders = string.format(_("minefieldOrders-comms", "Protect %s. Destroy enemy bases straight out from gaps"),homeStation:getCallSign())
					end
				end
				plot1name = "destroyEnemyBases"
				plot1 = destroyEnemyBases
			else
				victory("Human Navy")
			end
		end
			if homeStation == nil or not homeStation:isValid() then
				local mine_count = 0
				for pidx=1,32 do
					local p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						mine_count = mine_count + p:getWeaponStorage("Mine")
					end
				end
				if mine_count == 0 then
					victory("Kraylor")
				end
			end
		gapCheckDelayTimer = delta + gapCheckInterval
	end
end
function checkEasternernGap()
	gapClosed = false
	if difficulty < 1 then
		eastObjCount = 0
		eastObjs = getObjectsInRadius(20000, 0, 1500)
		for _, obj in ipairs(eastObjs) do
			if obj.typeName == "Mine" then
				eastObjCount = eastObjCount + 1
			end
		end
		if eastObjCount >= 12 then
			gapClosed = true
		end
	elseif difficulty > 1 then
		ediv2s1 = 0	--division 2, section 1
		eastObjs = getObjectsInRadius(20000, 375, 375)
		for _, obj in ipairs(eastObjs) do
			if obj.typeName == "Mine" then
				ediv2s1 = ediv2s1 + 1
			end
		end
		ediv2s2 = 0	--division 2, section 2
		eastObjs = getObjectsInRadius(20000, -375, 375)
		for _, obj in ipairs(eastObjs) do
			if obj.typeName == "Mine" then
				ediv2s2 = ediv2s2 + 1
			end
		end
		ediv2s3 = 0	--division 3, section 3
		eastObjs = getObjectsInRadius(20000, -1025, 375)
		for _, obj in ipairs(eastObjs) do
			if obj.typeName == "Mine" then
				ediv2s3 = ediv2s3 + 1
			end
		end
		ediv2s4 = 0	--division 4, section 4
		eastObjs = getObjectsInRadius(20000, 1025, 375)
		for _, obj in ipairs(eastObjs) do
			if obj.typeName == "Mine" then
				ediv2s4 = ediv2s4 + 1
			end
		end
		if ediv2s1 >= 3 and ediv2s2 >= 3 and ediv2s3 >= 3 and ediv2s4 >= 3 then
			gapClosed = true
		end
	else
		ediv1s1 = 0	--division 1, section 1
		eastObjs = getObjectsInRadius(20000, 750, 750)
		for _, obj in ipairs(eastObjs) do
			if obj.typeName == "Mine" then
				ediv1s1 = ediv1s1 + 1
			end
		end
		ediv1s2 = 0	--division 1, section 2
		eastObjs = getObjectsInRadius(20000, -750, 750)
		for _, obj in ipairs(eastObjs) do
			if obj.typeName == "Mine" then
				ediv1s2 = ediv1s2 + 1
			end
		end
		if ediv1s1 >= 6 and ediv1s2 >= 6 then
			gapClosed = true
		end
	end
	return gapClosed
end
function checkWesternernGap()
	gapClosed = false
	if difficulty < 1 then
		westObjCount = 0
		westObjs = getObjectsInRadius(-20000, 0, 1500)
		for _, obj in ipairs(westObjs) do
			if obj.typeName == "Mine" then
				westObjCount = westObjCount + 1
			end
		end
		if westObjCount >= 12 then
			gapClosed = true
		end
	elseif difficulty > 1 then
		wdiv2s1 = 0	--division 2, section 1
		westObjs = getObjectsInRadius(-20000, 375, 375)
		for _, obj in ipairs(westObjs) do
			if obj.typeName == "Mine" then
				wdiv2s1 = wdiv2s1 + 1
			end
		end
		wdiv2s2 = 0	--division 2, section 2
		westObjs = getObjectsInRadius(-20000, -375, 375)
		for _, obj in ipairs(westObjs) do
			if obj.typeName == "Mine" then
				wdiv2s2 = wdiv2s2 + 1
			end
		end
		wdiv2s3 = 0	--division 3, section 3
		westObjs = getObjectsInRadius(-20000, -1025, 375)
		for _, obj in ipairs(westObjs) do
			if obj.typeName == "Mine" then
				wdiv2s3 = wdiv2s3 + 1
			end
		end
		wdiv2s4 = 0	--division 4, section 4
		westObjs = getObjectsInRadius(-20000, 1025, 375)
		for _, obj in ipairs(westObjs) do
			if obj.typeName == "Mine" then
				wdiv2s4 = wdiv2s4 + 1
			end
		end
		if wdiv2s1 >= 3 and wdiv2s2 >= 3 and wdiv2s3 >= 3 and wdiv2s4 >= 3 then
			gapClosed = true
		end
	else
		wdiv1s1 = 0	--division 1, section 1
		westObjs = getObjectsInRadius(-20000, 750, 750)
		for _, obj in ipairs(westObjs) do
			if obj.typeName == "Mine" then
				wdiv1s1 = wdiv1s1 + 1
			end
		end
		wdiv1s2 = 0	--division 1, section 2
		westObjs = getObjectsInRadius(-20000, -750, 750)
		for _, obj in ipairs(westObjs) do
			if obj.typeName == "Mine" then
				wdiv1s2 = wdiv1s2 + 1
			end
		end
		if wdiv1s1 >= 6 and wdiv1s2 >= 6 then
			gapClosed = true
		end
	end
	return gapClosed
end
function checkNorthernGap()
	gapClosed = false
	if difficulty < 1 then
		northObjCount = 0
		northObjs = getObjectsInRadius(0, -20000, 1500)
		for _, obj in ipairs(northObjs) do
			if obj.typeName == "Mine" then
				northObjCount = northObjCount + 1
			end
		end
		if northObjCount >= 12 then
			gapClosed = true
		end
	elseif difficulty > 1 then
		ndiv2s1 = 0	--division 2, section 1
		northObjs = getObjectsInRadius(375, -20000, 375)
		for _, obj in ipairs(northObjs) do
			if obj.typeName == "Mine" then
				ndiv2s1 = ndiv2s1 + 1
			end
		end
		ndiv2s2 = 0	--division 2, section 2
		northObjs = getObjectsInRadius(-375, -20000, 375)
		for _, obj in ipairs(northObjs) do
			if obj.typeName == "Mine" then
				ndiv2s2 = ndiv2s2 + 1
			end
		end
		ndiv2s3 = 0	--division 3, section 3
		northObjs = getObjectsInRadius(-1025, -20000, 375)
		for _, obj in ipairs(northObjs) do
			if obj.typeName == "Mine" then
				ndiv2s3 = ndiv2s3 + 1
			end
		end
		ndiv2s4 = 0	--division 4, section 4
		northObjs = getObjectsInRadius(1025, -20000, 375)
		for _, obj in ipairs(northObjs) do
			if obj.typeName == "Mine" then
				ndiv2s4 = ndiv2s4 + 1
			end
		end
		if ndiv2s1 >= 3 and ndiv2s2 >= 3 and ndiv2s3 >= 3 and ndiv2s4 >= 3 then
			gapClosed = true
		end
	else
		ndiv1s1 = 0	--division 1, section 1
		northObjs = getObjectsInRadius(750, -20000, 750)
		for _, obj in ipairs(northObjs) do
			if obj.typeName == "Mine" then
				ndiv1s1 = ndiv1s1 + 1
			end
		end
		ndiv1s2 = 0	--division 1, section 2
		northObjs = getObjectsInRadius(-750, -20000, 750)
		for _, obj in ipairs(northObjs) do
			if obj.typeName == "Mine" then
				ndiv1s2 = ndiv1s2 + 1
			end
		end
		if ndiv1s1 >= 6 and ndiv1s2 >= 6 then
			gapClosed = true
		end
	end
	return gapClosed
end
function checkSouthernGap()
	gapClosed = false
	if difficulty < 1 then
		southObjCount = 0
		southObjs = getObjectsInRadius(0, 20000, 1500)
		for _, obj in ipairs(southObjs) do
			if obj.typeName == "Mine" then
				southObjCount = southObjCount + 1
			end
		end
		if southObjCount >= 12 then
			gapClosed = true
		end
	elseif difficulty > 1 then
		sdiv2s1 = 0	--division 2, section 1
		southObjs = getObjectsInRadius(375, 20000, 375)
		for _, obj in ipairs(southObjs) do
			if obj.typeName == "Mine" then
				sdiv2s1 = sdiv2s1 + 1
			end
		end
		sdiv2s2 = 0	--division 2, section 2
		southObjs = getObjectsInRadius(-375, 20000, 375)
		for _, obj in ipairs(southObjs) do
			if obj.typeName == "Mine" then
				sdiv2s2 = sdiv2s2 + 1
			end
		end
		sdiv2s3 = 0	--division 3, section 3
		southObjs = getObjectsInRadius(-1025, 20000, 375)
		for _, obj in ipairs(southObjs) do
			if obj.typeName == "Mine" then
				sdiv2s3 = sdiv2s3 + 1
			end
		end
		sdiv2s4 = 0	--division 4, section 4
		southObjs = getObjectsInRadius(1025, 20000, 375)
		for _, obj in ipairs(southObjs) do
			if obj.typeName == "Mine" then
				sdiv2s4 = sdiv2s4 + 1
			end
		end
		if sdiv2s1 >= 3 and sdiv2s2 >= 3 and sdiv2s3 >= 3 and sdiv2s4 >= 3 then
			gapClosed = true
		end
	else
		sdiv1s1 = 0	--division 1, section 1
		southObjs = getObjectsInRadius(750, 20000, 750)
		for _, obj in ipairs(southObjs) do
			if obj.typeName == "Mine" then
				sdiv1s1 = sdiv1s1 + 1
			end
		end
		sdiv1s2 = 0	--division 1, section 2
		southObjs = getObjectsInRadius(-750, 20000, 750)
		for _, obj in ipairs(southObjs) do
			if obj.typeName == "Mine" then
				sdiv1s2 = sdiv1s2 + 1
			end
		end
		if sdiv1s1 >= 6 and sdiv1s2 >= 6 then
			gapClosed = true
		end
	end
	return gapClosed
end
--  Quixotic addition
function destroyEnemyBases(delta)
	if homeStation:isValid() then
		validEnemies = 0
		for i=1,#enemyStationList do
			if enemyStationList[i]:isValid() then
				validEnemies = validEnemies + 1
			end
		end
		if validEnemies == 0 then
			victory("Human Navy")
		end
	else
		victory("Kraylor")
	end
end
-- keep the pressure up on the players
function waves(delta)
	waveTimer = waveTimer - delta
	if waveTimer < 0 then
		waveTimer = delta + interWave + random(1,60)
		spawnCompass = math.random(1,4)
		if spawnCompass == 1 then
			hf = spawnEnemies(0,-40000,difficulty,"Kraylor")
			if northMet then
				for _, enemy in ipairs(hf) do
					enemy:orderFlyTowardsBlind(0,0)
				end
				waveTimer = waveTimer - random(1,60)
			else
				for _, enemy in ipairs(hf) do
					enemy:orderFlyTowards(0,0)
				end
			end
		elseif spawnCompass == 2 then
			hf = spawnEnemies(0,40000,difficulty,"Ghosts")
			if southMet then
				for _, enemy in ipairs(hf) do
					enemy:orderFlyTowardsBlind(0,0)
				end
				waveTimer = waveTimer - random(1,60)
			else
				for _, enemy in ipairs(hf) do
					enemy:orderFlyTowards(0,0)
				end
			end
		elseif spawnCompass == 3 then
			hf = spawnEnemies(40000,0,difficulty,"Exuari")
			if eastMet then
				for _, enemy in ipairs(hf) do
					enemy:orderFlyTowardsBlind(0,0)
				end
				waveTimer = waveTimer - random(1,60)
			else
				for _, enemy in ipairs(hf) do
					enemy:orderFlyTowards(0,0)
				end
			end
		else
			hf = spawnEnemies(-40000,0,difficulty,"Ktlitans")
			if westMet then
				for _, enemy in ipairs(hf) do
					enemy:orderFlyTowardsBlind(0,0)
				end
				waveTimer = waveTimer - random(1,60)
			else
				for _, enemy in ipairs(hf) do
					enemy:orderFlyTowards(0,0)
				end
			end
		end
		if homeStation:areEnemiesInRange(2000) then
			wakeEnemyFleet = getObjectsInRange(2000)
			for _, enemy in ipairs(wakeEnemyFleet) do
				if enemy:isEnemy(homeStation) then
					enemy:orderRoaming()
				end
			end
		end
	end
end
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	if enemy_power == nil then 
		enemy_power = 1
	end
	enemyStrength = math.max(danger * enemy_power * playerPower(),5)
	enemyPosition = 0
	sp = irandom(300,500)			--random spacing of spawned group
	deployConfig = random(1,100)	--randomly choose between squarish formation and hexagonish formation
	enemyList = {}
	-- Reminder: stsl and stnl are ship template score and name list
	while enemyStrength > 0 do
		shipTemplateType = irandom(1,#stsl)
		while stsl[shipTemplateType] > enemyStrength * 1.1 + 5 do
			shipTemplateType = irandom(1,#stsl)
		end		
		ship = CpuShip():setFaction(enemyFaction):setTemplate(stnl[shipTemplateType]):orderRoaming()
		enemyPosition = enemyPosition + 1
		if deployConfig < 50 then
			ship:setPosition(xOrigin+fleetPosDelta1x[enemyPosition]*sp,yOrigin+fleetPosDelta1y[enemyPosition]*sp)
		else
			ship:setPosition(xOrigin+fleetPosDelta2x[enemyPosition]*sp,yOrigin+fleetPosDelta2y[enemyPosition]*sp)
		end
		table.insert(enemyList, ship)
		enemyStrength = enemyStrength - stsl[shipTemplateType]
	end
	return enemyList
end
--evaluate the players for enemy strength and size spawning purposes
function playerPower()
	playerShipScore = 0
	for p5idx=1,8 do
		p5obj = getPlayerShip(p5idx)
		if p5obj ~= nil and p5obj:isValid() then
			if p5obj.shipScore == nil then
				playerShipScore = playerShipScore + 24
			else
				playerShipScore = playerShipScore + p5obj.shipScore
			end
		end
	end
	if playerShipScore == 0 then
		return 24
	else
		return playerShipScore
	end
end
function update(delta)
	if delta == 0 then
		--game paused
		setPlayers()
		return
	end
	allowNewPlayerShips(false)    --no more ships once you've unpaused
	healthCheck(delta)
	transportPlot(delta)
	if playWithTimeLimit then
		gameTimeLimit = gameTimeLimit - delta
		if gameTimeLimit < 0 then
			victory("Kraylor")
		end
	end
	if plot1 ~= nil then	--main plot
		plot1(delta)
	end
	if plot2 ~= nil then	--waves
		plot2(delta)
	end
end
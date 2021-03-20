-- Name: Shakedown Cruise
-- Description: The shipyard with permission from Human Navy Command has placed a green crew on a new ship type. The mission is to evaluate the ship type Chavez along with the new crew.
--- 
--- Mission designed as a first time mission for new players. The broad outlines of the mission are the same each time, but some of the specifics vary for each mission run.
---
--- Duration: 1.5 - 2 hours to choice between mission completion and continuation. If you continue, add another hour or so.
---
--- Version 0
-- Type: Mission
-- Variation[Easy]: Relatively weaker enemies than normal
-- Variation[Hard]: Relatively stronger enemies than normal


require("utils.lua")

--------------------
-- Initialization --
--------------------
function init()
	scenario_version = "0.0.1"
	print(string.format("     -----     Scenario: Intro     -----     Version %s     -----",scenario_version))
	print(_VERSION)
	setVariations()
	setConstants()	--missle type names, template names and scores, deployment directions, player ship names, etc.
	constructEnvironment()
	mainPlot = trackFreighterPlot
	pod_scanned = false
	finalize_player_ship_work = false
	technician_vacation = true
	vacation_notification = false
	primaryOrders = "Evaluate Chavez class ship. Train officers. Protect ships if necessary"
	secondaryOrders = ""
	optionalOrders = ""
	mainGMButtons()
end
function setPlayer(p)
	if p == nil then
		return
	end
	p:setTemplate("Hathcock")
	p:setTypeName("Chavez")
	p:setJumpDrive(false)
	p:setImpulseMaxSpeed(70)
	p:setCanCombatManeuver(false)
	p:setRotationMaxSpeed(20)					--faster spin (vs 15)
	p:setAcceleration(10)						--faster (vs 8)
--                  	Arc,  Dir,  Range,Cyc,Dmg
	p:setBeamWeapon(0,	 30,	0,	 1000,	6,	6)
	p:setBeamWeapon(1,	  0,	0,		0,	0,	0)
	p:setBeamWeapon(2,	  0,	0,		0,	0,	0)
	p:setBeamWeapon(3,	  0,	0,		0,	0,	0)
	p:setWeaponTubeCount(1)
	p:setWeaponTubeDirection(0, 0)
	p:setWeaponTubeExclusiveFor(0,"Homing")
	p:setWeaponStorageMax("Homing",	6)
	p:setWeaponStorage("Homing",	6)
	p:setWeaponStorageMax("Nuke",	0)
	p:setWeaponStorage("Nuke",		0)
	p:setWeaponStorageMax("Mine",	0)
	p:setWeaponStorage("Mine",		0)
	p:setWeaponStorageMax("EMP",	0)
	p:setWeaponStorage("EMP",		0)
	p:setWeaponStorageMax("HVLI",	0)
	p:setWeaponStorage("HVLI",		0)
	p:setCanSelfDestruct(false)
	p:setCanScan(false)
	p:setCanHack(false)
	p:setCanLaunchProbe(false)
	p:setCanDock(false)
	p:setRepairCrewCount(5)
	p.maxRepairCrew = p:getRepairCrewCount()
	p.maxCargo = playerShipStats["Chavez"].cargo
	p.cargo = p.maxCargo
	p.maxRepairCrew = 2
	p.initialCoolant = p:getMaxCoolant()	
	p:setLongRangeRadarRange(playerShipStats["Chavez"].long_range_radar)
	p:setShortRangeRadarRange(playerShipStats["Chavez"].short_range_radar)
	p.tractor = playerShipStats["Chavez"].tractor
	p.mining = playerShipStats["Chavez"].mining
	local name = tableRemoveRandom(player_ship_names)
	if name ~= nil then
		p:setCallSign(name)
	end
	if finalize_player_ship_work then
		p:setJumpDrive(true)
		p.max_jump_range = 25000
		p.min_jump_range = 2500
		p:setJumpDriveRange(comms_source.min_jump_range,comms_source.max_jump_range)
		p:setJumpDriveCharge(comms_source.max_jump_range)
		if p:hasPlayerAtPosition("Engineering") then
			p.restart_engine_message = "restart_engine_message"
			p:addCustomMessage("Engineering",p.restart_engine_message,"You took the initiative and activated minimal jump drive capability")
		end
		if p:hasPlayerAtPosition("Engineering+") then
			p.restart_engine_message_plus = "restart_engine_message_plus"
			p:addCustomMessage("Engineering+",p.restart_engine_message_plus,"You took the initiative and activated minimal jump drive capability")
		end
		if p:hasPlayerAtPosition("PowerManagement") then
			p.restart_engine_message_pm = "restart_engine_message_pm"
			p:addCustomMessage("PowerManagement",p.restart_engine_message_pm,"You took the initiative and activated minimal jump drive capability")
		end
	else
		for _, system in ipairs(system_list) do
			p:setSystemPower(system, .25)
			p:commandSetSystemPowerRequest(system, .25)
		end
	end
	p:addToShipLog(string.format("Mission: This is a shakedown cruise for %s, a %s class vessel recently launched from the shipyards of station %s. Be sure to train officers at each station. You should also protect ships in need if necessary.",p:getCallSign(),p:getTypeName(),shipyard_station:getCallSign()),"Magenta")
end
function setVariations()
	if string.find(getScenarioVariation(),"Easy") then
		difficulty = .5
	elseif string.find(getScenarioVariation(),"Hard") then
		difficulty = 2
	else
		difficulty = 1		--default (normal)
	end
end
function setConstants()
	fully_functional_player_ship = false
	repeatExitBoundary = 100
	prefix_length = 0
	suffix_index = 0
	system_list = {
		"reactor",
		"beamweapons",
		"missilesystem",
		"maneuver",
		"impulse",
		"warp",
		"jumpdrive",
		"frontshield",
		"rearshield",
	}
	player_ship_names = {
		"Throck",
		"Thumb",
		"Knight",
		"Chalk",
		"Strack",
		"Thrust",
		"Shirk",
		"Flack",
		"Fright",
		"Clash",
		"Shorn",
		"Crush",
		"Portent",
		"Sluff",
		"Trivet",
		"Strive",
		"Blight",
		"Brink",
		"Grendel",
	}
	rescue_freighter_names = {
		"Navigator",
		"Sault",
		"Acavus",
		"Argus",
		"Adula",
		"Bovic",
		"Calumet",
		"Deplhic",
		"Edith",
		"Finima",
		"Golfito",
		"Hydrus",
		"Jindal",
		"Nuria",
		"Osaka",
		"Quinquereme",
		"Regina",
		"Suavic",
		"Torben",
		"Vedic",
	}
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	pool_selectivity = "full"
	template_pool_size = 5
	ship_template = {	--ordered by relative strength
		["Gnat"] =				{strength = 2,		create = gnat},
		["Lite Drone"] =		{strength = 3,		create = droneLite},
		["Jacket Drone"] =		{strength = 4,		create = droneJacket},
		["Ktlitan Drone"] =		{strength = 4,		create = stockTemplate},
		["Heavy Drone"] =		{strength = 5,		create = droneHeavy},
		["MT52 Hornet"] =		{strength = 5,		create = stockTemplate},
		["MU52 Hornet"] =		{strength = 5,		create = stockTemplate},
		["MV52 Hornet"] =		{strength = 6,		create = hornetMV52},
		["Adder MK3"] =			{strength = 5,		create = stockTemplate},
		["Adder MK4"] =			{strength = 6,		create = stockTemplate},
		["Fighter"] =			{strength = 6,		create = stockTemplate},
		["Ktlitan Fighter"] =	{strength = 6,		create = stockTemplate},
		["K2 Fighter"] =		{strength = 7,		create = k2fighter},
		["Adder MK5"] =			{strength = 7,		create = stockTemplate},
		["WX-Lindworm"] =		{strength = 7,		create = stockTemplate},
		["K3 Fighter"] =		{strength = 8,		create = k3fighter},
		["Adder MK6"] =			{strength = 8,		create = stockTemplate},
		["Ktlitan Scout"] =		{strength = 8,		create = stockTemplate},
		["WZ-Lindworm"] =		{strength = 9,		create = wzLindworm},
		["Adder MK7"] =			{strength = 9,		create = stockTemplate},
		["Adder MK8"] =			{strength = 10,		create = stockTemplate},
		["Adder MK9"] =			{strength = 11,		create = stockTemplate},
		["Phobos R2"] =			{strength = 13,		create = phobosR2},
		["Missile Cruiser"] =	{strength = 14,		create = stockTemplate},
		["Waddle 5"] =			{strength = 15,		create = waddle5},
		["Jade 5"] =			{strength = 15,		create = jade5},
		["Phobos T3"] =			{strength = 15,		create = stockTemplate},
		["Piranha F8"] =		{strength = 15,		create = stockTemplate},
		["Piranha F12"] =		{strength = 15,		create = stockTemplate},
		["Piranha F12.M"] =		{strength = 16,		create = stockTemplate},
		["Phobos M3"] =			{strength = 16,		create = stockTemplate},
		["Farco 3"] =			{strength = 16,		create = farco3},
		["Farco 5"] =			{strength = 16,		create = farco5},
		["Karnack"] =			{strength = 17,		create = stockTemplate},
		["Gunship"] =			{strength = 17,		create = stockTemplate},
		["Phobos T4"] =			{strength = 18,		create = phobosT4},
		["Cruiser"] =			{strength = 18,		create = stockTemplate},
		["Nirvana R5"] =		{strength = 19,		create = stockTemplate},
		["Farco 8"] =			{strength = 19,		create = farco8},
		["Nirvana R5A"] =		{strength = 20,		create = stockTemplate},
		["Adv. Gunship"] =		{strength = 20,		create = stockTemplate},
		["Ktlitan Worker"] =	{strength = 21,		create = stockTemplate},
		["Farco 11"] =			{strength = 21,		create = farco11},
		["Storm"] =				{strength = 22,		create = stockTemplate},
		["Stalker R5"] =		{strength = 22,		create = stockTemplate},
		["Stalker Q5"] =		{strength = 22,		create = stockTemplate},
		["Farco 13"] =			{strength = 24,		create = farco13},
		["Ranus U"] =			{strength = 25,		create = stockTemplate},
		["Stalker Q7"] =		{strength = 25,		create = stockTemplate},
		["Stalker R7"] =		{strength = 25,		create = stockTemplate},
		["Whirlwind"] =			{strength = 26,		create = whirlwind},
		["Adv. Striker"] =		{strength = 27,		create = stockTemplate},
		["Elara P2"] =			{strength = 28,		create = stockTemplate},
		["Tempest"] =			{strength = 30,		create = tempest},
		["Strikeship"] =		{strength = 30,		create = stockTemplate},
		["Fiend G3"] =			{strength = 33,		create = stockTemplate},
		["Fiend G4"] =			{strength = 35,		create = stockTemplate},
		["Cucaracha"] =			{strength = 36,		create = cucaracha},
		["Fiend G5"] =			{strength = 37,		create = stockTemplate},
		["Fiend G6"] =			{strength = 39,		create = stockTemplate},
		["Predator"] =			{strength = 42,		create = predator},
		["Ktlitan Breaker"] =	{strength = 45,		create = stockTemplate},
		["Hurricane"] =			{strength = 46,		create = hurricane},
		["Ktlitan Feeder"] =	{strength = 48,		create = stockTemplate},
		["Atlantis X23"] =		{strength = 50,		create = stockTemplate},
		["K2 Breaker"] =		{strength = 55,		create = k2breaker},
		["Ktlitan Destroyer"] =	{strength = 50,		create = stockTemplate},
		["Atlantis Y42"] =		{strength = 60,		create = atlantisY42},
		["Blockade Runner"] =	{strength = 65,		create = stockTemplate},
		["Starhammer II"] =		{strength = 70,		create = stockTemplate},
		["Enforcer"] =			{strength = 75,		create = enforcer},
		["Dreadnought"] =		{strength = 80,		create = stockTemplate},
		["Starhammer III"] =	{strength = 85,		create = starhammerIII},
		["Starhammer V"] =		{strength = 90,		create = starhammerV},
		["Battlestation"] =		{strength = 100,	create = stockTemplate},
		["Tyr"] =				{strength = 150,	create = tyr},
		["Odin"] =				{strength = 250,	create = stockTemplate},
	}
	formation_delta = {
		["square"] = {
			x = {0,1,0,-1, 0,1,-1, 1,-1,2,0,-2, 0,2,-2, 2,-2,2, 2,-2,-2,1,-1, 1,-1,0, 0,3,-3,1, 1,3,-3,-1,-1, 3,-3,2, 2,3,-3,-2,-2, 3,-3,3, 3,-3,-3,4,0,-4, 0,4,-4, 4,-4,-4,-4,-4,-4,-4,-4,4, 4,4, 4,4, 4, 1,-1, 2,-2, 3,-3,1,-1,2,-2,3,-3,5,-5,0, 0,5, 5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,5, 5,5, 5,5, 5,5, 5, 1,-1, 2,-2, 3,-3, 4,-4,1,-1,2,-2,3,-3,4,-4},
			y = {0,0,1, 0,-1,1,-1,-1, 1,0,2, 0,-2,2,-2,-2, 2,1,-1, 1,-1,2, 2,-2,-2,3,-3,0, 0,3,-3,1, 1, 3,-3,-1,-1,3,-3,2, 2, 3,-3,-2,-2,3,-3, 3,-3,0,4, 0,-4,4,-4,-4, 4, 1,-1, 2,-2, 3,-3,1,-1,2,-2,3,-3,-4,-4,-4,-4,-4,-4,4, 4,4, 4,4, 4,0, 0,5,-5,5,-5, 5,-5, 1,-1, 2,-2, 3,-3, 4,-4,1,-1,2,-2,3,-3,4,-4,-5,-5,-5,-5,-5,-5,-5,-5,5, 5,5, 5,5, 5,5, 5},
		},
		["hexagonal"] = {
			x = {0,2,-2,1,-1, 1,-1,4,-4,0, 0,2,-2,-2, 2,3,-3, 3,-3,6,-6,1,-1, 1,-1,3,-3, 3,-3,4,-4, 4,-4,5,-5, 5,-5,8,-8,4,-4, 4,-4,5,5 ,-5,-5,2, 2,-2,-2,0, 0,6, 6,-6,-6,7, 7,-7,-7,10,-10,5, 5,-5,-5,6, 6,-6,-6,7, 7,-7,-7,8, 8,-8,-8,9, 9,-9,-9,3, 3,-3,-3,1, 1,-1,-1,12,-12,6,-6, 6,-6,7,-7, 7,-7,8,-8, 8,-8,9,-9, 9,-9,10,-10,10,-10,11,-11,11,-11,4,-4, 4,-4,2,-2, 2,-2,0, 0},
			y = {0,0, 0,1, 1,-1,-1,0, 0,2,-2,2,-2, 2,-2,1,-1,-1, 1,0, 0,3, 3,-3,-3,3,-3,-3, 3,2,-2,-2, 2,1,-1,-1, 1,0, 0,4,-4,-4, 4,3,-3, 3,-3,4,-4, 4,-4,4,-4,2,-2, 2,-2,1,-1, 1,-1, 0,  0,5,-5, 5,-5,4,-4, 4,-4,3,-3, 3,-7,2,-2, 2,-2,1,-1, 1,-1,5,-5, 5,-5,5,-5, 5,-5, 0,  0,6, 6,-6,-6,5, 5,-5,-5,4, 4,-4,-4,3, 3,-3,-3, 2,  2,-2, -2, 1,  1,-1, -1,6, 6,-6,-6,6, 6,-6,-6,6,-6},
		},
		["pyramid"] = {
			[1] = {
				{angle =  0, distance = 0},
			},
			[2] = {
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
			},
			[3] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},				
			},
			[4] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle =  0, distance = 2},	
			},
			[5] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
			},
			[6] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle =  0, distance = 2},	
			},
			[7] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
			},
			[8] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle =  0, distance = 2},	
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
			},
			[9] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle = -4, distance = 4},
				{angle =  4, distance = 4},
			},
			[10] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle =  0, distance = 2},	
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle = -2, distance = 3},
				{angle =  2, distance = 3},
			},
			[11] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle = -4, distance = 4},
				{angle =  4, distance = 4},
				{angle = -3, distance = 4},
				{angle =  3, distance = 4},
			},
			[12] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle =  0, distance = 2},	
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle = -2, distance = 3},
				{angle =  2, distance = 3},
				{angle = -1, distance = 3},
				{angle =  1, distance = 3},
			},
			[13] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle =  0, distance = 3},
				{angle = -2, distance = 4},
				{angle =  2, distance = 4},
				{angle = -1, distance = 5},
				{angle =  1, distance = 5},
				{angle =  0, distance = 6},
			},
			[14] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle =  0, distance = 2},	
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle =  0, distance = 4},
				{angle = -2, distance = 4},
				{angle =  2, distance = 4},
				{angle = -1, distance = 5},
				{angle =  1, distance = 5},
				{angle =  0, distance = 6},
			},
			[15] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle =  0, distance = 2},	
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle =  0, distance = 3},
				{angle =  0, distance = 4},
				{angle = -2, distance = 4},
				{angle =  2, distance = 4},
				{angle = -1, distance = 5},
				{angle =  1, distance = 5},
				{angle =  0, distance = 6},
			},
		},
	}		
	max_pyramid_tier = 15	
	playerShipStats = {	
		["MP52 Hornet"] 		= { strength = 7, 	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 4000, tractor = false,	mining = false	},
		["Piranha"]				= { strength = 16,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 6000, tractor = false,	mining = false	},
		["Flavia P.Falcon"]		= { strength = 13,	cargo = 15,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000, tractor = true,		mining = true	},
		["Phobos M3P"]			= { strength = 19,	cargo = 10,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false	},
		["Atlantis"]			= { strength = 52,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true	},
		["Player Cruiser"]		= { strength = 40,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = false	},
		["Player Missile Cr."]	= { strength = 45,	cargo = 8,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, tractor = false,	mining = false	},
		["Player Fighter"]		= { strength = 7,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, tractor = false,	mining = false	},
		["Benedict"]			= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true	},
		["Kiriya"]				= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 35000, short_range_radar = 5000, tractor = true,		mining = true	},
		["Striker"]				= { strength = 8,	cargo = 4,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000, tractor = false,	mining = false	},
		["ZX-Lindworm"]			= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 5500, tractor = false,	mining = false	},
		["Repulse"]				= { strength = 14,	cargo = 12,	distance = 200,	long_range_radar = 38000, short_range_radar = 5000, tractor = true,		mining = false	},
		["Ender"]				= { strength = 100,	cargo = 20,	distance = 2000,long_range_radar = 45000, short_range_radar = 7000, tractor = true,		mining = false	},
		["Nautilus"]			= { strength = 12,	cargo = 7,	distance = 200,	long_range_radar = 22000, short_range_radar = 4000, tractor = false,	mining = false	},
		["Hathcock"]			= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, tractor = false,	mining = true	},
		["Maverick"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, tractor = false,	mining = true	},
		["Crucible"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false	},
		["Proto-Atlantis"]		= { strength = 40,	cargo = 4,	distance = 400,	long_range_radar = 30000, short_range_radar = 4500, tractor = false,	mining = true	},
		["Stricken"]			= { strength = 40,	cargo = 4,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, tractor = false,	mining = false	},
		["Surkov"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, tractor = false,	mining = false	},
		["Redhook"]				= { strength = 11,	cargo = 8,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false	},
		["Pacu"]				= { strength = 18,	cargo = 7,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false	},
		["Phobos T2"]			= { strength = 19,	cargo = 9,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false	},
		["Wombat"]				= { strength = 13,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 6000, tractor = false,	mining = false	},
		["Holmes"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 4000, tractor = true,		mining = false	},
		["Focus"]				= { strength = 35,	cargo = 4,	distance = 200,	long_range_radar = 32000, short_range_radar = 5000, tractor = false,	mining = true	},
		["Flavia 2C"]			= { strength = 25,	cargo = 12,	distance = 200,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = true	},
		["Destroyer IV"]		= { strength = 25,	cargo = 5,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = false	},
		["Destroyer III"]		= { strength = 25,	cargo = 7,	distance = 200,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = false	},
		["MX-Lindworm"]			= { strength = 10,	cargo = 3,	distance = 100,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = false	},
		["Striker LX"]			= { strength = 16,	cargo = 4,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, tractor = false,	mining = false	},
		["Maverick XP"]			= { strength = 23,	cargo = 5,	distance = 200,	long_range_radar = 25000, short_range_radar = 7000, tractor = true,		mining = false	},
		["Era"]					= { strength = 14,	cargo = 14,	distance = 200,	long_range_radar = 50000, short_range_radar = 5000, tractor = true,		mining = true	},
		["Squid"]				= { strength = 14,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = false,	mining = false	},
		["Atlantis II"]			= { strength = 60,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true	},
		["Chavez"]				= { strength = 8,	cargo = 6,	distance = 200,	long_range_radar = 20000, short_range_radar = 4500, tractor = true,		mining = true	},
	}	
	commonGoods = {"food","medicine","nickel","platinum","gold","dilithium","tritanium","luxury","cobalt","impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	componentGoods = {"impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	mineralGoods = {"nickel","platinum","gold","dilithium","tritanium","cobalt"}
	vapor_goods = {"gold pressed latinum","unobtanium","eludium","impossibrium"}
	show_player_info = true
	show_only_player_name = true
	info_choice = 0
	info_choice_max = 5
	mining_beam_string = {
		"beam_orange.png",
		"beam_yellow.png",
		"fire_sphere_texture.png"
	}
	mining_drain = .00025 * difficulty
end
function constructEnvironment()
	friendly_neutral_stations = {}
--	Spawn shipyard station (will be placed later)
	shipyard_station = placeStation(100000,100000,"RandomHumanNeutral","Human Navy","Large Station")
	shipyard_station.name = shipyard_station:getCallSign()
--	Spawn player
	local p = PlayerSpaceship():setTemplate("Hathcock")
	p.pidx = 1
	setPlayer(p)
--	Spawn freighter to be rescued
	rescue_angle = random(0,360)
	rescue_distance = random(12000,18000)
	local rf_x, rf_y = vectorFromAngleNorth(rescue_angle,rescue_distance)
	rescue_freighter = CpuShip():setTemplate("Fuel Freighter 3"):setCallSign(tableRemoveRandom(rescue_freighter_names))
	rescue_freighter:setPosition(rf_x, rf_y):setFaction("Human Navy"):setScanned(true):setCommsScript(""):setCommsFunction(commsShip)
	rescue_freighter.name = rescue_freighter:getCallSign()
	rescue_freighter.timer = 90
	rescue_freighter.distance_from_player = distance(p,rescue_freighter)
	rescue_freighter.contacted_by_player = false
--	Spawn station where freighter is headed
	integral_offset = random(50,100)
	integral_angle = (rescue_angle + integral_offset) % 360
	integral_distance = random(22000,30000)
	local is_x, is_y = vectorFromAngleNorth(integral_angle,integral_distance)
	integral_station = placeStation(is_x,is_y,"RandomHumanNeutral","Independent","Medium Station")
	table.insert(friendly_neutral_stations,integral_station)
	rescue_freighter:orderDock(integral_station)
--	Place shipyard station
	local ss_x, ss_y =  vectorFromAngleNorth((rescue_angle + 120) % 360,30000)
	shipyard_station:setPosition(ss_x, ss_y)
	shipyard_station.comms_data.weapon_available.Homing = true
	shipyard_station.comms_data.weapon_cost = {Homing = math.random(2,4), HVLI = math.random(1,3), Mine = math.random(2,5), Nuke = 12, EMP = 9}
	table.insert(friendly_neutral_stations,shipyard_station)
--	Asteroids between integral and shipyard stations
	local afc_x = (is_x + ss_x) / 2
	local afc_y = (is_y + ss_y) / 2
	afc_x = afc_x + random(-5000,5000)
	afc_y = afc_y + random(-5000,5000)
	local max_dist = math.min(distance(shipyard_station,afc_x,afc_y),distance(integral_station,afc_x,afc_y))
	trav_asteroids = placeRandomListAroundPoint(Asteroid, math.random(40,75), 500, max_dist*.8, afc_x, afc_y)
	for i=1,#trav_asteroids do
		trav_asteroids[i]:setSize(random(3,150)+random(3,150)+random(3,150))
	end
	asteroid_station = placeStation(afc_x,afc_y,"RandomHumanNeutral","Independent","Small Station")
	table.insert(friendly_neutral_stations,asteroid_station)
	if not integral_station:getRestocksScanProbes() and
		not shipyard_station:getRestocksScanProbes() and
		not asteroid_station:getRestocksScanProbes() then
		shipyard_station:setRestocksScanProbes(true)
	end
	if not integral_station:getSharesEnergyWithDocked() and
		not shipyard_station:getSharesEnergyWithDocked() and
		not asteroid_station:getSharesEnergyWithDocked() then
		shipyard_station:setSharesEnergyWithDocked(true)
	end
	if not integral_station:getRepairDocked() and
		not shipyard_station:getRepairDocked() and
		not asteroid_station:getRepairDocked() then
		shipyard_station:setRepairDocked(true)
	end
--	Pirate Kraylor pirate station
	primary_pirate_angle = angleFromVectorNorth(ss_x, ss_y, is_x, is_y)
	local secondary_pirate_angle = primary_pirate_angle + random(-25,25)
	if secondary_pirate_angle > 360 then
		secondary_pirate_angle = secondary_pirate_angle - 360
	end
	if secondary_pirate_angle < 0 then
		secondary_pirate_angle = secondary_pirate_angle + 360
	end
	local pirate_base_distance = random(50000,80000)
	local pb_x, pb_y = vectorFromAngleNorth(secondary_pirate_angle,pirate_base_distance)
	pb_x = pb_x + ss_x
	pb_y = pb_y + ss_y
	pirate_station = placeStation(pb_x, pb_y,"Sinister","Kraylor","Medium Station")
	pirate_station.name = pirate_station:getCallSign()
--	Pirate base defense fleet
	pirate_base_defense_fleet = {}
	local f_space = random(500,1000)
	local position_index = 1
	local enemy = CpuShip():setTemplate("Starhammer II"):setFaction("Kraylor")
	enemy:setCallSign(generateCallSign(nil,"Kraylor"))
	enemy:setTypeName("Starhammer IX")
	enemy:setImpulseMaxSpeed(75)							--faster impulse (vs 30)
	enemy:setRotationMaxSpeed(10)							-- up from default of 6
	enemy:setBeamWeapon(2,	90,	  200,	1500,		6,		 8)
	enemy:setBeamWeapon(3,	90,	  160,	1500,		6,		 8)
	enemy:weaponTubeDisallowMissle(0,"Nuke")
	enemy:setWeaponStorageMax("Homing",16)					--more (vs 4)
	enemy:setWeaponStorage("Homing", 16)
	enemy:setWeaponStorageMax("EMP",6)						--more (vs 2)
	enemy:setWeaponStorage("EMP", 6)
	enemy:setWeaponStorageMax("Nuke",4)						--more (vs 0)
	enemy:setWeaponStorage("Nuke", 4)
	enemy:setPosition(pb_x + formation_delta.square.x[position_index]*f_space,pb_y + formation_delta.square.y[position_index]*f_space)
	enemy:orderDefendTarget(pirate_station):setCommsScript(""):setCommsFunction(commsShip)
	table.insert(pirate_base_defense_fleet,enemy)
	for i=1,1+(difficulty*2) do
		position_index = position_index + 1
		enemy = CpuShip():setTemplate("MT52 Hornet"):setFaction("Kraylor")
		enemy:setCallSign(generateCallSign(nil,"Kraylor"))
		enemy:setPosition(pb_x + formation_delta.square.x[position_index]*f_space,pb_y + formation_delta.square.y[position_index]*f_space)
		enemy:orderDefendTarget(pirate_station):setCommsScript(""):setCommsFunction(commsShip)
		table.insert(pirate_base_defense_fleet,enemy)
		position_index = position_index + 1
		enemy = CpuShip():setTemplate("MU52 Hornet"):setFaction("Kraylor")
		enemy:setCallSign(generateCallSign(nil,"Kraylor"))
		enemy:setPosition(pb_x + formation_delta.square.x[position_index]*f_space,pb_y + formation_delta.square.y[position_index]*f_space)
		enemy:orderDefendTarget(pirate_station):setCommsScript(""):setCommsFunction(commsShip)
		table.insert(pirate_base_defense_fleet,enemy)
		position_index = position_index + 1
		enemy = CpuShip():setTemplate("Adder MK9"):setFaction("Kraylor")
		enemy:setCallSign(generateCallSign(nil,"Kraylor"))
		enemy:setPosition(pb_x + formation_delta.square.x[position_index]*f_space,pb_y + formation_delta.square.y[position_index]*f_space)
		enemy:orderDefendTarget(pirate_station):setCommsScript(""):setCommsFunction(commsShip)
		table.insert(pirate_base_defense_fleet,enemy)
		position_index = position_index + 1
		enemy = CpuShip():setTemplate("Phobos T3"):setFaction("Kraylor")
		enemy:setCallSign(generateCallSign(nil,"Kraylor"))
		enemy:setPosition(pb_x + formation_delta.square.x[position_index]*f_space,pb_y + formation_delta.square.y[position_index]*f_space)
		enemy:orderDefendTarget(pirate_station):setCommsScript(""):setCommsFunction(commsShip)
		table.insert(pirate_base_defense_fleet,enemy)
		position_index = position_index + 1
		enemy = CpuShip():setTemplate("Elara P2"):setFaction("Kraylor")
		enemy:setCallSign(generateCallSign(nil,"Kraylor"))
		enemy:setPosition(pb_x + formation_delta.square.x[position_index]*f_space,pb_y + formation_delta.square.y[position_index]*f_space)
		enemy:orderDefendTarget(pirate_station):setCommsScript(""):setCommsFunction(commsShip)
		table.insert(pirate_base_defense_fleet,enemy)
	end
--	Spawn nebulae
	local cn_x, cn_y = vectorFromAngleNorth(secondary_pirate_angle,pirate_base_distance + 1000)
	cn_x = cn_x + ss_x
	cn_y = cn_y + ss_y
	Nebula():setPosition(cn_x,cn_y)
	local ec_angle = random(0,360)
	local ec_x, ec_y = vectorFromAngleNorth(ec_angle,random(7000,9000))
	Nebula():setPosition(cn_x+ec_x,cn_y+ec_y)
	ec_x, ec_y = vectorFromAngleNorth((ec_angle + random(140,210))%360,random(7000,9000))
	Nebula():setPosition(cn_x+ec_x,cn_y+ec_y)
	nebula_band = random(10000,40000)
	local start_arc = secondary_pirate_angle - random(60,90)
	if start_arc < 360 then
		start_arc = start_arc + 360
	end
	if start_arc > 360 then
		start_arc = start_arc - 360
	end
	local finish_arc = (secondary_pirate_angle + random(60,90))%360
	local neb_blob_count = math.random(6,14)
	local neb_list = createRandomAlongArc(Nebula,neb_blob_count,is_x,is_y,pirate_base_distance+distance(integral_station,shipyard_station)-nebula_band/2,start_arc,finish_arc,nebula_band)
	full_neb_list = {}
	for i=1,neb_blob_count do
		table.insert(full_neb_list,neb_list[i])
		local size_choice = math.random(1,3)
		if size_choice > 1 then
			local nx, ny = neb_list[i]:getPosition()
			ec_angle = random(0,360)
			ec_x, ec_y = vectorFromAngleNorth(ec_angle,random(7000,9000))
			table.insert(full_neb_list,Nebula():setPosition(nx+ec_x,ny+ec_y))
			if size_choice > 2 then
				ec_x, ec_y = vectorFromAngleNorth((ec_angle + random(140,210))%360,random(7000,9000))
				table.insert(full_neb_list,Nebula():setPosition(nx+ec_x,ny+ec_y))
			end
		end
	end
	local station_neb = tableRemoveRandom(full_neb_list)
	local snx, sny = station_neb:getPosition()
	nebula_station = placeStation(snx, sny,"RandomHumanNeutral","Independent")
	table.insert(friendly_neutral_stations,nebula_station)
	local inside_list = createRandomAlongArc(Asteroid,2,is_x,is_y,pirate_base_distance+distance(integral_station,shipyard_station)-(nebula_band)/2,start_arc,finish_arc,nebula_band)
	snx, sny = inside_list[1]:getPosition()
	inside_list[1]:destroy()
	inside_human_station = placeStation(snx, sny,"RandomHumanNeutral","Human Navy")
	table.insert(friendly_neutral_stations,inside_human_station)
	snx, sny = inside_list[2]:getPosition()
	inside_list[2]:destroy()
	inside_independent_station = placeStation(snx, sny,"RandomHumanNeutral","Independent")
	table.insert(friendly_neutral_stations,inside_independent_station)
	local outside_list = createRandomAlongArc(Asteroid,5,is_x,is_y,pirate_base_distance+distance(integral_station,shipyard_station)-(nebula_band)/2,finish_arc,start_arc,nebula_band)
	outside_stations = {}
	for _, out_asteroid in ipairs(outside_list) do
		snx, sny = out_asteroid:getPosition()
		out_asteroid:destroy()
		local station_faction = "Independent"
		if random(1,5) <= 1 then
			station_faction = "Human Navy"
		end
		local outside_station = placeStation(snx, sny,"RandomHumanNeutral",station_faction)
		table.insert(friendly_neutral_stations,outside_station)
		table.insert(outside_stations,outside_station)
	end
	local scatter_list = createRandomAlongArc(Asteroid,math.random(50,200),is_x,is_y,pirate_base_distance+distance(integral_station,shipyard_station)-(nebula_band+5000)/2,start_arc,finish_arc,nebula_band+5000)
	for _, scatter in ipairs(scatter_list) do
		local size = random(1,100)
		for i=1,math.random(1,5) do
			size = size + random(3,500)
		end
		scatter:setSize(size)
	end
end
--	Main plot functions
function trackFreighterPlot(delta)
	local start_rescue = false
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.tracking_message == nil then
				p:addToShipLog(string.format("You've been tracking the friendly freighter, %s, as part of your training exercise",rescue_freighter:getCallSign()),"Magenta")
				p.tracking_message = "sent"
			end
			if distance(p,0,0) > 1000 then
				start_rescue = true
			end
			if distance(p,rescue_freighter) > (rescue_freighter.distance_from_player + 1000) then
				start_rescue = true
			end
		end
	end
	rescue_freighter.timer = rescue_freighter.timer - delta
	if rescue_freighter.timer < 0 then
		start_rescue = true
	end
	if start_rescue or rescue_freighter.contacted_by_player then
		mainPlot = rescueFreighterPlot
	end
end
function rescueFreighterPlot(delta)
	if rescue_freighter_pirates == nil then
		rescue_freighter_pirates = {}
		local rfp_angle = (rescue_angle + integral_offset / 2) % 360
		local rfp_distance = (rescue_distance + integral_distance) / 2
		local ef_x, ef_y = vectorFromAngleNorth(rfp_angle,rfp_distance)
		local f_space = random(500,1000)
		local position_index = 1
		local enemy = CpuShip():setTemplate("MT52 Hornet"):setFaction("Kraylor")
		enemy:setCallSign(generateCallSign(nil,"Kraylor"))
		enemy:setPosition(ef_x + formation_delta.square.x[position_index]*f_space,ef_y + formation_delta.square.y[position_index]*f_space)
		enemy:orderRoaming():setCommsScript(""):setCommsFunction(commsShip)
		table.insert(rescue_freighter_pirates,enemy)
		position_index = position_index + 1
		enemy = CpuShip():setTemplate("MT52 Hornet"):setFaction("Kraylor")
		enemy:setCallSign(generateCallSign(nil,"Kraylor"))
		enemy:setPosition(ef_x + formation_delta.square.x[position_index]*f_space,ef_y + formation_delta.square.y[position_index]*f_space)
		enemy:orderRoaming():setCommsScript(""):setCommsFunction(commsShip)
		table.insert(rescue_freighter_pirates,enemy)
		position_index = position_index + 1
		enemy = CpuShip():setTemplate("Adder MK5"):setFaction("Kraylor")
		enemy:setCallSign(generateCallSign(nil,"Kraylor"))
		enemy:setPosition(ef_x + formation_delta.square.x[position_index]*f_space,ef_y + formation_delta.square.y[position_index]*f_space)
		enemy:orderRoaming():setCommsScript(""):setCommsFunction(commsShip)
		table.insert(rescue_freighter_pirates,enemy)
		if difficulty >= 1 then
			position_index = position_index + 1
			enemy = CpuShip():setTemplate("MU52 Hornet"):setFaction("Kraylor")
			enemy:setCallSign(generateCallSign(nil,"Kraylor"))
			enemy:setPosition(ef_x + formation_delta.square.x[position_index]*f_space,ef_y + formation_delta.square.y[position_index]*f_space)
			enemy:orderRoaming():setCommsScript(""):setCommsFunction(commsShip)
			table.insert(rescue_freighter_pirates,enemy)
		end
		if difficulty >= 2 then
			position_index = position_index + 1
			enemy = CpuShip():setTemplate("MU52 Hornet"):setFaction("Kraylor")
			enemy:setCallSign(generateCallSign(nil,"Kraylor"))
			enemy:setPosition(ef_x + formation_delta.square.x[position_index]*f_space,ef_y + formation_delta.square.y[position_index]*f_space)
			enemy:orderRoaming():setCommsScript(""):setCommsFunction(commsShip)
			table.insert(rescue_freighter_pirates,enemy)
		end
		rescue_freighter.agree_to_rescue = false
		if not rescue_freighter.contacted_by_player then
			local p = getPlayerShip(-1)
			if p ~= nil and p:isValid() then
				rescue_freighter:sendCommsMessage(p,string.format("[Automated Emergency System] Please contact %s as soon as possible",rescue_freighter:getCallSign()))
			end
		end
	end
	if rescue_freighter ~= nil and rescue_freighter:isValid() then
		if rescue_freighter.agree_to_rescue then
			transportPlot = plotTransport
			for _, enemy in ipairs(rescue_freighter_pirates) do
				if enemy ~= nil and enemy:isValid() then
					enemy:setScanned(true)
				end
			end
			local shield_freq = rescue_freighter_pirates[3]:getShieldsFrequency()
			local adder_name = rescue_freighter_pirates[3]:getCallSign()
			for pidx=1,32 do
				local p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					if p.science_tactical_data_message == nil then
						local tactical_frequency_message = string.format("     Now that %s has provided detailed scan data on the Kraylor, you can help improve ship combat performance by providing beam and shield frequency data to the weapons officer.\n     For example, %s, the Kraylor Adder MK5 has its shields tuned to %i THz (terahertz), the lowest and reddest part of the 'Damage with Your Beams' graph.\n     You should tell the weapons officer to adjust beams to around %i THz, closer to the highest and greenest part of the graph, to maximize beam damage against %s. The inverted caret (^) marks your ship's current beam frequency",rescue_freighter:getCallSign(),adder_name,shield_freq*20+400,(shield_freq + 10)%20*20+400,adder_name) 
						if p:hasPlayerAtPosition("Science") then
							p.tactical_frequency_message = "tactical_frequency_message"
							p:addCustomMessage("Science",p.tactical_frequency_message,tactical_frequency_message)
						end
						if p:hasPlayerAtPosition("Operations") then
							p.tactical_frequency_message_ops = "tactical_frequency_message_ops"
							p:addCustomMessage("Operations",p.tactical_frequency_message_ops,tactical_frequency_message)
						end
						p.science_tactical_data_message = "sent"
					end
					if p.weapons_beam_adjust_message == nil then
						if p:hasPlayerAtPosition("Weapons") then
							p.adjust_beam_frequency = "adjust_beam_frequency"
							p:addCustomMessage("Weapons",p.adjust_beam_frequency,"The science officer *may* ask you to adjust the beam frequency to maximize damage against one or more of the Kraylor enemy ships. The button just above the shield toggle button in the lower right hand corner adjusts the beam frequency. The buttons below the shield toggle button deal with the shield frequency.\n\n*Important*\nThe shields must remain down while they are being calibrated. This makes the ship more vulnerable to attack during shield calibration.")
						end
						if p:hasPlayerAtPosition("Tactical") then
							p.adjust_beam_frequency_tac = "adjust_beam_frequency_tac"
							p:addCustomMessage("Weapons",p.adjust_beam_frequency_tac,"The science officer *may* ask you to adjust the beam frequency to maximize damage against one or more of the Kraylor enemy ships. The button along the bottom edge just to the right of the 'BEAMS' banner adjusts the beam frequency.")
						end
						p.weapons_beam_adjust_message = "sent"
					end
					if p.low_power_test_message == nil then
						local low_power = true
						for _, system in ipairs(system_list) do
							if p:getSystemPower(system) > .25 then
								low_power = false
								break
							end
						end
						if low_power then
							p.low_power_test_message = "sent"
							local power_message = "The engineering technicians just completed a 1/4 power test diagnostic suite, so all systems are still at low power. If you are about to enter combat, you probably want to raise all power levels to at least 100%. In combat, systems like engines, shields and weapons may need more power and correspondingly more coolant.\n\nWill set all systems to 100% power upon acknowledgement of this message."
							if p:hasPlayerAtPosition("Engineering") then
								p.power_message = "power_message"
								p:addCustomMessageWithCallback("Engineering",p.power_message,power_message,function()
									string.format("")	--need global context for serious proton
									for _, system in ipairs(system_list) do
										p:commandSetSystemPowerRequest(system, 1)
									end
								end)
							end
							if p:hasPlayerAtPosition("Engineering+") then
								p.power_message_plus = "power_message_plus"
								p:addCustomMessageWithCallback("Engineering+",p.power_message_plus,power_message,function()
									string.format("")	--need global context for serious proton
									for _, system in ipairs(system_list) do
										p:commandSetSystemPowerRequest(system, 1)
									end
								end)
							end
							if p:hasPlayerAtPosition("PowerManagement") then
								p.power_message_pm = "power_message_pm"
								p:addCustomMessageWithCallback("PowerManagement",p.power_message_pm,power_message,function()
									string.format("")	--need global context for serious proton
									for _, system in ipairs(system_list) do
										p:commandSetSystemPowerRequest(system, 1)
									end
								end)
							end
						end
					end
					if p.faster_impulse_engine_message == nil then
						if p.faster_impulse_timer == nil then
							p.faster_impulse_timer = 60
						end
						p.faster_impulse_timer = p.faster_impulse_timer - delta
						if p.faster_impulse_timer < 0 then
							p.faster_impulse_engine_message = "sent"
							if p:getSystemPower("impulse") <= 1 then
								if p:hasPlayerAtPosition("Engineering") then
									p.impulse_power_message = "impulse_power_message"
									p:addCustomMessage("Engineering",p.impulse_power_message,"You can increase ship speed by putting additional power into the impulse engines. If you do, be sure to also put coolant into the impulse engines to prevent overheating and eventual damage.")
								end
								if p:hasPlayerAtPosition("Engineering+") then
									p.impulse_power_message_plus = "impulse_power_message_plus"
									p:addCustomMessage("Engineering+",p.impulse_power_message_plus,"You can increase ship speed by putting additional power into the impulse engines. If you do, be sure to also put coolant into the impulse engines to prevent overheating and eventual damage.")
								end
								if p:hasPlayerAtPosition("PowerManagement") then
									p.impulse_power_message_pm = "impulse_power_message_pm"
									p:addCustomMessage("PowerManagement",p.impulse_power_message_pm,"You can increase ship speed by putting additional power into the impulse engines. If you do, be sure to also put coolant into the impulse engines to prevent overheating and eventual damage.")
								end
							end
						end
					end
				end
			end
		end
		local rescue_freighter_pirate_count = 0
		if rescue_freighter_pirates ~= nil then
			for _, enemy in ipairs(rescue_freighter_pirates) do
				if enemy ~= nil and enemy:isValid() then
					rescue_freighter_pirate_count = rescue_freighter_pirate_count + 1
				end
			end
		end
		if rescue_freighter_pirate_count == 0 then
			local rfp_x, rfp_y = rescue_freighter:getPosition()
			rescue_freighter_cargo = Artifact():setPosition(rfp_x, rfp_y):setModel("ammo_box"):setDescription("Cargo container"):onPickUp(cargoPickupProcess)
			rescue_freighter_cargo_type = componentGoods[math.random(1,#componentGoods)]
			rescue_freighter_cargo.cargo = rescue_freighter_cargo_type
			mainPlot = helpFreighterDelivery
		end
	else
		globalMessage(string.format("You resign in disgrace for failing to protect %s",rescue_freighter.name))
		victory("Kraylor")
	end
end
function helpFreighterDelivery(delta)
	if integral_station.player_delivery then
		if shipyard_timer == nil then
			shipyard_timer = random(15,30)
		end
		shipyard_timer = shipyard_timer - delta
		if shipyard_timer < 0 then
			if not shipyard_station:sendCommsMessage(getPlayerShip(-1),"Contact us for your next set of orders") then
				for pidx=1,32 do
					local p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						p:addToShipLog(string.format("Dock with %s so we can evaluate progress and adjust if necessary",shipyard_station:getCallSign()),"Magenta")
					end
				end
			end
			primaryOrders = string.format("Dock with %s for evaluation and potential adjustment",shipyard_station:getCallSign())
			mainPlot = dockWithShipyardAfterDelivery
		end
	end
end
function dockWithShipyardAfterDelivery(delta)
	if shipyard_station ~= nil and shipyard_station:isValid() then
		if vengeful_pirates == nil then
			vengeful_pirates = {}
			local player_list = {}
			for pidx=1,32 do
				local p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					table.insert(player_list,p)
				end
			end
			local ix, iy = integral_station:getPosition()
			local ex, ey = vectorFromAngleNorth(primary_pirate_angle,distance(integral_station,shipyard_station)+7000)
			ex = ex + ix
			ey = ey + iy
			local f_space = random(500,1000)
			local position_index = 1
			local enemy = CpuShip():setTemplate("MT52 Hornet"):setFaction("Kraylor")
			enemy:setCallSign(generateCallSign(nil,"Kraylor"))
			enemy:setPosition(ex + formation_delta.square.x[position_index]*f_space,ey + formation_delta.square.y[position_index]*f_space)
			enemy:orderRoaming():setCommsScript(""):setCommsFunction(commsShip)
			table.insert(vengeful_pirates,enemy)
			position_index = position_index + 1
			enemy = CpuShip():setTemplate("MT52 Hornet"):setFaction("Kraylor")
			enemy:setCallSign(generateCallSign(nil,"Kraylor"))
			enemy:setPosition(ex + formation_delta.square.x[position_index]*f_space,ey + formation_delta.square.y[position_index]*f_space)
			enemy:orderAttack(player_list[math.random(1,#player_list)]):setCommsScript(""):setCommsFunction(commsShip)
			table.insert(vengeful_pirates,enemy)
			position_index = position_index + 1
			enemy = CpuShip():setTemplate("MT52 Hornet"):setFaction("Kraylor")
			enemy:setCallSign(generateCallSign(nil,"Kraylor"))
			enemy:setPosition(ex + formation_delta.square.x[position_index]*f_space,ey + formation_delta.square.y[position_index]*f_space)
			enemy:orderRoaming():setCommsScript(""):setCommsFunction(commsShip)
			table.insert(vengeful_pirates,enemy)
			position_index = position_index + 1
			enemy = CpuShip():setTemplate("MT52 Hornet"):setFaction("Kraylor")
			enemy:setCallSign(generateCallSign(nil,"Kraylor"))
			enemy:setPosition(ex + formation_delta.square.x[position_index]*f_space,ey + formation_delta.square.y[position_index]*f_space)
			enemy:orderAttack(player_list[math.random(1,#player_list)]):setCommsScript(""):setCommsFunction(commsShip)
			table.insert(vengeful_pirates,enemy)
			position_index = position_index + 1
			enemy = CpuShip():setTemplate("Adder MK5"):setFaction("Kraylor")
			enemy:setCallSign(generateCallSign(nil,"Kraylor"))
			enemy:setPosition(ex + formation_delta.square.x[position_index]*f_space,ey + formation_delta.square.y[position_index]*f_space)
			enemy:orderRoaming():setCommsScript(""):setCommsFunction(commsShip)
			table.insert(vengeful_pirates,enemy)
			position_index = position_index + 1
			enemy = CpuShip():setTemplate("Adder MK5"):setFaction("Kraylor")
			enemy:setCallSign(generateCallSign(nil,"Kraylor"))
			enemy:setPosition(ex + formation_delta.square.x[position_index]*f_space,ey + formation_delta.square.y[position_index]*f_space)
			enemy:orderAttack(player_list[math.random(1,#player_list)]):setCommsScript(""):setCommsFunction(commsShip)
			table.insert(vengeful_pirates,enemy)
			if difficulty >= 1 then
				position_index = position_index + 1
				enemy = CpuShip():setTemplate("Stalker R5"):setFaction("Kraylor")
				enemy:setCallSign(generateCallSign(nil,"Kraylor"))
				enemy:setPosition(ex + formation_delta.square.x[position_index]*f_space,ey + formation_delta.square.y[position_index]*f_space)
				enemy:orderAttack(player_list[math.random(1,#player_list)]):setCommsScript(""):setCommsFunction(commsShip)
				table.insert(vengeful_pirates,enemy)
			end
			if difficulty >= 2 then
				position_index = position_index + 1
				enemy = CpuShip():setTemplate("Stalker R5"):setFaction("Kraylor")
				enemy:setCallSign(generateCallSign(nil,"Kraylor"))
				enemy:setPosition(ex + formation_delta.square.x[position_index]*f_space,ey + formation_delta.square.y[position_index]*f_space)
				enemy:orderRoaming():setCommsScript(""):setCommsFunction(commsShip)
				table.insert(vengeful_pirates,enemy)
				position_index = position_index + 1
				enemy = CpuShip():setTemplate("Stalker Q5"):setFaction("Kraylor")
				enemy:setCallSign(generateCallSign(nil,"Kraylor"))
				enemy:setPosition(ex + formation_delta.square.x[position_index]*f_space,ey + formation_delta.square.y[position_index]*f_space)
				enemy:orderAttack(player_list[math.random(1,#player_list)]):setCommsScript(""):setCommsFunction(commsShip)
				table.insert(vengeful_pirates,enemy)
			end
		end
		local vengeful_pirate_count = 0
		if vengeful_pirates ~= nil then
			for _, enemy in ipairs(vengeful_pirates) do
				if enemy ~= nil and enemy:isValid() then
					vengeful_pirate_count = vengeful_pirate_count + 1
				end
			end
		end
		if vengeful_pirate_count == 0 then
			local docked_with_shipyard = false
			for pidx=1,32 do
				local p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					if p:isDocked(shipyard_station) then
						docked_with_shipyard = true
						break
					end
				end
			end
			if docked_with_shipyard then
				finalize_player_ship_work = true
				escape_pods = {}
				local pod_deep_descriptions = {
					"Standard escape pod. No engine power. Minor damage detected. Faint life signs indicative of cryosleep systems. Diagnostics show no atmosphere remains requiring station facilities for revival",
					"Standard escape pod. Minimal engine power, engine shut down. Life signs detected, but low metabolism indicating artificial sleep induction. Recommend station revival facilities",
					"Outmoded escape pod. Life forms in cryostasis. Likely a cheap pod bought by a desperate miner. We should take it to a station for processing",
				}
				for i=1,3 do
					local pod_neb = tableRemoveRandom(full_neb_list)
					local pn_x, pn_y = pod_neb:getPosition()
					local pod = Artifact():setPosition(pn_x + random(-1000,1000),pn_y + random(-1000,1000)):allowPickup(false):setSpin(2.3)
					pod:setModel("transport_5_1"):setDescriptions("Low tech container",tableRemoveRandom(pod_deep_descriptions)):setScanningParameters(2,2):setRadarSignatureInfo(.01,.15,.85)
					local guard_angle = random(0,360)
					local guards = {}
					local ax, ay = pod:getPosition()
					for j=1,3 do
						local ex, ey = vectorFromAngleNorth(guard_angle,2500)
						local enemy = CpuShip():setTemplate("Adder MK5"):setFaction("Kraylor")
						enemy:setPosition(ex + ax, ey + ay):orderStandGround():setCommsScript(""):setCommsFunction(commsShip)
						table.insert(guards,enemy)
						guard_angle = (guard_angle + 120) % 360
					end
					table.insert(escape_pods,{pod=pod,pod_neb=pod_neb,guards=guards,retrieve_fleet=false})
				end
				for pidx=1,32 do
					local p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						p:addToShipLog(string.format("After you dock and finalize the outstanding work on %s, go investigate the source of transmissions received",p:getCallSign()),"Magenta")
					end
				end
				escape_pod_count = 3
				mainPlot = retrievePods
				primaryOrders = "Investigate transmissions. They seem to be coming from nebulae"
				spicePlot = pirateHarassment
			end
		end
	else
		globalMessage(string.format("You allowed %s to be destroyed",shipyard_station.name))
		victory("Kraylor")
	end
end
function retrievePods(delta)
	local valid_pod_count = 0
	local scanned_pod_count = 0
	if escape_pods ~= nil then
		if #escape_pods > 0 then
			for _, escape_pod in ipairs(escape_pods) do
				local defense_fleet = {}
				if escape_pod.pod ~= nil and escape_pod.pod:isValid() then
					valid_pod_count = valid_pod_count + 1
					if escape_pod.guards ~= nil then
						for pidx=1,32 do
							local p = getPlayerShip(pidx)
							if p ~= nil and p:isValid() then
								if distance(p,escape_pod.pod) < 4000 then
									for _, enemy in ipairs(escape_pod.guards) do
										if enemy ~= nil and enemy:isValid() then
											enemy:orderRoaming()
										end
									end
									escape_pod.guards = nil
								end
							end
						end
					end
					if escape_pod.pod.prepared == nil then
						if escape_pod.pod:isScannedByFaction("Human Navy") then
							escape_pod.pod:onPickUp(escapePodRetrieval)
							escape_pod.pod.prepared = true
							if shipyard_station.fleet_index == nil then
								shipyard_station.fleet_index = 1
								shipyard_station.defense_fleet = {}
								shipyard_station.defense_fleet_type = {
									{count = 4, template = "MT52 Hornet"},
									{count = 3, template = "Nirvana R5"},
									{count = 2, template = "Cucaracha"},
									{count = 4, template = "MU52 Hornet"},
									{count = 3, template = "Cruiser"},
									{count = 2, template = "Dreadnought"},
								}
							end
							for i=1,shipyard_station.defense_fleet_type[shipyard_station.fleet_index].count do
								local selected_template = shipyard_station.defense_fleet_type[shipyard_station.fleet_index].template
								local def_ship = ship_template[selected_template].create("Human Navy",selected_template)
								def_ship:setPosition(shipyard_station:getPosition()):setScanned(true):orderDefendTarget(shipyard_station):setCommsScript(""):setCommsFunction(commsShip)
								def_ship:setCallSign(generateCallSign(nil,"Human Navy"))
								table.insert(defense_fleet,def_ship)
							end
							table.insert(shipyard_station.defense_fleet,defense_fleet)
							shipyard_station.fleet_index = shipyard_station.fleet_index + 1
						end
					else
						scanned_pod_count = scanned_pod_count + 1
					end
				else
					if not escape_pod.retrieve_fleet then
						escape_pod.retrieve_fleet = true
						for i=1,shipyard_station.defense_fleet_type[shipyard_station.fleet_index].count do
							local selected_template = shipyard_station.defense_fleet_type[shipyard_station.fleet_index].template
							local def_ship = ship_template[selected_template].create("Human Navy",selected_template)
							def_ship:setPosition(shipyard_station:getPosition()):setScanned(true):orderDefendTarget(shipyard_station):setCommsScript(""):setCommsFunction(commsShip)
							def_ship:setCallSign(generateCallSign(nil,"Human Navy"))
							table.insert(defense_fleet,def_ship)
						end
						table.insert(shipyard_station.defense_fleet,defense_fleet)
						shipyard_station.fleet_index = shipyard_station.fleet_index + 1
					end
				end
			end
		end
	end
	escape_pod_count = valid_pod_count
	if scanned_pod_count > 0 then
		pod_scanned = true
		primaryOrders = string.format("Investigate transmission sources. %i identified. Unidentified transmission sources remain. Pick up escape pod.",scanned_pod_count)
		if scanned_pod_count >= valid_pod_count then
			if valid_pod_count > 1 then
				primaryOrders = "Pick up escape pods."
			else
				primaryOrders = "Pick up escape pod."
			end
		end
	end
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.pod_aboard_count ~= nil and p.pod_aboard_count > 0 then
				if p:isDocked(shipyard_station) then
					if p.pod_aboard_count > 1 then
						p:addToShipLog(string.format("The people aboard the escape pods you brought to %s are being cared for by medical personnel. They are grateful to have been rescued",shipyard_station:getCallSign()),"Magenta")
					else
						p:addToShipLog(string.format("The people aboard the escape pod you brought to %s are being cared for by medical personnel. They are grateful to have been rescued",shipyard_station:getCallSign()),"Magenta")
					end
					p:addReputationPoints(80*p.pod_aboard_count)
					p.pod_aboard_count = 0
				end
			end
			if p.get_pod_message == nil then
				if scanned_pod_count > 0 then
					p.get_pod_message = "sent"
					p:addToShipLog("Retrieve escape pod. Those life forms need our help.","Magenta")
				end
			end
		end
	end
	if valid_pod_count == 0 then
		globalMessage("You rescued all the escape pods")
		rescued_escape_pods = true
		mainPlot = nil	
	end
end
function asteroidSearch(delta)
	local scanned_count = 0
	local vacation_spot_count = 0
	for _, asteroid in ipairs(trav_asteroids) do
		if asteroid ~= nil and asteroid:isValid() then
			if asteroid:isScannedByFaction("Human Navy") then
				scanned_count = scanned_count + 1
			end
			if asteroid.vacation_spot then
				vacation_spot_count = vacation_spot_count + 1
			end
		end
	end
	if scanned_count > 4 then
		if vacation_spot_count < 1 then
			local spelunk_count = 0
			for _, asteroid in ipairs(trav_asteroids) do
				if asteroid ~= nil and asteroid:isValid() then
					if not asteroid:isScannedByFaction("Human Navy") then
						asteroid.vacation_spot = true
						asteroid:setDescriptionForScanState("fullscan",asteroid:getDescription("fullscan") .. " traces of polymers found on surface")
						spelunk_count = spelunk_count + 1
						if spelunk_count > 3 then
							break
						end
					end
				end
			end
		else
			if scanned_count > 20 then
				if miner_hints == nil then
					miner_hints = {}
					for _, asteroid in ipairs(trav_asteroids) do
						if asteroid ~= nil and asteroid:isValid() and asteroid.vacation_spot then
							local ax, ay = asteroid:getPosition()
							local a_size = asteroid:getSize()
							local extra_w = 100
							local hint_zone = Zone():setPoints(
								ax + a_size + extra_w, ay + a_size + extra_w,
								ax - a_size - extra_w, ay + a_size + extra_w,
								ax - a_size - extra_w, ay - a_size - extra_w,
								ax + a_size + extra_w, ay - a_size - extra_w
							):setColor(0,64,0)
							table.insert(miner_hints,hint_zone)
						end 
					end
					for pidx=1,32 do
						local p = getPlayerShip(pidx)
						if p ~= nil and p:isValid() then
							if not asteroid_station:sendCommsMessage(p,"We asked the asteroid miners what the technicians seemed particularly interested in for asteroid spelunking. Using that information, we've marked the asteroids where we think the technicians may be found.") then
								p:addToShipLog(string.format("[%s] We asked the asteroid miners what the technicians seemed particularly interested in for asteroid spelunking. Using that information, we've marked the asteroids where we think the technicians may be found",asteroid_station:getCallSign()),"Magenta")
							end
						end
					end
				end
			end
			for _, asteroid in ipairs(trav_asteroids) do
				if asteroid ~= nil and asteroid:isValid() and asteroid.vacation_spot then
					if asteroid:isScannedByFaction("Human Navy") then
						for pidx=1,32 do
							local p = getPlayerShip(pidx)
							if p ~= nil and p:isValid() then
								local p_a_distance = distance(p,asteroid)
								if p_a_distance < 1000 then
									if asteroid.detect_timer == nil then
										asteroid.detect_timer = 10
									end
									asteroid.detect_timer = asteroid.detect_timer - delta
									if asteroid.detect_timer < 0 then
										asteroid:setCallSign("Spelunking Outpost")
										if not asteroid:sendCommsMessage(p,string.format("You found us just in time, %s. Our air and energy were running low. We are transporting aboard.",p:getCallSign())) then
											p:addToShipLog(string.format("You found us just in time, %s. Our air and energy were running low. We are transporting aboard.",p:getCallSign()),"Magenta")
										end
										if miner_hints ~= nil then
											for _, z in ipairs(miner_hints) do
												z:destroy()
											end
											miner_hints = nil
										end
										p.technicians_aboard = true
										spelunkPlot = returnTechs
										break
									end
								end
							end
						end
					end
				end
			end
		end
	end
end
function returnTechs(delta)
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() and p.technicians_aboard then
			if p:isDocked(shipyard_station) then
				technician_vacation = false
				p:addToShipLog("The technicians thank you for the ride home","Magenta")
				spelunkPlot = nil
			end
		end
	end
end
function escapePodRetrieval(self,retriever)
	if retriever ~= nil and retriever:isValid() then
		if retriever.pod_aboard_count == nil then
			retriever.pod_aboard_count = 0
		end
		retriever.pod_aboard_count = retriever.pod_aboard_count + 1
		retriever:addToShipLog(string.format("The escape pod has been safely retrieved. Medical personnel are standing by on %s, waiting for you to dock",shipyard_station:getCallSign()),"Yellow")
	end
end
function destroyKraylorBase(delta)
	if human_base_danger == nil then
		human_base_danger = pirate_base_danger
	end
	if pirate_station == nil or not pirate_station:isValid() then
		globalMessage(string.format("Congratulations, You destroyed %s, the Kraylor base",pirate_station.name))
		victory("Human Navy")
	end
	if shipyard_station == nil or not shipyard_station:isValid() then
		globalMessage(string.format("You allowed %s to be destroyed",shipyard_station.name))
		victory("Kraylor")
	end
	if human_attack_timer == nil then
		human_attack_timer = 300 + random(1,30)
	end
	human_attack_timer = human_attack_timer - delta
	if human_attack_timer < 0 then
		print("human attack timeer less than zero")
		local ship_pools = {
			{
				"Adder MK6",
				"MU52 Hornet",
			},
			{
				"MT52 Hornet",
				"MU52 Hornet",
				"Nirvana R5",
				"Nirvana R3",
			},
			{
				"Adder MK3",
				"Adder MK5",
				"Adder MK7",
				"Adder MK8",
				"Adder MK9",
			},
			{
				"Phobos T3",
				"Adder MK9",
			},
		}
		local pool_choice = math.random(0,#ship_pools)
		local template_pool = nil
		if pool_choice ~= 0 then
			template_pool = ship_pools[pool_choice]
		end
		local player_count = 0
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				player_count = player_count + 1
			end
		end
		local ssx, ssy = shipyard_station:getPosition()
		local friends = spawnEnemies(ssx, ssy,1,"Human Navy",human_base_danger*player_count,template_pool)
		for _, friend in ipairs(friends) do
			friend:setCallSign(generateCallSign(nil,"Human Navy"))
			friend:orderFlyTowards(pirate_station:getPosition()):setScanned(true)
		end
		human_base_danger = human_base_danger + difficulty*4
		human_attack_timer = nil
	end
end
function cargoPickupProcess(self,retriever)
	if retriever ~= nil and retriever:isValid() then
		retriever.cargo_picked_up = true
		retriever:addToShipLog(string.format("The cargo dropped by %s has been retrieved",rescue_freighter:getCallSign()),"Magenta")
		if retriever.cargo < 1 then
			retriever.goods = {}
			retriever.cargo = retriever.maxCargo
		end
		retriever.cargo = retriever.cargo - 1
		if retriever.goods == nil then
			retriever.goods = {}
		end
		if retriever.goods[self.cargo] == nil then
			retriever.goods[self.cargo] = 0
		end
		retriever.goods[self.cargo] = retriever.goods[self.cargo] + 1
	end
end
function pirateHarassment(delta)
	if pirate_base_danger == nil then
		pirate_base_danger = 20
	end
	if shipyard_station ~= nil and shipyard_station:isValid() then
		if harassment_timer == nil then
			harassment_timer = 330 - difficulty * 20 + random(1,20)
		end
		harassment_timer = harassment_timer - delta
		if harassment_timer < 0 then
			harassment_timer = nil
			local start_neb = full_neb_list[math.random(1,#full_neb_list)]
			local nx, ny = start_neb:getPosition()
			local ship_pools = {
				{
					"Adder MK5",
					"MT52 Hornet",
				},
				{
					"MT52 Hornet",
					"MU52 Hornet",
					"Ktlitan Fighter",
					"Ktlitan Drone",
				},
				{
					"Adder MK3",
					"Adder MK4",
					"Adder MK5",
					"Adder MK6",
					"Adder MK7",
					"Adder MK8",
					"Adder MK9",
				},
				{
					"Ktlitan Drone",
					"Lite Drone",
					"Heavy Drone",
					"Jacket Drone",
				},
			}
			local pool_choice = math.random(0,#ship_pools)
			local template_pool = nil
			if pool_choice ~= 0 then
				template_pool = ship_pools[pool_choice]
			end
			local player_count = 0
			for pidx=1,32 do
				local p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					player_count = player_count + 1
				end
			end
			local enemies = spawnEnemies(nx,ny,1,"Kraylor",pirate_base_danger*player_count,template_pool)
			for _, enemy in ipairs(enemies) do
				enemy:orderFlyTowards(shipyard_station:getPosition())
			end
			pirate_base_danger = pirate_base_danger + difficulty*2
		end
	else
		globalMessage(string.format("You allowed %s to be destroyed",shipyard_station.name))
		victory("Kraylor")
	end
end
function plotTransport(delta)
	if transport_spawn_delay == nil then
		transport_spawn_delay = random(100,300)
	end
	if transport_list == nil then
		transport_list = {}
	end
	if #transport_list > 0 then
		for transport_index, transport in ipairs(transport_list) do
			if transport ~= nil and transport:isValid() then
				if transport.target ~= nil and transport.target:isValid() then
					local docked_with = transport:getDockedWith()
					if docked_with ~= nil then
						transport.undock_delay = transport.undock_delay - delta
--						print("Transport docked, transport:",transport:getCallSign(),"docked with:",docked_with,"dock target:",transport.target:getCallSign(),"delay:",transport.undock_delay)
						if transport.undock_delay < 0 then
							transport.target = selectTransportTarget(transport:getFaction())
							transport:orderDock(transport.target)
							transport.undock_delay = random(20,120)
--							print("delay done. new target:",transport.target:getCallSign(),"new delay:",transport.undock_delay)
						end
					end
				else
					for station_index, station in ipairs(friendly_neutral_stations) do
						if station == nil or not station:isValid() then
							table.remove(friendly_neutral_stations,station_index)
							break
						end
					end
					transport.target = selectTransportTarget(transport:getFaction())
					transport:orderDock(transport.target)
				end
			else
				table.remove(transport_list,transport_index)
				break
			end
		end
	end
	transport_spawn_delay = transport_spawn_delay - delta
	if transport_spawn_delay < 0 then
		transport_spawn_delay = nil
		if #transport_list < #friendly_neutral_stations then
			local transport_faction = "Independent"
			if random(1,10) <= 1 then
				transport_faction = "Human Navy"
			end
			local transport_types = {"Personnel","Goods","Garbage","Equipment","Fuel"}
			local transport_type = transport_types[math.random(1,#transport_types)]
			if random(1,100) <= 30 then
				transport_type = transport_type .. " Jump Freighter " .. math.random(3,5)
			else
				transport_type = transport_type .. " Freighter " .. math.random(1,5)
			end
			local new_transport = CpuShip():setTemplate(transport_type):setFaction(transport_faction):setCommsScript(""):setCommsFunction(commsShip)
			new_transport:setCallSign(generateCallSign(nil,transport_faction))
			new_transport.target = selectTransportTarget(new_transport:getFaction())
			new_transport.undock_delay = random(20,120)
			new_transport:orderDock(new_transport.target)
			local tx, ty = new_transport.target:getPosition()
			local dx, dy = vectorFromAngleNorth(random(0,360),random(25000,40000))
			new_transport:setPosition(tx+dx,ty+dy)
			table.insert(transport_list,new_transport)
		end
	end
end
function selectTransportTarget(transport_faction)
	local valid_station_count = 0
	for _, station in ipairs(friendly_neutral_stations) do
		if station ~= nil and station:isValid() then
			valid_station_count = valid_station_count + 1
		end
	end
	local valid_outside_station_count = 0
	for _, station in ipairs(outside_stations) do
		if station ~= nil and station:isValid() then
			valid_outside_station_count = valid_outside_station_count + 1
		end
	end
	local target_station = integral_station
	if math.random(1,3) <= 1 then
		repeat
			if transport_faction == "Independent" then
				local selection_index = math.random(0,#friendly_neutral_stations)
				if selection_index == 0 then
					target_station = pirate_station
				else
					target_station = friendly_neutral_stations[selection_index]
				end
			else
				target_station = friendly_neutral_stations[math.random(1,#friendly_neutral_stations)]
			end
		until(target_station ~= nil and target_station:isValid())
	else
		repeat
			target_station = outside_stations[math.random(1,#outside_stations)]
		until(target_station ~= nil and target_station:isValid())
	end
	return target_station
end

-- Terrain and environment creation functions
function angleFromVectorNorth(p1x,p1y,p2x,p2y)
	TWOPI = 6.2831853071795865
	RAD2DEG = 57.2957795130823209
	atan2parm1 = p2x - p1x
	atan2parm2 = p2y - p1y
	theta = math.atan2(atan2parm1, atan2parm2)
	if theta < 0 then
		theta = theta + TWOPI
	end
	return (360 - (RAD2DEG * theta)) % 360
end
function vectorFromAngleNorth(angle,distance)
--	print("input angle to vectorFromAngleNorth:")
--	print(angle)
	angle = (angle + 270) % 360
	local x, y = vectorFromAngle(angle,distance)
	return x, y
end
---------------------------
-- Game Master functions --
---------------------------
function debugButtons()
	clearGMFunctions()
	addGMFunction("-From Debug",mainGMButtons)
	addGMFunction("Object Counts",function()
		addGMMessage(starryUtil.debug.getNumberOfObjectsString())
	end)
	addGMFunction("always popup debug",function()
		popupGMDebug = "always"
	end)
	addGMFunction("once popup debug",function()
		popupGMDebug = "once"
	end)
	addGMFunction("never popup debug",function()
		popupGMDebug = "never"
	end)
end
function mainGMButtons()
	clearGMFunctions()
	local playerShipCount = 0
	local highestPlayerIndex = 0
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil then
			if p:isValid() then
				playerShipCount = playerShipCount + 1
			end
			highestPlayerIndex = pidx
		end
	end
	addGMFunction(string.format("+Player ships %i/%i",playerShipCount,highestPlayerIndex),playerShip)
	addGMFunction("+debug",debugButtons)
	if spicePlot == nil then
		addGMFunction("Stop or continue",function()
			spicePlot = pirateHarassment
			rescued_escape_pods = true
			finalize_player_ship_work = true
			escape_pod_count = 0
			addGMMessage("Skipping to the point where the player shooses to stop or to fight the Kraylor base")
		end)
	end
end
function showPlayerInfoOnConsole(delta)
	if show_player_info then
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				local player_name = p:getCallSign()
				if p.player_info_timer == nil then
					p.player_info_timer = delta + 5
				end
				p.player_info_timer = p.player_info_timer - delta
				if p.player_info_timer < 0 then
					if show_only_player_name then
						if p.show_name_helm then
							if p:hasPlayerAtPosition("Helms") then
								p.name_helm = "name_helm"
								p:addCustomInfo("Helms",p.name_helm,player_name)
							end
						else
							if p.name_helm ~= nil then
								p:removeCustom(p.name_helm)
								p.name_helm = nil
							end
						end
						if p.show_name_weapons then
							if p:hasPlayerAtPosition("Weapons") then
								p.name_weapons = "name_weapons"
								p:addCustomInfo("Weapons",p.name_weapons,player_name)
							end
						else
							if p.name_weapons ~= nil then
								p:removeCustom(p.name_weapons)
								p.name_weapons = nil
							end
						end
						if p.show_name_engineer then
							if p:hasPlayerAtPosition("Engineering") then
								p.name_engineer = "name_engineer"
								p:addCustomInfo("Engineering",p.name_engineer,player_name)
							end
						else
							if p.name_engineer ~= nil then
								p:removeCustom(p.name_engineer)
								p.name_engineer = nil
							end
						end
						p.player_info_timer = delta + 5
					else	--show player name and other info
						if p.name_toggle == nil then
							p.name_toggle = true
						end
						if p.name_toggle then	--show player name
							if p.show_name_helm then
								if p:hasPlayerAtPosition("Helms") then
									p.name_helm = "name_helm"
									p:addCustomInfo("Helms",p.name_helm,player_name)
								end
							else
								if p.name_helm ~= nil then
									p:removeCustom(p.name_helm)
									p.name_helm = nil
								end
							end
							if p.show_name_weapons then
								if p:hasPlayerAtPosition("Weapons") then
									p.name_weapons = "name_weapons"
									p:addCustomInfo("Weapons",p.name_weapons,player_name)
								end
							else
								if p.name_weapons ~= nil then
									p:removeCustom(p.name_weapons)
									p.name_weapons = nil
								end
							end
							if p.show_name_engineer then
								if p:hasPlayerAtPosition("Engineering") then
									p.name_engineer = "name_engineer"
									p:addCustomInfo("Engineering",p.name_engineer,player_name)
								end
							else
								if p.name_engineer ~= nil then
									p:removeCustom(p.name_engineer)
									p.name_engineer = nil
								end
							end
							p.name_toggle = false
							p.player_info_timer = delta + 5
						else	--show other info
							local ship_info = ""
							info_choice = info_choice + 1
							if info_choice > info_choice_max then
								info_choice = 1
							end
							if info_choice == 1 then
								ship_info = string.format("Repair Crew: %i",p:getRepairCrewCount())
								if p.maxRepairCrew ~= nil then
									ship_info = string.format("%s/%i",ship_info,p.maxRepairCrew)
								end
							elseif info_choice == 2 then
								ship_info = string.format("Hull: %i/%i",math.floor(p:getHull()),math.floor(p:getHullMax()))
							elseif info_choice == 3 then
								ship_info = "Shield: "
								if p:getShieldCount() == 1 then
									ship_info = string.format("%s%i/%i",ship_info,math.floor(p:getShieldLevel(0)),math.floor(p:getShieldMax(0)))
								else
									ship_info = string.format("%sF:%i/%i R:%i/%i",ship_info,math.floor(p:getShieldLevel(0)),math.floor(p:getShieldMax(0)),math.floor(p:getShieldLevel(1)),math.floor(p:getShieldMax(1)))
								end
							elseif info_choice == 4 then
								local beam_count = 0
								for i=0,15 do
									if p:getBeamWeaponRange(i) > 0 then
										beam_count = beam_count + 1
									end
								end
								ship_info = string.format("Beams: %i, Tubes: %i",beam_count,p:getWeaponTubeCount())
							else
								ship_info = p:getTypeName()
								print(ship_info)
								if ship_info == nil then
									ship_info = string.format("Repair Crew: %i",p:getRepairCrewCount())
								else
									ship_info = string.format("Type: %s",ship_info)
								end
							end
							if p.show_name_helm then
								if p:hasPlayerAtPosition("Helms") then
									p.name_helm = "name_helm"
									p:addCustomInfo("Helms",p.name_helm,ship_info)
								end
							else
								if p.name_helm ~= nil then
									p:removeCustom(p.name_helm)
									p.name_helm = nil
								end
							end
							if p.show_name_weapons then
								if p:hasPlayerAtPosition("Weapons") then
									p.name_weapons = "name_weapons"
									p:addCustomInfo("Weapons",p.name_weapons,ship_info)
								end
							else
								if p.name_weapons ~= nil then
									p:removeCustom(p.name_weapons)
									p.name_weapons = nil
								end
							end
							if p.show_name_engineer then
								if p:hasPlayerAtPosition("Engineering") then
									p.name_engineer = "name_engineer"
									p:addCustomInfo("Engineering",p.name_engineer,ship_info)
								end
							else
								if p.name_engineer ~= nil then
									p:removeCustom(p.name_engineer)
									p.name_engineer = nil
								end
							end
							p.name_toggle = true
							p.player_info_timer = delta + 3
						end
					end
				end
			end
		end
	else	--not show player info
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p.name_helm ~= nil then
					p:removeCustom(p.name_helm)
					p.name_helm = nil
				end
				if p.name_weapons ~= nil then
					p:removeCustom(p.name_weapons)
					p.name_weapons = nil
				end
				if p.name_engineer ~= nil then
					p:removeCustom(p.name_engineer)
					p.name_engineer = nil
				end
			end
		end
	end
end
function playerShip()
	clearGMFunctions()
	addGMFunction("-From Player ships",mainGMButtons)
	addGMFunction("+Describe stock",describeStockPlayerShips)
end
function describeStockPlayerShips()
	clearGMFunctions()
	addGMFunction("-Back",playerShip)
	addGMFunction("Atlantis",function()
		addGMMessage("Atlantis: Corvette, Destroyer   Hull:250   Shield:200,200   Size:400   Repair Crew:3   Cargo:6   R.Strength:52\nDefault advanced engine:Jump   Speeds: Impulse:90   Spin:10   Accelerate:20   C.Maneuver: Boost:400 Strafe:250\nBeams:2\n   Arc:100   Direction:-20   Range:1.5   Cycle:6   Damage:8\n   Arc:100   Direction: 20   Range:1.5   Cycle:6   Damage:8\nTubes:5   Load Speed:10   Side:4   Back:1\n   Direction:-90   Type:Exclude Mine\n   Direction:-90   Type:Exclude Mine\n   Direction: 90   Type:Exclude Mine\n   Direction: 90   Type:Exclude Mine\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      12 Homing\n      04 Nuke\n      08 Mine\n      06 EMP\n      20 HVLI\nA refitted Atlantis X23 for more general tasks. The large shield system has been replaced with an advanced combat maneuvering systems and improved impulse engines. Its missile loadout is also more diverse. Mistaking the modified Atlantis for an Atlantis X23 would be a deadly mistake.")
	end)
	addGMFunction("Benedict",function()
		addGMMessage("Benedict: Corvette, Freighter/Carrier   Hull:200   Shield:70,70   Size:400   Repair Crew:3   Cargo Space:9   R.Strength:10\nShip classes that may dock with Benedict:Starfighter, Frigate, Corvette\nDefault advanced engine:Jump (5U - 90U)   Speeds: Impulse:60   Spin:6   Accelerate:8   C.Maneuver: Boost:400 Strafe:250\nBeams:2 Turreted Speed:6\n   Arc:90   Direction:  0   Range:1.5   Cycle:6   Damage:4\n   Arc:90   Direction:180   Range:1.5   Cycle:6   Damage:4\nBenedict is an improved version of the Jump Carrier")
	end)
	addGMFunction("Crucible",function()
		addGMMessage("Crucible: Corvette, Popper   Hull:160   Shield:160,160   Size:200   Repair Crew:4   Cargo Space:5   R.Strength:45\nDefault advanced engine:Warp (750)   Speeds: Impulse:80   Spin:15   Accelerate:40   C.Maneuver: Boost:400 Strafe:250\nBeams:2\n   Arc:70   Direction:-30   Range:1   Cycle:6   Damage:5\n   Arc:70   Direction: 30   Range:1   Cycle:6   Damage:5\nTubes:6   Load Speed:8   Front:3   Side:2   Back:1\n   Direction:   0   Type:HVLI Only - Small\n   Direction:   0   Type:HVLI Only\n   Direction:   0   Type:HVLI Only - Large\n   Direction:-90   Type:Exclude Mine\n   Direction: 90   Type:Exclude Mine\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      08 Homing\n      04 Nuke\n      06 Mine\n      06 EMP\n      24 HVLI\nA number of missile tubes range around this ship. Beams were deemed lower priority, though they are still present. Stronger defenses than a frigate, but not as strong as the Atlantis")
	end)
	addGMFunction("Ender",function()
		addGMMessage("Ender: Dreadnaught, Battlecruiser   Hull:100   Shield:1200,1200   Size:2000   Repair Crew:8   Cargo Space:20   R.Strength:100\nShip classes that may dock with Benedict:Starfighter, Frigate, Corvette   Energy:1200\nDefault advanced engine:Jump   Speeds: Impulse:30   Spin:2   Accelerate:6   C.Maneuver: Boost:800 Strafe:500\nBeams:12 6 left, 6 right turreted Speed:6\n   Arc:120   Direction:-90   Range:2.5   Cycle:6.1   Damage:4\n   Arc:120   Direction:-90   Range:2.5   Cycle:6.0   Damage:4\n   Arc:120   Direction: 90   Range:2.5   Cycle:5.8   Damage:4\n   Arc:120   Direction: 90   Range:2.5   Cycle:6.3   Damage:4\n   Arc:120   Direction:-90   Range:2.5   Cycle:5.9   Damage:4\n   Arc:120   Direction:-90   Range:2.5   Cycle:6.4   Damage:4\n   Arc:120   Direction: 90   Range:2.5   Cycle:5.7   Damage:4\n   Arc:120   Direction: 90   Range:2.5   Cycle:5.6   Damage:4\n   Arc:120   Direction:-90   Range:2.5   Cycle:6.6   Damage:4\n   Arc:120   Direction:-90   Range:2.5   Cycle:5.5   Damage:4\n   Arc:120   Direction: 90   Range:2.5   Cycle:6.5   Damage:4\n   Arc:120   Direction: 90   Range:2.5   Cycle:6.2   Damage:4\nTubes:2   Load Speed:8   Front:1   Back:1\n   Direction:   0   Type:Homing Only\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      6 Homing\n      6 Mine")
	end)
	addGMFunction("Flavia P.Falcon",function()
		addGMMessage("Flavia P.Falcon: Frigate, Light Transport   Hull:100   Shield:70,70   Size:200   Repair Crew:8   Cargo Space:15   R.Strength:13\nDefault advanced engine:Warp (500)   Speeds: Impulse:60   Spin:10   Accelerate:10   C.Maneuver: Boost:250 Strafe:150\nBeams:2 rear facing\n   Arc:40   Direction:170   Range:1.2   Cycle:6   Damage:6\n   Arc:40   Direction:190   Range:1.2   Cycle:6   Damage:6\nTubes:1   Load Speed:20   Back:1\n   Direction:180   Type:Any\n   Ordnance stock and type:\n      3 Homing\n      1 Nuke\n      1 Mine\n      5 HVLI\nThe Flavia P.Falcon has a nuclear-capable rear-facing weapon tube and a warp drive.")
	end)
	addGMFunction("Hathcock",function()
		addGMMessage("Hathcock: Frigate, Cruiser: Sniper   Hull:120   Shield:70,70   Size:200   Repair Crew:2   Cargo Space:6   R.Strength:30\nDefault advanced engine:Jump   Speeds: Impulse:50   Spin:15   Accelerate:8   C.Maneuver: Boost:200 Strafe:150\nBeams:4 front facing\n   Arc:04   Direction:0   Range:1.4   Cycle:6   Damage:4\n   Arc:20   Direction:0   Range:1.2   Cycle:6   Damage:4\n   Arc:60   Direction:0   Range:1.0   Cycle:6   Damage:4\n   Arc:90   Direction:0   Range:0.8   Cycle:6   Damage:4\nTubes:2   Load Speed:15   Side:2\n   Direction:-90   Type:Any\n   Direction: 90   Type:Any\n   Ordnance stock and type:\n      4 Homing\n      1 Nuke\n      2 EMP\n      8 HVLI\nLong range narrow beam and some point defense beams, broadside missiles. Agile for a frigate")
	end)
	addGMFunction("Kiriya",function()
		addGMMessage("Kiriya: Corvette, Freighter/Carrier   Hull:200   Shield:70,70   Size:400   Repair Crew:3   Cargo Space:9   R.Strength:10\nShip classes that may dock with Benedict:Starfighter, Frigate, Corvette\nDefault advanced engine:Warp (750)   Speeds: Impulse:60   Spin:6   Accelerate:8   C.Maneuver: Boost:400 Strafe:250\nBeams:2 Turreted Speed:6\n   Arc:90   Direction:  0   Range:1.5   Cycle:6   Damage:4\n   Arc:90   Direction:180   Range:1.5   Cycle:6   Damage:4\nKiriya is an improved warp drive version of the Jump Carrier")
	end)
	addGMFunction("MP52 Hornet",function()
		addGMMessage("MP52 Hornet: Starfighter, Interceptor   Hull:70   Shield:60   Size:100   Repair Crew:1   Cargo:3   R.Strength:7\nDefault advanced engine:None   Speeds: Impulse:125   Spin:32   Accelerate:40   C.Maneuver: Boost:600   Energy:400\nBeams:2\n   Arc:30   Direction: 5   Range:.9   Cycle:4   Damage:2.5\n   Arc:30   Direction:-5   Range:.9   Cycle:4   Damage:2.5\nThe MP52 Hornet is a significantly upgraded version of MU52 Hornet, with nearly twice the hull strength, nearly three times the shielding, better acceleration, impulse boosters, and a second laser cannon.")
	end)
	addGMFunction("Maverick",function()
		addGMMessage("Maverick: Corvette, Gunner   Hull:160   Shield:160,160   Size:200   Repair Crew:4   Cargo:5   R.Strength:45\nDefault advanced engine:Warp (800)   Speeds: Impulse:80   Spin:15   Accelerate:40   C.Maneuver: Boost:400 Strafe:250\nBeams:6   3 forward, 2 side, 1 back (turreted speed .5)\n   Arc:10   Direction:  0   Range:2.0   Cycle:6   Damage:6\n   Arc: 90   Direction:-20   Range:1.5   Cycle:6   Damage:8\n   Arc: 90   Direction: 20   Range:1.5   Cycle:6   Damage:8\n   Arc: 40   Direction:-70   Range:1.0   Cycle:4   Damage:6\n   Arc: 40   Direction: 70   Range:1.0   Cycle:4   Damage:6\n   Arc:180   Direction:180   Range:0.8   Cycle:6   Damage:4   (turreted speed: .5)\nTubes:3   Load Speed:8   Side:2   Back:1\n   Direction:-90   Type:Exclude Mine\n   Direction: 90   Type:Exclude Mine\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      06 Homing\n      02 Nuke\n      02 Mine\n      04 EMP\n      10 HVLI\nA number of beams bristle from various points on this gunner. Missiles were deemed lower priority, though they are still present. Stronger defenses than a frigate, but not as strong as the Atlantis")
	end)
	addGMFunction("Nautilus",function()
		addGMMessage("Nautilus: Frigate, Mine Layer   Hull:100   Shield:60,60   Size:200   Repair Crew:4   Cargo:7   R.Strength:12\nDefault advanced engine:Jump   Speeds: Impulse:100   Spin:10   Accelerate:15   C.Maneuver: Boost:250 Strafe:150\nBeams:2 Turreted Speed:6\n   Arc:90   Direction: 35   Range:1   Cycle:6   Damage:6\n   Arc:90   Direction:-35   Range:1   Cycle:6   Damage:6\nTubes:3   Load Speed:10   Back:3\n   Direction:180   Type:Mine Only\n   Direction:180   Type:Mine Only\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      12 Mine\nSmall mine laying vessel with minimal armament, shields and hull")
	end)
	addGMFunction("Phobos MP3",function()
		addGMMessage("Phobos MP3: Frigate, Cruiser   Hull:200   Shield:100,100   Size:200   Repair Crew:3   Cargo:10   R.Strength:19\nDefault advanced engine:None   Speeds: Impulse:80   Spin:10   Accelerate:20   C.Maneuver: Boost:400 Strafe:250\nBeams:2\n   Arc:90   Direction:-15   Range:1.2   Cycle:8   Damage:6\n   Arc:90   Direction: 15   Range:1.2   Cycle:8   Damage:6\nTubes:3   Load Speed:10   Front:2   Back:1\n   Direction: -1   Type:Exclude Mine\n   Direction:  1   Type:Exclude Mine\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      10 Homing\n      02 Nuke\n      04 Mine\n      03 EMP\n      20 HVLI\nPlayer variant of the Phobos M3, not as strong as the atlantis, but has front firing tubes, making it an easier to use ship in some scenarios.")
	end)
	addGMFunction("Piranha",function()
		addGMMessage("Piranha: Frigate, Cruiser: Light Artillery   Hull:120   Shield:70,70   Size:200   Repair Crew:2   Cargo:8   R.Strength:16\nDefault advanced engine:None   Speeds: Impulse:60   Spin:10   Accelerate:8   C.Maneuver: Boost:200 Strafe:150\nTubes:8   Load Speed:8   Side:6   Back:2\n   Direction:-90   Type:HVLI and Homing Only\n   Direction:-90   Type:Any\n   Direction:-90   Type:HVLI and Homing Only\n   Direction: 90   Type:HVLI and Homing Only\n   Direction: 90   Type:Any\n   Direction: 90   Type:HVLI and Homing Only\n   Direction:170   Type:Mine Only\n   Direction:190   Type:Mine Only\n   Ordnance stock and type:\n      12 Homing\n      06 Nuke\n      08 Mine\n      20 HVLI\nThis combat-specialized Piranha F12 adds mine-laying tubes, combat maneuvering systems, and a jump drive.")
	end)	
	addGMFunction("Player Cruiser",function()
		addGMMessage("Player Cruiser:   Hull:200   Shield:80,80   Size:400   Repair Crew:3   Cargo:6   R.Strength:40\nDefault advanced engine:Jump   Speeds: Impulse:90   Spin:10   Accelerate:20   C.Maneuver: Boost:400 Strafe:250\nBeams:2\n   Arc:90   Direction:-15   Range:1   Cycle:6   Damage:10\n   Arc:90   Direction: 15   Range:1   Cycle:6   Damage:10\nTubes:3   Load Speed:8   Front:2   Back:1\n   Direction: -5   Type:Exclude Mine\n   Direction:  5   Type:Exclude Mine\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      12 Homing\n      04 Nuke\n      08 Mine\n      06 EMP")
	end)
	addGMFunction("Player Fighter",function()
		addGMMessage("Player Fighter:   Hull:60   Shield:40   Size:100   Repair Crew:3   Cargo:3   R.Strength:7\nDefault advanced engine:None   Speeds: Impulse:110   Spin:20   Accelerate:40   C.Maneuver: Boost:600   Energy:400\nBeams:2\n   Arc:40   Direction:-10   Range:1   Cycle:6   Damage:8\n   Arc:40   Direction: 10   Range:1   Cycle:6   Damage:8\nTube:1   Load Speed:10   Front:1\n   Direction:0   Type:HVLI Only\n   Ordnance stock and type:\n      4 HVLI")
	end)
	addGMFunction("Player Missile Cr.",function()
		addGMMessage("Player Missile Cr.:   Hull:200   Shield:110,70   Size:200   Repair Crew:3   Cargo:8   R.Strength:45\nDefault advanced engine:Warp (800)   Speeds: Impulse:60   Spin:8   Accelerate:15   C.Maneuver: Boost:450 Strafe:150\nTubes:7   Load Speed:8   Front:2   Side:4   Back:1\n   Direction:  0   Type:Exclude Mine\n   Direction:  0   Type:Exclude Mine\n   Direction: 90   Type:Homing Only\n   Direction: 90   Type:Homing Only\n   Direction:-90   Type:Homing Only\n   Direction:-90   Type:Homing Only\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      30 Homing\n      08 Nuke\n      12 Mine\n      10 EMP")
	end)	
	addGMFunction("Repulse",function()
		addGMMessage("Repulse: Frigate, Armored Transport   Hull:120   Shield:80,80   Size:200   Repair Crew:8   Cargo:12   R.Strength:14\nDefault advanced engine:Jump   Speeds: Impulse:55   Spin:9   Accelerate:10   C.Maneuver: Boost:250 Strafe:150\nBeams:2 Turreted Speed:5\n   Arc:200   Direction: 90   Range:1.2   Cycle:6   Damage:5\n   Arc:200   Direction:-90   Range:1.2   Cycle:6   Damage:5\nTubes:2   Load Speed:20   Front:1   Back:1\n   Direction:  0   Type:Any\n   Direction:180   Type:Any\n   Ordnance stock and type:\n      4 Homing\n      6 HVLI\nJump/Turret version of Flavia Falcon")
	end)
	addGMFunction("Striker",function()
		addGMMessage("Striker: Starfighter, Patrol   Hull:120   Shield:50,30   Size:200   Repair Crew:2   Cargo:4   R.Strength:8\nDefault advanced engine:None   Speeds: Impulse:45   Spin:15   Accelerate:30   C.Maneuver: Boost:250 Strafe:150   Energy:500\nBeams:2 Turreted Speed:6\n   Arc:100   Direction:-15   Range:1   Cycle:6   Damage:6\n   Arc:100   Direction: 15   Range:1   Cycle:6   Damage:6\nThe Striker is the predecessor to the advanced striker, slow but agile, but does not do an extreme amount of damage, and lacks in shields")
	end)
	addGMFunction("ZX-Lindworm",function()
		addGMMessage("ZX-Lindworm: Starfighter, Bomber   Hull:75   Shield:40   Size:100   Repair Crew:1   Cargo:3   R.Strength:8\nDefault advanced engine:None   Speeds: Impulse:70   Spin:15   Accelerate:25   C.Maneuver: Boost:250 Strafe:150   Energy:400\nBeam:1 Turreted Speed:4\n   Arc:270   Direction:180   Range:0.7   Cycle:6   Damage:2\nTubes:3   Load Speed:10   Front:3 (small)\n   Direction: 0   Type:Any - small\n   Direction: 1   Type:HVLI Only - small\n   Direction:-1   Type:HVLI Only - small\n   Ordnance stock and type:\n      03 Homing\n      12 HVLI")
	end)
end
--------------------------------
-- Station creation functions --
--------------------------------
function szt()
--Randomly choose station size template
	stationSizeRandom = random(1,100)
	if stationSizeRandom <= 8 then
		sizeTemplate = "Huge Station"		-- 8 percent huge
	elseif stationSizeRandom <= 24 then
		sizeTemplate = "Large Station"		--16 percent large
	elseif stationSizeRandom <= 50 then
		sizeTemplate = "Medium Station"		--26 percent medium
	else
		sizeTemplate = "Small Station"		--50 percent small
	end
	return sizeTemplate
end
function randomMineral(exclude)
	local good = mineralGoods[math.random(1,#mineralGoods)]
	if exclude == nil then
		return good
	else
		repeat
			good = mineralGoods[math.random(1,#mineralGoods)]
		until(good ~= exclude)
		return good
	end
end
function randomComponent(exclude)
	local good = componentGoods[math.random(1,#componentGoods)]
	if exclude == nil then
		return good
	else
		repeat
			good = componentGoods[math.random(1,#componentGoods)]
		until(good ~= exclude)
		return good
	end
end
function populateStationPool()
	station_pool = {
		["Science"] = {
			["Asimov"] = {
		        weapon_available = 	{
		        	Homing =			true,
		        	HVLI =				random(1,13)<=(9-difficulty),
		        	Mine =				true,
		        	Nuke =				random(1,13)<=(5-difficulty),
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop = "friend",
					reinforcements = "friend",
					jumpsupplydrop = "friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 			1.0, 
		        	neutral = 			3.0,
		        },
        		goods = {	
        			tractor = {
        				quantity =	5,	
        				cost =		48,
        			},
        			repulsor = {
        				quantity =	5,
        				cost =		48,
        			},
        		},
		        trade = {	
		        	food =			false, 
		        	medicine =		false, 
		        	luxury =		false,
		        },
				description = "Training and Coordination", 
				general = "We train naval cadets in routine and specialized functions aboard space vessels and coordinate naval activity throughout the sector", 
				history = "The original station builders were fans of the late 20th century scientist and author Isaac Asimov. The station was initially named Foundation, but was later changed simply to Asimov. It started off as a stellar observatory, then became a supply stop and as it has grown has become an educational and coordination hub for the region",
			},
			["Armstrong"] =	{
		        weapon_available = {
		        	Homing = 			random(1,13)<=(8-difficulty),	
		        	HVLI = 				true,		
		        	Mine = 				random(1,13)<=(7-difficulty),	
		        	Nuke = 				random(1,13)<=(5-difficulty),	
		        	EMP = 				true
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {	
					warp = {
						quantity =	5,	
						cost =		77,
					},
					repulsor = {
						quantity =	5,	
						cost =		62,
					},
				},
				trade = {	
					food = random(1,100) <= 45, 
					medicine = false, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Warp and Impulse engine manufacturing", 
				general = "We manufacture warp, impulse and jump engines for the human navy fleet as well as other independent clients on a contract basis", 
				history = "The station is named after the late 19th century astronaut as well as the fictionlized stations that followed. The station initially constructed entire space worthy vessels. In time, it transitioned into specializeing in propulsion systems.",
			},
			["Broeck"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					warp = {
						quantity =	5,
						cost =		36,
					},
				},
				trade = {
					food = random(1,100) <= 14, 
					medicine = false, 
					luxury = random(1,100) < 62,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Warp drive components", 
				general = "We provide warp drive engines and components", 
				history = "This station is named after Chris Van Den Broeck who did some initial research into the possibility of warp drive in the late 20th century on Earth",
			},
			["Coulomb"] = {
		        weapon_available = 	{
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
        		goods = {	
        			circuit =	{
        				quantity =	5,	
        				cost =		50,
        			},
        		},
        		trade = {	
        			food = random(1,100) <= 35, 
        			medicine = false, 
        			luxury = random(1,100) < 82,
        		},
				buy =	{
					[randomMineral()] = math.random(40,200),
				},
				description = "Shielded circuitry fabrication", 
				general = "We make a large variety of circuits for numerous ship systems shielded from sensor detection and external control interference", 
				history = "Our station is named after the law which quantifies the amount of force with which stationary electrically charged particals repel or attact each other - a fundamental principle in the design of our circuits",
			},
			["Heyes"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				true,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					sensor = {
						quantity =	5,
						cost =		72,
					},
				},
				trade = {
					food = random(1,100) <= 32, 
					medicine = false, 
					luxury = true,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Sensor components", 
				general = "We research and manufacture sensor components and systems", 
				history = "The station is named after Tony Heyes the inventor of some of the earliest electromagnetic sensors in the mid 20th century on Earth in the United Kingdom to assist blind human mobility",
			},
			["Hossam"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					nanites = {
						quantity =	5,	
						cost =		90,
					},
				},
				trade = {
					food = random(1,100) < 24, 
					medicine = random(1,100) < 44, 
					luxury = random(1,100) < 63,
				},
				description = "Nanite supplier", 
				general = "We provide nanites for various organic and non-organic systems", 
				history = "This station is named after the nanotechnologist Hossam Haick from the early 21st century on Earth in Israel",
			},
			["Maiman"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				false,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					beam = {
						quantity =	5,
						cost =		70,
					},
				},
				trade = {
					food = random(1,100) <= 75, 
					medicine = true, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Energy beam components", 
				general = "We research and manufacture energy beam components and systems", 
				history = "The station is named after Theodore Maiman who researched and built the first laser in the mid 20th century on Earth",
			},
			["Malthus"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
		        goods = {},
    			trade = {
    				food = random(1,100) <= 65, 
    				medicine = false, 
    				luxury = false,
    			},
    			description = "Gambling and resupply",
		        general = "The oldest station in the quadrant",
		        history = "",
			},
			["Marconi"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					beam = {
						quantity =	5,
						cost =		80,
					},
				},
				trade = {
					food = random(1,100) <= 53, 
					medicine = false, 
					luxury = true,
				},
				description = "Energy Beam Components", 
				general = "We manufacture energy beam components", 
				history = "Station named after Guglielmo Marconi an Italian inventor from early 20th century Earth who, along with Nicolo Tesla, claimed to have invented a death ray or particle beam weapon",
			},
			["Miller"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					optic =	{
						quantity =	5,
						cost =		60,
					},
				},
				trade = {
					food = random(1,100) <= 68, 
					medicine = false, 
					luxury = false,
				},
				description = "Exobiology research", 
				general = "We study recently discovered life forms not native to Earth", 
				history = "This station was named after one of the early exobiologists from mid 20th century Earth, Dr. Stanley Miller",
			},
			["Shawyer"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					impulse = {
						quantity =	5,
						cost =		100,
					},
				},
				trade = {
					food = random(1,100) <= 42, 
					medicine = false, 
					luxury = true,
				},
				description = "Impulse engine components", 
				general = "We research and manufacture impulse engine components and systems", 
				history = "The station is named after Roger Shawyer who built the first prototype impulse engine in the early 21st century",
			},
		},
		["History"] = {
			["Archimedes"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					beam = {
						quantity =	5,
						cost =		80,
					},
				},
				trade = {
					food = true, 
					medicine = false, 
					luxury = true,
				},
				description = "Energy and particle beam components", 
				general = "We fabricate general and specialized components for ship beam systems", 
				history = "This station was named after Archimedes who, according to legend, used a series of adjustable focal length mirrors to focus sunlight on a Roman naval fleet invading Syracuse, setting fire to it",
			},
			["Chatuchak"] =	{
		        weapon_available = {
		        	Homing =				random(1,10)<=(8-difficulty),	
		        	HVLI =				random(1,10)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,10)<=(5-difficulty),	
		        	EMP =				random(1,10)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		60,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Trading station", 
				general = "Only the largest market and trading location in twenty sectors. You can find your heart's desire here", 
				history = "Modeled after the early 21st century bazaar on Earth in Bangkok, Thailand. Designed and built with trade and commerce in mind",
			},
			["Grasberg"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		70,
					},
				},
				trade = {
					food = true, 
					medicine = false, 
					luxury = false,
				},
				buy = {
					[randomComponent()] = math.random(40,200),
				},
				description = "Mining", 
				general ="We mine nearby asteroids for precious minerals and process them for sale", 
				history = "This station's name is inspired by a large gold mine on Earth in Indonesia. The station builders hoped to have a similar amount of minerals found amongst these asteroids",
			},
			["Hayden"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					nanites = {
						quantity =	5,
						cost =		65,
					},
				},
				trade = {
					food = random(1,100) <= 85, 
					medicine = false, 
					luxury = false,
				},
				description = "Observatory and stellar mapping", 
				general = "We study the cosmos and map stellar phenomena. We also track moving asteroids. Look out! Just kidding", 
				history = "Station named in honor of Charles Hayden whose philanthropy continued astrophysical research and education on Earth in the early 20th century",
			},
			["Lipkin"] = {
		        weapon_available = {
		        	Homing =				random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					autodoc = {
						quantity =	5,
						cost =		76,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Autodoc components", 
				general = "", 
				history = "The station is named after Dr. Lipkin who pioneered some of the research and application around robot assisted surgery in the area of partial nephrectomy for renal tumors in the early 21st century on Earth",
			},
			["Madison"] = {
		        weapon_available = {
		        	Homing =			false,		
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(60,70),
					},
				},
				trade = {
					food = false, 
					medicine = true, 
					luxury = false,
				},
				description = "Zero gravity sports and entertainment", 
				general = "Come take in a game or two or perhaps see a show", 
				history = "Named after Madison Square Gardens from 21st century Earth, this station was designed to serve similar purposes in space - a venue for sports and entertainment",
			},
			["Rutherford"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					shield = {
						quantity =	5,	
						cost =		90,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = random(1,100) < 43,
				},
				description = "Shield components and research", 
				general = "We research and fabricate components for ship shield systems", 
				history = "This station was named after the national research institution Rutherford Appleton Laboratory in the United Kingdom which conducted some preliminary research into the feasability of generating an energy shield in the late 20th century",
			},
			["Toohie"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					shield = {
						quantity =	5,
						cost =		90,
					},
				},
				trade = {
					food = random(1,100) <= 21, 
					medicine = false, 
					luxury = true,
				},
				description = "Shield and armor components and research", 
				general = "We research and make general and specialized components for ship shield and ship armor systems", 
				history = "This station was named after one of the earliest researchers in shield technology, Alexander Toohie back when it was considered impractical to construct shields due to the physics involved."},
		},
		["Pop Sci Fi"] = {
			["Anderson"] = {
		        weapon_available = {
		        	Homing = false,		
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					battery = {
						quantity =	5,
						cost =		66,
					},
        			software = {
        				quantity =	5,
        				cost =		115,
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Battery and software engineering", 
				general = "We provide high quality high capacity batteries and specialized software for all shipboard systems", 
				history = "The station is named after a fictional software engineer in a late 20th century movie depicting humanity unknowingly conquered by aliens and kept docile by software generated illusion",
			},
			["Archer"] = {
		        weapon_available = {
		        	Homing = 			random(1,13)<=(8-difficulty),	
		        	HVLI = 				true,		
		        	Mine = 				random(1,13)<=(7-difficulty),	
		        	Nuke = 				random(1,13)<=(5-difficulty),	
		        	EMP = 				true
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					shield = {
						quantity =	5,
						cost =		90,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Shield and Armor Research", 
				general = "The finest shield and armor manufacturer in the quadrant", 
				history = "We named this station for the pioneering spirit of the 22nd century Starfleet explorer, Captain Jonathan Archer",
			},
			["Barclay"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					communication =	{
						quantity =	5,
						cost =		58,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Communication components", 
				general = "We provide a range of communication equipment and software for use aboard ships", 
				history = "The station is named after Reginald Barclay who established the first transgalactic com link through the creative application of a quantum singularity. Station personnel often refer to the station as the Broccoli station",
			},
			["Calvin"] = {
		        weapon_available = {
		        	Homing =			false,		
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {	
					robotic = {
						quantity =	5,	
						cost = 		90,
					},
				},
				trade = {
					food = random(1,100) <= 35, 
					medicine = false, 
					luxury = true,
				},
				buy =	{
					[randomComponent("robotic")] = math.random(40,200)
				},
				description = "Robotic research", 
				general = "We research and provide robotic systems and components", 
				history = "This station is named after Dr. Susan Calvin who pioneered robotic behavioral research and programming",
			},
			["Cavor"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					filament = {
						quantity =	5,
						cost =		42,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Advanced Material components", 
				general = "We fabricate several different kinds of materials critical to various space industries like ship building, station construction and mineral extraction", 
				history = "We named our station after Dr. Cavor, the physicist that invented a barrier material for gravity waves - Cavorite",
			},
			["Cyrus"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					impulse = {
						quantity =	5,
						cost =		124,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = random(1,100) < 78,
				},
				description = "Impulse engine components", 
				general = "We supply high quality impulse engines and parts for use aboard ships", 
				history = "This station was named after the fictional engineer, Cyrus Smith created by 19th century author Jules Verne",
			},
			["Deckard"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					android = {
						quantity =	5,
						cost =		73,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Android components", 
				general = "Supplier of android components, programming and service", 
				history = "Named for Richard Deckard who inspired many of the sophisticated safety security algorithms now required for all androids",
			},
			["Erickson"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					transporter = {
						quantity =	5,
						cost =		63,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Transporter components", 
				general = "We provide transporters used aboard ships as well as the components for repair and maintenance", 
				history = "The station is named after the early 22nd century inventor of the transporter, Dr. Emory Erickson. This station is proud to have received the endorsement of Admiral Leonard McCoy",
			},
			["Jabba"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Commerce and gambling", 
				general = "Come play some games and shop. House take does not exceed 4 percent", 
				history = "",
			},			
			["Komov"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				true,	
		        	Nuke =				false,	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					filament = {
						quantity =	5,
						cost =		46,
					},
				},
 				trade = {
 					food = false, 
 					medicine = false, 
 					luxury = false,
 				},
				description = "Xenopsychology training", 
				general = "We provide classes and simulation to help train diverse species in how to relate to each other", 
				history = "A continuation of the research initially conducted by Dr. Gennady Komov in the early 22nd century on Venus, supported by the application of these principles",
			},
			["Lando"] = {
		        weapon_available = {
		        	Homing =			true,	
		        	HVLI =				true,	
		        	Mine =				true,	
		        	Nuke =				false,	
		        	EMP =				false,
		        },
				weapon_cost = {
					Homing = math.random(2,5),
					HVLI = 2,
					Mine = math.random(2,5),
				},
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					shield = {
						quantity =	5,
						cost =		90,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Casino and Gambling", 
				general = "", 
				history = "",
			},			
			["Muddville"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		60,
					},
				},
				trade = {
					food = true, 
					medicine = true, 
					luxury = false,
				},
				description = "Trading station", 
				general = "Come to Muddvile for all your trade and commerce needs and desires", 
				history = "Upon retirement, Harry Mudd started this commercial venture using his leftover inventory and extensive connections obtained while he traveled the stars as a salesman",
			},
			["Nexus-6"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				false,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					android = {
						quantity =	5,
						cost =		93,
					},
				},
				trade = {
					food = false, 
					medicine = true, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
					[randomComponent("android")] = math.random(40,200),
				},
				description = "Android components", 
				general = "Androids, their parts, maintenance and recylcling", 
				history = "We named the station after the ground breaking android model produced by the Tyrell corporation",
			},
			["O'Brien"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					transporter = {
						quantity =	5,
						cost =		76,
					},
				},
				trade = {
					food = random(1,100) < 13, 
					medicine = true, 
					luxury = random(1,100) < 43,
				},
				description = "Transporter components", 
				general = "We research and fabricate high quality transporters and transporter components for use aboard ships", 
				history = "Miles O'Brien started this business after his experience as a transporter chief",
			},
			["Organa"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		95,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Diplomatic training", 
				general = "The premeire academy for leadership and diplomacy training in the region", 
				history = "Established by the royal family so critical during the political upheaval era",
			},
			["Owen"] = {
		        weapon_available = {
		        	Homing =			true,			
		        	HVLI =				false,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					lifter = {
						quantity =	5,
						cost =		61,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Load lifters and components", 
				general = "We provide load lifters and components for various ship systems", 
				history = "Owens started off in the moisture vaporator business on Tattooine then branched out into load lifters based on acquisition of proprietary software and protocols. The station name recognizes the tragic loss of our founder to Imperial violence",
			},
			["Ripley"] = {
		        weapon_available = {
		        	Homing =			false,		
		        	HVLI =				true,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					lifter = {
						quantity =	5,
						cost =		82,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = random(1,100) < 47,
				},
				description = "Load lifters and components", 
				general = "We provide load lifters and components", 
				history = "The station is named after Ellen Ripley who made creative and effective use of one of our load lifters when defending her ship",
			},
			["Skandar"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Routine maintenance and entertainment", 
				general = "Stop by for repairs. Take in one of our juggling shows featuring the four-armed Skandars", 
				history = "The nomadic Skandars have set up at this station to practice their entertainment and maintenance skills as well as build a community where Skandars can relax",
			},			
			["Soong"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					android = {
						quantity =	5,
						cost = 73,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Android components", 
				general = "We create androids and android components", 
				history = "The station is named after Dr. Noonian Soong, the famous android researcher and builder",
			},
			["Starnet"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
		        goods = {	
		        	software =	{
		        		quantity =	5,	
		        		cost =		140,
		        	},
		        },
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Automated weapons systems", 
				general = "We research and create automated weapons systems to improve ship combat capability", 
				history = "Lost the history memory bank. Recovery efforts only brought back the phrase, 'I'll be back'",
			},			
			["Tiberius"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					food = {
						quantity =	5,
						cost =		1,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Logistics coordination", 
				general = "We support the stations and ships in the area with planning and communication services", 
				history = "We recognize the influence of Starfleet Captain James Tiberius Kirk in the 23rd century in our station name",
			},
			["Tokra"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					filament = {
						quantity =	5,
						cost =		42,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Advanced material components", 
				general = "We create multiple types of advanced material components. Our most popular products are our filaments", 
				history = "We learned several of our critical industrial processes from the Tokra race, so we honor our fortune by naming the station after them",
			},
			["Utopia Planitia"] = {
		        weapon_available = 	{
		        	Homing = 			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				true,		
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        goods = {	
		        	warp =	{
		        		quantity =	5,	
		        		cost =		167,
		        	},
		        },
		        trade = {	
		        	food = false, 
		        	medicine = false, 
		        	luxury = false 
		        },
				description = "Ship building and maintenance facility", 
				general = "We work on all aspects of naval ship building and maintenance. Many of the naval models are researched, designed and built right here on this station. Our design goals seek to make the space faring experience as simple as possible given the tremendous capabilities of the modern naval vessel", 
				history = ""
			},
			["Vaiken"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					food = {
						quantity =	10,
						cost = 		1,
					},
        			medicine = {
        				quantity =	5,
        				cost = 		5,
        			},
        			impulse = {
        				quantity =	5,
        				cost = 		math.random(65,97),
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Ship building and maintenance facility", 
				general = "", 
				history = "",
			},			
			["Zefram"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
		        goods = {	
		        	warp =	{
		        		quantity =	5,	
		        		cost =		140,
		        	},
		        },
		        trade = {	
		        	food = false, 
		        	medicine = false, 
		        	luxury = true,
		        },
				description = "Warp engine components", 
				general = "We specialize in the esoteric components necessary to make warp drives function properly", 
				history = "Zefram Cochrane constructed the first warp drive in human history. We named our station after him because of the specialized warp systems work we do",
			},
		},
		["Spec Sci Fi"] = {
			["Alcaleica"] =	{
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					optic = {
						quantity =	5,
						cost =		66,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Optical Components", 
				general = "We make and supply optic components for various station and ship systems", 
				history = "This station continues the businesses from Earth based on the merging of several companies including Leica from Switzerland, the lens manufacturer and the Japanese advanced low carbon (ALCA) electronic and optic research and development company",
			},
			["Bethesda"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				reputation_cost_multipliers = {
					friend = 1.0, 
					neutral = 3.0,
				},
				goods = {	
					autodoc = {
						quantity =	5,
						cost =		36,
					},
					medicine = {
						quantity =	5,					
						cost = 		5,
					},
					food = {
						quantity =	math.random(5,10),	
						cost = 		1,
					},
				},
				trade = {	
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Medical research", 
				general = "We research and treat exotic medical conditions", 
				history = "The station is named after the United States national medical research center based in Bethesda, Maryland on earth which was established in the mid 20th century",
			},
			["Deer"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {	
					tractor = {
						quantity =	5,	
						cost =		90,
					},
        			repulsor = {
        				quantity =	5,
        				cost =		math.random(85,95),
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Repulsor and Tractor Beam Components", 
				general = "We can meet all your pushing and pulling needs with specialized equipment custom made", 
				history = "The station name comes from a short story by the 20th century author Clifford D. Simak as well as from the 19th century developer John Deere who inspired a company that makes the Earth bound equivalents of our products",
			},
			["Evondos"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				true,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				reputation_cost_multipliers = {
					friend = 1.0, 
					neutral = 3.0,
				},
				goods = {
					autodoc = {
						quantity =	5,
						cost =		56,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = random(1,100) < 41,
				},
				description = "Autodoc components", 
				general = "We provide components for automated medical machinery", 
				history = "The station is the evolution of the company that started automated pharmaceutical dispensing in the early 21st century on Earth in Finland",
			},
			["Feynman"] = {
		        weapon_available = 	{
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				true,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
        		goods = {	
        			software = {
        				quantity = 	5,	
        				cost =		115,
        			},
        			nanites = {
        				quantity =	5,	
        				cost =		79,
        			},
        		},
		        trade = {	
		        	food = false, 
		        	medicine = false, 
		        	luxury = true,
		        },
				description = "Nanotechnology research", 
				general = "We provide nanites and software for a variety of ship-board systems", 
				history = "This station's name recognizes one of the first scientific researchers into nanotechnology, physicist Richard Feynman",
			},
			["Mayo"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					autodoc = {
						quantity =	5,
						cost =		128,
					},
        			food = {
        				quantity =	5,
        				cost =		1,
        			},
        			medicine = {
        				quantity =	5,
        				cost =		5,
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Medical Research", 
				general = "We research exotic diseases and other human medical conditions", 
				history = "We continue the medical work started by William Worrall Mayo in the late 19th century on Earth",
			},
			["Olympus"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					optic =	{
						quantity =	5,
						cost =		66,
					},
				},
				trade = {	
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Optical components", 
				general = "We fabricate optical lenses and related equipment as well as fiber optic cabling and components", 
				history = "This station grew out of the Olympus company based on earth in the early 21st century. It merged with Infinera, then bought several software comapnies before branching out into space based industry",
			},
			["Panduit"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					optic =	{
						quantity =	5,
						cost =		79,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Optic components", 
				general = "We provide optic components for various ship systems", 
				history = "This station is an outgrowth of the Panduit corporation started in the mid 20th century on Earth in the United States",
			},
			["Shree"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {	
					tractor = {
						quantity =	5,	
						cost =		90,
					},
        			repulsor = {
        				quantity =	5,
        				cost =		math.random(85,95),
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Repulsor and tractor beam components", 
				general = "We make ship systems designed to push or pull other objects around in space", 
				history = "Our station is named Shree after one of many tugboat manufacturers in the early 21st century on Earth in India. Tugboats serve a similar purpose for ocean-going vessels on earth as tractor and repulsor beams serve for space-going vessels today",
			},
			["Vactel"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					circuit = {
						quantity =	5,
						cost =		50,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Shielded Circuitry Fabrication", 
				general = "We specialize in circuitry shielded from external hacking suitable for ship systems", 
				history = "We started as an expansion from the lunar based chip manufacturer of Earth legacy Intel electronic chips",
			},
			["Veloquan"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					sensor = {
						quantity =	5,
						cost =		68,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Sensor components", 
				general = "We research and construct components for the most powerful and accurate sensors used aboard ships along with the software to make them easy to use", 
				history = "The Veloquan company has its roots in the manufacturing of LIDAR sensors in the early 21st century on Earth in the United States for autonomous ground-based vehicles. They expanded research and manufacturing operations to include various sensors for space vehicles. Veloquan was the result of numerous mergers and acquisitions of several companies including Velodyne and Quanergy",
			},
			["Tandon"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Biotechnology research",
				general = "Merging the organic and inorganic through research", 
				history = "Continued from the Tandon school of engineering started on Earth in the early 21st century",
			},
		},
		["Generic"] = {
			["California"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {	
					gold = {
						quantity =	5,
						cost =		90,
					},
					dilithium = {
						quantity =	2,					
						cost = 		25,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Mining station", 
				general = "", 
				history = "",
			},
			["Impala"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		70,
					},
				},
				trade = {
					food = true, 
					medicine = false, 
					luxury = true,
				},
				buy = {
					[randomComponent()] = math.random(40,200),
				},
				description = "Mining", 
				general = "We mine nearby asteroids for precious minerals", 
				history = "",
			},
			["Krak"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				true,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					nickel = {
						quantity =	5,
						cost =		20,
					},
				},
				trade = {
					food = random(1,100) < 50, 
					medicine = true, 
					luxury = random(1,100) < 50,
				},
				buy = {
					[randomComponent()] = math.random(40,200),
				},
				description = "Mining station", 
				general = "", 
				history = "",
			},
			["Krik"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					nickel = {
						quantity =	5,
						cost =		20,
					},
				},
				trade = {
					food = true, 
					medicine = true, 
					luxury = random(1,100) < 50,
				},
				description = "Mining station", 
				general = "", 
				history = "",
			},
			["Kruk"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					nickel = {
						quantity =	5,
						cost =		20,
					},
				},
				trade = {
					food = random(1,100) < 50, 
					medicine = random(1,100) < 50, 
					luxury = true },
				buy = {
					[randomComponent()] = math.random(40,200),
				},
				description = "Mining station", 
				general = "", 
				history = "",
			},
			["Maverick"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Gambling and resupply", 
				general = "Relax and meet some interesting players", 
				history = "",
			},
			["Nefatha"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Commerce and recreation", 
				general = "", 
				history = "",
			},
			["Okun"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Xenopsychology research", 
				general = "", 
				history = "",
			},
			["Outpost-15"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Mining and trade", 
				general = "", 
				history = "",
			},
			["Outpost-21"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Mining and gambling", 
				general = "", 
				history = "",
			},
			["Outpost-7"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Resupply", 
				general = "", 
				history = "",
			},
			["Outpost-8"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "", 
				general = "", 
				history = "",
			},
			["Outpost-33"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Resupply", 
				general = "", 
				history = "",
			},
			["Prada"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Textiles and fashion", 
				general = "", 
				history = "",
			},
			["Research-11"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					medicine = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Stress Psychology Research", 
				general = "", 
				history = "",
			},
			["Research-19"] = {
		        weapon_available ={
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
		        goods = {},
		        trade = {
		        	food = false, 
		        	medicine = false, 
		        	luxury = false,
		        },
				description = "Low gravity research", 
				general = "", 
				history = "",
			},
			["Rubis"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Resupply", 
				general = "Get your energy here! Grab a drink before you go!", 
				history = "",
			},
			["Science-2"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					circuit = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Research Lab and Observatory", 
				general = "", 
				history = "",
			},
			["Science-4"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					medicine = {
						quantity =	5,
						cost =		math.random(30,80),
					},
					autodoc = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Biotech research", 
				general = "", 
				history = "",
			},
			["Science-7"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					food = {
						quantity =	2,
						cost =		1,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Observatory", 
				general = "", 
				history = "",
			},
			["Spot"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
		        goods = {},
		        trade = {
		        	food = false, 
		        	medicine = false, 
		        	luxury = false,
		        },
				description = "Observatory", 
				general = "", 
				history = "",
			},
			["Valero"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Resupply", 
				general = "", 
				history = "",
			},
		},
		["Sinister"] = {
			["Aramanth"] =	{goods = {}, description = "", general = "", history = ""},
			["Empok Nor"] =	{goods = {}, description = "", general = "", history = ""},
			["Gandala"] =	{goods = {}, description = "", general = "", history = ""},
			["Hassenstadt"] =	{goods = {}, description = "", general = "", history = ""},
			["Kaldor"] =	{goods = {}, description = "", general = "", history = ""},
			["Magenta Mesra"] =	{goods = {}, description = "", general = "", history = ""},
			["Mos Eisley"] =	{goods = {}, description = "", general = "", history = ""},
			["Questa Verde"] =	{goods = {}, description = "", general = "", history = ""},
			["R'lyeh"] =	{goods = {}, description = "", general = "", history = ""},
			["Scarlet Citadel"] =	{goods = {}, description = "", general = "", history = ""},
			["Stahlstadt"] =	{goods = {}, description = "", general = "", history = ""},
			["Ticonderoga"] =	{goods = {}, description = "", general = "", history = ""},
		},
	}
	station_priority = {}
	table.insert(station_priority,"Science")
	table.insert(station_priority,"Pop Sci Fi")
	table.insert(station_priority,"Spec Sci Fi")
	table.insert(station_priority,"History")
	table.insert(station_priority,"Generic")
	for group, list in pairs(station_pool) do
		local already_inserted = false
		for _, previous_group in ipairs(station_priority) do
			if group == previous_group then
				already_inserted = true
				break
			end
		end
		if not already_inserted and group ~= "Sinister" then
			table.insert(station_priority,group)
		end
	end
end
function placeStation(x,y,name,faction,size)
	--x and y are the position of the station
	--name should be the name of the station or the name of the station group
	--		omit name to get random station from groups in priority order
	--faction is the faction of the station
	--		omit and stationFaction will be used
	--size is the name of the station template to use
	--		omit and station template will be chosen at random via szt function
	if x == nil then return nil end
	if y == nil then return nil end
	local group, station = pickStation(name)
	if group == nil then return nil end
	station:setPosition(x,y)
	if faction ~= nil then
		station:setFaction(faction)
	else
		if stationFaction ~= nil then
			station:setFaction(stationFaction)
		else
			station:setFaction("Independent")
		end
	end
	if size == nil then
		station:setTemplate(szt())
	else
		local function Set(list)
			local set = {}
			for _, item in ipairs(list) do
				set[item] = true
			end
			return set
		end
		local station_size_templates = Set{"Small Station","Medium Station","Large Station","Huge Station"}
		if station_size_templates[size] then
			station:setTemplate(size)
		else
			station:setTemplate(szt())
		end
	end
	local size_matters = 0
	local station_size = station:getTypeName()
	if station_size == "Medium Station" then
		size_matters = 20
	elseif station_size == "Large Station" then
		size_matters = 30
	elseif station_size == "Huge Station" then
		size_matters = 40
	end
	local faction_matters = 0
	if station:getFaction() == "Human Navy" then
		faction_matters = 20
	end
	station.comms_data.probe_launch_repair =	random(1,100) <= (20 + size_matters + faction_matters)
	station.comms_data.scan_repair =			random(1,100) <= (30 + size_matters + faction_matters)
	station.comms_data.hack_repair =			random(1,100) <= (10 + size_matters + faction_matters)
	station.comms_data.combat_maneuver_repair =	random(1,100) <= (15 + size_matters + faction_matters)
	station.comms_data.self_destruct_repair =	random(1,100) <= (25 + size_matters + faction_matters)
	station.comms_data.jump_overcharge =		random(1,100) <= (5 + size_matters + faction_matters)
	station:setSharesEnergyWithDocked(random(1,100) <= (50 + size_matters + faction_matters))
	station:setRepairDocked(random(1,100) <= (55 + size_matters + faction_matters))
	station:setRestocksScanProbes(random(1,100) <= (45 + size_matters + faction_matters))
	--specialized code for particular stations
	local station_name = station:getCallSign()
	local chosen_goods = random(1,100)
	if station_name == "Grasberg" or station_name == "Impala" or station_name == "Outpost-15" or station_name == "Outpost-21" then
		placeRandomAsteroidsAroundPoint(15,1,15000,x,y)
		if chosen_goods < 20 then
			station.comms_data.goods.gold = {quantity = 5, cost = 25}
			station.comms_data.goods.cobalt = {quantity = 4, cost = 50}
		elseif chosen_goods < 40 then
			station.comms_data.goods.gold = {quantity = 5, cost = 25}
		elseif chosen_goods < 60 then
			station.comms_data.goods.cobalt = {quantity = 4, cost = 50}
		else
			if station_name == "Grasberg" then
				station.comms_data.goods.nickel = {quantity = 5, cost = math.random(40,50)}
			elseif station_name == "Outpost-15" then
				station.comms_data.goods.platinum = {quantity = 5, cost = math.random(40,50)}
			elseif station_name == "Outpost-21" then
				station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(40,50)}
			else	--Impala
				station.comms_data.goods.tritanium = {quantity = 5, cost = math.random(40,50)}
			end			
		end
	elseif station_name == "Jabba" or station_name == "Lando" or station_name == "Maverick" or station_name == "Okun" or station_name == "Outpost-8" or station_name == "Prada" or station_name == "Research-11" or station_name == "Research-19" or station_name == "Science-2" or station_name == "Science-4" or station_name == "Spot" or station_name == "Starnet" or station_name == "Tandon" then
		if chosen_goods < 33 then
			if station_name == "Jabba" then
				station.comms_data.goods.cobalt = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Okun" or station_name == "Spot" then
				station.comms_data.goods.optic = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Outpost-8" then
				station.comms_data.goods.impulse = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Research-11" then
				station.comms_data.goods.warp = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Research-19" then
				station.comms_data.goods.transporter = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Science-2" or station_name == "Tandon" then
				station.comms_data.goods.autodoc = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Science-4" then
				station.comms_data.goods.software = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Starnet" then
				station.comms_data.goods.shield = {quantity = 5, cost = math.random(68,81)}
			else
				station.comms_data.goods.luxury = {quantity = 5, cost = math.random(68,81)}
			end
		elseif chosen_goods < 66 then
			if station_name == "Okun" then
				station.comms_data.goods.filament = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Outpost-8" then
				station.comms_data.goods.tractor = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Prada" then
				station.comms_data.goods.cobalt = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Research-11" then
				station.comms_data.goods.repulsor = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Research-19" or station_name == "Spot" then
				station.comms_data.goods.sensor = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Science-2" or station_name == "Tandon" then
				station.comms_data.goods.android = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Science-4" then
				station.comms_data.goods.circuit = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Starnet" then
				station.comms_data.goods.lifter = {quantity = 5, cost = math.random(61,77)}
			else
				station.comms_data.goods.gold = {quantity = 5, cost = math.random(61,77)}
			end
		else
			if station_name == "Okun" then
				station.comms_data.goods.lifter = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Outpost-8" or station_name == "Starnet" then
				station.comms_data.goods.beam = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Prada" then
				station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Research-11" then
				station.comms_data.goods.robotic = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Research-19" then
				station.comms_data.goods.communication = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Science-2" then
				station.comms_data.goods.nanites = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Science-4" then
				station.comms_data.goods.battery = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Spot" then
				station.comms_data.goods.software = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Tandon" then
				station.comms_data.goods.robotic = {quantity = 5, cost = math.random(61,77)}
			else
				station.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,79)}
			end
		end
	elseif station_name == "Krak" or station_name == "Kruk" or station_name == "Krik" then
		if chosen_goods < 10 then
			station.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
			station.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
			station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		elseif chosen_goods < 20 then
			station.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
			station.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		elseif chosen_goods < 30 then
			station.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
			station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		elseif chosen_goods < 40 then
			station.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
			station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		elseif chosen_goods < 50 then
			station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		elseif chosen_goods < 60 then
			station.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		elseif chosen_goods < 70 then
			station.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		elseif chosen_goods < 80 then
			if station_name == "Krik" then
				station.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,65)}
			else
				station.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
				station.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
			end
		elseif chosen_goods < 90 then
			if station_name == "Krik" then
				station.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,65)}
				station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
			else
				station.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
				station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
			end
		else
			if station_name == "Krik" then
				station.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,65)}
				station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
			else
				station.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
			end
		end
		local posAxisKrak = random(0,360)
		local posKrak = random(10000,60000)
		local negKrak = random(10000,60000)
		local spreadKrak = random(4000,7000)
		local negAxisKrak = posAxisKrak + 180
		local xPosAngleKrak, yPosAngleKrak = vectorFromAngle(posAxisKrak, posKrak)
		local posKrakEnd = random(30,70)
		local negKrakEnd = random(40,80)
		if station_name == "Krik" then
			posKrak = random(30000,80000)
			negKrak = random(20000,60000)
			spreadKrak = random(5000,8000)
			posKrakEnd = random(40,90)
			negKrakEnd = random(30,60)
		end
		createRandomAsteroidAlongArc(30+posKrakEnd, x+xPosAngleKrak, y+yPosAngleKrak, posKrak, negAxisKrak, negAxisKrak+posKrakEnd, spreadKrak)
		local xNegAngleKrak, yNegAngleKrak = vectorFromAngle(negAxisKrak, negKrak)
		createRandomAsteroidAlongArc(30+negKrakEnd, x+xNegAngleKrak, y+yNegAngleKrak, negKrak, posAxisKrak, posAxisKrak+negKrakEnd, spreadKrak)
	end
	if station_name == "Tokra" or station_name == "Cavor" then
		local what_trade = random(1,100)
		if what_trade < 33 then
			station.comms_data.trade.food = true
		elseif what_trade > 66 then
			station.comms_data.trade.medicine = true
		else
			station.comms_data.trade.luxury = true
		end
	end
	return station
end
function pickStation(name)
	if station_pool == nil then
		populateStationPool()
	end
	local selected_station_name = nil
	local station_selection_list = {}
	local selected_station = nil
	local station = nil
	if name == nil then
		--default to random in priority order
		for _, group in ipairs(station_priority) do
			if station_pool[group] ~= nil then
				for station, details in pairs(station_pool[group]) do
					table.insert(station_selection_list,station)
				end
				if #station_selection_list > 0 then
					if selected_station_name == nil then
						selected_station_name = station_selection_list[math.random(1,#station_selection_list)]
						station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station_name):setDescription(station_pool[group][selected_station_name].description)
						station.comms_data = station_pool[group][selected_station_name]
						station_pool[group][selected_station_name] = nil
						return group, station
					end
				end
			end
		end
	else
		if name == "Random" then
			--random across all groups
			for group, list in pairs(station_pool) do
				for station_name, station_details in pairs(list) do
					table.insert(station_selection_list,{group = group, station_name = station_name, station_details = station_details})
				end
			end
			if #station_selection_list > 0 then
				selected_station = station_selection_list[math.random(1,#station_selection_list)]
				station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station.station_name):setDescription(selected_station.station_details.description)
				station.comms_data = selected_station.station_details
				station_pool[selected_station.group][selected_station.station_name] = nil
				return selected_station.group, station
			end
		elseif name == "RandomHumanNeutral" then
			for group, list in pairs(station_pool) do
				if group ~= "Generic" and group ~= "Sinister" then
					for station_name, station_details in pairs(list) do
						table.insert(station_selection_list,{group = group, station_name = station_name, station_details = station_details})
					end
				end
			end
			if #station_selection_list > 0 then
				selected_station = station_selection_list[math.random(1,#station_selection_list)]
				station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station.station_name):setDescription(selected_station.station_details.description)
				station.comms_data = selected_station.station_details
				station_pool[selected_station.group][selected_station.station_name] = nil
				return selected_station.group, station
			end
		elseif name == "RandomGenericSinister" then
			for group, list in pairs(station_pool) do
				if group == "Generic" or group == "Sinister" then
					for station_name, station_details in pairs(list) do
						table.insert(station_selection_list,{group = group, station_name = station_name, station_details = station_details})
					end
				end
			end
			if #station_selection_list > 0 then
				selected_station = station_selection_list[math.random(1,#station_selection_list)]
				station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station.station_name):setDescription(selected_station.station_details.description)
				station.comms_data = selected_station.station_details
				station_pool[selected_station.group][selected_station.station_name] = nil
				return selected_station.group, station
			end
		else
			if station_pool[name] ~= nil then
				--name is a group name
				for station_name, station_details in pairs(station_pool[name]) do
					table.insert(station_selection_list,{station_name = station_name, station_details = station_details})
				end
				if #station_selection_list > 0 then
					selected_station = station_selection_list[math.random(1,#station_selection_list)]
					station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station.station_name):setDescription(selected_station.station_details.description)
					station.comms_data = selected_station.station_details
					station_pool[name][selected_station.station_name] = nil
					return name, station
				end
			else
				for group, list in pairs(station_pool) do
					if station_pool[group][name] ~= nil then
						station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(name):setDescription(station_pool[group][name].description)
						station.comms_data = station_pool[group][name]
						station_pool[group][name] = nil
						return group, station
					end
				end
				--name not found in any group
				print("Name provided not found in groups or stations, nor is it an accepted specialized name, like Random, RandomHumanNeutral or RandomGenericSinister")
				return nil
			end
		end
	end
	return nil
end
---------------------------
-- Station communication --
---------------------------
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
            preorder = "friend",
            activatedefensefleet = "neutral",
        },
        service_cost = {
            supplydrop = math.random(80,120),
            reinforcements = math.random(125,175),
            activatedefensefleet = 20,
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
    if comms_source:isEnemy(comms_target) then
        return false
    end
    if comms_target:areEnemiesInRange(5000) then
        setCommsMessage("We are under attack! No time for chatting!");
        return true
    end
    if not comms_source:isDocked(comms_target) then
        handleUndockedState()
    else
        handleDockedState()
    end
    return true
end
function integralStationGoodsDeliveredComms()
	if integral_station.player_delivery then
		if not comms_source:getCanScan() and not fully_functional_player_ship then
			addCommsReply("Scanner diagnostic report",function()
				setCommsMessage("We noticed your scanners seem to be disabled. It is a simple matter to activate them. Would you like us to transmit the instructions to your technical staff?")
				addCommsReply("Such technical matters are handled by the shipyards only",function()
					setCommsMessage("Just trying to help")
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("I'll check with leadership and get back to you",function()
					setCommsMessage("Ok, you know where to find us")
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Yes, please send us the information",function()
					setCommsMessage("Transmitting now")
					for pidx=1,32 do
						local p = getPlayerShip(pidx)
						if p ~= nil and p:isValid() then
							if not p:getCanScan() then
								p:setCanScan(true)
								if p:hasPlayerAtPosition("Science") then
									p.enable_scanners_message = "enable_scanners_message"
									p:addCustomMessage("Science",p.enable_scanners_message,"A message comes across your terminal with instructions on enabling the scanners. You realize that all the steps had already been followed according to your training manual except for the last step. You flip that switch and the scanners come online. Curious, you review the training manual again and discover that the last instruction was covered up by the edge of the chat window you were using during orientation")
								end
								if p:hasPlayerAtPosition("Operations") then
									p.enable_scanners_message_ops = "enable_scanners_message_ops"
									p:addCustomMessage("Operations",p.enable_scanners_message_ops,"A message comes across your terminal with instructions on enabling the scanners. You realize that all the steps had already been followed according to your training manual except for the last step. You flip that switch and the scanners come online. Curious, you review the training manual again and discover that the last instruction was covered up by the edge of the chat window you were using during orientation")
								end
							end
						end
					end
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Back", commsStation)
			end)
		end
	end
end
function handleDockedState()
	local ctd = comms_target.comms_data
    if comms_source:isFriendly(comms_target) then
    	if ctd.friendlyness > 66 then
    		oMsg = string.format("Greetings %s!\nHow may we help you today?",comms_source:getCallSign())
    	elseif ctd.friendlyness > 33 then
			oMsg = "Good day, officer!\nWhat can we do for you today?"
		else
			oMsg = "Hello, may I help you?"
		end
    else
		oMsg = "Welcome to our lovely station."
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "\nForgive us if we seem a little distracted. We are carefully monitoring the enemies nearby."
	end
	oMsg = string.format("%s\n\nReputation: %i",oMsg,math.floor(comms_source:getReputationPoints()))
	setCommsMessage(oMsg)
	local missilePresence = 0
	local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	for _, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + comms_source:getWeaponStorageMax(missile_type)
	end
	if missilePresence > 0 then
		if 	(ctd.weapon_available.Nuke   and comms_source:getWeaponStorageMax("Nuke") > 0)   or 
			(ctd.weapon_available.EMP    and comms_source:getWeaponStorageMax("EMP") > 0)    or 
			(ctd.weapon_available.Homing and comms_source:getWeaponStorageMax("Homing") > 0) or 
			(ctd.weapon_available.Mine   and comms_source:getWeaponStorageMax("Mine") > 0)   or 
			(ctd.weapon_available.HVLI   and comms_source:getWeaponStorageMax("HVLI") > 0)   then
			addCommsReply("I need ordnance restocked", function()
				local ctd = comms_target.comms_data
				if stationCommsDiagnostic then print("in restock function") end
				setCommsMessage(string.format("What type of ordnance?\n\nReputation: %i",math.floor(comms_source:getReputationPoints())))
				if stationCommsDiagnostic then print(string.format("player nuke weapon storage max: %.1f",comms_source:getWeaponStorageMax("Nuke"))) end
				if comms_source:getWeaponStorageMax("Nuke") > 0 then
					if stationCommsDiagnostic then print("player can fire nukes") end
					if ctd.weapon_available.Nuke then
						if stationCommsDiagnostic then print("station has nukes available") end
						if math.random(1,10) <= 5 then
							nukePrompt = "Can you supply us with some nukes? ("
						else
							nukePrompt = "We really need some nukes ("
						end
						if stationCommsDiagnostic then print("nuke prompt: " .. nukePrompt) end
						addCommsReply(nukePrompt .. getWeaponCost("Nuke") .. " rep each)", function()
							if stationCommsDiagnostic then print("going to handle weapon restock function") end
							handleWeaponRestock("Nuke")
						end)
					end	--end station has nuke available if branch
				end	--end player can accept nuke if branch
				if comms_source:getWeaponStorageMax("EMP") > 0 then
					if ctd.weapon_available.EMP then
						if math.random(1,10) <= 5 then
							empPrompt = "Please re-stock our EMP missiles. ("
						else
							empPrompt = "Got any EMPs? ("
						end
						addCommsReply(empPrompt .. getWeaponCost("EMP") .. " rep each)", function()
							handleWeaponRestock("EMP")
						end)
					end	--end station has EMP available if branch
				end	--end player can accept EMP if branch
				if comms_source:getWeaponStorageMax("Homing") > 0 then
					if ctd.weapon_available.Homing then
						if math.random(1,10) <= 5 then
							homePrompt = "Do you have spare homing missiles for us? ("
						else
							homePrompt = "Do you have extra homing missiles? ("
						end
						addCommsReply(homePrompt .. getWeaponCost("Homing") .. " rep each)", function()
							handleWeaponRestock("Homing")
						end)
					end	--end station has homing for player if branch
				end	--end player can accept homing if branch
				if comms_source:getWeaponStorageMax("Mine") > 0 then
					if ctd.weapon_available.Mine then
						if math.random(1,10) <= 5 then
							minePrompt = "We could use some mines. ("
						else
							minePrompt = "How about mines? ("
						end
						addCommsReply(minePrompt .. getWeaponCost("Mine") .. " rep each)", function()
							handleWeaponRestock("Mine")
						end)
					end	--end station has mine for player if branch
				end	--end player can accept mine if branch
				if comms_source:getWeaponStorageMax("HVLI") > 0 then
					if ctd.weapon_available.HVLI then
						if math.random(1,10) <= 5 then
							hvliPrompt = "What about HVLI? ("
						else
							hvliPrompt = "Could you provide HVLI? ("
						end
						addCommsReply(hvliPrompt .. getWeaponCost("HVLI") .. " rep each)", function()
							handleWeaponRestock("HVLI")
						end)
					end	--end station has HVLI for player if branch
				end	--end player can accept HVLI if branch
			end)	--end player requests secondary ordnance comms reply branch
		end	--end secondary ordnance available from station if branch
	end	--end missles used on player ship if branch
	addCommsReply("Docking services status", function()
		local service_status = string.format("Station %s docking services status:",comms_target:getCallSign())
		if comms_target:getRestocksScanProbes() then
			service_status = string.format("%s\nReplenish scan probes.",service_status)
		else
			if comms_target.probe_fail_reason == nil then
				local reason_list = {
					"Cannot replenish scan probes due to fabrication unit failure.",
					"Parts shortage prevents scan probe replenishment.",
					"Station management has curtailed scan probe replenishment for cost cutting reasons.",
				}
				comms_target.probe_fail_reason = reason_list[math.random(1,#reason_list)]
			end
			service_status = string.format("%s\n%s",service_status,comms_target.probe_fail_reason)
		end
		if comms_target:getRepairDocked() then
			service_status = string.format("%s\nShip hull repair.",service_status)
		else
			if comms_target.repair_fail_reason == nil then
				reason_list = {
					"We're out of the necessary materials and supplies for hull repair.",
					"Hull repair automation unavailable while it is undergoing maintenance.",
					"All hull repair technicians quarantined to quarters due to illness.",
				}
				comms_target.repair_fail_reason = reason_list[math.random(1,#reason_list)]
			end
			service_status = string.format("%s\n%s",service_status,comms_target.repair_fail_reason)
		end
		if comms_target:getSharesEnergyWithDocked() then
			service_status = string.format("%s\nRecharge ship energy stores.",service_status)
		else
			if comms_target.energy_fail_reason == nil then
				reason_list = {
					"A recent reactor failure has put us on auxiliary power, so we cannot recharge ships.",
					"A damaged power coupling makes it too dangerous to recharge ships.",
					"An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now.",
				}
				comms_target.energy_fail_reason = reason_list[math.random(1,#reason_list)]
			end
			service_status = string.format("%s\n%s",service_status,comms_target.energy_fail_reason)
		end
		if fully_functional_player_ship then
			if comms_target.comms_data.jump_overcharge then
				service_status = string.format("%s\nMay overcharge jump drive",service_status)
			end
			if comms_target.comms_data.probe_launch_repair then
				service_status = string.format("%s\nMay repair probe launch system",service_status)
			end
			if comms_target.comms_data.hack_repair then
				service_status = string.format("%s\nMay repair hacking system",service_status)
			end
			if comms_target.comms_data.scan_repair then
				service_status = string.format("%s\nMay repair scanners",service_status)
			end
			if comms_target.comms_data.combat_maneuver_repair then
				service_status = string.format("%s\nMay repair combat maneuver",service_status)
			end
			if comms_target.comms_data.self_destruct_repair then
				service_status = string.format("%s\nMay repair self destruct system",service_status)
			end
		end
		setCommsMessage(service_status)
		addCommsReply("Back", commsStation)
	end)
	if comms_target.comms_data.jump_overcharge then
		if comms_source:hasJumpDrive() then
			local max_charge = comms_source.max_jump_range
			if max_charge == nil then
				max_charge = 50000
			end
			if comms_source:getJumpDriveCharge() >= max_charge then
				addCommsReply("Overcharge Jump Drive (10 Rep)",function()
					if comms_source:takeReputationPoints(10) then
						comms_source:setJumpDriveCharge(comms_source:getJumpDriveCharge() + max_charge)
						setCommsMessage(string.format("Your jump drive has been overcharged to %ik",math.floor(comms_source:getJumpDriveCharge()/1000)))
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back", commsStation)
				end)
			end
		end
	end
	if comms_target == integral_station then
		if comms_source.goods ~= nil and comms_source.goods[rescue_freighter_cargo_type] ~= nil and comms_source.goods[rescue_freighter_cargo_type] > 0 then
			addCommsReply(string.format("Deliver %s cargo from %s",rescue_freighter_cargo_type,rescue_freighter:getCallSign()),function()
				comms_source.goods[rescue_freighter_cargo_type] = comms_source.goods[rescue_freighter_cargo_type] - 1
				comms_source.cargo = comms_source.cargo + 1
				integral_station.player_delivery = true
				setCommsMessage(string.format("Thanks for the %s, we really needed it",rescue_freighter_cargo_type))
				integralStationGoodsDeliveredComms()
				addCommsReply("Back", commsStation)
			end)
		end
		integralStationGoodsDeliveredComms()
		if not comms_source:hasJumpDrive() then
			addCommsReply("Enable Jump Drive (5 Reputation)",function()
				if comms_source:takeReputationPoints(5) then
					comms_source:setJumpDrive(true)
					comms_source.max_jump_range = 25000
					comms_source.min_jump_range = 2500
					comms_source:setJumpDriveRange(comms_source.min_jump_range,comms_source.max_jump_range)
					comms_source:setJumpDriveCharge(comms_source.max_jump_range)
					setCommsMessage("The technician was able to activate minimal jump drive capability. Your shipyards may be able to increase the performance.")
					if comms_source:hasPlayerAtPosition("Helms") then
						comms_source.jump_drive_message = "jump_drive_message"
						comms_source:addCustomMessage("Helms",comms_source.jump_drive_message,"After the technician finishes the jump drive controls, he tells you that the best range he could get from the drive was 25 units. He tells you that you can always check the minimum and maximum range by moving the jump range slider all the way down and all the way up.")
					end
					if comms_source:hasPlayerAtPosition("Tactical") then
						comms_source.jump_drive_message_tac = "jump_drive_message_tac"
						comms_source:addCustomMessage("Tactical",comms_source.jump_drive_message_tac,"After the technician finishes the jump drive controls, he tells you that the best range he could get from the drive was 25 units. He tells you that you can always check the minimum and maximum range by moving the jump range slider all the way down and all the way up.")
					end
					if comms_source:hasPlayerAtPosition("SinglePilot") then
						comms_source.jump_drive_message_single = "jump_drive_message_single"
						comms_source:addCustomMessage("SinglePilot",comms_source.jump_drive_message_single,"After the technician finishes the jump drive controls, he tells you that the best range he could get from the drive was 25 units. He tells you that you can always check the minimum and maximum range by moving the jump range slider all the way down and all the way up.")
					end
					if comms_source:hasPlayerAtPosition("Engineering") then
						comms_source.jump_drive_message_eng = "jump_drive_message_eng"
						comms_source:addCustomMessage("Engineering",comms_source.jump_drive_message_eng,"As the technician makes some connections and configures the jump drive he mentions that the jump drive draws far more energy than the impulse drives, it generates heat when used and it will lose charge if you put less than 25% power in it")
					end
					if comms_source:hasPlayerAtPosition("Engineering+") then
						comms_source.jump_drive_message_eng_plus = "jump_drive_message_eng_plus"
						comms_source:addCustomMessage("Engineering+",comms_source.jump_drive_message_eng_plus,"As the technician makes some connections and configures the jump drive he mentions that the jump drive draws far more energy than the impulse drives, it generates heat when used and it will lose charge if you put less than 25% power in it")
					end
					if comms_source:hasPlayerAtPosition("PowerManagement") then
						comms_source.jump_drive_message_pm = "jump_drive_message_pm"
						comms_source:addCustomMessage("PowerManagement",comms_source.jump_drive_message_pm,"As the technician makes some connections and configures the jump drive he mentions that the jump drive draws far more energy than the impulse drives, it generates heat when used and it will lose charge if you put less than 25% power in it")
					end
				else
					setCommsMessage("Insufficient reputation")
				end
			end)
		end
	end
	if comms_target == asteroid_station and vacation_notification and technician_vacation then
		addCommsReply("Retrieve vacationing shipyard technicians",function()
			setCommsMessage("They're not on the station.")
			addCommsReply("Were they here on the station?",function()
				setCommsMessage("Yes, this was their first stop on their vacation")
				addCommsReply("Where did they go?",function()
					setCommsMessage("They left the station to visit several asteroids - also known as asteroid spelunking")
					spelunk_where = true
					addCommsReply("Back", commsStation)
				end)
				addCommsReply(string.format("What did they do while on %s?",asteroid_station:getCallSign()),function()
					setCommsMessage("They gathered supplies and talked to the miners about nearby asteroids")
					spelunk_what = true
					addCommsReply("Back", commsStation)
				end)
			end)
			addCommsReply("What is asteroid spelunking?",function()
				setCommsMessage("Exploring and investigating asteroids for recreational purposes, particularly any holes, cracks, crevices or craters that may be found.")
				addCommsReply("Isn't that dangerous?",function()
					setCommsMessage("It can be if you prepare poorly. The technicians took proper precautions as far we could tell.")
					spelunk_danger = true
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Why would the technicians take such a risk?",function()
					setCommsMessage("They just want some fun. Their shipyard jobs get boring. Examining asteroids may also be boring, but it's a different kind of boring.")
					spelunk_why = true
					addCommsReply("Back", commsStation)
				end)
			end)
			if spelunk_where and spelunk_what and spelunk_danger and spelunk_why then
				addCommsReply("Have the technicians contacted you since they left?",function()
					setCommsMessage("Oh yes. Standard safety protocol requires regular check in reports every 4 hours")
					addCommsReply("How long since their last check in?",function()
						setCommsMessage("Let me check the records...\n\nLooks like it's been ten hours since their last check in. That's not really cause for alarm yet. Sometimes they get caught up in their investigation. We were planning to send people out at the twelve hour mark based on their registered consumables such as air, water, food, energy, etc.")
						spelunk_check_in = true
						addCommsReply("Back", commsStation)
					end)
					addCommsReply("How can we contact the technicians?",function()
						setCommsMessage("I am transmitting their suit frequencies to you. Their suit communications don't have much power, so if they're inside one of the asteroids, you'll have to get close for the communication to work.")
						spelunk_contact = true
						addCommsReply("Back", commsStation)
					end)
				end)
				if spelunk_check_in and spelunk_contact then
					addCommsReply("Do you know which asteroids they planned to visit?",function()
						setCommsMessage("Not precisely. We'll send you information on the likeliest asteroids. Your science officer should be able to scan the asteroids and look for polymers (Kevlar, Mylar, Twaron, etc.) which are the primary components of their suits")
						spelunkPlot = asteroidSearch
						local composition = {
							{part = "osmium", chance = 2, max_value = 20},
							{part = "ruthenium", chance = 3, max_value = 30},
							{part = "rhodium", chance = 4, max_value = 40},
							{part = "magnesium", chance = 5, max_value = 50},
							{part = "platinum", chance = 6, max_value = 60},
							{part = "iridium", chance = 7, max_value = 70},
							{part = "gold", chance = 8, max_value = 80},
							{part = "palladium", chance = 9, max_value = 90},
							{part = "oxygen", chance = 10, max_value = 100},
							{part = "silicon", chance = 11, max_value = 110},
							{part = "hydrogen", chance = 12, max_value = 120},
							{part = "pyroxene", chance = 14, max_value = 140},
							{part = "olivine", chance = 15, max_value = 150},
							{part = "cobalt", chance = 16, max_value = 160},
							{part = "dilithium", chance = 17, max_value = 170},
							{part = "calcium", chance = 18, max_value = 180},
							{part = "nickel", chance = 19, max_value = 190},
							{part = "iron", chance = 20, max_value = 200},
						}
						for _, asteroid in ipairs(trav_asteroids) do
							if asteroid ~= nil and asteroid:isValid() then
								local unscanned_description = ""
								if random(0,100) < 65 then
									unscanned_description = "Structure: solid"
								elseif random(0,100) < 70 then
									unscanned_description = "Structure: rubble"
								else
									unscanned_description = "Structure: binary"
								end
								local scanned_description = ""
								asteroid.composition = 0
								for _, comp in ipairs(composition) do
									if random(1,100) < comp.chance and asteroid.composition < 100 then
										asteroid[comp.part] = math.random(1,comp.max_value)/10
										asteroid.composition = asteroid.composition + asteroid[comp.part]
										if asteroid.composition >= 100 then
											scanned_description = string.format("%s%s:remainder",scanned_description,comp.part)
										else
											scanned_description = string.format("%s%s:%.1f%% ",scanned_description,comp.part,asteroid[comp.part])
										end
									end
								end
								if asteroid.composition > 0 then
									if asteroid.composition < 100 then
										scanned_description = string.format("%s, %srock:remainder",unscanned_description, scanned_description)
									end
								else
									scanned_description = string.format("%s, just rock",unscanned_description, scanned_description)			
								end
								asteroid:setDescriptions(unscanned_description,scanned_description)
								local scan_parameter_tier_chance = 50
								if difficulty < 1 then
									scan_parameter_tier_chance = 25
								elseif difficulty > 1 then
									scan_parameter_tier_chance = 70
								end
								local scan_complexity = 1
								if random(0,100) < scan_parameter_tier_chance then
									scan_complexity = 2
								end
								local scan_depth = 1
								if random(0,100) < scan_parameter_tier_chance then
									if random(0,100) < scan_parameter_tier_chance then
										scan_depth = 3
									else
										scan_depth = 2
									end
								end
								asteroid:setScanningParameters(scan_complexity,scan_depth)
							end
						end
					end)
				end
			end
			addCommsReply("Back", commsStation)
--			setCommsMessage(string.format("They board %s, thanking you for the ride back to %s",comms_source:getCallSign(),shipyard_station:getCallSign()))
		end)
	end
	if finalize_player_ship_work and comms_target == shipyard_station then
		addCommsReply("Finish Chavez ship work",function()
			local done_with_work = true
			setCommsMessage(string.format("[Shipyard engineer] Based on the performance data you've provided, we can finalize various system configurations on %s, your instance of the Chavez class ship. What should we work on?",comms_source:getCallSign()))
			if comms_source.beams_adjusted == nil then
				done_with_work = false
				addCommsReply("Beam weapons system",function()
					if technician_vacation then
						setCommsMessage(string.format("Several technicians have taken vacation time asteroid spelunking near %s in %s, including our beam weapons specialist. You could transport them back here to complete this work",asteroid_station:getCallSign(),asteroid_station:getSectorName()))
						vacation_notification = true
					else
						comms_source.beams_adjusted = true
	--      							            	Arc,  Dir,  Range,Cyc,Dmg
						comms_source:setBeamWeapon(0,	 50,  -20,	 1200,	6,	4)
						comms_source:setBeamWeapon(1,	 50,   20,	 1200,	6,	4)
						comms_source:setImpulseMaxSpeed(65)
						setCommsMessage("Beam weapons system has been reconfigured to Human Navy military specifications")
						if comms_source:hasPlayerAtPosition("Weapons") then
							comms_source.beam_adjustment_message_wea = "beam_adjustment_message_wea"
							comms_source:addCustomMessage("Weapons",comms_source.beam_adjustment_message_wea,"The beam emitters have been divided into two sets angled for wider coverage and an overlap in the middle. The arcs are wider and the range is longer, but the individual beams do less damage. In the overlap, the beams do more damage. We tapped the impulse engine output to provide these improvements.")
						end
						if comms_source:hasPlayerAtPosition("Tactical") then
							comms_source.beam_adjustment_message_tac = "beam_adjustment_message_tac"
							comms_source:addCustomMessage("Tactical",comms_source.beam_adjustment_message_tac,"The beam emitters have been divided into two sets angled for wider coverage and an overlap in the middle. The arcs are wider and the range is longer, but the individual beams do less damage. In the overlap, the beams do more damage. We tapped the impulse engine output to provide these improvements. Impulse top speed reduced by 7.1%")
						end
						if comms_source:hasPlayerAtPosition("Helms") then
							comms_source.beam_adjustment_message_hlm = "beam_adjustment_message_hlm"
							comms_source:addCustomMessage("Helms",comms_source.beam_adjustment_message_hlm,"Beams divided, but with stronger overlap. We tapped the impulse engine output to provide these improvements. Impulse top speed reduced by 7.1%")
						end
					end
					addCommsReply("Back", commsStation)
				end)
			end
			if not comms_source:getCanScan() then
				done_with_work = false
				addCommsReply("Initialize Scanners",function()
					comms_source:setCanScan(true)
					if comms_source:hasPlayerAtPosition("Science") then
						comms_source.enable_scanners_message = "enable_scanners_message"
						comms_source:addCustomMessage("Science",comms_source.enable_scanners_message,"A message comes across your terminal with instructions on enabling the scanners. You realize that all the steps had already been followed according to your training manual except for the last step. You flip that switch and the scanners come online. Curious, you review the training manual again and discover that the last instruction was covered up by the edge of the chat window you were using during orientation")
					end
					if comms_source:hasPlayerAtPosition("Operations") then
						comms_source.enable_scanners_message_ops = "enable_scanners_message_ops"
						comms_source:addCustomMessage("Operations",comms_source.enable_scanners_message_ops,"A message comes across your terminal with instructions on enabling the scanners. You realize that all the steps had already been followed according to your training manual except for the last step. You flip that switch and the scanners come online. Curious, you review the training manual again and discover that the last instruction was covered up by the edge of the chat window you were using during orientation")
					end
					setCommsMessage("Scanners enabled")
					addCommsReply("Back", commsStation)
				end)
			end
			if not comms_source:getCanHack() then
				done_with_work = false
				addCommsReply("Activate Hacking System",function()
					comms_source:setCanHack(true)
					setCommsMessage("After the technician completes the hacking system installation, she looks at you and points to the controls, 'Hacking enemy vessels can often mean the difference between winning and losing an engagement. We're done here.' She leaves the bridge.")
					addCommsReply("Back", commsStation)
				end)
			end
			if comms_source.max_jump_range == nil or comms_source.max_jump_range == 25000 then
				local prompt = ""
				if comms_source.max_jump_range == nil then
					prompt = "Finalize jump drive installation"
				else
					prompt = "Adjust jump drive range"
				end
				addCommsReply(prompt,function()
					comms_source:setJumpDrive(true)
					comms_source.max_jump_range = 50000
					comms_source.min_jump_range = 5000
					comms_source:setJumpDriveRange(comms_source.min_jump_range,comms_source.max_jump_range)
					comms_source:setJumpDriveCharge(comms_source.max_jump_range)
					if prompt == "Adjust jump drive range" then
						setCommsMessage("Adjusted maximum jump drive range to 50 units and minimum jump drive range to 5 units")
						if comms_source:hasPlayerAtPosition("Helms") then
							comms_source.jump_drive_message = "jump_drive_message"
							comms_source:addCustomMessage("Helms",comms_source.jump_drive_message,"The jump drive engineer says, 'You're lucky that technician did not damage your jump drive. The minimum range is now 5 units and the maximum range is 50 units.'")
						end
						if comms_source:hasPlayerAtPosition("Tactical") then
							comms_source.jump_drive_message_tac = "jump_drive_message_tac"
							comms_source:addCustomMessage("Tactical",comms_source.jump_drive_message_tac,"The jump drive engineer says, 'You're lucky that technician did not damage your jump drive. The minimum range is now 5 units and the maximum range is 50 units.'")
						end
					else	
						setCommsMessage(string.format("Engine specialists completed the jump drive installation. %s can jump up to 50 units",comms_source:getCallSign()))
						if comms_source:hasPlayerAtPosition("Helms") then
							comms_source.jump_drive_message = "jump_drive_message"
							comms_source:addCustomMessage("Helms",comms_source.jump_drive_message,"After the engine specialist finishes the jump drive controls, he tells you that you can always check the minimum and maximum range by moving the jump range slider all the way down and all the way up.")
						end
						if comms_source:hasPlayerAtPosition("Tactical") then
							comms_source.jump_drive_message_tac = "jump_drive_message_tac"
							comms_source:addCustomMessage("Tactical",comms_source.jump_drive_message_tac,"After the engine specialist finishes the jump drive controls, he tells you that you can always check the minimum and maximum range by moving the jump range slider all the way down and all the way up.")
						end
						if comms_source:hasPlayerAtPosition("SinglePilot") then
							comms_source.jump_drive_message_single = "jump_drive_message_single"
							comms_source:addCustomMessage("SinglePilot",comms_source.jump_drive_message_single,"After the engine specialist finishes the jump drive controls, he tells you that you can always check the minimum and maximum range by moving the jump range slider all the way down and all the way up.")
						end
						if comms_source:hasPlayerAtPosition("Engineering") then
							comms_source.jump_drive_message_eng = "jump_drive_message_eng"
							comms_source:addCustomMessage("Engineering",comms_source.jump_drive_message_eng,"As the engine specialist makes some connections and configures the jump drive he mentions that the jump drive draws far more energy than the impulse drives, it generates heat when used and it will lose charge if you put less than 25% power in it")
						end
						if comms_source:hasPlayerAtPosition("Engineering+") then
							comms_source.jump_drive_message_eng_plus = "jump_drive_message_eng_plus"
							comms_source:addCustomMessage("Engineering+",comms_source.jump_drive_message_eng_plus,"As the engine specialist makes some connections and configures the jump drive he mentions that the jump drive draws far more energy than the impulse drives, it generates heat when used and it will lose charge if you put less than 25% power in it")
						end
						if comms_source:hasPlayerAtPosition("PowerManagement") then
							comms_source.jump_drive_message_pm = "jump_drive_message_pm"
							comms_source:addCustomMessage("PowerManagement",comms_source.jump_drive_message_pm,"As the engine specialist makes some connections and configures the jump drive he mentions that the jump drive draws far more energy than the impulse drives, it generates heat when used and it will lose charge if you put less than 25% power in it")
						end
					end
					addCommsReply("Back", commsStation)
				end)
			end
			if not comms_source:getCanLaunchProbe() then
				done_with_work = false
				addCommsReply("Install scan probe launch system",function()
					if technician_vacation then
						setCommsMessage(string.format("Several technicians have taken vacation time asteroid spelunking near %s in %s, including our probe launch system specialist. You could transport them back here to complete this work",asteroid_station:getCallSign(),asteroid_station:getSectorName()))
						vacation_notification = true
					else
						comms_source:setCanLaunchProbe(true)
						setCommsMessage("As the technician calibrates the probe launch controls, he says, 'I saw your orders. You're going to need these probes to find the source of the transmissions. I was on sensor duty when the readings came in. My gut tells me they're coming from within a nebula. Don't forget to link the probe to science if you see anything interesting within a probe's scan bubble. Good luck.' He flips the final activation switch and leaves.")
						if comms_source:hasPlayerAtPosition("Science") then
							comms_source.probe_launchers_message = "probe_launchers_message"
							comms_source:addCustomMessage("Science",comms_source.probe_launchers_message,"Now that probes can be launched, they can be linked to the science console once they are station keeping. When linked, you can get information on objects near the probe using the probe view button")
						end
					end
					addCommsReply("Back", commsStation)
				end)
			end
			if not comms_source:getCanCombatManeuver() then
				done_with_work = false
				addCommsReply("Finish auxiliary thruster system installation",function()
					if technician_vacation then
						setCommsMessage(string.format("Several technicians have taken vacation time asteroid spelunking near %s in %s, including our combat maneuvering system specialist. You could transport them back here to complete this work",asteroid_station:getCallSign(),asteroid_station:getSectorName()))
						vacation_notification = true
					else
						comms_source:setCanCombatManeuver(true)
						setCommsMessage("Auxiliary thruster based combat maneuver enabled")
						if comms_source:hasPlayerAtPosition("Helms") then
							comms_source.combat_maneuver_enabled_message = "combat_maneuver_enabled_message"
							comms_source:addCustomMessage("Helms",comms_source.combat_maneuver_enabled_message,"With auxiliary thrusters installed and configured, you can execute combat maneuvers allowing sideways motion as well as forward boost. Useful to dodge missiles or to chase down escaping fighters. Use cautiously: it rapidly adds heat to maneuvering and impulse and takes time to recharge.")
						end
						if comms_source:hasPlayerAtPosition("Tactical") then
							comms_source.combat_maneuver_enabled_message_tac = "combat_maneuver_enabled_message_tac"
							comms_source:addCustomMessage("Tactical",comms_source.combat_maneuver_enabled_message_tac,"With auxiliary thrusters installed and configured, you can execute combat maneuvers allowing sideways motion as well as forward boost. Useful to dodge missiles or to chase down escaping fighters. Use cautiously: it rapidly adds heat to maneuvering and impulse and takes time to recharge.")
						end
						if comms_source:hasPlayerAtPosition("Engineering") then
							comms_source.combat_maneuver_enabled_message_eng = "combat_maneuver_enabled_message_eng"
							comms_source:addCustomMessage("Engineering",comms_source.combat_maneuver_enabled_message_eng,"Now that Helm has controls for the thrusters attached to the combat maneuvering system, you can expect additional heat generation in the impulse engines and in the maneuvering systems during combat when Helm dodges missiles or chases faster ships. You should be ready to add coolant to those systems")
						end
						if comms_source:hasPlayerAtPosition("Engineering+") then
							comms_source.combat_maneuver_enabled_message_eng_plus = "combat_maneuver_enabled_message_eng_plus"
							comms_source:addCustomMessage("Engineering+",comms_source.combat_maneuver_enabled_message_eng_plus,"Now that Helm has controls for the thrusters attached to the combat maneuvering system, you can expect additional heat generation in the impulse engines and in the maneuvering systems during combat when Helm dodges missiles or chases faster ships. You should be ready to add coolant to those systems")
						end
						if comms_source:hasPlayerAtPosition("PowerManagement") then
							comms_source.combat_maneuver_enabled_message_pwr = "combat_maneuver_enabled_message_pwr"
							comms_source:addCustomMessage("PowerManagement",comms_source.combat_maneuver_enabled_message_pwr,"Now that Helm has controls for the thrusters attached to the combat maneuvering system, you can expect additional heat generation in the impulse engines and in the maneuvering systems during combat when Helm dodges missiles or chases faster ships. You should be ready to add coolant to those systems")
						end
					end
					addCommsReply("Back", commsStation)
				end)
			end
			if comms_source.mine_tube == nil then
				done_with_work = false
				addCommsReply("Install launchers for missile tubes",function()
					comms_source.mine_tube = "installed"
					comms_source:setWeaponTubeCount(2)
					comms_source:setTubeLoadTime(1,20)
					comms_source:weaponTubeAllowMissle(0,"HVLI")
					comms_source:setWeaponTubeDirection(1,180)
					comms_source:setWeaponTubeExclusiveFor(1,"Mine")
					comms_source:setWeaponStorageMax("HVLI",6)
					comms_source:setWeaponStorage("HVLI",   6)
					comms_source:setWeaponStorageMax("Mine",4)
					comms_source:setWeaponStorage("Mine",   4)
					setCommsMessage("Installed additional tube to launch mines.\n\nWe are waiting for delivery of heavy weapons. We can install those once they have been delivered")
					if comms_source:hasPlayerAtPosition("Weapons") then
						comms_source.mine_tube_message = "mine_tube_message"
						comms_source:addCustomMessage("Weapons",comms_source.mine_tube_message,"Your rear facing mine launching weapons tube has been fully installed. Coordinate carefully with Helm when launching mines: it is easy for the mines to trigger and damage your ship.\n\nWe also completed the final touches on your forward facing tube. It can now also launch High Velocity Lead Impactors (HVLIs) 5 at a time. These don't home on their target, so you'll want to coordinate with Helm when using them.")
					end
					if comms_source:hasPlayerAtPosition("Tactical") then
						comms_source.mine_tube_message_tac = "mine_tube_message_tac"
						comms_source:addCustomMessage("Tactical",comms_source.mine_tube_message_tac,"Your rear facing mine launching weapons tube has been fully installed. Be careful when launching mines: it is easy for the mines to trigger and damage your ship.\n\nWe also completed the final touches on your forward facing tube. It can now also launch High Velocity Lead Impactors (HVLIs) 5 at a time.")
					end
					if comms_source:hasPlayerAtPosition("Helms") then
						comms_source.mine_tube_message_hlm = "mine_tube_message_hlm"
						comms_source:addCustomMessage("Helms",comms_source.mine_tube_message_hlm,"Your rear facing mine launching weapons tube has been fully installed. Coordinate carefully with weapons when launching mines: it is easy for the mines to trigger and damage your ship. Be especially careful that you are not moving in reverse towards the mine when it's launched.\n\nThe forward tube can now also launch High Velocity Lead Impactors (HVLIs) 5 at a time. You'll have to aim them by turning the ship. You and Weapons will need to coordinate")
					end
					addCommsReply("Back", commsStation)
				end)
			else
				if comms_source.heavy_tubes == nil then
					done_with_work = false
					addCommsReply("Install heavy missile weapons",function()
						if escape_pod_count < 3 then
							comms_source.heavy_tubes = "installed"
							comms_source:setRotationMaxSpeed(15)	
							comms_source:setAcceleration(8)
							comms_source:setHullMax(160)
							comms_source:setHull(160)
							comms_source:setTubeLoadTime(1,.001)
							comms_source:commandUnloadTube(1)
							comms_source:setWeaponTubeCount(4)
							comms_source:setWeaponTubeDirection(1,-90)
							comms_source:setWeaponTubeDirection(2,90)
							comms_source:setWeaponTubeDirection(3,180)
							comms_source:setWeaponTubeExclusiveFor(1,"EMP")
							comms_source:setWeaponTubeExclusiveFor(2,"Nuke")
							comms_source:setWeaponTubeExclusiveFor(3,"Mine")
							comms_source:setWeaponStorageMax("EMP", 4)
							comms_source:setWeaponStorage("EMP",    4)
							comms_source:setWeaponStorageMax("Nuke",2)
							comms_source:setWeaponStorage("Nuke",   2)
							comms_source:setTubeLoadTime(0,10)
							comms_source:setTubeLoadTime(1,15)
							comms_source:setTubeLoadTime(2,15)
							comms_source:setTubeLoadTime(3,20)
							setCommsMessage("Installed broadside tubes for EMPs and Nukes")
							if comms_source:hasPlayerAtPosition("Weapons") then
								comms_source.heavy_tubes_message = "heavy_tubes_message"
								comms_source:addCustomMessage("Weapons",comms_source.heavy_tubes_message,"Added a left and right missile tube. The left tube can launch Electromagnetic Pulse missiles (EMPs). The right tube can launch nuclear torpedoes (Nukes). These heavy weapons have an area effect which can damage any target nearby, including friendly targets, even including your own ship. They also explode when they run out of fuel regardless of whether they have reached their intended target. Use with caution.\n\nAgility has been reduced a bit. Radiation shielding increased hull strength.")
							end
							if comms_source:hasPlayerAtPosition("Tactical") then
								comms_source.heavy_tubes_message_tac = "heavy_tubes_message_tac"
								comms_source:addCustomMessage("Tactical",comms_source.heavy_tubes_message_tac,"Added a left and right missile tube. The left tube can launch Electromagnetic Pulse missiles (EMPs). The right tube can launch nuclear torpedoes (Nukes). These heavy weapons have an area effect which can damage any target nearby, including friendly targets, even including your own ship. They also explode when they run out of fuel regardless of whether they have reached their intended target. Use with caution.\n\nIncreased load reduced agility by 22.5%, Radiation shielding increased hull strength.")
							end
							if comms_source:hasPlayerAtPosition("Helms") then
								comms_source.heavy_tubes_message_hlm = "heavy_tubes_message_hlm"
								comms_source:addCustomMessage("Helms",comms_source.heavy_tubes_message_hlm,"Added broadside missile tubes and heavy weapons.\n\nIncreased load reduced agility by 22.5%, Radiation shielding increased hull strength.")
							end
							if comms_source:hasPlayerAtPosition("Engineering") then
								comms_source.heavy_tubes_message_eng = "heavy_tubes_message_eng"
								comms_source:addCustomMessage("Engineering",comms_source.heavy_tubes_message_eng,"Added broadside missile tubes and heavy weapons.\n\nAgility has been reduced a bit. Radiation shielding has increased hull strength by 1/3")
							end
							if comms_source:hasPlayerAtPosition("Engineering+") then
								comms_source.heavy_tubes_message_eng_plus = "heavy_tubes_message_eng_plus"
								comms_source:addCustomMessage("Engineering+",comms_source.heavy_tubes_message_eng_plus,"Added broadside missile tubes and heavy weapons.\n\nAgility has been reduced a bit. Radiation shielding has increased hull strength by 1/3")
							end
							if comms_source:hasPlayerAtPosition("PowerManagement") then
								comms_source.heavy_tubes_message_pm = "heavy_tubes_message_pm"
								comms_source:addCustomMessage("PowerManagement",comms_source.heavy_tubes_message_pm,"Added broadside missile tubes and heavy weapons.\n\nAgility has been reduced a bit. Radiation shielding has increased hull strength by 1/3")
							end
						else
							setCommsMessage("Waiting on delivery of heavy missile weapons")
						end
						addCommsReply("Back", commsStation)
					end)
				end
			end
			if comms_source.full_sensor_range == nil then
				done_with_work = false
				addCommsReply("Tune the sensors for longer range",function()
					comms_source.full_sensor_range = "tuned"
					setCommsMessage("Long and short range sensors have been tuned")
					comms_source:setLongRangeRadarRange(30000)
					comms_source:setShortRangeRadarRange(5000)
					if comms_source:hasPlayerAtPosition("Science") then
						comms_source.long_range_longer_message = "long_range_longer_message"
						comms_source:addCustomMessage("Science",comms_source.long_range_longer_message,"Your long range sensors have been carefully tuned. Your previous range was 20U, now your range is 30U")
					end
					if comms_source:hasPlayerAtPosition("Operations") then
						comms_source.long_range_longer_message_ops = "long_range_longer_message_ops"
						comms_source:addCustomMessage("Operations",comms_source.long_range_longer_message_ops,"Your long range sensors have been carefully tuned. Your previous range was 20U, now your range is 30U")
					end
					if comms_source:hasPlayerAtPosition("Helms") then
						comms_source.short_range_longer_message = "short_range_longer_message"
						comms_source:addCustomMessage("Helms",comms_source.short_range_longer_message,"Your short range sensors have been retuned. Your previous range was 4.5U, now your range is 5U")
					end
					if comms_source:hasPlayerAtPosition("Weapons") then
						comms_source.short_range_longer_message_wea = "short_range_longer_message_wea"
						comms_source:addCustomMessage("Weapons",comms_source.short_range_longer_message_wea,"Your short range sensors have been retuned. Your previous range was 4.5U, now your range is 5U")
					end
					if comms_source:hasPlayerAtPosition("Tactical") then
						comms_source.short_range_longer_message_tac = "short_range_longer_message_tac"
						comms_source:addCustomMessage("Tactical",comms_source.short_range_longer_message_tac,"Your short range sensors have been retuned. Your previous range was 4.5U, now your range is 5U")
					end
					addCommsReply("Back", commsStation)
				end)
			end
			if not comms_source:getCanSelfDestruct() then
				done_with_work = false
				addCommsReply("Install self destruct system",function()
					comms_source:setCanSelfDestruct(true)
					setCommsMessage("Self destruct system installed")
					if comms_source:hasPlayerAtPosition("Engineering") then
						comms_source.self_destruct_message = "self_destruct_message"
						comms_source:addCustomMessage("Engineering",comms_source.self_destruct_message,"After the demolition engineer has checked and double checked the connections, he explains the failsafes associated with the self destruct system: 'Multiple officers must enter the appropriate confirmation code. Those codes are entrusted to other officers so that there must be unanimous consent before the self destruct sequence can be initiated.'")
					end
					if comms_source:hasPlayerAtPosition("Engineering+") then
						comms_source.self_destruct_message_plus = "self_destruct_message_plus"
						comms_source:addCustomMessage("Engineering+",comms_source.self_destruct_message_plus,"After the demolition engineer has checked and double checked the connections, he explains the failsafes associated with the self destruct system: 'Multiple officers must enter the appropriate confirmation code. Those codes are entrusted to other officers so that there must be unanimous consent before the self destruct sequence can be initiated.'")
					end
					addCommsReply("Back", commsStation)
				end)
			end
			if done_with_work then
				fully_functional_player_ship = true
				setCommsMessage(string.format("Nothing left to do for %s",comms_source:getCallSign()))
			end
			addCommsReply("Back", commsStation)
		end)
	end
	if fully_functional_player_ship then
		local offer_repair = false
		if comms_target.comms_data.probe_launch_repair and not comms_source:getCanLaunchProbe() then
			offer_repair = true
		end
		if not offer_repair and comms_target.comms_data.hack_repair and not comms_source:getCanHack() then
			offer_repair = true
		end
		if not offer_repair and comms_target.comms_data.scan_repair and not comms_source:getCanScan() then
			offer_repair = true
		end
		if not offer_repair and comms_target.comms_data.combat_maneuver_repair and not comms_source:getCanCombatManeuver() then
			offer_repair = true
		end
		if not offer_repair and comms_target.comms_data.self_destruct_repair and not comms_source:getCanSelfDestruct() then
			offer_repair = true
		end
		if offer_repair then
			addCommsReply("Repair ship system",function()
				setCommsMessage(string.format("What system would you like repaired?\n\nReputation: %i",math.floor(comms_source:getReputationPoints())))
				if comms_target.comms_data.probe_launch_repair then
					if not comms_source:getCanLaunchProbe() then
						addCommsReply("Repair probe launch system (5 Rep)",function()
							if comms_source:takeReputationPoints(5) then
								comms_source:setCanLaunchProbe(true)
								setCommsMessage("Your probe launch system has been repaired")
							else
								setCommsMessage("Insufficient reputation")
							end
							addCommsReply("Back", commsStation)
						end)
					end
				end
				if comms_target.comms_data.hack_repair then
					if not comms_source:getCanHack() then
						addCommsReply("Repair hacking system (5 Rep)",function()
							if comms_source:takeReputationPoints(5) then
								comms_source:setCanHack(true)
								setCommsMessage("Your hack system has been repaired")
							else
								setCommsMessage("Insufficient reputation")
							end
							addCommsReply("Back", commsStation)
						end)
					end
				end
				if comms_target.comms_data.scan_repair then
					if not comms_source:getCanScan() then
						addCommsReply("Repair scanners (5 Rep)",function()
							if comms_source:takeReputationPoints(5) then
								comms_source:setCanScan(true)
								setCommsMessage("Your scanners have been repaired")
							else
								setCommsMessage("Insufficient reputation")
							end
							addCommsReply("Back", commsStation)
						end)
					end
				end
				if comms_target.comms_data.combat_maneuver_repair then
					if not comms_source:getCanCombatManeuver() then
						addCommsReply("Repair combat maneuver (5 Rep)",function()
							if comms_source:takeReputationPoints(5) then
								comms_source:setCanCombatManeuver(true)
								setCommsMessage("Your combat maneuver has been repaired")
							else
								setCommsMessage("Insufficient reputation")
							end
							addCommsReply("Back", commsStation)
						end)
					end
				end
				if comms_target.comms_data.self_destruct_repair then
					if not comms_source:getCanSelfDestruct() then
						addCommsReply("Repair self destruct system (5 Rep)",function()
							if comms_source:takeReputationPoints(5) then
								comms_source:setCanSelfDestruct(true)
								setCommsMessage("Your self destruct system has been repaired")
							else
								setCommsMessage("Insufficient reputation")
							end
							addCommsReply("Back", commsStation)
						end)
					end
				end
				addCommsReply("Back", commsStation)
			end)
		end
	end
    if isAllowedTo(comms_target.comms_data.services.activatedefensefleet) and 
    	comms_target.comms_data.idle_defense_fleet ~= nil then
    	local defense_fleet_count = 0
    	for name, template in pairs(comms_target.comms_data.idle_defense_fleet) do
    		defense_fleet_count = defense_fleet_count + 1
    	end
    	if defense_fleet_count > 0 then
    		addCommsReply("Activate station defense fleet (" .. getServiceCost("activatedefensefleet") .. " rep)",function()
    			if comms_source:takeReputationPoints(getServiceCost("activatedefensefleet")) then
    				local out = string.format("%s defense fleet\n",comms_target:getCallSign())
    				for name, template in pairs(comms_target.comms_data.idle_defense_fleet) do
    					local script = Script()
						local position_x, position_y = comms_target:getPosition()
						local station_name = comms_target:getCallSign()
						script:setVariable("position_x", position_x):setVariable("position_y", position_y)
						script:setVariable("station_name",station_name)
    					script:setVariable("name",name)
    					script:setVariable("template",template)
    					script:setVariable("faction_id",comms_target:getFactionId())
    					script:run("border_defend_station.lua")
    					out = out .. " " .. name
    					comms_target.comms_data.idle_defense_fleet[name] = nil
    				end
    				out = out .. "\nactivated"
    				setCommsMessage(out)
    			else
    				setCommsMessage("Insufficient reputation")
    			end
				addCommsReply("Back", commsStation)
    		end)
		end
    end
	local has_gossip = random(1,100) < (100 - (30 * (difficulty - .5)))
	if (comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "") or
		(comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "") or
		(comms_source:isFriendly(comms_target) and comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" and has_gossip) then
		addCommsReply("Tell me more about your station", function()
			setCommsMessage("What would you like to know?")
			if comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "" then
				addCommsReply("General information", function()
					setCommsMessage(ctd.general)
					addCommsReply("Back", commsStation)
				end)
			end
			if ctd.history ~= nil and ctd.history ~= "" then
				addCommsReply("Station history", function()
					setCommsMessage(ctd.history)
					addCommsReply("Back", commsStation)
				end)
			end
			if comms_source:isFriendly(comms_target) then
				if ctd.gossip ~= nil and ctd.gossip ~= "" then
					if random(1,100) < (100 - (30 * (difficulty - .5))) then
						addCommsReply("Gossip", function()
							setCommsMessage(ctd.gossip)
							addCommsReply("Back", commsStation)
						end)
					end
				end
			end
			addCommsReply("Back",commsStation)
		end)	--end station info comms reply branch
	end
	if comms_source:isFriendly(comms_target) then
		addCommsReply("What are my current orders?", function()
			if rescued_escape_pods then
				setCommsMessage(string.format("All the escape pods have been rescued. Thank you. Those rescued are doing well and also send you their thanks. Checkout of the Chavez class %s is complete. She and her crew are ready to be put into service.\n\nYou have a choice. You can stand down knowing that you've served with distinction or you can take on another mission to join the fleet in defending %s and eradicating the Kraylor base nearby. What is your decision?",comms_source:getCallSign(),shipyard_station:getCallSign()))
				addCommsReply("Stand down (not enough time in real life)",function()
					addGMMessage("You rescued the escape pods")
					victory("Human Navy")
				end)
				addCommsReply("Take on more Kraylor",function()
					mainPlot = destroyKraylorBase
					setCommsMessage(string.format("Good luck %s",comms_source:getCallSign()))
					primaryOrders = string.format("Destroy %s in %s. Protect %s",pirate_station:getCallSign(),pirate_station:getSectorName(),shipyard_station:getCallSign())
					shipyard_station.comms_data.weapon_available.Nuke = true
					shipyard_station.comms_data.weapon_available.EMP = true
					rescued_escape_pods = false
				end)
			else
				setOptionalOrders()
				setSecondaryOrders()
				ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
				if playWithTimeLimit then
					ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
				end
				setCommsMessage(ordMsg)
				if mainPlot == retrievePods then
					addCommsReply("Report on transmissions received",function()
						if pod_scanned then
							setCommsMessage("At least one of the transmission sources has been identified as an escape pod in a nebula. The transmission characteristics strongly suggest that the other transmission sources are also escape pods.")
						else
							setCommsMessage("We recently started observing faint transmissions. Unfortunately, they defy efforts to locate or even determine a bearing. The detection started shortly after we installed algorithmic filters. Our lead technicians theorize that the transmission source (or sources) therefore are either inside or beyond nebulae in the area.")
						end
						addCommsReply("Back", commsStation)
					end)
				end
			end
			addCommsReply("Back", commsStation)
		end)
		if math.random(1,5) <= (3 - difficulty) then
			local hireCost = math.random(45,90)
			if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
				hireCost = math.random(30,60)
			end
			addCommsReply(string.format("Recruit repair crew member for %i reputation",hireCost), function()
				if not comms_source:takeReputationPoints(hireCost) then
					setCommsMessage("Insufficient reputation")
				else
					comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
					setCommsMessage("Repair crew member hired")
				end
				addCommsReply("Back", commsStation)
			end)
		end
		if comms_source.initialCoolant ~= nil then
			if math.random(1,5) <= (3 - difficulty) then
				local coolantCost = math.random(45,90)
				if comms_source:getMaxCoolant() < comms_source.initialCoolant then
					coolantCost = math.random(30,60)
				end
				addCommsReply(string.format("Purchase coolant for %i reputation",coolantCost), function()
					if not comms_source:takeReputationPoints(coolantCost) then
						setCommsMessage("Insufficient reputation")
					else
						comms_source:setMaxCoolant(comms_source:getMaxCoolant() + 2)
						setCommsMessage("Additional coolant purchased")
					end
					addCommsReply("Back", commsStation)
				end)
			end
		end
	else
		if math.random(1,5) <= (3 - difficulty) then
			local hireCost = math.random(60,120)
			if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
				hireCost = math.random(45,90)
			end
			addCommsReply(string.format("Recruit repair crew member for %i reputation",hireCost), function()
				if not comms_source:takeReputationPoints(hireCost) then
					setCommsMessage("Insufficient reputation")
				else
					comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
					setCommsMessage("Repair crew member hired")
				end
				addCommsReply("Back", commsStation)
			end)
		end
		if comms_source.initialCoolant ~= nil then
			if math.random(1,5) <= (3 - difficulty) then
				local coolantCost = math.random(60,120)
				if comms_source:getMaxCoolant() < comms_source.initialCoolant then
					coolantCost = math.random(45,90)
				end
				addCommsReply(string.format("Purchase coolant for %i reputation",coolantCost), function()
					if not comms_source:takeReputationPoints(coolantCost) then
						setCommsMessage("Insufficient reputation")
					else
						comms_source:setMaxCoolant(comms_source:getMaxCoolant() + 2)
						setCommsMessage("Additional coolant purchased")
					end
					addCommsReply("Back", commsStation)
				end)
			end
		end
	end
	local goodCount = 0
	for good, goodData in pairs(ctd.goods) do
		goodCount = goodCount + 1
	end
	if goodCount > 0 then
		addCommsReply("Buy, sell, trade", function()
			local ctd = comms_target.comms_data
			local goodsReport = string.format("Station %s:\nGoods or components available for sale: quantity, cost in reputation\n",comms_target:getCallSign())
			for good, goodData in pairs(ctd.goods) do
				goodsReport = goodsReport .. string.format("     %s: %i, %i\n",good,goodData["quantity"],goodData["cost"])
			end
			if ctd.buy ~= nil then
				goodsReport = goodsReport .. "Goods or components station will buy: price in reputation\n"
				for good, price in pairs(ctd.buy) do
					goodsReport = goodsReport .. string.format("     %s: %i\n",good,price)
				end
			end
			goodsReport = goodsReport .. string.format("Current cargo aboard %s:\n",comms_source:getCallSign())
			local cargoHoldEmpty = true
			local player_good_count = 0
			if comms_source.goods ~= nil then
				for good, goodQuantity in pairs(comms_source.goods) do
					player_good_count = player_good_count + 1
					goodsReport = goodsReport .. string.format("     %s: %i\n",good,goodQuantity)
				end
			end
			if player_good_count < 1 then
				goodsReport = goodsReport .. "     Empty\n"
			end
			goodsReport = goodsReport .. string.format("Available Space: %i, Available Reputation: %i\n",comms_source.cargo,math.floor(comms_source:getReputationPoints()))
			setCommsMessage(goodsReport)
			for good, goodData in pairs(ctd.goods) do
				addCommsReply(string.format("Buy one %s for %i reputation",good,goodData["cost"]), function()
					local goodTransactionMessage = string.format("Type: %s, Quantity: %i, Rep: %i",good,goodData["quantity"],goodData["cost"])
					if comms_source.cargo < 1 then
						goodTransactionMessage = goodTransactionMessage .. "\nInsufficient cargo space for purchase"
					elseif goodData["cost"] > math.floor(comms_source:getReputationPoints()) then
						goodTransactionMessage = goodTransactionMessage .. "\nInsufficient reputation for purchase"
					elseif goodData["quantity"] < 1 then
						goodTransactionMessage = goodTransactionMessage .. "\nInsufficient station inventory"
					else
						if comms_source:takeReputationPoints(goodData["cost"]) then
							comms_source.cargo = comms_source.cargo - 1
							goodData["quantity"] = goodData["quantity"] - 1
							if comms_source.goods == nil then
								comms_source.goods = {}
							end
							if comms_source.goods[good] == nil then
								comms_source.goods[good] = 0
							end
							comms_source.goods[good] = comms_source.goods[good] + 1
							goodTransactionMessage = goodTransactionMessage .. "\npurchased"
						else
							goodTransactionMessage = goodTransactionMessage .. "\nInsufficient reputation for purchase"
						end
					end
					setCommsMessage(goodTransactionMessage)
					addCommsReply("Back", commsStation)
				end)
			end
			if ctd.buy ~= nil then
				for good, price in pairs(ctd.buy) do
					if comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
						addCommsReply(string.format("Sell one %s for %i reputation",good,price), function()
							local goodTransactionMessage = string.format("Type: %s,  Reputation price: %i",good,price)
							comms_source.goods[good] = comms_source.goods[good] - 1
							comms_source:addReputationPoints(price)
							goodTransactionMessage = goodTransactionMessage .. "\nOne sold"
							comms_source.cargo = comms_source.cargo + 1
							setCommsMessage(goodTransactionMessage)
							addCommsReply("Back", commsStation)
						end)
					end
				end
			end
			if ctd.trade.food then
				if comms_source.goods ~= nil then
					if comms_source.goods.food ~= nil then
						if comms_source.goods.food.quantity > 0 then
							for good, goodData in pairs(ctd.goods) do
								addCommsReply(string.format("Trade food for %s",good), function()
									local goodTransactionMessage = string.format("Type: %s,  Quantity: %i",good,goodData["quantity"])
									if goodData["quantity"] < 1 then
										goodTransactionMessage = goodTransactionMessage .. "\nInsufficient station inventory"
									else
										goodData["quantity"] = goodData["quantity"] - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.goods["food"] = comms_source.goods["food"] - 1
										goodTransactionMessage = goodTransactionMessage .. "\nTraded"
									end
									setCommsMessage(goodTransactionMessage)
									addCommsReply("Back", commsStation)
								end)
							end
						end
					end
				end
			end
			if ctd.trade.medicine then
				if comms_source.goods ~= nil then
					if comms_source.goods.medicine ~= nil then
						if comms_source.goods.medicine.quantity > 0 then
							for good, goodData in pairs(ctd.goods) do
								addCommsReply(string.format("Trade medicine for %s",good), function()
									local goodTransactionMessage = string.format("Type: %s,  Quantity: %i",good,goodData["quantity"])
									if goodData["quantity"] < 1 then
										goodTransactionMessage = goodTransactionMessage .. "\nInsufficient station inventory"
									else
										goodData["quantity"] = goodData["quantity"] - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.goods["medicine"] = comms_source.goods["medicine"] - 1
										goodTransactionMessage = goodTransactionMessage .. "\nTraded"
									end
									setCommsMessage(goodTransactionMessage)
									addCommsReply("Back", commsStation)
								end)
							end
						end
					end
				end
			end
			if ctd.trade.luxury then
				if comms_source.goods ~= nil then
					if comms_source.goods.luxury ~= nil then
						if comms_source.goods.luxury.quantity > 0 then
							for good, goodData in pairs(ctd.goods) do
								addCommsReply(string.format("Trade luxury for %s",good), function()
									local goodTransactionMessage = string.format("Type: %s,  Quantity: %i",good,goodData["quantity"])
									if goodData[quantity] < 1 then
										goodTransactionMessage = goodTransactionMessage .. "\nInsufficient station inventory"
									else
										goodData["quantity"] = goodData["quantity"] - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.goods["luxury"] = comms_source.goods["luxury"] - 1
										goodTransactionMessage = goodTransactionMessage .. "\nTraded"
									end
									setCommsMessage(goodTransactionMessage)
									addCommsReply("Back", commsStation)
								end)
							end
						end
					end
				end
			end
			addCommsReply("Back", commsStation)
		end)
		local player_good_count = 0
		if comms_source.goods ~= nil then
			for good, goodQuantity in pairs(comms_source.goods) do
				player_good_count = player_good_count + 1
			end
		end
		if player_good_count > 0 then
			addCommsReply("Jettison cargo", function()
				setCommsMessage(string.format("Available space: %i\nWhat would you like to jettison?",comms_source.cargo))
				for good, good_quantity in pairs(comms_source.goods) do
					if good_quantity > 0 then
						addCommsReply(good, function()
							comms_source.goods[good] = comms_source.goods[good] - 1
							comms_source.cargo = comms_source.cargo + 1
							setCommsMessage(string.format("One %s jettisoned",good))
							addCommsReply("Back", commsStation)
						end)
					end
				end
				addCommsReply("Back", commsStation)
			end)
		end
		addCommsReply("No tutorial covered goods or cargo. Explain", function()
			setCommsMessage("Different types of cargo or goods may be obtained from stations, freighters or other sources. They go by one word descriptions such as dilithium, optic, warp, etc. Certain mission goals may require a particular type or types of cargo. Each player ship differs in cargo carrying capacity. Goods may be obtained by spending reputation points or by trading other types of cargo (typically food, medicine or luxury)")
			addCommsReply("Back", commsStation)
		end)
	end
end	--end of handleDockedState function
function setSecondaryOrders()
	secondaryOrders = ""
end
function setOptionalOrders()
	optionalOrders = ""
end
function isAllowedTo(state)
    if state == "friend" and comms_source:isFriendly(comms_target) then
        return true
    end
    if state == "neutral" and not comms_source:isEnemy(comms_target) then
        return true
    end
    return false
end
function handleWeaponRestock(weapon)
    if not comms_source:isDocked(comms_target) then 
		setCommsMessage("You need to stay docked for that action.")
		return
	end
    if not isAllowedTo(comms_data.weapons[weapon]) then
        if weapon == "Nuke" then setCommsMessage("We do not deal in weapons of mass destruction.")
        elseif weapon == "EMP" then setCommsMessage("We do not deal in weapons of mass disruption.")
        else setCommsMessage("We do not deal in those weapons.") end
        return
    end
    local points_per_item = getWeaponCost(weapon)
    local item_amount = math.floor(comms_source:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage("All nukes are charged and primed for destruction.");
        else
            setCommsMessage("Sorry, sir, but you are as fully stocked as I can allow.");
        end
        addCommsReply("Back", commsStation)
    else
		if comms_source:getReputationPoints() > points_per_item * item_amount then
			if comms_source:takeReputationPoints(points_per_item * item_amount) then
				comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
				if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
					setCommsMessage("You are fully loaded and ready to explode things.")
				else
					setCommsMessage("We generously resupplied you with some weapon charges.\nPut them to good use.")
				end
			else
				setCommsMessage("Not enough reputation.")
				return
			end
		else
			if comms_source:getReputationPoints() > points_per_item then
				setCommsMessage("You can't afford as much as I'd like to give you")
				addCommsReply("Get just one", function()
					if comms_source:takeReputationPoints(points_per_item) then
						comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + 1)
						if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
							setCommsMessage("You are fully loaded and ready to explode things.")
						else
							setCommsMessage("We generously resupplied you with one weapon charge.\nPut it to good use.")
						end
					else
						setCommsMessage("Not enough reputation.")
					end
					return
				end)
			else
				setCommsMessage("Not enough reputation.")
				return				
			end
		end
        addCommsReply("Back", commsStation)
    end
end
function getWeaponCost(weapon)
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function handleUndockedState()
    --Handle communications when we are not docked with the station.
    local ctd = comms_target.comms_data
    if comms_source:isFriendly(comms_target) then
        oMsg = "Good day, officer.\nIf you need supplies, please dock with us first."
    else
        oMsg = "Greetings.\nIf you want to do business, please dock with us first."
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you."
	end
	setCommsMessage(oMsg)
	if not comms_source:getCanDock() then
		addCommsReply("Request permission to dock",function()
			if comms_target == integral_station then
				setCommsMessage("Transmit your docking authorization codes")
				if rescue_freighter.agree_to_deliver then
					addCommsReply(string.format("Transmit codes provided by %s",rescue_freighter:getCallSign()),function()
						for pidx=1,32 do
							local p = getPlayerShip(pidx)
							if p ~= nil and p:isValid() then
								p:setCanDock(true)
							end
						end
						setCommsMessage("Docking access granted")
					end)
				else
					addCommsReply("We do not have any docking authorization codes",function()
						setCommsMessage("Without docking access codes, you are not authorized to dock")
					end)
				end
			else
				if comms_source:isFriendly(comms_target) and distance(comms_source,comms_target) < 5000 then
					for pidx=1,32 do
						local p = getPlayerShip(pidx)
						if p ~= nil and p:isValid() then
							p:setCanDock(true)
						end
					end
					setCommsMessage("Docking access granted")
				else
					setCommsMessage("Permission denied")
				end
			end
		end)
	end
	--[[
	if isAllowedTo(ctd.services.preorder) then
		addCommsReply("Expedite Dock",function()
			if comms_source.expedite_dock == nil then
				comms_source.expedite_dock = false
			end
			if comms_source.expedite_dock then
				--handle expedite request already present
				local existing_expedite = "Docking crew is standing by"
				if comms_target == comms_source.expedite_dock_station then
					existing_expedite = existing_expedite .. ". Current preorders:"
					local preorders_identified = false
					if comms_source.preorder_hvli ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   HVLIs: %i",comms_source.preorder_hvli)
					end
					if comms_source.preorder_homing ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   Homings: %i",comms_source.preorder_homing)						
					end
					if comms_source.preorder_mine ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   Mines: %i",comms_source.preorder_mine)						
					end
					if comms_source.preorder_emp ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   EMPs: %i",comms_source.preorder_emp)						
					end
					if comms_source.preorder_nuke ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   Nukes: %i",comms_source.preorder_nuke)						
					end
					if comms_source.preorder_repair_crew ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. "\n   One repair crew"						
					end
					if comms_source.preorder_coolant ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. "\n   Coolant"						
					end
					if preorders_identified then
						existing_expedite = existing_expedite .. "\nWould you like to preorder anything else?"
					else
						existing_expedite = existing_expedite .. " none.\nWould you like to preorder anything?"						
					end
					preorder_message = existing_expedite
					preOrderOrdnance()
				else
					existing_expedite = existing_expedite .. string.format(" on station %s (not this station, %s).",comms_source.expedite_dock_station:getCallSign(),comms_target:getCallSign())
					setCommsMessage(existing_expedite)
				end
				addCommsReply("Back",commsStation)
			else
				setCommsMessage("If you would like to speed up the addition of resources such as energy, ordnance, etc., please provide a time frame for your arrival. A docking crew will stand by until that time, after which they will return to their normal duties")
				preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
				addCommsReply("One minute (5 rep)", function()
					if comms_source:takeReputationPoints(5) then
						comms_source.expedite_dock = true
						comms_source.expedite_dock_station = comms_target
						comms_source.expedite_dock_timer_max = 60
						preOrderOrdnance()
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Two minutes (10 Rep)", function()
					if comms_source:takeReputationPoints(10) then
						comms_source.expedite_dock = true
						comms_source.expedite_dock_station = comms_target
						comms_source.expedite_dock_timer_max = 120
						preOrderOrdnance()
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Three minutes (15 Rep)", function()
					if comms_source:takeReputationPoints(15) then
						comms_source.expedite_dock = true
						comms_source.expedite_dock_station = comms_target
						comms_source.expedite_dock_timer_max = 180
						preOrderOrdnance()
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Back", commsStation)
		end)
	end	
	--]]
 	addCommsReply("I need information", function()
		setCommsMessage("What kind of information do you need?")
		addCommsReply("What are my current orders?", function()
			setOptionalOrders()
			setSecondaryOrders()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply("Back", commsStation)
		end)
		addCommsReply("What ordnance do you have available for restock?", function()
			local ctd = comms_target.comms_data
			local missileTypeAvailableCount = 0
			local ordnanceListMsg = ""
			if ctd.weapon_available.Nuke then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   Nuke"
			end
			if ctd.weapon_available.EMP then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   EMP"
			end
			if ctd.weapon_available.Homing then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   Homing"
			end
			if ctd.weapon_available.Mine then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   Mine"
			end
			if ctd.weapon_available.HVLI then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   HVLI"
			end
			if missileTypeAvailableCount == 0 then
				ordnanceListMsg = "We have no ordnance available for restock"
			elseif missileTypeAvailableCount == 1 then
				ordnanceListMsg = "We have the following type of ordnance available for restock:" .. ordnanceListMsg
			else
				ordnanceListMsg = "We have the following types of ordnance available for restock:" .. ordnanceListMsg
			end
			setCommsMessage(ordnanceListMsg)
			addCommsReply("Back", commsStation)
		end)
		addCommsReply("Docking services status", function()
	 		local ctd = comms_target.comms_data
			local service_status = string.format("Station %s docking services status:",comms_target:getCallSign())
			if comms_target:getRestocksScanProbes() then
				service_status = string.format("%s\nReplenish scan probes.",service_status)
			else
				if comms_target.probe_fail_reason == nil then
					local reason_list = {
						"Cannot replenish scan probes due to fabrication unit failure.",
						"Parts shortage prevents scan probe replenishment.",
						"Station management has curtailed scan probe replenishment for cost cutting reasons.",
					}
					comms_target.probe_fail_reason = reason_list[math.random(1,#reason_list)]
				end
				service_status = string.format("%s\n%s",service_status,comms_target.probe_fail_reason)
			end
			if comms_target:getRepairDocked() then
				service_status = string.format("%s\nShip hull repair.",service_status)
			else
				if comms_target.repair_fail_reason == nil then
					reason_list = {
						"We're out of the necessary materials and supplies for hull repair.",
						"Hull repair automation unavailable whie it is undergoing maintenance.",
						"All hull repair technicians quarantined to quarters due to illness.",
					}
					comms_target.repair_fail_reason = reason_list[math.random(1,#reason_list)]
				end
				service_status = string.format("%s\n%s",service_status,comms_target.repair_fail_reason)
			end
			if comms_target:getSharesEnergyWithDocked() then
				service_status = string.format("%s\nRecharge ship energy stores.",service_status)
			else
				if comms_target.energy_fail_reason == nil then
					reason_list = {
						"A recent reactor failure has put us on auxiliary power, so we cannot recharge ships.",
						"A damaged power coupling makes it too dangerous to recharge ships.",
						"An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now.",
					}
					comms_target.energy_fail_reason = reason_list[math.random(1,#reason_list)]
				end
				service_status = string.format("%s\n%s",service_status,comms_target.energy_fail_reason)
			end
			if fully_functional_player_ship then
				if comms_target.comms_data.jump_overcharge then
					service_status = string.format("%s\nMay overcharge jump drive",service_status)
				end
				if comms_target.comms_data.probe_launch_repair then
					service_status = string.format("%s\nMay repair probe launch system",service_status)
				end
				if comms_target.comms_data.hack_repair then
					service_status = string.format("%s\nMay repair hacking system",service_status)
				end
				if comms_target.comms_data.scan_repair then
					service_status = string.format("%s\nMay repair scanners",service_status)
				end
				if comms_target.comms_data.combat_maneuver_repair then
					service_status = string.format("%s\nMay repair combat maneuver",service_status)
				end
				if comms_target.comms_data.self_destruct_repair then
					service_status = string.format("%s\nMay repair self destruct system",service_status)
				end
			end
			setCommsMessage(service_status)
			addCommsReply("Back", commsStation)
		end)
		local goodsAvailable = false
		if ctd.goods ~= nil then
			for good, goodData in pairs(ctd.goods) do
				if goodData["quantity"] > 0 then
					goodsAvailable = true
				end
			end
		end
		if goodsAvailable then
			addCommsReply("What goods do you have available for sale or trade?", function()
				local ctd = comms_target.comms_data
				local goodsAvailableMsg = string.format("Station %s:\nGoods or components available: quantity, cost in reputation",comms_target:getCallSign())
				for good, goodData in pairs(ctd.goods) do
					goodsAvailableMsg = goodsAvailableMsg .. string.format("\n   %14s: %2i, %3i",good,goodData["quantity"],goodData["cost"])
				end
				setCommsMessage(goodsAvailableMsg)
				addCommsReply("Back", commsStation)
			end)
		end
--		if comms_source:isFriendly(comms_target) then
--			addCommsReply("Contact the office of wartime statistics",function()
--				wartimeStatistics()
--				addCommsReply("Back",commsStation)
--			end)
--		end
		addCommsReply("Where can I find particular goods?", function()
			local ctd = comms_target.comms_data
			gkMsg = "Friendly stations often have food or medicine or both. Neutral stations may trade their goods for food, medicine or luxury."
			if ctd.goodsKnowledge == nil then
				ctd.goodsKnowledge = {}
				local knowledgeCount = 0
				local knowledgeMax = 10
				for i=1,#humanStationList do
					local station = humanStationList[i]
					if station ~= nil and station:isValid() then
						local brainCheckChance = 60
						if distance_diagnostic then print("distance_diagnostic 7",comms_target,station) end
						if distance(comms_target,station) > 75000 then
							brainCheckChance = 20
						end
						for good, goodData in pairs(station.comms_data.goods) do
							if random(1,100) <= brainCheckChance then
								local stationCallSign = station:getCallSign()
								local stationSector = station:getSectorName()
								ctd.goodsKnowledge[good] =	{	station = stationCallSign,
																sector = stationSector,
																cost = goodData["cost"] }
								knowledgeCount = knowledgeCount + 1
								if knowledgeCount >= knowledgeMax then
									break
								end
							end
						end
					end
					if knowledgeCount >= knowledgeMax then
						break
					end
				end
			end
			local goodsKnowledgeCount = 0
			for good, goodKnowledge in pairs(ctd.goodsKnowledge) do
				goodsKnowledgeCount = goodsKnowledgeCount + 1
				addCommsReply(good, function()
					local ctd = comms_target.comms_data
					local stationName = ctd.goodsKnowledge[good]["station"]
					local sectorName = ctd.goodsKnowledge[good]["sector"]
					local goodName = good
					local goodCost = ctd.goodsKnowledge[good]["cost"]
					setCommsMessage(string.format("Station %s in sector %s has %s for %i reputation",stationName,sectorName,goodName,goodCost))
					addCommsReply("Back", commsStation)
				end)
			end
			if goodsKnowledgeCount > 0 then
				gkMsg = gkMsg .. "\n\nWhat goods are you interested in?\nI've heard about these:"
			else
				gkMsg = gkMsg .. " Beyond that, I have no knowledge of specific stations"
			end
			setCommsMessage(gkMsg)
			addCommsReply("Back", commsStation)
		end)
		local has_gossip = random(1,100) < (100 - (30 * (difficulty - .5)))
		if (comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "") or
			(comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "") or
			(comms_source:isFriendly(comms_target) and comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" and has_gossip) then
			addCommsReply("Tell me more about your station", function()
				setCommsMessage("What would you like to know?")
				if comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "" then
					addCommsReply("General information", function()
						setCommsMessage(ctd.general)
						addCommsReply("Back", commsStation)
					end)
				end
				if ctd.history ~= nil and ctd.history ~= "" then
					addCommsReply("Station history", function()
						setCommsMessage(ctd.history)
						addCommsReply("Back", commsStation)
					end)
				end
				if comms_source:isFriendly(comms_target) then
					if ctd.gossip ~= nil and ctd.gossip ~= "" then
						if random(1,100) < 50 then
							addCommsReply("Gossip", function()
								setCommsMessage(ctd.gossip)
								addCommsReply("Back", commsStation)
							end)
						end
					end
				end
			end)	--end station info comms reply branch
		end	--end public relations if branch
		if ctd.character ~= nil then
			if random(1,100) < (70 - (20 * difficulty)) then
				addCommsReply(string.format("Tell me about %s",ctd.character), function()
					if ctd.characterDescription ~= nil then
						setCommsMessage(ctd.characterDescription)
					else
						if ctd.characterDeadEnd == nil then
							local deadEndChoice = math.random(1,5)
							if deadEndChoice == 1 then
								ctd.characterDeadEnd = "Never heard of " .. ctd.character
							elseif deadEndChoice == 2 then
								ctd.characterDeadEnd = ctd.character .. " died last week. The funeral was yesterday"
							elseif deadEndChoice == 3 then
								ctd.characterDeadEnd = string.format("%s? Who's %s? There's nobody here named %s",ctd.character,ctd.character,ctd.character)
							elseif deadEndChoice == 4 then
								ctd.characterDeadEnd = string.format("We don't talk about %s. They are gone and good riddance",ctd.character)
							else
								ctd.characterDeadEnd = string.format("I think %s moved away",ctd.character)
							end
						end
						setCommsMessage(ctd.characterDeadEnd)
					end
				end)
			end
		end
		addCommsReply("Report status", function()
			msg = "Hull: " .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
			local shields = comms_target:getShieldCount()
			if shields == 1 then
				msg = msg .. "Shield: " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			else
				for n=0,shields-1 do
					msg = msg .. "Shield " .. n .. ": " .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
				end
			end			
			setCommsMessage(msg);
			addCommsReply("Back", commsStation)
		end)
	end)
	if isAllowedTo(comms_target.comms_data.services.supplydrop) then
        addCommsReply("Can you send a supply drop? ("..getServiceCost("supplydrop").."rep)", function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request backup.");
            else
                setCommsMessage("To which waypoint should we deliver your supplies?");
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
						if comms_source:takeReputationPoints(getServiceCost("supplydrop")) then
							local position_x, position_y = comms_target:getPosition()
							local target_x, target_y = comms_source:getWaypoint(n)
							local script = Script()
							script:setVariable("position_x", position_x):setVariable("position_y", position_y)
							script:setVariable("target_x", target_x):setVariable("target_y", target_y)
							script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
							setCommsMessage("We have dispatched a supply ship toward WP" .. n);
						else
							setCommsMessage("Not enough reputation!");
						end
                        addCommsReply("Back", commsStation)
                    end)
                end
            end
            addCommsReply("Back", commsStation)
        end)
    end
    if isAllowedTo(comms_target.comms_data.services.reinforcements) then
        addCommsReply("Please send reinforcements! ("..getServiceCost("reinforcements").."rep)", function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request reinforcements.");
            else
                setCommsMessage("To which waypoint should we dispatch the reinforcements?");
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
						if treaty then
							local tempAsteroid = VisualAsteroid():setPosition(comms_source:getWaypoint(n))
							local waypointInBorderZone = false
							for i=1,#borderZone do
								if borderZone[i]:isInside(tempAsteroid) then
									waypointInBorderZone = true
									break
								end
							end
							if waypointInBorderZone then
								setCommsMessage("We cannot break the treaty by sending reinforcements to WP" .. n .. " in the neutral border zone")
							elseif outerZone:isInside(tempAsteroid) then
								setCommsMessage("We cannot break the treaty by sending reinforcements to WP" .. n .. " across the neutral border zones")							
							else
								if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
									local ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
									ship:setCallSign(generateCallSign(nil,"Human Navy"))
									ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(friendlyVesselDestroyed)
									setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to assist at WP" .. n);
								else
									setCommsMessage("Not enough reputation!");
								end
							end
							tempAsteroid:destroy()
						else
							if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
								ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
								ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(friendlyVesselDestroyed)
								ship:setCallSign(generateCallSign(nil,"Human Navy"))
								setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to assist at WP" .. n);
							else
								setCommsMessage("Not enough reputation!");
							end
						end
                        addCommsReply("Back", commsStation)
                    end)
                end
            end
            addCommsReply("Back", commsStation)
        end)
    end
    if isAllowedTo(comms_target.comms_data.services.activatedefensefleet) and 
    	comms_target.comms_data.idle_defense_fleet ~= nil then
    	local defense_fleet_count = 0
    	for name, template in pairs(comms_target.comms_data.idle_defense_fleet) do
    		defense_fleet_count = defense_fleet_count + 1
    	end
    	if defense_fleet_count > 0 then
    		addCommsReply("Activate station defense fleet (" .. getServiceCost("activatedefensefleet") .. " rep)",function()
    			if comms_source:takeReputationPoints(getServiceCost("activatedefensefleet")) then
    				local out = string.format("%s defense fleet\n",comms_target:getCallSign())
    				for name, template in pairs(comms_target.comms_data.idle_defense_fleet) do
    					local script = Script()
						local position_x, position_y = comms_target:getPosition()
						local station_name = comms_target:getCallSign()
						script:setVariable("position_x", position_x):setVariable("position_y", position_y)
						script:setVariable("station_name",station_name)
    					script:setVariable("name",name)
    					script:setVariable("template",template)
    					script:setVariable("faction_id",comms_target:getFactionId())
    					script:run("border_defend_station.lua")
    					out = out .. " " .. name
    					comms_target.comms_data.idle_defense_fleet[name] = nil
    				end
    				out = out .. "\nactivated"
    				setCommsMessage(out)
    			else
    				setCommsMessage("Insufficient reputation")
    			end
				addCommsReply("Back", commsStation)
    		end)
		end
    end
end
function getServiceCost(service)
-- Return the number of reputation points that a specified service costs for
-- the current player.
    return math.ceil(comms_data.service_cost[service])
end
function getFriendStatus()
    if comms_source:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
------------------------
-- Ship communication --
------------------------
function commsShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	comms_data = comms_target.comms_data
	if comms_data.goods == nil then
		comms_data.goods = {}
		comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = 1, cost = random(20,80)}
		local shipType = comms_target:getTypeName()
		if shipType:find("Freighter") ~= nil then
			if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
				repeat
					comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = 1, cost = random(20,80)}
					local goodCount = 0
					for good, goodData in pairs(comms_data.goods) do
						goodCount = goodCount + 1
					end
				until(goodCount >= 3)
			end
		end
	end
	if comms_source:isFriendly(comms_target) then
		return friendlyComms(comms_data)
	end
	if comms_source:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentifiedBy(comms_source) then
		return enemyComms(comms_data)
	end
	return neutralComms(comms_data)
end
function friendlyComms(comms_data)
	if comms_data.friendlyness < 20 then
		setCommsMessage("What do you want?");
	else
		setCommsMessage("Sir, how can we assist?");
	end
	if comms_target == rescue_freighter then
		rescue_freighter.contacted_by_player  = true
		local rescue_freighter_pirate_count = 0
		if rescue_freighter_pirates ~= nil then
			for _, enemy in ipairs(rescue_freighter_pirates) do
				if enemy ~= nil and enemy:isValid() then
					rescue_freighter_pirate_count = rescue_freighter_pirate_count + 1
				end
			end
		end
		if rescue_freighter_pirate_count > 0 then
			if rescue_freighter.agree_to_rescue then
				setCommsMessage("Thanks for agreeing to help. What can we do for you?")
			else
				setCommsMessage("We could really use help with the approaching Kraylor. We have no armaments and they are acting aggressively")
				addCommsReply("We will help you against the Kraylor",function()
					setCommsMessage("That's great! We'll send you our scan telemetry on them")
					rescue_freighter.agree_to_rescue = true
					addCommsReply("Back", commsShip)
				end)
			end
			addCommsReply("What did you do to offend these Kraylor?",function()
				setCommsMessage("Nothing! The going theory is that they are engaging in pirate activities and want our cargo. Rather than asking, we think they're just going to destroy us and take whatever is left.")
				addCommsReply("Did you try to talk to them?",function()
					setCommsMessage("We did try to talk to them. They did not say much before they started chasing us. Maybe they'll listen to you.")
					addCommsReply("Back", commsShip)
				end)
				addCommsReply("Back", commsShip)
			end)
		else
			if rescue_freighter.agree_to_rescue then
				setCommsMessage("Thanks for helping with those Kraylor.\nWhat can we do for you?")
			end
			if mainPlot == helpFreighterDelivery then
				if rescue_freighter_cargo ~= nil and rescue_freighter_cargo:isValid() then
					addCommsReply("It looks like you dropped something...",function()
						setCommsMessage(string.format("Yes, the Kraylor damaged us such that we lost cargo capacity. It would be nice if you could pick that up and deliver it to %s",integral_station:getCallSign()))
						if rescue_freighter.agree_to_deliver == nil then
							addCommsReply("We'll deliver that cargo for you",function()
								rescue_freighter.agree_to_deliver = true
								comms_source:addReputationPoints(5)
								setCommsMessage(string.format("Thanks. We're transmitting the docking codes for %s to you",integral_station:getCallSign()))
								addCommsReply("Back", commsShip)
							end)
							if not comms_source:hasJumpDrive() then
								addCommsReply(string.format("%s is too far away and thus would take too long to deliver",integral_station:getCallSign()),function()
									setCommsMessage("We are traveling at impulse speed, so your speed should not be a problem. Besides, you could always use your jump drive if you're really in a hurry.")
									addCommsReply("We don't have a jump drive",function()
										setCommsMessage("Our scans show that you have a jump drive, but it's not active. Most likely the installtion is incomplete. I know the military follows strict protocols regarding engine activation, but we've got a technician aboard that can activate your jump drive. What do you think?")
										addCommsReply("No unauthorized technicians allowed to modify engines",function()
											setCommsMessage("Understood.")
											addCommsReply("Back", commsShip)
										end)
										addCommsReply("Please send over the technician to activate the jump drive",function()
											if distance(comms_source,rescue_freighter) < 1000 then
												comms_source:setJumpDrive(true)
												comms_source.max_jump_range = 25000
												comms_source.min_jump_range = 2500
												comms_source:setJumpDriveRange(comms_source.min_jump_range,comms_source.max_jump_range)
												comms_source:setJumpDriveCharge(comms_source.max_jump_range)
												setCommsMessage("The technician was able to activate minimal jump drive capability. Your shipyards may be able to increase the performance.")
												if comms_source:hasPlayerAtPosition("Helms") then
													comms_source.jump_drive_message = "jump_drive_message"
													comms_source:addCustomMessage("Helms",comms_source.jump_drive_message,"After the technician finishes the jump drive controls, he tells you that the best range he could get from the drive was 25 units. He tells you that you can always check the minimum and maximum range by moving the jump range slider all the way down and all the way up.")
												end
												if comms_source:hasPlayerAtPosition("Tactical") then
													comms_source.jump_drive_message_tac = "jump_drive_message_tac"
													comms_source:addCustomMessage("Tactical",comms_source.jump_drive_message_tac,"After the technician finishes the jump drive controls, he tells you that the best range he could get from the drive was 25 units. He tells you that you can always check the minimum and maximum range by moving the jump range slider all the way down and all the way up.")
												end
												if comms_source:hasPlayerAtPosition("SinglePilot") then
													comms_source.jump_drive_message_single = "jump_drive_message_single"
													comms_source:addCustomMessage("SinglePilot",comms_source.jump_drive_message_single,"After the technician finishes the jump drive controls, he tells you that the best range he could get from the drive was 25 units. He tells you that you can always check the minimum and maximum range by moving the jump range slider all the way down and all the way up.")
												end
												if comms_source:hasPlayerAtPosition("Engineering") then
													comms_source.jump_drive_message_eng = "jump_drive_message_eng"
													comms_source:addCustomMessage("Engineering",comms_source.jump_drive_message_eng,"As the technician makes some connections and configures the jump drive he mentions that the jump drive draws far more energy than the impulse drives, it generates heat when used and it will lose charge if you put less than 25% power in it")
												end
												if comms_source:hasPlayerAtPosition("Engineering+") then
													comms_source.jump_drive_message_eng_plus = "jump_drive_message_eng_plus"
													comms_source:addCustomMessage("Engineering+",comms_source.jump_drive_message_eng_plus,"As the technician makes some connections and configures the jump drive he mentions that the jump drive draws far more energy than the impulse drives, it generates heat when used and it will lose charge if you put less than 25% power in it")
												end
												if comms_source:hasPlayerAtPosition("PowerManagement") then
													comms_source.jump_drive_message_pm = "jump_drive_message_pm"
													comms_source:addCustomMessage("PowerManagement",comms_source.jump_drive_message_pm,"As the technician makes some connections and configures the jump drive he mentions that the jump drive draws far more energy than the impulse drives, it generates heat when used and it will lose charge if you put less than 25% power in it")
												end
											else
												setCommsMessage("You are too far away. Our transporters only work at a range of 1 unit or less")
											end
											addCommsReply("Back", commsShip)
										end)
										addCommsReply("Back", commsShip)
									end)
									addCommsReply("Since speed is not a problem, we agree to deliver the cargo",function()
										rescue_freighter.agree_to_deliver = true
										comms_source:addReputationPoints(5)
										setCommsMessage(string.format("Thanks. We're transmitting the docking codes for %s to you",integral_station:getCallSign()))
										addCommsReply("Back", commsShip)
									end)
									addCommsReply("Back", commsShip)
								end)
							end
							addCommsReply("That's not part of our mission",function()
								setCommsMessage("That's disappointing")
								addCommsReply("Back", commsShip)
							end)
						end
						if comms_source.integral_station_waypoint == nil then
							addCommsReply(string.format("We don't know where %s is located",integral_station:getCallSign()),function()
								comms_source:commandAddWaypoint(integral_station:getPosition())
								comms_source.integral_station_waypoint = "set"
								setCommsMessage(string.format("We can fix that. I just transmitted the coordinates of station %s to your navigation computer. You should see waypoint %i on it",integral_station:getCallSign(),comms_source:getWaypointCount()))
								addCommsReply("Back", commsShip)
							end)
						end
						addCommsReply("Back", commsShip)
					end)
				else	--cargo artifact picked up
					addCommsReply("What can you tell us about what we just picked up?",function()
						setCommsMessage(string.format("It's cargo we can no longer carry, originally bound for %s",integral_station:getCallSign()))
						if rescue_freighter.agree_to_deliver == nil then
							addCommsReply("We picked it up, we'll deliver it for you",function()
								rescue_freighter.agree_to_deliver = true
								comms_source:addReputationPoints(5)
								setCommsMessage(string.format("Thanks. We're transmitting the docking codes for %s to you",integral_station:getCallSign()))
								addCommsReply("Back", commsShip)
							end)
						end
						if comms_source.integral_station_waypoint == nil then
							addCommsReply(string.format("We don't know where %s is located",integral_station:getCallSign()),function()
								comms_source:commandAddWaypoint(integral_station:getPosition())
								comms_source.integral_station_waypoint = "set"
								setCommsMessage(string.format("We can fix that. I just transmitted the coordinates of station %s to your navigation computer. You should see waypoint %i on it",integral_station:getCallSign(),comms_source:getWaypointCount()))
								addCommsReply("Back", commsShip)
							end)
						end
						addCommsReply("Back", commsShip)
					end)
				end
			end
		end
		addCommsReply("What are you doing in this region of space?",function()
			setCommsMessage(string.format("We are delivering cargo to station %s in sector %s. What are you doing out here?",integral_station:getCallSign(),integral_station:getSectorName()))
			comms_source:addReputationPoints(1)
			addCommsReply("We're on a training mission",function()
				setCommsMessage("New recruits, eh? Learn well and good luck")
				addCommsReply("Back", commsShip)
			end)
			addCommsReply("We're testing the Chavez class shhip",function()
				setCommsMessage("I'll be interested in reading your report. Good luck")
				addCommsReply("Back", commsShip)
			end)
			addCommsReply("We're on a standard patrol mission",function()
				setCommsMessage("We're glad you're here")
				addCommsReply("Back", commsShip)
			end)
			addCommsReply(string.format("We're training, testing the %s and patrolling",comms_source:getCallSign()),function()
				setCommsMessage("You sound busy. Thanks for letting us know")
				comms_source:addReputationPoints(1)
				addCommsReply("Back", commsShip)
			end)
			addCommsReply("Back", commsShip)
		end)
	end
	addCommsReply("Defend a waypoint", function()
		if comms_source:getWaypointCount() == 0 then
			setCommsMessage("No waypoints set. Please set a waypoint first.");
			addCommsReply("Back", commsShip)
		else
			setCommsMessage("Which waypoint should we defend?");
			for n=1,comms_source:getWaypointCount() do
				addCommsReply("Defend WP" .. n, function()
					if treaty then
						local tempAsteroid = VisualAsteroid():setPosition(comms_source:getWaypoint(n))
						local waypointInBorderZone = false
						for i=1,#borderZone do
							if borderZone[i]:isInside(tempAsteroid) then
								waypointInBorderZone = true
								break
							end
						end
						if waypointInBorderZone then
							setCommsMessage("We cannot break the treaty by defending WP" .. n .. " in the neutral border zone")
						elseif outerZone:isInside(tempAsteroid) then
							setCommsMessage("We cannot break the treaty by defending WP" .. n .. " across the neutral border zones")							
						else
							comms_target:orderDefendLocation(comms_source:getWaypoint(n))
							setCommsMessage("We are heading to assist at WP" .. n ..".");
						end
						tempAsteroid:destroy()
					else
						comms_target:orderDefendLocation(comms_source:getWaypoint(n))
						setCommsMessage("We are heading to assist at WP" .. n ..".");
					end
					addCommsReply("Back", commsShip)
				end)
			end
		end
	end)
	if comms_data.friendlyness > 0.2 then
		addCommsReply("Assist me", function()
			setCommsMessage("Heading toward you to assist.");
			comms_target:orderDefendTarget(comms_source)
			addCommsReply("Back", commsShip)
		end)
	end
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
		addCommsReply("Back", commsShip)
	end)
	for _, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			addCommsReply("Dock at " .. obj:getCallSign(), function()
				setCommsMessage("Docking at " .. obj:getCallSign() .. ".");
				comms_target:orderDock(obj)
				addCommsReply("Back", commsShip)
			end)
		end
	end
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		if distance(comms_source, comms_target) < 5000 then
			local goodCount = 0
			if comms_source.goods ~= nil then
				for good, goodQuantity in pairs(comms_source.goods) do
					goodCount = goodCount + 1
				end
			end
			if goodCount > 0 then
				addCommsReply("Jettison cargo", function()
					setCommsMessage(string.format("Available space: %i\nWhat would you like to jettison?",comms_source.cargo))
					for good, good_quantity in pairs(comms_source.goods) do
						if good_quantity > 0 then
							addCommsReply(good, function()
								comms_source.goods[good] = comms_source.goods[good] - 1
								comms_source.cargo = comms_source.cargo + 1
								setCommsMessage(string.format("One %s jettisoned",good))
								addCommsReply("Back", commsShip)
							end)
						end
					end
					addCommsReply("Back", commsShip)
				end)
			end
			if comms_data.friendlyness > 66 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					if comms_source.goods ~= nil and comms_source.goods.luxury ~= nil and comms_source.goods.luxury > 0 then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 and good ~= "luxury" then
								addCommsReply(string.format("Trade luxury for %s",good), function()
									goodData.quantity = goodData.quantity - 1
									if comms_source.goods == nil then
										comms_source.goods = {}
									end
									if comms_source.goods[good] == nil then
										comms_source.goods[good] = 0
									end
									comms_source.goods[good] = comms_source.goods[good] + 1
									comms_source.goods.luxury = comms_source.goods.luxury - 1
									setCommsMessage(string.format("Traded your luxury for %s from %s",good,comms_target:getCallSign()))
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					end	--player has luxury branch
				end	--goods or equipment freighter
				if comms_source.cargo > 0 then
					for good, goodData in pairs(comms_data.goods) do
						if goodData.quantity > 0 then
							addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost)), function()
								if comms_source:takeReputationPoints(goodData.cost) then
									goodData.quantity = goodData.quantity - 1
									if comms_source.goods == nil then
										comms_source.goods = {}
									end
									if comms_source.goods[good] == nil then
										comms_source.goods[good] = 0
									end
									comms_source.goods[good] = comms_source.goods[good] + 1
									comms_source.cargo = comms_source.cargo - 1
									setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
								else
									setCommsMessage("Insufficient reputation for purchase")
								end
								addCommsReply("Back", commsShip)
							end)
						end
					end	--freighter goods loop
				end	--player has cargo space branch
			elseif comms_data.friendlyness > 33 then
				if comms_source.cargo > 0 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost)), function()
									if comms_source:takeReputationPoints(goodData.cost) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					else	--not goods or equipment freighter
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*2)), function()
									if comms_source:takeReputationPoints(goodData.cost*2) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					end
				end	--player has room for cargo branch
			else	--least friendly
				if comms_source.cargo > 0 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*2)), function()
									if comms_source:takeReputationPoints(goodData.cost*2) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					end	--goods or equipment freighter
				end	--player has room to get goods
			end	--various friendliness choices
		else	--not close enough to sell
			addCommsReply("Do you have cargo you might sell?", function()
				local goodCount = 0
				local cargoMsg = "We've got "
				for good, goodData in pairs(comms_data.goods) do
					if goodData.quantity > 0 then
						if goodCount > 0 then
							cargoMsg = cargoMsg .. ", " .. good
						else
							cargoMsg = cargoMsg .. good
						end
					end
					goodCount = goodCount + goodData.quantity
				end
				if goodCount == 0 then
					cargoMsg = cargoMsg .. "nothing"
				end
				setCommsMessage(cargoMsg)
				addCommsReply("Back", commsShip)
			end)
		end
	end
	return true
end
function enemyComms(comms_data)
	local faction = comms_target:getFaction()
	local tauntable = false
	local amenable = false
	if comms_data.friendlyness >= 33 then	--final: 33
		--taunt logic
		local taunt_option = "We will see to your destruction!"
		local taunt_success_reply = "Your bloodline will end here!"
		local taunt_failed_reply = "Your feeble threats are meaningless."
		local taunt_threshold = 30		--base chance of being taunted
		local immolation_threshold = 5	--base chance that taunting will enrage to the point of revenge immolation
		if faction == "Kraylor" then
			taunt_threshold = 35
			immolation_threshold = 6
			setCommsMessage("Ktzzzsss.\nYou will DIEEee weaklingsss!");
			local kraylorTauntChoice = math.random(1,3)
			if kraylorTauntChoice == 1 then
				taunt_option = "We will destroy you"
				taunt_success_reply = "We think not. It is you who will experience destruction!"
			elseif kraylorTauntChoice == 2 then
				taunt_option = "You have no honor"
				taunt_success_reply = "Your insult has brought our wrath upon you. Prepare to die."
				taunt_failed_reply = "Your comments about honor have no meaning to us"
			else
				taunt_option = "We pity your pathetic race"
				taunt_success_reply = "Pathetic? You will regret your disparagement!"
				taunt_failed_reply = "We don't care what you think of us"
			end
		elseif faction == "Arlenians" then
			taunt_threshold = 25
			immolation_threshold = 4
			setCommsMessage("We wish you no harm, but will harm you if we must.\nEnd of transmission.");
		elseif faction == "Exuari" then
			taunt_threshold = 40
			immolation_threshold = 7
			setCommsMessage("Stay out of our way, or your death will amuse us extremely!");
		elseif faction == "Ghosts" then
			taunt_threshold = 20
			immolation_threshold = 3
			setCommsMessage("One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted.");
			taunt_option = "EXECUTE: SELFDESTRUCT"
			taunt_success_reply = "Rogue command received. Targeting source."
			taunt_failed_reply = "External command ignored."
		elseif faction == "Ktlitans" then
			setCommsMessage("The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition.");
			taunt_option = "<Transmit 'The Itsy-Bitsy Spider' on all wavelengths>"
			taunt_success_reply = "We do not need permission to pluck apart such an insignificant threat."
			taunt_failed_reply = "The hive has greater priorities than exterminating pests."
		elseif faction == "TSN" then
			taunt_threshold = 15
			immolation_threshold = 2
			setCommsMessage("State your business")
		elseif faction == "USN" then
			taunt_threshold = 15
			immolation_threshold = 2
			setCommsMessage("What do you want? (not that we care)")
		elseif faction == "CUF" then
			taunt_threshold = 15
			immolation_threshold = 2
			setCommsMessage("Don't waste our time")
		else
			setCommsMessage("Mind your own business!");
		end
		comms_data.friendlyness = comms_data.friendlyness - random(0, 10)	--reduce friendlyness after each interaction
		addCommsReply(taunt_option, function()
			if random(0, 100) <= taunt_threshold then
				local current_order = comms_target:getOrder()
				print("order: " .. current_order)
				--Possible order strings returned:
				--Roaming
				--Fly towards
				--Attack
				--Stand Ground
				--Idle
				--Defend Location
				--Defend Target
				--Fly Formation (?)
				--Fly towards (ignore all)
				--Dock
				if comms_target.original_order == nil then
					comms_target.original_faction = faction
					comms_target.original_order = current_order
					if current_order == "Fly towards" or current_order == "Defend Location" or current_order == "Fly towards (ignore all)" then
						comms_target.original_target_x, comms_target.original_target_y = comms_target:getOrderTargetLocation()
						--print(string.format("Target_x: %f, Target_y: %f",comms_target.original_target_x,comms_target.original_target_y))
					end
					if current_order == "Attack" or current_order == "Dock" or current_order == "Defend Target" then
						local original_target = comms_target:getOrderTarget()
						--print("target:")
						--print(original_target)
						--print(original_target:getCallSign())
						comms_target.original_target = original_target
					end
					comms_target.taunt_may_expire = true	--change to conditional in future refactoring
					table.insert(enemy_reverts,comms_target)
				end
				comms_target:orderAttack(comms_source)	--consider alternative options besides attack in future refactoring
				setCommsMessage(taunt_success_reply);
			else
				--possible alternative consequences when taunt fails
				if random(1,100) < (immolation_threshold + difficulty) then	--final: immolation_threshold (set to 100 for testing)
					setCommsMessage("Subspace and time continuum disruption authorized")
					comms_source.continuum_target = true
					comms_source.continuum_initiator = comms_target
					plotContinuum = checkContinuum
				else
					setCommsMessage(taunt_failed_reply);
				end
			end
		end)
		tauntable = true
	end
	local enemy_health = getEnemyHealth(comms_target)
	if change_enemy_order_diagnostic then print(string.format("   enemy health:    %.2f",enemy_health)) end
	if change_enemy_order_diagnostic then print(string.format("   friendliness:    %.1f",comms_data.friendlyness)) end
	if comms_data.friendlyness >= 66 or enemy_health < .5 then	--final: 66, .5
		--amenable logic
		local amenable_chance = comms_data.friendlyness/3 + (1 - enemy_health)*30
		if change_enemy_order_diagnostic then print(string.format("   amenability:     %.1f",amenable_chance)) end
		addCommsReply("Stop your actions",function()
			local amenable_roll = random(1,100)
			if change_enemy_order_diagnostic then print(string.format("   amenable roll:   %.1f",amenable_roll)) end
			if amenable_roll < amenable_chance then
				local current_order = comms_target:getOrder()
				if comms_target.original_order == nil then
					comms_target.original_order = current_order
					comms_target.original_faction = faction
					if current_order == "Fly towards" or current_order == "Defend Location" or current_order == "Fly towards (ignore all)" then
						comms_target.original_target_x, comms_target.original_target_y = comms_target:getOrderTargetLocation()
						--print(string.format("Target_x: %f, Target_y: %f",comms_target.original_target_x,comms_target.original_target_y))
					end
					if current_order == "Attack" or current_order == "Dock" or current_order == "Defend Target" then
						local original_target = comms_target:getOrderTarget()
						--print("target:")
						--print(original_target)
						--print(original_target:getCallSign())
						comms_target.original_target = original_target
					end
					table.insert(enemy_reverts,comms_target)
				end
				comms_target.amenability_may_expire = true		--set up conditional in future refactoring
				comms_target:orderIdle()
				comms_target:setFaction("Independent")
				setCommsMessage("Just this once, we'll take your advice")
			else
				setCommsMessage("No")
			end
		end)
		comms_data.friendlyness = comms_data.friendlyness - random(0, 10)	--reduce friendlyness after each interaction
		amenable = true
	end
	if tauntable or amenable then
		return true
	else
		return false
	end
end
function getEnemyHealth(enemy)
	local enemy_health = 0
	local enemy_shield = 0
	local enemy_shield_count = enemy:getShieldCount()
	local faction = enemy:getFaction()
	if change_enemy_order_diagnostic then print(string.format("%s statistics:",enemy:getCallSign())) end
	if change_enemy_order_diagnostic then print(string.format("   shield count:    %i",enemy_shield_count)) end
	if enemy_shield_count > 0 then
		local total_shield_level = 0
		local max_shield_level = 0
		for i=1,enemy_shield_count do
			total_shield_level = total_shield_level + enemy:getShieldLevel(i-1)
			max_shield_level = max_shield_level + enemy:getShieldMax(i-1)
		end
		enemy_shield = total_shield_level/max_shield_level
	else
		enemy_shield = 1
	end
	if change_enemy_order_diagnostic then print(string.format("   shield health:   %.1f",enemy_shield)) end
	local enemy_hull = enemy:getHull()/enemy:getHullMax()
	if change_enemy_order_diagnostic then print(string.format("   hull health:     %.1f",enemy_hull)) end
	local enemy_reactor = enemy:getSystemHealth("reactor")
	if change_enemy_order_diagnostic then print(string.format("   reactor health:  %.1f",enemy_reactor)) end
	local enemy_maneuver = enemy:getSystemHealth("maneuver")
	if change_enemy_order_diagnostic then print(string.format("   maneuver health: %.1f",enemy_maneuver)) end
	local enemy_impulse = enemy:getSystemHealth("impulse")
	if change_enemy_order_diagnostic then print(string.format("   impulse health:  %.1f",enemy_impulse)) end
	local enemy_beam = 0
	if enemy:getBeamWeaponRange(0) > 0 then
		enemy_beam = enemy:getSystemHealth("beamweapons")
		if change_enemy_order_diagnostic then print(string.format("   beam health:     %.1f",enemy_beam)) end
	else
		enemy_beam = 1
		if change_enemy_order_diagnostic then print(string.format("   beam health:     %.1f (no beams)",enemy_beam)) end
	end
	local enemy_missile = 0
	if enemy:getWeaponTubeCount() > 0 then
		enemy_missile = enemy:getSystemHealth("missilesystem")
		if change_enemy_order_diagnostic then print(string.format("   missile health:  %.1f",enemy_missile)) end
	else
		enemy_missile = 1
		if change_enemy_order_diagnostic then print(string.format("   missile health:  %.1f (no missile system)",enemy_missile)) end
	end
	local enemy_warp = 0
	if enemy:hasWarpDrive() then
		enemy_warp = enemy:getSystemHealth("warp")
		if change_enemy_order_diagnostic then print(string.format("   warp health:     %.1f",enemy_warp)) end
	else
		enemy_warp = 1
		if change_enemy_order_diagnostic then print(string.format("   warp health:     %.1f (no warp drive)",enemy_warp)) end
	end
	local enemy_jump = 0
	if enemy:hasJumpDrive() then
		enemy_jump = enemy:getSystemHealth("jumpdrive")
		if change_enemy_order_diagnostic then print(string.format("   jump health:     %.1f",enemy_jump)) end
	else
		enemy_jump = 1
		if change_enemy_order_diagnostic then print(string.format("   jump health:     %.1f (no jump drive)",enemy_jump)) end
	end
	if change_enemy_order_diagnostic then print(string.format("   faction:         %s",faction)) end
	if faction == "Kraylor" then
		enemy_health = 
			enemy_shield 	* .3	+
			enemy_hull		* .4	+
			enemy_reactor	* .1 	+
			enemy_maneuver	* .03	+
			enemy_impulse	* .03	+
			enemy_beam		* .04	+
			enemy_missile	* .04	+
			enemy_warp		* .03	+
			enemy_jump		* .03
	elseif faction == "Arlenians" then
		enemy_health = 
			enemy_shield 	* .35	+
			enemy_hull		* .45	+
			enemy_reactor	* .05 	+
			enemy_maneuver	* .03	+
			enemy_impulse	* .04	+
			enemy_beam		* .02	+
			enemy_missile	* .02	+
			enemy_warp		* .02	+
			enemy_jump		* .02	
	elseif faction == "Exuari" then
		enemy_health = 
			enemy_shield 	* .2	+
			enemy_hull		* .3	+
			enemy_reactor	* .2 	+
			enemy_maneuver	* .05	+
			enemy_impulse	* .05	+
			enemy_beam		* .05	+
			enemy_missile	* .05	+
			enemy_warp		* .05	+
			enemy_jump		* .05	
	elseif faction == "Ghosts" then
		enemy_health = 
			enemy_shield 	* .25	+
			enemy_hull		* .25	+
			enemy_reactor	* .25 	+
			enemy_maneuver	* .04	+
			enemy_impulse	* .05	+
			enemy_beam		* .04	+
			enemy_missile	* .04	+
			enemy_warp		* .04	+
			enemy_jump		* .04	
	elseif faction == "Ktlitans" then
		enemy_health = 
			enemy_shield 	* .2	+
			enemy_hull		* .3	+
			enemy_reactor	* .1 	+
			enemy_maneuver	* .05	+
			enemy_impulse	* .05	+
			enemy_beam		* .05	+
			enemy_missile	* .05	+
			enemy_warp		* .1	+
			enemy_jump		* .1	
	elseif faction == "TSN" then
		enemy_health = 
			enemy_shield 	* .35	+
			enemy_hull		* .35	+
			enemy_reactor	* .08 	+
			enemy_maneuver	* .01	+
			enemy_impulse	* .02	+
			enemy_beam		* .02	+
			enemy_missile	* .01	+
			enemy_warp		* .08	+
			enemy_jump		* .08	
	elseif faction == "USN" then
		enemy_health = 
			enemy_shield 	* .38	+
			enemy_hull		* .38	+
			enemy_reactor	* .05 	+
			enemy_maneuver	* .02	+
			enemy_impulse	* .03	+
			enemy_beam		* .02	+
			enemy_missile	* .02	+
			enemy_warp		* .05	+
			enemy_jump		* .05	
	elseif faction == "CUF" then
		enemy_health = 
			enemy_shield 	* .35	+
			enemy_hull		* .38	+
			enemy_reactor	* .05 	+
			enemy_maneuver	* .03	+
			enemy_impulse	* .03	+
			enemy_beam		* .03	+
			enemy_missile	* .03	+
			enemy_warp		* .06	+
			enemy_jump		* .04	
	else
		enemy_health = 
			enemy_shield 	* .3	+
			enemy_hull		* .4	+
			enemy_reactor	* .06 	+
			enemy_maneuver	* .03	+
			enemy_impulse	* .05	+
			enemy_beam		* .03	+
			enemy_missile	* .03	+
			enemy_warp		* .05	+
			enemy_jump		* .05	
	end
	return enemy_health
end
function revertWait(delta)
	revert_timer = revert_timer - delta
	if revert_timer < 0 then
		revert_timer = delta + revert_timer_interval
		plotRevert = revertCheck
	end
end
function revertCheck(delta)
	if enemy_reverts ~= nil then
		for _, enemy in ipairs(enemy_reverts) do
			if enemy ~= nil and enemy:isValid() then
				local expiration_chance = 0
				local enemy_faction = enemy:getFaction()
				if enemy.taunt_may_expire then
					if enemy_faction == "Kraylor" then
						expiration_chance = 4.5
					elseif enemy_faction == "Arlenians" then
						expiration_chance = 7
					elseif enemy_faction == "Exuari" then
						expiration_chance = 2.5
					elseif enemy_faction == "Ghosts" then
						expiration_chance = 8.5
					elseif enemy_faction == "Ktlitans" then
						expiration_chance = 5.5
					elseif enemy_faction == "TSN" then
						expiration_chance = 3
					elseif enemy_faction == "USN" then
						expiration_chance = 3.5
					elseif enemy_faction == "CUF" then
						expiration_chance = 4
					else
						expiration_chance = 6
					end
				elseif enemy.amenability_may_expire then
					local enemy_health = getEnemyHealth(enemy)
					if enemy_faction == "Kraylor" then
						expiration_chance = 2.5
					elseif enemy_faction == "Arlenians" then
						expiration_chance = 3.25
					elseif enemy_faction == "Exuari" then
						expiration_chance = 6.6
					elseif enemy_faction == "Ghosts" then
						expiration_chance = 3.2
					elseif enemy_faction == "Ktlitans" then
						expiration_chance = 4.8
					elseif enemy_faction == "TSN" then
						expiration_chance = 3.5
					elseif enemy_faction == "USN" then
						expiration_chance = 2.8
					elseif enemy_faction == "CUF" then
						expiration_chance = 3
					else
						expiration_chance = 4
					end
					expiration_chance = expiration_chance + enemy_health*5
				end
				local expiration_roll = random(1,100)
				if expiration_roll < expiration_chance then
					local oo = enemy.original_order
					local otx = enemy.original_target_x
					local oty = enemy.original_target_y
					local ot = enemy.original_target
					if oo ~= nil then
						if oo == "Attack" then
							if ot ~= nil and ot:isValid() then
								enemy:orderAttack(ot)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Dock" then
							if ot ~= nil and ot:isValid() then
								enemy:orderDock(ot)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Defend Target" then
							if ot ~= nil and ot:isValid() then
								enemy:orderDefendTarget(ot)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Fly towards" then
							if otx ~= nil and oty ~= nil then
								enemy:orderFlyTowards(otx,oty)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Defend Location" then
							if otx ~= nil and oty ~= nil then
								enemy:orderDefendLocation(otx,oty)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Fly towards (ignore all)" then
							if otx ~= nil and oty ~= nil then
								enemy:orderFlyTowardsBlind(otx,oty)
							else
								enemy:orderRoaming()
							end
						else
							enemy:orderRoaming()
						end
					else
						enemy:orderRoaming()
					end
					if enemy.original_faction ~= nil then
						enemy:setFaction(enemy.original_faction)
					end
					enemy.taunt_may_expire = false
					enemy.amenability_may_expire = false
				end
			end
		end
	end
	plotRevert = revertWait
end
function checkContinuum(delta)
	local continuum_count = 0
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.continuum_target then
				continuum_count = continuum_count + 1
				if p.continuum_timer == nil then
					p.continuum_timer = delta + 30
				end
				p.continuum_timer = p.continuum_timer - delta
				if p.continuum_timer < 0 then
					if p.continuum_initiator ~= nil and p.continuum_initiator:isValid() then
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("frontshield",(p:getSystemHealth("frontshield") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("rearshield",(p:getSystemHealth("rearshield") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("reactor",(p:getSystemHealth("reactor") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("maneuver",(p:getSystemHealth("maneuver") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("impulse",(p:getSystemHealth("impulse") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("beamweapons",(p:getSystemHealth("beamweapons") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("missilesystem",(p:getSystemHealth("missilesystem") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("warp",(p:getSystemHealth("warp") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("jumpdrive",(p:getSystemHealth("jumpdrive") - 1)/2) end
						local ex, ey = p.continuum_initiator:getPosition()
						p.continuum_initiator:destroy()
						ExplosionEffect():setPosition(ex,ey):setSize(3000)
						resetContinuum(p)
					else
						resetContinuum(p)
					end
				else
					local timer_display = string.format("Disruption %i",math.floor(p.continuum_timer))
					if p:hasPlayerAtPosition("Relay") then
						p.continuum_timer_display = "continuum_timer_display"
						p:addCustomInfo("Relay",p.continuum_timer_display,timer_display)
					end
					if p:hasPlayerAtPosition("Operations") then
						p.continuum_timer_display_ops = "continuum_timer_display_ops"
						p:addCustomInfo("Operations",p.continuum_timer_display_ops,timer_display)
					end
				end
			else
				resetContinuum(p)
			end
		end
	end
end
function resetContinuum(p)
	p.continuum_target = nil
	p.continuum_timer = nil
	p.continuum_initiator = nil
	if p.continuum_timer_display ~= nil then
		p:removeCustom("Relay",p.continuum_timer_display)
		p.continuum_timer_display = nil
	end
	if p.continuum_timer_display_ops ~= nil then
		p:removeCustom("Operations",p.continuum_timer_display_ops)
		p.continuum_timer_display_ops = nil
	end
end
function neutralComms(comms_data)
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		setCommsMessage("Yes?")
		addCommsReply("Do you have cargo you might sell?", function()
			local goodCount = 0
			local cargoMsg = "We've got "
			for good, goodData in pairs(comms_data.goods) do
				if goodData.quantity > 0 then
					if goodCount > 0 then
						cargoMsg = cargoMsg .. ", " .. good
					else
						cargoMsg = cargoMsg .. good
					end
				end
				goodCount = goodCount + goodData.quantity
			end
			if goodCount == 0 then
				cargoMsg = cargoMsg .. "nothing"
			end
			setCommsMessage(cargoMsg)
		end)
		if distance_diagnostic then print("distance_diagnostic 9",comms_source,comms_target) end
		if distance(comms_source,comms_target) < 5000 then
			local goodCount = 0
			if comms_source.goods ~= nil then
				for good, goodQuantity in pairs(comms_source.goods) do
					goodCount = goodCount + 1
				end
			end
			if goodCount > 0 then
				addCommsReply("Jettison cargo", function()
					setCommsMessage(string.format("Available space: %i\nWhat would you like to jettison?",comms_source.cargo))
					for good, good_quantity in pairs(comms_source.goods) do
						if good_quantity > 0 then
							addCommsReply(good, function()
								comms_source.goods[good] = comms_source.goods[good] - 1
								comms_source.cargo = comms_source.cargo + 1
								setCommsMessage(string.format("One %s jettisoned",good))
								addCommsReply("Back", commsShip)
							end)
						end
					end
					addCommsReply("Back", commsShip)
				end)
			end
			if comms_source.cargo > 0 then
				if comms_data.friendlyness > 66 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost)), function()
									if comms_source:takeReputationPoints(goodData.cost) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					else
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*2)), function()
									if comms_source:takeReputationPoints(goodData.cost*2) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					end
				elseif comms_data.friendlyness > 33 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*2)), function()
									if comms_source:takeReputationPoints(goodData.cost*2) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					else
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*3)), function()
									if comms_source:takeReputationPoints(goodData.cost*3) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					end
				else	--least friendly
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*3)), function()
									if comms_source:takeReputationPoints(goodData.cost*3) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					end
				end	--end friendly branches
			end	--player has room for cargo
		end	--close enough to sell
	else	--not a freighter
		if comms_data.friendlyness > 50 then
			setCommsMessage("Sorry, we have no time to chat with you.\nWe are on an important mission.");
		else
			setCommsMessage("We have nothing for you.\nGood day.");
		end
	end	--end non-freighter communications else branch
	return true
end	--end neutral communications function
-----------------------
-- Utility functions --
-----------------------
function tableRemoveRandom(array)
--	Remove random element from array and return it.
	-- Returns nil if the array is empty,
	-- analogous to `table.remove`.
    local array_item_count = #array
    if array_item_count == 0 then
        return nil
    end
    local selected_item = math.random(array_item_count)
    array[selected_item], array[array_item_count] = array[array_item_count], array[selected_item]
    return table.remove(array)
end
function placeRandomAsteroidsAroundPoint(amount, dist_min, dist_max, x0, y0)
-- create amount of asteroid, at a distance between dist_min and dist_max around the point (x0, y0)
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance
        local asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
        Asteroid():setPosition(x, y):setSize(asteroid_size)
    end
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
	startArc = (startArc + 270) % 360
	endArcClockwise = (endArcClockwise + 270) % 360
	local object_list = {}
	local arcLen = endArcClockwise - startArc
	if startArc > endArcClockwise then
		endArcClockwise = endArcClockwise + 360
		arcLen = arcLen + 360
	end
	if amount > arcLen then
		for ndex=1,arcLen do
			local radialPoint = startArc+ndex
			local pointDist = distance + random(-randomize,randomize)
			table.insert(object_list,object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist))
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			table.insert(object_list,object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist))
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			table.insert(object_list,object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist))
		end
	end
	return object_list
end
function createRandomAsteroidAlongArc(amount, x, y, distance, startArc, endArcClockwise, randomize)
-- Create amount of asteroids along arc
-- Center defined by x and y
-- Radius defined by distance
-- Start of arc between 0 and 360 (startArc), end arc: endArcClockwise
-- Use randomize to vary the distance from the center point. Omit to keep distance constant
-- Example:
--   createRandomAsteroidAlongArc(100, 500, 3000, 65, 120, 450)
	if randomize == nil then randomize = 0 end
	if amount == nil then amount = 1 end
	local arcLen = endArcClockwise - startArc
	if startArc > endArcClockwise then
		endArcClockwise = endArcClockwise + 360
		arcLen = arcLen + 360
	end
    local asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
	if amount > arcLen then
		for ndex=1,arcLen do
			local radialPoint = startArc+ndex
			local pointDist = distance + random(-randomize,randomize)
		    asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
		    asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
		    asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
		end
	end
end
function placeRandomListAroundPoint(object_type, amount, dist_min, dist_max, x0, y0)
-- create amount of object_type, at a distance between dist_min and dist_max around the point (x0, y0) 
-- save in a list that is returned to caller
	local object_list = {}
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance
        table.insert(object_list,object_type():setPosition(x, y))
    end
    return object_list
end
function closestPlayerTo(obj)
-- Return the player ship closest to passed object parameter
-- Return nil if no valid result
-- Assumes a maximum of 8 player ships
	if obj ~= nil and obj:isValid() then
		local closestDistance = 9999999
		local closestPlayer = nil
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if distance_diagnostic then print("distance_diagnostic 10",p,obj) end
				local currentDistance = distance(p,obj)
				if currentDistance < closestDistance then
					closestPlayer = p
					closestDistance = currentDistance
				end
			end
		end
		return closestPlayer
	else
		return nil
	end
end
function nearStations(nobj, compareStationList)
--nobj = named object for comparison purposes (stations, players, etc)
--compareStationList = list of stations to compare against
	local remainingStations = {}
	local closestDistance = 9999999
	for ri, obj in ipairs(compareStationList) do
		if obj ~= nil and obj:isValid() and obj:getCallSign() ~= nobj:getCallSign() then
			table.insert(remainingStations,obj)
			if distance_diagnostic then print("distance_diagnostic 11",nobj,obj) end
			local currentDistance = distance(nobj, obj)
			if currentDistance < closestDistance then
				closestObj = obj
				closestDistance = currentDistance
			end
		end
	end
	for i=1,#remainingStations do
		if remainingStations[i]:getCallSign() == closestObj:getCallSign() then
			table.remove(remainingStations,i)
			break
		end
	end
	return closestObj, remainingStations
end
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction, enemyStrength, template_pool, shape, spawn_distance, spawn_angle, px, py)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	if enemyStrength == nil then
		enemyStrength = math.max(danger * difficulty * playerPower(),5)
	end
	local enemy_position = 0
	local sp = irandom(400,900)			--random spacing of spawned group
	if shape == nil then
		shape = "square"
		if random(1,100) < 50 then
			shape = "hexagonal"
		end
	end
	local enemyList = {}
	if template_pool == nil then
		template_pool_size = 10
		template_pool = getTemplatePool(enemyStrength)
	end
	if #template_pool < 1 then
		addGMMessage("Empty Template pool: fix excludes or other criteria")
		return enemyList
	end
	local prefix = generateCallSignPrefix(1)
	while enemyStrength > 0 do
		local selected_template = template_pool[math.random(1,#template_pool)]
--		print("selected template:",selected_template,"template pool:",template_pool,"ship template:",ship_template)
		local ship = ship_template[selected_template].create(enemyFaction,selected_template)
		enemy_position = enemy_position + 1
		if shape == "none" or shape == "pyramid" or shape == "ambush" then
			ship:setPosition(xOrigin,yOrigin)
		else
			ship:setPosition(xOrigin + formation_delta[shape].x[enemy_position] * sp, yOrigin + formation_delta[shape].y[enemy_position] * sp)
		end
		ship:setCommsScript(""):setCommsFunction(commsShip)
		table.insert(enemyList, ship)
		ship:setCallSign(generateCallSign(nil,enemyFaction))
		enemyStrength = enemyStrength - ship_template[selected_template].strength
	end
	if shape == "pyramid" then
		if spawn_distance == nil then
			spawn_distance = 30
		end
		if spawn_angle == nil then
			spawn_angle = random(0,360)
		end
		if px == nil then
			px = 0
		end
		if py == nil then
			py = 0
		end
		local pyramid_tier = math.min(#enemyList,max_pyramid_tier)
		for index, ship in ipairs(enemyList) do
			if index <= max_pyramid_tier then
				local pyramid_angle = spawn_angle + formation_delta.pyramid[pyramid_tier][index].angle
				if pyramid_angle < 0 then 
					pyramid_angle = pyramid_angle + 360
				end
				pyramid_angle = pyramid_angle % 360
				rx, ry = vectorFromAngle(pyramid_angle,spawn_distance*1000 + formation_delta.pyramid[pyramid_tier][index].distance * 800)
				ship:setPosition(px+rx,py+ry)
			else
				ship:setPosition(px+vx,py+vy)
			end
			ship:setHeading((spawn_angle + 270) % 360)
			ship:orderFlyTowards(px,py)
		end
	end
	if shape == "ambush" then
		if spawn_distance == nil then
			spawn_distance = 5
		end
		if spawn_angle == nil then
			spawn_angle = random(0,360)
		end
		local circle_increment = 360/#enemyList
		for _, enemy in ipairs(enemyList) do
			local dex, dey = vectorFromAngle(spawn_angle,spawn_distance*1000)
			enemy:setPosition(xOrigin+dex,yOrigin+dey):setRotation(spawn_angle+180)
			spawn_angle = spawn_angle + circle_increment
		end
	end
	return enemyList
end
function getTemplatePool(max_strength)
	local function getStrengthSort(tbl, sortFunction)
		local keys = {}
		for key in pairs(tbl) do
			table.insert(keys,key)
		end
		table.sort(keys, function(a,b)
			return sortFunction(tbl[a], tbl[b])
		end)
		return keys
	end
	local ship_template_by_strength = getStrengthSort(ship_template, function(a,b)
		return a.strength > b.strength
	end)
	local template_pool = {}
	if pool_selectivity == "less/heavy" then
		for _, current_ship_template in ipairs(ship_template_by_strength) do
			if ship_template[current_ship_template].strength <= max_strength then
				table.insert(template_pool,current_ship_template)
			end
			if #template_pool >= template_pool_size then
				break
			end
		end
	elseif pool_selectivity == "more/light" then
		for i=#ship_template_by_strength,1,-1 do
			local current_ship_template = ship_template_by_strength[i]
			if ship_template[current_ship_template].strength <= max_strength then
				table.insert(template_pool,current_ship_template)
			end
			if #template_pool >= template_pool_size then
				break
			end
		end
	else	--full
		for current_ship_template, details in pairs(ship_template) do
--			print("current ship template",current_ship_template,"details",details,"max strength:",max_strength)
			if details.strength <= max_strength then
				table.insert(template_pool,current_ship_template)
			end
		end
	end
	return template_pool
end
function playerPower()
--evaluate the players for enemy strength and size spawning purposes
	local playerShipScore = 0
	for p5idx=1,32 do
		local p5obj = getPlayerShip(p5idx)
		if p5obj ~= nil and p5obj:isValid() then
			if p5obj.shipScore == nil then
				playerShipScore = playerShipScore + 24
			else
				playerShipScore = playerShipScore + p5obj.shipScore
			end
		end
	end
	return playerShipScore
end
function setPlayers()
--set up players with name, goods, cargo space, reputation and either a warp drive or a jump drive if applicable
	local active_player_count = 0
	for p1idx=1,32 do
		pobj = getPlayerShip(p1idx)
		if pobj ~= nil and pobj:isValid() then
			active_player_count = active_player_count + 1
			if pobj.goods == nil then
				pobj.goods = {}
			end
			if pobj.initialRep == nil then
				pobj:addReputationPoints(500-(difficulty*20))
				pobj.initialRep = true
			end
			if not pobj.nameAssigned then
				pobj.nameAssigned = true
				local tempPlayerType = pobj:getTypeName()
				pobj.shipScore = playerShipStats[tempPlayerType].strength
				pobj.maxCargo = playerShipStats[tempPlayerType].cargo
				pobj:setLongRangeRadarRange(playerShipStats[tempPlayerType].long_range_radar)
				pobj:setShortRangeRadarRange(playerShipStats[tempPlayerType].short_range_radar)
				pobj.tractor = playerShipStats[tempPlayerType].tractor
				pobj.mining = playerShipStats[tempPlayerType].mining
				pobj.mining_target_lock = false
				pobj.mining_in_progress = false
				if tempPlayerType == "MP52 Hornet" then
					if #playerShipNamesFor["MP52Hornet"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["MP52Hornet"]))
					end
					pobj.autoCoolant = false
					pobj:setWarpDrive(true)
				elseif tempPlayerType == "Piranha" then
					if #playerShipNamesFor["Piranha"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Piranha"]))
					end
				elseif tempPlayerType == "Flavia P.Falcon" then
					if #playerShipNamesFor["FlaviaPFalcon"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["FlaviaPFalcon"]))
					end
				elseif tempPlayerType == "Phobos M3P" then
					if #playerShipNamesFor["PhobosM3P"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["PhobosM3P"]))
					end
					pobj:setWarpDrive(true)
					pobj:setWarpSpeed(500)
				elseif tempPlayerType == "Atlantis" then
					if #playerShipNamesFor["Atlantis"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Atlantis"]))
					end
				elseif tempPlayerType == "Player Cruiser" then
					if #playerShipNamesFor["Cruiser"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Cruiser"]))
					end
				elseif tempPlayerType == "Player Missile Cr." then
					if #playerShipNamesFor["MissileCruiser"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["MissileCruiser"]))
					end
				elseif tempPlayerType == "Player Fighter" then
					if #playerShipNamesFor["Fighter"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Fighter"]))
					end
					pobj.autoCoolant = false
					pobj:setJumpDrive(true)
					pobj.max_jump_range = 40000
					pobj.min_jump_range = 3000
					pobj:setJumpDriveRange(pobj.min_jump_range,pobj.max_jump_range)
					pobj:setJumpDriveCharge(pobj.max_jump_range)
				elseif tempPlayerType == "Benedict" then
					if #playerShipNamesFor["Benedict"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Benedict"]))
					end
				elseif tempPlayerType == "Kiriya" then
					if #playerShipNamesFor["Kiriya"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Kiriya"]))
					end
				elseif tempPlayerType == "Striker" then
					if #playerShipNamesFor["Striker"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Striker"]))
					end
					if pobj:getImpulseMaxSpeed() == 45 then
						pobj:setImpulseMaxSpeed(90)
					end
					if pobj:getBeamWeaponCycleTime(0) == 6 then
						local bi = 0
						repeat
							local tempArc = pobj:getBeamWeaponArc(bi)
							local tempDir = pobj:getBeamWeaponDirection(bi)
							local tempRng = pobj:getBeamWeaponRange(bi)
							local tempDmg = pobj:getBeamWeaponDamage(bi)
							pobj:setBeamWeapon(bi,tempArc,tempDir,tempRng,5,tempDmg)
							bi = bi + 1
						until(pobj:getBeamWeaponRange(bi) < 1)
					end
					pobj:setJumpDrive(true)
					pobj.max_jump_range = 40000
					pobj.min_jump_range = 3000
					pobj:setJumpDriveRange(pobj.min_jump_range,pobj.max_jump_range)
					pobj:setJumpDriveCharge(pobj.max_jump_range)
				elseif tempPlayerType == "ZX-Lindworm" then
					if #playerShipNamesFor["Lindworm"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Lindworm"]))
					end
					pobj.autoCoolant = false
					pobj:setWarpDrive(true)
				elseif tempPlayerType == "Repulse" then
					if #playerShipNamesFor["Repulse"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Repulse"]))
					end
				elseif tempPlayerType == "Ender" then
					if #playerShipNamesFor["Ender"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Ender"]))
					end
				elseif tempPlayerType == "Nautilus" then
					if #playerShipNamesFor["Nautilus"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Nautilus"]))
					end
				elseif tempPlayerType == "Hathcock" then
					if #playerShipNamesFor["Hathcock"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Hathcock"]))
					end
				elseif tempPlayerType == "Proto-Atlantis" then
					if #playerShipNamesFor["ProtoAtlantis"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["ProtoAtlantis"]))
					end
				elseif tempPlayerType == "Maverick" then
					if #playerShipNamesFor["Maverick"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Maverick"]))
					end
				elseif tempPlayerType == "Crucible" then
					if #playerShipNamesFor["Crucible"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Crucible"]))
					end
				elseif tempPlayerType == "Atlantis II" then
					if #playerShipNamesFor["AtlantisII"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["AtlantisII"]))
					end
				elseif tempPlayerType == "Surkov" then
					if #playerShipNamesFor["Surkov"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Surkov"]))
					end
				elseif tempPlayerType == "Stricken" then
					if #playerShipNamesFor["Stricken"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Stricken"]))
					end
				elseif tempPlayerType == "Redhook" then
					if #playerShipNamesFor["Redhook"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Redhook"]))
					end
				elseif tempPlayerType == "Destroyer III" then
					if #playerShipNamesFor["DestroyerIII"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["DestroyerIII"]))
					end
				else
					if #playerShipNamesFor["Leftovers"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Leftovers"]))
					end
					pobj.shipScore = 24
					pobj.maxCargo = 5
					pobj:setWarpDrive(true)
					pobj:setWarpSpeed(500)
					pobj:setLongRangeRadarRange(30000)
					pobj:setShortRangeRadarRange(5000)
					pobj.tractor = false
					pobj.mining = false
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
					if pobj:getBeamWeaponRange(0) > 0 then
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
				if pobj:hasJumpDrive() then
					if pobj.max_jump_range == nil then
						pobj.max_jump_range = 50000
						pobj.min_jump_range = 5000
					end
				end
			end
			pobj.initialCoolant = pobj:getMaxCoolant()
		end
	end
end

--		Mortal repair crew functions. Includes coolant loss as option to losing repair crew
function healthCheck(delta)
	healthCheckTimer = healthCheckTimer - delta
	if healthCheckTimer < 0 then
		if healthDiagnostic then print("health check timer expired") end
		for pidx=1,32 do
			if healthDiagnostic then print("in player loop") end
			local p = getPlayerShip(pidx)
			if healthDiagnostic then print("got player ship") end
			if p ~= nil and p:isValid() then
				if healthDiagnostic then print("valid ship") end
				if p:getRepairCrewCount() > 0 then
					if healthDiagnostic then print("crew on valid ship") end
					local fatalityChance = 0
					if healthDiagnostic then print("shields") end
					sc = p:getShieldCount()
					if healthDiagnostic then print("sc: " .. sc) end
					if p:getShieldCount() > 1 then
						cShield = (p:getSystemHealth("frontshield") + p:getSystemHealth("rearshield"))/2
					else
						cShield = p:getSystemHealth("frontshield")
					end
					fatalityChance = fatalityChance + (p.prevShield - cShield)
					p.prevShield = cShield
					if healthDiagnostic then print("reactor") end
					fatalityChance = fatalityChance + (p.prevReactor - p:getSystemHealth("reactor"))
					p.prevReactor = p:getSystemHealth("reactor")
					if healthDiagnostic then print("maneuver") end
					fatalityChance = fatalityChance + (p.prevManeuver - p:getSystemHealth("maneuver"))
					p.prevManeuver = p:getSystemHealth("maneuver")
					if healthDiagnostic then print("impulse") end
					fatalityChance = fatalityChance + (p.prevImpulse - p:getSystemHealth("impulse"))
					p.prevImpulse = p:getSystemHealth("impulse")
					if healthDiagnostic then print("beamweapons") end
					if p:getBeamWeaponRange(0) > 0 then
						if p.healthyBeam == nil then
							p.healthyBeam = 1.0
							p.prevBeam = 1.0
						end
						fatalityChance = fatalityChance + (p.prevBeam - p:getSystemHealth("beamweapons"))
						p.prevBeam = p:getSystemHealth("beamweapons")
					end
					if healthDiagnostic then print("missilesystem") end
					if p:getWeaponTubeCount() > 0 then
						if p.healthyMissile == nil then
							p.healthyMissile = 1.0
							p.prevMissile = 1.0
						end
						fatalityChance = fatalityChance + (p.prevMissile - p:getSystemHealth("missilesystem"))
						p.prevMissile = p:getSystemHealth("missilesystem")
					end
					if healthDiagnostic then print("warp") end
					if p:hasWarpDrive() then
						if p.healthyWarp == nil then
							p.healthyWarp = 1.0
							p.prevWarp = 1.0
						end
						fatalityChance = fatalityChance + (p.prevWarp - p:getSystemHealth("warp"))
						p.prevWarp = p:getSystemHealth("warp")
					end
					if healthDiagnostic then print("jumpdrive") end
					if p:hasJumpDrive() then
						if p.healthyJump == nil then
							p.healthyJump = 1.0
							p.prevJump = 1.0
						end
						fatalityChance = fatalityChance + (p.prevJump - p:getSystemHealth("jumpdrive"))
						p.prevJump = p:getSystemHealth("jumpdrive")
					end
					if healthDiagnostic then print("adjust") end
					if p:getRepairCrewCount() == 1 then
						fatalityChance = fatalityChance/2	-- increase chances of last repair crew standing
					end
					if healthDiagnostic then print("check") end
					if fatalityChance > 0 then
						crewFate(p,fatalityChance)
					end
				else	--no repair crew left
					if random(1,100) <= (4 - difficulty) then
						p:setRepairCrewCount(1)
						if p:hasPlayerAtPosition("Engineering") then
							local repairCrewRecovery = "repairCrewRecovery"
							p:addCustomMessage("Engineering",repairCrewRecovery,"Medical team has revived one of your repair crew")
						end
						if p:hasPlayerAtPosition("Engineering+") then
							local repairCrewRecoveryPlus = "repairCrewRecoveryPlus"
							p:addCustomMessage("Engineering+",repairCrewRecoveryPlus,"Medical team has revived one of your repair crew")
						end
						resetPreviousSystemHealth(p)
					end
				end
				if p.initialCoolant ~= nil then
					local current_coolant = p:getMaxCoolant()
					if current_coolant < 20 then
						if random(1,100) <= 4 then
							local reclaimed_coolant = 0
							if p.reclaimable_coolant ~= nil and p.reclaimable_coolant > 0 then
								reclaimed_coolant = p.reclaimable_coolant*random(.1,.5)	--get back 10 to 50 percent of reclaimable coolant
								p:setMaxCoolant(math.min(20,current_coolant + reclaimed_coolant))
								p.reclaimable_coolant = p.reclaimable_coolant - reclaimed_coolant
							end
							local noticable_reclaimed_coolant = math.floor(reclaimed_coolant)
							if noticable_reclaimed_coolant > 0 then
								if p:hasPlayerAtPosition("Engineering") then
									p:addCustomMessage("Engineering","coolant_recovery","Automated systems have recovered some coolant")
								end
								if p:hasPlayerAtPosition("Engineering+") then
									p:addCustomMessage("Engineering+","coolant_recovery_plus","Automated systems have recovered some coolant")
								end
							end
							resetPreviousSystemHealth(p)
						end
					end
				end
			end
		end
		healthCheckTimer = delta + healthCheckTimerInterval
		local stat_list = gatherStats()
		local eval_status = string.format("F:%.1f%% E:%.1f%% D:%.1f%%",stat_list.human.evaluation,stat_list.kraylor.evaluation,stat_list.human.evaluation-stat_list.kraylor.evaluation)
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p:hasPlayerAtPosition("Relay") then
					p.eval_status = "eval_status"
					p:addCustomInfo("Relay",p.eval_status,eval_status)
				end
				if p:hasPlayerAtPosition("Operations") then
					p.eval_status_operations = "eval_status_operations"
					p:addCustomInfo("Operations",p.eval_status_operations,eval_status)
				end
			end
		end
	end
end
function resetPreviousSystemHealth(p)
	if p:getShieldCount() > 1 then
		p.prevShield = (p:getSystemHealth("frontshield") + p:getSystemHealth("rearshield"))/2
	else
		p.prevShield = p:getSystemHealth("frontshield")
	end
	p.prevReactor = p:getSystemHealth("reactor")
	p.prevManeuver = p:getSystemHealth("maneuver")
	p.prevImpulse = p:getSystemHealth("impulse")
	if p:getBeamWeaponRange(0) > 0 then
		p.prevBeam = p:getSystemHealth("beamweapons")
	end
	if p:getWeaponTubeCount() > 0 then
		p.prevMissile = p:getSystemHealth("missilesystem")
	end
	if p:hasWarpDrive() then
		p.prevWarp = p:getSystemHealth("warp")
	end
	if p:hasJumpDrive() then
		p.prevJump = p:getSystemHealth("jumpdrive")
	end
end
function crewFate(p, fatalityChance)
	if math.random() < (fatalityChance) then
		if p.initialCoolant == nil then
			p:setRepairCrewCount(p:getRepairCrewCount() - 1)
			if p:hasPlayerAtPosition("Engineering") then
				local repairCrewFatality = "repairCrewFatality"
				p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
			end
			if p:hasPlayerAtPosition("Engineering+") then
				local repairCrewFatalityPlus = "repairCrewFatalityPlus"
				p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
			end
		else
			local consequence = 0
			local upper_consequence = 2
			local consequence_list = {}
			if p:getCanLaunchProbe() then
				upper_consequence = upper_consequence + 1
				table.insert(consequence_list,"probe")
			end
			if p:getCanHack() then
				upper_consequence = upper_consequence + 1
				table.insert(consequence_list,"hack")
			end
			if p:getCanScan() then
				upper_consequence = upper_consequence + 1
				table.insert(consequence_list,"scan")
			end
			if p:getCanCombatManeuver() then
				upper_consequence = upper_consequence + 1
				table.insert(consequence_list,"combat_maneuver")
			end
			if p:getCanSelfDestruct() then
				upper_consequence = upper_consequence + 1
				table.insert(consequence_list,"self_destruct")
			end
			consequence = math.random(1,upper_consequence)
			if consequence == 1 then
				p:setRepairCrewCount(p:getRepairCrewCount() - 1)
				if p:hasPlayerAtPosition("Engineering") then
					local repairCrewFatality = "repairCrewFatality"
					p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local repairCrewFatalityPlus = "repairCrewFatalityPlus"
					p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
				end
			elseif consequence == 2 then
				local current_coolant = p:getMaxCoolant()
				local lost_coolant = 0
				if current_coolant >= 10 then
					lost_coolant = current_coolant*random(.25,.5)	--lose between 25 and 50 percent
				else
					lost_coolant = current_coolant*random(.15,.35)	--lose between 15 and 35 percent
				end
				p:setMaxCoolant(current_coolant - lost_coolant)
				if p.reclaimable_coolant == nil then
					p.reclaimable_coolant = 0
				end
				p.reclaimable_coolant = math.min(20,p.reclaimable_coolant + lost_coolant*random(.8,1))
				if p:hasPlayerAtPosition("Engineering") then
					local coolantLoss = "coolantLoss"
					p:addCustomMessage("Engineering",coolantLoss,"Damage has caused a loss of coolant")
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local coolantLossPlus = "coolantLossPlus"
					p:addCustomMessage("Engineering+",coolantLossPlus,"Damage has caused a loss of coolant")
				end
			else
				local named_consequence = consequence_list[consequence-2]
				if named_consequence == "probe" then
					p:setCanLaunchProbe(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","probe_launch_damage_message","The probe launch system has been damaged")
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","probe_launch_damage_message_plus","The probe launch system has been damaged")
					end
				elseif named_consequence == "hack" then
					p:setCanHack(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","hack_damage_message","The hacking system has been damaged")
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","hack_damage_message_plus","The hacking system has been damaged")
					end
				elseif named_consequence == "scan" then
					p:setCanScan(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","scan_damage_message","The scanners have been damaged")
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","scan_damage_message_plus","The scanners have been damaged")
					end
				elseif named_consequence == "combat_maneuver" then
					p:setCanCombatManeuver(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","combat_maneuver_damage_message","Combat maneuver has been damaged")
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","combat_maneuver_damage_message_plus","Combat maneuver has been damaged")
					end
				elseif named_consequence == "self_destruct" then
					p:setCanSelfDestruct(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","self_destruct_damage_message","Self destruct system has been damaged")
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","self_destruct_damage_message_plus","Self destruct system has been damaged")
					end
				end
			end	--coolant loss branch
		end
	end
end
--      Inventory button and functions for relay/operations 
function cargoInventory(delta)
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			local cargoHoldEmpty = true
			if p.goods ~= nil then
				for good, quantity in pairs(p.goods) do
					if quantity ~= nil and quantity > 0 then
						cargoHoldEmpty = false
						break
					end
				end
			end
			if not cargoHoldEmpty then
				if p:hasPlayerAtPosition("Relay") then
					if p.inventoryButton == nil then
						local tbi = "inventory" .. p:getCallSign()
						p:addCustomButton("Relay",tbi,"Inventory",function() playerShipCargoInventory(p) end)
						p.inventoryButton = true
					end
				end
				if p:hasPlayerAtPosition("Operations") then
					if p.inventoryButton == nil then
						local tbi = "inventoryOp" .. p:getCallSign()
						p:addCustomButton("Operations",tbi,"Inventory",function() playerShipCargoInventory(p) end)
						p.inventoryButton = true
					end
				end
			end
		end
	end
end
function playerShipCargoInventory(p)
	p:addToShipLog(string.format("%s Current cargo:",p:getCallSign()),"Yellow")
	local goodCount = 0
	if p.goods ~= nil then
		for good, goodQuantity in pairs(p.goods) do
			goodCount = goodCount + 1
			p:addToShipLog(string.format("     %s: %i",good,goodQuantity),"Yellow")
		end
	end
	if goodCount < 1 then
		p:addToShipLog("     Empty","Yellow")
	end
	p:addToShipLog(string.format("Available space: %i",p.cargo),"Yellow")
end
--		Generate call sign functions
function generateCallSign(prefix,faction)
	if faction == nil then
		if prefix == nil then
			prefix = generateCallSignPrefix()
		end
	else
		if prefix == nil then
			prefix = getFactionPrefix(faction)
		else
			prefix = string.format("%s %s",getFactionPrefix(faction),prefix)
		end
	end
	suffix_index = suffix_index + math.random(1,3)
	if suffix_index > 999 then 
		suffix_index = 1
	end
	return string.format("%s%i",prefix,suffix_index)
end
function generateCallSignPrefix(length)
	if call_sign_prefix_pool == nil then
		call_sign_prefix_pool = {}
		prefix_length = prefix_length + 1
		if prefix_length > 3 then
			prefix_length = 1
		end
		fillPrefixPool()
	end
	if length == nil then
		length = prefix_length
	end
	local prefix_index = 0
	local prefix = ""
	for i=1,length do
		if #call_sign_prefix_pool < 1 then
			fillPrefixPool()
		end
		prefix_index = math.random(1,#call_sign_prefix_pool)
		prefix = prefix .. call_sign_prefix_pool[prefix_index]
		table.remove(call_sign_prefix_pool,prefix_index)
	end
	return prefix
end
function fillPrefixPool()
	for i=1,26 do
		table.insert(call_sign_prefix_pool,string.char(i+64))
	end
end
function getFactionPrefix(faction)
	local faction_prefix = nil
	if faction == "Kraylor" then
		if kraylor_names == nil then
			setKraylorNames()
		else
			if #kraylor_names < 1 then
				setKraylorNames()
			end
		end
		local kraylor_name_choice = math.random(1,#kraylor_names)
		faction_prefix = kraylor_names[kraylor_name_choice]
		table.remove(kraylor_names,kraylor_name_choice)
	end
	if faction == "Exuari" then
		if exuari_names == nil then
			setExuariNames()
		else
			if #exuari_names < 1 then
				setExuariNames()
			end
		end
		local exuari_name_choice = math.random(1,#exuari_names)
		faction_prefix = exuari_names[exuari_name_choice]
		table.remove(exuari_names,exuari_name_choice)
	end
	if faction == "Ghosts" then
		if ghosts_names == nil then
			setGhostsNames()
		else
			if #ghosts_names < 1 then
				setGhostsNames()
			end
		end
		local ghosts_name_choice = math.random(1,#ghosts_names)
		faction_prefix = ghosts_names[ghosts_name_choice]
		table.remove(ghosts_names,ghosts_name_choice)
	end
	if faction == "Independent" then
		if independent_names == nil then
			setIndependentNames()
		else
			if #independent_names < 1 then
				setIndependentNames()
			end
		end
		local independent_name_choice = math.random(1,#independent_names)
		faction_prefix = independent_names[independent_name_choice]
		table.remove(independent_names,independent_name_choice)
	end
	if faction == "Human Navy" then
		if human_names == nil then
			setHumanNames()
		else
			if #human_names < 1 then
				setHumanNames()
			end
		end
		local human_name_choice = math.random(1,#human_names)
		faction_prefix = human_names[human_name_choice]
		table.remove(human_names,human_name_choice)
	end
	if faction_prefix == nil then
		faction_prefix = generateCallSignPrefix()
	end
	return faction_prefix
end
function setGhostsNames()
	ghosts_names = {}
	table.insert(ghosts_names,"Abstract")
	table.insert(ghosts_names,"Ada")
	table.insert(ghosts_names,"Assemble")
	table.insert(ghosts_names,"Assert")
	table.insert(ghosts_names,"Backup")
	table.insert(ghosts_names,"BASIC")
	table.insert(ghosts_names,"Big Iron")
	table.insert(ghosts_names,"BigEndian")
	table.insert(ghosts_names,"Binary")
	table.insert(ghosts_names,"Bit")
	table.insert(ghosts_names,"Block")
	table.insert(ghosts_names,"Boot")
	table.insert(ghosts_names,"Branch")
	table.insert(ghosts_names,"BTree")
	table.insert(ghosts_names,"Bubble")
	table.insert(ghosts_names,"Byte")
	table.insert(ghosts_names,"Capacitor")
	table.insert(ghosts_names,"Case")
	table.insert(ghosts_names,"Chad")
	table.insert(ghosts_names,"Charge")
	table.insert(ghosts_names,"COBOL")
	table.insert(ghosts_names,"Collate")
	table.insert(ghosts_names,"Compile")
	table.insert(ghosts_names,"Control")
	table.insert(ghosts_names,"Construct")
	table.insert(ghosts_names,"Cycle")
	table.insert(ghosts_names,"Data")
	table.insert(ghosts_names,"Debug")
	table.insert(ghosts_names,"Decimal")
	table.insert(ghosts_names,"Decision")
	table.insert(ghosts_names,"Default")
	table.insert(ghosts_names,"DIMM")
	table.insert(ghosts_names,"Displacement")
	table.insert(ghosts_names,"Edge")
	table.insert(ghosts_names,"Exit")
	table.insert(ghosts_names,"Factor")
	table.insert(ghosts_names,"Flag")
	table.insert(ghosts_names,"Float")
	table.insert(ghosts_names,"Flow")
	table.insert(ghosts_names,"FORTRAN")
	table.insert(ghosts_names,"Fullword")
	table.insert(ghosts_names,"GIGO")
	table.insert(ghosts_names,"Graph")
	table.insert(ghosts_names,"Hack")
	table.insert(ghosts_names,"Hash")
	table.insert(ghosts_names,"Halfword")
	table.insert(ghosts_names,"Hertz")
	table.insert(ghosts_names,"Hexadecimal")
	table.insert(ghosts_names,"Indicator")
	table.insert(ghosts_names,"Initialize")
	table.insert(ghosts_names,"Integer")
	table.insert(ghosts_names,"Integrate")
	table.insert(ghosts_names,"Interrupt")
	table.insert(ghosts_names,"Java")
	table.insert(ghosts_names,"Lisp")
	table.insert(ghosts_names,"List")
	table.insert(ghosts_names,"Logic")
	table.insert(ghosts_names,"Loop")
	table.insert(ghosts_names,"Lua")
	table.insert(ghosts_names,"Magnetic")
	table.insert(ghosts_names,"Mask")
	table.insert(ghosts_names,"Memory")
	table.insert(ghosts_names,"Mnemonic")
	table.insert(ghosts_names,"Micro")
	table.insert(ghosts_names,"Model")
	table.insert(ghosts_names,"Nibble")
	table.insert(ghosts_names,"Octal")
	table.insert(ghosts_names,"Order")
	table.insert(ghosts_names,"Operator")
	table.insert(ghosts_names,"Parameter")
	table.insert(ghosts_names,"Pascal")
	table.insert(ghosts_names,"Pattern")
	table.insert(ghosts_names,"Pixel")
	table.insert(ghosts_names,"Point")
	table.insert(ghosts_names,"Polygon")
	table.insert(ghosts_names,"Port")
	table.insert(ghosts_names,"Process")
	table.insert(ghosts_names,"RAM")
	table.insert(ghosts_names,"Raster")
	table.insert(ghosts_names,"Rate")
	table.insert(ghosts_names,"Redundant")
	table.insert(ghosts_names,"Reference")
	table.insert(ghosts_names,"Refresh")
	table.insert(ghosts_names,"Register")
	table.insert(ghosts_names,"Resistor")
	table.insert(ghosts_names,"ROM")
	table.insert(ghosts_names,"Routine")
	table.insert(ghosts_names,"Ruby")
	table.insert(ghosts_names,"SAAS")
	table.insert(ghosts_names,"Sequence")
	table.insert(ghosts_names,"Share")
	table.insert(ghosts_names,"Silicon")
	table.insert(ghosts_names,"SIMM")
	table.insert(ghosts_names,"Socket")
	table.insert(ghosts_names,"Sort")
	table.insert(ghosts_names,"Structure")
	table.insert(ghosts_names,"Switch")
	table.insert(ghosts_names,"Symbol")
	table.insert(ghosts_names,"Trace")
	table.insert(ghosts_names,"Transistor")
	table.insert(ghosts_names,"Value")
	table.insert(ghosts_names,"Vector")
	table.insert(ghosts_names,"Version")
	table.insert(ghosts_names,"View")
	table.insert(ghosts_names,"WYSIWYG")
	table.insert(ghosts_names,"XOR")
end
function setExuariNames()
	exuari_names = {}
	table.insert(exuari_names,"Astonester")
	table.insert(exuari_names,"Ametripox")
	table.insert(exuari_names,"Bakeltevex")
	table.insert(exuari_names,"Baropledax")
	table.insert(exuari_names,"Batongomox")
	table.insert(exuari_names,"Bekilvimix")
	table.insert(exuari_names,"Benoglopok")
	table.insert(exuari_names,"Bilontipur")
	table.insert(exuari_names,"Bolictimik")
	table.insert(exuari_names,"Bomagralax")
	table.insert(exuari_names,"Buteldefex")
	table.insert(exuari_names,"Catondinab")
	table.insert(exuari_names,"Chatorlonox")
	table.insert(exuari_names,"Culagromik")
	table.insert(exuari_names,"Dakimbinix")
	table.insert(exuari_names,"Degintalix")
	table.insert(exuari_names,"Dimabratax")
	table.insert(exuari_names,"Dokintifix")
	table.insert(exuari_names,"Dotandirex")
	table.insert(exuari_names,"Dupalgawax")
	table.insert(exuari_names,"Ekoftupex")
	table.insert(exuari_names,"Elidranov")
	table.insert(exuari_names,"Fakobrovox")
	table.insert(exuari_names,"Femoplabix")
	table.insert(exuari_names,"Fibatralax")
	table.insert(exuari_names,"Fomartoran")
	table.insert(exuari_names,"Gateldepex")
	table.insert(exuari_names,"Gamutrewal")
	table.insert(exuari_names,"Gesanterux")
	table.insert(exuari_names,"Gimardanax")
	table.insert(exuari_names,"Hamintinal")
	table.insert(exuari_names,"Holangavak")
	table.insert(exuari_names,"Igolpafik")
	table.insert(exuari_names,"Inoklomat")
	table.insert(exuari_names,"Jamewtibex")
	table.insert(exuari_names,"Jepospagox")
	table.insert(exuari_names,"Kajortonox")
	table.insert(exuari_names,"Kapogrinix")
	table.insert(exuari_names,"Kelitravax")
	table.insert(exuari_names,"Kipaldanax")
	table.insert(exuari_names,"Kodendevex")
	table.insert(exuari_names,"Kotelpedex")
	table.insert(exuari_names,"Kutandolak")
	table.insert(exuari_names,"Lakirtinix")
	table.insert(exuari_names,"Lapoldinek")
	table.insert(exuari_names,"Lavorbonox")
	table.insert(exuari_names,"Letirvinix")
	table.insert(exuari_names,"Lowibromax")
	table.insert(exuari_names,"Makintibix")
	table.insert(exuari_names,"Makorpohox")
	table.insert(exuari_names,"Matoprowox")
	table.insert(exuari_names,"Mefinketix")
	table.insert(exuari_names,"Motandobak")
	table.insert(exuari_names,"Nakustunux")
	table.insert(exuari_names,"Nequivonax")
	table.insert(exuari_names,"Nitaldavax")
	table.insert(exuari_names,"Nobaldorex")
	table.insert(exuari_names,"Obimpitix")
	table.insert(exuari_names,"Owaklanat")
	table.insert(exuari_names,"Pakendesik")
	table.insert(exuari_names,"Pazinderix")
	table.insert(exuari_names,"Pefoglamuk")
	table.insert(exuari_names,"Pekirdivix")
	table.insert(exuari_names,"Potarkadax")
	table.insert(exuari_names,"Pulendemex")
	table.insert(exuari_names,"Quatordunix")
	table.insert(exuari_names,"Rakurdumux")
	table.insert(exuari_names,"Ralombenik")
	table.insert(exuari_names,"Regosporak")
	table.insert(exuari_names,"Retordofox")
	table.insert(exuari_names,"Rikondogox")
	table.insert(exuari_names,"Rokengelex")
	table.insert(exuari_names,"Rutarkadax")
	table.insert(exuari_names,"Sakeldepex")
	table.insert(exuari_names,"Setiftimix")
	table.insert(exuari_names,"Siparkonal")
	table.insert(exuari_names,"Sopaldanax")
	table.insert(exuari_names,"Sudastulux")
	table.insert(exuari_names,"Takeftebex")
	table.insert(exuari_names,"Taliskawit")
	table.insert(exuari_names,"Tegundolex")
	table.insert(exuari_names,"Tekintipix")
	table.insert(exuari_names,"Tiposhomox")
	table.insert(exuari_names,"Tokaldapax")
	table.insert(exuari_names,"Tomuglupux")
	table.insert(exuari_names,"Tufeldepex")
	table.insert(exuari_names,"Unegremek")
	table.insert(exuari_names,"Uvendipax")
	table.insert(exuari_names,"Vatorgopox")
	table.insert(exuari_names,"Venitribix")
	table.insert(exuari_names,"Vobalterix")
	table.insert(exuari_names,"Wakintivix")
	table.insert(exuari_names,"Wapaltunix")
	table.insert(exuari_names,"Wekitrolax")
	table.insert(exuari_names,"Wofarbanax")
	table.insert(exuari_names,"Xeniplofek")
	table.insert(exuari_names,"Yamaglevik")
	table.insert(exuari_names,"Yakildivix")
	table.insert(exuari_names,"Yegomparik")
	table.insert(exuari_names,"Zapondehex")
	table.insert(exuari_names,"Zikandelat")
end
function setKraylorNames()		
	kraylor_names = {}
	table.insert(kraylor_names,"Abroten")
	table.insert(kraylor_names,"Ankwar")
	table.insert(kraylor_names,"Bakrik")
	table.insert(kraylor_names,"Belgor")
	table.insert(kraylor_names,"Benkop")
	table.insert(kraylor_names,"Blargvet")
	table.insert(kraylor_names,"Bloktarg")
	table.insert(kraylor_names,"Bortok")
	table.insert(kraylor_names,"Bredjat")
	table.insert(kraylor_names,"Chankret")
	table.insert(kraylor_names,"Chatork")
	table.insert(kraylor_names,"Chokarp")
	table.insert(kraylor_names,"Cloprak")
	table.insert(kraylor_names,"Coplek")
	table.insert(kraylor_names,"Cortek")
	table.insert(kraylor_names,"Daltok")
	table.insert(kraylor_names,"Darpik")
	table.insert(kraylor_names,"Dastek")
	table.insert(kraylor_names,"Dotark")
	table.insert(kraylor_names,"Drambok")
	table.insert(kraylor_names,"Duntarg")
	table.insert(kraylor_names,"Earklat")
	table.insert(kraylor_names,"Ekmit")
	table.insert(kraylor_names,"Fakret")
	table.insert(kraylor_names,"Fapork")
	table.insert(kraylor_names,"Fawtrik")
	table.insert(kraylor_names,"Fenturp")
	table.insert(kraylor_names,"Feplik")
	table.insert(kraylor_names,"Figront")
	table.insert(kraylor_names,"Floktrag")
	table.insert(kraylor_names,"Fonkack")
	table.insert(kraylor_names,"Fontreg")
	table.insert(kraylor_names,"Foondrap")
	table.insert(kraylor_names,"Frotwak")
	table.insert(kraylor_names,"Gastonk")
	table.insert(kraylor_names,"Gentouk")
	table.insert(kraylor_names,"Gonpruk")
	table.insert(kraylor_names,"Gortak")
	table.insert(kraylor_names,"Gronkud")
	table.insert(kraylor_names,"Hewtang")
	table.insert(kraylor_names,"Hongtag")
	table.insert(kraylor_names,"Hortook")
	table.insert(kraylor_names,"Indrut")
	table.insert(kraylor_names,"Iprant")
	table.insert(kraylor_names,"Jakblet")
	table.insert(kraylor_names,"Jonket")
	table.insert(kraylor_names,"Jontot")
	table.insert(kraylor_names,"Kandarp")
	table.insert(kraylor_names,"Kantrok")
	table.insert(kraylor_names,"Kiptak")
	table.insert(kraylor_names,"Kortrant")
	table.insert(kraylor_names,"Krontgat")
	table.insert(kraylor_names,"Lobreck")
	table.insert(kraylor_names,"Lokrant")
	table.insert(kraylor_names,"Lomprok")
	table.insert(kraylor_names,"Lutrank")
	table.insert(kraylor_names,"Makrast")
	table.insert(kraylor_names,"Moklahft")
	table.insert(kraylor_names,"Morpug")
	table.insert(kraylor_names,"Nagblat")
	table.insert(kraylor_names,"Nokrat")
	table.insert(kraylor_names,"Nomek")
	table.insert(kraylor_names,"Notark")
	table.insert(kraylor_names,"Ontrok")
	table.insert(kraylor_names,"Orkpent")
	table.insert(kraylor_names,"Peechak")
	table.insert(kraylor_names,"Plogrent")
	table.insert(kraylor_names,"Pokrint")
	table.insert(kraylor_names,"Potarg")
	table.insert(kraylor_names,"Prangtil")
	table.insert(kraylor_names,"Quagbrok")
	table.insert(kraylor_names,"Quimprill")
	table.insert(kraylor_names,"Reekront")
	table.insert(kraylor_names,"Ripkort")
	table.insert(kraylor_names,"Rokust")
	table.insert(kraylor_names,"Rontrait")
	table.insert(kraylor_names,"Saknep")
	table.insert(kraylor_names,"Sengot")
	table.insert(kraylor_names,"Skitkard")
	table.insert(kraylor_names,"Skopgrek")
	table.insert(kraylor_names,"Sletrok")
	table.insert(kraylor_names,"Slorknat")
	table.insert(kraylor_names,"Spogrunk")
	table.insert(kraylor_names,"Staklurt")
	table.insert(kraylor_names,"Stonkbrant")
	table.insert(kraylor_names,"Swaktrep")
	table.insert(kraylor_names,"Tandrok")
	table.insert(kraylor_names,"Takrost")
	table.insert(kraylor_names,"Tonkrut")
	table.insert(kraylor_names,"Torkrot")
	table.insert(kraylor_names,"Trablok")
	table.insert(kraylor_names,"Trokdin")
	table.insert(kraylor_names,"Unkelt")
	table.insert(kraylor_names,"Urjop")
	table.insert(kraylor_names,"Vankront")
	table.insert(kraylor_names,"Vintrep")
	table.insert(kraylor_names,"Volkerd")
	table.insert(kraylor_names,"Vortread")
	table.insert(kraylor_names,"Wickurt")
	table.insert(kraylor_names,"Xokbrek")
	table.insert(kraylor_names,"Yeskret")
	table.insert(kraylor_names,"Zacktrope")
end
function setIndependentNames()
	independent_names = {}
	table.insert(independent_names,"Akdroft")	--faux Kraylor
	table.insert(independent_names,"Bletnik")	--faux Kraylor
	table.insert(independent_names,"Brogfent")	--faux Kraylor
	table.insert(independent_names,"Cruflech")	--faux Kraylor
	table.insert(independent_names,"Dengtoct")	--faux Kraylor
	table.insert(independent_names,"Fiklerg")	--faux Kraylor
	table.insert(independent_names,"Groftep")	--faux Kraylor
	table.insert(independent_names,"Hinkflort")	--faux Kraylor
	table.insert(independent_names,"Irklesht")	--faux Kraylor
	table.insert(independent_names,"Jotrak")	--faux Kraylor
	table.insert(independent_names,"Kargleth")	--faux Kraylor
	table.insert(independent_names,"Lidroft")	--faux Kraylor
	table.insert(independent_names,"Movrect")	--faux Kraylor
	table.insert(independent_names,"Nitrang")	--faux Kraylor
	table.insert(independent_names,"Poklapt")	--faux Kraylor
	table.insert(independent_names,"Raknalg")	--faux Kraylor
	table.insert(independent_names,"Stovtuk")	--faux Kraylor
	table.insert(independent_names,"Trongluft")	--faux Kraylor
	table.insert(independent_names,"Vactremp")	--faux Kraylor
	table.insert(independent_names,"Wunklesp")	--faux Kraylor
	table.insert(independent_names,"Yentrilg")	--faux Kraylor
	table.insert(independent_names,"Zeltrag")	--faux Kraylor
	table.insert(independent_names,"Avoltojop")		--faux Exuari
	table.insert(independent_names,"Bimartarax")	--faux Exuari
	table.insert(independent_names,"Cidalkapax")	--faux Exuari
	table.insert(independent_names,"Darongovax")	--faux Exuari
	table.insert(independent_names,"Felistiyik")	--faux Exuari
	table.insert(independent_names,"Gopendewex")	--faux Exuari
	table.insert(independent_names,"Hakortodox")	--faux Exuari
	table.insert(independent_names,"Jemistibix")	--faux Exuari
	table.insert(independent_names,"Kilampafax")	--faux Exuari
	table.insert(independent_names,"Lokuftumux")	--faux Exuari
	table.insert(independent_names,"Mabildirix")	--faux Exuari
	table.insert(independent_names,"Notervelex")	--faux Exuari
	table.insert(independent_names,"Pekolgonex")	--faux Exuari
	table.insert(independent_names,"Rifaltabax")	--faux Exuari
	table.insert(independent_names,"Sobendeyex")	--faux Exuari
	table.insert(independent_names,"Tinaftadax")	--faux Exuari
	table.insert(independent_names,"Vadorgomax")	--faux Exuari
	table.insert(independent_names,"Wilerpejex")	--faux Exuari
	table.insert(independent_names,"Yukawvalak")	--faux Exuari
	table.insert(independent_names,"Zajiltibix")	--faux Exuari
	table.insert(independent_names,"Alter")		--faux Ghosts
	table.insert(independent_names,"Assign")	--faux Ghosts
	table.insert(independent_names,"Brain")		--faux Ghosts
	table.insert(independent_names,"Break")		--faux Ghosts
	table.insert(independent_names,"Boundary")	--faux Ghosts
	table.insert(independent_names,"Code")		--faux Ghosts
	table.insert(independent_names,"Compare")	--faux Ghosts
	table.insert(independent_names,"Continue")	--faux Ghosts
	table.insert(independent_names,"Core")		--faux Ghosts
	table.insert(independent_names,"CRUD")		--faux Ghosts
	table.insert(independent_names,"Decode")	--faux Ghosts
	table.insert(independent_names,"Decrypt")	--faux Ghosts
	table.insert(independent_names,"Device")	--faux Ghosts
	table.insert(independent_names,"Encode")	--faux Ghosts
	table.insert(independent_names,"Encrypt")	--faux Ghosts
	table.insert(independent_names,"Event")		--faux Ghosts
	table.insert(independent_names,"Fetch")		--faux Ghosts
	table.insert(independent_names,"Frame")		--faux Ghosts
	table.insert(independent_names,"Go")		--faux Ghosts
	table.insert(independent_names,"IO")		--faux Ghosts
	table.insert(independent_names,"Interface")	--faux Ghosts
	table.insert(independent_names,"Kilo")		--faux Ghosts
	table.insert(independent_names,"Modify")	--faux Ghosts
	table.insert(independent_names,"Pin")		--faux Ghosts
	table.insert(independent_names,"Program")	--faux Ghosts
	table.insert(independent_names,"Purge")		--faux Ghosts
	table.insert(independent_names,"Retrieve")	--faux Ghosts
	table.insert(independent_names,"Store")		--faux Ghosts
	table.insert(independent_names,"Unit")		--faux Ghosts
	table.insert(independent_names,"Wire")		--faux Ghosts
end
function setHumanNames()
	human_names = {}
	table.insert(human_names,"Andromeda")
	table.insert(human_names,"Angelica")
	table.insert(human_names,"Artemis")
	table.insert(human_names,"Barrier")
	table.insert(human_names,"Beauteous")
	table.insert(human_names,"Bliss")
	table.insert(human_names,"Bonita")
	table.insert(human_names,"Bounty Hunter")
	table.insert(human_names,"Bueno")
	table.insert(human_names,"Capitol")
	table.insert(human_names,"Castigator")
	table.insert(human_names,"Centurion")
	table.insert(human_names,"Chakalaka")
	table.insert(human_names,"Charity")
	table.insert(human_names,"Christmas")
	table.insert(human_names,"Chutzpah")
	table.insert(human_names,"Constantine")
	table.insert(human_names,"Crystal")
	table.insert(human_names,"Dauntless")
	table.insert(human_names,"Defiant")
	table.insert(human_names,"Discovery")
	table.insert(human_names,"Dorcas")
	table.insert(human_names,"Elite")
	table.insert(human_names,"Empathy")
	table.insert(human_names,"Enlighten")
	table.insert(human_names,"Enterprise")
	table.insert(human_names,"Escape")
	table.insert(human_names,"Exclamatory")
	table.insert(human_names,"Faith")
	table.insert(human_names,"Felicity")
	table.insert(human_names,"Firefly")
	table.insert(human_names,"Foresight")
	table.insert(human_names,"Forthright")
	table.insert(human_names,"Fortitude")
	table.insert(human_names,"Frankenstein")
	table.insert(human_names,"Gallant")
	table.insert(human_names,"Gladiator")
	table.insert(human_names,"Glider")
	table.insert(human_names,"Godzilla")
	table.insert(human_names,"Grind")
	table.insert(human_names,"Happiness")
	table.insert(human_names,"Hearken")
	table.insert(human_names,"Helena")
	table.insert(human_names,"Heracles")
	table.insert(human_names,"Honorable Intentions")
	table.insert(human_names,"Hope")
	table.insert(human_names,"Inertia")
	table.insert(human_names,"Ingenius")
	table.insert(human_names,"Injurious")
	table.insert(human_names,"Insight")
	table.insert(human_names,"Insufferable")
	table.insert(human_names,"Insurmountable")
	table.insert(human_names,"Intractable")
	table.insert(human_names,"Intransigent")
	table.insert(human_names,"Jenny")
	table.insert(human_names,"Juice")
	table.insert(human_names,"Justice")
	table.insert(human_names,"Jurassic")
	table.insert(human_names,"Karma Cast")
	table.insert(human_names,"Knockout")
	table.insert(human_names,"Leila")
	table.insert(human_names,"Light Fantastic")
	table.insert(human_names,"Livid")
	table.insert(human_names,"Lolita")
	table.insert(human_names,"Mercury")
	table.insert(human_names,"Moira")
	table.insert(human_names,"Mona Lisa")
	table.insert(human_names,"Nancy")
	table.insert(human_names,"Olivia")
	table.insert(human_names,"Ominous")
	table.insert(human_names,"Oracle")
	table.insert(human_names,"Orca")
	table.insert(human_names,"Pandemic")
	table.insert(human_names,"Parsimonious")
	table.insert(human_names,"Personal Prejudice")
	table.insert(human_names,"Porpoise")
	table.insert(human_names,"Pristine")
	table.insert(human_names,"Purple Passion")
	table.insert(human_names,"Renegade")
	table.insert(human_names,"Revelation")
	table.insert(human_names,"Rosanna")
	table.insert(human_names,"Rozelle")
	table.insert(human_names,"Sainted Gramma")
	table.insert(human_names,"Shazam")
	table.insert(human_names,"Starbird")
	table.insert(human_names,"Stargazer")
	table.insert(human_names,"Stile")
	table.insert(human_names,"Streak")
	table.insert(human_names,"Take Flight")
	table.insert(human_names,"Taskmaster")
	table.insert(human_names,"The Way")
	table.insert(human_names,"Tornado")
	table.insert(human_names,"Trailblazer")
	table.insert(human_names,"Trident")
	table.insert(human_names,"Triple Threat")
	table.insert(human_names,"Turnabout")
	table.insert(human_names,"Undulator")
	table.insert(human_names,"Urgent")
	table.insert(human_names,"Victoria")
	table.insert(human_names,"Wee Bit")
	table.insert(human_names,"Wet Willie")
end

function stockTemplate(enemyFaction,template)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate(template):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	return ship
end
--------------------------------------------------------------------------------------------
--	Additional enemy ships with some modifications from the original template parameters  --
--------------------------------------------------------------------------------------------
function farco3(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Farco 3")
	ship:setShieldsMax(60, 40)									--stronger shields (vs 50, 40)
	ship:setShields(60, 40)					
--				   Index,  Arc,	Dir,	Range, Cycle,	Damage
	ship:setBeamWeapon(0,	90,	-15,	 1500,	5.0,	6.0)	--longer (vs 1200), faster (vs 8)
	ship:setBeamWeapon(1,	90,	 15,	 1500,	5.0,	6.0)
	local farco_3_db = queryScienceDatabase("Ships","Frigate","Farco 3")
	if farco_3_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Farco 3")
		farco_3_db = queryScienceDatabase("Ships","Frigate","Farco 3")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
			farco_3_db,		--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 3, the beams are longer and faster and the shields are slightly stronger.",
			{
				{key = "Tube -1", value = "60 sec"},	--torpedo tube direction and load speed
				{key = "Tube 1", value = "60 sec"},		--torpedo tube direction and load speed
			},
			nil		--jump range
		)
	end
	return ship
end
function farco5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Farco 5")
	ship:setShieldsMax(60, 40)				--stronger shields (vs 50, 40)
	ship:setShields(60, 40)	
	ship:setTubeLoadTime(0,30)				--faster (vs 60)
	ship:setTubeLoadTime(0,30)				
	local farco_5_db = queryScienceDatabase("Ships","Frigate","Farco 5")
	if farco_5_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Farco 5")
		farco_5_db = queryScienceDatabase("Ships","Frigate","Farco 5")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
			farco_5_db,		--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 5, the tubes load faster and the shields are slightly stronger.",
			{
				{key = "Tube -1", value = "30 sec"},	--torpedo tube direction and load speed
				{key = "Tube 1", value = "30 sec"},		--torpedo tube direction and load speed
			},
			nil		--jump range
		)
	end
	return ship
end
function farco8(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Farco 8")
	ship:setShieldsMax(80, 50)				--stronger shields (vs 50, 40)
	ship:setShields(80, 50)	
--				   Index,  Arc,	Dir,	Range, Cycle,	Damage
	ship:setBeamWeapon(0,	90,	-15,	 1500,	5.0,	6.0)	--longer (vs 1200), faster (vs 8)
	ship:setBeamWeapon(1,	90,	 15,	 1500,	5.0,	6.0)
	ship:setTubeLoadTime(0,30)				--faster (vs 60)
	ship:setTubeLoadTime(0,30)				
	local farco_8_db = queryScienceDatabase("Ships","Frigate","Farco 8")
	if farco_8_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Farco 8")
		farco_8_db = queryScienceDatabase("Ships","Frigate","Farco 8")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
			farco_8_db,		--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 8, the beams are longer and faster, the tubes load faster and the shields are stronger.",
			{
				{key = "Tube -1", value = "30 sec"},	--torpedo tube direction and load speed
				{key = "Tube 1", value = "30 sec"},		--torpedo tube direction and load speed
			},
			nil		--jump range
		)
	end
	return ship
end
function farco11(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Farco 11")
	ship:setShieldsMax(80, 50)				--stronger shields (vs 50, 40)
	ship:setShields(80, 50)	
	ship:setRotationMaxSpeed(15)								--faster maneuver (vs 10)
--				   Index,  Arc,	Dir,	Range, Cycle,	Damage
	ship:setBeamWeapon(0,	90,	-15,	 1500,	5.0,	6.0)	--longer (vs 1200), faster (vs 8)
	ship:setBeamWeapon(1,	90,	 15,	 1500,	5.0,	6.0)
	ship:setBeamWeapon(2,	20,	  0,	 1800,	5.0,	4.0)	--additional sniping beam
	local farco_11_db = queryScienceDatabase("Ships","Frigate","Farco 11")
	if farco_11_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Farco 11")
		farco_11_db = queryScienceDatabase("Ships","Frigate","Farco 11")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
			farco_11_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 11, the maneuver speed is faster, the beams are longer and faster, there's an added longer sniping beam and the shields are stronger.",
			{
				{key = "Tube -1", value = "60 sec"},	--torpedo tube direction and load speed
				{key = "Tube 1", value = "60 sec"},		--torpedo tube direction and load speed
			},
			nil		--jump range
		)
	end
	return ship
end
function farco13(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Farco 13")
	ship:setShieldsMax(90, 70)				--stronger shields (vs 50, 40)
	ship:setShields(90, 70)	
	ship:setRotationMaxSpeed(15)								--faster maneuver (vs 10)
--				   Index,  Arc,	Dir,	Range, Cycle,	Damage
	ship:setBeamWeapon(0,	90,	-15,	 1500,	5.0,	6.0)	--longer (vs 1200), faster (vs 8)
	ship:setBeamWeapon(1,	90,	 15,	 1500,	5.0,	6.0)
	ship:setBeamWeapon(2,	20,	  0,	 1800,	5.0,	4.0)	--additional sniping beam
	ship:setTubeLoadTime(0,30)				--faster (vs 60)
	ship:setTubeLoadTime(0,30)				
	ship:setWeaponStorageMax("Homing",16)						--more (vs 6)
	ship:setWeaponStorage("Homing", 16)		
	ship:setWeaponStorageMax("HVLI",30)							--more (vs 20)
	ship:setWeaponStorage("HVLI", 30)
	local farco_13_db = queryScienceDatabase("Ships","Frigate","Farco 13")
	if farco_13_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Farco 13")
		farco_13_db = queryScienceDatabase("Ships","Frigate","Farco 13")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
			farco_13_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 13, the maneuver speed is faster, the beams are longer and faster, there's an added longer sniping beam, the tubes load faster, there are more missiles and the shields are stronger.",
			{
				{key = "Tube -1", value = "30 sec"},	--torpedo tube direction and load speed
				{key = "Tube 1", value = "30 sec"},		--torpedo tube direction and load speed
			},
			nil		--jump range
		)
	end
	return ship
end
function whirlwind(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Storm"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Whirlwind")
	ship:setWeaponTubeCount(9)					--more (vs 5)
	ship:setWeaponTubeDirection(0,-90)			--3 left, 3 right, 3 front (vs 5 front)	
	ship:setWeaponTubeDirection(1,-92)				
	ship:setWeaponTubeDirection(2,-88)				
	ship:setWeaponTubeDirection(3, 90)				
	ship:setWeaponTubeDirection(4, 92)				
	ship:setWeaponTubeDirection(5, 88)				
	ship:setWeaponTubeDirection(6,  0)				
	ship:setWeaponTubeDirection(7,  2)				
	ship:setWeaponTubeDirection(8, -2)				
	ship:setWeaponStorageMax("Homing",36)						--more (vs 15)
	ship:setWeaponStorage("Homing", 36)		
	ship:setWeaponStorageMax("HVLI",36)							--more (vs 15)
	ship:setWeaponStorage("HVLI", 36)
	local whirlwind_db = queryScienceDatabase("Ships","Frigate","Whirlwind")
	if whirlwind_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Whirlwind")
		whirlwind_db = queryScienceDatabase("Ships","Frigate","Whirlwind")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Storm"),	--base ship database entry
			whirlwind_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Whirlwind, another heavy artillery cruiser, takes the Storm and adds tubes and missiles. It's as if the Storm swallowed a Pirahna and grew gills. Expect to see missiles, lots of missiles",
			{
				{key = "Tube -90", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube -92", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube -88", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube  90", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube  92", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube  88", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube   0", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube   2", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube  -2", value = "15 sec"},	--torpedo tube direction and load speed
			},
			nil		--jump range
		)
	end
	return ship
end
function phobosR2(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Phobos R2")
	ship:setWeaponTubeCount(1)			--one tube (vs 2)
	ship:setWeaponTubeDirection(0,0)	
	ship:setImpulseMaxSpeed(55)			--slower impulse (vs 60)
	ship:setRotationMaxSpeed(15)		--faster maneuver (vs 10)
	local phobos_r2_db = queryScienceDatabase("Ships","Frigate","Phobos R2")
	if phobos_r2_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Phobos R2")
		phobos_r2_db = queryScienceDatabase("Ships","Frigate","Phobos R2")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
			phobos_r2_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Phobos R2 model is very similar to the Phobos T3. It's got a faster turn speed, but only one missile tube",
			{
				{key = "Tube 0", value = "60 sec"},	--torpedo tube direction and load speed
			},
			nil
		)
		--[[
		phobos_r2_db:setLongDescription("The Phobos R2 model is very similar to the Phobos T3. It's got a faster turn speed, but only one missile tube")
		phobos_r2_db:setKeyValue("Class","Frigate")
		phobos_r2_db:setKeyValue("Sub-class","Cruiser")
		phobos_r2_db:setKeyValue("Size","80")
		phobos_r2_db:setKeyValue("Shield","50/40")
		phobos_r2_db:setKeyValue("Hull","70")
		phobos_r2_db:setKeyValue("Move speed","3.3 U/min")
		phobos_r2_db:setKeyValue("Turn speed","15.0 deg/sec")
		phobos_r2_db:setKeyValue("Beam weapon -15:90","6.0 Dmg / 8.0 sec")
		phobos_r2_db:setKeyValue("Beam weapon 15:90","6.0 Dmg / 8.0 sec")
		phobos_r2_db:setKeyValue("Tube 0","60 sec")
		phobos_r2_db:setKeyValue("Storage Homing","6")
		phobos_r2_db:setKeyValue("Storage HVLI","20")
		phobos_r2_db:setImage("radar_cruiser.png")
		--]]
	end
	return ship
end
function hornetMV52(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("MT52 Hornet"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("MV52 Hornet")
	ship:setBeamWeapon(0, 30, 0, 1000.0, 4.0, 3.0)	--longer and stronger beam (vs 700 & 3)
	ship:setRotationMaxSpeed(31)					--faster maneuver (vs 30)
	ship:setImpulseMaxSpeed(130)					--faster impulse (vs 120)
	local hornet_mv52_db = queryScienceDatabase("Ships","Starfighter","MV52 Hornet")
	if hornet_mv52_db == nil then
		local starfighter_db = queryScienceDatabase("Ships","Starfighter")
		starfighter_db:addEntry("MV52 Hornet")
		hornet_mv52_db = queryScienceDatabase("Ships","Starfighter","MV52 Hornet")
		addShipToDatabase(
			queryScienceDatabase("Ships","Starfighter","MT52 Hornet"),	--base ship database entry
			hornet_mv52_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The MV52 Hornet is very similar to the MT52 and MU52 models. The beam does more damage than both of the other Hornet models, it's max impulse speed is faster than both of the other Hornet models, it turns faster than the MT52, but slower than the MU52",
			nil,
			nil
		)
		--[[
		hornet_mv52_db:setLongDescription("The MV52 Hornet is very similar to the MT52 and MU52 models. The beam does more damage than both of the other Hornet models, it's max impulse speed is faster than both of the other Hornet models, it turns faster than the MT52, but slower than the MU52")
		hornet_mv52_db:setKeyValue("Class","Starfighter")
		hornet_mv52_db:setKeyValue("Sub-class","Interceptor")
		hornet_mv52_db:setKeyValue("Size","30")
		hornet_mv52_db:setKeyValue("Shield","20")
		hornet_mv52_db:setKeyValue("Hull","30")
		hornet_mv52_db:setKeyValue("Move speed","7.8 U/min")
		hornet_mv52_db:setKeyValue("Turn speed","31.0 deg/sec")
		hornet_mv52_db:setKeyValue("Beam weapon 0:30","3.0 Dmg / 4.0 sec")
		hornet_mv52_db:setImage("radar_fighter.png")
		--]]
	end
	return ship
end
function k2fighter(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Fighter"):orderRoaming()
	ship:setTypeName("K2 Fighter")
	ship:setBeamWeapon(0, 60, 0, 1200.0, 2.5, 6)	--beams cycle faster (vs 4.0)
	ship:setHullMax(65)								--weaker hull (vs 70)
	ship:setHull(65)
	local k2_fighter_db = queryScienceDatabase("Ships","No Class","K2 Fighter")
	if k2_fighter_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		no_class_db:addEntry("K2 Fighter")
		k2_fighter_db = queryScienceDatabase("Ships","No Class","K2 Fighter")
		addShipToDatabase(
			queryScienceDatabase("Ships","No Class","Ktlitan Fighter"),	--base ship database entry
			k2_fighter_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"Enterprising designers published this design specification based on salvaged Ktlitan Fighters. Comparatively, it's got beams that cycle faster, but the hull is a bit weaker.",
			nil,
			nil		--jump range
		)
		--[[
		k2_fighter_db:setLongDescription("Enterprising designers published this design specification based on salvaged Ktlitan Fighters. Comparatively, it's got beams that cycle faster, but the hull is a bit weaker.")
		k2_fighter_db:setKeyValue("Class","No Class")
		k2_fighter_db:setKeyValue("Sub-class","No Sub-Class")
		k2_fighter_db:setKeyValue("Size","180")
		k2_fighter_db:setKeyValue("Hull","65")
		k2_fighter_db:setKeyValue("Move speed","8.4 U/min")
		k2_fighter_db:setKeyValue("Turn speed","30.0 deg/sec")
		k2_fighter_db:setKeyValue("Beam weapon 0:60","6.0 Dmg / 2.5 sec")
		k2_fighter_db:setImage("radar_ktlitan_fighter.png")
		--]]
	end
	return ship
end	
function k3fighter(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Fighter"):orderRoaming()
	ship:setTypeName("K3 Fighter")
	ship:setBeamWeapon(0, 60, 0, 1200.0, 2.5, 9)	--beams cycle faster and damage more (vs 4.0 & 6)
	ship:setHullMax(60)								--weaker hull (vs 70)
	ship:setHull(60)
	local k3_fighter_db = queryScienceDatabase("Ships","No Class","K3 Fighter")
	if k3_fighter_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		no_class_db:addEntry("K3 Fighter")
		k3_fighter_db = queryScienceDatabase("Ships","No Class","K3 Fighter")
		addShipToDatabase(
			queryScienceDatabase("Ships","No Class","Ktlitan Fighter"),	--base ship database entry
			k3_fighter_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"Enterprising designers published this design specification based on salvaged Ktlitan Fighters. Comparatively, it's got beams that are stronger and that cycle faster, but the hull is weaker.",
			nil,
			nil		--jump range
		)
		--[[
		k3_fighter_db:setLongDescription("Enterprising designers published this design specification based on salvaged Ktlitan Fighters. Comparatively, it's got beams that cycle faster, but the hull is weaker.")
		k3_fighter_db:setKeyValue("Class","No Class")
		k3_fighter_db:setKeyValue("Sub-class","No Sub-Class")
		k3_fighter_db:setKeyValue("Size","180")
		k3_fighter_db:setKeyValue("Hull","60")
		k3_fighter_db:setKeyValue("Move speed","8.4 U/min")
		k3_fighter_db:setKeyValue("Turn speed","30.0 deg/sec")
		k3_fighter_db:setKeyValue("Beam weapon 0:60","9.0 Dmg / 2.5 sec")
		k3_fighter_db:setImage("radar_ktlitan_fighter.png")
		--]]
	end
	return ship
end	
function waddle5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Waddle 5")
	ship:setWarpDrive(true)
--				   Index,  Arc,	  Dir, Range, Cycle,	Damage
	ship:setBeamWeapon(2,	70,	  -30,	 600,	5.0,	2.0)	--adjust beam direction to match starboard side (vs -35)
	local waddle_5_db = queryScienceDatabase("Ships","Starfighter","Waddle 5")
	if waddle_5_db == nil then
		local starfighter_db = queryScienceDatabase("Ships","Starfighter")
		starfighter_db:addEntry("Waddle 5")
		waddle_5_db = queryScienceDatabase("Ships","Starfighter","Waddle 5")
		addShipToDatabase(
			queryScienceDatabase("Ships","Starfighter","Adder MK5"),	--base ship database entry
			waddle_5_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"Conversions R Us purchased a number of Adder MK 5 ships at auction and added warp drives to them to produce the Waddle 5",
			{
				{key = "Small tube 0", value = "15 sec"},	--torpedo tube direction and load speed
			},
			nil		--jump range
		)
		--[[
		waddle_5_db:setLongDescription("Conversions R Us purchased a number of Adder MK 5 ships at auction and added warp drives to them to produce the Waddle 5")
		waddle_5_db:setKeyValue("Class","Starfighter")
		waddle_5_db:setKeyValue("Sub-class","Gunship")
		waddle_5_db:setKeyValue("Size","80")
		waddle_5_db:setKeyValue("Shield","30")
		waddle_5_db:setKeyValue("Hull","50")
		waddle_5_db:setKeyValue("Move speed","4.8 U/min")
		waddle_5_db:setKeyValue("Turn speed","28.0 deg/sec")
		waddle_5_db:setKeyValue("Warp Speed","60.0 U/min")
		waddle_5_db:setKeyValue("Beam weapon 0:35","2.0 Dmg / 5.0 sec")
		waddle_5_db:setKeyValue("Beam weapon 30:70","2.0 Dmg / 5.0 sec")
		waddle_5_db:setKeyValue("Beam weapon -35:70","2.0 Dmg / 5.0 sec")
		waddle_5_db:setImage("radar_fighter.png")
		--]]
	end
	return ship
end
function jade5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Jade 5")
	ship:setJumpDrive(true)
	ship:setJumpDriveRange(5000,35000)
--				   Index,  Arc,	  Dir, Range, Cycle,	Damage
	ship:setBeamWeapon(2,	70,	  -30,	 600,	5.0,	2.0)	--adjust beam direction to match starboard side (vs -35)
	local jade_5_db = queryScienceDatabase("Ships","Starfighter","Jade 5")
	if jade_5_db == nil then
		local starfighter_db = queryScienceDatabase("Ships","Starfighter")
		starfighter_db:addEntry("Jade 5")
		jade_5_db = queryScienceDatabase("Ships","Starfighter","Jade 5")
		addShipToDatabase(
			queryScienceDatabase("Ships","Starfighter","Adder MK5"),	--base ship database entry
			jade_5_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"Conversions R Us purchased a number of Adder MK 5 ships at auction and added jump drives to them to produce the Jade 5",
			{
				{key = "Small tube 0", value = "15 sec"},	--torpedo tube direction and load speed
			},
			"5 - 35 U"		--jump range
		)
		--[[
		jade_5_db:setLongDescription("Conversions R Us purchased a number of Adder MK 5 ships at auction and added jump drives to them to produce the Jade 5")
		jade_5_db:setKeyValue("Class","Starfighter")
		jade_5_db:setKeyValue("Sub-class","Gunship")
		jade_5_db:setKeyValue("Size","80")
		jade_5_db:setKeyValue("Shield","30")
		jade_5_db:setKeyValue("Hull","50")
		jade_5_db:setKeyValue("Move speed","4.8 U/min")
		jade_5_db:setKeyValue("Turn speed","28.0 deg/sec")
		jade_5_db:setKeyValue("Jump Range","5 - 35 U")
		jade_5_db:setKeyValue("Beam weapon 0:35","2.0 Dmg / 5.0 sec")
		jade_5_db:setKeyValue("Beam weapon 30:70","2.0 Dmg / 5.0 sec")
		jade_5_db:setKeyValue("Beam weapon -35:70","2.0 Dmg / 5.0 sec")
		jade_5_db:setImage("radar_fighter.png")
		--]]
	end
	return ship
end
function droneLite(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone"):orderRoaming()
	ship:setTypeName("Lite Drone")
	ship:setHullMax(20)					--weaker hull (vs 30)
	ship:setHull(20)
	ship:setImpulseMaxSpeed(130)		--faster impulse (vs 120)
	ship:setRotationMaxSpeed(20)		--faster maneuver (vs 10)
	ship:setBeamWeapon(0,40,0,600,4,4)	--weaker (vs 6) beam
	local drone_lite_db = queryScienceDatabase("Ships","No Class","Lite Drone")
	if drone_lite_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		no_class_db:addEntry("Lite Drone")
		drone_lite_db = queryScienceDatabase("Ships","No Class","Lite Drone")
		addShipToDatabase(
			queryScienceDatabase("Ships","No Class","Ktlitan Drone"),	--base ship database entry
			drone_lite_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The light drone was pieced together from scavenged parts of various damaged Ktlitan drones. Compared to the Ktlitan drone, the lite drone has a weaker hull, and a weaker beam, but a faster turn and impulse speed",
			nil,
			nil
		)
		--[[
		drone_lite_db:setLongDescription("The light drone was pieced together from scavenged parts of various damaged Ktlitan drones. Compared to the Ktlitan drone, the lite drone has a weaker hull, and a weaker beam, but a faster turn and impulse speed")
		drone_lite_db:setKeyValue("Class","No Class")
		drone_lite_db:setKeyValue("Sub-class","No Sub-Class")
		drone_lite_db:setKeyValue("Size","150")
		drone_lite_db:setKeyValue("Hull","20")
		drone_lite_db:setKeyValue("Move speed","7.8 U/min")
		drone_lite_db:setKeyValue("Turn speed","20 deg/sec")
		drone_lite_db:setKeyValue("Beam weapon 0:40","4.0 Dmg / 4.0 sec")
		drone_lite_db:setImage("radar_ktlitan_drone.png")
		--]]
	end
	return ship
end
function droneHeavy(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone"):orderRoaming()
	ship:setTypeName("Heavy Drone")
	ship:setHullMax(40)					--stronger hull (vs 30)
	ship:setHull(40)
	ship:setImpulseMaxSpeed(110)		--slower impulse (vs 120)
	ship:setBeamWeapon(0,40,0,600,4,8)	--stronger (vs 6) beam
	local drone_heavy_db = queryScienceDatabase("Ships","No Class","Heavy Drone")
	if drone_heavy_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		no_class_db:addEntry("Heavy Drone")
		drone_heavy_db = queryScienceDatabase("Ships","No Class","Heavy Drone")
		addShipToDatabase(
			queryScienceDatabase("Ships","No Class","Ktlitan Drone"),	--base ship database entry
			drone_heavy_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The heavy drone has a stronger hull and a stronger beam than the normal Ktlitan Drone, but it also moves slower",
			nil,
			nil
		)
		--[[
		drone_heavy_db:setLongDescription("The heavy drone has a stronger hull and a stronger beam than the normal Ktlitan Drone, but it also moves slower")
		drone_heavy_db:setKeyValue("Class","No Class")
		drone_heavy_db:setKeyValue("Sub-class","No Sub-Class")
		drone_heavy_db:setKeyValue("Size","150")
		drone_heavy_db:setKeyValue("Hull","40")
		drone_heavy_db:setKeyValue("Move speed","6.6 U/min")
		drone_heavy_db:setKeyValue("Turn speed","10 deg/sec")
		drone_heavy_db:setKeyValue("Beam weapon 0:40","8.0 Dmg / 4.0 sec")
		drone_heavy_db:setImage("radar_ktlitan_drone.png")
		--]]
	end
	return ship
end
function droneJacket(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Jacket Drone")
	ship:setShieldsMax(20)				--stronger shields (vs none)
	ship:setShields(20)
	ship:setImpulseMaxSpeed(110)		--slower impulse (vs 120)
	ship:setBeamWeapon(0,40,0,600,4,4)	--weaker (vs 6) beam
	local drone_jacket_db = queryScienceDatabase("Ships","No Class","Jacket Drone")
	if drone_jacket_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		no_class_db:addEntry("Jacket Drone")
		drone_jacket_db = queryScienceDatabase("Ships","No Class","Jacket Drone")
		addShipToDatabase(
			queryScienceDatabase("Ships","No Class","Ktlitan Drone"),	--base ship database entry
			drone_jacket_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Jacket Drone is a Ktlitan Drone with a shield. It's also slightly slower and has a slightly weaker beam due to the energy requirements of the added shield",
			nil,
			nil
		)
		--[[
		drone_jacket_db:setLongDescription("The Jacket Drone is a Ktlitan Drone with a shield. It's also slightly slower and has a slightly weaker beam due to the energy requirements of the added shield")
		drone_jacket_db:setKeyValue("Class","No Class")
		drone_jacket_db:setKeyValue("Sub-class","No Sub-Class")
		drone_jacket_db:setKeyValue("Size","150")
		drone_jacket_db:setKeyValue("Shield","20")
		drone_jacket_db:setKeyValue("Hull","40")
		drone_jacket_db:setKeyValue("Move speed","6.6 U/min")
		drone_jacket_db:setKeyValue("Turn speed","10 deg/sec")
		drone_jacket_db:setKeyValue("Beam weapon 0:40","4.0 Dmg / 4.0 sec")
		drone_jacket_db:setImage("radar_ktlitan_drone.png")
		--]]
	end
	return ship
end
function wzLindworm(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("WX-Lindworm"):orderRoaming()
	ship:setTypeName("WZ-Lindworm")
	ship:setWeaponStorageMax("Nuke",2)		--more nukes (vs 0)
	ship:setWeaponStorage("Nuke",2)
	ship:setWeaponStorageMax("Homing",4)	--more homing (vs 1)
	ship:setWeaponStorage("Homing",4)
	ship:setWeaponStorageMax("HVLI",12)		--more HVLI (vs 6)
	ship:setWeaponStorage("HVLI",12)
	ship:setRotationMaxSpeed(12)			--slower maneuver (vs 15)
	ship:setHullMax(45)						--weaker hull (vs 50)
	ship:setHull(45)
	local wz_lindworm_db = queryScienceDatabase("Ships","Starfighter","WZ-Lindworm")
	if wz_lindworm_db == nil then
		local starfighter_db = queryScienceDatabase("Ships","Starfighter")
		starfighter_db:addEntry("WZ-Lindworm")
		wz_lindworm_db = queryScienceDatabase("Ships","Starfighter","WZ-Lindworm")
		addShipToDatabase(
			queryScienceDatabase("Ships","Starfighter","WX-Lindworm"),	--base ship database entry
			wz_lindworm_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The WZ-Lindworm is essentially the stock WX-Lindworm with more HVLIs, more homing missiles and added nukes. They had to remove some of the armor to get the additional missiles to fit, so the hull is weaker. Also, the WZ turns a little more slowly than the WX. This little bomber packs quite a whallop.",
			{
				{key = "Small tube 0", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Small tube 1", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Small tube -1", value = "15 sec"},	--torpedo tube direction and load speed
			},
			nil
		)
		--[[
		wz_lindworm_db:setLongDescription("The WZ-Lindworm is essentially the stock WX-Lindworm with more HVLIs, more homing missiles and added nukes. They had to remove some of the armor to get the additional missiles to fit, so the hull is weaker. Also, the WZ turns a little more slowly than the WX. This little bomber packs quite a whallop.")
		wz_lindworm_db:setKeyValue("Class","Starfighter")
		wz_lindworm_db:setKeyValue("Sub-class","Bomber")
		wz_lindworm_db:setKeyValue("Size","30")
		wz_lindworm_db:setKeyValue("Shield","20")
		wz_lindworm_db:setKeyValue("Hull","45")
		wz_lindworm_db:setKeyValue("Move speed","3.0 U/min")
		wz_lindworm_db:setKeyValue("Turn speed","12 deg/sec")
		wz_lindworm_db:setKeyValue("Small tube 0","15 sec")
		wz_lindworm_db:setKeyValue("Small tube 1","15 sec")
		wz_lindworm_db:setKeyValue("Small tube -1","15 sec")
		wz_lindworm_db:setKeyValue("Storage Homing","4")
		wz_lindworm_db:setKeyValue("Storage Nuke","2")
		wz_lindworm_db:setKeyValue("Storage HVLI","12")
		wz_lindworm_db:setImage("radar_fighter.png")
		--]]
	end
	return ship
end
function tempest(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Piranha F12"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Tempest")
	ship:setWeaponTubeCount(10)						--four more tubes (vs 6)
	ship:setWeaponTubeDirection(0, -88)				--5 per side
	ship:setWeaponTubeDirection(1, -89)				--slight angle spread
	ship:setWeaponTubeDirection(3,  88)				--3 for HVLI each side
	ship:setWeaponTubeDirection(4,  89)				--2 for homing and nuke each side
	ship:setWeaponTubeDirection(6, -91)				
	ship:setWeaponTubeDirection(7, -92)				
	ship:setWeaponTubeDirection(8,  91)				
	ship:setWeaponTubeDirection(9,  92)				
	ship:setWeaponTubeExclusiveFor(7,"HVLI")
	ship:setWeaponTubeExclusiveFor(9,"HVLI")
	ship:setWeaponStorageMax("Homing",16)			--more (vs 6)
	ship:setWeaponStorage("Homing", 16)				
	ship:setWeaponStorageMax("Nuke",8)				--more (vs 0)
	ship:setWeaponStorage("Nuke", 8)				
	ship:setWeaponStorageMax("HVLI",34)				--more (vs 20)
	ship:setWeaponStorage("HVLI", 34)
	local tempest_db = queryScienceDatabase("Ships","Frigate","Tempest")
	if tempest_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Tempest")
		tempest_db = queryScienceDatabase("Ships","Frigate","Tempest")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Piranha F12"),	--base ship database entry
			tempest_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"Loosely based on the Piranha F12 model, the Tempest adds four more broadside tubes (two on each side), more HVLIs, more Homing missiles and 8 Nukes. The Tempest can strike fear into the hearts of your enemies. Get yourself one today!",
			{
				{key = "Large tube -88", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube -89", value = "15 sec"},		--torpedo tube direction and load speed
				{key = "Large tube -90", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Large tube 88", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube 89", value = "15 sec"},		--torpedo tube direction and load speed
				{key = "Large tube 90", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube -91", value = "15 sec"},		--torpedo tube direction and load speed
				{key = "Tube -92", value = "15 sec"},		--torpedo tube direction and load speed
				{key = "Tube 91", value = "15 sec"},		--torpedo tube direction and load speed
				{key = "Tube 92", value = "15 sec"},		--torpedo tube direction and load speed
			},
			nil
		)
		--[[
		tempest_db:setLongDescription("Loosely based on the Piranha F12 model, the Tempest adds four more broadside tubes (two on each side), more HVLIs, more Homing missiles and 8 Nukes. The Tempest can strike fear into the hearts of your enemies. Get yourself one today!")
		tempest_db:setKeyValue("Class","Frigate")
		tempest_db:setKeyValue("Sub-class","Cruiser: Light Artillery")
		tempest_db:setKeyValue("Size","80")
		tempest_db:setKeyValue("Shield","30/30")
		tempest_db:setKeyValue("Hull","70")
		tempest_db:setKeyValue("Move speed","2.4 U/min")
		tempest_db:setKeyValue("Turn speed","6.0 deg/sec")
		tempest_db:setKeyValue("Large Tube -88","15 sec")
		tempest_db:setKeyValue("Tube -89","15 sec")
		tempest_db:setKeyValue("Large Tube -90","15 sec")
		tempest_db:setKeyValue("Large Tube 88","15 sec")
		tempest_db:setKeyValue("Tube 89","15 sec")
		tempest_db:setKeyValue("Large Tube 90","15 sec")
		tempest_db:setKeyValue("Tube -91","15 sec")
		tempest_db:setKeyValue("Tube -92","15 sec")
		tempest_db:setKeyValue("Tube 91","15 sec")
		tempest_db:setKeyValue("Tube 92","15 sec")
		tempest_db:setKeyValue("Storage Homing","16")
		tempest_db:setKeyValue("Storage Nuke","8")
		tempest_db:setKeyValue("Storage HVLI","34")
		tempest_db:setImage("radar_piranha.png")
		--]]
	end
	return ship
end
function enforcer(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Blockade Runner"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Enforcer")
	ship:setRadarTrace("radar_ktlitan_destroyer.png")			--different radar trace
	ship:setWarpDrive(true)										--warp (vs none)
	ship:setWarpSpeed(600)
	ship:setImpulseMaxSpeed(100)								--faster impulse (vs 60)
	ship:setRotationMaxSpeed(20)								--faster maneuver (vs 15)
	ship:setShieldsMax(200,100,100)								--stronger shields (vs 100,150)
	ship:setShields(200,100,100)					
	ship:setHullMax(100)										--stronger hull (vs 70)
	ship:setHull(100)
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,	30,	    5,	1500,		6,		10)	--narrower (vs 60), longer (vs 1000), stronger (vs 8)
	ship:setBeamWeapon(1,	30,	   -5,	1500,		6,		10)
	ship:setBeamWeapon(2,	 0,	    0,	   0,		0,		 0)	--fewer (vs 4)
	ship:setBeamWeapon(3,	 0,	    0,	   0,		0,		 0)
	ship:setWeaponTubeCount(3)									--more (vs 0)
	ship:setTubeSize(0,"large")									--large (vs normal)
	ship:setWeaponTubeDirection(1,-15)				
	ship:setWeaponTubeDirection(2, 15)				
	ship:setTubeLoadTime(0,18)
	ship:setTubeLoadTime(1,12)
	ship:setTubeLoadTime(2,12)			
	ship:setWeaponStorageMax("Homing",18)						--more (vs 0)
	ship:setWeaponStorage("Homing", 18)
	local enforcer_db = queryScienceDatabase("Ships","Frigate","Enforcer")
	if enforcer_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Enforcer")
		enforcer_db = queryScienceDatabase("Ships","Frigate","Enforcer")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Blockade Runner"),	--base ship database entry
			enforcer_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Enforcer is a highly modified Blockade Runner. A warp drive was added and impulse engines boosted along with turning speed. Three missile tubes were added to shoot homing missiles, large ones straight ahead. Stronger shields and hull. Removed rear facing beams and strengthened front beams.",
			{
				{key = "Large tube 0", value = "18 sec"},	--torpedo tube direction and load speed
				{key = "Tube -15", value = "12 sec"},		--torpedo tube direction and load speed
				{key = "Tube 15", value = "12 sec"},		--torpedo tube direction and load speed
			},
			nil
		)
		--[[
		enforcer_db:setLongDescription("The Enforcer is a highly modified Blockade Runner. A warp drive was added and impulse engines boosted along with turning speed. Three missile tubes were added to shoot homing missiles, large ones straight ahead. Stronger shields and hull. Removed rear facing beams and stengthened front beams.")
		enforcer_db:setKeyValue("Class","Frigate")
		enforcer_db:setKeyValue("Sub-class","High Punch")
		enforcer_db:setKeyValue("Size","200")
		enforcer_db:setKeyValue("Shield","200/100/100")
		enforcer_db:setKeyValue("Hull","100")
		enforcer_db:setKeyValue("Move speed","6.0 U/min")
		enforcer_db:setKeyValue("Turn speed","20.0 deg/sec")
		enforcer_db:setKeyValue("Warp Speed","36.0 U/min")
		enforcer_db:setKeyValue("Beam weapon -15:30","10.0 Dmg / 6.0 sec")
		enforcer_db:setKeyValue("Beam weapon 15:30","10.0 Dmg / 6.0 sec")
		enforcer_db:setKeyValue("Large Tube 0","20 sec")
		enforcer_db:setKeyValue("Tube -30","20 sec")
		enforcer_db:setKeyValue("Tube 30","20 sec")
		enforcer_db:setKeyValue("Storage Homing","18")
		--]]
		enforcer_db:setImage("radar_ktlitan_destroyer.png")		--override default radar image
	end
	return ship		
end
function predator(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Piranha F8"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Predator")
	ship:setShieldsMax(100,100)									--stronger shields (vs 30,30)
	ship:setShields(100,100)					
	ship:setHullMax(80)											--stronger hull (vs 70)
	ship:setHull(80)
	ship:setImpulseMaxSpeed(65)									--faster impulse (vs 40)
	ship:setRotationMaxSpeed(15)								--faster maneuver (vs 6)
	ship:setJumpDrive(true)
	ship:setJumpDriveRange(5000,35000)			
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,	90,	    0,	1000,		6,		 4)	--more (vs 0)
	ship:setBeamWeapon(1,	90,	  180,	1000,		6,		 4)	
	ship:setWeaponTubeCount(8)									--more (vs 3)
	ship:setWeaponTubeDirection(0,-60)				
	ship:setWeaponTubeDirection(1,-90)				
	ship:setWeaponTubeDirection(2,-90)				
	ship:setWeaponTubeDirection(3, 60)				
	ship:setWeaponTubeDirection(4, 90)				
	ship:setWeaponTubeDirection(5, 90)				
	ship:setWeaponTubeDirection(6,-120)				
	ship:setWeaponTubeDirection(7, 120)				
	ship:setWeaponTubeExclusiveFor(0,"Homing")
	ship:setWeaponTubeExclusiveFor(1,"Homing")
	ship:setWeaponTubeExclusiveFor(2,"Homing")
	ship:setWeaponTubeExclusiveFor(3,"Homing")
	ship:setWeaponTubeExclusiveFor(4,"Homing")
	ship:setWeaponTubeExclusiveFor(5,"Homing")
	ship:setWeaponTubeExclusiveFor(6,"Homing")
	ship:setWeaponTubeExclusiveFor(7,"Homing")
	ship:setWeaponStorageMax("Homing",32)						--more (vs 5)
	ship:setWeaponStorage("Homing", 32)		
	ship:setWeaponStorageMax("HVLI",0)							--less (vs 10)
	ship:setWeaponStorage("HVLI", 0)
	ship:setRadarTrace("radar_missile_cruiser.png")				--different radar trace
	local predator_db = queryScienceDatabase("Ships","Frigate","Predator")
	if predator_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Predator")
		predator_db = queryScienceDatabase("Ships","Frigate","Predator")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Piranha F8"),	--base ship database entry
			predator_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Predator is a significantly improved Piranha F8. Stronger shields and hull, faster impulse and turning speeds, a jump drive, beam weapons, eight missile tubes pointing in six directions and a large number of homing missiles to shoot.",
			{
				{key = "Large tube -60", value = "12 sec"},	--torpedo tube direction and load speed
				{key = "Tube -90", value = "12 sec"},		--torpedo tube direction and load speed
				{key = "Large tube -90", value = "12 sec"},	--torpedo tube direction and load speed
				{key = "Large tube 60", value = "12 sec"},	--torpedo tube direction and load speed
				{key = "Tube 90", value = "12 sec"},		--torpedo tube direction and load speed
				{key = "Large tube 90", value = "12 sec"},	--torpedo tube direction and load speed
				{key = "Tube -120", value = "12 sec"},		--torpedo tube direction and load speed
				{key = "Tube 120", value = "12 sec"},		--torpedo tube direction and load speed
			},
			"5 - 35 U"		--jump range
		)
		--[[
		predator_db:setLongDescription("The Predator is a significantly improved Piranha F8. Stronger shields and hull, faster impulse and turning speeds, a jump drive, beam weapons, eight missile tubes pointing in six directions and a large number of homing missiles to shoot.")
		predator_db:setKeyValue("Class","Frigate")
		predator_db:setKeyValue("Sub-class","Cruiser: Light Artillery")
		predator_db:setKeyValue("Size","80")
		predator_db:setKeyValue("Shield","100/100")
		predator_db:setKeyValue("Hull","80")
		predator_db:setKeyValue("Move speed","3.9 U/min")
		predator_db:setKeyValue("Turn speed","15.0 deg/sec")
		predator_db:setKeyValue("Jump Range","5 - 35 U")
		predator_db:setKeyValue("Beam weapon 0:90","4.0 Dmg / 6.0 sec")
		predator_db:setKeyValue("Beam weapon 180:90","4.0 Dmg / 6.0 sec")
		predator_db:setKeyValue("Large Tube -60","12 sec")
		predator_db:setKeyValue("Tube -90","12 sec")
		predator_db:setKeyValue("Large Tube -90","12 sec")
		predator_db:setKeyValue("Large Tube 60","12 sec")
		predator_db:setKeyValue("Tube 90","12 sec")
		predator_db:setKeyValue("Large Tube 90","12 sec")
		predator_db:setKeyValue("Tube -120","12 sec")
		predator_db:setKeyValue("Tube 120","12 sec")
		predator_db:setKeyValue("Storage Homing","32")
		--]]
		predator_db:setImage("radar_missile_cruiser.png")		--override default radar image
	end
	return ship		
end
function atlantisY42(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Atlantis X23"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Atlantis Y42")
	ship:setShieldsMax(300,200,300,200)							--stronger shields (vs 200,200,200,200)
	ship:setShields(300,200,300,200)					
	ship:setImpulseMaxSpeed(65)									--faster impulse (vs 30)
	ship:setRotationMaxSpeed(15)								--faster maneuver (vs 3.5)
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(2,	80,	  190,	1500,		6,		 8)	--narrower (vs 100)
	ship:setBeamWeapon(3,	80,	  170,	1500,		6,		 8)	--extra (vs 3 beams)
	ship:setWeaponStorageMax("Homing",16)						--more (vs 4)
	ship:setWeaponStorage("Homing", 16)
	local atlantis_y42_db = queryScienceDatabase("Ships","Corvette","Atlantis Y42")
	if atlantis_y42_db == nil then
		local corvette_db = queryScienceDatabase("Ships","Corvette")
		corvette_db:addEntry("Atlantis Y42")
		atlantis_y42_db = queryScienceDatabase("Ships","Corvette","Atlantis Y42")
		addShipToDatabase(
			queryScienceDatabase("Ships","Corvette","Atlantis X23"),	--base ship database entry
			atlantis_y42_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Atlantis Y42 improves on the Atlantis X23 with stronger shields, faster impulse and turn speeds, an extra beam in back and a larger missile stock",
			{
				{key = "Tube -90", value = "10 sec"},	--torpedo tube direction and load speed
				{key = " Tube -90", value = "10 sec"},	--torpedo tube direction and load speed
				{key = "Tube 90", value = "10 sec"},	--torpedo tube direction and load speed
				{key = " Tube 90", value = "10 sec"},	--torpedo tube direction and load speed
			},
			"5 - 50 U"		--jump range
		)
		--[[
		atlantis_y42_db:setLongDescription("The Atlantis Y42 improves on the Atlantis X23 with stronger shields, faster impulse and turn speeds, an extra beam in back and a larger missile stock")
		atlantis_y42_db:setKeyValue("Class","Corvette")
		atlantis_y42_db:setKeyValue("Sub-class","Destroyer")
		atlantis_y42_db:setKeyValue("Size","200")
		atlantis_y42_db:setKeyValue("Shield","300/200/300/200")
		atlantis_y42_db:setKeyValue("Hull","100")
		atlantis_y42_db:setKeyValue("Move speed","3.9 U/min")
		atlantis_y42_db:setKeyValue("Turn speed","15.0 deg/sec")
		atlantis_y42_db:setKeyValue("Jump Range","5 - 50 U")
		atlantis_y42_db:setKeyValue("Beam weapon -20:100","8.0 Dmg / 6.0 sec")
		atlantis_y42_db:setKeyValue("Beam weapon 20:100","8.0 Dmg / 6.0 sec")
		atlantis_y42_db:setKeyValue("Beam weapon 190:100","8.0 Dmg / 6.0 sec")
		atlantis_y42_db:setKeyValue("Beam weapon 170:100","8.0 Dmg / 6.0 sec")
		atlantis_y42_db:setKeyValue("Tube -90","10 sec")
		atlantis_y42_db:setKeyValue(" Tube -90","10 sec")
		atlantis_y42_db:setKeyValue("Tube 90","10 sec")
		atlantis_y42_db:setKeyValue(" Tube 90","10 sec")
		atlantis_y42_db:setKeyValue("Storage Homing","4")
		atlantis_y42_db:setKeyValue("Storage HVLI","20")
		atlantis_y42_db:setImage("radar_dread.png")
		--]]
	end
	return ship		
end
function starhammerV(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Starhammer II"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Starhammer V")
	ship:setImpulseMaxSpeed(65)									--faster impulse (vs 35)
	ship:setRotationMaxSpeed(15)								--faster maneuver (vs 6)
	ship:setShieldsMax(450, 350, 250, 250, 350)					--stronger shields (vs 450, 350, 150, 150, 350)
	ship:setShields(450, 350, 250, 250, 350)					
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(4,	60,	  180,	1500,		8,		11)	--extra rear facing beam
	ship:setWeaponStorageMax("Homing",16)						--more (vs 4)
	ship:setWeaponStorage("Homing", 16)		
	ship:setWeaponStorageMax("HVLI",36)							--more (vs 20)
	ship:setWeaponStorage("HVLI", 36)
	local starhammer_v_db = queryScienceDatabase("Ships","Corvette","Starhammer V")
	if starhammer_v_db == nil then
		local corvette_db = queryScienceDatabase("Ships","Corvette")
		corvette_db:addEntry("Starhammer V")
		starhammer_v_db = queryScienceDatabase("Ships","Corvette","Starhammer V")
		addShipToDatabase(
			queryScienceDatabase("Ships","Corvette","Starhammer II"),	--base ship database entry
			starhammer_v_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Starhammer V recognizes common modifications made in the field to the Starhammer II: stronger shields, faster impulse and turning speeds, additional rear beam and more missiles to shoot. These changes make the Starhammer V a force to be reckoned with.",
			{
				{key = "Tube 0", value = "10 sec"},	--torpedo tube direction and load speed
				{key = " Tube 0", value = "10 sec"},	--torpedo tube direction and load speed
			},
			"5 - 50 U"		--jump range
		)
		--[[
		starhammer_v_db:setLongDescription("The Starhammer V recognizes common modifications made in the field to the Starhammer II: stronger shields, faster impulse and turning speeds, additional rear beam and more missiles to shoot. These changes make the Starhammer V a force to be reckoned with.")
		starhammer_v_db:setKeyValue("Class","Corvette")
		starhammer_v_db:setKeyValue("Sub-class","Destroyer")
		starhammer_v_db:setKeyValue("Size","200")
		starhammer_v_db:setKeyValue("Shield","450/350/250/250/350")
		starhammer_v_db:setKeyValue("Hull","200")
		starhammer_v_db:setKeyValue("Move speed","3.9 U/min")
		starhammer_v_db:setKeyValue("Turn speed","15.0 deg/sec")
		starhammer_v_db:setKeyValue("Jump Range","5 - 50 U")
		starhammer_v_db:setKeyValue("Beam weapon -10:60","11.0 Dmg / 8.0 sec")
		starhammer_v_db:setKeyValue("Beam weapon 10:60","11.0 Dmg / 8.0 sec")
		starhammer_v_db:setKeyValue("Beam weapon -20:60","11.0 Dmg / 8.0 sec")
		starhammer_v_db:setKeyValue("Beam weapon 20:60","11.0 Dmg / 8.0 sec")
		starhammer_v_db:setKeyValue("Beam weapon 180:60","11.0 Dmg / 8.0 sec")
		starhammer_v_db:setKeyValue("Tube 0","10 sec")
		starhammer_v_db:setKeyValue(" Tube 0","10 sec")
		starhammer_v_db:setKeyValue("Storage Homing","16")
		starhammer_v_db:setKeyValue("Storage EMP","2")
		starhammer_v_db:setKeyValue("Storage HVLI","36")
		starhammer_v_db:setImage("radar_dread.png")
		--]]
	end
	return ship		
end
function tyr(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Battlestation"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Tyr")
	ship:setImpulseMaxSpeed(50)									--faster impulse (vs 30)
	ship:setRotationMaxSpeed(10)								--faster maneuver (vs 1.5)
	ship:setShieldsMax(400, 300, 300, 400, 300, 300)			--stronger shields (vs 300, 300, 300, 300, 300)
	ship:setShields(400, 300, 300, 400, 300, 300)					
	ship:setHullMax(100)										--stronger hull (vs 70)
	ship:setHull(100)
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,	90,	  -60,	2500,		6,		 8)	--stronger beams, broader coverage
	ship:setBeamWeapon(1,	90,	 -120,	2500,		6,		 8)
	ship:setBeamWeapon(2,	90,	   60,	2500,		6,		 8)
	ship:setBeamWeapon(3,	90,	  120,	2500,		6,		 8)
	ship:setBeamWeapon(4,	90,	  -60,	2500,		6,		 8)
	ship:setBeamWeapon(5,	90,	 -120,	2500,		6,		 8)
	ship:setBeamWeapon(6,	90,	   60,	2500,		6,		 8)
	ship:setBeamWeapon(7,	90,	  120,	2500,		6,		 8)
	ship:setBeamWeapon(8,	90,	  -60,	2500,		6,		 8)
	ship:setBeamWeapon(9,	90,	 -120,	2500,		6,		 8)
	ship:setBeamWeapon(10,	90,	   60,	2500,		6,		 8)
	ship:setBeamWeapon(11,	90,	  120,	2500,		6,		 8)
	local tyr_db = queryScienceDatabase("Ships","Dreadnought","Tyr")
	if tyr_db == nil then
		local corvette_db = queryScienceDatabase("Ships","Dreadnought")
		corvette_db:addEntry("Tyr")
		tyr_db = queryScienceDatabase("Ships","Dreadnought","Tyr")
		addShipToDatabase(
			queryScienceDatabase("Ships","Dreadnought","Battlestation"),	--base ship database entry
			tyr_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Tyr is the shipyard's answer to admiral konstatz' casual statement that the Battlestation model was too slow to be effective. The shipyards improved on the Battlestation by fitting the Tyr with more than twice the impulse speed and more than six times the turn speed. They threw in stronger shields and hull and wider beam coverage just to show that they could",
			nil,
			"5 - 50 U"		--jump range
		)
		--[[
		tyr_db:setLongDescription("The Tyr is the shipyard's answer to admiral konstatz' casual statement that the Battlestation model was too slow to be effective. The shipyards improved on the Battlestation by fitting the Tyr with more than twice the impulse speed and more than six times the turn speed. They threw in stronger shields and hull and wider beam coverage just to show that they could")
		tyr_db:setKeyValue("Class","Dreadnought")
		tyr_db:setKeyValue("Sub-class","Assault")
		tyr_db:setKeyValue("Size","200")
		tyr_db:setKeyValue("Shield","400/300/300/400/300/300")
		tyr_db:setKeyValue("Hull","100")
		tyr_db:setKeyValue("Move speed","3.0 U/min")
		tyr_db:setKeyValue("Turn speed","10.0 deg/sec")
		tyr_db:setKeyValue("Jump Range","5 - 50 U")
		tyr_db:setKeyValue("Beam weapon -60:90","8.0 Dmg / 6.0 sec")
		tyr_db:setKeyValue("Beam weapon -120:90","8.0 Dmg / 6.0 sec")
		tyr_db:setKeyValue("Beam weapon 60:90","8.0 Dmg / 6.0 sec")
		tyr_db:setKeyValue("Beam weapon 120:90","8.0 Dmg / 6.0 sec")
		tyr_db:setKeyValue(" Beam weapon -60:90","8.0 Dmg / 6.0 sec")
		tyr_db:setKeyValue(" Beam weapon -120:90","8.0 Dmg / 6.0 sec")
		tyr_db:setKeyValue(" Beam weapon 60:90","8.0 Dmg / 6.0 sec")
		tyr_db:setKeyValue(" Beam weapon 120:90","8.0 Dmg / 6.0 sec")
		tyr_db:setKeyValue("  Beam weapon -60:90","8.0 Dmg / 6.0 sec")
		tyr_db:setKeyValue("  Beam weapon -120:90","8.0 Dmg / 6.0 sec")
		tyr_db:setKeyValue("  Beam weapon 60:90","8.0 Dmg / 6.0 sec")
		tyr_db:setKeyValue("  Beam weapon 120:90","8.0 Dmg / 6.0 sec")
		tyr_db:setImage("radar_battleship.png")
		--]]
	end
	return ship
end
function gnat(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone"):orderRoaming()
	ship:setTypeName("Gnat")
	ship:setHullMax(15)					--weaker hull (vs 30)
	ship:setHull(15)
	ship:setImpulseMaxSpeed(140)		--faster impulse (vs 120)
	ship:setRotationMaxSpeed(25)		--faster maneuver (vs 10)
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,   40,		0,	 600,		4,		 3)	--weaker (vs 6) beam
	local gnat_db = queryScienceDatabase("Ships","No Class","Gnat")
	if gnat_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		no_class_db:addEntry("Gnat")
		gnat_db = queryScienceDatabase("Ships","No Class","Gnat")
		addShipToDatabase(
			queryScienceDatabase("Ships","No Class","Gnat"),	--base ship database entry
			gnat_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Gnat is a nimbler version of the Ktlitan Drone. It's got half the hull, but it moves and turns faster",
			nil,
			nil		--jump range
		)
	end
	return ship
end
function cucaracha(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Tug"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Cucaracha")
	ship:setShieldsMax(200, 50, 50, 50, 50, 50)		--stronger shields (vs 20)
	ship:setShields(200, 50, 50, 50, 50, 50)					
	ship:setHullMax(100)							--stronger hull (vs 50)
	ship:setHull(100)
	ship:setRotationMaxSpeed(20)					--faster maneuver (vs 10)
	ship:setAcceleration(30)						--faster acceleration (vs 15)
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,	60,	    0,	1500,		6,		10)	--extra rear facing beam
	local cucaracha_db = queryScienceDatabase("Ships","No Class","Cucaracha")
	if cucaracha_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		no_class_db:addEntry("Cucaracha")
		cucaracha_db = queryScienceDatabase("Ships","No Class","Cucaracha")
		addShipToDatabase(
			queryScienceDatabase("Ships","No Class","Cucaracha"),	--base ship database entry
			cucaracha_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Cucaracha is a quick ship built around the Tug model with heavy shields and a heavy beam designed to be difficult to squash",
			nil,
			nil		--jump range
		)
	end
	return ship
end
function starhammerIII(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Starhammer II"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Starhammer III")
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(4,	60,	  180,	1500,		8,		11)	--extra rear facing beam
	ship:setTubeSize(0,"large")
	ship:setWeaponStorageMax("Homing",16)						--more (vs 4)
	ship:setWeaponStorage("Homing", 16)		
	ship:setWeaponStorageMax("HVLI",36)							--more (vs 20)
	ship:setWeaponStorage("HVLI", 36)
	local starhammer_iii_db = queryScienceDatabase("Ships","Corvette","Starhammer III")
	if starhammer_iii_db == nil then
		local corvette_db = queryScienceDatabase("Ships","Corvette")
		corvette_db:addEntry("Starhammer III")
		starhammer_iii_db = queryScienceDatabase("Ships","Corvette","Starhammer III")
		addShipToDatabase(
			queryScienceDatabase("Ships","Corvette","Starhammer III"),	--base ship database entry
			starhammer_iii_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The designers of the Starhammer III took the Starhammer II and added a rear facing beam, enlarged one of the missile tubes and added more missiles to fire",
			{
				{key = "Large tube 0", value = "10 sec"},	--torpedo tube direction and load speed
				{key = "Tube 0", value = "10 sec"},			--torpedo tube direction and load speed
			},
			"5 - 50 U"		--jump range
		)
	end
	return ship
end
function k2breaker(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Breaker"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("K2 Breaker")
	ship:setHullMax(200)							--stronger hull (vs 120)
	ship:setHull(200)
	ship:setWeaponTubeCount(3)						--more (vs 1)
	ship:setTubeSize(0,"large")						--large (vs normal)
	ship:setWeaponTubeDirection(1,-30)				
	ship:setWeaponTubeDirection(2, 30)
	ship:setWeaponTubeExclusiveFor(0,"HVLI")		--only HVLI (vs any)
	ship:setWeaponStorageMax("Homing",16)			--more (vs 0)
	ship:setWeaponStorage("Homing", 16)
	ship:setWeaponStorageMax("HVLI",8)				--more (vs 5)
	ship:setWeaponStorage("HVLI", 8)
	local k2_breaker_db = queryScienceDatabase("Ships","No Class","K2 Breaker")
	if k2_breaker_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		no_class_db:addEntry("K2 Breaker")
		k2_breaker_db = queryScienceDatabase("Ships","No Class","K2 Breaker")
		addShipToDatabase(
			queryScienceDatabase("Ships","No Class","K2 Breaker"),	--base ship database entry
			k2_breaker_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The K2 Breaker designers took the Ktlitan Breaker and beefed up the hull, added two bracketing tubes, enlarged the center tube and added more missiles to shoot. Should be good for a couple of enemy ships",
			{
				{key = "Large tube 0", value = "13 sec"},	--torpedo tube direction and load speed
				{key = "Tube -30", value = "13 sec"},		--torpedo tube direction and load speed
				{key = "Tube 30", value = "13 sec"},		--torpedo tube direction and load speed
			},
			nil
		)
	end
	return ship
end
function hurricane(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Piranha F8"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Hurricane")
	ship:setJumpDrive(true)
	ship:setJumpDriveRange(5000,40000)			
	ship:setWeaponTubeCount(8)						--more (vs 3)
	ship:setWeaponTubeExclusiveFor(1,"HVLI")		--only HVLI (vs any)
	ship:setWeaponTubeDirection(1,  0)				--forward (vs -90)
	ship:setTubeSize(3,"large")						
	ship:setWeaponTubeDirection(3,-90)
	ship:setTubeSize(4,"small")
	ship:setWeaponTubeExclusiveFor(4,"Homing")
	ship:setWeaponTubeDirection(4,-15)
	ship:setTubeSize(5,"small")
	ship:setWeaponTubeExclusiveFor(5,"Homing")
	ship:setWeaponTubeDirection(5, 15)
	ship:setWeaponTubeExclusiveFor(6,"Homing")
	ship:setWeaponTubeDirection(6,-30)
	ship:setWeaponTubeExclusiveFor(7,"Homing")
	ship:setWeaponTubeDirection(7, 30)
	ship:setWeaponStorageMax("Homing",24)			--more (vs 5)
	ship:setWeaponStorage("Homing", 24)
	local hurricane_db = queryScienceDatabase("Ships","Frigate","Hurricane")
	if hurricane_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Hurricane")
		hurricane_db = queryScienceDatabase("Ships","Frigate","Hurricane")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Hurricane"),	--base ship database entry
			hurricane_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Hurricane is designed to jump in and shower the target with missiles. It is based on the Piranha F8, but with a jump drive, five more tubes in various directions and sizes and lots more missiles to shoot",
			{
				{key = "Large tube 0", value = "12 sec"},	--torpedo tube direction and load speed
				{key = "Tube 0", value = "12 sec"},			--torpedo tube direction and load speed
				{key = "Large tube 90", value = "12 sec"},	--torpedo tube direction and load speed
				{key = "Large tube -90", value = "12 sec"},	--torpedo tube direction and load speed
				{key = "Small tube -15", value = "12 sec"},	--torpedo tube direction and load speed
				{key = "Small tube 15", value = "12 sec"},	--torpedo tube direction and load speed
				{key = "Tube -30", value = "12 sec"},		--torpedo tube direction and load speed
				{key = "Tube 30", value = "12 sec"},		--torpedo tube direction and load speed
			},
			"5 - 40 U"		--jump range
		)
	end
	return ship
end
function phobosT4(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Phobos T4")
	ship:setRotationMaxSpeed(20)								--faster maneuver (vs 10)
	ship:setShieldsMax(80,30)									--stronger shields (vs 50,40)
	ship:setShields(80,30)					
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,	90,	  -15,	1500,		6,		6)	--longer (vs 1200), faster (vs 8)
	ship:setBeamWeapon(1,	90,	   15,	1500,		6,		6)	
	local phobos_t4_db = queryScienceDatabase("Ships","Frigate","Phobos T4")
	if phobos_t4_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Phobos T4")
		phobos_t4_db = queryScienceDatabase("Ships","Frigate","Phobos T4")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
			phobos_t4_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Phobos T4 makes some simple improvements on the Phobos T3: faster maneuver, stronger front shields, though weaker rear shields and longer and faster beam weapons",
			{
				{key = "Tube -1", value = "60 sec"},	--torpedo tube direction and load speed
				{key = "Tube 1", value = "60 sec"},		--torpedo tube direction and load speed
			},
			nil		--jump range
		)
	end
	return ship
end

function addShipToDatabase(base_db,modified_db,ship,description,tube_directions,jump_range)
	modified_db:setLongDescription(description)
	modified_db:setImage(base_db:getImage())
	modified_db:setKeyValue("Class",base_db:getKeyValue("Class"))
	modified_db:setKeyValue("Sub-class",base_db:getKeyValue("Sub-class"))
	modified_db:setKeyValue("Size",base_db:getKeyValue("Size"))
	local shields = ship:getShieldCount()
	if shields > 0 then
		local shield_string = ""
		for i=1,shields do
			if shield_string == "" then
				shield_string = string.format("%i",math.floor(ship:getShieldMax(i-1)))
			else
				shield_string = string.format("%s/%i",shield_string,math.floor(ship:getShieldMax(i-1)))
			end
		end
		modified_db:setKeyValue("Shield",shield_string)
	end
	modified_db:setKeyValue("Hull",string.format("%i",math.floor(ship:getHullMax())))
	modified_db:setKeyValue("Move speed",string.format("%.1f u/min",ship:getImpulseMaxSpeed()*60/1000))
	modified_db:setKeyValue("Turn speed",string.format("%.1f deg/sec",ship:getRotationMaxSpeed()))
	if ship:hasJumpDrive() then
		if jump_range == nil then
			local base_jump_range = base_db:getKeyValue("Jump range")
			if base_jump_range ~= nil and base_jump_range ~= "" then
				modified_db:setKeyValue("Jump range",base_jump_range)
			else
				modified_db:setKeyValue("Jump range","5 - 50 u")
			end
		else
			modified_db:setKeyValue("Jump range",jump_range)
		end
	end
	if ship:hasWarpDrive() then
		modified_db:setKeyValue("Warp Speed",string.format("%.1f u/min",ship:getWarpSpeed()*60/1000))
	end
	local key = ""
	if ship:getBeamWeaponRange(0) > 0 then
		local bi = 0
		repeat
			local beam_direction = ship:getBeamWeaponDirection(bi)
			if beam_direction > 315 and beam_direction < 360 then
				beam_direction = beam_direction - 360
			end
			key = string.format("Beam weapon %i:%i",ship:getBeamWeaponDirection(bi),ship:getBeamWeaponArc(bi))
			while(modified_db:getKeyValue(key) ~= "") do
				key = " " .. key
			end
			modified_db:setKeyValue(key,string.format("%.1f Dmg / %.1f sec",ship:getBeamWeaponDamage(bi),ship:getBeamWeaponCycleTime(bi)))
			bi = bi + 1
		until(ship:getBeamWeaponRange(bi) < 1)
	end
	local tubes = ship:getWeaponTubeCount()
	if tubes > 0 then
		if tube_directions ~= nil then
			for i=1,#tube_directions do
				modified_db:setKeyValue(tube_directions[i].key,tube_directions[i].value)
			end
		end
		local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for _, missile_type in ipairs(missile_types) do
			local max_storage = ship:getWeaponStorageMax(missile_type)
			if max_storage > 0 then
				modified_db:setKeyValue(string.format("Storage %s",missile_type),string.format("%i",max_storage))
			end
		end
	end
end

---------------------------
-- Statistical functions --
---------------------------
function detailedStats()
	print("Friendly")
	print("  Stations")
	print("    Survived")
	local friendlySurvivalValue = 0
	for _, station in ipairs(stationList) do
		if station:isValid() then
			if station:isFriendly(getPlayerShip(-1)) then
				print(string.format("      %2d %s",station.strength,station:getCallSign()))
				friendlySurvivalValue = friendlySurvivalValue + station.strength
			end
		end
	end
	print(string.format("     %3d = Total value of friendly stations that survived",friendlySurvivalValue))
	print("    Destroyed")
	local friendlyDestructionValue = 0
	for i=1,#friendlyStationDestroyedNameList do
		print(string.format("      %2d %s",friendlyStationDestroyedValue[i],friendlyStationDestroyedNameList[i]))
		friendlyDestructionValue = friendlyDestructionValue + friendlyStationDestroyedValue[i]
	end
	print(string.format("     %3d = Total value of friendly stations that were destroyed",friendlyDestructionValue))
	print("  Military vessels")
	print("    Survived")
	local friendlyShipSurvivedValue = 0
	for j=1,#friendlyFleetList do
		tempFleet = friendlyFleetList[j]
		for _, tempFriend in ipairs(tempFleet) do
			if tempFriend ~= nil and tempFriend:isValid() then
				local friend_type = tempFriend:getTypeName()
				print(string.format("      %3d %s %s",ship_template[friend_type].strength,tempFriend:getCallSign(),friend_type))
				friendlyShipSurvivedValue = friendlyShipSurvivedValue + ship_template[friend_type].strength
			end
		end
	end
	print(string.format("     %3d = total value of friendly military vessels that survived",friendlyShipSurvivedValue))
	print("    Destroyed")
	print("Independent")
	print("  Stations")
	print("    Survived")
	local neutralSurvivalValue = 0
	for _, station in ipairs(stationList) do
		if not station:isFriendly(getPlayerShip(-1)) and not station:isEnemy(getPlayerShip(-1))then
			if station:isValid() then
				print(string.format("      %2d %s",station.strength,station:getCallSign()))
				neutralSurvivalValue = neutralSurvivalValue + station.strength
			end
		end
	end
	print(string.format("     %3d = Total value of neutral stations that survived",neutralSurvivalValue))
	print("    Destroyed")
	local neutralDestroyedValue = 0
	for i=1,#neutralStationDestroyedNameList do
		print(string.format("      %2d %s",neutralStationDestroyedValue[i],neutralStationDestroyedNameList[i]))
		neutralDestroyedValue = neutralDestroyedValue + neutralStationDestroyedValue[i]
	end
	print(string.format("     %3d = Total value of neutral stations that were destoyed",neutralDestroyedValue))
	print("Enemy")
	print("  Stations")
	print("    Survived")
	local enemySurvivalValue = 0
	for _, station in ipairs(stationList) do
		if station:isEnemy(getPlayerShip(-1))then
			if station:isValid() then
				print(string.format("      %2d %s",station.strength,station:getCallSign()))
				enemySurvivalValue = enemySurvivalValue + station.strength
			end
		end
	end
	print(string.format("     %3d = Total value of enemy stations that survived",enemySurvivalValue))
	print("    Destroyed")
	local enemyDestroyedValue = 0
	for i=1,#enemyStationDestroyedNameList do
		print(string.format("      %2d %s",enemyStationDestroyedValue[i],enemyStationDestroyedNameList[i]))
		enemyDestroyedValue = enemyDestroyedValue + enemyStationDestroyedValue[i]
	end
	print(string.format("     %3d = Total value of enemy stations that were destroyed",enemyDestroyedValue))
	print("  Military vessels")
	print("    Survived")
	local enemyShipSurvivedValue = 0
	for j=1,#enemyFleetList do
		tempFleet = enemyFleetList[j]
		for _, tempEnemy in ipairs(tempFleet) do
			if tempEnemy ~= nil and tempEnemy:isValid() then
				local enemy_type = tempEnemy:getTypeName()
				print(string.format("      %3d %s %s",ship_template[enemy_type].strength,tempEnemy:getCallSign(),enemy_type))
				enemyShipSurvivedValue = enemyShipSurvivedValue + ship_template[enemy_type].strength
			end
		end
	end
	print(string.format("     %3d = total value of enemy military vessels that survived",enemyShipSurvivedValue))
	print("    Destroyed")
end
function gatherStats()
	local stat_list = {}
	stat_list.scenario = {name = "Borderline Fever", version = scenario_version}
	stat_list.times = {}
	stat_list.times.stage = game_state
	stat_list.times.threshold = destructionDifferenceEndCondition
	if playWithTimeLimit then
		stat_list.times.game = {}
		stat_list.times.game.max = defaultGameTimeLimitInMinutes*60
		stat_list.times.game.total_seconds_left = gameTimeLimit
		stat_list.times.game.minutes_left = math.floor(gameTimeLimit / 60)
		stat_list.times.game.seconds_left = math.floor(gameTimeLimit % 60)
	end
	stat_list.human = {}
	stat_list.human.station = {}
	stat_list.human.station.count = 0
	stat_list.human.station.value = 0
	stat_list.human.station.original_count = 0
	stat_list.human.station.original_value = 0
	stat_list.human.ship = {}
	stat_list.human.ship.value = 0
	stat_list.human.ship.original_value = rawHumanShipStrength
	stat_list.human.weight = {}
	stat_list.human.weight.station = friendlyStationComponentWeight
	stat_list.human.weight.ship = friendlyShipComponentWeight
	stat_list.human.weight.neutral = neutralStationComponentWeight
	stat_list.kraylor = {}
	stat_list.kraylor.station = {}
	stat_list.kraylor.station.count = 0
	stat_list.kraylor.station.value = 0
	stat_list.kraylor.station.original_count = 0
	stat_list.kraylor.station.original_value = 0
	stat_list.kraylor.ship = {}
	stat_list.kraylor.ship.value = 0
	stat_list.kraylor.ship.original_value = rawKraylorShipStrength
	stat_list.kraylor.weight = {}
	stat_list.kraylor.weight.station = enemyStationComponentWeight
	stat_list.kraylor.weight.ship = enemyShipComponentWeight
	stat_list.independent = {}
	stat_list.independent.station = {}
	stat_list.independent.station.count = 0
	stat_list.independent.station.value = 0
	stat_list.independent.station.original_count = 0
	stat_list.independent.station.original_value = 0
	if stationList ~= nil and #stationList > 0 then
		for _, station in ipairs(stationList) do
			if station:isValid() then
				if station:getFaction() == "Human Navy" then
					stat_list.human.station.count = stat_list.human.station.count + 1
					stat_list.human.station.value = stat_list.human.station.value + station.strength
				end
				if station:getFaction() == "Kraylor" then
					stat_list.kraylor.station.count = stat_list.kraylor.station.count + 1
					stat_list.kraylor.station.value = stat_list.kraylor.station.value + station.strength
				end
				if station:getFaction() == "Independent" then
					stat_list.independent.station.count = stat_list.independent.station.count + 1
					stat_list.independent.station.value = stat_list.independent.station.value + station.strength
				end
			end
		end
		if original_human_station_count == nil then
			original_human_station_count = stat_list.human.station.count
		end
		stat_list.human.station.original_count = original_human_station_count
		if original_human_station_value == nil then
			original_human_station_value = stat_list.human.station.value
		end
		stat_list.human.station.original_value = original_human_station_value
		if original_kraylor_station_count == nil then
			original_kraylor_station_count = stat_list.kraylor.station.count
		end
		stat_list.kraylor.station.original_count = original_kraylor_station_count
		if original_kraylor_station_value == nil then
			original_kraylor_station_value = stat_list.kraylor.station.value
		end
		stat_list.kraylor.station.original_value = original_kraylor_station_value
		if original_independent_station_count == nil then
			original_independent_station_count = stat_list.independent.station.count
		end
		stat_list.independent.station.original_count = original_independent_station_count
		if original_independent_station_value == nil then
			original_independent_station_value = stat_list.independent.station.value
		end
		stat_list.independent.station.original_value = original_independent_station_value
	end
	if stat_list.human.station.original_value > 0 then
		stat_list.human.station.percentage = stat_list.human.station.value/stat_list.human.station.original_value*100
	else
		stat_list.human.station.percentage = 100
	end
	if stat_list.kraylor.station.original_value > 0 then
		stat_list.kraylor.station.percentage = stat_list.kraylor.station.value/stat_list.kraylor.station.original_value*100
	else
		stat_list.kraylor.station.percentage = 100
	end
	if stat_list.independent.station.original_value > 0 then
		stat_list.independent.station.percentage = stat_list.independent.station.value/stat_list.independent.station.original_value*100
	else
		stat_list.independent.station.percentage = 100
	end
	if friendlyFleetList ~= nil and #friendlyFleetList > 0 then
		for _, temp_fleet in ipairs(friendlyFleetList) do
			for _, temp_friend in ipairs(temp_fleet) do
				if temp_friend ~= nil and temp_friend:isValid() then
					stat_list.human.ship.value = stat_list.human.ship.value + ship_template[temp_friend:getTypeName()].strength
				end
			end
		end
	end
	if enemyFleetList ~= nil and #enemyFleetList > 0 then
		for _, temp_fleet in ipairs(enemyFleetList) do
			for _, temp_enemy in ipairs(temp_fleet) do
				if temp_enemy ~= nil and temp_enemy:isValid() then
					stat_list.kraylor.ship.value = stat_list.kraylor.ship.value + ship_template[temp_enemy:getTypeName()].strength
				end
			end
		end
	end
	if stat_list.human.ship.original_value ~= nil and stat_list.human.ship.original_value > 0 then
		stat_list.human.ship.percentage = stat_list.human.ship.value/stat_list.human.ship.original_value*100
	else
		stat_list.human.ship.percentage = 100
	end
	if stat_list.kraylor.ship.original_value ~= nil and stat_list.kraylor.ship.original_value > 0 then
		stat_list.kraylor.ship.percentage = stat_list.kraylor.ship.value/stat_list.kraylor.ship.original_value*100
	else
		stat_list.kraylor.ship.percentage = 100
	end
--	stat_list.kraylor.evaluation = stat_list.kraylor.station.percentage * stat_list.kraylor.weight.station + stat_list.kraylor.ship.percentage * stat_list.kraylor.weight.ship
--	stat_list.human.evaluation = stat_list.human.station.percentage * stat_list.human.weight.station + stat_list.independent.station.percentage * stat_list.human.weight.neutral + stat_list.human.ship.percentage * stat_list.human.weight.ship
	return stat_list
end
function updateInner(delta)
	if delta == 0 then
		--game paused
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.pidx == nil then
				p.pidx = pidx
				setPlayer(p)
			end
		end
		return
	end
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.pidx == nil then
				p.pidx = pidx
				setPlayer(p)
			end
		end
	end
	if mainPlot ~= nil then
		mainPlot(delta)
	end
	if spicePlot ~= nil then
		spicePlot(delta)
	end
	if spelunkPlot ~= nil then
		spelunkPlot(delta)
	end
	if transportPlot ~= nil then
		transportPlot(delta)
	end
	if plotH ~= nil then	--health
		plotH(delta)
	end
	if plotCI ~= nil then	--cargo inventory
		plotCI(delta)
	end
	if plotRevert ~= nil then
		plotRevert(delta)
	end
	if plotContinuum ~= nil then
		plotContinuum(delta)
	end
end
function update(delta)
    local status,error=pcall(updateInner,delta)
    if not status then
		print("script error : - ")
		print(error)
		if popupGMDebug == "once" or popupGMDebug == "always" then
			if popupGMDebug == "once" then
				popupGMDebug = "never"
			end
			addGMMessage("script error - \n"..error)
		end
    end
end

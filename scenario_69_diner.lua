-- Name: Moe's Diner
-- Description: After years of saving your credits, you and your friends called in your last favors and have acquired an MP52 Hornet from surplus military supplies. It's small, but in good condition apart from a faulty impulse engine. The Hornet has two impulse engines. You're running on just one. Your friend Edward can fix the engine. He works at Moe's Diner. So, you are going there to get your impulse engine repaired and thus make your ship fully functional.
--- 
--- Mission designed as a single hornet ship mission for relatively new players. 
--- The broad outlines of the mission are the same each time, 
--- but some of the specifics vary for each mission run.
---
--- Duration: Subjective. There is a moment where victory is declared, but the scenario is primarily an exercise 
---
--- Version 1
-- Type: Replayable Mission
-- Setting[Enemies]: Choose the relative strength of the enemies
-- Enemies[Easy]: Relatively weak and/or few enemies
-- Enemies[Normal|Default]: Enemies balanced for the player ship
-- Enemies[Hard]: Stronger and/or more enemies
-- Enemies[Extreme]: Much stronger and/or far more enemies
-- Enemies[Quixotic]: Enemies almost guaranteed to be overwhelming
-- Setting[Murphy]: Choose the impact of random factors facing the players according to Murphy's law
-- Murphy[Easy]: Random factors generally favor the players
-- Murphy[Normal|Default]: A normal balance of random factors
-- Murphy[Hard]: Random factors are generally against the players

require("utils.lua")
require("place_station_scenario_utility.lua")
require("cpu_ship_diversification_scenario_utility.lua")
require("generate_call_sign_scenario_utility.lua")

--------------------
-- Initialization --
--------------------
function init()
	scenario_version = "1.0.1"
	print(string.format("     -----     Scenario: Diner     -----     Version %s     -----",scenario_version))
	print(_VERSION)
	marauder_diagnostic = false
	edward_talk_diagnostic = false
	planet_diagnostic = false
	setVariations()
	setConstants()	--missle type names, template names and scores, deployment directions, player ship names, etc.
	constructEnvironment()
	primaryOrders = "You have no formal orders. Your ship was obtained as military surplus. It identifies as part of the Human Navy but you and your crew are not part of any military command structure.\n\nHowever, you may contact members of the Human Navy and you may participate in actions against common enemies should you feel so motivated."
	secondaryOrders = ""
	optionalOrders = ""
	mainGMButtons()
end
function setPlayer(p)
	if p == nil then
		return
	end
	p:setTemplate("MP52 Hornet")
	p:setImpulseMaxSpeed(50)	--less (vs 125)
	p:setRepairCrewCount(2)		--more (vs 1)
	p.maxRepairCrew = p:getRepairCrewCount()
	p.shipScore = playerShipStats["MP52 Hornet"].strength 
	p.maxCargo = playerShipStats["MP52 Hornet"].cargo
	p:setLongRangeRadarRange(playerShipStats["MP52 Hornet"].long_range_radar)
	p:setShortRangeRadarRange(playerShipStats["MP52 Hornet"].short_range_radar)
	p.tractor = playerShipStats["MP52 Hornet"].tractor
	p.mining = playerShipStats["MP52 Hornet"].mining
	local name = tableRemoveRandom(player_ship_names)
	if name ~= nil then
		p:setCallSign(name)
	end
	p.cargo = p.maxCargo
	p.initialCoolant = p:getMaxCoolant()	
	p:addToShipLog(string.format("You and your associates on %s, a %s class vessel, are going to Moe's Diner to meet your friend, Edward to get your second impulse engine working. Be careful. There are many unscrupulous ship operators around here.",p:getCallSign(),p:getTypeName()),"Magenta")
end
function setVariations()
	if getScenarioSetting == nil then
		difficulty = 1
	else
		local enemy_config = {
			["Easy"] =		{number = .5},
			["Normal"] =	{number = 1},
			["Hard"] =		{number = 2},
			["Extreme"] =	{number = 3},
			["Quixotic"] =	{number = 5},
		}
		enemy_power =	enemy_config[getScenarioSetting("Enemies")].number
		local murphy_config = {
			["Easy"] =		{number = .5,	rep = 70,	adverse = .999,	lose_coolant = .99999,	gain_coolant = .005},
			["Normal"] =	{number = 1,	rep = 50,	adverse = .995,	lose_coolant = .99995,	gain_coolant = .001},
			["Hard"] =		{number = 2,	rep = 30,	adverse = .99,	lose_coolant = .9999,	gain_coolant = .0001},
		}
		difficulty =	murphy_config[getScenarioSetting("Murphy")].number
--		adverseEffect =	murphy_config[getScenarioSetting("Murphy")].adverse
--		coolant_loss =	murphy_config[getScenarioSetting("Murphy")].lose_coolant
--		coolant_gain =	murphy_config[getScenarioSetting("Murphy")].gain_coolant
--		starting_rep =	murphy_config[getScenarioSetting("Murphy")].rep
	end
end
function setConstants()
	player_found_exuari_base = false
	playerFoundExuariBasePlot = checkPlayerProximity
	upgrade_player_ship = false
	healthCheckTimerInterval = 8
	healthCheckTimer = healthCheckTimerInterval
	buzzer_timer_interval = 200
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
		"Thorny",
		"Streak",
		"Flit",
		"Bzzt",
		"Slip",
		"Quest",
		"Zip",
		"Stinger",
		"Sphex",
		"Vespa",
		"Bembicini",
		"Polyturator",
		"Urocerus",
		"Fervida",
	}
	rescue_freighter_names = {
		"Turbid",
		"Latorva",
		"Quelten",
		"Venus",
		"Norma",
		"Desire",
		"Traipse",
		"Strand",
		"Elanor",
		"Cat Scratch",
		"Bonita",
		"Scrape",
		"Filly",
		"Justine",
		"Jordan",
		"Float",
		"Floria",
		"Tillie",
		"Yemen",
		"Trousseau",
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
end
function constructEnvironment()
	patrol_convinced = false
	patrolConvincedPlot = patrolVisualCheck
	friendly_neutral_stations = {}
	transport_stations = {}
--	Spawn Moe's Diner
	diner_station = SpaceStation():setTemplate("Small Station"):setCommsScript(""):setCommsFunction(commsStation):setFaction("Human Navy")
	diner_station.comms_data = {
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
			luxury = {
				quantity =	5,	
				cost =		math.random(40,60),
			},
			food = {
				quantity =	5,
				cost =		1,
			},
		},
		trade = {	
			food =			false, 
			medicine =		false, 
			luxury =		false,
		},
		description = "A convenient place to fuel your ship and get a bit to eat", 
		general = "", 
		history = "",
	}
	diner_station:setCallSign("Moe's Diner"):setDescription("A convenient place to fuel your ship and get a bite to eat")
	impulse_repaired = false
	diner_x = random(-20000,20000)
	diner_y = random(-20000,20000)
	diner_station:setPosition(diner_x,diner_y)
	diner_station:onTakingDamage(dinerDamage)
	place_space = {}
	table.insert(friendly_neutral_stations,diner_station)
	table.insert(transport_stations,diner_station)
	table.insert(place_space,{obj=diner_station,dist=300})
--	Spawn player
	local p = PlayerSpaceship():setTemplate("MP52 Hornet")
	p:onTakingDamage(playerDamage)
	p.pidx = 1
	setPlayer(p)
	approach_angle = random(0,360)
	approach_distance = random(12000,18000)
	local player_start_x, player_start_y = vectorFromAngleNorth(approach_angle,approach_distance)
	p:setPosition(diner_x + player_start_x, diner_y + player_start_y)
	allowNewPlayerShips(false)
	table.insert(place_space,{obj=p,dist=100})
--	Debilitating marauders
	group_fleet = {}
	group_leaders = {}
	local group1_approach_angle = (approach_angle + 10) % 360
	local group1_start_x, group1_start_y = vectorFromAngleNorth(group1_approach_angle,approach_distance + 19000)
	group1_leader = CpuShip():setTemplate("MT52 Hornet"):setFaction("Exuari"):setCallSign(generateCallSign(nil,"Exuari")):orderAttack(p):setCommsScript(""):setCommsFunction(commsShip)
	group1_leader:setPosition(diner_x + group1_start_x, diner_y + group1_start_y):setHeading((group1_approach_angle + 180) % 360):onDestroyed(enemyVesselDestroyed)
	group1_leader.original_acceleration = group1_leader:getAcceleration()
--						    Index, Arc,	  Dir,	Range, Cycle,	Damage
	group1_leader:setBeamWeapon(0,	30,		0,	  900,	 3.5,	4.0)	--faster (vs 4), stronger (vs 2.5)
	group1_leader:setAcceleration(50):setAI("default")
	table.insert(place_space,{obj=group1_leader,dist=30})
	local group2_approach_angle = (approach_angle + 350) % 360
	local group2_start_x, group2_start_y = vectorFromAngleNorth(group2_approach_angle,approach_distance + 19000)
	group2_leader = CpuShip():setTemplate("MT52 Hornet"):setFaction("Exuari"):setCallSign(generateCallSign(nil,"Exuari")):orderAttack(p):setCommsScript(""):setCommsFunction(commsShip)
	group2_leader:setPosition(diner_x + group2_start_x, diner_y + group2_start_y):setHeading((group2_approach_angle + 180) % 360):onDestroyed(enemyVesselDestroyed)
	group2_leader.original_acceleration = group2_leader:getAcceleration()
--						    Index, Arc,	  Dir,	Range, Cycle,	Damage
	group2_leader:setBeamWeapon(0,	30,		0,	  900,	 3.5,	4.0)	--faster (vs 4), stronger (vs 2.5)
	group2_leader:setAcceleration(50):setAI("default")
	table.insert(place_space,{obj=group1_leader,dist=30})
	reset_leader_acceleration = 5
	local circle_angle_1 = group1_approach_angle
	local circle_angle_1_prime = 180
	local circle_angle_2 = group2_approach_angle
	local circle_angle_2_prime = 180
	table.insert(group_fleet,group1_leader)
	table.insert(group_leaders,group1_leader)
	table.insert(group_fleet,group2_leader)
	table.insert(group_leaders,group2_leader)
	for i=1,6 do
		local group1_follower = CpuShip():setTemplate("MU52 Hornet"):setFaction("Exuari"):setCommsScript(""):setCommsFunction(commsShip)
		group1_follower:setCallSign(generateCallSign(nil,"Exuari"))
		local form_x, form_y = vectorFromAngleNorth(circle_angle_1, 800)
		local form_prime_x, form_prime_y = vectorFromAngle(circle_angle_1_prime, 800)
		group1_follower:setPosition(diner_x + group1_start_x + form_x, diner_y + group1_start_y + form_y)
		group1_follower:setHeading((group1_approach_angle + 180) % 360):setAI("default")
		group1_follower:orderFlyFormation(group1_leader,form_prime_x,form_prime_y):onDestroyed(enemyVesselDestroyed)
		table.insert(group_fleet,group1_follower)
		circle_angle_1 = (circle_angle_1 + 60) % 360
		circle_angle_1_prime = (circle_angle_1_prime + 60) % 360
		table.insert(place_space,{obj=group1_follower,dist=30})
		local group2_follower = CpuShip():setTemplate("MU52 Hornet"):setFaction("Exuari")
		group2_follower:setCallSign(generateCallSign(nil,"Exuari"))
		form_x, form_y = vectorFromAngleNorth(circle_angle_2, 800)
		form_prime_x, form_prime_y = vectorFromAngle(circle_angle_2_prime, 800)
		group2_follower:setPosition(diner_x + group2_start_x + form_x, diner_y + group2_start_y + form_y)
		group2_follower:setHeading((group2_approach_angle + 180) % 360):setAI("default")
		group2_follower:orderFlyFormation(group2_leader,form_prime_x,form_prime_y):onDestroyed(enemyVesselDestroyed)
		table.insert(group_fleet,group2_follower)
		circle_angle_2 = (circle_angle_2 + 60) % 360
		circle_angle_2_prime = (circle_angle_2_prime + 60) % 360
		table.insert(place_space,{obj=group2_follower,dist=30})
	end
	marauder_state = 0
	--		leader			follower	(marauder state)
	--	0	attack player	fly formation
	--	1	attack player	attack player (alternatively diner/diner)
	--	2	blind retreat	blind retreat to base
	--	3	recover			recover
	marauderPlot = marauderAttackInFormation
--	Spawn marauder station and defenders
	marauder_x, marauder_y = vectorFromAngleNorth((approach_angle + 180 + random(-20,20)) % 360, random(35000,45000))
	marauder_x = marauder_x + diner_x
	marauder_y = marauder_y + diner_y
	marauder_station = dinerPlaceStation(marauder_x,marauder_y,"Sinister","Exuari")
	marauder_station:onDestroyed(winTheGame)
	local station_dist = {
		["Small Station"] = 300,
		["Medium Station"] = 1000,
		["Large Station"] = 1300,
		["Huge Station"] = 1500,
	}
	local station_defend_dist = {
		["Small Station"] = 2800,
		["Medium Station"] = 4200,
		["Large Station"] = 4800,
		["Huge Station"] = 5200,
	}
	table.insert(place_space,{obj=marauder_station,dist=station_defend_dist[marauder_station:getTypeName()]})
	marauder_defenders = {}
	for i=1,4 do
		local marauder_defender = CpuShip():setTemplate("Nirvana R5"):setFaction("Exuari"):setCallSign(generateCallSign(nil,"Exuari")):setPosition(marauder_x,marauder_y):orderDefendTarget(marauder_station):setCommsScript(""):setCommsFunction(commsShip):onDestroyed(enemyVesselDestroyed)
		table.insert(marauder_defenders,marauder_defender)
		marauder_defender = ship_template["Cucaracha"].create("Exuari","Cucaracha"):setPosition(marauder_x,marauder_y):setCallSign(generateCallSign(nil,"Exuari")):orderDefendTarget(marauder_station):setCommsScript(""):setCommsFunction(commsShip):onDestroyed(enemyVesselDestroyed)
		table.insert(marauder_defenders,marauder_defender)
	end
--	Spawn CUF repair station 
	local repair_station_angle = (approach_angle + random(60,120)) % 360
	repair_x, repair_y = vectorFromAngleNorth(repair_station_angle,random(15000,30000))
	local repair_station_names = {"Malthus","Skandar","Utopia Planitia","Vaiken","Maverick","Outpost-7","Outpost-33","Rubis","Valero"}
	repair_station = dinerPlaceStation(diner_x + repair_x, diner_y + repair_y, repair_station_names[math.random(1,#repair_station_names)], "CUF")
	table.insert(friendly_neutral_stations,repair_station)
	table.insert(transport_stations,repair_station)
	table.insert(place_space,{obj=repair_station,dist=station_defend_dist[repair_station:getTypeName()]})
	launchNewPatrol()
--	Spawn TSN shop station
	local shop_station_angle = (approach_angle + 360 - random(60,120)) % 360
	local shop_x, shop_y = vectorFromAngleNorth(shop_station_angle,random(15000,30000))
	local shop_station_names = {"Chatuchak","Madison","Jabba","Muddville","Nefatha","Organa"}
	shop_station = dinerPlaceStation(diner_x + shop_x, diner_y + shop_y, shop_station_names[math.random(1,#shop_station_names)], "TSN")
	table.insert(friendly_neutral_stations,shop_station)
	table.insert(transport_stations,shop_station)
	table.insert(place_space,{obj=shop_station,dist=station_dist[shop_station:getTypeName()]})
--	Spawn USN repair transport and Independent shop transport
	transport_list = {}
	local repair_transport_name = {"Flower","Orchid","Barsoom","Rutgard","Plinth","Rack"}
	local rvd_x, rvd_y = vectorFromAngleNorth(repair_station_angle,550)
	repair_transport = CpuShip():setTemplate("Equipment Freighter 1"):setFaction("USN"):setHeading(repair_station_angle):setCallSign(repair_transport_name[math.random(1,#repair_transport_name)]):setCommsScript(""):setCommsFunction(commsShip)
	repair_transport.home_station = repair_station
	repair_transport.normal_transport_plot = false
	repair_transport:setPosition(diner_x + rvd_x, diner_y + rvd_y):orderDock(diner_station):setScanState("simplescan")
	table.insert(transport_list,repair_transport)
	local shop_transport_name = {"Lark","Avian","Misanthrope","Pitfall","Garden","Troth","Entwine","Aware"}
	local svd_x, svd_y = vectorFromAngleNorth(shop_station_angle,550)
	shop_transport = CpuShip():setTemplate("Garbage Jump Freighter 3"):setFaction("Independent"):setHeading(shop_station_angle):setCallSign(shop_transport_name[math.random(1,#shop_transport_name)]):setCommsScript(""):setCommsFunction(commsShip)
	shop_transport.home_station = shop_station
	shop_transport.normal_transport_plot = false
	shop_transport:setPosition(diner_x + svd_x, diner_y + svd_y):orderDock(diner_station):setScanState("simplescan")
	table.insert(transport_list,shop_transport)
--	Spawn Independent mining station
	local mining_station_names = {"Grasberg","Impala","Outpost-15","Outpost-21","Krik","Krak","Kruk"}
	local mining_station_size = szt()
	local o_x = 0
	local o_y = 0
	local base_area_radius = 50000
	local area_radius = base_area_radius
	local compression_interval = 1000
	local mining_angle = random(0,360)
	repeat
		mining_angle = random(0,360)
		o_x, o_y = vectorFromAngle(mining_angle,random(0,area_radius))
		o_x = o_x + diner_x
		o_y = o_y + diner_y
		area_radius = area_radius + compression_interval
	until(farEnough(o_x,o_y,station_dist[mining_station_size],"Station"))
	mining_station = dinerPlaceStation(o_x, o_y, tableRemoveRandom(mining_station_names), "Independent", mining_station_size)
	table.insert(friendly_neutral_stations,mining_station)
	table.insert(transport_stations,mining_station)
	table.insert(place_space,{obj=mining_station,dist=station_dist[mining_station:getTypeName()]})
--	Spawn second mining station
	mining_station_size = szt()
	area_radius = base_area_radius
	local second_mining_angle = (mining_angle + 180) % 360
	repeat
		mining_angle = (second_mining_angle + random(-60,60) + 360) % 360
		o_x, o_y = vectorFromAngle(mining_angle,random(30000,area_radius))
		o_x = o_x + diner_x
		o_y = o_y + diner_y
		area_radius = area_radius + compression_interval
	until(farEnough(o_x,o_y,station_dist[mining_station_size],"Station"))
	second_mining_station = dinerPlaceStation(o_x, o_y, tableRemoveRandom(mining_station_names), "Independent", mining_station_size)
	table.insert(friendly_neutral_stations,second_mining_station)
	table.insert(transport_stations,second_mining_station)
	table.insert(place_space,{obj=second_mining_station,dist=station_dist[second_mining_station:getTypeName()]})
--	Spawn Black Hole
	area_radius = base_area_radius
	repeat
		o_x, o_y = vectorFromAngle(random(0,360),random(0,area_radius))
		o_x = o_x + diner_x
		o_y = o_y + diner_y
		area_radius = area_radius + compression_interval
	until(farEnough(o_x,o_y,6000))
	local bh = BlackHole():setPosition(o_x,o_y)
	table.insert(place_space,{obj=bh,dist=6000})
--	Spawn Planet
	area_radius = base_area_radius
	local planet_list = {
		{radius = random(600,1400), distance = random(-2500,-1400), 
			name = {"Gamma Piscium","Beta Lyporis","Sigma Draconis","Iota Carinae","Theta Arietis","Epsilon Indi","Beta Hydri"},
			color = {
				red = random(0.8,1), green = random(0.8,1), blue = random(0.8,1)
			},
			texture = {
				atmosphere = "planets/star-1.png"
			},
		},
		{radius = random(1700,3400), distance = random(-3500,-1200), rotation = random(200,350),
			name = {"Bespin","Aldea","Bersallis"},
			texture = {
				surface = "planets/gas-1.png"
			},
		},
		{radius = random(1700,3400), distance = random(-3500,-1200), rotation = random(200,350),
			name = {"Farius Prime","Deneb","Mordan"},
			texture = {
				surface = "planets/gas-2.png"
			},
		},
		{radius = random(1700,3400), distance = random(-3500,-1200), rotation = random(200,350),
			name = {"Kepler-7b","Alpha Omicron","Nelvana"},
			texture = {
				surface = "planets/gas-3.png"
			},
		},
		{radius = random(1500,2500), distance = random(-3100,-1200), rotation = random(350,500),
			name = {"Alderaan","Dagobah","Dantooine","Rigel"},
			color = {
				red = random(0,0.2), green = random(0,0.2), blue = random(0.8,1)
			},
			texture = {
				surface = "planets/planet-1.png", cloud = "planets/clouds-1.png", atmosphere = "planets/atmosphere.png"
			},
		},
		{radius = random(1500,2500), distance = random(-3100,-1200), rotation = random(350,500),
			name = {"Pahvo","Penthara","Scalos"},
			color = {
				red = random(0,0.2), green = random(0,0.2), blue = random(0.8,1)
			},
			texture = {
				surface = "planets/planet-4.png", cloud = "planets/clouds-3.png", atmosphere = "planets/atmosphere.png"
			},
		},
		{radius = random(1500,2500), distance = random(-3100,-1200), rotation = random(350,500),
			name = {"Tanuga","Vacca","Terlina","Timor"},
			color = {
				red = random(0,0.2), green = random(0,0.2), blue = random(0.8,1)
			},
			texture = {
				surface = "planets/planet-5.png", cloud = "planets/clouds-2.png", atmosphere = "planets/atmosphere.png"
			},
		},
	}
	local selected_planet_index = math.random(1,#planet_list)
	repeat
		o_x, o_y = vectorFromAngle(random(0,360),random(0,area_radius))
		o_x = o_x + diner_x
		o_y = o_y + diner_y
		area_radius = area_radius + compression_interval
	until(farEnough(o_x,o_y,planet_list[selected_planet_index].radius))
	local planet = Planet():setPosition(o_x,o_y):setPlanetRadius(planet_list[selected_planet_index].radius):setDistanceFromMovementPlane(planet_list[selected_planet_index].distance)
	planet:setCallSign(planet_list[selected_planet_index].name[math.random(1,#planet_list[selected_planet_index].name)])
	if planet_diagnostic then
		print("Planet index:",selected_planet_index,"name:",planet:getCallSign())
	end
	if planet_list[selected_planet_index].texture.surface ~= nil then
		planet:setPlanetSurfaceTexture(planet_list[selected_planet_index].texture.surface)
		if planet_diagnostic then
			print("    Surface texture:",planet_list[selected_planet_index].texture.surface)
		end
	end
	if planet_list[selected_planet_index].texture.atmosphere ~= nil then
		planet:setPlanetAtmosphereTexture(planet_list[selected_planet_index].texture.atmosphere)
		if planet_diagnostic then
			print("    Atmosphere texture:",planet_list[selected_planet_index].texture.atmosphere)
		end
	end
	if planet_list[selected_planet_index].texture.cloud ~= nil then
		planet:setPlanetCloudTexture(planet_list[selected_planet_index].texture.cloud)
		if planet_diagnostic then
			print("    Cloud texture:",planet_list[selected_planet_index].texture.cloud)
		end
	end
	if planet_list[selected_planet_index].color ~= nil then
		planet:setPlanetAtmosphereColor(planet_list[selected_planet_index].color.red,planet_list[selected_planet_index].color.green,planet_list[selected_planet_index].color.blue)
		if planet_diagnostic then
			print("    Atmosphere color (r,g,b):",planet_list[selected_planet_index].color.red,planet_list[selected_planet_index].color.green,planet_list[selected_planet_index].color.blue)
		end
	end
	if planet_list[selected_planet_index].rotation ~= nil then
		planet:setAxialRotationTime(planet_list[selected_planet_index].rotation)
		if planet_diagnostic then
			print("    Axial rotation time:",planet_list[selected_planet_index].rotation)
		end
	end
	table.insert(place_space,{obj=planet,dist=planet_list[selected_planet_index].radius})
--	Spawn Arlenian station
	local arlenian_station_size = szt()
	area_radius = base_area_radius
	repeat
		o_x, o_y = vectorFromAngle(random(0,360),random(0,area_radius))
		o_x = o_x + diner_x
		o_y = o_y + diner_y
		area_radius = area_radius + compression_interval
	until(farEnough(o_x,o_y,station_dist[arlenian_station_size],"Station"))
	arlenian_station = dinerPlaceStation(o_x, o_y, "RandomHumanNeutral", "Arlenians", arlenian_station_size)
	table.insert(friendly_neutral_stations,arlenian_station)
	table.insert(transport_stations,arlenian_station)
	table.insert(place_space,{obj=arlenian_station,dist=station_dist[arlenian_station:getTypeName()]})
--	Spawn USN station
	local usn_station_size = szt()
	area_radius = base_area_radius
	repeat
		o_x, o_y = vectorFromAngle(random(0,360),random(0,area_radius))
		o_x = o_x + diner_x
		o_y = o_y + diner_y
		area_radius = area_radius + compression_interval
	until(farEnough(o_x,o_y,station_dist[usn_station_size],"Station"))
	usn_station = dinerPlaceStation(o_x, o_y, "RandomHumanNeutral", "USN", usn_station_size)
	table.insert(friendly_neutral_stations,usn_station)
	table.insert(transport_stations,usn_station)
	table.insert(place_space,{obj=usn_station,dist=station_dist[usn_station:getTypeName()]})
--	Spawn Kraylor station
	local kraylor_station_size = szt()
	area_radius = base_area_radius
	repeat
		o_x, o_y = vectorFromAngle(random(0,360),random(0,area_radius))
		o_x = o_x + diner_x
		o_y = o_y + diner_y
		area_radius = area_radius + compression_interval
	until(farEnough(o_x,o_y,6*station_defend_dist[kraylor_station_size],"Station"))
	kraylor_station = dinerPlaceStation(o_x, o_y, "RandomHumanNeutral", "Kraylor", kraylor_station_size)
	table.insert(transport_stations,kraylor_station)
	table.insert(place_space,{obj=kraylor_station,dist=6*station_defend_dist[kraylor_station:getTypeName()]})
	local kraylor_fleet = spawnEnemies(o_x, o_y, 1, "Kraylor", 99)
	for i, ship in ipairs(kraylor_fleet) do
		ship:orderDefendTarget(kraylor_station):onDestroyed(enemyVesselDestroyed)
	end
--	Spawn remaining working transports	
	for i, station in ipairs(transport_stations) do
		if station ~= repair_station and station ~= shop_station then
			local transport, transport_size = randomTransportType()
			transport.home_station = station
			area_radius = base_area_radius
			repeat
				o_x, o_y = vectorFromAngle(random(0,360),random(0,area_radius))
				o_x = o_x + diner_x
				o_y = o_y + diner_y
				area_radius = area_radius + compression_interval
			until(farEnough(o_x, o_y, 100 + transport_size * 50))
			transport:setPosition(o_x, o_y):setFaction(station:getFaction())
			transport:setCallSign(generateCallSign(nil,station:getFaction()))
			transport.normal_transport_plot = true
			transport.target = pickTransportTarget(transport)
			if transport.target ~= nil then
				transport:orderDock(transport.target)
			end
			table.insert(place_space,{obj=transport,dist=100 + transport_size * 50})
			table.insert(transport_list,transport)
		end
	end
--	Gap nebulae
	local gap_neb_count = math.random(1,2 + difficulty*2)
	gap_nebulae = {}
	for i=1,gap_neb_count do
		local neb_group_count = math.random(1,3)
		for j=1,neb_group_count do
			if j == 1 then
				area_radius = base_area_radius
				repeat
					o_x, o_y = vectorFromAngle(random(0,360),random(0,area_radius))
					o_x = o_x + diner_x
					o_y = o_y + diner_y
					area_radius = area_radius + compression_interval
				until(farEnough(o_x,o_y,5000))
				table.insert(gap_nebulae,Nebula():setPosition(o_x,o_y))
			else
				local no_x, no_y = vectorFromAngle(random(0,360),random(5000,10000))
				o_x = o_x + no_x
				o_y = o_y + no_y
				table.insert(gap_nebulae,Nebula():setPosition(o_x,o_y))
			end
		end
	end
--	Remaining nebulae
	for i=1,math.random(1,2 + difficulty*2) do
		for j=1,math.random(1,3) do
			if j == 1 then
				o_x, o_y = vectorFromAngle(random(0,360),random(10000,base_area_radius + 10000))
				o_x = o_x + diner_x
				o_y = o_y + diner_y
				Nebula():setPosition(o_x,o_y)
			else
				local no_x, no_y = vectorFromAngle(random(0,360),random(5000,10000))
				o_x = o_x + no_x
				o_y = o_y + no_y
				Nebula():setPosition(o_x,o_y)
			end
		end
	end
--	Mission hints at stations		
	local station_pick_list = {arlenian_station,usn_station,mining_station,shop_station,repair_station}
	secondary_repair_stations = {}
	local mission_messages = {
		"Those marauding Exuari are a real nuisance.",
		"It would be nice if someone took those Exuari marauders down a notch or two.",
		"What about those Exuari! Are they bums or what?",
		"Someone that took care of those Exuari would be my friend for life.",
		"I wish those Exuari marauders would leave us alone."
	}
--	Helpful secondary systems repairs
	for i=1,5 do
		local station = tableRemoveRandom(station_pick_list)
		station.comms_data.mission_message = tableRemoveRandom(mission_messages)
		if i == 1 then
			station.comms_data.combat_maneuver_repair = true
			station.comms_data.service_cost.combat_maneuver_repair = math.random(1,3)
			table.insert(secondary_repair_stations,{station = station, repair = "combat maneuver", rep = station.comms_data.service_cost.combat_maneuver_repair})
		end
		if i == 2 then
			station.comms_data.hack_repair = true
			station.comms_data.service_cost.hack_repair = math.random(1,3)
			table.insert(secondary_repair_stations,{station = station, repair = "hacking", rep = station.comms_data.service_cost.hack_repair})
		end
		if i == 3 then
			station.comms_data.scan_repair = true
			station.comms_data.service_cost.scan_repair = math.random(1,3)
			table.insert(secondary_repair_stations,{station = station, repair = "scanning", rep = station.comms_data.service_cost.scan_repair})
		end
		if i == 4 then
			station.comms_data.self_destruct_repair = true
			station.comms_data.service_cost.self_destruct_repair = math.random(1,3)
			table.insert(secondary_repair_stations,{station = station, repair = "self destruct", rep = station.comms_data.service_cost.self_destruct_repair})
		end
		if i == 5 then
			station.comms_data.probe_launch_repair = true
			station.comms_data.service_cost.probe_launch_repair = math.random(1,3)
			table.insert(secondary_repair_stations,{station = station, repair = "probe launch", rep = station.comms_data.service_cost.probe_launch_repair})
		end
	end
end
function pickTransportTarget(transport)
	local transport_target = nil
	local boundary_check = 0
	repeat
		transport_target = transport_stations[math.random(1,#transport_stations)]
		boundary_check = boundary_check + 1
	until(boundary_check > 50 or (transport_target ~= nil and transport_target:isValid() and not transport:isEnemy(transport_target)))
	return transport_target
end
function randomTransportType()
	local transport_type = {"Personnel","Goods","Garbage","Equipment","Fuel"}
	local freighter_engine = "Freighter"
	local freighter_size = math.random(1,5)
	if random(1,100) < 30 then
		freighter_engine = "Jump Freighter"
		freighter_size = math.random(3,5)
	end
	return CpuShip():setTemplate(string.format("%s %s %i",transport_type[math.random(1,#transport_type)],freighter_engine,freighter_size)):setCommsScript(""):setCommsFunction(commsShip), freighter_size
end
function winTheGame()
	globalMessage("You have eliminated the source of the Exuari marauders")
	victory("Human Navy")
end
function farEnough(o_x,o_y,obj_dist,obj_type)
	local far_enough = true
	for index, item in ipairs(place_space) do
		comparison_distance = obj_dist + item.dist
		if obj_type ~= nil and obj_type == "Station" then
			if item.obj.typeName == "SpaceStation" then
				comparison_distance = comparison_distance + 6000
			end
		end
		if distance(item.obj,o_x,o_y) < comparison_distance then
			far_enough = false
			break
		end
	end
	return far_enough
end
--	Main plot functions
function dinerDamage(self,instigator)
	if marauder_state < 2 then	--attack player
		if self:getShieldLevel(0) < .01 then
			for i, marauder in ipairs(group_fleet) do
				if marauder ~= nil and marauder:isValid() then
					marauder:orderFlyTowardsBlind(marauder_x,marauder_y)
				end
			end
			marauder_state = 2	--blind retreat
			marauderPlot = marauderAttackDiner
		end
	end
end
function playerDamage(self,instigator)
	if marauder_state < 2 then	--attack player
		if self:getShieldLevel(0) < .01 or not self:getShieldsActive() then
			if random(1,100) <= 62 - difficulty * 12 then
				local loot_systems = {}
				if self:getCanCombatManeuver() then
					table.insert(loot_systems,"combat_maneuver")
				end
				if self:getCanHack() then
					table.insert(loot_systems,"hacking")
				end
				if self:getCanScan() then
					table.insert(loot_systems,"scanning")
				end
				if self:getCanSelfDestruct() then
					table.insert(loot_systems,"self_destruct")
				end
				if self:getCanLaunchProbe() then
					table.insert(loot_systems,"launch_probe")
				end
				if #loot_systems > 0 then
					local stolen_system = loot_systems[math.random(1,#loot_systems)]
					if stolen_system == "combat_maneuver" then
						self:setCanCombatManeuver(false)
					end
					if stolen_system == "hacking" then
						self:setCanHack(false)
					end
					if stolen_system == "scanning" then
						self:setCanScan(false)
					end
					if stolen_system == "self_destruct" then
						self:setCanSelfDestruct(false)
					end
					if stolen_system == "launch_probe" then
						self:setCanLaunchProbe(false)
					end
				else
					for i, marauder in ipairs(group_fleet) do
						if marauder ~= nil and marauder:isValid() then
							marauder:orderFlyTowardsBlind(marauder_x,marauder_y)
						end
					end
					marauder_state = 2	--blind retreat
					marauderPlot = marauderAttackPlayer
					if self:hasPlayerAtPosition("Engineering") then
						self.stolen_message = "stolen_message"
						self:addCustomMessage("Engineering",self.stolen_message,"Once those marauders got past our shields, they cut off pieces of our ship and took them. The pieces were critical portions of secondary systems such as combat maneuver, scanners, hacking systems, probe launchers and the self-destruct system.")
					end
					if self:hasPlayerAtPosition("Engineering+") then
						self.stolen_message_plus = "stolen_message_plus"
						self:addCustomMessage("Engineering+",self.stolen_message_plus,"Once those marauders got past our shields, they cut off pieces of our ship and took them. The pieces were critical portions of secondary systems such as combat maneuver, scanners, hacking systems, probe launchers and the self-destruct system.")
					end
				end
			end
		end
	end
end
function startRepairImpulse(delta)
	local p = getPlayerShip(-1)
	if getScenarioTime() > repair_impulse_timer then
		if p ~= nil and p:isValid() then
			if p.repair_timer_banner ~= nil then
				p:removeCustom(p.repair_timer_banner)
			end
			if p.repair_timer_banner_tac ~= nil then
				p:removeCustom(p.repair_timer_banner_tac)
			end
			if p.repair_timer_banner_eng ~= nil then
				p:removeCustom(p.repair_timer_banner_eng)
			end
			if p.repair_timer_banner_eng_plus ~= nil then
				p:removeCustom(p.repair_timer_banner_eng_plus)
			end
			p:setImpulseMaxSpeed(125)
			p:setCanDock(true)
		end
		impulse_repaired = true
		plotRepairImpulse = cleanUpImpulseRepair
	else
		local repair_timer_display = "Impulse Fix"
		local repair_timer_minutes = math.floor((repair_impulse_timer - getScenarioTime()) / 60)
		local repair_timer_seconds = math.floor((repair_impulse_timer - getScenarioTime()) % 60)
		if repair_timer_minutes <= 0 then
			repair_timer_display = string.format("%s %i",repair_timer_display,repair_timer_seconds)
		else
			repair_timer_display = string.format("%s %i:%.2i",repair_timer_display,repair_timer_minutes,repair_timer_seconds)
		end
		if p ~= nil and p:isValid() then
			if p:hasPlayerAtPosition("Helms") then
				p.repair_timer_banner = "repair_timer_banner"
				p:addCustomInfo("Helms",p.repair_timer_banner,repair_timer_display)
			end
			if p:hasPlayerAtPosition("Tactical") then
				p.repair_timer_banner_tac = "repair_timer_banner_tac"
				p:addCustomInfo("Tactical",p.repair_timer_banner_tac,repair_timer_display)
			end
			if p:hasPlayerAtPosition("Engineering") then
				p.repair_timer_banner_eng = "repair_timer_banner_eng"
				p:addCustomInfo("Engineering",p.repair_timer_banner_eng,repair_timer_display)
			end
			if p:hasPlayerAtPosition("Engineering+") then
				p.repair_timer_banner_eng_plus = "repair_timer_banner_eng_plus"
				p:addCustomInfo("Engineering+",p.repair_timer_banner_eng_plus,repair_timer_display)
			end
		end
	end
end
function cleanUpImpulseRepair(delta)
	local p = getPlayerShip(-1)
	if p ~= nil and p:isValid() then
		if p.repair_timer_banner ~= nil then
			p:removeCustom(p.repair_timer_banner)
			p.repair_timer_banner = nil
		end
		if p.repair_timer_banner_tac ~= nil then
			p:removeCustom(p.repair_timer_banner_tac)
			p.repair_timer_banner_tac = nil
		end
		if p.repair_timer_banner_eng ~= nil then
			p:removeCustom(p.repair_timer_banner_eng)
			p.repair_timer_banner_eng = nil
		end
		if p.repair_timer_banner_eng_plus ~= nil then
			p:removeCustom(p.repair_timer_banner_eng_plus)
			p.repair_timer_banner_eng_plus = nil
		end
	end
	if getScenarioTime() > (repair_impulse_timer + 2) then
		plotRepairImpulse = nil
	end
end
function buzzerRoaming(delta)
	preserveBuzzer()
	if getScenarioTime() > buzzer_timer then
		if buzzer ~= nil and buzzer:isValid() then
			if random(1,100) < 62 then
				if random(1,100) < 77 then
					buzzer:orderAttack(getPlayerShip(-1))
				else
					local p = getPlayerShip(-1)
					local p_x, p_y = p:getPosition()
					buzzer:orderFlyTowards(p_x, p_y)
				end
				buzzerPlot = buzzerPlayer
			else
				if diner_station ~= nil and diner_station:isValid() then
					if random(1,100) < 81 then
						buzzer:orderAttack(diner_station)
					else
						buzzer:orderFlyTowards(diner_x, diner_y)
					end
					buzzerPlot = buzzerDiner
				end
			end
		else
			spawnBuzzer()
--			buzzer:setCallSign(string.format("Buzzer %i",math.random(1,9999)))
--			print(string.format("New Buzzer %s",buzzer:getCallSign()))
		end
		buzzer_timer = getScenarioTime() + buzzer_timer_interval
	end
end
function buzzerPlayer(delta)
	preserveBuzzer()
	if getScenarioTime() > buzzer_timer then
		if buzzer ~= nil and buzzer:isValid() then
			if random(1,100) < 71 then
				if diner_station ~= nil and diner_station:isValid() then
					if random(1,100) < 58 then
						buzzer:orderAttack(diner_station)
					else
						buzzer:orderFlyTowards(diner_x, diner_y)
					end
					buzzerPlot = buzzerDiner
				end
			else
				buzzer:orderRoaming()
				buzzerPlot = buzzerRoaming
			end
		else
			spawnBuzzer()
--			buzzer:setCallSign(string.format("Buzzer %i",math.random(1,9999)))
--			print(string.format("New Buzzer %s",buzzer:getCallSign()))
		end
		buzzer_timer = getScenarioTime() + buzzer_timer_interval
	end
end
function buzzerDiner(delta)
	preserveBuzzer()
	if getScenarioTime() > buzzer_timer then
		if buzzer ~= nil and buzzer:isValid() then
			if random(1,100) < 88 then
				buzzer:orderAttack(getPlayerShip(-1))
				buzzerPlot = buzzerPlayer
			else
				buzzer:orderRoaming()
				buzzerPlot = buzzerRoaming
			end
		else
			spawnBuzzer()
--			buzzer:setCallSign(string.format("Buzzer %i",math.random(1,9999)))
--			print(string.format("New Buzzer %s",buzzer:getCallSign()))
		end
		buzzer_timer = getScenarioTime() + buzzer_timer_interval
	end
end
function preserveBuzzer()
	if buzzer ~= nil and buzzer:isValid() then
		if buzzer:getHull() < 15 then
			if random(1,100) < 20 then
				if marauder_station ~= nil and marauder_station:isValid() then
					local m_x, m_y = marauder_station:getPosition()
					buzzer:orderFlyTowardsBlind(m_x, m_y)
				end
				buzzerPlot = buzzerRecover
			end
		end
	else
		spawnBuzzer()
--		buzzer:setCallSign(string.format("Buzzer %i",math.random(1,9999)))
--		print(string.format("New Buzzer %s",buzzer:getCallSign()))
		buzzer_timer = getScenarioTime() + buzzer_timer_interval
	end
end
function buzzerRecover(delta)
	if buzzer ~= nil and buzzer:isValid() then
		if distance(buzzer,marauder_station) < 4000 then
			if not buzzer:isDocked(marauder_station) then
				buzzer:orderDock(marauder_station)
			end
		end
		if buzzer:isDocked(marauder_station) then
			if buzzer:getHull() >= buzzer:getHullMax() then
				buzzer:orderRoaming()
				buzzerPlot = buzzerRoaming
				buzzer_timer = getScenarioTime() + buzzer_timer_interval
			else
				buzzer:setHull(math.min(buzzer:getHullMax(),buzzer:getHull() + delta))
			end
		end
	else
		spawnBuzzer()
--		buzzer:setCallSign(string.format("Buzzer %i",math.random(1,9999)))
--		print(string.format("New Buzzer %s",buzzer:getCallSign()))
		buzzer_timer = getScenarioTime() + buzzer_timer_interval
	end
end
function spawnBuzzer()
	if buzzer_index == nil then
		buzzer_index = 1
	end
	local buzzer_templates = {"Fighter","Adder MK3","Fighter","Adder MK4","Fighter","Adder MK5","Fighter","Adder MK6","Fighter","Adder MK7","Fighter","Adder MK8","Fighter","Adder MK9"}
	buzzer = CpuShip():setTemplate(buzzer_templates[buzzer_index]):setPosition(marauder_x, marauder_y):setCallSign(generateCallSign(nil,"Exuari")):orderRoaming():setFaction("Exuari")
	buzzer_index = buzzer_index + 1
	if buzzer_index > #buzzer_templates then
		buzzer_index = 1
	end
end
function marauderAttackInFormation(delta)
	local marauder_status = "Marauder attack in formation"
	local group_leaders = "exist"
	local repair_transport_status = "Not docked at diner"
	local shop_transport_status = "Not docked at diner"
	local group_leader_1_status = "invalid"
	local group_leader_2_status = "unknown"
	local fleet_count = 0
	for marauder_index, marauder in ipairs(group_fleet) do
		if marauder ~= nil and marauder:isValid() then
			fleet_count = fleet_count + 1
		end
	end
	if fleet_count <= 7 then
		local p = getPlayerShip(-1)
		if p.impulse_blowout_message_eng == nil then
			p:setImpulseMaxSpeed(20)	--less (vs 125/50)
			p:setSystemHealth("impulse",-1)
			p.impulse_blowout_message_eng = "impulse_blowout_message_eng"
			p:addCustomMessage("Engineering",p.impulse_blowout_message_eng,"Major engine failure. Even with full field repairs, engine output will be less than 40%")
			p.impulse_blowout_message_epl = "impulse_blowout_message_epl"
			p:addCustomMessage("Engineering",p.impulse_blowout_message_epl,"Major engine failure. Even with full field repairs, engine output will be less than 40%")
		end
	end
	if group1_leader ~= nil and group2_leader ~= nil then
		if not group1_leader:isValid() or not group2_leader:isValid() then
			group_leaders = "one or more invalid"
			for i, marauder in ipairs(group_fleet) do
				if marauder ~= nil and marauder:isValid() then
					marauder:orderAttack(getPlayerShip(-1))
				end
			end
			marauder_state = 1	--attack player or diner
			marauderPlot = marauderAttackPlayer
		end
	else
		group_leaders = "don't exist"
		for i, marauder in ipairs(group_fleet) do
			if marauder ~= nil and marauder:isValid() then
				marauder:orderAttack(getPlayerShip(-1))
			end
		end
		marauder_state = 1	--attack player or diner
		marauderPlot = marauderAttackPlayer
	end
	local delete_marauder = "No"
	for marauder_index, marauder in ipairs(group_fleet) do
		if marauder ~= nil then
			if not marauder:isValid() then
				delete_marauder = "Yes, invalid"
				table.remove(group_fleet,marauder_index)
				break
			end
		else
			delete_marauder = "Yes, does not exist"
			table.remove(group_fleet,marauder_index)
			break		
		end
	end
	if repair_transport:isDocked(diner_station) then
		repair_transport_status = "Docked at diner"
		if group1_leader ~= nil and group1_leader:isValid() then
			group_leader_1_status = "valid"
			if distance(group1_leader,diner_station) < 10000 then
				group_leader_1_status = "valid, closer than 10 units to diner"
				repair_transport.target = repair_station
				repair_transport.normal_transport_plot = true
				repair_transport:orderDock(repair_station)
			elseif distance(group1_leader,marauder_station) < 10000 then
				group_leader_1_status = "valid, closer than 10 units to marauder base"
				repair_transport.target = repair_station
				repair_transport.normal_transport_plot = true
				repair_transport:orderDock(repair_station)
			end
		else
			group_leader_2_status = "invalid"
			if group2_leader ~= nil and group2_leader:isValid() then
				group_leader_2_status = "valid"
				if distance(group2_leader,diner_station) < 10000 then
					group_leader_2_status = "valid, closer than 10 units to diner"
					repair_transport.target = repair_station
					repair_transport.normal_transport_plot = true
					repair_transport:orderDock(repair_station)
				elseif distance(group2_leader,marauder_station) < 10000 then
					group_leader_2_status = "valid, closer than 10 units to marauder base"
					repair_transport.target = repair_station
					repair_transport.normal_transport_plot = true
					repair_transport:orderDock(repair_station)
				end
			else
				repair_transport.target = repair_station
				repair_transport.normal_transport_plot = true
				repair_transport:orderDock(repair_station)
			end
		end
	end
	if shop_transport:isDocked(diner_station) then
		shop_transport_status = "Docked at diner"
		if group1_leader ~= nil and group1_leader:isValid() then
			group_leader_1_status = "valid"
			if distance(group1_leader,diner_station) < 10000 then
				group_leader_1_status = "valid, closer than 10 units to diner"
				shop_transport.target = shop_station
				shop_transport.normal_transport_plot = true
				shop_transport:orderDock(shop_station)
			elseif distance(group1_leader,marauder_station) < 10000 then
				group_leader_1_status = "valid, closer than 10 units to marauder base"
				shop_transport.target = shop_station
				shop_transport.normal_transport_plot = true
				shop_transport:orderDock(shop_station)
			end
		else
			group_leader_2_status = "invalid"
			if group2_leader ~= nil and group2_leader:isValid() then
				group_leader_2_status = "valid"
				if distance(group2_leader,diner_station) < 10000 then
					group_leader_2_status = "valid, closer than 10 units to diner"
					shop_transport.target = shop_station
					shop_transport.normal_transport_plot = true
					shop_transport:orderDock(shop_station)
				elseif distance(group2_leader,marauder_station) < 10000 then
					group_leader_2_status = "valid, closer than 10 units to marauder base"
					shop_transport.target = shop_station
					shop_transport.normal_transport_plot = true
					shop_transport:orderDock(shop_station)
				end
			else
				shop_transport.target = shop_station
				shop_transport.normal_transport_plot = true
				shop_transport:orderDock(shop_station)
			end
		end
	end
	if marauder_diagnostic then
		print(marauder_status,"group leaders:",group_leaders,"delete marauder:",delete_marauder,"marauder state:",marauder_state,"fleet count:",fleet_count)
	end
end
function marauderAttackDiner(delta)
	local ordered_to_dock = true
	for marauder_index, marauder in ipairs(group_fleet) do
		if marauder ~= nil then
			if marauder:isValid() then
				local order_string = marauder:getOrder()
				if not string.find(order_string,"Dock") then
					ordered_to_dock = false
				end
			else
				table.remove(group_fleet,marauder_index)
				break
			end
		else
			table.remove(group_fleet,marauder_index)
			break		
		end
	end
	if marauder_state == 2 then	--blind retreat
		upgrade_player_ship = true
		if marauder_station ~= nil and marauder_station:isValid() then
			for marauder_index, marauder in ipairs(group_fleet) do
				if marauder ~= nil and marauder:isValid() then
					if distance(marauder,marauder_station) < 10000 then
						marauder:orderDock(marauder_station):setAI("fighter")
					end
				end
			end
		end
		if ordered_to_dock then
			marauder_state = 3	--recover
			marauderPlot = marauderRecover
		end
	end
end
function marauderAttackPlayer(delta)
	local marauder_status = "Marauder attack player"
	local delete_marauder = "No"
	local repair_transport_status = "Not docked at diner"
	local shop_transport_status = "Not docked at diner"
	local group_leader_1_status = "invalid"
	local group_leader_2_status = "unknown"
	local ordered_to_dock = true
	local fleet_count = 0
	for marauder_index, marauder in ipairs(group_fleet) do
		if marauder ~= nil and marauder:isValid() then
			fleet_count = fleet_count + 1
		end
	end
	if fleet_count <= 7 then
		local p = getPlayerShip(-1)
		if p.impulse_blowout_message == nil then
			p:setImpulseMaxSpeed(20)	--less (vs 125/50)
			p:setSystemHealth("impulse",-1)
			p.impulse_blowout_message = "impulse_blowout_message"
			if p:hasPlayerAtPosition("Engineering") then
				p:addCustomMessage("Engineering",p.impulse_blowout_message,"Major engine failure. Even with full field repairs, engine output will be less than 40%")
			end
			if p:hasPlayerAtPosition("Engineering+") then
				p:addCustomMessage("Engineering+",p.impulse_blowout_message,"Major engine failure. Even with full field repairs, engine output will be less than 40%")
			end
		end
	end
	for marauder_index, marauder in ipairs(group_fleet) do
		if marauder ~= nil then
			if marauder:isValid() then
				local order_string = marauder:getOrder()
				if not string.find(order_string,"Dock") then
					ordered_to_dock = false
				end
			else
				delete_marauder = "Yes, invalid"
				table.remove(group_fleet,marauder_index)
				break
			end
		else
			delete_marauder = "Yes, does not exist"
			table.remove(group_fleet,marauder_index)
			break		
		end
	end
	if repair_transport:isDocked(diner_station) then
		repair_transport_status = "Docked at diner"
		if group1_leader ~= nil and group1_leader:isValid() then
			group_leader_1_status = "valid"
			if distance(group1_leader,diner_station) < 10000 then
				group_leader_1_status = "valid, closer than 10 units to diner"
				repair_transport.target = repair_station
				repair_transport.normal_transport_plot = true
				repair_transport:orderDock(repair_station)
			elseif distance(group1_leader,marauder_station) < 10000 then
				group_leader_1_status = "valid, closer than 10 units to marauder base"
				repair_transport.target = repair_station
				repair_transport.normal_transport_plot = true
				repair_transport:orderDock(repair_station)
			end
		else
			group_leader_2_status = "invalid"
			if group2_leader ~= nil and group2_leader:isValid() then
				group_leader_2_status = "valid"
				if distance(group2_leader,diner_station) < 10000 then
					group_leader_2_status = "valid, closer than 10 units to diner"
					repair_transport.target = repair_station
					repair_transport.normal_transport_plot = true
					repair_transport:orderDock(repair_station)
				elseif distance(group2_leader,marauder_station) < 10000 then
					group_leader_2_status = "valid, closer than 10 units to marauder base"
					repair_transport.target = repair_station
					repair_transport.normal_transport_plot = true
					repair_transport:orderDock(repair_station)
				end
			else
				repair_transport.target = repair_station
				repair_transport.normal_transport_plot = true
				repair_transport:orderDock(repair_station)
			end
		end
	end
	if shop_transport:isDocked(diner_station) then
		shop_transport_status = "Docked at diner"
		if group1_leader ~= nil and group1_leader:isValid() then
			group_leader_1_status = "valid"
			if distance(group1_leader,diner_station) < 10000 then
				group_leader_1_status = "valid, closer than 10 units to diner"
				shop_transport.target = shop_station
				shop_transport.normal_transport_plot = true
				shop_transport:orderDock(shop_station)
			elseif distance(group1_leader,marauder_station) < 10000 then
				group_leader_1_status = "valid, closer than 10 units to marauder base"
				shop_transport.target = shop_station
				shop_transport.normal_transport_plot = true
				shop_transport:orderDock(shop_station)
			end
		else
			group_leader_2_status = "invalid"
			if group2_leader ~= nil and group2_leader:isValid() then
				group_leader_2_status = "valid"
				if distance(group2_leader,diner_station) < 10000 then
					group_leader_2_status = "valid, closer than 10 units to diner"
					shop_transport.target = shop_station
					shop_transport.normal_transport_plot = true
					shop_transport:orderDock(shop_station)
				elseif distance(group2_leader,marauder_station) < 10000 then
					group_leader_2_status = "valid, closer than 10 units to marauder base"
					shop_transport.target = shop_station
					shop_transport.normal_transport_plot = true
					shop_transport:orderDock(shop_station)
				end
			else
				shop_transport.target = shop_station
				shop_transport.normal_transport_plot = true
				shop_transport:orderDock(shop_station)
			end
		end
	end
	if marauder_state == 2 then	--blind retreat
		if marauder_station ~= nil and marauder_station:isValid() then
			for marauder_index, marauder in ipairs(group_fleet) do
				if marauder ~= nil and marauder:isValid() then
					if distance(marauder,marauder_station) < 10000 then
						marauder:orderDock(marauder_station):setAI("fighter")
					end
				end
			end
		end
		if ordered_to_dock then
			marauder_state = 3	--recover
			marauderPlot = marauderRecover
		end
	end
	if marauder_diagnostic then
		print(marauder_status,"group leader status: 1:",group_leader_1_status,"2:",group_leader_2_status,"delete marauder:",delete_marauder,"repair transport:",repair_transport_status,"shop transport:",shop_transport_status,"ordered to dock:",ordered_to_dock,"marauder state:",marauder_state)
	end
end
function marauderRecover(delta)
	if buzzer == nil then
		spawnBuzzer()
--		buzzer:setCallSign(string.format("Buzzer %i",math.random(1,9999)))
--		print(string.format("New Buzzer %s",buzzer:getCallSign()))
		buzzerPlot = buzzerRoaming
		buzzer_timer = getScenarioTime() + buzzer_timer_interval
	end
	patrolPlot = patrolToTheDiner
	local recovered = true
	for marauder_index, marauder in ipairs(group_fleet) do
		if marauder ~= nil then
			if marauder:isValid() then
				if marauder:getHull() >= marauder:getHullMax() then
					if marauder_station ~= nil and marauder_station:isValid() then
						marauder:orderDefendTarget(marauder_station)
					end
				else
					recovered = false
					if marauder_station ~= nil and marauder_station:isValid() then
						if marauder:isDocked(marauder_station) then
							marauder:setHull(math.min(marauder:getHullMax(),marauder:getHull() + delta))
						end
					end
				end
			end
		end
	end
	if recovered then
		marauderPlot = nil
		if marauder_diagnostic then print("Ended first marauder plot since all marauders have recovered and are defending the station") end
	end
end
function marauderToTheDiner(delta)
	if patrolPlot == nil then
		if diner_station ~= nil and diner_station:isValid() then
			if group1_leader ~= nil and group1_leader:isValid() then
				group1_leader:orderAttack(diner_station)
				for i, marauder in ipairs(group_fleet) do
					if marauder ~= nil and marauder:isValid() and marauder ~= group1_leader then
						marauder:orderDefendTarget(group1_leader):setAI("default")
					end
				end
			elseif group1_leader ~= nil and group2_leader:isValid() then
				group2_leader:orderAttack(diner_station)
				for i, marauder in ipairs(group_fleet) do
					if marauder ~= nil and marauder:isValid() and marauder ~= group2_leader then
						marauder:orderDefendTarget(group2_leader):setAI("default")
					end
				end
			else
				for i, marauder in ipairs(group_fleet) do
					if marauder ~= nil and marauder:isValid() then
						marauder:orderFlyTowards(diner_x, diner_y):setAI("default")
					end
				end
			end
		else
			for i, marauder in ipairs(group_fleet) do
				if marauder ~= nil and marauder:isValid() then
					marauder:orderRoaming():setAI("default")
				end
			end
		end
		marauderPlot = marauderAttackDiner
		marauder_state = 1	--attack player/diner
	end
end
function checkPlayerProximity(delta)
	local p = getPlayerShip(-1)
	if p ~= nil and p:isValid() then
		if marauder_station ~= nil and marauder_station:isValid() then
			if distance(p,marauder_station) < 18000 then
				player_found_exuari_base = true
				playerFoundExuariBasePlot = nil
			end
		end
	end
end
function patrolVisualCheck(delta)
	for i, ship in ipairs(patrol_fleet) do
		if ship ~= nil and ship:isValid() then
			if distance(ship,marauder_station) < 20000 then
				patrol_convinced = true
				patrolConvincedPlot = nil
				break
			end
		end
	end
end
function patrolToTheDiner(delta)
	if marauderPlot == nil then
		if patrol_leader ~= nil and patrol_leader:isValid() then
			if diner_station ~= nil and diner_station:isValid() then
				patrol_leader:orderDefendTarget(diner_station)
			else
				patrol_leader:orderRoaming()
			end
			for i, ship in ipairs(patrol_fleet) do
				if ship ~= nil and ship:isValid() and ship ~= patrol_leader then
					ship:orderDefendTarget(patrol_leader)
				end
			end
		else
			for i, ship in ipairs(patrol_fleet) do
				if ship ~= nil and ship:isValid() then
					if diner_station ~= nil and diner_station:isValid() then
						ship:orderDefendTarget(diner_station)
					else
						ship:orderRoaming()
					end
				end
			end
		end
		patrolPlot = patrolDefendDiner
		diner_defend_timer = getScenarioTime() + 300
	end
end
function patrolDefendDiner(delta)
	local diner_proximity = true
	local patrol_exists = false
	for i, ship in ipairs(patrol_fleet) do
		if ship ~= nil and ship:isValid() then
			patrol_exists = true
			if diner_station ~= nil and diner_station:isValid() then
				if distance(ship,diner_station) > 10000 then
					diner_proximity = false
					break
				end
			else
				ship:orderRoaming()
				patrolPlot = nil
			end
		end
	end
	if patrol_exists then
		if diner_proximity then
			if getScenarioTime() > diner_defend_timer then
				if patrol_exists then
					if patrol_leader ~= nil and patrol_leader:isValid() then
						if repair_station ~= nil and repair_station:isValid() then
							patrol_leader:orderDefendTarget(repair_station)
						else
							patrol_leader:orderRoaming()
						end
						for i, ship in ipairs(patrol_fleet) do
							if ship ~= nil and ship:isValid() and ship ~= patrol_leader then
								ship:orderDefendTarget(patrol_leader)
							end
						end
					else
						for i, ship in ipairs(patrol_fleet) do
							if ship ~= nil and ship:isValid() then
								if repair_station ~= nil and repair_station:isValid() then
									ship:orderDefendTarget(repair_station)
								else
									ship:orderRoaming()
								end
							end
						end
					end
				else
					launchNewPatrol()
				end
				patrolPlot = patrolToRepair
			end
		end
	else
		launchNewPatrol()
		patrolPlot = patrolToRepair
	end
end
function patrolToRepair(delta)
	local patrol_exists = false
	local repair_proximity = true
	for i, ship in ipairs(patrol_fleet) do
		if ship ~= nil and ship:isValid() then
			patrol_exists = true
			if repair_station ~= nil and repair_station:isValid() then
				if distance(ship,repair_station) > 10000 then
					repair_proximity = false
					break
				end
			else
				ship:orderRoaming()
				patrolPlot = nil
				upgrade_player_ship = true
			end
		end
	end
	if repair_proximity then
		patrolPlot = patrolRecover
		marauderPlot = marauderToTheDiner
	end
	if not patrol_exists then
		launchNewPatrol()
	end
end
function patrolRecover(delta)
	local recovered = true
	local patrol_exists = false
	for i, ship in ipairs(patrol_fleet) do
		if ship ~= nil and ship:isValid() then
			patrol_exists = true
			if ship:getHull() >= ship:getHullMax() then
				if repair_station ~= nil and repair_station:isValid() then
					if ship:isDocked(repair_station) then
						ship:orderDefendTarget(repair_station)
					end
				else
					ship:orderRoaming()
					upgrade_player_ship = true
				end
			else
				recovered = false
				if repair_station ~= nil and repair_station:isValid() then
					if ship:isDocked(repair_station) then
						ship:setHull(math.min(ship:getHullMax(),ship:getHull() + delta))
					else
						ship:orderDock(repair_station)
					end
				else
					upgrade_player_ship = true				
				end
			end
		end
	end
	if recovered then
		patrolPlot = nil
	end
	if not patrol_exists then
		launchNewPatrol()
		marauderPlot = marauderToTheDiner
	end
end
function launchNewPatrol()
--	Spawn Human Navy patrol fleet
	if repair_station ~= nil and repair_station:isValid() then
		patrol_fleet = {}
		patrol_leader = CpuShip():setTemplate("Cruiser"):setFaction("Human Navy"):setCallSign(generateCallSign(nil,"Human Navy")):orderDefendTarget(repair_station):setPosition(diner_x + repair_x, diner_y + repair_y):setCommsScript(""):setCommsFunction(commsShip)
		table.insert(patrol_fleet,patrol_leader)
		table.insert(patrol_fleet,CpuShip():setTemplate("Nirvana R5"):setFaction("Human Navy"):setCallSign(generateCallSign(nil,"Human Navy")):orderDefendTarget(repair_station):setPosition(diner_x + repair_x, diner_y + repair_y):setCommsScript(""):setCommsFunction(commsShip))
		table.insert(patrol_fleet,CpuShip():setTemplate("Nirvana R5A"):setFaction("Human Navy"):setCallSign(generateCallSign(nil,"Human Navy")):orderDefendTarget(repair_station):setPosition(diner_x + repair_x, diner_y + repair_y):setCommsScript(""):setCommsFunction(commsShip))
		table.insert(patrol_fleet,CpuShip():setTemplate("Nirvana R3"):setFaction("Human Navy"):setCallSign(generateCallSign(nil,"Human Navy")):orderDefendTarget(repair_station):setPosition(diner_x + repair_x, diner_y + repair_y):setCommsScript(""):setCommsFunction(commsShip))
		table.insert(patrol_fleet,CpuShip():setTemplate("MU52 Hornet"):setFaction("Human Navy"):setCallSign(generateCallSign(nil,"Human Navy")):orderDefendTarget(repair_station):setPosition(diner_x + repair_x, diner_y + repair_y):setCommsScript(""):setCommsFunction(commsShip))
		table.insert(patrol_fleet,CpuShip():setTemplate("MU52 Hornet"):setFaction("Human Navy"):setCallSign(generateCallSign(nil,"Human Navy")):orderDefendTarget(repair_station):setPosition(diner_x + repair_x, diner_y + repair_y):setCommsScript(""):setCommsFunction(commsShip))
		table.insert(patrol_fleet,CpuShip():setTemplate("Fighter"):setFaction("Human Navy"):setCallSign(generateCallSign(nil,"Human Navy")):orderDefendTarget(repair_station):setPosition(diner_x + repair_x, diner_y + repair_y):setCommsScript(""):setCommsFunction(commsShip))
		table.insert(patrol_fleet,CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign(generateCallSign(nil,"Human Navy")):orderDefendTarget(repair_station):setPosition(diner_x + repair_x, diner_y + repair_y):setCommsScript(""):setCommsFunction(commsShip))
		for i, ship in ipairs(patrol_fleet) do
			ship.patrol_fleet = true
		end
	end
end
function directTransportsToStations(delta)
	if transport_list == nil then
		transport_list = {}
	end
	if #transport_list > 0 then
		for transport_index, transport in ipairs(transport_list) do
			if transport ~= nil and transport:isValid() then
				if transport.normal_transport_plot then
					local target = nil
					if transport.target ~= nil and transport.target:isValid() then
						local docked_with = transport:getDockedWith()
						if docked_with ~= nil then
							if transport.undock_delay == nil then
								transport.undock_delay = random(20,120)
							end
							transport.undock_delay = transport.undock_delay - delta
							if transport.undock_delay < 0 then
								target = pickTransportTarget(transport)
								if target ~= nil then
									transport.target = target
								else
									if transport.home_station ~= nil then
										transport.target = transport.home_station
									end
								end
								if transport.target ~= nil then
									transport:orderDock(transport.target)
								end
								transport.undock_delay = random(20,120)
							end
						end
					else
						for station_index, station in ipairs(friendly_neutral_stations) do
							if station == nil or not station:isValid() then
								table.remove(friendly_neutral_stations,station_index)
								break
							end
						end
						for station_index, station in ipairs(transport_stations) do
							if station == nil or not station:isValid() then
								table.remove(transport_stations,station_index)
								break
							end
						end
						target = pickTransportTarget(transport)
						if target ~= nil then
							transport.target = target
						else
							if transport.home_station ~= nil then
								transport.target = transport.home_station
							end
						end
						if transport.target ~= nil then
							transport:orderDock(transport.target)
						end
					end
				end
			else
				table.remove(transport_list,transport_index)
				break
			end
		end
	end
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
function dinerPlaceStation(x,y,name,faction,size)
	local station = placeStation(x,y,name,faction,size)
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
		local negAxisKrak = (posAxisKrak + 180) % 360
		local xPosAngleKrak, yPosAngleKrak = vectorFromAngle(posAxisKrak, posKrak)
		local posKrakEnd = random(30,70)
		local negKrakEnd = random(40,80)
		--[[
		if station_name == "Krik" then
			posKrak = random(30000,80000)
			negKrak = random(20000,60000)
			spreadKrak = random(5000,8000)
			posKrakEnd = random(40,90)
			negKrakEnd = random(30,60)
		end
		--]]
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
	addGMFunction("Global Vars",function()
		local out = "Marauder Plot: "
		if marauderPlot == marauderAttackPlayer then
			out = out .. "attack player"
		elseif marauderPlot == marauderAttackInFormation then
			out = out .. "attack in formation"
		elseif marauderPlot == marauderAttackDiner then
			out = out .. "attack diner"
		elseif marauderPlot == marauderRecover then
			out = out .. "recover"
		elseif marauderPlot == marauderToTheDiner then
			out = out .. "to the diner"
		elseif marauderPlot == nil then
			out = out .. "nil"
		else
			out = out .. "unknown"
		end
		out = out .. "   Marauder State: "
		if marauder_state == nil then
			out = out .. "nil"
		elseif marauder_state == 0 then
			out = out .. "0: leader attack player, follower fly formation"
		elseif marauder_state == 1 then
			out = out .. "1: leader and follower attack player or diner"
		elseif marauder_state == 2 then
			out = out .. "2: leader and follower blind retreat"
		elseif marauder_state == 3 then
			out = out .. "3: leader and follower recover"
		else
			out = out .. "unknown"
		end
		out = out .. "\nPatrol Plot: "
		if patrolPlot == patrolToTheDiner then
			out = out .. "to the diner"
		elseif patrolPlot == patrolDefendDiner then
			out = out .. "defend diner"
		elseif patrolPlot == patrolToRepair then
			out = out .. "to repair"
		elseif patrolPlot == patrolRecover then
			out = out .. "recover"
		elseif patrolPlot == nil then
			out = out .. "nil"
		else
			out = out .. "unknown"
		end
		out = out .. "   Defend Diner Timer: "
		if diner_defend_timer == nil then
			out = out .. "nil"
		else
			out = out .. string.format("%.1f",(getScenarioTime() - diner_defend_timer))
		end
		out = out .. "\nBuzzer Plot: "
		if buzzerPlot == buzzerRoaming then
			out = out .. "roaming"
		elseif buzzerPlot == buzzerPlayer then
			out = out .. "player"
		elseif buzzerPlot == buzzerDiner then
			out = out .. "diner"
		elseif buzzerPlot == buzzerRecover then
			out = out .. "recover"
		elseif buzzerPlot == nil then
			out = out .. "nil"
		else
			out = out .. "unknown"
		end
		out = out .. "   Buzzer Timer: "
		if buzzer_timer == nil then
			out = out .. "nil"
		else
			out = out .. string.format("%.1f",(buzzer_timer - getScenarioTime()))
		end
		out = out .. "\nRepair Impulse Plot: "
		if plotRepairImpulse == nil then
			out = out .. "nil"
		elseif plotRepairImpulse == startRepairImpulse then
			out = out .. "start"
		elseif plotRepairImpulse == cleanUpImpulseRepair then
			out = out .. "clean up"
		else
			out = out .. "unknown"
		end
		out = out .. "   Impulse Repair Timer: "
		if repair_impulse_timer == nil then
			out = out .. "nil"
		else
			out = out .. string.format("%.1f",repair_impulse_timer - getScenarioTime())
		end
		out = out .. string.format("\nUpgrade player ship %s",upgrade_player_ship)
		if repair_station:isValid() then
			out = out .. string.format("\nRepair: %s",repair_station:getCallSign())
		else
			out = out .. "\nRepair: (destroyed)"
		end
		if shop_station:isValid() then
			out = out .. string.format(", Shop: %s",shop_station:getCallSign())
		else
			out = out .. ", Shop: (destroyed)"
		end
		if mining_station:isValid() then
			out = out .. string.format(", Mining: %s",mining_station:getCallSign())
		else
			out = out .. ", Mining: (destroyed)"
		end
		if arlenian_station:isValid() then
			out = out .. string.format(", Arlenian: %s",arlenian_station:getCallSign())
		else
			out = out .. ", Arlenian: (destroyed)"
		end
		if usn_station:isValid() then
			out = out .. string.format(", USN: %s",usn_station:getCallSign())
		else
			out = out .. ", USN: (destroyed)"
		end
		addGMMessage(out)
	end)
end
function mainGMButtons()
	clearGMFunctions()
	addGMFunction(string.format("Version %s",scenario_version),function()
		local version_message = string.format("Scenario version %s\n LUA version %s",scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	addGMFunction("+debug",debugButtons)
	if spicePlot == nil then
		addGMFunction("Stop or continue",function()
			spicePlot = pirateHarassment
			rescued_escape_pods = true
			finalize_player_ship_work = true
			escape_pod_count = 0
			technician_vacation = false
			addGMMessage("Skipping to the point where the player chooses to stop or to fight the Kraylor base")
		end)
	end
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
function edwardRepairsImpulseEngines()
	if comms_source:isDocked(comms_target) then
		comms_source:setCanDock(false)
		repair_impulse_timer = getScenarioTime() + 90
		plotRepairImpulse = startRepairImpulse
		setCommsMessage("Impulse engine repairs are under way")
	else
		setCommsMessage("I can't work on your engines unless you're docked.")
	end
	addCommsReply("Back",commsStation)
end
function handleDockedState()
    if comms_source:isFriendly(comms_target) then
    	if comms_target.comms_data.friendlyness > 66 then
    		oMsg = string.format("Greetings %s!\nHow may we help you today?",comms_source:getCallSign())
    	elseif comms_target.comms_data.friendlyness > 33 then
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
	if comms_source.delivery_station ~= nil and comms_source.delivery_station == comms_target then
		addCommsReply("Deliver food from Moe's Diner",function()
			setCommsMessage("We've been looking forward to that. Thank you very much. Moe always makes such tasty food")
			comms_source:addReputationPoints(math.random(5,10))
			comms_source.delivery_station = nil
			addCommsReply("Back",commsStation)
		end)
	end
	if comms_target == diner_station then
		local edward_available = true
		if not impulse_repaired then
			if edward_talk_diagnostic then print("impulse not repaired") end
			if repair_transport:isDocked(comms_target) or shop_transport:isDocked(comms_target) then
				if edward_talk_diagnostic then print("a transport is docked with Moe's Diner") end
				edward_available = false
				local marauder_distance = 0
				if group1_leader ~= nil and group1_leader:isValid() then
					marauder_distance = distance(group1_leader,comms_target)
				end
				if group2_leader ~= nil and group2_leader:isValid() then
					local group2_leader_distance = distance(group2_leader,comms_target)
					if marauder_distance > 0 then
						marauder_distance = math.min(marauder_distance,group2_leader_distance)
					else
						marauder_distance = group2_leader_distance
					end
				end
				if marauder_distance < 15000 then
					if edward_talk_diagnostic then print("marauder distance < 15 U") end
					if random(1,100) < 17 then
						edward_available = true
						if edward_talk_diagnostic then print("available (< 17)") end
					else
						edward_available = false
						if edward_talk_diagnostic then print("unavailable (>= 17)") end
					end
				else
					if edward_talk_diagnostic then print("marauder distance >= 15 U") end
					if random(1,100) < 83 then
						edward_available = true
						if edward_talk_diagnostic then print("available (< 83)") end
					else
						edward_available = false
						if edward_talk_diagnostic then print("unavailable (>= 83)") end
					end
				end
			else
				if edward_talk_diagnostic then print("transports not docked with Moe's Diner") end
				if plotRepairImpulse ~= nil then
					edward_available = true
					repair_impulse_timer = repair_impulse_timer + 20
					if edward_talk_diagnostic then print("available, 20 seconds added to timer") end
				else
					if edward_talk_diagnostic then print("plot repair impulse is nil") end
					if random(1,100) < 83 then
						edward_available = true
						if edward_talk_diagnostic then print("available (< 83)") end
					else
						edward_available = false
						if edward_talk_diagnostic then print("unavailable (>= 83)") end
					end
				end
			end
			addCommsReply("Talk to Edward",function()
				string.format("")	--global context for serios proton
				if edward_available then
					if plotRepairImpulse ~= nil then
						setCommsMessage("I'm working on your impulse engines")
					else
						setCommsMessage(string.format("I'm glad you could make it. The Hornet you acquired looks great! %s, eh? What kind of name is that?",comms_source:getCallSign()))
						addCommsReply(string.format("It came named %s, so we don't know",comms_source:getCallSign()),function()
							setCommsMessage("Got it. So, I understand you're here to get your secondary impulse engine in top working condition. I've got the parts and the time. Are you ready for me to work on it? Keep in mind that while I am working on it, you won't be able to undock.")
							addCommsReply("What about that Exuari group?",edwardExuariGroupMessage)
							addCommsReply("How long will it take to fix the impulse engine?",function()
								setCommsMessage("It should only take one or two minutes to fix your impulse engines. The hard part was getting the components and I've already got those")
								addCommsReply("If you're ready, please proceed. We'll wait",edwardRepairsImpulseEngines)
							end)
							addCommsReply("We'll wait. Please repair the impulse engines",edwardRepairsImpulseEngines)
							addCommsReply("Back",commsStation)
						end)
						addCommsReply("We're not sure. Do you have any ideas?",function()
							local player_ship_names_and_descriptions = {
								{name = "Thorny", resp = "Thanks", desc = "I think Thorny cautions your enemies that you're about to cause them pain - like a thorn in their side"},
								{name = "Streak", resp = "Ha! Thanks", desc = "Streak reminds me of fast speed. Kind of a misnomer until your impulse engines are fixed."},
								{name = "Flit", resp = "Thanks", desc = "Flit refers to how a small terrestrial airborn animal travels quickly from point to point."},
								{name = "Bzzt", resp = "Thanks", desc = "Bzzt seems like an onomatopoeia of the sound a hornet makes when it lands and stings."},
								{name = "Slip", resp = "Thanks", desc = "I think any of these meanings could apply: to move easily, a long narrow piece, a slender youth"},
								{name = "Quest", resp = "Thanks", desc = "The best I can tell you is that it means a journey with some kind of grand goal."},
								{name = "Zip", resp = "Thanks", desc = "I think the name refers to the Hornet's speed. Must have been named before the engines were damaged."},
								{name = "Stinger", resp = "Thanks", desc = "The name could refer back to the hornet's natural weapon."},
								{name = "Sphex", resp = "Thanks", desc = "I think this is part of the scientific name for insects like the Hornet."},
								{name = "Vespa", resp = "Thanks", desc = "I think this might be a partial scientific name for wasps or hornets."},
								{name = "Bembicini", resp = "Thanks", desc = "Bembicini is a fancy name for a wasp or a hornet."},
								{name = "Polyturator", resp = "Thanks", desc = "I think Polyturator is a kind of wasp."},
								{name = "Urocerus", resp = "Thanks", desc = "The Urocerus is a kind of stinging insect."},
								{name = "Fervida", resp = "No worries", desc = "Sorry, can't help you. Fervid means hot. Not sure about Fervida."},
							}
							local desc = nil
							local resp = "No worries"
							for i=1,#player_ship_names_and_descriptions do
								if player_ship_names_and_descriptions[i].name == comms_source:getCallSign() then
									desc = player_ship_names_and_descriptions[i].desc
									resp = player_ship_names_and_descriptions[i].resp
								end
							end
							if desc ~= nil then
								setCommsMessage(desc)
							else
								setCommsMessage(string.format("Sorry, %s is not familiar to me",comms_source:getCallSign()))
							end
							addCommsReply(string.format("%s. Please proceed with the impulse engine repairs",resp),edwardRepairsImpulseEngines)
							addCommsReply("Back",commsStation)
						end)
					end
				else
					setCommsMessage("Edward is with a customer right now. You'll have to try again later")
				end
				addCommsReply("Back",commsStation)
			end)
		else	--impulse repaired
			if edward_talk_diagnostic then print("impulse repaired") end
			addCommsReply("Talk to Edward",function()
				string.format("")	--global context for serious proton
				if edward_available then
					setCommsMessage("I'm glad I could get your impulse engines in proper working order.")
					addCommsReply("Thanks for help",function()
						string.format("")	--global context
						setCommsMessage("You're welcome. I'm on break from the dining room right now. Is there anything else?")
						if comms_source.edward_list_button == nil then
							addCommsReply("Can you help us with our secondary systems?",function()
								string.format("")	--global context
								setCommsMessage("I really need to keep up my job here at the diner. However, I know where you can get pretty good deals on secondary ship systems repairs around here. I'll drop a note in your computer systems with a list of stations that do good work relatively inexpensively.")
								if comms_source.edward_list_button == nil then
									comms_source.edward_list_button = true
									local edward_list_message = "Stations that can easily fix broken secondary systems:\nSector, Station, System, Reputation:"
									for i, station in ipairs(secondary_repair_stations) do
										edward_list_message = string.format("%s\n%s, %s, %s, %s",edward_list_message,station.station:getSectorName(),station.station:getCallSign(),station.repair,station.rep)
									end
									comms_source.edwards_list_button_relay = "edwards_list_button_relay"
									comms_source:addCustomButton("Relay",comms_source.edwards_list_button_relay,"Edward's Note",function()
										string.format("")
										comms_source.edwards_list_button_relay_message = "edwards_list_button_relay_message"
										comms_source:addCustomMessage("Relay",comms_source.edwards_list_button_relay_message,edward_list_message)
									end)
									comms_source.edwards_list_button_ops = "edwards_list_button_ops"
									comms_source:addCustomButton("Operations",comms_source.edwards_list_button_ops,"Edward's Note",function()
										string.format("")
										comms_source.edwards_list_button_ops_message = "edwards_list_button_ops_message"
										comms_source:addCustomMessage("Operations",comms_source.edwards_list_button_ops_message,edward_list_message)
									end)
									comms_source.edwards_list_button_helm = "edwards_list_button_helm"
									comms_source:addCustomButton("Helms",comms_source.edwards_list_button_helm,"Edward's Note",function()
										string.format("")
										comms_source.edwards_list_button_helm_message = "edwards_list_button_helm_message"
										comms_source:addCustomMessage("Helms",comms_source.edwards_list_button_helm_message,edward_list_message)
									end)
									comms_source.edwards_list_button_tac = "edwards_list_button_tac"
									comms_source:addCustomButton("Tactical",comms_source.edwards_list_button_tac,"Edward's Note",function()
										string.format("")
										comms_source.edwards_list_button_tac_message = "edwards_list_button_tac_message"
										comms_source:addCustomMessage("Tactical",comms_source.edwards_list_button_tac_message,edward_list_message)
									end)
								end
								addCommsReply("Back",commsStation)
							end)
						end
						addCommsReply("Back",commsStation)
					end)
				else
					setCommsMessage("Edward is with a customer right now. You'll have to try again later")
				end
				addCommsReply("Back",commsStation)
			end)
			if comms_source:getReputationPoints() <= 5 then
				if comms_source.diner_food_station == nil then
					addCommsReply("Deliver food for Moe",function()
						local customers = {repair_station,shop_station,arlenian_station,mining_station,usn_station}
						if comms_source.delivery_station == nil then
							repeat
								comms_source.delivery_station = customers[math.random(1,#customers)]
							until(comms_source.delivery_station ~= nil and comms_source.delivery_station:isValid())
							setCommsMessage(string.format("Please deliver this food order to %s in %s. Thanks",comms_source.delivery_station:getCallSign(),comms_source.delivery_station:getSectorName()))
						else
							if comms_source.delivery_station:isValid() then
								setCommsMessage(string.format("We don't have any additional deliveries available. Besides, you still need to deliver your current food order to %s in %s.",comms_source.delivery_station:getCallSign(),comms_source.delivery_station:getSectorName()))
							else
								repeat
									comms_source.delivery_station = customers[math.random(1,#customers)]
								until(comms_source.delivery_station ~= nil and comms_source.delivery_station:isValid())
								setCommsMessage(string.format("We keep losing customers left and right. Please deliver this food order to %s in %s. Thanks",comms_source.delivery_station:getCallSign(),comms_source.delivery_station:getSectorName()))
							end
						end
						addCommsReply("Back",commsStation)
					end)
				end
			end
		end
	end
	if upgrade_player_ship then
		addCommsReply("Upgrade ship",function()
			string.format("")	--global context
			if comms_target == repair_station then
				if comms_source.strengthen_shields == nil then
					setCommsMessage("The technicians here can raise the strength of your shields. They think you'll need it if you go after the Exuari. Interested?")
					addCommsReply("Yes, we want our shield strength increased",function()
						string.format("")	--global context
						if comms_source:getShieldCount() == 1 then
							comms_source:setShieldsMax(100):setShields(100)
						else
							comms_source:setShieldsMax(100,100):setShields(100,100)
						end
						setCommsMessage("You got it! Good luck with those Exuari.")
						comms_source.strengthen_shields = true
						addCommsReply("Back",commsStation)
					end)
				else
					if shop_station ~= nil and shop_station:isValid() then
						setCommsMessage(string.format("We can't help you anymore, but we hear that %s can",shop_station:getCallSign()))
					else
						setCommsMessage("We can't help you anymore")
					end
				end
			elseif comms_target == shop_station then
				if comms_source.homing_missile == nil then
					setCommsMessage("We've got a spare homing missile launcher designed for your ship. We'd be willing to install it if you think you'll use it against those persnickety Exuari marauders.")
					addCommsReply("We'd like the missile launcher installed",function()
						string.format("")	--global context
						if comms_source:getWeaponTubeCount() == 0 then
							comms_source:setWeaponTubeCount(1):setWeaponTubeExclusiveFor(0,"Homing"):setWeaponStorageMax("Homing",5):setWeaponStorage("Homing",5)
						else
							comms_source:setWeaponTubeCount(2):setWeaponTubeExclusiveFor(0,"Homing"):setWeaponStorageMax("Homing",5):setWeaponStorage("Homing",5):setWeaponTubeDirection(0,0)
							comms_source:setWeaponTubeExclusiveFor(1,"Mine"):setWeaponTubeDirection(1,180)
						end
						setCommsMessage("Installed. Go shoot some Exuari for us")
						comms_source.homing_missile = true
						addCommsReply("Back",commsStation)
					end)
				else
					if mining_station ~= nil and mining_station:isValid() then
						setCommsMessage(string.format("We only had the missile launcher, but %s may have something for you",mining_station:getCallSign()))
					else
						setCommsMessage("We only had the missile launcher, sorry")
					end
				end
			elseif comms_target == mining_station then
				if comms_source.mine_tube == nil then
					setCommsMessage("We could install a mine launching tube designed for your MP52 Hornet. That could be very useful against hostile Exuari.")
					addCommsReply("Oh yes, please install the mine tube",function()
						string.format("")	--global context
						if comms_source:getWeaponTubeCount() == 0 then
							comms_source:setWeaponTubeCount(1):setWeaponTubeExclusiveFor(0,"Mine"):setWeaponStorageMax("Mine",5):setWeaponStorage("Mine",5):setWeaponTubeDirection(0,180)
						else
							comms_source:setWeaponTubeCount(2):setWeaponTubeExclusiveFor(1,"Mine"):setWeaponStorageMax("Mine",5):setWeaponStorage("Mine",5):setWeaponTubeDirection(1,180)
						end
						setCommsMessage("You have a mine launching tube in the rear. Be careful, those mines can be dangerous.")
						comms_source.mine_tube = true
						addCommsReply("Back",commsStation)
					end)
				else
					if arlenian_station ~= nil and arlenian_station:isValid() then
						setCommsMessage(string.format("We've got nothing else, but maybe %s has something",arlenian_station:getCallSign()))
					else
						setCommsMessage("We've got nothing else.")
					end
				end
			elseif comms_target == arlenian_station then
				if comms_source.warp_drive == nil then
					setCommsMessage("We've got a miniaturized warp drive that fits small ships like yours. A nimbler ship is much more of a threat to any nefarious Exuari you might encounter. Would you like it?")
					addCommsReply("A warp drive would be fabulous. We'll take it",function()
						string.format("")	--global context
						comms_source:setWarpDrive(true):setWarpSpeed(750)
						setCommsMessage("Congratulations, you are now the proud owner of a warp drive enabled vessel. Use it wisely.")
						comms_source.warp_drive = true
						addCommsReply("Back",commsStation)
					end)
				else
					if usn_station ~= nil and usn_station:isValid() then
						setCommsMessage(string.format("We have already helped you. However, you should check with %s",usn_station:getCallSign()))
					else
						setCommsMessage("We have already helped you.")
					end
				end
			elseif comms_target == usn_station then
				if comms_source.beam_speed == nil then
					setCommsMessage("We can improve your beam weapon performance by reducing the amount of time it takes to recharge between shots. Would that help you against, say, enemy Exuari?")
					addCommsReply("That would help. Please make those performance improvements",function()
						string.format("")	--global context
						comms_source:setBeamWeapon(0,30,5,900,2.5,2.5):setBeamWeapon(1,30,-5,900,2.5,2.5)
						setCommsMessage("Done. You should notice a marked improvement in your beam charge times. Spread some beam cheer to our Exuari 'friends.'")
						comms_source.beam_speed = true
						addCommsReply("Back",commsStation)
					end)
				else
					if second_mining_station ~= nil and second_mining_station:isValid() then
						setCommsMessage(string.format("We already tweaked your beams. You shoud inquire at %s",second_mining_station:getCallSign()))
					else
						setCommsMessage("We already tweaked your beams.")
					end
				end
			elseif comms_target == second_mining_station then
				if comms_source.second_shield_arc == nil then
					setCommsMessage("We can improve your shield protection by adding another shield generator so that you can have a front and rear shield arc. That could help agains thte Exuari, right?")
					addCommsReply("It would! Please install another shield generator",function()
						string.format("")
						comms_source:setShieldsMax(comms_source:getShieldMax(0),comms_source:getShieldMax(0))
						setCommsMessage("Installed. Take the fight to the Exuari for us")
						comms_source.second_shield_arc = "installed"
						addCommsReply("Back",commsStation)
					end)
				else
					if repair_station ~= nil and repair_station:isValid() then
						setCommsMessage(string.format("We already gave you a second shield arc. You shoud inquire at %s",repair_station:getCallSign()))
					else
						setCommsMessage("We already gave you a second shield arc.")
					end
				end
			else
				setCommsMessage("Sorry, no upgrades here.\n\nThe rapscallion that set light to the grail shaped beacon ...uh... I mean enabled the 'Upgrade ship' button will be severely chastised")
			end
			addCommsReply("Back",commsStation)
		end)
	end
	local missilePresence = 0
	local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	for i, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + comms_source:getWeaponStorageMax(missile_type)
	end
	if missilePresence > 0 then
		if 	(comms_target.comms_data.weapon_available.Nuke   and comms_source:getWeaponStorageMax("Nuke") > 0)   or 
			(comms_target.comms_data.weapon_available.EMP    and comms_source:getWeaponStorageMax("EMP") > 0)    or 
			(comms_target.comms_data.weapon_available.Homing and comms_source:getWeaponStorageMax("Homing") > 0) or 
			(comms_target.comms_data.weapon_available.Mine   and comms_source:getWeaponStorageMax("Mine") > 0)   or 
			(comms_target.comms_data.weapon_available.HVLI   and comms_source:getWeaponStorageMax("HVLI") > 0)   then
			addCommsReply("I need ordnance restocked", function()
				if stationCommsDiagnostic then print("in restock function") end
				setCommsMessage(string.format("What type of ordnance?\n\nReputation: %i",math.floor(comms_source:getReputationPoints())))
				if stationCommsDiagnostic then print(string.format("player nuke weapon storage max: %.1f",comms_source:getWeaponStorageMax("Nuke"))) end
				if comms_source:getWeaponStorageMax("Nuke") > 0 then
					if stationCommsDiagnostic then print("player can fire nukes") end
					if comms_target.comms_data.weapon_available.Nuke then
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
					if comms_target.comms_data.weapon_available.EMP then
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
					if comms_target.comms_data.weapon_available.Homing then
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
					if comms_target.comms_data.weapon_available.Mine then
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
					if comms_target.comms_data.weapon_available.HVLI then
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
					addCommsReply(string.format("Repair probe launch system (%s Rep)",comms_target.comms_data.service_cost.probe_launch_repair),function()
						if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.probe_launch_repair) then
							comms_source:setCanLaunchProbe(true)
							if comms_target.comms_data.mission_message == nil then
								setCommsMessage("Your probe launch system has been repaired")
							else
								setCommsMessage(string.format("Your probe launch system has been repaired.\n\n%s",comms_target.comms_data.mission_message))
							end
						else
							setCommsMessage("Insufficient reputation")
						end
						addCommsReply("Back", commsStation)
					end)
				end
			end
			if comms_target.comms_data.hack_repair then
				if not comms_source:getCanHack() then
					addCommsReply(string.format("Repair hacking system (%s Rep)",comms_target.comms_data.service_cost.hack_repair),function()
						if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.hack_repair) then
							comms_source:setCanHack(true)
							if comms_target.comms_data.mission_message == nil then
								setCommsMessage("Your hack system has been repaired")
							else
								setCommsMessage(string.format("Your hack system has been repaired.\n\n%s",comms_target.comms_data.mission_message))
							end
						else
							setCommsMessage("Insufficient reputation")
						end
						addCommsReply("Back", commsStation)
					end)
				end
			end
			if comms_target.comms_data.scan_repair then
				if not comms_source:getCanScan() then
					addCommsReply(string.format("Repair scanning system (%s Rep)",comms_target.comms_data.service_cost.scan_repair),function()
						if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.scan_repair) then
							comms_source:setCanScan(true)
							if comms_target.comms_data.mission_message == nil then
								setCommsMessage("Your scanners have been repaired")
							else
								setCommsMessage(string.format("Your scanners have been repaired.\n\n%s",comms_target.comms_data.mission_message))
							end
						else
							setCommsMessage("Insufficient reputation")
						end
						addCommsReply("Back", commsStation)
					end)
				end
			end
			if comms_target.comms_data.combat_maneuver_repair then
				if not comms_source:getCanCombatManeuver() then
					addCommsReply(string.format("Repair combat maneuver (%s Rep)",comms_target.comms_data.service_cost.combat_maneuver_repair),function()
						if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.combat_maneuver_repair) then
							comms_source:setCanCombatManeuver(true)
							if comms_target.comms_data.mission_message == nil then
								setCommsMessage("Your combat maneuver has been repaired")
							else
								setCommsMessage(string.format("Your combat maneuver has been repaired.\n\n%s",comms_target.comms_data.mission_message))
							end
						else
							setCommsMessage("Insufficient reputation")
						end
						addCommsReply("Back", commsStation)
					end)
				end
			end
			if comms_target.comms_data.self_destruct_repair then
				if not comms_source:getCanSelfDestruct() then
					addCommsReply(string.format("Repair self destruct system (%s Rep)",comms_target.comms_data.service_cost.self_destruct_repair),function()
						if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.self_destruct_repair) then
							comms_source:setCanSelfDestruct(true)
							if comms_target.comms_data.mission_message == nil then
								setCommsMessage("Your self destruct system has been repaired")
							else
								setCommsMessage(string.format("Your self destruct system has been repaired.\n\n%s",comms_target.comms_data.mission_message))
							end
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
					setCommsMessage(comms_target.comms_data.general)
					addCommsReply("Back", commsStation)
				end)
			end
			if comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "" then
				addCommsReply("Station history", function()
					setCommsMessage(comms_target.comms_data.history)
					addCommsReply("Back", commsStation)
				end)
			end
			if comms_source:isFriendly(comms_target) then
				if comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" then
					if random(1,100) < (100 - (30 * (difficulty - .5))) then
						addCommsReply("Gossip", function()
							setCommsMessage(comms_target.comms_data.gossip)
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
			setOptionalOrders()
			setSecondaryOrders()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
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
	for good, goodData in pairs(comms_target.comms_data.goods) do
		goodCount = goodCount + 1
	end
	if goodCount > 0 then
		addCommsReply("Buy, sell, trade", function()
			local goodsReport = string.format("Station %s:\nGoods or components available for sale: quantity, cost in reputation\n",comms_target:getCallSign())
			for good, goodData in pairs(comms_target.comms_data.goods) do
				goodsReport = goodsReport .. string.format("     %s: %i, %i\n",good,goodData["quantity"],goodData["cost"])
			end
			if comms_target.comms_data.buy ~= nil then
				goodsReport = goodsReport .. "Goods or components station will buy: price in reputation\n"
				for good, price in pairs(comms_target.comms_data.buy) do
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
			for good, goodData in pairs(comms_target.comms_data.goods) do
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
			if comms_target.comms_data.buy ~= nil then
				for good, price in pairs(comms_target.comms_data.buy) do
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
			if comms_target.comms_data.trade.food then
				if comms_source.goods ~= nil then
					if comms_source.goods.food ~= nil then
						if comms_source.goods.food.quantity > 0 then
							for good, goodData in pairs(comms_target.comms_data.goods) do
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
			if comms_target.comms_data.trade.medicine then
				if comms_source.goods ~= nil then
					if comms_source.goods.medicine ~= nil then
						if comms_source.goods.medicine.quantity > 0 then
							for good, goodData in pairs(comms_target.comms_data.goods) do
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
			if comms_target.comms_data.trade.luxury then
				if comms_source.goods ~= nil then
					if comms_source.goods.luxury ~= nil then
						if comms_source.goods.luxury.quantity > 0 then
							for good, goodData in pairs(comms_target.comms_data.goods) do
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
function edwardExuariGroupMessage()
	setCommsMessage("They are pretty bad. They fly around harassing anyone they think they can get something from")
	addCommsReply("Do you think they'll come after us?",function()
		setCommsMessage("The chances are pretty good. They like stealing whatever they can get from ships and reselling it on the black market or adding it to their own fleet.")
		addCommsReply("Back",commsStation)	
	end)
	addCommsReply("Why hasn't the CUF patrol taken care of them?",function()
		setCommsMessage("The CUF patrol has tried. However, their patrol pattern is pretty easy to predict and the Exuari often do their dirty deeds while the patrol is somewhere else.")
		addCommsReply("Back",commsStation)	
	end)
	addCommsReply("Will they attack Moe's Diner?",function()
		setCommsMessage("The Exuari marauders usually don't bother us much. We occasionally deliver food to them and we don't really have anything they're interested in on the station.")
		addCommsReply("Back",commsStation)	
	end)
	addCommsReply("Back",commsStation)
end
function handleUndockedState()
    --Handle communications when we are not docked with the station.
    if comms_source:isFriendly(comms_target) then
        oMsg = "Good day, officer.\nIf you need supplies, please dock with us first."
    else
        oMsg = "Greetings.\nIf you want to do business, please dock with us first."
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you."
	end
	setCommsMessage(oMsg)
	if comms_target == diner_station then
		if not impulse_repaired then
			addCommsReply("Talk to Edward",function()
				if random(1,100) < 18 then
					setCommsMessage("Edward is with a customer right now. You'll have to try again later")
				else
					setCommsMessage("Good to hear from you! Did you get the Hornet?")
					addCommsReply("Yes and we're headed your way",function()
						setCommsMessage("Drop on by. I've got the impulse engine part for your second impulse engine ready. I'm working in the diner today, so if I'm busy, you'll have to wait until I get a break. The repair won't take long.")
						addCommsReply("What about that Exuari group?",edwardExuariGroupMessage)
						addCommsReply("Back",commsStation)
					end)
					addCommsReply("Yes, but it's got impulse engine problems",function()
						setCommsMessage("I remember that. I've got the replacement part. Drop by anytime, but I'm working in the diner today. I'll help you out as soon as I'm on break. The repair won't take long.")
						addCommsReply("What about that Exuari group?",edwardExuariGroupMessage)
						addCommsReply("Back",commsStation)
					end)
				end
				addCommsReply("Back",commsStation)
			end)
		end
	end
	--[[
	if isAllowedTo(comms_target.comms_data.services.preorder) then
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
			local missileTypeAvailableCount = 0
			local ordnanceListMsg = ""
			if comms_target.comms_data.weapon_available.Nuke then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   Nuke"
			end
			if comms_target.comms_data.weapon_available.EMP then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   EMP"
			end
			if comms_target.comms_data.weapon_available.Homing then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   Homing"
			end
			if comms_target.comms_data.weapon_available.Mine then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   Mine"
			end
			if comms_target.comms_data.weapon_available.HVLI then
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
			setCommsMessage(service_status)
			addCommsReply("Back", commsStation)
		end)
		local goodsAvailable = false
		if comms_target.comms_data.goods ~= nil then
			for good, goodData in pairs(comms_target.comms_data.goods) do
				if goodData["quantity"] > 0 then
					goodsAvailable = true
				end
			end
		end
		if goodsAvailable then
			addCommsReply("What goods do you have available for sale or trade?", function()
				local goodsAvailableMsg = string.format("Station %s:\nGoods or components available: quantity, cost in reputation",comms_target:getCallSign())
				for good, goodData in pairs(comms_target.comms_data.goods) do
					goodsAvailableMsg = goodsAvailableMsg .. string.format("\n   %14s: %2i, %3i",good,goodData["quantity"],goodData["cost"])
				end
				setCommsMessage(goodsAvailableMsg)
				addCommsReply("Back", commsStation)
			end)
		end
		addCommsReply("Where can I find particular goods?", function()
			gkMsg = "Friendly stations often have food or medicine or both. Neutral stations may trade their goods for food, medicine or luxury."
			if comms_target.comms_data.goodsKnowledge == nil then
				comms_target.comms_data.goodsKnowledge = {}
				local knowledgeCount = 0
				local knowledgeMax = 10
				for i=1,#friendly_neutral_stations do
					local station = friendly_neutral_stations[i]
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
								comms_target.comms_data.goodsKnowledge[good] =	{	station = stationCallSign,
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
			for good, goodKnowledge in pairs(comms_target.comms_data.goodsKnowledge) do
				goodsKnowledgeCount = goodsKnowledgeCount + 1
				addCommsReply(good, function()
					local stationName = comms_target.comms_data.goodsKnowledge[good]["station"]
					local sectorName = comms_target.comms_data.goodsKnowledge[good]["sector"]
					local goodName = good
					local goodCost = comms_target.comms_data.goodsKnowledge[good]["cost"]
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
						setCommsMessage(comms_target.comms_data.general)
						addCommsReply("Back", commsStation)
					end)
				end
				if comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "" then
					addCommsReply("Station history", function()
						setCommsMessage(comms_target.comms_data.history)
						addCommsReply("Back", commsStation)
					end)
				end
				if comms_source:isFriendly(comms_target) then
					if comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" then
						if random(1,100) < 50 then
							addCommsReply("Gossip", function()
								setCommsMessage(comms_target.comms_data.gossip)
								addCommsReply("Back", commsStation)
							end)
						end
					end
				end
			end)	--end station info comms reply branch
		end	--end public relations if branch
		if comms_target.comms_data.character ~= nil then
			if random(1,100) < (70 - (20 * difficulty)) then
				addCommsReply(string.format("Tell me about %s",comms_target.comms_data.character), function()
					if comms_target.comms_data.characterDescription ~= nil then
						setCommsMessage(comms_target.comms_data.characterDescription)
					else
						if comms_target.comms_data.characterDeadEnd == nil then
							local deadEndChoice = math.random(1,5)
							if deadEndChoice == 1 then
								comms_target.comms_data.characterDeadEnd = "Never heard of " .. comms_target.comms_data.character
							elseif deadEndChoice == 2 then
								comms_target.comms_data.characterDeadEnd = comms_target.comms_data.character .. " died last week. The funeral was yesterday"
							elseif deadEndChoice == 3 then
								comms_target.comms_data.characterDeadEnd = string.format("%s? Who's %s? There's nobody here named %s",comms_target.comms_data.character,comms_target.comms_data.character,comms_target.comms_data.character)
							elseif deadEndChoice == 4 then
								comms_target.comms_data.characterDeadEnd = string.format("We don't talk about %s. They are gone and good riddance",comms_target.comms_data.character)
							else
								comms_target.comms_data.characterDeadEnd = string.format("I think %s moved away",comms_target.comms_data.character)
							end
						end
						setCommsMessage(comms_target.comms_data.characterDeadEnd)
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
									local ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setCallSign(generateCallSign(nil,"Human Navy")):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
									ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(friendlyVesselDestroyed)
									setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to assist at WP" .. n);
								else
									setCommsMessage("Not enough reputation!");
								end
							end
							tempAsteroid:destroy()
						else
							if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
								ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setCallSign(generateCallSign(nil,"Human Navy")):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
								ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(friendlyVesselDestroyed)
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
	if player_found_exuari_base then
		if comms_target.patrol_fleet and not patrol_convinced then
			addCommsReply("Report location of Exuari station",function()
				setCommsMessage(string.format("Thank you for identifying Exuari station %s in %s. Your report corroborates other recent reports. Your service to the greater community has been noted.",marauder_station:getCallSign(),marauder_station:getSectorName()))
				patrol_convinced = true
				patrolConvincedPlot = nil
				comms_source:addReputationPoints(30)
				addCommsReply("Back", commsShip)
			end)
		end
	end
	addCommsReply("Defend a waypoint", function()
		if comms_source:getWaypointCount() == 0 then
			setCommsMessage("No waypoints set. Please set a waypoint first.");
		else
			if comms_target.patrol_fleet then
				if patrol_convinced then
					setCommsMessage("Which waypoint should we defend?");
					for n=1,comms_source:getWaypointCount() do
						addCommsReply("Defend WP" .. n, function()
							comms_target:orderDefendLocation(comms_source:getWaypoint(n))
							setCommsMessage("We are heading to assist at WP" .. n ..".");
							addCommsReply("Back", commsShip)
						end)
					end
				else
					setCommsMessage("We cannot deviate from our patrol duty orders, sorry")
				end
			else
				setCommsMessage("Which waypoint should we defend?");
				for n=1,comms_source:getWaypointCount() do
					addCommsReply("Defend WP" .. n, function()
						comms_target:orderDefendLocation(comms_source:getWaypoint(n))
						setCommsMessage("We are heading to assist at WP" .. n ..".");
						addCommsReply("Back", commsShip)
					end)
				end
			end
		end
		addCommsReply("Back", commsShip)
	end)
	if comms_data.friendlyness > 0.2 then
		if comms_target.patrol_fleet then
			addCommsReply("Assist me", function()
				if patrol_convinced then
					setCommsMessage("Heading toward you to assist.");
					comms_target:orderDefendTarget(comms_source)
				else
					setCommsMessage("We cannot deviate from our patrol duty orders, sorry")
				end
				addCommsReply("Back", commsShip)
			end)
		else
			addCommsReply("Assist me", function()
				setCommsMessage("Heading toward you to assist.");
				comms_target:orderDefendTarget(comms_source)
				addCommsReply("Back", commsShip)
			end)
		end
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
	for i, obj in ipairs(comms_target:getObjectsInRange(5000)) do
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
		for i, enemy in ipairs(enemy_reverts) do
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
        local x = x0 + math.cos(r / 180 * math.pi) * distance
        local y = y0 + math.sin(r / 180 * math.pi) * distance
        local asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
        if farEnough(x, y, asteroid_size) then
	        local ta = Asteroid():setPosition(x, y):setSize(asteroid_size)
	        table.insert(place_space,{obj=ta,dist=asteroid_size})
	        VisualAsteroid():setPosition(x + random(-asteroid_size,asteroid_size), y + random(-asteroid_size,asteroid_size))
	        VisualAsteroid():setPosition(x + random(-asteroid_size,asteroid_size), y + random(-asteroid_size,asteroid_size))
	    end
    end
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
			local ax = x + math.cos(radialPoint / 180 * math.pi) * pointDist
			local ay = y + math.sin(radialPoint / 180 * math.pi) * pointDist
			if farEnough(ax, ay, asteroid_size) then
				local ta = Asteroid():setPosition(ax, ay):setSize(asteroid_size)
		        table.insert(place_space,{obj=ta,dist=asteroid_size})
		        VisualAsteroid():setPosition(ax + random(-asteroid_size,asteroid_size), ay + random(-asteroid_size,asteroid_size))
		        VisualAsteroid():setPosition(ax + random(-asteroid_size,asteroid_size), ay + random(-asteroid_size,asteroid_size))
			end
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
		    asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			local ax = x + math.cos(radialPoint / 180 * math.pi) * pointDist
			local ay = y + math.sin(radialPoint / 180 * math.pi) * pointDist
			if farEnough(ax, ay, asteroid_size) then
				local ta = Asteroid():setPosition(ax, ay):setSize(asteroid_size)
		        table.insert(place_space,{obj=ta,dist=asteroid_size})
		        VisualAsteroid():setPosition(ax + random(-asteroid_size,asteroid_size), ay + random(-asteroid_size,asteroid_size))
		        VisualAsteroid():setPosition(ax + random(-asteroid_size,asteroid_size), ay + random(-asteroid_size,asteroid_size))
			end
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
		    asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			local ax = x + math.cos(radialPoint / 180 * math.pi) * pointDist
			local ay = y + math.sin(radialPoint / 180 * math.pi) * pointDist
			if farEnough(ax, ay, asteroid_size) then
				local ta = Asteroid():setPosition(ax, ay):setSize(asteroid_size)
		        table.insert(place_space,{obj=ta,dist=asteroid_size})
		        VisualAsteroid():setPosition(ax + random(-asteroid_size,asteroid_size), ay + random(-asteroid_size,asteroid_size))
		        VisualAsteroid():setPosition(ax + random(-asteroid_size,asteroid_size), ay + random(-asteroid_size,asteroid_size))
			end
		end
	end
end
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction, enemyStrength, template_pool, shape, spawn_distance, spawn_angle, px, py)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	if enemyStrength == nil then
		enemyStrength = math.max(danger * enemy_power * playerPower(),5)
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
		template_pool_size = 15
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
		ship:setCallSign(generateCallSign(nil,enemyFaction)):orderRoaming()
		if ship:isEnemy(getPlayerShip(-1)) then
			ship:onDestroyed(enemyVesselDestroyed)
		elseif ship:isFriendly(getPlayerShip(-1)) then
			ship:onDestroyed(friendlyVesselDestroyed)
		end
		enemy_position = enemy_position + 1
		if shape == "none" or shape == "pyramid" or shape == "ambush" then
			ship:setPosition(xOrigin,yOrigin)
		else
			ship:setPosition(xOrigin + formation_delta[shape].x[enemy_position] * sp, yOrigin + formation_delta[shape].y[enemy_position] * sp)
		end
		ship:setCommsScript(""):setCommsFunction(commsShip)
		table.insert(enemyList, ship)
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
		for i, enemy in ipairs(enemyList) do
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
		for i, current_ship_template in ipairs(ship_template_by_strength) do
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
function friendlyVesselDestroyed(self, instigator)
	--[[
	tempShipType = self:getTypeName()
	table.insert(friendlyVesselDestroyedNameList,self:getCallSign())
	table.insert(friendlyVesselDestroyedType,tempShipType)
	table.insert(friendlyVesselDestroyedValue,ship_template[tempShipType].strength)
	--]]
end
function enemyVesselDestroyed(self, instigator)
	--[[
	tempShipType = self:getTypeName()
	local exclude_mod_list = {}
	if not self:hasSystem("warp") then
		table.insert(exclude_mod_list,4)
		table.insert(exclude_mod_list,25)
	end
	if not self:hasSystem("jumpdrive") then
		table.insert(exclude_mod_list,5)
		table.insert(exclude_mod_list,26)
	end
	if self:getShieldCount() < 1 then
		table.insert(exclude_mod_list,6)
		table.insert(exclude_mod_list,17)
		table.insert(exclude_mod_list,27)
	end
	if not self:hasSystem("beamweapons") then
		table.insert(exclude_mod_list,1)
		table.insert(exclude_mod_list,21)
		table.insert(exclude_mod_list,22)
	end
	if not self:hasSystem("missilesystem") then
		table.insert(exclude_mod_list,2)
		table.insert(exclude_mod_list,23)
	end
	local wreck_mod_type_index_list = {}
	if #exclude_mod_list > 0 then
		for i=1,#wreck_mod_type do
			local include = true
			for j=1,#exclude_mod_list do
				if i == exclude_mod_list[j] then
					include = false
				end
			end
			if include then
				table.insert(wreck_mod_type_index_list,i)
			end
		end
	else
		for i=1,#wreck_mod_type do
			table.insert(wreck_mod_type_index_list,i)
		end
	end
	local debris_count = math.floor(random(0,ship_template[tempShipType].strength)/6)
	if debris_count > 0 then
		local self_x, self_y = self:getPosition()
		for i=1,debris_count do
			local debris_x, debris_y = vectorFromAngle(random(0,360),random(300,500))
			if instigator ~= nil then
				local instigator_x, instigator_y = instigator:getPosition()
				while(distance(instigator_x, instigator_y, (self_x + debris_x), (self_y + debris_y)) < 400) do
					debris_x, debris_y = vectorFromAngle(random(0,360),random(300,500))
				end
			end
			if random(1,100) > 25 then
				local excluded_mod = false
--				local wmt = wreck_mod_type_index_list[math.random(1,#wreck_mod_type_index_list)]
				local wmt = 32	--for testing
				local wma = wreck_mod_type[wmt].func(self_x, self_y)
				wma.debris_end_x = self_x + debris_x
				wma.debris_end_y = self_y + debris_y
				table.insert(wreck_mod_debris,wma)
			else
				local ra = Asteroid():setPosition(self_x, self_y):setSize(80)
				ra.debris_end_x = self_x + debris_x
				ra.debris_end_y = self_y + debris_y
				table.insert(wreck_mod_debris,ra)
			end
		end
	end
	--]]
	local player = getPlayerShip(-1)
	if player ~= nil and player:isValid() then
		player:addReputationPoints(1)
	end
end
--      Inventory button and functions for relay/operations 
function cargoInventory(delta)
	for i,p in ipairs(getActivePlayerShips()) do
		local cargoHoldEmpty = true
		if p.goods ~= nil then
			for good, quantity in pairs(p.goods) do
				if quantity ~= nil and quantity > 0 then
					cargoHoldEmpty = false
					break
				end
			end
		end
		if cargoHoldEmpty then
			if p.inventory_button_rel ~= nil then
				p:removeCustom(p.inventory_button_rel)
				p.inventory_button_rel = nil
			end
			if p.inventory_button_ops ~= nil then
				p:removeCustom(p.inventory_button_ops)
				p.inventory_button_ops = nil
			end
		else
			if p.inventory_button_rel == nil then
				p.inventory_button_rel = "inventory_button_rel"
				p:addCustomButton("Relay",p.inventory_button_rel,"Inventory",function() 
					string.format("")
					playerShipCargoInventory(p,"Relay") 
				end)
			end
			if p.inventory_button_ops == nil then
				p.inventory_button_ops = "inventory_button_ops"
				p:addCustomButton("Operations",p.inventory_button_ops,"Inventory",function() 
					string.format("")
					playerShipCargoInventory(p,"Operations") 
				end)
			end
		end
	end
end
function playerShipCargoInventory(p,console)
	local out = string.format("%s Current cargo:",p:getCallSign())
	local goodCount = 0
	if p.goods ~= nil then
		for good, goodQuantity in pairs(p.goods) do
			goodCount = goodCount + 1
			out = string.format("%s\n     %s: %i",out,good,goodQuantity)
		end
	end
	if goodCount < 1 then
		out = string.format("%s\n     Empty",out)
	end
	out = string.format("%s\nAvailable space: %i",p.cargo)
	p:addCustomMessage(console,"inventory_message",out)
end
------------------------
--	Update functions  --
------------------------
function updateInner(delta)
	if delta == 0 then
		--game paused
		for i,p in ipairs(getActivePlayerShips()) do
			if p.pidx == nil then
				p.pidx = i
				setPlayer(p)
			end
		end
		return
	end
	local current_elapsed_time = getScenarioTime()
	if current_elapsed_time < reset_leader_acceleration and current_elapsed_time > reset_leader_acceleration - 1 then
		for index, leader in ipairs(group_leaders) do
			leader:setAcceleration(leader.original_acceleration)
		end
	end
	for i,p in ipairs(getActivePlayerShips()) do
		if p.pidx == nil then
			p.pidx = i
			setPlayer(p)
		end
	end
	if marauderPlot ~= nil then
		marauderPlot(delta)
	end
	if patrolPlot ~= nil then
		patrolPlot(delta)
	end
	if patrolConvincedPlot ~= nil then
		patrolConvincedPlot(delta)
	end
	if playerFoundExuariBasePlot ~= nil then
		playerFoundExuariBasePlot(delta)
	end
	if getScenarioTime() > 1200 then
		upgrade_player_ship = true
	end
	if buzzerPlot ~= nil then
		buzzerPlot(delta)
	end
	if plotRepairImpulse ~= nil then
		plotRepairImpulse(delta)
	end
	if spicePlot ~= nil then
		spicePlot(delta)
	end
	if directTransportsToStations ~= nil then
		directTransportsToStations(delta)
	end
	if cargoInventory ~= nil then	--cargo inventory
		cargoInventory(delta)
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

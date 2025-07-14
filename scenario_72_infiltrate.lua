-- Name: Infiltrate
-- Description: Join defensive fleet around primary Human Navy station and fight off enemies. Along the way, operational orders will be expanded.
--- 
--- Mission designed as a single ship mission for the Phobos M3P 
--- The broad outlines of the mission are the same each time, 
--- but some of the specifics vary for each mission run.
---
--- Duration: two hours at least
---
--- Version 1
---
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online. There's one every weekend. All experience levels are welcome. 
-- Type: Replayable Mission
-- Author: Xansta
-- Setting[Enemies]: Configures strength and/or number of enemies in this scenario
-- Enemies[Easy]: Fewer or weaker enemies
-- Enemies[Normal|Default]: Normal number or strength of enemies
-- Enemies[Hard]: More or stronger enemies
-- Enemies[Extreme]: Much stronger, many more enemies
-- Enemies[Quixotic]: Insanely strong and/or inordinately large numbers of enemies
-- Setting[Murphy]: Configures the perversity of the universe according to Murphy's law
-- Murphy[Easy]: Random factors are more in your favor
-- Murphy[Normal|Default]: Random factors are normal
-- Murphy[Hard]: Random factors are more against you
-- Setting[Fortress]: Configures the size of the enemy fortress. Default is large.
-- Fortress[Medium]: Medium sized fortress
-- Fortress[Large|Default]: Large sized fortress
-- Fortress[Huge]: Huge sized fortress

require("utils.lua")
require("place_station_scenario_utility.lua")
require("cpu_ship_diversification_scenario_utility.lua")
require("generate_call_sign_scenario_utility.lua")
--	also uses files border_defend_station.lua, platform_drop.lua, supply_drop.lua
--------------------
-- Initialization --
--------------------
function init()
	scenario_version = "0.1.1"
	ee_version = "2024.12.08"
	print(string.format("    ----    Scenario: Infiltrate    ----    Version %s    ----    Tested wuth EE version %s    ----",scenario_version,ee_version))
	print(_VERSION)
	setVariations()	--numeric difficulty, Kraylor fortress size
	setConstants()	--missle type names, template names and scores, deployment directions, player ship names, etc.
	constructEnvironment()
	mainGMButtons()
end
function setPlayer(p)
	if p == nil then
		return
	end
	p:setTemplate("Phobos M3P")
	p.maxRepairCrew = p:getRepairCrewCount()
	p.shipScore = playerShipStats["Phobos M3P"].strength 
	p.maxCargo = playerShipStats["Phobos M3P"].cargo
	p:setLongRangeRadarRange(playerShipStats["Phobos M3P"].long_range_radar)
	p:setShortRangeRadarRange(playerShipStats["Phobos M3P"].short_range_radar)
	p.normal_long_range_radar = p:getLongRangeRadarRange()
	p.tractor = playerShipStats["Phobos M3P"].tractor
	p.mining = playerShipStats["Phobos M3P"].mining
	local name = tableRemoveRandom(player_ship_names)
	if name ~= nil then
		p:setCallSign(name)
	end
	p.cargo = p.maxCargo
	p.initialCoolant = p:getMaxCoolant()	
	p.healthyShield = 1.0
	p.prevShield = 1.0
	p.healthyReactor = 1.0
	p.prevReactor = 1.0
	p.healthyManeuver = 1.0
	p.prevManeuver = 1.0
	p.healthyImpulse = 1.0
	p.prevImpulse = 1.0
	p.healthyBeam = 1.0
	p.prevBeam = 1.0
	p.healthyMissile = 1.0
	p.prevMissile = 1.0
	local system_types = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
	p.normal_coolant_rate = {}
	p.normal_power_rate = {}
	for _, system in ipairs(system_types) do
		p.normal_coolant_rate[system] = p:getSystemCoolantRate(system)
		p.normal_power_rate[system] = p:getSystemPowerRate(system)
	end
end
function setVariations()
	if getScenarioSetting == nil then
		enemy_power = 1
		difficulty = 1
		kraylor_fort_size = "Large Station"
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
			["Easy"] =		{number = .5,	},
			["Normal"] =	{number = 1,	},
			["Hard"] =		{number = 2,	},
		}
		difficulty =	murphy_config[getScenarioSetting("Murphy")].number
		local fortress_config = {
			["Medium"] = "Medium Station",
			["Large"] = "Large Station",
			["Huge"] = "Huge Station",
		}
		kraylor_fort_size = fortress_config[getScenarioSetting("Fortress")]
	end
end
function setConstants()
	distance_diagnostic = false
	stationCommsDiagnostic = false
	change_enemy_order_diagnostic = false
	healthDiagnostic = false
	local c_x, c_y = vectorFromAngleNorth(random(0,360),random(0,60000))
	center_x = 909000 + c_x
	center_y = 151000 + c_y
	zone_reveal_count = 0
	max_iff_time = 19 - (4 * difficulty)		--length of time in minutes
	cover_blown = "No"
	plotCI = cargoInventory
	plotH = healthCheck				--Damage to ship can kill repair crew members
	healthCheckTimerInterval = 8
	healthCheckTimer = healthCheckTimerInterval
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
		"Blinder",
		"Shadow",
		"Distortion",
		"Diemos",
		"Ganymede",
		"Castillo",
		"Thebe",
		"Retrograde",
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
	artifactCounter = 0
	artifactNumber = 0
	sensor_impact = 1	--normal
	sensor_jammer_list = {}
	sensor_jammer_range = 60000
	sensor_jammer_impact = 40000
	sensor_jammer_scan_complexity = 3
	sensor_jammer_scan_depth = 3
	sensor_jammer_power_units = false	--false means percentage, true is units
end
function constructEnvironment()
	place_space = {}
	transport_stations = {}
	kraylor_fort_angle = random(0,360)
	kraylor_fort_distance = random(80000,120000)
	kraylor_fort_x, kraylor_fort_y = vectorFromAngleNorth(kraylor_fort_angle,kraylor_fort_distance)
	kraylor_fort_x = kraylor_fort_x + center_x
	kraylor_fort_y = kraylor_fort_y + center_y
	kraylor_fort = placeStation(kraylor_fort_x,kraylor_fort_y,"Sinister","Kraylor",kraylor_fort_size)
	kraylor_fort:onDestroyed(winTheGame)
	table.insert(place_space,{obj=kraylor_fort,dist=25000})
	table.insert(transport_stations,kraylor_fort)
--	Spawn player
	local p = PlayerSpaceship():setTemplate("Phobos M3P")
	p:onTakingDamage(playerDamage)
	p.pidx = 1
	setPlayer(p)
	p:setPosition(center_x, center_y)
	allowNewPlayerShips(false)
	table.insert(place_space,{obj=p,dist=100})
--	Kraylor fort defensive fleet	
	kraylor_fort_defense_fleet = spawnEnemies(kraylor_fort_x, kraylor_fort_y, 3, "Kraylor", 95)
	for _, ship in ipairs(kraylor_fort_defense_fleet) do
		ship:orderDefendTarget(kraylor_fort)
	end
	local inner_points = {}
	local outer_points = {}
	local ip_x, ip_y = vectorFromAngleNorth(kraylor_fort_angle,10000)
	local op_x, op_y = vectorFromAngleNorth(kraylor_fort_angle,25000)
	table.insert(inner_points,{x = kraylor_fort_x + ip_x, y = kraylor_fort_y + ip_y})
	table.insert(outer_points,{x = kraylor_fort_x + op_x, y = kraylor_fort_y + op_y})
	for i=1,5 do
		ip_x, ip_y = vectorFromAngleNorth((kraylor_fort_angle + i * 60) % 360,10000)
		op_x, op_y = vectorFromAngleNorth((kraylor_fort_angle + i * 60) % 360,25000)
		table.insert(inner_points,{x = kraylor_fort_x + ip_x, y = kraylor_fort_y + ip_y})
		table.insert(outer_points,{x = kraylor_fort_x + op_x, y = kraylor_fort_y + op_y})
	end
	table.insert(inner_points,{x = inner_points[1].x, y = inner_points[1].y})
	table.insert(outer_points,{x = outer_points[1].x, y = outer_points[1].y})
	region = {}
	for i=1,6 do
		local zone = Zone():setPoints(
			inner_points[i].x, inner_points[i].y,		outer_points[i].x, outer_points[i].y,
			outer_points[i+1].x, outer_points[i+1].y,	inner_points[i+1].x, inner_points[i+1].y
		)
		zone.name = string.format("Region %i",i-1)
		zone:setLabel(zone.name)
		region[i-1] = zone
	end
	fort_zone_color = {
		["G1"] =	{r=128,	g=0,	b=0},
		["G2"] =	{r=0,	g=128,	b=0},
		["G3"] =	{r=0,	g=0,	b=128},
		["G4"] =	{r=128,	g=0,	b=128},
		["G5"] =	{r=128,	g=128,	b=0},
		["G6"] =	{r=0,	g=128,	b=128},
		["G7"] =	{r=255,	g=69,	b=0},
		["G8"] =	{r=95,	g=158,	b=160},
		["G9"] =	{r=255,	g=127,	b=80},
		["G11"] =	{r=65,	g=105,	b=225},
		["G12"] =	{r=186,	g=85,	b=211},
		["G13"] =	{r=138,	g=43,	b=226},
		["G14"] =	{r=160,	g=82,	b=45},
		["G15"] =	{r=178,	g=150,	b=80},
		["G16"] =	{r=85,	g=107,	b=47},
		["G17"] =	{r=178,	g=34,	b=34},
		["G18"] =	{r=34,	g=139,	b=34},
		["G19"] =	{r=153,	g=153,	b=255},
		["G21"] =	{r=64,	g=0,	b=0},
		["G22"] =	{r=0,	g=64,	b=0},
		["G23"] =	{r=0,	g=0,	b=64},
		["G24"] =	{r=64,	g=0,	b=64},
		["G25"] =	{r=64,	g=64,	b=0},
		["G26"] =	{r=0,	g=64,	b=64},
		["G27"] =	{r=128,	g=128,	b=128},
		["G28"] =	{r=64,	g=64,	b=64},
		["G29"] =	{r=192,	g=192,	b=192},
		["G31"] =	{r=32,	g=50,	b=112},
		["G32"] =	{r=93,	g=42,	b=106},
		["G33"] =	{r=69,	g=21,	b=113},
		["G34"] =	{r=80,	g=41,	b=23},
		["G35"] =	{r=89,	g=75,	b=40},
		["G36"] =	{r=42,	g=53,	b=24},
		["G37"] =	{r=87,	g=17,	b=17},
		["G38"] =	{r=17,	g=69,	b=17},
		["G39"] =	{r=77,	g=77,	b=128},
		["G41"] =	{r=32,	g=0,	b=0},
		["G42"] =	{r=0,	g=32,	b=0},
		["G43"] =	{r=0,	g=0,	b=32},
		["G44"] =	{r=32,	g=0,	b=32},
		["G45"] =	{r=32,	g=32,	b=0},
		["G46"] =	{r=0,	g=32,	b=32},
		["G47"] =	{r=96,	g=96,	b=96},
		["G48"] =	{r=32,	g=32,	b=32},
		["G49"] =	{r=155,	g=155,	b=155},
		["G51"] =	{r=192,	g=0,	b=0},
		["G52"] =	{r=0,	g=192,	b=0},
		["G53"] =	{r=0,	g=0,	b=192},
		["G54"] =	{r=192,	g=0,	b=192},
		["G55"] =	{r=192,	g=192,	b=0},
		["G56"] =	{r=0,	g=192,	b=192},
		["G57"] =	{r=255,	g=0,	b=128},
		["G58"] =	{r=120,	g=140,	b=80},
		["G59"] =	{r=130,	g=120,	b=160},
	}
	fort_zones = {}
	named_fort_zones = {}
	local top_points = {}			--innermost ring of points
	local top_mid_points = {}		--next highest, bounding the top and the middle layer
	local mid_bot_points = {}		--next highest, bounding the middle and bottom layer
	local bot_points = {}			--outermost ring of points
	local tp_x, tp_y = vectorFromAngleNorth(kraylor_fort_angle,10000)
	local tmp_x, tmp_y = vectorFromAngleNorth(kraylor_fort_angle,14000)
	local mbp_x, mbp_y = vectorFromAngleNorth(kraylor_fort_angle,18000)
	local bp_x, bp_y = vectorFromAngleNorth(kraylor_fort_angle,22000)
	table.insert(top_points,{x = kraylor_fort_x + tp_x, y = kraylor_fort_y + tp_y})
	table.insert(top_mid_points,{x = kraylor_fort_x + tmp_x, y = kraylor_fort_y + tmp_y})
	table.insert(mid_bot_points,{x = kraylor_fort_x + mbp_x, y = kraylor_fort_y + mbp_y})
	table.insert(bot_points,{x = kraylor_fort_x + bp_x, y = kraylor_fort_y + bp_y})
	for i=1,17 do
		tp_x, tp_y = vectorFromAngleNorth((kraylor_fort_angle + i * 20) % 360,10000)	
		tmp_x, tmp_y = vectorFromAngleNorth((kraylor_fort_angle + i * 20) % 360,14000)	
		mbp_x, mbp_y = vectorFromAngleNorth((kraylor_fort_angle + i * 20) % 360,18000)	
		bp_x, bp_y = vectorFromAngleNorth((kraylor_fort_angle + i * 20) % 360,22000)	
		table.insert(top_points,{x = kraylor_fort_x + tp_x, y = kraylor_fort_y + tp_y})
		table.insert(top_mid_points,{x = kraylor_fort_x + tmp_x, y = kraylor_fort_y + tmp_y})
		table.insert(mid_bot_points,{x = kraylor_fort_x + mbp_x, y = kraylor_fort_y + mbp_y})
		table.insert(bot_points,{x = kraylor_fort_x + bp_x, y = kraylor_fort_y + bp_y})
	end
	--	add the first set of points after the last to make the code simpler when building the zones
	table.insert(top_points,{x = top_points[1].x, y = top_points[1].y})
	table.insert(top_mid_points,{x = top_mid_points[1].x, y = top_mid_points[1].y})
	table.insert(mid_bot_points,{x = mid_bot_points[1].x, y = mid_bot_points[1].y})
	table.insert(bot_points,{x = bot_points[1].x, y = bot_points[1].y})
	local ksl = 0	--Kraylor section label (region index)
	local kll = 0	--Kraylor local label
	local ship_impact = populateShipImpact()
	kraylor_fort_defense_platforms = {}
	current_region = region[ksl]
	current_region.zones = {}
	for i=1,18 do
		--	First of three zones (innermost)
		local zone = Zone():setPoints(
			top_points[i].x, top_points[i].y,				top_mid_points[i].x, top_mid_points[i].y,
			top_mid_points[i+1].x, top_mid_points[i+1].y,	top_points[i+1].x, top_points[i+1].y
		)
		zone.center_x = (top_points[i].x + top_mid_points[i].x + top_mid_points[i+1].x + top_points[i+1].x)/4
		zone.center_y = (top_points[i].y + top_mid_points[i].y + top_mid_points[i+1].y + top_points[i+1].y)/4
		zone:setFaction("Kraylor")
		kll = kll + 1
		zone.name = string.format("G%i",ksl * 10 + kll)
		zone:setLabel(zone.name)
		zone.group = ksl
		zone.radius = distance(zone.center_x,zone.center_y,top_mid_points[i].x,top_mid_points[i].y)
		if #ship_impact < 1 then
			ship_impact = populateShipImpact()
		end
		zone.ship_impact = tableRemoveRandom(ship_impact)
		named_fort_zones[zone.name] = zone
		table.insert(current_region.zones,zone)
		table.insert(fort_zones,zone)
		--	Items in the inner zones
		if kll == 4 then
			local dp = CpuShip():setTemplate("Defense platform"):setFaction("Kraylor"):orderStandGround():setPosition(zone.center_x,zone.center_y)
			dp.region = ksl
			table.insert(kraylor_fort_defense_platforms,dp)
		end
		if kll == 1 or kll == 7 then
			sensorJammer(zone.center_x,zone.center_y)
		end
		--	Second of three zones (middle)
		zone = Zone():setPoints(
			top_mid_points[i].x, top_mid_points[i].y,		mid_bot_points[i].x, mid_bot_points[i].y,
			mid_bot_points[i+1].x, mid_bot_points[i+1].y,	top_mid_points[i+1].x, top_mid_points[i+1].y
		)
		zone.center_x = (top_mid_points[i].x + mid_bot_points[i].x + mid_bot_points[i+1].x + top_mid_points[i+1].x)/4
		zone.center_y = (top_mid_points[i].y + mid_bot_points[i].y + mid_bot_points[i+1].y + top_mid_points[i+1].y)/4
		zone:setFaction("Kraylor")
		kll = kll + 1
		zone.name = string.format("G%i",ksl * 10 + kll)
		zone:setLabel(zone.name)
		zone.group = ksl
		zone.radius = distance(zone.center_x,zone.center_y,mid_bot_points[i].x,mid_bot_points[i].y)
		if #ship_impact < 1 then
			ship_impact = populateShipImpact()
		end
		zone.ship_impact = tableRemoveRandom(ship_impact)
		named_fort_zones[zone.name] = zone
		table.insert(current_region.zones,zone)
		table.insert(fort_zones,zone)
		--	Items in the middle zones
		if kll == 5 then
			WarpJammer():setPosition(zone.center_x,zone.center_y):setFaction("Kraylor"):setRange(8000)
		end
		if difficulty >= 1 then
			if kll == 2 or kll == 8 then
				local st = sniperTower("Kraylor")
				st:setPosition(zone.center_x,zone.center_y):orderStandGround()
			end
		end
		--	Third of three zones (outermost)
		zone = Zone():setPoints(
			mid_bot_points[i].x, mid_bot_points[i].y,		bot_points[i].x, bot_points[i].y,
			bot_points[i+1].x, bot_points[i+1].y,			mid_bot_points[i+1].x, mid_bot_points[i+1].y
		)
		zone.center_x = (mid_bot_points[i].x + bot_points[i].x + bot_points[i+1].x + mid_bot_points[i+1].x)/4
		zone.center_y = (mid_bot_points[i].y + bot_points[i].y + bot_points[i+1].y + mid_bot_points[i+1].y)/4
		zone:setFaction("Kraylor")
		kll = kll + 1
		zone.name = string.format("G%i",ksl * 10 + kll)
		zone:setLabel(zone.name)
		zone.group = ksl
		zone.radius = distance(zone.center_x,zone.center_y,bot_points[i].x,bot_points[i].y)
		if #ship_impact < 1 then
			ship_impact = populateShipImpact()
		end
		zone.ship_impact = tableRemoveRandom(ship_impact)
		named_fort_zones[zone.name] = zone
		table.insert(current_region.zones,zone)
		table.insert(fort_zones,zone)
		--	Items in outer zones
		if kll == 3 or kll == 9 then
			zone.outer_edge_x = (bot_points[i].x + bot_points[i+1].x)/2
			zone.outer_edge_y = (bot_points[i].y + bot_points[i+1].y)/2
		end
		if difficulty >= 2 then
			if kll == 6 then
				local mt = missilePodTX16("Kraylor")
				mt:setPosition(zone.center_x,zone.center_y)
			end
			if kll == 3 or kll == 9 then
				local mt = missilePodTX8("Kraylor")
				mt:setPosition(zone.center_x,zone.center_y)
			end
		end
		if kll >= 9 then
			kll = 0
			ksl = ksl + 1
			if ksl <= 5 then
				current_region = region[ksl]
				current_region.zones = {}
			end
		end
	end
	plotFortZone = fortZoneCheck
	stalker_patrol = {}
	stalker_patrol_timer = 30
	stalkerPatrolPlot = stalkerPatrolDelay
--	Primary human station
	phs_x, phs_y = vectorFromAngle(random(0,360),random(1000,4000))
	phs_x = phs_x + center_x
	phs_y = phs_y + center_y
	primary_human_station = placeStation(phs_x, phs_y, "RandomHumanNeutral", "Human Navy")
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
	table.insert(transport_stations,primary_human_station)
	table.insert(place_space,{obj=primary_human_station,dist=station_defend_dist[primary_human_station:getTypeName()]})
	primary_fighter_defense = setPrimaryFighterDefense(phs_x,phs_y,"Human Navy")
	primary_adder_defense = setPrimaryAdderDefense(phs_x,phs_y,"Human Navy")
	primary_nirvana_defense = setPrimaryNirvanaDefense(phs_x,phs_y,"Human Navy")
	primary_phobos_defense = setPrimaryPhobosDefense(phs_x,phs_y,"Human Navy")
	primary_check_timer = 8
	primaryDefensePlot = primaryFighterCheck
	p:addToShipLog(string.format("Welcome to %s. You will be helping the %s defensive fleet against any enemy aggression. Good Luck.",primary_human_station:getCallSign(),primary_human_station:getCallSign()),"Magenta")
	primary_orders = string.format("Defend %s",primary_human_station:getCallSign())
--	Kraylor harassing fighters
	kraylor_fighters = {}
	setKraylorFighters()
	plotKraylorFighters = kraylorFighterCheck
--	USN station
	local usn_angle = random(0,360)
	local usn_distance = random(26000,50000)
	usn_station_x, usn_station_y = vectorFromAngleNorth(usn_angle,usn_distance)
	usn_station_x = usn_station_x + center_x
	usn_station_y = usn_station_y + center_y
	usn_station = placeStation(usn_station_x, usn_station_y, "RandomHumanNeutral", "USN")
	table.insert(transport_stations,usn_station)
	table.insert(place_space,{obj=usn_station,dist=station_dist[usn_station:getTypeName()]})
--	TSN station
	local tsn_angle = (usn_angle + random(120,240)) % 360
	local tsn_distance = random(26000,50000)
	tsn_station_x, tsn_station_y = vectorFromAngleNorth(tsn_angle,tsn_distance)
	tsn_station_x = tsn_station_x + center_x
	tsn_station_y = tsn_station_y + center_y
	tsn_station = placeStation(tsn_station_x, tsn_station_y, "RandomHumanNeutral", "TSN")
	table.insert(transport_stations,tsn_station)
	table.insert(place_space,{obj=tsn_station,dist=station_dist[tsn_station:getTypeName()]})
--	CUF station
	local cuf_station_size = szt()
	local o_x = 0
	local o_y = 0
	local base_area_radius = 50000
	local area_radius = base_area_radius
	local compression_interval = 2000
	repeat
		o_x, o_y = vectorFromAngle(random(0,360),random(0,area_radius))
		o_x = o_x + center_x
		o_y = o_y + center_y
		area_radius = area_radius + compression_interval
	until(farEnough(o_x,o_y,station_dist[cuf_station_size]))
	cuf_station = placeStation(o_x, o_y, "RandomHumanNeutral", "CUF", cuf_station_size)
	table.insert(transport_stations,cuf_station)
	table.insert(place_space,{obj=cuf_station,dist=station_dist[cuf_station:getTypeName()]})
--	Spawn Independent mining station
	local mining_station_names = {"Grasberg","Impala","Outpost-15","Outpost-21","Krik","Krak","Kruk"}
	local mining_station_size = szt()
	base_area_radius = 50000
	area_radius = base_area_radius
	compression_interval = 1000
	repeat
		o_x, o_y = vectorFromAngle(random(0,360),random(0,area_radius))
		o_x = o_x + center_x
		o_y = o_y + center_y
		area_radius = area_radius + compression_interval
	until(farEnough(o_x,o_y,station_dist[mining_station_size]))
	repeat
		local independent_mining_station_name = tableRemoveRandom(mining_station_names)
		mining_station = placeStation(o_x, o_y, independent_mining_station_name, "Independent", mining_station_size)
		if mining_station == nil then
			print("Something went wrong when placing a mining station. o_x:",o_x,"o_y:",o_y,"Name:",independent_mining_station_name,"Size:",mining_station_size)
		end
	until(mining_station ~= nil)
	table.insert(transport_stations,mining_station)
	table.insert(place_space,{obj=mining_station,dist=station_dist[mining_station:getTypeName()]})
--	Spawn Human mining station
	mining_station_size = szt()
	base_area_radius = 50000
	area_radius = base_area_radius
	compression_interval = 1000
	repeat
		o_x, o_y = vectorFromAngle(random(0,360),random(0,area_radius))
		o_x = o_x + center_x
		o_y = o_y + center_y
		area_radius = area_radius + compression_interval
	until(farEnough(o_x,o_y,station_dist[mining_station_size]))
	local human_mining_station_name = tableRemoveRandom(mining_station_names)
	human_mining_station = placeStation(o_x, o_y, human_mining_station_name, "Human Navy", mining_station_size)
	table.insert(transport_stations,human_mining_station)
	table.insert(place_space,{obj=human_mining_station,dist=station_dist[human_mining_station:getTypeName()]})
--	Spawn Black Hole
	area_radius = base_area_radius
	repeat
		o_x, o_y = vectorFromAngle(random(0,360),random(0,area_radius))
		o_x = o_x + center_x
		o_y = o_y + center_y
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
		o_x = o_x + center_x
		o_y = o_y + center_y
		area_radius = area_radius + compression_interval
	until(farEnough(o_x,o_y,planet_list[selected_planet_index].radius))
	local planet = Planet():setPosition(o_x,o_y):setPlanetRadius(planet_list[selected_planet_index].radius):setDistanceFromMovementPlane(planet_list[selected_planet_index].distance)
	planet:setCallSign(planet_list[selected_planet_index].name[math.random(1,#planet_list[selected_planet_index].name)])
	if planet_list[selected_planet_index].texture.surface ~= nil then
		planet:setPlanetSurfaceTexture(planet_list[selected_planet_index].texture.surface)
	end
	if planet_list[selected_planet_index].texture.atmosphere ~= nil then
		planet:setPlanetAtmosphereTexture(planet_list[selected_planet_index].texture.atmosphere)
	end
	if planet_list[selected_planet_index].texture.cloud ~= nil then
		planet:setPlanetCloudTexture(planet_list[selected_planet_index].texture.cloud)
	end
	if planet_list[selected_planet_index].color ~= nil then
		planet:setPlanetAtmosphereColor(planet_list[selected_planet_index].color.red,planet_list[selected_planet_index].color.green,planet_list[selected_planet_index].color.blue)
	end
	if planet_list[selected_planet_index].rotation ~= nil then
		planet:setAxialRotationTime(planet_list[selected_planet_index].rotation)
	end
	table.insert(place_space,{obj=planet,dist=planet_list[selected_planet_index].radius})
--	Spawn Arlenian station
	local arlenian_station_size = szt()
	area_radius = base_area_radius
	repeat
		o_x, o_y = vectorFromAngle(random(0,360),random(0,area_radius))
		o_x = o_x + center_x
		o_y = o_y + center_y
		area_radius = area_radius + compression_interval
	until(farEnough(o_x,o_y,station_dist[arlenian_station_size]))
	arlenian_station = placeStation(o_x, o_y, "RandomHumanNeutral", "Arlenians", arlenian_station_size)
	table.insert(transport_stations,arlenian_station)
	table.insert(place_space,{obj=arlenian_station,dist=station_dist[arlenian_station:getTypeName()]})
--	Spawn Kraylor station
	local kraylor_station_size = szt()
	area_radius = base_area_radius
	repeat
		o_x, o_y = vectorFromAngle(random(0,360),random(0,area_radius))
		o_x = o_x + center_x
		o_y = o_y + center_y
		area_radius = area_radius + compression_interval
	until(farEnough(o_x,o_y,6*station_defend_dist[kraylor_station_size]))
	kraylor_station = placeStation(o_x, o_y, "Sinister", "Kraylor", kraylor_station_size)
	table.insert(transport_stations,kraylor_station)
	table.insert(place_space,{obj=kraylor_station,dist=6*station_defend_dist[kraylor_station:getTypeName()]})
	local kraylor_fleet = spawnEnemies(o_x, o_y, 1, "Kraylor", 99)
	for _, ship in ipairs(kraylor_fleet) do
		ship:orderDefendTarget(kraylor_station):onDestroyed(enemyVesselDestroyed)
	end
	local last_x = center_x
	local last_y = center_y
	for i=1,20 do
--		print("index:",i)
		local station_size = szt()
		local start_area = i
		area_radius = base_area_radius
		repeat
			o_x, o_y = vectorFromAngle(random(0,360),random(0,area_radius))
			if start_area % 2 == 0 then
				o_x = o_x + center_x
				o_y = o_y + center_y
			else
				o_x = o_x + last_x
				o_y = o_y + last_y
			end
			start_area = start_area + 1
			area_radius = area_radius + compression_interval
		until(farEnough(o_x,o_y,station_defend_dist[station_size]))
		last_x = o_x
		last_y = o_y
		local station_choice = random(1,100)
		if station_choice < 50 then
			selected_faction = "Independent"
		elseif station_choice < 57 then
			selected_faction = "Kraylor"
		elseif station_choice < 64 then
			selected_faction = "Arlenians"
		elseif station_choice < 71 then
			selected_faction = "Human Navy"
		elseif station_choice < 78 then
			selected_faction = "TSN"
		elseif station_choice < 85 then
			selected_faction = "Exuari"
		elseif station_choice < 92 then
			selected_faction = "USN"
		else
			selected_faction = "CUF"
		end
--		print("selected faction:",selected_faction)
		local station = placeStation(o_x, o_y, "RandomHumanNeutral", selected_faction, station_size)
--		print("station:",station:getSectorName(),station:getCallSign())
		local defense_fleet = spawnEnemies(o_x,o_y,1,selected_faction,math.random(20,40))
--		print("size of defense fleet:",#defense_fleet)
		for _, ship in ipairs(defense_fleet) do
			ship:orderDefendTarget(station)
--			print("   name:",ship:getCallSign())
		end
		table.insert(transport_stations,station)
		table.insert(place_space,{obj=station,dist=station_defend_dist[station:getTypeName()]})
	end
--	Spawn working transports	
	transport_list = {}
	for _, station in ipairs(transport_stations) do
		local transport, transport_size = randomTransportType()
		transport.home_station = station
		area_radius = base_area_radius
		repeat
			o_x, o_y = vectorFromAngle(random(0,360),random(0,area_radius))
			o_x = o_x + center_x
			o_y = o_y + center_y
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
	transportPlot = directTransportsToStations
	local gap_neb_count = math.random(1,2 + difficulty*2)
	gap_nebulae = {}
	for i=1,gap_neb_count do
		local neb_group_count = math.random(1,3)
		for j=1,neb_group_count do
			if j == 1 then
				area_radius = base_area_radius
				repeat
					o_x, o_y = vectorFromAngle(random(0,360),random(0,area_radius))
					o_x = o_x + center_x
					o_y = o_y + center_y
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
	for i=1,math.random(1,2 + difficulty*2) do
		for j=1,math.random(1,3) do
			if j == 1 then
				o_x, o_y = vectorFromAngle(random(0,360),random(10000,base_area_radius + 10000))
				o_x = o_x + center_x
				o_y = o_y + center_y
				Nebula():setPosition(o_x,o_y)
			else
				local no_x, no_y = vectorFromAngle(random(0,360),random(5000,10000))
				o_x = o_x + no_x
				o_y = o_y + no_y
				Nebula():setPosition(o_x,o_y)
			end
		end
	end
	for i=1,math.random(1,3) do
		o_x, o_y = vectorFromAngle(random(0,360),random(1000,30000))
		o_x = o_x + kraylor_fort_x
		o_y = o_y + kraylor_fort_y
		Nebula():setPosition(o_x,o_y)
	end
end
function farEnough(o_x,o_y,obj_dist)
	local far_enough = true
	for index, item in ipairs(place_space) do
		if distance(item.obj,o_x,o_y) < (obj_dist + item.dist) then
			far_enough = false
			break
		end
	end
	return far_enough
end
function playerDamage(self,instigator)
	string.format("")
end
---------------------------------------
--	Support for constant plot lines  --
---------------------------------------
function primaryPhobosCheck(delta)
	primary_check_timer = primary_check_timer - delta
	if primary_check_timer < 0 then
		if #primary_phobos_defense < 1 then
			if human_mining_station ~= nil and human_mining_station:isValid() then
				local human_mining_station_x, human_mining_station_y = human_mining_station:getPosition()
				local phobos_choice = random(1,100)
				if phobos_choice < (80 - difficulty * 20) then
					primary_phobos_defense = setPrimaryPhobosDefense(phs_x,phs_y,"Human Navy")
				else
					primary_phobos_defense = setPrimaryPhobosDefense(human_mining_station_x,human_mining_station_y,"Human Navy")
				end
			end
		else
			for index, ship in ipairs(primary_phobos_defense) do
				if not ship:isValid() then
					primary_phobos_defense[index] = primary_phobos_defense[#primary_phobos_defense]
					primary_phobos_defense[#primary_phobos_defense] = nil
					break
				end
			end
		end
		primary_check_timer = 8
		primaryDefensePlot = primaryFighterCheck
	end
end
function primaryNirvanaCheck(delta)
	primary_check_timer = primary_check_timer - delta
	if primary_check_timer < 0 then
		if #primary_nirvana_defense < 1 then
			if cuf_station ~= nil and cuf_station:isValid() then
				local cuf_station_x, cuf_station_y = cuf_station:getPosition()
				local iff_choice = random(1,100)
				if iff_choice < (80 - difficulty * 20) then
					primary_nirvana_defense = setPrimaryNirvanaDefense(cuf_station_x,cuf_station_y,"Human Navy")
				else
					primary_nirvana_defense = setPrimaryNirvanaDefense(cuf_station_x,cuf_station_y,"CUF")
				end
			end
		else
			for index, ship in ipairs(primary_nirvana_defense) do
				if not ship:isValid() then
					primary_nirvana_defense[index] = primary_nirvana_defense[#primary_nirvana_defense]
					primary_nirvana_defense[#primary_nirvana_defense] = nil
					break
				end
			end
		end
		primary_check_timer = 8
		primaryDefensePlot = primaryPhobosCheck
	end
end
function primaryAdderCheck(delta)
	primary_check_timer = primary_check_timer - delta
	if primary_check_timer < 0 then
		if #primary_adder_defense < 1 then
			if tsn_station ~= nil and tsn_station:isValid() then
				local iff_choice = random(1,100)
				if iff_choice < (80 - difficulty * 20) then
					primary_adder_defense = setPrimaryAdderDefense(tsn_station_x,tsn_station_y,"Human Navy")
				else
					primary_adder_defense = setPrimaryAdderDefense(tsn_station_x,tsn_station_y,"TSN")
				end
			end
		else
			for index, ship in ipairs(primary_adder_defense) do
				if not ship:isValid() then
					primary_adder_defense[index] = primary_adder_defense[#primary_adder_defense]
					primary_adder_defense[#primary_adder_defense] = nil
					break
				end
			end
		end
		primary_check_timer = 8
		primaryDefensePlot = primaryNirvanaCheck
	end
end
function primaryFighterCheck(delta)
	primary_check_timer = primary_check_timer - delta
	if primary_check_timer < 0 then
		if #primary_fighter_defense < 1 then
			if usn_station ~= nil and usn_station:isValid() then
				local iff_choice = random(1,100)
				if iff_choice < (80 - difficulty * 20) then
					primary_fighter_defense = setPrimaryFighterDefense(usn_station_x,usn_station_y,"Human Navy")
				else
					primary_fighter_defense = setPrimaryFighterDefense(usn_station_x,usn_station_y,"USN")
				end
			end
		else
			for index, ship in ipairs(primary_fighter_defense) do
				if not ship:isValid() then
					primary_fighter_defense[index] = primary_fighter_defense[#primary_fighter_defense]
					primary_fighter_defense[#primary_fighter_defense] = nil
					break
				end
			end
		end
		primary_check_timer = 8
		primaryDefensePlot = primaryAdderCheck
	end
end
function setPrimaryFighterDefense(x,y,faction)
	local deploy_angle = random(0,360)
	local dx, dy = vectorFromAngle(deploy_angle,2000)
	local ship = CpuShip():setTemplate("MT52 Hornet"):setFaction(faction):setScanState("simplescan"):setCallSign(generateCallSign(nil,faction)):setPosition(x + dx,y + dy):orderDefendTarget(primary_human_station)
	local list = {}
	table.insert(list,ship)
	for i=1,4 do
		deploy_angle = (deploy_angle + 72) % 360
		dx, dy = vectorFromAngle(deploy_angle,2000)
		ship = CpuShip():setTemplate("MT52 Hornet"):setFaction(faction):setScanState("simplescan"):setCallSign(generateCallSign(nil,faction)):setPosition(x + dx,y + dy):orderDefendTarget(primary_human_station)
		table.insert(list,ship)
	end
	return list
end
function setPrimaryAdderDefense(x,y,faction)
	local deploy_angle = random(0,360)
	local dx, dy = vectorFromAngle(deploy_angle,2000)
	local ship = CpuShip():setTemplate("Adder MK5"):setFaction(faction):setScanState("simplescan"):setCallSign(generateCallSign(nil,faction)):setPosition(x + dx,y + dy):orderDefendTarget(primary_human_station)
	local list = {}
	table.insert(list,ship)
	for i=1,2 do
		deploy_angle = (deploy_angle + 120) % 360
		dx, dy = vectorFromAngle(deploy_angle,2000)
		ship = CpuShip():setTemplate("Adder MK5"):setFaction(faction):setScanState("simplescan"):setCallSign(generateCallSign(nil,faction)):setPosition(x + dx,y + dy):orderDefendTarget(primary_human_station)
		table.insert(list,ship)
	end
	return list
end
function setPrimaryNirvanaDefense(x,y,faction)
	local deploy_angle = random(0,360)
	local dx, dy = vectorFromAngle(deploy_angle,2000)
	local ship = CpuShip():setTemplate("Nirvana R5"):setFaction(faction):setScanState("simplescan"):setCallSign(generateCallSign(nil,faction)):setPosition(x + dx,y + dy):orderDefendTarget(primary_human_station)
	local list = {}
	table.insert(list,ship)
	for i=1,2 do
		deploy_angle = (deploy_angle + 120) % 360
		dx, dy = vectorFromAngle(deploy_angle,2000)
		ship = CpuShip():setTemplate("Nirvana R5"):setFaction(faction):setScanState("simplescan"):setCallSign(generateCallSign(nil,faction)):setPosition(x + dx,y + dy):orderDefendTarget(primary_human_station)
		table.insert(list,ship)
	end
	return list
end
function setPrimaryPhobosDefense(x,y,faction)
	local deploy_angle = random(0,360)
	local dx, dy = vectorFromAngle(deploy_angle,2000)
	local ship = CpuShip():setTemplate("Phobos T3"):setFaction(faction):setScanState("simplescan"):setCallSign(generateCallSign(nil,faction)):setPosition(x + dx,y + dy):orderDefendTarget(primary_human_station)
	local list = {}
	table.insert(list,ship)
	deploy_angle = (deploy_angle + 180) % 360
	dx, dy = vectorFromAngle(deploy_angle,2000)
	ship = CpuShip():setTemplate("Phobos T3"):setFaction(faction):setScanState("simplescan"):setCallSign(generateCallSign(nil,faction)):setPosition(x + dx,y + dy):orderDefendTarget(primary_human_station)
	table.insert(list,ship)
	return list
end
function setKraylorFighters()
	local add_to_placement_table = false
	if kraylor_fighter_distance == nil then
		kraylor_fighter_distance = 30000
		add_to_placement_table = true
		kraylor_fighter_wave_count = 1
	else
		kraylor_fighter_distance = kraylor_fighter_distance + 5000
		if kraylor_fighter_distance > (kraylor_fort_distance - 30000) then
			kraylor_fighter_distance = kraylor_fort_distance - 30000
			if improved_kraylor == nil then
				improved_kraylor = .2
			else
				improved_kraylor = improved_kraylor + .1
			end
		end
		kraylor_fighter_wave_count = kraylor_fighter_wave_count + 1
		if kraylor_fighter_wave_count >= 3 and defense_platform_count == nil then
			defense_platform_count = 3
			local p = getPlayerShip(-1)
			p:addToShipLog(string.format("[%s] These Kraylor fighters seem to be following a pattern. We prepared a couple of freighters with the necessary equipment to deploy a defense platform. You must direct the freighter via waypoint to the best location to defend %s",primary_human_station:getCallSign(),primary_human_station:getCallSign()),"Magenta")
			secondary_orders = "Direct freighter to deploy defense platform"
		end
	end
	local attack_angle = angleFromVectorNorth(phs_x, phs_y, kraylor_fort_x, kraylor_fort_y)
	local start_point_x, start_point_y = vectorFromAngleNorth((attack_angle + 180) % 360,kraylor_fighter_distance)
	start_point_x = start_point_x + phs_x
	start_point_y = start_point_y + phs_y
	local ship = CpuShip():setTemplate("MT52 Hornet"):setFaction("Kraylor"):setCallSign(generateCallSign(nil,"Kraylor")):setCommsScript(""):setCommsFunction(commsShip)
	local selected_ai = "fighter"
	if add_to_placement_table then
		ship:orderAttack(primary_human_station)
		ship:setAI("default")
		selected_ai = "default"
		table.insert(place_space,{obj=ship,dist=2000})
	else
		local order_choice = random(1,100)
		if order_choice < 40 then
			ship:orderAttack(primary_human_station)
			ship:setAI("default")
			selected_ai = "default"
		elseif order_choice < 80 then
			ship:orderAttack(primary_human_station)
		elseif order_choice < 90 then
			ship:orderFlyTowards(phs_x,phs_y)
			ship:setAI("default")
			selected_ai = "default"
		else
			ship:orderFlyTowards(phs_x,phs_y)
		end
		if improved_kraylor ~= nil then
			ship:setBeamWeapon(0,ship:getBeamWeaponArc(0),ship:getBeamWeaponDirection(0),ship:getBeamWeaponRange(0),math.max(ship:getBeamWeaponCycleTime(0)*.1,ship:getBeamWeaponCycleTime(0) * (1 - improved_kraylor)),ship:getBeamWeaponDamage(0)*(1 + improved_kraylor))
			ship:setShieldsMax(ship:getShieldMax(0)*(1 + improved_kraylor))
		end
	end
	ship:setPosition(start_point_x, start_point_y):setHeading(attack_angle)
	ship.leader = true
	local leader = ship
	table.insert(kraylor_fighters,ship)
	local circle_angle = (attack_angle + 60) % 360
	local circle_angle_prime = 60
	ship = CpuShip():setTemplate("MU52 Hornet"):setFaction("Kraylor"):setCommsScript(""):setCommsFunction(commsShip)
	ship:setCallSign(generateCallSign(nil,"Kraylor"))
	local form_x, form_y = vectorFromAngleNorth(circle_angle, 800)
	local form_prime_x, form_prime_y = vectorFromAngle(circle_angle_prime, 800)
	ship:setPosition(start_point_x + form_x, start_point_y + form_y)
	ship:setHeading(attack_angle):setAI(selected_ai)
	ship:orderFlyFormation(leader,form_prime_x,form_prime_y)
	table.insert(kraylor_fighters,ship)
	ship = CpuShip():setTemplate("MU52 Hornet"):setFaction("Kraylor"):setCommsScript(""):setCommsFunction(commsShip)
	ship:setCallSign(generateCallSign(nil,"Kraylor"))
	form_x, form_y = vectorFromAngleNorth(circle_angle, 1600)
	form_prime_x, form_prime_y = vectorFromAngle(circle_angle_prime, 1600)
	ship:setPosition(start_point_x + form_x, start_point_y + form_y)
	ship:setHeading(attack_angle):setAI(selected_ai)
	ship:orderFlyFormation(leader,form_prime_x,form_prime_y)
	table.insert(kraylor_fighters,ship)
	circle_angle = (attack_angle + 300) % 360
	circle_angle_prime = 300
	ship = CpuShip():setTemplate("MU52 Hornet"):setFaction("Kraylor"):setCommsScript(""):setCommsFunction(commsShip)
	ship:setCallSign(generateCallSign(nil,"Kraylor"))
	form_x, form_y = vectorFromAngleNorth(circle_angle, 800)
	form_prime_x, form_prime_y = vectorFromAngle(circle_angle_prime, 800)
	ship:setPosition(start_point_x + form_x, start_point_y + form_y)
	ship:setHeading(attack_angle):setAI(selected_ai)
	ship:orderFlyFormation(leader,form_prime_x,form_prime_y)
	table.insert(kraylor_fighters,ship)
	ship = CpuShip():setTemplate("MU52 Hornet"):setFaction("Kraylor"):setCommsScript(""):setCommsFunction(commsShip)
	ship:setCallSign(generateCallSign(nil,"Kraylor"))
	form_x, form_y = vectorFromAngleNorth(circle_angle, 1600)
	form_prime_x, form_prime_y = vectorFromAngle(circle_angle_prime, 1600)
	ship:setPosition(start_point_x + form_x, start_point_y + form_y)
	ship:setHeading(attack_angle):setAI(selected_ai)
	ship:orderFlyFormation(leader,form_prime_x,form_prime_y)
	table.insert(kraylor_fighters,ship)
	if difficulty >= 1 then
		circle_angle = (attack_angle + 120) %360
		circle_angle_prime = 120
		ship = CpuShip():setTemplate("MU52 Hornet"):setFaction("Kraylor"):setCommsScript(""):setCommsFunction(commsShip)
		ship:setCallSign(generateCallSign(nil,"Kraylor"))
		form_x, form_y = vectorFromAngleNorth(circle_angle, 800)
		form_prime_x, form_prime_y = vectorFromAngle(circle_angle_prime, 800)
		ship:setPosition(start_point_x + form_x, start_point_y + form_y)
		ship:setHeading(attack_angle):setAI(selected_ai)
		ship:orderFlyFormation(leader,form_prime_x,form_prime_y)
		table.insert(kraylor_fighters,ship)
		circle_angle = (attack_angle + 240) %360
		circle_angle_prime = 240
		ship = CpuShip():setTemplate("MU52 Hornet"):setFaction("Kraylor"):setCommsScript(""):setCommsFunction(commsShip)
		ship:setCallSign(generateCallSign(nil,"Kraylor"))
		form_x, form_y = vectorFromAngleNorth(circle_angle, 800)
		form_prime_x, form_prime_y = vectorFromAngle(circle_angle_prime, 800)
		ship:setPosition(start_point_x + form_x, start_point_y + form_y)
		ship:setHeading(attack_angle):setAI(selected_ai)
		ship:orderFlyFormation(leader,form_prime_x,form_prime_y)
		table.insert(kraylor_fighters,ship)
	end
	if difficulty >= 2 then
		circle_angle = (attack_angle + 120) %360
		circle_angle_prime = 120
		ship = CpuShip():setTemplate("MU52 Hornet"):setFaction("Kraylor"):setCommsScript(""):setCommsFunction(commsShip)
		ship:setCallSign(generateCallSign(nil,"Kraylor"))
		form_x, form_y = vectorFromAngleNorth(circle_angle, 1600)
		form_prime_x, form_prime_y = vectorFromAngle(circle_angle_prime, 1600)
		ship:setPosition(start_point_x + form_x, start_point_y + form_y)
		ship:setHeading(attack_angle):setAI(selected_ai)
		ship:orderFlyFormation(leader,form_prime_x,form_prime_y)
		table.insert(kraylor_fighters,ship)
		circle_angle = (attack_angle + 240) %360
		circle_angle_prime = 240
		ship = CpuShip():setTemplate("MU52 Hornet"):setFaction("Kraylor"):setCommsScript(""):setCommsFunction(commsShip)
		ship:setCallSign(generateCallSign(nil,"Kraylor"))
		form_x, form_y = vectorFromAngleNorth(circle_angle, 1600)
		form_prime_x, form_prime_y = vectorFromAngle(circle_angle_prime, 1600)
		ship:setPosition(start_point_x + form_x, start_point_y + form_y)
		ship:setHeading(attack_angle):setAI(selected_ai)
		ship:orderFlyFormation(leader,form_prime_x,form_prime_y)
		table.insert(kraylor_fighters,ship)
	end
end
function kraylorFighterCheck(delta)
	if #kraylor_fighters < 1 then
		setKraylorFighters()
		kraylor_fighter_reset_delay = 200
		plotKraylorFighters = kraylorFighterWait
	else
		local deleted_ship = false
		for index, ship in ipairs(kraylor_fighters) do
			if ship:isValid() then
				if ship.leader ~= true then
					if distance(ship,primary_human_station) < 10000 then
						if not string.find(ship:getOrder(),"oam") then
							ship:orderRoaming()
							kraylor_impatience = 200
						end
					end
				end
			else
				kraylor_fighters[index] = kraylor_fighters[#kraylor_fighters]
				kraylor_fighters[#kraylor_fighters] = nil
				deleted_ship = true
				break
			end
		end
		if not deleted_ship then
			if #kraylor_fighters < 2 then
				kraylor_fighters[1]:orderRoaming():setAI("fighter")
				kraylor_fighters = {}
				setKraylorFighters()
				kraylor_fighter_reset_delay = 200
				plotKraylorFighters = kraylorFighterWait
			else
				if kraylor_impatience ~= nil then
					kraylor_impatience = kraylor_impatience - delta
					if kraylor_impatience < 0 then
						for index, ship in ipairs(kraylor_fighters) do
							if ship:isValid() then
								ship:orderRoaming()
							end
						end
						kraylor_fighter_reset_delay = 200
						plotKraylorFighters = kraylorFighterWait
						kraylor_impatience = nil
						kraylor_fighters = {}
						setKraylorFighters()
					end
				end
			end
		end
	end
end
function kraylorFighterWait(delta)
	kraylor_fighter_reset_delay = kraylor_fighter_reset_delay - delta
	if kraylor_fighter_reset_delay < 0 then
		plotKraylorFighters = kraylorFighterCheck
	end
end
----------------------------------------------------
--	Support for defense platform deployment plot  --
----------------------------------------------------
function checkPlatformDeployed(delta)
	for _, pos in ipairs(deployed_platform_positions) do
		local list = getObjectsInRadius(pos.x,pos.y,600)
		if #list > 0 then
			for index, obj in ipairs(list) do
				if obj.typeName == "CpuShip" then
					if obj:getTypeName() == "Defense platform" then
						platform_deployed = true
						local p = getPlayerShip(-1)
						if p.platform_deployed_message == nil then
							p:addToShipLog("Thanks for getting that defense platform deployed. Hopefully, that will help with those pesky Kraylor fighters","Magenta")
							p.platform_deployed_message = "sent"
						end
						post_platform_timer = random(30,60)
						deployPlatformPlot = platformEvaluation
					end
				end
			end
		end
	end
end
function platformEvaluation(delta)
	post_platform_timer = post_platform_timer - delta
	if post_platform_timer < 0 then
		local p = getPlayerShip(-1)
		if p.find_the_source_message == nil then
			p:addToShipLog(string.format("We really need to find the source of those Kraylor fighters and do something about it. Your mandate has been expanded to include finding and destroying the source of the Kraylor fighters. To facilitate your mission, we've prepared a warp drive for your ship. Dock with %s if you wish to have the warp drive installed.",primary_human_station:getCallSign()),"Magenta")
			p.find_the_source_message = "sent"
		end
		secondary_orders = "Destroy source of Kraylor fighters"
		optional_orders = string.format("Dock with %s to get warp drive installed",primary_human_station:getCallSign())
		warp_drive_install_available = true
		deployPlatformPlot = nil
	end
end
-------------------------------------------
--	Support for infiltration plot lines  --
-------------------------------------------
function coverCheck(delta)
	local p = getPlayerShip(-1)
	if p:getFaction() == "Independent" then
		if p:getWeaponTubeCount() > 0 then
			cover_blown = "Weapons"
		end
		if distance(kraylor_fort,p) < 30000 then
			local vx, vy = p:getVelocity()
			local player_velocity = math.sqrt((math.abs(vx)*math.abs(vx))+(math.abs(vy)*math.abs(vy)))
	--		print("velocity:",player_velocity)	--240 max impulse
			if player_velocity > 250 then
				cover_blown = "Warp"
			end
			if security_platform == nil then
				local platform_range = 999999
				local platform_index = 0
				for index, platform in ipairs(kraylor_fort_defense_platforms) do
					if platform:isValid() then
						local current_distance = distance(p,platform)
						if current_distance < platform_range then
							platform_range = current_distance
							platform_index = index
						end
					end
				end
				security_platform = kraylor_fort_defense_platforms[platform_index]
				virus_region = region[security_platform.region]
			end
			if p:isCommsInactive() and kraylor_fort_hail_accepted == nil then
				kraylor_fort:setCommsScript(""):setCommsFunction(commsKraylorFort)
				kraylor_fort_hail_accepted = kraylor_fort:openCommsTo(p)
			end
			if p:isDocked(security_platform) then
				if docked_with_kraylor_security_platform == nil then
					p:setCanDock(false)
					local security_dock_clamps_locked_msg = "The docking clamps have locked the ship to the defense platform"
					p:addCustomMessage("Helms","hlm_clamps_locked_msg",security_dock_clamps_locked_msg)
					p:addCustomMessage("Tactical","tac_clamps_locked_msg",security_dock_clamps_locked_msg)
					p:addCustomMessage("Single","one_clamps_locked_msg",security_dock_clamps_locked_msg)
				end
				docked_with_kraylor_security_platform = true
				if p:isCommsInactive() and security_platform_hail_accepted == nil then
					security_platform:setCommsScript(""):setCommsFunction(commsSecurityPlatform)
					security_platform_hail_accepted = security_platform:openCommsTo(p)
				end
			end
		end
	end
	iff_timer = iff_timer - delta
	local console_iff_timer = {
		["Helms"] =				"hlm_iff_timer",
		["Weapons"] =			"wea_iff_timer",
		["Engineering"] =		"eng_iff_timer",
		["Science"] =			"sci_iff_timer",
		["Relay"] =				"rly_iff_timer",
		["Tactical"] =			"tac_iff_timer",
		["Operations"] =		"ops_iff_timer",
		["Engineering+"] =		"pls_iff_timer",
		["ShipLog"] =			"log_iff_timer",
		["Single"] =			"one_iff_timer",
		["DamageControl"] =		"dmg_iff_timer",
		["PowerManagement"] =	"pwr_iff_timer",
		["Database"] =			"dat_iff_timer",
		["AltRelay"] =			"alt_iff_timer",
	}
	if iff_timer < 0 then
		p:setFaction("Human Navy")
		if p:getDockedWith() ~= nil then
			if p:isDocked(kraylor_fort) then
				p:commandCloseTextComm()
				kraylor_fort:sendCommsMessage(p,"We do not engage in discussion with enemies. We apologize for any inconvenience. Hava a nice day.")
				kraylor_fort:setCommsScript(""):setCommsFunction(commsStation)
			else
				if security_platform ~= nil then
					if p:isDocked(security_platform) then
						p:commandCloseTextComm()
						security_platform:sendCommsMessage(p,"We do not engage in discussion with enemies. We apologize for any inconvenience. Hava a nice day.")
						security_platform:setCommsScript(""):setCommsFunction(commsShip)
					end
				end
			end
		else
			p:setCanDock(true)
		end
		cover_blown = "IFF"
		for console, timer in pairs(console_iff_timer) do
			p:removeCustom(timer)
		end
		plotInfiltrate = nil
	else
		local timer_status = "IFF Expires"
		local timer_minutes = math.floor(iff_timer / 60)
		local timer_seconds = math.floor(iff_timer % 60)
		if timer_minutes <= 0 then
			timer_status = string.format("%s %i",timer_status,timer_seconds)
		else
			timer_status = string.format("%s %i:%.2i",timer_status,timer_minutes,timer_seconds)
		end
		for console, timer in pairs(console_iff_timer) do
			p:addCustomInfo(console,timer,timer_status)
		end
	end
end
function toggleWeapons()
	local p = getPlayerShip(-1)
	if p:getWeaponTubeCount() == 0 then
		p:setBeamWeapon(0,90,-15,1200,8,6):setBeamWeapon(1,90,15,1200,8,6)
		p:setWeaponTubeCount(3)
	else
		p:setBeamWeapon(0,0,0,0,0,0):setBeamWeapon(1,0,0,0,0,0)
		p:setWeaponTubeCount(0)
	end
end
function commsSecurityPlatform()
	setCommsMessage(string.format("Greetings, %s. I am inspector Krevkin. I am here to verify your cargo, check for contraband and be sure all Kraylor safety regulations are being observed. Please open your access doorway.",comms_source:getCallSign()))
	addCommsReply("Opening the doorway now",allowInspection)
	addCommsReply("You may not enter our ship",function()
		setCommsMessage(string.format("We do not allow commercial access until after we complete an inspection. Refuse and you must vacate this area. If you attempt to proceed to %s, you will be treated as enemies and fired upon. This is your last opportunity.",kraylor_fort:getCallSign()))
		addCommsReply("You've made your point. Enter and inspect",allowInspection)
		addCommsReply("We will not submit to inspection",refuseInspection)
	end)
	addCommsReply("Are you alone?",function()
		setCommsMessage(string.format("%s is part of a military installation. As per Kraylor protocol 23, paragraph 19, 'all inspectors must be accompanied by no less than two armed guards during their inspection.' Today, I have %i with me. Enough questions. Open your access doorway.",security_platform:getCallSign(),math.random(3,5)))
		addCommsReply("I see. Come on in",allowInspection)
		addCommsReply("We can't allow so many to board our ship",refuseInspection)
	end)
end
function refuseInspection()
	setCommsMessage(string.format("%s, you are hereby ordered to vacate the area immediately and do not return on pain of death. Have a nice day. %s out.",comms_source:getCallSign(),security_platform:getCallSign()))
	comms_source:setCanDock(true)
	comms_source:commandUndock()
	comms_source:setCanDock(false)
	if iff_timer > 10 then
		iff_timer = 10
	end
	security_platform:setCommsScript(""):setCommsFunction(commsStation)
	return true
end
function allowInspection()
	setCommsMessage(string.format("Your cooperation is appreciated, %s",comms_source:getCallSign()))
	inspection_timer = 10
	inspectionPlot = inspectCargo
	return true
end
function inspectCargo(delta)
	inspection_timer = inspection_timer - delta
	if inspection_timer < 0 then
		local p = getPlayerShip(-1)
		local cargo_inspected_msg = string.format("The inspector opens a container marked %s and looks carefully inside. He seems satisfied and directs one of his guards to close the container.",kraylor_good)
		p:addCustomMessage("Relay","rly_cargo_inspected_msg",cargo_inspected_msg)
		p:addCustomMessage("Operations","ops_cargo_inspected_msg",cargo_inspected_msg)
		p:addCustomMessage("Single","one_cargo_inspected_msg",cargo_inspected_msg)
		p:addCustomMessage("ShipLog","log_cargo_inspected_msg",cargo_inspected_msg)
		p:addCustomMessage("AltRelay","alt_cargo_inspected_msg",cargo_inspected_msg)
		inspectionPlot = inspectEngineering
		inspection_timer = 10
	end
end
function inspectEngineering(delta)
	inspection_timer = inspection_timer - delta
	if inspection_timer < 0 then
		local p = getPlayerShip(-1)
		local engines_inspected_msg = "Krevkin comes into the engine room acting like he owns the entire ship. He squints at a couple of readout panels, looks suspiciously at a couple of technicians then leaves."
		p:addCustomMessage("Engineering","eng_engines_inspected_msg",engines_inspected_msg)
		p:addCustomMessage("Engineering+","pls_engines_inspected_msg",engines_inspected_msg)
		p:addCustomMessage("DamageControl","dmg_engines_inspected_msg",engines_inspected_msg)
		p:addCustomMessage("PowerManagement","pwr_engines_inspected_msg",engines_inspected_msg)
		p:addCustomMessage("Single","one_engines_inspected_msg",engines_inspected_msg)
		inspectionPlot = inspectWeapons
		inspection_timer = 10
	end
end
function inspectWeapons(delta)
	inspection_timer = inspection_timer - delta
	if inspection_timer < 0 then
		local p = getPlayerShip(-1)
		local contraband_type = "none"
		if p:getWeaponStorage("HVLI") > 1 then
			contraband_type = "HVLI"
		elseif p:getWeaponStorage("Homing") > 1 then
			contraband_type = "Homing"
		elseif p:getWeaponStorage("Mine") > 1 then
			contraband_type = "Mine"
		elseif p:getWeaponStorage("EMP") > 1 then
			contraband_type = "EMP"
		elseif p:getWeaponStorage("Nuke") > 1 then
			contraband_type = "Nuke"
		end
		if contraband_type ~= "none" then
			p:setWeaponStorage(contraband_type,math.floor(p:getWeaponStorage(contraband_type)/2))
			local weapons_inspected_msg = string.format("[Weapons technician] Krevkin looked around the weapons area. All the controls were hidden, but there's only so much we could do about the missiles. We had stored them in containers marked %s. He motioned his guards to a couple of the containers and said, 'contraband.' He looked at me and winked! So, he took some of our %s type missiles. I hope he does not open the containers for inspection any time soon. \n\nI took note of the lot numbers and put together a remote detonation switch just in case.",kraylor_good,contraband_type)
			p:addCustomMessage("Weapons","wea_weapons_inspected_msg",weapons_inspected_msg)
			p:addCustomMessage("Tactical","tac_weapons_inspected_msg",weapons_inspected_msg)
			p:addCustomMessage("Single","one_weapons_inspected_msg",weapons_inspected_msg)
			p:addCustomButton("Weapons","wea_remote_detonate","Remote Detonate",remoteDetonate)
			p:addCustomButton("Tactical","tac_remote_detonate","Remote Detonate",remoteDetonate)
			p:addCustomButton("Single","one_remote_detonate","Remote Detonate",remoteDetonate)
			inspection_timer = 15
		else
			local short_weapons_inspected_msg = "Krevkin looks briefly in the weapons control room, does not see anything amiss and moves on"
			p:addCustomMessage("Weapons","wea_weapons_inspected_msg",short_weapons_inspected_msg)
			p:addCustomMessage("Tactical","tac_weapons_inspected_msg",short_weapons_inspected_msg)
			p:addCustomMessage("Single","one_weapons_inspected_msg",short_weapons_inspected_msg)
			inspection_timer = 7
		end
		inspectionPlot = inspectComplete
	end
end
function inspectComplete(delta)
	inspection_timer = inspection_timer - delta
	if inspection_timer < 0 then
		local p = getPlayerShip(-1)
		p:setCanDock(true)
		if p:isCommsInactive() and security_platform_exit_hail_accepted == nil then
			security_platform_exit_hail_accepted = security_platform:sendCommsMessage(p,string.format("Inspection has been completed. You may proceed to %s in %s.",kraylor_fort:getCallSign(),kraylor_fort:getSectorName()))
			if not security_platform_exit_hail_accepted or not security_platform_hail_accepted then
				cover_blown = "ignored security"
			end
			inspectionPlot = nil
			virus_delay_timer = 10
			virusPlot = checkFortDock
			cargoPlot = checkForHail
		end
	end
end
function remoteDetonate()
	if security_platform:isValid() then
		local ex, ey = security_platform:getPosition()
		security_platform:destroy()
		ExplosionEffect():setPosition(ex,ey):setSize(1500)
		local list = getObjectsInRadius(ex,ey,1500)
		for _, obj in ipairs(list) do
			if obj.typeName == "CpuShip" or obj.typeName == "PlayerSpaceship" then
				obj:takeDamage(500)
			end
		end
	end
	local p = getPlayerShip(-1)
	if p ~= nil and p:isValid() then
		p:removeCustom("wea_remote_detonate")
		p:removeCustom("tac_remote_detonate")
		p:removeCustom("one_remote_detonate")
	end
end
function checkFortDock(delta)
	virus_delay_timer = virus_delay_timer - delta
	if virus_delay_timer < 0 then
		local p = getPlayerShip(-1)
		if p:isDocked(kraylor_fort) then
			p:setCanDock(false)
			local fort_clamps_locked_msg = string.format("The docking clamps have locked the ship to %s",kraylor_fort:getCallSign())
			p:addCustomMessage("Helms","hlm_clamps_locked_msg",fort_clamps_locked_msg)
			p:addCustomMessage("Tactical","tac_clamps_locked_msg",fort_clamps_locked_msg)
			p:addCustomMessage("Single","one_clamps_locked_msg",fort_clamps_locked_msg)
			virus_delay_timer = 25
			virusPlot = interfaceWithDock
		end
		virus_delay_timer = 10
	end
end
function interfaceWithDock(delta)
	virus_delay_timer = virus_delay_timer - delta
	if virus_delay_timer < 0 then
		local p = getPlayerShip(-1)
		virus_delay_timer = 30
		local virus_deployed_msg = string.format("The virus has been inserted into the computer systems of %s via their docking clamp's electronic interface. We should have results shortly.",kraylor_fort:getCallSign())
		p:addCustomMessage("Engineering","eng_virus_deployed",virus_deployed_msg)
		p:addCustomMessage("Engineering+","pls_virus_deployed",virus_deployed_msg)
		p:addCustomMessage("DamageControl","dmg_virus_deployed",virus_deployed_msg)
		p:addCustomMessage("PowerManagement","pwr_virus_deployed",virus_deployed_msg)
		p:addCustomMessage("Single","one_virus_deployed",virus_deployed_msg)
		virusPlot = fieldDeactivation
	end
end
function fieldDeactivation(delta)
	local effect_interval = .25
	virus_delay_timer = virus_delay_timer - delta
	if virus_delay_timer < 0 then
		if virus_effect == nil then
			virus_effect = "flash white in sequence"
		end
		if zone_index == nil then
			zone_index = 1
		end
		if zone_index > 9 then
			if virus_effect == "flash white in sequence" then
				zone_index = 1
				virus_effect = "flash red at random"
			elseif virus_effect == "flash red at random" then
				zone_index = 1
				virus_effect = "flash green in sequence"
			elseif virus_effect == "flash green in sequence" then
				for _, zone in ipairs(virus_region.zones) do
					zone:destroy()
				end
				zone_index = 1
				virus_region.zones = {}
				virus_region:setColor(0,128,0)
				local p = getPlayerShip(-1)
				local confirm_virus_msg = string.format("The virus deactivated several defensive fields around %s. All enemy forces should attack through the area marked %s on ship mapping consoles such as Science and Relay to avoid other %s defensive fields. The virus has gone into continuous hidden control mode to prevent the impacted defensive fields from being reactivated by %s personnel. Nevertheless, %s should be careful because the Kraylor may trace the virus origins back to %s",kraylor_fort:getCallSign(),virus_region.name,kraylor_fort:getCallSign(),kraylor_fort:getCallSign(),p:getCallSign(),p:getCallSign())
				p:addCustomMessage("Engineering","eng_confirm_virus_msg",confirm_virus_msg)
				p:addCustomMessage("Engineering+","pls_confirm_virus_msg",confirm_virus_msg)
				p:addCustomMessage("DamageControl","dmg_confirm_virus_msg",confirm_virus_msg)
				p:addCustomMessage("PowerManagement","pwr_confirm_virus_msg",confirm_virus_msg)
				p:addCustomMessage("Single","one_confirm_virus_msg",confirm_virus_msg)
				if iff_timer > 30 then
					iff_timer = 30
				end
				virusPlot = nil
			end
		end
		if virus_effect == "flash white in sequence" then
			if virus_region.zones[zone_index].color_state == nil then
				virus_region.zones[zone_index]:setColor(255,255,255)
				virus_region.zones[zone_index].color_state = "white"
				virus_delay_timer = effect_interval
			elseif virus_region.zones[zone_index].color_state == "white" then
				virus_region.zones[zone_index]:setColor(0,0,0)
				virus_region.zones[zone_index].color_state = "black"
				virus_delay_timer = effect_interval
				zone_index = zone_index + 1
			end
		elseif virus_effect == "flash red at random" then
			if index_list == nil then
				index_list = {1,2,3,4,5,6,7,8,9}
			end
			if random_index == nil then
				random_index = tableRemoveRandom(index_list)
			end
			if virus_region.zones[random_index].color_state == "black" then
				virus_region.zones[random_index]:setColor(255,0,0)
				virus_region.zones[random_index].color_state = "red"
				virus_delay_timer = effect_interval
			elseif virus_region.zones[random_index].color_state == "red" then
				virus_region.zones[random_index]:setColor(16,16,16)
				virus_region.zones[random_index].color_state = "dark"
				virus_delay_timer = effect_interval
				random_index = nil
				zone_index = zone_index + 1
			end
		elseif virus_effect == "flash green in sequence" then
			if #virus_region.zones > 0 then
				if virus_region.zones[zone_index].color_state == "dark" then
					virus_region.zones[zone_index]:setColor(0,255,0)
					virus_region.zones[zone_index].color_state = "green"
					virus_delay_timer = effect_interval
				elseif virus_region.zones[zone_index].color_state == "green" then
					virus_region.zones[zone_index]:setColor(0,0,0)
					virus_region.zones[zone_index].color_state = "black"
					virus_delay_timer = effect_interval
					zone_index = zone_index + 1
				end
			end
		end
	end
end
function checkForHail(delta)
	local p = getPlayerShip(-1)
	if p:isDocked(kraylor_fort) then
		if p:isCommsInactive() and fort_hail_accepted == nil then
			local comms_function = commsKraylorFortDock
			if cover_blown ~= "No" then
				comms_function = commsKraylorFortDockBlown
			end
			kraylor_fort:setCommsScript(""):setCommsFunction(comms_function)
			fort_hail_accepted = kraylor_fort:openCommsTo(p)
		end
	end
	if fort_hail_accepted ~= nil then
		cargoPlot = nil
	end
end
function commsKraylorFortDock()
	setCommsMessage(string.format("Greetings, %s. Please state the purpose of your visit to %s.",comms_source:getCallSign(),comms_target:getCallSign()))
	addCommsReply(string.format("We are here to provide cargo requested by %s",comms_target:getCallSign()),function()
		string.format("")
		setCommsMessage("What cargo do you bring?")
		local player_good_count = 0
		if comms_source.goods ~= nil then
			for good, good_quantity in pairs(comms_source.goods) do
				if good_quantity > 0 then
					player_good_count = player_good_count + 1
				end
			end
		end
		if player_good_count < 1 then
			addCommsReply("None",function()
				string.format("")
				setCommsMessage("Then, apart from target practice, you are useless to us. Have a nice day.")
				if iff_timer > 2 then
					iff_timer = 2
				end
				comms_target:setCommsScript(""):setCommsFunction(commsStation)
			end)
		else
			for good, good_quantity in pairs(comms_source.goods) do
				if good_quantity > 0 then
					addCommsReply(string.format("%s (Quantity:%i)",good,good_quantity),function()
						string.format("")
						if good == kraylor_good then
							setCommsMessage(string.format("We need %s. Are you prepared to provide us with %s for a better standing with the Kraylor empire?",good,good))
							addCommsReply("Yes",function()
								string.format("")
								comms_source.goods[good] = comms_source.goods[good] - 1
								comms_source:addReputationPoints(50)
								comms_source.cargo = comms_source.cargo + 1
								setCommsMessage(string.format("%s transferred. You have the thanks of station %s on behalf of the Kraylor empire. Go in pieces ...uh... peace.",good,kraylor_fort:getCallSign()))
								comms_source:setCanDock(true)
								comms_target:setCommsScript(""):setCommsFunction(commsStation)
							end)
							addCommsReply("No",function()
								string.format("")
								setCommsMessage(string.format("Then why are you here? ...One moment... ah, from this report, I see why you are here. Your plan has failed, %s, your intentions are now clear.",comms_source:getCallSign()))
								if iff_timer > 4 then
									iff_timer = 4
								end
								comms_target:setCommsScript(""):setCommsFunction(commsStation)
								addCommsReply("What do you mean?",function()
									string.format("")
									setCommsMessage("Only that your traitorous ship will serve as a briefly bright shining example to others that try to thwart us. Take comfort from the fact that your final act will be in service to the Kraylor empire")
								end)
							end)
							addCommsReply("Do you have any other incentives to offer?",function()
								string.format("")
								setCommsMessage("Something more valuable to you? Your life perhaps?")
								addCommsReply("Quite right. We accept your terms",function()
									string.format("")
									comms_source.goods[good] = comms_source.goods[good] - 1
									comms_source.cargo = comms_source.cargo + 1
									setCommsMessage(string.format("%s transferred. You may depart at your convenience",good))
									comms_source:setCanDock(true)
									comms_target:setCommsScript(""):setCommsFunction(commsStation)
								end)
								addCommsReply("Are you threatening us?",function()
									string.format("")
									setCommsMessage("Not any longer. It is obvious that addressing you further is beneath my dignity.")
									if iff_timer > 3 then
										iff_timer = 3
									end
									comms_target:setCommsScript(""):setCommsFunction(commsStation)
								end)
							end)
						else
							setCommsMessage(string.format("We do not need %s. We need %s. Clearly you have not read the official proclamations made to the general populace of this area regarding our cargo needs. You shall be destroyed for your incompetence. This will serve as a warning to any other would-be traders that they should read our publications more carefully.",good,kraylor_good))
							if iff_timer > 5 then
								iff_timer = 5
							end
							comms_target:setCommsScript(""):setCommsFunction(commsStation)
						end
					end)
				end
			end
		end
	end)
	addCommsReply(string.format("We are here to sabotage %s",comms_target:getCallSign()),function()
		string.format("")
		setCommsMessage("I see. And how is that going for you?")
		if iff_timer > 2 then
			iff_timer = 2
		end
		comms_target:setCommsScript(""):setCommsFunction(commsStation)
		addCommsReply("Quite well, actually. Everything is proceeding as planned.",function()
			string.format("")
			setCommsMessage("Good. I hope that you enjoy the fruition of your plans. I know I certainly will.")
		end)
	end)
	addCommsReply(string.format("We plan to use the hospitality facilities provided by %s",comms_target:getCallSign()), function()
		string.format("")
		setCommsMessage(string.format("Sadly, we have no such facilities. However, we appreciate the hospitable offering of %s as target practice for our warriors.",comms_source:getCallSign()))
		if iff_timer > 3 then
			iff_timer = 3
		end
		comms_target:setCommsScript(""):setCommsFunction(commsStation)
	end)
	return true
end
function commsKraylorFortDockBlown()
	setCommsMessage(string.format("What brings such foolish Human Navy infiltrators to %s?",comms_target:getCallSign()))
	addCommsReply("We are delivering cargo, not infiltrating", function()
		string.format("")
		local reason_message = revelationMessage("You are poor liars.")
		setCommsMessage(reason_message)
		if iff_timer > 4 then
			iff_timer = 4
		end
		comms_target:setCommsScript(""):setCommsFunction(commsStation)
		addCommsReply("Release us. You have no right to hold us here",function()
			string.format("")
			setCommsMessage(string.format("We have every right, you filthy spies. We will enjoy watching your ship suffer impotently at the hand of the defensive forces around %s. Goodbye %s.",comms_target:getCallSign(),comms_source:getCallSign()))
		end)
	end)
	addCommsReply("We are Independent traders, not part of the Human Navy", function()
		string.format("")
		local reason_message = revelationMessage("Independent traders, Ha!")
		setCommsMessage(reason_message)
		if iff_timer > 4 then
			iff_timer = 4
		end
		comms_target:setCommsScript(""):setCommsFunction(commsStation)
		addCommsReply("What are you going to do?",function()
			string.format("")
			setCommsMessage(string.format("Do? Why, we will be entertained by your ship exploding as the defensive forces around %s use you as target practice. Goodbye %s.",comms_target:getCallSign(),comms_source:getCallSign()))
		end)
	end)
	addCommsReply(string.format("Why do you accuse us? Don't you want the %s we brought?",kraylor_good),function()
		string.format("")
		local reason_message = revelationMessage(string.format("Yes, the %s was important to us. However, it is more important to deal properly with spies.",kraylor_good))
		setCommsMessage(reason_message)
		if iff_timer > 5 then
			iff_timer = 5
		end
		comms_target:setCommsScript(""):setCommsFunction(commsStation)
		addCommsReply("How do you treat spies?",function()
			string.format("")
			setCommsMessage(string.format("In this case, you will be executed in a glorious blaze provided by the defensive forces around %s. Goodbye %s.",comms_target:getCallSign(),comms_source:getCallSign()))
		end)
	end)
	return true
end
function revelationMessage(msg_prefix)
	local reason_message = msg_prefix
	if cover_blown == "Warp" then
		reason_message = string.format("%s When we observed %s traveling at warp speed, a very unusual speed for a freighter, we ran further sensor checks and discovered your hidden weapons and Human Navy origins. Speaking of which, I think we will take care of your forged IFF now.",reason_message,comms_source:getCallSign())
	elseif cover_blown == "Weapons" then
		reason_message = string.format("%s When we observed the weapons on %s, very unusual for a freighter, we ran further sensor checks and discovered your hidden warp drive and Human Navy origins. Speaking of which, I think we will take care of your forged IFF now.",reason_message,comms_source:getCallSign())
	elseif cover_blown == "IFF" then
		reason_message = string.format("%s Your forged and now reverted IFF shows you for the true Human Navy riffraff that you are.",reason_message)
	else	--ignored security
		reason_message = string.format("%s Your abberent behavior in response to normal security protocol messages revealed your true colors. Additional scans revealed your hidden weapons, warp drive and Human Navy origins. Speaking of which, I think we will take care of your forged IFF now.",reason_message)
	end
	return reason_message
end
function commsKraylorFort()
	setCommsMessage(string.format("Dock with defense platform %s in %s for cargo inspection",security_platform:getCallSign(),security_platform:getSectorName()))
	addCommsReply("We hear and obey",function()
		string.format("")
		setCommsMessage("An appropriate subservient attitude")
		addCommsReply("Back",commsKraylorFort)
	end)
	addCommsReply("Do we have to?",function()
		string.format("")
		setCommsMessage(string.format("Your impertinence shows no bounds, %s. How dare you question our security protocols. If you wish to trade with us, you will abide by our regulations and protocols or at best, you will not trade with us or at worst, you will find yourself reduced to your component elements",comms_source:getCallSign()))
		addCommsReply("Ok, ok. We just asked for confirmation. We will comply.",function()
			string.format("")
			setCommsMessage("See that you do.")
			addCommsReply("Back",commsKraylorFort)
		end)
		addCommsReply("Back",commsKraylorFort)
	end)
	kraylor_fort:setCommsScript(""):setCommsFunction(commsStation)
	return true
end
---------------------------------------
--	Support for fortress plot lines  --
---------------------------------------
function populateShipImpact()
	return {"scan","combat_maneuver","probe_launch","hacking","shields","shield_health","beams","missiles","ftl"}
end
function fortZoneCheck(delta)
	local iv = .99	--impact value
	local obj_list = getObjectsInRadius(kraylor_fort_x,kraylor_fort_y,25000)
	for _, obj in ipairs(obj_list) do
		if obj ~= nil and obj:isValid() then
			if obj.typeName == "CpuShip" or obj.typeName == "PlayerSpaceship" then
				if obj:isEnemy(kraylor_fort) then
					for r=0,5 do
						if region[r]:isInside(obj) then
							for _, zone in ipairs(region[r].zones) do
								if zone:isValid() and zone:isInside(obj) then
									if zone.revealed == nil then
										zone.revealed = true
										zone:setColor(fort_zone_color[zone.name].r,fort_zone_color[zone.name].g,fort_zone_color[zone.name].b)
										newZonePatrolCheck(obj)
										zone_reveal_count = zone_reveal_count + 1
									end
									if obj.typeName == "CpuShip" then
										if zone.ship_impact == "shields" then
											if obj:getShieldCount() > 0 then
												if obj:getShieldCount() == 1 then
													obj:setShields(obj:getShieldLevel(0)*iv)
												elseif obj:getShieldCount() == 2 then
													obj:setShields(
														obj:getShieldLevel(0)*iv,
														obj:getShieldLevel(1)*iv
													)
												elseif obj:getShieldCount() == 3 then
													obj:setShields(
														obj:getShieldLevel(0)*iv,
														obj:getShieldLevel(1)*iv,
														obj:getShieldLevel(2)*iv
													)
												elseif obj:getShieldCount() == 4 then
													obj:setShields(
														obj:getShieldLevel(0)*iv,
														obj:getShieldLevel(1)*iv,
														obj:getShieldLevel(2)*iv,
														obj:getShieldLevel(3)*iv
													)
												elseif obj:getShieldCount() == 5 then
													obj:setShields(
														obj:getShieldLevel(0)*iv,
														obj:getShieldLevel(1)*iv,
														obj:getShieldLevel(2)*iv,
														obj:getShieldLevel(3)*iv,
														obj:getShieldLevel(4)*iv
													)
												else
													obj:setShields(
														obj:getShieldLevel(0)*iv,
														obj:getShieldLevel(1)*iv,
														obj:getShieldLevel(2)*iv,
														obj:getShieldLevel(3)*iv,
														obj:getShieldLevel(4)*iv,
														obj:getShieldLevel(5)*iv
													)
												end
											end
										elseif zone.ship_impact == "shield_health" then
											obj:setSystemHealth("frontshield",(obj:getSystemHealth("frontshield") + 1) * iv - 1)
											obj:setSystemHealth("rearshield",(obj:getSystemHealth("rearshield") + 1) * iv - 1)
										elseif zone.ship_impact == "beams" then
											obj:setSystemHealth("beamweapons",(obj:getSystemHealth("beamweapons") + 1) * iv - 1)
										elseif zone.ship_impact == "missiles" then
											obj:setSystemHealth("missilesystem",(obj:getSystemHealth("missilesystem") + 1) * iv - 1)
										elseif zone.ship_impact == "ftl" then
											obj:setSystemHealth("warp",(obj:getSystemHealth("warp") + 1) * iv - 1)
											obj:setSystemHealth("jumpdrive",(obj:getSystemHealth("jumpdrive") + 1) * iv - 1)
										end
									else	--PlayerSpaceship
										if zone.ship_impact == "shields" then
											if obj:getShieldCount() > 0 then
												if obj:getShieldCount() == 1 then
													obj:setShields(obj:getShieldLevel(0)*iv)
												else
													if random(1,100) <= 50 then
														--	local before_front = obj:getShieldLevel(0)
														obj:setShields(obj:getShieldLevel(0)*iv,obj:getShieldLevel(1))
														--	print("Zone:",zone.name,"front shields before:",before_front,"after:",obj:getShieldLevel(0))
													else
														--	local before_rear = obj:getShieldLevel(1)
														obj:setShields(obj:getShieldLevel(0),obj:getShieldLevel(1)*iv)
														--	print("Zone:",zone.name,"rear shields before:",before_rear,"after:",obj:getShieldLevel(1))
													end
												end
											end
										elseif zone.ship_impact == "shield_health" then
											if obj:getShieldCount() > 0 then
												if obj:getShieldCount() == 1 then
													obj:setSystemHealth("frontshield",(obj:getSystemHealth("frontshield") + 1) * iv - 1)
												else
													if random(1,100) <= 50 then
														--	local before_front_health = obj:getSystemHealth("frontshield")
														obj:setSystemHealth("frontshield",(obj:getSystemHealth("frontshield") + 1) * iv - 1)
														--	print("Zone:",zone.name,"front shield health before:",before_front_health,"after:",obj:getSystemHealth("frontshield"))
													else
														--	local before_rear_health = obj:getSystemHealth("rearshield")
														obj:setSystemHealth("rearshield",(obj:getSystemHealth("rearshield") + 1) * iv - 1)
														--	print("Zone:",zone.name,"rear shield health before:",before_rear_health,"after:",obj:getSystemHealth("rearshield"))
													end
												end
											end
										elseif zone.ship_impact == "beams" then
											--	local before_beams = obj:getSystemHealth("beamweapons")
											obj:setSystemHealth("beamweapons",(obj:getSystemHealth("beamweapons") + 1) * iv - 1)
											--	print("Zone:",zone.name,"beams before:",before_beams,"after:",obj:getSystemHealth("beamweapons"))
										elseif zone.ship_impact == "missiles" then
											--	local before_missiles = obj:getSystemHealth("missilesystem")
											obj:setSystemHealth("missilesystem",(obj:getSystemHealth("missilesystem") + 1) * iv - 1)
											--	print("Zone:",zone.name,"missiles before:",before_missiles,"after:",obj:getSystemHealth("missilesystem"))
										elseif zone.ship_impact == "ftl" then
											--	local before_warp = obj:getSystemHealth("warp")
											--	local before_jump = obj:getSystemHealth("jumpdrive")
											obj:setSystemHealth("warp",(obj:getSystemHealth("warp") + 1) * iv - 1)
											obj:setSystemHealth("jumpdrive",(obj:getSystemHealth("jumpdrive") + 1) * iv - 1)
											--	print("Zone:",zone.name,"warp before:",before_warp,"after:",obj:getSystemHealth("warp"),"jump before:",before_jump,"after:",obj:getSystemHealth("jumpdrive"))
										elseif zone.ship_impact == "scan" then
											obj:setCanScan(false)
											--	print("Zone:",zone.name,"Scan disabled")
										elseif zone.ship_impact == "combat_maneuver" then
											obj:setCanCombatManeuver(false)
											--	print("Zone:",zone.name,"Combat maneuver disabled")
										elseif zone.ship_impact == "probe_launch" then
											obj:setCanLaunchProbe(false)
											--	print("Zone:",zone.name,"Probe Launch disabled")
										elseif zone.ship_impact == "hacking" then
											obj:setCanHack(false)
											--	print("Zone:",zone.name,"Hacking disabled")
										end
									end
									break
								end
							end
							break
						end
					end
				end
			end
		end
	end
--[[
	for _, zone in ipairs(fort_zones) do
		local obj_list = getObjectsInRadius(zone.center_x,zone.center_y,zone.radius)
		for _, obj in ipairs(obj_list) do
			if obj ~= nil and obj:isValid() then
				if zone:isInside(obj) then
					if obj:isEnemy(zone) then
						if obj.typeName == "CpuShip" then
							if zone.revealed == nil then
								zone.revealed = true
								zone:setColor(fort_zone_color[zone.name].r,fort_zone_color[zone.name].g,fort_zone_color[zone.name].b)
								newZonePatrolCheck(obj)
								zone_reveal_count = zone_reveal_count + 1
							end
							if zone.ship_impact == "shields" then
								if obj:getShieldCount() > 0 then
									if obj:getShieldCount() == 1 then
										obj:setShields(obj:getShieldLevel(0)*.95)
									elseif obj:getShieldCount() == 2 then
										obj:setShields(
											obj:getShieldLevel(0)*iv,
											obj:getShieldLevel(1)*iv
										)
									elseif obj:getShieldCount() == 3 then
										obj:setShields(
											obj:getShieldLevel(0)*iv,
											obj:getShieldLevel(1)*iv,
											obj:getShieldLevel(2)*iv
										)
									elseif obj:getShieldCount() == 4 then
										obj:setShields(
											obj:getShieldLevel(0)*iv,
											obj:getShieldLevel(1)*iv,
											obj:getShieldLevel(2)*iv,
											obj:getShieldLevel(3)*iv
										)
									elseif obj:getShieldCount() == 5 then
										obj:setShields(
											obj:getShieldLevel(0)*iv,
											obj:getShieldLevel(1)*iv,
											obj:getShieldLevel(2)*iv,
											obj:getShieldLevel(3)*iv,
											obj:getShieldLevel(4)*iv
										)
									else
										obj:setShields(
											obj:getShieldLevel(0)*iv,
											obj:getShieldLevel(1)*iv,
											obj:getShieldLevel(2)*iv,
											obj:getShieldLevel(3)*iv,
											obj:getShieldLevel(4)*iv,
											obj:getShieldLevel(5)*iv
										)
									end
								end
							elseif zone.ship_impact == "shield_health" then
								obj:setSystemHealth("frontshield",(obj:getSystemHealth("frontshield") + 1) * iv - 1)
								obj:setSystemHealth("rearshield",(obj:getSystemHealth("rearshield") + 1) * iv - 1)
							elseif zone.ship_impact == "beams" then
								obj:setSystemHealth("beamweapons",(obj:getSystemHealth("beamweapons") + 1) * iv - 1)
							elseif zone.ship_impact == "missiles" then
								obj:setSystemHealth("missilesystem",(obj:getSystemHealth("missilesystem") + 1) * iv - 1)
							elseif zone.ship_impact == "ftl" then
								obj:setSystemHealth("warp",(obj:getSystemHealth("warp") + 1) * iv - 1)
								obj:setSystemHealth("jumpdrive",(obj:getSystemHealth("jumpdrive") + 1) * iv - 1)
							end
						elseif obj.typeName == "PlayerSpaceship" then
							if zone.revealed == nil then
								zone.revealed = true
								zone:setColor(fort_zone_color[zone.name].r,fort_zone_color[zone.name].g,fort_zone_color[zone.name].b)
								newZonePatrolCheck(obj)
								zone_reveal_count = zone_reveal_count + 1
							end
							if zone.ship_impact == "shields" then
								--print("impact: shields")
								if obj:getShieldCount() > 0 then
									if obj:getShieldCount() == 1 then
										obj:setShields(obj:getShieldLevel(0)*iv)
									else
										if random(1,100) <= 50 then
											obj:setShields(obj:getShieldLevel(0)*iv,obj:getShieldLevel(1))
										else
											obj:setShields(obj:getShieldLevel(0),obj:getShieldLevel(1)*iv)
										end
									end
								end
							elseif zone.ship_impact == "shield_health" then
								--print("impact: shield health")
								if obj:getShieldCount() > 0 then
									if obj:getShieldCount() == 1 then
										obj:setSystemHealth("frontshield",(obj:getSystemHealth("frontshield") + 1) * iv - 1)
									else
										if random(1,100) <= 50 then
											obj:setSystemHealth("frontshield",(obj:getSystemHealth("frontshield") + 1) * iv - 1)
										else
											obj:setSystemHealth("rearshield",(obj:getSystemHealth("rearshield") + 1) * iv - 1)
										end
									end
								end
							elseif zone.ship_impact == "beams" then
								--print("impact: beams")
								obj:setSystemHealth("beamweapons",(obj:getSystemHealth("beamweapons") + 1) * iv - 1)
							elseif zone.ship_impact == "missiles" then
								--print("impact: missiles")
								obj:setSystemHealth("missilesystem",(obj:getSystemHealth("missilesystem") + 1) * iv - 1)
							elseif zone.ship_impact == "ftl" then
								--print("impact: ftl")
								obj:setSystemHealth("warp",(obj:getSystemHealth("warp") + 1) * iv - 1)
								obj:setSystemHealth("jumpdrive",(obj:getSystemHealth("jumpdrive") + 1) * iv - 1)
							elseif zone.ship_impact == "scan" then
								--print("impact: scan")
								obj:setCanScan(false)
							elseif zone.ship_impact == "combat_maneuver" then
								--print("impact: combat maneuver")
								obj:setCanCombatManeuver(false)
							elseif zone.ship_impact == "probe_launch" then
								--print("impact: probe launch")
								obj:setCanLaunchProbe(false)
							elseif zone.ship_impact == "hacking" then
								--print("impact: hack")
								obj:setCanHack(false)
							end
						end
					end
				end
			end
		end
	end
--]]
	if zone_reveal_count >= 2 then
		local p = getPlayerShip(-1)
		if p:isValid() then
			if p.defense_field_report_message == nil then
				p:addToShipLog("We've been monitoring friendly encounters with those Kraylor defense fields and their effects. Contact a friendly station to get a current monitoring result report.","Magenta")
				p.defense_field_report_message = "sent"
			end
			if zone_reveal_count >=3 then
				if p.friendly_suggestion_message == nil then
					p:addToShipLog(string.format("With the defense platform in place, you may try to get friendly ships to help against those Kraylor emplacements, even some of the ones defending %s",primary_human_station:getCallSign()),"Magenta")
					p.friendly_suggestion_message = "sent"
				end
				if zone_reveal_count >= 5 then
					if p.infiltrate_message == nil then
						p:addToShipLog(string.format("Headquarters has devised a potential alternative plan for dealing with the Kraylor emplacements. Dock with %s for discussion.",primary_human_station:getCallSign()),"Magenta")
						p.infiltrate_message = "sent"
					end
				end
			end
		end
	end
end
function createNewZonePatrol(ship)
	zone_patrol = {}
	local ship_x, ship_y = ship:getPosition()
	local zone_patrol_angle = angleFromVectorNorth(ship_x, ship_y, kraylor_fort_x, kraylor_fort_y)
	local leader_x, leader_y = vectorFromAngleNorth(zone_patrol_angle, 1500)
	local p_ship = CpuShip():setTemplate("MT52 Hornet"):setFaction("Kraylor"):setCallSign(generateCallSign(nil,"Kraylor")):orderAttack(ship):setCommsScript(""):setCommsFunction(commsShip)
	p_ship:setPosition(kraylor_fort_x + leader_x, kraylor_fort_y + leader_y):setHeading(zone_patrol_angle):onDestroyed(enemyVesselDestroyed):setAI("default")
	p_ship.leader = true
	table.insert(zone_patrol,p_ship)
	local circle_angle = zone_patrol_angle
	local circle_angle_prime = 0
	for i=1,6 do
		local f_ship = CpuShip():setTemplate("MU52 Hornet"):setFaction("Kraylor"):setCommsScript(""):setCommsFunction(commsShip)
		f_ship:setCallSign(generateCallSign(nil,"Kraylor"))
		local form_x, form_y = vectorFromAngleNorth(circle_angle, 800)
		local form_prime_x, form_prime_y = vectorFromAngle(circle_angle_prime, 800)
		f_ship:setPosition(kraylor_fort_x + leader_x + form_x, kraylor_fort_y + leader_y + form_y)
		f_ship:setHeading(zone_patrol_angle):setAI("default")
		f_ship:orderFlyFormation(zone_patrol[1],form_prime_x, form_prime_y):onDestroyed(enemyVesselDestroyed)
		table.insert(zone_patrol,f_ship)
		circle_angle = (circle_angle + 60) % 360
		circle_angle_prime = (circle_angle_prime + 60) % 360
	end
end
function newZonePatrolCheck(ship)
	if zone_patrol == nil then
		createNewZonePatrol(ship)
	else
		local p_ship_count = 0
		for _, p_ship in pairs(zone_patrol) do
			if p_ship ~= nil and p_ship:isValid() then
				p_ship_count = p_ship_count + 1
			end
		end
		if p_ship_count < 5 then
			if p_ship_count == 0 then
				createNewZonePatrol(ship)
			elseif p_ship_count < 3 then
				for _, p_ship in pairs(zone_patrol) do
					if p_ship ~= nil and p_ship:isValid() then
						p_ship:setAI("fighter")
						p_ship:orderRoaming()
					end
				end
				createNewZonePatrol(ship)
			else
				for _, p_ship in pairs(zone_patrol) do
					if p_ship ~= nil and p_ship:isValid() then
						p_ship:setAI("fighter")
					end
				end
			end
		end
		for _, p_ship in pairs(zone_patrol) do
			if p_ship ~= nil and p_ship:isValid() then
				local target = p_ship:getOrderTarget()
				if target ~= nil then
					if not target:isValid() then
						p_ship:orderAttack(ship)
					end
				else
					p_ship:orderAttack(ship)
				end
			end
		end
	end
end
function sensorJammerPickupProcess(self,retriever)
	local jammer_call_sign = self:getCallSign()
	sensor_jammer_list[jammer_call_sign] = nil
	if not self:isScannedBy(retriever) then
		retriever:setCanScan(false)
	end
end
function sensorJammer(x,y)
	artifactCounter = artifactCounter + 1
	artifactNumber = artifactNumber + math.random(1,4)
	local random_suffix = string.char(math.random(65,90))
	local jammer_call_sign = string.format("SJ%i%s",artifactNumber,random_suffix)
	local sensor_jammer = Artifact():setPosition(x,y):setScanningParameters(sensor_jammer_scan_complexity,sensor_jammer_scan_depth):setRadarSignatureInfo(.2,.4,.1):setModel("SensorBuoyMKIII"):setDescriptions("Source of unusual emanations","Source of emanations interfering with long range sensors"):setCallSign(jammer_call_sign)
	sensor_jammer:onPickUp(sensorJammerPickupProcess)
	sensor_jammer_list[jammer_call_sign] = sensor_jammer
	sensor_jammer.jam_range = sensor_jammer_range
	sensor_jammer.jam_impact = sensor_jammer_impact
	sensor_jammer.jam_impact_units = sensor_jammer_power_units
end
function updatePlayerLongRangeSensors(p)
	local base_range = p.normal_long_range_radar
	local impact_range = math.max(base_range * sensor_impact,p:getShortRangeRadarRange())
	local sensor_jammer_impact = 0
	for jammer_name, sensor_jammer in pairs(sensor_jammer_list) do
		if sensor_jammer ~= nil and sensor_jammer:isValid() then
			local jammer_distance = distance(p,sensor_jammer)
			if jammer_distance < sensor_jammer.jam_range then
				if sensor_jammer.jam_impact_units then
					sensor_jammer_impact = math.max(sensor_jammer_impact,sensor_jammer.jam_impact*(1-(jammer_distance/sensor_jammer.jam_range)))
				else
					sensor_jammer_impact = math.max(sensor_jammer_impact,impact_range*sensor_jammer.jam_impact/100000*(1-(jammer_distance/sensor_jammer.jam_range)))
				end
			end
		else
			sensor_jammer_list[jammer_name] = nil
		end
	end
	impact_range = math.max(p:getShortRangeRadarRange(),impact_range - sensor_jammer_impact)
	p:setLongRangeRadarRange(impact_range)
end
function stalkerPatrolDelay(delta)
	stalker_patrol_timer = stalker_patrol_timer - delta
	if stalker_patrol_timer < 0 then
		stalkerPatrolPlot = stalkerPatrolCheck
	end
end
function stalkerPatrolCheck(delta)
	for i=1,6 do
		local ship = stalker_patrol[i]
		if ship == nil then
			createStalkerPatrol(i)
		else
			if ship:isValid() then
				if string.find(ship:getOrder(),"Defend") then
					ship.patrol_point_index = ship.patrol_point_index + 1
					if ship.patrol_point_index > #ship.patrol_points then
						ship.patrol_point_index = 1
					end
					ship:orderFlyTowards(ship.patrol_points[ship.patrol_point_index].x,ship.patrol_points[ship.patrol_point_index].y)
				end
			else
				createStalkerPatrol(i)
			end
		end
	end
	stalker_patrol_timer = 10
	stalkerPatrolPlot = stalkerPatrolDelay
end
function createStalkerPatrol(index)
	local stalker_templates = {"Stalker R7","Stalker R5","Stalker Q7","Stalker Q5"}
	local start_patrol_points = {"G3","G13","G23","G33","G43","G53"}
	local finish_patrol_points = {"G9","G19","G29","G39","G49","G59"}
	if named_fort_zones[start_patrol_points[index]] ~= nil and named_fort_zones[start_patrol_points[index]]:isValid() then
		local ship = CpuShip():setTemplate(stalker_templates[math.random(1,#stalker_templates)]):setCallSign(generateCallSign(nil,"Kraylor"))
		ship:setPosition(kraylor_fort_x,kraylor_fort_y)
		ship.patrol_points = {
			{x = named_fort_zones[start_patrol_points[index]].outer_edge_x, y = named_fort_zones[start_patrol_points[index]].outer_edge_y},
			{x = named_fort_zones[finish_patrol_points[index]].outer_edge_x, y = named_fort_zones[finish_patrol_points[index]].outer_edge_y}
		}
		ship:orderFlyTowards(ship.patrol_points[1].x, ship.patrol_points[1].y)
		ship.patrol_point_index = 1
		stalker_patrol[index] = ship
	end
end
function winTheGame()
	globalMessage("You have eliminated the source of the Kraylor attackers")
	victory("Human Navy")
end
--	specialized fortress emplacements
function missilePod(enemyFaction)
	-- common shared between all the missile pods
	local ship=CpuShip():setFaction(enemyFaction):setTemplate("Defense platform"):orderStandGround():setTypeName("Missile Pod")
	-- no beams for missile platforms
	ship:setBeamWeapon(0, 30, 0, 0, 1.5, 20.0):setBeamWeaponTurret(0, 0, 0, 0)
	ship:setBeamWeapon(1, 30, 60, 0, 1.5, 20.0):setBeamWeaponTurret(1, 0, 0, 0)
	ship:setBeamWeapon(2, 30, 120, 0, 1.5, 20.0):setBeamWeaponTurret(2, 0, 0, 0)
	ship:setBeamWeapon(3, 30, 180, 0, 1.5, 20.0):setBeamWeaponTurret(3, 0, 0, 0)
	ship:setBeamWeapon(4, 30, 240, 0, 1.5, 20.0):setBeamWeaponTurret(4, 0, 0, 0)
	ship:setBeamWeapon(5, 30, 300, 0, 1.5, 20.0):setBeamWeaponTurret(5, 0, 0, 0)
	-- much weaker shields / hull than normal
	ship:setHullMax(35):setHull(35):setShieldsMax(50):setShields(50)
	ship:setRotationMaxSpeed(5)
	-- note no missiles - that is done in the individual type of platforms
	local missile_pod_db = queryScienceDatabase("Stations","Missile Pod")
	if missile_pod_db == nil then
		local station_db = queryScienceDatabase("Stations")
		if station_db == nil then
			station_db = stationScienceEntry()
		end
		station_db:addEntry("Missile Pod")
		missile_pod_db = queryScienceDatabase("Stations","Missile Pod")
		missile_pod_db:setLongDescription("A missile pod allows a limited selection of ship types to dock. It has offensive weapons sytems to help defend against enemy ships")
		missile_pod_db:setImage("radartrace_smallstation.png")
		missile_pod_db:setKeyValue("Class","Small")
		missile_pod_db:setKeyValue("Size",300)
		missile_pod_db:setKeyValue("Allowed to Dock","Starfighter/Frigate")
		missile_pod_db:setModelDataName("space_station_4")
	end
	return ship
end
function missilePodTX8(enemyFaction)
	local ship=missilePod(enemyFaction):setTypeName("Missile Pod TX8")
	ship:setShortRangeRadarRange("5500")
	ship:setWeaponTubeCount(4)
	ship:setTubeLoadTime(0,random(16,23)):setWeaponTubeDirection(0,0)
	ship:setTubeLoadTime(1,random(16,23)):setWeaponTubeDirection(1,90)
	ship:setTubeLoadTime(2,random(16,23)):setWeaponTubeDirection(1,180)
	ship:setTubeLoadTime(3,random(16,23)):setWeaponTubeDirection(1,270)
	ship:setTubeSize(0,"medium"):setWeaponTubeExclusiveFor(0,"Homing")
	ship:setTubeSize(1,"medium"):setWeaponTubeExclusiveFor(1,"Homing")
	ship:setTubeSize(2,"medium"):setWeaponTubeExclusiveFor(2,"Homing")
	ship:setTubeSize(3,"medium"):setWeaponTubeExclusiveFor(3,"Homing")
	ship:setWeaponStorageMax("Homing", 400):setWeaponStorage("Homing", 400)
	local missile_pod_tx8_db = queryScienceDatabase("Stations","Missile Pod","Missile Pod TX8")
	if missile_pod_tx8_db == nil then
		local missile_pod_db = queryScienceDatabase("Stations","Missile Pod")
		missile_pod_db:addEntry("Missile Pod TX8")
		missile_pod_tx8_db = queryScienceDatabase("Stations","Missile Pod","Missile Pod TX8")
		missile_pod_tx8_db:setLongDescription("A missile pod allows a limited selection of ship types to dock. The TX8 fires medium, tracking missiles from four tubes to help defend against enemy ships")
		missile_pod_tx8_db:setImage("radartrace_smallstation.png")
		missile_pod_tx8_db:setKeyValue("Class","Small")
		missile_pod_tx8_db:setKeyValue("Size",300)
		missile_pod_tx8_db:setKeyValue("Shield",50)
		missile_pod_tx8_db:setKeyValue("Hull",35)
		missile_pod_tx8_db:setKeyValue("Turn speed","5 deg/sec")
		missile_pod_tx8_db:setKeyValue("Tube 0","16-23 Sec")
		missile_pod_tx8_db:setKeyValue("Tube 90","16-23 Sec")
		missile_pod_tx8_db:setKeyValue("Tube 180","16-23 Sec")
		missile_pod_tx8_db:setKeyValue("Tube 270","16-23 Sec")
		missile_pod_tx8_db:setKeyValue("Storage Homing",400)
		missile_pod_tx8_db:setKeyValue("Allowed to Dock","Starfighter/Frigate")
		missile_pod_tx8_db:setModelDataName("space_station_4")
	end
	return ship
end
function missilePodTX16(enemyFaction)
	local ship=missilePod(enemyFaction):setTypeName("Missile Pod TX16")
	ship:setShortRangeRadarRange("4500")
	ship:setWeaponTubeCount(4)
	ship:setTubeLoadTime(0,random(21,28)):setWeaponTubeDirection(0,0)
	ship:setTubeLoadTime(1,random(21,28)):setWeaponTubeDirection(1,90)
	ship:setTubeLoadTime(2,random(21,28)):setWeaponTubeDirection(1,180)
	ship:setTubeLoadTime(3,random(21,28)):setWeaponTubeDirection(1,270)
	ship:setTubeSize(0,"large"):setWeaponTubeExclusiveFor(0,"Homing")
	ship:setTubeSize(1,"large"):setWeaponTubeExclusiveFor(1,"Homing")
	ship:setTubeSize(2,"large"):setWeaponTubeExclusiveFor(2,"Homing")
	ship:setTubeSize(3,"large"):setWeaponTubeExclusiveFor(3,"Homing")
	ship:setWeaponStorageMax("Homing", 400):setWeaponStorage("Homing", 400)
	local missile_pod_tx16_db = queryScienceDatabase("Stations","Missile Pod","Missile Pod TX16")
	if missile_pod_tx16_db == nil then
		local missile_pod_db = queryScienceDatabase("Stations","Missile Pod")
		missile_pod_db:addEntry("Missile Pod TX16")
		missile_pod_tx16_db = queryScienceDatabase("Stations","Missile Pod","Missile Pod TX16")
		missile_pod_tx16_db:setLongDescription("A missile pod allows a limited selection of ship types to dock. The TX16 fires large, tracking missiles from four tubes to help defend against enemy ships")
		missile_pod_tx16_db:setImage("radartrace_smallstation.png")
		missile_pod_tx16_db:setKeyValue("Class","Small")
		missile_pod_tx16_db:setKeyValue("Size",300)
		missile_pod_tx16_db:setKeyValue("Shield",50)
		missile_pod_tx16_db:setKeyValue("Hull",35)
		missile_pod_tx16_db:setKeyValue("Turn speed","5 deg/sec")
		missile_pod_tx16_db:setKeyValue("Large Tube 0","21-28 Sec")
		missile_pod_tx16_db:setKeyValue("Large Tube 90","21-28 Sec")
		missile_pod_tx16_db:setKeyValue("Large Tube 180","21-28 Sec")
		missile_pod_tx16_db:setKeyValue("Large Tube 270","21-28 Sec")
		missile_pod_tx16_db:setKeyValue("Storage Homing",400)
		missile_pod_tx16_db:setKeyValue("Allowed to Dock","Starfighter/Frigate")
		missile_pod_tx16_db:setModelDataName("space_station_4")
	end
	return ship
end
function sniperTower(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Defense platform"):orderRoaming()
	ship:setShortRangeRadarRange(7000)
	ship:setTypeName("Sniper Tower")
	ship:setRotationMaxSpeed(3)			--faster maneuver (vs .5)
	ship:setSharesEnergyWithDocked(true)
	ship:setRepairDocked(true)
	ship:setRestocksScanProbes(true)
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,	10,	   0,	6000,		6,		6)
	ship:setBeamWeapon(1,	10,	   90,	6000,		6,		6)
	ship:setBeamWeapon(2,	10,	  180,	6000,		6,		6)
	ship:setBeamWeapon(3,	10,	  270,	6000,		6,		6)
	ship:setBeamWeapon(4,	 0,	    0,	   0,		0,		0)
	ship:setBeamWeapon(5,	 0,	    0,	   0,		0,		0)
	local sniper_tower_db = queryScienceDatabase("Stations","Sniper Tower")
	if sniper_tower_db == nil then
		local station_db = queryScienceDatabase("Stations")
		if station_db == nil then
			station_db = stationScienceEntry()
		end
		station_db:addEntry("Sniper Tower")
		sniper_tower_db = queryScienceDatabase("Stations","Sniper Tower")
		sniper_tower_db:setLongDescription("A sniper tower allows a limited selection of ship types to dock. It has offensive weapons sytems to help defend against enemy ships")
		sniper_tower_db:setImage("radartrace_smallstation.png")
		sniper_tower_db:setKeyValue("Class","Small")
		sniper_tower_db:setKeyValue("Size",150)
		sniper_tower_db:setKeyValue("Shield","120/120/120/120/120/120")
		sniper_tower_db:setKeyValue("Hull",300)
		sniper_tower_db:setKeyValue("Turn speed","3 deg/sec")
		sniper_tower_db:setKeyValue("Beam weapon   0:10","6.0 Dmg / 6.0 Sec")
		sniper_tower_db:setKeyValue("Beam weapon  90:10","6.0 Dmg / 6.0 Sec")
		sniper_tower_db:setKeyValue("Beam weapon 180:10","6.0 Dmg / 6.0 Sec")
		sniper_tower_db:setKeyValue("Beam weapon 270:10","6.0 Dmg / 6.0 Sec")
		sniper_tower_db:setKeyValue("Beam Range","6 Units")
		sniper_tower_db:setKeyValue("Allowed to Dock","Starfighter/Frigate")
		sniper_tower_db:setModelDataName("space_station_4")
	end
	return ship	
end
function stationScienceEntry()
	station_db = ScienceDatabase():setName("Stations")
	station_db:setLongDescription("Stations are places for ships to dock, get repaired and replenished, interact with station personnel, etc. They are like oases, service stations, villages, towns, cities, etc.")
	station_db:addEntry("Small")
	local small_station_db = queryScienceDatabase("Stations","Small")
	small_station_db:setLongDescription("Stations of this size are often used as research outposts, listening stations, and security checkpoints. Crews turn over frequently in a small station's cramped accommodatations, but they are small enough to look like ships on many long-range sensors, and organized raiders sometimes take advantage of this by placing small stations in nebulae to serve as raiding bases. They are lightly shielded and vulnerable to swarming assaults.")
	small_station_db:setImage("radartrace_smallstation.png")
	small_station_db:setKeyValue("Class","Small")
	small_station_db:setKeyValue("Size",300)
	small_station_db:setKeyValue("Shield",300)
	small_station_db:setKeyValue("Hull",150)
	small_station_db:setModelDataName("space_station_4")
	station_db:addEntry("Medium")
	local medium_station_db = queryScienceDatabase("Stations","Medium")
	medium_station_db:setLongDescription("Large enough to accommodate small crews for extended periods of times, stations of this size are often trading posts, refuelling bases, mining operations, and forward military bases. While their shields are strong, concerted attacks by many ships can bring them down quickly.")
	medium_station_db:setImage("radartrace_mediumstation.png")
	medium_station_db:setKeyValue("Class","Medium")
	medium_station_db:setKeyValue("Size",1000)
	medium_station_db:setKeyValue("Shield",800)
	medium_station_db:setKeyValue("Hull",400)
	medium_station_db:setModelDataName("space_station_3")
	station_db:addEntry("Large")
	local large_station_db = queryScienceDatabase("Stations","Large")
	large_station_db:setLongDescription("These spaceborne communities often represent permanent bases in a sector. Stations of this size can be military installations, commercial hubs, deep-space settlements, and small shipyards. Only a concentrated attack can penetrate a large station's shields, and its hull can withstand all but the most powerful weaponry.")
	large_station_db:setImage("radartrace_largestation.png")
	large_station_db:setKeyValue("Class","Large")
	large_station_db:setKeyValue("Size",1300)
	large_station_db:setKeyValue("Shield","1000/1000/1000")
	large_station_db:setKeyValue("Hull",500)
	large_station_db:setModelDataName("space_station_2")
	station_db:addEntry("Huge")
	local huge_station_db = queryScienceDatabase("Stations","Huge")
	huge_station_db:setLongDescription("The size of a sprawling town, stations at this scale represent a faction's center of spaceborne power in a region. They serve many functions at once and represent an extensive investment of time, money, and labor. A huge station's shields and thick hull can keep it intact long enough for reinforcements to arrive, even when faced with an ongoing siege or massive, perfectly coordinated assault.")
	huge_station_db:setImage("radartrace_hugestation.png")
	huge_station_db:setKeyValue("Class","Huge")
	huge_station_db:setKeyValue("Size",1500)
	huge_station_db:setKeyValue("Shield","1200/1200/1200/1200")
	huge_station_db:setKeyValue("Hull",800)
	huge_station_db:setModelDataName("space_station_1")
	return station_db
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
	if #transport_list < #transport_stations then
		local check_stations = {}
		for _, station in pairs(transport_stations) do
			table.insert(check_stations,{station = station, transport = false})
		end
		for _, transport in pairs(transport_list) do
			for si, station in ipairs(check_stations) do
				if transport.home_station == station then
					station.transport = true
					break
				end
			end
		end
		for _, station in ipairs(check_stations) do
			if not station.transport then
				local transport, transport_size = randomTransportType()
				transport.home_station = station.station
				area_radius = 75000
				local o_x, o_y = vectorFromAngle(random(0,360),random(0,area_radius))
				o_x = o_x + center_x
				o_y = o_y + center_y
				transport:setPosition(o_x, o_y):setFaction(station.station:getFaction())
				transport:setCallSign(generateCallSign(nil,station.station:getFaction()))
				transport.normal_transport_plot = true
				transport.target = pickTransportTarget(transport)
				if transport.target ~= nil then
					transport:orderDock(transport.target)
				end
				table.insert(transport_list,transport)
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
---------------------------
-- Game Master functions --
---------------------------
function mainGMButtons()
	clearGMFunctions()
	addGMFunction(string.format("Version %s",scenario_version),function()
		local version_message = string.format("Scenario version %s\n LUA version %s",scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	addGMFunction("Show State",function()
		local p = getPlayerShip(-1)
		local out = "Mission state:"
		out = string.format("%s\n%s defense timer: %.1f",out,primary_human_station:getCallSign(),primary_check_timer)
		out = string.format("%s\n    Phobos: %i, %s   Nirvana: %i, %s   Adder: %i, %s   Fighter: %i, %s",out,#primary_phobos_defense,primary_phobos_defense[1]:getFaction(),#primary_nirvana_defense,primary_nirvana_defense[1]:getFaction(),#primary_adder_defense,primary_adder_defense[1]:getFaction(),#primary_fighter_defense,primary_fighter_defense[1]:getFaction())
		out = string.format("%s\nKraylor fighter wave count: %i",out,kraylor_fighter_wave_count)
		if improved_kraylor ~= nil then
			out = string.format("%s   Improved Kraylor: %.1f",out,improved_kraylor)
		end
		if defense_platform_count ~= nil then
			out = string.format("%s\nDefense platforms available for deployment: %i",out,defense_platform_count)
			if warp_drive_install_available then
				out = string.format("%s   Warp drive is now available to the player.",out)
			end
		end
		out = string.format("%s\nZones revealed: %i",out,zone_reveal_count)
		if p:isValid() then
			out = string.format("%s   Player faction: %s",out,p:getFaction())
			if iff_timer ~= nil and iff_timer > 0 then
				out = string.format("%s   IFF seconds remaining: %.1f",out,iff_timer)
			end
		end
		out = string.format("%s\nCover Blown: %s",out,cover_blown)
		addGMMessage(out)
	end)
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
	local missilePresence = 0
	local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	for _, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + comms_source:getWeaponStorageMax(missile_type)
	end
	if comms_target == primary_human_station then
--		addCommsReply("Test infiltrate ship conversation and conversion",commsDiscussInfiltrate)	--only for testing
		if warp_drive_install_available and not comms_source:hasWarpDrive() then
			addCommsReply("Install Warp Drive",function()
				setCommsMessage(string.format("Congratualtions %s on your warp drive.\n\nRemember, you must drop out of warp to fire any of your weapons",comms_source:getCallSign()))
				comms_source:setWarpDrive(true)
				comms_source:setWarpSpeed(650)
				addCommsReply("Back", commsStation)
			end)
		end
		if zone_reveal_count >= 5 then
			addCommsReply("Discuss alternative plan",function()
				setCommsMessage("We suggested that you direct some friendly warships to help in your mission to destroy the Kraylor fortress. You could have done this through waypoints or by leading the charge yourself. Was this tactic successful?")
				addCommsReply("We didn't try",function()
					setCommsMessage("Why did you not try garnering help from friendly warships?")
					addCommsReply("We missed your message advising us of this tactic",function()
						setCommsMessage("Understood. You should try taking advantage of friendly warships. If that does not work, come back and we can discuss further.")
						addCommsReply("Back",commsStation)
					end)
					addCommsReply("We felt we could do it without help",function()
						setCommsMessage("That is, of course, your decision. We recommend you take advantage of the help available through friendly warships. Feel free to come back a discuss further if desired.")
						addCommsReply("Back",commsStation)
					end)
					addCommsReply("We ran out of time",function()
						setCommsMessage("Sounds like you ran out of patience. Your mission does not include a time limit. I know that the friendly ships move slowly, but they are available to help through waypoints or direct assistance. We can talk more if you need more tactical advice.")
						addCommsReply("Back",commsStation)
					end)
					addCommsReply("Back",commsStation)
				end)
				addCommsReply("Yes, we will continue with this tactic",function()
					setCommsMessage("Very good. We wish you the best of luck. Return here to discuss options if you change your mind.")
					addCommsReply("Back",commsStation)
				end)
				addCommsReply("We've had some success and want to try some more",function()
					setCommsMessage("That's good to hear. Should you wish to try something else, come back and we can talk about it.")
					addCommsReply("Back",commsStation)
				end)
				addCommsReply("It started well, but now it's not working",commsDiscussInfiltrate)
				addCommsReply("No. We would like to know of any alternative",commsDiscussInfiltrate)
				addCommsReply("Back",commsStation)
			end)
		end
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
			ordMsg = primary_orders .. "\n" .. secondary_orders .. optional_orders
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
function commsDiscussInfiltrate()
	setCommsMessage("We have an alternative plan that involves you sneaking in disguised as a freighter to disable a corridor of their defensive fields. Interested?")
	addCommsReply("No, that's too risky",function()
		setCommsMessage("Your choice. We can talk further if you change your mind.")
		addCommsReply("Back",commsStation)
	end)
	addCommsReply("Sounds interesting. Do you have more details?",function()
		setCommsMessage("Certainly. We would change your Identify Friend or Foe (IFF) module to show that your ship is Independent rather than part of the Human Navy. We would deactivate your weapons and load a computer virus into your docking systems. We would put cargo in your hold that we know the Kraylors need. Once you dock with the Kraylor fortress, you would activate the virus.")
		addCommsReply("Isn't it impossible to hack an IFF?",function()
			setCommsMessage(string.format("Normal systems engineers with normal equipment certainly cannot hack an IFF. Even genius systems programmers without access to high powered computer systems could not. However, we've created an IFF that should broadcast an Independent signal for approximately %i minutes",max_iff_time))
			addCommsReply(string.format("I'm not convinced. No sneaky path for %s",comms_source:getCallSign()),function()
				setCommsMessage("Understood. Continue your mission as originally planned.")
				addCommsReply("Back",commsStation)
			end)
			addCommsReply("We're ready for the changes",commsDisguiseShip)
			addCommsReply("Back",commsStation)
		end)
		addCommsReply("Are there any Kraylor security procedures we should know about?",function()
			setCommsMessage("We only have reports gathered from other Independent freighters. Sometimes the Kraylor just ask questions over comms, sometimes they stop the freighter, sometimes they ask the freighter to dock at a security station before docking at the main station. There were a very small percentage of freighters that went missing after a delivery. The Kraylor need goods and services just like the rest of us, so they are not likely to risk their supplies with security that's too harsh or paranoid. We believe that the risk is quite low if you follow any reasonable security requests made by the Kraylor.")
			addCommsReply("That still sounds too risky for us",function()
				setCommsMessage("Your hesitancy is understandable. Continue with your mission with your current resources. We can reopen the discussion if you change your mind.")
				addCommsReply("Back",commsStation)
			end)
			addCommsReply("We're ready for the changes",commsDisguiseShip)
			addCommsReply("Back",commsStation)
		end)
		addCommsReply("Won't our warp drive give us away?",function()
			setCommsMessage("Most sensors cannot distinguish between a warp drive and a jump drive. Many freighters have jump drives, but they don't use them unless they are in a hurry. We recommend you not use the warp drive to approach the Kraylor.")
			addCommsReply("We could get a competent Kraylor sensor operator. It's too risky",function()
				setCommsMessage("It's definitely a risk. We respect your decision. Good luck with your mission")
				addCommsReply("Back",commsStation)
			end)
			addCommsReply("We will risk it. Please make the changes",commsDisguiseShip)
			addCommsReply("Back",commsStation)
		end)
		addCommsReply("Trusting a hacked IFF is too much. We'll pass.",function()
			setCommsMessage("Acknowledged. We are here if you change your mind.")
			addCommsReply("Back",commsStation)
		end)
		addCommsReply("I'd feel too naked without weapons. No can do",function()
			setCommsMessage("You could reactivate your weapons in an emergency, but that would likely clue the Kraylor that you're not just a freighter")
			addCommsReply("Still too much risk, in my opinion",function()
				setCommsMessage("Your concerns are noted. We can talk again if you change your mind")
				addCommsReply("Back",commsStation)
			end)
			addCommsReply("In that case, set us up. We're ready",commsDisguiseShip)
			addCommsReply("Back",commsStation)
		end)
		addCommsReply("We're ready for the changes",commsDisguiseShip)
		addCommsReply("Back",commsStation)
	end)
	addCommsReply("We are ready for the disguise",commsDisguiseShip)
	addCommsReply("Back",commsStation)
end
function commsDisguiseShip()
	if comms_source:getFaction() == "Human Navy" then
		comms_source:setFaction("Independent")
		toggleWeapons()
		if comms_source.goods == nil then
			comms_source.goods = {}
		end
		kraylor_good = "platinum"
		local cargo_type = "has been loaded"
		if comms_source.cargo == 0 then
			for good, quantity in pairs(comms_source.goods) do
				kraylor_good = good
			end
			cargo_type "was already aboard"
		else
			comms_source.cargo = comms_source.cargo - 1
			if comms_source.goods["platinum"] == nil then
				comms_source.goods["platinum"] = 0
			end
			comms_source.goods["platinum"] = comms_source.goods["platinum"] + 1
		end
		comms_source.enable_weapons = "enable_weapons"
		comms_source.enable_weapons_tac = "enable_weapons_tac"
		comms_source.enable_weapons_one = "enable_weapons_one"
		comms_source:addCustomButton("Weapons",comms_source.enable_weapons,"Enable Weapons",function()
			string.format("")
			toggleWeapons()
			comms_source:removeCustom(comms_source.enable_weapons)
			comms_source:removeCustom(comms_source.enable_weapons_tac)
			comms_source:removeCustom(comms_source.enable_weapons_one)
		end)
		comms_source:addCustomButton("Tactical",comms_source.enable_weapons_tac,"Enable Weapons",function()
			string.format("")
			toggleWeapons()
			comms_source:removeCustom(comms_source.enable_weapons_one)
			comms_source:removeCustom(comms_source.enable_weapons_tac)
			comms_source:removeCustom(comms_source.enable_weapons)
		end)
		comms_source:addCustomButton("Single",comms_source.enable_weapons_one,"Enable Weapons",function()
			string.format("")
			toggleWeapons()
			comms_source:removeCustom(comms_source.enable_weapons_one)
			comms_source:removeCustom(comms_source.enable_weapons_tac)
			comms_source:removeCustom(comms_source.enable_weapons)
		end)
		iff_timer = max_iff_time * 60
		plotInfiltrate = coverCheck
		setCommsMessage(string.format("Your IFF is programmed to read Independent, your weapons are disguised and disabled, and the Kraylor cargo, %s, %s. Good luck",kraylor_good,cargo_type))
	else	--used for testing
		comms_source:setFaction("Human Navy")
		toggleWeapons()
		setCommsMessage("Weapons reset")
	end
end
function setSecondaryOrders()
	secondary_orders = ""
	if defense_platform_count ~= nil then
		secondary_orders = "Direct freighter to deploy defense platform"
	end
	if platform_deployed then
		secondary_orders = "Destroy source of Kraylor fighters"
	end
end
function setOptionalOrders()
	optional_orders = ""
	if platform_deployed then
		local p = getPlayerShip(-1)
		if not p:hasWarpDrive() then
			optional_orders = string.format("\nOptional: Dock with %s to install warp drive",primary_human_station:getCallSign())
		elseif zone_reveal_count >= 5 then
			if comms_source:getFaction() == "Human Navy" then
				optional_orders = string.format("\nOptional: Dock with %s to discuss alternative plan",primary_human_station:getCallSign())
			end
		end
	end
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
    if comms_source:isFriendly(comms_target) then
        oMsg = "Good day, officer.\nIf you need supplies, please dock with us first."
    else
        oMsg = "Greetings.\nIf you want to do business, please dock with us first."
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you."
	end
	setCommsMessage(oMsg)
 	addCommsReply("I need information", function()
		setCommsMessage("What kind of information do you need?")
		if zone_reveal_count > 1 then
			addCommsReply("Report on Kraylor defensive fields",function()
				setCommsMessage("Report has been added to the ship log")
				for r=0,5 do
					for _, zone in ipairs(region[r].zones) do
						if zone:isValid() then
							if zone.revealed then
								comms_source:addToShipLog(string.format("   %s: %s",zone.name,zone.ship_impact),string.format("%i,%i,%i",fort_zone_color[zone.name].r,fort_zone_color[zone.name].g,fort_zone_color[zone.name].b))
							end
						end
					end
				end
			end)
		end
		addCommsReply("What are my current orders?", function()
			setOptionalOrders()
			setSecondaryOrders()
			ordMsg = primary_orders .. "\n" .. secondary_orders .. optional_orders
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
	if comms_target == primary_human_station then
		if defense_platform_count ~= nil and defense_platform_count > 0 then
			addCommsReply("Deploy defense platform", function()
				if comms_source:getWaypointCount() < 1 then
					setCommsMessage("You need to set a waypoint to identify the location where the defense platform should be built")
				else
					setCommsMessage("Specify the waypoint where the defense platform should be built")
					for n=1,comms_source:getWaypointCount() do
						addCommsReply(string.format("Waypoint %i",n), function()
							local freighter_x, freighter_y = comms_target:getPosition()
							local target_x, target_y = comms_source:getWaypoint(n)
							local script = Script()
							script:setVariable("freighter_x", freighter_x):setVariable("freighter_y", freighter_y)
							script:setVariable("target_x", target_x):setVariable("target_y", target_y)
							script:setVariable("faction_id", comms_target:getFactionId()):run("platform_drop.lua")
							setCommsMessage(string.format("We have sent a freighter towards waypoint %i",n))
							defense_platform_count = defense_platform_count - 1
							if deployed_platform_positions == nil then
								deployed_platform_positions = {}
								platform_deployed = false
							end
							table.insert(deployed_platform_positions,{x=target_x,y=target_y})
							deployPlatformPlot = checkPlatformDeployed
							addCommsReply("Back", commsStation)
						end)
					end
				end
				addCommsReply("Back", commsStation)
			end)
		end
	end
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
						if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
							ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setCallSign(generateCallSign(nil,"Human Navy")):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
							ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(friendlyVesselDestroyed)
							setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to assist at WP" .. n);
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
			setCommsMessage("Sorry, we have no time to chat with you.\nWe are busy.");
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
	    end
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
			local ax = x + math.cos(radialPoint / 180 * math.pi) * pointDist
			local ay = y + math.sin(radialPoint / 180 * math.pi) * pointDist
			if farEnough(ax, ay, asteroid_size) then
				local ta = Asteroid():setPosition(ax, ay):setSize(asteroid_size)
		        table.insert(place_space,{obj=ta,dist=asteroid_size})
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
function friendlyVesselDestroyed(self, instigator)
	string.format("")
	--[[
	tempShipType = self:getTypeName()
	table.insert(friendlyVesselDestroyedNameList,self:getCallSign())
	table.insert(friendlyVesselDestroyedType,tempShipType)
	table.insert(friendlyVesselDestroyedValue,ship_template[tempShipType].strength)
	--]]
end
function enemyVesselDestroyed(self, instigator)
	local player = getPlayerShip(-1)
	if player ~= nil and player:isValid() then
		player:addReputationPoints(1)
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
------------------------
--	Update functions  --
------------------------
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
			updatePlayerLongRangeSensors(p)
		end
	end
	if plotFortZone ~= nil then
		plotFortZone(delta)
	end
	if stalkerPatrolPlot ~= nil then
		stalkerPatrolPlot(delta)
	end
	if plotKraylorFighters ~= nil then
		plotKraylorFighters(delta)
	end
	if primaryDefensePlot ~= nil then
		primaryDefensePlot(delta)
	end
	if deployPlatformPlot ~= nil then
		deployPlatformPlot(delta)
	end
	if plotInfiltrate ~= nil then
		plotInfiltrate(delta)
	end
	if inspectionPlot ~= nil then
		inspectionPlot(delta)
	end
	if virusPlot ~= nil then
		virusPlot(delta)
	end
	if cargoPlot ~= nil then
		cargoPlot(delta)
	end
	if transportPlot ~= nil then
		transportPlot(delta)
	end
	if plotCI ~= nil then	--cargo inventory
		plotCI(delta)
	end
	if plotH ~= nil then	--health
		plotH(delta)
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

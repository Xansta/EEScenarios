-- Name: Dodge
-- Description: Single player ship of type Repulse. Suggest Science and Relay vs. Operations due to Relay's view. Goal: save as many as possible. Limited bases. Diverse factions
--- 
--- Designed to be short, challenging and different each time. Players scored between 0 and 100 based on how many survivors and their faction: friendlies are worth more than neutrals which are worth more than enemies. Score determines final rank: Admirals score > 90. Cadets score <= 30.
---
--- Duration: 30 minutes
---
--- Version 0
-- Type: Replayable Mission
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
-- Setting[Sensor Jammer Range]: Configure the upper limit of the range of the sensor jammers. The shorter, the easier
-- Sensor Jammer Range[Short]: Sensor jammers have short range
-- Sensor Jammer Range[Medium|Default]: Sensor jammers have medium range
-- Sensor Jammer Range[Long]: Sensor jammers have long range
-- Setting[Sensor Jammer Strength]: Configure the upper limit of the strength of the sensor jammers. The weaker, the easier
-- Sensor Jammer Strength[Weak]: Sensor jammers are weak
-- Sensor Jammer Strength[Normal|Default]: Sensor jammers have average strength
-- Sensor Jammer Strength[Strong]: Sensor jammers are strong
-- Setting[Scan Defense]: Configure the upper limit of Science's scan difficulty of artifacts in the scenario. The higher, the harder
-- Scan Defense[Easy]: Easy artifact scans
-- Scan Defense[Simple]: Simple artifact scans
-- Scan Defense[Normal|Default]: Normal artifact scans
-- Scan Defense[Tricky]: Tricky artifact scans
-- Scan Defense[Hard]: Hard artifact scans
-- Scan Defense[Difficult]: Difficult artifact scans
-- Scan Defense[Challenging]: Challenging artifact scans

--	Environment exists roughly along a line
--	One base per faction in the environment
--	All factions patrol the line
--	Disaster approaches from a perpendicular location

--	Improvement ideas:
--	Service jonques to repair ship (in progress)
--	Timer for end of game after black holes appear
--	Brain game for weapons

require("utils.lua")
require("place_station_scenario_utility.lua")
--	also uses supply_drop.lua

--------------------
-- Initialization --
--------------------
function init()
	scenario_version = "0.2.1"
	print(string.format("     -----     Scenario: Dodge     -----     Version %s     -----",scenario_version))
	print(_VERSION)
	patrol_maintenance_diagnostic = false
	expedition_maintenance_diagnostic = false
	task_maintenance_diagnostic = false
	spawn_enemy_diagnostic = false
	setVariations()
	setConstants()	--missle type names, template names and scores, deployment directions, player ship names, etc.
	constructEnvironment()
	mainGMButtons()
end
function setPlayer(p)
	if p == nil then
		return
	end
	p:setTemplate("Repulse")
	p:setImpulseMaxSpeed(70)				-- up from default of 55
	p:setHullMax(170 - (difficulty*20))		-- stronger hull (vs 120)
	p:setHull(170 - (difficulty*20))
	p:addReputationPoints(70 - (difficulty*20))
	p.impulse_upgrade = 0
	p.shield_upgrade = 0
	p.tube_speed_upgrade = 0
	p.goods = {}
	p.maxRepairCrew = p:getRepairCrewCount()
	p.shipScore = playerShipStats["Repulse"].strength 
	p.maxCargo = playerShipStats["Repulse"].cargo
	p:setLongRangeRadarRange(playerShipStats["Repulse"].long_range_radar)
	p:setShortRangeRadarRange(playerShipStats["Repulse"].short_range_radar)
	p.normal_long_range_radar = p:getLongRangeRadarRange()
	p.tractor = playerShipStats["Repulse"].tractor
	p.mining = playerShipStats["Repulse"].mining
	local name = tableRemoveRandom(player_ship_names)
	if name ~= nil then
		p:setCallSign(name)
	end
	p.residents = {
		["friend"] = 0,
		["neutral"] = 0,
		["enemy"] = 0,
	}
	p.resident_capacity = 30
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
	p:onDestroyed(playerDestroyed)
end
function setVariations()
	if getScenarioSetting == nil then
		difficulty = 1
		adverseEffect = .995
		coolant_loss = .99995
		coolant_gain = .001
		starting_rep = 20
		enemy_power = 1
		sensor_jammer_upper_strength = 25000
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
		adverseEffect =	murphy_config[getScenarioSetting("Murphy")].adverse
		coolant_loss =	murphy_config[getScenarioSetting("Murphy")].lose_coolant
		coolant_gain =	murphy_config[getScenarioSetting("Murphy")].gain_coolant
		starting_rep =	murphy_config[getScenarioSetting("Murphy")].rep
		local sensor_jammer_range_config = {
			["Short"] =		30000,
			["Medium"] =	40000,
			["Long"] =		50000,
		}
		sensor_jammer_upper_range = sensor_jammer_range_config[getScenarioSetting("Sensor Jammer Range")]
		local sensor_jammer_strength_config = {
			["Weak"] =		20000,
			["Normal"] = 	25000,
			["Strong"] =	30000,
		}
		sensor_jammer_upper_strength = sensor_jammer_strength_config[getScenarioSetting("Sensor Jammer Strength")]
		artifact_scan_config = {
			["Easy"] = 			4,
			["Simple"] =		5,
			["Normal"] =		6,
			["Tricky"] =		7,
			["Hard"] =			8,
			["Difficult"] =		9,
			["Challenging"] =	10,
		}
		artifact_scan_upper_limit = artifact_scan_config[getScenarioSetting("Scan Defense")]
	end
end
function setConstants()
	distance_diagnostic = false
	stationCommsDiagnostic = false
	change_enemy_order_diagnostic = false
	healthDiagnostic = false
	sensor_jammer_diagnostic = false
	max_repeat_loop = 100
	local c_x, c_y = vectorFromAngleNorth(random(0,360),random(0,60000))
	center_x = 909000 + c_x
	center_y = 151000 + c_y
	primary_orders = _("orders-comms","Protect and save the civilian population who live on space stations.")
	plotCI = cargoInventory
	plotH = healthCheck				--Damage to ship can kill repair crew members
	healthCheckTimerInterval = 8
	healthCheckTimer = healthCheckTimerInterval
	maintenance_timer_interval = 7
	maintenance_timer = maintenance_timer_interval
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
		"Fiddler",
		"Brinks",
		"Loomis",
		"Mowag",
		"Patria",
		"Pandur",
		"Terrex",
		"Komatsu",
		"Eitan",
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
		["Nirvana R3"] =		{strength = 12,		create = stockTemplate},
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
	fly_formation = {
		["V"] =		{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
					},
		["Vac"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
					},
		["V4"] =	{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 60	, dist = 2	},
						{angle = 300, dist = 2	},
					},
		["Vac4"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 30	, dist = 2	},
						{angle = 330, dist = 2	},
					},
		["A"] =		{
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
					},
		["Aac"] =	{
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
					},
		["A4"] =	{
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 120, dist = 2	},
						{angle = 240, dist = 2	},
					},
		["Aac4"] =	{
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 150, dist = 2	},
						{angle = 210, dist = 2	},
					},
		["/"] =		{
						{angle = 60	, dist = 1	},
						{angle = 240, dist = 1	},
					},
		["-"] =		{
						{angle = 90	, dist = 1	},
						{angle = 270, dist = 1	},
					},
		["-4"] =		{
						{angle = 90	, dist = 1	},
						{angle = 270, dist = 1	},
						{angle = 90	, dist = 2	},
						{angle = 270, dist = 2	},
					},
		["\\"] =	{
						{angle = 300, dist = 1	},
						{angle = 120, dist = 1	},
					},
		["|"] =		{
						{angle = 0	, dist = 1	},
						{angle = 180, dist = 1	},
					},
		["|4"] =	{
						{angle = 0	, dist = 1	},
						{angle = 180, dist = 1	},
						{angle = 0	, dist = 2	},
						{angle = 180, dist = 2	},
					},
		["/ac"] =	{
						{angle = 30	, dist = 1	},
						{angle = 210, dist = 1	},
					},
		["\\ac"] =	{
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
					},
		["M"] =		{
						{angle = 60	, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 270, dist = 1	},
					},
		["Mac"] =	{
						{angle = 30	, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 270, dist = 1	},
					},
		["M6"] =	{
						{angle = 60	, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 270, dist = 1	},
						{angle = 120, dist = 1.3},
						{angle = 240, dist = 1.3},
					},
		["Mac6"] =	{
						{angle = 30	, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 270, dist = 1	},
						{angle = 125, dist = 1.7},
						{angle = 235, dist = 1.7},
					},
		["W"] =		{
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 270, dist = 1	},
					},
		["Wac"] =	{
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 270, dist = 1	},
					},
		["W6"] =	{
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 270, dist = 1	},
						{angle = 60	, dist = 1.3},
						{angle = 300, dist = 1.3},
					},
		["Wac6"] =	{
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 270, dist = 1	},
						{angle = 55	, dist = 1.7},
						{angle = 295, dist = 1.7},
					},
		["X"] =		{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
					},
		["Xac"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
					},
		["X8"] =	{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 60	, dist = 2	},
						{angle = 300, dist = 2	},
						{angle = 120, dist = 2	},
						{angle = 240, dist = 2	},
					},
		["Xac8"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 30	, dist = 2	},
						{angle = 330, dist = 2	},
						{angle = 150, dist = 2	},
						{angle = 210, dist = 2	},
					},
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
	sensor_jammer_power_units = true	--false means percentage, true is units
end
function environmentObject(ref_x, ref_y, dist, axis)
	if ref_x == nil or ref_y == nil or dist == nil then
		print("function environmentObject expects ref_x, ref_y and dist to be provided")
		return
	end
	if axis == nil then
		local axis_choice = {"gross","invert"}
		axis = axis_choice[math.random(1,#axis_choice)]
	end
	local forward_angle = gross_angle
	local backward_angle = invert_angle
	local forward_angle_start = gross_angle_start
	local backward_angle_start = invert_angle_start
	if axis ~= "gross" then
		forward_angle = invert_angle
		backward_angle = gross_angle
		forward_angle_start = invert_angle_start
		backward_angle_start = gross_angle_start
	end
	local count_repeat_loop = 0
	repeat
		local o_x, o_y = vectorFromAngleNorth((random(forward_angle_start,forward_angle_start+place_arc))%360,random(lower_bound,upper_bound))
		if random(1,100) > axis_bias then
			o_x, o_y = vectorFromAngleNorth((random(backward_angle_start,backward_angle_start+place_arc))%360,random(lower_bound,upper_bound))
		end
		ref_x = ref_x + o_x
		ref_y = ref_y + o_y
		count_repeat_loop = count_repeat_loop + 1
	until(farEnough(ref_x,ref_y,dist) or count_repeat_loop > max_repeat_loop)
	if count_repeat_loop > max_repeat_loop then
		print("repeated too many times when trying to get far enough away")
		print("last ref_x:",ref_x,"last ref_y:",ref_y)
		return nil
	else
		return ref_x, ref_y
	end
end
function constructEnvironment()
	safety_x = 0
	safety_y = 0
	black_hole_milestone = 600	--final: 600, test: 140
	place_space = {}
	transport_stations = {}
--	Spawn player
	local p = PlayerSpaceship():setTemplate("Repulse")
	p:onTakingDamage(playerDamage)
	p.pidx = 1
	setPlayer(p)
	p:setPosition(center_x, center_y)
	allowNewPlayerShips(false)
	table.insert(place_space,{obj=p,dist=100,shape="circle"})
--	Determine angles
	gross_angle = random(0,360)
	invert_angle = (gross_angle + 180) % 360
	place_arc = 50
	gross_angle_start = gross_angle - place_arc/2
	if gross_angle_start < 0 then
		gross_angle_start = gross_angle_start + 360
	end
	invert_angle_start = invert_angle - place_arc/2
	if invert_angle_start < 0 then
		invert_angle_start = invert_angle_start + 360
	end
	lower_bound = 10000
	upper_bound = 50000
	axis_bias = 61
--	Add stars and planets
	local star_list = {
		{radius = random(600,1400), distance = random(-2500,-1400), 
			name = {"Gamma Piscium","Beta Lyporis","Sigma Draconis","Iota Carinae","Theta Arietis","Epsilon Indi","Beta Hydri"},
			color = {
				red = random(0.8,1), green = random(0.8,1), blue = random(0.8,1)
			},
			texture = {
				atmosphere = "planets/star-1.png"
			},
		},
	}
	local planet_list = {
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
	local eo_x, eo_y = environmentObject(center_x, center_y, star_list[1].radius + 1000, "gross")
	local the_sun = Planet():setPosition(eo_x, eo_y):setPlanetRadius(star_list[1].radius):setDistanceFromMovementPlane(star_list[1].distance)
	the_sun:setCallSign(star_list[1].name[math.random(1,#star_list[1].name)])
	the_sun:setPlanetAtmosphereTexture(star_list[1].texture.atmosphere):setPlanetAtmosphereColor(star_list[1].color.red,star_list[1].color.green,star_list[1].color.blue)
	table.insert(place_space,{obj=the_sun,dist=star_list[1].radius + 1000,shape="circle"})
	local inner_orbit = 0
	local outer_orbit = 0
	local p2p_dist = distance(p,the_sun)
	local selected_planet_index = math.random(1,#planet_list)
	local count_repeat_loop = 0
	repeat
		inner_orbit = random(10000,50000)
		outer_orbit = inner_orbit + (planet_list[selected_planet_index].radius * 2) + 1000
		count_repeat_loop = count_repeat_loop + 1
	until(p2p_dist < inner_orbit or p2p_dist > outer_orbit or count_repeat_loop > max_repeat_loop)
	if count_repeat_loop > max_repeat_loop then
		print("repeated too many times when trying to determine an inner and outer orbit")
		print("last inner orbit:",inner_orbit,"last outer orbit:",outer_orbit,"selected planet index:",selected_planet_index,"radius:",planet_list[selected_planet_index].radius)
	end
	local planet_x, planet_y = vectorFromAngleNorth(gross_angle,inner_orbit + planet_list[selected_planet_index].radius + 500)
	planet_x = planet_x + eo_x
	planet_y = planet_y + eo_y
	local planet = Planet():setPosition(planet_x, planet_y):setPlanetRadius(planet_list[selected_planet_index].radius):setDistanceFromMovementPlane(planet_list[selected_planet_index].distance)
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
--	planet:setOrbit(the_sun,(60000-inner_orbit)/50)
	planet:setOrbit(the_sun,math.pi*2*inner_orbit/250)
	table.insert(place_space,{obj=the_sun,inner_orbit = inner_orbit, outer_orbit = outer_orbit, shape="toroid"})
--	Set up for terrain feature creation loop
	local station_faction = {"Human Navy","Independent","Kraylor","Arlenians","Exuari","Ghosts","Ktlitans","TSN","USN","CUF"}
	local bus_faction = {"Human Navy","Independent","Kraylor","Arlenians","Exuari","Ghosts","Ktlitans","TSN","USN","CUF"}
	station_list = {}
	residents = {
		["friend"] = 0,
		["neutral"] = 0,
		["enemy"] = 0,
	}
	bus_list = {}
	transport_list = {}
	local black_hole_chance = 1
	black_hole_count = math.random(1,6)
	local probe_chance = 6
	local warp_jammer_chance = 3
	local worm_hole_chance = 2
	worm_hole_count = math.random(1,4)
	local sensor_jammer_chance = 6
	local sensor_buoy_chance = 6
	local ad_buoy_chance = 8
	local nebula_chance = 5
	local mine_chance = 4
	local station_chance = 3
	local bus_chance = 3
	local mine_field_chance = 4
	mine_field_count = math.random(3,8)
	local asteroid_field_chance = 4
	asteroid_field_count = math.random(2,6)
	local transport_chance = 7
	repeat
		local current_object_chance = 0
		local object_roll = random(0,100)
		current_object_chance = current_object_chance + black_hole_chance
		if object_roll <= current_object_chance then
			placeBlackHole()
			goto iterate
		end
		current_object_chance = current_object_chance + probe_chance
		if object_roll <= current_object_chance then
			placeProbe()
			goto iterate
		end
		current_object_chance = current_object_chance + warp_jammer_chance
		if object_roll <= current_object_chance then
			placeWarpJammer()
			goto iterate
		end
		current_object_chance = current_object_chance + worm_hole_chance
		if object_roll <= current_object_chance then
			placeWormHole()
			goto iterate
		end
		current_object_chance = current_object_chance + sensor_jammer_chance
		if object_roll <= current_object_chance then
			placeSensorJammer()
			goto iterate
		end
		current_object_chance = current_object_chance + sensor_buoy_chance
		if object_roll <= current_object_chance then
			placeSensorBuoy()
			goto iterate
		end
		current_object_chance = current_object_chance + ad_buoy_chance
		if object_roll <= current_object_chance then
			placeAdBuoy()
			goto iterate
		end
		current_object_chance = current_object_chance + nebula_chance
		if object_roll <= current_object_chance then
			placeNebula()
			goto iterate
		end
		current_object_chance = current_object_chance + mine_chance
		if object_roll <= current_object_chance then
			placeMine()
			goto iterate
		end
		current_object_chance = current_object_chance + station_chance
		if object_roll <= current_object_chance then
			if #station_faction > 0 then
				placeEnvironmentStation(tableRemoveRandom(station_faction))
			else
				placeAsteroid()
			end
			goto iterate
		end
		current_object_chance = current_object_chance + bus_chance
		if object_roll <= current_object_chance then
			if #bus_faction > 0 then
				placeBus(tableRemoveRandom(bus_faction))
			else
				placeAsteroid()
			end
			goto iterate
		end
		current_object_chance = current_object_chance + mine_field_chance
		if object_roll <= current_object_chance then
			placeMineField()
			goto iterate
		end
		current_object_chance = current_object_chance + asteroid_field_chance
		if object_roll <= current_object_chance then
			placeAsteroidField()
			goto iterate
		end
		current_object_chance = current_object_chance + transport_chance
		if object_roll <= current_object_chance then
			placeTransport()
			goto iterate
		end
		placeAsteroid()
		::iterate::
	until((#station_faction < 1 and #bus_faction < 1))
	maintenancePlot = defenseMaintenance
	taxi_missions = {}
	local taxi_stations = {}
	for _, station in ipairs(station_list) do
		if station:isFriendly(p) or not station:isEnemy(p) then
			table.insert(taxi_stations,station)
		end
	end
	local jump_charge_count = 0
	local jump_charge_candidate_stations = {}
	local combat_maneuver_count = 0
	local combat_maneuver_fix_candidate_stations = {}
	for _, station in ipairs(station_list) do
		if station:isFriendly(p) or not station:isEnemy(p) then
			if station.comms_data ~= nil then
				if station.comms_data.jump_overcharge then
					jump_charge_count = jump_charge_count + 1
				else
					table.insert(jump_charge_candidate_stations,station)
				end
				if station.comms_data.combat_maneuver_repair then
					combat_maneuver_count = combat_maneuver_count + 1
				else
					table.insert(combat_maneuver_fix_candidate_stations,station)
				end
			else
				table.insert(jump_charge_candidate_stations,station)
				table.insert(combat_maneuver_fix_candidate_stations,station)
			end
		end
	end
	if jump_charge_count < 3 then
		for i=1,3-jump_charge_count do
			local station = tableRemoveRandom(jump_charge_candidate_stations)
			if station.comms_data == nil then
				station.comms_data = {
			        friendlyness = random(0.0, 100.0)
			    }
			end
			station.comms_data.jump_overcharge = true
		end
	end
	if combat_maneuver_count < 3 then
		for i=1,3-combat_maneuver_count do
			local station = tableRemoveRandom(combat_maneuver_fix_candidate_stations)
			if station.comms_data == nil then
				station.comms_data = {
			        friendlyness = random(0.0, 100.0)
			    }
			end
			station.comms_data.combat_maneuver_repair = true
			if station.comms_data.service_cost == nil then
				station.comms_data.service_cost = {}
			end
			station.comms_data.service_cost.combat_maneuver_repair = math.random(5,10)
		end
	end
	for i=1,10 do
		if #taxi_stations < 1 then
			for _, station in ipairs(station_list) do
				if station:isFriendly(p) or not station:isEnemy(p) then
					table.insert(taxi_stations,station)
				end
			end
		end
		local origin_station = tableRemoveRandom(taxi_stations)
		if #taxi_stations < 1 then
			for _, station in ipairs(station_list) do
				if station:isFriendly(p) or not station:isEnemy(p) then
					table.insert(taxi_stations,station)
				end
			end
		end
		local destination_station = tableRemoveRandom(taxi_stations)
		local taxi_distance = distance(origin_station,destination_station)
		local passenger_count = math.random(1,3)*5
		local passenger_importance = 0
		local passenger_description = ""
		if origin_station:isFriendly(destination_station) then
			passenger_importance = 1
			local desc_list = {
				_("goal-comms","a group of friends"),
				_("goal-comms","a family"),
			}
			passenger_description = desc_list[math.random(1,#desc_list)]
		elseif origin_station:isEnemy(destination_station) then
			passenger_importance = 3
			passenger_description = _("goal-comms","a diplomatic delegation")
		else
			passenger_importance = 2
			passenger_description = _("goal-comms","some businessmen")
		end
		local reputation_payoff = math.floor(taxi_distance/1000*passenger_count/2*passenger_importance/difficulty)
		local mission_description = string.format(_("goal-comms","Transport %s (%i passengers) from %s station %s in %s to %s station %s in %s (%i units) for %i reputation."),passenger_description,passenger_count,origin_station:getFaction(),origin_station:getCallSign(),origin_station:getSectorName(),destination_station:getFaction(),destination_station:getCallSign(),destination_station:getSectorName(),math.floor(taxi_distance/1000),reputation_payoff)
		if #taxi_missions > 0 then
			local match = false
			for _, mission in ipairs(taxi_missions) do
				if mission.origin == origin_station and mission.destination == destination_station and mission.count == passenger_count then
					match = true
					break
				end
			end
			if not match then
				table.insert(taxi_missions,{desc=mission_description,origin=origin_station,destination=destination_station,count=passenger_count,payoff=reputation_payoff})
			end
		else
			table.insert(taxi_missions,{desc=mission_description,origin=origin_station,destination=destination_station,count=passenger_count,payoff=reputation_payoff})
		end
	end
end
function placeBlackHole()
	if black_hole_count > 0 then
		local eo_x, eo_y = environmentObject(center_x, center_y, 6000)
		local bh = BlackHole():setPosition(eo_x, eo_y)
		table.insert(place_space,{obj=bh,dist=6000,shape="circle"})
		black_hole_count = black_hole_count - 1
	else
		placeAsteroid()
	end
end
function placeProbe()
	if #station_list < 1 then
		placeAsteroid()
	else
		local eo_x, eo_y = environmentObject(center_x, center_y, 200)
		local sp = ScanProbe():setPosition(eo_x, eo_y)
		local owner = station_list[math.random(1,#station_list)]
		sp:setLifetime(30*60):setOwner(owner):setTarget(eo_x,eo_y)
		table.insert(place_space,{obj=sp,dist=200,shape="circle"})
	end
end
function placeWarpJammer()
	if warp_jammer_info == nil then
		warp_jammer_list = {}
		warp_jammer_info = {
			["Human Navy"] =	{id = "H", count = 0},
			["Independent"] =	{id = "I", count = 0},
			["Kraylor"] =		{id = "K", count = 0},
			["Arlenians"] =		{id = "A", count = 0},
			["Exuari"] =		{id = "E", count = 0},
			["Ghosts"] =		{id = "G", count = 0},
			["Ktlitans"] =		{id = "B", count = 0},
			["TSN"] =			{id = "T", count = 0},
			["USN"] =			{id = "U", count = 0},
			["CUF"] =			{id = "C", count = 0},
		}
	end
	local eo_x, eo_y = environmentObject(center_x, center_y, 200)
	local wj = WarpJammer():setPosition(eo_x, eo_y)
	local wj_faction = {"Human Navy","Independent","Kraylor","Arlenians","Exuari","Ghosts","Ktlitans","TSN","USN","CUF"}
	local selected_faction = wj_faction[math.random(1,#wj_faction)]
	local wj_range = random(5000,20000)
	wj:setRange(wj_range):setFaction(selected_faction)
	warp_jammer_info[selected_faction].count = warp_jammer_info[selected_faction].count + 1
	wj:setCallSign(string.format("%sWJ%i",warp_jammer_info[selected_faction].id,warp_jammer_info[selected_faction].count))
	wj.range = wj_range
	table.insert(warp_jammer_list,wj)
	table.insert(place_space,{obj=wj,dist=200,shape="circle"})
end
function placeWormHole()
	if worm_hole_count > 0 then
		local eo_x, eo_y = environmentObject(center_x, center_y, 6000)
		local we_x, we_y = environmentObject(center_x, center_y, 500)
		local count_repeat_loop = 0
		repeat
			we_x, we_y = environmentObject(center_x, center_y, 500)
			count_repeat_loop = count_repeat_loop + 1
		until(distance(eo_x, eo_y, we_x, we_y) > 50000 or count_repeat_loop > max_repeat_loop)
		if count_repeat_loop > max_repeat_loop then
			print("repeated too many times while placing a wormhole")
			print("eo_x:",eo_x,"eo_y:",eo_y,"we_x:",we_x,"we_y:",we_y)
		end
		local wh = WormHole():setPosition(eo_x, eo_y):setTargetPosition(we_x, we_y)
		table.insert(place_space,{obj=wh,dist=6000,shape="circle"})
		table.insert(place_space,{dist=500,ps_x=we_x,ps_y=we_y,shape="circle"})
		worm_hole_count = worm_hole_count - 1
	else
		placeAsteroid()
	end
end
function placeSensorJammer()
	local lo_range = 10000
	local hi_range = sensor_jammer_upper_range
	local lo_impact = 10000
	local hi_impact = sensor_jammer_upper_strength
	local range_increment = (hi_range - lo_range)/8
	local impact_increment = (hi_impact - lo_impact)/4
	local mix = math.random(2,artifact_scan_upper_limit)
	sensor_jammer_scan_complexity = 1 
	sensor_jammer_scan_depth = 1
	if mix > 5 then
		sensor_jammer_scan_depth = math.min(math.random(mix-4,mix),8)
		sensor_jammer_scan_complexity = math.max(mix - sensor_jammer_scan_depth,1)
	else
		sensor_jammer_scan_depth = math.random(1,mix)
		sensor_jammer_scan_complexity = math.max(mix - sensor_jammer_scan_depth,1)
	end
	sensor_jammer_range = lo_range + (sensor_jammer_scan_depth*range_increment)
	sensor_jammer_impact = lo_impact + (sensor_jammer_scan_complexity*impact_increment)
	local eo_x, eo_y = environmentObject(center_x, center_y, 200)
	local sj = sensorJammer(eo_x, eo_y)
	table.insert(place_space,{obj=sj,dist=200,shape="circle"})
end
function placeSensorBuoy()
	local out = ""
	local eo_x, eo_y = environmentObject(center_x, center_y, 200)
	local scan_complexity = 1
	local scan_depth = 1
	local mix = math.random(2,artifact_scan_upper_limit)
	if mix > 5 then
		scan_depth = math.min(math.random(mix-4,mix),8)
		scan_complexity = math.max(mix - scan_depth,1)
	else
		scan_depth = math.random(1,mix)
		scan_complexity = math.max(mix - scan_depth,1)
	end
	local sb = Artifact():setPosition(eo_x, eo_y):setScanningParameters(scan_complexity,scan_depth):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII")
	local buoy_type_list = {}
	local buoy_type = ""
	if #station_list > 0 then
		table.insert(buoy_type_list,"station")
	end
	if #transport_list > 0 then
		table.insert(buoy_type_list,"transport")
	end
	if #bus_list > 0 then
		table.insert(buoy_type_list,"bus")
	end
	if #buoy_type_list > 0 then
		buoy_type = tableRemoveRandom(buoy_type_list)
		if buoy_type == "station" then
			local selected_stations = {}
			for index, station in ipairs(station_list) do
				table.insert(selected_stations,station)
			end
			for i=1,3 do
				if #selected_stations > 0 then
					local station = tableRemoveRandom(selected_stations)
					if out == "" then
						out = string.format(_("scienceDescription-buoy","Sensor Record: %s station in %s"),station:getFaction(),station:getSectorName())
					else
						out = string.format(_("scienceDescription-buoy","%s, %s station in %s"),out,station:getFaction(),station:getSectorName())
					end
				else
					break
				end
			end
		end
		if buoy_type == "transport" then
			local selected_transports = {}
			for _, transport in ipairs(transport_list) do
				table.insert(selected_transports,transport)
			end
			for i=1,3 do
				if #selected_transports > 0 then
					local transport = tableRemoveRandom(selected_transports)
					if transport.comms_data == nil then
						transport.comms_data = {friendlyness = random(0.0, 100.0)}
					end
					if transport.comms_data.goods == nil then
						goodsOnShip(transport,transport.comms_data)
					end
					local goods_carrying = ""
					for good, goodData in pairs(transport.comms_data.goods) do
						if goods_carrying == "" then
							goods_carrying = good
						else
							goods_carrying = string.format("%s, %s",goods_carrying,good)
						end
					end
					if out == "" then
						out = string.format(_("scienceDescription-buoy","Sensor Record: %s %s %s in %s carrying %s"),transport:getFaction(),transport:getTypeName(),transport:getCallSign(),transport:getSectorName(),goods_carrying)
					else
						out = string.format(_("scienceDescription-buoy","%s; %s %s %s in %s carrying %s"),out,transport:getFaction(),transport:getTypeName(),transport:getCallSign(),transport:getSectorName(),goods_carrying)
					end
				else
					break
				end
			end
		end
		if buoy_type == "bus" then
			local selected_bus_list = {}
			for _, bus in ipairs(bus_list) do
				table.insert(selected_bus_list,bus)
			end
			for i=1,3 do
				if #selected_bus_list > 0 then
					local bus = tableRemoveRandom(selected_bus_list)
					if out == "" then
						out = string.format(_("scienceDescription-buoy","Sensor Record: %s %s %s in %s"),bus:getFaction(),bus:getTypeName(),bus:getCallSign(),bus:getSectorName())
					else
						out = string.format(_("scienceDescription-buoy","%s; %s %s %s in %s"),out,bus:getFaction(),bus:getTypeName(),bus:getCallSign(),bus:getSectorName())
					end
				else
					break
				end
			end
		end
	else
		out = _("scienceDescription-buoy","No data recorded")
	end
	sb:setDescriptions(_("scienceDescription-buoy","Automated data gathering device"),out)
	table.insert(place_space,{obj=sb,dist=200,shape="circle"})
end
function placeAdBuoy()
	local eo_x, eo_y = environmentObject(center_x, center_y, 200)
	local scan_complexity = 1
	local scan_depth = 1
	local mix = math.random(2,math.min(artifact_scan_upper_limit,5))
	scan_depth = math.random(1,mix)
	scan_complexity = math.max(mix - scan_depth,1)
	local ab = Artifact():setPosition(eo_x, eo_y):setScanningParameters(scan_complexity,scan_depth):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII")
	local billboards = {
		_("scienceDescription-buoy","Come to Billy Bob's for the best food in the sector"),
		_("scienceDescription-buoy","It's never too late to buy life insurance"),
		_("scienceDescription-buoy","You'll feel better in an Adder Mark 9"),
		_("scienceDescription-buoy","Visit Repulse shipyards for the best deals"),
		_("scienceDescription-buoy","Fresh fish! We catch, you buy!"),
		_("scienceDescription-buoy","Get your fuel cells at Melinda's Market"),
		_("scienceDescription-buoy","Find a companion. All species available"),
		_("scienceDescription-buoy","Feeling down? Robotherapist is there for you"),
		_("scienceDescription-buoy","30 days, 30 kilograms, guaranteed"),
		_("scienceDescription-buoy","Try our asteroid dust diet weight loss program"),
		_("scienceDescription-buoy","Best tasting water in the quadrant"),
		_("scienceDescription-buoy","Amazing shows every night at Lenny's Lounge"),
		_("scienceDescription-buoy","Tip: make lemons an integral part of your diet"),
	}
	ab:setDescriptions(_("scienceDescription-buoy","Automated data gathering device"),billboards[math.random(1,#billboards)])
	table.insert(place_space,{obj=ab,dist=200,shape="circle"})
end
function placeNebula()
	local eo_x, eo_y = environmentObject(center_x, center_y, 5000)
	local neb = Nebula():setPosition(eo_x, eo_y)
	table.insert(place_space,{obj=neb,dist=2500,shape="circle"})
	if random(1,100) < 77 then
		local n_angle = random(0,360)
		local n_x, n_y = vectorFromAngle(n_angle,random(5000,10000))
		local neb2 = Nebula():setPosition(eo_x + n_x, eo_y + n_y)
		if random(1,100) < 37 then
			local n2_angle = (n_angle + random(120,240)) % 360
			n_x, n_y = vectorFromAngle(n2_angle,random(5000,10000))
			eo_x = eo_x + n_x
			eo_y = eo_y + n_y
			local neb3 = Nebula():setPosition(eo_x, eo_y)
			if random(1,100) < 22 then
				local n3_angle = (n2_angle + random(120,240)) % 360
				n_x, n_y = vectorFromAngle(n3_angle,random(5000,10000))
				local neb4 = Nebula():setPosition(eo_x + n_x, eo_y + n_y)
			end
		end
	end
end
function placeMine()
	local eo_x, eo_y = environmentObject(center_x, center_y, 1000)
	local m = Mine():setPosition(eo_x, eo_y)
	table.insert(place_space,{obj=m,dist=1000,shape="circle"})
end
function placeEnvironmentStation(selected_faction)
	local station_defend_dist = {
		["Small Station"] = 2800,
		["Medium Station"] = 4200,
		["Large Station"] = 4800,
		["Huge Station"] = 5200,
	}
	local station_residents = {
		["Small Station"] = 25,
		["Medium Station"] = 50,
		["Large Station"] = 80,
		["Huge Station"] = 150,
	}
	local s_size = szt()
	local eo_x, eo_y = environmentObject(center_x, center_y, station_defend_dist[s_size])
	local name_group = "RandomHumanNeutral"
	if selected_faction == "Kraylor" or selected_faction == "Exuari" or selected_faction == "Ktlitan" or selected_faction == "Ghosts" then
		name_group = "Sinister"
	end
	local station = placeStation(eo_x, eo_y, name_group, selected_faction, s_size)
	station.residents = station_residents[s_size]
	local p = getPlayerShip(-1)
	if station:isEnemy(p) then
		residents["enemy"] = residents["enemy"] + station.residents
	elseif station:isFriendly(p) then
		residents["friend"] = residents["friend"] + station.residents
	else
		residents["neutral"] = residents["neutral"] + station.residents
	end
	table.insert(place_space,{obj=station,dist=station_defend_dist[s_size],shape="circle"})
	table.insert(station_list,station)
	--defense fleet
	local fleet = spawnEnemies(eo_x, eo_y, 1, selected_faction, 35)
	for _, ship in ipairs(fleet) do
		ship:setFaction("Independent")
		ship:orderDefendTarget(station)
		ship:setFaction(selected_faction)
		ship:setCallSign(generateCallSign(nil,selected_faction))
	end
	station.defense_fleet = fleet
	--patrol squad
	local patrol_templates = {"Adder MK3","Adder MK4","Adder MK5","Adder MK6","Adder MK7","Adder MK8","Adder MK9","MT52 Hornet","MU52 Hornet","Nirvana R5","Nirvana R5A","Nirvana R3"}
	local template = patrol_templates[math.random(1,#patrol_templates)]
	local patrol_angle = angleFromVectorNorth(center_x, center_y, eo_x, eo_y)
	local pd_x, pd_y = vectorFromAngleNorth(patrol_angle,2000)
	pd_x = pd_x + eo_x
	pd_y = pd_y + eo_y
	local leader_ship = ship_template[template].create(selected_faction,template)
	leader_ship:setPosition(pd_x, pd_y)
	leader_ship:setHeading(patrol_angle)
	leader_ship:setFaction("Independent")
	leader_ship:orderFlyTowards(center_x, center_y)
	leader_ship:setFaction(selected_faction)
	leader_ship:setCallSign(generateCallSign(nil,selected_faction))
	local formation_spacing = 800
	station.patrol_fleet = {}
	leader_ship.home_station = station
	leader_ship.home_station_name = station:getCallSign()
	leader_ship:setCommsScript(""):setCommsFunction(commsShip)
	table.insert(station.patrol_fleet,leader_ship)
	for _, form in ipairs(fly_formation["V"]) do
		local ship = ship_template[template].create(selected_faction,template)
		local form_x, form_y = vectorFromAngleNorth(patrol_angle + form.angle, form.dist * formation_spacing)
		local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist * formation_spacing)
		ship:setFaction("Independent")
		ship:setPosition(pd_x + form_x, pd_y + form_y):setHeading(patrol_angle):orderFlyFormation(leader_ship,form_prime_x,form_prime_y)
		ship:setFaction(selected_faction)
		ship:setCallSign(generateCallSign(nil,selected_faction))
		ship:setAcceleration(ship:getAcceleration()*1.1)
		ship:setImpulseMaxSpeed(ship:getImpulseMaxSpeed()*1.1)
		ship.home_station = station
		ship.home_station_name = station:getCallSign()
		ship:setCommsScript(""):setCommsFunction(commsShip)
		table.insert(station.patrol_fleet,ship)
	end
end
function placeBus(selected_faction)
	local eo_x, eo_y = environmentObject(center_x, center_y, 600)
	local bus, bus_size = randomTransportType()
	bus:setTypeName(_("ship_type_name","Mass Transit")):orderIdle()
	bus:setPosition(eo_x, eo_y):setFaction(selected_faction)
	bus:setCallSign(generateCallSign(nil,selected_faction))
	bus.passenger_capacity = 30 + (10*bus_size)
	bus.residents = {
		["friend"] = 0,
		["neutral"] = 0,
		["enemy"] = 0,
	}
	table.insert(place_space,{obj=bus,dist=600,shape="circle"})
	table.insert(bus_list,bus)
end
function placeMineField()
	if mine_field_count > 0 then
		if random(1,100) < 60 then
			local field_size = math.random(1,3)
			local mine_circle = {
				{inner_count = 4,	mid_count = 10,		outer_count = 15},	--1
				{inner_count = 9,	mid_count = 15,		outer_count = 20},	--2
				{inner_count = 15,	mid_count = 20,		outer_count = 25},	--3
			}
			local eo_x, eo_y = environmentObject(center_x, center_y, 4000 + (field_size*1500))
			local angle = random(0,360)
			local mx = 0
			local my = 0
			for i=1,mine_circle[field_size].inner_count do
				mx, my = vectorFromAngle(angle,field_size*1000)
				Mine():setPosition(eo_x+mx,eo_y+my)
				angle = (angle + (360/mine_circle[field_size].inner_count)) % 360
			end
			for i=1,mine_circle[field_size].mid_count do
				mx, my = vectorFromAngle(angle,field_size*1000 + 1200)
				Mine():setPosition(eo_x+mx,eo_y+my)
				angle = (angle + (360/mine_circle[field_size].mid_count)) % 360
			end
			table.insert(place_space,{dist=3000 + (field_size*1000),ps_x=eo_x,ps_y=eo_y,shape="circle"})
		else
			local mine_angle = random(0,360)
			local inverted_mine_angle = (mine_angle + 180) % 360
			local mine_space = 1500
			local length_half_count = math.random(2,5)
			local half_field_length = length_half_count*mine_space
			local field_length = half_field_length*2
			local axis_edge_x, axis_edge_y = vectorFromAngleNorth(mine_angle,half_field_length)
			local inverted_axis_edge_x, inverted_axis_edge_y = vectorFromAngleNorth(inverted_mine_angle,half_field_length)
			local width_count = math.random(1,3)	--1, 3, or 5 lines of width
			local width_count = width_count * 2 - width_count
			local half_field_width = (width_count * mine_space) / 2
			local left_front_x, left_front_y = vectorFromAngleNorth((mine_angle + 270) % 360,half_field_width)
			left_front_x = left_front_x + axis_edge_x
			left_front_y = left_front_y + axis_edge_y
			local right_front_x, right_front_y = vectorFromAngleNorth((mine_angle + 90) % 360,half_field_width)
			right_front_x = right_front_x + axis_edge_x
			right_front_y = right_front_y + axis_edge_y
			local left_rear_x, left_rear_y = vectorFromAngleNorth((inverted_mine_angle + 90) % 360,half_field_width)
			left_rear_x = left_rear_x + inverted_axis_edge_x
			left_rear_y = left_rear_y + inverted_axis_edge_y
			local right_rear_x, right_rear_y = vectorFromAngleNorth((inverted_mine_angle + 270) % 360,half_field_width)
			right_rear_x = right_rear_x + inverted_axis_edge_x
			right_rear_y = right_rear_y + inverted_axis_edge_y
			local eo_x, eo_y = environmentObject(center_x, center_y, distance(left_front_x,left_front_y,right_rear_x,right_rear_y) + (mine_space/2))
			local loop_mine_x = 0
			local loop_mine_y = 0
			for i=1,length_half_count*2 do
				Mine():setPosition(eo_x + inverted_axis_edge_x + loop_mine_x, eo_y + inverted_axis_edge_y + loop_mine_y)
				if width_count > 1 then
					local perp_x, perp_y = vectorFromAngleNorth((mine_angle + 90) % 360,mine_space)
					Mine():setPosition(eo_x + inverted_axis_edge_x + loop_mine_x + perp_x, eo_y + inverted_axis_edge_y + loop_mine_y + perp_y)
					perp_x, perp_y = vectorFromAngleNorth((mine_angle + 270) % 360,mine_space)
					Mine():setPosition(eo_x + inverted_axis_edge_x + loop_mine_x + perp_x, eo_y + inverted_axis_edge_y + loop_mine_y + perp_y)
				end
				if width_count > 2 then
					local perp_x, perp_y = vectorFromAngleNorth((mine_angle + 90) % 360,mine_space*2)
					Mine():setPosition(eo_x + inverted_axis_edge_x + loop_mine_x + perp_x, eo_y + inverted_axis_edge_y + loop_mine_y + perp_y)
					perp_x, perp_y = vectorFromAngleNorth((mine_angle + 270) % 360,mine_space*2)
					Mine():setPosition(eo_x + inverted_axis_edge_x + loop_mine_x + perp_x, eo_y + inverted_axis_edge_y + loop_mine_y + perp_y)
				end
				loop_mine_x, loop_mine_y = vectorFromAngleNorth(mine_angle,mine_space*i)
			end
			half_field_length = (length_half_count + 1)*mine_space
			inverted_axis_edge_x, inverted_axis_edge_y = vectorFromAngleNorth(inverted_mine_angle,half_field_length)
			half_field_width = ((width_count*1.5) * mine_space) / 2
			left_front_x, left_front_y = vectorFromAngleNorth((mine_angle + 270) % 360,half_field_width)
			left_front_x = left_front_x + axis_edge_x
			left_front_y = left_front_y + axis_edge_y
			right_front_x, right_front_y = vectorFromAngleNorth((mine_angle + 90) % 360,half_field_width)
			right_front_x = right_front_x + axis_edge_x
			right_front_y = right_front_y + axis_edge_y
			left_rear_x, left_rear_y = vectorFromAngleNorth((inverted_mine_angle + 90) % 360,half_field_width)
			left_rear_x = left_rear_x + inverted_axis_edge_x
			left_rear_y = left_rear_y + inverted_axis_edge_y
			right_rear_x, right_rear_y = vectorFromAngleNorth((inverted_mine_angle + 270) % 360,half_field_width)
			right_rear_x = right_rear_x + inverted_axis_edge_x
			right_rear_y = right_rear_y + inverted_axis_edge_y
			local check_zone = Zone():setPoints(left_front_x + eo_x,left_front_y + eo_y,right_front_x + eo_x,right_front_y + eo_y,right_rear_x + eo_x,right_rear_y + eo_y,left_rear_x + eo_x,left_rear_y + eo_y)
			table.insert(place_space,{ps_x=eo_x,ps_y=eo_y,shape="zone",zone=check_zone})
		end
		mine_field_count = mine_field_count - 1
	else
		placeAsteroid()
	end
end
function placeAsteroidField()
	if asteroid_field_count > 0 then
		local field_size = random(2000,8000)
		local eo_x, eo_y = environmentObject(center_x, center_y, field_size + 400)
		placeRandomAsteroidsAroundPoint(math.floor(field_size/random(50,100)),100,field_size, eo_x, eo_y)
		asteroid_field_count = asteroid_field_count - 1
	else
		placeAsteroid()
	end
end
function placeTransport()
	local eo_x, eo_y = environmentObject(center_x, center_y, 600)
	local ship, ship_size = randomTransportType()
	local faction_list = {"Human Navy","Independent","Kraylor","Arlenians","Exuari","Ghosts","Ktlitans","TSN","USN","CUF"}
	ship:setPosition(eo_x, eo_y):setFaction(faction_list[math.random(1,#faction_list)])
	ship:setCallSign(generateCallSign(nil,ship:getFaction()))
	ship.residents = {
		["friend"] = 0,
		["neutral"] = 0,
		["enemy"] = 0,
	}
	table.insert(place_space,{obj=ship,dist=600,shape="circle"})
	table.insert(transport_list,ship)
end
function placeAsteroid()
	local asteroid_size = random(2,200) + random(2,200) + random(2,200) + random(2,200)
	local eo_x, eo_y = environmentObject(center_x, center_y, asteroid_size)
	local ta = Asteroid():setPosition(eo_x, eo_y):setSize(asteroid_size)
	table.insert(place_space,{obj=ta,dist=asteroid_size,shape="circle"})
end
function farEnough(o_x,o_y,obj_dist)
	local far_enough = true
	for _, item in ipairs(place_space) do
		if item.shape == "circle" then
			if distanceDiagnostic then
				print("Distance diagnostic 2: item.obj:",item.obj,item.obj:getCallSign(),"o_x:",o_x,"o_y:",o_y)
			end
			if item.obj ~= nil and item.obj:isValid() then
				if distance(item.obj,o_x,o_y) < (obj_dist + item.dist) then
					far_enough = false
					break
				end
			elseif item.ps_x ~= nil then
				if distance(item.ps_x, item.ps_y, o_x, o_y) < (obj_dist + item.dist) then
					far_enough = false
					break
				end
			end
		elseif item.shape == "rectangle" then
			if	o_x > item.lo_x and 
				o_x < item.hi_x and
				o_y > item.lo_y and
				o_y < item.hi_y then
				far_enough = false
				break
			end
		elseif item.shape == "toroid" then
			if item.obj ~= nil and item.obj:isValid() then
				local origin_dist = distance(item.obj,o_x,o_y)
				if origin_dist > item.inner_orbit - obj_dist and
					origin_dist < item.outer_orbit + obj_dist then
					far_enough = false
					break
				end
			end
		elseif item.shape == "zone" then
			local va = VisualAsteroid():setPosition(o_x,o_y)
			if item.zone:isInside(va) then
				far_enough = false
			end
			va:destroy()
			if far_enough then
				for i=1,30 do
					local v_x, v_y = vectorFromAngleNorth(i*12,obj_dist)
					if item.zone:isInside(va) then
						far_enough = false
					end
					va:destroy()
					if not far_enough then
						break
					end
				end
			end
			if not far_enough then
				break
			end
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
function defenseMaintenance(delta)
	if #station_list > 0 then
		for station_index, station in ipairs(station_list) do
			if station ~= nil and station:isValid() then
				local fleet_count = 0
				local deleted_ship = false
				if station.defense_fleet ~= nil and #station.defense_fleet > 0 then
					for fleet_index, ship in ipairs(station.defense_fleet) do
						if ship ~= nil and ship:isValid() then
							fleet_count = fleet_count + 1
						else
							station.defense_fleet[fleet_index] = station.defense_fleet[#station.defense_fleet]
							station.defense_fleet[#station.defense_fleet] = nil
							deleted_ship = true
							break
						end
					end
				end
				if fleet_count < 1 and not deleted_ship then
					if station.defense_fleet_timer == nil then
						station.defense_fleet_timer = getScenarioTime() + 30
					end
					if station.defense_fleet_timer < getScenarioTime() then
						station.defense_fleet_timer = nil
						local df_x, df_y = station:getPosition()
						local station_faction = station:getFaction()
						local fleet = spawnEnemies(df_x, df_y, 1, station_faction, 35)
						for _, ship in ipairs(fleet) do
							ship:setFaction("Independent")
							ship:orderDefendTarget(station)
							ship:setFaction(station_faction)
							ship:setCallSign(generateCallSign(nil,ship:getFaction()))
						end
						station.defense_fleet = fleet
					end
				end
			else
				station_list[station_index] = station_list[#station_list]
				station_list[#station_list] = nil
				break
			end
		end
	end
	maintenancePlot = patrolMaintenance
end
function patrolMaintenance(delta)
	if #station_list > 0 then
		for station_index, station in ipairs(station_list) do
			if station ~= nil and station:isValid() then
				local fleet_count = 0
				local deleted_ship = false
				if station.patrol_fleet ~= nil and #station.patrol_fleet > 0 then
					for fleet_index, ship in ipairs(station.patrol_fleet) do
						if ship ~= nil and ship:isValid() then
							fleet_count = fleet_count + 1
						else
							station.patrol_fleet[fleet_index] = station.patrol_fleet[#station.patrol_fleet]
							station.patrol_fleet[#station.patrol_fleet] = nil
							deleted_ship = true
							break
						end
					end
				end
				if not deleted_ship then
					local pf_x, pf_y = station:getPosition()
					if fleet_count < 1 then
						if station.patrol_fleet_timer == nil then
							station.patrol_fleet_timer = getScenarioTime() + 30
						end
						if station.patrol_fleet_timer < getScenarioTime() then
							station.patrol_fleet_timer = nil
							local selected_faction = station:getFaction()
							local patrol_templates = {"Adder MK3","Adder MK4","Adder MK5","Adder MK6","Adder MK7","Adder MK8","Adder MK9","MT52 Hornet","MU52 Hornet","Nirvana R5","Nirvana R5A","Nirvana R3"}
							local template = patrol_templates[math.random(1,#patrol_templates)]
							local patrol_angle = angleFromVectorNorth(center_x, center_y, pf_x, pf_y)
							local pd_x, pd_y = vectorFromAngleNorth(patrol_angle,2000)
							pd_x = pd_x + pf_x
							pd_y = pd_y + pf_y
							if patrol_maintenance_diagnostic then print("patrol template:",template,"faction:",selected_faction) end
							local leader_ship = ship_template[template].create(selected_faction,template)
							leader_ship:setPosition(pd_x, pd_y)
							leader_ship:setHeading(patrol_angle)
							leader_ship:setFaction("Independent")
							leader_ship:orderFlyTowards(center_x, center_y)
							leader_ship:setFaction(selected_faction)
							leader_ship:setCallSign(generateCallSign(nil,leader_ship:getFaction()))
							local formation_spacing = 800
							station.patrol_fleet = {}
							leader_ship.home_station = station
							leader_ship.home_station_name = station:getCallSign()
							leader_ship:setCommsScript(""):setCommsFunction(commsShip)
							table.insert(station.patrol_fleet,leader_ship)
							for _, form in ipairs(fly_formation["V"]) do
								local ship = ship_template[template].create(selected_faction,template)
								local form_x, form_y = vectorFromAngleNorth(patrol_angle + form.angle, form.dist * formation_spacing)
								local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist * formation_spacing)
								ship:setFaction("Independent")
								ship:setPosition(pd_x + form_x, pd_y + form_y):setHeading(patrol_angle):orderFlyFormation(leader_ship,form_prime_x,form_prime_y)
								ship:setFaction(selected_faction)
								ship:setCallSign(generateCallSign(nil,ship:getFaction()))
								ship:setAcceleration(ship:getAcceleration()*1.1)
								ship:setImpulseMaxSpeed(ship:getImpulseMaxSpeed()*1.1)
								ship.home_station = station
								ship.home_station_name = station:getCallSign()
								ship:setCommsScript(""):setCommsFunction(commsShip)
								table.insert(station.patrol_fleet,ship)
							end
						end
					else
						for _, ship in ipairs(station.patrol_fleet) do
							local center_dist = distance(ship,center_x,center_y)
							local temp_faction = ship:getFaction()
							if center_dist < 500 then
								ship:setFaction("Independent")
								ship:orderFlyTowards(pf_x, pf_y)
								ship:setFaction(temp_faction)
							end
							if center_dist < 5000 then
								if string.find(ship:getOrder(),"Defend") then
									ship:setFaction("Independent")
									ship:orderFlyTowards(pf_x, pf_y)
									ship:setFaction(temp_faction)
								end
							end
							if distance(ship,pf_x, pf_y) < 1200 then
								ship:setFaction("Independent")
								ship:orderFlyTowards(center_x,center_y)
								ship:setFaction(temp_faction)
							end
						end
					end
				end
			else
				station_list[station_index] = station_list[#station_list]
				station_list[#station_list] = nil
				break
			end
		end
	end
	maintenancePlot = expeditionMaintenance
end
function expeditionMaintenance(delta)
	if #station_list > 0 then
		local fleet_count = 0
		local deleted_station = false
		for station_index, station in ipairs(station_list) do
			if station ~= nil and station:isValid() then
				if station.expedition_fleet ~= nil and #station.expedition_fleet > 0 then
					fleet_count = fleet_count + 1
				end
			else
				station_list[station_index] = station_list[#station_list]
				station_list[#station_list] = nil
				deleted_station = true
				break
			end
		end
		if not deleted_station then
			if fleet_count < 5 then
				if #station_list > 5 then
					local avail_station = {}
					for _, station in ipairs(station_list) do
						if station.expedition_fleet == nil or #station.expedition_fleet < 1 then
							table.insert(avail_station,station)
						end
					end
					local station = avail_station[math.random(1,#avail_station)]
					local selected_faction = station:getFaction()
					local expedition_templates = {"Phobos T3","Karnack","Cruiser","Gunship","Adv. Gunship","Phobos R2","Farco 3","Farco 5","Farco 8","Farco 11","Farco 13","Phobos T4"}
					local template = expedition_templates[math.random(1,#expedition_templates)]
					local pf_x, pf_y = station:getPosition()
					local expedition_angle = angleFromVectorNorth(center_x, center_y, pf_x, pf_y)
					local pd_x, pd_y = vectorFromAngleNorth(expedition_angle,2000)
					pd_x = pd_x + pf_x
					pd_y = pd_y + pf_y
					if expedition_maintenance_diagnostic then print("expedition template:",template,"faction:",selected_faction) end
					local leader_ship = ship_template[template].create(selected_faction,template)
					leader_ship:setPosition(pd_x, pd_y)
					leader_ship:setHeading(expedition_angle)
					leader_ship:setCallSign(generateCallSign(nil,leader_ship:getFaction()))
					leader_ship:orderRoaming()
					local formation_spacing = 800
					station.expedition_fleet = {}
					leader_ship.home_station = station
					leader_ship.home_station_name = station:getCallSign()
					leader_ship:setCommsScript(""):setCommsFunction(commsShip)
					table.insert(station.expedition_fleet,leader_ship)
					for _, form in ipairs(fly_formation["Vac"]) do
						local ship = ship_template[template].create(selected_faction,template)
						local form_x, form_y = vectorFromAngleNorth(expedition_angle + form.angle, form.dist * formation_spacing)
						local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist * formation_spacing)
						ship:setFaction("Independent")
						ship:setPosition(pd_x + form_x, pd_y + form_y):setHeading(expedition_angle):orderFlyFormation(leader_ship,form_prime_x,form_prime_y)
						ship:setFaction(selected_faction)
						ship:setCallSign(generateCallSign(nil,ship:getFaction()))
						ship:setAcceleration(ship:getAcceleration()*1.1)
						ship:setImpulseMaxSpeed(ship:getImpulseMaxSpeed()*1.1)
						ship.home_station = station
						ship.home_station_name = station:getCallSign()
						ship:setCommsScript(""):setCommsFunction(commsShip)
						table.insert(station.expedition_fleet,ship)
					end
				end
			else
				for station_index, station in ipairs(station_list) do
					fleet_count = 0
					local deleted_ship = false
					if station.expedition_fleet ~= nil and #station.expedition_fleet > 0 then
						for fleet_index, ship in ipairs(station.expedition_fleet) do
							if ship ~= nil and ship:isValid() then
								fleet_count = fleet_count + 1
							else
								station.expedition_fleet[fleet_index] = station.expedition_fleet[#station.expedition_fleet]
								station.expedition_fleet[#station.expedition_fleet] = nil
								deleted_ship = true
								break
							end
						end
					end
					if not deleted_ship then
						if fleet_count < 1 then
							station.expedition_fleet = nil
						end
					end
				end
			end
		end
	end
	maintenancePlot = taskMaintenance
end
function taskMaintenance(delta)
	if #station_list > 0 then
		local fleet_count = 0
		local deleted_station = false
		for station_index, station in ipairs(station_list) do
			if station ~= nil and station:isValid() then
				if station.task_fleet ~= nil and #station.task_fleet > 0 then
					fleet_count = fleet_count + 1
				end
			else
				station_list[station_index] = station_list[#station_list]
				station_list[#station_list] = nil
				deleted_station = true
				break
			end
		end
		if not deleted_station then
			if fleet_count < 5 then
				if #station_list > 5 then
					local avail_station = {}
					for _, station in ipairs(station_list) do
						if station.task_fleet == nil or #station.task_fleet < 1 then
							for tsi, station_target in ipairs(station_list) do
								if station:isEnemy(station_target) then
									table.insert(avail_station,station)
								end
							end
						end
					end
					if #avail_station > 0 then
						local station = avail_station[math.random(1,#avail_station)]
						local selected_faction = station:getFaction()
						local task_templates = {"Phobos T3","Karnack","Cruiser","Gunship","Adv. Gunship","Phobos R2","Farco 3","Farco 5","Farco 8","Farco 11","Farco 13","Phobos T4"}
						local template = task_templates[math.random(1,#task_templates)]
						local pf_x, pf_y = station:getPosition()
						local target_station_list = {}
						for _, target_station in ipairs(station_list) do
							if station:isEnemy(target_station) then
								table.insert(target_station_list,target_station)
							end
						end
						local target_station = target_station_list[math.random(1,#target_station_list)]
						local ts_x, ts_y = target_station:getPosition()
						local task_angle = angleFromVectorNorth(ts_x, ts_y, pf_x, pf_y)
						local pd_x, pd_y = vectorFromAngleNorth(task_angle,2000)
						pd_x = pd_x + pf_x
						pd_y = pd_y + pf_y
						if task_maintenance_diagnostic then print("task template:",template,"faction:",selected_faction) end
						local leader_ship = ship_template[template].create(selected_faction,template)
						leader_ship:setPosition(pd_x, pd_y)
						leader_ship:setHeading(task_angle)
						leader_ship:setCallSign(generateCallSign(nil,leader_ship:getFaction()))
						leader_ship:orderAttack(target_station)
						local formation_spacing = 800
						station.task_fleet = {}
						table.insert(station.task_fleet,leader_ship)
						for _, form in ipairs(fly_formation["Vac"]) do
							local ship = ship_template[template].create(selected_faction,template)
							local form_x, form_y = vectorFromAngleNorth(task_angle + form.angle, form.dist * formation_spacing)
							local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist * formation_spacing)
							ship:setFaction("Independent")
							ship:setPosition(pd_x + form_x, pd_y + form_y):setHeading(task_angle):orderFlyFormation(leader_ship,form_prime_x,form_prime_y)
							ship:setFaction(selected_faction)
							ship:setCallSign(generateCallSign(nil,ship:getFaction()))
							ship:setAcceleration(ship:getAcceleration()*1.1)
							ship:setImpulseMaxSpeed(ship:getImpulseMaxSpeed()*1.1)
							table.insert(station.task_fleet,ship)
						end
					end
				end
			else
				for station_index, station in ipairs(station_list) do
					fleet_count = 0
					local deleted_ship = false
					if station.task_fleet ~= nil and #station.task_fleet > 0 then
						for fleet_index, ship in ipairs(station.task_fleet) do
							if ship ~= nil and ship:isValid() then
								fleet_count = fleet_count + 1
							else
								station.task_fleet[fleet_index] = station.task_fleet[#station.task_fleet]
								station.task_fleet[#station.task_fleet] = nil
								deleted_ship = true
								break
							end
						end
					end
					if not deleted_ship then
						if fleet_count < 1 then
							station.task_fleet = nil
						end
					end
				end
			end
		end
	end
	maintenancePlot = transportCommerceMaintenance
end
function transportCommerceMaintenance(delta)
	if #transport_list > 0 then
		local p = getPlayerShip(-1)
		local bus_contact_count = 0
		local freighter_contact_count = 0
		local s_time = getScenarioTime()
		if s_time > black_hole_milestone then
			for _, bus in ipairs(bus_list) do
				if bus ~= nil and bus:isValid() and bus.rescue_pickup ~= nil then
					bus_contact_count = bus_contact_count + 1
				end
			end
			for _, transport in ipairs(transport_list) do
				if transport ~= nil and transport:isValid() and transport.rescue_pickup ~= nil then
					freighter_contact_count = freighter_contact_count + 1
				end
			end
		end
		for transport_index, transport in ipairs(transport_list) do
			if transport ~= nil and transport:isValid() then
				local temp_faction = transport:getFaction()
				local docked_with = transport:getDockedWith()
				local transport_target = nil
				if transport.rescue_pickup == nil then
					local inspired_rescue = false
					if s_time > black_hole_milestone then
						if random(1,100) < ((bus_contact_count*2) + freighter_contact_count) then
							inspired_rescue = true
						end
					end
					if docked_with ~= nil then
						if transport.undock_timer == nil then
							transport.undock_timer = s_time + 20
						elseif transport.undock_timer < s_time then
							transport.undock_timer = nil
							transport_target = pickTransportTarget(transport)
							if inspired_rescue then
								if docked_with.residents > 0 then
									if 5 >= docked_with.residents then
										if p:isFriendly(docked_with) then
											transport.residents["friend"] = transport.residents["friend"] + docked_with.residents
										elseif p:isEnemy(docked_with) then
											transport.residents["enemy"] = transport.residents["enemy"] + docked_with.residents
										else
											transport.residents["neutral"] = transport.residents["neutral"] + docked_with.residents
										end
										docked_with.residents = 0
									else
										docked_with.residents = docked_with.residents - 5
										if p:isFriendly(docked_with) then
											transport.residents["friend"] =  5
										elseif p:isEnemy(docked_with) then
											transport.residents["enemy"] = 5
										else
											transport.residents["neutral"] = 5
										end
									end
									transport.rescue_pickup = "complete"
									p:addToShipLog(string.format("[%s] Getting the heck out of Dodge",transport:getCallSign()),"Green")
									transport:orderFlyTowards(safety_x, safety_y)
									if transport.quadruple_impulse == nil then
										if transport.double_impulse then
											transport:setImpulseMaxSpeed(transport:getImpulseMaxSpeed()*2)
										else
											transport:setImpulseMaxSpeed(transport:getImpulseMaxSpeed()*4)
											transport.double_impulse = true
										end
										transport.quadruple_impulse = true
									end
									print("freighter inspired to pick up passengers",transport:getCallSign())
								else
									if transport_target ~= nil then
										transport:setFaction("Independent")
										transport:orderDock(transport_target)
										transport:setFaction(temp_faction)
										if transport.double_impulse == nil then
											transport:setImpulseMaxSpeed(transport:getImpulseMaxSpeed()*2)
											transport.double_impulse = true
										end
										transport.rescue_pickup = "enroute"
									end
								end
							else
								if transport_target ~= nil then
									transport:setFaction("Independent")
									transport:orderDock(transport_target)
									transport:setFaction(temp_faction)
								end
							end
						end
					else
						if string.find("Dock",transport:getOrder()) then
							transport_target = transport:getOrderTarget()
							if transport_target == nil or not transport_target:isValid() then
								transport_target = pickTransportTarget(transport)
								if inspired_rescue then
									if transport_target ~= nil then
										transport:setFaction("Independent")
										transport:orderDock(transport_target)
										transport:setFaction(temp_faction)
										if transport.double_impulse == nil then
											transport:setImpulseMaxSpeed(transport:getImpulseMaxSpeed()*2)
											transport.double_impulse = true
										end
										transport.rescue_pickup = "enroute"
									end
								else
									if transport_target ~= nil then
										transport:setFaction("Independent")
										transport:orderDock(transport_target)
										transport:setFaction(temp_faction)
									end
								end
							end
						else
							transport_target = pickTransportTarget(transport)
							if inspired_rescue then
								if transport_target ~= nil then
									transport:setFaction("Independent")
									transport:orderDock(transport_target)
									transport:setFaction(temp_faction)
									if transport.double_impulse == nil then
										transport:setImpulseMaxSpeed(transport:getImpulseMaxSpeed()*2)
										transport.double_impulse = true
									end
									transport.rescue_pickup = "enroute"
								end
							else
								if transport_target ~= nil then
									transport:setFaction("Independent")
									transport:orderDock(transport_target)
									transport:setFaction(temp_faction)
								end
							end
						end
					end
				else	--rescue pickup enabled
					if transport.rescue_pickup == "enroute" then
						if docked_with ~= nil then
							if docked_with.residents > 0 then
								if 5 >= docked_with.residents then
									if p:isFriendly(docked_with) then
										transport.residents["friend"] = transport.residents["friend"] + docked_with.residents
									elseif p:isEnemy(docked_with) then
										transport.residents["enemy"] = transport.residents["enemy"] + docked_with.residents
									else
										transport.residents["neutral"] = transport.residents["neutral"] + docked_with.residents
									end
									docked_with.residents = 0
								else
									docked_with.residents = docked_with.residents - 5
									if p:isFriendly(docked_with) then
										transport.residents["friend"] =  5
									elseif p:isEnemy(docked_with) then
										transport.residents["enemy"] =  5
									else
										transport.residents["neutral"] =  5
									end
								end
								transport.rescue_pickup = "complete"
								p:addToShipLog(string.format(_("goal-shipLog","[%s] Picked up 5 passengers from %s. Getting the heck out of Dodge."),transport:getCallSign(),docked_with:getCallSign()),"Green")
								transport:orderFlyTowards(safety_x, safety_y)
								if transport.quadruple_impulse == nil then
									if transport.double_impulse then
										transport:setImpulseMaxSpeed(transport:getImpulseMaxSpeed()*2)
									else
										transport:setImpulseMaxSpeed(transport:getImpulseMaxSpeed()*4)
										transport.double_impulse = true
									end
									transport.quadruple_impulse = true
								end
							else
								p:addToShipLog(string.format(_("goal-shipLog","[%s] Nobody to pick up at %s"),transport:getCallSign(),docked_with:getCallSign()),"Green")
								transport.rescue_pickup = nil
							end
						else
							if string.find("Dock",transport:getOrder()) then
								transport_target = transport:getOrderTarget()
								if transport_target == nil or not transport_target:isValid() then
									p:addToShipLog(string.format(_("goal-shipLog","[%s] Those passengers are out of luck"),transport:getCallSign()),"Green")
									transport.rescue_pickup = nil
								end
							else
								transport.rescue_pickup = nil
							end
						end
					end
				end
			else
				transport_list[transport_index] = transport_list[#transport_list]
				transport_list[#transport_list] = nil
				break
			end
		end
	end
	maintenancePlot = massTransitMaintenance
end
function massTransitMaintenance(delta)
	if #bus_list > 0 then
		local p = getPlayerShip(-1)
		local bus_contact_count = 0
		local freighter_contact_count = 0
		local s_time = getScenarioTime()
		if s_time > black_hole_milestone then
			for _, bus in ipairs(bus_list) do
				if bus ~= nil and bus:isValid() and bus.rescue_pickup ~= nil then
					bus_contact_count = bus_contact_count + 1
				end
			end
			for _, transport in ipairs(transport_list) do
				if transport ~= nil and transport:isValid() and transport.rescue_pickup ~= nil then
					freighter_contact_count = freighter_contact_count + 1
				end
			end
		end
		for bus_index, bus in ipairs(bus_list) do
			if bus ~= nil and bus:isValid() then
				local temp_faction = bus:getFaction()
				local docked_with = bus:getDockedWith()
				local bus_target = nil
				if bus.rescue_pickup == nil then
					local inspired_rescue = false
					if s_time > black_hole_milestone then
						if random(1,100) < ((bus_contact_count*2) + freighter_contact_count) then
							inspired_rescue = true
						end
					end
					if docked_with ~= nil then
						if bus.undock_timer == nil then
							bus.undock_timer = s_time + 20
						elseif bus.undock_timer < s_time then
							bus.undock_timer = nil
							bus_target = pickTransportTarget(bus)
							if inspired_rescue then
								if docked_with.residents > 0 then
									if bus.passenger_capacity >= docked_with.residents then
										bus.passenger_capacity = bus.passenger_capacity - docked_with.residents
										if p:isFriendly(docked_with) then
											bus.residents["friend"] = bus.residents["friend"] + docked_with.residents
										elseif p:isEnemy(docked_with) then
											bus.residents["enemy"] = bus.residents["enemy"] + docked_with.residents
										else
											bus.residents["neutral"] = bus.residents["neutral"] + docked_with.residents
										end
										docked_with.residents = 0
									else
										docked_with.residents = docked_with.residents - bus.passenger_capacity
										if p:isFriendly(docked_with) then
											bus.residents["friend"] = bus.residents["friend"] + bus.passenger_capacity
										elseif p:isEnemy(docked_with) then
											bus.residents["enemy"] = bus.residents["enemy"] + bus.passenger_capacity
										else
											bus.residents["neutral"] = bus.residents["neutral"] + bus.passenger_capacity
										end
										bus.passenger_capacity = 0
									end
									if bus.passenger_capacity == 0 then
										bus.rescue_pickup = "complete"
										p:addToShipLog(string.format(_("goal-shipLog","[%s] Getting the heck out of Dodge"),bus:getCallSign()),"Green")
									else
										p:addToShipLog(string.format(_("goal-shipLog","[%s] Picked up passengers at %s. I've got room for %i more, but for now, I'm getting the heck out of Dodge."),bus:getCallSign(),docked_with:getCallSign(),bus.passenger_capacity),"Green")
										bus.rescue_pickup = nil
									end
									bus:orderFlyTowards(safety_x, safety_y)
								else
									if bus_target ~= nil then
										bus:setFaction("Independent")
										bus:orderDock(bus_target)
										bus:setFaction(temp_faction)
										if bus.double_impulse == nil then
											bus:setImpulseMaxSpeed(bus:getImpulseMaxSpeed()*2)
											bus.double_impulse = true
										end
										bus.rescue_pickup = "enroute"
									end
								end
							else
								if bus_target ~= nil then
									bus:setFaction("Independent")
									bus:orderDock(bus_target)
									bus:setFaction(temp_faction)
								end
							end
						end
					else
						if string.find("Dock",bus:getOrder()) then
							bus_target = bus:getOrderTarget()
							if bus_target == nil or not bus_target:isValid() then
								bus_target = pickTransportTarget(bus)
								if inspired_rescue then
									if bus_target ~= nil then
										bus:setFaction("Independent")
										bus:orderDock(bus_target)
										bus:setFaction(temp_faction)
										if bus.double_impulse == nil then
											bus:setImpulseMaxSpeed(bus:getImpulseMaxSpeed()*2)
											bus.double_impulse = true
										end
										bus.rescue_pickup = "enroute"
									end
								else
									if bus_target ~= nil then
										bus:setFaction("Independent")
										bus:orderDock(bus_target)
										bus:setFaction(temp_faction)
									end
								end
							end
						else
							bus_target = pickTransportTarget(bus)
							if inspired_rescue then
								if bus_target ~= nil then
									bus:setFaction("Independent")
									bus:orderDock(bus_target)
									bus:setFaction(temp_faction)
									if bus.double_impulse == nil then
										bus:setImpulseMaxSpeed(bus:getImpulseMaxSpeed()*2)
										bus.double_impulse = true
									end
									bus.rescue_pickup = "enroute"
								end
							else
								if bus_target ~= nil then
									bus:setFaction("Independent")
									bus:orderDock(bus_target)
									bus:setFaction(temp_faction)
								end
							end
						end
					end
				else
					--different automation once the rescue starts
					if bus.rescue_pickup == "enroute" then
						if docked_with ~= nil then
							if docked_with.residents > 0 then
								if bus.passenger_capacity >= docked_with.residents then
									bus.passenger_capacity = bus.passenger_capacity - docked_with.residents
									if p:isFriendly(docked_with) then
										bus.residents["friend"] = bus.residents["friend"] + docked_with.residents
									elseif p:isEnemy(docked_with) then
										bus.residents["enemy"] = bus.residents["enemy"] + docked_with.residents
									else
										bus.residents["neutral"] = bus.residents["neutral"] + docked_with.residents
									end
									docked_with.residents = 0
								else
									docked_with.residents = docked_with.residents - bus.passenger_capacity
									if p:isFriendly(docked_with) then
										bus.residents["friend"] = bus.residents["friend"] + bus.passenger_capacity
									elseif p:isEnemy(docked_with) then
										bus.residents["enemy"] = bus.residents["enemy"] + bus.passenger_capacity
									else
										bus.residents["neutral"] = bus.residents["neutral"] + bus.passenger_capacity
									end
									bus.passenger_capacity = 0
								end
								if bus.passenger_capacity == 0 then
									bus.rescue_pickup = "complete"
									p:addToShipLog(string.format(_("goal-shipLog","[%s] Getting the heck out of Dodge"),bus:getCallSign()),"Green")
								else
									p:addToShipLog(string.format(_("goal-shipLog","[%s] Picked up passengers at %s. I've got room for %i more, but for now, I'm getting the heck out of Dodge."),bus:getCallSign(),docked_with:getCallSign(),bus.passenger_capacity),"Green")
									bus.rescue_pickup = nil
								end
							else
								p:addToShipLog(string.format(_("goal-shipLog","[%s] Nobody to pick up at %s. I'm getting the heck out of Dodge."),bus:getCallSign(),docked_with:getCallSign()),"Green")
								bus.rescue_pickup = nil
							end
							bus:orderFlyTowards(safety_x, safety_y)
							if bus.quadruple_impulse == nil then
								if bus.double_impulse then
									bus:setImpulseMaxSpeed(bus:getImpulseMaxSpeed()*2)
								else
									bus:setImpulseMaxSpeed(bus:getImpulseMaxSpeed()*4)
									bus.double_impulse = true
								end
								bus.quadruple_impulse = true
							end
						else
							if string.find("Dock",bus:getOrder()) then
								bus_target = bus:getOrderTarget()
								if bus_target == nil or not bus_target:isValid() then
									p:addToShipLog(string.format(_("goal-shipLog","[%s] Those passengers are out of luck"),bus:getCallSign()),"Green")
									bus.rescue_pickup = nil
								end
							else
								bus.rescue_pickup = nil
							end
						end
					end
				end
			else
				bus_list[bus_index] = bus_list[#bus_list]
				bus_list[#bus_list] = nil
				break
			end
		end
	end
	maintenancePlot = warpJammerMaintenance
end
function warpJammerMaintenance()
	if #warp_jammer_list > 0 then
		for wj_index, wj in ipairs(warp_jammer_list) do
			if wj ~= nil and wj:isValid() then
				if wj.reset_time ~= nil then
					if getScenarioTime() > wj.reset_time then
						wj:setRange(wj.range)
						wj.reset_time = nil
					end
				end
			else
				warp_jammer_list[wj_index] = warp_jammer_list[#warp_jammer_list]
				warp_jammer_list[#warp_jammer_list] = nil
				break
			end
		end
	end
	maintenancePlot = defenseMaintenance
end

function sensorJammerPickupProcess(self,retriever)
	local jammer_call_sign = self:getCallSign()
	sensor_jammer_list[jammer_call_sign] = nil
	if not self:isScannedBy(retriever) then
		retriever:setCanScan(false)
		retriever.scanner_dead = "scanner_dead"
		retriever:addCustomMessage("Science",retriever.scanner_dead,_("msgScience","The unscanned artifact we just picked up has fried our scanners"))
		retriever.scanner_dead_ops = "scanner_dead_ops"
		retriever:addCustomMessage("Operations",retriever.scanner_dead_ops,_("msgOperations","The unscanned artifact we just picked up has fried our scanners"))
	end
end
function sensorJammer(x,y)
	artifactCounter = artifactCounter + 1
	artifactNumber = artifactNumber + math.random(1,4)
	local random_suffix = string.char(math.random(65,90))
	local jammer_call_sign = string.format("SJ%i%s",artifactNumber,random_suffix)
	local scanned_description = string.format(_("scienceDescription-artifact","Source of emanations interfering with long range sensors. Range:%.1fu Impact:%.1fu"),sensor_jammer_range/1000,sensor_jammer_impact/1000)
	local sensor_jammer = Artifact():setPosition(x,y):setScanningParameters(sensor_jammer_scan_complexity,sensor_jammer_scan_depth):setRadarSignatureInfo(.2,.4,.1):setModel("SensorBuoyMKIII"):setDescriptions(_("scienceDescription-artifact","Source of unusual emanations"),scanned_description):setCallSign(jammer_call_sign)
	sensor_jammer:onPickUp(sensorJammerPickupProcess)
	sensor_jammer_list[jammer_call_sign] = sensor_jammer
	sensor_jammer.jam_range = sensor_jammer_range
	sensor_jammer.jam_impact = sensor_jammer_impact
	sensor_jammer.jam_impact_units = sensor_jammer_power_units
	return sensor_jammer
end
function updatePlayerLongRangeSensors(p)
	local base_range = p.normal_long_range_radar
	local impact_range = math.max(base_range * sensor_impact,p:getShortRangeRadarRange())
	local sensor_jammer_impact = 0
	if jammer_count == nil then
		jammer_count = 0
	end
	local previous_jammer_count = jammer_count
	jammer_count = 0
	if sensor_jammer_diagnostic then
		local out = "Jammers: name, distance, range, impact, calculated impact"
	end
	for jammer_name, sensor_jammer in pairs(sensor_jammer_list) do
		if sensor_jammer ~= nil and sensor_jammer:isValid() then
			local jammer_distance = distance(p,sensor_jammer)
			if jammer_distance < sensor_jammer.jam_range then
				jammer_count = jammer_count + 1
				if sensor_jammer.jam_impact_units then
					sensor_jammer_impact = math.max(sensor_jammer_impact,sensor_jammer.jam_impact*(1-(jammer_distance/sensor_jammer.jam_range)))
				else
					sensor_jammer_impact = math.max(sensor_jammer_impact,impact_range*sensor_jammer.jam_impact/100000*(1-(jammer_distance/sensor_jammer.jam_range)))
				end
				if sensor_jammer_diagnostic then
					out = string.format("%s\n%s, %.1f, %.1f, %.1f, %.1f",out,jammer_name,jammer_distance,sensor_jammer.jam_range,sensor_jammer.jam_impact,sensor_jammer_impact)
				end
			end
		else
			sensor_jammer_list[jammer_name] = nil
		end
	end
	impact_range = math.max(p:getShortRangeRadarRange(),impact_range - sensor_jammer_impact)
	p:setLongRangeRadarRange(impact_range)
	if sensor_jammer_diagnostic then
		if jammer_count ~= previous_jammer_count then
			print(out)
			print("Selected jammer impact:",sensor_jammer_impact,"Applied:",impact_range,"Normal:",p.normal_long_range_radar)
		end
	end
end
function updatePlayerUpgradeMission(p)
	if p.impulse_upgrade == 1 then
		if p.goods ~= nil then
			for good, good_quantity in pairs(p.goods) do
				if good == p.impulse_upgrade_part and good_quantity > 0 then
					p:setImpulseMaxSpeed(85)	--faster vs base 70 and upgraded 75
					good_quantity = good_quantity - 1
					p.impulse_upgrade = 2
					local final_impulse_upgrade_msg = string.format(_("msgEngineer","With the %s just acquired, you improve your impulse engine top speed by 13%%"),good)
					p.final_impulse_upgrade_msg_eng = "final_impulse_upgrade_msg_eng"
					p.final_impulse_upgrade_msg_plus = "final_impulse_upgrade_msg_plus"
					p:addCustomMessage("Engineering",p.final_impulse_upgrade_msg_eng,final_impulse_upgrade_msg)
					p:addCustomMessage("Engineering+",p.final_impulse_upgrade_msg_plus,final_impulse_upgrade_msg)
				end
			end
		end
	end
	if p.shield_upgrade == 1 then
		if p.goods ~= nil then
			for good, good_quantity in pairs(p.goods) do
				if good == p.shield_upgrade_part and good_quantity > 0 then
					p:setShieldsMax(100,100)	--stronger vs base 80,80 and upgraded 90,90
					good_quantity = good_quantity - 1
					p.shield_upgrade = 2
					local final_shield_upgrade_msg = string.format(_("msgEngineer","With the %s just acquired, you improve your shield charge capacity top speed by 11%%"),good)
					p.final_shield_upgrade_msg_eng = "final_shield_upgrade_msg_eng"
					p.final_shield_upgrade_msg_plus = "final_shield_upgrade_msg_plus"
					p:addCustomMessage("Engineering",p.final_shield_upgrade_msg_eng,final_shield_upgrade_msg)
					p:addCustomMessage("Engineering+",p.final_shield_upgrade_msg_plus,final_shield_upgrade_msg)
				end
			end
		end
	end
	if p.tube_speed_upgrade == 1 then
		if p.goods ~= nil then
			for good, good_quantity in pairs(p.goods) do
				if good == p.tube_speed_upgrade_part and good_quantity > 0 then
					p:setTubeLoadTime(0,10)		--faster vs base 20 and upgraded 15
					p:setTubeLoadTime(1,10)		--faster vs base 20 and upgraded 15
					good_quantity = good_quantity - 1
					p.tube_speed_upgrade = 2
					local final_tube_speed_upgrade_msg = string.format(_("msgEngineer","With the %s just acquired, you improve your weapon tube load time by 33%%"),good)
					p.final_tube_speed_upgrade_msg_eng = "final_tube_speed_upgrade_msg_eng"
					p.final_tube_speed_upgrade_msg_plus = "final_tube_speed_upgrade_msg_plus"
					p:addCustomMessage("Engineering",p.final_tube_speed_upgrade_msg_eng,final_tube_speed_upgrade_msg)
					p:addCustomMessage("Engineering+",p.final_tube_speed_upgrade_msg_plus,final_tube_speed_upgrade_msg)
				end
			end
		end
	end
end

function pickTransportTarget(transport)
	local transport_target = nil
	if #station_list > 0 then
		local count_repeat_loop = 0
		repeat
	--		transport_target = transport_stations[math.random(1,#transport_stations)]
			transport_target = station_list[math.random(1,#station_list)]
			count_repeat_loop = count_repeat_loop + 1
		until(count_repeat_loop > max_repeat_loop or (transport_target ~= nil and transport_target:isValid() and not transport:isEnemy(transport_target)))
		if count_repeat_loop > max_repeat_loop then
			print("repeated too many times when picking a transport target")
		end
	end
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

function establishDevouringBlackHoles()
	devouring_black_holes = {}
	devouring_black_hole_names = {
		"Andrea",
		"Barry",
		"Chantal",
		"Dexter",
		"Erin",
		"Fernand",
		"Gabrielle",
		"Humberto",
		"Imelda",
		"Jerry",
		"Karen",
		"Lorenzo",
		"Melissa",
		"Nestor",
		"Olga",
		"Pablo",
		"Rebekah",
		"Sebastian",
		"Tanya",
		"Van",
		"Wendy",
	}
	devouring_origin_x, devouring_origin_y = vectorFromAngleNorth((gross_angle + 90) % 360,170000)
	devouring_origin_x = devouring_origin_x + center_x
	devouring_origin_y = devouring_origin_y + center_y
	safety_x, safety_y = vectorFromAngleNorth((gross_angle + 270) % 360,170000)
	safety_x = safety_x + center_x
	safety_y = safety_y + center_y
	for _, station in ipairs(station_list) do
		if station ~= nil and station:isValid() then
			local s_x, s_y = station:getPosition()
			local travel_angle = angleFromVectorNorth(s_x, s_y, devouring_origin_x, devouring_origin_y)
			local spawn_range = 30000
			local spawn_x = nil
			local spawn_y = nil
			local count_repeat_loop = 0
			repeat
				spawn_x, spawn_y = vectorFromAngleNorth(travel_angle,spawn_range)
				spawn_x = spawn_x + devouring_origin_x
				spawn_y = spawn_y + devouring_origin_y
				spawn_range = spawn_range + 1000
				count_repeat_loop = count_repeat_loop + 1
			until(blackHoleSpacing(spawn_x,spawn_y) or count_repeat_loop > max_repeat_loop)
			if count_repeat_loop > max_repeat_loop then
				print("repeated too many times when establishing a devouring black hole")
				print("station:",station:getCallSign(),"spawn_x:",spawn_x,"spawn_y:",spawn_y)
			end
			local bh = BlackHole():setPosition(spawn_x, spawn_y)
			bh.travel_angle = travel_angle
			bh.name = tableRemoveRandom(devouring_black_hole_names)
			table.insert(devouring_black_holes,bh)
		end
	end
	local p = getPlayerShip(-1)
	local p_x, p_y = p:getPosition()
	local reading_angle = angleFromVectorNorth(devouring_origin_x, devouring_origin_y, p_x, p_y)
	p:addToShipLog(string.format(_("goal-shipLog","We are getting some unusual readings at bearing %i"),math.floor(reading_angle)),"Magenta")
	central_control = Artifact():setPosition(devouring_origin_x, devouring_origin_y):setDescriptions(_("scienceDescription-artifact","Alien technological device"),_("scienceDescription-artifact","Alien black hole control mechanism [87% confidence]"))
	central_control:setScanningParameters(1,2):setRadarSignatureInfo(.9,0,0)
	central_control:allowPickup(false)
	central_control:onPlayerCollision(handleCentralControl)
	control_stage = 0
	--	stage 0:
	--		Player action: scan then collide
	--			On collision without scan: 
	--				player ship thrown 20u, scanners disabled, remain stage 0
	--			On collision with scan: 
	--				One black hole disabled, player ship thrown 20u, 
	--				rotate black holes in updateDevouringBlackHoles, move to stage 1
	--	stage 1:
	--		Player action: scan then collide
	--			On collision without scan: 
	--				player ship thrown 25u, scanners disabled, remain stage 1
	--			On collision with scan: 
	--				One black hole disabled, player ship thrown 20u, static message to relay
	--				add inner defense platforms in handleCentralControl, move to stage 2
	--	stage 2:
	--		Player action: scan then collide
	--			On collision without scan: 
	--				player ship thrown 30u, scanners disabled, remain stage 2
	--			On collision with scan: 
	--				One black hole disabled, player ship thrown 20u, 
	--				commsCentralControlStage2: division report
	--				nebula covers artifact in updateDevouringBlackHoles, move to stage 3
	--	stage 3:
	--		Player action: scan then collide
	--			On collision without scan: 
	--				player ship thrown 35u, scanners disabled, remain stage 3
	--			On collision with scan:
	--				player thrown 20u, commsCentralControlStage3: division report, halt dark or light
	--				black holes close to 10k in handleCentralControl, move to stage 4
	--	stage 4:
	--		Player action: scan then collide
	--			On collision without scan:
	--				player thrown 40u, scanners disabled, remain stage 4
	--			On collision with scan:
	--				player thrown 20u, commsCentralControlStage4: Research review, division report, category report, halt light or dark
	--				add gateway controllers in handleCentralControl, move to stage 5
	--	stage 5:
	--		Player action: scan then collide, first with door, then with central controller
	--			On collision without scan:
	--				central controller: player thrown 45u, scanners disabled, remain stage 5
	--				door or non-door: throw player 40, disable scanners, remain stage 5
	--			On collision with scan:
	--				non-door: throw player 40u
	--				door: mark player as having passed through door
	--				controller: if not through door first, player thrown 45u, scanners disabled, remain stage 5
	--				controller (after passing through door):
	--				player thrown 20u, commsCentralControlStage5: Research review of summary and practicum, division report, category report, halt light, dark, small, medium or large
	--				add exterior gateway controller ships that stand ground, move to stage 6
	--	stage 6:
	--		Player action: scan then collide, first with door, then with central controller
	--			On collision without scan:
	--				controller: throw player 50u, scanners disabled, remain stage 6
	--				door or non-door: throw player 40u, disable scanners, remain stage 5
	--			On collision with scan:
	--				non-door: throw player 40u
	--				door: mark player as having passed through door
	--				controller: if not through door first, player thrown 50u, scanners disabled, remain stage 5
	--				controller (after passing through door):
	--				player thrown 20u, commsCentralControlStage6: Research review (summary, practicum, correspondence and references), division report, category report, halt light, dark, small, medium or large
	--				add double exterior guards, move to stage 7
	--	stage 7:
	--		Player action: scan then collide, first with door then with controller
	--			On collision without scan:
	--				controller: throw player 55u, disable scanners, remain stage 7
	--				door or non-door: thrown player 40u, disable scanners, remain stage 7
	--			On collision with scan:
	--				non-door: throw player 40u
	--				door: mark player as having passed through door
	--				controller: if not through door first, throw player 55u, disable scanners, remain stage 7
	--				controller (after passing through door):
	--				player thrown 20u, commsCentralControlStage6: Research review (summary, practicum, correspondence and references), division report, category report, halt light, dark, small, medium or large
	--				add warp jammer, move to stage 8
	--	stage 8:
	--		Player action: scan then collide, first with door then with controller
	--			On collision without scan:
	--				controller: throw player 60u, disable scanners, remain stage 8
	--				door or non-door: thrown player 40u, disable scanners, remain stage 8
	--			On collision with scan:
	--				non-door: throw player 40u
	--				door: mark player as having passed through door
	--				controller: if not through door first, throw player 60u, disable scanners, remain stage 8
	--				controller (after passing through door):
	--				player thrown 20u, commsCentralControlStage6: Research review (summary, practicum, correspondence and references), division report, category report, halt light, dark, small, medium or large
	orbiting_black_holes = {}
	local obh_angle = 0
	for i=1,6 do
		local obh_x, obh_y = vectorFromAngleNorth(obh_angle,12000)
		local bh = BlackHole():setPosition(devouring_origin_x + obh_x,devouring_origin_y + obh_y)
		bh.angle = obh_angle
		bh.radius = 12000
		bh.rotation_speed = 1.5
		table.insert(orbiting_black_holes,bh)
		obh_angle = obh_angle + 60
	end
end
function centralToss(player,throw_distance)
	local throw_x, throw_y = vectorFromAngle(random(0,360),throw_distance)
	player:setPosition(devouring_origin_x + throw_x, devouring_origin_y + throw_y)
	player:setCanScan(false)
	local toss_burnout_message = "toss_burnout_message"
	player:addCustomMessage("Science",toss_burnout_message,_("msgScience","The unscanned alien technological device teleported us away and damaged our scanners"))
	local toss_burnout_message_ops = "toss_burnout_message_ops"
	player:addCustomMessage("Operations",toss_burnout_message_ops,_("msgOperations","The unscanned alien technological device teleported us away and damaged our scanners"))
end
function handleCentralControl(self,player)
	local throw_20_x, throw_20_y = vectorFromAngle(random(0,360),20000)
	if control_stage == 0 then
		if self:isScannedBy(player) then
			for i=1,#devouring_black_holes do
				local dbh = devouring_black_holes[i]
				dbh:setCallSign(dbh.name)
				if i <= #devouring_black_holes / 2 then
					dbh.division = _("securityProtocol-comms","Light")
				else
					dbh.division = _("securityProtocol-comms","Dark")
				end
			end
			--	stop a random devouring black hole
			local selected_bh = math.random(1,#devouring_black_holes)
			local halted_bh = devouring_black_holes[selected_bh]
			devouring_black_holes[selected_bh] = devouring_black_holes[#devouring_black_holes]
			devouring_black_holes[#devouring_black_holes] = nil
			control_stage = 1
			local park_x, park_y = vectorFromAngleNorth(gross_angle,300000 + (10000*control_stage))
			local halt_x, halt_y = halted_bh:getPosition()
			halted_bh:setPosition(park_x + halt_x, park_y + halt_y)
			--	teleport player and tell them what happened
			player:setPosition(devouring_origin_x + throw_20_x, devouring_origin_y + throw_20_y)
			local stage_1_success_message = "stage_1_success_message"
			player:addCustomMessage("Science",stage_1_success_message,_("msgScience","We brought the alien black hole control mechanism aboard and tried to access it. It seems to have teleported us away, but has moved one of the black holes. It has also plugged its names of the black holes into our computer systems."))
			local stage_1_success_message_ops = "stage_1_success_message_ops"
			player:addCustomMessage("Operations",stage_1_success_message_ops,_("msgOperations","We brought the alien black hole control mechanism aboard and tried to access it. It seems to have teleported us away, but has moved one of the black holes. It has also plugged its names of the black holes into our computer systems."))
			central_control:setDescriptions(_("scienceDescription-artifact","Reconfigured alien technological device"),_("scienceDescription-artifact","Alien black hole control mechanism [92% confidence]"))
			if random(1,100) < 50 then
				central_control_scan_complexity = 2
				central_control_scan_depth = 2
			else
				central_control_scan_complexity = 1
				central_control_scan_depth = 3
			end
			central_control:setScanningParameters(central_control_scan_complexity,central_control_scan_depth)
			central_control:setScanned(false)
			--rotating black holes (see updateDevouringBlackHoles)
		else
			centralToss(player,20000)
		end
	elseif control_stage == 1 then
		if self:isScannedBy(player) then
			local selected_bh = math.random(1,#devouring_black_holes)
			local halted_bh = devouring_black_holes[selected_bh]
			devouring_black_holes[selected_bh] = devouring_black_holes[#devouring_black_holes]
			devouring_black_holes[#devouring_black_holes] = nil
			--	Add inner defense platforms of various factions
			central_control_defense_platforms = {}
			local platform_factions = {"Kraylor","Exuari","Ktlitans","Arlenians","Ghosts"}
			local bhdp_angle = random(0,360)
			for i=1,5 do
				local bhdp = CpuShip():setTemplate("Defense platform"):setFaction(tableRemoveRandom(platform_factions)):orderStandGround()
				local bhdp_x, bhdp_y = vectorFromAngle(bhdp_angle,4000)
				bhdp:setPosition(devouring_origin_x + bhdp_x, devouring_origin_y + bhdp_y)
				table.insert(central_control_defense_platforms,bhdp)
				bhdp_angle = (bhdp_angle + 72) % 360
			end
			control_stage = 2
			local park_x, park_y = vectorFromAngleNorth(gross_angle,300000 + (10000*control_stage))
			local halt_x, halt_y = halted_bh:getPosition()
			halted_bh:setPosition(park_x + halt_x, park_y + halt_y)
			player:setPosition(devouring_origin_x + throw_20_x, devouring_origin_y + throw_20_y)
			local stage_2_success_message = "stage_2_success_message"
			local msg = _("msgScience","We picked up the alien black hole control mechanism. We tried an alternate access method, but it teleported us away again. It has moved one of the black holes")
			player:addCustomMessage("Science",stage_2_success_message,msg)
			local stage_2_success_message_ops = "stage_2_success_message_ops"
			player:addCustomMessage("Operations",stage_2_success_message_ops,msg)
			self:setCallSign(_("securityProtocol-comms","Security Protocol Subroutine"))
			self:sendCommsMessage(player,_("securityProtocol-comms","Sponsored by the Astronomy, Physics and Sociology departments\nSecured content access error"))
			self:setCallSign("")
			central_control:setDescriptions(_("scienceDescription-artifact","Weird alien technological device"),_("scienceDescription-artifact","Alien black hole control mechanism [94% confidence]"))
			if random(1,100) < 50 then
				central_control_scan_complexity = central_control_scan_complexity + 1
			else
				central_control_scan_depth = central_control_scan_depth + 1
			end
			central_control:setScanningParameters(central_control_scan_complexity,central_control_scan_depth)
			central_control:setScanned(false)
		else
			centralToss(player,25000)
		end
	elseif control_stage == 2 then
		if self:isScannedBy(player) then
			local selected_bh = math.random(1,#devouring_black_holes)
			local halted_bh = devouring_black_holes[selected_bh]
			devouring_black_holes[selected_bh] = devouring_black_holes[#devouring_black_holes]
			devouring_black_holes[#devouring_black_holes] = nil
			control_stage = 3
			local park_x, park_y = vectorFromAngleNorth(gross_angle,300000 + (10000*control_stage))
			local halt_x, halt_y = halted_bh:getPosition()
			halted_bh:setPosition(park_x + halt_x, park_y + halt_y)
			player:setPosition(devouring_origin_x + throw_20_x, devouring_origin_y + throw_20_y)
			local stage_3_success_message = "stage_3_success_message"
			local msg = _("msgScience","We learned quite a bit from our previous efforts to access the alien black hole control mechanism. The error message was especially enlightening. It still teleported us away, but has moved one of the black holes")
			player:addCustomMessage("Science",stage_3_success_message,msg)
			local stage_3_success_message_ops = "stage_3_success_message_ops"
			player:addCustomMessage("Operations",stage_3_success_message_ops,msg)
			self:setCommsScript(""):setCommsFunction(commsCentralControlStage2)
			self:setCallSign(_("securityProtocol-comms","Security Protocol Subroutine"))
			self:openCommsTo(player)
			self:setCallSign("")
			central_control:setDescriptions(_("scienceDescription-artifact","Strange alien technological device"),_("scienceDescription-artifact","Alien black hole control mechanism [96% confidence]"))
			if central_control_scan_complexity >= 4 then
				central_control_scan_depth = central_control_scan_depth + 1
			else
				if random(1,100) < 50 then
					central_control_scan_complexity = central_control_scan_complexity + 1
				else
					central_control_scan_depth = central_control_scan_depth + 1
				end
			end
			central_control:setScanningParameters(central_control_scan_complexity,central_control_scan_depth)
			central_control:setScanned(false)
			central_control_nebula = Nebula():setPosition(devouring_origin_x,devouring_origin_y)	--nebula covers controller
		else
			centralToss(player,30000)
		end
	elseif control_stage == 3 then
		if self:isScannedBy(player) then
			control_stage = 4
			player:setPosition(devouring_origin_x + throw_20_x, devouring_origin_y + throw_20_y)
			local stage_4_success_message = "stage_4_success_message"
			local msg = _("msgScience","Our cyber team got a little further before the alien black hole control mechanism teleported us away. Relay should check the communication linkage we established.")
			player:addCustomMessage("Science",stage_4_success_message,msg)
			local stage_4_success_message_ops = "stage_4_success_message_ops"
			player:addCustomMessage("Operations",stage_4_success_message_ops,msg)
			for _, bh in ipairs(orbiting_black_holes) do	--black holes close to 10k
				bh.radius = 10000
			end
			self:setCommsScript(""):setCommsFunction(commsCentralControlStage3)
			self:setCallSign(_("securityProtocol-comms","Security Protocol Subroutine"))
			self:openCommsTo(player)
			self:setCallSign("")
			central_control:setDescriptions(_("scienceDescription-artifact","Unusual alien technological device"),_("scienceDescription-artifact","Alien black hole control mechanism [97% confidence]"))
			if central_control_scan_complexity >= 4 then
				central_control_scan_depth = central_control_scan_depth + 1
			else
				if random(1,100) < 50 then
					central_control_scan_complexity = central_control_scan_complexity + 1
				else
					central_control_scan_depth = central_control_scan_depth + 1
				end
			end
			central_control:setScanningParameters(central_control_scan_complexity,central_control_scan_depth)
			central_control:setScanned(false)
		else
			centralToss(player,35000)
		end
	elseif control_stage == 4 then
		if self:isScannedBy(player) then
			control_stage = 5
			player:setPosition(devouring_origin_x + throw_20_x, devouring_origin_y + throw_20_y)
			local stage_5_success_message = "stage_5_success_message"
			local msg = _("msgScience","Our hackers believe they have convinced the security protocol subroutine in the alien black hole control mechanism that we're a legitimate user. Relay should check the communication linkage the hackers established.")
			player:addCustomMessage("Science",stage_5_success_message,msg)
			local stage_5_success_message_ops = "stage_5_success_message_ops"
			player:addCustomMessage("Operations",stage_5_success_message_ops,msg)
			for i=1,#devouring_black_holes do
				local dbh = devouring_black_holes[i]
				if i % 3 == 0 then
					dbh.category = _("securityProtocol-comms","Small")
				elseif i % 3 == 1 then
					dbh.category = _("securityProtocol-comms","Medium")
				else
					dbh.category = _("securityProtocol-comms","Large")
				end
			end
			self:setCommsScript(""):setCommsFunction(commsCentralControlStage4)
			self:setCallSign(_("securityProtocol-comms","Security Protocol Subroutine"))
			self:openCommsTo(player)
			self:setCallSign("")
			central_control:setDescriptions(_("scienceDescription-artifact","Extraordinary alien technological device"),_("scienceDescription-artifact","Alien black hole control mechanism [98% confidence]"))
			if central_control_scan_complexity >= 4 then
				central_control_scan_depth = central_control_scan_depth + 1
			else
				if random(1,100) < 50 then
					central_control_scan_complexity = central_control_scan_complexity + 1
				else
					central_control_scan_depth = central_control_scan_depth + 1
				end
			end
			central_control:setScanningParameters(central_control_scan_complexity,central_control_scan_depth)
			central_control:setScanned(false)
			--	gateway controllers
			local spacing = 1000
			local grid_ref = {
				{angle = 0, 	radius = spacing},
				{angle = 45,	radius = math.sqrt(spacing * spacing + spacing * spacing)},
				{angle = 90, 	radius = spacing},
				{angle = 135,	radius = math.sqrt(spacing * spacing + spacing * spacing)},
				{angle = 180, 	radius = spacing},
				{angle = 225,	radius = math.sqrt(spacing * spacing + spacing * spacing)},
				{angle = 270, 	radius = spacing},
				{angle = 315,	radius = math.sqrt(spacing * spacing + spacing * spacing)},
			}
			grid_control = {}
			for i=1,8 do
				local g_x, g_y = vectorFromAngleNorth(grid_ref[i].angle,grid_ref[i].radius)
				local ca = Artifact():setPosition(devouring_origin_x + g_x, devouring_origin_y + g_y)
				ca.angle = grid_ref[i].angle
				ca.radius = grid_ref[i].radius
				ca.rotation_speed = 2
				ca:setDescriptions(_("scienceDescription-artifact","Smaller version of central alien technological device"),_("scienceDescription-artifact","Alien technological device with quantum link to central device"))
				ca:setScanningParameters(2,1):setRadarSignatureInfo(.1,0,.3):allowPickup(false)
				ca:onPlayerCollision(handleGridControl)
				table.insert(grid_control,ca)
			end
			central_control.entered_through_doorway = false
			central_control:setRadarTraceColor(160,82,45)
			local selected_door = math.random(1,#grid_control)
			grid_control[selected_door].door = true
			grid_control[selected_door]:setDescriptions(_("scienceDescription-artifact","Smaller version of central alien technological device"),_("scienceDescription-artifact","Alien technological device with quantum link to central device. Embedded code could be translated as 'doorway.'"))
		else
			centralToss(player,40000)
		end
	elseif control_stage == 5 then
		if self:isScannedBy(player) and self.entered_through_doorway then
			control_stage = 6
			player:setPosition(devouring_origin_x + throw_20_x, devouring_origin_y + throw_20_y)
			local stage_6_success_message = "stage_6_success_message"
			local msg = _("msgScience","We tweaked our access methods so that we resemble a maintenance user to the security subroutine in the alien black hole control mechanism has teleported us away. Hopefully, Relay can make good use of this access.")
			player:addCustomMessage("Science",stage_6_success_message,msg)
			local stage_6_success_message_ops = "stage_6_success_message_ops"
			player:addCustomMessage("Operations",stage_6_success_message_ops,msg)
			self:setCommsScript(""):setCommsFunction(commsCentralControlStage5)
			self:setCallSign(_("securityProtocol-comms","Security Protocol Subroutine"))
			self:openCommsTo(player)
			self:setCallSign("")
			central_control:setDescriptions(_("scienceDescription-artifact","Jumpy alien technological device"),_("scienceDescription-artifact","Alien black hole control mechanism [99% confidence]"))
			if central_control_scan_complexity >= 4 then
				central_control_scan_depth = central_control_scan_depth + 1
			else
				if random(1,100) < 50 then
					central_control_scan_complexity = central_control_scan_complexity + 1
				else
					central_control_scan_depth = central_control_scan_depth + 1
				end
			end
			central_control:setScanningParameters(central_control_scan_complexity,central_control_scan_depth)
			central_control:setScanned(false)
			--	reset controller gateway
			for index, ca in ipairs(grid_control) do
				ca:setScanned(false)
				ca.door = false
				ca:setRadarTraceColor(255,255,255)
				ca:setDescriptions(_("scienceDescription-artifact","Smaller version of central alien technological device"),_("scienceDescription-artifact","Alien technological device with quantum link to central device"))
			end
			central_control.entered_through_doorway = false
			local selected_door = math.random(1,#grid_control)
			grid_control[selected_door].door = true
			grid_control[selected_door]:setDescriptions(_("scienceDescription-artifact","Smaller version of central alien technological device"),_("scienceDescription-artifact","Alien technological device with quantum link to central device. Embedded code could be translated as 'doorway.'"))
			--	exterior controller guards
			local guard_angle = 0
			control_guards = {}
			for i=1,12 do
				local cdg = CpuShip():setTemplate("Adder MK5"):setFaction("Exuari"):orderStandGround()
				local g_x, g_y = vectorFromAngleNorth(guard_angle,18000)
				cdg:setPosition(devouring_origin_x + g_x, devouring_origin_y + g_y):setCallSign(string.format("CDG%i",i))
				table.insert(control_guards,cdg)
				guard_angle = guard_angle + 30
			end
		else
			centralToss(player,45000)
		end
	elseif control_stage == 6 then
		if self:isScannedBy(player) and self.entered_through_doorway then
			control_stage = 7
			player:setPosition(devouring_origin_x + throw_20_x, devouring_origin_y + throw_20_y)
			local stage_7_success_message = "stage_7_success_message"
			local msg = _("msgScience","We've hacked in as one of the research authors on the alien black hole control mechanism. We still got teleported away, but we should be able to get more information from the Relay link.")
			player:addCustomMessage("Science",stage_7_success_message,msg)
			local stage_7_success_message_ops = "stage_7_success_message_ops"
			player:addCustomMessage("Operations",stage_7_success_message_ops,msg)
			self:setCommsScript(""):setCommsFunction(commsCentralControlStage6)
			self:setCallSign(_("securityProtocol-comms","Security Protocol Subroutine"))
			self:openCommsTo(player)
			self:setCallSign("")
			central_control:setDescriptions(_("scienceDescription-artifact","Funky alien technological device"),_("scienceDescription-artifact","Alien black hole control mechanism [99.6% confidence]"))
			local scan_complexity = player:scanningComplexity(central_control)
			local scan_depth = player:scanningChannelDepth(central_control)
			if scan_complexity >= 4 then
				central_control:setScanningParameters(scan_complexity,scan_depth+1)
			else
				if random(1,100) < 50 then
					central_control:setScanningParameters(scan_complexity+1,scan_depth)
				else
					central_control:setScanningParameters(scan_complexity,scan_depth+1)
				end
			end
			--	reset gateway
			central_control:setScanned(false)
			for index, ca in ipairs(grid_control) do
				ca:setScanned(false)
				ca.door = false
				ca:setRadarTraceColor(255,255,255)
				ca:setDescriptions(_("scienceDescription-artifact","Smaller version of central alien technological device"),_("scienceDescription-artifact","Alien technological device with quantum link to central device"))
			end
			central_control.entered_through_doorway = false
			local selected_door = math.random(1,#grid_control)
			grid_control[selected_door].door = true
			grid_control[selected_door]:setDescriptions(_("scienceDescription-artifact","Smaller version of central alien technological device"),_("scienceDescription-artifact","Alien technological device with quantum link to central device. Embedded code could be translated as 'doorway.'"))
			--	get rid of old guards
			for _, ship in ipairs(control_guards) do
				ship:destroy()
			end
			--	double the guards
			local guard_angle = 0
			control_guards = {}
			for i=1,12 do
				local cdg = CpuShip():setTemplate("Adder MK5"):setFaction("Exuari"):orderStandGround()
				cdg:setWeaponStorageMax("Homing",2)			--more (vs 0)
				cdg:setWeaponStorage("Homing",2)
				local g_x, g_y = vectorFromAngleNorth(guard_angle,18000)
				cdg:setPosition(devouring_origin_x + g_x, devouring_origin_y + g_y):setCallSign(string.format("CDG%i",i))
				table.insert(control_guards,cdg)
				cdg = CpuShip():setTemplate("Phobos T3"):setFaction("Exuari"):orderStandGround()
				g_x, g_y = vectorFromAngleNorth(guard_angle + 15,18000)
				cdg:setPosition(devouring_origin_x + g_x, devouring_origin_y + g_y):setCallSign(string.format("CDG%i",i+12))
				table.insert(control_guards,cdg)
				guard_angle = guard_angle + 30
			end
		else
			centralToss(player,50000)
		end
	elseif control_stage == 7 then
		if self:isScannedBy(player) and self.entered_through_doorway then
			control_stage = 8
			player:setPosition(devouring_origin_x + throw_20_x, devouring_origin_y + throw_20_y)
			local stage_8_success_message = "stage_8_success_message"
			local msg = _("msgScience","We're in as an author again with a couple of minor tweaks that we hope will grant further access. Relay should check it out. However, indications show that the physical security is more subtly dangerous.")
			player:addCustomMessage("Science",stage_8_success_message,msg)
			local stage_8_success_message_ops = "stage_8_success_message_ops"
			player:addCustomMessage("Operations",stage_8_success_message_ops,msg)
			self:setCommsScript(""):setCommsFunction(commsCentralControlStage6)
			self:setCallSign(_("securityProtocol-comms","Security Protocol Subroutine"))
			self:openCommsTo(player)
			self:setCallSign("")
			central_control:setDescriptions(_("scienceDescription-artifact","Disparaging alien technological device"),_("scienceDescription-artifact","Alien black hole control mechanism [99.7% confidence]"))
			local scan_complexity = player:scanningComplexity(central_control)
			local scan_depth = player:scanningChannelDepth(central_control)
			if scan_complexity >= 4 then
				central_control:setScanningParameters(scan_complexity,scan_depth+1)
			else
				if random(1,100) < 50 then
					central_control:setScanningParameters(scan_complexity+1,scan_depth)
				else
					central_control:setScanningParameters(scan_complexity,scan_depth+1)
				end
			end
			--	reset gateway
			central_control:setScanned(false)
			for index, ca in ipairs(grid_control) do
				ca:setScanned(false)
				ca.door = false
				ca:setRadarTraceColor(255,255,255)
				ca:setDescriptions(_("scienceDescription-artifact","Smaller version of central alien technological device"),_("scienceDescription-artifact","Alien technological device with quantum link to central device"))
			end
			central_control.entered_through_doorway = false
			local selected_door = math.random(1,#grid_control)
			grid_control[selected_door].door = true
			grid_control[selected_door]:setDescriptions(_("scienceDescription-artifact","Smaller version of central alien technological device"),_("scienceDescription-artifact","Alien technological device with quantum link to central device. Embedded code could be translated as 'doorway.'"))
			--	get rid of old guards
			for _, ship in ipairs(control_guards) do
				ship:destroy()
			end
			--	double the guards
			local guard_angle = 0
			control_guards = {}
			for i=1,12 do
				local cdg = CpuShip():setTemplate("Adder MK5"):setFaction("Exuari"):orderStandGround()
				cdg:setWeaponStorageMax("Homing",2)			--more (vs 0)
				cdg:setWeaponStorage("Homing",2)
				local g_x, g_y = vectorFromAngleNorth(guard_angle,18000)
				cdg:setPosition(devouring_origin_x + g_x, devouring_origin_y + g_y):setCallSign(string.format("CDG%i",i))
				table.insert(control_guards,cdg)
				cdg = CpuShip():setTemplate("Phobos T3"):setFaction("Exuari"):orderStandGround()
				g_x, g_y = vectorFromAngleNorth(guard_angle + 15,18000)
				cdg:setPosition(devouring_origin_x + g_x, devouring_origin_y + g_y):setCallSign(string.format("CDG%i",i+12))
				table.insert(control_guards,cdg)
				guard_angle = guard_angle + 30
			end
			--	warp jammer
			if central_control_warp_jammer == nil or not central_control_warp_jammer:isValid() then
				central_control_warp_jammer = WarpJammer():setRange(10000):setPosition(devouring_origin_x + 250,devouring_origin_y + 250)
			end
		else
			centralToss(player,55000)
		end
	elseif control_stage == 8 then
		if self:isScannedBy(player) and self.entered_through_doorway then
			control_stage = 9
			player:setPosition(devouring_origin_x + throw_20_x, devouring_origin_y + throw_20_y)
			local stage_9_success_message = "stage_9_success_message"
			local msg = _("msgScience","We're in as an author again with a couple of minor tweaks that we hope will grant further access. Relay should check it out. However, indications show that the physical security is more subtly dangerous.")
			player:addCustomMessage("Science",stage_9_success_message,msg)
			local stage_9_success_message_ops = "stage_9_success_message_ops"
			player:addCustomMessage("Operations",stage_9_success_message_ops,msg)
			self:setCommsScript(""):setCommsFunction(commsCentralControlStage6)
			self:setCallSign(_("securityProtocol-comms","Security Protocol Subroutine"))
			self:openCommsTo(player)
			self:setCallSign("")
			central_control:setDescriptions(_("scienceDescription-artifact","Paranoid alien technological device"),_("scienceDescription-artifact","Alien black hole control mechanism [99.75% confidence]"))
			local scan_complexity = player:scanningComplexity(central_control)
			local scan_depth = player:scanningChannelDepth(central_control)
			if scan_complexity >= 4 then
				central_control:setScanningParameters(scan_complexity,scan_depth+1)
			else
				if random(1,100) < 50 then
					central_control:setScanningParameters(scan_complexity+1,scan_depth)
				else
					central_control:setScanningParameters(scan_complexity,scan_depth+1)
				end
			end
			--	reset gateway
			central_control:setScanned(false)
			for index, ca in ipairs(grid_control) do
				ca:setScanned(false)
				ca.door = false
				ca:setRadarTraceColor(255,255,255)
				ca:setDescriptions(_("scienceDescription-artifact","Smaller version of central alien technological device"),_("scienceDescription-artifact","Alien technological device with quantum link to central device"))
			end
			central_control.entered_through_doorway = false
			local selected_door = math.random(1,#grid_control)
			grid_control[selected_door].door = true
			grid_control[selected_door]:setDescriptions(_("scienceDescription-artifact","Smaller version of central alien technological device"),_("scienceDescription-artifact","Alien technological device with quantum link to central device. Embedded code could be translated as 'doorway.'"))
			--	get rid of old guards
			for _, ship in ipairs(control_guards) do
				ship:destroy()
			end
			--	double the guards
			local guard_angle = 0
			control_guards = {}
			for i=1,12 do
				local cdg = CpuShip():setTemplate("Adder MK9"):setFaction("Exuari"):orderStandGround()
				cdg:setWeaponStorageMax("Homing",2)			--more (vs 0)
				cdg:setWeaponStorage("Homing",2)
				local g_x, g_y = vectorFromAngleNorth(guard_angle,18000)
				cdg:setPosition(devouring_origin_x + g_x, devouring_origin_y + g_y):setCallSign(string.format("CDG%i",i))
				table.insert(control_guards,cdg)
				cdg = CpuShip():setTemplate("Phobos T3"):setFaction("Exuari"):orderStandGround()
				cdg:setWeaponStorageMax("Nuke",2)			--more (vs 0)
				cdg:setWeaponStorage("Nuke",2)
				g_x, g_y = vectorFromAngleNorth(guard_angle + 15,18000)
				cdg:setPosition(devouring_origin_x + g_x, devouring_origin_y + g_y):setCallSign(string.format("CDG%i",i+12))
				table.insert(control_guards,cdg)
				guard_angle = guard_angle + 30
			end
			--	warp jammer
			if central_control_warp_jammer == nil or not central_control_warp_jammer:isValid() then
				central_control_warp_jammer = WarpJammer():setRange(10000):setPosition(devouring_origin_x + 250,devouring_origin_y + 250)
			end
		else
			centralToss(player,60000)
		end
	end
end
function commsCentralControlStage2()
	setCommsMessage(_("securityProtocol-comms","Sponsored by the Astronomy, Physics and Sociology departments\nPartial access granted. Progress halted on singularity identified during interaction.\n\nRequest?"))
	addCommsReply(_("securityProtocol-comms","Display Divisions"),function()
		local light_list = ""
		local dark_list = ""
		for i=1,#devouring_black_holes do
			local dbh = devouring_black_holes[i]
			if dbh.division == _("securityProtocol-comms","Light") then
				if light_list == "" then
					light_list = _("securityProtocol-comms","Light: ") .. dbh.name
				else
					light_list = light_list .. ", " .. dbh.name
				end
			else
				if dark_list == "" then
					dark_list = _("securityProtocol-comms","Dark: ") .. dbh.name
				else
					dark_list = dark_list .. ", " .. dbh.name
				end
			end
		end
		setCommsMessage(string.format(_("securityProtocol-comms","Division report:\n%s\n%s"),light_list,dark_list))
		central_control:setCommsScript(""):setCommsFunction(nil)
		addCommsReply(_("Back","Back"),function()
			setCommsMessage(_("securityProtocol-comms","Unauthorized access detected.\nInitiating security review."))
			central_control:setCommsScript(""):setCommsFunction(nil)
		end)
	end)
end
function commsCentralControlStage3()
	setCommsMessage(_("securityProtocol-comms","Sponsored by the Astronomy, Physics and Sociology departments\nTreatise on the physical and socioeconomic interactions between graduated singularities and sundry established population groups (working title)\nPartial access granted.\n\nRequest?"))
	addCommsReply(_("securityProtocol-comms","Display Divisions"),function()
		local light_list = ""
		local dark_list = ""
		for i=1,#devouring_black_holes do
			local dbh = devouring_black_holes[i]
			if dbh.division == _("securityProtocol-comms","Light") then
				if light_list == "" then
					light_list = _("securityProtocol-comms","Light: ") .. dbh.name
				else
					light_list = light_list .. ", " .. dbh.name
				end
			else
				if dark_list == "" then
					dark_list = _("securityProtocol-comms","Dark: ") .. dbh.name
				else
					dark_list = dark_list .. ", " .. dbh.name
				end
			end
		end
		setCommsMessage(string.format(_("securityProtocol-comms","Division report:\n%s\n%s"),light_list,dark_list))
		if difficulty < 1 then
			addCommsReply(_("Back","Back"),commsCentralControlStage3)
		end
		central_control:setCommsScript(""):setCommsFunction(nil)
	end)
	addCommsReply(_("securityProtocol-comms","Halt a Light division singularity"),function()
		local light_list = {}
		for i=1,#devouring_black_holes do
			if devouring_black_holes[i].division == _("securityProtocol-comms","Light") then
				table.insert(light_list,i)	--save index
			end
		end
		local selected_bh = light_list[math.random(1,#light_list)]
		local park_x, park_y = vectorFromAngleNorth(gross_angle,300000 + (10000*control_stage))
		local halt_x, halt_y = devouring_black_holes[selected_bh]:getPosition()
		devouring_black_holes[selected_bh]:setPosition(park_x + halt_x, park_y + halt_y)
		setCommsMessage(string.format(_("securityProtocol-comms","%s parked."),devouring_black_holes[selected_bh].name))
		devouring_black_holes[selected_bh] = devouring_black_holes[#devouring_black_holes]
		devouring_black_holes[#devouring_black_holes] = nil
		central_control:setCommsScript(""):setCommsFunction(nil)
		addCommsReply(_("Back","Back"),function()
			setCommsMessage(_("securityProtocol-comms","Unauthorized access detected.\nInitiating security review."))
			central_control:setCommsScript(""):setCommsFunction(nil)
		end)
	end)
	addCommsReply(_("securityProtocol-comms","Halt a Dark division singularity"),function()
		local dark_list = {}
		for i=1,#devouring_black_holes do
			if devouring_black_holes[i].division == _("securityProtocol-comms","Dark") then
				table.insert(dark_list,i)	--save index
			end
		end
		local selected_bh = dark_list[math.random(1,#dark_list)]
		local park_x, park_y = vectorFromAngleNorth(gross_angle,300000 + (10000*control_stage))
		local halt_x, halt_y = devouring_black_holes[selected_bh]:getPosition()
		devouring_black_holes[selected_bh]:setPosition(park_x + halt_x, park_y + halt_y)
		setCommsMessage(string.format(_("securityProtocol-comms","%s parked."),devouring_black_holes[selected_bh].name))
		devouring_black_holes[selected_bh] = devouring_black_holes[#devouring_black_holes]
		devouring_black_holes[#devouring_black_holes] = nil
		central_control:setCommsScript(""):setCommsFunction(nil)
		addCommsReply(_("Back","Back"),function()
			setCommsMessage(_("securityProtocol-comms","Unauthorized access detected.\nInitiating security review."))
			central_control:setCommsScript(""):setCommsFunction(nil)
		end)
	end) 
end
function commsCentralControlStage4()
	setCommsMessage(_("securityProtocol-comms","Sponsored by the Astronomy, Physics and Sociology departments\nTreatise on the physical and socioeconomic interactions between graduated singularities and sundry established population groups (working title)\nLow level user access granted.\n\nRequest?"))
	addCommsReply(_("securityProtocol-comms","Review Current Research"),function()
		setCommsMessage(_("securityProtocol-comms","Summary: This research effort theorizes a number of different categories of responses between differently measured singularities and populations of different origins (see figure 1). There is disagreement between the sponsoring departments as to the likliest outcomes. The astronomy representative, Rosenberg, postulates technological innovation due to the proximity of the singularity and the pressure associated with survival. Strickland, from the sociology department, disagrees: people will be so focused on survival, they'll ignore any potential innovation. The physics representative takes a compromise position: some innovation will occur, but it's likely to get lost in the general destruction. Each representative has outlined their supporting formulas and charts in appendices A, B and C respectively."))
		addCommsReply(_("Back","Back"),commsCentralControlStage4)
	end)
	addCommsReply(_("securityProtocol-comms","Display Divisions"),function()
		local light_list = ""
		local dark_list = ""
		for i=1,#devouring_black_holes do
			local dbh = devouring_black_holes[i]
			if dbh.division == _("securityProtocol-comms","Light") then
				if light_list == "" then
					light_list = _("securityProtocol-comms","Light: ") .. dbh.name
				else
					light_list = light_list .. ", " .. dbh.name
				end
			else
				if dark_list == "" then
					dark_list = _("securityProtocol-comms","Dark: ") .. dbh.name
				else
					dark_list = dark_list .. ", " .. dbh.name
				end
			end
		end
		setCommsMessage(string.format(_("securityProtocol-comms","Division report:\n%s\n%s"),light_list,dark_list))
		if difficulty < 2 then
			addCommsReply(_("Back","Back"),commsCentralControlStage4)
		else
			addCommsReply(_("Back","Back"),function()
				setCommsMessage(_("securityProtocol-comms","Unauthorized access detected.\nInitiating security review."))
				central_control:setCommsScript(""):setCommsFunction(nil)
			end)
		end
		central_control:setCommsScript(""):setCommsFunction(nil)
	end)
	addCommsReply(_("securityProtocol-comms","Display Categories"),function()
		local small_list = ""
		local medium_list = ""
		local large_list = ""
		for i=1,#devouring_black_holes do
			local dbh = devouring_black_holes[i]
			if dbh.category == _("securityProtocol-comms","Small") then
				if small_list == "" then
					small_list = _("securityProtocol-comms","Small: ") .. dbh.name
				else
					small_list = small_list .. ", " .. dbh.name
				end
			elseif dbh.category == _("securityProtocol-comms","Medium") then
				if medium_list == "" then
					medium_list = _("securityProtocol-comms","Medium: ") .. dbh.name
				else
					medium_list = medium_list .. ", " .. dbh.name
				end
			else
				if large_list == "" then
					large_list = _("securityProtocol-comms","Large: ") .. dbh.name
				else
					large_list = large_list .. ", " .. dbh.name
				end
			end
		end
		setCommsMessage(string.format(_("securityProtocol-comms","Category report:\n%s\n%s\n%s"),small_list,medium_list,large_list))
		if difficulty < 1 then
			addCommsReply(_("Back","Back"),commsCentralControlStage4)
		else
			addCommsReply(_("Back","Back"),function()
				setCommsMessage(_("securityProtocol-comms","Unauthorized access detected.\nInitiating security review."))
				central_control:setCommsScript(""):setCommsFunction(nil)
			end)
		end
		central_control:setCommsScript(""):setCommsFunction(nil)
	end)
	addCommsReply(_("securityProtocol-comms","Halt a Light division singularity"),function()
		local light_list = {}
		for i=1,#devouring_black_holes do
			if devouring_black_holes[i].division == "Light" then
				table.insert(light_list,i)
			end
		end
		local selected_bh = light_list[math.random(1,#light_list)]
		local park_x, park_y = vectorFromAngleNorth(gross_angle,300000 + (10000*control_stage))
		local halt_x, halt_y = devouring_black_holes[selected_bh]:getPosition()
		devouring_black_holes[selected_bh]:setPosition(park_x + halt_x, park_y + halt_y)
		setCommsMessage(string.format(_("securityProtocol-comms","%s parked."),devouring_black_holes[selected_bh].name))
		devouring_black_holes[selected_bh] = devouring_black_holes[#devouring_black_holes]
		devouring_black_holes[#devouring_black_holes] = nil
		central_control:setCommsScript(""):setCommsFunction(nil)
		addCommsReply(_("Back","Back"),function()
			setCommsMessage(_("securityProtocol-comms","Unauthorized access detected.\nInitiating security review."))
			central_control:setCommsScript(""):setCommsFunction(nil)
		end)
	end)
	addCommsReply(_("securityProtocol-comms","Halt a Dark division singularity"),function()
		local dark_list = {}
		for i=1,#devouring_black_holes do
			if devouring_black_holes[i].division == _("securityProtocol-comms","Dark") then
				table.insert(dark_list,i)
			end
		end
		local selected_bh = dark_list[math.random(1,#dark_list)]
		local park_x, park_y = vectorFromAngleNorth(gross_angle,300000 + (10000*control_stage))
		local halt_x, halt_y = devouring_black_holes[selected_bh]:getPosition()
		devouring_black_holes[selected_bh]:setPosition(park_x + halt_x, park_y + halt_y)
		setCommsMessage(string.format(_("securityProtocol-comms","%s parked."),devouring_black_holes[selected_bh].name))
		devouring_black_holes[selected_bh] = devouring_black_holes[#devouring_black_holes]
		devouring_black_holes[#devouring_black_holes] = nil
		central_control:setCommsScript(""):setCommsFunction(nil)
		addCommsReply(_("Back","Back"),function()
			setCommsMessage(_("securityProtocol-comms","Unauthorized access detected.\nInitiating security review."))
			central_control:setCommsScript(""):setCommsFunction(nil)
		end)
	end) 
end
function commsCentralControlStage5()
	setCommsMessage(_("securityProtocol-comms","Sponsored by the Astronomy, Physics and Sociology departments\nTreatise on the physical and socioeconomic interactions between graduated singularities and sundry established population groups (working title)\nMaintenance level user access granted.\n\nRequest?"))
	addCommsReply(_("securityProtocol-comms","Review Current Research"),function()
		setCommsMessage(_("securityProtocol-comms","Specify research section"))
		addCommsReply(_("securityProtocol-comms","Summary"),function()
			setCommsMessage(_("securityProtocol-comms","This research effort theorizes a number of different categories of responses between differently measured singularities and populations of different origins (see figure 1). There is disagreement between the sponsoring departments as to the likliest outcomes. The astronomy representative, Rosenberg, postulates technological innovation due to the proximity of the singularity and the pressure associated with survival. Strickland, from the sociology department, disagrees: people will be so focused on survival, they'll ignore any potential innovation. The physics representative takes a compromise position: some innovation will occur, but it's likely to get lost in the general destruction. Each representative has outlined their supporting formulas and charts in appendices A, B and C respectively."))
			addCommsReply(_("Back","Back"),commsCentralControlStage5)
		end)
		addCommsReply(_("securityProtocol-comms","Practicum"),function()
			setCommsMessage(_("securityProtocol-comms","To verify, validate, invalidate and/or refute the assertions in this research, a large scale theoretical experiment is recommended. Seed funding from each department should be set aside for future investment along with any excess technological resources. Modeling is deemed insufficient for accurate result determination.\n\nDue to lack of resources, this research project will be filed under future potential research projects. Current backlog: 3,435,665 research projects."))
			addCommsReply(_("Back","Back"),commsCentralControlStage5)
		end)
		addCommsReply(_("Back","Back"),commsCentralControlStage5)
	end)
	addCommsReply(_("securityProtocol-comms","Display Divisions"),function()
		local light_list = ""
		local dark_list = ""
		for i=1,#devouring_black_holes do
			local dbh = devouring_black_holes[i]
			if dbh.division == _("securityProtocol-comms","Light") then
				if light_list == "" then
					light_list = _("securityProtocol-comms","Light: ") .. dbh.name
				else
					light_list = light_list .. ", " .. dbh.name
				end
			else
				if dark_list == "" then
					dark_list = _("securityProtocol-comms","Dark: ") .. dbh.name
				else
					dark_list = dark_list .. ", " .. dbh.name
				end
			end
		end
		setCommsMessage(string.format(_("securityProtocol-comms","Division report:\n%s\n%s"),light_list,dark_list))
		addCommsReply(_("Back","Back"),commsCentralControlStage5)
		central_control:setCommsScript(""):setCommsFunction(nil)
	end)
	addCommsReply(_("securityProtocol-comms","Display Categories"),function()
		local small_list = ""
		local medium_list = ""
		local large_list = ""
		for i=1,#devouring_black_holes do
			local dbh = devouring_black_holes[i]
			if dbh.category == _("securityProtocol-comms","Small") then
				if small_list == "" then
					small_list = _("securityProtocol-comms","Small: ") .. dbh.name
				else
					small_list = small_list .. ", " .. dbh.name
				end
			elseif dbh.category == _("securityProtocol-comms","Medium") then
				if medium_list == "" then
					medium_list = _("securityProtocol-comms","Medium: ") .. dbh.name
				else
					medium_list = medium_list .. ", " .. dbh.name
				end
			else
				if large_list == "" then
					large_list = _("securityProtocol-comms","Large: ") .. dbh.name
				else
					large_list = large_list .. ", " .. dbh.name
				end
			end
		end
		setCommsMessage(string.format(_("securityProtocol-comms","Category report:\n%s\n%s\n%s"),small_list,medium_list,large_list))
		if difficulty < 2 then
			addCommsReply(_("Back","Back"),commsCentralControlStage5)
		else
			addCommsReply(_("Back","Back"),function()
				setCommsMessage(_("securityProtocol-comms","Unauthorized access detected.\nInitiating security review."))
				central_control:setCommsScript(""):setCommsFunction(nil)
			end)
		end
		central_control:setCommsScript(""):setCommsFunction(nil)
	end)
	addCommsReply(_("securityProtocol-comms","Halt a division singularity"),function()
		setCommsMessage(_("securityProtocol-comms","Which division?"))
		addCommsReply(_("securityProtocol-comms","Halt a Light division singularity"),function()
			local light_list = {}
			for i=1,#devouring_black_holes do
				if devouring_black_holes[i].division == _("securityProtocol-comms","Light") then
					table.insert(light_list,i)
				end
			end
			local selected_bh = light_list[math.random(1,#light_list)]
			local park_x, park_y = vectorFromAngleNorth(gross_angle,300000 + (10000*control_stage))
			local halt_x, halt_y = devouring_black_holes[selected_bh]:getPosition()
			devouring_black_holes[selected_bh]:setPosition(park_x + halt_x, park_y + halt_y)
			setCommsMessage(string.format(_("securityProtocol-comms","%s parked."),devouring_black_holes[selected_bh].name))
			devouring_black_holes[selected_bh] = devouring_black_holes[#devouring_black_holes]
			devouring_black_holes[#devouring_black_holes] = nil
			central_control:setCommsScript(""):setCommsFunction(nil)
			addCommsReply(_("Back","Back"),function()
				setCommsMessage(_("securityProtocol-comms","Unauthorized access detected.\nInitiating security review."))
				central_control:setCommsScript(""):setCommsFunction(nil)
			end)
		end)
		addCommsReply(_("securityProtocol-comms","Halt a Dark division singularity"),function()
			local dark_list = {}
			for i=1,#devouring_black_holes do
				if devouring_black_holes[i].division == _("securityProtocol-comms","Dark") then
					table.insert(dark_list,i)
				end
			end
			local selected_bh = dark_list[math.random(1,#dark_list)]
			local park_x, park_y = vectorFromAngleNorth(gross_angle,300000 + (10000*control_stage))
			local halt_x, halt_y = devouring_black_holes[selected_bh]:getPosition()
			devouring_black_holes[selected_bh]:setPosition(park_x + halt_x, park_y + halt_y)
			setCommsMessage(string.format(_("securityProtocol-comms","%s parked."),devouring_black_holes[selected_bh].name))
			devouring_black_holes[selected_bh] = devouring_black_holes[#devouring_black_holes]
			devouring_black_holes[#devouring_black_holes] = nil
			central_control:setCommsScript(""):setCommsFunction(nil)
			addCommsReply(_("Back","Back"),function()
				setCommsMessage(_("securityProtocol-comms","Unauthorized access detected.\nInitiating security review."))
				central_control:setCommsScript(""):setCommsFunction(nil)
			end)
		end) 
	end)
	addCommsReply(_("securityProtocol-comms","Halt a category singularity"),function()
		setCommsMessage(_("securityProtocol-comms","Which category?"))
		addCommsReply(_("securityProtocol-comms","Halt a Small category singularity"),function()
			local small_list = {}
			for i=1,#devouring_black_holes do
				if devouring_black_holes[i].category == _("securityProtocol-comms","Small") then
					table.insert(small_list,i)
				end
			end
			local selected_bh = small_list[math.random(1,#small_list)]
			local park_x, park_y = vectorFromAngleNorth(gross_angle,300000 + (10000*control_stage))
			local halt_x, halt_y = devouring_black_holes[selected_bh]:getPosition()
			devouring_black_holes[selected_bh]:setPosition(park_x + halt_x, park_y + halt_y)
			setCommsMessage(string.format(_("securityProtocol-comms","%s parked."),devouring_black_holes[selected_bh].name))
			devouring_black_holes[selected_bh] = devouring_black_holes[#devouring_black_holes]
			devouring_black_holes[#devouring_black_holes] = nil
			central_control:setCommsScript(""):setCommsFunction(nil)
			addCommsReply(_("Back","Back"),function()
				setCommsMessage(_("securityProtocol-comms","Unauthorized access detected.\nInitiating security review."))
				central_control:setCommsScript(""):setCommsFunction(nil)
			end)
		end)
		addCommsReply(_("securityProtocol-comms","Halt a Medium category singularity"),function()
			local medium_list = {}
			for i=1,#devouring_black_holes do
				if devouring_black_holes[i].category == _("securityProtocol-comms","Medium") then
					table.insert(medium_list,i)
				end
			end
			local selected_bh = medium_list[math.random(1,#medium_list)]
			local park_x, park_y = vectorFromAngleNorth(gross_angle,300000 + (10000*control_stage))
			local halt_x, halt_y = devouring_black_holes[selected_bh]:getPosition()
			devouring_black_holes[selected_bh]:setPosition(park_x + halt_x, park_y + halt_y)
			setCommsMessage(string.format(_("securityProtocol-comms","%s parked."),devouring_black_holes[selected_bh].name))
			devouring_black_holes[selected_bh] = devouring_black_holes[#devouring_black_holes]
			devouring_black_holes[#devouring_black_holes] = nil
			central_control:setCommsScript(""):setCommsFunction(nil)
			addCommsReply(_("Back","Back"),function()
				setCommsMessage(_("securityProtocol-comms","Unauthorized access detected.\nInitiating security review."))
				central_control:setCommsScript(""):setCommsFunction(nil)
			end)
		end)
		addCommsReply(_("securityProtocol-comms","Halt a Large category singularity"),function()
			local large_list = {}
			for i=1,#devouring_black_holes do
				if devouring_black_holes[i].category == _("securityProtocol-comms","Large") then
					table.insert(large_list,i)
				end
			end
			local selected_bh = large_list[math.random(1,#large_list)]
			local park_x, park_y = vectorFromAngleNorth(gross_angle,300000 + (10000*control_stage))
			local halt_x, halt_y = devouring_black_holes[selected_bh]:getPosition()
			devouring_black_holes[selected_bh]:setPosition(park_x + halt_x, park_y + halt_y)
			setCommsMessage(string.format(_("securityProtocol-comms","%s parked."),devouring_black_holes[selected_bh].name))
			devouring_black_holes[selected_bh] = devouring_black_holes[#devouring_black_holes]
			devouring_black_holes[#devouring_black_holes] = nil
			central_control:setCommsScript(""):setCommsFunction(nil)
			addCommsReply(_("Back","Back"),function()
				setCommsMessage(_("securityProtocol-comms","Unauthorized access detected.\nInitiating security review."))
				central_control:setCommsScript(""):setCommsFunction(nil)
			end)
		end)
	end)
end
function commsCentralControlStage6()
	setCommsMessage(_("securityProtocol-comms","Sponsored by the Astronomy, Physics and Sociology departments\nTreatise on the physical and socioeconomic interactions between graduated singularities and sundry established population groups (working title)\nGuest access granted. User identified as Dr. Rosenberg.\n\nGreetings Dr. Rosenberg. What is your request?"))
	addCommsReply(_("securityProtocol-comms","Review Current Research"),function()
		setCommsMessage(_("securityProtocol-comms","Specify research section"))
		addCommsReply(_("securityProtocol-comms","Summary"),function()
			setCommsMessage(_("securityProtocol-comms","This research effort theorizes a number of different categories of responses between differently measured singularities and populations of different origins (see figure 1). There is disagreement between the sponsoring departments as to the likliest outcomes. The astronomy representative, Rosenberg, postulates technological innovation due to the proximity of the singularity and the pressure associated with survival. Strickland, from the sociology department, disagrees: people will be so focused on survival, they'll ignore any potential innovation. The physics representative takes a compromise position: some innovation will occur, but it's likely to get lost in the general destruction. Each representative has outlined their supporting formulas and charts in appendices A, B and C respectively."))
			addCommsReply(_("Back","Back"),commsCentralControlStage6)
		end)
		addCommsReply(_("securityProtocol-comms","Practicum"),function()
			setCommsMessage(_("securityProtocol-comms","To verify, validate, invalidate and/or refute the assertions in this research, a large scale theoretical experiment is recommended. Seed funding from each department should be set aside for future investment along with any excess technological resources. Modeling is deemed insufficient for accurate result determination.\n\nDue to lack of resources, this research project will be filed under future potential research projects. Current backlog: 3,435,665 research projects."))
			addCommsReply(_("Back","Back"),commsCentralControlStage6)
		end)
		addCommsReply(_("securityProtocol-comms","Interdepartmental Correspondence"),function()
			setCommsReply(_("securityProtocol-comms","To: Physics, Astronomy and Sociology Department heads\nFrom: Resource Allocation Department (automated)\nSubject: Experimental Research Approval\n\nCongratulations! Your research project has been approved for implementation. Based on the clear and thorough details provided in your dissertation, construction and deployment will commence immediately. Due to the efficiencies of the Inter-Universal academic research program, the time between submission and the start of implementation is only 65,434,689,432 years*. Estimated time to experiment inception: 44,356 years*.\n\n*All times are approximate based on local language translation software limitations"))
			addCommsReply(_("Back","Back"),commsCentralControlStage6)
		end)
		addCommsReply(_("securityProtocol-comms","Author References"),function()
			setCommsReply(_("securityProtocol-comms","Authors:\nG. Rosenberg, Lead Astronomy Researcher, Concorde Correspondence College, Universe 17, Milky Way Galaxy, Sol System, Jupiter Colony\nR. Strickland, Head of Sociology, Our Lady of the Lake Higher Educational Institute, Universe 3, Eye of Sauron Galaxy, Venktis System, Aplotrey Station orbiting Girfall Prime\nPhysics Representative (not named - group mind), Order of Trafalgar Research Center, Universe 7, Trondheim Galaxy, Fillist System, Rorschach Nebula"))
			addCommsReply(_("Back","Back"),commsCentralControlStage6)
		end)
		addCommsReply(_("Back","Back"),commsCentralControlStage6)
	end)
	addCommsReply(_("securityProtocol-comms","Display Divisions"),function()
		local light_list = ""
		local dark_list = ""
		for i=1,#devouring_black_holes do
			local dbh = devouring_black_holes[i]
			if dbh.division == _("securityProtocol-comms","Light") then
				if light_list == "" then
					light_list = _("securityProtocol-comms","Light: ") .. dbh.name
				else
					light_list = light_list .. ", " .. dbh.name
				end
			else
				if dark_list == "" then
					dark_list = _("securityProtocol-comms","Dark: ") .. dbh.name
				else
					dark_list = dark_list .. ", " .. dbh.name
				end
			end
		end
		setCommsMessage(string.format(_("securityProtocol-comms","Division report:\n%s\n%s"),light_list,dark_list))
		addCommsReply(_("Back","Back"),commsCentralControlStage6)
		central_control:setCommsScript(""):setCommsFunction(nil)
	end)
	addCommsReply(_("securityProtocol-comms","Display Categories"),function()
		local small_list = ""
		local medium_list = ""
		local large_list = ""
		for i=1,#devouring_black_holes do
			local dbh = devouring_black_holes[i]
			if dbh.category == _("securityProtocol-comms","Small") then
				if small_list == "" then
					small_list = _("securityProtocol-comms","Small: ") .. dbh.name
				else
					small_list = small_list .. ", " .. dbh.name
				end
			elseif dbh.category == _("securityProtocol-comms","Medium") then
				if medium_list == "" then
					medium_list = _("securityProtocol-comms","Medium: ") .. dbh.name
				else
					medium_list = medium_list .. ", " .. dbh.name
				end
			else
				if large_list == "" then
					large_list = _("securityProtocol-comms","Large: ") .. dbh.name
				else
					large_list = large_list .. ", " .. dbh.name
				end
			end
		end
		setCommsMessage(string.format(_("securityProtocol-comms","Category report:\n%s\n%s\n%s"),small_list,medium_list,large_list))
		addCommsReply(_("Back","Back"),commsCentralControlStage6)
		central_control:setCommsScript(""):setCommsFunction(nil)
	end)
	addCommsReply(_("securityProtocol-comms","Halt a division singularity"),function()
		setCommsMessage(_("securityProtocol-comms","Which division?"))
		addCommsReply(_("securityProtocol-comms","Halt a Light division singularity"),function()
			local light_list = {}
			for i=1,#devouring_black_holes do
				if devouring_black_holes[i].division == _("securityProtocol-comms","Light") then
					table.insert(light_list,i)
				end
			end
			local selected_bh = light_list[math.random(1,#light_list)]
			local park_x, park_y = vectorFromAngleNorth(gross_angle,300000 + (10000*control_stage))
			local halt_x, halt_y = devouring_black_holes[selected_bh]:getPosition()
			devouring_black_holes[selected_bh]:setPosition(park_x + halt_x, park_y + halt_y)
			setCommsMessage(string.format(_("securityProtocol-comms","%s parked.\n\nHave a nice day, Dr. Rosenberg."),devouring_black_holes[selected_bh].name))
			devouring_black_holes[selected_bh] = devouring_black_holes[#devouring_black_holes]
			devouring_black_holes[#devouring_black_holes] = nil
			central_control:setCommsScript(""):setCommsFunction(nil)
			addCommsReply(_("Back","Back"),function()
				setCommsMessage(_("securityProtocol-comms","Unauthorized access detected.\nInitiating security review."))
				central_control:setCommsScript(""):setCommsFunction(nil)
			end)
		end)
		addCommsReply(_("securityProtocol-comms","Halt a Dark division singularity"),function()
			local dark_list = {}
			for i=1,#devouring_black_holes do
				if devouring_black_holes[i].division == _("securityProtocol-comms","Dark") then
					table.insert(dark_list,i)
				end
			end
			local selected_bh = dark_list[math.random(1,#dark_list)]
			local park_x, park_y = vectorFromAngleNorth(gross_angle,300000 + (10000*control_stage))
			local halt_x, halt_y = devouring_black_holes[selected_bh]:getPosition()
			devouring_black_holes[selected_bh]:setPosition(park_x + halt_x, park_y + halt_y)
			setCommsMessage(string.format(_("securityProtocol-comms","%s parked.\n\nHave a nice day, Dr. Rosenberg."),devouring_black_holes[selected_bh].name))
			devouring_black_holes[selected_bh] = devouring_black_holes[#devouring_black_holes]
			devouring_black_holes[#devouring_black_holes] = nil
			central_control:setCommsScript(""):setCommsFunction(nil)
			addCommsReply(_("Back","Back"),function()
				setCommsMessage(_("securityProtocol-comms","Unauthorized access detected.\nInitiating security review."))
				central_control:setCommsScript(""):setCommsFunction(nil)
			end)
		end) 
		addCommsReply(_("Back","Back"),commsCentralControlStage6)
	end)
	addCommsReply(_("securityProtocol-comms","Halt a category singularity"),function()
		setCommsMessage(_("securityProtocol-comms","Which category?"))
		addCommsReply(_("securityProtocol-comms","Halt a Small category singularity"),function()
			local small_list = {}
			for i=1,#devouring_black_holes do
				if devouring_black_holes[i].category == _("securityProtocol-comms","Small") then
					table.insert(small_list,i)
				end
			end
			local selected_bh = small_list[math.random(1,#small_list)]
			local park_x, park_y = vectorFromAngleNorth(gross_angle,300000 + (10000*control_stage))
			local halt_x, halt_y = devouring_black_holes[selected_bh]:getPosition()
			devouring_black_holes[selected_bh]:setPosition(park_x + halt_x, park_y + halt_y)
			setCommsMessage(string.format(_("securityProtocol-comms","%s parked.\n\nHave a nice day, Dr. Rosenberg."),devouring_black_holes[selected_bh].name))
			devouring_black_holes[selected_bh] = devouring_black_holes[#devouring_black_holes]
			devouring_black_holes[#devouring_black_holes] = nil
			central_control:setCommsScript(""):setCommsFunction(nil)
			addCommsReply(_("Back","Back"),function()
				setCommsMessage(_("securityProtocol-comms","Unauthorized access detected.\nInitiating security review."))
				central_control:setCommsScript(""):setCommsFunction(nil)
			end)
		end)
		addCommsReply(_("securityProtocol-comms","Halt a Medium category singularity"),function()
			local medium_list = {}
			for i=1,#devouring_black_holes do
				if devouring_black_holes[i].category == _("securityProtocol-comms","Medium") then
					table.insert(medium_list,i)
				end
			end
			local selected_bh = medium_list[math.random(1,#medium_list)]
			local park_x, park_y = vectorFromAngleNorth(gross_angle,300000 + (10000*control_stage))
			local halt_x, halt_y = devouring_black_holes[selected_bh]:getPosition()
			devouring_black_holes[selected_bh]:setPosition(park_x + halt_x, park_y + halt_y)
			setCommsMessage(string.format(_("securityProtocol-comms","%s parked.\n\nHave a nice day, Dr. Rosenberg."),devouring_black_holes[selected_bh].name))
			devouring_black_holes[selected_bh] = devouring_black_holes[#devouring_black_holes]
			devouring_black_holes[#devouring_black_holes] = nil
			central_control:setCommsScript(""):setCommsFunction(nil)
			addCommsReply(_("Back","Back"),function()
				setCommsMessage(_("securityProtocol-comms","Unauthorized access detected.\nInitiating security review."))
				central_control:setCommsScript(""):setCommsFunction(nil)
			end)
		end)
		addCommsReply(_("securityProtocol-comms","Halt a Large category singularity"),function()
			local large_list = {}
			for i=1,#devouring_black_holes do
				if devouring_black_holes[i].category == _("securityProtocol-comms","Large") then
					table.insert(large_list,i)
				end
			end
			local selected_bh = large_list[math.random(1,#large_list)]
			local park_x, park_y = vectorFromAngleNorth(gross_angle,300000 + (10000*control_stage))
			local halt_x, halt_y = devouring_black_holes[selected_bh]:getPosition()
			devouring_black_holes[selected_bh]:setPosition(park_x + halt_x, park_y + halt_y)
			setCommsMessage(string.format(_("securityProtocol-comms","%s parked.\n\nHave a nice day, Dr. Rosenberg."),devouring_black_holes[selected_bh].name))
			devouring_black_holes[selected_bh] = devouring_black_holes[#devouring_black_holes]
			devouring_black_holes[#devouring_black_holes] = nil
			central_control:setCommsScript(""):setCommsFunction(nil)
			addCommsReply(_("Back","Back"),function()
				setCommsMessage(_("securityProtocol-comms","Unauthorized access detected.\nInitiating security review."))
				central_control:setCommsScript(""):setCommsFunction(nil)
			end)
		end)
		addCommsReply(_("Back","Back"),commsCentralControlStage6)
	end)
end
function commsSelectedBus()
	setCommsMessage(_("bus-comms","It looks like you're headed out to investigate those black holes. Do you have any ideas about what I should do?"))
	addCommsReply(_("bus-comms","No."),function()
		setCommsMessage(string.format(_("bus-comms","Ok, we'll keep on doing what we're doing. Good luck, %s"),comms_source:getCallSign()))
		comms_target:setCommsScript(""):setCommsFunction(commsShip)
	end)
	addCommsReply(_("bus-comms","Not really. Why are you asking us?"),function()
		setCommsMessage(_("bus-comms","You're the only one that seems to be taking any action related to the approaching disaster."))
		addCommsReply(_("bus-comms","You were optimistic. We don't have any ideas."),function()
			setCommsMessage(_("bus-comms","Gotta find optimism *somewhere*."))
			comms_target:setCommsScript(""):setCommsFunction(commsShip)
		end)
		addCommsReply(string.format(_("bus-comms","What are your capabilities, %s?"),comms_target:getCallSign()),function()
			local out = string.format(_("bus-comms","We're a busy %s mass transit vessel currently located in %s with a passenger carrying capacity of %i and a top impulse speed of %.1f units per minute"),comms_target:getFaction(),comms_target:getSectorName(),comms_target.passenger_capacity,comms_target:getImpulseMaxSpeed()*60/1000)
			if comms_target:hasSystem("jumpdrive") then
				out = string.format(_("bus-comms","%s with a jump drive."),out)
			end
			setCommsMessage(out)
			addCommsReply(_("bus-comms","Maybe you could pick people up and get them away."),function()
				if comms_target.rescue_pickup == nil then
					comms_target:setCommsScript(""):setCommsFunction(commsShip)
					setRescueDestination()
				else
					--already on a rescue pickup
					if comms_target.rescue_pickup == "enroute" then
						local order_target = comms_target:getOrderTarget()
						setCommsMessage(string.format(_("bus-comms","I am already on my way to %s in %s.\nDo you want me to go somewhere else?"),order_target:getCallSign(),order_target:getSectorName()))
						comms_target:setCommsScript(""):setCommsFunction(commsShip)
						addCommsReply(_("bus-comms","Yes, please change your destination"),setRescueDestination)
					elseif comms_target.rescue_pickup == "complete" then
						comms_target:setCommsScript(""):setCommsFunction(commsShip)
						setCommsMessage(_("bus-comms","I've already picked up as many passengers as I can carry"))
					end
				end
			end)
			comms_target:setCommsScript(""):setCommsFunction(commsShip)
		end)
	end)
	addCommsReply(_("bus-comms","Who are you?"),function()
		local out = string.format(_("bus-comms","We're a busy %s mass transit vessel currently located in %s with a passenger carrying capacity of %i and a top impulse speed of %.1f units per minute"),comms_target:getFaction(),comms_target:getSectorName(),comms_target.passenger_capacity,comms_target:getImpulseMaxSpeed()*60/1000)
		if comms_target:hasSystem("jumpdrive") then
			out = string.format(_("bus-comms","%s with a jump drive."),out)
		end
		setCommsMessage(out)
		addCommsReply(_("bus-comms","A noble task for a noble ship. Why are you contacting us?"),function()
			setCommsMessage(string.format(_("bus-comms","You look like you're on a mission and could inspire us or direct us. Clearly, we're bothering you. Good luck, %s"),comms_source:getCallSign()))
			comms_target:setCommsScript(""):setCommsFunction(commsShip)
		end)
		addCommsReply(_("bus-comms","Hmmm. Maybe you could rescue people."),function()
			if comms_target.rescue_pickup == nil then
				comms_target:setCommsScript(""):setCommsFunction(commsShip)
				setRescueDestination()
			else
				--already on a rescue pickup
				if comms_target.rescue_pickup == "enroute" then
					local order_target = comms_target:getOrderTarget()
					setCommsMessage(string.format(_("bus-comms","I am already on my way to %s in %s.\nDo you want me to go somewhere else?"),order_target:getCallSign(),order_target:getSectorName()))
					comms_target:setCommsScript(""):setCommsFunction(commsShip)
					addCommsReply(_("bus-comms","Yes, please change your destination"),setRescueDestination)
				elseif comms_target.rescue_pickup == "complete" then
					comms_target:setCommsScript(""):setCommsFunction(commsShip)
					setCommsMessage(_("bus-comms","I've already picked up as many passengers as I can carry"))
				end
			end
		end)
		comms_target:setCommsScript(""):setCommsFunction(commsShip)
	end)
end
function handleGridControl(self,player)
	local throw_40_x, throw_40_y = vectorFromAngle(random(0,360),40000)
	if self:isScannedBy(player) then
		if self.door then
			central_control.entered_through_doorway = true
		else
			player:setPosition(devouring_origin_x + throw_40_x, devouring_origin_y + throw_40_y)
		end
	else
		player:setPosition(devouring_origin_x + throw_40_x, devouring_origin_y + throw_40_y)
		player:setCanScan(false)
		local toss_burnout_message = "toss_burnout_message"
		player:addCustomMessage("Science",toss_burnout_message,_("msgScience","The unscanned alien technological device teleported us away and damaged our scanners"))
		local toss_burnout_message_ops = "toss_burnout_message_ops"
		player:addCustomMessage("Operations",toss_burnout_message_ops,_("msgOperations","The unscanned alien technological device teleported us away and damaged our scanners"))
	end
end
function blackHoleSpacing(spawn_x, spawn_y)
	for _, hole in ipairs(devouring_black_holes) do
		if distance(hole,spawn_x,spawn_y) < 12000 then
			return false
		end
	end
	return true
end
function updateDevouringBlackHoles(delta)
	if #devouring_black_holes > 0 then
		for bh_index, bh in ipairs(devouring_black_holes) do
			if bh ~= nil and bh:isValid() then
				local d_x, d_y = vectorFromAngleNorth(bh.travel_angle,200000/1200*delta)
				local c_x, c_y = bh:getPosition()
				bh:setPosition(c_x + d_x, c_y + d_y)
			else
				devouring_black_holes[bh_index] = devouring_black_holes[#devouring_black_holes]
				devouring_black_holes[#devouring_black_holes] = nil
				break
			end
		end
	end
	if control_stage > 0 then
		for _, bh in ipairs(orbiting_black_holes) do
			bh.angle = (bh.angle + bh.rotation_speed * delta) % 360
			local obh_x, obh_y = vectorFromAngleNorth(bh.angle,bh.radius)
			bh:setPosition(devouring_origin_x + obh_x, devouring_origin_y + obh_y)
		end
		if control_stage > 2 then
			central_control_nebula:setPosition(devouring_origin_x,devouring_origin_y)
			if control_stage > 4 then
				local p = getPlayerShip(-1)
				for _, ca in ipairs(grid_control) do
					if ca.door then
						if ca:isScannedBy(p) then
							if math.floor(getScenarioTime()) % 2 == 0 then
								ca:setRadarTraceColor(160,82,45)
								if door_diagnostic then
									print("door color is dark")
								end
							else
								ca:setRadarTraceColor(255,255,255)
								if door_diagnostic then
									print("door color is white")
								end
							end
						end
					end
					if control_stage > 6 then
						ca.angle = (ca.angle + ca.rotation_speed * delta) % 360
						local dx, dy = vectorFromAngleNorth(ca.angle,ca.radius)
						ca:setPosition(devouring_origin_x + dx, devouring_origin_y + dy)
					end
				end
			end
		end
	end
end
function countSurvivors()
	local survivor_count = {
		["station"] =	{
							["friend"] = 0,
							["neutral"] = 0,
							["enemy"] = 0,
						},
		["bus"] =		{
							["friend"] = 0,
							["neutral"] = 0,
							["enemy"] = 0,
						},
		["freighter"] =	{
							["friend"] = 0,
							["neutral"] = 0,
							["enemy"] = 0,
						},
		["player"] =	{
							["friend"] = 0,
							["neutral"] = 0,
							["enemy"] = 0,
						},
		["total"] =		{
							["friend"] = 0,
							["neutral"] = 0,
							["enemy"] = 0,
							["total"] = 0,
						}
	}
	local p = getPlayerShip(-1)
	for _, station in ipairs(station_list) do
		if station ~= nil and station:isValid() then
			if station.residents ~= nil and station.residents > 0 then
				if station:isFriendly(p) then
					survivor_count["station"]["friend"] = survivor_count["station"]["friend"] + station.residents
				elseif station:isEnemy(p) then
					survivor_count["station"]["enemy"] = survivor_count["station"]["enemy"] + station.residents
				else
					survivor_count["station"]["neutral"] = survivor_count["station"]["neutral"] + station.residents
				end 
			end
		end
	end
	for _, bus in ipairs(bus_list) do
		if bus ~= nil and bus:isValid() then
			if bus.residents ~= nil then
				if bus.residents["friend"] ~= nil then
					survivor_count["bus"]["friend"] = survivor_count["bus"]["friend"] + bus.residents["friend"]
				end
				if bus.residents["neutral"] ~= nil then
					survivor_count["bus"]["neutral"] = survivor_count["bus"]["neutral"] + bus.residents["neutral"]
				end
				if bus.residents["enemy"] ~= nil then
					survivor_count["bus"]["enemy"] = survivor_count["bus"]["enemy"] + bus.residents["enemy"]
				end
			end
		end
	end
	for _, freighter in ipairs(transport_list) do
		if freighter ~= nil and freighter:isValid() then
			if freighter.residents ~= nil then
				if freighter.residents["friend"] ~= nil then
					survivor_count["freighter"]["friend"] = survivor_count["freighter"]["friend"] + freighter.residents["friend"]
				end
				if freighter.residents["neutral"] ~= nil then
					survivor_count["freighter"]["neutral"] = survivor_count["freighter"]["neutral"] + freighter.residents["neutral"]
				end
				if freighter.residents["enemy"] ~= nil then
					survivor_count["freighter"]["enemy"] = survivor_count["freighter"]["enemy"] + freighter.residents["enemy"]
				end
			end
		end
	end
	local p = getPlayerShip(-1)
	if p ~= nil and p:isValid() then
		if p.residents ~= nil then
			if p.residents["friend"] ~= nil then
				survivor_count["player"]["friend"] = p.residents["friend"]
			end
			if p.residents["neutral"] ~= nil then
				survivor_count["player"]["neutral"] = p.residents["neutral"]
			end
			if p.residents["enemy"] ~= nil then
				survivor_count["player"]["enemy"] = p.residents["enemy"]
			end
		end
	end
	survivor_count["total"]["friend"] = survivor_count["station"]["friend"] + survivor_count["bus"]["friend"] + survivor_count["freighter"]["friend"] + survivor_count["player"]["friend"]
	survivor_count["total"]["neutral"] = survivor_count["station"]["neutral"] + survivor_count["bus"]["neutral"] + survivor_count["freighter"]["neutral"] + survivor_count["player"]["neutral"]
	survivor_count["total"]["enemy"] = survivor_count["station"]["enemy"] + survivor_count["bus"]["enemy"] + survivor_count["freighter"]["enemy"] + survivor_count["player"]["enemy"]
	survivor_count["total"]["total"] = survivor_count["total"]["friend"] + survivor_count["total"]["neutral"] + survivor_count["total"]["enemy"]
	return survivor_count
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
	addGMFunction(string.format(_("buttonGM","Version %s"),scenario_version),function()
		local version_message = string.format(_("msgGM","Scenario version %s\n LUA version %s"),scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	addGMFunction(_("buttonGM","Show Survivors"),function()
		local survivor_count = countSurvivors()
		local out = _("msgGM","Original Resident Civilians:")
		out = string.format(_("msgGM","%s\n    Friends:%s   Neutrals:%s   Enemies:%s   Total:%s"),out,residents["friend"],residents["neutral"],residents["enemy"],residents["friend"] + residents["neutral"] + residents["enemy"])
		out = string.format(_("msgGM","%s\nCurrent Survivors:\n    On a Station:"),out)
		out = string.format(_("msgGM","%s\n        Friends:%s   Neutrals:%s   Enemies:%s"),out,survivor_count["station"]["friend"],survivor_count["station"]["neutral"],survivor_count["station"]["enemy"])
		out = string.format(_("msgGM","%s\n    On a Bus:"),out)
		out = string.format(_("msgGM","%s\n        Friends:%s   Neutrals:%s   Enemies:%s"),out,survivor_count["bus"]["friend"],survivor_count["bus"]["neutral"],survivor_count["bus"]["enemy"])
		out = string.format(_("msgGM","%s\n    On a Freighter:"),out)
		out = string.format(_("msgGM","%s\n        Friends:%s   Neutrals:%s   Enemies:%s"),out,survivor_count["freighter"]["friend"],survivor_count["freighter"]["neutral"],survivor_count["freighter"]["enemy"])
		out = string.format(_("msgGM","%s\n    On Player Ship:"),out)
		out = string.format(_("msgGM","%s\n        Friends:%s   Neutrals:%s   Enemies:%s"),out,survivor_count["player"]["friend"],survivor_count["player"]["neutral"],survivor_count["player"]["enemy"])
		out = string.format(_("msgGM","%s\n\n    Total:"),out)
		out = string.format(_("msgGM","%s\n        Friends:%s   Neutrals:%s   Enemies:%s   Total:%s"),out,survivor_count["total"]["friend"],survivor_count["total"]["neutral"],survivor_count["total"]["enemy"],survivor_count["total"]["total"])
		addGMMessage(out)
	end)
	addGMFunction(_("buttonGM","+Station Reports"),stationReports)
	if getScenarioTime() < black_hole_milestone then
		addGMFunction(_("buttonGM","Test: Release BHs"),function()
			if getScenarioTime() > black_hole_milestone then
				addGMMessage(_("msgGM","Black holes already released"))
			else
				black_hole_milestone = getScenarioTime()
				addGMMessage(string.format(_("msgGM","Black holes released. Scenario time: %.1f"),getScenarioTime()))
			end
			mainGMButtons()
		end)
	end 
end
function stationReports()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main"),mainGMButtons)
	if station_list ~= nil and #station_list > 0 then
		local p = getPlayerShip(-1)
		if p ~= nil and p:isValid() then
			local applicable_station_count = 0
			for index, station in ipairs(station_list) do
				if station ~= nil and station:isValid() and station.comms_data ~= nil then
					if station:isFriendly(p) or not station:isEnemy(p) then
						applicable_station_count = applicable_station_count + 1
						addGMFunction(string.format("%s %s",station:getCallSign(),station:getSectorName()),function()
							local out = string.format(_("msgGM","%s %s  %s  %s  Friendliness:%s"),station:getSectorName(),station:getCallSign(),station:getTypeName(),station:getFaction(),station.comms_data.friendlyness)
							out = string.format(_("msgGM","%s\nShares Energy: %s,  Repairs Hull: %s,  Restocks Scan Probes: %s"),out,station:getSharesEnergyWithDocked(),station:getRepairDocked(),station:getRestocksScanProbes())
							out = string.format(_("msgGM","%s\nFix Probes: %s,  Fix Hack: %s,  Fix Scan: %s,  Fix Combat Maneuver: %s,  Fix Destruct: %s, Fix Slow Tube: %s"),out,station.comms_data.probe_launch_repair,station.comms_data.hack_repair,station.comms_data.scan_repair,station.comms_data.combat_maneuver_repair,station.comms_data.self_destruct_repair,station.comms_data.self_destruct_repair,station.comms_data.tube_slow_down_repair)
							if station.comms_data.weapon_cost == nil then
								station.comms_data.weapon_cost = {
									Homing = math.random(1,4),
									HVLI = math.random(1,3),
									Mine = math.random(2,5),
									Nuke = math.random(12,18),
									EMP = math.random(7,13)
								}
							else
								if station.comms_data.weapon_cost.Homing == nil then
									station.comms_data.weapon_cost.Homing = math.random(1,4)
								end
								if station.comms_data.weapon_cost.HVLI == nil then
									station.comms_data.weapon_cost.HVLI = math.random(1,3)
								end
								if station.comms_data.weapon_cost.Nuke == nil then
									station.comms_data.weapon_cost.Nuke = math.random(12,18)
								end
								if station.comms_data.weapon_cost.Mine == nil then
									station.comms_data.weapon_cost.Mine = math.random(2,5)
								end
								if station.comms_data.weapon_cost.EMP == nil then
									station.comms_data.weapon_cost.EMP = math.random(7,13)
								end
							end
							out = string.format(_("msgGM","%s\nHoming: %s %s,   Nuke: %s %s,   Mine: %s %s,   EMP: %s %s,   HVLI: %s %s"),out,station.comms_data.weapon_available.Homing,station.comms_data.weapon_cost.Homing,station.comms_data.weapon_available.Nuke,station.comms_data.weapon_cost.Nuke,station.comms_data.weapon_available.Mine,station.comms_data.weapon_cost.Mine,station.comms_data.weapon_available.EMP,station.comms_data.weapon_cost.EMP,station.comms_data.weapon_available.HVLI,station.comms_data.weapon_cost.HVLI)
--							out = string.format("%s\n      Cost multipliers and Max Refill:   Friend: %.1f %.1f,   Neutral: %.1f %.1f",out,station.comms_data.reputation_cost_multipliers.friend,station.comms_data.max_weapon_refill_amount.friend,station.comms_data.reputation_cost_multipliers.neutral,station.comms_data.max_weapon_refill_amount.neutral)
							out = string.format(_("msgGM","%s\nServices and their costs:"),out)
							for service, cost in pairs(station.comms_data.service_cost) do
								out = string.format("%s\n      %s: %s",out,service,cost)
							end
							if station.comms_data.jump_overcharge then
								out = string.format(_("msgGM","%s\n      jump overcharge: 10"),out)
							end
							if station.comms_data.goods ~= nil or station.comms_data.trade ~= nil or station.comms_data.buy ~= nil then
								out = string.format(_("msgGM","%s\nGoods:"),out)
								if station.comms_data.goods ~= nil then
									out = string.format(_("msgGM","%s\n    Sell:"),out)
									for good, good_detail in pairs(station.comms_data.goods) do
										out = string.format(_("msgGM","%s\n        %s: Cost:%s   Quantity:%s"),out,good,good_detail.cost,good_detail.quantity)
									end
								end
								if station.comms_data.trade ~= nil then
									out = string.format(_("msgGM","%s\n    Trade:"),out)
									for good, trade in pairs(station.comms_data.trade) do
										out = string.format("%s\n        %s: %s",out,good,trade)
									end
								end
								if station.comms_data.buy ~= nil then
									out = string.format(_("msgGM","%s\n    Buy:"),out)
									for good, amount in pairs(station.comms_data.buy) do
										out = string.format("%s\n        %s: %s",out,good,amount)
									end
								end
							end
							addGMMessage(out)
							stationReports()
						end)					
					end
				end
			end
			if applicable_station_count == 0 then
				addGMMessage(_("msgGM","No applicable stations. Reports useless. No action taken"))
				mainGMButtons()
			end
		else
			addGMMessage(_("msgGM","No valid player ship. Reports useless. No action taken"))
			mainGMButtons()
		end
	else
		addGMMessage(_("msgGM","No applicable stations. Reports useless. No action taken"))
		mainGMButtons()
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
        setCommsMessage(_("station-comms","We are under attack! No time for chatting!"))
        return true
    end
    if not comms_source:isDocked(comms_target) then
        handleUndockedState()
    else
        handleDockedState()
    end
    return true
end
function passengerList(console)
	local p = getPlayerShip(-1)
	local out = string.format(_("station-comms","No armored transport missions.\nPassengers on board:%i\nAvailable passenger capacity:%i"),30-p.resident_capacity,p.resident_capacity)
	if p.taxi_missions ~= nil then
		if #p.taxi_missions > 0 then
			if #p.taxi_missions > 1 then
				out = _("station-comms","Current armored transport missions:")
			else
				out = _("station-comms","Current armored transport mission:")
			end
			for _, mission in ipairs(p.taxi_missions) do
				out = string.format("%s\n    %s",out,mission.desc)
			end
		end
		out = string.format(_("station-comms","%s\nPassengers on board:%i\nAvailable passenger capacity:%i"),out,30-p.resident_capacity,p.resident_capacity)
	end
	local passenger_list_console_message = string.format("passenger_list_console_message_%s",console)
	p:addCustomMessage(console,passenger_list_console_message,out)
end
function upgradeReminder(console,button_id)
	local p = getPlayerShip(-1)
	local out = _("msgConsole","Parts needed for upgrade:")
	local upgrade_count = 0
	if p.impulse_upgrade == 1 then
		out = string.format(_("msgConsole","%s\nImpulse upgrade: %s"),out,p.impulse_upgrade_part)
		upgrade_count = upgrade_count + 1
	end
	if p.shield_upgrade == 1 then
		out = string.format(_("msgConsole","%s\nShield upgrade: %s"),out,p.shield_upgrade_part)
		upgrade_count = upgrade_count + 1
	end
	if p.tube_speed_upgrade == 1 then
		out = string.format(_("msgConsole","%s\nWeapon tube load speed upgrade: %s"),out,p.tube_speed_upgrade_part)
		upgrade_count = upgrade_count + 1
	end
	if upgrade_count == 0 then
		out = string.format(_("msgConsole","%s\nNone. Upgrade(s) already completed."),out)
		p:removeCustom(console,button_id)		
	end
	local upgrade_reminder_console_message = string.format("upgrade_reminder_console_message_%s",console)
	p:addCustomMessage(console,upgrade_reminder_console_message,out)
end
function handleDockedState()
    if comms_source:isFriendly(comms_target) then
    	if comms_target.comms_data.friendlyness > 66 then
    		oMsg = string.format(_("station-comms","Greetings %s!\nHow may we help you today?"),comms_source:getCallSign())
    	elseif comms_target.comms_data.friendlyness > 33 then
			oMsg = _("station-comms","Good day, officer!\nWhat can we do for you today?")
		else
			oMsg = _("station-comms","Hello, may I help you?")
		end
    else
		oMsg = _("station-comms","Welcome to our lovely station.")
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. _("station-comms","\nForgive us if we seem a little distracted. We are carefully monitoring the enemies nearby.")
	end
	if getScenarioTime() > black_hole_milestone then
		oMsg = string.format(_("station-comms","%s\nResidents on %s: %s    %s passenger capacity:%s"),oMsg,comms_target:getCallSign(),comms_target.residents,comms_source:getCallSign(),comms_source.resident_capacity)
	end
	setCommsMessage(oMsg)
	if getScenarioTime() > black_hole_milestone then
		if comms_target.residents > 0 and comms_source.resident_capacity > 0 then
			addCommsReply(_("station-comms","Pick up residents"),function()
				local pick_up_count = 0
				if comms_source.resident_capacity >= comms_target.residents then
					pick_up_count = comms_target.residents
					comms_source.resident_capacity = comms_source.resident_capacity - comms_target.residents
					if comms_source:isFriendly(comms_target) then
						comms_source.residents["friend"] = comms_source.residents["friend"] + comms_target.residents
					else
						comms_source.residents["neutral"] = comms_source.residents["neutral"] + comms_target.residents
					end
					comms_target.residents = 0
				else
					pick_up_count = comms_source.resident_capacity
					comms_target.residents = comms_target.residents - comms_source.resident_capacity
					if comms_source:isFriendly(comms_target) then
						comms_source.residents["friend"] = comms_source.residents["friend"] + comms_source.resident_capacity
					else
						comms_source.residents["neutral"] = comms_source.residents["neutral"] + comms_source.resident_capacity
					end
					comms_source.resident_capacity = 0
				end
				setCommsMessage(string.format(_("station-comms","%s residents picked up"),pick_up_count))
				addCommsReply(_("Back","Back"), commsStation)
			end)
		end
		if comms_source.taxi_missions ~= nil and #comms_source.taxi_missions > 0 then
			local prompt = _("station-comms","What about my mission?")
			if #comms_source.taxi_missions > 1 then
				prompt = _("station-comms","What about my missions?")
			end
			addCommsReply(prompt,function()
				setCommsMessage(_("station-comms","In light of the unusual readings in the area, your passengers have all elected to remain aboard your ship. You have received half of your planned extra reputation. Your passengers prefer to remain alive."))
				for _, mission in ipairs(comms_source.taxi_missions) do
					comms_source:addReputationPoints(math.floor(mission.payoff/2))
				end
				comms_source.taxi_missions = nil
				addCommsReply(_("Back","Back"), commsStation)
			end)
		end
	else
		local deleted_mission = false
		local viable_missions = 0
		local count_repeat_loop = 0
		repeat
			if #taxi_missions > 0 then
				viable_missions = 0
				for mission_index, mission in ipairs(taxi_missions) do
					if mission.origin:isValid() then
						if mission.destination:isValid() then
							if comms_target == mission.origin then
								if comms_target.residents > mission.count and comms_source.resident_capacity > mission.count then
									viable_missions = viable_missions + 1
								end
							end
						else
							taxi_missions[mission_index] = taxi_missions[#taxi_missions]
							taxi_missions[#taxi_missions] = nil
							deleted_mission = true
							break	
						end
					else
						taxi_missions[mission_index] = taxi_missions[#taxi_missions]
						taxi_missions[#taxi_missions] = nil
						deleted_mission = true
						break	
					end
				end
			end
			count_repeat_loop = count_repeat_loop + 1
		until(not deleted_mission or count_repeat_loop > max_repeat_loop)
		if count_repeat_loop > max_repeat_loop then
			print("repeated too many times when looking for viable missions")
			print("taxi mission count:",#taxi_missions,"viable missions:",viable_missions)
		end
--	table.insert(taxi_missions,{desc=mission_description,origin=origin_station,destination=destination_station,count=passenger_count,payoff=reputation_payoff})
		if viable_missions > 0 then
			addCommsReply(_("station-comms","What armored transport missions are available?"),function()
				local mission_count = 0
				for mission_index, mission in ipairs(taxi_missions) do
					if mission.origin:isValid() and mission.destination:isValid() and comms_target == mission.origin then
						if comms_target.residents > mission.count and comms_source.resident_capacity > mission.count then
							mission_count = mission_count + 1
							addCommsReply(string.format(_("station-comms","People to %s (%s) for %i reputation"),mission.destination:getCallSign(),mission.destination:getFaction(),mission.payoff),function()
								if comms_source.taxi_missions == nil then
									comms_source.taxi_missions = {}
								end
								comms_source.resident_capacity = comms_source.resident_capacity - mission.count
								if comms_source:isFriendly(comms_target) then
									comms_source.residents["friend"] = comms_source.residents["friend"] + mission.count
								else
									comms_source.residents["neutral"] = comms_source.residents["neutral"] + mission.count
								end
								comms_target.residents = comms_target.residents - mission.count
								setCommsMessage(string.format(_("station-comms","You have accepted the following mission:\n%s\n%i passengers have boarded."),mission.desc,mission.count))
								table.insert(comms_source.taxi_missions,mission)
								if comms_source.passenger_list_button_relay == nil then
									comms_source.passenger_list_button_relay = "passenger_list_button_relay"
									comms_source:addCustomButton("Relay",comms_source.passenger_list_button_relay,_("buttonRelay","Passenger List"),function()
										string.format("")
										passengerList("Relay")
									end)
								end
								if comms_source.passenger_list_button_ops == nil then
									comms_source.passenger_list_button_ops = "passenger_list_button_ops"
									comms_source:addCustomButton("Operations",comms_source.passenger_list_button_ops,_("buttonOperations","Passenger List"),function()
										string.format("")
										passengerList("Operations")
									end)
								end
								if comms_source.passenger_list_button_log == nil then
									comms_source.passenger_list_button_log = "passenger_list_button_log"
									comms_source:addCustomButton("shiplog",comms_source.passenger_list_button_log,_("buttonShipLog","Passenger List"),function()
										string.format("")
										passengerList("shiplog")
									end)
								end
								if comms_source.passenger_list_button_single == nil then
									comms_source.passenger_list_button_single = "passenger_list_button_single"
									comms_source:addCustomButton("SinglePilot",comms_source.passenger_list_button_single,_("buttonSingle","Passenger List"),function()
										string.format("")
										passengerList("SinglePilot")
									end)
								end
								taxi_missions[mission_index] = taxi_missions[#taxi_missions]
								taxi_missions[#taxi_missions] = nil
								if comms_source.impulse_upgrade > 0 and comms_source.tube_speed_upgrade > 0 and comms_source.shield_upgrade == 0 then
									comms_source:setShieldsMax(90,90)		--stronger (vs 80,80)
									comms_source.shield_upgrade = 1
									local shield_list = {
										"shield",
										"circuit",
										"battery",
										"nanites",
									}
									comms_source.shield_upgrade_part = shield_list[math.random(1,#shield_list)]
									local eng_msg = string.format(_("msgEngineer","One of the passengers that just boarded was interested in the shield generators and batteries. After talking for a bit, he showed you how to increase the shield capacity by 12.5%%. You could double that if you acquire some %s."),comms_source.shield_upgrade_part)
									comms_source.shield_msg_eng = "shield_msg_eng"
									comms_source.shield_msg_plus = "shield_msg_plus"
									comms_source:addCustomMessage("Engineering",comms_source.shield_msg_eng,eng_msg)
									comms_source:addCustomMessage("Engineering+",comms_source.shield_msg_plus,eng_msg)
									comms_source.upgrade_reminder_button_eng = "upgrade_reminder_button_eng"
									comms_source:addCustomButton("Engineering",comms_source.upgrade_reminder_button_eng,_("buttonEngineer","Upgrade Notes"),function()
										string.format("")
										upgradeReminder("Engineering",comms_source.upgrade_reminder_button_eng)
									end)
									comms_source.upgrade_reminder_button_plus = "upgrade_reminder_button_plus"
									comms_source:addCustomButton("Engineering+",comms_source.upgrade_reminder_button_plus,_("buttonEngineer+","Upgrade Notes"),function()
										string.format("")
										upgradeReminder("Engineering+",comms_source.upgrade_reminder_button_plus)
									end)
								elseif comms_source.shield_upgrade > 0 and comms_source.tube_speed_upgrade > 0 and comms_source.impulse_upgrade == 0 then
									comms_source:setImpulseMaxSpeed(75)		--faster (vs 70)
									comms_source.impulse_upgrade = 1
									local impulse_list = {
										"lifter",
										"optic",
										"software",
										"impulse",
									}
									comms_source.impulse_upgrade_part = impulse_list[math.random(1,#impulse_list)]
									local impulse_msg = string.format(_("msgEngineer","One of the passengers that just boarded was interested in the impulse engines. He showed you how to increase the maximum impulse speed by about 7%%. You could triple that if you acquire some %s."),comms_source.impulse_upgrade_part)
									comms_source.impulse_msg_eng = "impulse_msg_eng"
									comms_source.impulse_msg_plus = "impulse_msg_plus"
									comms_source:addCustomMessage("Engineering",comms_source.impulse_msg_eng,impulse_msg)
									comms_source:addCustomMessage("Engineering+",comms_source.impulse_msg_plus,impulse_msg)
									comms_source.upgrade_reminder_button_eng = "upgrade_reminder_button_eng"
									comms_source:addCustomButton("Engineering",comms_source.upgrade_reminder_button_eng,_("buttonEngineer","Upgrade Notes"),function()
										string.format("")
										upgradeReminder("Engineering",comms_source.upgrade_reminder_button_eng)
									end)
									comms_source.upgrade_reminder_button_plus = "upgrade_reminder_button_plus"
									comms_source:addCustomButton("Engineering+",comms_source.upgrade_reminder_button_plus,_("buttonEngineer+","Upgrade Notes"),function()
										string.format("")
										upgradeReminder("Engineering+",comms_source.upgrade_reminder_button_plus)
									end)
								elseif comms_source.shield_upgrade > 0 and comms_source.impulse_upgrade > 0 and comms_source.tube_speed_upgrade == 0 then
									comms_source:setTubeLoadTime(0,15)		--faster vs base 20
									comms_source:setTubeLoadTime(1,15)		--faster vs base 20
									comms_source.tube_speed_upgrade = 1
									local tube_speed_list = {
										"tractor",
										"filament",
										"sensor",
										"robotic",
									}
									comms_source.tube_speed_upgrade_part = tube_speed_list[math.random(1,#tube_speed_list)]
									local tube_speed_msg = string.format(_("msgEngineer","One of the passengers that just boarded was interested in the weapons tubes. He showed you how to speed up the weapons tube load time by about 25%%. You could double that if you acquire some %s."),comms_source.tube_speed_upgrade_part)
									comms_source.tube_speed_msg_eng = "tube_speed_msg_eng"
									comms_source.tube_speed_msg_plus = "tube_speed_msg_plus"
									comms_source:addCustomMessage("Engineering",comms_source.tube_speed_msg_eng,tube_speed_msg)
									comms_source:addCustomMessage("Engineering+",comms_source.tube_speed_msg_plus,tube_speed_msg)
									comms_source.upgrade_reminder_button_eng = "upgrade_reminder_button_eng"
									comms_source:addCustomButton("Engineering",comms_source.upgrade_reminder_button_eng,_("buttonEngineer","Upgrade Notes"),function()
										string.format("")
										upgradeReminder("Engineering",comms_source.upgrade_reminder_button_eng)
									end)
									comms_source.upgrade_reminder_button_plus = "upgrade_reminder_button_plus"
									comms_source:addCustomButton("Engineering+",comms_source.upgrade_reminder_button_plus,_("buttonEngineer+","Upgrade Notes"),function()
										string.format("")
										upgradeReminder("Engineering+",comms_source.upgrade_reminder_button_plus)
									end)
								else
									local upgrade_list = {}
									if comms_source.impulse_upgrade == 0 then
										table.insert(upgrade_list,"impulse")
									end
									if comms_source.shield_upgrade == 0 then
										table.insert(upgrade_list,"shield")
									end
									if comms_source.tube_speed_upgrade == 0 then
										table.insert(upgrade_list,"tube_speed")
									end
									if #upgrade_list > 0 then
										local selected_upgrade = upgrade_list[math.random(1,#upgrade_list)]
										if selected_upgrade == "shield" then
											comms_source:setShieldsMax(90,90)		--stronger (vs 80,80)
											comms_source.shield_upgrade = 1
											local shield_list = {
												"shield",
												"circuit",
												"battery",
												"nanites",
											}
											comms_source.shield_upgrade_part = shield_list[math.random(1,#shield_list)]
											local eng_msg = string.format(_("msgEngineer","One of the passengers that just boarded was interested in the shield generators and batteries. After talking for a bit, he showed you how to increase the shield capacity by 12.5%%. You could double that if you acquire some %s."),comms_source.shield_upgrade_part)
											comms_source.shield_msg_eng = "shield_msg_eng"
											comms_source.shield_msg_plus = "shield_msg_plus"
											comms_source:addCustomMessage("Engineering",comms_source.shield_msg_eng,eng_msg)
											comms_source:addCustomMessage("Engineering+",comms_source.shield_msg_plus,eng_msg)
											comms_source.upgrade_reminder_button_eng = "upgrade_reminder_button_eng"
											comms_source:addCustomButton("Engineering",comms_source.upgrade_reminder_button_eng,_("buttonEngineer","Upgrade Notes"),function()
												string.format("")
												upgradeReminder("Engineering",comms_source.upgrade_reminder_button_eng)
											end)
											comms_source.upgrade_reminder_button_plus = "upgrade_reminder_button_plus"
											comms_source:addCustomButton("Engineering+",comms_source.upgrade_reminder_button_plus,_("buttonEngineer+","Upgrade Notes"),function()
												string.format("")
												upgradeReminder("Engineering+",comms_source.upgrade_reminder_button_plus)
											end)
										elseif selected_upgrade == "impulse" then
											comms_source:setImpulseMaxSpeed(75)		--faster (vs 70)
											comms_source.impulse_upgrade = 1
											local impulse_list = {
												"lifter",
												"optic",
												"software",
												"impulse",
											}
											comms_source.impulse_upgrade_part = impulse_list[math.random(1,#impulse_list)]
											local impulse_msg = string.format(_("msgEngineer","One of the passengers that just boarded was interested in the impulse engines. He showed you how to increase the maximum impulse speed by about 7%%. You could triple that if you acquire some %s."),comms_source.impulse_upgrade_part)
											comms_source.impulse_msg_eng = "impulse_msg_eng"
											comms_source.impulse_msg_plus = "impulse_msg_plus"
											comms_source:addCustomMessage("Engineering",comms_source.impulse_msg_eng,impulse_msg)
											comms_source:addCustomMessage("Engineering+",comms_source.impulse_msg_plus,impulse_msg)
											comms_source.upgrade_reminder_button_eng = "upgrade_reminder_button_eng"
											comms_source:addCustomButton("Engineering",comms_source.upgrade_reminder_button_eng,_("buttonEngineer","Upgrade Notes"),function()
												string.format("")
												upgradeReminder("Engineering",comms_source.upgrade_reminder_button_eng)
											end)
											comms_source.upgrade_reminder_button_plus = "upgrade_reminder_button_plus"
											comms_source:addCustomButton("Engineering+",comms_source.upgrade_reminder_button_plus,_("buttonEngineer+","Upgrade Notes"),function()
												string.format("")
												upgradeReminder("Engineering+",comms_source.upgrade_reminder_button_plus)
											end)
										elseif selected_upgrade == "tube_speed" then
											comms_source:setTubeLoadTime(0,15)		--faster vs base 20
											comms_source:setTubeLoadTime(1,15)		--faster vs base 20
											comms_source.tube_speed_upgrade = 1
											local tube_speed_list = {
												"tractor",
												"filament",
												"sensor",
												"robotic",
											}
											comms_source.tube_speed_upgrade_part = tube_speed_list[math.random(1,#tube_speed_list)]
											local tube_speed_msg = string.format(_("msgEngineer","One of the passengers that just boarded was interested in the weapons tubes. He showed you how to speed up the weapons tube load time by about 25%%. You could double that if you acquire some %s."),comms_source.tube_speed_upgrade_part)
											comms_source.tube_speed_msg_eng = "tube_speed_msg_eng"
											comms_source.tube_speed_msg_plus = "tube_speed_msg_plus"
											comms_source:addCustomMessage("Engineering",comms_source.tube_speed_msg_eng,tube_speed_msg)
											comms_source:addCustomMessage("Engineering+",comms_source.tube_speed_msg_plus,tube_speed_msg)
											comms_source.upgrade_reminder_button_eng = "upgrade_reminder_button_eng"
											comms_source:addCustomButton("Engineering",comms_source.upgrade_reminder_button_eng,_("buttonEngineer","Upgrade Notes"),function()
												string.format("")
												upgradeReminder("Engineering",comms_source.upgrade_reminder_button_eng)
											end)
											comms_source.upgrade_reminder_button_plus = "upgrade_reminder_button_plus"
											comms_source:addCustomButton("Engineering+",comms_source.upgrade_reminder_button_plus,_("buttonEngineer+","Upgrade Notes"),function()
												string.format("")
												upgradeReminder("Engineering+",comms_source.upgrade_reminder_button_plus)
											end)
										end
									end
								end
							end)
						end
					end
				end
				if mission_count > 0 then
					setCommsMessage(string.format(_("station-comms","We have the following %i mission(s) available:\nClick to accept mission"),mission_count))
				else
					setCommsMessage(_("station-comms","We have no missions available"))
				end
				mission_count = 0
				for mission_index, mission in ipairs(taxi_missions) do
					if mission.origin:isValid() and mission.destination:isValid() and comms_target == mission.destination then
						if mission.origin.residents > mission.count and comms_source.resident_capacity > mission.count then
							mission_count = mission_count + 1
						end
					end
				end
				if mission_count > 0 then
					addCommsReply(_("station-comms","What about armored transport missions that end here?"),function()
						string.format("")	--global context for serious proton
						local out = ""
						mission_count = 0
						for mission_index, mission in ipairs(taxi_missions) do
							if mission.origin:isValid() and mission.destination:isValid() and comms_target == mission.destination then
								if mission.origin.residents > mission.count and comms_source.resident_capacity > mission.count then
									mission_count = mission_count + 1
									out = out .. "\n" .. mission.desc
								end
							end
						end
						if out == "" then
							out = _("station-comms","No missions that we could find")
						else
							if mission_count > 1 then
								out = _("station-comms","According to our connections software, these are missions that end here:") .. out
							else
								out = _("station-comms","According to our connections software, this mission ends here:") .. out
							end
						end
						setCommsMessage(out)
						addCommsReply(_("Back","Back"), commsStation)
					end)
				end
				addCommsReply(_("Back","Back"), commsStation)
			end)
		end
		if comms_source.taxi_missions ~= nil and #comms_source.taxi_missions > 0 then
			--loop through missions already accepted to see if they can be completed here
			for mission_index, mission in ipairs(comms_source.taxi_missions) do
				if mission.destination:isValid() then
					if mission.destination == comms_target then
						addCommsReply(string.format(_("station-comms","Complete transportation mission to %s"),mission.destination:getCallSign()),function()
							comms_source:addReputationPoints(mission.payoff)
							comms_target.residents = comms_target.residents + mission.count
							comms_source.resident_capacity = comms_source.resident_capacity + mission.count
							if comms_source.residents["neutral"] >= mission.count then
								comms_source.residents["neutral"] = comms_source.residents["neutral"] - mission.count
							else
								comms_source.residents["friend"] = comms_source.residents["friend"] - mission.count
							end
							setCommsMessage(string.format(_("station-comms","This mission:\n%s\n...has been completed"),mission.desc))
							comms_source.taxi_missions[mission_index] = comms_source.taxi_missions[#comms_source.taxi_missions]
							comms_source.taxi_missions[#comms_source.taxi_missions] = nil
						end)
					end
				else
					addCommsReply(string.format(_("station-comms","Unknown %i"),mission_index),function()
						comms_source:addReputationPoints(math.floor(mission.payoff/2))
						setCommsMessage(string.format(_("station-comms","This mission:\n%s\n...is no longer valid since the destination station has been destroyed. You've received half of the planned reputation since you completed the first part and the passengers are glad to still be alive."),mission.desc))
						comms_source.taxi_missions[mission_index] = comms_source.taxi_missions[#comms_source.taxi_missions]
						comms_source.taxi_missions[#comms_source.taxi_missions] = nil
					end)
				end
			end
		end
	end
	local missilePresence = 0
	local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	for _, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + comms_source:getWeaponStorageMax(missile_type)
	end
	if missilePresence > 0 then
		if 	(comms_target.comms_data.weapon_available.Nuke   and comms_source:getWeaponStorageMax("Nuke") > 0)   or 
			(comms_target.comms_data.weapon_available.EMP    and comms_source:getWeaponStorageMax("EMP") > 0)    or 
			(comms_target.comms_data.weapon_available.Homing and comms_source:getWeaponStorageMax("Homing") > 0) or 
			(comms_target.comms_data.weapon_available.Mine   and comms_source:getWeaponStorageMax("Mine") > 0)   or 
			(comms_target.comms_data.weapon_available.HVLI   and comms_source:getWeaponStorageMax("HVLI") > 0)   then
			addCommsReply(_("ammo-comms","I need ordnance restocked"), function()
				if stationCommsDiagnostic then print("in restock function") end
				setCommsMessage(string.format(_("ammo-comms","What type of ordnance?\n\nReputation: %i"),math.floor(comms_source:getReputationPoints())))
				if stationCommsDiagnostic then print(string.format("player nuke weapon storage max: %.1f",comms_source:getWeaponStorageMax("Nuke"))) end
				if comms_source:getWeaponStorageMax("Nuke") > 0 then
					if stationCommsDiagnostic then print("player can fire nukes") end
					if comms_target.comms_data.weapon_available.Nuke then
						if stationCommsDiagnostic then print("station has nukes available") end
						if math.random(1,10) <= 5 then
							nukePrompt = _("ammo-comms","Can you supply us with some nukes? (")
						else
							nukePrompt = _("ammo-comms","We really need some nukes (")
						end
						if stationCommsDiagnostic then print("nuke prompt: " .. nukePrompt) end
						addCommsReply(nukePrompt .. getWeaponCost("Nuke") .. _("ammo-comms"," rep each)"), function()
							if stationCommsDiagnostic then print("going to handle weapon restock function") end
							handleWeaponRestock("Nuke")
						end)
					end	--end station has nuke available if branch
				end	--end player can accept nuke if branch
				if comms_source:getWeaponStorageMax("EMP") > 0 then
					if comms_target.comms_data.weapon_available.EMP then
						if math.random(1,10) <= 5 then
							empPrompt = _("ammo-comms","Please re-stock our EMP missiles. (")
						else
							empPrompt = _("ammo-comms","Got any EMPs? (")
						end
						addCommsReply(empPrompt .. getWeaponCost("EMP") .. _("ammo-comms"," rep each)"), function()
							handleWeaponRestock("EMP")
						end)
					end	--end station has EMP available if branch
				end	--end player can accept EMP if branch
				if comms_source:getWeaponStorageMax("Homing") > 0 then
					if comms_target.comms_data.weapon_available.Homing then
						if math.random(1,10) <= 5 then
							homePrompt = _("ammo-comms","Do you have spare homing missiles for us? (")
						else
							homePrompt = _("ammo-comms","Do you have extra homing missiles? (")
						end
						addCommsReply(homePrompt .. getWeaponCost("Homing") .. _("ammo-comms"," rep each)"), function()
							handleWeaponRestock("Homing")
						end)
					end	--end station has homing for player if branch
				end	--end player can accept homing if branch
				if comms_source:getWeaponStorageMax("Mine") > 0 then
					if comms_target.comms_data.weapon_available.Mine then
						if math.random(1,10) <= 5 then
							minePrompt = _("ammo-comms","We could use some mines. (")
						else
							minePrompt = _("ammo-comms","How about mines? (")
						end
						addCommsReply(minePrompt .. getWeaponCost("Mine") .. _("ammo-comms"," rep each)"), function()
							handleWeaponRestock("Mine")
						end)
					end	--end station has mine for player if branch
				end	--end player can accept mine if branch
				if comms_source:getWeaponStorageMax("HVLI") > 0 then
					if comms_target.comms_data.weapon_available.HVLI then
						if math.random(1,10) <= 5 then
							hvliPrompt = _("ammo-comms","What about HVLI? (")
						else
							hvliPrompt = _("ammo-comms","Could you provide HVLI? (")
						end
						addCommsReply(hvliPrompt .. getWeaponCost("HVLI") .. _("ammo-comms"," rep each)"), function()
							handleWeaponRestock("HVLI")
						end)
					end	--end station has HVLI for player if branch
				end	--end player can accept HVLI if branch
			end)	--end player requests secondary ordnance comms reply branch
		end	--end secondary ordnance available from station if branch
	end	--end missles used on player ship if branch
	addCommsReply(_("station-comms","Docking services status"), function()
		local service_status = string.format(_("station-comms","Station %s docking services status:"),comms_target:getCallSign())
		if comms_target:getRestocksScanProbes() then
			service_status = string.format(_("station-comms","%s\nReplenish scan probes."),service_status)
		else
			if comms_target.probe_fail_reason == nil then
				local reason_list = {
					_("station-comms","Cannot replenish scan probes due to fabrication unit failure."),
					_("station-comms","Parts shortage prevents scan probe replenishment."),
					_("station-comms","Station management has curtailed scan probe replenishment for cost cutting reasons."),
				}
				comms_target.probe_fail_reason = reason_list[math.random(1,#reason_list)]
			end
			service_status = string.format("%s\n%s",service_status,comms_target.probe_fail_reason)
		end
		if comms_target:getRepairDocked() then
			service_status = string.format(_("station-comms","%s\nShip hull repair."),service_status)
		else
			if comms_target.repair_fail_reason == nil then
				reason_list = {
					_("station-comms","We're out of the necessary materials and supplies for hull repair."),
					_("station-comms","Hull repair automation unavailable while it is undergoing maintenance."),
					_("station-comms","All hull repair technicians quarantined to quarters due to illness."),
				}
				comms_target.repair_fail_reason = reason_list[math.random(1,#reason_list)]
			end
			service_status = string.format("%s\n%s",service_status,comms_target.repair_fail_reason)
		end
		if comms_target:getSharesEnergyWithDocked() then
			service_status = string.format(_("station-comms","%s\nRecharge ship energy stores."),service_status)
		else
			if comms_target.energy_fail_reason == nil then
				reason_list = {
					_("station-comms","A recent reactor failure has put us on auxiliary power, so we cannot recharge ships."),
					_("station-comms","A damaged power coupling makes it too dangerous to recharge ships."),
					_("station-comms","An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now."),
				}
				comms_target.energy_fail_reason = reason_list[math.random(1,#reason_list)]
			end
			service_status = string.format("%s\n%s",service_status,comms_target.energy_fail_reason)
		end
		if comms_target.comms_data.jump_overcharge then
			service_status = string.format(_("station-comms","%s\nMay overcharge jump drive"),service_status)
		end
		if comms_target.comms_data.probe_launch_repair then
			service_status = string.format(_("station-comms","%s\nMay repair probe launch system"),service_status)
		end
		if comms_target.comms_data.hack_repair then
			service_status = string.format(_("station-comms","%s\nMay repair hacking system"),service_status)
		end
		if comms_target.comms_data.scan_repair then
			service_status = string.format(_("station-comms","%s\nMay repair scanners"),service_status)
		end
		if comms_target.comms_data.combat_maneuver_repair then
			service_status = string.format(_("station-comms","%s\nMay repair combat maneuver"),service_status)
		end
		if comms_target.comms_data.self_destruct_repair then
			service_status = string.format(_("station-comms","%s\nMay repair self destruct system"),service_status)
		end
		setCommsMessage(service_status)
		addCommsReply(_("Back","Back"), commsStation)
	end)
	if comms_target.comms_data.jump_overcharge then
		if comms_source:hasJumpDrive() then
			local max_charge = comms_source.max_jump_range
			if max_charge == nil then
				max_charge = 50000
			end
			if comms_source:getJumpDriveCharge() >= max_charge then
				addCommsReply(_("station-comms","Overcharge Jump Drive (10 Rep)"),function()
					if comms_source:takeReputationPoints(10) then
						comms_source:setJumpDriveCharge(comms_source:getJumpDriveCharge() + max_charge)
						setCommsMessage(string.format(_("station-comms","Your jump drive has been overcharged to %ik"),math.floor(comms_source:getJumpDriveCharge()/1000)))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
					addCommsReply(_("Back","Back"), commsStation)
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
		addCommsReply(_("station-comms","Repair ship system"),function()
			setCommsMessage(string.format(_("station-comms","What system would you like repaired?\n\nReputation: %i"),math.floor(comms_source:getReputationPoints())))
			if comms_target.comms_data.probe_launch_repair then
				if not comms_source:getCanLaunchProbe() then
					addCommsReply(string.format(_("station-comms","Repair probe launch system (%s Rep)"),comms_target.comms_data.service_cost.probe_launch_repair),function()
						if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.probe_launch_repair) then
							comms_source:setCanLaunchProbe(true)
							if comms_target.comms_data.mission_message == nil then
								setCommsMessage(_("station-comms","Your probe launch system has been repaired"))
							else
								setCommsMessage(string.format(_("station-comms","Your probe launch system has been repaired.\n\n%s"),comms_target.comms_data.mission_message))
							end
						else
							setCommsMessage(_("needRep-comms","Insufficient reputation"))
						end
						addCommsReply(_("Back","Back"), commsStation)
					end)
				end
			end
			if comms_target.comms_data.hack_repair then
				if not comms_source:getCanHack() then
					addCommsReply(string.format(_("station-comms","Repair hacking system (%s Rep)"),comms_target.comms_data.service_cost.hack_repair),function()
						if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.hack_repair) then
							comms_source:setCanHack(true)
							if comms_target.comms_data.mission_message == nil then
								setCommsMessage(_("station-comms","Your hack system has been repaired"))
							else
								setCommsMessage(string.format(_("station-comms","Your hack system has been repaired.\n\n%s"),comms_target.comms_data.mission_message))
							end
						else
							setCommsMessage(_("needRep-comms","Insufficient reputation"))
						end
						addCommsReply(_("Back","Back"), commsStation)
					end)
				end
			end
			if comms_target.comms_data.scan_repair then
				if not comms_source:getCanScan() then
					addCommsReply(string.format(_("station-comms","Repair scanning system (%s Rep)"),comms_target.comms_data.service_cost.scan_repair),function()
						if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.scan_repair) then
							comms_source:setCanScan(true)
							if comms_target.comms_data.mission_message == nil then
								setCommsMessage(_("station-comms","Your scanners have been repaired"))
							else
								setCommsMessage(string.format(_("station-comms","Your scanners have been repaired.\n\n%s"),comms_target.comms_data.mission_message))
							end
						else
							setCommsMessage(_("needRep-comms","Insufficient reputation"))
						end
						addCommsReply(_("Back","Back"), commsStation)
					end)
				end
			end
			if comms_target.comms_data.combat_maneuver_repair then
				if not comms_source:getCanCombatManeuver() then
					addCommsReply(string.format(_("station-comms","Repair combat maneuver (%s Rep)"),comms_target.comms_data.service_cost.combat_maneuver_repair),function()
						if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.combat_maneuver_repair) then
							comms_source:setCanCombatManeuver(true)
							if comms_target.comms_data.mission_message == nil then
								setCommsMessage(_("station-comms","Your combat maneuver has been repaired"))
							else
								setCommsMessage(string.format(_("station-comms","Your combat maneuver has been repaired.\n\n%s"),comms_target.comms_data.mission_message))
							end
						else
							setCommsMessage(_("needRep-comms","Insufficient reputation"))
						end
						addCommsReply(_("Back","Back"), commsStation)
					end)
				end
			end
			if comms_target.comms_data.self_destruct_repair then
				if not comms_source:getCanSelfDestruct() then
					addCommsReply(string.format(_("station-comms","Repair self destruct system (%s Rep)"),comms_target.comms_data.service_cost.self_destruct_repair),function()
						if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.self_destruct_repair) then
							comms_source:setCanSelfDestruct(true)
							if comms_target.comms_data.mission_message == nil then
								setCommsMessage(_("station-comms","Your self destruct system has been repaired"))
							else
								setCommsMessage(string.format(_("station-comms","Your self destruct system has been repaired.\n\n%s"),comms_target.comms_data.mission_message))
							end
						else
							setCommsMessage(_("needRep-comms","Insufficient reputation"))
						end
						addCommsReply(_("Back","Back"), commsStation)
					end)
				end
			end
			addCommsReply(_("Back","Back"), commsStation)
		end)
	end
	local has_gossip = random(1,100) < (100 - (30 * (difficulty - .5)))
	if (comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "") or
		(comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "") or
		(comms_source:isFriendly(comms_target) and comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" and has_gossip) then
		addCommsReply(_("station-comms","Tell me more about your station"), function()
			setCommsMessage(_("station-comms","What would you like to know?"))
			if comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "" then
				addCommsReply(_("station-comms","General information"), function()
					setCommsMessage(comms_target.comms_data.general)
					addCommsReply(_("Back","Back"), commsStation)
				end)
			end
			if comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "" then
				addCommsReply(_("station-comms","Station history"), function()
					setCommsMessage(comms_target.comms_data.history)
					addCommsReply(_("Back","Back"), commsStation)
				end)
			end
			if comms_source:isFriendly(comms_target) then
				if comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" then
					if random(1,100) < (100 - (30 * (difficulty - .5))) then
						addCommsReply(_("station-comms","Gossip"), function()
							setCommsMessage(comms_target.comms_data.gossip)
							addCommsReply(_("Back","Back"), commsStation)
						end)
					end
				end
			end
			addCommsReply(_("Back","Back"), commsStation)
		end)	--end station info comms reply branch
	end
	if comms_source:isFriendly(comms_target) then
		addCommsReply(_("orders-comms", "What are my current orders?"), function()
			setOptionalOrders()
			setSecondaryOrders()
			ordMsg = primary_orders .. "\n" .. secondary_orders .. optional_orders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format(_("orders-comms", "\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply(_("Back"), commsStation)
		end)
		getRepairCrewFromStation("friendly")
		getCoolantFromStation("friendly")
	else
		getRepairCrewFromStation("neutral")
		getCoolantFromStation("neutral")
	end
	local goodCount = 0
	for good, goodData in pairs(comms_target.comms_data.goods) do
		goodCount = goodCount + 1
	end
	if goodCount > 0 then
		addCommsReply(_("station-comms","Buy, sell, trade"), function()
			local goodsReport = string.format(_("station-comms","Station %s:\nGoods or components available for sale: quantity, cost in reputation\n"),comms_target:getCallSign())
			for good, goodData in pairs(comms_target.comms_data.goods) do
				goodsReport = goodsReport .. string.format("     %s: %i, %i\n",good,goodData["quantity"],goodData["cost"])
			end
			if comms_target.comms_data.buy ~= nil then
				goodsReport = goodsReport .. _("station-comms","Goods or components station will buy: price in reputation\n")
				for good, price in pairs(comms_target.comms_data.buy) do
					goodsReport = goodsReport .. string.format("     %s: %i\n",good,price)
				end
			end
			goodsReport = goodsReport .. string.format(_("station-comms","Current cargo aboard %s:\n"),comms_source:getCallSign())
			local cargoHoldEmpty = true
			local player_good_count = 0
			if comms_source.goods ~= nil then
				for good, goodQuantity in pairs(comms_source.goods) do
					player_good_count = player_good_count + 1
					goodsReport = goodsReport .. string.format("     %s: %i\n",good,goodQuantity)
				end
			end
			if player_good_count < 1 then
				goodsReport = goodsReport .. _("station-comms","     Empty\n")
			end
			goodsReport = goodsReport .. string.format(_("station-comms","Available Space: %i, Available Reputation: %i\n"),comms_source.cargo,math.floor(comms_source:getReputationPoints()))
			setCommsMessage(goodsReport)
			for good, goodData in pairs(comms_target.comms_data.goods) do
				addCommsReply(string.format(_("station-comms","Buy one %s for %i reputation"),good,goodData["cost"]), function()
					local goodTransactionMessage = string.format(_("station-comms","Type: %s, Quantity: %i, Rep: %i"),good,goodData["quantity"],goodData["cost"])
					if comms_source.cargo < 1 then
						goodTransactionMessage = goodTransactionMessage .. _("station-comms","\nInsufficient cargo space for purchase")
					elseif goodData["cost"] > math.floor(comms_source:getReputationPoints()) then
						goodTransactionMessage = goodTransactionMessage .. _("station-comms","\nInsufficient reputation for purchase")
					elseif goodData["quantity"] < 1 then
						goodTransactionMessage = goodTransactionMessage .. _("station-comms","\nInsufficient station inventory")
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
							goodTransactionMessage = goodTransactionMessage .. _("station-comms","\npurchased")
						else
							goodTransactionMessage = goodTransactionMessage .. _("station-comms","\nInsufficient reputation for purchase")
						end
					end
					setCommsMessage(goodTransactionMessage)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if comms_target.comms_data.buy ~= nil then
				for good, price in pairs(comms_target.comms_data.buy) do
					if comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
						addCommsReply(string.format(_("station-comms","Sell one %s for %i reputation"),good,price), function()
							local goodTransactionMessage = string.format(_("station-comms","Type: %s,  Reputation price: %i"),good,price)
							comms_source.goods[good] = comms_source.goods[good] - 1
							comms_source:addReputationPoints(price)
							goodTransactionMessage = goodTransactionMessage .. _("station-comms","\nOne sold")
							comms_source.cargo = comms_source.cargo + 1
							setCommsMessage(goodTransactionMessage)
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
			end
			if comms_target.comms_data.trade.food then
				if comms_source.goods ~= nil then
					if comms_source.goods.food ~= nil then
						if comms_source.goods.food.quantity > 0 then
							for good, goodData in pairs(comms_target.comms_data.goods) do
								addCommsReply(string.format(_("station-comms","Trade food for %s"),good), function()
									local goodTransactionMessage = string.format(_("station-comms","Type: %s,  Quantity: %i"),good,goodData["quantity"])
									if goodData["quantity"] < 1 then
										goodTransactionMessage = goodTransactionMessage .. _("station-comms","\nInsufficient station inventory")
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
										goodTransactionMessage = goodTransactionMessage .. _("station-comms","\nTraded")
									end
									setCommsMessage(goodTransactionMessage)
									addCommsReply(_("Back"), commsStation)
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
								addCommsReply(string.format(_("station-comms","Trade medicine for %s"),good), function()
									local goodTransactionMessage = string.format(_("station-comms","Type: %s,  Quantity: %i"),good,goodData["quantity"])
									if goodData["quantity"] < 1 then
										goodTransactionMessage = goodTransactionMessage .. _("station-comms","\nInsufficient station inventory")
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
										goodTransactionMessage = goodTransactionMessage .. _("station-comms","\nTraded")
									end
									setCommsMessage(goodTransactionMessage)
									addCommsReply(_("Back"), commsStation)
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
								addCommsReply(string.format(_("station-comms","Trade luxury for %s"),good), function()
									local goodTransactionMessage = string.format(_("station-comms","Type: %s,  Quantity: %i"),good,goodData["quantity"])
									if goodData[quantity] < 1 then
										goodTransactionMessage = goodTransactionMessage .. _("station-comms","\nInsufficient station inventory")
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
										goodTransactionMessage = goodTransactionMessage .. _("station-comms","\nTraded")
									end
									setCommsMessage(goodTransactionMessage)
									addCommsReply(_("Back"), commsStation)
								end)
							end
						end
					end
				end
			end
			addCommsReply(_("Back"), commsStation)
		end)
		local player_good_count = 0
		if comms_source.goods ~= nil then
			for good, goodQuantity in pairs(comms_source.goods) do
				player_good_count = player_good_count + 1
			end
		end
		if player_good_count > 0 then
			addCommsReply(_("station-comms","Jettison cargo"), function()
				setCommsMessage(string.format(_("station-comms","Available space: %i\nWhat would you like to jettison?"),comms_source.cargo))
				for good, good_quantity in pairs(comms_source.goods) do
					if good_quantity > 0 then
						addCommsReply(good, function()
							comms_source.goods[good] = comms_source.goods[good] - 1
							comms_source.cargo = comms_source.cargo + 1
							setCommsMessage(string.format(_("station-comms","One %s jettisoned"),good))
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
		addCommsReply(_("station-comms","No tutorial covered goods or cargo. Explain"), function()
			setCommsMessage(_("station-comms","Different types of cargo or goods may be obtained from stations, freighters or other sources. They go by one word descriptions such as dilithium, optic, warp, etc. Certain mission goals may require a particular type or types of cargo. Each player ship differs in cargo carrying capacity. Goods may be obtained by spending reputation points or by trading other types of cargo (typically food, medicine or luxury)"))
			addCommsReply(_("Back"), commsStation)
		end)
	end
end	--end of handleDockedState function
function getRepairCrewFromStation(relationship)
	addCommsReply(_("trade-comms","Recruit repair crew member"),function()
		if comms_target.comms_data.available_repair_crew == nil then
			comms_target.comms_data.available_repair_crew = math.random(0,3)
		end
		if comms_target.comms_data.available_repair_crew > 0 then	--station has repair crew available
			if comms_target.comms_data.crew_available_delay == nil then
				comms_target.comms_data.crew_available_delay = 0
			end
			if getScenarioTime() > comms_target.comms_data.crew_available_delay then	--no delay in progress
				if random(1,5) <= (3 - difficulty) then		--repair crew available
					local hire_cost = math.random(45,90)
					if relationship ~= "friendly" then
						hire_cost = math.random(60,120)
					end
					if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
						hire_cost = math.random(30,60)
						if relationship ~= "friendly" then
							hire_cost = math.random(45,90)
						end
					end
					setCommsMessage(_("trade-comms","We have a repair crew candidate for you to consider"))
					addCommsReply(string.format(_("trade-comms", "Recruit repair crew member for %i reputation"),hire_cost), function()
						if not comms_source:takeReputationPoints(hire_cost) then
							setCommsMessage(_("needRep-comms", "Insufficient reputation"))
						else
							comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
							comms_target.comms_data.available_repair_crew = comms_target.comms_data.available_repair_crew - 1
							if comms_target.comms_data.available_repair_crew <= 0 then
								comms_target.comms_data.new_repair_crew_delay = getScenarioTime() + random(200,500)
							end
							setCommsMessage(_("trade-comms", "Repair crew member hired"))
						end
						addCommsReply(_("Back"), commsStation)
					end)
				else	--repair crew delayed
					local delay_reason = {
						_("trade-comms","A possible repair recruit is awaiting final certification. They should be available in "),
						_("trade-comms","There's one repair crew candidate completing their license application. They should be available in "),
						_("trade-comms","One repair crew should be getting here from their medical checkout in "),
					}
					local delay_seconds = math.random(10,30)
					comms_target.comms_data.crew_available_delay = getScenarioTime() + delay_seconds
					comms_target.comms_data.crew_available_delay_reason = delay_reason[math.random(1,#delay_reason)]
					setCommsMessage(string.format(_("trade-comms","%s %i seconds"),comms_target.comms_data.crew_available_delay_reason,delay_seconds))
				end
			else	--delay in progress
				local delay_seconds = math.floor(comms_target.comms_data.crew_available_delay - getScenarioTime())
				if delay_seconds > 1 then
					setCommsMessage(string.format(_("trade-comms","%s %i seconds"),comms_target.comms_data.crew_available_delay_reason,delay_seconds))
				else
					setCommsMessage(string.format(_("trade-comms","%s a second"),comms_target.comms_data.crew_available_delay_reason))
				end
			end
		else	--station does not have repair crew available
			if comms_target.comms_data.new_repair_crew_delay == nil then
				comms_target.comms_data.new_repair_crew_delay = 0
			end
			if getScenarioTime() > comms_target.comms_data.new_repair_crew_delay then
				comms_target.comms_data.available_repair_crew = math.random(1,3)
				local delay_reason = {
					_("trade-comms","A possible repair recruit is awaiting final certification. They should be available in "),
					_("trade-comms","There's one repair crew candidate completing their license application. They should be available in "),
					_("trade-comms","One repair crew should be getting here from their medical checkout in "),
				}
				local delay_seconds = math.random(10,30)
				comms_target.comms_data.crew_available_delay = getScenarioTime() + delay_seconds
				comms_target.comms_data.crew_available_delay_reason = delay_reason[math.random(1,#delay_reason)]
				setCommsMessage(string.format(_("trade-comms","Several arrived on station earlier. %s %i seconds"),comms_target.comms_data.crew_available_delay_reason,delay_seconds))
			else
				local delay_time = math.floor(comms_target.comms_data.new_repair_crew_delay - getScenarioTime())
				local delay_minutes = math.floor(delay_time / 60)
				local delay_seconds = math.floor(delay_time % 60)
				local delay_status = string.format(_("trade-comms","%i seconds"),delay_seconds)
				if delay_seconds == 1 then
					delay_status = string.format(_("trade-comms","%i second"),delay_seconds)
				end
				if delay_minutes > 0 then
					if delay_minutes > 1 then
						delay_status = string.format(_("trade-comms","%i minutes and %s"),delay_minutes,delay_status)
					else
						delay_status = string.format(_("trade-comms","%i minute and %s"),delay_minutes,delay_status)
					end							
				end
				setCommsMessage(string.format(_("trade-comms","There are some repair crew recruits in route for %s. Travel time remaining is %s."),comms_target:getCallSign(),delay_status))
			end
		end
		addCommsReply(_("Back"), commsStation)
	end)
end
function getCoolantFromStation(relationship)
	if comms_source.initialCoolant ~= nil then
		addCommsReply(_("trade-comms","Purchase Coolant"),function()
			if comms_target.comms_data.coolant_inventory == nil then
				comms_target.comms_data.coolant_inventory = math.random(0,3)*2
			end
			if comms_target.comms_data.coolant_inventory > 0 then	--station has coolant
				if comms_target.comms_data.coolant_packaging_delay == nil then
					comms_target.comms_data.coolant_packaging_delay = 0
				end
				if getScenarioTime() > comms_target.comms_data.coolant_packaging_delay then		--no delay
					if math.random(1,5) <= (3 - difficulty) then
						local coolantCost = math.random(45,90)
						if relationship ~= "friendly" then
							coolantCost = math.random(60,120)
						end
						if comms_source:getMaxCoolant() < comms_source.initialCoolant then
							coolantCost = math.random(30,60)
							if relationship ~= "friendly" then
								coolantCost = math.random(45,90)
							end
						end
						setCommsMessage(_("trade-comms","We've got some coolant available for you"))
						addCommsReply(string.format(_("trade-comms", "Purchase coolant for %i reputation"),coolantCost), function()
							if not comms_source:takeReputationPoints(coolantCost) then
								setCommsMessage(_("needRep-comms", "Insufficient reputation"))
							else
								comms_source:setMaxCoolant(comms_source:getMaxCoolant() + 2)
								comms_target.comms_data.coolant_inventory = comms_target.comms_data.coolant_inventory - 2
								if comms_target.comms_data.coolant_inventory <= 0 then
									comms_target.comms_data.coolant_inventory_delay = getScenarioTime() + random(60,300)
								end
								setCommsMessage(_("trade-comms", "Additional coolant purchased"))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					else
						local delay_seconds = math.random(3,20)
						comms_target.comms_data.coolant_packaging_delay = getScenarioTime() + delay_seconds
						setCommsMessage(string.format(_("trade-comms","The coolant preparation facility is having difficulty packaging the coolant for transport. They say thay should have it working in about %i seconds"),delay_seconds))
					end
				else	--delay in progress
					local delay_seconds = math.floor(comms_target.comms_data.coolant_packaging_delay - getScenarioTime())
					if delay_seconds > 1 then
						setCommsMessage(string.format(_("trade-comms","The coolant preparation facility is having difficulty packaging the coolant for transport. They say they should have it working in about %i seconds"),delay_seconds))
					else
						setCommsMessage(_("trade-comms","The coolant preparation facility is having difficulty packaging the coolant for transportation. They say they should have it working in a second"))
					end
				end
			else	--station is out of coolant
				if comms_target.comms_data.coolant_inventory_delay == nil then
					comms_target.comms_data.coolant_inventory_delay = 0
				end
				if getScenarioTime() > comms_target.comms_data.coolant_inventory_delay then
					comms_target.comms_data.coolant_inventory = math.random(1,3)*2
					local delay_seconds = math.random(3,20)
					comms_target.comms_data.coolant_packaging_delay = getScenarioTime() + delay_seconds
					setCommsMessage(string.format(_("trade-comms","Our coolant production facility just made some, but it's not quite ready to be transported. The preparation facility says it should take about %i seconds"),delay_seconds))
				else
					local delay_time = math.floor(comms_target.comms_data.coolant_inventory_delay - getScenarioTime())
					local delay_minutes = math.floor(delay_time / 60)
					local delay_seconds = math.floor(delay_time % 60)
					local delay_status = string.format(_("trade-comms","%i seconds"),delay_seconds)
					if delay_seconds == 1 then
						delay_status = string.format(_("trade-comms","%i second"),delay_seconds)
					end
					if delay_minutes > 0 then
						if delay_minutes > 1 then
							delay_status = string.format(_("trade-comms","%i minutes and %s"),delay_minutes,delay_status)
						else
							delay_status = string.format(_("trade-comms","%i minute and %s"),delay_minutes,delay_status)
						end							
					end
					setCommsMessage(string.format(_("trade-comms","Our coolant production facility is making more right now. Coolant manufacturing time remaining is %s."),delay_status))
				end
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function setSecondaryOrders()
	secondary_orders = ""
end
function setOptionalOrders()
	optional_orders = ""
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
		setCommsMessage(_("ammo-comms","You need to stay docked for that action."))
		return
	end
    if not isAllowedTo(comms_data.weapons[weapon]) then
        if weapon == "Nuke" then setCommsMessage(_("ammo-comms","We do not deal in weapons of mass destruction."))
        elseif weapon == "EMP" then setCommsMessage(_("ammo-comms","We do not deal in weapons of mass disruption."))
        else setCommsMessage(_("ammo-comms","We do not deal in those weapons.")) end
        return
    end
    local points_per_item = getWeaponCost(weapon)
    local item_amount = math.floor(comms_source:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage(_("ammo-comms","All nukes are charged and primed for destruction."))
        else
            setCommsMessage(_("ammo-comms","Sorry, sir, but you are as fully stocked as I can allow."))
        end
		addCommsReply(_("Back"), commsStation)
    else
		if comms_source:getReputationPoints() > points_per_item * item_amount then
			if comms_source:takeReputationPoints(points_per_item * item_amount) then
				comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
				if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
					setCommsMessage(_("ammo-comms","You are fully loaded and ready to explode things."))
				else
					setCommsMessage(_("ammo-comms","We generously resupplied you with some weapon charges.\nPut them to good use."))
				end
			else
				setCommsMessage(_("needRep-comms","Insufficient reputation"))
				return
			end
		else
			if comms_source:getReputationPoints() > points_per_item then
				setCommsMessage(_("ammo-comms","You can't afford as much as I'd like to give you"))
				addCommsReply(_("ammo-comms","Get just one"), function()
					if comms_source:takeReputationPoints(points_per_item) then
						comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + 1)
						if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
							setCommsMessage(_("ammo-comms","You are fully loaded and ready to explode things."))
						else
							setCommsMessage(_("ammo-comms","We generously resupplied you with one weapon charge.\nPut it to good use."))
						end
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
					return
				end)
			else
				setCommsMessage(_("needRep-comms","Insufficient reputation"))
				return				
			end
		end
		addCommsReply(_("Back"), commsStation)
    end
end
function getWeaponCost(weapon)
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function handleUndockedState()
    --Handle communications when we are not docked with the station.
    if comms_source:isFriendly(comms_target) then
        oMsg = _("station-comms","Good day, officer.\nIf you need supplies, please dock with us first.")
    else
        oMsg = _("station-comms","Greetings.\nIf you want to do business, please dock with us first.")
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. _("station-comms","\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you.")
	end
	if getScenarioTime() > black_hole_milestone then
		oMsg = string.format(_("station-comms","%s\nResidents on %s: %s    %s passenger capacity:%s"),oMsg,comms_target:getCallSign(),comms_target.residents,comms_source:getCallSign(),comms_source.resident_capacity)
	end
	setCommsMessage(oMsg)
	local count_repeat_loop = 0
	repeat
		local wj_deleted = false
		if #warp_jammer_list > 0 then
			for wj_index, wj in ipairs(warp_jammer_list) do
				if wj == nil then
					warp_jammer_list[wj_index] = warp_jammer_list[#warp_jammer_list]
					warp_jammer_list[#warp_jammer_list] = nil
					wj_deleted = true
					break
				elseif not wj:isValid() then
					warp_jammer_list[wj_index] = warp_jammer_list[#warp_jammer_list]
					warp_jammer_list[#warp_jammer_list] = nil
					wj_deleted = true
					break
				end
			end
		end
		count_repeat_loop = count_repeat_loop + 1
	until(not wj_deleted or count_repeat_loop > max_repeat_loop)
	if count_repeat_loop > max_repeat_loop then
		print("repeated too many times when cleaning warp jammer list")
	end
	local accessible_warp_jammers = {}
	for _, wj in ipairs(warp_jammer_list) do
		if wj ~= nil and wj:isValid() then
			if distance(comms_target,wj) < 30000 then
				if wj:isFriendly(comms_source) or wj:isFriendly(comms_target) then
					table.insert(accessible_warp_jammers,wj)
				elseif not wj:isEnemy(comms_source) or not wj:isEnemy(comms_target) then
					table.insert(accessible_warp_jammers,wj)
				end
			end
		end
	end
	if #accessible_warp_jammers > 0 then
		addCommsReply(_("station-comms","Connect to warp jammer"),function()
			setCommsMessage(_("station-comms","Which one would you like to connect to?"))
			for index, wj in ipairs(accessible_warp_jammers) do
				local wj_rep = 0
				if wj:isFriendly(comms_target) then
					if wj:isFriendly(comms_source) then
						wj_rep = 0
					else
						if wj:isEnemy(comms_source) then
							wj_rep = 10
						else
							wj_rep = 5
						end
					end
				elseif wj:isEnemy(comms_target) then
					if wj:isFriendly(comms_source) then
						wj_rep = 15
					else
						if wj:isEnemy(comms_source) then
							--should never get here
							wj_rep = 100
						else
							wj_rep = 20
						end
					end
				else
					if wj:isFriendly(comms_source) then
						wj_rep = 10
					else
						if wj:isEnemy(comms_source) then
							wj_rep = 25
						else
							wj_rep = 20
						end
					end
				end
				local reputation_prompt = ""
				if wj_rep > 0 then
					reputation_prompt = string.format(_("station-comms","(%i reputation)"),wj_rep)
				end
				addCommsReply(string.format("%s %s",wj:getCallSign(),reputation_prompt),function()
					if comms_source:takeReputationPoints(wj_rep) then
						setCommsMessage(string.format(_("station-comms","%s Automated warp jammer access menu"),wj:getCallSign()))
						addCommsReply(_("station-comms","Reduce range to 1 unit for 1 minute"),function()
							wj:setRange(1000)
							wj.reset_time = getScenarioTime() + 60
							setCommsMessage(_("station-comms","Acknowledged. Range adjusted. Reset timer engaged."))
						end)
						addCommsReply(_("station-comms","Reduce range by 50% for 2 minutes"),function()
							wj:setRange(wj.range/2)
							wj.reset_time = getScenarioTime() + 120
							setCommsMessage(_("station-comms","Acknowledged. Range adjusted. Reset timer engaged."))
						end)
						addCommsReply(_("station-comms","Reduce range by 25% for 3 minutes"),function()
							wj:setRange(wj.range*.75)
							wj.reset_time = getScenarioTime() + 180
							setCommsMessage(_("station-comms","Acknowledged. Range adjusted. Reset timer engaged."))
						end)
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				end)
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end
 	addCommsReply(_("station-comms","I need information"), function()
		setCommsMessage(_("station-comms","What kind of information do you need?"))
		addCommsReply(_("station-comms","What are my current orders?"), function()
			setOptionalOrders()
			setSecondaryOrders()
			ordMsg = primary_orders .. "\n" .. secondary_orders .. optional_orders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format(_("station-comms","\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(_("station-comms","Do you have any armored transportation missions?"),function()
			local mission_report = ""
			local deleted_mission = false
			local viable_missions = 0
			local count_repeat_loop = 0
			repeat
				if #taxi_missions > 0 then
					viable_missions = 0
					for mission_index, mission in ipairs(taxi_missions) do
						if mission.origin:isValid() then
							if mission.destination:isValid() then
								if comms_target == mission.origin then
									viable_missions = viable_missions + 1
								end
							else
								taxi_missions[mission_index] = taxi_missions[#taxi_missions]
								taxi_missions[#taxi_missions] = nil
								deleted_mission = true
								break	
							end
						else
							taxi_missions[mission_index] = taxi_missions[#taxi_missions]
							taxi_missions[#taxi_missions] = nil
							deleted_mission = true
							break	
						end
					end
				end
				count_repeat_loop = count_repeat_loop + 1
			until(not deleted_mission or count_repeat_loop > max_repeat_loop)
			if count_repeat_loop > max_repeat_loop then
				print("repeated too many times when seeking viable missions")
				print("taxi mission count:",#taxi_missions,"viable missions:",viable_missions)
			end
			if viable_missions > 0 then
				for mission_index, mission in ipairs(taxi_missions) do
					if mission.origin:isValid() then
						if mission.destination:isValid() then
							if comms_target == mission.origin then
								if mission_report == "" then
									mission_report = _("station-comms","Available mission(s):")
								end
								mission_report = mission_report .. "\n" .. mission.desc
							end
						end
					end
				end
				if mission_report == "" then
					setCommsMessage(_("station-comms","No missions availble"))
				else
					setCommsMessage(mission_report)
				end
			else
				setCommsMessage(_("station-comms","No missions availble"))
			end
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(_("station-comms","What ordnance do you have available for restock?"), function()
			local missileTypeAvailableCount = 0
			local ordnanceListMsg = ""
			if comms_target.comms_data.weapon_available.Nuke then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("station-comms","\n   Nuke")
			end
			if comms_target.comms_data.weapon_available.EMP then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("station-comms","\n   EMP")
			end
			if comms_target.comms_data.weapon_available.Homing then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("station-comms","\n   Homing")
			end
			if comms_target.comms_data.weapon_available.Mine then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("station-comms","\n   Mine")
			end
			if comms_target.comms_data.weapon_available.HVLI then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("station-comms","\n   HVLI")
			end
			if missileTypeAvailableCount == 0 then
				ordnanceListMsg = _("station-comms","We have no ordnance available for restock")
			elseif missileTypeAvailableCount == 1 then
				ordnanceListMsg = _("station-comms","We have the following type of ordnance available for restock:") .. ordnanceListMsg
			else
				ordnanceListMsg = _("station-comms","We have the following types of ordnance available for restock:") .. ordnanceListMsg
			end
			setCommsMessage(ordnanceListMsg)
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(_("station-comms","Docking services status"), function()
			local service_status = string.format(_("station-comms","Station %s docking services status:"),comms_target:getCallSign())
			if comms_target:getRestocksScanProbes() then
				service_status = string.format(_("station-comms","%s\nReplenish scan probes."),service_status)
			else
				if comms_target.probe_fail_reason == nil then
					local reason_list = {
						_("station-comms","Cannot replenish scan probes due to fabrication unit failure."),
						_("station-comms","Parts shortage prevents scan probe replenishment."),
						_("station-comms","Station management has curtailed scan probe replenishment for cost cutting reasons."),
					}
					comms_target.probe_fail_reason = reason_list[math.random(1,#reason_list)]
				end
				service_status = string.format("%s\n%s",service_status,comms_target.probe_fail_reason)
			end
			if comms_target:getRepairDocked() then
				service_status = string.format(_("station-comms","%s\nShip hull repair."),service_status)
			else
				if comms_target.repair_fail_reason == nil then
					reason_list = {
						_("station-comms","We're out of the necessary materials and supplies for hull repair."),
						_("station-comms","Hull repair automation unavailable whie it is undergoing maintenance."),
						_("station-comms","All hull repair technicians quarantined to quarters due to illness."),
					}
					comms_target.repair_fail_reason = reason_list[math.random(1,#reason_list)]
				end
				service_status = string.format("%s\n%s",service_status,comms_target.repair_fail_reason)
			end
			if comms_target:getSharesEnergyWithDocked() then
				service_status = string.format(_("station-comms","%s\nRecharge ship energy stores."),service_status)
			else
				if comms_target.energy_fail_reason == nil then
					reason_list = {
						_("station-comms","A recent reactor failure has put us on auxiliary power, so we cannot recharge ships."),
						_("station-comms","A damaged power coupling makes it too dangerous to recharge ships."),
						_("station-comms","An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now."),
					}
					comms_target.energy_fail_reason = reason_list[math.random(1,#reason_list)]
				end
				service_status = string.format("%s\n%s",service_status,comms_target.energy_fail_reason)
			end
			if comms_target.comms_data.jump_overcharge then
				service_status = string.format(_("station-comms","%s\nMay overcharge jump drive"),service_status)
			end
			if comms_target.comms_data.probe_launch_repair then
				service_status = string.format(_("station-comms","%s\nMay repair probe launch system"),service_status)
			end
			if comms_target.comms_data.hack_repair then
				service_status = string.format(_("station-comms","%s\nMay repair hacking system"),service_status)
			end
			if comms_target.comms_data.scan_repair then
				service_status = string.format(_("station-comms","%s\nMay repair scanners"),service_status)
			end
			if comms_target.comms_data.combat_maneuver_repair then
				service_status = string.format(_("station-comms","%s\nMay repair combat maneuver"),service_status)
			end
			if comms_target.comms_data.self_destruct_repair then
				service_status = string.format(_("station-comms","%s\nMay repair self destruct system"),service_status)
			end
			setCommsMessage(service_status)
			addCommsReply(_("Back"), commsStation)
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
			addCommsReply(_("trade-comms","What goods do you have available for sale or trade?"), function()
				local goodsAvailableMsg = string.format(_("trade-comms","Station %s:\nGoods or components available: quantity, cost in reputation"),comms_target:getCallSign())
				for good, goodData in pairs(comms_target.comms_data.goods) do
					goodsAvailableMsg = goodsAvailableMsg .. string.format("\n   %14s: %2i, %3i",good,goodData["quantity"],goodData["cost"])
				end
				setCommsMessage(goodsAvailableMsg)
				addCommsReply(_("Back"), commsStation)
			end)
		end
		addCommsReply(_("trade-comms","Where can I find particular goods?"), function()
			gkMsg = _("trade-comms","Friendly stations often have food or medicine or both. Neutral stations may trade their goods for food, medicine or luxury.")
			if comms_target.comms_data.goodsKnowledge == nil then
				comms_target.comms_data.goodsKnowledge = {}
				local knowledgeCount = 0
				local knowledgeMax = 10
				for i=1,#station_list do
					local station = station_list[i]
					if station ~= nil and station:isValid() then
						if not station:isEnemy(comms_source) then
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
					setCommsMessage(string.format(_("trade-comms","Station %s in sector %s has %s for %i reputation"),stationName,sectorName,goodName,goodCost))
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if goodsKnowledgeCount > 0 then
				gkMsg = gkMsg .. _("trade-comms","\n\nWhat goods are you interested in?\nI've heard about these:")
			else
				gkMsg = gkMsg .. _("trade-comms"," Beyond that, I have no knowledge of specific stations")
			end
			setCommsMessage(gkMsg)
			addCommsReply(_("Back"), commsStation)
		end)
		local has_gossip = random(1,100) < (100 - (30 * (difficulty - .5)))
		if (comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "") or
			(comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "") or
			(comms_source:isFriendly(comms_target) and comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" and has_gossip) then
			addCommsReply(_("station-comms","Tell me more about your station"), function()
				setCommsMessage(_("station-comms","What would you like to know?"))
				if comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "" then
					addCommsReply(_("station-comms","General information"), function()
						setCommsMessage(comms_target.comms_data.general)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "" then
					addCommsReply(_("station-comms","Station history"), function()
						setCommsMessage(comms_target.comms_data.history)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if comms_source:isFriendly(comms_target) then
					if comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" then
						if random(1,100) < 50 then
							addCommsReply(_("gossip-comms","Gossip"), function()
								setCommsMessage(comms_target.comms_data.gossip)
								addCommsReply(_("Back"), commsStation)
							end)
						end
					end
				end
			end)	--end station info comms reply branch
		end	--end public relations if branch
		if comms_target.comms_data.character ~= nil then
			if random(1,100) < (70 - (20 * difficulty)) then
				addCommsReply(string.format(_("station-comms","Tell me about %s"),comms_target.comms_data.character), function()
					if comms_target.comms_data.characterDescription ~= nil then
						setCommsMessage(comms_target.comms_data.characterDescription)
					else
						if comms_target.comms_data.characterDeadEnd == nil then
							local deadEndChoice = math.random(1,5)
							if deadEndChoice == 1 then
								comms_target.comms_data.characterDeadEnd = _("station-comms","Never heard of ") .. comms_target.comms_data.character
							elseif deadEndChoice == 2 then
								comms_target.comms_data.characterDeadEnd = string.format(_("station-comms","%s died last week. The funeral was yesterday"),comms_target.comms_data.character)
							elseif deadEndChoice == 3 then
								comms_target.comms_data.characterDeadEnd = string.format(_("station-comms","%s? Who's %s? There's nobody here named %s"),comms_target.comms_data.character,comms_target.comms_data.character,comms_target.comms_data.character)
							elseif deadEndChoice == 4 then
								comms_target.comms_data.characterDeadEnd = string.format(_("station-comms","We don't talk about %s. They are gone and good riddance"),comms_target.comms_data.character)
							else
								comms_target.comms_data.characterDeadEnd = string.format(_("station-comms","I think %s moved away"),comms_target.comms_data.character)
							end
						end
						setCommsMessage(comms_target.comms_data.characterDeadEnd)
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
		end
		addCommsReply(_("station-comms","Report status"), function()
			msg = _("station-comms","Hull: ") .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
			local shields = comms_target:getShieldCount()
			if shields == 1 then
				msg = msg .. _("station-comms","Shield: ") .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			else
				for n=0,shields-1 do
					msg = msg .. _("station-comms","Shield " .. n .. ": ") .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
				end
			end			
			setCommsMessage(msg);
			addCommsReply(_("Back"), commsStation)
		end)
	end)
	if isAllowedTo(comms_target.comms_data.services.supplydrop) then
        addCommsReply(string.format(_("station-comms","Can you send a supply drop? (%s rep)"),getServiceCost("supplydrop")), function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage(_("station-comms","You need to set a waypoint before you can request supplies."))
            else
                setCommsMessage(_("station-comms","To which waypoint should we deliver your supplies?"))
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply(string.format(_("station-comms","Waypoint %i"),n), function()
						if comms_source:takeReputationPoints(getServiceCost("supplydrop")) then
							local position_x, position_y = comms_target:getPosition()
							local target_x, target_y = comms_source:getWaypoint(n)
							local script = Script()
							script:setVariable("position_x", position_x):setVariable("position_y", position_y)
							script:setVariable("target_x", target_x):setVariable("target_y", target_y)
							script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
							setCommsMessage(string.format(_("station-comms","We have dispatched a supply ship toward Waypoint %i"),n))
						else
							setCommsMessage(_("needRep-comms","Insufficient reputation"))
						end
						addCommsReply(_("Back"), commsStation)
                    end)
                end
            end
			addCommsReply(_("Back"), commsStation)
        end)
    end
    if isAllowedTo(comms_target.comms_data.services.reinforcements) then
        addCommsReply(string.format(_("station-comms","Please send reinforcements! (%s rep)"),getServiceCost("reinforcements")), function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage(_("station-comms","You need to set a waypoint before you can request reinforcements."))
            else
                setCommsMessage(_("station-comms","To which waypoint should we dispatch the reinforcements?"))
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply(string.format(_("station-comms","Waypoint %i"),n), function()
						if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
							ship = CpuShip():setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setCallSign(generateCallSign(nil,"Human Navy")):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
							ship:setFactionId(comms_target:getFactionId())
							ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(friendlyVesselDestroyed)
							setCommsMessage(string.format(_("station-comms","We have dispatched %s to assist at Waypoint %i"),ship:getCallSign(),n))
						else
							setCommsMessage(_("needRep-comms","Insufficient reputation"))
						end
						addCommsReply(_("Back"), commsStation)
                    end)
                end
            end
			addCommsReply(_("Back"), commsStation)
        end)
    end
    if isAllowedTo(comms_target.comms_data.services.servicejonque) then
    	addCommsReply(_("station-comms","Please send a service jonque for repairs"), function()
    		local out = string.format(_("station-comms","Would you like the service jonque to come to you directly or would you prefer to set up a rendezvous via a waypoint? Either way, you will need %.1f reputation."),getServiceCost("servicejonque"))
    		addCommsReply(_("station-comms","Direct"),function()
    			if comms_source:takeReputationPoints(getServiceCost("servicejonque")) then
					ship = serviceJonque(comms_target:getFaction()):setPosition(comms_target:getPosition()):setCallSign(generateCallSign(nil,comms_target:getFaction())):setScanned(true):orderDefendTarget(comms_source)
					ship.comms_data = {
						friendlyness = random(0.0, 100.0),
						weapons = {
							Homing = comms_target.comms_data.weapons.Homing,
							HVLI = comms_target.comms_data.weapons.HVLI,
							Mine = comms_target.comms_data.weapons.Mine,
							Nuke = comms_target.comms_data.weapons.Nuke,
							EMP = comms_target.comms_data.weapons.EMP,
						},
						weapon_cost = {
							Homing = comms_target.comms_data.weapon_cost.Homing * 2,
							HVLI = comms_target.comms_data.weapon_cost.HVLI * 2,
							Mine = comms_target.comms_data.weapon_cost.Mine * 2,
							Nuke = comms_target.comms_data.weapon_cost.Nuke * 2,
							EMP = comms_target.comms_data.weapon_cost.EMP * 2,
						},
						weapon_inventory = {
							Homing = 40,
							HVLI = 40,
							Mine = 20,
							Nuke = 10,
							EMP = 10,
						},
						weapon_inventory_max = {
							Homing = 40,
							HVLI = 40,
							Mine = 20,
							Nuke = 10,
							EMP = 10,
						},
						reputation_cost_multipliers = {
							friend = comms_target.comms_data.reputation_cost_multipliers.friend,
							neutral = math.max(comms_target.comms_data.reputation_cost_multipliers.friend,comms_target.comms_data.reputation_cost_multipliers.neutral/2)
						},
					}
					setCommsMessage(string.format(_("station-comms","We have dispatched %s to come to you to help with repairs"),ship:getCallSign()))
    			else
					setCommsMessage(_("needRep-comms","Insufficient reputation"))
    			end
				addCommsReply(_("Back"), commsStation)
    		end)
    		if comms_source:getWaypointCount() < 1 then
    			out = out .. _("station-comms","\n\nNote: if you want to use a waypoint, you will have to back out and set one and come back.")
    		else
    			for n=1,comms_source:getWaypointCount() do
    				addCommsReply(string.format(_("station-comms","Rendezvous at waypoint %i"),n),function()
    					if comms_source:takeReputationPoints(getServiceCost("servicejonque")) then
    						ship = serviceJonque(comms_target:getFaction()):setPosition(comms_target:getPosition()):setCallSign(generateCallSign(nil,comms_target:getFaction())):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
							ship.comms_data = {
								friendlyness = random(0.0, 100.0),
								weapons = {
									Homing = comms_target.comms_data.weapons.Homing,
									HVLI = comms_target.comms_data.weapons.HVLI,
									Mine = comms_target.comms_data.weapons.Mine,
									Nuke = comms_target.comms_data.weapons.Nuke,
									EMP = comms_target.comms_data.weapons.EMP,
								},
								weapon_cost = {
									Homing = comms_target.comms_data.weapon_cost.Homing * 2,
									HVLI = comms_target.comms_data.weapon_cost.HVLI * 2,
									Mine = comms_target.comms_data.weapon_cost.Mine * 2,
									Nuke = comms_target.comms_data.weapon_cost.Nuke * 2,
									EMP = comms_target.comms_data.weapon_cost.EMP * 2,
								},
								weapon_inventory = {
									Homing = 40,
									HVLI = 40,
									Mine = 20,
									Nuke = 10,
									EMP = 10,
								},
								weapon_inventory_max = {
									Homing = 40,
									HVLI = 40,
									Mine = 20,
									Nuke = 10,
									EMP = 10,
								},
								reputation_cost_multipliers = {
									friend = comms_target.comms_data.reputation_cost_multipliers.friend,
									neutral = math.max(comms_target.comms_data.reputation_cost_multipliers.friend,comms_target.comms_data.reputation_cost_multipliers.neutral/2)
								},
							}
    						setCommsMessage(string.format(_("station-comms","We have dispatched %s to rendezvous at waypoint %i"),ship:getCallSign(),n))
    					else
							setCommsMessage(_("needRep-comms","Insufficient reputation"))
    					end
						addCommsReply(_("Back"), commsStation)
    				end)
    			end
    		end
    		setCommsMessage(out)
			addCommsReply(_("Back"), commsStation)
    	end)
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
		goodsOnShip(comms_target,comms_data)
	end
	if comms_source:isFriendly(comms_target) then
		return friendlyComms(comms_data)
	end
	if comms_source:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentifiedBy(comms_source) then
		return enemyComms(comms_data)
	end
	return neutralComms(comms_data)
end
function goodsOnShip(comms_target,comms_data)
	comms_data.goods = {}
	comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = 1, cost = random(20,80)}
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
			local count_repeat_loop = 0
			repeat
				comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = 1, cost = random(20,80)}
				local goodCount = 0
				for good, goodData in pairs(comms_data.goods) do
					goodCount = goodCount + 1
				end
				count_repeat_loop = count_repeat_loop + 1
			until(goodCount >= 3 or count_repeat_loop > max_repeat_loop)
			if count_repeat_loop > max_repeat_loop then
				print("repeated too many times when setting up goods for freighter")
			end
		end
	end
end
function friendlyComms(comms_data)
	if comms_data.friendlyness < 20 then
		setCommsMessage(_("ship-comms","What do you want?"))
	else
		setCommsMessage(_("ship-comms","Sir, how can we assist?"))
	end
	if comms_target.rescue_pickup == nil then
		addCommsReply(_("ship-comms","Defend a waypoint"), function()
			if comms_source:getWaypointCount() == 0 then
				setCommsMessage(_("ship-comms","No waypoints set. Please set a waypoint first."))
			else
				setCommsMessage(_("ship-comms","Which waypoint should we defend?"))
				for n=1,comms_source:getWaypointCount() do
					addCommsReply(string.format(_("ship-comms","Defend Waypoint %i"),n), function()
						comms_target:orderDefendLocation(comms_source:getWaypoint(n))
						setCommsMessage(string.format(_("ship-comms","We are heading to assist at Waypoint %i."),n))
						addCommsReply(_("Back"), commsShip)
					end)
				end
			end
			addCommsReply(_("Back"), commsShip)
		end)
	end
	if comms_target.rescue_pickup == nil then
		if comms_data.friendlyness > 0.2 then
			addCommsReply(_("ship-comms","Assist me"), function()
				setCommsMessage(_("ship-comms","Heading toward you to assist."))
				comms_target:orderDefendTarget(comms_source)
				addCommsReply(_("Back"), commsShip)
			end)
		end
	end
	addCommsReply(_("ship-comms","Report status"), function()
		msg = _("ship-comms","Hull: ") .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
		local shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = msg .. _("ship-comms","Shield: ") .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
		elseif shields == 2 then
			msg = msg .. _("ship-comms","Front Shield: ") .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			msg = msg .. _("ship-comms","Rear Shield: ") .. math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100) .. "%\n"
		else
			for n=0,shields-1 do
				msg = msg .. _("ship-comms","Shield " .. n .. ": ") .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
			end
		end
		local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for i, missile_type in ipairs(missile_types) do
			if comms_target:getWeaponStorageMax(missile_type) > 0 then
					msg = msg .. missile_type .. _("ship-comms"," Missiles: ") .. math.floor(comms_target:getWeaponStorage(missile_type)) .. "/" .. math.floor(comms_target:getWeaponStorageMax(missile_type)) .. "\n"
			end
		end
		if comms_target.home_station ~= nil then
			msg = string.format(_("ship-comms","%sPatrolling out of %s"),msg,comms_target.home_station_name)
			if comms_target.home_station ~= nil and comms_target.home_station:isValid() then
				msg = string.format(_("ship-comms","%s in %s"),msg,comms_target.home_station:getSectorName())
			else
				msg = string.format(_("ship-comms","%s, but contact with %s has been cut off"),msg,comms_target.home_station_name)
			end
		end
		setCommsMessage(msg);
		addCommsReply(_("Back"), commsShip)
	end)
	if comms_target.rescue_pickup == nil then
		for index, obj in ipairs(comms_target:getObjectsInRange(5000)) do
			if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
				addCommsReply(string.format(_("ship-comms","Dock at %s"),obj:getCallSign()), function()
					setCommsMessage(string.format(_("ship-comms","Docking at %s."),obj:getCallSign()))
					comms_target:orderDock(obj)
					addCommsReply(_("Back"), commsShip)
				end)
			end
		end
	end
	local shipType = comms_target:getTypeName()
	if getScenarioTime() > black_hole_milestone then
		addCommsReply(_("ship-comms","Pick up passengers"),function()
			string.format("")	--global context for serious proton
			if shipType:find("Freighter") ~= nil then
				if comms_target.rescue_pickup == nil then
					setRescueDestination()
				else
					--already on a rescue pickup
					if comms_target.rescue_pickup == "enroute" then
						local order_target = comms_target:getOrderTarget()
						setCommsMessage(string.format(_("ship-comms","I am already on my way to %s in %s.\nDo you want me to go somewhere else?"),order_target:getCallSign(),order_target:getSectorName()))
						addCommsReply(_("ship-comms","Yes, please change your destination"),setRescueDestination)
					elseif comms_target.rescue_pickup == "complete" then
						setCommsMessage(_("ship-comms","I've already picked up as many passengers as I can carry"))
					end
				end
			else
				--not a freighter
				if shipType:find("Transit") ~= nil then
					if comms_target.rescue_pickup == nil then
						setRescueDestination()
					else
						--already on a rescue pickup
						if comms_target.rescue_pickup == "enroute" then
							local order_target = comms_target:getOrderTarget()
							setCommsMessage(string.format(_("ship-comms","I am already on my way to %s in %s.\nDo you want me to go somewhere else?"),order_target:getCallSign(),order_target:getSectorName()))
							addCommsReply(_("ship-comms","Yes, please change your destination"),setRescueDestination)
						elseif comms_target.rescue_pickup == "complete" then
							setCommsMessage(_("ship-comms","I've already picked up as many passengers as I can carry"))
						end
					end
				else
					setCommsMessage(_("ship-comms","We have no room for passengers. We're packed with weapons and engines and stuff"))
				end
			end
			addCommsReply(_("Back"), commsShip)
		end)
		if comms_source.investigation_fleet ~= nil then
			for index, ship in ipairs(comms_source.investigation_fleet) do
				if ship ~= nil and ship:isValid() then
					if ship == comms_target then
						addCommsReply(_("ship-comms","What is your mission?"),function()
							setCommsMessage(_("ship-comms","When we discovered the ring of black holes, the other black holes moving towards us, and then observed you moving towards the ring of black holes, we all got together to discuss options - 'we' being leaders from the various factions in the area."))
							addCommsReply(_("ship-comms","That does not answer my question"),function()
								setCommsMessage(_("ship-comms","Well, some of us thought your investigation is appropriate. Others blame you for the behavior of the black holes. We're here to protect you and help however we can. The others are here to kill you. How would you like for us to proceed?"))
								addCommsReply(_("ship-comms","Continue on your mission"),function()
									setCommsMessage(_("ship-comms","Will do"))
									addCommsReply(_("Back"), commsShip)
								end)
								addCommsReply(_("ship-comms","Attack enemies"),function()
									comms_target:orderRoaming()
									setCommsMessage(_("ship-comms","As you wish"))
									addCommsReply(_("Back"), commsShip)
								end)
								addCommsReply(_("ship-comms","Find transports and tell them to evacuate civilians"),function()
									comms_target.help_civilians = true
									comms_target:setCommsFunction(nil)
									if evangelist == nil then
										evangelist = {}
									end
									table.insert(evangelist,comms_target)
									setCommsMessage(_("ship-comms","We'll do the best we can"))
									addCommsReply(_("Back"), commsShip)
								end)
							end)
							addCommsReply(_("Back"), commsShip)
						end)
						break
					end
				end
			end
		end
	end
	if shipType:find("Freighter") ~= nil then
		if distance(comms_source, comms_target) < 5000 then
			local goodCount = 0
			if comms_source.goods ~= nil then
				for good, goodQuantity in pairs(comms_source.goods) do
					goodCount = goodCount + 1
				end
			end
			if goodCount > 0 then
				addCommsReply(_("ship-comms","Jettison cargo"), function()
					setCommsMessage(string.format(_("ship-comms","Available space: %i\nWhat would you like to jettison?"),comms_source.cargo))
					for good, good_quantity in pairs(comms_source.goods) do
						if good_quantity > 0 then
							addCommsReply(good, function()
								comms_source.goods[good] = comms_source.goods[good] - 1
								comms_source.cargo = comms_source.cargo + 1
								setCommsMessage(string.format(_("ship-comms","One %s jettisoned"),good))
								addCommsReply(_("Back"), commsShip)
							end)
						end
					end
					addCommsReply(_("Back"), commsShip)
				end)
			end
			if comms_data.friendlyness > 66 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					if comms_source.goods ~= nil and comms_source.goods.luxury ~= nil and comms_source.goods.luxury > 0 then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 and good ~= "luxury" then
								addCommsReply(string.format(_("ship-comms","Trade luxury for %s"),good), function()
									goodData.quantity = goodData.quantity - 1
									if comms_source.goods == nil then
										comms_source.goods = {}
									end
									if comms_source.goods[good] == nil then
										comms_source.goods[good] = 0
									end
									comms_source.goods[good] = comms_source.goods[good] + 1
									comms_source.goods.luxury = comms_source.goods.luxury - 1
									setCommsMessage(string.format(_("ship-comms","Traded your luxury for %s from %s"),good,comms_target:getCallSign()))
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end	--freighter goods loop
					end	--player has luxury branch
				end	--goods or equipment freighter
				if comms_source.cargo > 0 then
					for good, goodData in pairs(comms_data.goods) do
						if goodData.quantity > 0 then
							addCommsReply(string.format(_("ship-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost)), function()
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
									setCommsMessage(string.format(_("ship-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
								else
									setCommsMessage(_("needRep-comms","Insufficient reputation"))
								end
								addCommsReply(_("Back"), commsShip)
							end)
						end
					end	--freighter goods loop
				end	--player has cargo space branch
			elseif comms_data.friendlyness > 33 then
				if comms_source.cargo > 0 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("ship-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost)), function()
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
										setCommsMessage(string.format(_("ship-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
									else
										setCommsMessage(_("needRep-comms","Insufficient reputation"))
									end
									addCommsReply(_("Back"), commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					else	--not goods or equipment freighter
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("ship-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost*2)), function()
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
										setCommsMessage(string.format(_("ship-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
									else
										setCommsMessage(_("needRep-comms","Insufficient reputation"))
									end
									addCommsReply(_("Back"), commsShip)
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
								addCommsReply(string.format(_("ship-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost*2)), function()
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
										setCommsMessage(string.format(_("ship-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
									else
										setCommsMessage(_("needRep-comms","Insufficient reputation"))
									end
									addCommsReply(_("Back"), commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					end	--goods or equipment freighter
				end	--player has room to get goods
			end	--various friendliness choices
		else	--not close enough to sell
			addCommsReply(_("ship-comms","Do you have cargo you might sell?"), function()
				local goodCount = 0
				local cargoMsg = _("ship-comms","We've got ")
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
					cargoMsg = cargoMsg .. _("ship-comms","nothing")
				end
				setCommsMessage(cargoMsg)
				addCommsReply(_("Back"), commsShip)
			end)
		end
	end
	return true
end
function setRescueDestination()
	local friendly_station_list = {}
	local neutral_station_list = {}
	for _, station in ipairs(station_list) do
		if station ~= nil and station:isValid() then
			if comms_target:isFriendly(station) then
				table.insert(friendly_station_list,station)
			elseif not comms_target:isEnemy(station) then
				table.insert(neutral_station_list,station)
			end
		end
	end
	local capacity = 5
	local shipType = comms_target:getTypeName()
	if shipType:find("Transit") ~= nil then
		capacity = comms_target.passenger_capacity
	end
	if #friendly_station_list > 0 then
		setCommsMessage(string.format(_("ship-comms","I only have room for %i passengers.\nFrom which of these stations should I pick up passengers?"),capacity))
		for index, station in ipairs(friendly_station_list) do
			addCommsReply(string.format(_("ship-comms","%s in %s"),station:getCallSign(),station:getSectorName()),function()
				setCommsMessage(string.format(_("ship-comms","I'll head for %s"),station:getCallSign()))
				comms_target:orderDock(station)
				comms_target.rescue_pickup = "enroute"
				if comms_target.double_impulse == nil then
					comms_target:setImpulseMaxSpeed(comms_target:getImpulseMaxSpeed()*2)
					comms_target.double_impulse = true
				end
			end)
		end
	elseif #neutral_station_list > 0 then
		setCommsMessage(string.format(_("ship-comms","I only have room for %i passengers.\nIf I really had to, from which of these stations should I pick up passengers?"),capacity))
		for index, station in ipairs(neutral_station_list) do
			addCommsReply(string.format(_("ship-comms","%s in %s"),station:getCallSign(),station:getSectorName()),function()
				setCommsMessage(string.format(_("ship-comms","Since it's an emergency, I'll head for %s"),station:getCallSign()))
				comms_target:orderDock(station)
				comms_target.rescue_pickup = "enroute"
				if comms_target.double_impulse == nil then
					comms_target:setImpulseMaxSpeed(comms_target:getImpulseMaxSpeed()*2)
					comms_target.double_impulse = true
				end
			end)
		end
	else
		setCommsMessage(_("ship-comms","No stations will allow me to dock"))
	end
end
function enemyComms(comms_data)
	local faction = comms_target:getFaction()
	local tauntable = false
	local amenable = false
	if comms_data.friendlyness >= 33 then	--final: 33
		--taunt logic
		local taunt_option = _("ship-comms","We will see to your destruction!")
		local taunt_success_reply = _("ship-comms","Your bloodline will end here!")
		local taunt_failed_reply = _("ship-comms","Your feeble threats are meaningless.")
		local taunt_threshold = 30		--base chance of being taunted
		local immolation_threshold = 5	--base chance that taunting will enrage to the point of revenge immolation
		if faction == "Kraylor" then
			taunt_threshold = 35
			immolation_threshold = 6
			setCommsMessage(_("ship-comms","Ktzzzsss.\nYou will DIEEee weaklingsss!"))
			local kraylorTauntChoice = math.random(1,3)
			if kraylorTauntChoice == 1 then
				taunt_option = _("ship-comms","We will destroy you")
				taunt_success_reply = _("ship-comms","We think not. It is you who will experience destruction!")
			elseif kraylorTauntChoice == 2 then
				taunt_option = _("ship-comms","You have no honor")
				taunt_success_reply = _("ship-comms","Your insult has brought our wrath upon you. Prepare to die.")
				taunt_failed_reply = _("ship-comms","Your comments about honor have no meaning to us")
			else
				taunt_option = _("ship-comms","We pity your pathetic race")
				taunt_success_reply = _("ship-comms","Pathetic? You will regret your disparagement!")
				taunt_failed_reply = _("ship-comms","We don't care what you think of us")
			end
		elseif faction == "Arlenians" then
			taunt_threshold = 25
			immolation_threshold = 4
			setCommsMessage(_("ship-comms","We wish you no harm, but will harm you if we must.\nEnd of transmission."))
		elseif faction == "Exuari" then
			taunt_threshold = 40
			immolation_threshold = 7
			setCommsMessage(_("ship-comms","Stay out of our way, or your death will amuse us extremely!"))
		elseif faction == "Ghosts" then
			taunt_threshold = 20
			immolation_threshold = 3
			setCommsMessage(_("ship-comms","One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted."))
			taunt_option = _("ship-comms","EXECUTE: SELFDESTRUCT")
			taunt_success_reply = _("ship-comms","Rogue command received. Targeting source.")
			taunt_failed_reply = _("ship-comms","External command ignored.")
		elseif faction == "Ktlitans" then
			setCommsMessage(_("ship-comms","The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition."))
			taunt_option = _("ship-comms","<Transmit 'The Itsy-Bitsy Spider' on all wavelengths>")
			taunt_success_reply = _("ship-comms","We do not need permission to pluck apart such an insignificant threat.")
			taunt_failed_reply = _("ship-comms","The hive has greater priorities than exterminating pests.")
		elseif faction == "TSN" then
			taunt_threshold = 15
			immolation_threshold = 2
			setCommsMessage(_("ship-comms","State your business"))
		elseif faction == "USN" then
			taunt_threshold = 15
			immolation_threshold = 2
			setCommsMessage(_("ship-comms","What do you want? (not that we care)"))
		elseif faction == "CUF" then
			taunt_threshold = 15
			immolation_threshold = 2
			setCommsMessage(_("ship-comms","Don't waste our time"))
		else
			setCommsMessage(_("ship-comms","Mind your own business!"))
		end
		comms_data.friendlyness = comms_data.friendlyness - random(0, 10)	--reduce friendlyness after each interaction
		addCommsReply(taunt_option, function()
			if random(0, 100) <= taunt_threshold then
				local current_order = comms_target:getOrder()
--				print("order: " .. current_order)
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
					setCommsMessage(_("ship-comms","Subspace and time continuum disruption authorized"))
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
		addCommsReply(_("ship-comms","Stop your actions"),function()
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
				setCommsMessage(_("ship-comms","Just this once, we'll take your advice"))
			else
				setCommsMessage(_("ship-comms","No"))
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
					local timer_display = string.format(_("tabRelay&Operations","Disruption %i"),math.floor(p.continuum_timer))
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
	if getScenarioTime() > black_hole_milestone then
		addCommsReply(_("ship-comms","Pick up passengers"),function()
			string.format("")	--global context for serious proton
			if shipType:find("Freighter") ~= nil then
				if comms_target.rescue_pickup == nil then
					setRescueDestination()
				else
					--already on a rescue pickup
					if comms_target.rescue_pickup == "enroute" then
						local order_target = comms_target:getOrderTarget()
						setCommsMessage(string.format(_("ship-comms","I am already on my way to %s in %s.\nDo you want me to go somewhere else?"),order_target:getCallSign(),order_target:getSectorName()))
						addCommsReply(_("ship-comms","Yes, please change your destination"),setRescueDestination)
					elseif comms_target.rescue_pickup == "complete" then
						setCommsMessage(_("ship-comms","I've already picked up as many passengers as I can carry"))
					end
				end
			else
				--not a freighter
				if shipType:find("Transit") ~= nil then
					if comms_target.rescue_pickup == nil then
						setRescueDestination()
					else
						--already on a rescue pickup
						if comms_target.rescue_pickup == "enroute" then
							local order_target = comms_target:getOrderTarget()
							setCommsMessage(string.format(_("ship-comms","I am already on my way to %s in %s.\nDo you want me to go somewhere else?"),order_target:getCallSign(),order_target:getSectorName()))
							addCommsReply(_("ship-comms","Yes, please change your destination"),setRescueDestination)
						elseif comms_target.rescue_pickup == "complete" then
							setCommsMessage(_("ship-comms","I've already picked up as many passengers as I can carry"))
						end
					end
				else
					setCommsMessage(_("ship-comms","We have no room for passengers. We're packed with weapons and engines and stuff"))
				end
			end
			addCommsReply(_("Back"), commsShip)
		end)
	end
	if shipType:find("Freighter") ~= nil then
		setCommsMessage(_("ship-comms","Yes?"))
		addCommsReply(_("ship-comms","Do you have cargo you might sell?"), function()
			local goodCount = 0
			local cargoMsg = _("ship-comms","We've got ")
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
				cargoMsg = cargoMsg .. _("ship-comms","nothing")
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
				addCommsReply(_("ship-comms","Jettison cargo"), function()
					setCommsMessage(string.format(_("ship-comms","Available space: %i\nWhat would you like to jettison?"),comms_source.cargo))
					for good, good_quantity in pairs(comms_source.goods) do
						if good_quantity > 0 then
							addCommsReply(good, function()
								comms_source.goods[good] = comms_source.goods[good] - 1
								comms_source.cargo = comms_source.cargo + 1
								setCommsMessage(string.format(_("ship-comms","One %s jettisoned"),good))
								addCommsReply(_("Back"), commsShip)
							end)
						end
					end
					addCommsReply(_("Back"), commsShip)
				end)
			end
			if comms_source.cargo > 0 then
				if comms_data.friendlyness > 66 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("ship-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost)), function()
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
										setCommsMessage(string.format(_("ship-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
									else
										setCommsMessage(_("needRep-comms","Insufficient reputation"))
									end
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end	--freighter goods loop
					else
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("ship-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost*2)), function()
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
										setCommsMessage(string.format(_("ship-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
									else
										setCommsMessage(_("needRep-comms","Insufficient reputation"))
									end
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end	--freighter goods loop
					end
				elseif comms_data.friendlyness > 33 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("ship-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost*2)), function()
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
										setCommsMessage(string.format(_("ship-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
									else
										setCommsMessage(_("needRep-comms","Insufficient reputation"))
									end
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end	--freighter goods loop
					else
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("ship-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost*3)), function()
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
										setCommsMessage(string.format(_("ship-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
									else
										setCommsMessage(_("needRep-comms","Insufficient reputation"))
									end
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end	--freighter goods loop
					end
				else	--least friendly
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("ship-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost*3)), function()
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
										setCommsMessage(string.format(_("ship-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
									else
										setCommsMessage(_("needRep-comms","Insufficient reputation"))
									end
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end	--freighter goods loop
					end
				end	--end friendly branches
			end	--player has room for cargo
		end	--close enough to sell
	else	--not a freighter
		if comms_target.home_station ~= nil then
			if comms_data.friendlyness > 50 then
				setCommsMessage(string.format(_("ship-comms","Hello %s"),comms_source:getCallSign()))
			else
				setCommsMessage(_("ship-comms","Yes?"))
			end
			addCommsReply(_("ship-comms","What are you up to?"),function()
				local msg = string.format(_("ship-comms","Patrolling out of %s"),comms_target.home_station_name)
				if comms_target.home_station ~= nil and comms_target.home_station:isValid() then
					msg = string.format(_("ship-comms","%s in %s"),msg,comms_target.home_station:getSectorName())
				else
					msg = string.format(_("ship-comms","%s, but contact with %s has been cut off"),msg,comms_target.home_station_name)
				end
				setCommsMessage(msg)
				addCommsReply(_("Back"), commsShip)
			end)
		else
			if comms_data.friendlyness > 50 then
				setCommsMessage(_("ship-comms","Sorry, we have no time to chat with you.\nWe are busy."))
			else
				setCommsMessage(_("ship-comms","We have nothing for you.\nGood day."))
			end
		end
	end	--end non-freighter communications else branch
	return true
end	--end neutral communications function
function commsServiceJonque()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	comms_data = comms_target.comms_data
	if comms_source:isFriendly(comms_target) then
		return friendlyServiceJonqueComms(comms_data)
	end
	if comms_source:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentifiedBy(comms_source) then
		return enemyComms(comms_data)
	end
	return neutralServiceJonqueComms(comms_data)
end
function friendlyServiceJonqueComms(comms_data)
	if comms_data.friendlyness < 20 then
		setCommsMessage(_("ship-comms","What do you want?"))
	else
		setCommsMessage(_("ship-comms","Sir, how can we assist?"))
	end
	addCommsReply(_("ship-comms","Defend a waypoint"), function()
		if comms_source:getWaypointCount() == 0 then
			setCommsMessage(_("ship-comms","No waypoints set. Please set a waypoint first."))
		else
			setCommsMessage(_("ship-comms","Which waypoint should we defend?"))
			for n=1,comms_source:getWaypointCount() do
				addCommsReply(string.format(_("ship-comms","Defend Waypoint %i"),n), function()
					comms_target:orderDefendLocation(comms_source:getWaypoint(n))
					setCommsMessage(string.format(_("ship-comms","We are heading to assist at Waypoint %i."),n))
					addCommsReply(_("Back"), commsServiceJonque)
				end)
			end
		end
		addCommsReply(_("Back"), commsServiceJonque)
	end)
	if comms_data.friendlyness > 0.2 then
		addCommsReply(_("ship-comms","Assist me"), function()
			setCommsMessage(_("ship-comms","Heading toward you to assist."))
			comms_target:orderDefendTarget(comms_source)
			addCommsReply(_("Back"), commsServiceJonque)
		end)
	end
	addCommsReply(_("ship-comms","Report status"), function()
		msg = _("ship-comms","Hull: ") .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
		local shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = msg .. _("ship-comms","Shield: ") .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
		elseif shields == 2 then
			msg = msg .. _("ship-comms","Front Shield: ") .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			msg = msg .. _("ship-comms","Rear Shield: ") .. math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100) .. "%\n"
		else
			for n=0,shields-1 do
				msg = msg .. _("ship-comms","Shield " .. n .. ": ") .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
			end
		end
		setCommsMessage(msg);
		addCommsReply(_("Back"), commsServiceJonque)
	end)
	for index, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			addCommsReply(string.format(_("ship-comms","Dock at %s"),obj:getCallSign()), function()
				setCommsMessage(string.format(_("ship-comms","Docking at %s."),obj:getCallSign()))
				comms_target:orderDock(obj)
				addCommsReply(_("Back"), commsServiceJonque)
			end)
		end
	end
	if distance(comms_source,comms_target) < 5000 then
		commonServiceOptions()
	end
end
function neutralServiceJonqueComms(comms_data)
	if comms_data.friendlyness < 20 then
		setCommsMessage(_("ship-comms","What do you want?"))
	else
		setCommsMessage(_("ship-comms","Sir, how can we assist?"))
	end
	addCommsReply(_("ship-comms","How are you doing?"), function()
		msg = _("ship-comms","Hull: ") .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
		local shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = msg .. _("ship-comms","Shield: ") .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
		elseif shields == 2 then
			msg = msg .. _("ship-comms","Front Shield: ") .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			msg = msg .. _("ship-comms","Rear Shield: ") .. math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100) .. "%\n"
		else
			for n=0,shields-1 do
				msg = msg .. _("ship-comms","Shield " .. n .. ": ") .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
			end
		end
		setCommsMessage(msg);
		addCommsReply(_("Back"), commsServiceJonque)
	end)
	commonServiceOptions()
end
function commonServiceOptions()
	addCommsReply(_("ship-comms","Service options"),function()
		local offer_repair = false
		if not comms_source:getCanLaunchProbe() then
			offer_repair = true
		end
		if not offer_repair and not comms_source:getCanHack() then
			offer_repair = true
		end
		if not offer_repair and not comms_source:getCanScan() then
			offer_repair = true
		end
		if not offer_repair and not comms_source:getCanCombatManeuver() then
			offer_repair = true
		end
		if not offer_repair and not comms_source:getCanSelfDestruct() then
			offer_repair = true
		end
		if offer_repair then
			addCommsReply(_("ship-comms","Repair ship system"),function()
				setCommsMessage(string.format(_("ship-comms","What system would you like repaired?")))
				if not comms_source:getCanLaunchProbe() then
					addCommsReply(_("ship-comms","Repair probe launch system"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanLaunchProbe(true)
							setCommsMessage(_("ship-comms","Your probe launch system has been repaired"))
						else
							setCommsMessage(_("ship-comms","You need to stay close if you want me to fix your ship"))
						end
						addCommsReply(_("Back"), commsServiceJonque)
					end)
				end
				if not comms_source:getCanHack() then
					addCommsReply(_("ship-comms","Repair hacking system"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanHack(true)
							setCommsMessage(_("ship-comms","Your hack system has been repaired"))
						else
							setCommsMessage(_("ship-comms","You need to stay close if you want me to fix your ship"))
						end
						addCommsReply(_("Back"), commsServiceJonque)
					end)
				end
				if not comms_source:getCanScan() then
					addCommsReply(_("ship-comms","Repair scanning system"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanScan(true)
							setCommsMessage(_("ship-comms","Your scanners have been repaired"))
						else
							setCommsMessage(_("ship-comms","You need to stay close if you want me to fix your ship"))
						end
						addCommsReply(_("Back"), commsServiceJonque)
					end)
				end
				if not comms_source:getCanCombatManeuver() then
					addCommsReply(_("ship-comms","Repair combat maneuver"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanCombatManeuver(true)
							setCommsMessage(_("ship-comms","Your combat maneuver has been repaired"))
						else
							setCommsMessage(_("ship-comms","You need to stay close if you want me to fix your ship"))
						end
						addCommsReply(_("Back"), commsServiceJonque)
					end)
				end
				if not comms_source:getCanSelfDestruct() then
					addCommsReply(_("ship-comms","Repair self destruct system"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanSelfDestruct(true)
							setCommsMessage(_("ship-comms","Your self destruct system has been repaired"))
						else
							setCommsMessage(_("ship-comms","You need to stay close if you want me to fix your ship"))
						end
						addCommsReply(_("Back"), commsServiceJonque)
					end)
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
		end
		local offer_hull_repair = false
		if comms_source:getHull() < comms_source:getHullMax() then
			offer_hull_repair = true
		end
		if offer_hull_repair then
			local full_repair = comms_source:getHullMax() - comms_source:getHull()
			local premium = 30
			if full_repair > 100 then
				premium = 100
			elseif full_repair > 50 then
				premium = 60
			end
			addCommsReply(string.format(_("ship-comms","Full hull repair (%i reputation)"),math.floor(full_repair + premium)),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(math.floor(full_repair + premium)) then
						comms_source:setHull(comms_source:getHullMax())
						setCommsMessage(_("ship-comms","All fixed up and ready to go"))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("ship-comms","You need to stay close if you want me to fix your ship"))
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
			addCommsReply(string.format(_("ship-comms","Add %i%% to hull (%i reputation)"),math.floor(full_repair/2/comms_source:getHullMax()*100),math.floor(full_repair/2 + premium/2)),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(math.floor(full_repair/2 + premium/2)) then
						comms_source:setHull(comms_source:getHull() + (full_repair/2))
						setCommsMessage(_("ship-comms","Repairs completed as requested"))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("ship-comms","You need to stay close if you want me to fix your ship"))
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
			addCommsReply(string.format(_("ship-comms","Add %i%% to hull (%i reputation)"),math.floor(full_repair/3/comms_source:getHullMax()*100),math.floor(full_repair/3)),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(math.floor(full_repair/3)) then
						comms_source:setHull(comms_source:getHull() + (full_repair/3))
						setCommsMessage(_("ship-comms","Repairs completed as requested"))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("ship-comms","You need to stay close if you want me to fix your ship"))
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
		end
		local offer_ordnance = false
		local ordnance_inventory = 0
		for ordnance_type, count in pairs(comms_target.comms_data.weapon_inventory) do
			ordnance_inventory = ordnance_inventory + count
		end
		local player_missile_types = {
			["Homing"] = {shoots = false, max = 0, current = 0, need=0},
			["Nuke"] = {shoots = false, max = 0, current = 0, need=0},
			["Mine"] = {shoots = false, max = 0, current = 0, need=0},
			["EMP"] = {shoots = false, max = 0, current = 0, need=0},
			["HVLI"] = {shoots = false, max = 0, current = 0, need=0},
		}
		if ordnance_inventory > 0 then
			for missile_type, ord in pairs(player_missile_types) do
				ord.max = comms_source:getWeaponStorageMax(missile_type)
				if ord.max ~= nil and ord.max > 0 then
					ord.shoots = true
					ord.current = comms_source:getWeaponStorage(missile_type)
					if ord.current < ord.max then
						ord.need = ord.max - ord.current
						if comms_target.comms_data.weapon_inventory[missile_type] > 0 then
							offer_ordnance = true
						end
					end
				end
			end
		end
		if offer_ordnance then
			addCommsReply(_("ship-comms","Restock ordnance"),function()
				for missile_type, ord in pairs(player_missile_types) do
					if ord.current < ord.max and comms_target.comms_data.weapon_inventory[missile_type] > 0 then
						comms_data = comms_target.comms_data
						setCommsMessage(_("ship-comms","What kind of ordnance?"))
						addCommsReply(string.format(_("ship-comms","%s (%i reputation each)"),missile_type,getWeaponCost(missile_type)),function()
							if distance(comms_source,comms_target) < 5000 then
								if comms_target.comms_data.weapon_inventory[missile_type] >= ord.need then
									if comms_source:takeReputationPoints(getWeaponCost(missile_type)*ord.need) then
										comms_source:setWeaponStorage(missile_type,ord.max)
										comms_target.comms_data.weapon_inventory[missile_type] = comms_target.comms_data.weapon_inventory[missile_type] - ord.need
										setCommsMessage(string.format(_("ship-comms","Restocked your %s type ordnance"),missile_type))
									else
										if comms_source:getReputationPoints() > getWeaponCost(missile_type) then
											setCommsMessage(string.format(_("needRep-comms","You don't have enough reputation to fully replenish your %s type ordnance. You need %i and you only have %i. How would you like to proceed?"),missile_type,getWeaponCost(missile_type)*ord.need,math.floor(comms_source:getReputationPoints())))
											addCommsReply(string.format(_("ship-comms","Get one (%i reputation)"),getWeaponCost(missile_type)), function()
												if distance(comms_source,comms_target) < 5000 then
													if comms_source:takeReputationPoints(getWeaponCost(missile_type)) then
														comms_source:setWeaponStorage(missile_type,comms_source:getWeaponStorage(missile_type) + 1)
														comms_target.comms_data.weapon_inventory[missile_type] = comms_target.comms_data.weapon_inventory[missile_type] - 1
														setCommsMessage(string.format(_("ship-comms","One %s provided"),missile_type))
													else
														setCommsMessage(_("needRep-comms","Insufficient reputation"))
													end
												else
													setCommsMessage(_("ship-comms","You need to stay close if you want me to restock your ordnance"))
												end
												addCommsReply(_("Back"), commsServiceJonque)
											end)
											if comms_source:getReputationPoints() > getWeaponCost(missile_type)*2 then
												local max_afford = 0
												local missile_count = 0
												repeat
													max_afford = max_afford + getWeaponCost(missile_type)
													missile_count = missile_count + 1
												until(max_afford + getWeaponCost(missile_type) > comms_source:getReputationPoints())
												addCommsReply(string.format(_("ship-comms","Get %i (%i reputation)"),missile_count,max_afford),function()
													if distance(comms_source,comms_target) < 5000 then
														if comms_source:takeReputationPoints(getWeaponCost(missile_type)*missile_count) then
															comms_source:setWeaponStorage(missile_type,comms_source:getWeaponStorage(missile_type) + missile_count)
															comms_target.comms_data.weapon_inventory[missile_type] = comms_target.comms_data.weapon_inventory[missile_type] - missile_count
															setCommsMessage(string.format(_("ship-comms","%i %ss provided"),missile_count,missile_type))
														else
															setCommsMessage(_("needRep-comms","Insufficient reputation"))
														end
													else
														setCommsMessage(_("ship-comms","You need to stay close if you want me to restock your ordnance"))
													end
													addCommsReply(_("Back"), commsServiceJonque)
												end)
											end
										else
											setCommsMessage(_("needRep-comms","Insufficient reputation"))
										end
									end
								else
									setCommsMessage(string.format(_("ship-comms","I don't have enough %s type ordnance to fully restock you. How would you like to proceed?"),missile_type))
									addCommsReply(_("ship-comms","We'll take all you've got"),function()
										if comms_source:takeReputationPoints(getWeaponCost(missile_type)*comms_target.comms_data.weapon_inventory[missile_type]) then
											comms_source:setWeaponStorage(missile_type,comms_source:getWeaponStorage(missile_type) + comms_target.comms_data.weapon_inventory[missile_type])
											if comms_target.comms_data.weapon_inventory[missile_type] > 1 then
												setCommsMessage(string.format(_("ship-comms","%i %ss provided"),missile_count,missile_type))
											else
												setCommsMessage(string.format(_("ship-comms","One %s provided"),missile_type))
											end
											comms_target.comms_data.weapon_inventory[missile_type] = 0
										else
											setCommsMessage(string.format(_("needRep-comms","You don't have enough reputation to get all of our %s type ordnance. You need %i and you only have %i. How would you like to proceed?"),missile_type,getWeaponCost(missile_type)*comms_target.comms_data.weapon_inventory[missile_type],math.floor(comms_source:getReputationPoints())))
											addCommsReply(string.format(_("ship-comms","Get one (%i reputation)"),getWeaponCost(missile_type)), function()
												if distance(comms_source,comms_target) < 5000 then
													if comms_source:takeReputationPoints(getWeaponCost(missile_type)) then
														comms_source:setWeaponStorage(missile_type,comms_source:getWeaponStorage(missile_type) + 1)
														comms_target.comms_data.weapon_inventory[missile_type] = comms_target.comms_data.weapon_inventory[missile_type] - 1
														setCommsMessage(string.format(_("ship-comms","One %s provided"),missile_type))
													else
														setCommsMessage(_("needRep-comms","Insufficient reputation"))
													end
												else
													setCommsMessage(_("ship-comms","You need to stay close if you want me to restock your ordnance"))
												end
												addCommsReply(_("Back"), commsServiceJonque)
											end)
											if comms_source:getReputationPoints() > getWeaponCost(missile_type)*2 then
												local max_afford = 0
												local missile_count = 0
												repeat
													max_afford = max_afford + getWeaponCost(missile_type)
													missile_count = missile_count + 1
												until(max_afford + getWeaponCost(missile_type) > comms_source:getReputationPoints())
												addCommsReply(string.format(_("ship-comms","Get %i (%i reputation)"),missile_count,max_afford),function()
													if distance(comms_source,comms_target) < 5000 then
														if comms_source:takeReputationPoints(getWeaponCost(missile_type)*missile_count) then
															comms_source:setWeaponStorage(missile_type,comms_source:getWeaponStorage(missile_type) + missile_count)
															comms_target.comms_data.weapon_inventory[missile_type] = comms_target.comms_data.weapon_inventory[missile_type] + missile_count
															setCommsMessage(string.format(_("ship-comms","%i %ss provided"),missile_count,missile_type))
														else
															setCommsMessage(_("needRep-comms","Insufficient reputation"))
														end
													else
														setCommsMessage(_("ship-comms","You need to stay close if you want me to restock your ordnance"))
													end
													addCommsReply(_("Back"), commsServiceJonque)
												end)
											end
										end
									end)
									addCommsReply(string.format(_("ship-comms","Get one (%i reputation)"),getWeaponCost(missile_type)), function()
										if distance(comms_source,comms_target) < 5000 then
											if comms_source:takeReputationPoints(getWeaponCost(missile_type)) then
												comms_source:setWeaponStorage(missile_type,comms_source:getWeaponStorage(missile_type) + 1)
												comms_target.comms_data.weapon_inventory[missile_type] = comms_target.comms_data.weapon_inventory[missile_type] - 1
												setCommsMessage(string.format(_("ship-comms","One %s provided"),missile_type))
											else
												setCommsMessage(_("needRep-comms","Insufficient reputation"))
											end
										else
											setCommsMessage(_("ship-comms","You need to stay close if you want me to restock your ordnance"))
										end
										addCommsReply(_("Back"), commsServiceJonque)
									end)
								end
							else
								setCommsMessage(_("ship-comms","You need to stay close if you want me to restock your ordnance"))
							end
							addCommsReply(_("Back"), commsServiceJonque)
						end)
					end
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
		end
		local offer_probes = false
		if comms_source:getScanProbeCount() < comms_source:getMaxScanProbeCount() then
			offer_probes = true
		end
		if offer_probes then
			addCommsReply(_("ship-comms","Restock scan probes (5 reputation)"),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(5) then
						comms_source:setScanProbeCount(comms_source:getMaxScanProbeCount())
						setCommsMessage(_("ship-comms","I replenished your probes for you."))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("ship-comms","You need to stay close if you'd like your probes restocked."))
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
		end
		local offer_power = false
		if comms_source:getEnergyLevel() < comms_source:getEnergyLevelMax()/2 then
			offer_power = true
		end
		if offer_power then
			local power_charge = math.floor((comms_source:getEnergyLevelMax() - comms_source:getEnergyLevel())/3)
			addCommsReply(string.format(_("ship-comms","Quick charge the main batteries (%i reputation)"),power_charge),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(power_charge) then
						comms_source:setEnergyLevel(comms_source:getEnergyLevelMax())
						comms_source:commandSetSystemPowerRequest("reactor",1)
						comms_source:setSystemPower("reactor",1)
						comms_source:setSystemHeat("reactor",2)
						setCommsMessage(_("ship-comms","Your batteries have been charged"))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("ship-comms","You need to stay close if you want your batteries charged quickly"))
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
		end
		if offer_hull_repair or offer_repair or offer_ordnance or offer_probes or offer_power then
			setCommsMessage(_("ship-comms","How can I help you get your ship in good running order?"))
		else
			setCommsMessage(_("ship-comms","There's nothing on your ship that I can help you fix. Sorry."))
		end
	end)
end
function updateEvangelist()
	for index, ship in ipairs(evangelist) do
		if ship ~= nil then
			if ship:isValid() then
				if ship.evangelist_timer == nil then
					ship.evangelist_timer = getScenarioTime() + 10
					if ship.evangelist_target == nil then
						local target_transports = {}
						local friendly_transports = {}
						for transport_index, transport in ipairs(transport_list) do
							if transport ~= nil then
								if transport:isValid() then
									if not transport:isEnemy(ship) then
										local dist = distance(transport,ship)
										table.insert(target_transports,{transport=transport,dist=dist})
										if transport:isFriendly(ship) then
											table.insert(friendly_transports,transport)
										end
									end
								else
									transport_list[transport_index] = transport_list[#transport_list]
									transport_list[#transport_list] = nil
									break
								end
							else
								transport_list[transport_index] = transport_list[#transport_list]
								transport_list[#transport_list] = nil
								break
							end
						end
						for bus_index, bus in ipairs(bus_list) do
							if bus ~= nil then
								if bus:isValid() then
									if not bus:isEnemy(ship) then
										local dist = distance(bus,ship)
										table.insert(target_transports,{transport=bus,dist=dist})
										if bus:isFriendly(ship) then
											table.insert(friendly_transports,bus)
										end
									end
								else
									bus_list[bus_index] = bus_list[#bus_list]
									bus_list[#bus_list] = nil
									break
								end
							else
								bus_list[bus_index] = bus_list[#bus_list]
								bus_list[#bus_list] = nil
								break
							end
						end
						if #target_transports > 0 then
							table.sort(target_transports,function(a,b)
								return a.dist < b.dist
							end)
							for _, transport in ipairs(target_transports) do
								if transport.rescue_pickup == nil then
									ship.evangelist_target = transport
									ship:orderDefendTarget(transport)
									break
								end
							end
						end
					else
						--check target
						if ship.evangelist_target:isValid() then
							if distance(ship,ship.evangelist_target) < 8500 then
								local transport = ship.evangelist_target
								if transport.rescue_pickup == nil then
									local docked_with = transport:getDockedWith()
									if docked_with == nil then
										local transport_target = nil
										if string.find("Dock",transport:getOrder()) then
											transport_target = transport:getOrderTarget()
											if transport_target == nil or not transport_target:isValid() then
												transport_target = pickTransportTarget(transport)
											end
										else
											transport_target = pickTransportTarget(transport)
										end
										if transport_target ~= nil then
											local temp_faction = transport:getFaction()
											transport:setFaction("Independent")
											transport:orderDock(transport_target)
											transport:setFaction(temp_faction)
											if transport.double_impulse == nil then
												transport:setImpulseMaxSpeed(transport:getImpulseMaxSpeed()*2)
												transport.double_impulse = true
											end
											transport.rescue_pickup = "enroute"
										end
									end
								else
									ship.evangelist_target = nil
									ship.evangelist_timer = nil
								end
							end
						else
							ship.evangelist_target = nil
							ship.evangelist_timer = nil
						end
					end
				else
					if ship.evangelist_timer > getScenarioTime() then
						ship.evangelist_timer = nil
					end
				end
			else
				evangelist[index] = evangelist[#evangelist]
				evangelist[#evangelist] = nil
				break
			end
		else
			evangelist[index] = evangelist[#evangelist]
			evangelist[#evangelist] = nil
			break
		end
	end
end
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
    local temp = array[selected_item]
    array[selected_item] = array[array_item_count]
    array[array_item_count] = temp
    return table.remove(array)
end
function placeRandomAsteroidsAroundPoint(amount, dist_min, dist_max, x0, y0)
-- create amount of asteroid, at a distance between dist_min and dist_max around the point (x0, y0)
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        local x = x0 + math.cos(r / 180 * math.pi) * distance
        local y = y0 + math.sin(r / 180 * math.pi) * distance
--      local asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
        local asteroid_size = random(2,200) + random(2,200) + random(2,200) + random(2,200)
        if farEnough(x, y, asteroid_size) then
	        local ta = Asteroid():setPosition(x, y):setSize(asteroid_size)
	        table.insert(place_space,{obj=ta,dist=asteroid_size,shape="circle"})
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
	while enemyStrength > 0 do
		local selected_template = template_pool[math.random(1,#template_pool)]
		if spawn_enemy_diagnostic then print("Spawn Enemies selected template:",selected_template,"template pool:",template_pool,"ship template:",ship_template,"Enemy faction:",enemyFaction) end
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
							p:addCustomMessage("Engineering",repairCrewRecovery,_("msgEngineer","Medical team has revived one of your repair crew"))
						end
						if p:hasPlayerAtPosition("Engineering+") then
							local repairCrewRecoveryPlus = "repairCrewRecoveryPlus"
							p:addCustomMessage("Engineering+",repairCrewRecoveryPlus,_("msgEngineer+","Medical team has revived one of your repair crew"))
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
									p:addCustomMessage("Engineering","coolant_recovery",_("msgEngineer","Automated systems have recovered some coolant"))
								end
								if p:hasPlayerAtPosition("Engineering+") then
									p:addCustomMessage("Engineering+","coolant_recovery_plus",_("msgEngineer+","Automated systems have recovered some coolant"))
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
				p:addCustomMessage("Engineering",repairCrewFatality,_("msgEngineer","One of your repair crew has perished"))
			end
			if p:hasPlayerAtPosition("Engineering+") then
				local repairCrewFatalityPlus = "repairCrewFatalityPlus"
				p:addCustomMessage("Engineering+",repairCrewFatalityPlus,_("msgEngineer+","One of your repair crew has perished"))
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
					p:addCustomMessage("Engineering",repairCrewFatality,_("msgEngineer","One of your repair crew has perished"))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local repairCrewFatalityPlus = "repairCrewFatalityPlus"
					p:addCustomMessage("Engineering+",repairCrewFatalityPlus,_("msgEngineer+","One of your repair crew has perished"))
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
					p:addCustomMessage("Engineering",coolantLoss,_("msgEngineer","Damage has caused a loss of coolant"))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local coolantLossPlus = "coolantLossPlus"
					p:addCustomMessage("Engineering+",coolantLossPlus,_("msgEngineer+","Damage has caused a loss of coolant"))
				end
			else
				local named_consequence = consequence_list[consequence-2]
				if named_consequence == "probe" then
					p:setCanLaunchProbe(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","probe_launch_damage_message",_("msgEngineer","The probe launch system has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","probe_launch_damage_message_plus",_("msgEngineer+","The probe launch system has been damaged"))
					end
				elseif named_consequence == "hack" then
					p:setCanHack(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","hack_damage_message",_("msgEngineer","The hacking system has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","hack_damage_message_plus",_("msgEngineer+","The hacking system has been damaged"))
					end
				elseif named_consequence == "scan" then
					p:setCanScan(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","scan_damage_message",_("msgEngineer","The scanners have been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","scan_damage_message_plus",_("msgEngineer+","The scanners have been damaged"))
					end
				elseif named_consequence == "combat_maneuver" then
					p:setCanCombatManeuver(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","combat_maneuver_damage_message",_("msgEngineer","Combat maneuver has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","combat_maneuver_damage_message_plus",_("msgEngineer+","Combat maneuver has been damaged"))
					end
				elseif named_consequence == "self_destruct" then
					p:setCanSelfDestruct(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","self_destruct_damage_message",_("msgEngineer","Self destruct system has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","self_destruct_damage_message_plus",_("msgEngineer+","Self destruct system has been damaged"))
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
			if p.resident_capacity < 30 then
				cargoHoldEmpty = false				
			end
			if not cargoHoldEmpty then
				if p:hasPlayerAtPosition("Relay") then
					if p.inventoryButton == nil then
						local tbi = "inventory" .. p:getCallSign()
						p:addCustomButton("Relay",tbi,_("buttonRelay","Inventory"),function() playerShipCargoInventory(p) end)
						p.inventoryButton = true
					end
				end
				if p:hasPlayerAtPosition("Operations") then
					if p.inventoryButton == nil then
						local tbi = "inventoryOp" .. p:getCallSign()
						p:addCustomButton("Operations",tbi,_("buttonOperations","Inventory"),function() playerShipCargoInventory(p) end)
						p.inventoryButton = true
					end
				end
			end
		end
	end
end
function playerShipCargoInventory(p)
	p:addToShipLog(string.format(_("inventory-shipLog","%s Current cargo:"),p:getCallSign()),"Yellow")
	local goodCount = 0
	if p.goods ~= nil then
		for good, goodQuantity in pairs(p.goods) do
			goodCount = goodCount + 1
			p:addToShipLog(string.format("     %s: %i",good,goodQuantity),"Yellow")
		end
	end
	if goodCount < 1 then
		p:addToShipLog(_("inventory-shipLog","     Empty"),"Yellow")
	end
	p:addToShipLog(string.format(_("inventory-shipLog","Available space: %i"),p.cargo),"Yellow")
	p:addToShipLog(string.format(_("inventory-shipLog","Passengers aboard: %i    Available space for passengers: %i"),30-p.resident_capacity,p.resident_capacity),"Yellow")
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
	if faction == "Arlenians" then
		if arlenian_names == nil then
			setArlenianNames()
		else
			if #arlenian_names < 1 then
				setArlenianNames()
			end
		end
		local arlenian_name_choice = math.random(1,#arlenian_names)
		faction_prefix = arlenian_names[arlenian_name_choice]
		table.remove(arlenian_names,arlenian_name_choice)
	end
	if faction == "USN" then
		if usn_names == nil then
			setUsnNames()
		else
			if #usn_names < 1 then
				setUsnNames()
			end
		end
		local usn_name_choice = math.random(1,#usn_names)
		faction_prefix = usn_names[usn_name_choice]
		table.remove(usn_names,usn_name_choice)
	end
	if faction == "TSN" then
		if tsn_names == nil then
			setTsnNames()
		else
			if #tsn_names < 1 then
				setTsnNames()
			end
		end
		local tsn_name_choice = math.random(1,#tsn_names)
		faction_prefix = tsn_names[tsn_name_choice]
		table.remove(tsn_names,tsn_name_choice)
	end
	if faction == "CUF" then
		if cuf_names == nil then
			setCufNames()
		else
			if #cuf_names < 1 then
				setCufNames()
			end
		end
		local cuf_name_choice = math.random(1,#cuf_names)
		faction_prefix = cuf_names[cuf_name_choice]
		table.remove(cuf_names,cuf_name_choice)
	end
	if faction == "Ktlitans" then
		if ktlitan_names == nil then
			setKtlitanNames()
		else
			if #ktlitan_names < 1 then
				setKtlitanNames()
			end
		end
		local ktlitan_name_choice = math.random(1,#ktlitan_names)
		faction_prefix = ktlitan_names[ktlitan_name_choice]
		table.remove(ktlitan_names,ktlitan_name_choice)
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
	table.insert(independent_names,"Chakak")		--faux Ktlitans
	table.insert(independent_names,"Chakik")		--faux Ktlitans
	table.insert(independent_names,"Chaklik")		--faux Ktlitans
	table.insert(independent_names,"Kaklak")		--faux Ktlitans
	table.insert(independent_names,"Kiklak")		--faux Ktlitans
	table.insert(independent_names,"Kitpak")		--faux Ktlitans
	table.insert(independent_names,"Kitplak")		--faux Ktlitans
	table.insert(independent_names,"Pipklat")		--faux Ktlitans
	table.insert(independent_names,"Piptik")		--faux Ktlitans
end
function setCufNames()
	cuf_names = {}
	table.insert(cuf_names,"Allegro")
	table.insert(cuf_names,"Bonafide")
	table.insert(cuf_names,"Brief Blur")
	table.insert(cuf_names,"Byzantine Born")
	table.insert(cuf_names,"Celeste")
	table.insert(cuf_names,"Chosen Charter")
	table.insert(cuf_names,"Conundrum")
	table.insert(cuf_names,"Crazy Clef")
	table.insert(cuf_names,"Curtail")
	table.insert(cuf_names,"Dark Demesne")
	table.insert(cuf_names,"Diminutive Drama")
	table.insert(cuf_names,"Draconian Destiny")
	table.insert(cuf_names,"Fickle Frown")
	table.insert(cuf_names,"Final Freeze")
	table.insert(cuf_names,"Fried Feather")
	table.insert(cuf_names,"Frozen Flare")
	table.insert(cuf_names,"Gaunt Gator")
	table.insert(cuf_names,"Hidden Harpoon")
	table.insert(cuf_names,"Intense Interest")
	table.insert(cuf_names,"Lackadaisical")
	table.insert(cuf_names,"Largess")
	table.insert(cuf_names,"Ointment")
	table.insert(cuf_names,"Plush Puzzle")
	table.insert(cuf_names,"Slick")
	table.insert(cuf_names,"Thumper")
	table.insert(cuf_names,"Torpid")
	table.insert(cuf_names,"Triple Take")
end
function setUsnNames()
	usn_names = {}
	table.insert(usn_names,"Belladonna")
	table.insert(usn_names,"Broken Dragon")
	table.insert(usn_names,"Burning Knave")
	table.insert(usn_names,"Corona Flare")
	table.insert(usn_names,"Daring the Deep")
	table.insert(usn_names,"Dragon's Cutlass")
	table.insert(usn_names,"Dragon's Sadness")
	table.insert(usn_names,"Elusive Doom")
	table.insert(usn_names,"Fast Flare")
	table.insert(usn_names,"Flying Flare")
	table.insert(usn_names,"Fulminate")
	table.insert(usn_names,"Gaseous Gale")
	table.insert(usn_names,"Golden Anger")
	table.insert(usn_names,"Greedy Promethean")
	table.insert(usn_names,"Happy Mynock")
	table.insert(usn_names,"Jimi Saru")
	table.insert(usn_names,"Jolly Roger")
	table.insert(usn_names,"Killer's Grief")
	table.insert(usn_names,"Mad Delight")
	table.insert(usn_names,"Nocturnal Neptune")
	table.insert(usn_names,"Obscure Orbiter")
	table.insert(usn_names,"Red Rift")
	table.insert(usn_names,"Rusty Belle")
	table.insert(usn_names,"Silver Pearl")
	table.insert(usn_names,"Sodden Corsair")
	table.insert(usn_names,"Solar Sailor")
	table.insert(usn_names,"Solar Secret")
	table.insert(usn_names,"Sun's Grief")
	table.insert(usn_names,"Tortuga Shadows")
	table.insert(usn_names,"Trinity")
	table.insert(usn_names,"Wayfaring Wind")
end
function setTsnNames()
	tsn_names = {}
	table.insert(tsn_names,"Aegis")
	table.insert(tsn_names,"Allegiance")
	table.insert(tsn_names,"Apollo")
	table.insert(tsn_names,"Ares")
	table.insert(tsn_names,"Casper")
	table.insert(tsn_names,"Charger")
	table.insert(tsn_names,"Dauntless")
	table.insert(tsn_names,"Demeter")
	table.insert(tsn_names,"Eagle")
	table.insert(tsn_names,"Excalibur")
	table.insert(tsn_names,"Falcon")
	table.insert(tsn_names,"Guardian")
	table.insert(tsn_names,"Hawk")
	table.insert(tsn_names,"Hera")
	table.insert(tsn_names,"Horizon")
	table.insert(tsn_names,"Hunter")
	table.insert(tsn_names,"Hydra")
	table.insert(tsn_names,"Intrepid")
	table.insert(tsn_names,"Lancer")
	table.insert(tsn_names,"Montgomery")
	table.insert(tsn_names,"Nemesis")
	table.insert(tsn_names,"Osiris")
	table.insert(tsn_names,"Pegasus")
	table.insert(tsn_names,"Phoenix")
	table.insert(tsn_names,"Poseidon")
	table.insert(tsn_names,"Raven")
	table.insert(tsn_names,"Sabre")
	table.insert(tsn_names,"Stalker")
	table.insert(tsn_names,"Valkyrie")
	table.insert(tsn_names,"Viper")
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
function setKtlitanNames()
	ktlitan_names = {}
	table.insert(ktlitan_names,"Chaklak")
	table.insert(ktlitan_names,"Chaklit")
	table.insert(ktlitan_names,"Chitlat")
	table.insert(ktlitan_names,"Chitlit")
	table.insert(ktlitan_names,"Chitpik")
	table.insert(ktlitan_names,"Chokpit")
	table.insert(ktlitan_names,"Choktip")
	table.insert(ktlitan_names,"Choktot")
	table.insert(ktlitan_names,"Chotlap")
	table.insert(ktlitan_names,"Chotlat")
	table.insert(ktlitan_names,"Chotlot")
	table.insert(ktlitan_names,"Kaftlit")
	table.insert(ktlitan_names,"Kaplak")
	table.insert(ktlitan_names,"Kaplat")
	table.insert(ktlitan_names,"Kichpak")
	table.insert(ktlitan_names,"Kichpik")
	table.insert(ktlitan_names,"Kichtak")
	table.insert(ktlitan_names,"Kiftlat")
	table.insert(ktlitan_names,"Kiftak")
	table.insert(ktlitan_names,"Kiftakt")
	table.insert(ktlitan_names,"Kiftlikt")
	table.insert(ktlitan_names,"Kiftlit")
	table.insert(ktlitan_names,"Kiklat")
	table.insert(ktlitan_names,"Kiklik")
	table.insert(ktlitan_names,"Kiklit")
	table.insert(ktlitan_names,"Kiplit")
	table.insert(ktlitan_names,"Kiptot")
	table.insert(ktlitan_names,"Kitchip")
	table.insert(ktlitan_names,"Kitchit")
	table.insert(ktlitan_names,"Kitlaft")
	table.insert(ktlitan_names,"Kitlak")
	table.insert(ktlitan_names,"Kitlakt")
	table.insert(ktlitan_names,"Kitlich")
	table.insert(ktlitan_names,"Kitlik")
	table.insert(ktlitan_names,"Kitpok")
	table.insert(ktlitan_names,"Koptich")
	table.insert(ktlitan_names,"Koptlik")
	table.insert(ktlitan_names,"Kotplat")
	table.insert(ktlitan_names,"Pachtik")
	table.insert(ktlitan_names,"Paflak")
	table.insert(ktlitan_names,"Paftak")
	table.insert(ktlitan_names,"Paftik")
	table.insert(ktlitan_names,"Pakchit")
	table.insert(ktlitan_names,"Pakchok")
	table.insert(ktlitan_names,"Paktok")
	table.insert(ktlitan_names,"Piklit")
	table.insert(ktlitan_names,"Piflit")
	table.insert(ktlitan_names,"Piftik")
	table.insert(ktlitan_names,"Pitlak")
	table.insert(ktlitan_names,"Pochkik")
	table.insert(ktlitan_names,"Pochkit")
	table.insert(ktlitan_names,"Poftlit")
	table.insert(ktlitan_names,"Pokchap")
	table.insert(ktlitan_names,"Pokchat")
	table.insert(ktlitan_names,"Poktat")
	table.insert(ktlitan_names,"Poklit")
	table.insert(ktlitan_names,"Potlak")
	table.insert(ktlitan_names,"Tachpik")
	table.insert(ktlitan_names,"Tachpit")
	table.insert(ktlitan_names,"Taklit")
	table.insert(ktlitan_names,"Talkip")
	table.insert(ktlitan_names,"Talpik")
	table.insert(ktlitan_names,"Taltkip")
	table.insert(ktlitan_names,"Taltkit")
	table.insert(ktlitan_names,"Tichpik")
	table.insert(ktlitan_names,"Tikplit")
	table.insert(ktlitan_names,"Tiklich")
	table.insert(ktlitan_names,"Tiklip")
	table.insert(ktlitan_names,"Tiklip")
	table.insert(ktlitan_names,"Tilpit")
	table.insert(ktlitan_names,"Tiltlit")
	table.insert(ktlitan_names,"Tochtik")
	table.insert(ktlitan_names,"Tochkap")
	table.insert(ktlitan_names,"Tochpik")
	table.insert(ktlitan_names,"Tochpit")
	table.insert(ktlitan_names,"Tochkit")
	table.insert(ktlitan_names,"Totlop")
	table.insert(ktlitan_names,"Totlot")
end
function setArlenianNames()
	arlenian_names = {}
	table.insert(arlenian_names,"Balura")
	table.insert(arlenian_names,"Baminda")
	table.insert(arlenian_names,"Belarne")
	table.insert(arlenian_names,"Bilanna")
	table.insert(arlenian_names,"Calonda")
	table.insert(arlenian_names,"Carila")
	table.insert(arlenian_names,"Carulda")
	table.insert(arlenian_names,"Charma")
	table.insert(arlenian_names,"Choralle")
	table.insert(arlenian_names,"Corlune")
	table.insert(arlenian_names,"Damilda")
	table.insert(arlenian_names,"Dilenda")
	table.insert(arlenian_names,"Dorla")
	table.insert(arlenian_names,"Elena")
	table.insert(arlenian_names,"Emerla")
	table.insert(arlenian_names,"Famelda")
	table.insert(arlenian_names,"Finelle")
	table.insert(arlenian_names,"Fontaine")
	table.insert(arlenian_names,"Forlanne")
	table.insert(arlenian_names,"Gendura")
	table.insert(arlenian_names,"Gilarne")
	table.insert(arlenian_names,"Grizelle")
	table.insert(arlenian_names,"Hilerna")
	table.insert(arlenian_names,"Homella")
	table.insert(arlenian_names,"Jarille")
	table.insert(arlenian_names,"Jindarre")
	table.insert(arlenian_names,"Juminde")
	table.insert(arlenian_names,"Kalena")
	table.insert(arlenian_names,"Kimarna")
	table.insert(arlenian_names,"Kolira")
	table.insert(arlenian_names,"Lanerra")
	table.insert(arlenian_names,"Lamura")
	table.insert(arlenian_names,"Lavila")
	table.insert(arlenian_names,"Lavorna")
	table.insert(arlenian_names,"Lendura")
	table.insert(arlenian_names,"Limala")
	table.insert(arlenian_names,"Lorelle")
	table.insert(arlenian_names,"Mavelle")
	table.insert(arlenian_names,"Menola")
	table.insert(arlenian_names,"Merla")
	table.insert(arlenian_names,"Mitelle")
	table.insert(arlenian_names,"Mivelda")
	table.insert(arlenian_names,"Morainne")
	table.insert(arlenian_names,"Morda")
	table.insert(arlenian_names,"Morlena")
	table.insert(arlenian_names,"Nadela")
	table.insert(arlenian_names,"Naminda")
	table.insert(arlenian_names,"Nilana")
	table.insert(arlenian_names,"Nurelle")
	table.insert(arlenian_names,"Panela")
	table.insert(arlenian_names,"Pelnare")
	table.insert(arlenian_names,"Pilera")
	table.insert(arlenian_names,"Povelle")
	table.insert(arlenian_names,"Quilarre")
	table.insert(arlenian_names,"Ramila")
	table.insert(arlenian_names,"Renatha")
	table.insert(arlenian_names,"Rendelle")
	table.insert(arlenian_names,"Rinalda")
	table.insert(arlenian_names,"Riderla")
	table.insert(arlenian_names,"Rifalle")
	table.insert(arlenian_names,"Samila")
	table.insert(arlenian_names,"Salura")
	table.insert(arlenian_names,"Selinda")
	table.insert(arlenian_names,"Simanda")
	table.insert(arlenian_names,"Sodila")
	table.insert(arlenian_names,"Talinda")
	table.insert(arlenian_names,"Tamierre")
	table.insert(arlenian_names,"Telorre")
	table.insert(arlenian_names,"Terila")
	table.insert(arlenian_names,"Turalla")
	table.insert(arlenian_names,"Valerna")
	table.insert(arlenian_names,"Vilanda")
	table.insert(arlenian_names,"Vomera")
	table.insert(arlenian_names,"Wanelle")
	table.insert(arlenian_names,"Warenda")
	table.insert(arlenian_names,"Wilena")
	table.insert(arlenian_names,"Wodarla")
	table.insert(arlenian_names,"Yamelda")
	table.insert(arlenian_names,"Yelanda")
end

function stockTemplate(enemyFaction,template)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate(template)
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
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Farco 3")
			farco_3_db = queryScienceDatabase("Ships","Frigate","Farco 3")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
				farco_3_db,		--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 3, the beams are longer and faster and the shields are slightly stronger."),
				{
					{key = "Tube -1", value = "60 sec"},	--torpedo tube direction and load speed
					{key = "Tube 1", value = "60 sec"},		--torpedo tube direction and load speed
				},
				nil		--jump range
			)
		end
	end
	return ship
end
function farco5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Farco 5")
			farco_5_db = queryScienceDatabase("Ships","Frigate","Farco 5")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
				farco_5_db,		--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 5, the tubes load faster and the shields are slightly stronger."),
				{
					{key = "Tube -1", value = "30 sec"},	--torpedo tube direction and load speed
					{key = "Tube 1", value = "30 sec"},		--torpedo tube direction and load speed
				},
				nil		--jump range
			)
		end
	end
	return ship
end
function farco8(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Farco 8")
			farco_8_db = queryScienceDatabase("Ships","Frigate","Farco 8")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
				farco_8_db,		--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 8, the beams are longer and faster, the tubes load faster and the shields are stronger."),
				{
					{key = "Tube -1", value = "30 sec"},	--torpedo tube direction and load speed
					{key = "Tube 1", value = "30 sec"},		--torpedo tube direction and load speed
				},
				nil		--jump range
			)
		end
	end
	return ship
end
function farco11(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Farco 11")
			farco_11_db = queryScienceDatabase("Ships","Frigate","Farco 11")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
				farco_11_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 11, the maneuver speed is faster, the beams are longer and faster, there's an added longer sniping beam and the shields are stronger."),
				{
					{key = "Tube -1", value = "60 sec"},	--torpedo tube direction and load speed
					{key = "Tube 1", value = "60 sec"},		--torpedo tube direction and load speed
				},
				nil		--jump range
			)
		end
	end
	return ship
end
function farco13(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Farco 13")
			farco_13_db = queryScienceDatabase("Ships","Frigate","Farco 13")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
				farco_13_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 13, the maneuver speed is faster, the beams are longer and faster, there's an added longer sniping beam, the tubes load faster, there are more missiles and the shields are stronger."),
				{
					{key = "Tube -1", value = "30 sec"},	--torpedo tube direction and load speed
					{key = "Tube 1", value = "30 sec"},		--torpedo tube direction and load speed
				},
				nil		--jump range
			)
		end
	end
	return ship
end
function whirlwind(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Storm")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Whirlwind")
			whirlwind_db = queryScienceDatabase("Ships","Frigate","Whirlwind")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Storm"),	--base ship database entry
				whirlwind_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The Whirlwind, another heavy artillery cruiser, takes the Storm and adds tubes and missiles. It's as if the Storm swallowed a Pirahna and grew gills. Expect to see missiles, lots of missiles"),
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
	end
	return ship
end
function phobosR2(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Phobos R2")
			phobos_r2_db = queryScienceDatabase("Ships","Frigate","Phobos R2")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
				phobos_r2_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The Phobos R2 model is very similar to the Phobos T3. It's got a faster turn speed, but only one missile tube"),
				{
					{key = "Tube 0", value = "60 sec"},	--torpedo tube direction and load speed
				},
				nil
			)
		end
	end
	return ship
end
function hornetMV52(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("MT52 Hornet")
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
		if starfighter_db ~= nil then	--added for translation issues
			starfighter_db:addEntry("MV52 Hornet")
			hornet_mv52_db = queryScienceDatabase("Ships","Starfighter","MV52 Hornet")
			addShipToDatabase(
				queryScienceDatabase("Ships","Starfighter","MT52 Hornet"),	--base ship database entry
				hornet_mv52_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The MV52 Hornet is very similar to the MT52 and MU52 models. The beam does more damage than both of the other Hornet models, it's max impulse speed is faster than both of the other Hornet models, it turns faster than the MT52, but slower than the MU52"),
				nil,
				nil
			)
		end
	end
	return ship
end
function k2fighter(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Fighter")
	ship:setTypeName("K2 Fighter")
	ship:setBeamWeapon(0, 60, 0, 1200.0, 2.5, 6)	--beams cycle faster (vs 4.0)
	ship:setHullMax(65)								--weaker hull (vs 70)
	ship:setHull(65)
	local k2_fighter_db = queryScienceDatabase("Ships","No Class","K2 Fighter")
	if k2_fighter_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry("K2 Fighter")
			k2_fighter_db = queryScienceDatabase("Ships","No Class","K2 Fighter")
			addShipToDatabase(
				queryScienceDatabase("Ships","No Class","Ktlitan Fighter"),	--base ship database entry
				k2_fighter_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","Enterprising designers published this design specification based on salvaged Ktlitan Fighters. Comparatively, it's got beams that cycle faster, but the hull is a bit weaker."),
				nil,
				nil		--jump range
			)
		end
	end
	return ship
end	
function k3fighter(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Fighter")
	ship:setTypeName("K3 Fighter")
	ship:setBeamWeapon(0, 60, 0, 1200.0, 2.5, 9)	--beams cycle faster and damage more (vs 4.0 & 6)
	ship:setHullMax(60)								--weaker hull (vs 70)
	ship:setHull(60)
	local k3_fighter_db = queryScienceDatabase("Ships","No Class","K3 Fighter")
	if k3_fighter_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry("K3 Fighter")
			k3_fighter_db = queryScienceDatabase("Ships","No Class","K3 Fighter")
			addShipToDatabase(
				queryScienceDatabase("Ships","No Class","Ktlitan Fighter"),	--base ship database entry
				k3_fighter_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","Enterprising designers published this design specification based on salvaged Ktlitan Fighters. Comparatively, it's got beams that are stronger and that cycle faster, but the hull is weaker."),
				nil,
				nil		--jump range
			)
		end
	end
	return ship
end	
function waddle5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5")
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
		if starfighter_db ~= nil then	--added for translation issues
			starfighter_db:addEntry("Waddle 5")
			waddle_5_db = queryScienceDatabase("Ships","Starfighter","Waddle 5")
			addShipToDatabase(
				queryScienceDatabase("Ships","Starfighter","Adder MK5"),	--base ship database entry
				waddle_5_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","Conversions R Us purchased a number of Adder MK 5 ships at auction and added warp drives to them to produce the Waddle 5"),
				{
					{key = "Small tube 0", value = "15 sec"},	--torpedo tube direction and load speed
				},
				nil		--jump range
			)
		end
	end
	return ship
end
function jade5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5")
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
		if starfighter_db ~= nil then	--added for translation issues
			starfighter_db:addEntry("Jade 5")
			jade_5_db = queryScienceDatabase("Ships","Starfighter","Jade 5")
			addShipToDatabase(
				queryScienceDatabase("Ships","Starfighter","Adder MK5"),	--base ship database entry
				jade_5_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","Conversions R Us purchased a number of Adder MK 5 ships at auction and added jump drives to them to produce the Jade 5"),
				{
					{key = "Small tube 0", value = "15 sec"},	--torpedo tube direction and load speed
				},
				"5 - 35 U"		--jump range
			)
		end
	end
	return ship
end
function droneLite(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone")
	ship:setTypeName("Lite Drone")
	ship:setHullMax(20)					--weaker hull (vs 30)
	ship:setHull(20)
	ship:setImpulseMaxSpeed(130)		--faster impulse (vs 120)
	ship:setRotationMaxSpeed(20)		--faster maneuver (vs 10)
	ship:setBeamWeapon(0,40,0,600,4,4)	--weaker (vs 6) beam
	local drone_lite_db = queryScienceDatabase("Ships","No Class","Lite Drone")
	if drone_lite_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry("Lite Drone")
			drone_lite_db = queryScienceDatabase("Ships","No Class","Lite Drone")
			addShipToDatabase(
				queryScienceDatabase("Ships","No Class","Ktlitan Drone"),	--base ship database entry
				drone_lite_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The light drone was pieced together from scavenged parts of various damaged Ktlitan drones. Compared to the Ktlitan drone, the lite drone has a weaker hull, and a weaker beam, but a faster turn and impulse speed"),
				nil,
				nil
			)
		end
	end
	return ship
end
function droneHeavy(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone")
	ship:setTypeName("Heavy Drone")
	ship:setHullMax(40)					--stronger hull (vs 30)
	ship:setHull(40)
	ship:setImpulseMaxSpeed(110)		--slower impulse (vs 120)
	ship:setBeamWeapon(0,40,0,600,4,8)	--stronger (vs 6) beam
	local drone_heavy_db = queryScienceDatabase("Ships","No Class","Heavy Drone")
	if drone_heavy_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry("Heavy Drone")
			drone_heavy_db = queryScienceDatabase("Ships","No Class","Heavy Drone")
			addShipToDatabase(
				queryScienceDatabase("Ships","No Class","Ktlitan Drone"),	--base ship database entry
				drone_heavy_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The heavy drone has a stronger hull and a stronger beam than the normal Ktlitan Drone, but it also moves slower"),
				nil,
				nil
			)
		end
	end
	return ship
end
function droneJacket(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone")
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
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry("Jacket Drone")
			drone_jacket_db = queryScienceDatabase("Ships","No Class","Jacket Drone")
			addShipToDatabase(
				queryScienceDatabase("Ships","No Class","Ktlitan Drone"),	--base ship database entry
				drone_jacket_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The Jacket Drone is a Ktlitan Drone with a shield. It's also slightly slower and has a slightly weaker beam due to the energy requirements of the added shield"),
				nil,
				nil
			)
		end
	end
	return ship
end
function wzLindworm(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("WX-Lindworm")
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
		if starfighter_db ~= nil then	--added for translation issues
			starfighter_db:addEntry("WZ-Lindworm")
			wz_lindworm_db = queryScienceDatabase("Ships","Starfighter","WZ-Lindworm")
			addShipToDatabase(
				queryScienceDatabase("Ships","Starfighter","WX-Lindworm"),	--base ship database entry
				wz_lindworm_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The WZ-Lindworm is essentially the stock WX-Lindworm with more HVLIs, more homing missiles and added nukes. They had to remove some of the armor to get the additional missiles to fit, so the hull is weaker. Also, the WZ turns a little more slowly than the WX. This little bomber packs quite a whallop."),
				{
					{key = "Small tube 0", value = "15 sec"},	--torpedo tube direction and load speed
					{key = "Small tube 1", value = "15 sec"},	--torpedo tube direction and load speed
					{key = "Small tube -1", value = "15 sec"},	--torpedo tube direction and load speed
				},
				nil
			)
		end
	end
	return ship
end
function tempest(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Piranha F12")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Tempest")
			tempest_db = queryScienceDatabase("Ships","Frigate","Tempest")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Piranha F12"),	--base ship database entry
				tempest_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","Loosely based on the Piranha F12 model, the Tempest adds four more broadside tubes (two on each side), more HVLIs, more Homing missiles and 8 Nukes. The Tempest can strike fear into the hearts of your enemies. Get yourself one today!"),
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
		end
	end
	return ship
end
function enforcer(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Blockade Runner")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Enforcer")
			enforcer_db = queryScienceDatabase("Ships","Frigate","Enforcer")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Blockade Runner"),	--base ship database entry
				enforcer_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The Enforcer is a highly modified Blockade Runner. A warp drive was added and impulse engines boosted along with turning speed. Three missile tubes were added to shoot homing missiles, large ones straight ahead. Stronger shields and hull. Removed rear facing beams and strengthened front beams."),
				{
					{key = "Large tube 0", value = "18 sec"},	--torpedo tube direction and load speed
					{key = "Tube -15", value = "12 sec"},		--torpedo tube direction and load speed
					{key = "Tube 15", value = "12 sec"},		--torpedo tube direction and load speed
				},
				nil
			)
			enforcer_db:setImage("radar_ktlitan_destroyer.png")		--override default radar image
		end
	end
	return ship		
end
function predator(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Piranha F8")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Predator")
			predator_db = queryScienceDatabase("Ships","Frigate","Predator")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Piranha F8"),	--base ship database entry
				predator_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The Predator is a significantly improved Piranha F8. Stronger shields and hull, faster impulse and turning speeds, a jump drive, beam weapons, eight missile tubes pointing in six directions and a large number of homing missiles to shoot."),
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
			predator_db:setImage("radar_missile_cruiser.png")		--override default radar image
		end
	end
	return ship		
end
function atlantisY42(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Atlantis X23")
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
		if corvette_db ~= nil then	--added for translation issues
			corvette_db:addEntry("Atlantis Y42")
			atlantis_y42_db = queryScienceDatabase("Ships","Corvette","Atlantis Y42")
			addShipToDatabase(
				queryScienceDatabase("Ships","Corvette","Atlantis X23"),	--base ship database entry
				atlantis_y42_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The Atlantis Y42 improves on the Atlantis X23 with stronger shields, faster impulse and turn speeds, an extra beam in back and a larger missile stock"),
				{
					{key = "Tube -90", value = "10 sec"},	--torpedo tube direction and load speed
					{key = " Tube -90", value = "10 sec"},	--torpedo tube direction and load speed
					{key = "Tube 90", value = "10 sec"},	--torpedo tube direction and load speed
					{key = " Tube 90", value = "10 sec"},	--torpedo tube direction and load speed
				},
				"5 - 50 U"		--jump range
			)
		end
	end
	return ship		
end
function starhammerV(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Starhammer II")
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
		if corvette_db ~= nil then	--added for translation issues
			corvette_db:addEntry("Starhammer V")
			starhammer_v_db = queryScienceDatabase("Ships","Corvette","Starhammer V")
			addShipToDatabase(
				queryScienceDatabase("Ships","Corvette","Starhammer II"),	--base ship database entry
				starhammer_v_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The Starhammer V recognizes common modifications made in the field to the Starhammer II: stronger shields, faster impulse and turning speeds, additional rear beam and more missiles to shoot. These changes make the Starhammer V a force to be reckoned with."),
				{
					{key = "Tube 0", value = "10 sec"},	--torpedo tube direction and load speed
					{key = " Tube 0", value = "10 sec"},	--torpedo tube direction and load speed
				},
				"5 - 50 U"		--jump range
			)
		end
	end
	return ship		
end
function tyr(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Battlestation")
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
		if corvette_db ~= nil then	--added for translation issues
			corvette_db:addEntry("Tyr")
			tyr_db = queryScienceDatabase("Ships","Dreadnought","Tyr")
			addShipToDatabase(
				queryScienceDatabase("Ships","Dreadnought","Battlestation"),	--base ship database entry
				tyr_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The Tyr is the shipyard's answer to Admiral Konstatz' casual statement that the Battlestation model was too slow to be effective. The shipyards improved on the Battlestation by fitting the Tyr with more than twice the impulse speed and more than six times the turn speed. They threw in stronger shields and hull and wider beam coverage just to show that they could"),
				nil,
				"5 - 50 U"		--jump range
			)
		end
	end
	return ship
end
function gnat(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone")
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
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry("Gnat")
			gnat_db = queryScienceDatabase("Ships","No Class","Gnat")
			addShipToDatabase(
				queryScienceDatabase("Ships","No Class","Gnat"),	--base ship database entry
				gnat_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The Gnat is a nimbler version of the Ktlitan Drone. It's got half the hull, but it moves and turns faster"),
				nil,
				nil		--jump range
			)
		end
	end
	return ship
end
function cucaracha(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Tug")
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
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry("Cucaracha")
			cucaracha_db = queryScienceDatabase("Ships","No Class","Cucaracha")
			addShipToDatabase(
				queryScienceDatabase("Ships","No Class","Cucaracha"),	--base ship database entry
				cucaracha_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The Cucaracha is a quick ship built around the Tug model with heavy shields and a heavy beam designed to be difficult to squash"),
				nil,
				nil		--jump range
			)
		end
	end
	return ship
end
function starhammerIII(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Starhammer II")
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
		if corvette_db ~= nil then	--added for translation issues
			corvette_db:addEntry("Starhammer III")
			starhammer_iii_db = queryScienceDatabase("Ships","Corvette","Starhammer III")
			addShipToDatabase(
				queryScienceDatabase("Ships","Corvette","Starhammer III"),	--base ship database entry
				starhammer_iii_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The designers of the Starhammer III took the Starhammer II and added a rear facing beam, enlarged one of the missile tubes and added more missiles to fire"),
				{
					{key = "Large tube 0", value = "10 sec"},	--torpedo tube direction and load speed
					{key = "Tube 0", value = "10 sec"},			--torpedo tube direction and load speed
				},
				"5 - 50 U"		--jump range
			)
		end
	end
	return ship
end
function k2breaker(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Breaker")
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
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry("K2 Breaker")
			k2_breaker_db = queryScienceDatabase("Ships","No Class","K2 Breaker")
			addShipToDatabase(
				queryScienceDatabase("Ships","No Class","K2 Breaker"),	--base ship database entry
				k2_breaker_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The K2 Breaker designers took the Ktlitan Breaker and beefed up the hull, added two bracketing tubes, enlarged the center tube and added more missiles to shoot. Should be good for a couple of enemy ships"),
				{
					{key = "Large tube 0", value = "13 sec"},	--torpedo tube direction and load speed
					{key = "Tube -30", value = "13 sec"},		--torpedo tube direction and load speed
					{key = "Tube 30", value = "13 sec"},		--torpedo tube direction and load speed
				},
				nil
			)
		end
	end
	return ship
end
function hurricane(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Piranha F8")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Hurricane")
			hurricane_db = queryScienceDatabase("Ships","Frigate","Hurricane")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Hurricane"),	--base ship database entry
				hurricane_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The Hurricane is designed to jump in and shower the target with missiles. It is based on the Piranha F8, but with a jump drive, five more tubes in various directions and sizes and lots more missiles to shoot"),
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
	end
	return ship
end
function phobosT4(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Phobos T4")
			phobos_t4_db = queryScienceDatabase("Ships","Frigate","Phobos T4")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
				phobos_t4_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("ship-scienceDatabase","The Phobos T4 makes some simple improvements on the Phobos T3: faster maneuver, stronger front shields, though weaker rear shields and longer and faster beam weapons"),
				{
					{key = "Tube -1", value = "60 sec"},	--torpedo tube direction and load speed
					{key = "Tube 1", value = "60 sec"},		--torpedo tube direction and load speed
				},
				nil		--jump range
			)
		end
	end
	return ship
end
function serviceJonque(enemyFaction)
	local ship = CpuShip():setTemplate("Garbage Jump Freighter 4")
	if enemyFaction ~= nil then
		ship:setFaction(enemyFaction)
	end
	ship:setTypeName("Service Jonque"):setCommsScript(""):setCommsFunction(commsServiceJonque)
	addFreighter("Service Jonque",ship)	--update science database if applicable
	return ship
end
function genericFreighterScienceInfo(specific_freighter_db,base_db,ship)
	specific_freighter_db:setImage("radar/transport.png")
	specific_freighter_db:setKeyValue("Sub-class","Freighter")
	specific_freighter_db:setKeyValue("Size",base_db:getKeyValue("Size"))
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
		specific_freighter_db:setKeyValue("Shield",shield_string)
	end
	specific_freighter_db:setKeyValue("Hull",string.format("%i",math.floor(ship:getHullMax())))
	specific_freighter_db:setKeyValue("Move speed",string.format("%.1f u/min",ship:getImpulseMaxSpeed()*60/1000))
	specific_freighter_db:setKeyValue("Turn speed",string.format("%.1f deg/sec",ship:getRotationMaxSpeed()))
	if ship:hasJumpDrive() then
		local base_jump_range = base_db:getKeyValue("Jump range")
		if base_jump_range ~= nil and base_jump_range ~= "" then
			specific_freighter_db:setKeyValue("Jump range",base_jump_range)
		else
			specific_freighter_db:setKeyValue("Jump range","5 - 50 u")
		end
	end
	if ship:hasWarpDrive() then
		specific_freighter_db:setKeyValue("Warp Speed",string.format("%.1f u/min",ship:getWarpSpeed()*60/1000))
	end
end
function addFreighters()
	local freighter_db = queryScienceDatabase("Ships","Freighter")
	if freighter_db == nil then
		local ship_db = queryScienceDatabase("Ships")
		ship_db:addEntry("Freighter")
		freighter_db = queryScienceDatabase("Ships","Freighter")
		freighter_db:setImage("radar/transport.png")
		freighter_db:setLongDescription(_("ship-scienceDatabase","Small, medium and large scale transport ships. These are the working ships that keep commerce going in any sector. They may carry personnel, goods, cargo, equipment, garbage, fuel, research material, etc."))
	end
	return freighter_db
end
function addFreighter(freighter_type,ship)
	local freighter_db = addFreighters()
	if freighter_type ~= nil then
		if freighter_type == "Space Sedan" then
			local space_sedan_db = queryScienceDatabase("Ships","Freighter","Space Sedan")
			if space_sedan_db == nil then
				freighter_db:addEntry("Space Sedan")
				space_sedan_db = queryScienceDatabase("Ships","Freighter","Space Sedan")
				genericFreighterScienceInfo(space_sedan_db,queryScienceDatabase("Ships","Corvette","Personnel Jump Freighter 3"),ship)
				space_sedan_db:setModelDataName("transport_1_3")
				space_sedan_db:setLongDescription(_("ship-scienceDatabase","The Space Sedan was built around a surplus Personnel Jump Freighter 3. It's designed to provide relatively low cost transportation primarily for people, but there is also a limited amount of cargo space available"))
			end
		elseif freighter_type == "Omnibus" then
			local omnibus_db = queryScienceDatabase("Ships","Freighter","Omnibus")
			if omnibus_db == nil then
				freighter_db:addEntry("Omnibus")
				omnibus_db = queryScienceDatabase("Ships","Freighter","Omnibus")
				genericFreighterScienceInfo(omnibus_db,queryScienceDatabase("Ships","Corvette","Personnel Jump Freighter 5"),ship)
				omnibus_db:setModelDataName("transport_1_5")
				omnibus_db:setLongDescription(_("ship-scienceDatabase","The Omnibus was designed from the Personnel Jump Freighter 5. It's made to transport large numbers of passengers of various types along with their luggage and any associated cargo"))
			end
		elseif freighter_type == "Service Jonque" then
			local service_jonque_db = queryScienceDatabase("Ships","Freighter","Service Jonque")
			if service_jonque_db == nil then
				freighter_db:addEntry("Service Jonque")
				service_jonque_db = queryScienceDatabase("Ships","Freighter","Service Jonque")
				genericFreighterScienceInfo(service_jonque_db,queryScienceDatabase("Ships","Corvette","Equipment Jump Freighter 4"),ship)
				service_jonque_db:setModelDataName("transport_4_4")
				service_jonque_db:setLongDescription(_("ship-scienceDatabase","The Service Jonque is a modified Equipment Jump Freighter 4. It's designed to carry spare parts and equipment as well as the necessary repair personnel to where it's needed to repair stations and ships"))
			end
		elseif freighter_type == "Courier" then
			local courier_db = queryScienceDatabase("Ships","Freighter","Courier")
			if courier_db == nil then
				freighter_db:addEntry("Courier")
				courier_db = queryScienceDatabase("Ships","Freighter","Courier")
				genericFreighterScienceInfo(courier_db,queryScienceDatabase("Ships","Corvette","Personnel Freighter 1"),ship)
				courier_db:setModelDataName("transport_1_1")
				courier_db:setLongDescription(_("ship-scienceDatabase","The Courier is a souped up Personnel Freighter 1. It's made to deliver people and messages fast. Very fast"))
			end
		elseif freighter_type == "Work Wagon" then
			local work_wagon_db = queryScienceDatabase("Ships","Freighter","Work Wagon")
			if work_wagon_db == nil then
				freighter_db:addEntry("Work Wagon")
				work_wagon_db = queryScienceDatabase("Ships","Freighter","Work Wagon")
				genericFreighterScienceInfo(work_wagon_db,queryScienceDatabase("Ships","Corvette","Equipment Freighter 2"),ship)
				work_wagon_db:setModelDataName("transport_4_2")
				work_wagon_db:setLongDescription(_("ship-scienceDatabase","The Work Wagon is a conversion of an Equipment Freighter 2 designed to carry equipment and parts where they are needed for repair or construction."))
			end
		elseif freighter_type == "Laden Lorry" then
			local laden_lorry_db = queryScienceDatabase("Ships","Freighter","Laden Lorry")
			if laden_lorry_db == nil then
				freighter_db:addEntry("Laden Lorry")
				laden_lorry_db = queryScienceDatabase("Ships","Freighter","Laden Lorry")
				genericFreighterScienceInfo(laden_lorry_db,queryScienceDatabase("Ships","Corvette","Goods Freighter 3"),ship)
				laden_lorry_db:setModelDataName("transport_2_3")
				laden_lorry_db:setLongDescription(_("ship-scienceDatabase","As a side contract, Conversion R Us put together the Laden Lorry from some recently acquired Goods Freighter 3 hulls. The added warp drive makes for a more versatile goods carrying vessel."))
			end
		elseif freighter_type == "Physics Research" then
			local physics_research_db = queryScienceDatabase("Ships","Freighter","Physics Research")
			if physics_research_db == nil then
				freighter_db:addEntry("Physics Research")
				physics_research_db = queryScienceDatabase("Ships","Freighter","Physics Research")
				genericFreighterScienceInfo(physics_research_db,queryScienceDatabase("Ships","Corvette","Garbage Freighter 3"),ship)
				physics_research_db:setModelDataName("transport_3_3")
				physics_research_db:setLongDescription(_("ship-scienceDatabase","Conversion R Us cleaned up and converted excess freighter hulls into Physics Research vessels. The reduced weight improved the impulse speed and maneuverability."))
			end
		end
	end
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
		local count_repeat_loop = 0
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
			count_repeat_loop = count_repeat_loop + 1
		until(ship:getBeamWeaponRange(bi) < 1 or count_repeat_loop > max_repeat_loop)
		if count_repeat_loop > max_repeat_loop then
			print("repeated too many times when going through beams")
		end
	end
	local tubes = ship:getWeaponTubeCount()
	if tubes > 0 then
		if tube_directions ~= nil then
			for i=1,#tube_directions do
				modified_db:setKeyValue(tube_directions[i].key,tube_directions[i].value)
			end
		end
		local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for index, missile_type in ipairs(missile_types) do
			local max_storage = ship:getWeaponStorageMax(missile_type)
			if max_storage > 0 then
				modified_db:setKeyValue(string.format("Storage %s",missile_type),string.format("%i",max_storage))
			end
		end
	end
end
------------------------
--	Update functions  --
------------------------
function launchInvestigationFleet(p)
	p.investigation_fleet = {}
	for _, station in ipairs(station_list) do
		if station ~= nil and station:isValid() then
			local station_x, station_y = station:getPosition()
			local launch_angle = random(0,360)
			for i=1,difficulty*2 do
				local dx, dy = vectorFromAngleNorth(launch_angle,5000)
				local ship = ship_template["Jade 5"].create(station:getFaction(),"Jade 5"):setPosition(station_x + dx, station_y + dy)
				if ship:isEnemy(p) then
					ship:orderAttack(p)
				else
					ship:orderDefendTarget(p)
				end
				table.insert(p.investigation_fleet,ship)
				dx, dy = vectorFromAngleNorth((launch_angle + i * 360/difficulty*4) % 360,5000)
				ship = ship_template["Waddle 5"].create(station:getFaction(),"Waddle 5"):setPosition(station_x + dx, station_y + dy)
				if ship:isEnemy(p) then
					ship:orderAttack(p)
				else
					ship:orderDefendTarget(p)
				end
				table.insert(p.investigation_fleet,ship)
				launch_angle = (launch_angle + 360/difficulty*2) % 360
			end
		end
	end
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
	local s_time = getScenarioTime()
	if s_time > 7 then
		if mission_message == nil then
			local p = getPlayerShip(-1)
			mission_message = string.format(_("goal-shipLog","Greetings %s. Welcome to Dodge, a region named after the fictional cliche frontier location from early 20th century literature. Many harrowing adventures occurred in the fictional wild west version of Dodge. Similarly, in this region of space named Dodge, regular commercial traffic struggles to succeed due to the lack of a strong central authority and the proximity of several factions that war with each other. With your Repulse type ship, armed, but with ample cargo and passenger space, you should be able to succeed as a courier or as someone that helps rein in some of the wanton destruction and fighting. Your job will be to provide essential services for the people of Dodge."),p:getCallSign())
			p:addToShipLog(mission_message,"Magenta")
		end
	end
	if s_time > 55 then
		if solicitation_1 == nil then
			local p = getPlayerShip(-1)
			local mission_selection = math.random(1,#taxi_missions)
			local mission = taxi_missions[mission_selection]
			solicitation_1 = ""
			if mission.origin ~= nil and mission.origin:isValid() then
				if mission.destination ~= nil and mission.destination:isValid() then
					solicitation_1 = string.format(_("goal-shipLog","Hi. I represent some people who want to travel to %s in %s. They don't want to take normal transportation due to the risk of predation by warring factions. They asked me to find them safer transportation. Since you're an armored transport, I thought I'd see if you're interested. Here are the details:\n\n%s\n\nAnyway, if you're interested, you can find them on %s in %s"),mission.destination:getCallSign(),mission.destination:getSectorName(),mission.desc,mission.origin:getCallSign(),mission.origin:getSectorName())
					mission.origin:sendCommsMessage(p,solicitation_1)
				end
			end
		end
	end
	if s_time > 132 then
		if solicitation_2 == nil then
			local p = getPlayerShip(-1)
			local mission_selection = math.random(1,#taxi_missions)
			local mission = taxi_missions[mission_selection]
			if not mission.solicited then
				solicitation_2 = ""
				if mission.origin ~= nil and mission.origin:isValid() then
					if mission.destination ~= nil and mission.destination:isValid() then
						solicitation_2 = string.format(_("goal-shipLog","Hello. I know people who want to travel to %s in %s. They want safer travel than standard mass transportation. I'm contacting you on their behalf. If you're interested, here are the details:\n\n%s\n\nYou can find them on %s in %s"),mission.destination:getCallSign(),mission.destination:getSectorName(),mission.desc,mission.origin:getCallSign(),mission.origin:getSectorName())
						mission.origin:sendCommsMessage(p,solicitation_2)
					end
				end
			end
		end
	end
	if s_time > black_hole_milestone then
		if devouring_black_holes == nil then
			establishDevouringBlackHoles()
		else
			updateDevouringBlackHoles(delta)
		end
	end
	if s_time > 1800 then
		local survivor_count = countSurvivors()
		local score = .5*survivor_count["total"]["friend"]/residents["friend"] + .3*survivor_count["total"]["neutral"]/residents["neutral"] + .2*survivor_count["total"]["enemy"]/residents["enemy"]
		local rank = _("msgMainscreen","Cadet")
		if score > .9 then 
			rank = _("msgMainscreen","Admiral")
		elseif score > .8 then
			rank = _("msgMainscreen","Commodore")
		elseif score > .7 then
			rank = _("msgMainscreen","Captain")
		elseif score > .6 then
			rank = _("msgMainscreen","Commander")
		elseif score > .5 then
			rank = _("msgMainscreen","Lieutenant")
		elseif score > .4 then
			rank = _("msgMainscreen","Ensign")
		elseif score > .3 then
			rank = _("msgMainscreen","Acting Ensign")
		end
		local total_start = residents["friend"] + residents["neutral"] + residents["enemy"]
		local msg = string.format(_("msgMainscreen","Survivors:   %i/%i(%i%%)    Score:%i   Rank:%s"),survivor_count["total"]["total"],total_start,math.floor(survivor_count["total"]["total"]/total_start*100),math.floor(score*100),rank)
		globalMessage(msg)
		setBanner(msg)
		local consoles = {"Helms", "Weapons", "Engineering", "Science", "Relay", "Tactical", "Engineering+", "Operations", "Single", "DamageControl", "PowerManagement", "Database", "AltRelay", "CommsOnly", "ShipLog"}
		local p = getPlayerShip(-1)
		msg = string.format(_("msgMainscreen","End of game information:\n%s"),msg)
		for _, console in ipairs(consoles) do
			local stat_msg = string.format("stat_msg_%s",console)
			p:addCustomMessage(console,stat_msg,msg)
		end
		victory("Human Navy")
	end
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.pidx == nil then
				p.pidx = pidx
				setPlayer(p)
			end
			updatePlayerLongRangeSensors(p)
			updatePlayerUpgradeMission(p)
			if s_time > black_hole_milestone then
				if p.mass_transit_request == nil then
					if distance(p,central_control) < 60000 then
						p.mass_transit_request = "done"
						local bus_pool = {}
						for _, bus in ipairs(bus_list) do
							if bus ~= nil and bus:isValid() and not bus:isEnemy(p) then
								table.insert(bus_pool,bus)
							end
						end
						if #bus_pool > 0 then
							local selected_bus = bus_pool[math.random(1,#bus_pool)]
							selected_bus:setCommsScript(""):setCommsFunction(commsSelectedBus)
							selected_bus:openCommsTo(p)
						end
					end
				end
				if p.investigation_fleet == nil then
					if distance(p,central_control) < 1000 then
						launchInvestigationFleet(p)
					end
				end
			end
		end
	end
	if evangelist ~= nil then
		updateEvangelist()
	end
	if maintenancePlot ~= nil then
		maintenancePlot(delta)
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
function playerDestroyed()
	local survivor_count = countSurvivors()
	local score = .5*survivor_count["total"]["friend"]/residents["friend"] + .3*survivor_count["total"]["neutral"]/residents["neutral"] + .2*survivor_count["total"]["enemy"]/residents["enemy"]
	local rank = _("msgMainscreen","Cadet")
	if score > .9 then 
		rank = _("msgMainscreen","Admiral")
	elseif score > .8 then
		rank = _("msgMainscreen","Commodore")
	elseif score > .7 then
		rank = _("msgMainscreen","Captain")
	elseif score > .6 then
		rank = _("msgMainscreen","Commander")
	elseif score > .5 then
		rank = _("msgMainscreen","Lieutenant")
	elseif score > .4 then
		rank = _("msgMainscreen","Ensign")
	elseif score > .3 then
		rank = _("msgMainscreen","Acting Ensign")
	end
	local total_start = residents["friend"] + residents["neutral"] + residents["enemy"]
	local msg = string.format(_("msgMainscreen","Survivors:   %i/%i(%i%%)    Score:%i   Rank:%s"),survivor_count["total"]["total"],total_start,math.floor(survivor_count["total"]["total"]/total_start*100),math.floor(score*100),rank)
	local g_msg = string.format(_("msgMainscreen","%s\nNote: The score means significantly less since your ship was destroyed.\nHad you survived, you might have helped more Dodge residents."),msg)
	globalMessage(g_msg)
	msg = string.format(_("msgMainscreen","%s   Ship destroyed. Score inaccurate, provided for reference only."),msg)
	setBanner(msg)
	victory("Exuari")
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

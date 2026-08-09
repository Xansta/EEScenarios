-- Name: Déjà vu
-- Description: Patrol the area to protect against enemy attacks plus ad hoc missions
---
--- Version 1
---
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online. There's usually one every weekend. All experience levels are welcome. 
-- Type: Replayable Mission
-- Author: Xansta
-- Setting[Enemies]: Configures strength and/or number of enemies in this scenario
-- Enemies[Easy]: Fewer or weaker enemies
-- Enemies[Normal|Default]: Normal number or strength of enemies
-- Enemies[Hard]: More or stronger enemies
-- Enemies[Extreme]: Much stronger, many more enemies
-- Enemies[Quixotic]: Insanely strong and/or inordinately large numbers of enemies
-- Setting[ReputationGoal]: Sets the reputation goal to win the game. Default 500 runs about an hour
-- ReputationGoal[400]: Accumulate 400 reputation points to win
-- ReputationGoal[800|Default]: Accumulate 800 reputation points to win
-- ReputationGoal[1200]: Accumulate 1200 reputation points to win
-- ReputationGoal[1600]: Accumulate 1600 reputation points to win

--	Fixed neighborhood with some simple missions
--		Plan for several non-linear missions that multiple player ships can accomplish
--	Randomized exterior regions for subsequent missions
require("utils.lua")
require("place_station_scenario_utility.lua")
require("comms_scenario_utility.lua")
require("spawn_ships_scenario_utility.lua")
function init()
	scenario_version = "1.0.3"
	ee_version = "2024.12.08"
	print(string.format("    ----    Scenario: Déjà vu    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
	if _VERSION ~= nil then
		print("Lua version:",_VERSION)
	end
	setConstants()
	setGlobals()
	setVariations()
	setSpawnShipGlobals()
	constructEnvironment()
	mainGMButtons()
	onNewPlayerShip(setPlayers)
end
function mainGMButtons()
	clearGMFunctions()
	addGMFunction("+Spawn Ship(s)",spawnGMShips)
end
function setConstants()
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	sensor_impact = 1	--normal is 1
	strip_transports = {
		"Independent",
		"Arlenians",
		"Kraylor",
		"Ktlitans",
		"Ghosts",
		"Independent",
		"Independent",
		"Independent",
		"Independent",
		"Independent",
	}
	faction_letter = {
		["Human Navy"] = "H",
		["Independent"] = "I",
		["Kraylor"] = "K",
		["Ktlitans"] = "B",
		["Exuari"] = "E",
		["Ghosts"] = "G",
		["Arlenians"] = "A",
		["TSN"] = "T",
		["CUF"] = "C",
		["USN"] = "U",
	}
	station_spacing = {
		["Small Station"] =		{touch = 300,	defend = 2600,	platform = 600,		outer_platform = 7500},
		["Medium Station"] =	{touch = 1200,	defend = 4000,	platform = 2400,	outer_platform = 9100},
		["Large Station"] =		{touch = 1400,	defend = 4600,	platform = 2800,	outer_platform = 9700},
		["Huge Station"] =		{touch = 2000,	defend = 4960,	platform = 3500,	outer_platform = 10100},
	}
	system_types = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
	ship_template_distance = {
		["Adder MK3"] =						100,
		["Adder MK4"] =						100,
		["Adder MK5"] =						100,
		["Adder MK6"] =						100,
		["Adder MK7"] =						100,
		["Adder MK8"] =						100,
		["Adder MK9"] =						100,
		["Adv. Gunship"] =					400,
		["Adv. Striker"] = 					300,
		["Atlantis X23"] =					400,
		["Atlantis Y42"] =					400,
		["Battlestation"] =					2000,
		["Beast Breaker"] =					300,
		["Blockade Runner"] =				400,
		["Blade"] =							300,
		["Broom"] =							100,
		["Brush"] =							100,
		["Buster"] =						100,
		["Command Base"] =					800,		
		["Courier"] =						600,
		["Cruiser"] =						200,
		["Cucaracha"] =						200,
		["Dagger"] =						100,
		["Dash"] =							200,
		["Defense platform"] =				800,
		["Diva"] =							350,
		["Tsarina"] =						350,
		["Brood Mother"] =					350,
		["Dread No More"] =					400,
		["Dreadnought"] =					400,
		["Elara P2"] =						200,
		["Enforcer"] =						400,
		["Enforcer V2"] =					400,
		["Equipment Freighter 1"] =			600,
		["Equipment Freighter 2"] =			600,
		["Equipment Freighter 3"] =			600,
		["Equipment Freighter 4"] =			800,
		["Equipment Freighter 5"] =			800,
		["Equipment Jump Freighter 3"] =	600,
		["Equipment Jump Freighter 4"] =	800,
		["Equipment Jump Freighter 5"] =	800,
		["Farco 3"] =						200,
		["Farco 5"] =						200,
		["Farco 8"] =						200,
		["Farco 11"] =						200,
		["Farco 13"] =						200,
		["Fiend G3"] =						400,
		["Fiend G4"] =						400,
		["Fiend G5"] =						400,
		["Fiend G6"] =						400,
		["Fighter"] =						200,
		["Flash"] =							100,
		["Flavia"] =						200,
		["Flavia Falcon"] =					200,
		["Fortress"] =						2000,
		["Foul Feeder"] =					300,
		["Fray"] =							200,
		["Fuel Freighter 1"] =				600,
		["Fuel Freighter 2"] =				600,
		["Fuel Freighter 3"] =				600,
		["Fuel Freighter 4"] =				800,
		["Fuel Freighter 5"] =				800,
		["Fuel Jump Freighter 3"] =			600,
		["Fuel Jump Freighter 4"] =			800,
		["Fuel Jump Freighter 5"] =			800,
		["Garbage Freighter 1"] =			600,
		["Garbage Freighter 2"] =			600,
		["Garbage Freighter 3"] =			600,
		["Garbage Freighter 4"] =			800,
		["Garbage Freighter 5"] =			800,
		["Garbage Jump Freighter 3"] =		600,
		["Garbage Jump Freighter 4"] =		800,
		["Garbage Jump Freighter 5"] =		800,
		["Gnat"] =							300,
		["Goods Freighter 1"] =				600,
		["Goods Freighter 2"] =				600,
		["Goods Freighter 3"] =				600,
		["Goods Freighter 4"] =				800,
		["Goods Freighter 5"] =				800,
		["Goods Jump Freighter 3"] =		600,
		["Goods Jump Freighter 4"] =		800,
		["Goods Jump Freighter 5"] =		800,
		["Guard"] =							600,	--transport_1_1
		["Gulper"] =						400,
		["Gunner"] =						100,
		["Gunship"] =						400,
		["Heavy Drone"] = 					300,
		["Hunter"] =						200,
		["Jacket Drone"] =					300,
		["Jade 5"] =						100,
		["Jagger"] =						100,
		["Jump Carrier"] =					800,		
		["Karnack"] =						200,
		["K2 Fighter"] =					300,
		["K3 Fighter"] =					300,
		["Ktlitan Breaker"] =				300,
		["Ktlitan Destroyer"] = 			500,
		["Ktlitan Drone"] =					300,
		["Ktlitan Feeder"] =				300,
		["Ktlitan Fighter"] =				300,
		["Ktlitan Queen"] =					500,
		["Ktlitan Scout"] =					300,
		["Ktlitan Worker"] =				300,
		["Laden Lorry"] =					600,
		["Lite Drone"] = 					300,
		["Loki"] =							1500,
		["Maniapak"] =						100,
		["Mikado"] =						200,
		["Military Outpost"] =				800,
		["Missile Pod D1"] =				800,
		["Missile Pod D2"] =				800,
		["Missile Pod D4"] =				800,
		["Missile Pod T1"] =				800,
		["Missile Pod T2"] =				800,
		["Missile Pod TI2"] =				800,
		["Missile Pod TI4"] =				800,
		["Missile Pod TI8"] =				800,
		["Missile Pod TX4"] =				800,
		["Missile Pod TX8"] =				800,
		["Missile Pod TX16"] =				800,
		["Missile Pod S1"] =				800,
		["Missile Pod S4"] =				800,
		["Missile Cruiser"] =				200,
		["MT52 Hornet"] =					100,
		["MT55 Hornet"] =					100,
		["MU52 Hornet"] =					100,
		["MU55 Hornet"] =					100,
		["Munemi"] =						100,
		["MV52 Hornet"] =					100,
		["Nirvana R3"] =					200,
		["Nirvana R5"] =					200,
		["Nirvana R5A"] =					200,
		["Odin"] = 							1500,
		["Omnibus"] = 						800,
		["Personnel Freighter 1"] =			600,
		["Personnel Freighter 2"] =			600,
		["Personnel Freighter 3"] =			600,
		["Personnel Freighter 4"] =			800,
		["Personnel Freighter 5"] =			800,
		["Personnel Jump Freighter 3"] =	600,
		["Personnel Jump Freighter 4"] =	800,
		["Personnel Jump Freighter 5"] =	800,
		["Phobos M3"] =						200,
		["Phobos R2"] =						200,
		["Phobos T3"] =						200,
		["Phobos T4"] =						200,
		["Physics Research"] =				600,
		["Piranha F10"] =					200,
		["Piranha F12"] =					200,
		["Piranha F12.M"] =					200,
		["Piranha F8"] =					200,
		["Porcupine"] =						400,
		["Prador"] =						2000,
		["Predator"] =						200,
		["Predator V2"] =					200,
		["Racer"] =							200,
		["Ranger"] =						100,
		["Ranus U"] =						200,
		["Roc"] =							200,
		["Rook"] =							200,
		["Ryder"] =							2000,
		["Sentinel"] =						600,
		["Service Jonque"] =				800,
		["Shepherd"] =						100,
		["Shooter"] =						100,
		["Sloop"] =							200,
		["Sniper Tower"] =					800,
		["Space Sedan"] =					600,
		["Stalker Q5"] =					200,
		["Stalker Q7"] =					200,
		["Stalker R5"] =					200,
		["Stalker R7"] =					200,
		["Starhammer II"] =					400,
		["Starhammer III"] =				400,
		["Starhammer V"] =					400,
		["Storm"] =							200,
		["Strike"] =						200,
		["Strikeship"] = 					200,
		["Strongarm"] =						400,
		["Supervisor"] =					400,
		["Sweeper"] =						100,
		["Tempest"] =						200,
		["Transport1x1"] =					600,
		["Transport1x2"] =					600,
		["Transport1x3"] =					600,
		["Transport1x4"] =					800,
		["Transport1x5"] =					800,
		["Transport2x1"] =					600,
		["Transport2x2"] =					600,
		["Transport2x3"] =					600,
		["Transport2x4"] =					800,
		["Transport2x5"] =					800,
		["Transport3x1"] =					600,
		["Transport3x2"] =					600,
		["Transport3x3"] =					600,
		["Transport3x4"] =					800,
		["Transport3x5"] =					800,
		["Transport4x1"] =					600,
		["Transport4x2"] =					600,
		["Transport4x3"] =					600,
		["Transport4x4"] =					800,
		["Transport4x5"] =					800,
		["Transport5x1"] =					600,
		["Transport5x2"] =					600,
		["Transport5x3"] =					600,
		["Transport5x4"] =					800,
		["Transport5x5"] =					800,
		["Tug"] =							200,
		["Tyr"] =							2000,
		["Waddle 5"] =						100,
		["Warden"] =						600,
		["Weapons platform"] =				200,
		["Whirlwind"] =						200,
		["Wombat"] =						100,
		["Work Wagon"] =					600,
		["WX-Lindworm"] =					100,
		["WZ-Lindworm"] =					100,
	}
	beam_range_losses = {
		{name = "Lo",	val = .8,	desc = "May slightly reduce beam range"},			
		{name = "Md",	val = .7,	desc = "May reduce beam range"},					
		{name = "Hi",	val = .6,	desc = "May significantly reduce beam range"},		
		{name = "Sv",	val = .5,	desc = "May severely reduce beam range"},			
	}
	beam_range_gains = {
		{name = "Lo",	val = 1.1,	desc = "May slightly increase beam range"},				
		{name = "Md",	val = 1.25,	desc = "May increase beam range"},						
		{name = "Hi",	val = 1.4,	desc = "May significantly increase beam range"},		
	}
	shield_losses = {
		{name = "Lo",	val = .99999,	desc = "May cause low rates of shield charge loss"},	
		{name = "Md",	val = .99995,	desc = "May cause shield charge loss"},					
		{name = "Hi",	val = .9999,	desc = "May cause high rates of shield charge loss"},	
		{name = "Sv",	val = .999,		desc = "May cause severe rates of shield charge loss"},	
	}
	shield_gains = {
		{name = "Lo",	val = 1.000005,	desc = "May slightly increase shield charge"},		
		{name = "Md",	val = 1.00005,	desc = "May increase shield charge"},				
		{name = "Hi",	val = 1.0005,	desc = "May significantly increase shield charge"},	
	}
	coolant_losses = {
		{name = "Lo",	val = .99999,	desc = "May cause low level coolant leakage"},			--easy
		{name = "Md",	val = .99995,	desc = "May cause coolant leakage"},					--normal
		{name = "Hi",	val = .9999,	desc = "May cause high rates of coolant leakage"},		--hard
		{name = "Sv",	val = .999,		desc = "May cause severe rates of coolant leakage"},	--quixotic
	}
	coolant_gains = {
		{name = "Lo",	val = .0001,	desc = "May gain low amounts of coolant"},		--hard
		{name = "Md",	val = .001,		desc = "May gain coolant"},						--normal
		{name = "Hi",	val = .01,		desc = "May gain high amounts of coolant"},		--easy
	}
end
function setGlobals()
	primary_orders = "Patrol friendly stations"
	complete_faction_sources = {
		"Human Navy",
		"Kraylor",
		"Independent",
		"Arlenians",
		"Exuari",
		"Ghosts",
		"Ktlitans",
		"USN",
		"TSN",
		"CUF",
	}
	research_containers = {}
	blinking_artifacts = {}
	blink_artifact_time = getScenarioTime() + 1
	artifact_number = 0
	sensor_jammer_list = {}
	max_repeat_loop = 50
	current_orders_button = true
	stations_sell_goods = true
	stations_buy_goods = true
	station_general_information = true
	stations_support_transport_missions = true
	stations_support_cargo_missions = true
	outer_stations = {}
	friendly_spike_stations = {}
	relative_strength = 1
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
		["Mehklar"] =		{id = "M", count = 0},
	}
	initial_message_time = getScenarioTime() + random(3,8)
	player_start_points = {
		{x = 1000,	y = 1000},	--1
		{x = -1000,	y = 1000},	--2
		{x = 1000,	y = -1000},	--3
		{x = -1000,	y = -1000},	--4
		{x = 2000,	y = 1000},	--5
		{x = -2000,	y = 1000},	--6
		{x = 1000,	y = 2000},	--7
		{x = 1000,	y = -2000},	--8
		{x = 2000,	y = -1000},	--9
		{x = -2000,	y = -1000},	--10
		{x = -1000,	y = 2000},	--11
		{x = -1000,	y = -2000},	--12
		{x = 2000,	y = 2000},	--13
		{x = -2000,	y = 2000},	--14
		{x = 2000,	y = -2000},	--15
		{x = -2000,	y = -2000},	--16
		{x = 3000,	y = 1000},	--17
		{x = -3000,	y = 1000},	--18
		{x = 3000,	y = 2000},	--19
		{x = -3000,	y = 2000},	--20
		{x = 3000,	y = 3000},	--21
		{x = -3000,	y = 3000},	--22
		{x = 3000,	y = -1000},	--23
		{x = -3000,	y = -1000},	--24
		{x = 3000,	y = -2000},	--25
		{x = -3000,	y = -2000},	--26
		{x = 3000,	y = -3000},	--27
		{x = -3000,	y = -3000},	--28
		{x = 1000,	y = 3000},	--29
		{x = -1000,	y = 3000},	--30
		{x = 1000,	y = -3000},	--31
		{x = -1000,	y = -3000},	--32
	}
	player_ship_stats = {	
		["Atlantis"]			= { strength = 52,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = true	},
		["Atlantis II"]			= { strength = 60,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = true	},
		["Benedict"]			= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = true	},
		["Crucible"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Destroyer III"]		= { strength = 25,	cargo = 7,	distance = 200,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = false	},
		["Destroyer IV"]		= { strength = 25,	cargo = 5,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = false	},
		["Ender"]				= { strength = 100,	cargo = 20,	distance = 2000,long_range_radar = 45000, short_range_radar = 7000, probes = 8,	tractor = true,		mining = false	},
		["Era"]					= { strength = 14,	cargo = 14,	distance = 200,	long_range_radar = 50000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = true	},
		["Flavia 2C"]			= { strength = 25,	cargo = 12,	distance = 200,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = true	},
		["Flavia P.Falcon"]		= { strength = 13,	cargo = 15,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = true	},
		["Focus"]				= { strength = 35,	cargo = 4,	distance = 200,	long_range_radar = 32000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = true	},
		["Hathcock"]			= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = true	},
		["Holmes"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 4000, probes = 8,	tractor = true,		mining = false	},
		["Kiriya"]				= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 35000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = true	},
		["Maverick"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, probes = 8,	tractor = false,	mining = true	},
		["Maverick XP"]			= { strength = 23,	cargo = 5,	distance = 200,	long_range_radar = 25000, short_range_radar = 7000, probes = 8,	tractor = true,		mining = false	},
		["MP52 Hornet"] 		= { strength = 7, 	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 4000, probes = 8,	tractor = false,	mining = false	},
		["MX-Lindworm"]			= { strength = 10,	cargo = 3,	distance = 100,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = false	},
		["Nautilus"]			= { strength = 12,	cargo = 7,	distance = 200,	long_range_radar = 22000, short_range_radar = 4000, probes = 8,	tractor = false,	mining = false	},
		["Pacu"]				= { strength = 18,	cargo = 7,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Phobos M3P"]			= { strength = 19,	cargo = 10,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = false	},
		["Phobos T2"]			= { strength = 19,	cargo = 9,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = false	},
		["Piranha"]				= { strength = 16,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Player Cruiser"]		= { strength = 40,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = false	},
		["Player Missile Cr."]	= { strength = 45,	cargo = 8,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Player Fighter"]		= { strength = 7,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, probes = 8,	tractor = false,	mining = false	},
		["Proto-Atlantis"]		= { strength = 40,	cargo = 4,	distance = 400,	long_range_radar = 30000, short_range_radar = 4500, probes = 8,	tractor = false,	mining = true	},
		["Redhook"]				= { strength = 11,	cargo = 8,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Repulse"]				= { strength = 14,	cargo = 12,	distance = 200,	long_range_radar = 38000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = false	},
		["Saipan"]				= { strength = 30,	cargo = 4,	distance = 200,	long_range_radar = 25000, short_range_radar = 4500, probes = 10,tractor = false,	mining = false	},
		["Squid"]				= { strength = 14,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = false	},
		["Stricken"]			= { strength = 40,	cargo = 4,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, probes = 8,	tractor = false,	mining = false	},
		["Striker"]				= { strength = 8,	cargo = 4,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = false	},
		["Striker LX"]			= { strength = 16,	cargo = 4,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, probes = 8,	tractor = false,	mining = false	},
		["Surkov"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Wombat"]				= { strength = 13,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["ZX-Lindworm"]			= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 5500, probes = 8,	tractor = false,	mining = false	},
	}
	player_ship_names_for = {
		["Atlantis"] =			{"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"},
		["Atlantis II"] =		{"Spyder", "Shelob", "Tarantula", "Aragog", "Charlotte"},
		["Benedict"] =			{"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"},
		["Crucible"] =			{"Sling", "Stark", "Torrid", "Kicker", "Flummox"},
		["Ender"] =				{"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"},
		["Flavia P.Falcon"] =	{"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"},
		["Hathcock"] =			{"Hayha","Waldron","Plunkett","Mawhinney","Furlong","Zaytsev","Pavlichenko","Pegahmagabow","Fett","Hawkeye","Hanzo"},
		["Kiriya"] =			{"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"},
		["Maverick"] =			{"Angel", "Thunderbird", "Roaster", "Magnifier", "Hedge"},
		["MP52 Hornet"] =		{"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"},
		["Nautilus"] =			{"October","Abdiel","Manxman","Newcon","Nusret","Pluton","Amiral","Amur","Heinkel","Dornier"},
		["Phobos M3P"] =		{"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"},
		["Phobos M5P"] =		{"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde","Rage","Cogitate","Thrust","Coyote"},
		["Piranha"] =			{"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"},
		["Player Cruiser"] =	{"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"},
		["Player Fighter"] =	{"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"},
		["Player Missile Cr."] ={"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"},
		["Proto-Atlantis"] =	{"Narsil", "Blade", "Decapitator", "Trisect", "Sabre"},
		["Redhook"] =			{"Headhunter", "Thud", "Troll", "Scalper", "Shark"},
		["Repulse"] =			{"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"},
		["Saipan"] =			{"Atlas", "Bernard", "Alexander", "Retribution", "Sulaco", "Conestoga", "Saratoga", "Pegasus"},
		["Stricken"] =			{"Blazon", "Streaker", "Pinto", "Spear", "Javelin"},
		["Striker"] =			{"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"},
		["Surkov"] =			{"Sting", "Sneak", "Bingo", "Thrill", "Vivisect"},
		["ZX-Lindworm"] =		{"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"},
		["Leftovers"] =			{"Foregone","Righteous","Scandalous"},
	}
	star_list = {
		{radius = random(600,1400), distance = random(-2500,-1400), 
			name = {
				"Gamma Piscium",
				"Beta Lyporis",
				"Sigma Draconis",
				"Iota Carinae",
				"Theta Arietis",
				"Epsilon Indi",
				"Beta Hydri",
				"Acamar",
				"Bellatrix",
				"Castula",
				"Dziban",
				"Elnath",
				"Flegetonte",
				"Geminga",
				"Helvetios",
				"Inquill",
				"Jishui",
				"Kaus Borealis",
				"Liesma",
				"Macondo",
				"Nikawiy",
				"Orkaria",
				"Poerava",
				"Stribor",
				"Taygeta",
				"Tuiren",
				"Ukdah",
				"Wouri",
				"Xihe",
				"Yildun",
				"Zosma",
			},
			color = {
				red = random(0.8,1), green = random(0.8,1), blue = random(0.8,1)
			},
			texture = {
				atmosphere = "planets/star-1.png"
			},
		},
	}
	planet_list = {
		{
			name = {"Bespin","Aldea","Bersallis"},
			texture = {
				surface = "planets/gas-1.png"
			},
		},
		{
			name = {"Farius Prime","Deneb","Mordan"},
			texture = {
				surface = "planets/gas-2.png"
			},
		},
		{
			name = {"Kepler-7b","Alpha Omicron","Nelvana"},
			texture = {
				surface = "planets/gas-3.png"
			},
		},
		{
			name = {"Alderaan","Dagobah","Dantooine","Rigel"},
			color = {
				red = random(0,0.2), 
				green = random(0,0.2), 
				blue = random(0.8,1)
			},
			texture = {
				surface = "planets/planet-1.png", 
				cloud = "planets/clouds-1.png", 
				atmosphere = "planets/atmosphere.png"
			},
		},
		{
			name = {"Pahvo","Penthara","Scalos"},
			color = {
				red = random(0,0.2), 
				green = random(0,0.2), 
				blue = random(0.8,1)
			},
			texture = {
				surface = "planets/planet-4.png", 
				cloud = "planets/clouds-3.png", 
				atmosphere = "planets/atmosphere.png"
			},
		},
		{
			name = {"Tanuga","Vacca","Terlina","Timor"},
			color = {
				red = random(0,0.2), 
				green = random(0,0.2), 
				blue = random(0.8,1)
			},
			texture = {
				surface = "planets/planet-5.png", 
				cloud = "planets/clouds-2.png", 
				atmosphere = "planets/atmosphere.png"
			},
		},
	}
	moon_list = {
		{
			name = {"Ganymede", "Europa", "Deimos", "Luna"},
			texture = {
				surface = "planets/moon-1.png"
			}
		},
		{
			name = {"Myopia", "Zapata", "Lichen", "Fandango"},
			texture = {
				surface = "planets/moon-2.png"
			}
		},
		{
			name = {"Scratmat", "Tipple", "Dranken", "Calypso"},
			texture = {
				surface = "planets/moon-3.png"
			}
		},
	}
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
	reputation_goal = tonumber(getScenarioSetting("ReputationGoal"))
end
function constructEnvironment()
	constructFixedArea()
	constructDynamicArea()
end
function constructFixedArea()
	star_fixed = Planet():setPosition(45833, 16927):setPlanetRadius(5000)
		:setCallSign(tableRemoveRandom(star_list[1].name))
		:setPlanetAtmosphereTexture(star_list[1].texture.atmosphere)
		:setPlanetAtmosphereColor(star_list[1].color.red,star_list[1].color.green,star_list[1].color.blue)
	nice_planet = Planet():setPosition(-72786, 13672):setPlanetRadius(5000):setPlanetCloudRadius(5200.00)
		:setCallSign(tableRemoveRandom(planet_list[4].name))
		:setPlanetAtmosphereTexture(planet_list[4].texture.atmosphere)
		:setDistanceFromMovementPlane(-1500)
		:setPlanetSurfaceTexture(planet_list[4].texture.surface)
		:setPlanetCloudTexture("planets/clouds-3.png")
		:setPlanetAtmosphereColor(planet_list[4].color.red,planet_list[4].color.green,planet_list[4].color.blue)
		:setAxialRotationTime(1000)
		:setOrbit(star_fixed,3000)	--final 3000
	inner_moon = Planet():setPosition(-53646, 13542):setPlanetRadius(1200)
		:setCallSign(tableRemoveRandom(moon_list[1].name))
		:setPlanetSurfaceTexture(moon_list[1].texture.surface)
		:setDistanceFromMovementPlane(-200)
		:setAxialRotationTime(500)
		:setOrbit(nice_planet,700)	--final 700
	outer_moon = Planet():setPosition(-39062, 13411):setPlanetRadius(1400):setPlanetCloudRadius(1600)
		:setCallSign(tableRemoveRandom(moon_list[3].name))
		:setPlanetSurfaceTexture(moon_list[3].texture.surface)
		:setPlanetCloudTexture("planets/clouds-1.png")
		:setDistanceFromMovementPlane(-300)
		:setAxialRotationTime(700)
		:setOrbit(nice_planet,-1200)	--final -1200
	local planet_angle = angleHeading(-72786, 13672, 45833, 16927)
	local planet_dist = distance(-72786, 13672, 45833, 16927)
	local np2_x, np2_y = vectorFromAngle(planet_angle,planet_dist,true)
	nice_planet_2 = Planet():setPosition(np2_x + 45833, np2_y + 16927):setPlanetRadius(5000):setPlanetCloudRadius(5200.00)
		:setCallSign(tableRemoveRandom(planet_list[5].name))
		:setPlanetAtmosphereTexture(planet_list[5].texture.atmosphere)
		:setDistanceFromMovementPlane(-1500)
		:setPlanetSurfaceTexture(planet_list[5].texture.surface)
		:setPlanetCloudTexture("planets/clouds-2.png")
		:setPlanetAtmosphereColor(planet_list[5].color.red,planet_list[5].color.green,planet_list[5].color.blue)
		:setAxialRotationTime(1200)
		:setOrbit(star_fixed,3000)	--final 3000
	local moon_angle = angleHeading(-53646, 13542, 45833, 16927)
	local moon_dist = distance(-53646, 13542, 45833, 16927)
	local im2_x, im2_y = vectorFromAngle(moon_angle,moon_dist,true)
	inner_moon_2 = Planet():setPosition(im2_x + 45833, im2_y + 16927):setPlanetRadius(1200)
		:setCallSign(tableRemoveRandom(moon_list[2].name))
		:setPlanetSurfaceTexture(moon_list[2].texture.surface)
		:setDistanceFromMovementPlane(-200)
		:setAxialRotationTime(550)
	moon_angle = angleHeading(-39062, 13411, 45833, 16927)
	moon_dist = distance(-39062, 13411, 45833, 16927)
	local om2_x, om2_y = vectorFromAngle(moon_angle,moon_dist,true)
	outer_moon_2 = Planet():setPosition(om2_x + 45833, om2_y + 16927):setPlanetRadius(1400):setPlanetCloudRadius(1600)
		:setCallSign(tableRemoveRandom(moon_list[1].name))
		:setPlanetSurfaceTexture(moon_list[1].texture.surface)
		:setPlanetCloudTexture("planets/clouds-1.png")
		:setDistanceFromMovementPlane(-300)
		:setAxialRotationTime(750)
		:setOrbit(nice_planet_2,-1200)	--final -1200
	inner_moon_2:setOrbit(outer_moon_2,230)
	planet_collision_list = {
		{planet = star_fixed,		fudge = 430},
		{planet = nice_planet,		fudge = 187},
		{planet = inner_moon,		fudge = 32},
		{planet = outer_moon,		fudge = 45},
		{planet = nice_planet_2,	fudge = 187},
		{planet = inner_moon_2,		fudge = 32},
		{planet = outer_moon_2,		fudge = 45},
	}
	self_defending_stations = {}
	inner_stations = {}
	--	Stations near headquarters
	station_headquarters = placeStation(-2865, 10417,"Pop Sci Fi","Human Navy","Large Station")
	station_headquarters:setShortRangeRadarRange(15000)
	station_headquarters.transport_mission_restricted = true
	table.insert(inner_stations,station_headquarters)
	station_asteroids_i_near_h = placeStation(-7889, 27185,"Generic","Independent","Small Station")
	table.insert(self_defending_stations,station_asteroids_i_near_h)
	table.insert(inner_stations,station_asteroids_i_near_h)
	station_asteroids_a_far_h = placeStation(850, 37137,"History","Arlenians","Small Station")
	station_asteroids_a_far_h.transport_mission_restricted = true
	table.insert(inner_stations,station_asteroids_a_far_h)
	table.insert(self_defending_stations,station_asteroids_a_far_h)
	--	stations near medium TSN station
	station_med_TSN = placeStation(43846, -21746,"Spec Sci Fi","TSN","Medium Station")
	station_med_TSN:setShortRangeRadarRange(10000)
	station_med_TSN.transport_mission_restricted = true
	table.insert(inner_stations,station_med_TSN)
	if station_med_TSN.comms_data.buy == nil then
		station_med_TSN.comms_data.buy = {}
	end
	station_med_TSN.comms_data.buy.tritanium = math.random(70,90)
	station_asteroids_i_near_t = placeStation(49310, -12572,"Generic","Independent","Small Station")
	table.insert(self_defending_stations,station_asteroids_i_near_t)
	table.insert(inner_stations,station_asteroids_i_near_t)
	station_asteroids_g_far_t = placeStation(65477, -9885,"Science","Ghosts","Small Station")
	station_asteroids_g_far_t.transport_mission_restricted = true
	table.insert(self_defending_stations,station_asteroids_g_far_t)
	--	stations between large USN station and huge CUF station
	station_large_USN = placeStation(20914, 43695,"Pop Sci Fi","USN","Large Station")
	station_large_USN:setShortRangeRadarRange(15000)
	station_large_USN.transport_mission_restricted = true
	table.insert(inner_stations,station_large_USN)
	station_huge_CUF = placeStation(76019, 22159,"RandomHumanNeutral","CUF","Huge Station")
	station_huge_CUF:setShortRangeRadarRange(20000)
	station_huge_CUF.transport_mission_restricted = true
	table.insert(inner_stations,station_huge_CUF)
	station_asteroids_k_near_u = placeStation(46761, 56462,"Sinister","Kraylor","Small Station")
	table.insert(self_defending_stations,station_asteroids_k_near_u)
	station_asteroids_b_near_c = placeStation(62007, 39194,"Sinister","Ktlitans","Small Station")
	table.insert(self_defending_stations,station_asteroids_b_near_c)
	--	make sure friendly stations have missiles
	local friendlies = {station_large_USN,station_huge_CUF,station_med_TSN,station_headquarters}
	local cost = {
		["Homing"] =	math.random(1,5),
		["HVLI"] =		math.random(1,4),
		["Mine"] =		math.random(2,8),
		["EMP"] =		math.random(8,12),
		["Nuke"] =		math.random(12,18),
	}
	for j,missile in ipairs(missile_types) do
		local available = false
		for i,station in ipairs(friendlies) do
			if station.comms_data.weapon_available[missile] then
				available = true
				break
			end
		end
		if not available then
			local selected_station = tableSelectRandom(friendlies)
			selected_station.comms_data.weapon_available[missile] = true
			if selected_station.comms_data.weapon_cost == nil then
				selected_station.comms_data.weapon_cost = {}
			end
			selected_station.comms_data.weapon_cost[missile] = cost[missile]
		end
	end
	for i,station in ipairs(friendlies) do
		local no_missiles = true
		for j,missile in ipairs(missile_types) do
			if station.comms_data.weapon_available[missile] then
				no_missiles = false
				break
			end
		end
		if no_missiles then
			local selected_missile = tableSelectRandom(missile_types)
			station.comms_data.weapon_available[selected_missile] = true
			if station.comms_data.weapon_cost == nil then
				station.comms_data.weapon_cost = {}
			end
			station.comms_data.weapon_cost[selected_missile] = cost[selected_missile]
		end
	end
	--	station ghost eye
	station_eye_ghost = placeStation(-92065, -91965,"History","Ghosts","Medium Station")
	station_eye_ghost.transport_mission_restricted = true
	--	aggressive Kraylor
	station_aggressive_kraylor = placeStation(196329, 106410,"Sinister","Kraylor","Medium Station")
	kraylor_defenders = {}
    table.insert(kraylor_defenders,CpuShip():setFaction("Kraylor"):setTemplate("Adder MK5"):setPosition(199950, 109231):orderDefendTarget(station_aggressive_kraylor))
    table.insert(kraylor_defenders,CpuShip():setFaction("Kraylor"):setTemplate("Adder MK5"):setPosition(199624, 103215):orderDefendTarget(station_aggressive_kraylor))
    table.insert(kraylor_defenders,CpuShip():setFaction("Kraylor"):setTemplate("Adder MK5"):setPosition(192090, 104649):orderDefendTarget(station_aggressive_kraylor))
    table.insert(kraylor_defenders,CpuShip():setFaction("Kraylor"):setTemplate("Adder MK5"):setPosition(193736, 110198):orderDefendTarget(station_aggressive_kraylor))
   	local sx, sy = station_aggressive_kraylor:getPosition()
   	orbiting_platforms = {}    
    for i=1,4 do
    	local x, y = vectorFromAngle(i*90,2000,true)
    	local dp = CpuShip():setFaction("Kraylor"):setTemplate("Defense platform"):setCallSign(string.format("KDP%i",i)):setPosition(sx + x, sy + y):orderStandGround()
    	dp.focus_x = sx
    	dp.focus_y = sy
    	dp.angle = i*90
    	dp.dist = 2000
    	table.insert(orbiting_platforms,dp)
    end
    kraylor_attackers = {}
    --	aggressive Ktlitans
    station_aggressive_ktlitans = placeStation(137995, 154587,"Sinister","Ktlitans","Medium Station")
    ktlitan_defenders = {}
    table.insert(ktlitan_defenders,CpuShip():setFaction("Ktlitans"):setTemplate("Dagger"):setPosition(142014, 154615):orderDefendTarget(station_aggressive_ktlitans))
    table.insert(ktlitan_defenders,CpuShip():setFaction("Ktlitans"):setTemplate("Dagger"):setPosition(139524, 150867):orderDefendTarget(station_aggressive_ktlitans))
    table.insert(ktlitan_defenders,CpuShip():setFaction("Ktlitans"):setTemplate("Dagger"):setPosition(134867, 152057):orderDefendTarget(station_aggressive_ktlitans))
    table.insert(ktlitan_defenders,CpuShip():setFaction("Ktlitans"):setTemplate("Dagger"):setPosition(136813, 158429):orderDefendTarget(station_aggressive_ktlitans))
	sx, sy = station_aggressive_ktlitans:getPosition()
    for i=1,4 do
    	local x, y = vectorFromAngle(i*90,2000,true)
    	local dp = CpuShip():setFaction("Ktlitans"):setTemplate("Defense platform"):setCallSign(string.format("BDP%i",i)):setPosition(sx + x, sy + y):orderStandGround()
    	dp.focus_x = sx
    	dp.focus_y = sy
    	dp.angle = i*90
    	dp.dist = 2000
    	table.insert(orbiting_platforms,dp)
    end
    ktlitan_attackers = {}
	patrol_points = {station_headquarters,station_med_TSN,station_large_USN,station_huge_CUF}
	fixed_asteroids = {}
	--	field near large human navy station
	table.insert(fixed_asteroids,Asteroid():setPosition(-7524, 41263):setSize(130))
	table.insert(fixed_asteroids,Asteroid():setPosition(-5340, 39928):setSize(122))
	table.insert(fixed_asteroids,Asteroid():setPosition(-2791, 40535):setSize(111))
	table.insert(fixed_asteroids,Asteroid():setPosition(-5219, 35559):setSize(115))
	table.insert(fixed_asteroids,Asteroid():setPosition(-8010, 37016):setSize(111))
	table.insert(fixed_asteroids,Asteroid():setPosition(-7039, 34588):setSize(114))
	table.insert(fixed_asteroids,Asteroid():setPosition(-3520, 34346):setSize(112))
	table.insert(fixed_asteroids,Asteroid():setPosition(-5704, 32647):setSize(129))
	table.insert(fixed_asteroids,Asteroid():setPosition(-4976, 30098):setSize(117))
	table.insert(fixed_asteroids,Asteroid():setPosition(-4976, 30098):setSize(114))
	table.insert(fixed_asteroids,Asteroid():setPosition(-6311, 30098):setSize(128))
	table.insert(fixed_asteroids,Asteroid():setPosition(-4126, 29127):setSize(113))
	table.insert(fixed_asteroids,Asteroid():setPosition(-6675, 45026):setSize(129))
	table.insert(fixed_asteroids,Asteroid():setPosition(-5219, 42477):setSize(115))
	table.insert(fixed_asteroids,Asteroid():setPosition(-3398, 48302):setSize(120))
	table.insert(fixed_asteroids,Asteroid():setPosition(-2913, 43812):setSize(118))
	table.insert(fixed_asteroids,Asteroid():setPosition(2913, 43691):setSize(117))
	table.insert(fixed_asteroids,Asteroid():setPosition(-243, 41385):setSize(124))
	table.insert(fixed_asteroids,Asteroid():setPosition(1092, 39322):setSize(121))
	table.insert(fixed_asteroids,Asteroid():setPosition(-1456, 35802):setSize(128))
	table.insert(fixed_asteroids,Asteroid():setPosition(-364, 47331):setSize(123))
	table.insert(fixed_asteroids,Asteroid():setPosition(1942, 46482):setSize(111))
	table.insert(fixed_asteroids,Asteroid():setPosition(-1335, 44176):setSize(128))
	table.insert(fixed_asteroids,Asteroid():setPosition(-1942, 38229):setSize(114))
	table.insert(fixed_asteroids,Asteroid():setPosition(-3398, 37622):setSize(111))
	table.insert(fixed_asteroids,Asteroid():setPosition(243, 34346):setSize(116))
	table.insert(fixed_asteroids,Asteroid():setPosition(-1214, 32282):setSize(114))
	table.insert(fixed_asteroids,Asteroid():setPosition(-3277, 31312):setSize(114))
	table.insert(fixed_asteroids,Asteroid():setPosition(-1092, 29370):setSize(122))
	table.insert(fixed_asteroids,Asteroid():setPosition(-121, 27428):setSize(129))
	table.insert(fixed_asteroids,Asteroid():setPosition(-243, 24879):setSize(130))
	table.insert(fixed_asteroids,Asteroid():setPosition(-2185, 25972):setSize(124))
	table.insert(fixed_asteroids,Asteroid():setPosition(-2670, 28278):setSize(116))
	table.insert(fixed_asteroids,Asteroid():setPosition(-3884, 27428):setSize(115))
	table.insert(fixed_asteroids,Asteroid():setPosition(-5219, 27185):setSize(112))
	table.insert(fixed_asteroids,Asteroid():setPosition(-6432, 27428):setSize(121))
	table.insert(fixed_asteroids,Asteroid():setPosition(-8253, 24151):setSize(127))
	table.insert(fixed_asteroids,Asteroid():setPosition(-7403, 25365):setSize(115))
	table.insert(fixed_asteroids,Asteroid():setPosition(-4369, 22695):setSize(127))
	table.insert(fixed_asteroids,Asteroid():setPosition(-4733, 25850):setSize(111))
	table.insert(fixed_asteroids,Asteroid():setPosition(-2549, 23787):setSize(117))
	table.insert(fixed_asteroids,Asteroid():setPosition(-2670, 21967):setSize(113))
	table.insert(fixed_asteroids,Asteroid():setPosition(-5340, 24394):setSize(125))
	table.insert(fixed_asteroids,Asteroid():setPosition(-4369, 23908):setSize(128))
	table.insert(fixed_asteroids,Asteroid():setPosition(-8131, 20753):setSize(113))
	table.insert(fixed_asteroids,Asteroid():setPosition(-7646, 19418):setSize(113))
	table.insert(fixed_asteroids,Asteroid():setPosition(-7282, 23059):setSize(119))
	table.insert(fixed_asteroids,Asteroid():setPosition(-6311, 22452):setSize(116))
	table.insert(fixed_asteroids,Asteroid():setPosition(-6190, 20389):setSize(124))
	table.insert(fixed_asteroids,Asteroid():setPosition(-4126, 14078):setSize(125))
	table.insert(fixed_asteroids,Asteroid():setPosition(-5340, 13957):setSize(119))
	table.insert(fixed_asteroids,Asteroid():setPosition(-2549, 14442):setSize(112))
	table.insert(fixed_asteroids,Asteroid():setPosition(-4248, 15413):setSize(127))
	table.insert(fixed_asteroids,Asteroid():setPosition(-3641, 19661):setSize(118))
	table.insert(fixed_asteroids,Asteroid():setPosition(-5219, 19297):setSize(119))
	table.insert(fixed_asteroids,Asteroid():setPosition(-5219, 17719):setSize(112))
	table.insert(fixed_asteroids,Asteroid():setPosition(-6554, 18690):setSize(124))
	table.insert(fixed_asteroids,Asteroid():setPosition(-8738, 18447):setSize(120))
	table.insert(fixed_asteroids,Asteroid():setPosition(-2427, 18447):setSize(114))
	table.insert(fixed_asteroids,Asteroid():setPosition(-8495, 16020):setSize(123))
	table.insert(fixed_asteroids,Asteroid():setPosition(-7889, 15292):setSize(116))
	table.insert(fixed_asteroids,Asteroid():setPosition(-6796, 16869):setSize(117))
	table.insert(fixed_asteroids,Asteroid():setPosition(-8010, 17598):setSize(117))
	table.insert(fixed_asteroids,Asteroid():setPosition(-5219, 15292):setSize(111))
	table.insert(fixed_asteroids,Asteroid():setPosition(-5219, 16748):setSize(114))
	table.insert(fixed_asteroids,Asteroid():setPosition(-6675, 14564):setSize(110))
	table.insert(fixed_asteroids,Asteroid():setPosition(-6432, 15656):setSize(129))
	table.insert(fixed_asteroids,Asteroid():setPosition(-1942, 17234):setSize(114))
	table.insert(fixed_asteroids,Asteroid():setPosition(-1214, 17962):setSize(111))
	table.insert(fixed_asteroids,Asteroid():setPosition(-4005, 16627):setSize(120))
	table.insert(fixed_asteroids,Asteroid():setPosition(-3884, 18326):setSize(114))
	table.insert(fixed_asteroids,Asteroid():setPosition(-2913, 15170):setSize(125))
	table.insert(fixed_asteroids,Asteroid():setPosition(-2063, 15899):setSize(129))
	table.insert(fixed_asteroids,Asteroid():setPosition(-1092, 16991):setSize(128))
	table.insert(fixed_asteroids,Asteroid():setPosition(-2791, 16748):setSize(126))
	table.insert(fixed_asteroids,Asteroid():setPosition(-1092, 21724):setSize(126))
	table.insert(fixed_asteroids,Asteroid():setPosition(-4490, 21238):setSize(130))
	table.insert(fixed_asteroids,Asteroid():setPosition(-243, 19297):setSize(123))
	table.insert(fixed_asteroids,Asteroid():setPosition(-1335, 19175):setSize(116))
	table.insert(fixed_asteroids,Asteroid():setPosition(-2670, 20510):setSize(119))
	table.insert(fixed_asteroids,Asteroid():setPosition(-1214, 20510):setSize(124))
    --	field near medium TSN station
    table.insert(fixed_asteroids,Asteroid():setPosition(66352, -4948):setSize(52))
    table.insert(fixed_asteroids,Asteroid():setPosition(67391, -5779):setSize(39))
    table.insert(fixed_asteroids,Asteroid():setPosition(66352, -6194):setSize(119))
    table.insert(fixed_asteroids,Asteroid():setPosition(67114, -7025):setSize(50))
    table.insert(fixed_asteroids,Asteroid():setPosition(67183, -7995):setSize(118))
    table.insert(fixed_asteroids,Asteroid():setPosition(65383, -8341):setSize(67))
    table.insert(fixed_asteroids,Asteroid():setPosition(66214, -7925):setSize(110))
    table.insert(fixed_asteroids,Asteroid():setPosition(60149, -9820):setSize(125))
    table.insert(fixed_asteroids,Asteroid():setPosition(60258, -4948):setSize(116))
    table.insert(fixed_asteroids,Asteroid():setPosition(60439, -7069):setSize(114))
    table.insert(fixed_asteroids,Asteroid():setPosition(64898, -3978):setSize(25))
    table.insert(fixed_asteroids,Asteroid():setPosition(63305, -3632):setSize(116))
    table.insert(fixed_asteroids,Asteroid():setPosition(61713, -3840):setSize(128))
    table.insert(fixed_asteroids,Asteroid():setPosition(63624, -6635):setSize(126))
    table.insert(fixed_asteroids,Asteroid():setPosition(61990, -6194):setSize(89))
    table.insert(fixed_asteroids,Asteroid():setPosition(63582, -8064):setSize(21))
    table.insert(fixed_asteroids,Asteroid():setPosition(64829, -6956):setSize(124))
    table.insert(fixed_asteroids,Asteroid():setPosition(63651, -5156):setSize(125))
    table.insert(fixed_asteroids,Asteroid():setPosition(64898, -5502):setSize(58))
    table.insert(fixed_asteroids,Asteroid():setPosition(63028, -12080):setSize(121))
    table.insert(fixed_asteroids,Asteroid():setPosition(61163, -12137):setSize(116))
    table.insert(fixed_asteroids,Asteroid():setPosition(61920, -10626):setSize(111))
    table.insert(fixed_asteroids,Asteroid():setPosition(63045, -13729):setSize(119))
    table.insert(fixed_asteroids,Asteroid():setPosition(58412, -8662):setSize(128))
    table.insert(fixed_asteroids,Asteroid():setPosition(64203, -9386):setSize(111))
    table.insert(fixed_asteroids,Asteroid():setPosition(62176, -8807):setSize(115))
    table.insert(fixed_asteroids,Asteroid():setPosition(66352, -9103):setSize(126))
    table.insert(fixed_asteroids,Asteroid():setPosition(65590, -11180):setSize(121))
    table.insert(fixed_asteroids,Asteroid():setPosition(66375, -12426):setSize(125))
    table.insert(fixed_asteroids,Asteroid():setPosition(64759, -12496):setSize(125))
    table.insert(fixed_asteroids,Asteroid():setPosition(64058, -11123):setSize(110))
    table.insert(fixed_asteroids,Asteroid():setPosition(62176, -16480):setSize(118))
    table.insert(fixed_asteroids,Asteroid():setPosition(58991, -19086):setSize(118))
    table.insert(fixed_asteroids,Asteroid():setPosition(52331, -7359):setSize(182))
    table.insert(fixed_asteroids,Asteroid():setPosition(47843, -16769):setSize(220))
    table.insert(fixed_asteroids,Asteroid():setPosition(50884, -11558):setSize(257))
    table.insert(fixed_asteroids,Asteroid():setPosition(47409, -14163):setSize(405))
    table.insert(fixed_asteroids,Asteroid():setPosition(42342, -17783):setSize(352))
    table.insert(fixed_asteroids,Asteroid():setPosition(50015, -14743):setSize(288))
    table.insert(fixed_asteroids,Asteroid():setPosition(45237, -12571):setSize(330))
    table.insert(fixed_asteroids,Asteroid():setPosition(57696, -3909):setSize(114))
    table.insert(fixed_asteroids,Asteroid():setPosition(58267, -5767):setSize(129))
    table.insert(fixed_asteroids,Asteroid():setPosition(55806, -4319):setSize(125))
    table.insert(fixed_asteroids,Asteroid():setPosition(56530, -7214):setSize(125))
    table.insert(fixed_asteroids,Asteroid():setPosition(55951, -11413):setSize(153))
    table.insert(fixed_asteroids,Asteroid():setPosition(56675, -14308):setSize(213))
    table.insert(fixed_asteroids,Asteroid():setPosition(53345, -13440):setSize(301))
    table.insert(fixed_asteroids,Asteroid():setPosition(56096, -17059):setSize(620))
    table.insert(fixed_asteroids,Asteroid():setPosition(52187, -16480):setSize(376))
    table.insert(fixed_asteroids,Asteroid():setPosition(44369, -15756):setSize(326))
    table.insert(fixed_asteroids,Asteroid():setPosition(59635, -3286):setSize(89))
    table.insert(fixed_asteroids,Asteroid():setPosition(59860, -14163):setSize(121))
    table.insert(fixed_asteroids,Asteroid():setPosition(59281, -11702):setSize(113))
    table.insert(fixed_asteroids,Asteroid():setPosition(47843, -22271):setSize(710))
    table.insert(fixed_asteroids,Asteroid():setPosition(45672, -19231):setSize(383))
    table.insert(fixed_asteroids,Asteroid():setPosition(49581, -19810):setSize(476))
    table.insert(fixed_asteroids,Asteroid():setPosition(53055, -19375):setSize(407))
    table.insert(fixed_asteroids,Asteroid():setPosition(55661, -21257):setSize(118))
    table.insert(fixed_asteroids,Asteroid():setPosition(52476, -22995):setSize(500))
    table.insert(fixed_asteroids,Asteroid():setPosition(53490, -10544):setSize(128))
    table.insert(fixed_asteroids,Asteroid():setPosition(48712, -9820):setSize(117))
    --	field between CUF and USN stations
	table.insert(fixed_asteroids,Asteroid():setPosition(71094, 26302):setSize(122))
	table.insert(fixed_asteroids,Asteroid():setPosition(69010, 29427):setSize(124))
	table.insert(fixed_asteroids,Asteroid():setPosition(72396, 28906):setSize(111))
	table.insert(fixed_asteroids,Asteroid():setPosition(78385, 46615):setSize(114))
	table.insert(fixed_asteroids,Asteroid():setPosition(80208, 42188):setSize(115))
	table.insert(fixed_asteroids,Asteroid():setPosition(68490, 45833):setSize(124))
	table.insert(fixed_asteroids,Asteroid():setPosition(72396, 44792):setSize(116))
	table.insert(fixed_asteroids,Asteroid():setPosition(70052, 39323):setSize(116))
	table.insert(fixed_asteroids,Asteroid():setPosition(63281, 31250):setSize(118))
	table.insert(fixed_asteroids,Asteroid():setPosition(66667, 37240):setSize(123))
	table.insert(fixed_asteroids,Asteroid():setPosition(68229, 34635):setSize(119))
	table.insert(fixed_asteroids,Asteroid():setPosition(64323, 40104):setSize(122))
	table.insert(fixed_asteroids,Asteroid():setPosition(53646, 48958):setSize(129))
	table.insert(fixed_asteroids,Asteroid():setPosition(61979, 49479):setSize(129))
	table.insert(fixed_asteroids,Asteroid():setPosition(43490, 58594):setSize(126))
	table.insert(fixed_asteroids,Asteroid():setPosition(46875, 59896):setSize(124))
	table.insert(fixed_asteroids,Asteroid():setPosition(47656, 51823):setSize(113))
	table.insert(fixed_asteroids,Asteroid():setPosition(63021, 59115):setSize(127))
	table.insert(fixed_asteroids,Asteroid():setPosition(46615, 44010):setSize(130))
	table.insert(fixed_asteroids,Asteroid():setPosition(54948, 45573):setSize(119))
	table.insert(fixed_asteroids,Asteroid():setPosition(61979, 42188):setSize(118))
	table.insert(fixed_asteroids,Asteroid():setPosition(65104, 53385):setSize(129))
	table.insert(fixed_asteroids,Asteroid():setPosition(62500, 55729):setSize(122))
	table.insert(fixed_asteroids,Asteroid():setPosition(21094, 39323):setSize(129))
	table.insert(fixed_asteroids,Asteroid():setPosition(35677, 50781):setSize(120))
	table.insert(fixed_asteroids,Asteroid():setPosition(35156, 47656):setSize(116))
	table.insert(fixed_asteroids,Asteroid():setPosition(25000, 44531):setSize(127))
	table.insert(fixed_asteroids,Asteroid():setPosition(30469, 47396):setSize(127))
	table.insert(fixed_asteroids,Asteroid():setPosition(41406, 51823):setSize(127))
	table.insert(fixed_asteroids,Asteroid():setPosition(58333, 47656):setSize(122))
	table.insert(fixed_asteroids,Asteroid():setPosition(60156, 30469):setSize(118))
	table.insert(fixed_asteroids,Asteroid():setPosition(18490, 41146):setSize(117))
	table.insert(fixed_asteroids,Asteroid():setPosition(18490, 41146):setSize(116))
	local scan_tiers = {	--complex = bars, depth = windows
		{complex = 1,	depth = 1},
		{complex = 2,	depth = 1},
		{complex = 3,	depth = 1},
		{complex = 1,	depth = 2},
		{complex = 2,	depth = 2},
		{complex = 1,	depth = 3},
	}
	research_asteroids = {}
	for i,a in ipairs(fixed_asteroids) do
		table.insert(research_asteroids,a)
		local unscanned_description = ""
		if random(0,100) < 65 then
			unscanned_description = _("scienceDescription-asteroid", "Structure: solid")
			a.structure = "solid"
		elseif random(0,100) < 70 then
			unscanned_description = _("scienceDescription-asteroid", "Structure: rubble")
			a.structure = "rubble"
		else
			unscanned_description = _("scienceDescription-asteroid", "Structure: binary")
			a.structure = "binary"
		end
		local bits = {
			{name = "osmium",		presence = 2},
			{name = "ruthenium",	presence = 3},
			{name = "rhodium",		presence = 4},
			{name = "magnesium",	presence = 5},
			{name = "platinum",		presence = 6},
			{name = "iridium",		presence = 7},
			{name = "gold",			presence = 8},
			{name = "palladium",	presence = 9},
			{name = "oxygen",		presence = 10},
			{name = "silicon",		presence = 11},
			{name = "hydrogen",		presence = 12},
			{name = "nitrogen",		presence = 13},
			{name = "pyroxene",		presence = 14},
			{name = "olivine",		presence = 15},
			{name = "cobalt",		presence = 16},
			{name = "dilithium",	presence = 17},
			{name = "nickel",		presence = 18},
			{name = "iron",			presence = 19},
		}
		local scanned_description = unscanned_description
		a.composition = 0
		for j,bit in ipairs(bits) do
			if random(0,100) < bit.presence and a.composition < 100 then
				local component = bit.name
				local upper = bit.presence
				a[component] = math.random(1,upper*10)/10
				a.composition = a.composition + a[component]
				if a.composition >= 100 then
					scanned_description = string.format("%s\n%s:remainder",scanned_description,component)
					break
				else
					scanned_description = string.format("%s\n%s:%.1f%%",scanned_description,component,a[component])
				end
			end
		end
		if a.composition > 0 then
			if a.composition < 100 then
				scanned_description = string.format("%s\nrock:remainder",scanned_description)
			end
		else
			scanned_description = string.format("%s\njust rock",scanned_description)
		end
		target_asteroid_notes = {
			["osmium"] = math.random(1,20)/10,
			["iridium"] = math.random(1,70)/10,
			["olivine"] = math.random(1,150)/10,
			["iron"] = math.random(1,190)/10,
		}
    	a:setDescriptions(unscanned_description,scanned_description)
    	local tier = tableSelectRandom(scan_tiers)
    	a:setScanningParameters(tier.complex,tier.depth)
	end
	--	field forming ghost eye
	table.insert(fixed_asteroids,Asteroid():setPosition(-98727, -85777):setSize(50))
	table.insert(fixed_asteroids,Asteroid():setPosition(-99202, -83559):setSize(119))
	table.insert(fixed_asteroids,Asteroid():setPosition(-92549, -81658):setSize(500))
	table.insert(fixed_asteroids,Asteroid():setPosition(-96566, -81355):setSize(113))
	table.insert(fixed_asteroids,Asteroid():setPosition(-78132, -94174):setSize(41))
	table.insert(fixed_asteroids,Asteroid():setPosition(-76789, -95979):setSize(117))
	table.insert(fixed_asteroids,Asteroid():setPosition(-80508, -97184):setSize(30))
	table.insert(fixed_asteroids,Asteroid():setPosition(-80983, -94491):setSize(122))
	table.insert(fixed_asteroids,Asteroid():setPosition(-80123, -91888):setSize(76))
	table.insert(fixed_asteroids,Asteroid():setPosition(-82568, -87045):setSize(126))
	table.insert(fixed_asteroids,Asteroid():setPosition(-77656, -89738):setSize(92))
	table.insert(fixed_asteroids,Asteroid():setPosition(-79874, -87837):setSize(113))
	table.insert(fixed_asteroids,Asteroid():setPosition(-74963, -92590):setSize(111))
	table.insert(fixed_asteroids,Asteroid():setPosition(-89538, -81500):setSize(121))
	table.insert(fixed_asteroids,Asteroid():setPosition(-80350, -90055):setSize(129))
	table.insert(fixed_asteroids,Asteroid():setPosition(-75728, -90524):setSize(120))
	table.insert(fixed_asteroids,Asteroid():setPosition(-78132, -91956):setSize(112))
	table.insert(fixed_asteroids,Asteroid():setPosition(-96034, -83718):setSize(153))
	table.insert(fixed_asteroids,Asteroid():setPosition(-88905, -82609):setSize(121))
	table.insert(fixed_asteroids,Asteroid():setPosition(-90543, -85459):setSize(129))
	table.insert(fixed_asteroids,Asteroid():setPosition(-93611, -83401):setSize(120))
	table.insert(fixed_asteroids,Asteroid():setPosition(-82884, -91798):setSize(127))
	table.insert(fixed_asteroids,Asteroid():setPosition(-86370, -84510):setSize(118))
	table.insert(fixed_asteroids,Asteroid():setPosition(-101737, -100036):setSize(126))
	table.insert(fixed_asteroids,Asteroid():setPosition(-100311, -96709):setSize(113))
	table.insert(fixed_asteroids,Asteroid():setPosition(-98569, -98135):setSize(115))
	table.insert(fixed_asteroids,Asteroid():setPosition(-98429, -92694):setSize(175))
	table.insert(fixed_asteroids,Asteroid():setPosition(-99486, -94239):setSize(113))
	table.insert(fixed_asteroids,Asteroid():setPosition(-101643, -95146):setSize(580))
	table.insert(fixed_asteroids,Asteroid():setPosition(-98185, -95540):setSize(118))
	table.insert(fixed_asteroids,Asteroid():setPosition(-100543, -92125):setSize(118))
	table.insert(fixed_asteroids,Asteroid():setPosition(-106490, -96234):setSize(61))
	table.insert(fixed_asteroids,Asteroid():setPosition(-103480, -96709):setSize(113))
	table.insert(fixed_asteroids,Asteroid():setPosition(-103638, -91639):setSize(620))
	table.insert(fixed_asteroids,Asteroid():setPosition(-102529, -93857):setSize(128))
	table.insert(fixed_asteroids,Asteroid():setPosition(-111718, -93540):setSize(28))
	table.insert(fixed_asteroids,Asteroid():setPosition(-109183, -92907):setSize(34))
	table.insert(fixed_asteroids,Asteroid():setPosition(-106490, -93699):setSize(122))
	table.insert(fixed_asteroids,Asteroid():setPosition(-105064, -89263):setSize(112))
	table.insert(fixed_asteroids,Asteroid():setPosition(-107758, -90213):setSize(125))
	table.insert(fixed_asteroids,Asteroid():setPosition(-96966, -87572):setSize(242))
	table.insert(fixed_asteroids,Asteroid():setPosition(-98917, -89280):setSize(111))
	table.insert(fixed_asteroids,Asteroid():setPosition(-99995, -87203):setSize(129))
	table.insert(fixed_asteroids,Asteroid():setPosition(-100218, -89767):setSize(120))
	table.insert(fixed_asteroids,Asteroid():setPosition(-102529, -87679):setSize(730))
	table.insert(fixed_asteroids,Asteroid():setPosition(-102477, -85447):setSize(113))
	table.insert(fixed_asteroids,Asteroid():setPosition(-101844, -90499):setSize(129))
	table.insert(fixed_asteroids,Asteroid():setPosition(-96641, -96352):setSize(251))
	table.insert(fixed_asteroids,Asteroid():setPosition(-98727, -100670):setSize(850))
	table.insert(fixed_asteroids,Asteroid():setPosition(-97777, -102888):setSize(125))
	table.insert(fixed_asteroids,Asteroid():setPosition(-92865, -101145):setSize(128))
	table.insert(fixed_asteroids,Asteroid():setPosition(-94450, -102888):setSize(124))
	table.insert(fixed_asteroids,Asteroid():setPosition(-94039, -85784):setSize(125))
	table.insert(fixed_asteroids,Asteroid():setPosition(-90489, -102412):setSize(114))
	table.insert(fixed_asteroids,Asteroid():setPosition(-91031, -99442):setSize(112))
	table.insert(fixed_asteroids,Asteroid():setPosition(-96192, -99244):setSize(128))
	table.insert(fixed_asteroids,Asteroid():setPosition(-93714, -98466):setSize(121))
	table.insert(fixed_asteroids,Asteroid():setPosition(-88113, -100511):setSize(114))
	table.insert(fixed_asteroids,Asteroid():setPosition(-85895, -101937):setSize(117))
	table.insert(fixed_asteroids,Asteroid():setPosition(-82092, -99402):setSize(118))
	table.insert(fixed_asteroids,Asteroid():setPosition(-83835, -98610):setSize(112))
	table.insert(fixed_asteroids,Asteroid():setPosition(-84944, -94174):setSize(405))
	table.insert(fixed_asteroids,Asteroid():setPosition(-84608, -89361):setSize(438))
	table.insert(fixed_asteroids,Asteroid():setPosition(-86560, -87003):setSize(496))
	table.insert(fixed_asteroids,Asteroid():setPosition(-89080, -97572):setSize(348))
	table.insert(fixed_asteroids,Asteroid():setPosition(-85261, -97026):setSize(120))
	for i,ast in ipairs(fixed_asteroids) do
		local asteroid_size = ast:getSize()
		local tx, ty = ast:getPosition()
		local tether = random(asteroid_size + 10,800)
		local v_angle = random(0,360)
		local vx, vy = vectorFromAngle(v_angle,tether,true)
		vx = vx + tx
		vy = vy + ty
		VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
--		if vx > -20000 and vx < 0 and vy > -20000 and vy < 0 then
--			print("visual asteroid 1 near player spawn:",vx,vy)
--		end
		tether = random(asteroid_size + 10, asteroid_size + 800)
		v_angle = (v_angle + random(120,240)) % 360
		vx, vy = vectorFromAngle(v_angle,tether,true)
		vx = vx + tx
		vy = vy + ty
		VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
--		if vx > -20000 and vx < 0 and vy > -20000 and vy < 0 then
--			print("visual asteroid 2 near player spawn:",vx,vy)
--		end
	end
    fixed_nebulae = {}
	table.insert(fixed_nebulae,Nebula():setPosition(69271, 36458))
	table.insert(fixed_nebulae,Nebula():setPosition(70313, 27865))
	table.insert(fixed_nebulae,Nebula():setPosition(79167, 44010))
	table.insert(fixed_nebulae,Nebula():setPosition(70313, 45573))
	table.insert(fixed_nebulae,Nebula():setPosition(62500, 32552))
	table.insert(fixed_nebulae,Nebula():setPosition(47135, 43750))
	table.insert(fixed_nebulae,Nebula():setPosition(54948, 47396))
	table.insert(fixed_nebulae,Nebula():setPosition(62760, 56771))
	table.insert(fixed_nebulae,Nebula():setPosition(34635, 48958))
	anomalous_nebulae = {}
	nebula_pool = {}
	for i,n in ipairs(fixed_nebulae) do
		table.insert(nebula_pool,n)
	end
	local anomalous_nebula_types = {
		"-C",	--lose coolant
		"+C",	--gain coolant
		"-BR",	--lose beam range
		"+BR",	--gain beam range
		"-SC",	--lose shield charge
		"+SC",	--gain shield charge
	}
	for i,name in ipairs(anomalous_nebula_types) do
		local neb = tableRemoveRandom(nebula_pool)
		neb.name = name
		if name == "-SC" then
			local sl = tableSelectRandom(shield_losses)
			neb.shield_loss = sl.val
			neb.scanned_desc = sl.desc
		elseif name == "+SC" then
			local sg = tableSelectRandom(shield_gains)
			neb.shield_gain = sg.val
			neb.scanned_desc = sg.desc
		elseif name == "-BR" then
			local bl = tableSelectRandom(beam_range_losses)
			neb.beam_range_loss = bl.val
			neb.scanned_desc = bl.desc
		elseif name == "+BR" then
			local bg = tableSelectRandom(beam_range_gains)
			neb.beam_range_gain = bg.val
			neb.scanned_desc = bg.desc
		elseif name == "-C" then
			local cl = tableSelectRandom(coolant_losses)
			neb.coolant_loss = cl.val
			neb.scanned_desc = cl.desc
		elseif name == "+C" then
			local cg = tableSelectRandom(coolant_gains)
			neb.coolant_gain = cg.val
			neb.scanned_desc = cg.desc
		end
		neb:setDescriptions("Anomalous nebula",neb.scanned_desc)
    	local tier = tableSelectRandom(scan_tiers)
    	neb:setScanningParameters(tier.complex,tier.depth)
		table.insert(anomalous_nebulae,neb)
	end
	table.insert(fixed_nebulae,Nebula():setPosition(45313, 58333))	--Kraylor
	table.insert(fixed_nebulae,Nebula():setPosition(61979, 41667))	--Bug
	table.insert(fixed_nebulae,Nebula():setPosition(19531, 40885))	--USN
	table.insert(fixed_nebulae,Nebula():setPosition(76823, 21615))	--CUF
	--	link to expanse area
	expanse_angle = random(90,180)
	expanse_x, expanse_y = vectorFromAngle(expanse_angle,random(300000,600000),true)
--	print("Expanse:",getSectorName(expanse_x,expanse_y))
    wormhole_to_expanse = WormHole():setPosition(5508, 37012):setTargetPosition(expanse_x,expanse_y)
    wormhole_to_expanse:onTeleportation(expanseWormholeTax)
end
function expanseWormholeTax(self,transportee)
	if isObjectType(transportee,"CpuShip") then
		for i,system in ipairs(system_types) do
			if transportee:hasSystem(system) then
				transportee:setSystemHealth(system,random(-.2,.2))
			end
		end
	elseif isObjectType(transportee,"PlayerSpaceship") then
		if transportee.wormhole_guide then
			if transportee:getShieldsActive() then
				transportee:setEnergy(transportee:getEnergy()*.75)
			else
				transportee:setEnergy(transportee:getEnergy()*.5)
			end
		else
			if transportee:getShieldsActive() then
				transportee:setEnergy(transportee:getEnergy()*.3)
				for i,system in ipairs(system_types) do
					if transportee:hasSystem(system) then
						transportee:setSystemHealth(system,random(-.2,.2))
					end
				end
			else
				transportee:setEnergy(transportee:getEnergy()*.15)
				for i,system in ipairs(system_types) do
					if transportee:hasSystem(system) then
						transportee:setSystemHealth(system,random(-.8,-.3))
					end
				end
			end
		end
	end
end
function constructDynamicArea()
	expansion_space = {}
	for i=0,270,90 do
		wx, wy = vectorFromAngle(i,5500,true)
		local wj = WarpJammer():setPosition(expanse_x + wx, expanse_y + wy):setRange(10000):setFaction("Exuari")
		table.insert(expansion_space,{obj=wj,shape="circle",dist=6000})
	end
	expansion_stations = {}
	local es_x, es_y = vectorFromAngle(expanse_angle,25000,true)
	station_expanse_e_far = placeStation(expanse_x + es_x, expanse_y + es_y,"Sinister","Exuari")
	table.insert(expansion_space,{obj=station_expanse_e_far,shape="circle",dist=4000})
	table.insert(self_defending_stations,station_expanse_e_far)
	for i=0,270,90 do
		dpx, dpy = vectorFromAngle(i,3000,true)
		local dp = CpuShip():setTemplate("Defense platform"):setPosition(expanse_x + es_x + dpx, expanse_y + es_y + dpy):setFaction("Exuari"):orderStandGround()
		dp.angle = i
		dp.dist = 3000
		dp.focus_x = expanse_x + es_x
		dp.focus_y = expanse_y + es_y
		table.insert(orbiting_platforms,dp)
	end
	table.insert(expansion_stations,station_expanse_e_far)
	es_x, es_y = vectorFromAngle(expanse_angle,-25000,true)
	station_expanse_e_near = placeStation(expanse_x + es_x, expanse_y + es_y,"Sinister","Exuari")
	table.insert(expansion_space,{obj=station_expanse_e_near,shape="circle",dist=4000})
	table.insert(self_defending_stations,station_expanse_e_near)
	for i=0,270,90 do
		dpx, dpy = vectorFromAngle(i,3000,true)
		local dp = CpuShip():setTemplate("Defense platform"):setPosition(expanse_x + es_x + dpx, expanse_y + es_y + dpy):setFaction("Exuari"):orderStandGround()
		dp.angle = i
		dp.dist = 3000
		dp.focus_x = expanse_x + es_x
		dp.focus_y = expanse_y + es_y
		table.insert(orbiting_platforms,dp)
	end
	local faction_leg = {
		"Ghosts",
		"TSN",
		"Independent",
		"Human Navy",
		"Arlenians",
	}
	local slat_x = expanse_x
	local slat_y = expanse_y
	tpa = Artifact():setFaction("Human Navy")	--temporary player artifact
	tsa = Artifact()	--temporary station artifact
	for i,faction in ipairs(faction_leg) do
		local psx, psy = findClearSpot(expansion_space,"rectangle",slat_x,slat_y,50000,40000,expanse_angle + 90,12000,true)
		tsa:setFaction(faction)
		local named_group = "RandomHumanNeutral"
		if tpa:isEnemy(tsa) then
			named_group = "Sinister"
		end
		if psx ~= nil then
			local placed_station = placeStation(psx,psy,named_group,faction)
			if placed_station ~= nil then
				station_type = placed_station:getTypeName()
				table.insert(expansion_space,{obj=placed_station,dist=station_spacing[station_type].touch,shape="circle"})
				table.insert(expansion_stations,placed_station)
				table.insert(self_defending_stations,placed_station)
				if faction == "Human Navy" then
					station_research_delivery = placed_station
				end
			end
		end
		psx, psy = vectorFromAngle(expanse_angle + 90,40000,true)
		slat_x = slat_x + psx
		slat_y = slat_y + psy
	end
	faction_leg = {
		"Ghosts",
		"Kraylor",
		"USN",
		"CUF",
		"Ktlitans",
	}
	slat_x = expanse_x
	slat_y = expanse_y
	for i,faction in ipairs(faction_leg) do
		local psx, psy = findClearSpot(expansion_space,"rectangle",slat_x,slat_y,50000,40000,expanse_angle - 90,12000,true)
		tsa:setFaction(faction)
		local named_group = "RandomHumanNeutral"
		if tpa:isEnemy(tsa) then
			named_group = "Sinister"
		end
		if psx ~= nil then
			local placed_station = placeStation(psx,psy,named_group,faction)
			if placed_station ~= nil then
				station_type = placed_station:getTypeName()
				table.insert(expansion_space,{obj=placed_station,dist=station_spacing[station_type].touch,shape="circle"})
				table.insert(expansion_stations,placed_station)
				table.insert(self_defending_stations,placed_station)
			end
		end
		psx, psy = vectorFromAngle(expanse_angle - 90,40000,true)
		slat_x = slat_x + psx
		slat_y = slat_y + psy
	end
	tpa:destroy()
	tsa:destroy()
	transport_list = {}
	placement_areas = {
		["Expansion Strip"] = {
			stations = expansion_stations,
			transports = expansion_transports,
			space = expansion_space,
			shape = "central rectangle",
			center_x = expanse_x,
			center_y = expanse_y,
			width = 400000,
			height = 50000,
			angle = expanse_angle + 90,
			transport_pool = strip_transports,
		}
	}
	local terrain = {
		{chance = 4,	count = 0,	max = math.random(1,2),		func = placeStar,			desc = "Star",				},	--2
		{chance = 4,	count = 0,	max = math.random(1,2),		func = placeBlackHole,		desc = "Black hole",		},	--2
		{chance = 7,	count = 0,	max = -1,					func = placeProbe,			desc = "Probe",				},	--3
		{chance = 4,	count = 0,	max = math.random(7,15),	func = placeWarpJammer,		desc = "Warp jammer",		},	--4
		{chance = 7,	count = 0,	max = math.random(6,15),	func = placeSensorJammer,	desc = "Sensor jammer",		},	--6
		{chance = 7,	count = 0,	max = -1,					func = placeSensorBuoy,		desc = "Sensor buoy",		},	--7
		{chance = 8,	count = 0,	max = -1,					func = placeAdBuoy,			desc = "Ad buoy",			},	--8
		{chance = 7,	count = 0,	max = -1,					func = placeNebula,			desc = "Nebula",			},	--9
		{chance = 5,	count = 0,	max = -1,					func = placeMine,			desc = "Mine",				},	--10
		{chance = 5,	count = 0,	max = math.random(3,9),		func = placeMineField,		desc = "Mine field",		},	--11
		{chance = 9,	count = 0,	max = 10,					func = placeTransport,		desc = "Transport",			},	--13
		{chance = 6,	count = 0,	max = math.random(2,7),		func = placeAsteroidField,	desc = "Asteroid field",	},	--12
		{chance = 7,	count = 0,	max = math.random(2,7),		func = placeAsteroidBlob,	desc = "Asteroid blob",		},	--14
		{chance = 7,	count = 0,	max = math.random(2,7),		func = placeMinefieldBlob,	desc = "Minefield blob",	},	--15
	}
	local objects_placed_count = 0
	repeat
		local roll = random(0,100)
		local object_chance = 0
		for i,terrain_object in ipairs(terrain) do
			object_chance = object_chance + terrain_object.chance
			if roll <= object_chance then
				if terrain_object.max < 0 or terrain_object.count < terrain_object.max then
					local call_function = terrain_object.func
					local placement_result = call_function("Expansion Strip")
					if placement_result then
						terrain_object.count = terrain_object.count + 1
					end
				else
					placeAsteroid("Expansion Strip")
				end
				break
			elseif i == #terrain then
				placeAsteroid("Expansion Strip")
			end
		end
		objects_placed_count = objects_placed_count + 1
	until(objects_placed_count >= 400 and #transport_list >= 10)
end
--	Construct environment utilities
function findClearSpot(objects,area_shape,area_point_x,area_point_y,area_distance,area_distance_2,area_angle,new_buffer,placing_station)
	--area distance 2 is only required for torus areas and rectangle areas
	--area angle is only required for rectangle areas
	assert(type(objects)=="table",string.format("function findClearSpot expects an object list table as the first parameter, but got a %s instead",type(objects)))
	assert(type(area_shape)=="string",string.format("function findClearSpot expects an area shape string as the second parameter, but got a %s instead",type(area_shape)))
	assert(type(area_point_x)=="number",string.format("function findClearSpot expects an area point X coordinate number as the third parameter, but got a %s instead",type(area_point_x)))
	assert(type(area_point_y)=="number",string.format("function findClearSpot expects an area point Y coordinate number as the fourth parameter, but got a %s instead",type(area_point_y)))
	assert(type(area_distance)=="number",string.format("function findClearSpot expects an area distance number as the fifth parameter, but got a %s instead",type(area_distance)))
	local valid_shapes = {"circle","torus","rectangle"}
	assert(valid_shapes[area_shape] == nil,string.format("function findClearSpot expects a valid shape in the second parameter, but got %s instead",area_shape))
	assert(type(new_buffer)=="number",string.format("function findClearSpot expects a new item buffer distance number as the eighth parameter, but got a %s instead",type(new_buffer)))
	local valid_table_item_shapes = {"circle","zone"}
	local far_enough = true
	local current_loop_count = 0
	local cx, cy = 0	--candidate x and y coordinates
	if area_shape == "circle" then
		repeat
			current_loop_count = current_loop_count + 1
			cx, cy = vectorFromAngle(random(0,360),random(0,area_distance),true)
			cx = cx + area_point_x
			cy = cy + area_point_y
			far_enough = true
			for i,item in ipairs(objects) do
				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil and placing_station and isObjectType(item.obj,"SpaceStation") then
						comparison_dist = 12000
					end
					if distance(cx,cy,ix,iy) < (comparison_dist + new_buffer) then
						far_enough = false
						break
					end
				end
				if item.shape == "zone" then
					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ta = Artifact():setPosition(cx,cy)
					if item.obj:isInside(ta) then
						far_enough = false
					end
					ta:destroy()
					if not far_enough then
						break
					end
				end
			end
		until(far_enough or current_loop_count > max_repeat_loop)
		if current_loop_count > max_repeat_loop then
			return
		else
			return cx, cy
		end
	elseif area_shape == "torus" then
		assert(type(area_distance_2)=="number",string.format("function findClearSpot expects an area distance number as the sixth parameter when the shape is torus, but got a %s instead",type(area_distance_2)))
		repeat
			cx, cy = vectorFromAngle(random(0,360),random(area_distance,area_distance_2),true)
			cx = cx + area_point_x
			cy = cy + area_point_y
			far_enough = true
			for i,item in ipairs(objects) do
				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil and placing_station and isObjectType(item.obj,"SpaceStation") then
						comparison_dist = 12000
					end
					if distance(cx,cy,ix,iy) < (comparison_dist + new_buffer) then
						far_enough = false
						break
					end
				end
			end
			current_loop_count = current_loop_count + 1
		until(far_enough or current_loop_count > max_repeat_loop)
		if current_loop_count > max_repeat_loop then
			return
		else
			return cx, cy
		end
	elseif area_shape == "central rectangle" then
		assert(type(area_distance_2)=="number",string.format("function findClearSpot expects an area distance number (width) as the sixth parameter when the shape is rectangle, but got a %s instead",type(area_distance_2)))
		assert(type(area_angle)=="number",string.format("function findClearSpot expects an area angle number as the seventh parameter when the shape is central rectangle, but got a %s instead",type(area_angle)))
		repeat
			cx, cy = vectorFromAngle(area_angle,random(-area_distance/2,area_distance/2),true)
			cx = cx + area_point_x
			cy = cy + area_point_y
			local px, py = vectorFromAngle(area_angle + 90,random(-area_distance_2/2,area_distance_2/2),true)
			cx = cx + px
			cy = cy + py
			far_enough = true
			for i,item in ipairs(objects) do
				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil and placing_station and isObjectType(item.obj,"SpaceStation") then
						comparison_dist = 12000
					end
					if distance(cx,cy,ix,iy) < (comparison_dist + new_buffer) then
						far_enough = false
						break
					end
				end
			end
			current_loop_count = current_loop_count + 1
		until(far_enough or current_loop_count > max_repeat_loop)
		if current_loop_count > max_repeat_loop then
			return
		else
			return cx, cy
		end
	elseif area_shape == "rectangle" then
		assert(type(area_distance_2)=="number",string.format("function findClearSpot expects an area distance number (width) as the sixth parameter when the shape is rectangle, but got a %s instead",type(area_distance_2)))
		assert(type(area_angle)=="number",string.format("function findClearSpot expects an area angle number as the seventh parameter when the shape is rectangle, but got a %s instead",type(area_angle)))
		repeat
			cx, cy = vectorFromAngle(area_angle,random(0,area_distance),true)
			cx = cx + area_point_x
			cy = cy + area_point_y
			local px, py = vectorFromAngle(area_angle + 90,random(-area_distance_2/2,area_distance_2/2),true)
			cx = cx + px
			cy = cy + py
			far_enough = true
			for i,item in ipairs(objects) do
				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil and placing_station and isObjectType(item.obj,"SpaceStation") then
						comparison_dist = 12000
					end
					if distance(cx,cy,ix,iy) < (comparison_dist + new_buffer) then
						far_enough = false
						break
					end
				end
			end
			current_loop_count = current_loop_count + 1
		until(far_enough or current_loop_count > max_repeat_loop)
		if current_loop_count > max_repeat_loop then
			return
		else
			return cx, cy
		end
	end
end
function placeMinefieldBlob(placement_area)
	local area = placement_areas[placement_area]
	local radius = random(1500,4500)
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,radius)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,radius)
	elseif placement_area == "Expansion Strip" or placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,radius)
	end
	if eo_x ~= nil then
		local mine_list = {}
		table.insert(mine_list,Mine():setPosition(eo_x,eo_y))
		local reached_the_edge = false
		local mine_space = 1400
		repeat
			local overlay = false
			local nmx, nmy = nil
			repeat
				overlay = false
				local base_mine_index = math.random(1,#mine_list)
				local base_mine = mine_list[base_mine_index]
				local bmx, bmy = base_mine:getPosition()
				local angle = random(0,360)
				nmx, nmy = vectorFromAngle(angle,mine_space,true)
				nmx = nmx + bmx
				nmy = nmy + bmy
				for i, mine in ipairs(mine_list) do
					if i ~= base_mine_index then
						local cmx, cmy = mine:getPosition()
						local mine_distance = distance(cmx, cmy, nmx, nmy)
						if mine_distance < mine_space then
							overlay = true
							break
						end
					end
				end
			until(not overlay)
			table.insert(mine_list,Mine():setPosition(nmx,nmy))
			if distance(eo_x, eo_y, nmx, nmy) > radius then
				reached_the_edge = true
			end
		until(reached_the_edge)
		for i,mine in ipairs(mine_list) do
			table.insert(area.space,{obj=mine,dist=mine_space,shape="circle"})
		end
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
	return mine_list
end
function placeAsteroidBlob(placement_area)
	local area = placement_areas[placement_area]
	local radius = random(1500,4500)
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,radius)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,radius)
	elseif placement_area == "Expansion Strip" or placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,radius)
	end
	if eo_x ~= nil then
		local asteroid_list = {}
		local asteroid_size = random(2,180) + random(2,180) + random(2,180) + random(2,180)
		local a = Asteroid():setPosition(eo_x, eo_y):setSize(asteroid_size)
		table.insert(asteroid_list,a)
		local reached_the_edge = false
		repeat
			local overlay = false
			local nax, nay = nil
			repeat
				overlay = false
				local base_asteroid_index = math.random(1,#asteroid_list)
				local base_asteroid = asteroid_list[base_asteroid_index]
				local bax, bay = base_asteroid:getPosition()
				local angle = random(0,360)
				asteroid_size = random(2,180) + random(2,180) + random(2,180) + random(2,180)
				local asteroid_space = (base_asteroid:getSize() + asteroid_size)*random(1.05,1.25)
				nax, nay = vectorFromAngle(angle,asteroid_space,true)
				nax = nax + bax
				nay = nay + bay
				for i,asteroid in ipairs(asteroid_list) do
					if i ~= base_asteroid_index then
						local cax, cay = asteroid:getPosition()
						local asteroid_distance = distance(cax,cay,nax,nay)
						if asteroid_distance < asteroid_space then
							overlay = true
							break
						end
					end
				end
			until(not overlay)
			a = Asteroid():setPosition(nax,nay):setSize(asteroid_size)
			table.insert(asteroid_list,a)
			if distance(eo_x,eo_y,nax,nay) > radius then
				reached_the_edge = true
			end
		until(reached_the_edge)
		for i,ast in ipairs(asteroid_list) do
			asteroid_size = ast:getSize()
			local tx, ty = ast:getPosition()
			table.insert(area.space,{obj=ast,dist=asteroid_size,shape="circle"})
			local tether = random(asteroid_size + 10,800)
			local v_angle = random(0,360)
			local vx, vy = vectorFromAngle(v_angle,tether,true)
			vx = vx + tx
			vy = vy + ty
			VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
--			if vx > -20000 and vx < 0 and vy > -20000 and vy < 0 then
--				print("visual asteroid 1 near player spawn:",vx,vy)
--			end
			tether = random(asteroid_size + 10, asteroid_size + 800)
			v_angle = (v_angle + random(120,240)) % 360
			vx, vy = vectorFromAngle(v_angle,tether,true)
			vx = vx + tx
			vy = vy + ty
			VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
--			if vx > -20000 and vx < 0 and vy > -20000 and vy < 0 then
--				print("visual asteroid 1 near player spawn:",vx,vy)
--			end
		end
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeStar(placement_area)
	local area = placement_areas[placement_area]
	local radius = random(600,1400)
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,radius)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,radius)
	elseif placement_area == "Expansion Strip" or placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,radius)
	end
	if eo_x ~= nil then
		local star = Planet():setPosition(eo_x, eo_y):setPlanetRadius(radius):setDistanceFromMovementPlane(-radius*.5)
		star:setCallSign(tableRemoveRandom(star_list[1].name))
		star:setPlanetAtmosphereTexture(star_list[1].texture.atmosphere):setPlanetAtmosphereColor(random(0.5,1),random(0.5,1),random(0.5,1))
		table.insert(area.space,{obj=star,dist=radius + 1000,shape="circle"})
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeBlackHole(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,6000)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,6000)
	elseif placement_area == "Expansion Strip" or placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,6000)
	end
	if eo_x ~= nil then
		local bh = BlackHole():setPosition(eo_x, eo_y)
		table.insert(area.space,{obj=bh,dist=6000,shape="circle"})
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeProbe(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,200)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,200)
	elseif placement_area == "Expansion Strip" == placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,200)
		print("probe:",area.angle)
	end
	if eo_x ~= nil then
		local sp = ScanProbe():setPosition(eo_x, eo_y)
		local station_pool = {}
		if inner_stations ~= nil and #inner_stations > 0 then
			for i,station in ipairs(inner_stations) do
				if station:isValid() then
					table.insert(station_pool,station)
				end
			end
		end
		if outer_stations ~= nil and #outer_stations > 0 then
			for i,station in ipairs(outer_stations) do
				if station:isValid() then
					table.insert(station_pool,station)
				end
			end
		end
		local owner = tableSelectRandom(station_pool)
		sp:setLifetime(30*60):setOwner(owner):setTarget(eo_x,eo_y)
		table.insert(area.space,{obj=sp,dist=200,shape="circle"})
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeWarpJammer(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,200)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,200)
	elseif placement_area == "Expansion Strip" or placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,200)
	end
	if eo_x ~= nil then
		local wj = WarpJammer():setPosition(eo_x, eo_y)
		local closest_station_distance = 999999
		local closest_station = nil
		local station_pool = {}
		if expansion_stations ~= nil and #expansion_stations > 0 then
			for i,station in ipairs(expansion_stations) do
				if station:isValid() then
					table.insert(station_pool,station)
				end
			end
		end
		for i, station in ipairs(station_pool) do
			local current_distance = distance(station, eo_x, eo_y)
			if current_distance < closest_station_distance then
				closest_station_distance = current_distance
				closest_station = station
			end
		end
		local selected_faction = closest_station:getFaction()
		local warp_jammer_range = 0
		for i=1,5 do
			warp_jammer_range = warp_jammer_range + random(1000,4000)
		end
		wj:setRange(warp_jammer_range):setFaction(selected_faction)
		warp_jammer_info[selected_faction].count = warp_jammer_info[selected_faction].count + 1
		wj:setCallSign(string.format("%sWJ%i",warp_jammer_info[selected_faction].id,warp_jammer_info[selected_faction].count))
		wj.range = warp_jammer_range
		table.insert(warp_jammer_list,wj)
		table.insert(area.space,{obj=wj,dist=200,shape="circle"})
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeWormHole(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,6000)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,6000)
	elseif placement_area == "Expansion Strip" or placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,6000)
		print("wormhole:",area.angle)
	end
	if eo_x ~= nil then
		local we_x, we_y = nil
		local count_repeat_loop = 0
		repeat
			if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
				we_x, we_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,500)
			elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
				we_x, we_y = findClearSpot(area.space,area.shape,area.center_x,area.inner_radius,area.outer_radius,nil,500)
			elseif placement_area == "Expansion Strip" or placement_area == "Connecting Square" then
				eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,500)
			end
			count_repeat_loop = count_repeat_loop + 1
		until((we_x ~= nil and distance(eo_x, eo_y, we_x, we_y) > 50000) or count_repeat_loop > max_repeat_loop)
		if count_repeat_loop > max_repeat_loop then
			print("repeated too many times while placing a wormhole")
			print("eo_x:",eo_x,"eo_y:",eo_y,"we_x:",we_x,"we_y:",we_y)
		end
		if we_x ~= nil then
			local wh = WormHole():setPosition(eo_x, eo_y):setTargetPosition(we_x, we_y)
			wh:onTeleportation(function(self,transportee)
				string.format("")
				if transportee ~= nil and transportee:isValid() and isObjectType(transportee,"PlayerSpaceship") then
					transportee:setEnergy(transportee:getMaxEnergy()/2)	--reduces if more than half, increases if less than half
				end
			end)
			local va_exit = VisualAsteroid():setPosition(we_x, we_y)
			table.insert(area.space,{obj=wh,dist=6000,shape="circle"})
			table.insert(area.space,{obj=va_exit,dist=500,shape="circle"})
			return true
		else
			placeAsteroid(placement_area)
			return false
		end
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeSensorJammer(placement_area)
	local area = placement_areas[placement_area]
	local lo_range = 10000
	local hi_range = 30000
	local lo_impact = 10000
	local hi_impact = 20000
	local range_increment = (hi_range - lo_range)/8
	local impact_increment = (hi_impact - lo_impact)/4
--	local mix = math.random(2,10 - (4 - (2*math.floor(difficulty))))	--	2-6, 2-8, 2-10
	local mix = math.random(2,10 - (4 - (2)))	--	2-8
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
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,200)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,200)
	elseif placement_area == "Expansion Strip" or placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,200)
	end
	if eo_x ~= nil then
		local sj = sensorJammer(eo_x, eo_y)
		table.insert(area.space,{obj=sj,dist=200,shape="circle"})
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeSensorBuoy(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,200)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,200)
	elseif placement_area == "Expansion Strip" or placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,200)
	end
	local out = ""
	if eo_x ~= nil then
		local sb = Artifact():setPosition(eo_x, eo_y):setScanningParameters(math.random(1,difficulty*2),math.random(1,difficulty*2)):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII")
		local buoy_type_list = {}
		local buoy_type = ""
		local station_pool = {}
		if inner_stations ~= nil and #inner_stations > 0 then
			for i,station in ipairs(inner_stations) do
				if station:isValid() then
					table.insert(station_pool,station)
				end
			end
		end
		if outer_stations ~= nil and #outer_stations > 0 then
			for i,station in ipairs(outer_stations) do
				if station:isValid() then
					table.insert(station_pool,station)
				end
			end
		end
		if #station_pool > 0 then
			table.insert(buoy_type_list,"station")
		end
		if transport_list ~= nil and #transport_list > 0 then
			table.insert(buoy_type_list,"transport")
		end
		if #buoy_type_list > 0 then
			buoy_type = tableRemoveRandom(buoy_type_list)
			if buoy_type == "station" then
				local selected_stations = {}
				for i, station in ipairs(station_pool) do
					table.insert(selected_stations,station)
				end
				for i=1,3 do
					if #selected_stations > 0 then
						local station = tableRemoveRandom(selected_stations)
						if out == "" then
							out = string.format(_("scienceDescription-buoy","Sensor Record: %s station %s in %s"),station:getFaction(),station:getCallSign(),station:getSectorName())
						else
							out = string.format(_("scienceDescription-buoy","%s, %s station %s in %s"),out,station:getFaction(),station:getCallSign(),station:getSectorName())
						end
					else
						break
					end
				end
			end
			if buoy_type == "transport" then
				local selected_transports = {}
				for i, transport in ipairs(transport_list) do
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
		else
			out = _("scienceDescription-buoy","No data recorded")
		end
		sb:setDescriptions(_("scienceDescription-buoy","Automated data gathering device"),out)
		table.insert(area.space,{obj=sb,dist=200,shape="circle"})
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeAdBuoy(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,200)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,200)
	elseif placement_area == "Expansion Strip" or placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,200)
	end
	if eo_x ~= nil then
		local ab = Artifact():setPosition(eo_x, eo_y):setScanningParameters(difficulty*2,1):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII")
		local billboards = {
			_("scienceDescription-buoy","Come to Billy Bob's for the best food in the sector"),
			_("scienceDescription-buoy","It's never too late to buy life insurance"),
			_("scienceDescription-buoy","You'll feel better in an Adder Mark 9"),
			_("scienceDescription-buoy","Melinda's Mynock Management service: excellent rates, satisfaction guaranteed"),
			_("scienceDescription-buoy","Visit Repulse shipyards for the best deals"),
			_("scienceDescription-buoy","Fresh fish! We catch, you buy!"),
			_("scienceDescription-buoy","Get your fuel cells at Melinda's Market"),
			_("scienceDescription-buoy","Find a special companion. All species available"),
			_("scienceDescription-buoy","Feeling down? Robotherapist is there for you"),
			_("scienceDescription-buoy","30 days, 30 kilograms, guaranteed"),
			_("scienceDescription-buoy","Try our asteroid dust diet weight loss program"),
			_("scienceDescription-buoy","Best tasting water in the quadrant at Willy's Waterway"),
			_("scienceDescription-buoy","Amazing shows every night at Lenny's Lounge"),
			_("scienceDescription-buoy","Get all your vaccinations at Fred's Pharmacy. Pick up some snacks, too"),
			_("scienceDescription-buoy","Tip: make lemons an integral part of your diet"),
		}
		ab:setDescriptions(_("scienceDescription-buoy","Automated data gathering device"),billboards[math.random(1,#billboards)])
		table.insert(area.space,{obj=ab,dist=200,shape="circle"})
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeNebula(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,3000)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,3000)
	elseif placement_area == "Expansion Strip" or placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,2000)
	end
	if eo_x ~= nil then
		local neb = Nebula():setPosition(eo_x, eo_y)
		table.insert(area.space,{obj=neb,dist=1500,shape="circle"})
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
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeMine(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,1000)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,1000)
	elseif placement_area == "Expansion Strip" or placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,1000)
	end
	if eo_x ~= nil then
		local m = Mine():setPosition(eo_x, eo_y)
		table.insert(area.space,{obj=m,dist=1000,shape="circle"})
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeMineField(placement_area)
	local area = placement_areas[placement_area]
	local field_size = math.random(1,3)
	local mine_circle = {
		{inner_count = 4,	mid_count = 10,		outer_count = 15},	--1
		{inner_count = 9,	mid_count = 15,		outer_count = 20},	--2
		{inner_count = 15,	mid_count = 20,		outer_count = 25},	--3
	}
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,4000 + (field_size*1500))
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,4000 + (field_size*1500))
	elseif placement_area == "Expansion Strip" or placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,4000 + (field_size*1500))
	end
	if eo_x ~= nil then
		local angle = random(0,360)
		local mx = 0
		local my = 0
		for i=1,mine_circle[field_size].inner_count do
			mx, my = vectorFromAngle(angle,field_size*1000)
			local m = Mine():setPosition(eo_x+mx,eo_y+my)
			table.insert(area.space,{obj=m,dist=1000,shape="circle"})
			angle = (angle + (360/mine_circle[field_size].inner_count)) % 360
		end
		for i=1,mine_circle[field_size].mid_count do
			mx, my = vectorFromAngle(angle,field_size*1000 + 1200)
			local m = Mine():setPosition(eo_x+mx,eo_y+my)
			table.insert(area.space,{obj=m,dist=1000,shape="circle"})
			angle = (angle + (360/mine_circle[field_size].mid_count)) % 360
		end
		if random(1,100) < 30 + difficulty*20 then
			local n_x, n_y = vectorFromAngle(random(0,360),random(50,2000))
			Nebula():setPosition(eo_x + n_x, eo_y + n_y)
		end
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeAsteroidField(placement_area)
	local field_size = random(2000,8000)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,field_size + 500)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,500)
	elseif placement_area == "Expansion Strip" or placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,500)
	end
	if eo_x ~= nil then
		local asteroid_field = {}
		for n=1,math.floor(field_size/random(300,500)) do
			local asteroid_size = 0
			for s=1,4 do
				asteroid_size = asteroid_size + random(2,200)
			end
			local dist = random(100,field_size)
			local x,y = findClearSpot(asteroid_field,"circle",eo_x,eo_y,field_size,nil,nil,asteroid_size)
			if x ~= nil then
				local ast = Asteroid():setPosition(x,y):setSize(asteroid_size)
				table.insert(area.space,{obj=ast,dist=asteroid_size,shape="circle"})
				table.insert(asteroid_field,{obj=ast,dist=asteroid_size,shape="circle"})
				local tether = random(asteroid_size + 10,800)
				local v_angle = random(0,360)
				local vx, vy = vectorFromAngle(v_angle,tether,true)
				vx = vx + x
				vy = vy + y
				VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
--				if vx > -20000 and vx < 0 and vy > -20000 and vy < 0 then
--					print("visual asteroid 1 near player spawn:",vx,vy)
--				end
				tether = random(asteroid_size + 10, asteroid_size + 800)
				v_angle = (v_angle + random(120,240)) % 360
				vx, vy = vectorFromAngle(v_angle,tether,true)
				vx = vx + x
				vy = vy + y
				VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
--				if vx > -20000 and vx < 0 and vy > -20000 and vy < 0 then
--					print("visual asteroid 2 near player spawn:",vx,vy)
--				end
			else
				break
			end
		end
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeTransport(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,600)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,600)
	elseif placement_area == "Expansion Strip" or placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,600)
	end
	if eo_x ~= nil then
		local ship, ship_size = randomTransportType()
		if transport_factions == nil or #transport_factions == 0 then
			transport_factions = {}
			for i,faction in pairs(area.transport_pool) do
				table.insert(transport_factions,faction)
			end
		end
		ship:setPosition(eo_x, eo_y):setFaction(tableRemoveRandom(transport_factions))
		ship:setCallSign(generateCallSign(nil,ship:getFaction()))
		table.insert(area.space,{obj=ship,dist=600,shape="circle"})
		table.insert(transport_list,ship)
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeAsteroid(placement_area)
	local asteroid_size = random(2,200) + random(2,200) + random(2,200) + random(2,200)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,asteroid_size)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,asteroid_size)
	elseif placement_area == "Expansion Strip" or placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,asteroid_size)
	end
	if eo_x ~= nil then
		local ta = Asteroid():setPosition(eo_x, eo_y):setSize(asteroid_size)
		table.insert(area.space,{obj=ta,dist=asteroid_size,shape="circle"})
		--[[
		local tether = random(asteroid_size + 10,800)
		local v_angle = random(0,360)
		local vx, vy = vectorFromAngle(v_angle,tether,true)
		vx = vx + eo_x
		vy = vy + eo_y
		VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
		if vx > -20000 and vx < 0 and vy > -20000 and vy < 0 then
			print("visual asteroid 1 near player spawn:",vx,vy)
		end
		tether = random(asteroid_size + 10, asteroid_size + 800)
		v_angle = (v_angle + random(120,240)) % 360
		vx, vy = vectorFromAngle(v_angle,tether,true)
		vx = vx + eo_x
		vy = vy + eo_x
		VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
		if vx > -20000 and vx < 0 and vy > -20000 and vy < 0 then
			print("visual asteroid 2 near player spawn:",vx,vy)
		end
		--]]
		return true
	else
		return false
	end
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
function maintainTransports()
	local clean_list = true
	for i,transport in ipairs(transport_list) do
		if transport ~= nil then
			if not transport:isValid() then
				transport_list[i] = transport_list[#transport_list]
				transport_list[#transport_list] = nil
				clean_list = false
				break
			end
		else
			transport_list[i] = transport_list[#transport_list]
			transport_list[#transport_list] = nil
			clean_list = false
			break
		end
	end
	if clean_list then
		for i,transport in ipairs(transport_list) do
			if transport ~= nil and transport:isValid() then
				if transport:getDockedWith() ~= nil then	--docked
					if transport.dock_time == nil then
						transport.dock_time = getScenarioTime() + random(5,30)
					end
				elseif transport:getOrder() ~= "Dock" then	--no docking order
					if transport.dock_time == nil then
						transport.dock_time = getScenarioTime() + random(5,30)
					end
				elseif transport:getOrder() == "Dock" then	--docking order to invalid station
					if transport:getOrderTarget() == nil or not transport:getOrderTarget():isValid() then
						if transport.dock_time == nil then
							transport.dock_time = getScenarioTime() + random(5,30)
						end
					end
				end
			end
			if transport.dock_time ~= nil and getScenarioTime() > transport.dock_time then
				local transport_station_pool = {}
				for j,station in ipairs(expansion_stations) do
					if station ~= nil then
						if station:isValid() then
							if not transport:isEnemy(station) then
								table.insert(transport_station_pool,station)
							end
						else
							expansion_stations[j] = expansion_stations[#expansion_stations]
							expansion_stations[#expansion_stations] = nil
							clean_list = false
							break
						end
					else
						expansion_stations[j] = expansion_stations[#expansion_stations]
						expansion_stations[#expansion_stations] = nil
						clean_list = false
						break
					end
				end
				if clean_list and #transport_station_pool > 0 then
					local dock_station = tableSelectRandom(transport_station_pool)
					transport:orderDock(dock_station)
					transport.dock_time = nil
				end
			end
		end
		if clean_list and #transport_list < #expansion_stations then
			if transport_spawn_time == nil then
				transport_spawn_time = getScenarioTime() + random(30,60)
			end
			if getScenarioTime() > transport_spawn_time then
				if random(1,100) < 30 then
					local transport_station_spawn_pool = {}
					for i,station in ipairs(expansion_stations) do
						if station ~= nil and station:isValid() and station:getFaction() ~= "Exuari" then
							table.insert(transport_station_spawn_pool,station)
						end
					end
					local destination_station = tableSelectRandom(transport_station_spawn_pool)
					local sx,sy = destination_station:getPosition()
					local ship, ship_size = randomTransportType()
					local faction_pool = {}
					for i,faction in ipairs(strip_transports) do
						local tta = Artifact():setFaction(faction)
						if not tta:isEnemy(destination_station) then
							table.insert(faction_pool,faction)
						end
						tta:destroy()
					end
					ship:setFaction(tableSelectRandom(faction_pool))
					ship:setPosition(sx,sy)
					ship:setCallSign(generateCallSign(nil,ship:getFaction()))
					table.insert(transport_list,ship)
					ship:orderDock(destination_station)
				end
				transport_spawn_time = getScenarioTime() + random(30,60)
			end
		end
	end
end
--	Sensor jammer utilities
function sensorJammerPickupProcess(self,retriever)
	string.format("")
	local jammer_call_sign = self:getCallSign()
	sensor_jammer_list[jammer_call_sign] = nil
	if not self:isScannedBy(retriever) then
		retriever:setCanScan(false)
		retriever.scanner_dead = "scanner_dead"
		retriever:addCustomMessage("Science",retriever.scanner_dead,_("msgScience","The unscanned artifact we just picked up has fried our scanners"))
		retriever.scanner_dead_ops = "scanner_dead_ops"
		retriever:addCustomMessage("Operations",retriever.scanner_dead_ops,_("msgOperations","The unscanned artifact we just picked up has fried our scanners"))
	end
	may_explain_sensor_jammer = true
end
function sensorJammer(x,y)
	artifact_number = artifact_number + math.random(1,4)
	local random_suffix = string.char(math.random(65,90))
	local jammer_call_sign = string.format("SJ%i%s",artifact_number,random_suffix)
	local scanned_description = string.format(_("scienceDescription-artifact","Source of emanations interfering with long range sensors. Range:%.1fu Impact:%.1fu"),sensor_jammer_range/1000,sensor_jammer_impact/1000)
	local sensor_jammer = Artifact():setPosition(x,y):setScanningParameters(sensor_jammer_scan_complexity,sensor_jammer_scan_depth):setRadarSignatureInfo(.2,.4,.1):setModel("SensorBuoyMKIII"):setDescriptions(_("scienceDescription-artifact","Source of unusual emanations"),scanned_description):setCallSign(jammer_call_sign)
	sensor_jammer:onPickUp(sensorJammerPickupProcess)
	sensor_jammer_list[jammer_call_sign] = sensor_jammer
	sensor_jammer.jam_range = sensor_jammer_range
	sensor_jammer.jam_impact = sensor_jammer_impact
	sensor_jammer.jam_impact_units = sensor_jammer_power_units
	return sensor_jammer
end
--	initialize player ship
function setPlayers()
	for i,p in ipairs(getActivePlayerShips()) do
		if p.shipScore == nil then
			updatePlayerSoftTemplate(p)
		end
	end
end
function updatePlayerSoftTemplate(p)
	--set defaults for those ships not found in the list
	local pi = nil
	local px, py = 0
	for i=1,32 do
		pi = getPlayerShip(i)
		if pi == p then
			px = player_start_points[i].x
			py = player_start_points[i].y
			break
		end
	end
	p:setPosition(px,py)
	p.shipScore = 24
	p.maxCargo = 5
	p.cargo = p.maxCargo
	p.tractor = false
	p.tractor_target_lock = false
	p.mining = false
	p.goods = {}
	local temp_type_name = p:getTypeName()
	if temp_type_name ~= nil then
		local p_stat = player_ship_stats[temp_type_name]
		if p_stat ~= nil then
			p.maxCargo = p_stat.cargo
			p.cargo = p.maxCargo
			p:setMaxScanProbeCount(p_stat.probes)
			p:setScanProbeCount(p:getMaxScanProbeCount())
			p:setLongRangeRadarRange(player_ship_stats[temp_type_name].long_range_radar)
			p:setShortRangeRadarRange(player_ship_stats[temp_type_name].short_range_radar)
			p.normal_long_range_radar = player_ship_stats[temp_type_name].long_range_radar
			p.tractor = p_stat.tractor
			p.tractor_target_lock = false
			p.mining = p_stat.mining
			if p.name_set == nil then
				local player_ship_name_list = player_ship_names_for[temp_type_name]
				local player_ship_name = nil
				if player_ship_name_list ~= nil then
					player_ship_name = tableRemoveRandom(player_ship_name_list)
				end
				if player_ship_name == nil then
					player_ship_name = tableSelectRandom(player_ship_names_for["Leftovers"])
				end
				if player_ship_name ~= nil then
					p:setCallSign(player_ship_name)
				end
				p.name_set = true
			end
		else
			addGMMessage(string.format("Player ship %s's template type (%s) could not be found in table player_ship_stats",p:getCallSign(),temp_type_name))
		end
	end
	p.maxRepairCrew = p:getRepairCrewCount()
	p.healthyShield = 1.0
	p.prevShield = 1.0
	p.healthyReactor = 1.0
	p.prevReactor = 1.0
	p.healthyManeuver = 1.0
	p.prevManeuver = 1.0
	p.healthyImpulse = 1.0
	p.prevImpulse = 1.0
	if p:getBeamWeaponRange(0) > 0 then
		p.healthyBeam = 1.0
		p.prevBeam = 1.0
	end
	local tube_count = p:getWeaponTubeCount()
	if tube_count > 0 then
		p.healthyMissile = 1.0
		p.prevMissile = 1.0
		local size_letter = {
			["small"] = 	"S",
			["medium"] =	"M",
			["large"] =		"L",
		}
		p.tube_size = ""
		for i=1,tube_count do
			p.tube_size = p.tube_size .. size_letter[p:getTubeSize(i-1)]
		end
	end
	if p:hasWarpDrive() then
		p.healthyWarp = 1.0
		p.prevWarp = 1.0
	end
	if p:hasJumpDrive() then
		p.healthyJump = 1.0
		p.prevJump = 1.0
	end
	p.initialCoolant = p:getMaxCoolant()
	p.normal_coolant_rate = {}
	p.normal_power_rate = {}
	for _, system in ipairs(system_types) do
		p.normal_coolant_rate[system] = p:getSystemCoolantRate(system)
		p.normal_power_rate[system] = p:getSystemPowerRate(system)
	end
end
--	generic utilities
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
function availableForComms(p)
	if not p:isCommsInactive() then
		return false
	end
	if p:isCommsOpening() then
		return false
	end
	if p:isCommsBeingHailed() then
		return false
	end
	if p:isCommsBeingHailedByGM() then
		return false
	end
	if p:isCommsChatOpen() then
		return false
	end
	if p:isCommsChatOpenToGM() then
		return false
	end
	if p:isCommsChatOpenToPlayer() then
		return
	end
	if p:isCommsScriptOpen() then
		return false
	end
	return true
end
--	mission related functions
function getCurrentOrders()
	local current_orders_prompts = {
		_("orders-comms","Current orders?"),
		_("orders-comms","What are my current orders?"),
		string.format(_("orders-comms","Current orders for %s?"),comms_source:getCallSign()),
		_("orders-comms","Remind me of our current orders, please"),
	}
	addCommsReply(tableSelectRandom(current_orders_prompts),function()
		setOptionalOrders()
		local player_primary_orders = primary_orders
		if uniform_plague_mission_fully_accepted then
			primary_orders = "Gather research from stations in The Strip"
			player_primary_orders = primary_orders
		else
			if comms_source.uniform_plague_mission then
				player_primary_orders = "Gather research from stations in The Strip"
			end
		end
		ordMsg = player_primary_orders .. "\n" .. optional_orders
		setCommsMessage(ordMsg)
		addCommsReply(_("Back"), commsStation)
	end)
end
function setOptionalOrders()
	optional_orders = ""
	if comms_source.transport_mission ~= nil 
	or comms_source.cargo_mission ~= nil 
	or (comms_source.rock_research and not rock_research_complete) 
	or (comms_source:getFaction() == "TSN" and not comms_source.completed_ghosts_transport_mission)
	or (comms_source.delivered_ghost_VIP and not comms_source.completed_ghosts_transport_mission) 
	or (comms_source.destroy_agressive_kraylor_station_mission and station_aggressive_kraylor:isValid())
	or (comms_source.destroy_agressive_ktlitan_station_mission and station_aggressive_ktlitans:isValid()) then
		local optional_orders_header = {
			_("orders-comms","\nOptional:"),
			_("orders-comms","\nOptional orders:"),
			_("orders-comms","\nThese orders are optional:"),
			_("orders-comms","\nNot required:"),
		}
		optional_orders = tableSelectRandom(optional_orders_header)
	end
	if comms_source.transport_mission ~= nil then
		if comms_source.transport_mission.destination ~= nil and comms_source.transport_mission.destination:isValid() then
			optional_orders = string.format(_("orders-comms","%s\nTransport %s to %s station %s in %s"),optional_orders,comms_source.transport_mission.character.name,comms_source.transport_mission.destination:getFaction(),comms_source.transport_mission.destination_name,comms_source.transport_mission.destination:getSectorName())
		else
			optional_orders = string.format(_("orders-comms","%s\nTransport %s to station %s (defunct)"),optional_orders,comms_source.transport_mission.character.name,comms_source.transport_mission.destination_name)
		end
	end
	if comms_source.cargo_mission ~= nil then
		if comms_source.cargo_mission.loaded then
			if comms_source.cargo_mission.destination ~= nil and comms_source.cargo_mission.destination:isValid() then
				optional_orders = string.format(_("orders-comms","%s\nDeliver cargo for %s to station %s in %s"),optional_orders,comms_source.cargo_mission.character.name,comms_source.cargo_mission.destination_name,comms_source.cargo_mission.destination:getSectorName())
			else
				optional_orders = string.format(_("orders-comms","%s\nDeliver cargo for %s to station %s (defunct)"),optional_orders,comms_source.cargo_mission.character.name,comms_source.cargo_mission.destination_name)
			end
		else
			if comms_source.cargo_mission.origin ~= nil and comms_source.cargo_mission.origin:isValid() then
				optional_orders = string.format(_("orders-comms","%s\nPick up cargo for %s at station %s in %s"),optional_orders,comms_source.cargo_mission.character.name,comms_source.cargo_mission.origin_name,comms_source.cargo_mission.origin:getSectorName())
			else
				optional_orders = string.format(_("orders-comms","%s\nPick up cargo for %s at station %s (defunct)"),optional_orders,comms_source.cargo_mission.character.name,comms_source.cargo_mission.origin_name)
			end
		end
	end
	if comms_source.restoration_mission ~= nil then
		if comms_source.restoration_mission.achievement then
			if comms_source.restoration_mission.destination ~= nil and comms_source.restoration_mission.destination:isValid() then
				optional_orders = string.format("%s\n%s",optional_orders,comms_source.restoration_mission.optional_orders_second_half)
			else
				optional_orders = string.format(_("orders-comms","%s\n%s (defunct)"),optional_orders,comms_source.restoration_mission.optional_orders_second_half)
			end
		else
			if comms_source.restoration_mission.origin ~= nil and comms_source.restoration_mission.origin:isValid() then
				optional_orders = string.format("%s\n%s",optional_orders,comms_source.restoration_mission.optional_orders_first_half)
			else
				optional_orders = string.format(_("orders-comms","%s\n%s (defunct)"),optional_orders,comms_source.restoration_mission.optional_orders_first_half)
			end
		end
	end
	if comms_source.rock_research and not rock_research_complete then
		if comms_source.asteroid_data_cache then
			optional_orders = string.format("%s\nReturn data cache from Jessi Alcott's missing asteroid.",optional_orders)
		else
			optional_orders = string.format("%s\nFind Jessi Alcott's asteroid. Asteroids scanned so far: %i.",optional_orders,scanned_asteroid_count)
		end
	end
	if comms_source:getFaction() == "TSN" and not comms_source.completed_ghosts_transport_mission then
		if station_eye_ghost:isValid() then
			optional_orders = string.format("%s\nDeliver the Ghosts scientist to station %s in %s.",optional_orders,station_eye_ghost:getCallSign(),station_eye_ghost:getSectorName())
		end
	end
	if comms_source.delivered_ghost_VIP and not comms_source.completed_ghosts_transport_mission then
		optional_orders = string.format("%s\nDeliver tritanium to station %s.",optional_orders,station_med_TSN:getCallSign())
	end
	if comms_source.destroy_agressive_kraylor_station_mission then
		if station_aggressive_kraylor:isValid() then
			if comms_source.destroy_agressive_ktlitan_station_mission then
				if station_aggressive_ktlitans:isValid() then
					optional_orders = string.format("%s\nDestroy aggressive Kraylor and Ktlitan stations.",optional_orders)
				else
					optional_orders = string.format("%s\nDestroy aggressive Kraylor station.",optional_orders)
				end
			else
				optional_orders = string.format("%s\nDestroy aggressive Kraylor station.",optional_orders)
			end
		else
			if comms_source.destroy_agressive_ktlitan_station_mission then
				if station_aggressive_ktlitans:isValid() then
					optional_orders = string.format("%s\nDestroy aggressive Ktlitan station.",optional_orders)
				end
			end
		end
	elseif comms_source.destroy_agressive_ktlitan_station_mission then
		if station_aggressive_ktlitans:isValid() then
			optional_orders = string.format("%s\nDestroy aggressive Ktlitan station.",optional_orders)
		end
	end
end
function scenarioMissionsUndocked()
	showPatrolCircuitStatus()
	rockResearch()
	showStripResearch()
end
function scenarioMissions()
	local option_count = 0
	option_count = option_count + showPatrolCircuitStatus()
	option_count = option_count + destroyAggressiveKraylorStation()
	option_count = option_count + destroyAggressiveKtlitanStation()
	option_count = option_count + transportGhostVIP()
	option_count = option_count + rockResearch()
	option_count = option_count + uniformPlague()
	option_count = option_count + wormholeGuide()
	option_count = option_count + showStripResearch()
	option_count = option_count + getResearchContainer()
	option_count = option_count + deliverResearchContainers()
	option_count = option_count + upgradeMissileCapacity()
	return option_count
end
function scenarioStationTalk()
	local knowledge_count = 0
	if comms_target == station_large_USN or comms_target == station_huge_CUF then
		local scenario_station_talk_prompts = {
			"Why are you in a nebula?",
			"Why build a station in a nebula?",
			"Is there a reason you're in a nebula?",
			"Why hide your station in a nebula?",
		}
		knowledge_count = knowledge_count + 1
		addCommsReply(tableSelectRandom(scenario_station_talk_prompts), function()
			setCommsMessage("The scientists that were part of the station when it was built noticed that some of the nebula around here had unusual properties. Part of the reason for setting up here was to study those properties. Nebulae block sensors as your science officer can tell you. From a ship, you need to use a probe to run scans on a nebula. We built specialized sensors into this station to facilitate nebula research. This nebula no longer exhibits those unusual properties, but other nebulae around here might.")
			addCommsReply(_("Back"), commsStation)
		end)
	end
	return knowledge_count
end
function verifyAsteroid()
	if osmium == 0 then
		addCommsReply("osmium",function()
			traceDigits("osmium",osmium)
		end)
	end
	if iridium == 0 then
		addCommsReply("iridium",function()
			traceDigits("iridium",iridium)
		end)
	end
	if olivine == 0 then
		addCommsReply("olivine",function()
			traceDigits("olivine",olivine)
		end)
	end
	if iron == 0 then
		addCommsReply("iron",function()
			traceDigits("iron",iron)
		end)
	end
	if osmium ~= 0 and iridium ~= 0 and olivine ~= 0 and iron ~= 0 then
		if target_asteroid ~= nil and target_asteroid:isValid() then
			if	osmium == target_asteroid.osmium and
				iridium == target_asteroid.iridium and
				olivine == target_asteroid.olivine and
				iron == target_asteroid.iron then
				setCommsMessage("You found it! I have uncloaked my data storage cache. Please go retrieve it for me.")
				if asteroid_data_cache == nil then
					local x, y = target_asteroid:getPosition()
					local rad = target_asteroid:getSize()
					local dx, dy = vectorFromAngle(random(0,360),rad + 200,true)
					asteroid_data_cache = Artifact():setPosition(x + dx, y + dy):setModel("ammo_box"):allowPickup(true):setSpin(0.5):setRadarTraceColor(227,185,255)
					asteroid_data_cache:onPickUp(function(self,player)
						string.format("")
						player.asteroid_data_cache = true
					end)
				end
			else
				setCommsMessage("Your data does not match my notes. You'll need to keep looking")
			end
		else
			setCommsMessage("Your data does not match my notes. You'll need to keep looking")
			pickTargetAsteroid()
		end
	end
end
function traceDigits(trace_element,percentage)
	setCommsMessage(string.format("Provide the 10's digit for %s. For example, if there was 23.5%% %s, the 10's digit would be 2.",trace_element,trace_element))
	for i=0,9 do
		addCommsReply(string.format("10's digit %i",i),function()
			setCommsMessage(string.format("Provide the 1's digit for %s. For example, if there was 23.5%% %s, the 1's digit would be 3.",trace_element,trace_element))
			for j=0,9 do
				addCommsReply(string.format("1's digit %i",j),function()
					setCommsMessage(string.format("Provide one digit after the decimal point for %s. For example, if there was 23.5%% %s, the digit would be 5.",trace_element,trace_element))
					for k=0,9 do
						addCommsReply(string.format("after decimal digit %i",k),function()
							print(string.format("%s: %.1f",trace_element,i*10 + j + k/10))
							percentage = i*10 + j + k/10
							if trace_element == "osmium" then
								osmium = percentage
							elseif trace_element == "iridium" then
								iridium = percentage
							elseif trace_element == "olivine" then
								olivine = percentage
							elseif trace_element == "iron" then
								iron = percentage
							end
							setCommsMessage(string.format("That's %.1f%% for %s. Let's get data for another element.",percentage,trace_element))
							verifyAsteroid()
						end)
					end
				end)
			end
		end)
	end
end
function rockResearch()
	local option_count = 0
	if comms_target == station_headquarters then
		if comms_source.rock_research and not rock_research_complete then
			option_count = option_count + 1
			addCommsReply("Contact Jessi Alcott regarding her missing asteroid",function()
				if comms_source.asteroid_data_cache then
					setCommsMessage("[Jessi] Did you get my asteroid data cache?")
					if comms_source:isDocked(comms_target) then
						addCommsReply("Yes. It is being delivered now",function()
							rock_research_complete = true
							comms_source:addReputationPoints(100)
							setCommsMessage("[Jessi] Thanks! You are truly stellar representatives of the Human Navy.")
						end)
					else
						addCommsReply("Yes. We'll bring it to you soon",function()
							setCommsMessage("[Jessi] Oh goody!")
						end)
					end
				else
					setCommsMessage("[Jessi] Have you found my missing asteroid?")
					addCommsReply("Not yet. Need asteroid details",function()
						setCommsMessage("I would be happy to provide those.")
						addCommsReply("Composition",function()
							setCommsMessage("The asteroid I'm looking for is composed of the following: osmium, iridium, olivine, iron, and rock")
							addCommsReply("We found an asteroid of that composition",function()
								setCommsMessage("Good. Let's verify the trace elements of the asteroid you've found against my notes.")
								osmium = 0
								iridium = 0
								olivine = 0
								iron = 0
								verifyAsteroid()
							end)
						end)
						if scanned_asteroid_count > 5 and asteroid_structure ~= nil then
							addCommsReply("Structure",function()
								setCommsMessage(string.format("The structure of the asteroid I'm looking for is %s",asteroid_structure))
							end)
						end
						if scanned_asteroid_count > 10 and target_asteroid_sector ~= nil then
							addCommsReply("Sector",function()
								setCommsMessage(string.format("The asteroid is in sector %s.",target_asteroid_sector))
							end)
						end
					end)
				end
			end)
		elseif not rock_research_complete then
			option_count = option_count + 1
			addCommsReply("Find missing asteroid",function()
				setCommsMessage("Jessi Alcott has been researching asteroids in the area. Unfortunately, she left behind the bulk of her research on the asteroid that most interests her. She says the asteroid has traces of osmium and iridium. To help her out, you'll need to scan asteroids for ones that match her criteria. Contact her here to confirm any potential asteroid you might find.")
				comms_source.rock_research = true 
			end)
		end
	end
	return option_count
end
function transportGhostVIP()
	local option_count = 0
	if comms_target == station_med_TSN then
		if comms_source:getFaction() == "Human Navy" then
			if station_asteroids_g_far_t:isValid() and station_eye_ghost:isValid() and not station_asteroids_g_far_t.ghost_VIP_enroute then
				option_count = option_count + 1
				addCommsReply("Transport Ghosts scientist",function()
					setCommsMessage(string.format("There's a ghost scientist on station %s needing transportation to station %s. In exchange, %s will provide tritanium which we (station %s) need. In order to complete the mission, your ship will need to become part of the TSN for the duration of the mission. If you accept, we will update your IFF from Human Navy to TSN.\n\nDo you accept the mission?",station_asteroids_g_far_t:getCallSign(),station_eye_ghost:getCallSign(),station_eye_ghost:getCallSign(),comms_target:getCallSign()))
					addCommsReply("Accept mission",function()
						if station_asteroids_g_far_t:isValid() then
							if station_eye_ghost:isValid() then
								comms_source:setFaction("TSN")
								setCommsMessage(string.format("You are now part of the Terran Stellar Navy (TSN). IFF updated.\nThe Ghost scientist is on station %s in sector %s. He needs to be delivered to station %s in sector %s.",station_asteroids_g_far_t:getCallSign(),station_asteroids_g_far_t:getSectorName(),station_eye_ghost:getCallSign(),station_eye_ghost:getSectorName()))
							else
								setCommsMessage("Unfortunately, the tritanium supplying station is no longer with us, so the mission is no longer available.")
							end
						else
							setCommsMessage("Unfortunately, the station with the ghost scientist is no longer with us, so the mission is no longer available.")
						end
					end)
					addCommsReply("Decline mission",commsStation)
				end)
			end
			if comms_source.delivered_ghost_VIP and not comms_source.completed_ghosts_transport_mission then
				if comms_source.goods["tritanium"] > 0 then
					option_count = option_count + 1
					addCommsReply(string.format("Deliver tritanium to %s",comms_target:getCallSign()),function()
						comms_source.cargo = comms_source.cargo + 1
						comms_source.goods["tritanium"] = comms_source.goods["tritanium"] - 1
						comms_source:setFaction("Human Navy")
						comms_source:addReputationPoints(80)
						comms_source.completed_ghosts_transport_mission = true
						setCommsMessage(string.format("You have completed the mission to transport the Ghosts scientist and retrieve tritanium mission."))
					end)
				end
			end
		elseif comms_source:getFaction() == "TSN" then
			option_count = option_count + 1
			addCommsReply("Abandon transport Ghosts scientist mission",function()
				comms_source:setFaction("Human Navy")
				setCommsMessage("You have returned to the service of the Human Navy. IFF updated")
			end)
		end
	end
	if comms_target == station_asteroids_g_far_t then
		if station_eye_ghost:isValid() then
			if not station_asteroids_g_far_t.ghost_VIP_enroute then
				option_count = option_count + 1
				addCommsReply("Get Ghosts scientist",function()
					comms_source.ghost_VIP = true
					comms_target.ghost_VIP_enroute = true
					setCommsMessage(string.format("The ghost scientist has boarded %s. He needs to be taken to %s in sector %s",comms_source:getCallSign(),station_eye_ghost:getCallSign(),station_eye_ghost:getSectorName()))
				end)
			else
				setCommsMessage("The Ghosts scientist has already left, so the mission is no longer available.")
			end
		else
			setCommsMessage("Unfortunately, the tritanium supplying station is no longer with us, so the mission is no longer available.")
		end
	end
	if comms_target == station_eye_ghost then
		if comms_source.ghost_VIP then
			option_count = option_count + 1
			addCommsReply("Deliver Ghosts scientist",function()
				comms_source.ghost_VIP = false
				comms_source.delivered_ghost_VIP = true
				if comms_source.cargo < 1 then
					setCommsMessage("Ghosts scientist has been delivered. There is not enough room in your cargo hold for tritanium.")
				elseif comms_source.cargo < 2 then
					setCommsMessage("Ghosts scientist has been delivered. One tritanium loaded in your cargo hold.")
					comms_source.cargo = comms_source.cargo - 1
					if comms_source.goods == nil then
						comms_source.goods = {}
					end
					if comms_source.goods["tritanium"] == nil then
						comms_source.goods["tritanium"] = 0
					end
					comms_source.goods["tritanium"] = comms_source.goods["tritanium"] + 1
				else
					setCommsMessage("Ghosts scientist has been delivered. Two tritanium loaded in your cargo hold, one for the mission and an extra in gratitude.")
					comms_source.cargo = comms_source.cargo - 2
					if comms_source.goods == nil then
						comms_source.goods = {}
					end
					if comms_source.goods["tritanium"] == nil then
						comms_source.goods["tritanium"] = 0
					end
					comms_source.goods["tritanium"] = comms_source.goods["tritanium"] + 2
				end
				IFF_fail_time = getScenarioTime() + random(1,3)
			end)
		end
	end
	return option_count
end
function upgradeMissileCapacity()
	local option_count = 0
	if comms_target == station_asteroids_i_near_h and not comms_source.missile_capacity_upgrade then
		if comms_source.destroy_agressive_kraylor_station_mission or comms_source.destroy_agressive_ktlitan_station_mission then
			option_count = 1
			addCommsReply("Upgrade missile storage capacity",function()
				if comms_target.missile_capacity_upgrade_good == nil then
					local good_pool = {}
					for i,station in ipairs(inner_stations) do
						if station ~= nil and station:isValid() and station ~= comms_target then
							if station.comms_data.goods ~= nil then
								for good,details in pairs(station.comms_data.goods) do
									if good ~= "food" and good ~= "medicine" then
										if details.quantity > 0 then
											if comms_target.comms_data.goods ~= nil then
												local good_is_here = false
												for good_here,details_here in pairs(comms_target.comms_data.goods) do
													if good == good_here then
														good_is_here = true
														break
													end
												end
												if not good_is_here then
													table.insert(good_pool,good)
												end
											end
										end
									end
								end
							end
						end
					end
					comms_target.missile_capacity_upgrade_good = tableSelectRandom(good_pool)
				end
				setCommsMessage(string.format("We can upgrade your missile storage capacity if you provide us with %s",comms_target.missile_capacity_upgrade_good))
				addCommsReply("Get missile capacity upgrade",function()
					if comms_source.goods ~= nil and comms_source.goods[comms_target.missile_capacity_upgrade_good] ~= nil and comms_source.goods[comms_target.missile_capacity_upgrade_good] > 0 then
						local increase = {
							["Homing"] = 4,
							["HVLI"] = 4,
							["Mine"] = 3,
							["EMP"] = 2,
							["Nuke"] = 2,
						}
						for i,missile in ipairs(missile_types) do
							if comms_source:getWeaponStorageMax(missile) > 0 then
								comms_source:setWeaponStorageMax(missile, comms_source:getWeaponStorageMax(missile) + increase[missile])
							end
						end
						comms_source.missile_capacity_upgrade = true
						comms_source.goods[comms_target.missile_capacity_upgrade_good] = comms_source.goods[comms_target.missile_capacity_upgrade_good] - 1
						comms_source.cargo = comms_source.cargo + 1
						setCommsMessage("Your ship can now store more missiles")
					else
						setCommsMessage(string.format("You don't have any %s in your ship inventory",comms_target.missile_capacity_upgrade_good))
					end
				end)
			end)
		end
	end
	return option_count
end
function destroyAggressiveKraylorStation()
	local option_count = 0
	if comms_target == station_huge_CUF then
		if station_aggressive_kraylor:isValid() and not comms_source.destroy_agressive_kraylor_station_mission then
			option_count = option_count + 1
			addCommsReply("Destroy aggressive Kraylor station",function()
				local ox, oy = comms_target:getPosition()
				local dx, dy = station_aggressive_kraylor:getPosition()
				local bearing = math.floor(angleHeading(ox, oy, dx, dy))
				setCommsMessage(string.format("The Kraylor have sent several attacking forces here. Judging from their attack vector, they have a station on bearing %i. Your mission is to destroy that station. Our enhanced sensors don't show anything, so the station must be over 100 units away.",bearing))
				comms_source.destroy_agressive_kraylor_station_mission = true
			end)
		end
	end
	return option_count
end
function destroyAggressiveKtlitanStation()
	local option_count = 0
	if comms_target == station_large_USN then
		if station_aggressive_ktlitans:isValid() and not comms_source.destroy_agressive_ktlitan_station_mission then
			option_count = option_count + 1
			addCommsReply("Destroy aggressive Ktlitan station",function()
				local ox, oy = comms_target:getPosition()
				local dx, dy = station_aggressive_ktlitans:getPosition()
				local bearing = math.floor(angleHeading(ox, oy, dx, dy))
				setCommsMessage(string.format("The Ktlitans have sent several attacking forces here. Judging from their attack vector, they have a station on bearing %i. Your mission is to destroy that station. Our enhanced sensors don't show anything, so the station must be over 100 units away.",bearing))
				comms_source.destroy_agressive_ktlitan_station_mission = true
			end)
		end
	end
	return option_count
end
function showStripResearch()
	local option_count = 0
	local may_show_research = false
	if uniform_plague_mission_fully_accepted then
		for i,station in ipairs(expansion_stations) do
			if station ~= nil and station:isValid() then
				if comms_target == station then
					if comms_source:isFriendly(comms_target) then
						may_show_research = true
						break
					end
				end
			end
		end
	end
	if may_show_research then
		option_count = 1
		addCommsReply("Report on plague research mission",function()
			setCommsMessage("Report added to ship log")
			if station_research_delivery ~= nil and station_research_delivery:isValid() then
				if station_research_delivery.containers == nil then
					station_research_delivery.containers = {
						"Human Navy"
					}
				end
				local delivered = ""
				local faction_sources = {}
				for i,f in ipairs(complete_faction_sources) do
					table.insert(faction_sources,f)
				end
				for i,c in ipairs(station_research_delivery.containers) do
					delivered = string.format("%s   %s",delivered,c)
					for j,faction in ipairs(faction_sources) do
						if c == faction then
							faction_sources[j] = faction_sources[#faction_sources]
							faction_sources[#faction_sources] = nil
							break
						end
					end
				end
				comms_source:addToShipLog(string.format("Research delivered to station %s in %s:",station_research_delivery:getCallSign(),station_research_delivery:getSectorName()),"Yellow")
				comms_source:addToShipLog(delivered,"Green")
				local remaining = ""
				for i,faction in ipairs(faction_sources) do
					remaining = string.format("%s   %s",remaining,faction)
				end
				comms_source:addToShipLog("Research remaining to be delivered:","Yellow")
				comms_source:addToShipLog(remaining,"Red")
				for i,p in ipairs(getActivePlayerShips()) do
					comms_source:addToShipLog(string.format("Research aboard %s:",p:getCallSign()),"Yellow")
					if p.containers ~= nil and #p.containers > 0 then
						local aboard = ""
						for j,c in ipairs(p.containers) do
							aboard = string.format("%s   %s",aboard,c)
						end
						comms_source:addToShipLog(aboard,"95,158,160")
					else
						comms_source:addToShipLog("   None","95,158,160")
					end
				end
			end
		end)
	end
	return option_count
end
function showPatrolCircuitStatus()
	local option_count = 0
	if not comms_source.uniform_plague_mission then
		if comms_target == station_headquarters or comms_target == station_med_TSN or comms_target == station_large_USN or comms_target == station_huge_CUF then
			option_count = option_count + 1
			addCommsReply("Show my patrol circuit status",function()
				local out = string.format("Circuits completed by %s: %i",comms_source:getCallSign(),comms_source.patrol_circuits)
				if #comms_source.patrol_points > 0 then
					out = string.format("%s\nStations visited on current circuit:",out)
					for i,station in ipairs(comms_source.patrol_points) do
						if station:isValid() then
							out = string.format("%s   %s",out,station:getCallSign())
						else
							out = string.format("%s   unknown (destroyed)",out)
						end
					end
				else
					out = string.format("%s\nNo stations yet visited on current circuit",out)
				end
				out = string.format("%s\nFull circuit:",out)
				for i,station in ipairs(patrol_points) do
					if station:isValid() then
						out = string.format("%s   %s",out,station:getCallSign())
					end
				end
				setCommsMessage(out)
			end)
		end
	end
	return option_count
end
function getResearchContainer()
	local option_count = 0
	if station_research_delivery ~= nil and station_research_delivery:isValid() then
		local may_provide_research = false
		for i,station in ipairs(expansion_stations) do
			if station ~= nil and station:isValid() then
				if comms_target == station then
					if not comms_source:isEnemy(comms_target) then
						may_provide_research = true
						break
					end
				end
			end
		end
		if may_provide_research then
			if station_research_delivery.containers == nil then
				station_research_delivery.containers = {
					"Human Navy"
				}
			end
			local delivered = false
			for i,c in ipairs(station_research_delivery.containers) do
				if comms_target:getFaction() == c then
					delivered = true
					break
				end
			end
			if not delivered then
				local transit = false
				for i,p in ipairs(getActivePlayerShips()) do
					if p.containers ~= nil and #p.containers > 0 then
						for j,c in ipairs(p.containers) do
							if comms_target:getFaction() == c then
								transit = true
								break
							end
						end
						if transit then
							break
						end
					end
				end
				if not transit then
					option_count = 1
					addCommsReply(string.format("Get research and samples for %s",comms_target:getFaction()),function()
						setCommsMessage(string.format("Research and samples obtained for %s",comms_target:getFaction()))
						if comms_source.containers == nil then
							comms_source.containers = {}
						end
						table.insert(comms_source.containers,comms_target:getFaction())
					end)
				end
			end
		end
	end
	return option_count
end
function deliverResearchContainers()
	local option_count = 0
	if comms_source.containers ~= nil and #comms_source.containers > 0 then
		if comms_target == station_research_delivery then
			option_count = 1
			addCommsReply("Deliver research containers",function()
				local delivered = {}
				if comms_target.containers == nil then
					comms_target.containers = {}
				end
				for i,c in ipairs(comms_source.containers) do
					if #comms_target.containers > 0 then
						local match = false
						for j,faction in ipairs(comms_target.containers) do
							if c == faction then
								match = true
								break
							end
						end
						if not match then
							table.insert(comms_target.containers,c)
							table.insert(delivered,c)
						end
					end
				end
				if #delivered > 0 then
					local out = "Delivered research for faction"
					if #delivered > 1 then
						out = "Delivered research for factions"
					end
					for i,f in ipairs(delivered) do
						out = string.format("%s\n   %s",out,f)
					end
					setCommsMessage(out)
				else
					setCommsMessage("Research already obtained for factions delivered. No new faction research delivered.")
				end
				comms_source.containers = {}
			end)
		end
	end
	return option_count
end
function wormholeGuide()
	local option_count = 0
	if station_asteroids_a_far_h ~= nil and station_asteroids_a_far_h:isValid() then
		if comms_target == station_asteroids_a_far_h then
			if station_asteroids_a_far_h.wormhole_guide  and not comms_source.wormhole_guide then
				option_count = 1
				addCommsReply("Install wormhole guide (50 reputation)",function()
					if comms_source:takeReputationPoints(50) then
						comms_source.wormhole_guide = true
						setCommsMessage("Wormhole guide installed")
					else
						setCommsMessage("Insufficient reputation")
					end
				end)
			end
		end
	end
	return option_count
end
function uniformPlague()
	local option_count = 0
	if comms_target == station_headquarters then
		if station_headquarters.uniform_plague_mission and not comms_source.uniform_plague_mission then
			option_count = 1
			addCommsReply("Plague Research",function()
				local out = string.format("You destroyed the aggressive enemy stations in this region. With %i reputation out of a goal of %i reputation, you have completed %i%% of your primary mission goal.",math.floor(comms_source:getReputationPoints()),reputation_goal,math.floor(comms_source:getReputationPoints()/reputation_goal*100))
				out = string.format("%s Some kind of plague has affected all factions in a number of regions around the galaxy. The only region that seems to be immune is known as The Strip. Scientists in all factions in The Strip have agreed to pool their research to find out why this plague is so pervasive and how it might be stopped.",out)
				out = string.format("%s If you accept this mission, it would supercede your reputation based mission.",out)
				if #getActivePlayerShips() > 1 then
					out = string.format("%s All player ships would need to accept this plague research mission.",out)
				end
				setCommsMessage(out)
				addCommsReply("Accept Plague Research Mission",function()
					comms_source.uniform_plague_mission = true
					local out = string.format("The quickest way to The Strip is through the wormhole in sector %s.",wormhole_to_expanse:getSectorName())
					out = string.format("%s Be careful when traversing the wormhole. Ship systems have been known to be damaged. Raising shields helps. Also, Exuari ships prey on anyone coming through the wormhole.",out)
					if station_asteroids_a_far_h ~= nil and station_asteroids_a_far_h:isValid() then
						out = string.format("%s The Arlenians on station %s in sector %s can install a wormhole guidance system to prevent most of the system damage.",out,station_asteroids_a_far_h:getCallSign(),station_asteroids_a_far_h:getSectorName())
					end
					setCommsMessage(out)
					addCommsReply("What do we do in The Strip?",function()
						setCommsMessage(string.format("Dock at a station from each faction. Collect any research and related samples they have completed. Deliver research and samples to station %s in sector %s",station_research_delivery:getCallSign(),station_research_delivery:getSectorName()))
						addCommsReply("What about enemy factions?",function()
							setCommsMessage("You have been equipped with standardized research containers. Contact the enemy faction station scientist. Launch the research container. They will load the container and return it to you. You'll need to retrieve it. The military leaders may be unaware of this cooperative research effort, so you may have to retrieve the research under fire.")
							addCommsReply(string.format("Should we worry about station %s",station_research_delivery:getCallSign()),function()
								setCommsMessage(string.format("Yes. If %s is destroyed, the mission is a failure. The same is true of the research stations: if they get destroyed before you retrieve the research, the mission is a failure.",station_research_delivery:getCallSign()))
							end)
						end)
					end)
				end)
			end)
		end
	end
	return option_count
end
function commsEnemyStation()
	if distance(comms_source,comms_target) < 5000 then
		if comms_target.container_status == nil then
			setCommsMessage("Ready to receive research container.")
			addCommsReply("Launch container",function()
				createContainer()
				setCommsMessage("Container launched")
			end)
		elseif comms_target.container_status == "in transit to station" then
			setCommsMessage(string.format("Research container is in transit to station %s",comms_target:getCallSign()))
		elseif comms_target.container_status == "being loaded" then
			setCommsMessage(string.format("Research container arrived at station %s and is being loaded with data and samples.",comms_target:getCallSign()))
		elseif comms_target.container_status == "returning to ship" then
			setCommsMessage(string.format("Research container with samples and data in transit from station %s to original launch point.",comms_target:getCallSign()))
		elseif comms_target.container_status == "awaiting retrieval" then
			setCommsMessage(string.format("Research container from station %s with data and samples awaiting retrieval at original launch point.",comms_target:getCallSign()))
		elseif comms_target.container_status == "retrieved" then
			setCommsMessage("Research container has been retrieved")
			addCommsReply("Data lost. We need another copy.",function()
				setCommsMessage("Ready to receive another research container.")
				addCommsReply("Launch another container (50 reputation)",function()
					if comms_source:takeReputationPoints(50) then
						createContainer()
						setCommsMessage("Container launched")
					else
						setCommsMessage("Insufficient reputation")
					end
				end)
			end)
		end
	else
		setCommsMessage(string.format("Scientist on station %s will only connect communications if ship is within 5 units",comms_target:getCallSign()))
	end
end
function createContainer()
	local origin_x, origin_y = comms_source:getPosition()
	local rdx, rdy = vectorFromAngle(random(0,360),player_ship_stats[comms_source:getTypeName()].distance + 100,true)
	origin_x = origin_x + rdx
	origin_y = origin_y + rdy
	local destination_x, destination_y = comms_target:getPosition()
	local a = Artifact():setPosition(origin_x, origin_y):setModel("ammo_box"):allowPickup(false)
	a.origin_x = origin_x
	a.origin_y = origin_y
	a.destination_x = destination_x
	a.destination_y = destination_y
	a.angle = angleHeading(origin_x, origin_y, destination_x, destination_y)
--	print("container angle:",a.angle)
	a:setDescriptions("Research collection container","Research collection container in transit to station")
	a:setScanningParameters(1,1)
	a.blink_colors = {
		{r = 0,		g = 255,	b = 0},		--green
		{r = 173,	g = 216,	b = 230},	--blue
	}
	a.blink_index = 1
	a.launch_time = getScenarioTime()
	a.travel_time = 30
	a.arrival_time = a.launch_time + a.travel_time
	a.start_distance = distance(origin_x, origin_y, destination_x, destination_y)
	a.container_status = "in transit to station"
	a.station = comms_target
	a.faction = comms_target:getFaction()
	comms_target.container_status = a.container_status
	a:onPickUp(retrieveContainer)
	table.insert(research_containers,a)
	table.insert(blinking_artifacts,a)
end
function retrieveContainer(self,p)
	if self.station:isValid() then
		self.station.container_status = "retrieved"
	end
	if p.containers == nil then
		p.containers = {}
	end
	table.insert(p.containers,self.faction)
end
--	update related functions
function updatePlayerTrackPatrolPoint(p)
	if p.patrol_points == nil then
		p.patrol_points = {}
		p.patrol_circuits = 0
	elseif #p.patrol_points >= #patrol_points then
		p.patrol_points = {}
		p.patrol_circuits = p.patrol_circuits + 1
		p:addReputationPoints(20)
	end
	for i,patrol_point in ipairs(patrol_points) do
		if patrol_point ~= nil and patrol_point:isValid() then
			local met = false
			for j,met_patrol_point in ipairs(p.patrol_points) do
				if met_patrol_point == patrol_point then
					met = true
					break
				end
			end
			if not met then
				if p:isDocked(patrol_point) and p:getFaction() == "Human Navy" then
					table.insert(p.patrol_points,patrol_point)
					p:addReputationPoints(20)
				end
			end
		else
			patrol_points[i] = patrol_points[#patrol_points]
			patrol_points[#patrol_points] = nil
			break
		end
	end
end
function updatePlayerInitialPatrolMissionMessage(p)
	if getScenarioTime() > initial_message_time then
		if not p.initialPatrolMissionMessage then
			if availableForComms(p) then
				station_headquarters:sendCommsMessage(p,string.format("Your orders, %s:\nPatrol these friendly stations:\n%s %s\n%s %s\n%s %s\n%s %s\nYou need to dock with each one for the patrol circuit to be marked as complete. As you patrol, destroy enemies, and/or complete missions, your reputation will increase. Your goal is to get %i or more reputation.",p:getCallSign(),station_headquarters:getFaction(),station_headquarters:getCallSign(),station_med_TSN:getFaction(),station_med_TSN:getCallSign(),station_large_USN:getFaction(),station_large_USN:getCallSign(),station_huge_CUF:getFaction(),station_huge_CUF:getCallSign(),reputation_goal))
				p.initialPatrolMissionMessage = true
				primary_orders = string.format("Patrol friendly stations %s, %s, %s, and %s. Gather %s reputation.",station_headquarters:getCallSign(),station_med_TSN:getCallSign(),station_large_USN:getCallSign(),station_huge_CUF:getCallSign(),reputation_goal)
			end
		end
	end
end
function updatePlayerIFFFailureCheck(p)
	if IFF_fail_time ~= nil then
		if p.switch_iff_count == nil then
			p.switch_iff_count = 5
		end
		if p.switch_iff_count > 0 then
			if p:getFaction() == "TSN" then
				if station_eye_ghost:isValid() then
					if not p:isDocked(station_eye_ghost) then
						if getScenarioTime() > IFF_fail_time then
							p:setFaction("Human Navy")
							p.switch_iff_count = p.switch_iff_count - 1
							IFF_fail_time = getScenarioTime() + .5
							p.IFF_fail = true
							if IFF_fail_message_time == nil then
								IFF_fail_message_time = getScenarioTime() + 5
							end
						end
					end
				else
					if getScenarioTime() > IFF_fail_time then
						p:setFaction("Human Navy")
						p.switch_iff_count = p.switch_iff_count - 1
						IFF_fail_time = getScenarioTime() + .5
						p.IFF_fail = true
						if IFF_fail_message_time == nil then
							IFF_fail_message_time = getScenarioTime() + 5
						end
					end
				end
			else
				if getScenarioTime() > IFF_fail_time then
					p:setFaction("TSN")
					p.switch_iff_count = p.switch_iff_count - 1
					IFF_fail_time = getScenarioTime() + .5
				end
			end
		else
			p:setFaction("Human Navy")
			IFF_fail_time = nil
		end
	end
	if IFF_fail_message_time ~= nil then
		if p.IFF_fail then
			if getScenarioTime() > IFF_fail_message_time then
				p:addToShipLog(string.format("The IFF change to TSN has failed. %s has reverted to Human Navy",p:getCallSign()),"Red")
				IFF_fail_message_time = nil
			end
		end
	end
end
function updatePlayerShipNameBanner(p)
	p.ship_name_banner_hlm = "ship_name_banner_hlm"
	p:addCustomInfo("Helms",p.ship_name_banner_hlm,string.format("%s %s in %s",p:getFaction(),p:getCallSign(),p:getSectorName()),1)
	p.ship_name_banner_rel = "ship_name_banner_rel"
	p:addCustomInfo("Relay",p.ship_name_banner_rel,string.format("%s %s in %s",p:getFaction(),p:getCallSign(),p:getSectorName()),1)
	p.ship_name_banner_tac = "ship_name_banner_tac"
	p:addCustomInfo("Tactical",p.ship_name_banner_tac,string.format("%s %s in %s",p:getFaction(),p:getCallSign(),p:getSectorName()),1)
	p.ship_name_banner_ops = "ship_name_banner_ops"
	p:addCustomInfo("Operations",p.ship_name_banner_ops,string.format("%s %s in %s",p:getFaction(),p:getCallSign(),p:getSectorName()),1)
end
function updatePlayerStarHeat(delta,p)
	if p:isValid() then
		if star_fixed:isValid() then
			local star_distance = distance(star_fixed,p)
			if star_distance < 20000 then
				local base_heat = .05
				local heat_impact = delta * (1 - (star_distance/100000)) * base_heat
				if p:getShieldsActive() then
					heat_impact = heat_impact/2
				end
				local system_heat_list = {
					["reactor"] = {before = p:getSystemHeat("reactor"), after = 0},
					["beamweapons"] = {before = p:getSystemHeat("beamweapons"), after = 0},
					["missilesystem"] = {before = p:getSystemHeat("missilesystem"), after = 0},
					["maneuver"] = {before = p:getSystemHeat("maneuver"), after = 0},
					["impulse"] = {before = p:getSystemHeat("impulse"), after = 0},
					["warp"] = {before = p:getSystemHeat("warp"), after = 0},
					["jumpdrive"] = {before = p:getSystemHeat("jumpdrive"), after = 0},
					["frontshield"] = {before = p:getSystemHeat("frontshield"), after = 0},
					["rearshield"] = {before = p:getSystemHeat("rearshield"), after = 0},				
				}
				for system, heat in pairs(system_heat_list) do
					if p:hasSystem(system) then
						p:setSystemHeat(system,heat.before + heat_impact)
					end
				end
			end
		end
	end
end
function updatePlayerInNebula(delta,p)
	local inside_gain_coolant_nebula = false
	local inside_lose_beam_range_nebula = false
	local inside_gain_beam_range_nebula = false
	local gain_coolant_nebulae = {}
	local lose_beam_range_nebulae = {}
	local gain_beam_range_nebulae = {}
	local obj_list = p:getObjectsInRange(5100)
	if #anomalous_nebulae > 0 then 
		for i,obj in ipairs(obj_list) do
			if isObjectType(obj,"Nebula") then
				for j,neb in ipairs(anomalous_nebulae) do
					if neb.name ~= nil and neb == obj then
						if distance(p,neb) <= 5000 then
							if neb.name == "-C" then
								p:setMaxCoolant(p:getMaxCoolant()*neb.coolant_loss)
								if p:getMaxCoolant() > 30 and random(1,100) <= 13 then
									local engine_choice = math.random(1,3)
									local adverse_effect = .995
									if engine_choice == 1 then
										p:setSystemHealth("impulse",p:getSystemHealth("impulse")*adverse_effect)
									elseif engine_choice == 2 then
										if p:hasWarpDrive() then
											p:setSystemHealth("warp",p:getSystemHealth("warp")*adverse_effect)
										end
									else
										if p:hasJumpDrive() then
											p:setSystemHealth("jumpdrive",p:getSystemHealth("jumpdrive")*adverse_effect)
										end
									end
								end
							end
							if neb.name == "+C" then
								inside_gain_coolant_nebula = true
								table.insert(gain_coolant_nebulae,neb)
							end
							if neb.name == "-BR" then
								inside_lose_beam_range_nebula = true
								table.insert(lose_beam_range_nebulae,neb)
							end
							if neb.name == "+BR" then
								inside_gain_beam_range_nebula = true
								table.insert(gain_beam_range_nebulae,neb)
							end
							if neb.name == "-SC" then
								if p:getShieldCount() > 0 then
									local charge_loss_cap = p:getShieldMax(0)*0.1
									local adjusted_shield = p:getShieldLevel(0)*neb.shield_loss
									if adjusted_shield > charge_loss_cap then
										if p:getShieldCount() == 1 then
											p:setShields(adjusted_shield)
										else
											p:setShields(adjusted_shield,p:getShieldLevel(1))
										end
									end
									if p:getShieldCount() > 1 then
										charge_loss_cap = p:getShieldMax(1)*0.1
										adjusted_shield = p:getShieldLevel(1)*neb.shield_loss
										if adjusted_shield > charge_loss_cap then
											p:setShields(p:getShieldLevel(0),adjusted_shield)
										end
									end
								end
							end
							if neb.name == "+SC" then
								if p:getShieldCount() > 0 then
									local charge_gain_cap = p:getShieldMax(0)*1.25
									local adjusted_shield = p:getShieldLevel(0)*neb.shield_gain
									if adjusted_shield < charge_gain_cap then
										if p:getShieldCount() == 1 then
											p:setShields(adjusted_shield)
										else
											p:setShields(adjusted_shield,p:getShieldLevel(1))
										end
									end
									if p:getShieldCount() > 1 then
										charge_gain_cap = p:getShieldMax(1)*1.25
										adjusted_shield = p:getShieldLevel(1)*neb.shield_gain
										if adjusted_shield < charge_gain_cap then
											p:setShields(p:getShieldLevel(0),adjusted_shield)
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
	if inside_gain_coolant_nebula then
		if p.get_coolant then
			if p.coolant_trigger then
				updateCoolantGivenPlayer(p,delta,gain_coolant_nebulae)
			end
		else
			if p:hasPlayerAtPosition("Engineering") then
				p.get_coolant_button = "get_coolant_button"
				p:addCustomButton("Engineering",p.get_coolant_button,"Get Coolant",function() 
					string.format("")
					getCoolantGivenPlayer(p) 
				end, 24)
				p.get_coolant = true
			end
			if p:hasPlayerAtPosition("Engineering+") then
				p.get_coolant_button_plus = "get_coolant_button_plus"
				p:addCustomButton("Engineering+",p.get_coolant_button_plus,"Get Coolant",function() 
					string.format("")
					getCoolantGivenPlayer(p) 
				end, 24)
				p.get_coolant = true
			end
		end
	else
		p.get_coolant = false
		p.coolant_trigger = false
		p.configure_coolant_timer = nil
		p.deploy_coolant_timer = nil
		if p:hasPlayerAtPosition("Engineering") then
			if p.get_coolant_button ~= nil then
				p:removeCustom(p.get_coolant_button)
				p.get_coolant_button = nil
			end
			if p.gather_coolant ~= nil then
				p:removeCustom(p.gather_coolant)
				p.gather_coolant = nil
			end
		end
		if p:hasPlayerAtPosition("Engineering+") then
			if p.get_coolant_button_plus ~= nil then
				p:removeCustom(p.get_coolant_button_plus)
				p.get_coolant_button_plus = nil
			end
			if p.gather_coolant_plus ~= nil then
				p:removeCustom(p.gather_coolant_plus)
				p.gather_coolant_plus = nil
			end
		end
	end
	local range_differential = 1
	if inside_lose_beam_range_nebula and inside_gain_beam_range_nebula then
		if p.normal_beam_range == nil then
			p.normal_beam_range = {}
			for i=0,15 do
				if p:getBeamWeaponRange(i) > 1 then
					p.normal_beam_range[i] = p:getBeamWeaponRange(i)
				end
			end
		end
		for i,neb in ipairs(lose_beam_range_nebulae) do
			if neb.beam_range_loss ~= nil then
				range_differential = math.min(range_differential,neb.beam_range_loss)
			end
		end
		for i=0,15 do
			local rng = p:getBeamWeaponRange(i)
			if rng > 1 then
				local arc = p:getBeamWeaponArc(i)
				local dir = p:getBeamWeaponDirection(i)
				local cyc = p:getBeamWeaponCycleTime(i)
				local dmg = p:getBeamWeaponDamage(i)
				p:setBeamWeapon(i,arc,dir,p.normal_beam_range[i]*range_differential,cyc,dmg)
			end
		end
		range_differential = 1
		for i,neb in ipairs(gain_beam_range_nebulae) do
			if neb.beam_range_gain ~= nil then
				range_differential = math.max(range_differential,neb.beam_range_gain)
			end
		end
		for i=0,15 do
			local rng = p:getBeamWeaponRange(i)
			if rng > 1 then
				local arc = p:getBeamWeaponArc(i)
				local dir = p:getBeamWeaponDirection(i)
				local cyc = p:getBeamWeaponCycleTime(i)
				local dmg = p:getBeamWeaponDamage(i)
				p:setBeamWeapon(i,arc,dir,rng*range_differential,cyc,dmg)
			end
		end
	elseif inside_lose_beam_range_nebula then
		if p.normal_beam_range == nil then
			p.normal_beam_range = {}
			for i=0,15 do
				if p:getBeamWeaponRange(i) > 1 then
					p.normal_beam_range[i] = p:getBeamWeaponRange(i)
				end
			end
		end
		for i,neb in ipairs(lose_beam_range_nebulae) do
			if neb.beam_range_loss ~= nil then
				range_differential = math.min(range_differential,neb.beam_range_loss)
			end
		end
		for i=0,15 do
			local rng = p:getBeamWeaponRange(i)
			if rng > 1 then
				local arc = p:getBeamWeaponArc(i)
				local dir = p:getBeamWeaponDirection(i)
				local cyc = p:getBeamWeaponCycleTime(i)
				local dmg = p:getBeamWeaponDamage(i)
				p:setBeamWeapon(i,arc,dir,p.normal_beam_range[i]*range_differential,cyc,dmg)
			end
		end
	elseif inside_gain_beam_range_nebula then
		if p.normal_beam_range == nil then
			p.normal_beam_range = {}
			for i=0,15 do
				if p:getBeamWeaponRange(i) > 1 then
					p.normal_beam_range[i] = p:getBeamWeaponRange(i)
				end
			end
		end
		for i,neb in ipairs(gain_beam_range_nebulae) do
			if neb.beam_range_gain ~= nil then
				range_differential = math.max(range_differential,neb.beam_range_gain)
			end
		end
		for i=0,15 do
			local rng = p:getBeamWeaponRange(i)
			if rng > 1 then
				local arc = p:getBeamWeaponArc(i)
				local dir = p:getBeamWeaponDirection(i)
				local cyc = p:getBeamWeaponCycleTime(i)
				local dmg = p:getBeamWeaponDamage(i)
				p:setBeamWeapon(i,arc,dir,p.normal_beam_range[i]*range_differential,cyc,dmg)
			end
		end
	else
		if p.normal_beam_range ~= nil then
			for i=0,15 do
				local rng = p:getBeamWeaponRange(i)
				if rng > 1 then
					local arc = p:getBeamWeaponArc(i)
					local dir = p:getBeamWeaponDirection(i)
					local cyc = p:getBeamWeaponCycleTime(i)
					local dmg = p:getBeamWeaponDamage(i)
					p:setBeamWeapon(i,arc,dir,p.normal_beam_range[i],cyc,dmg)
				end
			end
			p.normal_beam_range = nil
		end
	end
end
function updatePlayerStripGuideArtifact(p)
	local sgx, sgy = vectorFromAngle(random(10,170),12000,true)
	sgx = sgx + expanse_x
	sgy = sgy + expanse_y
	local sga = Artifact():setPosition(sgx,sgy):setModel("SensorBuoyMKII")
	sga:setDescriptions("Automated data gathering device","Guide to stations in The Strip")
	sga:setScanningParameters(1,1):allowPickup(true)
	sga:onPickUp(addGuideButton)
end
function addGuideButton(self,p)
	string.format("")
	p.guide_button_rel = "guide_button_rel"
	p:addCustomButton("Relay",p.guide_button_rel,"Station Guide",function()
		string.format("")
		local out = stripGuide(p)
		p.station_guide_rel = "station_guide_rel"
		p:addCustomMessage("Relay",p.station_guide_rel,out)
	end)
	p.guide_button_ops = "guide_button_ops"
	p:addCustomButton("Operations",p.guide_button_ops,"Station Guide",function()
		string.format("")
		local out = stripGuide(p)
		p.station_guide_ops = "station_guide_ops"
		p:addCustomMessage("Operations",p.station_guide_ops,out)
	end)
end
function stripGuide(p)
	local station_details = {}
	local px, py = p:getPosition()
	for i,station in ipairs(expansion_stations) do
		if station ~= nil and station:isValid() then
			local sx, sy = station:getPosition()
			table.insert(station_details,{sector=station:getSectorName(),name=station:getCallSign(),faction=station:getFaction(),dist=distance(px,py,sx,sy),bear=angleHeading(px,py,sx,sy)})
		end
	end
	table.sort(station_details,function(a,b)
		return a.dist < b.dist
	end)
	local out = "Sector Name Faction Distance Bearing"
	for i,station in ipairs(station_details) do
		out = string.format("%s\n%s %s %s %.1fU %.1f",out,station.sector,station.name,station.faction,station.dist/1000,station.bear)
	end
	return out
end
function updateCoolantGivenPlayer(p, delta, gain_coolant_nebulae)
	if p.configure_coolant_timer == nil then
		p.configure_coolant_timer = delta + 5
	end
	p.configure_coolant_timer = p.configure_coolant_timer - delta
	if p.configure_coolant_timer < 0 then
		if p.deploy_coolant_timer == nil then
			p.deploy_coolant_timer = delta + 5
		end
		p.deploy_coolant_timer = p.deploy_coolant_timer - delta
		if p.deploy_coolant_timer < 0 then
			gather_coolant_status = "Gathering Coolant"
			local player_coolant_gain = 0
			for c,neb in ipairs(gain_coolant_nebulae) do
				player_coolant_gain = math.max(player_coolant_gain,neb.coolant_gain)
			end
			p:setMaxCoolant(p:getMaxCoolant() + player_coolant_gain)
			if p:getMaxCoolant() > 30 and random(1,100) <= 13 then
				local engine_choice = math.random(1,3)
				local adverse_effect = .995
				if engine_choice == 1 then
					p:setSystemHealth("impulse",p:getSystemHealth("impulse")*adverse_effect)
				elseif engine_choice == 2 then
					if p:hasWarpDrive() then
						p:setSystemHealth("warp",p:getSystemHealth("warp")*adverse_effect)
					end
				else
					if p:hasJumpDrive() then
						p:setSystemHealth("jumpdrive",p:getSystemHealth("jumpdrive")*adverse_effect)
					end
				end
			end
		else
			gather_coolant_status = string.format("Deploying Collectors %i",math.ceil(p.deploy_coolant_timer - delta))
		end
	else
		gather_coolant_status = string.format("Configuring Collectors %i",math.ceil(p.configure_coolant_timer - delta))
	end
	if p:hasPlayerAtPosition("Engineering") then
		p.gather_coolant = "gather_coolant"
		p:addCustomInfo("Engineering",p.gather_coolant,gather_coolant_status, 5)
	end
	if p:hasPlayerAtPosition("Engineering+") then
		p.gather_coolant_plus = "gather_coolant_plus"
		p:addCustomInfo("Engineering+",p.gather_coolant_plus,gather_coolant_status, 5)
	end
end
function getCoolantGivenPlayer(p)
	if p:hasPlayerAtPosition("Engineering") then
		if p.get_coolant_button ~= nil then
			p:removeCustom(p.get_coolant_button)
			p.get_coolant_button = nil
		end
	end
	if p:hasPlayerAtPosition("Engineering+") then
		if p.get_coolant_button_plus ~= nil then
			p:removeCustom(p.get_coolant_button_plus)
			p.get_coolant_button_plus = nil
		end
	end
	p.coolant_trigger = true
end
function updatePlayerLongRangeSensors(delta,p)
	local free_sensor_boost = false
	local sensor_boost_present = false
	local sensor_boost_amount = 0
	local base_range = p.normal_long_range_radar
	if p.station_sensor_boost ~= nil then
		base_range = base_range + p.station_sensor_boost
	end
	if p:getDockedWith() == nil then
		base_range = p.normal_long_range_radar
		p.station_sensor_boost = nil
	end
	if p.power_sensor_interval ~= nil and p.power_sensor_interval > 0 and p:getEnergyLevel() > p:getEnergyLevelMax()*.05 then
		if p.power_sensor_state == nil then
			p.power_sensor_state = "disabled"
		end
		if p.power_sensor_state == "disabled" then
			p.power_sensor_state = "standby"
			updatePowerSensorButtons(p)
		elseif p.power_sensor_state == "enabled" then
			base_range = base_range + (1000 * p.power_sensor_interval * p.power_sensor_level)
			local power_decrement = delta*p.power_sensor_level*2
--			print("boost sensor power drain value:",power_decrement,"before energy:",p:getEnergyLevel())
			p:setEnergyLevel(p:getEnergyLevel() - power_decrement)
--			print("after:",p:getEnergyLevel())
		end
	else
		if p.power_sensor_state ~= nil then
			p.power_sensor_state = "disabled"
			updatePowerSensorButtons(p)
		end
	end
	local impact_range = math.max(base_range*sensor_impact,p:getShortRangeRadarRange())
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
	local probe_scan_boost_impact = 0
	if boost_probe_list ~= nil then
		for boost_probe_index, boost_probe in ipairs(boost_probe_list) do
			if boost_probe ~= nil and boost_probe:isValid() then
				if specialty_probe_diagnostic then
					print("Processing specialty probe in list, index:",boost_probe_index,"player:",p:getCallSign())
				end
				if distance_diagnostic then
					print("distance_diagnostic 24 boost_probe:",boost_probe,"p:",p)
				end		
				local boost_probe_distance = distance(boost_probe,p)
				if boost_probe_distance < boost_probe.range*1000 then
					if boost_probe_distance < boost_probe.range*1000/2 then
						if specialty_probe_diagnostic then
							print("current probe scan impact:",probe_scan_boost_impact)
						end
						probe_scan_boost_impact = math.max(probe_scan_boost_impact,boost_probe.boost*1000)
					else
						local best_boost = boost_probe.boost*1000
						local adjusted_range = boost_probe.range*1000
						local half_adjusted_range = adjusted_range/2
						local raw_scan_gradient = boost_probe_distance/half_adjusted_range
						local scan_gradient = 2 - raw_scan_gradient
						if specialty_probe_diagnostic then
							print("boost:",boost_probe.boost,"distance:",boost_probe_distance,"range:",boost_probe.range)
							print("best boost:",best_boost,"adjusted range:",adjusted_range,"half adjusted range:",half_adjusted_range,"raw scan gradient:",raw_scan_gradient,"scan gradient:",scan_gradient)
							print("current probe scan impact:",probe_scan_boost_impact)
						end
						probe_scan_boost_impact = math.max(probe_scan_boost_impact,best_boost * scan_gradient)
					end
					if specialty_probe_diagnostic then
						print("In range. Range:",boost_probe.range*1000,"distance:",boost_probe_distance,"new probe scan impact:",probe_scan_boost_impact)
					end
				end
			else
				boost_probe_list[boost_probe_index] = boost_probe_list[#boost_probe_list]
				boost_probe_list[#boost_probe_list] = nil
				if specialty_probe_diagnostic then
					print("Specialty probe deleted from list. Index:",boost_probe_index)
				end
				break
			end
		end
	end
	impact_range = math.max(p:getShortRangeRadarRange(),impact_range + probe_scan_boost_impact)
	p:setLongRangeRadarRange(impact_range)
end
function improvedStationService(p)
	if p.instant_energy ~= nil then
		if #p.instant_energy > 0 then
			for i,station in ipairs(p.instant_energy) do
				if station:isValid() then
					if p:isDocked(station) then
						p:setEnergyLevel(p:getEnergyLevelMax())
					end
				else
					p.instant_energy[i] = p.instant_energy[#p.instant_energy]
					p.instant_energy[#p.instant_energy] = nil
					break
				end
			end
		else
			p.instant_energy = nil
		end
	end
	if p.instant_hull ~= nil then
		if #p.instant_hull > 0 then
			for i,station in ipairs(p.instant_hull) do
				if station:isValid() then
					if p:isDocked(station) then
						p:setHull(p:getHullMax())
					end
				else
					p.instant_hull[i] = p.instant_hull[#p.instant_hull]
					p.instant_hull[#p.instant_hull] = nil
					break
				end
			end
		else
			p.instant_hull = nil
		end
	end
	if p.instant_probes ~= nil then
		if #p.instant_probes > 0 then
			for i,station in ipairs(p.instant_probes) do
				if station:isValid() then
					if p:isDocked(station) then
						p:setScanProbeCount(p:getMaxScanProbeCount())
					end
				else
					p.instant_probes[i] = p.instant_probes[#p.instant_probes]
					p.instant_probes[#p.instant_probes] = nil
				end
			end
		else
			p.instant_probes = nil
		end
	end
end
function updateOrbitingPlatforms()
	for i,dp in ipairs(orbiting_platforms) do
		if dp ~= nil and dp:isValid() then
			dp.angle = dp.angle + .01
			local x, y = vectorFromAngle(dp.angle,dp.dist,true)
			dp:setPosition(dp.focus_x + x, dp.focus_y + y)
		else
			orbiting_platforms[i] = orbiting_platforms[#orbiting_platforms]
			orbiting_platforms[#orbiting_platforms] = nil
			break
		end
	end
end
function updateAggressiveFactions()
	if station_aggressive_kraylor ~= nil and station_aggressive_kraylor:isValid() then
		local kraylor_power = 0
		local clean_list = true
		if #kraylor_defenders > 0 then
			for i,ship in ipairs(kraylor_defenders) do
				if ship ~= nil and ship:isValid() then
					kraylor_power = kraylor_power + ship_template[ship:getTypeName()].strength
				else
					kraylor_defenders[i] = kraylor_defenders[#kraylor_defenders]
					kraylor_defenders[#kraylor_defenders] = nil
					clean_list = false
					break
				end
			end
			if clean_list then
				if kraylor_power < (playerPower() * .2) then
					if kraylor_defend_time == nil or getScenarioTime() > kraylor_defend_time then
						fleetSpawnFaction = "Kraylor"
						local sx, sy = station_aggressive_kraylor:getPosition()
						local fleet = spawnRandomArmed(sx, sy)
						for i,ship in ipairs(fleet) do
							ship:orderDefendTarget(station_aggressive_kraylor)
							table.insert(kraylor_defenders,ship)
						end
						kraylor_defend_time = getScenarioTime() + 250 + random(1,100)
					end
				else
					if #kraylor_attackers > 0 then
						kraylor_power = 0
						for i,ship in ipairs(kraylor_attackers) do
							if ship ~= nil and ship:isValid() then
								kraylor_power = kraylor_power + ship_template[ship:getTypeName()].strength
							else
								kraylor_attackers[i] = kraylor_attackers[#kraylor_attackers]
								kraylor_attackers[#kraylor_attackers] = nil
								clean_list = false
								break
							end
						end
						if clean_list then
							if kraylor_power < (playerPower() * .2) then
								if kraylor_attack_time == nil or getScenarioTime() > kraylor_attack_time then
									fleetSpawnFaction = "Kraylor"
									local sx, sy = station_aggressive_kraylor:getPosition()
									local fleet = spawnRandomArmed(sx, sy)
									local tx, ty = station_huge_CUF:getPosition()
									for i,ship in ipairs(fleet) do
										ship:orderFlyTowards(tx, ty)
										table.insert(kraylor_attackers,ship)
									end
									kraylor_attack_time = getScenarioTime() + 500 + random(1,100)
								end
							end
						end
					else
						if kraylor_attack_time == nil or getScenarioTime() > kraylor_attack_time then
							fleetSpawnFaction = "Kraylor"
							local sx, sy = station_aggressive_kraylor:getPosition()
							local tx, ty = station_huge_CUF:getPosition()
							local fleet = spawnRandomArmed((sx + tx) / 2, (sy + ty) / 2)
							for i,ship in ipairs(fleet) do
								ship:orderFlyTowards(tx, ty)
								table.insert(kraylor_attackers,ship)
							end
							kraylor_attack_time = getScenarioTime() + 500 + random(1,100)
						end
					end
				end
			end
		else
			if kraylor_defend_time == nil or getScenarioTime() > kraylor_defend_time then
				fleetSpawnFaction = "Kraylor"
				local sx, sy = station_aggressive_kraylor:getPosition()
				local fleet = spawnRandomArmed(sx, sy)
				for i,ship in ipairs(fleet) do
					ship:orderDefendTarget(station_aggressive_kraylor)
					table.insert(kraylor_defenders,ship)
				end
				kraylor_defend_time = getScenarioTime() + 250 + random(1,100)
			end
		end
	else
		if not destroy_agressive_kraylor_station_mission_complete then
			for i,p in ipairs(getActivePlayerShips()) do
				if p.destroy_agressive_kraylor_station_mission then
					p:addReputationPoints(100)
					break
				end
			end
			destroy_agressive_kraylor_station_mission_complete = true
		end
	end
	if station_aggressive_ktlitans ~= nil and station_aggressive_ktlitans:isValid() then
		local ktlitan_power = 0
		local clean_list = true
		if #ktlitan_defenders > 0 then
			for i,ship in ipairs(ktlitan_defenders) do
				if ship ~= nil and ship:isValid() then
					ktlitan_power = ktlitan_power + ship_template[ship:getTypeName()].strength
				else
					ktlitan_defenders[i] = ktlitan_defenders[#ktlitan_defenders]
					ktlitan_defenders[#ktlitan_defenders] = nil
					clean_list = false
					break
				end
			end
			if clean_list then
				if ktlitan_power < (playerPower() * .2) then
					if ktlitan_defend_time == nil or getScenarioTime() > ktlitan_defend_time then
						fleetSpawnFaction = "Ktlitans"
						local sx, sy = station_aggressive_ktlitans:getPosition()
						local fleet = spawnRandomArmed(sx, sy)
						for i,ship in ipairs(fleet) do
							ship:orderDefendTarget(station_aggressive_ktlitans)
							table.insert(ktlitan_defenders,ship)
						end
						ktlitan_defend_time = getScenarioTime() + 250 + random(1,100)
					end
				else
					if #ktlitan_attackers > 0 then
						ktlitan_power = 0
						for i,ship in ipairs(ktlitan_attackers) do
							if ship ~= nil and ship:isValid() then
								ktlitan_power = ktlitan_power + ship_template[ship:getTypeName()].strength
							else
								ktlitan_attackers[i] = ktlitan_attackers[#ktlitan_attackers]
								ktlitan_attackers[#ktlitan_attackers] = nil
								clean_list = false
								break
							end
						end
						if clean_list then
							if ktlitan_power < (playerPower() * .2) then
								if ktlitan_attack_time == nil or getScenarioTime() > ktlitan_attack_time then
									fleetSpawnFaction = "Ktlitans"
									local sx, sy = station_aggressive_ktlitans:getPosition()
									local fleet = spawnRandomArmed(sx, sy)
									local tx, ty = station_large_USN:getPosition()
									for i,ship in ipairs(fleet) do
										ship:orderFlyTowards(tx, ty)
										table.insert(ktlitan_attackers,ship)
									end
									ktlitan_attack_time = getScenarioTime() + 500 + random(1,100)
								end
							end
						end
					else
						if ktlitan_attack_time == nil or getScenarioTime() > ktlitan_attack_time then
							fleetSpawnFaction = "Ktlitans"
							local sx, sy = station_aggressive_ktlitans:getPosition()
							local tx, ty = station_large_USN:getPosition()
							local fleet = spawnRandomArmed((sx + tx) / 2, (sy + ty) / 2)
							for i,ship in ipairs(fleet) do
								ship:orderFlyTowards(tx, ty)
								table.insert(ktlitan_attackers,ship)
							end
							ktlitan_attack_time = getScenarioTime() + 500 + random(1,100)
						end
					end
				end
			end
		else
			if kraylor_defend_time == nil or getScenarioTime() > kraylor_defend_time then
				fleetSpawnFaction = "Kraylor"
				local sx, sy = station_aggressive_kraylor:getPosition()
				local fleet = spawnRandomArmed(sx, sy)
				for i,ship in ipairs(fleet) do
					ship:orderDefendTarget(station_aggressive_kraylor)
					table.insert(kraylor_defenders,ship)
				end
				kraylor_defend_time = getScenarioTime() + 250 + random(1,100)
			end
		end
	else
		if not destroy_agressive_ktlitan_station_mission_complete then
			for i,p in ipairs(getActivePlayerShips()) do
				if p.destroy_agressive_ktlitan_station_mission then
					p:addReputationPoints(100)
					break
				end
			end
			destroy_agressive_ktlitan_station_mission_complete = true
		end
	end
end
function updateEstablishGhostDefenders()
	if ghost_defenders == nil then
		ghost_defenders = {}
		local fx, fy = station_eye_ghost:getPosition()
		fleetSpawnFaction = "Ghosts"
		local fleet = spawnRandomArmed(fx, fy)
		for i,ship in ipairs(fleet) do
			ship:orderDefendTarget(station_eye_ghost)
			table.insert(ghost_defenders,ship)
		end
		fleet = spawnRandomArmed(fx, fy)
		for i,ship in ipairs(fleet) do
			ship:orderDefendTarget(station_eye_ghost)
			table.insert(ghost_defenders,ship)
		end
	end
end
function updatePlanetCollisionDetection()
	local planet_bump_damage = 5
	for i, details in ipairs(planet_collision_list) do
--		print("Planet:",planet:getCallSign())
		local planet = details.planet
		local fudge = details.fudge
		local planet_x, planet_y = planet:getPosition()
		local collision_list = getObjectsInRadius(planet_x, planet_y, planet:getPlanetRadius() + 2000)
		local obj_dist = 0
		local ship_distance = 0
		local obj_type_name = ""
		for i, obj in ipairs(collision_list) do
			if obj:isValid() and obj ~= planet then
				obj_dist = distance(obj,planet)
				if isObjectType(obj,"CpuShip") then
					obj_type_name = obj:getTypeName()
					if obj_type_name ~= nil then
						ship_distance = ship_template_distance[obj:getTypeName()]
						if ship_distance == nil then
							print("distance not retrieved from ship template for cpu ship, template:",obj:getCallSign(),obj:getTypeName(),"defaulting to ship distance 400")
							ship_distance = 400
						end
					else
						print("type name nil on cpu ship:",obj:getCallSign(),"defaulting to ship distance 400")
						ship_distance = 400
					end
					local threshold = planet:getPlanetRadius() + ship_distance + fudge
--					print("Dist:",math.floor(obj_dist),"P-Rad:",math.floor(planet:getPlanetRadius()),"S-Rad",ship_distance,"Fudge:",fudge,"Thresh:",math.floor(threshold))
					if obj_dist <= threshold then
						obj:takeDamage(planet_bump_damage,"kinetic",planet_x,planet_y)
					end
				end
				if isObjectType(obj,"PlayerSpaceship") then
					obj_type_name = obj:getTypeName()
					if obj_type_name ~= nil then
						ship_distance = player_ship_stats[obj:getTypeName()].distance
						if ship_distance == nil then
							print("distance not retrieved from player ship stats for player ship:",obj:getCallSign(),"defaulting to ship distance 400")
							ship_distance = 400
						end
					else
						print("type name nil on player ship:",obj:getCallSign(),"defaulting to ship distance 400")
						ship_distance = 400
					end
					if obj_dist <= (planet:getPlanetRadius() + ship_distance + fudge) then
						obj:takeDamage(planet_bump_damage,"kinetic",planet_x,planet_y)
					end
				end
			end
		end
	end
end
function pickTargetAsteroid()
	if scanned_asteroid_count > 10 then
		local target_pool = {}
		for i,a in ipairs(research_asteroids) do
			if a.structure == asteroid_structure then
				if not a:isScannedByFaction("Human Navy") then
					if target_asteroid_sector == nil then
						table.insert(target_pool,a)
					else
						if a:getSectorName() == target_asteroid_sector then
							table.insert(target_pool,a)
						end
					end
				end
			end
		end
		if #target_pool > 0 then
			target_asteroid = tableSelectRandom(target_pool)
			target_asteroid.osmium = target_asteroid_notes.osmium
			target_asteroid.iridium = target_asteroid_notes.iridium
			target_asteroid.olivine = target_asteroid_notes.olivine
			target_asteroid.iron = target_asteroid_notes.iron
			local scanned_desc = string.format("Structure: %s",target_asteroid.structure)
			local unscanned_desc = scanned_desc
			scanned_desc = string.format("%s\nosmium:%.1f",scanned_desc,target_asteroid.osmium)
			scanned_desc = string.format("%s\niridium:%.1f",scanned_desc,target_asteroid.iridium)
			scanned_desc = string.format("%s\nolivine:%.1f",scanned_desc,target_asteroid.olivine)
			scanned_desc = string.format("%s\niron:%.1f",scanned_desc,target_asteroid.iron)
			scanned_desc = string.format("%s\nrock:remainder",scanned_desc)
			target_asteroid:setDescriptions(unscanned_desc,scanned_desc)
			target_asteroid_sector = target_asteroid:getSectorName()
		else
			print("nothing in asteroid pool, asteroid research mission cannot be completed")
		end
	end
end
function updateAsteroidResearch()
	scanned_asteroid_count = 0
	for i,a in ipairs(research_asteroids) do
		if a:isScannedByFaction("Human Navy") then
			scanned_asteroid_count = scanned_asteroid_count + 1
		end
	end
	if scanned_asteroid_count > 5 then
		if asteroid_structure == nil then
			structures = {"binary","rubble","solid"}
			asteroid_structure = tableSelectRandom(structures)
			for i,p in ipairs(getActivePlayerShips()) do
				if p.rock_research then
					if not p.structure_message then
						if availableForComms(p) then
							station_headquarters:sendCommsMessage(p,string.format("[Jessi Alcott] I just remembered that the structure of the asteroid I'm interested in is %s",asteroid_structure))
							p.structure_message = true
						end
					end
				end
			end
		end
	end
	if scanned_asteroid_count > 10 then
		if target_asteroid == nil or not target_asteroid:isValid() then
			pickTargetAsteroid()
			for i,p in ipairs(getActivePlayerShips()) do
				if p.rock_research then
					if not p.sector_message then
						if availableForComms(p) then
							station_headquarters:sendCommsMessage(p,string.format("[Jessi Alcott] I just remembered that the asteroid I'm interested in is in sector %s",target_asteroid_sector))
							p.sector_message = true
						end
					end
				end
			end
		end
	end
end
function updateUniformPlague()
	if not station_aggressive_kraylor:isValid() and not station_aggressive_ktlitans:isValid() then
		if uniform_plague_time == nil then
			uniform_plague_time = getScenarioTime() + random(60,120)
		elseif getScenarioTime() > uniform_plague_time then
			station_asteroids_a_far_h.wormhole_guide = true
			local accepted = true
			for i,p in ipairs(getActivePlayerShips()) do
				if not p.uniform_plague_mission_notification_message and availableForComms(p) then
					station_headquarters:sendCommsMessage(p,string.format("An alternative mission has come to our attention. Contact the dispatch office on station %s for details.",station_headquarters:getCallSign()))
					p.uniform_plague_mission_notification_message = true
					station_headquarters.uniform_plague_mission = true
				end
				if not p.uniform_plague_mission then
					accepted = false
				end
			end
			if accepted then
				uniform_plague_mission_fully_accepted = true
			end
			if uniform_plague_mission_fully_accepted then
				--handle plague updates
			end
		end
	end
end
function updateBlinkArtifact()
	if #blinking_artifacts > 0 then
		if getScenarioTime() > blink_artifact_time then
			local clean_list = true
			for i,a in ipairs(blinking_artifacts) do
				if not a:isValid() then
					blinking_artifacts[i] = blinking_artifacts[#blinking_artifacts]
					blinking_artifacts[#blinking_artifacts] = nil
					clean_list = false
					break
				end
			end
			if clean_list then
				for i,a in ipairs(blinking_artifacts) do
					a.blink_index = a.blink_index + 1
					if a.blink_index > #a.blink_colors then
						a.blink_index = 1
					end
					a:setRadarTraceColor(a.blink_colors[a.blink_index].r,a.blink_colors[a.blink_index].g,a.blink_colors[a.blink_index].b)
				end
				blink_artifact_time = getScenarioTime() + 1
			end
		end
	end
end
function updateResearchContainers()
	if #research_containers > 0 then
		local clean_list = true
		for i,a in ipairs(research_containers) do
			if not a:isValid() then
				research_containers[i] = research_containers[#research_containers]
				research_containers[#research_containers] = nil
				clean_list = false
				break
			end
		end
		if clean_list then
			for i,a in ipairs(research_containers) do
				if getScenarioTime() > a.arrival_time then
					if a.container_status == "in transit to station" then
						a.container_status = "being loaded"
						a:setDescriptions("Research collection container","Research collection container being loaded")
						if a.station:isValid() then
							a.station.container_status = "being loaded"
						else
							a:explode()
						end
						a.arrival_time = getScenarioTime() + 60
					elseif a.container_status == "being loaded" then
						a.container_status = "returning to ship"
						a:setDescriptions("Research collection container","Research collection container returning to ship")
						if a.station:isValid() then
							a.station.container_status = "returning to ship"
						end
						a.launch_time = getScenarioTime()
						a.arrival_time = a.launch_time + a.travel_time
						a:allowPickup(true)
					elseif a.container_status == "returning to ship" then
						a.container_status = "awaiting retrieval"
						a:setDescriptions("Research collection container","Research collection container awaiting retrieval")
						if a.station:isValid() then
							a.station.container_status = "awaiting retrieval"
						end
						a:allowPickup(true)
						research_containers[i] = research_containers[#research_containers]
						research_containers[#research_containers] = nil
						break
					end
				else
					if a.container_status == "in transit to station" then
						local elapsed_time = getScenarioTime() - a.launch_time
						local travel_progress = elapsed_time/a.travel_time
						local travel_distance = a.start_distance * travel_progress
						local new_x, new_y = vectorFromAngle(a.angle,travel_distance,true)
						new_x = new_x + a.origin_x
						new_y = new_y + a.origin_y
						a:setPosition(new_x, new_y)
--						print("To station. clock:",getScenarioTime(),"launch:",a.launch_time,"elapsed:",elapsed_time,"travel:",a.travel_time,"progress%:",travel_progress,"distance:",travel_distance,"angle:",a.angle,"x,y:",new_x, new_y)
					elseif a.container_status == "returning to ship" then
						local elapsed_time = getScenarioTime() - a.launch_time
						local travel_progress = elapsed_time/a.travel_time
						local travel_distance = a.start_distance * travel_progress
						local new_x, new_y = vectorFromAngle(a.angle + 180,travel_distance,true)
						new_x = new_x + a.destination_x
						new_y = new_y + a.destination_y
						a:setPosition(new_x, new_y)
--						print("To ship. clock:",getScenarioTime(),"launch:",a.launch_time,"elapsed:",elapsed_time,"travel:",a.travel_time,"progress%:",travel_progress,"distance:",travel_distance,"angle:",a.angle,"x,y:",new_x, new_y)
					end
				end
			end
		end
	end
end
function updateStationDefense()
	for i,station in ipairs(self_defending_stations) do
		if station ~= nil and station:isValid() then
			local station_x, station_y = station:getPosition()
			local nearby_objects = getObjectsInRadius(station_x, station_y, 8000)
			for j,obj in ipairs(nearby_objects) do
				if obj:isEnemy(station) then
					if isObjectType(obj,"CpuShip") or isObjectType(obj,"PlayerSpaceship") then
						if station.defenders == nil then
							station.defenders = {}
						end
						local clean_list = true
						if #station.defenders > 0 then
							for k,ship in ipairs(station.defenders) do
								if ship == nil or not ship:isValid() then
									station.defenders[k] = station.defenders[#station.defenders]
									station.defenders[#station.defenders] = nil
									clean_list = false
									break
								end
							end
						end
						if clean_list then
							if #station.defenders <= 2 then
								fleetSpawnFaction = station:getFaction()
								local fleet = spawnRandomArmed(station_x, station_y)
								for k,ship in ipairs(fleet) do
									ship:orderDefendTarget(station)
									table.insert(station.defenders,ship)
								end
								break
							end
						end
					end
				end
			end
		else
			self_defending_stations[i] = self_defending_stations[#self_defending_stations]
			self_defending_stations[#self_defending_stations] = nil
			break
		end
	end
end
function update(delta)
	if delta == 0 then
		return
	end
	local p = getPlayerShip(-1)
	if p ~= nil and p:isValid() then
		if uniform_plague_mission_fully_accepted then
			local mission_failure = false
			if station_research_delivery == nil or not station_research_delivery:isValid() then
				mission_failure = true
				mission_failure_reason = "the research delivery station was destroyed"
			end
			if not mission_failure then
				local remaining_station_factions = {}
				for i,station in ipairs(expansion_stations) do
					if station ~= nil and station:isValid() then
						local faction_counted = false
						for j,rsf in ipairs(remaining_station_factions) do
							if rsf == station:getFaction() then
								faction_counted = true
								break
							end
						end
						if not faction_counted then
							table.insert(remaining_station_factions,station:getFaction())
						end
					end
				end
				if #complete_faction_sources > #remaining_station_factions then
					local destroyed_station_factions = {}
					for i,cfs in ipairs(complete_faction_sources) do
						local can_get_faction = false
						for j,rsf in ipairs(remaining_station_factions) do
							if rsf == cfs then
								can_get_faction = true
							end
						end
						if not can_get_faction then
							table.insert(destroyed_station_factions,cfs)
						end
					end
					if #destroyed_station_factions > 0 then
						for i,c in ipairs(station_research_delivery.containers) do
							for j,dsf in ipairs(destroyed_station_factions) do
								if dsf == c then
									destroyed_station_factions[j] = destroyed_station_factions[#destroyed_station_factions]
									destroyed_station_factions[#destroyed_station_factions] = nil
									break
								end
							end
						end
						if #destroyed_station_factions > 0 then
							for i,p in ipairs(getActivePlayerShips()) do
								if p.containers ~= nil and #p.containers > 0 then
									for j,c in ipairs(p.containers) do
										for k,dsf in ipairs(destroyed_station_factions) do
											if dsf == c then
												destroyed_station_factions[k] = destroyed_station_factions[#destroyed_station_factions]
												destroyed_station_factions[#destroyed_station_factions] = nil
												break
											end
										end
									end
								end
							end
							if #destroyed_station_factions > 0 then
								mission_failure = true
								mission_failure_reason = string.format("all %s faction stations were destroyed before research was collected",destroyed_station_factions[1])
							end
						end
					end
				end
			end
			if mission_failure then
				local out = string.format("Mission failed because %s.",mission_failure_reason)
				out = string.format("%s\nGoal: Deliver research   Final reputation: %s",out,getPlayerShip(-1):getReputationPoints())
				out = string.format("%s\nEnemies: %s   Time spent in mission: %s",out,getScenarioSetting("Enemies"),formatTime(getScenarioTime()))
				globalMessage(out)
				victory("Exuari")
			end
			local faction_sources = {}
			for i,f in ipairs(complete_faction_sources) do
				table.insert(faction_sources,f)
			end
			if station_research_delivery.containers ~= nil then
				for i,c in ipairs(station_research_delivery.containers) do
					for j,f in ipairs(faction_sources) do
						if c == f then
							faction_sources[j] = faction_sources[#faction_sources]
							faction_sources[#faction_sources] = nil
							break
						end
					end
				end
			end
			if #faction_sources == 0 then
				local out = "Research from all factions was gathered and delivered.\nGalactic civilization has been saved from probable extinction."
				out = string.format("%s\nGoal: Deliver research   Final reputation: %s",out,getPlayerShip(-1):getReputationPoints())
				out = string.format("%s\nEnemies: %s   Time spent in mission: %s",out,getScenarioSetting("Enemies"),formatTime(getScenarioTime()))
				globalMessage(out)
				victory("Human Navy")
			end
		else
			if p:getReputationPoints() >= reputation_goal and not uniform_plague_mission_fully_accepted then
				local out = "You met your reputation goal"
				out = string.format("%s\nGoal: %s   Final reputation: %s",out,reputation_goal,getPlayerShip(-1):getReputationPoints())
				out = string.format("%s\nEnemies: %s   Time spent in mission: %s",out,getScenarioSetting("Enemies"),formatTime(getScenarioTime()))
				globalMessage(out)
				victory("Human Navy")
			end
		end
		if exuari_bandits == nil then
			exuari_bandits = {}
			local fleet = spawnRandomArmed(expanse_x,expanse_y)
			for i,ship in ipairs(fleet) do
				ship:setFaction("Exuari"):orderDefendLocation(expanse_x,expanse_y)
				table.insert(exuari_bandits,ship)
			end
			fleet = spawnRandomArmed(expanse_x,expanse_y)
			for i,ship in ipairs(fleet) do
				ship:setFaction("Exuari"):orderDefendLocation(expanse_x,expanse_y)
				table.insert(exuari_bandits,ship)
			end
			fleet = spawnRandomArmed(expanse_x,expanse_y)
			for i,ship in ipairs(fleet) do
				ship:setFaction("Exuari"):orderDefendLocation(expanse_x,expanse_y)
				table.insert(exuari_bandits,ship)
			end
			updatePlayerStripGuideArtifact(p)
		end
	end
	local plague_count = 0		--how many players took on the plague mission
	for i,p in ipairs(getActivePlayerShips()) do
		if p.uniform_plague_mission then
			plague_count = plague_count + 1
		end
		updatePlayerTrackPatrolPoint(p)
		updatePlayerInitialPatrolMissionMessage(p)
		updatePlayerInventoryButtonUtility(p)
		updatePlayerIFFFailureCheck(p)
		updatePlayerShipNameBanner(p)
		updatePlayerStarHeat(delta,p)
		updatePlayerInNebula(delta,p)
		updatePlayerLongRangeSensors(delta,p)
		improvedStationService(p)
	end
	if plague_count < #getActivePlayerShips() then
		if #patrol_points < 4 then
			local out = "One of the stations on your patrol was destroyed"
			out = string.format("%s\nGoal: %s   Final reputation: %s",out,reputation_goal,getPlayerShip(-1):getReputationPoints())
			out = string.format("%s\nEnemies: %s   Time spent in mission: %s",out,getScenarioSetting("Enemies"),formatTime(getScenarioTime()))
			globalMessage(out)
			victory("Exuari")
		end
	end
	updateAsteroidResearch()
	updatePlanetCollisionDetection()
	updateOrbitingPlatforms()
	updateAggressiveFactions()
	updateEstablishGhostDefenders()
	updateUniformPlague()
	updateBlinkArtifact()
	updateResearchContainers()
	updateStationDefense()
	maintainTransports()
end
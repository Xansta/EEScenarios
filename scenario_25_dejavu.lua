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
	scenario_version = "1.0.1"
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
	stations_sell_goods = true
	stations_buy_goods = true
	relative_strength = 1
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
	planet_collision_list = {
		{planet = star_fixed,	fudge = 430},
		{planet = nice_planet,	fudge = 187},
		{planet = inner_moon,	fudge = 32},
		{planet = outer_moon,	fudge = 45},
	}
	--	Stations near headquarters
	station_headquarters = placeStation(-2865, 10417,"Pop Sci Fi","Human Navy","Large Station")
	station_headquarters:setShortRangeRadarRange(15000)
	station_asteroids_i_near_h = placeStation(-7889, 27185,"Generic","Independent","Small Station")
	station_asteroids_a_far_h = placeStation(850, 37137,"History","Arlenians","Small Station")
	--	stations near medium TSN station
	station_med_TSN = placeStation(43846, -21746,"Spec Sci Fi","TSN","Medium Station")
	station_med_TSN:setShortRangeRadarRange(10000)
	if station_med_TSN.comms_data.buy == nil then
		station_med_TSN.comms_data.buy = {}
	end
	station_med_TSN.comms_data.buy.tritanium = math.random(70,90)
	station_asteroids_i_near_t = placeStation(49310, -12572,"Generic","Independent","Small Station")
	station_asteroids_g_far_t = placeStation(65477, -9885,"Science","Ghosts","Small Station")
	--	stations between large USN station and huge CUF station
	station_large_USN = placeStation(20914, 43695,"Pop Sci Fi","USN","Large Station")
	station_large_USN:setShortRangeRadarRange(15000)
	station_huge_CUF = placeStation(76019, 22159,"RandomHumanNeutral","CUF","Huge Station")
	station_huge_CUF:setShortRangeRadarRange(20000)
	station_asteroids_k_near_u = placeStation(46761, 56462,"Sinister","Kraylor","Small Station")
	station_asteroids_b_near_c = placeStation(62007, 39194,"Sinister","Ktlitans","Small Station")
	--	station ghost eye
	station_eye_ghost = placeStation(-92065, -91965,"History","Ghosts","Medium Station")
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
	for i,a in ipairs(fixed_asteroids) do
    	local a_size = a:getSize()
    	local sx, sy = a:getPosition()
    	local dx = random(a_size + 50,a_size + 100)
    	local dy = random(a_size + 50,a_size + 100)
    	local size_variance = a_size * .2
    	VisualAsteroid():setPosition(sx + dx, sy + dy):setSize(a_size + random(-size_variance,size_variance))
    	VisualAsteroid():setPosition(sx - dx, sy - dy):setSize(a_size + random(-size_variance,size_variance))
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
function scenarioMissionsUndocked()
	showPatrolCircuitStatus()
	rockResearch()
end
function scenarioMissions()
	local option_count = 0
	option_count = option_count + showPatrolCircuitStatus()
	option_count = option_count + destroyAggressiveKraylorStation()
	option_count = option_count + destroyAggressiveKtlitanStation()
	option_count = option_count + transportGhostVIP()
	option_count = option_count + rockResearch()
	return option_count
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
		else
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
				IFF_fail_time = getScenarioTime() + random(3,8)
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
function showPatrolCircuitStatus()
	local option_count = 0
	if not comms_source.released_from_patrol_duty then
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
			end
		end
	end
end
function updatePlayerIFFFailureCheck(p)
	if IFF_fail_time ~= nil then
		if p:getFaction() == "TSN" then
			if station_eye_ghost:isValid() then
				if not p:isDocked(station_eye_ghost) then
					if getScenarioTime() > IFF_fail_time then
						p:setFaction("Human Navy")
						IFF_fail_time = nil
						p.IFF_fail = true
						IFF_fail_message_time = getScenarioTime() + 3
					end
				end
			else
				if getScenarioTime() > IFF_fail_time then
					p:setFaction("Human Navy")
					IFF_fail_time = nil
					p.IFF_fail = true
					IFF_fail_message_time = getScenarioTime() + 3
				end
			end
		end
	end
	if IFF_fail_message_time ~= nil then
		if p.IFF_fail then
			if getScenarioTime() > IFF_fail_message_time then
				p:addToShipLog(string.format("The IFF change to TSN has failed. %s has reverted to Human Navy","Red"))
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
		p:addCustomInfo("Engineering",p.gather_coolant_plus,gather_coolant_status, 5)
	end
end
function updateOrbitingPlatforms()
	for i,dp in ipairs(orbiting_platforms) do
		if dp ~= nil and dp:isValid() then
			dp.angle = dp.angle + .01
			local x, y = vectorFromAngle(dp.angle,dp.dist)
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
function update(delta)
	if delta == 0 then
		return
	end
	if getPlayerShip(-1):getReputationPoints() >= reputation_goal then
		local out = "You met your reputation goal"
		out = string.format("%s\nGoal: %s   Final reputation: %s",out,reputation_goal,getPlayerShip(-1):getReputationPoints())
		out = string.format("%s\nEnemies: %s   Time spent in mission: %s",out,getScenarioSetting("Enemies"),formatTime(getScenarioTime()))
		globalMessage(out)
		victory("Human Navy")
	end
	local released_count = 0
	for i,p in ipairs(getActivePlayerShips()) do
		updatePlayerTrackPatrolPoint(p)
		updatePlayerInitialPatrolMissionMessage(p)
		updatePlayerIFFFailureCheck(p)
		updatePlayerShipNameBanner(p)
		updatePlayerStarHeat(delta,p)
		updatePlayerInNebula(delta,p)
		if p.released_from_patrol_duty then
			released_count = released_count + 1
		end
	end
	if released_count < #getActivePlayerShips() then
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
end
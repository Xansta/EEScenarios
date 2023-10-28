-- Name: Shop Til You Drop
-- Description: Recovering from a battle, you're a long way from home. Your ship has been cobbled together from parts.
--- 
--- Designed to run with one or more player ships with different terrain each time. Player ships start off with limited capabilities, but can be upgraded beyond the normal player ship capabilities.
---
--- Duration: At least an hour
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
-- Setting[Density]: Configures the relative density of the terrain
-- Density[Normal|Default]: Normal terrain density
-- Density[Less Dense]: Terrain is less dense than normal
-- Density[More Dense]: Terrain is more dense than normal

require("utils.lua")
require("place_station_scenario_utility.lua")
require("player_ship_upgrade_downgrade_path_scenario_utility.lua")
require("generate_call_sign_scenario_utility.lua")
require("cpu_ship_diversification_scenario_utility.lua")

function init()
	scenario_version = "1.0.2"
	ee_version = "2023.06.17"
	print(string.format("    ----    Scenario: Shop Til You Drop    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
	print(_VERSION)
	spew_function_diagnostic = false
	spray_forth_diagnostic = false
	setVariations()	
	setConstants()	
	constructEnvironment()
	onNewPlayerShip(setPlayers)
end
function setVariations()
	if spew_function_diagnostic then print("top of set variations") end
	local enemy_config = {
		["Easy"] =		{number = .5},
		["Normal"] =	{number = 1},
		["Hard"] =		{number = 2},
		["Extreme"] =	{number = 3},
		["Quixotic"] =	{number = 5},
	}
	enemy_power =	enemy_config[getScenarioSetting("Enemies")].number
	local murphy_config = {
		["Easy"] =		{number = .5,	adverse = .999,	lose_coolant = .99999,	gain_coolant = .005,	rep = 40,	start_danger =  .4},
		["Normal"] =	{number = 1,	adverse = .995,	lose_coolant = .99995,	gain_coolant = .001,	rep = 20,	start_danger =  .8},
		["Hard"] =		{number = 2,	adverse = .99,	lose_coolant = .9999,	gain_coolant = .0001,	rep = 0,	start_danger = 1.2},
	}
	difficulty =			murphy_config[getScenarioSetting("Murphy")].number
	adverseEffect =			murphy_config[getScenarioSetting("Murphy")].adverse
	coolant_loss =			murphy_config[getScenarioSetting("Murphy")].lose_coolant
	coolant_gain =			murphy_config[getScenarioSetting("Murphy")].gain_coolant
	reputation_start_amount=murphy_config[getScenarioSetting("Murphy")].rep
	current_danger =		murphy_config[getScenarioSetting("Murphy")].start_danger
	local density_config = {
		["Normal"] =		200,
		["Less Dense"] =	100,
		["More Dense"] =	300,
	}
	terrain_density = density_config[getScenarioSetting("Density")]
	if spew_function_diagnostic then print("bottom of set variations") end
end
function setConstants()
	if spew_function_diagnostic then print("top of set constants") end
	max_repeat_loop = 300
	center_x = random(400000,1200000)
	center_y = random(60000,260000)
	asteroid_field_angle = random(0,360)
	player_spawn_x, player_spawn_y = vectorFromAngleNorth(asteroid_field_angle,random(-300,300)+9500)
	player_spawn_x = player_spawn_x + center_x
	player_spawn_y = player_spawn_y + center_y
	primary_orders = _("orders-comms","Survive")
	mileage_compensation = 6500
	upgrade_price = 2
	transport_list = {}
	warp_jammer_list = {}
	exuari_player_attackers = {}
	exuari_spray = {}
	regional_news = {}
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
	playerShipUpgradeDowngradeData()
	player_ship_spawn_count = 0
	--Player ship name lists to supplant standard randomized call sign generation
	player_ship_names_for = {}
	player_ship_names_for["Amalgam"] = {"Mixer","Igor","Ronco","Ginsu"}
	player_ship_names_for["Atlantis"] = {"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"}
	player_ship_names_for["Atlantis II"] = {"Spyder", "Shelob", "Tarantula", "Aragog", "Charlotte"}
	player_ship_names_for["Benedict"] = {"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"}
	player_ship_names_for["Crucible"] = {"Sling", "Stark", "Torrid", "Kicker", "Flummox"}
	player_ship_names_for["Cruzeiro"] = {"Vamanos", "Cougar", "Parthos", "Trifecta", "Light Mind"}
	player_ship_names_for["Destroyer III"] = {"Trebuchet", "Pitcher", "Mutant", "Gronk", "Methuselah"}
	player_ship_names_for["Ender"] = {"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"}
	player_ship_names_for["Flavia P.Falcon"] = {"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"}
	player_ship_names_for["Hathcock"] = {"Hayha", "Waldron", "Plunkett", "Mawhinney", "Furlong", "Zaytsev", "Pavlichenko", "Pegahmagabow", "Fett", "Hawkeye", "Hanzo"}
	player_ship_names_for["Kiriya"] = {"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"}
	player_ship_names_for["MP52 Hornet"] = {"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"}
	player_ship_names_for["Maverick"] = {"Angel", "Thunderbird", "Roaster", "Magnifier", "Hedge"}
	player_ship_names_for["Midian"] = {"Flipper", "Feint", "Dolphin", "Joker", "Trickster"}
	player_ship_names_for["Nautilus"] = {"October", "Abdiel", "Manxman", "Newcon", "Nusret", "Pluton", "Amiral", "Amur", "Heinkel", "Dornier"}
	player_ship_names_for["Phobos M3P"] = {"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"}
	player_ship_names_for["Piranha"] = {"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"}
	player_ship_names_for["Player Cruiser"] = {"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"}
	player_ship_names_for["Player Fighter"] = {"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"}
	player_ship_names_for["Player Missile Cr."] = {"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"}
	player_ship_names_for["Proto-Atlantis"] = {"Narsil", "Blade", "Decapitator", "Trisect", "Sabre"}
	player_ship_names_for["Raven"] = {"Claw", "Bethel", "Cicero", "Da Vinci", "Skaats"}
	player_ship_names_for["Redhook"] = {"Headhunter", "Thud", "Troll", "Scalper", "Shark"}
	player_ship_names_for["Repulse"] = {"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"}
	player_ship_names_for["Squid"] = {"Ink", "Tentacle", "Pierce", "Writhe", "Bogey"}
	player_ship_names_for["Stricken"] = {"Blazon", "Streaker", "Pinto", "Spear", "Javelin"}
	player_ship_names_for["Striker"] = {"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"}
	player_ship_names_for["Surkov"] = {"Sting", "Sneak", "Bingo", "Thrill", "Vivisect"}
	player_ship_names_for["ZX-Lindworm"] = {"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"}
	player_ship_names_for["Leftovers"] = {"Foregone","Righteous","Masher"}
	playerShipStats = {	--taken from sandbox. Not all are used. Not all characteristics are used.
		["Atlantis"]			= { strength = 52,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Benedict"]			= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 10,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Crucible"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 9,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Ender"]				= { strength = 100,	cargo = 20,	distance = 2000,long_range_radar = 45000, short_range_radar = 7000, tractor = true,		mining = false,	probes = 12,	pods = 6,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 2,	epjam = 0,	},
		["Flavia P.Falcon"]		= { strength = 13,	cargo = 15,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 8,		pods = 4,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Hathcock"]			= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, tractor = false,	mining = true,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Kiriya"]				= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 35000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 10,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Maverick"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, tractor = false,	mining = true,	probes = 9,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["MP52 Hornet"] 		= { strength = 7, 	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 4000, tractor = false,	mining = false,	probes = 5,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Nautilus"]			= { strength = 12,	cargo = 7,	distance = 200,	long_range_radar = 22000, short_range_radar = 4000, tractor = false,	mining = false,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Phobos M3P"]			= { strength = 19,	cargo = 10,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 6,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Piranha"]				= { strength = 16,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 6,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Player Cruiser"]		= { strength = 40,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Player Missile Cr."]	= { strength = 45,	cargo = 8,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 9,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Player Fighter"]		= { strength = 7,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Repulse"]				= { strength = 14,	cargo = 12,	distance = 200,	long_range_radar = 38000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 8,		pods = 5,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Striker"]				= { strength = 8,	cargo = 4,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 6,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["ZX-Lindworm"]			= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 5500, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
	--	Custom player ships	
		["Amalgam"]				= { strength = 42,	cargo = 7,	distance = 400,	long_range_radar = 36000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 11,	pods = 3,	turbo_torp = true,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Atlantis II"]			= { strength = 60,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 11,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Barrow"]				= { strength = 9,	cargo = 9,	distance = 400,	long_range_radar = 35000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 12,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 2,	},
		["Bermuda"]				= { strength = 30,	cargo = 4,	distance = 400,	long_range_radar = 30000, short_range_radar = 4500, tractor = true,		mining = false,	probes = 14,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Butler"]				= { strength = 20,	cargo = 6,	distance = 200,	long_range_radar = 30000, short_range_radar = 5500, tractor = true,		mining = false,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Caretaker"]			= { strength = 23,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 9,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Chavez"]				= { strength = 21,	cargo = 6,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 2.5,	prox_scan = 0,	epjam = 1,	},
		["Crab"]				= { strength = 20,	cargo = 6,	distance = 200,	long_range_radar = 30000, short_range_radar = 5500, tractor = false,	mining = true,	probes = 13,	pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Destroyer III"]		= { strength = 25,	cargo = 7,	distance = 200,	long_range_radar = 32000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Destroyer IV"]		= { strength = 22,	cargo = 5,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 8,		pods = 1,	turbo_torp = true,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Eldridge"]			= { strength = 20,	cargo = 7,	distance = 200,	long_range_radar = 24000, short_range_radar = 8000, tractor = false,	mining = true,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 3,	prox_scan = 3,	epjam = 0,	},
		["Era"]					= { strength = 14,	cargo = 14,	distance = 200,	long_range_radar = 50000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 8,		pods = 4,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 9,	epjam = 3,	},
		["Flavia 2C"]			= { strength = 25,	cargo = 12,	distance = 200,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 9,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Focus"]				= { strength = 35,	cargo = 4,	distance = 200,	long_range_radar = 32000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 8,		pods = 1,	turbo_torp = true,	patrol_probe = 1.25,prox_scan = 0,	epjam = 0,	},
		["Fowl"]				= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 3,	},
		["Fray"]				= { strength = 22,	cargo = 5,	distance = 200,	long_range_radar = 23000, short_range_radar = 4500, tractor = true,		mining = false,	probes = 7,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Fresnel"]				= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = true,	patrol_probe = 0,	prox_scan = 9,	epjam = 0,	},
		["Gadfly"]				= { strength = 9,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 3.6,	prox_scan = 9,	epjam = 0,	},
		["Glass Cannon"]		= { strength = 15,	cargo = 3,	distance = 100,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 8,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Gull"]				= { strength = 14,	cargo = 14,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 8,		pods = 4,	turbo_torp = false,	patrol_probe = 4,	prox_scan = 0,	epjam = 0,	},
		["Holmes"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 4000, tractor = true,		mining = false,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Interlock"]			= { strength = 19,	cargo = 12,	distance = 200,	long_range_radar = 35000, short_range_radar = 5500, tractor = false,	mining = true,	probes = 13,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Kludge"]				= { strength = 22,	cargo = 9,	distance = 200,	long_range_radar = 35000, short_range_radar = 3500, tractor = false,	mining = true,	probes = 20,	pods = 5,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Lurker"]				= { strength = 18,	cargo = 3,	distance = 100,	long_range_radar = 21000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Mantis"]				= { strength = 30,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 9,		pods = 2,	turbo_torp = true,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Maverick XP"]			= { strength = 23,	cargo = 5,	distance = 200,	long_range_radar = 25000, short_range_radar = 7000, tractor = true,		mining = false,	probes = 10,	pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 2,	epjam = 0,	},
		["Midian"]				= { strength = 30,	cargo = 9,	distance = 200,	long_range_radar = 25000, short_range_radar = 5500, tractor = false,	mining = false,	probes = 9,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["MX-Lindworm"]			= { strength = 10,	cargo = 3,	distance = 100,	long_range_radar = 30000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 5,		pods = 1,	turbo_torp = false,	patrol_probe = 3,	prox_scan = 9,	epjam = 0,	},
		["Noble"]				= { strength = 33,	cargo = 6,	distance = 400,	long_range_radar = 27000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Nusret"]				= { strength = 16,	cargo = 7,	distance = 200,	long_range_radar = 25000, short_range_radar = 4000, tractor = false,	mining = true,	probes = 10,	pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 3,	},
		["Orca"]				= { strength = 19,	cargo = 6,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 6,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 1,	},
		["Pacu"]				= { strength = 18,	cargo = 7,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 6,		pods = 2,	turbo_torp = false,	patrol_probe = 2.5,	prox_scan = 1,	epjam = 0,	},
		["Peacock"]				= { strength = 30,	cargo = 9,	distance = 400,	long_range_radar = 25000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 10,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Phargus"]				= { strength = 15,	cargo = 6,	distance = 200,	long_range_radar = 20000, short_range_radar = 5500, tractor = false,	mining = false,	probes = 6,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Phobos T2"]			= { strength = 19,	cargo = 9,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 5,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Phobos T2.2"]			= { strength = 19,	cargo = 9,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 5,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Phoenix"]				= { strength = 40,	cargo = 6,	distance = 400,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 6,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Porcupine"]			= { strength = 30,	cargo = 6,	distance = 400,	long_range_radar = 25000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Proto-Atlantis"]		= { strength = 40,	cargo = 4,	distance = 400,	long_range_radar = 30000, short_range_radar = 4500, tractor = false,	mining = true,	probes = 8,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Proto-Atlantis 2"]	= { strength = 40,	cargo = 4,	distance = 400,	long_range_radar = 30000, short_range_radar = 4500, tractor = false,	mining = true,	probes = 8,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Raven"]				= { strength = 30,	cargo = 5,	distance = 400,	long_range_radar = 25000, short_range_radar = 6000, tractor = true,		mining = false,	probes = 7,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Redhook"]				= { strength = 12,	cargo = 8,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 6,		pods = 2,	turbo_torp = false,	patrol_probe = 2.5,	prox_scan = 9,	epjam = 0,	},
		["Roc"]					= { strength = 25,	cargo = 6,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 6,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 1,	},
		["Rodent"]				= { strength = 23,	cargo = 8,	distance = 200,	long_range_radar = 40000, short_range_radar = 5500, tractor = false,	mining = false,	probes = 9,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Rook"]				= { strength = 15,	cargo = 12,	distance = 200,	long_range_radar = 41000, short_range_radar = 5500, tractor = false,	mining = true,	probes = 13,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Rotor"]				= { strength = 35,	cargo = 5,	distance = 200,	long_range_radar = 25000, short_range_radar = 4000, tractor = true,		mining = false,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Safari"]				= { strength = 15,	cargo = 10,	distance = 200,	long_range_radar = 33000, short_range_radar = 4500, tractor = true,		mining = false,	probes = 9,		pods = 3,	turbo_torp = false,	patrol_probe = 3.5,	prox_scan = 0,	epjam = 0,	},
		["Scatter"]				= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 28000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 8,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Skray"]				= { strength = 15,	cargo = 3,	distance = 200, long_range_radar = 30000, short_range_radar = 7500, tractor = false,	mining = false,	probes = 25,	pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 3,	epjam = 0,	},
		["Sloop"]				= { strength = 20,	cargo = 8,	distance = 200,	long_range_radar = 35000, short_range_radar = 4500, tractor = true,		mining = true,	probes = 9,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 2,	epjam = 2,	},
		["Squid"]				= { strength = 14,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 7,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 9,	epjam = 0,	},
		["Striker LX"]			= { strength = 16,	cargo = 4,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, tractor = false,	mining = false,	probes = 7,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Surkov"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Twister"]				= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 23000, short_range_radar = 5500, tractor = false,	mining = true,	probes = 15,	pods = 2,	turbo_torp = false,	patrol_probe = 3,	prox_scan = 1,	epjam = 0,	},
		["Torch"]				= { strength = 9,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4000, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Vermin"]				= { strength = 10,	cargo = 3,	distance = 100,	long_range_radar = 22000, short_range_radar = 4000, tractor = false,	mining = true,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 3.6,	prox_scan = 0,	epjam = 1,	},
		["Windmill"]			= { strength = 19,	cargo = 11,	distance = 200,	long_range_radar = 33000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 8,		pods = 4,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Wombat"]				= { strength = 18,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 5,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 2,	},
		["Wrocket"]				= { strength = 19,	cargo = 8,	distance = 200,	long_range_radar = 32000, short_range_radar = 5500, tractor = false,	mining = false,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["XR-Lindworm"]			= { strength = 12,	cargo = 3,	distance = 100,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 5,		pods = 1,	turbo_torp = false,	patrol_probe = 3.9,	prox_scan = 9,	epjam = 0,	},
	}
	fly_formation_3 = {"V","Vac","A","Aac","/","-","\\","|","/ac","\\ac"}
	fly_formation_5 = {"V4","Vac4","A4","Aac4","-4","|4","/4","\\4","M","Mac","W","Wac","X","Xac"}
	fly_formation_7 = {"M6","Mac6","W6","Wac6","V6","Vac6","A6","Aac6"}
	fly_formation_9 = {"X8","Xac8","V8","Vac8","A8","Aac8"}
	fly_formation_13= {"X12","Xac12"}
	fly_formation_17= {"X16","Xac16"}
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
		["V6"] =	{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 60	, dist = 2	},
						{angle = 300, dist = 2	},
						{angle = 60	, dist = 3	},
						{angle = 300, dist = 3	},
					},
		["Vac6"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 30	, dist = 2	},
						{angle = 330, dist = 2	},
						{angle = 30	, dist = 3	},
						{angle = 330, dist = 3	},
					},
		["V8"] =	{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 60	, dist = 2	},
						{angle = 300, dist = 2	},
						{angle = 60	, dist = 3	},
						{angle = 300, dist = 3	},
						{angle = 60	, dist = 4	},
						{angle = 300, dist = 4	},
					},
		["Vac8"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 30	, dist = 2	},
						{angle = 330, dist = 2	},
						{angle = 30	, dist = 3	},
						{angle = 330, dist = 3	},
						{angle = 30	, dist = 4	},
						{angle = 330, dist = 4	},
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
		["A6"] =	{
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 120, dist = 2	},
						{angle = 240, dist = 2	},
						{angle = 120, dist = 3	},
						{angle = 240, dist = 3	},
					},
		["Aac6"] =	{
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 150, dist = 2	},
						{angle = 210, dist = 2	},
						{angle = 150, dist = 3	},
						{angle = 210, dist = 3	},
					},
		["A8"] =	{
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 120, dist = 2	},
						{angle = 240, dist = 2	},
						{angle = 120, dist = 3	},
						{angle = 240, dist = 3	},
						{angle = 120, dist = 4	},
						{angle = 240, dist = 4	},
					},
		["Aac8"] =	{
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 150, dist = 2	},
						{angle = 210, dist = 2	},
						{angle = 150, dist = 3	},
						{angle = 210, dist = 3	},
						{angle = 150, dist = 4	},
						{angle = 210, dist = 4	},
					},
		["/"] =		{
						{angle = 60	, dist = 1	},
						{angle = 240, dist = 1	},
					},
		["/4"] =	{
						{angle = 60	, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 60	, dist = 2	},
						{angle = 240, dist = 2	},
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
		["\\4"] =	{
						{angle = 300, dist = 1	},
						{angle = 120, dist = 1	},
						{angle = 300, dist = 2	},
						{angle = 120, dist = 2	},
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
						{angle = 305, dist = 1.7},
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
		["X12"] =	{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 60	, dist = 2	},
						{angle = 300, dist = 2	},
						{angle = 120, dist = 2	},
						{angle = 240, dist = 2	},
						{angle = 60	, dist = 3	},
						{angle = 300, dist = 3	},
						{angle = 120, dist = 3	},
						{angle = 240, dist = 3	},
					},
		["Xac12"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 30	, dist = 2	},
						{angle = 330, dist = 2	},
						{angle = 150, dist = 2	},
						{angle = 210, dist = 2	},
						{angle = 30	, dist = 3	},
						{angle = 330, dist = 3	},
						{angle = 150, dist = 3	},
						{angle = 210, dist = 3	},
					},
		["X16"] =	{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 60	, dist = 2	},
						{angle = 300, dist = 2	},
						{angle = 120, dist = 2	},
						{angle = 240, dist = 2	},
						{angle = 60	, dist = 3	},
						{angle = 300, dist = 3	},
						{angle = 120, dist = 3	},
						{angle = 240, dist = 3	},
						{angle = 60	, dist = 4	},
						{angle = 300, dist = 4	},
						{angle = 120, dist = 4	},
						{angle = 240, dist = 4	},
					},
		["Xac16"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 30	, dist = 2	},
						{angle = 330, dist = 2	},
						{angle = 150, dist = 2	},
						{angle = 210, dist = 2	},
						{angle = 30	, dist = 3	},
						{angle = 330, dist = 3	},
						{angle = 150, dist = 3	},
						{angle = 210, dist = 3	},
						{angle = 30	, dist = 4	},
						{angle = 330, dist = 4	},
						{angle = 150, dist = 4	},
						{angle = 210, dist = 4	},
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
	pool_selectivity = "full"
	template_pool_size = 8
	ship_template = {	--ordered by relative strength
		["Gnat"] =				{strength = 2,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 4500,	hop_angle = 0,	hop_range = 580,	create = gnat},
		["Lite Drone"] =		{strength = 3,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = droneLite},
		["Jacket Drone"] =		{strength = 4,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = droneJacket},
		["Ktlitan Drone"] =		{strength = 4,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Heavy Drone"] =		{strength = 5,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 580,	create = droneHeavy},
		["Adder MK3"] =			{strength = 5,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["MT52 Hornet"] =		{strength = 5,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 680,	create = stockTemplate},
		["MU52 Hornet"] =		{strength = 5,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 880,	create = stockTemplate},
		["Dagger"] =			{strength = 6,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["MV52 Hornet"] =		{strength = 6,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = hornetMV52},
		["MT55 Hornet"] =		{strength = 6,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 680,	create = hornetMT55},
		["Adder MK4"] =			{strength = 6,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Fighter"] =			{strength = 6,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Ktlitan Fighter"] =	{strength = 6,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["FX64 Hornet"] =		{strength = 7,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1480,	create = hornetFX64},
		["Blade"] =				{strength = 7,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Gunner"] =			{strength = 7,	missile_only = false,	missile_primary = false,	missile_secondary = true,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["K2 Fighter"] =		{strength = 7,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = k2fighter},
		["Adder MK5"] =			{strength = 7,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["WX-Lindworm"] =		{strength = 7,	missile_only = true,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["K3 Fighter"] =		{strength = 8,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = k3fighter},
		["Shooter"] =			{strength = 8,	missile_only = false,	missile_primary = false,	missile_secondary = true,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Jagger"] =			{strength = 8,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Adder MK6"] =			{strength = 8,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Ktlitan Scout"] =		{strength = 8,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 7000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["WZ-Lindworm"] =		{strength = 9,	missile_only = true,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 2500,	create = wzLindworm},
		["Adder MK7"] =			{strength = 9,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Adder MK8"] =			{strength = 10,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Adder MK9"] =			{strength = 11,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Nirvana R3"] =		{strength = 12,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Phobos R2"] =			{strength = 13,	missile_only = false,	missile_primary = false,	missile_secondary = true,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = phobosR2},
		["Missile Cruiser"] =	{strength = 14,	missile_only = true,	missile_primary = false,	missile_secondary = false,	short_range_radar = 7000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Waddle 5"] =			{strength = 15,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = waddle5},
		["Jade 5"] =			{strength = 15,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = jade5},
		["Phobos T3"] =			{strength = 15,	missile_only = false,	missile_primary = false,	missile_secondary = true,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Guard"] =				{strength = 15,	missile_only = false,	missile_primary = false,	missile_secondary = true,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Piranha F8"] =		{strength = 15,	missile_only = true,	missile_primary = false,	missile_secondary = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = stockTemplate},
		["Piranha F12"] =		{strength = 15,	missile_only = true,	missile_primary = false,	missile_secondary = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = stockTemplate},
		["Piranha F12.M"] =		{strength = 16,	missile_only = true,	missile_primary = false,	missile_secondary = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = stockTemplate},
		["Phobos M3"] =			{strength = 16,	missile_only = false,	missile_primary = false,	missile_secondary = true,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Farco 3"] =			{strength = 16,	missile_only = false,	missile_primary = false,	missile_secondary = true,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	create = farco3},
		["Farco 5"] =			{strength = 16,	missile_only = false,	missile_primary = false,	missile_secondary = true,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1180,	create = farco5},
		["Karnack"] =			{strength = 17,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Gunship"] =			{strength = 17,	missile_only = false,	missile_primary = false,	missile_secondary = true,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Phobos T4"] =			{strength = 18,	missile_only = false,	missile_primary = false,	missile_secondary = true,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1480,	create = phobosT4},
		["Cruiser"] =			{strength = 18,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Nirvana R5"] =		{strength = 19,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Farco 8"] =			{strength = 19,	missile_only = false,	missile_primary = false,	missile_secondary = true,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	create = farco8},
		["Nirvana R5A"] =		{strength = 20,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Adv. Gunship"] =		{strength = 20,	missile_only = false,	missile_primary = false,	missile_secondary = true,	short_range_radar = 7000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Ktlitan Worker"] =	{strength = 20,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 90,	hop_range = 580,	create = stockTemplate},
		["Farco 11"] =			{strength = 21,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	create = farco11},
		["Storm"] =				{strength = 22,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Warden"] =			{strength = 22,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Racer"] =				{strength = 22,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Strike"] =			{strength = 23,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Dash"] =				{strength = 23,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Farco 13"] =			{strength = 24,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1480,	create = farco13},
		["Sentinel"] =			{strength = 24,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Ranus U"] =			{strength = 25,	missile_only = true,	missile_primary = false,	missile_secondary = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Flash"] =				{strength = 25,	missile_only = true,	missile_primary = false,	missile_secondary = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Ranger"] =			{strength = 25,	missile_only = true,	missile_primary = false,	missile_secondary = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Buster"] =			{strength = 25,	missile_only = true,	missile_primary = false,	missile_secondary = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Stalker Q7"] =		{strength = 25,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Stalker R7"] =		{strength = 25,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Whirlwind"] =			{strength = 26,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = whirlwind},
		["Hunter"] =			{strength = 26,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Adv. Striker"] =		{strength = 27,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Tempest"] =			{strength = 30,	missile_only = true,	missile_primary = false,	missile_secondary = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = tempest},
		["Strikeship"] =		{strength = 30,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Maniapak"] =			{strength = 34,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 580,	create = maniapak},
		["Cucaracha"] =			{strength = 36,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1480,	create = cucaracha},
		["Predator"] =			{strength = 42,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 7500,	hop_angle = 0,	hop_range = 980,	create = predator},
		["Ktlitan Breaker"] =	{strength = 45,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 780,	create = stockTemplate},
		["Hurricane"] =			{strength = 46,	missile_only = true,	missile_primary = false,	missile_secondary = false,	short_range_radar = 6000,	hop_angle = 15,	hop_range = 2500,	create = hurricane},
		["Ktlitan Feeder"] =	{strength = 48,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Atlantis X23"] =		{strength = 50,	missile_only = false,	missile_primary = false,	missile_secondary = true,	short_range_radar = 10000,	hop_angle = 0,	hop_range = 1480,	create = stockTemplate},
		["Ktlitan Destroyer"] =	{strength = 50,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 9000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["K2 Breaker"] =		{strength = 55,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 780,	create = k2breaker},
		["Atlantis Y42"] =		{strength = 60,	missile_only = false,	missile_primary = false,	missile_secondary = true,	short_range_radar = 10000,	hop_angle = 0,	hop_range = 1480,	create = atlantisY42},
		["Blockade Runner"] =	{strength = 63,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Starhammer II"] =		{strength = 70,	missile_only = false,	missile_primary = false,	missile_secondary = true,	short_range_radar = 10000,	hop_angle = 0,	hop_range = 1480,	create = stockTemplate},
		["Enforcer"] =			{strength = 75,	missile_only = false,	missile_primary = true,		missile_secondary = false,	short_range_radar = 9000,	hop_angle = 0,	hop_range = 1480,	create = enforcer},
		["Dreadnought"] =		{strength = 80,	missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 9000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Starhammer III"] =	{strength = 85,	missile_only = false,	missile_primary = false,	missile_secondary = true,	short_range_radar = 12000,	hop_angle = 0,	hop_range = 1480,	create = starhammerIII},
		["Starhammer V"] =		{strength = 90,	missile_only = false,	missile_primary = false,	missile_secondary = true,	short_range_radar = 15000,	hop_angle = 0,	hop_range = 1480,	create = starhammerV},
		["Tyr"] =				{strength = 150,missile_only = false,	missile_primary = false,	missile_secondary = false,	short_range_radar = 9500,	hop_angle = 90,	hop_range = 2480,	create = tyr},
	}	
	no_ftl_template_pool = {"Gnat","Lite Drone","Jacket Drone","Ktlitan Drone","Heavy Drone","Adder MK3","MT52 Hornet","MU52 Hornet","Dagger","MV52 Hornet","MT55 Hornet","Adder MK4","Fighter","Ktlitan Fighter","FX64 Hornet","Blade","Gunner","K2 Fighter","Adder MK5","WX-Lindworm","K3 Fighter","Shooter","Jagger","Adder MK6","Ktlitan Scout","WZ-Lindworm","Adder MK7","Adder MK8","Adder MK9","Nirvana R3","Phobos R2","Missile Cruiser","Phobos T3","Guard","Piranha F8","Piranha F12","Piranha F12.M","Phobos M3","Farco 3","Farco 5","Karnack","Gunship","Phobos T4","Cruiser","Nirvana R5","Farco 8","Nirvana R5A","Adv. Gunship","Ktlitan Worker","Farco 11","Storm","Warden","Farco 13","Sentinel","Ranus U","Flash","Ranger","Buster","Whirlwind","Tempest","Maniapak","Cucaracha","Ktlitan Breaker","Ktlitan Feeder","Ktlitan Destroyer","K2 Breaker","Blockade Runner","Enforcer","Dreadnought",}
	ftl_template_pool = {"Waddle 5","Jade 5","Racer","Dash","Stalker Q7","Stalker R7","Hunter","Adv. Striker","Strikeship","Predator","Hurricane","Atlantis X23","Atlantis Y42","Starhammer II","Starhammer III","Starhammer V","Tyr",}
	commonGoods = {
		_("trade-comms","food"),			-- 1
		_("trade-comms","medicine"),		-- 2
		_("trade-comms","luxury"),			-- 3
		_("trade-comms","nickel"),			-- 4
		_("trade-comms","platinum"),		-- 5
		_("trade-comms","gold"),			-- 6
		_("trade-comms","dilithium"),		-- 7
		_("trade-comms","tritanium"),		-- 8
		_("trade-comms","cobalt"),			-- 9
		_("trade-comms","impulse"),			--10
		_("trade-comms","warp"),			--11
		_("trade-comms","shield"),			--12
		_("trade-comms","tractor"),			--13
		_("trade-comms","repulsor"),		--14
		_("trade-comms","beam"),			--15
		_("trade-comms","optic"),			--16
		_("trade-comms","robotic"),			--17
		_("trade-comms","filament"),		--18
		_("trade-comms","transporter"),		--19
		_("trade-comms","sensor"),			--20
		_("trade-comms","communication"),	--21
		_("trade-comms","autodoc"),			--22
		_("trade-comms","lifter"),			--23
		_("trade-comms","android"),			--24
		_("trade-comms","nanites"),			--25
		_("trade-comms","software"),		--26
		_("trade-comms","circuit"),			--27
		_("trade-comms","battery"),			--28
	}
	componentGoods = {
		_("trade-comms","impulse"),
		_("trade-comms","warp"),
		_("trade-comms","shield"),
		_("trade-comms","tractor"),
		_("trade-comms","repulsor"),
		_("trade-comms","beam"),
		_("trade-comms","optic"),
		_("trade-comms","robotic"),
		_("trade-comms","filament"),
		_("trade-comms","transporter"),
		_("trade-comms","sensor"),
		_("trade-comms","communication"),
		_("trade-comms","autodoc"),
		_("trade-comms","lifter"),
		_("trade-comms","android"),
		_("trade-comms","nanites"),
		_("trade-comms","software"),
		_("trade-comms","circuit"),
		_("trade-comms","battery"),
	}
	mineralGoods = {
		_("trade-comms","nickel"),
		_("trade-comms","platinum"),
		_("trade-comms","gold"),
		_("trade-comms","dilithium"),
		_("trade-comms","tritanium"),
		_("trade-comms","cobalt"),
	}
	vapor_goods = {
		_("trade-comms","gold pressed latinum"),
		_("trade-comms","unobtanium"),
		_("trade-comms","eludium"),
		_("trade-comms","impossibrium"),
	}
	characters = {
		{name = "Frank Brown", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Joyce Miller", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Harry Jones", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Emma Davis", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Zhang Wei Chen", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Yu Yan Li", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Li Wei Wang", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Li Na Zhao", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Sai Laghari", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Anaya Khatri", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Vihaan Reddy", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Trisha Varma", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Henry Gunawan", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Putri Febrian", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Stanley Hartono", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Citra Mulyadi", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Bashir Pitafi", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Hania Kohli", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Gohar Lehri", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Sohelia Lau", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Gabriel Santos", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Ana Melo", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Lucas Barbosa", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Juliana Rocha", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Habib Oni", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Chinara Adebayo", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Tanimu Ali", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Naija Bello", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Shamim Khan", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Barsha Tripura", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Sumon Das", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Farah Munsi", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Denis Popov", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Pasha Sokolov", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Burian Ivanov", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Radka Vasiliev", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Jose Hernandez", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Victoria Garcia", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Miguel Lopez", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Renata Rodriguez", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
	}
	if spew_function_diagnostic then print("bottom of set constants") end
end
-- Terrain and environment creation functions
function constructEnvironment()
	if spew_function_diagnostic then print("top of construct environment") end
	--	Charles Acosta's freighter - central to the first part of the plot
	needy_freighter = CpuShip():setTemplate("Goods Freighter 1"):setFaction("Independent"):setPosition(center_x,center_y):setCommsScript(""):setCommsFunction(commsShip)
	needy_freighter:setCallSign(getFactionPrefix("Independent"))
	needy_freighter:setSystemHealthMax("impulse",random(-.7,-.5))	--damaged engines
	--	asteroid field that Acosta was working
	for i=1,math.random(5,10) do
		local size = 0
		for j=1,4 do
			size = size + random(5,180)
		end
		local ax, ay = vectorFromAngleNorth(asteroid_field_angle + random(-45,45),800 + (random(size,size + 300) * i))
		local as = Asteroid():setPosition(center_x + ax, center_y + ay):setSize(size)
		size = 0
		for j=1,4 do
			size = size + random(5,180)
		end
		ax, ay = vectorFromAngleNorth(asteroid_field_angle + random(-45,45),800 + (random(size,size + 300) * i))
		as = VisualAsteroid():setPosition(center_x + ax, center_y + ay):setSize(size)
		size = 0
		for j=1,4 do
			size = size + random(5,180)
		end
		ax, ay = vectorFromAngleNorth(asteroid_field_angle + random(-45,45),800 + (random(size,size + 300) * i))
		as = VisualAsteroid():setPosition(center_x + ax, center_y + ay):setSize(size)
	end
	local needy_station_angle = asteroid_field_angle + random(170,190)
	local psx, psy = vectorFromAngleNorth(needy_station_angle,random(8000,16000))
	inner_circle = {}
	station_list = {}
	--	station Acosta was going to deliver minerals to until the engines went out
	station_needy_freighter = placeStation(center_x + psx,center_y + psy,"RandomHumanNeutral","Independent")
	station_needy_freighter:onTakingDamage(stationDamaged):onDestruction(stationDestroyed)
	table.insert(inner_circle,station_needy_freighter)
	table.insert(station_list,station_needy_freighter)
	--	moon, planet and star that the station is attached to (station in synchronous orbit around moon, moon orbits planet, planet orbits star
	local moon_x, moon_y = vectorFromAngleNorth(asteroid_field_angle + 180,3000)
	local moon_list = {
		{
			name = {"Ganymede", "Europa", "Deimos", "Callisto", "Amalthea"},
			texture = {
				surface = "planets/moon-1.png"
			}
		},
		{
			name = {"Himalia", "Ananke", "Pasiphe", "Sinope", "Lysithea"},
			texture = {
				surface = "planets/moon-2.png"
			}
		},
		{
			name = {"Leda", "Adrastea", "Arinome", "Metis", "Chaldene"},
			texture = {
				surface = "planets/moon-3.png"
			}
		},
	}
	local selected_moon = tableRemoveRandom(moon_list)
	needy_moon = Planet():setPlanetRadius(1500):setPosition(center_x + psx + moon_x,center_y + psy + moon_y)
	needy_moon:setCallSign(selected_moon.name[math.random(1,#selected_moon.name)])
	needy_moon:setPlanetSurfaceTexture(selected_moon.texture.surface)
	needy_moon:setAxialRotationTime(random(500,900)):setDistanceFromMovementPlane(0)
	station_needy_freighter.moon_angle = needy_station_angle + 180
	station_needy_freighter.moon_distance = distance(center_x + psx + moon_x,center_y + psy + moon_y,center_x + psx,center_y + psy)
	local sx, sy = vectorFromAngleNorth(station_needy_freighter.moon_angle,station_needy_freighter.moon_distance)
	local mx, my = needy_moon:getPosition()
	station_needy_freighter:setPosition(mx + sx, my + sy)
	local planet_list = {
		{
			name = {"Biju","Aldea","Bersallis"},
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
	local selected_planet = tableRemoveRandom(planet_list)
	local planet_x, planet_y = vectorFromAngleNorth(asteroid_field_angle + 180,20000)
	needy_planet = Planet():setPlanetRadius(8000):setPosition(center_x + psx + moon_x + planet_x,center_y + psy + moon_y + planet_y)
	needy_planet:setCallSign(selected_planet.name[math.random(1,#selected_planet.name)])
	needy_planet:setPlanetSurfaceTexture(selected_planet.texture.surface)
	if selected_planet.texture.atmosphere ~= nil then
		needy_planet:setPlanetAtmosphereTexture(selected_planet.texture.atmosphere)
	end
	if selected_planet.texture.cloud ~= nil then
		needy_planet:setPlanetCloudTexture(selected_planet.texture.cloud)
	end
	if selected_planet.color ~= nil then
		needy_planet:setPlanetAtmosphereColor(selected_planet.color.red, selected_planet.color.green, selected_planet.color.blue)
	end
	needy_planet:setAxialRotationTime(random(350,500)):setDistanceFromMovementPlane(0)
	star_list = {
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
	local selected_star = math.random(1,#star_list)
	local star_x, star_y = vectorFromAngleNorth(asteroid_field_angle + 180,50000)
	needy_star = Planet():setPlanetRadius(star_list[selected_star].radius):setPosition(center_x + psx + moon_x + planet_x + star_x,center_y + psy + moon_y + planet_y + star_y)
	needy_star:setCallSign(star_list[selected_star].name[math.random(1,#star_list[selected_star].name)]):setDistanceFromMovementPlane(star_list[selected_star].radius*-.5)
	needy_star:setPlanetAtmosphereTexture(star_list[selected_star].texture.atmosphere):setPlanetAtmosphereColor(random(0.8,1),random(0.8,1),random(0.8,1)):setDistanceFromMovementPlane(-500)
	needy_planet:setOrbit(needy_star,24000)	--final 24000
	needy_moon:setOrbit(needy_planet,3000)	--final 3000
	--	primary arms of stations in the 3 directions away from the star
	--	3 in the inner circle plus the orbiting station, total of 4 (Independent)
	--	6 in the outer circle (3 Ghosts, 3 TSN)
	--	6 in the peripheral circle (3 Independent, 3 USN)
	local base_angles = {
		asteroid_field_angle,
		asteroid_field_angle + 90,
		asteroid_field_angle + 270,
	}
	local placed_station = nil
	outer_circle = {}
	peripheral_circle = {}
	local ghost_anchors = {}
	local usn_anchors = {}
	local larger_candidate_coordinates = {}
	for i,angle in ipairs(base_angles) do
		psx, psy = vectorFromAngleNorth(angle + random(-20,20),random(15000,50000))
		placed_station = placeStation(center_x + psx,center_y + psy,"RandomHumanNeutral","Independent")
		placed_station.base_angle = angle
		placed_station:onTakingDamage(stationDamaged):onDestruction(stationDestroyed)
		table.insert(inner_circle,placed_station)
		table.insert(station_list,placed_station)
		outer_psx, outer_psy = vectorFromAngleNorth(angle,random(15000,30000))
		placed_station = placeStation(center_x + psx + outer_psx,center_y + psy + outer_psy,"Sinister","Ghosts")
		placed_station.base_angle = angle
		placed_station:onTakingDamage(stationDamaged):onDestruction(stationDestroyed)
		table.insert(outer_circle,placed_station)
		table.insert(station_list,placed_station)
		table.insert(ghost_anchors,placed_station)
		outer_2_psx, outer_2_psy = vectorFromAngleNorth(angle + random(-50,50),random(15000,30000))
		placed_station = placeStation(center_x + psx + outer_psx + outer_2_psx,center_y + psy + outer_psy + outer_2_psy,"RandomHumanNeutral","TSN")
		placed_station.base_angle = angle
		placed_station:onTakingDamage(stationDamaged):onDestruction(stationDestroyed)
		table.insert(outer_circle,placed_station)
		table.insert(station_list,placed_station)
		local sx, sy = placed_station:getPosition()
		local lx, ly = vectorFromAngleNorth(angle + 90,random(15000,50000))
		if i == 2 then
			lx, ly = vectorFromAngleNorth(angle + 90,random(15000,25000))
		end
		lx = lx + sx
		ly = ly + sy
		table.insert(larger_candidate_coordinates,{x = lx,y = ly,radius = distance(lx,ly,sx,sy)/2})
		lx, ly = vectorFromAngleNorth(angle + 270,random(15000,50000))
		if i == 3 then
			lx, ly = vectorFromAngleNorth(angle + 270,random(15000,25000))
		end
		lx = lx + sx
		ly = ly + sy
		table.insert(larger_candidate_coordinates,{x = lx,y = ly,radius = distance(lx,ly,sx,sy)/2})
		peripheral_psx, peripheral_psy = vectorFromAngleNorth(angle,random(20000,50000))
		placed_station = placeStation(center_x + psx + outer_psx + outer_2_psx + peripheral_psx,center_y + psy + outer_psy + outer_2_psy + peripheral_psy,"RandomHumanNeutral","Independent")
		placed_station.base_angle = angle
		placed_station:onTakingDamage(stationDamaged):onDestruction(stationDestroyed)
		table.insert(station_list,placed_station)
		table.insert(peripheral_circle,placed_station)
		peripheral_2_psx, peripheral_2_psy = vectorFromAngleNorth(angle + random(-90,90),random(12000,30000))
		placed_station = placeStation(center_x + psx + outer_psx + outer_2_psx + peripheral_psx + peripheral_2_psx,center_y + psy + outer_psy + outer_2_psy + peripheral_psy + peripheral_2_psy,"RandomHumanNeutral","USN")
		placed_station.base_angle = angle
		placed_station:onTakingDamage(stationDamaged):onDestruction(stationDestroyed)
		table.insert(peripheral_circle,placed_station)
		table.insert(station_list,placed_station)
		table.insert(usn_anchors,placed_station)
	end
	--	Exuari enemy stations right in the middle of it all, between the Ghosts' stations
	nearby_enemy_stations = {}
	exuari_station_names = {}
	local largest_coordinate_candidates = {}
	local u1x, u1y = usn_anchors[1]:getPosition()
	local u2x, u2y = usn_anchors[2]:getPosition()
	local usn_angle = angleFromVectorNorth(u2x,u2y,u1x,u1y)
	local usn_distance = distance(u1x,u1y,u2x,u2y)
	local cx, cy = vectorFromAngleNorth(usn_angle,usn_distance/3)
	table.insert(largest_coordinate_candidates,{x = u1x + cx, y = u1y + cy,radius = usn_distance/6})
	cx, cy = vectorFromAngleNorth(usn_angle + 180,usn_distance/3)
	table.insert(largest_coordinate_candidates,{x = u2x + cx, y = u2y + cy,radius = usn_distance/6})
	u1x, u1y = usn_anchors[1]:getPosition()
	u2x, u2y = usn_anchors[3]:getPosition()
	usn_angle = angleFromVectorNorth(u2x,u2y,u1x,u1y)
	usn_distance = distance(u1x,u1y,u2x,u2y)
	cx, cy = vectorFromAngleNorth(usn_angle,usn_distance/3)
	table.insert(largest_coordinate_candidates,{x = u1x + cx, y = u1y + cy,radius = usn_distance/6})
	cx, cy = vectorFromAngleNorth(usn_angle + 180,usn_distance/3)
	table.insert(largest_coordinate_candidates,{x = u2x + cx, y = u2y + cy,radius = usn_distance/6})
	local minefield_coordinate_candidates = {}
	local g1x, g1y = ghost_anchors[1]:getPosition()
	local g2x, g2y = ghost_anchors[2]:getPosition()
	psx = (g1x + g2x)/2
	psy = (g1y + g2y)/2
	placed_station = placeStation(psx, psy,"Sinister","Exuari")
	placed_station:onTakingDamage(stationDamaged):onDestruction(stationDestroyed)
	table.insert(exuari_station_names,placed_station:getCallSign())
	table.insert(station_list,placed_station)
	table.insert(nearby_enemy_stations,placed_station)
	local minefield_radius = distance(g1x,g1y,psx,psy)/4
	table.insert(minefield_coordinate_candidates,{x = (g1x + psx)/2, y = (g1y + psy)/2, radius = minefield_radius})
	table.insert(minefield_coordinate_candidates,{x = (g2x + psx)/2, y = (g2y + psy)/2, radius = minefield_radius})
	needy_freighter_attackers = {}
	secondary_order_list = {}
	--	Initial Exuari attacking ship
	local ship_angle = angleFromVectorNorth(psx, psy, player_spawn_x, player_spawn_y)
	local ship_x, ship_y = vectorFromAngleNorth(ship_angle,22500)
	local enemy = CpuShip():setTemplate("Adder MK5"):setPosition(ship_x + player_spawn_x,ship_y + player_spawn_y):setFaction("Exuari"):orderAttack(needy_freighter):setCallSign(getFactionPrefix("Exuari"))
	table.insert(needy_freighter_attackers,enemy)
	table.insert(secondary_order_list,enemy)
	g1x, g1y = ghost_anchors[1]:getPosition()
	g2x, g2y = ghost_anchors[3]:getPosition()
	psx = (g1x + g2x)/2
	psy = (g1y + g2y)/2
	placed_station = placeStation(psx, psy,"Sinister","Exuari")
	placed_station:onTakingDamage(stationDamaged):onDestruction(stationDestroyed)
	table.insert(exuari_station_names,placed_station:getCallSign())
	table.insert(station_list,placed_station)
	table.insert(nearby_enemy_stations,placed_station)
	--	Minefields around the Exuari
	local other_minefield_radius = distance(g1x,g1y,psx,psy)/4
	table.insert(minefield_coordinate_candidates,{x = (g1x + psx)/2, y = (g1y + psy)/2, radius = other_minefield_radius})
	table.insert(minefield_coordinate_candidates,{x = (g2x + psx)/2, y = (g2y + psy)/2, radius = other_minefield_radius})
	minefield_radius = (minefield_radius + other_minefield_radius)/2
	local minefield_angle = angleFromVectorNorth(psx,psy,center_x,center_y)
	local mx, my = vectorFromAngleNorth(minefield_angle,minefield_radius*2)
	table.insert(minefield_coordinate_candidates,{x = mx + psx, y = my + psy, radius = minefield_radius})
	mx, my = vectorFromAngleNorth(minefield_angle + 180,minefield_radius*2)
	table.insert(minefield_coordinate_candidates,{x = mx + psx, y = my + psy, radius = minefield_radius})
	local sx, sy = station_list[#station_list - 1]:getPosition()
	minefield_angle = angleFromVectorNorth(sx,sy,center_x,center_y)
	mx, my = vectorFromAngleNorth(minefield_angle,minefield_radius*2)
	table.insert(minefield_coordinate_candidates,{x = mx + sx, y = my + sy, radius = minefield_radius})
	mx, my = vectorFromAngleNorth(minefield_angle + 180,minefield_radius*2)
	table.insert(minefield_coordinate_candidates,{x = mx + sx, y = my + sy, radius = minefield_radius})
	local black_hole_coordinate_candidates = {}
	for i,field in ipairs(minefield_coordinate_candidates) do
		if random(1,100) <= 42 then
			placeMinefieldBlob(field.x,field.y,field.radius*.37)
		else
			table.insert(black_hole_coordinate_candidates,field)
		end
	end
	local asteroid_field_coordinate_candidates = {}
	--	black holes around the Exuari
	for i,hole in ipairs(black_hole_coordinate_candidates) do
		if random(1,100) <= 26 then
			BlackHole():setPosition(hole.x,hole.y)
		else
			table.insert(asteroid_field_coordinate_candidates,hole)
		end
	end
	local planet_coordinate_candidates = {}
	--	asteroid blobs around the Exuari
	for i,field in ipairs(asteroid_field_coordinate_candidates) do
		if random(1,100) <= 42 then
			placeAsteroidBlob(field.x,field.y,field.radius*.37)
		else
			table.insert(planet_coordinate_candidates,field)
		end
	end
	local warp_jammer_coordinate_candidates = {}
	--	planets and moons around the Exuari
	for i,left in ipairs(planet_coordinate_candidates) do
		if random(1,100) <= 42 then
			selected_planet = tableRemoveRandom(planet_list)
			if selected_planet ~= nil then
				local scattered_planet = Planet():setPlanetRadius(left.radius/2):setPosition(left.x,left.y)
				scattered_planet:setCallSign(selected_planet.name[math.random(1,#selected_planet.name)])
				scattered_planet:setPlanetSurfaceTexture(selected_planet.texture.surface)
				if selected_planet.texture.atmosphere ~= nil then
					scattered_planet:setPlanetAtmosphereTexture(selected_planet.texture.atmosphere)
				end
				if selected_planet.texture.cloud ~= nil then
					scattered_planet:setPlanetCloudTexture(selected_planet.texture.cloud)
				end
				if selected_planet.color ~= nil then
					scattered_planet:setPlanetAtmosphereColor(selected_planet.color.red,selected_planet.color.green,selected_planet.color.blue)
				end
				scattered_planet:setAxialRotationTime(random(350,500))
				selected_moon = tableRemoveRandom(moon_list)
				if selected_moon ~= nil then
					local scattered_moon = Planet():setPlanetRadius(left.radius/8):setPosition(left.x,left.y + left.radius - left.radius/16)
					scattered_moon:setCallSign(selected_moon.name[math.random(1,#selected_moon.name)])
					scattered_moon:setPlanetSurfaceTexture(selected_moon.texture.surface)
					scattered_moon:setAxialRotationTime(random(500,900))
					scattered_moon:setOrbit(scattered_planet,random(100,200))
				end
			end
		else
			table.insert(warp_jammer_coordinate_candidates,left)
		end
	end
	local wormhole_coordinate_candidates = {}
	--	warp jammers around the exuari
	for i,left in ipairs(warp_jammer_coordinate_candidates) do
		if random(1,100) <= 42 then
			WarpJammer():setPosition(left.x,left.y):setRange(left.radius)
		else
			table.insert(wormhole_coordinate_candidates,left)
		end
	end
	local leftovers = {}
	--	wormholes around the Exuari
	for i,left in ipairs(wormhole_coordinate_candidates) do
		if random(1,100) <= 42 then
			local wh = WormHole():setPosition(left.x,left.y)
			local snx, sny = station_needy_freighter:getPosition()
			wh:onTeleportation(wormholeToOrbiter):setTargetPosition(snx,sny)
		else
			table.insert(leftovers,left)
		end
	end
	--	add larger terrain gaps to the list of locations
	for i,larger in ipairs(larger_candidate_coordinates) do
		table.insert(leftovers,larger)
	end
	minefield_coordinate_candidates = {}
	--	more asteroid blobs
	for i,left in ipairs(leftovers) do
		if random(1,100) <= 68 then
			placeAsteroidBlob(left.x,left.y,left.radius*.37)
		else
			table.insert(minefield_coordinate_candidates,left)
		end
	end
	warp_jammer_coordinate_candidates = {}
	--	more minefield blobs
	for i,left in ipairs(minefield_coordinate_candidates) do
		if random(1,100) <= 71 then
			placeMinefieldBlob(left.x,left.y,left.radius*.37)
		else
			table.insert(warp_jammer_coordinate_candidates,left)
		end
	end
	black_hole_coordinate_candidates = {}
	--	more warp jammers
	for i,left in ipairs(warp_jammer_coordinate_candidates) do
		if random(1,100) <= 55 then
			WarpJammer():setPosition(left.x,left.y):setRange(left.radius)
		else
			table.insert(black_hole_coordinate_candidates,left)
		end
	end
	wormhole_coordinate_candidates = {}
	--	more black holes
	for i,left in ipairs(black_hole_coordinate_candidates) do
		if random(1,100) <= 36 then
			BlackHole():setPosition(left.x,left.y)
		else
			table.insert(wormhole_coordinate_candidates,left)
		end
	end
	--	fill the rest with wormholes
	for i,left in ipairs(wormhole_coordinate_candidates) do
		local wh = WormHole():setPosition(left.x,left.y)
		local snx, sny = station_needy_freighter:getPosition()
		wh:onTeleportation(wormholeToOrbiter):setTargetPosition(snx,sny)
	end
	--	fill the largest terrain gaps starting with asteroid blobs
	minefield_coordinate_candidates = {}
	for i,left in ipairs(largest_coordinate_candidates) do
		if random(1,100) <= 68 then
			placeAsteroidBlob(left.x,left.y,left.radius*.37)
		else
			table.insert(minefield_coordinate_candidates,left)
		end
	end
	wormhole_coordinate_candidates = {}
	--	more minefield blobs
	for i,left in ipairs(minefield_coordinate_candidates) do
		if random(1,100) <= 71 then
			placeMinefieldBlob(left.x,left.y,left.radius*.37)
		else
			table.insert(wormhole_coordinate_candidates,left)
		end
	end
	black_hole_coordinate_candidates = {}
	--	more wormholes
	for i,left in ipairs(wormhole_coordinate_candidates) do
		if random(1,100) <= 42 then
			local wh = WormHole():setPosition(left.x,left.y)
			local snx, sny = station_needy_freighter:getPosition()
			wh:onTeleportation(wormholeToOrbiter):setTargetPosition(snx,sny)
		else
			table.insert(black_hole_coordinate_candidates,left)
		end
	end
	--	put black holes in whatever is left
	for i,left in ipairs(black_hole_coordinate_candidates) do
		BlackHole():setPosition(left.x,left.y)
	end
	--	fill in some of the gaps
	local scattered_objects = 0
	local pie_left = asteroid_field_angle + 260
	local pie_right = asteroid_field_angle + 100
	if pie_right < pie_left then
		pie_right = pie_right + 360
	end
	obj_type_sizes = {
		{typ = "Planet",		siz = 10000},
		{typ = "BlackHole",		siz = 6000},
		{typ = "WormHole",		siz = 5500},
		{typ = "WarpJammer",	siz = 5000},
		{typ = "mineblob",		siz = 4000},
		{typ = "asteroidblob",	siz = 3500},
		{typ = "Mine",			siz = 2000},
		{typ = "Asteroid",		siz = 1000},
	}
	repeat
		local ox, oy = vectorFromAngleNorth(random(pie_left,pie_right),(random(2500,100000) + random(2500,100000)))
		ox = ox + center_x
		oy = oy + center_y
		local obj_list = getObjectsInRadius(ox, oy, 20000)
		local closest_distance = 20000
		local closest_obj = nil
		for i,obj in ipairs(obj_list) do
			local obj_dist = distance(obj,ox,oy)
			if obj_dist < closest_distance then
				closest_distance = obj_dist
				closest_obj = obj
			end
		end
		local type_list = {}
		for i,type_size in ipairs(obj_type_sizes) do
			if type_size.siz < closest_distance then
				table.insert(type_list,type_size.typ)
			end
		end
		if #type_list > 0 then
			local insert_type = type_list[math.random(1,#type_list)]
			if insert_type == "Planet" then
				closest_distance = math.min(closest_distance * .95,20000)
				selected_planet = tableRemoveRandom(planet_list)
				if selected_planet ~= nil then
					local scattered_planet = Planet():setPlanetRadius(closest_distance/2):setPosition(ox,oy)
					scattered_planet:setCallSign(selected_planet.name[math.random(1,#selected_planet.name)])
					scattered_planet:setPlanetSurfaceTexture(selected_planet.texture.surface)
					if selected_planet.texture.atmosphere ~= nil then
						scattered_planet:setPlanetAtmosphereTexture(selected_planet.texture.atmosphere)
					end
					if selected_planet.texture.cloud ~= nil then
						scattered_planet:setPlanetCloudTexture(selected_planet.texture.cloud)
					end
					if selected_planet.color ~= nil then
						scattered_planet:setPlanetAtmosphereColor(selected_planet.color.red,selected_planet.color.green,selected_planet.color.blue)
					end
					scattered_planet:setAxialRotationTime(random(350,500))
					selected_moon = tableRemoveRandom(moon_list)
					if selected_moon ~= nil then
						local scattered_moon = Planet():setPlanetRadius(closest_distance/8):setPosition(ox,oy + closest_distance - closest_distance/16)
						scattered_moon:setCallSign(selected_moon.name[math.random(1,#selected_moon.name)])
						scattered_moon:setPlanetSurfaceTexture(selected_moon.texture.surface)
						scattered_moon:setAxialRotationTime(random(500,900))
						scattered_moon:setOrbit(scattered_planet,random(100,200))
					end
				end
			elseif insert_type == "BlackHole" then
				BlackHole():setPosition(ox,oy)
			elseif insert_type == "WormHole" then
				local wh = WormHole():setPosition(ox,oy)
				local snx, sny = station_needy_freighter:getPosition()
				wh:onTeleportation(wormholeToOrbiter):setTargetPosition(snx,sny)
			elseif insert_type == "WarpJammer" then
				closest_distance = math.min(closest_distance * .95,20000)
				WarpJammer():setPosition(ox,oy):setRange(closest_distance)
			elseif insert_type == "mineblob" then
				closest_distance = math.min(closest_distance,15000)
				placeMinefieldBlob(ox,oy,closest_distance*.37)
			elseif insert_type == "asteroidblob" then
				closest_distance = math.min(closest_distance,15000)
				placeAsteroidBlob(ox,oy,closest_distance*.37)
			elseif insert_type == "Mine" then
				Mine():setPosition(ox,oy)
			elseif insert_type == "Asteroid" then
				Asteroid():setPosition(ox,oy):setSize(random(20,950))
				VisualAsteroid():setPosition(ox + random(-200,200), oy + random(-200,200))
				VisualAsteroid():setPosition(ox + random(-200,200), oy + random(-200,200))
			end
		end
		scattered_objects = scattered_objects + 1
	until(scattered_objects > terrain_density)
	--	Second Exuari attacking ship
	ship_angle = angleFromVectorNorth(psx, psy, player_spawn_x, player_spawn_y)
	ship_x, ship_y = vectorFromAngleNorth(ship_angle,22500)
	enemy = CpuShip():setTemplate("MT52 Hornet"):setPosition(ship_x + player_spawn_x,ship_y + player_spawn_y):setFaction("Exuari"):orderFlyTowards(center_x,center_y):setCallSign(getFactionPrefix("Exuari"))
	table.insert(needy_freighter_attackers,enemy)
	table.insert(secondary_order_list,enemy)
	victim_station_names = {}
	for i,station in ipairs(station_list) do
		if station ~= nil and station:isValid() and station:getFaction() ~= "Exuari" and station:getFaction() ~= "Ghosts" then
			table.insert(victim_station_names,station:getCallSign())
		end
	end
	plotTriggerExuariWave = needyFreighterAttackers
	maintenancePlot = defenseMaintenance
	if spew_function_diagnostic then print("bottom of construct environment") end
end
function wormholeToOrbiter(self,teleportee)
	if teleportee.typeName == "CpuShip" or teleportee.typeName == "PlayerSpaceship" then
		teleportee:setSystemHealth("beamweapons",teleportee:getSystemHealth("beamweapons") - .5)
		teleportee:setSystemHealth("missilesystem",teleportee:getSystemHealth("missilesystem") - .5)
		if teleportee.typeName == "PlayerSpaceship" then
			teleportee:setEnergy(teleportee:getEnergy()/2)
		end
		if station_needy_freighter ~= nil and station_needy_freighter:isValid() then
			local snx, sny = station_needy_freighter:getPosition()
			self:setTargetPosition(snx,sny)
			teleportee:setPosition(snx,sny)
		end
	end
end
function placeAsteroidBlob(x,y,field_radius)
	local asteroid_list = {}
	local a = Asteroid():setPosition(x,y)
	local size = random(10,400) + random(10,400)
	a:setSize(size)
	table.insert(asteroid_list,a)
	local va = VisualAsteroid():setPosition(x + random(-200,200), y + random(-200,200))
	va:setSize(random(10,400) + random(10,400))
	va = VisualAsteroid():setPosition(x + random(-200,200), y + random(-200,200))
	va:setSize(random(10,400) + random(10,400))
	local reached_the_edge = false
	repeat
		local overlay = false
		local nax = nil
		local nay = nil
		repeat
			overlay = false
			local base_asteroid_index = math.random(1,#asteroid_list)
			local base_asteroid = asteroid_list[base_asteroid_index]
			local bax, bay = base_asteroid:getPosition()
			local angle = random(0,360)
			size = random(10,400) + random(10,400)
			local asteroid_space = (base_asteroid:getSize() + size)*random(1.05,1.25)
			nax, nay = vectorFromAngleNorth(angle,asteroid_space)
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
		a = Asteroid():setPosition(nax,nay)
		a:setSize(size)
		table.insert(asteroid_list,a)
		va = VisualAsteroid():setPosition(nax + random(-200,200), nay + random(-200,200))
		va:setSize(random(10,400) + random(10,400))
		va = VisualAsteroid():setPosition(nax + random(-200,200), nay + random(-200,200))
		va:setSize(random(10,400) + random(10,400))
		if distance(x,y,nax,nay) > field_radius then
			reached_the_edge = true
		end
	until(reached_the_edge)
	return asteroid_list
end
function placeMinefieldBlob(x,y,mine_blob_radius)
	local mine_list = {}
	table.insert(mine_list,Mine():setPosition(x,y))
	local reached_the_edge = false
	local mine_space = 1400
	repeat
		local overlay = false
		local nmx = nil
		local nmy = nil
		repeat
			overlay = false
			local base_mine_index = math.random(1,#mine_list)
			local base_mine = mine_list[base_mine_index]
			local bmx, bmy = base_mine:getPosition()
			local angle = random(0,360)
			nmx, nmy = vectorFromAngleNorth(angle,mine_space)
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
		if distance(x, y, nmx, nmy) > mine_blob_radius then
			reached_the_edge = true
		end
	until(reached_the_edge)
	return mine_list
end
function spreadUpgradeServices(stations,tempTypeName,thickness,limit)
	if spew_function_diagnostic then print("top of spread upgrade services") end
	if thickness == nil or thickness < 1 or thickness > 3 then
		print("Thickness must be between 1 and 3 inclusive for the spread upgrade services function")
		return
	end
	if stations == nil or #stations < 1 then
		print("There needs to be at least 1 station in the stations list for the spread upgrade services function")
		return
	end
	if limit == nil then
		limit = 1
	else
		if limit > 1 or limit <= 0 then
			print("Limit needs to be between 0 and 1 for the spread upgrade services function")
			return
		end
	end
	local station_service_pool = {
		"beam","missiles","shield","hull","impulse","ftl","sensors",
	}
	local station_pool = {}
	while(#station_service_pool > 0) do
		local service = tableRemoveRandom(station_service_pool)
		if #station_pool < 1 then
			for _,station in ipairs(stations) do
				if station ~= nil and station:isValid() then
					table.insert(station_pool,station)
				end
			end
			if #station_pool < 1 then
				print("There must be at least 1 valid station in the stations list for the spread upgrade services function")
				return
			end
		end
		local station_1 = nil
		local station_2 = nil
		local station_3 = nil
		station_1 = tableRemoveRandom(station_pool)
		if thickness > 1 then
			if #station_pool < 1 then
				for _,station in ipairs(stations) do
					if station ~= nil and station:isValid() then
						table.insert(station_pool,station)
					end
				end
			end
			station_2 = tableRemoveRandom(station_pool)
			if thickness > 2 then
				if #station_pool < 1 then
					for _,station in ipairs(stations) do
						if station ~= nil and station:isValid() then
							table.insert(station_pool,station)
						end
					end
				end
				station_3 = tableRemoveRandom(station_pool)
			end
		end
		if station_1.comms_data.upgrade_path == nil then
			station_1.comms_data.upgrade_path = {}
		end
		if station_1.comms_data.upgrade_path[tempTypeName] == nil then
			station_1.comms_data.upgrade_path[tempTypeName] = {}
		end
		station_1.comms_data.upgrade_path[tempTypeName][service] = math.floor(#upgrade_path[tempTypeName][service] * limit)
		if thickness > 1 then
			if station_2.comms_data.upgrade_path == nil then
				station_2.comms_data.upgrade_path = {}
			end
			if station_2.comms_data.upgrade_path[tempTypeName] == nil then
				station_2.comms_data.upgrade_path[tempTypeName] = {}
			end
			station_2.comms_data.upgrade_path[tempTypeName][service] = math.floor(#upgrade_path[tempTypeName][service] * limit)
			if thickness > 2 then
				if station_3.comms_data.upgrade_path == nil then
					station_3.comms_data.upgrade_path = {}
				end
				if station_3.comms_data.upgrade_path[tempTypeName] == nil then
					station_3.comms_data.upgrade_path[tempTypeName] = {}
				end
				station_3.comms_data.upgrade_path[tempTypeName][service] = math.floor(#upgrade_path[tempTypeName][service] * limit)
			end
		end
	end
	if spew_function_diagnostic then print("bottom of spread upgrade services") end
end
--	Player setup functions
function setPlayers(p)
	if spew_function_diagnostic then print("top of set players") end
	if p == nil then
		return
	end
	p:setPosition(player_spawn_x, player_spawn_y)
	--set defaults for those ships not found in the list
	p.shipScore = 24
	p.maxCargo = 5
	p.cargo = p.maxCargo
	p.tractor = false
	p.tractor_target_lock = false
	p.mining = false
	p.goods = {}
	p:setFaction("CUF")
	updatePlayerSoftTemplate(p)
	player_ship_spawn_count = player_ship_spawn_count + 1
	p:onDestruction(playerDestruction)
	if p:getReputationPoints() == 0 then
		p:setReputationPoints(reputation_start_amount)
	end
	if spew_function_diagnostic then print("bottom of set players") end
end
function updatePlayerSoftTemplate(p)
	if spew_function_diagnostic then print("top of update player soft template") end
	local tempTypeName = p:getTypeName()
	if tempTypeName ~= nil then
		if playerShipStats[tempTypeName] ~= nil then
			p.upgrade_path = {
				["beam"] = 1,
				["missiles"] = 1,
				["shield"] = 1,
				["hull"] = 1,
				["impulse"] = 1,
				["ftl"] = 1,
				["sensors"] = 1,
			}
			for i=0,15 do
				p:setBeamWeapon(i,0,0,0,0,0)
			end
			for i,b in ipairs(upgrade_path[tempTypeName].beam[1]) do
				p:setBeamWeapon(b.idx,b.arc,b.dir,b.rng,b.cyc,b.dmg)
				if b.tar ~= nil then
					p:setBeamWeaponTurret(b.idx,b.tar,b.tdr,b.trt)
				end
			end
			p:setWeaponTubeCount(0)
			local missile_trans = {
				{typ = "Homing", short_type = "hom"},
				{typ = "Nuke", short_type = "nuk"},
				{typ = "EMP", short_type = "emp"},
				{typ = "Mine", short_type = "min"},
				{typ = "HVLI", short_type = "hvl"},
			}
			if upgrade_path[tempTypeName].tube[1][1].idx >= 0 then
				p:setWeaponTubeCount(#upgrade_path[tempTypeName].tube[1])
				local size_trans = {
					["S"] = "small",
					["M"] = "medium",
					["L"] = "large",
				}
				for i,m in ipairs(upgrade_path[tempTypeName].tube[1]) do
					p:setWeaponTubeDirection(m.idx,m.dir)
					p:setTubeSize(m.idx,size_trans[m.siz])
					p:setTubeLoadTime(m.idx,m.spd)
					local exclusive = false
					for j,lm in ipairs(missile_trans) do
						if m[lm.short_type] then
							if exclusive then
								p:weaponTubeAllowMissle(m.idx,lm.typ)
							else
								p:setWeaponTubeExclusiveFor(m.idx,lm.typ)
								exclusive = true
							end
						end
					end
				end
			end
			for i,o in ipairs(missile_trans) do
				p:setWeaponStorageMax(o.typ,upgrade_path[tempTypeName].ordnance[1][o.short_type])
				p:setWeaponStorage(o.typ,upgrade_path[tempTypeName].ordnance[1][o.short_type])
			end
			if p:getWeaponTubeCount() > 0 then
				local size_letter = {
					["small"] = 	"S",
					["medium"] =	"M",
					["large"] =		"L",
				}
				p.tube_size = ""
				for i=1,p:getWeaponTubeCount() do
					p.tube_size = p.tube_size .. size_letter[p:getTubeSize(i-1)]
				end
			end
			p:setShieldsMax(upgrade_path[tempTypeName].shield[1][1].max)
			p:setShields(upgrade_path[tempTypeName].shield[1][1].max)
			p:setHullMax(upgrade_path[tempTypeName].hull[1].max)
			p:setHull(upgrade_path[tempTypeName].hull[1].max)
			p:setImpulseMaxSpeed(upgrade_path[tempTypeName].impulse[1].max_front,upgrade_path[tempTypeName].impulse[1].max_back)
			p:setAcceleration(upgrade_path[tempTypeName].impulse[1].accel_front,upgrade_path[tempTypeName].impulse[1].accel_back)
			p:setRotationMaxSpeed(upgrade_path[tempTypeName].impulse[1].turn)
			p:setCanCombatManeuver(false)
			p:setCombatManeuver(0,0)
			p.combat_maneuver_capable = false
			p:setJumpDrive(false)
			p:setWarpDrive(false)
			p:setLongRangeRadarRange(upgrade_path[tempTypeName].sensors[1].long)
			p.normal_long_range_radar = upgrade_path[tempTypeName].sensors[1].long
			p:setShortRangeRadarRange(upgrade_path[tempTypeName].sensors[1].short)
			p.prox_scan = upgrade_path[tempTypeName].sensors[1].prox_scan
			p.shipScore = upgrade_path[tempTypeName].score
			if not upgrade_path[tempTypeName].providers then
				spreadUpgradeServices(inner_circle,tempTypeName,2,.5)
				spreadUpgradeServices(outer_circle,tempTypeName,1,.75)
				spreadUpgradeServices(peripheral_circle,tempTypeName,3,1)
				upgrade_path[tempTypeName].providers = true
			end
			p.upgrade_state_rel = "upgrade_state_rel"
			p:addCustomButton("Relay",p.upgrade_state_rel,_("upgradeState-buttonRelay","Upgrade State"),function()
				string.format("")
				upgradeState(p,"Relay")
			end,99)
			p.upgrade_state_ops = "upgrade_state_ops"
			p:addCustomButton("Operations",p.upgrade_state_ops,_("upgradeState-buttonOperations","Upgrade State"),function()
				string.format("")
				upgradeState(p,"Operations")
			end,99)
			--set values from list
			p.maxCargo = playerShipStats[tempTypeName].cargo
			p.cargo = p.maxCargo
			p:setMaxScanProbeCount(playerShipStats[tempTypeName].probes)
			p:setScanProbeCount(p:getMaxScanProbeCount())
			p.tractor = playerShipStats[tempTypeName].tractor
			p.tractor_target_lock = false
			p.mining = playerShipStats[tempTypeName].mining
			local player_ship_name_list = player_ship_names_for[tempTypeName]
			local player_ship_name = nil
			if player_ship_name_list ~= nil then
				player_ship_name = tableRemoveRandom(player_ship_name_list)
			end
			if player_ship_name == nil then
				player_ship_name = tableRemoveRandom(player_ship_names_for["Leftovers"])
			end
			if player_ship_name ~= nil then
				p:setCallSign(player_ship_name)
			end
			p.score_settings_source = tempTypeName
			addShipUpgradeInfoToScienceDatabase(tempTypeName)
		else
			addGMMessage(string.format("Player ship %s's template type (%s) could not be found in table PlayerShipStats",p:getCallSign(),tempTypeName))
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
	local system_types = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
	p.normal_coolant_rate = {}
	p.normal_power_rate = {}
	for _, system in ipairs(system_types) do
		p.normal_coolant_rate[system] = p:getSystemCoolantRate(system)
		p.normal_power_rate[system] = p:getSystemPowerRate(system)
	end
	if spew_function_diagnostic then print("bottom of update player soft template") end
end
function upgradeState(p,console)
	local out = string.format(_("upgradeState-msgRelay","State of player ship %s along the tech upgrade path"),p:getCallSign())
	local u_types = {
		["beam"] = {name = _("upgradeState-msgRelay","Beam Weapons (range, damage, arc width, cycle time")},
		["ftl"] = {name = _("upgradeState-msgRelay","Faster Than Light engine (warp, jump)")},
		["missiles"] = {name = _("upgradeState-msgRelay","Missile Weapons (tubes, type, size, load time)")},
		["shield"] = {name = _("upgradeState-msgRelay","Shield")},
		["hull"] = {name = _("upgradeState-msgRelay","Hull")},
		["impulse"] = {name = _("upgradeState-msgRelay","Impulse (speed, acceleration, maneuverability, combat maneuver)")},
		["sensors"] = {name = _("upgradeState-msgRelay","Sensors (long range, short range, automated proximity scanner)")},
	}
	local temp_type = p:getTypeName()
	for u_type_name,u_type in pairs(u_types) do
		out = string.format("%s\n%s/%s %s",out,p.upgrade_path[u_type_name],#upgrade_path[temp_type][u_type_name],u_type.name)
	end
	p.upgrade_state_message = "upgrade_state_message"
	p:addCustomMessage(console,p.upgrade_state_message,out)
end

---------------------------
-- Station communication --
---------------------------
function commsStation()
	if spew_function_diagnostic then print("top of comms station") end
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
	if not comms_source:isEnemy(comms_target) then
		addStationToDatabase(comms_target)
	end
    comms_data = comms_target.comms_data
	if spew_function_diagnostic then print("bottom (ish) of comms station") end
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
function handleUndockedState()
    --Handle communications when we are not docked with the station.
    if comms_source:isFriendly(comms_target) then
        oMsg = _("station-comms", "Good day, officer.\nIf you need supplies, please dock with us first.")
    else
        oMsg = _("station-comms", "Greetings.\nIf you want to do business, please dock with us first.")
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. _("station-comms", "\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you.")
	end
	setCommsMessage(oMsg)
	if diagnostic_tud then
		testUpgradeDowngrade()
	end
	oMsg = nil
 	addCommsReply(_("station-comms", "I need information"), function()
		setCommsMessage(_("station-comms", "What kind of information do you need?"))
		addCommsReply(_("orders-comms", "What are my current orders?"), function()
			setOptionalOrders()
			setSecondaryOrders()
			primary_orders = _("orders-comms","Survive.")
			if getScenarioTime() > 600 then
				primary_orders = _("orders-comms","Survive. Contact the CUF")
			end
			ordMsg = primary_orders .. "\n" .. secondary_orders .. optional_orders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format(_("orders-comms", "\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			if getScenarioTime() > 1200 then
				addCommsReply(_("orders-comms","Is there any more we can do?"),moreOrders)
			end
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(_("station-comms","Station services (ordnance restock, repair, upgrade)"),function()
			setCommsMessage(_("station-comms","We offer a variety of services when you dock with us."))
			addCommsReply(_("ammo-comms", "What ordnance do you have available for restock?"), function()
				local missileTypeAvailableCount = 0
				local ordnanceListMsg = ""
				if comms_target.comms_data.weapon_available.Nuke then
					missileTypeAvailableCount = missileTypeAvailableCount + 1
					ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   Nuke")
				end
				if comms_target.comms_data.weapon_available.EMP then
					missileTypeAvailableCount = missileTypeAvailableCount + 1
					ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   EMP")
				end
				if comms_target.comms_data.weapon_available.Homing then
					missileTypeAvailableCount = missileTypeAvailableCount + 1
					ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   Homing")
				end
				if comms_target.comms_data.weapon_available.Mine then
					missileTypeAvailableCount = missileTypeAvailableCount + 1
					ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   Mine")
				end
				if comms_target.comms_data.weapon_available.HVLI then
					missileTypeAvailableCount = missileTypeAvailableCount + 1
					ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   HVLI")
				end
				if missileTypeAvailableCount == 0 then
					ordnanceListMsg = _("ammo-comms", "We have no ordnance available for restock")
				elseif missileTypeAvailableCount == 1 then
					ordnanceListMsg = string.format(_("ammo-comms", "We have the following type of ordnance available for restock:%s"),ordnanceListMsg)
				else
					ordnanceListMsg = string.format(_("ammo-comms", "We have the following types of ordnance available for restock:%s"),ordnanceListMsg)
				end
				setCommsMessage(ordnanceListMsg)
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("dockingServicesStatus-comms", "Docking services status"), function()
				setCommsMessage(_("dockingServicesStatus-comms","Which docking service category do you want a status for?\n    Primary services:\n        Charge battery, repair hull, replenish probes\n    Secondary systems repair:\n        Scanners, hacking, probe launch, combat maneuver, self destruct\n    Upgrade ship systems:\n        Beam, missile, shield, hull, impulse, ftl, sensors"))
				addCommsReply(_("dockingServicesStatus-comms","Primary services"),function()
					local service_status = string.format(_("dockingServicesStatus-comms", "Station %s primary docking services status:"),comms_target:getCallSign())
					if comms_target:getRestocksScanProbes() then
						service_status = string.format(_("dockingServicesStatus-comms", "%s\nReplenish scan probes."),service_status)
					else
						if comms_target.probe_fail_reason == nil then
							local reason_list = {
								_("dockingServicesStatus-comms", "Cannot replenish scan probes due to fabrication unit failure."),
								_("dockingServicesStatus-comms", "Parts shortage prevents scan probe replenishment."),
								_("dockingServicesStatus-comms", "Station management has curtailed scan probe replenishment for cost cutting reasons."),
							}
							comms_target.probe_fail_reason = reason_list[math.random(1,#reason_list)]
						end
						service_status = string.format("%s\n%s",service_status,comms_target.probe_fail_reason)
					end
					if comms_target:getRepairDocked() then
						service_status = string.format(_("dockingServicesStatus-comms", "%s\nShip hull repair."),service_status)
					else
						if comms_target.repair_fail_reason == nil then
							reason_list = {
								_("dockingServicesStatus-comms", "We're out of the necessary materials and supplies for hull repair."),
								_("dockingServicesStatus-comms", "Hull repair automation unavailable whie it is undergoing maintenance."),
								_("dockingServicesStatus-comms", "All hull repair technicians quarantined to quarters due to illness."),
							}
							comms_target.repair_fail_reason = reason_list[math.random(1,#reason_list)]
						end
						service_status = string.format("%s\n%s",service_status,comms_target.repair_fail_reason)
					end
					if comms_target:getSharesEnergyWithDocked() then
						service_status = string.format(_("dockingServicesStatus-comms", "%s\nRecharge ship energy stores."),service_status)
					else
						if comms_target.energy_fail_reason == nil then
							reason_list = {
								_("dockingServicesStatus-comms", "A recent reactor failure has put us on auxiliary power, so we cannot recharge ships."),
								_("dockingServicesStatus-comms", "A damaged power coupling makes it too dangerous to recharge ships."),
								_("dockingServicesStatus-comms", "An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now."),
							}
							comms_target.energy_fail_reason = reason_list[math.random(1,#reason_list)]
						end
						service_status = string.format("%s\n%s",service_status,comms_target.energy_fail_reason)
					end
					setCommsMessage(service_status)
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("dockingServicesStatus-comms","Secondary systems repair"),function()
					local service_status = string.format(_("dockingServicesStatus-comms", "Station %s docking repair services status:"),comms_target:getCallSign())
					if comms_target.comms_data.jump_overcharge then
						service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay overcharge jump drive"),service_status)
					end
					if comms_target.comms_data.probe_launch_repair then
						service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair probe launch system"),service_status)
					end
					if comms_target.comms_data.hack_repair then
						service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair hacking system"),service_status)
					end
					if comms_target.comms_data.scan_repair then
						service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair scanners"),service_status)
					end
					if comms_target.comms_data.combat_maneuver_repair then
						service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair combat maneuver"),service_status)
					end
					if comms_target.comms_data.self_destruct_repair then
						service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair self destruct system"),service_status)
					end
					setCommsMessage(service_status)
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("dockingServicesStatus-comms","Upgrade ship systems"),function()
					local service_status = string.format(_("dockingServicesStatus-comms", "Station %s docking upgrade services:"),comms_target:getCallSign())
					if comms_target.comms_data.upgrade_path ~= nil then
						local p_ship_type = comms_source:getTypeName()
						if comms_target.comms_data.upgrade_path[p_ship_type] ~= nil then
							local upgrade_count = 0
							local out = _(_("dockingServicesStatus-comms","We can provide the following upgrades:\n    system: description (reputation cost)"))
							for u_type, u_blob in pairs(comms_target.comms_data.upgrade_path[p_ship_type]) do
								local p_upgrade_level = comms_source.upgrade_path[u_type]
								if u_blob > p_upgrade_level then
									upgrade_count = upgrade_count + 1
									out = string.format("%s\n        %s: %s (%s)",out,u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc,math.ceil(base_upgrade_cost+((p_upgrade_level+1)*upgrade_price)))
								end
							end
							if upgrade_count > 0 then
								setCommsMessage(out)
							else
								setCommsMessage(_("dockingServicesStatus-comms","No more ship upgrades available for your ship"))
							end
						else
							setCommsMessage(_("dockingServicesStatus-comms","No ship upgrades available for your ship"))
						end
					else
						setCommsMessage(_("dockingServicesStatus-comms","No ship upgrades available"))
					end
					addCommsReply("Explain ship upgrade categories",explainShipUpgrades)
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
		end)
		addCommsReply(string.format(_("station-comms","Goods information at %s or near %s"),comms_target:getCallSign(),comms_target:getCallSign()),function()
			setCommsMessage(_("station-comms","Always good to get some goods"))
			local goodsAvailable = false
			if comms_target.comms_data.goods ~= nil then
				for good, goodData in pairs(comms_target.comms_data.goods) do
					if goodData["quantity"] > 0 then
						goodsAvailable = true
					end
				end
			end
			if goodsAvailable then
				addCommsReply(_("trade-comms", "What goods do you have available for sale or trade?"), function()
					local goodsAvailableMsg = string.format(_("trade-comms", "Station %s:\nGoods or components available: quantity, cost in reputation"),comms_target:getCallSign())
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
		end)
		local has_gossip = random(1,100) < (100 - (30 * (difficulty - .5)))
		if (comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "") or
			(comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "") or
			(comms_source:isFriendly(comms_target) and comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" and has_gossip) then
			addCommsReply(_("stationGeneralInfo-comms","Tell me more about your station"), function()
				setCommsMessage(_("stationGeneralInfo-comms","What would you like to know?"))
				if comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "" then
					addCommsReply(_("stationGeneralInfo-comms","General information"), function()
						setCommsMessage(comms_target.comms_data.general)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "" then
					addCommsReply(_("stationGeneralInfo-comms","Station history"), function()
						setCommsMessage(comms_target.comms_data.history)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if comms_source:isFriendly(comms_target) then
					if comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" then
						if has_gossip then
							addCommsReply(_("stationGeneralInfo-comms","Gossip"), function()
								setCommsMessage(comms_target.comms_data.gossip)
								addCommsReply(_("Back"), commsStation)
							end)
						end
					end
				end
			end)	--end station info comms reply branch
		end	--end public relations if branch
		addCommsReply(_("situationReport-comms","Report status"), function()
			msg = _("situationReport-comms","Hull: ") .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
			local shields = comms_target:getShieldCount()
			if shields == 1 then
				msg = msg .. _("situationReport-comms","Shield: ") .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			else
				for n=0,shields-1 do
					msg = msg .. _("situationReport-comms","Shield ") .. n .. ": " .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
				end
			end			
			setCommsMessage(msg);
			addCommsReply(_("Back"), commsStation)
		end)
	end)
	if isAllowedTo(comms_target.comms_data.services.supplydrop) then
        addCommsReply(string.format(_("stationAssist-comms", "Can you send a supply drop? (%d rep)"), getServiceCost("supplydrop")), function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms", "You need to set a waypoint before you can request backup."));
            else
                setCommsMessage(_("stationAssist-comms", "To which waypoint should we deliver your supplies?"));
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
						if comms_source:takeReputationPoints(getServiceCost("supplydrop")) then
							local position_x, position_y = comms_target:getPosition()
							local target_x, target_y = comms_source:getWaypoint(n)
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
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms", "You need to set a waypoint before you can request reinforcements."));
            else
                setCommsMessage(_("stationAssist-comms", "To which waypoint should we dispatch the reinforcements?"));
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
						if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
							ship = CpuShip():setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setCallSign(generateCallSign(nil,comms_target:getFaction())):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
							ship:setFactionId(comms_target:getFactionId())
							ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(friendlyVesselDestroyed)
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
    if isAllowedTo(comms_target.comms_data.services.servicejonque) then
    	addCommsReply(_("stationAssist-comms","Please send a service jonque for repairs"), function()
    		local out = string.format(_("stationAssist-comms","Would you like the service jonque to come to you directly or would you prefer to set up a rendezvous via a waypoint? Either way, you will need %.1f reputation."),getServiceCost("servicejonque"))
    		addCommsReply("Direct",function()
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
					setCommsMessage(string.format(_("stationAssist-comms","We have dispatched %s to come to you to help with repairs"),ship:getCallSign()))
    			else
					setCommsMessage(_("needRep-comms", "Not enough reputation!"));
    			end
    		end)
    		if comms_source:getWaypointCount() < 1 then
    			out = out .. _("stationAssist-comms","\n\nNote: if you want to use a waypoint, you will have to back out and set one and come back.")
    		else
    			for n=1,comms_source:getWaypointCount() do
    				addCommsReply(string.format(_("stationAssist-comms","Rendezvous at waypoint %i"),n),function()
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
    						setCommsMessage(string.format(_("stationAssist-comms","We have dispatched %s to rendezvous at waypoint %i"),ship:getCallSign(),n))
    					else
							setCommsMessage(_("needRep-comms", "Not enough reputation!"));
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
function handleDockedState()
	if spew_function_diagnostic then print("top of handle docked state") end
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
	setCommsMessage(oMsg)
	if diagnostic_tud then
		testUpgradeDowngrade()
	end
	addCommsReply(_("station-comms","Show mission activity at this station"),function()
		local presented_mission_button = false
		if commsTransportMission() then
			presented_mission_button = true
		end
		if commsCargoMission() then
			presented_mission_button = true
		end
		if commsRestorationMission() then
			presented_mission_button = true
		end
		if presented_mission_button then
			setCommsMessage(_("station-comms","Which mission activity are you interested in?"))
		else
			setCommsMessage(_("station-comms","No mission activity available here."))
		end
		addCommsReply(_("Back"), commsStation)
	end)
	commsOrdnanceUpgradesRepairs()
	commsInformationStation()
	commsResources()
	if spew_function_diagnostic then print("bottom of handle docked state") end
end
function commsTransportMission()
	if spew_function_diagnostic then print("top of comms transport mission") end
	local presented_mission_button = false
	local mission_character = nil
	local mission_type = nil
	if comms_source.transport_mission ~= nil then
		if comms_source.transport_mission.destination ~= nil and comms_source.transport_mission.destination:isValid() then
			if comms_source.transport_mission.destination == comms_target then
				presented_mission_button = true
				addCommsReply(string.format(_("station-comms","Deliver %s to %s"),comms_source.transport_mission.character.name,comms_target:getCallSign()),function()
					if not comms_source:isDocked(comms_target) then 
						setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
						return
					end
					setCommsMessage(string.format(_("station-comms","%s disembarks at %s and thanks you"),comms_source.transport_mission.character.name,comms_target:getCallSign()))
					comms_source:addReputationPoints(comms_source.transport_mission.reward)
					if comms_target.residents == nil then
						comms_target.residents = {}
					end
					table.insert(comms_target.residents,comms_source.transport_mission.character)
					comms_source.transport_mission = nil
					addCommsReply(_("Back"), commsStation)
				end)
			end
		else
			comms_source:addToShipLog(string.format(_("shipLog","%s disembarks at %s because %s has been destroyed. You receive %s reputation for your efforts"),comms_source.transport_mission.character.name,comms_target:getCallSign(),comms_source.transport_mission.destination_name,comms_source.transport_mission.reward/2),"Yellow")
			comms_source:addReputationPoints(comms_source.transport_mission.reward/2)
			if comms_target.residents == nil then
				comms_target.residents = {}
			end
			table.insert(comms_target.residents,comms_source.transport_mission.character)
			comms_source.transport_mission = nil
		end
	else
		if comms_target.transport_mission == nil then
			mission_character = tableRemoveRandom(characters)
			local mission_target = nil
			if mission_character ~= nil then
				mission_type = random(1,100)
				local destination_pool = {}
				if mission_type < 20 then
					for _, station in ipairs(station_list) do
						if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) and not comms_source:isFriendly(station) then
							table.insert(destination_pool,station)
						end
					end
					mission_target = tableRemoveRandom(destination_pool)
					if mission_target ~= nil then
						comms_target.transport_mission = {
							["destination"] = mission_target,
							["destination_name"] = mission_target:getCallSign(),
							["reward"] = 40 + math.floor((distance(comms_source,mission_target) / mileage_compensation)),
							["character"] = mission_character,
						}
					else
						for _, station in ipairs(station_list) do
							if station ~= nil and station:isValid() and station ~= comms_target and comms_source:isFriendly(station) then
								table.insert(destination_pool,station)
							end
						end
						mission_target = tableRemoveRandom(destination_pool)
						if mission_target ~= nil then
							comms_target.transport_mission = {
								["destination"] = mission_target,
								["destination_name"] = mission_target:getCallSign(),
								["reward"] = 30 + math.floor((distance(comms_source,mission_target) / mileage_compensation)),
								["character"] = mission_character,
							}
						else
							for _, station in ipairs(inner_circle) do
								if station ~= nil and station:isValid() and station ~= comms_target then
									table.insert(destination_pool,station)
								end
							end
							mission_target = tableRemoveRandom(destination_pool)
							if mission_target ~= nil then
								comms_target.transport_mission = {
									["destination"] = mission_target,
									["destination_name"] = mission_target:getCallSign(),
									["reward"] = 20 + math.floor((distance(comms_source,mission_target) / mileage_compensation)),
									["character"] = mission_character,
								}
							end
						end
					end
				elseif mission_type < 50 then
					for _, station in ipairs(station_list) do
						if station ~= nil and station:isValid() and station ~= comms_target and comms_source:isFriendly(station) then
							table.insert(destination_pool,station)
						end
					end
					mission_target = tableRemoveRandom(destination_pool)
					if mission_target ~= nil then
						comms_target.transport_mission = {
							["destination"] = mission_target,
							["destination_name"] = mission_target:getCallSign(),
							["reward"] = 30 + math.floor((distance(comms_source,mission_target) / mileage_compensation)),
							["character"] = mission_character,
						}
					else
						for _, station in ipairs(inner_circle) do
							if station ~= nil and station:isValid() and station ~= comms_target then
								table.insert(destination_pool,station)
							end
						end
						mission_target = tableRemoveRandom(destination_pool)
						if mission_target ~= nil then
							comms_target.transport_mission = {
								["destination"] = mission_target,
								["destination_name"] = mission_target:getCallSign(),
								["reward"] = 20 + math.floor((distance(comms_source,mission_target) / mileage_compensation)),
								["character"] = mission_character,
							}
						else
							for _, station in ipairs(station_list) do
								if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) and not comms_source:isFriendly(station) then
									table.insert(destination_pool,station)
								end
							end
							mission_target = tableRemoveRandom(destination_pool)
							if mission_target ~= nil then
								comms_target.transport_mission = {
									["destination"] = mission_target,
									["destination_name"] = mission_target:getCallSign(),
									["reward"] = 40 + math.floor((distance(comms_source,mission_target) / mileage_compensation)),
									["character"] = mission_character,
								}
							end
						end
					end
				else
					for _, station in ipairs(inner_circle) do
						if station ~= nil and station:isValid() and station ~= comms_target then
							table.insert(destination_pool,station)
						end
					end
					mission_target = tableRemoveRandom(destination_pool)
					if mission_target ~= nil then
						comms_target.transport_mission = {
							["destination"] = mission_target,
							["destination_name"] = mission_target:getCallSign(),
							["reward"] = 20 + math.floor((distance(comms_source,mission_target) / mileage_compensation)),
							["character"] = mission_character,
						}
					else
						for _, station in ipairs(station_list) do
							if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) then
								table.insert(destination_pool,station)
							end
						end
						mission_target = tableRemoveRandom(destination_pool)
						if mission_target ~= nil then
							local reward = 40 + math.floor((distance(comms_source,mission_target) / mileage_compensation))
							if mission_target:isFriendly(comms_source) then
								reward = 30 + math.floor((distance(comms_source,mission_target) / mileage_compensation))
							end
							comms_target.transport_mission = {
								["destination"] = mission_target,
								["destination_name"] = mission_target:getCallSign(),
								["reward"] = reward,
								["character"] = mission_character,
							}
						end
					end
				end
			end
		else
			if not comms_target.transport_mission.destination:isValid() then
				if comms_target.residents == nil then
					comms_target.residents = {}
				end
				table.insert(comms_target.residents,comms_target.transport_mission.character)
				comms_target.transport_mission = nil
			end
		end
		if comms_target.transport_mission ~= nil then
			presented_mission_button = true
			addCommsReply(_("station-comms","Transport Passenger"),function()
				local out = string.format(_("station-comms","%s wishes to be transported to %s station %s in sector %s."),comms_target.transport_mission.character.name,comms_target.transport_mission.destination:getFaction(),comms_target.transport_mission.destination_name,comms_target.transport_mission.destination:getSectorName())
				out = string.format(_("station-comms","%s Transporting %s would increase your reputation by %s."),out,comms_target.transport_mission.character.object_pronoun,comms_target.transport_mission.reward)
				setCommsMessage(out)
				addCommsReply(string.format(_("station-comms","Agree to transport %s to %s station %s"),comms_target.transport_mission.character.name,comms_target.transport_mission.destination:getFaction(),comms_target.transport_mission.destination_name),function()
					if not comms_source:isDocked(comms_target) then 
						setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
						return
					end
					comms_source.transport_mission = comms_target.transport_mission
					comms_target.transport_mission = nil
					setCommsMessage(string.format(_("station-comms","You direct %s to guest quarters and say, 'Welcome aboard the %s'"),comms_source.transport_mission.character.name,comms_source:getCallSign()))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("station-comms","Decline transportation request"),function()
					if random(1,5) <= 1 then
						setCommsMessage(string.format(_("station-comms","You tell %s that you cannot take on any transportation missions at this time. The offer disappears from the message board."),comms_target.transport_mission.character.name))
						comms_target.transport_mission = nil
					else
						setCommsMessage(string.format(_("station-comms","You tell %s that you cannot take on any transportation missions at this time."),comms_target.transport_mission.character.name))
					end
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
	if spew_function_diagnostic then print("bottom (ish) of comms transport mission") end
	return presented_mission_button
end
function commsCargoMission()
	if spew_function_diagnostic then print("top of comms cargo mission") end
	local presented_mission_button = false
	local mission_character = nil
	if comms_source.cargo_mission ~= nil then
		if comms_source.cargo_mission.loaded then
			if comms_source.cargo_mission.destination ~= nil and comms_source.cargo_mission.destination:isValid() then
				if comms_source.cargo_mission.destination == comms_target then
					addCommsReply(string.format(_("station-comms","Deliver cargo to %s on %s"),comms_source.cargo_mission.character.name,comms_target:getCallSign()),function()
						string.format("")
						presented_mission_button = true
						if not comms_source:isDocked(comms_target) then 
							setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
							return
						end
						setCommsMessage(string.format(_("station-comms","%s thanks you for retrieving the cargo"),comms_source.cargo_mission.character.name))
						comms_source:addReputationPoints(comms_source.cargo_mission.reward)
						comms_source.cargo_mission = nil
						addCommsReply(_("Back"), commsStation)
					end)
				end
			else
				comms_source:addToShipLog(string.format(_("shipLog","Automated systems on %s have informed you of the destruction of station %s. Your mission to deliver cargo for %s to %s is no longer valid. You unloaded the cargo and requested the station authorities handle it for the family of %s. You received %s reputation for your efforts. The mission has been removed from your mission log."),comms_target:getCallSign(),comms_source.cargo_mission.destination_name,comms_source.cargo_mission.character.name,comms_source.cargo_mission.destination_name,comms_source.cargo_mission.character.name,comms_source.cargo_mission.reward/2),"Yellow")
				comms_source:addReputationPoints(math.floor(comms_source.cargo_mission.reward/2))
				comms_source.cargo_mission = nil
			end
		else
			if comms_source.cargo_mission.origin ~= nil and comms_source.cargo_mission.origin:isValid() then
				if comms_source.cargo_mission.origin == comms_target then
					presented_mission_button = true
					addCommsReply(string.format(_("station-comms","Pick up cargo for %s"),comms_source.cargo_mission.character.name),function()
						if not comms_source:isDocked(comms_target) then 
							setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
							return
						end
						setCommsMessage(string.format(_("station-comms","The cargo for %s has been loaded on %s"),comms_source.cargo_mission.character.name,comms_source:getCallSign()))
						comms_source.cargo_mission.loaded = true
						addCommsReply(_("Back"), commsStation)
					end)
				end
			else
				comms_source:addToShipLog(string.format(_("shipLog","Automated systems on %s have informed you of the destruction of station %s. Your mission to retrieve cargo for %s from %s is no longer valid and has been removed from your mission log."),comms_target:getCallSign(),comms_source.cargo_mission.origin_name,comms_source.cargo_mission.character.name,comms_source.cargo_mission.origin_name),"Yellow")
				if comms_source.cargo_mission.destination:isValid() then
					table.insert(comms_source.cargo_mission.destination.residents,comms_source.cargo_mission.character)
				end
				comms_source.cargo_mission = nil
			end
		end
	else
		if comms_target.cargo_mission == nil then
			if comms_target.residents ~= nil then
				mission_character = tableRemoveRandom(comms_target.residents)
				local mission_origin = nil
				if mission_character ~= nil then
					mission_type = random(1,100)
					local origin_pool = {}
					if mission_type < 20 then
						for _, station in ipairs(station_list) do
							if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) and not comms_source:isFriendly(station) then
								table.insert(origin_pool,station)
							end
						end
						mission_origin = tableRemoveRandom(origin_pool)
						if mission_origin ~= nil then
							comms_target.cargo_mission = {
								["origin"] = mission_origin,
								["origin_name"] = mission_origin:getCallSign(),
								["destination"] = comms_target,
								["destination_name"] = comms_target:getCallSign(),
								["reward"] = 50 + math.floor((distance(comms_source,mission_origin) / mileage_compensation)),
								["character"] = mission_character,
							}
						else
							for _, station in ipairs(station_list) do
								if station ~= nil and station:isValid() and station ~= comms_target and comms_source:isFriendly(station) then
									table.insert(origin_pool,station)
								end
							end
							mission_origin = tableRemoveRandom(origin_pool)
							if mission_origin ~= nil then
								comms_target.cargo_mission = {
									["origin"] = mission_origin,
									["origin_name"] = mission_origin:getCallSign(),
									["destination"] = comms_target,
									["destination_name"] = comms_target:getCallSign(),
									["reward"] = 40 + math.floor((distance(comms_source,mission_origin) / mileage_compensation)),
									["character"] = mission_character,
								}
							else
								for _, station in ipairs(inner_circle) do
									if station ~= nil and station:isValid() and station ~= comms_target then
										table.insert(origin_pool,station)
									end
								end
								mission_origin = tableRemoveRandom(origin_pool)
								if mission_origin ~= nil then
									comms_target.cargo_mission = {
										["origin"] = mission_origin,
										["origin_name"] = mission_origin:getCallSign(),
										["destination"] = comms_target,
										["destination_name"] = comms_target:getCallSign(),
										["reward"] = 30 + math.floor((distance(comms_source,mission_origin) / mileage_compensation)),
										["character"] = mission_character,
									}
								end
							end
						end
					elseif mission_type < 50 then
						for _, station in ipairs(station_list) do
							if station ~= nil and station:isValid() and station ~= comms_target and comms_source:isFriendly(station) then
								table.insert(origin_pool,station)
							end
						end
						mission_origin = tableRemoveRandom(origin_pool)
						if mission_origin ~= nil then
							comms_target.cargo_mission = {
								["origin"] = mission_origin,
								["origin_name"] = mission_origin:getCallSign(),
								["destination"] = comms_target,
								["destination_name"] = comms_target:getCallSign(),
								["reward"] = 40 + math.floor((distance(comms_source,mission_origin) / mileage_compensation)),
								["character"] = mission_character,
							}
						else
							for _, station in ipairs(inner_circle) do
								if station ~= nil and station:isValid() and station ~= comms_target then
									table.insert(origin_pool,station)
								end
							end
							mission_origin = tableRemoveRandom(origin_pool)
							if mission_origin ~= nil then
								comms_target.cargo_mission = {
									["origin"] = mission_origin,
									["origin_name"] = mission_origin:getCallSign(),
									["destination"] = comms_target,
									["destination_name"] = comms_target:getCallSign(),
									["reward"] = 30 + math.floor((distance(comms_source,mission_origin) / mileage_compensation)),
									["character"] = mission_character,
								}
							else
								for _, station in ipairs(station_list) do
									if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) and not comms_source:isFriendly(station) then
										table.insert(origin_pool,station)
									end
								end
								mission_origin = tableRemoveRandom(origin_pool)
								if mission_origin ~= nil then
									comms_target.cargo_mission = {
										["origin"] = mission_origin,
										["origin_name"] = mission_origin:getCallSign(),
										["destination"] = comms_target,
										["destination_name"] = comms_target:getCallSign(),
										["reward"] = 50 + math.floor((distance(comms_source,mission_origin) / mileage_compensation)),
										["character"] = mission_character,
									}
								end
							end
						end
					else
						for _, station in ipairs(inner_circle) do
							if station ~= nil and station:isValid() and station ~= comms_target then
								table.insert(origin_pool,station)
							end
						end
						mission_origin = tableRemoveRandom(origin_pool)
						if mission_origin ~= nil then
							comms_target.cargo_mission = {
								["origin"] = mission_origin,
								["origin_name"] = mission_origin:getCallSign(),
								["destination"] = comms_target,
								["destination_name"] = comms_target:getCallSign(),
								["reward"] = 30 + math.floor((distance(comms_source,mission_origin) / mileage_compensation)),
								["character"] = mission_character,
							}
						else
							for _, station in ipairs(station_list) do
								if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) then
									table.insert(origin_pool,station)
								end
							end
							mission_origin = tableRemoveRandom(origin_pool)
							if mission_origin ~= nil then
								local reward = 50 + math.floor((distance(comms_source,mission_origin) / mileage_compensation))
								if mission_origin:isFriendly(comms_source) then
									reward = 40 + math.floor((distance(comms_source,mission_origin) / mileage_compensation))
								end
								comms_target.cargo_mission = {
									["origin"] = mission_origin,
									["origin_name"] = mission_origin:getCallSign(),
									["destination"] = comms_target,
									["destination_name"] = comms_target:getCallSign(),
									["reward"] = reward,
									["character"] = mission_character,
								}
							end
						end
					end
				end
			end
		else
			if not comms_target.cargo_mission.origin:isValid() then
				table.insert(comms_target.residents,comms_target.cargo_mission.character)
				comms_target.cargo_mission = nil
			end
		end
		if comms_target.cargo_mission ~= nil then
			presented_mission_button = true
			addCommsReply(_("station-comms","Retrieve Cargo"),function()
				local out = string.format(_("station-comms","%s wishes you to pick up cargo from %s station %s in sector %s and deliver it here."),comms_target.cargo_mission.character.name,comms_target.cargo_mission.origin:getFaction(),comms_target.cargo_mission.origin_name,comms_target.cargo_mission.origin:getSectorName())
				out = string.format(_("station-comms","%s Retrieving and delivering this cargo for %s would increase your reputation by %s."),out,comms_target.cargo_mission.character.name,comms_target.cargo_mission.reward)
				setCommsMessage(out)
				addCommsReply(string.format(_("station-comms","Agree to retrieve cargo for %s"),comms_target.cargo_mission.character.name),function()
					if not comms_source:isDocked(comms_target) then 
						setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
						return
					end
					comms_source.cargo_mission = comms_target.cargo_mission
					comms_source.cargo_mission.loaded = false
					comms_target.cargo_mission = nil
					setCommsMessage(string.format(_("station-comms","%s thanks you and contacts station %s to let them know that %s will be picking up the cargo."),comms_source.cargo_mission.character.name,comms_source.cargo_mission.origin_name,comms_source:getCallSign()))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("station-comms","Decline cargo retrieval request"),function()
					if random(1,5) <= 1 then
						setCommsMessage(string.format(_("station-comms","You tell %s that you cannot take on any cargo retrieval missions at this time. The offer disappears from the message board."),comms_target.cargo_mission.character.name))
						comms_target.cargo_mission = nil
					else
						setCommsMessage(string.format(_("station-comms","You tell %s that you cannot take on any transportation missions at this time."),comms_target.transport_mission.character.name))
					end
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
	if spew_function_diagnostic then print("bottom (ish) of comms cargo mission") end
	return presented_mission_button
end
function commsRestorationMission()
	if spew_function_diagnostic then print("top of comms restoration mission") end
	local presented_mission_button = false
	if comms_source.restoration_mission ~= nil then
		if comms_source.restoration_mission.achievement then
			if comms_source.restoration_mission.destination ~= nil and comms_source.restoration_mission.destination:isValid() then
				if comms_source.restoration_mission.destination == comms_target then
					presented_mission_button = true
					addCommsReply(comms_source.restoration_mission.completion_prompt,function()
						if not comms_source:isDocked(comms_target) then 
							setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
							return
						end
						setCommsMessage(comms_source.restoration_mission.thanks_message)
						comms_source:addReputationPoints(comms_source.restoration_mission.reward)
						if comms_source.restoration_mission.reward_type == "energy" then
							if comms_source.instant_energy == nil then
								comms_source.instant_energy = {}
							end
							table.insert(comms_source.instant_energy,comms_target)
							comms_target:setSharesEnergyWithDocked(true)
						end
						if comms_source.restoration_mission.reward_type == "hull" then
							if comms_source.instant_hull == nil then
								comms_source.instant_hull = {}
							end
							table.insert(comms_source.instant_hull,comms_target)
							comms_target:setRepairDocked(true)
						end
						if comms_source.restoration_mission.reward_type == "restock_probes" then
							if comms_source.instant_probes == nil then
								comms_source.instant_probes = {}
							end
							table.insert(comms_source.instant_probes,comms_target)
							comms_target:setRestocksScanProbes(true)
						end
						if comms_source.restoration_mission.reward_type == "homing" then
							if comms_source.homing_discount == nil then
								comms_source.homing_discount = {}
							end
							table.insert(comms_source.homing_discount,comms_target)
							comms_target.comms_data.weapon_available.Homing = true
							comms_target.comms_data.max_weapon_refill_amount.neutral = 1
						end
						if comms_source.restoration_mission.reward_type == "nuke" then
							if comms_source.nuke_discount == nil then
								comms_source.nuke_discount = {}
							end
							table.insert(comms_source.nuke_discount,comms_target)
							comms_target.comms_data.weapon_available.Nuke = true
							comms_target.comms_data.weapons["Nuke"] = "neutral"
							comms_target.comms_data.max_weapon_refill_amount.neutral = 1
						end
						if comms_source.restoration_mission.reward_type == "emp" then
							if comms_source.emp_discount == nil then
								comms_source.emp_discount = {}
							end
							table.insert(comms_source.emp_discount,comms_target)
							comms_target.comms_data.weapon_available.EMP = true
							comms_target.comms_data.weapons["EMP"] = "neutral"
							comms_target.comms_data.max_weapon_refill_amount.neutral = 1
						end
						if comms_source.restoration_mission.reward_type == "mine" then
							if comms_source.mine_discount == nil then
								comms_source.mine_discount = {}
							end
							table.insert(comms_source.mine_discount,comms_target)
							comms_target.comms_data.weapon_available.Mine = true
							comms_target.comms_data.weapons["Mine"] = "neutral"
							comms_target.comms_data.max_weapon_refill_amount.neutral = 1
						end
						if comms_source.restoration_mission.reward_type == "hvli" then
							if comms_source.hvli_discount == nil then
								comms_source.hvli_discount = {}
							end
							table.insert(comms_source.hvli_discount,comms_target)
							comms_target.comms_data.weapon_available.HVLI = true
							comms_target.comms_data.max_weapon_refill_amount.neutral = 1
						end
						comms_source.restoration_mission = nil
						addCommsReply(_("Back"), commsStation)
					end)
				end
			else
				comms_source:addToShipLog(comms_source.restoration_mission.destroyed_message,"Yellow")
				comms_source:addReputationPoints(math.floor(comms_source.restoration_mission.reward/2))
				comms_source.restoration_mission = nil
			end
		else
			if comms_source.restoration_mission.origin ~= nil and comms_source.restoration_mission.origin:isValid() then
				if comms_source.restoration_mission.origin == comms_target then
					presented_mission_button = true
					addCommsReply(comms_source.restoration_mission.halfway_prompt,function()
						if not comms_source:isDocked(comms_target) then 
							setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
							return
						end
						setCommsMessage(comms_source.restoration_mission.halfway_complete_message)
						comms_source.restoration_mission.achievement = true
						addCommsReply(_("Back"), commsStation)
					end)
				end
			else
				comms_source:addToShipLog(comms_source.restoration_mission.destroyed_message,"Yellow")
				comms_source.restoration_mission = nil
			end
		end
	else
		if comms_target.restoration_mission == nil then
			local restore_targets = {}
			if not comms_target:getSharesEnergyWithDocked() then
				table.insert(restore_targets,"energy")
			end
			if not comms_target:getRepairDocked() then
				table.insert(restore_targets,"hull")
			end
			if not comms_target:getRestocksScanProbes() then
				table.insert(restore_targets,"restock_probes")
			end
			if not comms_target.comms_data.weapon_available.Homing then
				table.insert(restore_targets,"homing")
			end
			if not comms_target.comms_data.weapon_available.Nuke then
				table.insert(restore_targets,"nuke")
			end
			if not comms_target.comms_data.weapon_available.EMP then
				table.insert(restore_targets,"emp")
			end
			if not comms_target.comms_data.weapon_available.Mine then
				table.insert(restore_targets,"mine")
			end
			if not comms_target.comms_data.weapon_available.HVLI then
				table.insert(restore_targets,"hvli")
			end
			local origin_pool = {}
			for _, station in ipairs(station_list) do
				if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) then
					table.insert(origin_pool,station)
				end
			end
			local mission_origin = tableRemoveRandom(origin_pool)
			if #restore_targets > 0 and mission_origin ~= nil then
				local restore_target = restore_targets[math.random(1,#restore_targets)]
				comms_target.restoration_mission = {}
				comms_target.restoration_mission.origin = mission_origin
				comms_target.restoration_mission.destination = comms_target
				comms_target.restoration_mission.reward = 15 + math.floor((distance(comms_source,mission_origin) / mileage_compensation))
				comms_target.restoration_mission.reward_type = restore_target
				if restore_target == "energy" then
					if comms_target.energy_fail_reason == nil then
						reason_list = {
							_("dockingServicesStatus-comms", "A recent reactor failure has put us on auxiliary power, so we cannot recharge ships."),
							_("dockingServicesStatus-comms", "A damaged power coupling makes it too dangerous to recharge ships."),
							_("dockingServicesStatus-comms", "An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now."),
						}
						comms_target.energy_fail_reason = reason_list[math.random(1,#reason_list)]
					end
					if comms_target.energy_fail_reason == _("dockingServicesStatus-comms", "A recent reactor failure has put us on auxiliary power, so we cannot recharge ships.") then
						comms_target.restoration_mission.initiation_prompt = _("station-comms","Repair reactor")
						comms_target.restoration_mission.explain_mission = string.format(_("station-comms","We are currently running on auxiliary power due to a recent reactor failure. This prevents us from recharging ships when they dock. However, station %s in sector %s has the necessary reactor repair parts. They've agreed to provide the parts to us, we just need someone to go pick them up. If you do this for us, we would reprogram our docking bay to instantly recharge your ship any time you docked with us.\n\nPicking up the reactor repair parts for %s would increase your reputation by %i."),mission_origin:getCallSign(),mission_origin:getSectorName(),comms_target:getCallSign(),comms_target.restoration_mission.reward)
						comms_target.restoration_mission.accept_prompt = _("station-comms","Agree to pick up reactor repair parts")
						comms_target.restoration_mission.reject_prompt = _("station-comms","Decline to retrieve reactor repair parts")
						comms_target.restoration_mission.halfway_prompt = _("station-comms","Load parts to repair reactor")
						comms_target.restoration_mission.halfway_complete_message = _("station-comms","Reactor repair parts loaded")
						comms_target.restoration_mission.destroyed_message = _("shipLog","Due to station destruction, your mission to repair the reactor cannot be completed")
						comms_target.restoration_mission.completion_prompt = _("station-comms","Provide parts to repair reactor")
						comms_target.restoration_mission.thanks_message = _("station-comms","Thanks for the parts. Our reactor has been repaired. Come back and recharge any time.")
						comms_target.restoration_mission.optional_orders_first_half = string.format(_("orders-comms","Pick up reactor parts from %s in %s"),mission_origin:getCallSign(),mission_origin:getSectorName())
						comms_target.restoration_mission.optional_orders_second_half = string.format(_("orders-comms","Deliver reactor parts to %s in %s"),comms_target:getCallSign(),comms_target:getSectorName())
					elseif comms_target.energy_fail_reason == _("dockingServicesStatus-comms", "A damaged power coupling makes it too dangerous to recharge ships.") then
						comms_target.restoration_mission.initiation_prompt = _("station-comms","Repair power coupling")
						comms_target.restoration_mission.explain_mission = string.format(_("station-comms","A damaged power coupling prevents us from recharging ships when they dock. Station %s in sector %s has the necessary power coupling repair parts. They've agreed to give us the parts, but we need someone to go get them. If you get the parts for us, we would reprogram our docking bay to instantly recharge your ship any time you docked with us.\n\nGetting the power coupling repair parts for %s would increase your reputation by %i."),mission_origin:getCallSign(),mission_origin:getSectorName(),comms_target:getCallSign(),comms_target.restoration_mission.reward)
						comms_target.restoration_mission.accept_prompt = _("station-comms","Agree to get power coupling repair parts")
						comms_target.restoration_mission.reject_prompt = _("station-comms","Decline to get power coupling repair parts")
						comms_target.restoration_mission.halfway_prompt = _("station-comms","Load parts to repair power coupling")
						comms_target.restoration_mission.halfway_complete_message = _("station-comms","Power coupling repair parts loaded")
						comms_target.restoration_mission.destroyed_message = _("shipLog","Due to station destruction, your mission to repair the power coupling cannot be completed")
						comms_target.restoration_mission.completion_prompt = _("station-comms","Provide parts to repair power coupling")
						comms_target.restoration_mission.thanks_message = _("station-comms","Thanks for the parts. Our power coupling has been repaired. Come back and recharge any time.")
						comms_target.restoration_mission.optional_orders_first_half = string.format(_("orders-comms","Get power coupling repair parts from %s in %s"),mission_origin:getCallSign(),mission_origin:getSectorName())
						comms_target.restoration_mission.optional_orders_second_half = string.format(_("orders-comms","Deliver power coupling repair parts to %s in %s"),comms_target:getCallSign(),comms_target:getSectorName())
					elseif comms_target.energy_fail_reason == _("dockingServicesStatus-comms", "An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now.") then
						comms_target.restoration_mission.initiation_prompt = _("station-comms","Replace solar panels")
						comms_target.restoration_mission.explain_mission = string.format(_("station-comms","Several solar panels hit by an asteroid currently keeps us from recharging ships when they dock. Station %s in sector %s has some replacement solar panels, but we need someone to transport them. If you transport the solar panels back to us, we would reprogram our docking bay to instantly recharge your ship any time you docked with us.\n\nTransporting the power coupling repair parts for %s would increase your reputation by %i."),mission_origin:getCallSign(),mission_origin:getSectorName(),comms_target:getCallSign(),comms_target.restoration_mission.reward)
						comms_target.restoration_mission.accept_prompt = _("station-comms","Agree to transport solar panels")
						comms_target.restoration_mission.reject_prompt = _("station-comms","Decline to transport solar panels")
						comms_target.restoration_mission.halfway_prompt = _("station-comms","Load replacement solar panels")
						comms_target.restoration_mission.halfway_complete_message = _("station-comms","Replacement solar panels loaded")
						comms_target.restoration_mission.destroyed_message = _("shipLog","Due to station destruction, your mission to replace the solar panels cannot be completed")
						comms_target.restoration_mission.completion_prompt = _("station-comms","Unload replacement solar panels")
						comms_target.restoration_mission.thanks_message = _("station-comms","Thanks for the replacement solar panels. We've installed them now, so we're able to recharge ships that dock. Come back and recharge any time.")
						comms_target.restoration_mission.optional_orders_first_half = string.format(_("orders-comms","Get solar panels from %s in %s"),mission_origin:getCallSign(),mission_origin:getSectorName())
						comms_target.restoration_mission.optional_orders_second_half = string.format(_("orders-comms","Deliver solar panels to %s in %s"),comms_target:getCallSign(),comms_target:getSectorName())
					end
				end
				if restore_target == "hull" then
					if comms_target.repair_fail_reason == nil then
						reason_list = {
							_("dockingServicesStatus-comms", "We're out of the necessary materials and supplies for hull repair."),
							_("dockingServicesStatus-comms", "Hull repair automation unavailable while it is undergoing maintenance."),
							_("dockingServicesStatus-comms", "All hull repair technicians quarantined to quarters due to illness."),
						}
						comms_target.repair_fail_reason = reason_list[math.random(1,#reason_list)]
					end
					if comms_target.repair_fail_reason == _("dockingServicesStatus-comms", "We're out of the necessary materials and supplies for hull repair.") then
						comms_target.restoration_mission.initiation_prompt = _("station-comms","Resupply hull repair facility")
						comms_target.restoration_mission.explain_mission = string.format(_("station-comms","We currently don't have materials and supplies to conduct hull repair on ships that dock. However, station %s in sector %s has the necessary materials and supplies. They've agreed to provide them to us, we just need someone to go pick them up. If you do this for us, we would reprogram our docking bay to instantly fix your ship's hull any time you docked with us.\n\nPicking up the materials and supplies for %s would increase your reputation by %i."),mission_origin:getCallSign(),mission_origin:getSectorName(),comms_target:getCallSign(),comms_target.restoration_mission.reward)
						comms_target.restoration_mission.accept_prompt = _("station-comms","Agree to pick up materials and supplies")
						comms_target.restoration_mission.reject_prompt = _("station-comms","Decline to retrieve materials and supplies")
						comms_target.restoration_mission.halfway_prompt = _("station-comms","Load materials and supplies for hull repair facility")
						comms_target.restoration_mission.halfway_complete_message = _("station-comms","Materials and supplies loaded")
						comms_target.restoration_mission.destroyed_message = _("shipLog","Due to station destruction, your mission to provide materials and supplies for the hull repair facility cannot be completed")
						comms_target.restoration_mission.completion_prompt = _("station-comms","Unload materials and supplies for hull repair facility")
						comms_target.restoration_mission.thanks_message = _("station-comms","Thanks for the materials and supplies. Our hull repair facility is back in business. Come back and get your hull repaired any time.")
						comms_target.restoration_mission.optional_orders_first_half = string.format(_("orders-comms","Pick up hull repair facility materials and supplies from %s in %s"),mission_origin:getCallSign(),mission_origin:getSectorName())
						comms_target.restoration_mission.optional_orders_second_half = string.format(_("orders-comms","Deliver hull repair facility materials and supplies to %s in %s"),comms_target:getCallSign(),comms_target:getSectorName())
					elseif comms_target.repair_fail_reason == _("dockingServicesStatus-comms", "Hull repair automation unavailable while it is undergoing maintenance.") then
						comms_target.restoration_mission.initiation_prompt = _("station-comms","Maintain hull repair facility")
						comms_target.restoration_mission.explain_mission = string.format(_("station-comms","Our hull repair facility is stuck in a maintenance cycle. We can't get certification until we have the latest software updates along with some exotic trace materials. Station %s in sector %s has the maintenance cycle bundle. They've agreed to give it to us, but we need someone to get it. If you do this for us, we would reprogram our docking bay to instantly fix your ship's hull any time you docked with us.\n\nGetting the maintenance cycle bundle for %s would increase your reputation by %i."),mission_origin:getCallSign(),mission_origin:getSectorName(),comms_target:getCallSign(),comms_target.restoration_mission.reward)
						comms_target.restoration_mission.accept_prompt = _("station-comms","Agree to get maintenance bundle")
						comms_target.restoration_mission.reject_prompt = _("station-comms","Decline to get maintenance bundle")
						comms_target.restoration_mission.halfway_prompt = _("station-comms","Load maintenance bundle for hull repair facility")
						comms_target.restoration_mission.halfway_complete_message = _("station-comms","Maintenance bundle loaded")
						comms_target.restoration_mission.destroyed_message = _("shipLog","Due to station destruction, your mission to provide a maintenance bundle for the hull repair facility cannot be completed")
						comms_target.restoration_mission.completion_prompt = _("station-comms","Unload maintenance bundle for hull repair facility")
						comms_target.restoration_mission.thanks_message = _("station-comms","Thanks for the maintenance bundle. We have completed the maintenance cycle on our hull repair facility. Come back and get your hull repaired any time.")
						comms_target.restoration_mission.optional_orders_first_half = string.format(_("orders-comms","Get hull repair facility maintenance bundle from %s in %s"),mission_origin:getCallSign(),mission_origin:getSectorName())
						comms_target.restoration_mission.optional_orders_second_half = string.format(_("orders-comms","Deliver hull repair facility maintenance bundle to %s in %s"),comms_target:getCallSign(),comms_target:getSectorName())
					elseif comms_target.repair_fail_reason == _("dockingServicesStatus-comms", "All hull repair technicians quarantined to quarters due to illness.") then
						comms_target.restoration_mission.initiation_prompt = _("station-comms","Help quarantined hull repair facility technicians")
						comms_target.restoration_mission.explain_mission = string.format(_("station-comms","Our hull repair facility technicians are quarantined. Our medical bay is out of the medicine to make them better. Station %s in sector %s has the medical supplies. We need you to transport those medical supplies. If you do this for us, we would reprogram our docking bay to instantly fix your ship's hull any time you docked with us.\n\nTransporting the medical supplies for %s would increase your reputation by %i."),mission_origin:getCallSign(),mission_origin:getSectorName(),comms_target:getCallSign(),comms_target.restoration_mission.reward)
						comms_target.restoration_mission.accept_prompt = _("station-comms","Agree to transport medical supplies")
						comms_target.restoration_mission.reject_prompt = _("station-comms","Decline to transport medical supplies")
						comms_target.restoration_mission.halfway_prompt = _("station-comms","Load medical supplies for hull repair facility technicians")
						comms_target.restoration_mission.halfway_complete_message = _("station-comms","Medical supplies loaded")
						comms_target.restoration_mission.destroyed_message = _("shipLog","Due to station destruction, your mission to transport medical supplies for the hull repair facility technicians cannot be completed")
						comms_target.restoration_mission.completion_prompt = _("station-comms","Unload medical supplies for hull repair facility technicians")
						comms_target.restoration_mission.thanks_message = _("station-comms","Thanks for the medical supplies. The technicians are feeling much better. Quarantine has been lifted. Come back and get your hull repaired any time.")
						comms_target.restoration_mission.optional_orders_first_half = string.format(_("orders-comms","Get medical supplies for technicians from %s in %s"),mission_origin:getCallSign(),mission_origin:getSectorName())
						comms_target.restoration_mission.optional_orders_second_half = string.format(_("orders-comms","Deliver medical supplies for technicians to %s in %s"),comms_target:getCallSign(),comms_target:getSectorName())
					end
				end
				if restore_target == "restock_probes" then
					if comms_target.probe_fail_reason == nil then
						local reason_list = {
							_("dockingServicesStatus-comms", "Cannot replenish scan probes due to fabrication unit failure."),
							_("dockingServicesStatus-comms", "Parts shortage prevents scan probe replenishment."),
							_("dockingServicesStatus-comms", "Station management has curtailed scan probe replenishment for cost cutting reasons."),
						}
						comms_target.probe_fail_reason = reason_list[math.random(1,#reason_list)]
					end
					if comms_target.probe_fail_reason == _("dockingServicesStatus-comms", "Cannot replenish scan probes due to fabrication unit failure.") then
						comms_target.restoration_mission.initiation_prompt = _("station-comms","Replace scan probe fabrication unit")
						comms_target.restoration_mission.explain_mission = string.format(_("station-comms","The unit that fabricates scan probes has failed. Station %s in sector %s has a replacement unit. We need you to transport the replacement probe fabrication unit. If you do this for us, we would reprogram our docking bay to instantly replenish your ship's scan probe supply any time you docked with us.\n\nTransporting the scan probe fabrication unit for %s would increase your reputation by %i."),mission_origin:getCallSign(),mission_origin:getSectorName(),comms_target:getCallSign(),comms_target.restoration_mission.reward)
						comms_target.restoration_mission.accept_prompt = _("station-comms","Agree to transport scan probe fabrication unit")
						comms_target.restoration_mission.reject_prompt = _("station-comms","Decline to transport scan probe fabrication unit")
						comms_target.restoration_mission.halfway_prompt = _("station-comms","Load replacement scan probe fabrication unit")
						comms_target.restoration_mission.halfway_complete_message = _("station-comms","Scan probe fabrication unit loaded")
						comms_target.restoration_mission.destroyed_message = _("shipLog","Due to station destruction, your mission to transport a replacement scan probe fabrication unit cannot be completed")
						comms_target.restoration_mission.completion_prompt = _("station-comms","Unload replacement scan probe fabrication unit")
						comms_target.restoration_mission.thanks_message = _("station-comms","Thanks for the scan probe fabrication unit. It's manufacturing probes at maximum capacity. Come back and get your scan probes replenished any time.")
						comms_target.restoration_mission.optional_orders_first_half = string.format(_("orders-comms","Get scan probe fabrication unit from %s in %s"),mission_origin:getCallSign(),mission_origin:getSectorName())
						comms_target.restoration_mission.optional_orders_second_half = string.format(_("orders-comms","Deliver scan probe fabrication unit to %s in %s"),comms_target:getCallSign(),comms_target:getSectorName())
					elseif comms_target.probe_fail_reason == _("dockingServicesStatus-comms", "Parts shortage prevents scan probe replenishment.") then
						comms_target.restoration_mission.initiation_prompt = _("station-comms","Provide parts for scan probe manufacturing")
						comms_target.restoration_mission.explain_mission = string.format(_("station-comms","Our scan probe manufacturing facility needs some repair parts. Station %s in sector %s has the necessary repair parts. We need someone to get those parts for us. If you do this for us, we would reprogram our docking bay to instantly replenish your ship's scan probe supply any time you docked with us.\n\nGetting the scan probe manufacturing facility repair parts for %s would increase your reputation by %i."),mission_origin:getCallSign(),mission_origin:getSectorName(),comms_target:getCallSign(),comms_target.restoration_mission.reward)
						comms_target.restoration_mission.accept_prompt = _("station-comms","Agree to get the repair parts")
						comms_target.restoration_mission.reject_prompt = _("station-comms","Decline to get the repair parts")
						comms_target.restoration_mission.halfway_prompt = _("station-comms","Load the scan probe manufacturing facility repair parts")
						comms_target.restoration_mission.halfway_complete_message = _("station-comms","Repair parts loaded")
						comms_target.restoration_mission.destroyed_message = _("shipLog","Due to station destruction, your mission to get repair parts for a scan probe manufacturing facility cannot be completed")
						comms_target.restoration_mission.completion_prompt = _("station-comms","Unload scan probe manufacturing facility repair parts")
						comms_target.restoration_mission.thanks_message = _("station-comms","Thanks for the repair parts. We are manufacturing probes at maximum capacity. Come back and get your scan probes replenished any time.")
						comms_target.restoration_mission.optional_orders_first_half = string.format(_("orders-comms","Get scan probe manufacturing facility repair parts from %s in %s"),mission_origin:getCallSign(),mission_origin:getSectorName())
						comms_target.restoration_mission.optional_orders_second_half = string.format(_("orders-comms","Deliver scan probe fmanufacturing facility repair parts to %s in %s"),comms_target:getCallSign(),comms_target:getSectorName())
					elseif comms_target.probe_fail_reason == _("dockingServicesStatus-comms", "Station management has curtailed scan probe replenishment for cost cutting reasons.") then
						comms_target.restoration_mission.initiation_prompt = _("station-comms","Improve efficiency of scan probe manufacturing")
						comms_target.restoration_mission.explain_mission = string.format(_("station-comms","Management shut down our scan probe manufacturing department claiming cost overruns. Felix Transom is on station %s in sector %s and he's got the latest efficiency algorithm and production techniques. He's eager to share his knowledge, but has no transportation. If you could bring him here, we would reprogram our docking bay to instantly replenish your ship's scan probe supply any time you docked with us.\n\nBringing Felix to %s would increase your reputation by %i."),mission_origin:getCallSign(),mission_origin:getSectorName(),comms_target:getCallSign(),comms_target.restoration_mission.reward)
						comms_target.restoration_mission.accept_prompt = _("station-comms","Agree to bring Felix")
						comms_target.restoration_mission.reject_prompt = _("station-comms","Decline to bring Felix")
						comms_target.restoration_mission.halfway_prompt = _("station-comms","Welcome Felix, the scan probe manufacturing efficiency expert aboard")
						comms_target.restoration_mission.halfway_complete_message = _("station-comms","[Felix] Fine ship you have here. I'm happy to be aboard.")
						comms_target.restoration_mission.destroyed_message = _("shipLog","Due to station destruction, your mission to transport the probe manufacturing efficiency expert cannot be completed")
						comms_target.restoration_mission.completion_prompt = _("station-comms","Direct Felix to disembark to provide scan probe efficiency advice")
						comms_target.restoration_mission.thanks_message = _("station-comms","Thanks for bringing Felix to us. Management has brought the scan probe manufacturing facility back online based on Felix's advice. Come back and get your scan probes replenished any time.")
						comms_target.restoration_mission.optional_orders_first_half = string.format(_("orders-comms","Pick up efficiency expert from %s in %s"),mission_origin:getCallSign(),mission_origin:getSectorName())
						comms_target.restoration_mission.optional_orders_second_half = string.format(_("orders-comms","Transport efficiency expert to %s in %s"),comms_target:getCallSign(),comms_target:getSectorName())
					end
				end
				if restore_target == "homing" or restore_target == "nuke" or restore_target == "emp" or restore_target == "mine" or restore_target == "hvli" then
					local restore_missiles = {
						["homing"] =	{desc = _("station-comms","homing missiles"),	rep = 1},
						["nuke"] =		{desc = _("station-comms","nukes"),				rep = 5},
						["emp"] =		{desc = _("station-comms","EMPs"),				rep = 5},
						["mine"] =		{desc = _("station-comms","mines"),				rep = 1},
						["hvli"] =		{desc = _("station-comms","HVLIs"),				rep = 1},
					}
					comms_target.restoration_mission.initiation_prompt = string.format(_("station-comms","Restore %s supply facility"),restore_missiles[restore_target].desc)
					comms_target.restoration_mission.explain_mission = string.format(_("station-comms","We provided %s for docked ships until the assembly line broke down. However, station %s in sector %s has repair parts. We need you to transport the repair parts. If you do this for us, we would restock your %s for %i rep each every time you docked with us.\n\nTransporting the repair parts for %s would increase your reputation by %i."),restore_missiles[restore_target].desc,mission_origin:getCallSign(),mission_origin:getSectorName(),restore_missiles[restore_target].desc,restore_missiles[restore_target].rep,comms_target:getCallSign(),comms_target.restoration_mission.reward)
					comms_target.restoration_mission.accept_prompt = _("station-comms","Agree to transport repair parts")
					comms_target.restoration_mission.reject_prompt = _("station-comms","Decline to transport repair parts")
					comms_target.restoration_mission.halfway_prompt = string.format(_("station-comms","Load %s assembly line repair parts"),restore_missiles[restore_target].desc)
					comms_target.restoration_mission.halfway_complete_message = _("station-comms","Repair parts loaded")
					comms_target.restoration_mission.destroyed_message = string.format(_("shipLog","Due to station destruction, your mission to transport repair parts for the %s assembly line cannot be completed"),restore_missiles[restore_target].desc)
					comms_target.restoration_mission.completion_prompt = string.format(_("station-comms","Unload repair parts for %s assembly line"),restore_missiles[restore_target].desc)
					comms_target.restoration_mission.thanks_message = string.format(_("station-comms","Thanks for the repair parts. We are once again able to make %s. Come back and replenish them any time."),restore_missiles[restore_target].desc)
					comms_target.restoration_mission.optional_orders_first_half = string.format(_("orders-comms","Pick up %s assembly line repair parts from %s in %s"),restore_missiles[restore_target].desc,mission_origin:getCallSign(),mission_origin:getSectorName())
					comms_target.restoration_mission.optional_orders_second_half = string.format(_("orders-comms","Deliver %s assembly line repair parts to %s in %s"),restore_missiles[restore_target].desc,comms_target:getCallSign(),comms_target:getSectorName())
				end
			end
		else
			if not comms_target.restoration_mission.origin:isValid() then
				comms_target.restoration_mission = nil
			end
		end
		if comms_target.restoration_mission ~= nil then
			presented_mission_button = true
			addCommsReply(comms_target.restoration_mission.initiation_prompt,function()
				setCommsMessage(comms_target.restoration_mission.explain_mission)
				addCommsReply(comms_target.restoration_mission.accept_prompt,function()
					comms_source.restoration_mission = {}
					comms_source.restoration_mission.origin =						comms_target.restoration_mission.origin
					comms_source.restoration_mission.destination =					comms_target.restoration_mission.destination
					comms_source.restoration_mission.reward =						comms_target.restoration_mission.reward
					comms_source.restoration_mission.achievement = false
					comms_source.restoration_mission.reward_type = 					comms_target.restoration_mission.reward_type
					comms_source.restoration_mission.halfway_prompt = 				comms_target.restoration_mission.halfway_prompt		
					comms_source.restoration_mission.halfway_complete_message =		comms_target.restoration_mission.halfway_complete_message
					comms_source.restoration_mission.destroyed_message = 			comms_target.restoration_mission.destroyed_message	
					comms_source.restoration_mission.completion_prompt = 			comms_target.restoration_mission.completion_prompt	
					comms_source.restoration_mission.thanks_message = 				comms_target.restoration_mission.thanks_message
					comms_source.restoration_mission.optional_orders_first_half = 	comms_target.restoration_mission.optional_orders_first_half 
					comms_source.restoration_mission.optional_orders_second_half =	comms_target.restoration_mission.optional_orders_second_half
					setCommsMessage(string.format(_("station-comms","We will contact %s to let them know you are coming"),comms_source.restoration_mission.origin:getCallSign()))
					comms_target.restoration_mission = nil
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(comms_target.restoration_mission.reject_prompt,function()
					local decline_acknowledgements = {
						_("station-comms","Understood."),
						_("station-comms","Acknowledged."),
						_("station-comms","Disappointed, but we understand."),
						_("station-comms","Ok, but think about it."),
						_("station-comms","Ok."),
					}
					setCommsMessage(decline_acknowledgements[math.random(1,#decline_acknowledgements)])
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
	if spew_function_diagnostic then print("bottom (ish) of comms restoration mission") end
	return presented_mission_button
end
function upgradePlayerShip(p,u_type)
	if spew_function_diagnostic then print("top of upgrade player ship") end
	local tempTypeName = p:getTypeName()
	local current_level = p.upgrade_path[u_type]
	if u_type == "beam" then
		for i,b in ipairs(upgrade_path[tempTypeName].beam[current_level+1]) do
			p:setBeamWeapon(b.idx,b.arc,b.dir,b.rng,b.cyc,b.dmg)
			p:setBeamWeaponTurret(b.idx,0,0,0)
			if b.tar ~= nil then
				p:setBeamWeaponTurret(b.idx,b.tar,b.tdr,b.trt)
			end
		end
	elseif u_type == "missiles" then
		for i=1,p:getWeaponTubeCount() do
			local tube_speed = p:getTubeLoadTime(i-1)
			p:setTubeLoadTime(i+1,.000001)
			p:commandUnloadTube(i-1)
			p:setTubeLoadTime(i+1,tube_speed)
		end
		local tube_level = upgrade_path[tempTypeName].missiles[current_level+1].tube
		local ordnance_level = upgrade_path[tempTypeName].missiles[current_level+1].ord
		p:setWeaponTubeCount(#upgrade_path[tempTypeName].tube[tube_level])
		local size_trans = {
			["S"] = "small",
			["M"] = "medium",
			["L"] = "large",
		}
		local missile_trans = {
			{typ = "Homing", short_type = "hom"},
			{typ = "Nuke", short_type = "nuk"},
			{typ = "EMP", short_type = "emp"},
			{typ = "Mine", short_type = "min"},
			{typ = "HVLI", short_type = "hvl"},
		}
		for i,m in ipairs(upgrade_path[tempTypeName].tube[tube_level]) do
			p:setWeaponTubeDirection(m.idx,m.dir)
			p:setTubeSize(m.idx,size_trans[m.siz])
			p:setTubeLoadTime(m.idx,m.spd)
			local exclusive = false
			for j,lm in ipairs(missile_trans) do
				if m[lm.short_type] then
					if exclusive then
						p:weaponTubeAllowMissle(m.idx,lm.typ)
					else
						p:setWeaponTubeExclusiveFor(m.idx,lm.typ)
						exclusive = true
					end
				end
			end
		end
		for i,o in ipairs(missile_trans) do
--			print("upgrade ship missiles: o typ:",o.typ,"template:",tempTypeName,"ordnance level:",ordnance_level,"o short type:",o.short_type)
			p:setWeaponStorageMax(o.typ,upgrade_path[tempTypeName].ordnance[ordnance_level][o.short_type])
		end
		if p:getWeaponTubeCount() > 0 then
			local size_letter = {
				["small"] = 	"S",
				["medium"] =	"M",
				["large"] =		"L",
			}
			p.tube_size = ""
			for i=1,p:getWeaponTubeCount() do
				p.tube_size = p.tube_size .. size_letter[p:getTubeSize(i-1)]
			end
		end
	elseif u_type == "shield" then
		if #upgrade_path[tempTypeName].shield[current_level+1] > 1 then
			p:setShieldsMax(upgrade_path[tempTypeName].shield[current_level+1][1].max,upgrade_path[tempTypeName].shield[current_level+1][2].max)
			p:setShields(upgrade_path[tempTypeName].shield[current_level+1][1].max,upgrade_path[tempTypeName].shield[current_level+1][2].max)
		else
			p:setShieldsMax(upgrade_path[tempTypeName].shield[current_level+1][1].max)
			p:setShields(upgrade_path[tempTypeName].shield[current_level+1][1].max)
		end
	elseif u_type == "hull" then
		p:setHullMax(upgrade_path[tempTypeName].hull[current_level+1].max)
		p:setHull(upgrade_path[tempTypeName].hull[current_level+1].max)
	elseif u_type == "impulse" then
		p:setImpulseMaxSpeed(upgrade_path[tempTypeName].impulse[current_level+1].max_front,upgrade_path[tempTypeName].impulse[current_level+1].max_back)
		p:setAcceleration(upgrade_path[tempTypeName].impulse[current_level+1].accel_front,upgrade_path[tempTypeName].impulse[current_level+1].accel_back)
		p:setRotationMaxSpeed(upgrade_path[tempTypeName].impulse[current_level+1].turn)
		if upgrade_path[tempTypeName].impulse[current_level+1].boost > 0 or upgrade_path[tempTypeName].impulse[current_level+1].strafe > 0 then
			p:setCanCombatManeuver(true)
			p:setCombatManeuver(upgrade_path[tempTypeName].impulse[current_level+1].boost,upgrade_path[tempTypeName].impulse[current_level+1].strafe)
			p.combat_maneuver_capable = true
		end
	elseif u_type == "ftl" then
		if upgrade_path[tempTypeName].ftl[current_level+1].jump_long > 0 then
			p:setJumpDrive(true)
			p.max_jump_range = upgrade_path[tempTypeName].ftl[current_level+1].jump_long
			p.min_jump_range = upgrade_path[tempTypeName].ftl[current_level+1].jump_short
			p:setJumpDriveRange(p.min_jump_range,p.max_jump_range)
			p:setJumpDriveCharge(p.max_jump_range)
		end
		if upgrade_path[tempTypeName].ftl[current_level+1].warp > 0 then
			p:setWarpDrive(true)
			p:setWarpSpeed(upgrade_path[tempTypeName].ftl[current_level+1].warp)
		end
	elseif u_type == "sensors" then		
		p:setLongRangeRadarRange(upgrade_path[tempTypeName].sensors[current_level+1].long)
		p.normal_long_range_radar = upgrade_path[tempTypeName].sensors[current_level+1].long
		p:setShortRangeRadarRange(upgrade_path[tempTypeName].sensors[current_level+1].short)
		p.prox_scan = upgrade_path[tempTypeName].sensors[current_level+1].prox_scan
	end
	p.upgrade_path[u_type] = current_level+1
	p.shipScore = p.shipScore + 1
	if spew_function_diagnostic then print("bottom of upgrade player ship") end
end
function downgradePlayerShip(p,u_type)
	if spew_function_diagnostic then print("top of downgrade player ship") end
	local tempTypeName = p:getTypeName()
	local current_level = p.upgrade_path[u_type]
	if u_type == "beam" then
		for i=0,15 do
			p:setBeamWeapon(i,0,0,0,0,0)
			p:setBeamWeaponTurret(i,0,0,0)
		end
		for i,b in ipairs(upgrade_path[tempTypeName].beam[current_level-1]) do
			p:setBeamWeapon(b.idx,b.arc,b.dir,b.rng,b.cyc,b.dmg)
			p:setBeamWeaponTurret(b.idx,0,0,0)
			if b.tar ~= nil then
				p:setBeamWeaponTurret(b.idx,b.tar,b.tdr,b.trt)
			end
		end
	elseif u_type == "missiles" then
		for i=1,p:getWeaponTubeCount() do
			local tube_speed = p:getTubeLoadTime(i-1)
			p:setTubeLoadTime(i+1,.000001)
			p:commandUnloadTube(i-1)
			p:setTubeLoadTime(i+1,tube_speed)
			p:setWeaponTubeExclusiveFor(i-1,"HVLI")
			p:weaponTubeDisallowMissle(i-1,"HVLI")
		end
		local tube_level = upgrade_path[tempTypeName].missiles[current_level-1].tube
		local ordnance_level = upgrade_path[tempTypeName].missiles[current_level-1].ord
		p:setWeaponTubeCount(#upgrade_path[tempTypeName].tube[tube_level])
		local size_trans = {
			["S"] = "small",
			["M"] = "medium",
			["L"] = "large",
		}
		local missile_trans = {
			{typ = "Homing", short_type = "hom"},
			{typ = "Nuke", short_type = "nuk"},
			{typ = "EMP", short_type = "emp"},
			{typ = "Mine", short_type = "min"},
			{typ = "HVLI", short_type = "hvl"},
		}
		for i,m in ipairs(upgrade_path[tempTypeName].tube[tube_level]) do
			p:setWeaponTubeDirection(m.idx,m.dir)
			p:setTubeSize(m.idx,size_trans[m.siz])
			p:setTubeLoadTime(m.idx,m.spd)
			local exclusive = false
			for j,lm in ipairs(missile_trans) do
				if m[lm.short_type] then
					if exclusive then
						p:weaponTubeAllowMissle(m.idx,lm.typ)
					else
						p:setWeaponTubeExclusiveFor(m.idx,lm.typ)
						exclusive = true
					end
				end
			end
		end
		for i,o in ipairs(missile_trans) do
--			print("upgrade ship missiles: o typ:",o.typ,"template:",tempTypeName,"ordnance level:",ordnance_level,"o short type:",o.short_type)
			p:setWeaponStorageMax(o.typ,upgrade_path[tempTypeName].ordnance[ordnance_level][o.short_type])
		end
		if p:getWeaponTubeCount() > 0 then
			local size_letter = {
				["small"] = 	"S",
				["medium"] =	"M",
				["large"] =		"L",
			}
			p.tube_size = ""
			for i=1,p:getWeaponTubeCount() do
				p.tube_size = p.tube_size .. size_letter[p:getTubeSize(i-1)]
			end
		end
	elseif u_type == "shield" then
		if #upgrade_path[tempTypeName].shield[current_level-1] > 1 then
			p:setShieldsMax(upgrade_path[tempTypeName].shield[current_level-1][1].max,upgrade_path[tempTypeName].shield[current_level-1][2].max)
			p:setShields(upgrade_path[tempTypeName].shield[current_level-1][1].max,upgrade_path[tempTypeName].shield[current_level-1][2].max)
		else
			p:setShieldsMax(upgrade_path[tempTypeName].shield[current_level-1][1].max)
			p:setShields(upgrade_path[tempTypeName].shield[current_level-1][1].max)
		end
	elseif u_type == "hull" then
		p:setHullMax(upgrade_path[tempTypeName].hull[current_level-1].max)
		p:setHull(upgrade_path[tempTypeName].hull[current_level-1].max)
	elseif u_type == "impulse" then
		p:setImpulseMaxSpeed(upgrade_path[tempTypeName].impulse[current_level-1].max_front,upgrade_path[tempTypeName].impulse[current_level-1].max_back)
		p:setAcceleration(upgrade_path[tempTypeName].impulse[current_level-1].accel_front,upgrade_path[tempTypeName].impulse[current_level-1].accel_back)
		p:setRotationMaxSpeed(upgrade_path[tempTypeName].impulse[current_level-1].turn)
		if upgrade_path[tempTypeName].impulse[current_level-1].boost > 0 or upgrade_path[tempTypeName].impulse[current_level-1].strafe > 0 then
			p:setCanCombatManeuver(true)
			p:setCombatManeuver(upgrade_path[tempTypeName].impulse[current_level-1].boost,upgrade_path[tempTypeName].impulse[current_level-1].strafe)
			p.combat_maneuver_capable = true
		else
			p:setCanCombatManeuver(false)
			p.combat_maneuver_capable = false
		end
	elseif u_type == "ftl" then
		if upgrade_path[tempTypeName].ftl[current_level-1].jump_long > 0 then
			p:setJumpDrive(true)
			p.max_jump_range = upgrade_path[tempTypeName].ftl[current_level-1].jump_long
			p.min_jump_range = upgrade_path[tempTypeName].ftl[current_level-1].jump_short
			p:setJumpDriveRange(p.min_jump_range,p.max_jump_range)
			p:setJumpDriveCharge(p.max_jump_range)
		else
			p:setJumpDrive(false)
		end
		if upgrade_path[tempTypeName].ftl[current_level-1].warp > 0 then
			p:setWarpDrive(true)
			p:setWarpSpeed(upgrade_path[tempTypeName].ftl[current_level-1].warp)
		else
			p:setWarpDrive(false)
		end
	elseif u_type == "sensors" then		
		p:setLongRangeRadarRange(upgrade_path[tempTypeName].sensors[current_level-1].long)
		p.normal_long_range_radar = upgrade_path[tempTypeName].sensors[current_level-1].long
		p:setShortRangeRadarRange(upgrade_path[tempTypeName].sensors[current_level-1].short)
		p.prox_scan = upgrade_path[tempTypeName].sensors[current_level-1].prox_scan
	end
	p.upgrade_path[u_type] = current_level-1
	p.shipScore = p.shipScore - 1
	if spew_function_diagnostic then print("bottom of downgrade player ship") end
end
function commsFreeUpgrades()
	if spew_function_diagnostic then print("top of comms free upgrades") end
	comms_source.free_upgrade = "complete"
	if comms_source.free_upgrade_count == nil then
		comms_source.free_upgrade_count = 20
	end
	setCommsMessage(string.format(_("upgrade-comms","Welcome, my CUF friends! I'm ready to upgrade your ship with 20 levels of free upgrades. Out of those 20, %s remain.\nMy employers are keeping a close eye on me, so I can only do upgrades right now, since I'm technically not supposed to do upgrades for free. As soon as you close comms, or undock, the free upgrades are done. What upgrade would you like?"),comms_source.free_upgrade_count))
	local p_ship_type = comms_source:getTypeName()
	for u_type, u_blob in pairs(upgrade_path[p_ship_type]) do
		local p_upgrade_level = comms_source.upgrade_path[u_type]
		if u_type ~= "score" and u_type ~= "providers" and u_type ~= "tube" and u_type ~= "ordnance" then
			if #u_blob > p_upgrade_level then
				addCommsReply(string.format("%s: %s",u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc),function()
					if not comms_source:isDocked(comms_target) then 
						setCommsMessage(_("upgrade-comms","You need to stay docked for that action."))
						return
					end
					upgradePlayerShip(comms_source,u_type)
					setCommsMessage(_("upgrade-comms","Upgrade complete"))
					comms_source.free_upgrade_count = comms_source.free_upgrade_count - 1
					if comms_source.free_upgrade_count > 0 then
						addCommsReply(_("Back to Acosta's free upgrades"), commsFreeUpgrades)
					end
				end)
			end
		end
	end
	if spew_function_diagnostic then print("bottom of comms free upgrades") end
end
function commsOrdnanceUpgradesRepairs()
	if spew_function_diagnostic then print("top of ordnance upgrades repairs") end
	local goodCount = 0
	for good, goodData in pairs(comms_target.comms_data.goods) do
		goodCount = goodCount + 1
	end
	addCommsReply(_("station-comms","Station services (restock ordnance, upgrades, repairs)"),function()
		setCommsMessage(_("station-comms","What station service are you interested in?"))
		if station_nearest_inner ~= nil and station_nearest_inner:isValid() then
			if needy_freighter ~= nil and needy_freighter:isValid() then
				if needy_freighter:isDocked(station_nearest_inner) or distance(needy_freighter,station_nearest_inner) < 1000 then
					if comms_target == station_nearest_inner then
						if comms_source.free_upgrade == nil then
							addCommsReply("Charles Acosta's Upgrade Shop (free upgrades)",commsFreeUpgrades)
						end
					end
				end
			end
		end
		if comms_target.comms_data.upgrade_path ~= nil then
			local p_ship_type = comms_source:getTypeName()
			if comms_target.comms_data.upgrade_path[p_ship_type] ~= nil then
				addCommsReply(_("upgrade-comms","Upgrade ship"),function()
					local upgrade_count = 0
					for u_type, u_blob in pairs(comms_target.comms_data.upgrade_path[p_ship_type]) do
						local p_upgrade_level = comms_source.upgrade_path[u_type]
						if u_blob > p_upgrade_level then
							upgrade_count = upgrade_count + 1
							addCommsReply(string.format("%s: %s",u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc),function()
								local premium_upgrade_price = math.ceil(base_upgrade_cost+30+((p_upgrade_level+1)*upgrade_price))
								local tradeoff_upgrade_price = math.ceil(base_upgrade_cost+10+((p_upgrade_level+1)*upgrade_price))
								local pitdroid_upgrade_price = math.ceil(base_upgrade_cost+((p_upgrade_level+1)*upgrade_price))
								if comms_target.good_traded_for_upgrade == nil then
									comms_target.good_traded_for_upgrade = {"food","medicine"}
								end
								if goodCount > 0 then
									if comms_source.goods ~= nil then
										local trade_good_list = {}
										for good, good_quantity in ipairs(comms_source.goods) do
											if good_quantity > 0 then
												local traded = false
												for i,traded_good in ipairs(comms_target.good_traded_for_upgrade) do
													if traded_good == good then
														traded = true
														break
													end
												end
												if not traded then
													table.insert(trade_good_list,good)
												end
											end
										end
									end
								end
								local tandem_modified_system = nil
								local random_system = nil
								if upgrade_path[p_ship_type][u_type][1].downgrade ~= nil then
									local upgraded_systems = {}
									for p_u_system, p_u_level in pairs(comms_source.upgrade_path) do
										if p_u_system ~= u_type and p_u_level > 1 then
											table.insert(upgraded_systems,{sys=p_u_system,lvl=p_u_level,desc=upgrade_path[p_ship_type][p_u_system][p_u_level - 1].downgrade})
										end
									end
									table.sort(upgraded_systems,function(a,b)
										return a.lvl > b.lvl
									end)
									if #upgraded_systems > 0 then
										tandem_modified_system = upgraded_systems[1]
										random_system = upgraded_systems[math.random(1,#upgraded_systems)]
									end
								end
								if tandem_modified_system ~= nil then
									if trade_good_list ~= nil and #trade_good_list > 0 then
										setCommsMessage(string.format(_("upgrade-comms","We've got four ways to provide the %s upgrade (%s):\n    Trade: certified technician performs the upgrade in exchange for cargo on your ship\n    Premium: certified technician performs the upgrade\n    Tradeoff: Freelance technician performs the upgrade but another system will be modified: %s\n    Pit Droid: Upgrade guaranteed, but there is a chance that another system may be modified"),u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc,tandem_modified_system.sys))
									else
										setCommsMessage(string.format(_("upgrade-comms","We've got three ways to provide the %s upgrade (%s):\n    Premium: certified technician performs the upgrade\n    Tradeoff: Freelance technician performs the upgrade but another system will be modified: %s\n    Pit Droid: Upgrade guaranteed, but there is a chance that another system may be modified"),u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc,tandem_modified_system.sys))
									end
								else
									if trade_good_list ~= nil and #trade_good_list > 0 then
										setCommsMessage(string.format(_("upgrade-comms","We've got three ways to provide the %s upgrade (%s):\n    Trade: certified technician performs the upgrade in exchange for cargo on your ship\n    Premium: certified technician performs the upgrade\n    Pit Droid: Upgrade guaranteed, but there is a chance that another system may be modified"),u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc))
									else
										setCommsMessage(string.format(_("upgrade-comms","We've got two ways to provide the %s upgrade (%s):\n    Premium: certified technician performs the upgrade\n    Pit Droid: Upgrade guaranteed, but there is a chance that another system may be modified"),u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc))
									end
								end
								if trade_good_list ~= nil and #trade_good_list > 0 then
									for i, trade_good in ipairs(trade_good_list) do
										addCommsReply(string.format(_("upgrade-comms","Trade (%s)"),trade_good),function()
											if not comms_source:isDocked(comms_target) then 
												setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
												return
											end
											if comms_source.goods[trade_good] ~= nil and comms_source.goods[trade_good] > 0 then
												comms_source.goods[trade_good] = comms_source.goods[trade_good] - 1
												table.insert(comms_target.good_traded_for_upgrade,trade_good)
												upgradePlayerShip(comms_source,u_type)
												setCommsMessage(_("upgrade-comms","Upgrade complete"))
											else
												setCommsMessage(_("upgrade-comms","Insufficient cargo"))
											end
											addCommsReply(_("Back"), commsStation)
										end)
									end
								end
								addCommsReply(string.format(_("upgrade-comms","Premium (%s reputation)"),premium_upgrade_price),function()
									if not comms_source:isDocked(comms_target) then 
										setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
										return
									end
									if comms_source:takeReputationPoints(premium_upgrade_price) then
										upgradePlayerShip(comms_source,u_type)
										setCommsMessage(_("upgrade-comms","Upgrade complete"))
									else
										setCommsMessage(_("needRep-comms", "Insufficient reputation"))
									end
									addCommsReply(_("Back"), commsStation)
								end)
								if tandem_modified_system ~= nil then
									addCommsReply(string.format(_("upgrade-comms","Tradeoff (%s reputation)"),tradeoff_upgrade_price),function()
										if not comms_source:isDocked(comms_target) then 
											setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
											return
										end
										if comms_source:takeReputationPoints(tradeoff_upgrade_price) then
											upgradePlayerShip(comms_source,u_type)
											downgradePlayerShip(comms_source,tandem_modified_system.sys)
											setCommsMessage(string.format(_("upgrade-comms","Upgrade complete. The upgrade has %s on your %s system."),tandem_modified_system.desc,tandem_modified_system.sys))
										else
											setCommsMessage(_("needRep-comms", "Insufficient reputation"))
										end
										addCommsReply(_("Back"), commsStation)
									end)
								end
								addCommsReply(string.format(_("upgrade-comms","Pit Droid (%s reputation)"),pitdroid_upgrade_price),function()
									if not comms_source:isDocked(comms_target) then 
										setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
										return
									end
									if comms_source:takeReputationPoints(pitdroid_upgrade_price) then
										upgradePlayerShip(comms_source,u_type)
										local upgrade_consequence = ""
										if random(1,100) < (50 - (difficulty * 10)) and random_system ~= nil then
											downgradePlayerShip(comms_source,random_system.sys)
											upgrade_consequence = string.format(_("upgrade-comms"," The upgrade has %s on your %s system."),random_system.desc,random_system.sys)
										end
										setCommsMessage(string.format(_("upgrade-comms","Upgrade complete.%s"),upgrade_consequence))
									else
										setCommsMessage(_("needRep-comms", "Insufficient reputation"))
									end
									addCommsReply(_("Back"), commsStation)
								end)
								addCommsReply(_("Back"), commsStation)
							end)
						end
						if upgrade_count > 0 then
							setCommsMessage(_("upgrade-comms","What kind of upgrade are you interested in? We can provide the following upgrades\nsystem: description"))
						else
							setCommsMessage(_("upgrade-comms","Alas, we cannot upgrade any of your systems"))
						end
					end
					addCommsReply(_("Back"), commsStation)
				end)
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
							addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), nukePrompt, getWeaponCost("Nuke")), function()
								if stationCommsDiagnostic then print("going to handle weapon restock function") end
								handleWeaponRestock("Nuke")
							end)
						end	--end station has nuke available if branch
					end	--end player can accept nuke if branch
					if comms_source:getWeaponStorageMax("EMP") > 0 then
						if comms_target.comms_data.weapon_available.EMP then
							if math.random(1,10) <= 5 then
								empPrompt = _("ammo-comms", "Please re-stock our EMP missiles. (")
							else
								empPrompt = _("ammo-comms", "Got any EMPs? (")
							end
							addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), empPrompt, getWeaponCost("EMP")), function()
								handleWeaponRestock("EMP")
							end)
						end	--end station has EMP available if branch
					end	--end player can accept EMP if branch
					if comms_source:getWeaponStorageMax("Homing") > 0 then
						if comms_target.comms_data.weapon_available.Homing then
							if math.random(1,10) <= 5 then
								homePrompt = _("ammo-comms", "Do you have spare homing missiles for us? (")
							else
								homePrompt = _("ammo-comms", "Do you have extra homing missiles? (")
							end
							addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), homePrompt, getWeaponCost("Homing")), function()
								handleWeaponRestock("Homing")
							end)
						end	--end station has homing for player if branch
					end	--end player can accept homing if branch
					if comms_source:getWeaponStorageMax("Mine") > 0 then
						if comms_target.comms_data.weapon_available.Mine then
							if math.random(1,10) <= 5 then
								minePrompt = _("ammo-comms", "We could use some mines. (")
							else
								minePrompt = _("ammo-comms", "How about mines? (")
							end
							addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), minePrompt, getWeaponCost("Mine")), function()
								handleWeaponRestock("Mine")
							end)
						end	--end station has mine for player if branch
					end	--end player can accept mine if branch
					if comms_source:getWeaponStorageMax("HVLI") > 0 then
						if comms_target.comms_data.weapon_available.HVLI then
							if math.random(1,10) <= 5 then
								hvliPrompt = _("ammo-comms", "What about HVLI? (")
							else
								hvliPrompt = _("ammo-comms", "Could you provide HVLI? (")
							end
							addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), hvliPrompt, getWeaponCost("HVLI")), function()
								handleWeaponRestock("HVLI")
							end)
						end	--end station has HVLI for player if branch
					end	--end player can accept HVLI if branch
				end)	--end player requests secondary ordnance comms reply branch
			end	--end secondary ordnance available from station if branch
		end	--end missles used on player ship if branch
		addCommsReply(_("dockingServicesStatus-comms", "Docking services status"), function()
			local service_status = string.format(_("dockingServicesStatus-comms", "Station %s docking services status:"),comms_target:getCallSign())
			if comms_target:getRestocksScanProbes() then
				service_status = string.format(_("dockingServicesStatus-comms", "%s\nReplenish scan probes."),service_status)
			else
				if comms_target.probe_fail_reason == nil then
					local reason_list = {
						_("dockingServicesStatus-comms", "Cannot replenish scan probes due to fabrication unit failure."),
						_("dockingServicesStatus-comms", "Parts shortage prevents scan probe replenishment."),
						_("dockingServicesStatus-comms", "Station management has curtailed scan probe replenishment for cost cutting reasons."),
					}
					comms_target.probe_fail_reason = reason_list[math.random(1,#reason_list)]
				end
				service_status = string.format("%s\n%s",service_status,comms_target.probe_fail_reason)
			end
			if comms_target:getRepairDocked() then
				service_status = string.format(_("dockingServicesStatus-comms", "%s\nShip hull repair."),service_status)
			else
				if comms_target.repair_fail_reason == nil then
					reason_list = {
						_("dockingServicesStatus-comms", "We're out of the necessary materials and supplies for hull repair."),
						_("dockingServicesStatus-comms", "Hull repair automation unavailable while it is undergoing maintenance."),
						_("dockingServicesStatus-comms", "All hull repair technicians quarantined to quarters due to illness."),
					}
					comms_target.repair_fail_reason = reason_list[math.random(1,#reason_list)]
				end
				service_status = string.format("%s\n%s",service_status,comms_target.repair_fail_reason)
			end
			if comms_target:getSharesEnergyWithDocked() then
				service_status = string.format(_("dockingServicesStatus-comms", "%s\nRecharge ship energy stores."),service_status)
			else
				if comms_target.energy_fail_reason == nil then
					reason_list = {
						_("dockingServicesStatus-comms", "A recent reactor failure has put us on auxiliary power, so we cannot recharge ships."),
						_("dockingServicesStatus-comms", "A damaged power coupling makes it too dangerous to recharge ships."),
						_("dockingServicesStatus-comms", "An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now."),
					}
					comms_target.energy_fail_reason = reason_list[math.random(1,#reason_list)]
				end
				service_status = string.format("%s\n%s",service_status,comms_target.energy_fail_reason)
			end
			if comms_target.comms_data.jump_overcharge then
				service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay overcharge jump drive"),service_status)
			end
			if comms_target.comms_data.probe_launch_repair then
				service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair probe launch system"),service_status)
			end
			if comms_target.comms_data.hack_repair then
				service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair hacking system"),service_status)
			end
			if comms_target.comms_data.scan_repair then
				service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair scanners"),service_status)
			end
			if comms_target.comms_data.combat_maneuver_repair then
				service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair combat maneuver"),service_status)
			end
			if comms_target.comms_data.self_destruct_repair then
				service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair self destruct system"),service_status)
			end
			setCommsMessage(service_status)
			addCommsReply(_("Back"), commsStation)
		end)
		if comms_target.comms_data.jump_overcharge then
			if comms_source:hasJumpDrive() then
				local max_charge = comms_source.max_jump_range
				if max_charge == nil then
					max_charge = 50000
				end
				if comms_source:getJumpDriveCharge() >= max_charge then
					addCommsReply(_("dockingServicesStatus-comms", "Overcharge Jump Drive (10 Rep)"),function()
						if not comms_source:isDocked(comms_target) then 
							setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
							return
						end
						if comms_source:takeReputationPoints(10) then
							comms_source:setJumpDriveCharge(comms_source:getJumpDriveCharge() + max_charge)
							setCommsMessage(string.format(_("dockingServicesStatus-comms", "Your jump drive has been overcharged to %ik"),math.floor(comms_source:getJumpDriveCharge()/1000)))
						else
							setCommsMessage(_("needRep-comms", "Insufficient reputation"))
						end
						addCommsReply(_("Back"), commsStation)
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
		if not offer_repair and comms_target.comms_data.combat_maneuver_repair and not comms_source:getCanCombatManeuver() and comms_source.combat_maneuver_capable then
			offer_repair = true
		end
		if not offer_repair and comms_target.comms_data.self_destruct_repair and not comms_source:getCanSelfDestruct() then
			offer_repair = true
		end
		if offer_repair then
			addCommsReply(_("dockingServicesStatus-comms", "Repair ship system"),function()
				setCommsMessage(string.format(_("dockingServicesStatus-comms","What system would you like repaired?\n\nReputation: %i"),math.floor(comms_source:getReputationPoints())))
				if comms_target.comms_data.probe_launch_repair then
					if not comms_source:getCanLaunchProbe() then
						addCommsReply(string.format(_("dockingServicesStatus-comms","Repair probe launch system (%s Rep)"),comms_target.comms_data.service_cost.probe_launch_repair),function()
							if not comms_source:isDocked(comms_target) then 
								setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
								return
							end
							if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.probe_launch_repair) then
								comms_source:setCanLaunchProbe(true)
								setCommsMessage(_("dockingServicesStatus-comms", "Your probe launch system has been repaired"))
							else
								setCommsMessage(_("needRep-comms", "Insufficient reputation"))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				if comms_target.comms_data.hack_repair then
					if not comms_source:getCanHack() then
						addCommsReply(string.format(_("dockingServicesStatus-comms","Repair hacking system (%s Rep)"),comms_target.comms_data.service_cost.hack_repair),function()
							if not comms_source:isDocked(comms_target) then 
								setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
								return
							end
							if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.hack_repair) then
								comms_source:setCanHack(true)
								setCommsMessage(_("dockingServicesStatus-comms", "Your hack system has been repaired"))
							else
								setCommsMessage(_("needRep-comms", "Insufficient reputation"))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				if comms_target.comms_data.scan_repair then
					if not comms_source:getCanScan() then
						addCommsReply(string.format(_("dockingServicesStatus-comms","Repair scanning system (%s Rep)"),comms_target.comms_data.service_cost.scan_repair),function()
							if not comms_source:isDocked(comms_target) then 
								setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
								return
							end
							if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.scan_repair) then
								comms_source:setCanScan(true)
								setCommsMessage(_("dockingServicesStatus-comms", "Your scanners have been repaired"))
							else
								setCommsMessage(_("needRep-comms", "Insufficient reputation"))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				if comms_target.comms_data.combat_maneuver_repair then
					if not comms_source:getCanCombatManeuver() then
						if comms_source.combat_maneuver_capable then
							addCommsReply(string.format(_("dockingServicesStatus-comms","Repair combat maneuver (%s Rep)"),comms_target.comms_data.service_cost.combat_maneuver_repair),function()
								if not comms_source:isDocked(comms_target) then 
									setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
									return
								end
								if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.combat_maneuver_repair) then
									comms_source:setCanCombatManeuver(true)
									setCommsMessage(_("dockingServicesStatus-comms", "Your combat maneuver has been repaired"))
								else
									setCommsMessage(_("needRep-comms", "Insufficient reputation"))
								end
								addCommsReply(_("Back"), commsStation)
							end)
						end
					end
				end
				if comms_target.comms_data.self_destruct_repair then
					if not comms_source:getCanSelfDestruct() then
						addCommsReply(string.format(_("dockingServicesStatus-comms","Repair self destruct system (%s Rep)"),comms_target.comms_data.service_cost.self_destruct_repair),function()
							if not comms_source:isDocked(comms_target) then 
								setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
								return
							end
							if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.self_destruct_repair) then
								comms_source:setCanSelfDestruct(true)
								setCommsMessage(_("dockingServicesStatus-comms", "Your self destruct system has been repaired"))
							else
								setCommsMessage(_("needRep-comms", "Insufficient reputation"))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
		if comms_source.shield_banner == nil or not comms_source.shield_banner then
			if comms_target.shield_banner == nil then
				if random(1,100) < 50 then
					comms_target.shield_banner = true
				else
					comms_target.shield_banner = false
				end
			end
			if comms_target.shield_banner then
				addCommsReply(_("station-comms","Spare portable shield diagnostic"),function()
					setCommsMessage(_("station-comms","We've got a spare portable shield diagnostic if you're interested. Engineers use these to get raw data on shield status. Why? well, sometimes they prefer the raw numbers over the normal percentages that appear. Would you like to get this for your engineer?"))
					addCommsReply(_("station-comms","Yes, that's a perfect gift (5 reputation)"),function()
						if comms_source:takeReputationPoints(5) then
							comms_source.shield_banner = true
							comms_target.shield_banner = false
							setCommsMessage(_("station-comms","Installed"))
						else
							setCommsMessage(_("needRep-comms", "Insufficient reputation"))
						end
						addCommsReply(_("Back"), commsStation)
					end)
				end)
			end
		elseif comms_source.shield_banner ~= nil and comms_source.shield_banner then
			addCommsReply("Give portable shield diagnostic to repair technicians",function()
				setCommsMessage("Thanks. They will put it to good use.")
				comms_source.shield_banner = false
				comms_target.shield_banner = true
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end)
	if spew_function_diagnostic then print("end of ordnance upgrades repairs") end
end
function commsInformationStation()
	if spew_function_diagnostic then print("top of comms information station") end
	addCommsReply(_("station-comms","I need information"),function()
		setCommsMessage(_("station-comms","What do you need to know?"))
		addCommsReply(_("station-comms","What's with all the warp jammers?"),function()
			setCommsMessage(_("station-comms","When factions in various stations in the area started attacking each other, there was a particularly nasty tactic employed where warp or jump ships would ambush a station. Stations could not maintain defensive patrols indefinitely due to the expense. Putting in a warp jammer gives the station a chance to scramble their defense fleet when an enemy approaches. Of course, it slows friendly traffic, commercial or military, too. So, most warp jammers are controlled by nearby factions to allow them to enable or disable them upon request to facilitate the flow of ships. You can't connect to the warp jammer while docked because you're clearly not yet ready to traverse the controlled area. Destroying a warp jammer may have undesired indirect consequences, but there's no official rule against it."))
			addCommsReply(_("Back"), commsStation)
		end)
		local has_gossip = random(1,100) < (100 - (30 * (difficulty - .5)))
		if (comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "") or
			(comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "") or
			(comms_source:isFriendly(comms_target) and comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" and has_gossip) then
			addCommsReply(_("station-comms", "Tell me more about your station"), function()
				setCommsMessage(_("station-comms", "What would you like to know?"))
				if comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "" then
					addCommsReply(_("stationGeneralInfo-comms", "General information"), function()
						setCommsMessage(comms_target.comms_data.general)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "" then
					addCommsReply(_("stationStory-comms", "Station history"), function()
						setCommsMessage(comms_target.comms_data.history)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if comms_source:isFriendly(comms_target) then
					if comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" then
						if has_gossip then
							addCommsReply(_("gossip-comms", "Gossip"), function()
								setCommsMessage(comms_target.comms_data.gossip)
								addCommsReply(_("Back"), commsStation)
							end)
						end
					end
				end
				addCommsReply(_("Back"), commsStation)
			end)	--end station info comms reply branch
		end
		addCommsReply(_("orders-comms", "What are my current orders?"), function()
			setOptionalOrders()
			setSecondaryOrders()
			primary_orders = _("orders-comms","Survive.")
			if getScenarioTime() > 600 then
				primary_orders = _("orders-comms","Survive. Contact the CUF")
			end
			ordMsg = primary_orders .. "\n" .. secondary_orders .. optional_orders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format(_("orders-comms", "\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			if getScenarioTime() > 1200 then
				addCommsReply(_("orders-comms","Is there any more we can do?"),moreOrders)
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end)
	if spew_function_diagnostic then print("bottom of comms information station") end
end
function moreOrders()
	setCommsMessage(_("orders-comms","I'm just a lowly station communications operator. Those bits you read about orders come from your own internal computers and communications records. I just organize them for you. Are you sure you want to ask me about other things you can do? I don't represent your commanders in the CUF, you know."))
	addCommsReply(_("orders-comms","Yes, please advise us"),function()
		setCommsMessage(_("orders-comms","I talk to a variety of commanders of ships and stations. These are some of my insights:"))
		addCommsReply(_("orders-comms","Survive"),function()
			setCommsMessage(_("orders-comms","This is fairly obvious. It's written into your primary orders. I've noticed you are capable of defending yourself through the destruction of enemy vessels. Keep it up."))
			addCommsReply(_("orders-comms","Back to suggested actions"),moreOrders)
			addCommsReply(_("orders-comms","Back to station communication"),commsStation)
		end)
		addCommsReply(_("orders-comms","Reconnect"),function()
			setCommsMessage(_("orders-comms","We've heard your story of violent transport from CUF space to here, how you struggled to put your ship back into working order. We know you'd like to reconnect with your homes, and that directive is written into your primary orders. I suggest you keep looking for information on how to contact the CUF."))
			addCommsReply(_("orders-comms","Back to suggested actions"),moreOrders)
			addCommsReply(_("orders-comms","Back to station communication"),commsStation)
		end)
		addCommsReply(_("orders-comms","Shop for ship upgrades"),function()
			setCommsMessage(_("orders-comms","Different stations around here offer different types and levels of ship upgrades. Keep shopping for upgrades. The upgrades give your ship an edge over your enemies. The farther out you go, the higher the potential level of upgrades. Check your science database. Ship Yard tells you about your ship upgrades and the Stations > Neutral tells you about stations you've talked to in this area."))
			addCommsReply(_("orders-comms","Back to suggested actions"),moreOrders)
			addCommsReply(_("orders-comms","Back to station communication"),commsStation)
		end)
		addCommsReply(_("orders-comms","Proactive Destruction"),function()
			setCommsMessage(_("orders-comms","Most of the destruction visited on us and our neighbors comes from the Exuari. If you were to destroy those Exuari stations, you would be doing a tremendous service for all of us."))
			addCommsReply(_("orders-comms","Where are the Exuari stations?"),function()
				setCommsMessage(_("orders-comms","I can't tell you. The Exuari monitor communications and they send out extra special destructive attacks on stations that divulge their location. However, it's not that hard to track their ships backwards to determine their location."))
				addCommsReply(_("orders-comms","Back to suggested actions"),moreOrders)
				addCommsReply(_("orders-comms","Back to station communication"),commsStation)
			end)
			addCommsReply(_("orders-comms","Back to suggested actions"),moreOrders)
			addCommsReply(_("orders-comms","Back to station communication"),commsStation)
		end)
		addCommsReply(_("orders-comms","Back to station communication"),commsStation)
	end)
end
function commsResources()
	if spew_function_diagnostic then print("top of comms resources") end
	local goodCount = 0
	for good, goodData in pairs(comms_target.comms_data.goods) do
		goodCount = goodCount + 1
	end
	addCommsReply(_("station-comms","Resources (repair crew, coolant, goods)"),function()
		setCommsMessage(_("station-comms","Which of the following are you interested in?"))
		if comms_source:isFriendly(comms_target) then
			getRepairCrewFromStation("friendly")
			getCoolantFromStation("friendly")
		else
			getRepairCrewFromStation("neutral")
			getCoolantFromStation("neutral")
		end
		if goodCount > 0 then
			addCommsReply(_("trade-comms", "Buy, sell, trade"), function()
				local goodsReport = string.format(_("trade-comms", "Station %s:\nGoods or components available for sale: quantity, cost in reputation\n"),comms_target:getCallSign())
				for good, goodData in pairs(comms_target.comms_data.goods) do
					goodsReport = goodsReport .. string.format(_("trade-comms", "     %s: %i, %i\n"),good,goodData["quantity"],goodData["cost"])
				end
				if comms_target.comms_data.buy ~= nil then
					goodsReport = goodsReport .. _("trade-comms", "Goods or components station will buy: price in reputation\n")
					for good, price in pairs(comms_target.comms_data.buy) do
						goodsReport = goodsReport .. string.format(_("trade-comms", "     %s: %i\n"),good,price)
					end
				end
				goodsReport = goodsReport .. string.format(_("trade-comms", "Current cargo aboard %s:\n"),comms_source:getCallSign())
				local cargoHoldEmpty = true
				local player_good_count = 0
				if comms_source.goods ~= nil then
					for good, goodQuantity in pairs(comms_source.goods) do
						player_good_count = player_good_count + 1
						goodsReport = goodsReport .. string.format(_("trade-comms", "     %s: %i\n"),good,goodQuantity)
					end
				end
				if player_good_count < 1 then
					goodsReport = goodsReport .. _("trade-comms", "     Empty\n")
				end
				goodsReport = goodsReport .. string.format(_("trade-comms", "Available Space: %i, Available Reputation: %i\n"),comms_source.cargo,math.floor(comms_source:getReputationPoints()))
				setCommsMessage(goodsReport)
				for good, goodData in pairs(comms_target.comms_data.goods) do
					addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,goodData["cost"]), function()
						if not comms_source:isDocked(comms_target) then 
							setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
							return
						end
						local goodTransactionMessage = string.format(_("trade-comms", "Type: %s, Quantity: %i, Rep: %i"),good,goodData["quantity"],goodData["cost"])
						if comms_source.cargo < 1 then
							goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nInsufficient cargo space for purchase")
						elseif goodData["cost"] > math.floor(comms_source:getReputationPoints()) then
							goodTransactionMessage = goodTransactionMessage .. _("needRep-comms", "\nInsufficient reputation for purchase")
						elseif goodData["quantity"] < 1 then
							goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nInsufficient station inventory")
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
								goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\npurchased")
							else
								goodTransactionMessage = goodTransactionMessage .. _("needRep-comms", "\nInsufficient reputation for purchase")
							end
						end
						setCommsMessage(goodTransactionMessage)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if comms_target.comms_data.buy ~= nil then
					for good, price in pairs(comms_target.comms_data.buy) do
						if comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
							addCommsReply(string.format(_("trade-comms", "Sell one %s for %i reputation"),good,price), function()
								if not comms_source:isDocked(comms_target) then 
									setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
									return
								end
								local goodTransactionMessage = string.format(_("trade-comms", "Type: %s,  Reputation price: %i"),good,price)
								comms_source.goods[good] = comms_source.goods[good] - 1
								comms_source:addReputationPoints(price)
								goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nOne sold")
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
									addCommsReply(string.format(_("trade-comms", "Trade food for %s"),good), function()
										if not comms_source:isDocked(comms_target) then 
											setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
											return
										end
										local goodTransactionMessage = string.format(_("trade-comms", "Type: %s,  Quantity: %i"),good,goodData["quantity"])
										if goodData["quantity"] < 1 then
											goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nInsufficient station inventory")
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
											goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nTraded")
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
									addCommsReply(string.format(_("trade-comms", "Trade medicine for %s"),good), function()
										if not comms_source:isDocked(comms_target) then 
											setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
											return
										end
										local goodTransactionMessage = string.format(_("trade-comms", "Type: %s,  Quantity: %i"),good,goodData["quantity"])
										if goodData["quantity"] < 1 then
											goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nInsufficient station inventory")
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
											goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nTraded")
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
									addCommsReply(string.format(_("trade-comms", "Trade luxury for %s"),good), function()
										if not comms_source:isDocked(comms_target) then 
											setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
											return
										end
										local goodTransactionMessage = string.format(_("trade-comms", "Type: %s,  Quantity: %i"),good,goodData["quantity"])
										if goodData[quantity] < 1 then
											goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nInsufficient station inventory")
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
											goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nTraded")
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
				addCommsReply(_("trade-comms", "Jettison cargo"), function()
					setCommsMessage(string.format(_("trade-comms", "Available space: %i\nWhat would you like to jettison?"),comms_source.cargo))
					for good, good_quantity in pairs(comms_source.goods) do
						if good_quantity > 0 then
							addCommsReply(good, function()
								comms_source.goods[good] = comms_source.goods[good] - 1
								comms_source.cargo = comms_source.cargo + 1
								setCommsMessage(string.format(_("trade-comms", "One %s jettisoned"),good))
								addCommsReply(_("Back"), commsStation)
							end)
						end
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
			addCommsReply(_("explainGoods-comms", "No tutorial covered goods or cargo. Explain"), function()
				setCommsMessage(_("explainGoods-comms", "Different types of cargo or goods may be obtained from stations, freighters or other sources. They go by one word descriptions such as dilithium, optic, warp, etc. Certain mission goals may require a particular type or types of cargo. Each player ship differs in cargo carrying capacity. Goods may be obtained by spending reputation points or by trading other types of cargo (typically food, medicine or luxury)"))
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end)
	if spew_function_diagnostic then print("bottom of comms resources") end
end
function getRepairCrewFromStation(relationship)
	if spew_function_diagnostic then print("top of get repair crew from station") end
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
						if not comms_source:isDocked(comms_target) then 
							setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
							return
						end
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
	if spew_function_diagnostic then print("bottom of get repair crew from station") end
end
function getCoolantFromStation(relationship)
	if spew_function_diagnostic then print("top of get coolant from station") end
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
							if not comms_source:isDocked(comms_target) then 
								setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
								return
							end
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
						setCommsMessage(string.format(_("trade-comms","The coolant preparation facility is having difficulty packaging the coolant for transport. They say they should have it working in about %i seconds"),delay_seconds))
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
	if spew_function_diagnostic then print("bottom of get coolant from station") end
end
function setSecondaryOrders()
	if spew_function_diagnostic then print("top of set secondary orders") end
	secondary_orders = ""
	if spew_function_diagnostic then print("bottom of set secondary orders") end
end
function setOptionalOrders()
	if spew_function_diagnostic then print("top of set optional orders") end
	optional_orders = ""
	if comms_source.transport_mission ~= nil or comms_source.cargo_mission ~= nil then
		optional_orders = _("orders-comms","\nOptional:")
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
	if spew_function_diagnostic then print("bottom of set optional orders") end
end
function isAllowedTo(state)
	if spew_function_diagnostic then print("top of is allowed to") end
    if state == "friend" and comms_source:isFriendly(comms_target) then
        return true
    end
    if state == "neutral" and not comms_source:isEnemy(comms_target) then
        return true
    end
    return false
end
function handleWeaponRestock(weapon)
	if spew_function_diagnostic then print("top of handle weapon restock") end
	if not comms_source:isDocked(comms_target) then 
		setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
		return
	end
    if not isAllowedTo(comms_data.weapons[weapon]) then
        if weapon == "Nuke" then setCommsMessage(_("ammo-comms", "We do not deal in weapons of mass destruction."))
        elseif weapon == "EMP" then setCommsMessage(_("ammo-comms", "We do not deal in weapons of mass disruption."))
        else setCommsMessage(_("ammo-comms", "We do not deal in those weapons.")) end
        return
    end
    local points_per_item = getWeaponCost(weapon)
    local item_amount = math.floor(comms_source:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage(_("ammo-comms", "All nukes are charged and primed for destruction."));
        else
            setCommsMessage(_("ammo-comms", "Sorry, sir, but you are as fully stocked as I can allow."));
        end
        addCommsReply(_("Back"), commsStation)
    else
		if comms_source:getReputationPoints() > points_per_item * item_amount then
			if comms_source:takeReputationPoints(points_per_item * item_amount) then
				comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
				if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
		            setCommsMessage(_("ammo-comms", "You are fully loaded and ready to explode things."))
				else
		            setCommsMessage(_("ammo-comms", "We generously resupplied you with some weapon charges.\nPut them to good use."))
				end
			else
	            setCommsMessage(_("needRep-comms", "Not enough reputation."))
				return
			end
		else
			if comms_source:getReputationPoints() > points_per_item then
				setCommsMessage(_("ammo-comms","You can't afford as much as I'd like to give you"))
				addCommsReply(_("ammo-comms","Get just one"), function()
					if comms_source:takeReputationPoints(points_per_item) then
						comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + 1)
						if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
				            setCommsMessage(_("ammo-comms", "You are fully loaded and ready to explode things."))
						else
				            setCommsMessage(_("ammo-comms", "We generously resupplied you with some weapon charges.\nPut them to good use."))
						end
					else
			            setCommsMessage(_("needRep-comms", "Not enough reputation."))
					end
					return
				end)
			else
	            setCommsMessage(_("needRep-comms", "Not enough reputation."))
				return				
			end
		end
        addCommsReply(_("Back"), commsStation)
    end
	if spew_function_diagnostic then print("bottom of handle weapon restock") end
end
function getWeaponCost(weapon)
	if spew_function_diagnostic then print("top of get weapon cost") end
	local discounts = {
		["Homing"] = {tbl = comms_source.homing_discount, rep = 1},
		["Nuke"] = {tbl = comms_source.nuke_discount, rep = 5},
		["EMP"] = {tbl = comms_source.emp_discount, rep = 5},
		["Mine"] = {tbl = comms_source.mine_discount, rep = 1},
		["HVLI"] = {tbl = comms_source.hvli_discount, rep = 1},
	}
	if discounts[weapon].tbl ~= nil then
		for i,station in ipairs(discounts[weapon].tbl) do
			if station == comms_target then
				return discounts[weapon].rep
			end
		end
	end
	if spew_function_diagnostic then print("bottom (ish) of get weapon cost") end
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function getFriendStatus()
    if comms_source:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
function explainShipUpgrades()
	setCommsMessage(_("dockingServicesStatus-comms","Which ship system upgrade category are you wondering about?"))
	--upgrade_path explained
	addCommsReply(_("dockingServicesStatus-comms","beam"),function()
		setCommsMessage(_("dockingServicesStatus-comms","Beam upgrades refer to the beam weapons systems. They might include additional beam mounts, longer range, faster recharge or cycle times, increased damage, wider beam firing arcs or faster beam turret rotation speed."))
		addCommsReply(_("dockingServicesStatus-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("dockingServicesStatus-comms","missiles"),function()
		setCommsMessage(_("dockingServicesStatus-comms","Missile upgrades refer to aspects of the missile weapons systems. They might include additional tubes, faster tube load times, increased tube size, additional missile types or additional missile storage capacity."))
		addCommsReply(_("dockingServicesStatus-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("dockingServicesStatus-comms","shield"),function()
		setCommsMessage(_("dockingServicesStatus-comms","Shield upgrades refer to the protective energy shields around your ship. They might include increased charge capacity (overall strength) for the front, rear or both shield arcs or the addition of a shield arc."))
		addCommsReply(_("dockingServicesStatus-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("dockingServicesStatus-comms","hull"),function()
		setCommsMessage(_("dockingServicesStatus-comms","Hull upgrades refer to strengthening the ship hull to withstand more damage in the form of armor plating or structural bolstering."))
		addCommsReply(_("dockingServicesStatus-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("dockingServicesStatus-comms","impulse"),function()
		setCommsMessage(_("dockingServicesStatus-comms","Impulse upgrades refer to changes related to the impulse engines. They might include improving the top speed or acceleration (forward, reverse or both), maneuvering speed or combat maneuver (boost, which is moving forward, or strafe, which is sideways motion or both)."))
		addCommsReply(_("dockingServicesStatus-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("dockingServicesStatus-comms","ftl"),function()
		setCommsMessage(_("dockingServicesStatus-comms","FTL (short for faster than light) upgrades refer to warp drive or jump drive enhancements. They might include the addition of an ftl drive, a change in the range of the jump drive or an increase in the top speed of the warp drive"))
		addCommsReply(_("dockingServicesStatus-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("dockingServicesStatus-comms","sensors"),function()
		setCommsMessage(_("dockingServicesStatus-comms","Sensor upgrades refer to the ship's ability to detect other objects. They might include increased long range sensors, increased short range sensors, automated proximity scanners for ships or improved range for automated proximity scanners."))
		addCommsReply(_("dockingServicesStatus-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("Back"), commsStation)
end
function testUpgradeDowngrade()
	if spew_function_diagnostic then print("top of test upgrade downgrade") end
	addCommsReply("TUD",function()
		local p_ship_type = comms_source:getTypeName()
		if upgrade_path[p_ship_type] == nil then
			setCommsMessage(string.format("No upgrade path for %s",p_ship_type))
		else
			local tud_out = "Current upgrade state:"
			for p_u_system, p_u_level in pairs(comms_source.upgrade_path) do
				tud_out = string.format("%s\n  %s level:%s\n    ug:%s\n    dg:%s",tud_out,p_u_system,p_u_level,upgrade_path[p_ship_type][p_u_system][p_u_level].desc,upgrade_path[p_ship_type][p_u_system][p_u_level].downgrade)
			end
			setCommsMessage(tud_out)
			for p_u_system, p_u_level in pairs(comms_source.upgrade_path) do
				local max_sys_level = #upgrade_path[p_ship_type][p_u_system]
				if max_sys_level > p_u_level then
					addCommsReply(string.format("%s: %s",p_u_system,upgrade_path[p_ship_type][p_u_system][p_u_level + 1].desc),function()
						upgradePlayerShip(comms_source,p_u_system)
						setCommsMessage(_("upgrade-comms","Upgrade complete"))
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if p_u_level > 1 then
					addCommsReply(string.format("%s: %s",p_u_system,upgrade_path[p_ship_type][p_u_system][p_u_level - 1].downgrade),function()
						downgradePlayerShip(comms_source,p_u_system)
						setCommsMessage(_("upgrade-comms","Downgrade complete"))
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
		end
		addCommsReply(_("Back"), commsStation)
	end)
	if spew_function_diagnostic then print("bottom of test upgrade downgrade") end
end
function addStationToDatabase(station)
	if spew_function_diagnostic then print("top of add station to database") end
	--	Assumes all player ships will be the same faction
	local player_faction = "CUF"
	local stations_key = _("scienceDB","Stations")
	local stations_db = queryScienceDatabase(stations_key)
	if stations_db == nil then
		stations_db = ScienceDatabase():setName(stations_key)
	end
	local station_db = nil
	local station_key = station:getCallSign()
	local temp_artifact = Artifact():setFaction(player_faction)
	local first_time_entry = false
	if station:isFriendly(temp_artifact) then
		local friendly_key = _("scienceDB","Friendly")
		local friendly_db = queryScienceDatabase(stations_key,friendly_key)
		if friendly_db == nil then
			stations_db:addEntry(friendly_key)
			friendly_db = queryScienceDatabase(stations_key,friendly_key)
			friendly_db:setLongDescription(_("scienceDB","Friendly stations share their short range telemetry with your ship on the Relay and Strategic Map consoles. These are the known friendly stations."))
		end
		station_db = queryScienceDatabase(stations_key,friendly_key,station_key)
		if station_db == nil then
			friendly_db:addEntry(station_key)
			station_db = queryScienceDatabase(stations_key,friendly_key,station_key)
			first_time_entry = true
		end
	elseif not station:isEnemy(temp_artifact) then
		local neutral_key = "Neutral"
		local neutral_db = queryScienceDatabase(stations_key,neutral_key)
		if neutral_db == nil then
			stations_db:addEntry(neutral_key)
			neutral_db = queryScienceDatabase(stations_key,neutral_key)
			neutral_db:setLongDescription(_("scienceDB","Neutral stations don't share their short range telemetry with your ship, but they do allow for docking. These are the known neutral stations."))
		end
		station_db = queryScienceDatabase(stations_key,neutral_key,station_key)
		if station_db == nil then
			neutral_db:addEntry(station_key)
			station_db = queryScienceDatabase(stations_key,neutral_key,station_key)
			first_time_entry = true
		end
	end
	if first_time_entry then
		local out = ""
		if station:getDescription() ~= nil then
			out = station:getDescription()
		end
		if station.comms_data ~= nil then
			if station.comms_data.general ~= nil and station.comms_data.general ~= "" then
				out = string.format(_("scienceDB","%s\n\nGeneral Information: %s"),out,station.comms_data.general)
			end
			if station.comms_data.history ~= nil and station.comms_data.history ~= "" then
				out = string.format(_("scienceDB","%s\n\nHistory: %s"),out,station.comms_data.history)
			end
		end
		if out ~= "" then
			station_db:setLongDescription(out)
		end
		local station_type = station:getTypeName()
		local size_value = ""
		local small_station_key = _("scienceDB","Small Station")
		local medium_station_key = _("scienceDB","Medium Station")
		local large_station_key = _("scienceDB","Large Station")
		local huge_station_key = _("scienceDB","Huge Station")
		if station_type == small_station_key then
			size_value = _("scienceDB","Small")
			local small_db = queryScienceDatabase(stations_key,small_station_key)
			if small_db ~= nil then
				station_db:setImage(small_db:getImage())
			end
			station_db:setModelDataName("space_station_4")
		elseif station_type == medium_station_key then
			size_value = _("scienceDB","Medium")
			local medium_db = queryScienceDatabase(stations_key,medium_station_key)
			if medium_db ~= nil then
				station_db:setImage(medium_db:getImage())
			end
			station_db:setModelDataName("space_station_3")
		elseif station_type == large_station_key then
			size_value = _("scienceDB","Large")
			local large_db = queryScienceDatabase(stations_key,large_station_key)
			if large_db ~= nil then
				station_db:setImage(large_db:getImage())
			end
			station_db:setModelDataName("space_station_2")
		elseif station_type == huge_station_key then
			size_value = _("scienceDB","Huge")
			local huge_db = queryScienceDatabase(stations_key,huge_station_key)
			if huge_db ~= nil then
				station_db:setImage(huge_db:getImage())
			end
			station_db:setModelDataName("space_station_1")
		end
		if size_value ~= "" then
			local size_key = _("scienceDB","Size")
			station_db:setKeyValue(size_key,size_value)
		end
		if station == station_needy_freighter then
			local faction_key = _("scienceDB","Faction")
			station_db:setKeyValue(faction_key,station:getFaction())
			local primary_orbit_key = _("scienceDB","Primary orbit")
			station_db:setKeyValue(primary_orbit_key,string.format(_("scienceDB","Synchronous around moon %s"),needy_moon:getCallSign()))
			local secondary_orbit_key = _("scienceDB","Secondary orbit")
			station_db:setKeyValue(secondary_orbit_key,string.format(_("scienceDB","Moon %s orbits planet %s"),needy_moon:getCallSign(),needy_planet:getCallSign()))
			local tertiary_orbit_key = _("scienceDB","Tertiary orbit")
			station_db:setKeyValue(tertiary_orbit_key,string.format(_("scienceDB","Planet %s orbits star %s"),needy_planet:getCallSign(),needy_star:getCallSign()))
		else
			local location_key = _("scienceDB","Location, Faction")
			station_db:setKeyValue(location_key,string.format("%s, %s",station:getSectorName(),station:getFaction()))
		end
	end
	local dock_service = ""
	local service_count = 0
	if station:getSharesEnergyWithDocked() then
		dock_service = _("scienceDB","share energy")
		service_count = service_count + 1
	end
	if station:getRepairDocked() then
		if dock_service == "" then
			dock_service = _("scienceDB","repair hull")
		else
			dock_service = string.format(_("scienceDB","%s, repair hull"),dock_service)
		end
		service_count = service_count + 1
	end
	if station:getRestocksScanProbes() then
		if dock_service == "" then
			dock_service = _("scienceDB","replenish probes")
		else
			dock_service = string.format(_("scienceDB","%s, replenish probes"),dock_service)
		end
		service_count = service_count + 1
	end
	if service_count > 0 then
		local docking_services_key = _("scienceDB","Docking Services")
		if service_count == 1 then
			docking_services_key = _("scienceDB","Docking Service")
		end
		station_db:setKeyValue(docking_services_key,dock_service)
	end
	if station.comms_data ~= nil then
		if station.comms_data.weapon_available ~= nil then
			if station.comms_data.weapon_cost == nil then
				station.comms_data.weapon_cost = {
					Homing = math.random(1,4),
					HVLI = math.random(1,3),
					Mine = math.random(2,5),
					Nuke = math.random(12,18),
					EMP = math.random(7,13),
				}
			end
			if station.comms_data.reputation_cost_multipliers == nil then
				station.comms_data.reputation_cost_multipliers = {
					friend = 1.0,
					neutral = 3.0,
				}
			end
			local station_missiles = {
				{name = "Homing",	key = _("scienceDB","Restock Homing")},
				{name = "HVLI",		key = _("scienceDB","Restock HVLI")},
				{name = "Mine",		key = _("scienceDB","Restock Mine")},
				{name = "Nuke",		key = _("scienceDB","Restock Nuke")},
				{name = "EMP",		key = _("scienceDB","Restock EMP")},
			}
			for i,sm in ipairs(station_missiles) do
				if station.comms_data.weapon_available[sm.name] then
					if station.comms_data.weapon_cost[sm.name] ~= nil then
						local val = string.format(_("scienceDB","%i reputation each"),math.ceil(station.comms_data.weapon_cost[sm.name] * station.comms_data.reputation_cost_multipliers["friend"]))
						station_db:setKeyValue(sm.key,val)
					end
				end
			end
		end
		local secondary_system_repair = {
			{name = "scan_repair",				key = _("scienceDB","Repair scanners")},
			{name = "combat_maneuver_repair",	key = _("scienceDB","Repair combat maneuver")},
			{name = "hack_repair",				key = _("scienceDB","Repair hacking")},
			{name = "probe_launch_repair",		key = _("scienceDB","Repair probe launch")},
			{name = "tube_slow_down_repair",	key = _("scienceDB","Repair slow tube")},
			{name = "self_destruct_repair",		key = _("scienceDB","Repair scanners")},
		}
		for i,ssr in ipairs(secondary_system_repair) do
			if station.comms_data[ssr.name] then
				if station.comms_data.service_cost[ssr.name] ~= nil then
					local val = string.format(_("scienceDB","%s reputation"),station.comms_data.service_cost[ssr.name])
					station_db:setKeyValue(ssr.key,val)
				end
			end
		end
		if station.comms_data.service_available ~= nil then
			local general_service = {
				{name = "supplydrop",				key = _("scienceDB","Drop supplies")},
				{name = "reinforcements",			key = _("scienceDB","Standard reinforcements")},
				{name = "hornet_reinforcements",	key = _("scienceDB","Hornet reinforcements")},
				{name = "phobos_reinforcements",	key = _("scienceDB","Phobos reinforcements")},
				{name = "amk3_reinforcements",		key = _("scienceDB","Adder3 reinforcements")},
				{name = "amk8_reinforcements",		key = _("scienceDB","Adder8 reinforcements")},
				{name = "shield_overcharge",		key = _("scienceDB","Shield overcharge")},
			}
			for i,gs in ipairs(general_service) do
				if station.comms_data.service_available[gs.name] then
					if station.comms_data.service_cost[gs.name] ~= nil then
						local val = string.format(_("scienceDB","%s reputation"),station.comms_data.service_cost[gs.name])
						station_db:setKeyValue(gs.key,val)
					end
				end
			end
		end
		if station.comms_data.upgrade_path ~= nil then
			local upgrade_service = {
				["beam"] = _("scienceDB","Beam weapons"),
				["missiles"] = _("scienceDB","Misslie systems"),
				["shield"] = _("scienceDB","Shield"),
				["hull"] = _("scienceDB","Hull"),
				["impulse"] = _("scienceDB","Impulse systems"),
				["ftl"] = _("scienceDB","FTL engines"),
				["sensors"] = _("scienceDB","Sensor systems"),
			}
			for template,upgrade in pairs(station.comms_data.upgrade_path) do
				for u_type, u_blob in pairs(upgrade) do
					local u_key = string.format("%s %s",template,upgrade_service[u_type])
					station_db:setKeyValue(u_key,string.format(_("scienceDB","Max upgrade level: %i"),u_blob))
				end
			end
		end
	end
	temp_artifact:destroy()
	if spew_function_diagnostic then print("bottom of add station to database") end
end
------------------------
-- Ship communication --
------------------------
function commsShip()
	if spew_function_diagnostic then print("top of comms ship") end
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	comms_data = comms_target.comms_data
	if comms_data.goods == nil then
		goodsOnShip(comms_target,comms_data)
	end
	if spew_function_diagnostic then print("middle of comms ship") end
	if comms_source.needy_freighter_contact then
		commsNeedyFreighter()
		if spew_function_diagnostic then print("bottom (ish) of comms ship after comms needy freighter") end
		return true
	elseif comms_source.needy_freighter_thanks then
		commsNeedyFreighterThanks()
		if spew_function_diagnostic then print("bottom (ish) of comms ship after comms needy freighter thanks") end
		return true
	else
		if comms_source:isFriendly(comms_target) then
			if spew_function_diagnostic then print("bottom (ish) of comms ship before friendly comms") end
			return friendlyComms(comms_data)
		end
		if comms_source:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentifiedBy(comms_source) then
			if spew_function_diagnostic then print("bottom (ish) of comms ship before enemy comms") end
			return enemyComms(comms_data)
		end
		if spew_function_diagnostic then print("bottom (ish) of comms ship before neutral comms") end
		return neutralComms(comms_data)
	end
end
function goodsOnShip(comms_target,comms_data)
	if spew_function_diagnostic then print("top of goods on ship") end
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
	if spew_function_diagnostic then print("bottom of goods on ship") end
end
function friendlyComms(comms_data)
	if spew_function_diagnostic then print("top of friendly comms") end
	if comms_data.friendlyness < 20 then
		setCommsMessage(_("shipAssist-comms", "What do you want?"));
	else
		setCommsMessage(_("shipAssist-comms", "Sir, how can we assist?"));
	end
	addCommsReply(_("shipAssist-comms", "Defend a waypoint"), function()
		if comms_source:getWaypointCount() == 0 then
			setCommsMessage(_("shipAssist-comms", "No waypoints set. Please set a waypoint first."));
		else
			setCommsMessage(_("shipAssist-comms", "Which waypoint should we defend?"));
			for n=1,comms_source:getWaypointCount() do
				addCommsReply(string.format(_("shipAssist-comms", "Defend WP %d"), n), function()
					comms_target:orderDefendLocation(comms_source:getWaypoint(n))
					setCommsMessage(string.format(_("shipAssist-comms", "We are heading to assist at WP %d."), n));
					addCommsReply(_("Back"), commsShip)
				end)
			end
		end
		addCommsReply(_("Back"), commsShip)
	end)
	if comms_data.friendlyness > 0.2 then
		addCommsReply(_("shipAssist-comms", "Assist me"), function()
			setCommsMessage(_("shipAssist-comms", "Heading toward you to assist."));
			comms_target:orderDefendTarget(comms_source)
			addCommsReply(_("Back"), commsShip)
		end)
	end
	addCommsReply(_("shipAssist-comms", "Report status"), function()
		msg = _("shipAssist-comms","Hull: ") .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
		local shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = msg .. _("shipAssist-comms","Shield: ") .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
		elseif shields == 2 then
			msg = msg .. _("shipAssist-comms","Front Shield: ") .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			msg = msg .. _("shipAssist-comms","Rear Shield: ") .. math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100) .. "%\n"
		else
			for n=0,shields-1 do
				msg = msg .. _("shipAssist-comms","Shield ") .. n .. ": " .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
			end
		end
		local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for i, missile_type in ipairs(missile_types) do
			if comms_target:getWeaponStorageMax(missile_type) > 0 then
				msg = msg .. missile_type .. _("shipAssist-comms"," Missiles: ") .. math.floor(comms_target:getWeaponStorage(missile_type)) .. "/" .. math.floor(comms_target:getWeaponStorageMax(missile_type)) .. "\n"
			end
		end
		local current_order = comms_target:getOrder()
		if current_order == "Dock" then
			local current_dock_target = comms_target:getOrderTarget()
			msg = string.format(_("shipAssist-comms","%sCurrently on course to dock with %s station %s in %s"),msg,current_dock_target:getFaction(),current_dock_target:getCallSign(),current_dock_target:getSectorName())
		end
		setCommsMessage(msg);
		addCommsReply(_("Back"), commsShip)
	end)
	for index, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			addCommsReply(string.format(_("shipAssist-comms", "Dock at %s"), obj:getCallSign()), function()
				setCommsMessage(string.format(_("shipAssist-comms", "Docking at %s."), obj:getCallSign()));
				comms_target:orderDock(obj)
				addCommsReply(_("Back"), commsShip)
			end)
		end
	end
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil or shipType:find("Transport") ~= nil then
		if comms_target:getOrder() == "Dock" then
			local dock_target = comms_target:getOrderTarget()
			if dock_target ~= nil and dock_target:isValid() and not dock_target:isEnemy(comms_source) then
				addCommsReply(_("ship-comms","Please tell me about your destination"),function()
					setCommsMessage(string.format(_("ship-comms","We are going to station %s in sector %s. We'll pick stuff up, drop stuff off, the usual commercial activity. Here, let me send you the data on the station for your science database."),dock_target:getCallSign(),dock_target:getSectorName()))
					addStationToDatabase(dock_target)
					addCommsReply(_("Back"), commsShip)
				end)
			end
		end
		if distance(comms_source, comms_target) < 5000 then
			local goodCount = 0
			if comms_source.goods ~= nil then
				for good, goodQuantity in pairs(comms_source.goods) do
					goodCount = goodCount + 1
				end
			end
			if goodCount > 0 then
				addCommsReply(_("trade-comms", "Jettison cargo"), function()
					setCommsMessage(string.format(_("trade-comms", "Available space: %i\nWhat would you like to jettison?"),comms_source.cargo))
					for good, good_quantity in pairs(comms_source.goods) do
						if good_quantity > 0 then
							addCommsReply(good, function()
								comms_source.goods[good] = comms_source.goods[good] - 1
								comms_source.cargo = comms_source.cargo + 1
								setCommsMessage(string.format(_("trade-comms", "One %s jettisoned"),good))
								addCommsReply("Back", commsShip)
							end)
						end
					end
					addCommsReply(_("Back"), commsShip)
				end)
			end
			local will_trade = false
			local will_sell = false
			local cost_multiplier = 1
			if comms_data.friendlyness > 66 then
				will_sell = true
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					if comms_source.goods ~= nil and comms_source.goods[_("trade-comms","luxury")] ~= nil and comms_source.goods[_("trade-comms","luxury")] > 0 then
						will_trade = true
					end
				end
			elseif comms_data.friendlyness > 33 then
				will_sell = true
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					cost_multiplier = 1
				else
					cost_multiplier = 2
				end
			else	--least friendly
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					will_sell = true
					cost_multiplier = 2
				end
			end
			if will_trade then
				for good, goodData in pairs(comms_data.goods) do
					if goodData.quantity > 0 and good ~= _("trade-comms","luxury") then
						addCommsReply(string.format(_("ship-comms","Trade luxury for %s"),good), function()
							goodData.quantity = goodData.quantity - 1
							if comms_source.goods == nil then
								comms_source.goods = {}
							end
							if comms_source.goods[good] == nil then
								comms_source.goods[good] = 0
							end
							comms_source.goods[good] = comms_source.goods[good] + 1
							comms_source.goods[_("trade-comms","luxury")] = comms_source.goods[_("trade-comms","luxury")] - 1
							setCommsMessage(string.format(_("ship-comms","Traded your luxury for %s from %s"),good,comms_target:getCallSign()))
							addCommsReply(_("Back"), commsShip)
						end)
					end
				end	--freighter goods loop
			end
			if comms_source.cargo > 0 and will_sell then
				for good, goodData in pairs(comms_data.goods) do
					if goodData.quantity > 0 then
						local good_cost = math.floor(goodData.cost*cost_multiplier)
						addCommsReply(string.format(_("ship-comms","Buy one %s for %i reputation"),good,good_cost), function()
							if comms_source:takeReputationPoints(good_cost) then
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
								setCommsMessage(_("ship-comms","Insufficient reputation for purchase"))
							end
							addCommsReply(_("Back"), commsShip)
						end)
					end
				end	--freighter goods loop
			end
		else	--not close enough to sell
			addCommsReply(_("trade-comms","Do you have cargo you might sell?"), function()
				local goodCount = 0
				local cargoMsg = _("trade-comms","We've got ")
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
					cargoMsg = cargoMsg .. _("trade-comms","nothing")
				end
				setCommsMessage(cargoMsg)
				addCommsReply(_("Back"), commsShip)
			end)
		end
	end
	if spew_function_diagnostic then print("bottom (ish) of friendly comms") end
	return true
end
function enemyComms(comms_data)
	if spew_function_diagnostic then print("top of enemy comms") end
	local faction = comms_target:getFaction()
	local tauntable = false
	local amenable = false
	if comms_data.friendlyness >= 33 then	--final: 33
		--taunt logic
		local taunt_option = _("shipEnemy-comms","We will see to your destruction!")
		local taunt_success_reply = _("shipEnemy-comms","Your bloodline will end here!")
		local taunt_failed_reply = _("shipEnemy-comms","Your feeble threats are meaningless.")
		local taunt_threshold = 30		--base chance of being taunted
		local immolation_threshold = 5	--base chance that taunting will enrage to the point of revenge immolation
		if faction == "Kraylor" then
			taunt_threshold = 35
			immolation_threshold = 6
			setCommsMessage(_("shipEnemy-comms","Ktzzzsss.\nYou will DIEEee weaklingsss!"));
			local kraylorTauntChoice = math.random(1,3)
			if kraylorTauntChoice == 1 then
				taunt_option = _("shipEnemy-comms","We will destroy you")
				taunt_success_reply = _("shipEnemy-comms","We think not. It is you who will experience destruction!")
			elseif kraylorTauntChoice == 2 then
				taunt_option = _("shipEnemy-comms","You have no honor")
				taunt_success_reply = _("shipEnemy-comms","Your insult has brought our wrath upon you. Prepare to die.")
				taunt_failed_reply = _("shipEnemy-comms","Your comments about honor have no meaning to us")
			else
				taunt_option = _("shipEnemy-comms","We pity your pathetic race")
				taunt_success_reply = _("shipEnemy-comms","Pathetic? You will regret your disparagement!")
				taunt_failed_reply = _("shipEnemy-comms","We don't care what you think of us")
			end
		elseif faction == "Arlenians" then
			taunt_threshold = 25
			immolation_threshold = 4
			setCommsMessage(_("shipEnemy-comms","We wish you no harm, but will harm you if we must.\nEnd of transmission."));
		elseif faction == "Exuari" then
			taunt_threshold = 40
			immolation_threshold = 7
			setCommsMessage(_("shipEnemy-comms","Stay out of our way, or your death will amuse us extremely!"));
		elseif faction == "Ghosts" then
			taunt_threshold = 20
			immolation_threshold = 3
			setCommsMessage(_("shipEnemy-comms","One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted."));
			taunt_option = _("shipEnemy-comms","EXECUTE: SELFDESTRUCT")
			taunt_success_reply = _("shipEnemy-comms","Rogue command received. Targeting source.")
			taunt_failed_reply = _("shipEnemy-comms","External command ignored.")
		elseif faction == "Ktlitans" then
			setCommsMessage(_("shipEnemy-comms","The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition."));
			taunt_option = _("shipEnemy-comms","<Transmit 'The Itsy-Bitsy Spider' on all wavelengths>")
			taunt_success_reply = _("shipEnemy-comms","We do not need permission to pluck apart such an insignificant threat.")
			taunt_failed_reply = _("shipEnemy-comms","The hive has greater priorities than exterminating pests.")
		elseif faction == "TSN" then
			taunt_threshold = 15
			immolation_threshold = 2
			setCommsMessage(_("shipEnemy-comms","State your business"))
		elseif faction == "USN" then
			taunt_threshold = 15
			immolation_threshold = 2
			setCommsMessage(_("shipEnemy-comms","What do you want? (not that we care)"))
		elseif faction == "CUF" then
			taunt_threshold = 15
			immolation_threshold = 2
			setCommsMessage(_("shipEnemy-comms","Don't waste our time"))
		else
			setCommsMessage(_("shipEnemy-comms","Mind your own business!"));
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
					setCommsMessage(_("shipEnemy-comms","Subspace and time continuum disruption authorized"))
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
		addCommsReply(_("shipEnemy-comms","Stop your actions"),function()
			local amenable_roll = random(1,100)
			if change_enemy_order_diagnostic then print(string.format("   amenable roll:   %.1f",amenable_roll)) end
			if amenable_roll < amenable_chance then
				local current_order = comms_target:getOrder()
				if comms_target.original_order == nil then
					comms_target.original_order = current_order
					comms_target.original_faction = faction
					if current_order == "Fly towards" or current_order == "Defend Location" or current_order == "Fly towards (ignore all)" then
						comms_target.original_target_x, comms_target.original_target_y = comms_target:getOrderTargetLocation()
					end
					if current_order == "Attack" or current_order == "Dock" or current_order == "Defend Target" then
						local original_target = comms_target:getOrderTarget()
						comms_target.original_target = original_target
					end
					table.insert(enemy_reverts,comms_target)
				end
				comms_target.amenability_may_expire = true		--set up conditional in future refactoring
				comms_target:orderIdle()
				comms_target:setFaction("Independent")
				setCommsMessage(_("shipEnemy-comms","Just this once, we'll take your advice"))
			else
				setCommsMessage(_("shipEnemy-comms","No"))
			end
		end)
		comms_data.friendlyness = comms_data.friendlyness - random(0, 10)	--reduce friendlyness after each interaction
		amenable = true
	end
	if spew_function_diagnostic then print("bottom (ish) of enemy comms") end
	if tauntable or amenable then
		return true
	else
		return false
	end
end
function getEnemyHealth(enemy)
	if spew_function_diagnostic then print("top of get enemy health") end
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
	if spew_function_diagnostic then print("bottom (ish) of get enemy health") end
	return enemy_health
end
function revertWait(delta)
	if spew_function_diagnostic then print("top of revert wait") end
	revert_timer = revert_timer - delta
	if revert_timer < 0 then
		revert_timer = delta + revert_timer_interval
		plotRevert = revertCheck
	end
	if spew_function_diagnostic then print("bottom of revert wait") end
end
function revertCheck(delta)
	if spew_function_diagnostic then print("top of revert check") end
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
	if spew_function_diagnostic then print("bottom of revert check") end
end
function checkContinuum(delta)
	if spew_function_diagnostic then print("top of check continuum") end
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
	if spew_function_diagnostic then print("bottom of check continuum") end
end
function resetContinuum(p)
	if spew_function_diagnostic then print("top of reset continuum") end
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
	if spew_function_diagnostic then print("bottom of reset continuum") end
end
function neutralComms(comms_data)
	if spew_function_diagnostic then print("top of neutral comms") end
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil or shipType:find("Transport") ~= nil then
		if comms_target:getOrder() == "Dock" then
			local dock_target = comms_target:getOrderTarget()
			if dock_target ~= nil and dock_target:isValid() and not dock_target:isEnemy(comms_source) then
				addCommsReply(_("ship-comms","Please tell me about your destination"),function()
					setCommsMessage(string.format(_("ship-comms","We are going to station %s in sector %s. We'll pick stuff up, drop stuff off, the usual commercial activity. Here, let me send you the data on the station for your science database."),dock_target:getCallSign(),dock_target:getSectorName()))
					addStationToDatabase(dock_target)
					addCommsReply(_("Back"), commsShip)
				end)
			end
		end
		setCommsMessage(_("ship-comms","Yes?"))
		if comms_target == needy_freighter then
			addCommsReply(string.format("Review %s's request",comms_target:getCallSign()),commsNeedyFreighter)
		end
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
			local will_sell = false
			local cost_multiplier = 1
			if comms_data.friendlyness > 66 then
				will_sell = true
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					cost_multiplier = 1
				else
					cost_multiplier = 2
				end
			elseif comms_data.friendlyness > 33 then
				will_sell = true
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					cost_multiplier = 2
				else
					cost_multiplier = 3
				end
			else	--least friendly
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					will_sell = true
					cost_multiplier = 3
				end
			end
			if comms_source.cargo > 0 and will_sell then
				for good, goodData in pairs(comms_data.goods) do
					if goodData.quantity > 0 then
						local good_cost = math.floor(goodData.cost*cost_multiplier)
						addCommsReply(string.format(_("ship-comms","Buy one %s for %i reputation"),good,good_cost), function()
							if comms_source:takeReputationPoints(good_cost) then
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
								setCommsMessage(_("ship-comms","Insufficient reputation for purchase"))
							end
							addCommsReply(_("Back"), commsShip)
						end)
					end
				end	--freighter goods loop
			end	--player has room for cargo
		end	--close enough to sell
	else	--not a freighter
		if comms_data.friendlyness > 50 then
			setCommsMessage(_("ship-comms","Sorry, we have no time to chat with you.\nWe are busy."));
		else
			setCommsMessage(_("ship-comms","We have nothing for you.\nGood day."));
		end
	end	--end non-freighter communications else branch
	if spew_function_diagnostic then print("bottom (ish) of neutral comms") end
	return true
end	--end neutral communications function
function commsNeedyFreighterThanks()
	if spew_function_diagnostic then print("top of comms needy freighter thanks") end
	comms_source.needy_freighter_thanks = false
	addToRegionalNews("grateful needy freighter",comms_source)
	setCommsMessage(string.format(_("ship-comms","Thanks for the help. I can take it from here. You should visit me at station %s in sector %s when you can."),comms_target.nearest_inner:getCallSign(),comms_target.nearest_inner:getSectorName()))
	addCommsReply(_("ship-comms","You're welcome. Why should we visit?"),function()
		setCommsMessage(_("ship-comms","To show my appreciation, I can give you 20 levels of upgrades for your ship. I'll be retiring soon and I've got all this spare equipment that only I know where it's located and how to use it."))
		addCommsReply(_("ship-comms","Sounds great. We will go right away"),function()
			setCommsMessage(_("ship-comms","You'll have to wait until I get there and you'll have to make sure I arrive safely. You never know about those pesky Exuari."))
			addCommsReply(_("ship-comms","We will be sure you get there safely"),function()
				setCommsMessage(_("ship-comms","Thanks"))
				addCommsReply(_("ship-comms","Back to invitation"),commsNeedyFreighterThanks)
				addCommsReply(_("ship-comms","Back to ship comms"), commsShip)
			end)
			addCommsReply(_("ship-comms","Back to invitation"),commsNeedyFreighterThanks)
			addCommsReply(_("ship-comms","Back to ship comms"), commsShip)
		end)
		addCommsReply(_("ship-comms","Back to invitation"),commsNeedyFreighterThanks)
		addCommsReply(_("ship-comms","Back to ship comms"), commsShip)
	end)
	if spew_function_diagnostic then print("bottom of comms needy freighter thanks") end
end
function commsNeedyFreighter()
	if spew_function_diagnostic then print("top of comms needy freighter") end
	if comms_source.will_help_needy == nil or comms_source.will_help_needy then
		if comms_target.impulse_repaired == nil then
			comms_source.needy_freighter_contact = false
			setCommsMessage(string.format(_("ship-comms","Ahoy %s,\nWe could use some help here in sector %s"),comms_source:getCallSign(),comms_target:getSectorName()))
			addCommsReply(_("ship-comms","What seems to be the trouble?"),function()
				setCommsMessage(_("ship-comms","My engines have failed. I know how to fix them, but I'm the only one aboard and the job requires two sets of hands to complete. Do you have someone to spare to help me fix my engines?"))
				addCommsReply(_("ship-comms","We could send over one of our repair crew"),function()
					comms_source.will_help_needy = true
					addToRegionalNews("needy freighter help",comms_source)
					setCommsMessage(string.format(_("ship-comms","That would be perfect. We can get started on the engines as soon as your repair crew transfers over.\n\nNote: %s must be within 5 units of %s to transfer personnel"),comms_source:getCallSign(),comms_target:getCallSign()))
					addCommsReply(_("ship-comms","What's the hurry?"),function()
						setCommsMessage(_("ship-comms","Well, around this time, the Exuari usually send ships to prey on freighters. I'm usually gone by now, but with my engines down, I'm a sitting duck."))
						addCommsReply(_("ship-comms","We will be there shortly"),function()
							setCommsMessage(_("ship-comms","Thanks"))
						end)
						addCommsReply(_("ship-comms","Back to help request"),commsNeedyFreighter)
						addCommsReply(_("ship-comms","Back to ship comms"), commsShip)
					end)
					addCommsReply(_("ship-comms","Back to help request"),commsNeedyFreighter)
					addCommsReply(_("ship-comms","Back to ship comms"), commsShip)
				end)
				addCommsReply(_("ship-comms","Protocol says we cannot help unknown ships"),function()
					setCommsMessage(string.format(_("ship-comms","I can fix that. My name is Charles Acosta. My ship goes by %s. I'm an Independent captain currently mining asteroids for some extra money. I also work in local shipyards fixing up various types of ships.\n\nYou should know that about this time, there are usually some Exuari that show up to harass me. I'm usually gone by now, but I'm stuck with my engines out. I'd really appreciate some help."),comms_target:getCallSign()))
					addCommsReply(_("ship-comms","Now we know you. We will be there shortly"),function()
						comms_source.will_help_needy = true
						addToRegionalNews("needy freighter help",comms_source)
						setCommsMessage(string.format(_("ship-comms","Thanks.\n\nNote: %s needs to be within 5 units of %s in order to transfer personnel."),comms_source:getCallSign(),comms_target:getCallSign()))
					end)
					addCommsReply(_("ship-comms","Back to help request"),commsNeedyFreighter)
					addCommsReply(_("ship-comms","Back to ship comms"), commsShip)
				end)
				addCommsReply(_("ship-comms","Back to ship comms"), commsShip)
			end)
		elseif comms_source.needy_freighter_contact then
			comms_source.needy_freighter_contact = false
			comms_source.will_help_needy = true
			if station_nearest_inner ~= nil and station_nearest_inner:isValid() then
				if needy_freighter:isDocked(station_nearest_inner) then
					setCommsMessage(string.format(_("ship-comms","Thanks to some help from the CUF, the major damage to my impulse engines has been repaired. Visit %s in sector %s for 20 levels of free ship upgrades in appreciation of the helpful CUF."),station_nearest_inner:getCallSign(),station_nearest_inner:getSectorName()))
				else
					setCommsMessage(string.format(_("ship-comms","Thanks to some help from the CUF, the major damage to my impulse engines has been repaired. I am on my way to %s in sector %s. Once I arrive, feel free to visit and I'll provide 20 levels of free ship upgrades in appreciation of the helpful CUF."),station_nearest_inner:getCallSign(),station_nearest_inner:getSectorName()))
				end
			else
				setCommsMessage(_("ship-comms","Thanks to some help from the CUF, the major damage to my impulse engines has been repaired."))
			end
		else
			setCommsMessage(_("ship-comms","Thanks again for the help."))
		end
	end
	if spew_function_diagnostic then print("bottom of comms needy freighter") end
end
-------------------------
--	Utility functions  --
-------------------------
function stationDamaged(self,instigator)
	if self:getFaction() == "Exuari" then
		if instigator ~= nil and instigator:isValid() then
			if instigator:getFaction() == "CUF" then
				addToRegionalNews(string.format("CUF attack %s",self:getCallSign()),instigator)
			end
		end
	else
		if instigator ~= nil and instigator:getFaction() == "Exuari" then
			addToRegionalNews(string.format("Exuari attack %s",self:getCallSign()))
		end
	end
end
function stationDestroyed(self,instigator)
	if self:getFaction() == "Exuari" then
		if instigator ~= nil and instigator:isValid() then
			if instigator:getFaction() == "CUF" then
				addToRegionalNews(string.format("CUF destroy %s",self:getCallSign()),instigator)
			else
				addToRegionalNews(string.format("%s destroyed",self:getCallSign()))
			end
		end
	else
		if instigator ~= nil then
			if instigator:getFaction() == "Exuari" then
				addToRegionalNews(string.format("Exuari destroy %s",self:getCallSign()))
			else
				addToRegionalNews(string.format("%s destroyed",self:getCallSign()))
			end
		end
	end
end
function tableRemoveRandom(array)
	if spew_function_diagnostic then print("top of table remove random") end
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
	if spew_function_diagnostic then print("bottom (ish) of table remove random") end
    return table.remove(array)
end
function angleFromVectorNorth(p1x,p1y,p2x,p2y)
	if spew_function_diagnostic then print("top of angle from vector north") end
	TWOPI = 6.2831853071795865
	RAD2DEG = 57.2957795130823209
	atan2parm1 = p2x - p1x
	atan2parm2 = p2y - p1y
	theta = math.atan2(atan2parm1, atan2parm2)
	if theta < 0 then
		theta = theta + TWOPI
	end
	if spew_function_diagnostic then print("bottom (ish) of angle from vector north") end
	return (360 - (RAD2DEG * theta)) % 360
end
function vectorFromAngleNorth(angle,distance)
	if spew_function_diagnostic then print("top of vector from angle north") end
--	print("input angle to vectorFromAngleNorth:")
--	print(angle)
	angle = (angle + 270) % 360
	local x, y = vectorFromAngle(angle,distance)
	if spew_function_diagnostic then print("bottom (ish) of vector from angle north") end
	return x, y
end
function availableForComms(p)
	if spew_function_diagnostic then print("top of available for comms") end
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
		return false
	end
	if p:isCommsScriptOpen() then
		return false
	end
	if spew_function_diagnostic then print("bottom (ish) of available for comms") end
	return true
end
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction, enemyStrength, template_pool, shape, spawn_distance, spawn_angle, px, py)
	if spew_function_diagnostic then print("top of spawn enemies") end
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	if enemyStrength == nil then
		enemyStrength = math.max(danger * enemy_power * playerPower(),5)
	end
	print("spawn enemies: enemy strength:",enemyStrength,"player power:",playerPower(),"danger:",danger)
	local original_enemy_strength = enemyStrength
	local enemy_position = 0
	local sp = random(400,900)			--random spacing of spawned group
	if shape == nil then
		shape = "square"
		if random(1,100) < 50 then
			shape = "hexagonal"
		end
	end
	local temp_shape = nil
	local enemyList = {}
	if template_pool == nil then
		template_pool_size = math.random(10,15)
		template_pool = getTemplatePool(enemyStrength)
	end
	if #template_pool < 1 then
		addGMMessage("Empty Template pool: fix excludes or other criteria")
		return enemyList, original_enemy_strength
	end
	while enemyStrength > 0 do
		local selected_template = template_pool[math.random(1,#template_pool)]
		local repeat_max = 0
		if enemyStrength > 4 then
			repeat
				selected_template = template_pool[math.random(1,#template_pool)]
				repeat_max = repeat_max + 1
			until(ship_template[selected_template].strength <= (enemyStrength + 5) or repeat_max > 50)
			if repeat_max > 50 then print("exceeded 50 on repeat max when selecting template") end
		else
			break
		end
		local ship = ship_template[selected_template].create(enemyFaction,selected_template)
		ship:setCallSign(generateCallSign(nil,enemyFaction)):orderRoaming()
		enemy_position = enemy_position + 1
		if shape == "none" or shape == "pyramid" or shape == "ambush" then
			ship:setPosition(xOrigin,yOrigin)
		elseif shape == "formation" then
			if temp_shape == nil then
				temp_shape = "square"
				if random(1,100) < 50 then
					temp_shape = "hexagonal"
				end
			end
			ship:setPosition(xOrigin + formation_delta[temp_shape].x[enemy_position] * sp, yOrigin + formation_delta[temp_shape].y[enemy_position] * sp)
		else
			ship:setPosition(xOrigin + formation_delta[shape].x[enemy_position] * sp, yOrigin + formation_delta[shape].y[enemy_position] * sp)
		end
		ship:setCommsScript(""):setCommsFunction(commsShip)
		table.insert(enemyList, ship)
		enemyStrength = enemyStrength - ship_template[selected_template].strength
	end
	if shape == "formation" and #enemyList <= 17 then
		local slowest_ship_speed = 500
		local slowest_ship = nil
		local slowest_ship_index = 0
		for i,ship in ipairs(enemyList) do
			if ship:getImpulseMaxSpeed() < slowest_ship_speed then
				slowest_ship_speed = ship:getImpulseMaxSpeed()
				slowest_ship = ship
				slowest_ship_index = i
			end
		end
		local leader_ship = slowest_ship
		
		local fleet_prefix = generateCallSignPrefix(1)
		leader_ship:setPosition(xOrigin,yOrigin)
		if px == nil then
			px = center_x
			py = center_y
		end
		if spawn_distance == nil then
			spawn_distance = 1000
		end
		local flight_angle = angleFromVectorNorth(px,py,xOrigin,yOrigin)
		leader_ship:setHeading(flight_angle):setCallSign(generateCallSign(fleet_prefix,enemyFaction))
		leader_ship.formation_ships = {}
		local formation_shape = ""
		if #enemyList <= 3 then
			formation_shape = fly_formation_3[math.random(1,#fly_formation_3)]
		elseif #enemyList <= 5 then
			formation_shape = fly_formation_5[math.random(1,#fly_formation_5)]
		elseif #enemyList <= 7 then
			formation_shape = fly_formation_7[math.random(1,#fly_formation_7)]
		elseif #enemyList <= 9 then
			formation_shape = fly_formation_9[math.random(1,#fly_formation_9)]
		elseif #enemyList <= 13 then
			formation_shape = fly_formation_13[math.random(1,#fly_formation_13)]
		elseif #enemyList <= 17 then
			formation_shape = fly_formation_17[math.random(1,#fly_formation_17)]
		end
		local enemy_list_index = 1
		for i, form in ipairs(fly_formation[formation_shape]) do
			if enemyList[enemy_list_index] ~= leader_ship then
				if enemy_list_index <= #enemyList then
					local ship = enemyList[enemy_list_index]
					local form_x, form_y = vectorFromAngleNorth(flight_angle + form.angle, form.dist * spawn_distance)
					local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist * spawn_distance)
					ship:setPosition(xOrigin + form_x, yOrigin + form_y):setHeading(flight_angle):orderFlyFormation(leader_ship,form_prime_x,form_prime_y)
					ship:setCallSign(generateCallSign(fleet_prefix,enemyFaction))
					table.insert(leader_ship.formation_ships,ship)
				end
			end
			enemy_list_index = enemy_list_index + 1
		end
		leader_ship:orderFlyTowards(px,py)
		table.insert(secondary_order_list,leader_ship)
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
	if spew_function_diagnostic then print("bottom (ish) of spawn enemies") end
	return enemyList, original_enemy_strength
end
function playerPower()
--evaluate the players for enemy strength and size spawning purposes
	local player_ship_score = 0
	for i,p in ipairs(getActivePlayerShips()) do
		if p:isValid() then
			if p.shipScore == nil then
				p.shipScore = 24
			end
			player_ship_score = player_ship_score + p.shipScore
		end
	end
	return player_ship_score
end
function getTemplatePool(max_strength)
	if spew_function_diagnostic then print("top of get template pool") end
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
	if spew_function_diagnostic then print("bottom (ish) of get template pool") end
	return template_pool
end
function getDuration()
	if spew_function_diagnostic then print("top of get duration") end
	local duration = getScenarioTime()
	local duration_string = math.floor(duration)
	if duration > 60 then
		local minutes = math.floor(duration / 60)
		local seconds = math.floor(duration % 60)
		if minutes > 1 then
			if minutes > 60 then
				local hours = math.floor(minutes / 60)
				minutes = math.floor(minutes % 60)
				if hours > 1 then
					if minutes > 1 then
						if seconds > 1 then
							duration_string = string.format(_("msgMainscreen","%s hours, %s minutes and %s seconds"),hours,minutes,seconds)
						else
							duration_string = string.format(_("msgMainscreen","%s hours, %s minutes and %s second"),hours,minutes,seconds)
						end
					else
						if seconds > 1 then
							duration_string = string.format(_("msgMainscreen","%s hours, %s minute and %s seconds"),hours,minutes,seconds)
						else
							duration_string = string.format(_("msgMainscreen","%s hours, %s minute and %s second"),hours,minutes,seconds)
						end
					end
				else
					if minutes > 1 then
						if seconds > 1 then
							duration_string = string.format(_("msgMainscreen","%s hour, %s minutes and %s seconds"),hours,minutes,seconds)
						else
							duration_string = string.format(_("msgMainscreen","%s hour, %s minutes and %s second"),hours,minutes,seconds)
						end
					else
						if seconds > 1 then
							duration_string = string.format(_("msgMainscreen","%s hour, %s minute and %s seconds"),hours,minutes,seconds)
						else
							duration_string = string.format(_("msgMainscreen","%s hour, %s minute and %s second"),hours,minutes,seconds)									
						end
					end
				end
			else
				if seconds > 1 then
					duration_string = string.format(_("msgMainscreen","%s minutes and %s seconds"),minutes,seconds)
				else
					duration_string = string.format(_("msgMainscreen","%s minutes and %s second"),minutes,seconds)
				end
			end
		else
			duration_string = string.format(_("msgMainscreen","%s minute and %s seconds"),minutes,seconds)
		end
	else
		duration_string = string.format(_("msgMainscreen","%s seconds"),duration_string)
	end
	if spew_function_diagnostic then print("bottom (ish) of get duration") end
	return duration_string
end
function addToRegionalNews(desc,player)
	if spew_function_diagnostic then print("top of add to regional news") end
	local episode_number = math.floor(getScenarioTime() / 600) + 1
	if regional_news_episodes == nil then
		regional_news_episodes = {}
	end
	local current_episode = nil
	if #regional_news_episodes > 0 then
		for i,episode in ipairs(regional_news_episodes) do
			if episode.number == episode_number then
				current_episode = episode
			end
		end
	end
	if current_episode == nil then
		current_episode = {number = episode_number, entries = {}}
		table.insert(regional_news_episodes,current_episode)
		local station_promoters = {}
		for i,station in ipairs(station_list) do
			if station ~= nil and station:isValid() and station:getFaction() ~= "Exuari" then
				table.insert(station_promoters,station)
			end
		end
		local station_promoter = station_promoters[math.random(1,#station_promoters)]
		if station_promoter:getFaction() == "Ghosts" then
			table.insert(current_episode.entries,{short_desc = "promotion", long_desc = string.format(_("news-comms","Regional News Episode %s is sponsored by station %s in sector %s where you can get all of your electronic subsystems repaired at a fair price."),episode_number,station_promoter:getCallSign(),station_promoter:getSectorName())})
		else
			if station_promoter.comms_data.upgrade_path == nil then
				table.insert(current_episode.entries,{short_desc = "promotion", long_desc = string.format(_("news-comms","Regional News Episode %s is sponsored by station %s in sector %s where you can get the best tasting BBQ in the region."),episode_number,station_promoter:getCallSign(),station_promoter:getSectorName())})
			else
				local served_templates = ""
				for template, path in pairs(station_promoter.comms_data.upgrade_path) do
					local upgrade_systems = ""
					for u_type, u_blob in pairs(path) do
						if upgrade_systems == "" then
							upgrade_systems = u_type
						else
							upgrade_systems = string.format("%s, %s",upgrade_systems,u_type)
						end
					end
					if served_templates == "" then
						served_templates = string.format("%s (%s)",template,upgrade_systems)
					else
						served_templates = string.format("%s, %s (%s)",served_templates,template,upgrade_systems)
					end
				end
				table.insert(current_episode.entries,{short_desc = "promotion", long_desc = string.format(_("news-comms","Regional News Episode %s is sponsored by station %s in sector %s where you can get a wide range of services including ship system upgrades for %s."),episode_number,station_promoter:getCallSign(),station_promoter:getSectorName(),served_templates)})
			end
		end
	end
	local described_entry = false
	for i,entry in ipairs(current_episode.entries) do
		if entry.short_desc == desc then
			described_entry = true
			break
		end
	end
	if not described_entry then
		local player_name = _("news-comms","the CUF")
		if player ~= nil and player:isValid() then
			player_name = player:getCallSign()
		end
		local free_upgrade_station_name = _("news-comms","(station now destroyed)")
		if station_nearest_inner ~= nil and station_nearest_inner:isValid() then
			free_upgrade_station_name = string.format(_("news-comms","%s in sector %s"),station_nearest_inner:getCallSign(),station_nearest_inner:getSectorName())
		end
		local news_descriptions = {
			["needy freighter help"] = string.format(_("news-comms","Charles Acosta reached out to %s for help repairing his impulse engines."),player_name),
			["grateful needy freighter"] = string.format(_("news-comms","A grateful Charles Acosta invites %s to station %s."),player_name,free_upgrade_station_name),
		}
		for i,station_name in ipairs(victim_station_names) do
			news_descriptions[string.format("Exuari attack %s",station_name)] = string.format(_("news-comms","The Exuari attack station %s."),station_name)
			news_descriptions[string.format("Exuari destroy %s",station_name)] = string.format(_("news-comms","The Exuari have destroyed station %s."),station_name)
			news_descriptions[string.format("%s destroyed",station_name)] = string.format(_("news-comms","Station %s has been destroyed."),station_name)
		end
		for i,station_name in ipairs(exuari_station_names) do
			news_descriptions[string.format("CUF attack %s",station_name)] = string.format(_("news-comms","Exuari station %s is attacked by %s! The region hopes that %s gets what it deserves."),station_name,player_name,station_name)
			news_descriptions[string.format("CUF destroy %s",station_name)] = string.format(_("news-comms","The Exuari station %s has been destroyed by %s! The region rejoices."),station_name,player_name)
			news_descriptions[string.format("%s destroyed",station_name)] = string.format(_("news-comms","The Exuari station %s has been destroyed! The region rejoices."),station_name)
		end
--		regional_news_episodes[episode][desc] = {long_desc = news_descriptions[desc], time_stamp = getScenarioTime()}
		table.insert(current_episode.entries,{short_desc = desc, long_desc = news_descriptions[desc], time_stamp = getScenarioTime()})
	end
	if spew_function_diagnostic then print("bottom of add to regional news") end
end
function colonTime(time)
	if time > 60 then
		local minutes = time / 60
		if minutes > 60 then
			local hours = math.floor(time / 3600)
			local minutes = math.floor((time - (hours * 3600)) / 60)
			local seconds = math.floor(time - (hours * 3600) - (minutes * 60))
			return string.format("%s:%02d:%02d",hours,minutes,seconds)
		end
		minutes = math.floor(time / 60)
		local seconds = math.floor(time - (minutes * 60))
		return string.format("%s:%02d",minutes,seconds)
	end
	return math.floor(time)
end
--	Transport selection and direction functions
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
------------------------
--	Update functions  --
------------------------
function updateInner(delta)
	if spew_function_diagnostic then print("top of update inner") end
	if delta == 0 then
		--game paused
		for pidx, p in ipairs(getActivePlayerShips()) do
			if p.pidx == nil then
				p.pidx = pidx
				setPlayers(p)
			end
		end
		return
	end
	if not isPerSystemDamageUsed() then
		reason = _("msgMainscreen","Scenario needs the 'Per-system damage' option under 'Extra settings'")
		globalMessage(reason)
		setBanner(reason)
		victory("Exuari")
	end
	for pidx, p in ipairs(getActivePlayerShips()) do
		if p.pidx == nil then
			p.pidx = pidx
			setPlayers(p)
		end
		if p.needy_freighter_contact == nil then
			if availableForComms(p) then
				p.needy_freighter_contact = true
				p:addToShipLog(string.format(_("goal-shipLog","We intersected an unknown anomaly in space. It violently transported us to an unexplored section of our galaxy. It may have done more than just damage %s. Despite repairing our communications, along with many other systems, we have not been able to contact any CUF station or ship. %s is largely in working order, though many of her capabilities have been curtailed. We may be able to enhance her further. We have identified neutral factions in this region. We might improve %s at these neutral faction stations. Our primary mission is to survive and to restore contact with the Celestial Unified Fleet."),p:getCallSign(),p:getCallSign(),p:getCallSign()),"Green")
				needy_freighter:openCommsTo(p)
			end
		end
		checkHelpNeedyFreighter(p)
		updatePlayerTubeSizeBanner(p)
		updatePlayerIDBanner(p)
		updatePlayerRegionalNews(p)
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
				if p.instant_probes:isValid() then
					if p:isDocked(p.instant_probes) then
						p:setScanProbeCount(p:getMaxScanProbeCount())
					end
				else
					p.instant_probes[i] = p.instant_probes[#p.instant_probes]
					p.p.instant_probes[#p.instant_probes] = nil
				end
			else
				p.instant_probes = nil
			end
		end
	end
	checkForSecondaryOrders()
	plotTriggerExuariWave()
	maintenancePlot()
    if station_needy_freighter ~= nil and station_needy_freighter:isValid() then
		local sx, sy = vectorFromAngleNorth(station_needy_freighter.moon_angle,station_needy_freighter.moon_distance)
		local mx, my = needy_moon:getPosition()
		station_needy_freighter:setPosition(mx + sx, my + sy)
	end
	if spew_function_diagnostic then print("bottom of update inner") end
end

function needyFreighterAttackers()
	if spew_function_diagnostic then print("top of needy freighter attackers") end
	if #needy_freighter_attackers > 0 then
		for i,ship in ipairs(needy_freighter_attackers) do
			if ship == nil or not ship:isValid() then
				needy_freighter_attackers[i] = needy_freighter_attackers[#needy_freighter_attackers]
				needy_freighter_attackers[#needy_freighter_attackers] = nil
				break
			end
		end
	else
		plotTriggerExuariWave = setPlayerAttackers
	end
	if spew_function_diagnostic then print("bottom of needy freighter attackers") end
end
function setPlayerAttackers()
	if spew_function_diagnostic then print("top of set player attackers") end
	if #exuari_player_attackers < 1 then
		local source_stations = {}
		if #nearby_enemy_stations > 0 then
			for i,station in ipairs(nearby_enemy_stations) do
		 		if station ~= nil and station:isValid() then
		 			table.insert(source_stations,station)
		 		else
		 			nearby_enemy_stations[i] = nearby_enemy_stations[#nearby_enemy_stations]
		 			nearby_enemy_stations[#nearby_enemy_stations] = nil
		 			break
		 		end
		 	end
		end
		if #source_stations > 0 then
			source_station = source_stations[math.random(1,#source_stations)]
			local players = getActivePlayerShips()
			if #players > 0 then
				local spawn_x, spawn_y = source_station:getPosition()
				local vx, vy = players[math.random(1,#players)]:getPosition()
				local fleet = spawnEnemies(spawn_x, spawn_y, current_danger, "Exuari", nil, no_ftl_template_pool, "formation", 800, nil, vx, vy)
				for i,ship in ipairs(fleet) do
					table.insert(exuari_player_attackers,ship)
				end
				plotTriggerExuariWave = checkPlayerAttackers
			end
		end
	end
	if spew_function_diagnostic then print("bottom of set player attackers") end
end
function checkPlayerAttackers()
	if spew_function_diagnostic then print("top of check player attackers") end
	if #exuari_player_attackers > 0 then
		local clean_list = true
		for i, ship in ipairs(exuari_player_attackers) do
			if ship == nil or not ship:isValid() then
				exuari_player_attackers[i] = exuari_player_attackers[#exuari_player_attackers]
				exuari_player_attackers[#exuari_player_attackers] = nil
				clean_list = false
				break
			end
		end
		if clean_list then
			local exuari_player_attackers_power = 0
			for i, ship in ipairs(exuari_player_attackers) do
				if ship ~= nil and ship:isValid() then
					exuari_player_attackers_power = exuari_player_attackers_power + ship_template[ship:getTypeName()].strength
				end
			end
			if playerPower() > (exuari_player_attackers_power/3) then
				exuari_player_attackers = {}
				plotTriggerExuariWave = sprayForth
			end
		end
	end
	if spew_function_diagnostic then print("bottom of check player attackers") end
end
function sprayForth()
	if spew_function_diagnostic then print("top of spray forth") end
	if spray_forth_diagnostic then print("top of spray forth") end
	local clean_list = true
	if #nearby_enemy_stations > 0 then
		if spray_forth_diagnostic then print("At least one Exuari station exists") end
		repeat
			clean_list = true
			for i,station in ipairs(nearby_enemy_stations) do
				if station == nil or not station:isValid() then
					nearby_enemy_stations[i] = nearby_enemy_stations[#nearby_enemy_stations]
					nearby_enemy_stations[#nearby_enemy_stations] = nil
					clean_list = false
					break
				end
			end
		until(clean_list)
	end
	if #station_list > 0 then
		if spray_forth_diagnostic then print("At least one station exists") end
		repeat
			clean_list = true
			for i,station in ipairs(station_list) do
				if station == nil or not station:isValid() then
					station_list[i] = station_list[#station_list]
					station_list[#station_list] = nil
					clean_list = false
					break
				end
			end
		until(clean_list)
	end
	if #exuari_spray > 0 then
		--check timer and empty percentage
		if spray_forth_diagnostic then print("At least one Exuari attacker exists. current time:",getScenarioTime(),"spray timer:",exuari_spray_timer) end
		if getScenarioTime() > exuari_spray_timer then
			exuari_spray = {}
			if spray_forth_diagnostic then print("clear exuari spray array because it is time") end
		else
			local exuari_strength = 0
			clean_list = true
			for i,ship in ipairs(exuari_spray) do
				if ship ~= nil and ship:isValid() then
					exuari_strength = exuari_strength + ship_template[ship:getTypeName()].strength
				else
					exuari_spray[i] = exuari_spray[#exuari_spray]
					exuari_spray[#exuari_spray] = nil
					clean_list = false
					break
				end
			end
			if spray_forth_diagnostic then print(string.format("totaled exuari strength: %s, clean: %s",exuari_strength,clean_list)) end
			if clean_list then
				local pp = playerPower()/3
--				print("player power divided by 3:",pp)
				if exuari_strength < pp then
					exuari_spray = {}
					if spray_forth_diagnostic then print("clear exuari spray array because exuari strength is less than player power divided by 3") end
				end
			end
		end
	else
		if spray_forth_diagnostic then print("No Exuari attacker exists") end
		exuari_spray_timer = getScenarioTime() + 360
		current_danger = current_danger * random(1.03,1.1)
		local source_stations = {}
		if #nearby_enemy_stations > 0 then
			for i,station in ipairs(nearby_enemy_stations) do
		 		if station ~= nil and station:isValid() then
		 			table.insert(source_stations,station)
		 		end
		 	end
		end
		if #source_stations > 0 then
			if spray_forth_diagnostic then print("At least one Exuar station exists from which to launch an attack") end
			source_station = source_stations[math.random(1,#source_stations)]
			local spawn_x, spawn_y = source_station:getPosition()
			local attack_types = {"formation","blob","chase"}
			local attack_targets = {"player","neighbor","roaming"}
			local attack_type = attack_types[math.random(1,#attack_types)]
			local attack_target = attack_targets[math.random(1,#attack_targets)]
			local attack_victim_list = nil
			if spray_forth_diagnostic then print("attack target:",attack_target,"attack type:",attack_type) end
			if attack_target == "player" then
				attack_victim_list = getActivePlayerShips()
				if spray_forth_diagnostic then print("got active player ships list") end
			elseif attack_target == "neighbor" then
				local victim_stations = {}
				for i,station in ipairs(station_list) do
					if station:isEnemy(source_station) then
						table.insert(victim_stations,station)
					end
				end
				attack_victim_list = victim_stations
				if spray_forth_diagnostic then print("got victim station list") end
			elseif attack_target == "roaming" then
				local fleet = nil
				if attack_type == "formation" then
					fleet = spawnEnemies(spawn_x, spawn_y, current_danger, "Exuari", nil, no_ftl_template_pool, "formation", random(800,1300), nil, center_x, center_y)
					if spray_forth_diagnostic then print(string.format("spawned formation of %i ships",#fleet)) end
					local leader = nil
					for i,ship in ipairs(fleet) do
						if ship:getOrder() == "Fly towards" then
							ship:orderRoaming()
							leader = ship
							break
						end
					end
					if spray_forth_diagnostic then print("reprogrammed leader to roam") end
					for i,ship in ipairs(secondary_order_list) do
						if ship == leader then
							secondary_order_list[i] = secondary_order_list[#secondary_order_list]
							secondary_order_list[#secondary_order_list] = nil
							break
						end
					end
					if spray_forth_diagnostic then print("removed leader from secondary order list") end
				elseif attack_type == "blob" then
					fleet = spawnEnemies(spawn_x, spawn_y, current_danger, "Exuari")
					if spray_forth_diagnostic then print(string.format("spawned blob of %i ships",#fleet)) end
				elseif attack_type == "chase" then
					fleet = spawnEnemies(spawn_x, spawn_y, current_danger, "Exuari", nil, ftl_template_pool)
					if spray_forth_diagnostic then print(string.format("spawned chase of %i ships",#fleet)) end
				end
				for i,ship in ipairs(fleet) do
					table.insert(exuari_spray,ship)
				end
				if spray_forth_diagnostic then print("added fleet to exuari spray list") end
			end
			if attack_target == "player" or attack_target == "neighbor" then
				if spray_forth_diagnostic then print("attach target is player or neighbor") end
				if #attack_victim_list > 0 then
					if spray_forth_diagnostic then print("at least one victim exists") end
					attack_victim = attack_victim_list[math.random(1,#attack_victim_list)]
					if spray_forth_diagnostic then print("selected victim:",attack_victim:getCallSign()) end
					local vx, vy = attack_victim:getPosition()
					local fleet = nil
					if attack_type == "formation" then
						fleet = spawnEnemies(spawn_x, spawn_y, current_danger, "Exuari", nil, no_ftl_template_pool, "formation", random(800,1300), nil, vx, vy)
						if spray_forth_diagnostic then print(string.format("spawned formation of %i ships on %s",#fleet,attack_target)) end
					elseif attack_type == "blob" then
						fleet = spawnEnemies(spawn_x, spawn_y, current_danger, "Exuari")
						if spray_forth_diagnostic then print(string.format("spawned blob of %i ships on %s",#fleet,attack_target)) end
					elseif attack_type == "chase" then
						fleet = spawnEnemies(spawn_x, spawn_y, current_danger, "Exuari", nil, ftl_template_pool)
						if spray_forth_diagnostic then print(string.format("spawned chase of %i ships on %s",#fleet,attack_target)) end
					end
					if attack_type == "blob" or attack_type == "chase" then
						if random(1,100) < 50 then
							for i,ship in ipairs(fleet) do
								ship:orderAttack(attack_victim)
								table.insert(secondary_order_list,ship)
							end
							if spray_forth_diagnostic then print(string.format("programmed %s ships to attack %s",attack_target,attack_victim:getCallSign())) end
						else
							for i,ship in ipairs(fleet) do
								ship:orderFlyTowards(vx,vy)
								table.insert(secondary_order_list,ship)
							end
							if spray_forth_diagnostic then print(string.format("programmed %s ships to fly towards %s and added them to secondary order list",attack_target,attack_victim:getCallSign())) end
						end
					end
					for i,ship in ipairs(fleet) do
						table.insert(exuari_spray,ship)
					end
					if spray_forth_diagnostic then print("added ships to exuari spray list") end
				end
			end
		else
			plotTriggerExuariWave = afterNearbyExuariDestroyed
			print("nearby exuari stations destroyed")
		end
	end
	if nearby_enemy_stations ~= nil and #nearby_enemy_stations < 1 then
		plotTriggerExuariWave = afterNearbyExuariDestroyed
		print("nearby exuari stations destroyed")
	end
	if spew_function_diagnostic then print("bottom of spray forth") end
	if spray_forth_diagnostic then print("bottom of spray forth") end
end
function afterNearbyExuariDestroyed()
	if spew_function_diagnostic then print("top of after nearby exuari destroyed") end
	--end of short mission, add more here if desired
	local duration_string = getDuration()
	globalMessage(string.format(_("msgMainscreen","The persnickety Exuari stations have been destroyed. Mission duration: %s"),duration_string))
	victory("CUF")
	if spew_function_diagnostic then print("bottom of after nearby exuari destroyed") end
end
function checkForSecondaryOrders()
	if spew_function_diagnostic then print("top of check for secondary orders") end
	if #secondary_order_list > 0 then
		for i,ship in ipairs(secondary_order_list) do
			if ship ~= nil and ship:isValid() then
				if ship:getOrder() == "Defend Location" then
					ship:orderRoaming()
					secondary_order_list[i] = secondary_order_list[#secondary_order_list]
					secondary_order_list[#secondary_order_list] = nil
					break
				elseif ship:getOrder() == "Attack" then
					local target = ship:getOrderTarget()
					if target == nil or not target:isValid() then
						ship:orderRoaming()
						secondary_order_list[i] = secondary_order_list[#secondary_order_list]
						secondary_order_list[#secondary_order_list] = nil
						break
					end
				end
			else
				secondary_order_list[i] = secondary_order_list[#secondary_order_list]
				secondary_order_list[#secondary_order_list] = nil
				break
			end
		end
	end
	if spew_function_diagnostic then print("bottom of check for secondary orders") end
end
--	Maintenance functions
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
						if station:areEnemiesInRange(10000) then
							station.defense_fleet_timer = nil
							local df_x, df_y = station:getPosition()
							local station_faction = station:getFaction()
							local fleet = spawnEnemies(df_x, df_y, 1, station_faction)
							for _, ship in ipairs(fleet) do
								ship:orderDefendTarget(station)
								ship:setCallSign(generateCallSign(nil,ship:getFaction()))
							end
							station.defense_fleet = fleet
						else
							station.defense_fleet_timer = getScenarioTime() + 30
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
	maintenancePlot = transportCommerceMaintenance
end
function transportCommerceMaintenance(delta)
	if #transport_list > 0 then
		local s_time = getScenarioTime()
		for transport_index, transport in ipairs(transport_list) do
			if transport ~= nil and transport:isValid() then
				local temp_faction = transport:getFaction()
				local docked_with = transport:getDockedWith()
				local transport_target = nil
				if docked_with ~= nil then
					if transport.undock_timer == nil then
						transport.undock_timer = s_time + random(10,25)
					elseif transport.undock_timer < s_time then
						transport.undock_timer = nil
						transport_target = pickTransportTarget(transport)
						if transport_target ~= nil then
							transport:orderDock(transport_target)
						end
					end
				else
					if string.find("Dock",transport:getOrder()) then
						transport_target = transport:getOrderTarget()
						if transport_target == nil or not transport_target:isValid() then
							transport_target = pickTransportTarget(transport)
							if transport_target ~= nil then
								transport:orderDock(transport_target)
							end
						end
					else
						transport_target = pickTransportTarget(transport)
						if transport_target ~= nil then
							transport:orderDock(transport_target)
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
	if transport_spawn_timer == nil then
		transport_spawn_timer = getScenarioTime() + random(30,40)
	end
	local clean_list = true
	for i,station in ipairs(station_list) do
		if station == nil or not station:isValid() then
			station_list[i] = station_list[#station_list]
			station_list[#station_list] = nil
			clean_list = false
			break
		end
	end
	if getScenarioTime() > transport_spawn_timer and clean_list and #transport_list < #station_list then
		transport_spawn_timer = nil
		if transport_spawn_stations == nil then
			transport_spawn_stations = {}
			for i,station in ipairs(station_list) do
				table.insert(transport_spawn_stations,station)
			end
		end
		local function spawnTransport(selected_station)
			local station_x, station_y = selected_station:getPosition()
			local transport = randomTransportType()
			transport:setFaction(selected_station:getFaction()):setCallSign(getFactionPrefix(selected_station:getFaction()))
			local start_x, start_y = vectorFromAngle(random(0,360),random(40000,100000))
			transport:setPosition(station_x + start_x,station_y + start_y)
			transport:orderDock(selected_station)
			table.insert(transport_list,transport)
		end
		local selected_station = tableRemoveRandom(transport_spawn_stations)
		if selected_station ~= nil and selected_station:isValid() then
			spawnTransport(selected_station)
		else
			if #transport_spawn_stations == 0 and #transport_list < #station_list then
				local unmatched_stations = {}
				for i,station in ipairs(station_list) do
					table.insert(unmatched_stations,station)
				end
				for i,transport in ipairs(transport_list) do
					for j,station in ipairs(unmatched_stations) do
						if transport:getFaction() == station:getFaction() then
							unmatched_stations[j] = unmatched_stations[#unmatched_stations]
							unmatched_stations[#unmatched_stations] = nil
							break
						end
					end
				end
				if #unmatched_stations > 0 then
					selected_station = tableRemoveRandom(unmatched_stations)
					if selected_station ~= nil and selected_station:isValid() then
						spawnTransport(selected_station)
					end
				end
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
--	Player update functions
function updatePlayerRegionalNews(p)
	if regional_news_episodes ~= nil and #regional_news_episodes > 0 then
		if p.regional_news_buttons_established == nil then
			p.show_regional_news_rel = "show_regional_news_rel"
			p:addCustomButton("Relay",p.show_regional_news_rel,_("news-buttonRelay","+Regional News"),function()
				string.format("")
				showReginalNews(p)
			end,500)
			p.show_regional_news_ops = "show_regional_news_ops"
			p:addCustomButton("Operations",p.show_regional_news_ops,_("news-buttonOperations","+Regional News"),function()
				string.format("")
				showReginalNews(p)
			end,500)
			p.regional_news_buttons_established = true
		end
	end
end
function regionalNewsEpisodeToLog(p,episode)
	for i,entry in ipairs(episode.entries) do
		if entry.short_desc == "promotion" then
			p:addToShipLog(entry.long_desc,"Yellow")
		else
			p:addToShipLog(string.format("[%s] %s",colonTime(entry.time_stamp),entry.long_desc),"Green")
		end
	end
end
function showReginalNews(p)
	p:removeCustom(p.show_regional_news_rel)
	p:removeCustom(p.show_regional_news_ops)
	p.hide_regional_news_rel = "hide_regional_news_rel"
	p:addCustomButton("Relay",p.hide_regional_news_rel,_("news-buttonRelay","-Regional News"),function()
		string.format("")
		hideRegionalNews(p)
	end,500)
	p.hide_regional_news_ops = "hide_regional_news_ops"
	p:addCustomButton("Operations",p.hide_regional_news_ops,_("news-buttonOperations","-Regional News"),function()
		string.format("")
		hideRegionalNews(p)
	end,500)
	for i,episode in ipairs(regional_news_episodes) do
		local episode_number = episode.number
		local episode_button = string.format("episode_%i_button_rel",episode_number)
		p[episode_button] = episode_button
		p:addCustomButton("Relay",p[episode_button],string.format(_("news-buttonRelay","Episode %s"),episode_number),function()
			string.format("")
			regionalNewsEpisodeToLog(p,episode)
		end,500+i)
		episode_button = string.format("episode_%i_button_ops",episode_number)
		p[episode_button] = episode_button
		p:addCustomButton("Operations",p[episode_button],string.format(_("news-buttonOperations","Episode %s"),episode_number),function()
			string.format("")
			regionalNewsEpisodeToLog(p,episode)
		end,500+i)
	end
end
function hideRegionalNews(p)
	p:removeCustom(p.hide_regional_news_rel)
	p:removeCustom(p.hide_regional_news_ops)
	for i,episode in ipairs(regional_news_episodes) do
		local episode_button = string.format("episode_%i_button_rel",i)
		p[episode_button] = episode_button
		p:removeCustom(p[episode_button])
		episode_button = string.format("episode_%i_button_ops",i)
		p[episode_button] = episode_button
		p:removeCustom(p[episode_button])
	end
	p.show_regional_news_rel = "show_regional_news_rel"
	p:addCustomButton("Relay",p.show_regional_news_rel,_("news-buttonRelay","+Regional News"),function()
		string.format("")
		showReginalNews(p)
	end,500)
	p.show_regional_news_ops = "show_regional_news_ops"
	p:addCustomButton("Operations",p.show_regional_news_ops,_("news-buttonOperations","+Regional News"),function()
		string.format("")
		showReginalNews(p)
	end,500)
end
function updatePlayerProximityScan(p)
	local obj_list = p:getObjectsInRange(p.prox_scan*1000)
	if obj_list ~= nil and #obj_list > 0 then
		for _, obj in ipairs(obj_list) do
			if obj:isValid() and obj.typeName == "CpuShip" and not obj:isFullyScannedBy(p) then
				obj:setScanState("simplescan")
			end
		end
	end
end
function updatePlayerTubeSizeBanner(p)
	if p.tube_size ~= nil then
		local tube_size_banner = string.format(_("tabWeapons","%s tubes: %s"),p:getCallSign(),p.tube_size)
		if #p.tube_size == 1 then
			tube_size_banner = string.format(_("tabWeapons","%s tube: %s"),p:getCallSign(),p.tube_size)
		end
		p.tube_sizes_wea = "tube_sizes_wea"
		p:addCustomInfo("Weapons",p.tube_sizes_wea,tube_size_banner,1)
		p.tube_sizes_tac = "tube_sizes_tac"
		p:addCustomInfo("Tactical",p.tube_sizes_tac,tube_size_banner,1)
	end
end
function updatePlayerIDBanner(p)
	p.name_tag_hlm = "name_tag_hlm"
	p:addCustomInfo("Helms",p.name_tag_hlm,string.format("%s %s in %s",p:getFaction(),p:getCallSign(),p:getSectorName()),3)
	p.name_tag_tac = "name_tag_tac"
	p:addCustomInfo("Tactical",p.name_tag_tac,string.format("%s %s in %s",p:getFaction(),p:getCallSign(),p:getSectorName()),3)
end
function checkHelpNeedyFreighter(p)
	if spew_function_diagnostic then print("top of check help needy freighter") end
	if p.will_help_needy then
		if needy_freighter ~= nil and needy_freighter:isValid() then
			if needy_freighter.impulse_repaired == nil then
				if distance(p,needy_freighter) < 5000 and p.repair_crew_on_needy_freighter == nil then
					p.transport_repair_crew_eng = "transport_repair_crew_eng"
					p:addCustomButton("Engineering",p.transport_repair_crew_eng,"Transport Repair Crew",function()
						string.format("")
						transportRepairCrew(p)
					end,20)
					p.transport_repair_crew_epl = "transport_repair_crew_epl"
					p:addCustomButton("Engineering+",p.transport_repair_crew_epl,"Transport Repair Crew",function()
						string.format("")
						transportRepairCrew(p)
					end,20)
				else
					if p.transport_repair_crew_eng ~= nil then
						p:removeCustom(p.transport_repair_crew_eng)
						p.transport_repair_crew_eng = nil
					end
					if p.transport_repair_crew_epl ~= nil then
						p:removeCustom(p.transport_repair_crew_epl)
						p.transport_repair_crew_epl = nil
					end
				end
				if p.repair_crew_on_needy_freighter then
					if p.repair_timer ~= nil and getScenarioTime() > p.repair_timer then
						if p.repair_timer_eng ~= nil then
							p:removeCustom(p.repair_timer_eng)
							p.repair_timer_eng = nil
						end
						if p.repair_timer_epl ~= nil then
							p:removeCustom(p.repair_timer_epl)
							p.repair_timer_epl = nil
						end
						needy_freighter:setSystemHealthMax("impulse",1)
						needy_freighter.impulse_repaired = true
						p.helped_needy_freighter = true
						local dist = 999999
						if station_nearest_inner == nil then
							for i,station in ipairs(inner_circle) do
								if station ~= nil and station:isValid() then
									if station ~= station_needy_freighter and distance(p,station) < dist then
										station_nearest_inner = station
										dist = distance(p,station)
									end
								end
							end
						end
						print("station nearest inner:",station_nearest_inner:getCallSign(),"inner circle stations:")
						for i,station in ipairs(inner_circle) do
							print(station:getCallSign())
						end
						needy_freighter.nearest_inner = station_nearest_inner
						needy_freighter:orderDock(needy_freighter.nearest_inner)
						if p.shop_reward_message == nil then
							if availableForComms(p) then
								p.needy_freighter_thanks = true
								needy_freighter:openCommsTo(p)
								p.shop_reward_message = "sent"
							end
						end
					else
						local timer_out = string.format("Repairs: %i",math.floor(p.repair_timer - getScenarioTime()))
						p.repair_timer_eng = "repair_timer_eng"
						p:addCustomInfo("Engineering",p.repair_timer_eng,timer_out,5)
						p.repair_timer_epl = "repair_timer_epl"
						p:addCustomInfo("Engineering+",p.repair_timer_epl,timer_out,5)
					end
				end
			elseif needy_freighter.impulse_repaired then
				if p.repair_crew_on_needy_freighter then
					if distance(p,needy_freighter) < 5000 then
						p.return_repair_crew_eng = "return_repair_crew_eng"
						p:addCustomButton("Engineering",p.return_repair_crew_eng,"Return Repair Crew",function()
							string.format("")
							returnRepairCrew(p)
						end,20)
						p.return_repair_crew_epl = "return_repair_crew_epl"
						p:addCustomButton("Engineering+",p.return_repair_crew_epl,"Return Repair Crew",function()
							string.format("")
							returnRepairCrew(p)
						end,20)
					else
						if p.return_repair_crew_eng ~= nil then
							p:removeCustom(p.return_repair_crew_eng)
							p.return_repair_crew_eng = nil
						end
						if p.return_repair_crew_epl ~= nil then
							p:removeCustom(p.return_repair_crew_epl)
							p.return_repair_crew_epl = nil
						end
					end
				end
			end
		end
	end
	if spew_function_diagnostic then print("bottom of check help needy freighter") end
end
function returnRepairCrew(p)
	if spew_function_diagnostic then print("top of return repair crew") end
	p.will_help_needy = false
	p.repair_crew_on_needy_freighter = false
	p:setRepairCrewCount(p:getRepairCrewCount() + 1)
	p:removeCustom(p.return_repair_crew_eng)
	p:removeCustom(p.return_repair_crew_epl)
	p.return_repair_crew_eng = "return_repair_crew_eng"
	p:addCustomMessage("Engineering",p.return_repair_crew_eng,string.format("Repair crew has returned from %s",needy_freighter:getCallSign()))
	p.return_repair_crew_epl = "return_repair_crew_epl"
	p:addCustomMessage("Engineering+",p.return_repair_crew_epl,string.format("Repair crew has returned from %s",needy_freighter:getCallSign()))
	if spew_function_diagnostic then print("bottom of return repair crew") end
end
function transportRepairCrew(p)
	if spew_function_diagnostic then print("top of transport repair crew") end
	p.repair_crew_on_needy_freighter = true
	p:setRepairCrewCount(p:getRepairCrewCount() - 1)
	p:removeCustom(p.transport_repair_crew_eng)
	p:removeCustom(p.transport_repair_crew_epl)
	p.repair_crew_transferred_over_eng = "repair_crew_transferred_over_eng"
	p:addCustomMessage("Engineering",p.repair_crew_transferred_over_eng,string.format("One repair crew transferred to %s",needy_freighter:getCallSign()))
	p.repair_crew_transferred_over_epl = "repair_crew_transferred_over_epl"
	p:addCustomMessage("Engineering+",p.repair_crew_transferred_over_epl,string.format("One repair crew transferred to %s",needy_freighter:getCallSign()))
	p.repair_timer = getScenarioTime() + 60	--final: 60, test: 10
	if spew_function_diagnostic then print("bottom of transport repair crew") end
end

function update(delta)
 	if spew_function_diagnostic then print("top of update") end
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
 	if spew_function_diagnostic then print("bottom of update") end
end

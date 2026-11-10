-- Name: K-War
-- Description: Win the war with the Kraylor or the war with the Kraylor and Ktlitan if there are enough player ships participating. Critical artifact(s) may give the enemies or the players an advantage.
---
--- Supports up to 9 player ships simultaneously. The mission goals vary with the number of players. Terrain differs each time
---
--- Version 1
---
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online. There's usually one every weekend. All experience levels are welcome. 
-- Type: Replayable Mission
-- Author: Xansta
-- Setting[Murphy]: Configures the perversity of the universe according to Murphy's law
-- Murphy[Easy]: Random factors are more in your favor
-- Murphy[Normal|Default]: Random factors are normal
-- Murphy[Hard]: Random factors are more against you
-- Setting[Enemies]: Configures strength and/or number of enemies in this scenario
-- Enemies[Easy]: Fewer or weaker enemies
-- Enemies[Normal|Default]: Normal number or strength of enemies
-- Enemies[Hard]: More or stronger enemies
-- Enemies[Extreme]: Much stronger, many more enemies
-- Enemies[Quixotic]: Insanely strong and/or inordinately large numbers of enemies
-- Setting[Respawn]: Configures whether the player ship or ships automatically respawn in game or not and how often if they do automatically respawn
-- Respawn[None|Default]: Player ships do not automatically respawn
-- Respawn[One]: Player ships will automatically respawn once
-- Respawn[Two]: Player ships will automatically respawn twice
-- Respawn[Three]: Player ships will automatically respawn thrice
-- Respawn[Infinite]: Player ships will automatically respawn forever

--	Scenario outline
--	There's a war with the Kraylor. Intel has it that there's an artifact out there that
--	might give the Kraylor an edge. We need to get it before they do. Destroy main
--	Kraylor military station. Home station and Kraylor military station have defense 
--	platforms. If the Kraylor get the artifact, they'll start having enhancements on their
--	ships. If we get the artifact, our ships will get some enhancements. Place the 
--	artifact far away from the Kraylor and the Human Navy in a 3rd region. The terrain has
--	one region with the Human Navy station in the center and another region with the
--	Kraylor station in the center.

--	2 player ships
--		Add an Arlenian station that needs to be protected from Kraylor attack.
--		The Arlenian station should be in a 4th region.
--	3 or 4 player ships
--		Add a second and/or third artifact that the Kraylor and players are hunting. 
--		Enhancements are split between the artifacts
--	5 player ships
--		The ktlitans have joined the war and the search for the artifacts. Need a 5th
--		region. Winning the war requires the destruction of the Kraylor and the 
--		Ktlitan military stations
--	6 player ships
--		3 Human Navy and 3 TSN player ships. The TSN ships will not readily defend the 
--		Arlenians since they are enemies.
--	7 or 8 player ships
--		4 Human Navy and 3/4 TSN player ships. 4th and/or 5th enhancement artifact(s) added 
--	9 player ships
--		3 Human Navy, 3 TSN, and 3 CUF player ships. The CUF will not readily attack the 
--		Ktlitans since they are neutral

require("utils.lua")
require("place_station_scenario_utility.lua")
require("comms_scenario_utility.lua")
require("spawn_ships_scenario_utility.lua")
function init()
	scenario_version = "1.0.0"
	ee_version = "2024.12.08"
	print(string.format("    ----    Scenario: K-War    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
	if _VERSION ~= nil then
		print("Lua version:",_VERSION)
	end
	setConstants()
	setGlobals()
	setVariations()
	setSpawnShipGlobals()
	mainGMButtons()
	onNewPlayerShip(setPlayers)
end
function mainGMButtons()
	clearGMFunctions()
	addGMFunction(_("buttonGM","+Spawn Ship(s)"),spawnGMShips)
	addGMFunction(_("buttonGM","+Player Waypoints"),playerWaypoints)
end
function playerWaypoints()
	clearGMFunctions()
	addGMFunction("-Main",mainGMButtons)
	addGMFunction("List Waypoints",function()
		local out = _("msgGM","Player ship waypoints")
		for i,p in ipairs(getActivePlayerShips()) do
			local wc = p:getWaypointCount()
			if wc > 0 then
				out = string.format("%s\n  %s:%i",out,p:getCallSign(),wc)
				for n=1,wc do
					out = string.format(_("msgGM","%s\n    %i: sector %s"),out,n,getSectorName(p:getWaypoint(n)))
				end
			else
				out = string.format(_("msgGM","%s\n  %s:None"),out,p:getCallSign())
			end
		end
		addGMMessage(out)
	end)
end
function setConstants()
	difficulty = 1
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	sensor_impact = 1	--normal is 1
	station_spacing = {
		["Small Station"] =		{touch = 300,	defend = 2600,	platform = 1700,	outer_platform = 7500},
		["Medium Station"] =	{touch = 1200,	defend = 4000,	platform = 2900,	outer_platform = 9100},
		["Large Station"] =		{touch = 1400,	defend = 4600,	platform = 3300,	outer_platform = 9700},
		["Huge Station"] =		{touch = 2000,	defend = 4960,	platform = 4000,	outer_platform = 10100},
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
		["FX64 Hornet"] =					100,
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
		{name = "Lo",	val = .8,	desc = _("scienceDescription-nebula","May slightly reduce beam range")},			
		{name = "Md",	val = .7,	desc = _("scienceDescription-nebula","May reduce beam range")},					
		{name = "Hi",	val = .6,	desc = _("scienceDescription-nebula","May significantly reduce beam range")},		
		{name = "Sv",	val = .5,	desc = _("scienceDescription-nebula","May severely reduce beam range")},			
	}
	beam_range_gains = {
		{name = "Lo",	val = 1.1,	desc = _("scienceDescription-nebula","May slightly increase beam range")},				
		{name = "Md",	val = 1.25,	desc = _("scienceDescription-nebula","May increase beam range")},						
		{name = "Hi",	val = 1.4,	desc = _("scienceDescription-nebula","May significantly increase beam range")},		
	}
	shield_losses = {
		{name = "Lo",	val = .99999,	desc = _("scienceDescription-nebula","May cause low rates of shield charge loss")},	
		{name = "Md",	val = .99995,	desc = _("scienceDescription-nebula","May cause shield charge loss")},					
		{name = "Hi",	val = .9999,	desc = _("scienceDescription-nebula","May cause high rates of shield charge loss")},	
		{name = "Sv",	val = .999,		desc = _("scienceDescription-nebula","May cause severe rates of shield charge loss")},	
	}
	shield_gains = {
		{name = "Lo",	val = 1.000005,	desc = _("scienceDescription-nebula","May slightly increase shield charge")},		
		{name = "Md",	val = 1.00005,	desc = _("scienceDescription-nebula","May increase shield charge")},				
		{name = "Hi",	val = 1.0005,	desc = _("scienceDescription-nebula","May significantly increase shield charge")},	
	}
	coolant_losses = {
		{name = "Lo",	val = .99999,	desc = _("scienceDescription-nebula","May cause low level coolant leakage")},			--easy
		{name = "Md",	val = .99995,	desc = _("scienceDescription-nebula","May cause coolant leakage")},					--normal
		{name = "Hi",	val = .9999,	desc = _("scienceDescription-nebula","May cause high rates of coolant leakage")},		--hard
		{name = "Sv",	val = .999,		desc = _("scienceDescription-nebula","May cause severe rates of coolant leakage")},	--quixotic
	}
	coolant_gains = {
		{name = "Lo",	val = .0001,	desc = _("scienceDescription-nebula","May gain low amounts of coolant")},		--hard
		{name = "Md",	val = .001,		desc = _("scienceDescription-nebula","May gain coolant")},						--normal
		{name = "Hi",	val = .01,		desc = _("scienceDescription-nebula","May gain high amounts of coolant")},		--easy
	}
	scan_tiers = {	--complex = bars, depth = windows
		{complex = 1,	depth = 1},
		{complex = 2,	depth = 1},
		{complex = 3,	depth = 1},
		{complex = 1,	depth = 2},
		{complex = 2,	depth = 2},
		{complex = 1,	depth = 3},
	}
end
function setGlobals()
	hqs = {}
	attack_force_delay = 8
	anomalous_nebulae = {}
	critical_artifacts = {}
	science_ships = {}
	player_artifacts_delivered = 0
	enemy_artifacts_delivered = 0
	cyber_attack_factors = {30, 50, 75, 90, 100}
	cyber_attack_intervals = {20, 40, 60, 80, 100}
	cyber_attack_ships = {}
	spiky_spin_ships = {}
	impulse_boost_ships = {}
	pdc_factors = {20,30,50,75,90}
	pdc_ships = {}
	deployed_players = {}
	player_upgrades = {
		{name = "Shield balancer",	avail = false,	impl = "Delivery"},
		{name = "Missile capacity",	avail = false,	impl = "Docking"},
		{name = "Stronger sensors",	avail = false,	impl = "Instant"},
		{name = "Early detonation",	avail = false,	impl = "Delivery"},
		{name = "Faster tubes",		avail = false,	impl = "Docking"},
		{name = "Faster spin",		avail = false,	impl = "Docking"},
	}
	enemy_upgrades = {
		{name = "Spiky spin",		avail = false,	impl = "Delivery"},
		{name = "Cyber attack",		avail = false,	impl = "Instant"},
		{name = "Tactical hop",		avail = false,	impl = "Delivery"},
		{name = "Shield frequency",	avail = false,	impl = "Instant"},
		{name = "Skip beam",		avail = false,	impl = "Delivery"},
		{name = "Point defense",	avail = false,	impl = "Delivery"},
	}
	primary_orders = _("orders-comms","Win the war with the Kraylor")
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
	region_parameters = {
		{count = 3,	radius = 50000,	clutter = 100,	--	1 player ship
			start_factions = {"Arlenians","Independent","TSN","CUF","USN"},
			kraylor_factions = {"Independent","Ghosts","USN"},
		},	
		{count = 4,	radius = 50000,	clutter = 100,	--	2 player ships
			start_factions = {"Independent","TSN","CUF","USN"},
			kraylor_factions = {"Independent","Ghosts","USN"},
			arlenian_factions = {"Independent","Human Navy","Ghosts","Ktlitans","USN","CUF"},
		},	
		{count = 4,	radius = 60000,	clutter = 100,	--	3 player ships
			start_factions = {"Independent","TSN","CUF","USN"},
			kraylor_factions = {"Independent","Ghosts","USN"},
			arlenian_factions = {"Independent","Human Navy","Ghosts","Ktlitans","USN","CUF"},
		},	
		{count = 4,	radius = 60000,	clutter = 100,	--	4 player ships
			start_factions = {"Independent","TSN","CUF","USN"},
			kraylor_factions = {"Independent","Ghosts","USN"},
			arlenian_factions = {"Independent","Human Navy","Ghosts","Ktlitans","USN","CUF"},
		},	
		{count = 5,	radius = 70000,	clutter = 100,	--	5 player ships
			start_factions = {"Independent","TSN","CUF","USN"},
			kraylor_factions = {"Independent","Ghosts","USN"},
			arlenian_factions = {"Independent","Human Navy","Ghosts","Ktlitans","USN","CUF"},
			ktlitan_factions = {"Independent","Arlenians","Ghosts","CUF"}
		},	
		{count = 5,	radius = 70000,	clutter = 100,	--	6 player ships
			start_factions = {"Independent","CUF","USN"},
			kraylor_factions = {"Independent","Ghosts","USN"},
			arlenian_factions = {"Independent","Human Navy","Ghosts","Ktlitans","USN","CUF"},
			ktlitan_factions = {"Independent","Arlenians","Ghosts","CUF"},
		},	
		{count = 6,	radius = 80000,	clutter = 100,	--	7 player ships
			start_factions = {"Independent","CUF","USN"},
			kraylor_factions = {"Independent","Ghosts","USN"},
			arlenian_factions = {"Independent","Human Navy","Ghosts","Ktlitans","USN","CUF"},
			ktlitan_factions = {"Independent","Arlenians","Ghosts","CUF"},
		},	
		{count = 6,	radius = 80000,	clutter = 100,	--	8 player ships
			start_factions = {"Independent","CUF","USN"},
			kraylor_factions = {"Independent","Ghosts","USN"},
			arlenian_factions = {"Independent","Human Navy","Ghosts","Ktlitans","USN","CUF"},
			ktlitan_factions = {"Independent","Arlenians","Ghosts","CUF"},
		},	
		{count = 6,	radius = 90000,	clutter = 100,	--	9 player ships
			start_factions = {"Independent","USN"},
			kraylor_factions = {"Independent","Ghosts","USN"},
			arlenian_factions = {"Independent","Human Navy","Ghosts","Ktlitans","USN","CUF"},
			ktlitan_factions = {"Independent","Arlenians","Ghosts","CUF"},
		},	
	}
	respawns = {
		["Atlantis"] =			"Crucible",
		["Crucible"] =			"Player Cruiser",
		["Player Cruiser"] =	"Maverick",
		["Maverick"] =			"Nautilus",
		["Nautilus"] =			"Flavia P.Falcon",
		["Flavia P.Falcon"] =	"Hathcock",
		["Hathcock"] =			"Phobos M3P",
		["Phobos M3P"] =		"Piranha",
		["Piranha"] =			"Player Missile Cr.",
		["Player Missile Cr."] ="Atlantis",
		["Benedict"] =			"Kiriya",
		["Kiriya"] =			"Saipan",
		["Saipan"] =			"Crucible",
		["Ender"] =				"MP52 Hornet",
		["MP52 Hornet"] =		"Repulse",
		["Repulse"] =			"Striker",
		["Striker"] =			"ZX-Lindworm",
		["ZX-Lindworm"] =		"Player Fighter",
		["Player Fighter"] =	"Player Cruiser",
	}	
	inner_space = {}
	orbiting_platforms = {}
	planet_collision_list = {}
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
	include_major_systems_repair_in_status = true
	include_minor_systems_repair_in_status = true
	include_goods_for_sale_in_status = true
	include_goods_wanted_in_status = true
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
			info = {
				{
					name = "Gamma Piscium",
					unscanned = _("scienceDescription-star","Yellow,\nspectral type G8 III"),
					scanned = _("scienceDescription-star","Yellow,\nspectral type G8 III,\ngiant,\nsurface temperature 4,833 K,\n11 solar radii"),
				},
				{
					name = "Beta Leporis",
					unscanned = _("scienceDescription-star","Classification G5 II"),
					scanned = _("scienceDescription-star","Classification G5 II,\nbright giant,\nbinary"),
				},
				{
					name = "Sigma Draconis",
					unscanned = _("scienceDescription-star","Classification K0 V or G9 V"),
					scanned = _("scienceDescription-star","Classification K0 V or G9 V,\nmain sequence dwarf,\n84% of Sol mass"),
				},
				{
					name = "Iota Carinae",
					unscanned = _("scienceDescription-star","Classification A7 lb"),
					scanned = _("scienceDescription-star","Classification A7 lb,\nsupergiant,\ntemperature 7,500 K,\n7xSol mass"),
				},
				{
					name = "Theta Arietis",
					unscanned = _("scienceDescription-star","Classification A1 Vn"),
					scanned = _("scienceDescription-star","Classification A1 Vn,\ntype A main sequence,\nnebulous"),
				},
				{
					name = "Epsilon Indi",
					unscanned = _("scienceDescription-star","Classification K5V"),
					scanned = _("scienceDescription-star","Classification K5V,\norange,\ntemperature 4,649 K"),
				},
				{
					name = "Beta Hydri",
					unscanned = _("scienceDescription-star","Classification G2 IV"),
					scanned = _("scienceDescription-star","Classification G2 IV,\n113% of Sol mass,\n185% Sol radius"),
				},
				{
					name = "Acamar",
					unscanned = _("scienceDescription-star","Classification A3 IV-V"),
					scanned = _("scienceDescription-star","Classification A3 IV-V,\n2.6xSol mass"),
				},
				{
					name = "Bellatrix",
					unscanned = _("scienceDescription-star","Classification B2 III or B2 V"),
					scanned = _("scienceDescription-star","Classification B2 III or B2 V,\n8.6xSol mass,\ntemperature 22,000 K"),
				},
				{
					name = "Castula",
					unscanned = _("scienceDescription-star","Classification G8 IIIb Fe-0.5"),
					scanned = _("scienceDescription-star","Classification G8 IIIb Fe-0.5,\nyellow,\nred clump giant"),
				},
				{
					name = "Dziban",
					unscanned = _("scienceDescription-star","Classification F5 IV-V"),
					scanned = _("scienceDescription-star","Classification F5 IV-V,\nF-type subgiant\nF-type main sequence"),
				},
				{
					name = "Elnath",
					unscanned = _("scienceDescription-star","Classification B7 III"),
					scanned = _("scienceDescription-star","Classification B7 III,\nB-class giant,\n5xSol mass"),
				},
				{
					name = "Flegetonte",
					unscanned = _("scienceDescription-star","Classification K0"),
					scanned = _("scienceDescription-star","Classification K0,\norange-red,\ntemperature ~4,000 K"),
				},
				{
					name = "Geminga",
					unscanned = _("scienceDescription-star","Pulsar or Neutron star"),
					scanned = _("scienceDescription-star","Pulsar or Neutron star,\ngamma ray source"),
				},
				{	
					name = "Helvetios",	
					unscanned = _("scienceDescription-star","Classification G2V"),
					scanned = _("scienceDescription-star","Classification G2V,\nyellow,\ntemperature 5,571 K"),
				},
				{	
					name = "Inquill",	
					unscanned = _("scienceDescription-star","Classification G1V(w)"),
					scanned = _("scienceDescription-star","Classification G1V(w),\n1.24xSol mass,n7th magnitude G-type main sequence"),
				},
				{	
					name = "Jishui",	
					unscanned = _("scienceDescription-star","Classification F3 III"),
					scanned = _("scienceDescription-star","Classification F3 III,\nF-type giant,\ntemperature 6,309 K"),
				},
				{	
					name = "Kaus Borealis",	
					unscanned = _("scienceDescription-star","Classification K1 IIIb"),
					scanned = _("scienceDescription-star","Classification K1 IIIb,\ngiant,\ntemperature 4,768 K"),
				},
				{	
					name = "Liesma",	
					unscanned = _("scienceDescription-star","Classification G0V"),
					scanned = _("scienceDescription-star","Classification G0V,\nG-type giant, \ntemperature 5,741 K"),
				},
				{	
					name = "Macondo",	
					unscanned = _("scienceDescription-star","Classification K2IV-V or K3V"),
					scanned = _("scienceDescription-star","Classification K2IV-V or K3V,\norange,\nK-type main sequence,\ntemperature 5,030 K"),
				},
				{	
					name = "Nikawiy",	
					unscanned = _("scienceDescription-star","Classification G5"),
					scanned = _("scienceDescription-star","Classification G5,\nyellow,\nluminosity 7.7"),
				},
				{	
					name = "Orkaria",	
					unscanned = _("scienceDescription-star","Classification M4.5"),
					scanned = _("scienceDescription-star","Classification M4.5,\nRed Dwarf,\nluminosity .0035,\ntemperature 3,111 K"),
				},
				{	
					name = "Poerava",	
					unscanned = _("scienceDescription-star","Classification F7V"),
					scanned = _("scienceDescription-star","Classification F7V,\nyellow-white,\nluminosity 1.9,\ntemperature 6,440 K"),
				},
				{	
					name = "Stribor",	
					unscanned = _("scienceDescription-star","Classification F8V"),
					scanned = _("scienceDescription-star","Classification F8V,\nluminosity 2.9,\ntemperature 6,122 K"),
				},
				{	
					name = "Taygeta",	
					unscanned = _("scienceDescription-star","Classification B"),
					scanned = _("scienceDescription-star","Classification B-type subgiant, blue-white, luminosity 600, temperature 13,696 K"),
				},
				{	
					name = "Tuiren",	
					unscanned = _("scienceDescription-star","Classification G"),
					scanned = _("scienceDescription-star","Classification G,\nmagnitude 12.26,\ntemperature 5,580 K"),
				},
				{	
					name = "Ukdah",	
					unscanned = _("scienceDescription-star","Classification K"),
					scanned = _("scienceDescription-star","Classification K2.5 III,\nK-type giant,\ntemperature 4,244 K"),
				},
				{	
					name = "Wouri",	
					unscanned = _("scienceDescription-star","Classification K"),
					scanned = _("scienceDescription-star","Classification 5V,\nK-type main sequence,\ntemperature 4,782 K"),
				},
				{	
					name = "Xihe",	
					unscanned = _("scienceDescription-star","Classification G"),
					scanned = _("scienceDescription-star","Classification G8 III,\nevolved G-type giant,\ntemperature 4,790 K"),
				},
				{	
					name = "Yildun",	
					unscanned = _("scienceDescription-star","Classification A"),
					scanned = _("scienceDescription-star","Classification A1 Van,\nwhite hued,\nA-type main sequence,\ntemperature 9,911 K"),
				},
				{	
					name = "Zosma",	
					unscanned = _("scienceDescription-star","Classification A"),
					scanned = _("scienceDescription-star","Classification A4 V,\nwhite hued,\nA-type main sequence,\ntemperature 8,296 K"),
				},
			},
			color = {
				red = random(0.5,1), green = random(0.5,1), blue = random(0.5,1)
			},
			texture = {
				atmosphere = "planets/star-1.png"
			},
		},
	}
	planet_list = {
		{
			name = {"Bespin","Aldea","Bersallis"},
			unscanned = _("scienceDescription-planet","Class J"),
			scanned = _("scienceDescription-planet","Class J, Jovian, source for hydrogen and helium and a large variety of exotic gasses"),
			texture = {
				surface = "planets/gas-1.png"
			},
			radius = random(4000,7500),
		},
		{
			name = {"Farius Prime","Deneb","Mordan"},
			unscanned = _("scienceDescription-planet","Class J"),
			scanned = _("scienceDescription-planet","Class J, Neptunian, source for hydrogen helium, ammonia, methane, water"),
			texture = {
				surface = "planets/gas-2.png"
			},
			radius = random(4000,7500),
		},
		{
			name = {"Kepler-7b","Alpha Omicron","Nelvana"},
			unscanned = _("scienceDescription-planet","Class J"),
			scanned = _("scienceDescription-planet","Class J, Neptunian, composed of hydrogen, helium, methane, water"),
			texture = {
				surface = "planets/gas-3.png"
			},
			radius = random(4000,7500),
		},
		{
			name = {"Alderaan","Dagobah","Dantooine","Rigel"},
			unscanned = {
				["Alderaan"] = _("scienceDescription-planet","Class M"),
				["Dagobah"] = _("scienceDescription-planet","Class M"),
				["Dantooine"] = _("scienceDescription-planet","Class L"),
				["Rigel"] = _("scienceDescription-planet","Class M"),
			},
			scanned = {
				["Alderaan"] = _("scienceDescription-planet","Class M, Minshara, supports life, large peaceful civilization present."),
				["Dagobah"] = _("scienceDescription-planet","Class M, Minshara, supports life, mostly vegetation and simple life forms present."),
				["Dantooine"] = _("scienceDescription-planet","Class L, marginally habitable, serves as an outpost."),
				["Rigel"] = _("scienceDescription-planet","Class M, Minshara, supports life, rest and recreation planet."),
			},
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
			radius = random(3000,5000),
		},
		{
			name = {"Pahvo","Penthara IV","Scalos"},
			unscanned = _("scienceDescription-planet","Class M"),
			scanned = {
				["Pahvo"] = _("scienceDescription-planet","Class M, Minshara, supports life, forested planet."),
				["Penthara IV"] = _("scienceDescription-planet","Class M, Minshara, supports life, colony established."),
				["Scalos"] = _("scienceDescription-planet","Class M, Minshara, supports life, extinct civilization on the surface."),
			},
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
			radius = random(3000,5000),
		},
		{
			name = {"Tanuga IV","Vacca VI","Terlina III","Timor"},
			unscanned = _("scienceDescription-planet","Class M"),
			scanned = {
				["Tanuga IV"] = _("scienceDescription-planet","Class M, Minshara, supports life, research colony."),
				["Vacca VI"] = _("scienceDescription-planet","Class M, Minshara, supports life, colonized by refugees."),
				["Terlina III"] = _("scienceDescription-planet","Class M, Minshara, supports life, forest world."),
				["Timor"] = _("scienceDescription-planet","Class M, Minshara, supports life."),
			},
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
			radius = random(3000,5000),
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
	local murphy_config = {
		["Easy"] =		{number = .5,	art_thresh = .3,	rep = 90,	bump = 20,	},
		["Normal"] =	{number = 1,	art_thresh = .2,	rep = 50,	bump = 10,	},
		["Hard"] =		{number = 2,	art_thresh = .1,	rep = 30,	bump = 5,	},
		["Extreme"] =	{number = 3,	art_thresh = .07,	rep = 20,	bump = 3,	},
		["Quixotic"] =	{number = 5,	art_thresh = .04,	rep = 10,	bump = 1,	},
	}
	difficulty =				murphy_config[getScenarioSetting("Murphy")].number
	artifact_threshold =		murphy_config[getScenarioSetting("Murphy")].art_thresh
	local enemy_config = {
		["Easy"] =		{number = .5},
		["Normal"] =	{number = 1},
		["Hard"] =		{number = 2},
		["Extreme"] =	{number = 3},
		["Quixotic"] =	{number = 5},
	}
	enemy_power =	enemy_config[getScenarioSetting("Enemies")].number
	local respawn_config = {
		["None"] =		{respawn = false,	max = 0},
		["One"] =		{respawn = true,	max = 1},
		["Two"] =		{respawn = true,	max = 2},
		["Three"] =		{respawn = true,	max = 3},
		["Infinite"] =	{respawn = true,	max = 999},	--I know, it's not infinite, but come on, after 999, it should stop
	}
	player_respawns = respawn_config[getScenarioSetting("Respawn")].respawn
	player_respawn_max = respawn_config[getScenarioSetting("Respawn")].max
end
function constructEnvironment()
	allowNewPlayerShips(false)
	p_count = #getActivePlayerShips()
	if not player_start_positions_constructed then
		globalMessage(_("msgMainscreen-startGame","Construct Environment Phase 1"),1)
		constructPlayerStartPositions()
	elseif not start_planets_constructed then
		globalMessage(_("msgMainscreen-startGame","Construct Environment Phase 2"),1)
		constructStartPlanets()
	elseif not start_stations_constructed then
		globalMessage(_("msgMainscreen-startGame","Construct Environment Phase 3"),1)
		constructStartStations()
	elseif not start_terrain_constructed then
		globalMessage(_("msgMainscreen-startGame","Construct Environment Phase 4"),1)
		constructStartTerrain()
	elseif not mid_terrain_constructed then
		globalMessage(_("msgMainscreen-startGame","Construct Environment Phase 5"),1)
		constructMidTerrain()
	elseif not kraylor_terrain_constructed then
		globalMessage(_("msgMainscreen-startGame","Construct Environment Phase 6"),1)
		constructKraylorTerrain()
	elseif not arlenian_terrain_constructed then
		spaces = {
			{inner_space, mid_space, kraylor_space},	--1 player ship
			{inner_space, mid_space, kraylor_space},	--2 player ships
			{inner_space, mid_space, kraylor_space},	--3 player ships
			{inner_space, mid_space, kraylor_space},	--4 player ships
			{inner_space, mid_space, kraylor_space},	--5 player ships
			{inner_space, mid_space, kraylor_space},	--6 player ships
			{inner_space, mid_space, kraylor_space},	--7 player ships
			{inner_space, mid_space, kraylor_space},	--8 player ships
			{inner_space, mid_space, kraylor_space},	--9 player ships
		}
		space_station = {
			[inner_space] = inner_stations,
			[mid_space] = mid_stations,
			[kraylor_space] = kraylor_stations,
		}
		globalMessage(_("msgMainscreen-startGame","Construct Environment Phase 7"),1)
		constructArlenianTerrain()
	elseif not ktlitan_terrain_constructed then
		globalMessage(_("msgMainscreen-startGame","Construct Environment Phase 8"),1)
		constructKtlitanTerrain()
	elseif not aux_terrain_constructed then
		globalMessage(_("msgMainscreen-startGame","Construct Environment Phase 9"),1)
		constructAuxTerrain()
		--wormhole network, anomalous nebulae and probe starting stations
		local nebula_pool = {}
		for k,s in ipairs(spaces[starting_players]) do
			for i,station in ipairs(space_station[s]) do
				if station.comms_data.system_repair == nil then
					station.comms_data.system_repair = {}
					local system_list = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
					for i, system in ipairs(system_list) do
						local chance = 60
						local eval = random(1,100)
						station.comms_data.system_repair[system] = eval <= chance
					end
				end
			end
			for i,item in ipairs(s) do
				local other_spaces = {}
				for j,space in ipairs(spaces[starting_players]) do
					if space ~= s then
						table.insert(other_spaces,space)
					end
				end
				if isObjectType(item.obj,"WormHole") then
					local selected_space = tableSelectRandom(other_spaces)
					local tx, ty = findClearSpot(
						selected_space,"circle",space_center[selected_space].x,space_center[selected_space].y,
						region_parameters[starting_players].radius,nil,nil,200
					)
					if tx ~= nil then
						item.obj:setTargetPosition(tx,ty)
					end
				end
				if isObjectType(item.obj,"ScanProbe") then
					local selected_space = tableSelectRandom(other_spaces)
					local selected_station = tableSelectRandom(space_station[selected_space])
					item.obj:setOwner(selected_station)
					local lpx, lpy = vectorFromAngle(random(0,360),random(2000,3000),true)
					local sx, sy = selected_station:getPosition()
					item.obj:setPosition(sx + lpx, sy + lpy)
				end
				if isObjectType(item.obj,"Nebula") then
					table.insert(nebula_pool,item.obj)
				end
			end
		end
		if #nebula_pool > 6 then
			nebula_groups = math.floor(#nebula_pool / 6 / 3)
			if nebula_groups > 0 then
				for i=1,nebula_groups do
					local neb_names = {"-SC","+SC","-C","+C","-BR","+BR"}
					for j=1,6 do
						setAnomalousNebula(tableRemoveRandom(nebula_pool),tableRemoveRandom(neb_names))
					end
				end
			end
		end
	else
		environment_constructed = true
	end
end
function constructPlayerStartPositions()
	start_region_center_x = 150000 + random(-60000,60000)
	start_region_center_y = 130000 + random(-15000,15000)
	space_center = {}
	space_center[inner_space] = {x = start_region_center_x,		y = start_region_center_y}
	inner_stations = {}
	local hq_sizes = {"Medium Station","Large Station","Huge Station"}
	local selected_size = tableRemoveRandom(hq_sizes)
	human_headquarters = placeStation(start_region_center_x,start_region_center_y,"Pop Sci Fi","Human Navy",selected_size)
	hqs["Human Navy"] = human_headquarters
	table.insert(inner_space,{obj=human_headquarters,dist=station_spacing[human_headquarters:getTypeName()].outer_platform,shape="circle"})
	table.insert(inner_stations,human_headquarters)
	human_navy_spawn_angle = random(0,360)
	local min_dist = station_spacing[selected_size].platform + 400
	start_region_player_spawn_x, start_region_player_spawn_y = vectorFromAngle(human_navy_spawn_angle,random(math.max(3500,min_dist),5000),true)
	start_region_player_spawn_x = start_region_player_spawn_x + start_region_center_x
	start_region_player_spawn_y = start_region_player_spawn_y + start_region_center_y
	start_region_player_spawn = {
		{x = start_region_player_spawn_x,			y = start_region_player_spawn_y},
		{x = start_region_player_spawn_x + 1000,	y = start_region_player_spawn_y},
		{x = start_region_player_spawn_x,			y = start_region_player_spawn_y + 1000},
		{x = start_region_player_spawn_x - 1000,	y = start_region_player_spawn_y},
		{x = start_region_player_spawn_x,			y = start_region_player_spawn_y - 1000},
	}
	createOrbitingDefenses(human_headquarters,6)
	for i,dp in ipairs(human_headquarters.station_platforms) do
		dp:setScannedByFaction("Human Navy",true)
	end
	if p_count < 6 then
		for i,p in ipairs(getActivePlayerShips()) do
			p:setPosition(start_region_player_spawn[i].x,start_region_player_spawn[i].y)
			p.spawn_x = start_region_player_spawn[i].x
			p.spawn_y = start_region_player_spawn[i].y
			table.insert(inner_space,{obj=p,dist=500,shape="circle"})
		end
	else
		tsn_spawn_angle = (human_navy_spawn_angle + random(-90,90)) % 360
		selected_size = tableRemoveRandom(hq_sizes)
		min_dist = station_spacing[selected_size].platform + 400
		tsn_spawn_dist = random(math.max(3500,min_dist),5000)
		start_region_player_spawn_tsn_x, start_region_player_spawn_tsn_y = vectorFromAngle(tsn_spawn_angle,tsn_spawn_dist,true)
		start_region_player_spawn_tsn_x = start_region_player_spawn_tsn_x + start_region_player_spawn_x
		start_region_player_spawn_tsn_y = start_region_player_spawn_tsn_y + start_region_player_spawn_y
		start_region_player_spawn_tsn = {
			{x = start_region_player_spawn_tsn_x,			y = start_region_player_spawn_tsn_y},
			{x = start_region_player_spawn_tsn_x + 1000,	y = start_region_player_spawn_tsn_y},
			{x = start_region_player_spawn_tsn_x,			y = start_region_player_spawn_tsn_y + 1000},
			{x = start_region_player_spawn_tsn_x - 1000,	y = start_region_player_spawn_tsn_y},
		}
		tsn_headquarters_x, tsn_headquarters_y = vectorFromAngle(tsn_spawn_angle,tsn_spawn_dist*1.5,true)
		tsn_headquarters_x = tsn_headquarters_x + start_region_player_spawn_tsn_x
		tsn_headquarters_y = tsn_headquarters_y + start_region_player_spawn_tsn_y
		tsn_headquarters = placeStation(tsn_headquarters_x,tsn_headquarters_y,"History","TSN",selected_size)
		hqs["TSN"] = tsn_headquarters
		table.insert(inner_space,{obj=tsn_headquarters,dist=station_spacing[tsn_headquarters:getTypeName()].outer_platform,shape="circle"})
		table.insert(inner_stations,tsn_headquarters)
		createOrbitingDefenses(tsn_headquarters,6)
		for i,dp in ipairs(human_headquarters.station_platforms) do
			dp:setScannedByFaction("TSN",true)
		end
		for i,dp in ipairs(tsn_headquarters.station_platforms) do
			dp:setScannedByFaction("TSN",true)
			dp:setScannedByFaction("Human Navy",true)
		end
		if p_count == 6 then
			for i,p in ipairs(getActivePlayerShips()) do
				if i < 4 then
					p:setPosition(start_region_player_spawn[i].x,start_region_player_spawn[i].y)
					p.spawn_x = start_region_player_spawn[i].x
					p.spawn_y = start_region_player_spawn[i].y
				else
					p:setPosition(start_region_player_spawn_tsn[i-3].x,start_region_player_spawn_tsn[i-3].y)
					p.spawn_x = start_region_player_spawn_tsn[i-3].x
					p.spawn_y = start_region_player_spawn_tsn[i-3].y
				end
				table.insert(inner_space,{obj=p,dist=500,shape="circle"})
			end
		elseif p_count == 7 or p_count == 8 then
			for i,p in ipairs(getActivePlayerShips()) do
				if i < 5 then
					p:setPosition(start_region_player_spawn[i].x,start_region_player_spawn[i].y)
					p.spawn_x = start_region_player_spawn[i].x
					p.spawn_y = start_region_player_spawn[i].y
				else
					p:setPosition(start_region_player_spawn_tsn[i-4].x,start_region_player_spawn_tsn[i-4].y)
					p.spawn_x = start_region_player_spawn_tsn[i-4].x
					p.spawn_y = start_region_player_spawn_tsn[i-4].y
				end
				table.insert(inner_space,{obj=p,dist=500,shape="circle"})
			end
		else
			cuf_spawn_angle = (tsn_spawn_angle + random(40,100)) % 360
			selected_size = tableRemoveRandom(hq_sizes)
			min_dist = station_spacing[selected_size].platform + 400
			cuf_spawn_dist = random(math.max(3500,min_dist),5000)
			start_region_player_spawn_cuf_x, start_region_player_spawn_cuf_y = vectorFromAngle(cuf_spawn_angle,cuf_spawn_dist,true)
			start_region_player_spawn_cuf_x = start_region_player_spawn_cuf_x + start_region_player_spawn_tsn_x
			start_region_player_spawn_cuf_y = start_region_player_spawn_cuf_y + start_region_player_spawn_tsn_y
			start_region_player_spawn_cuf = {
				{x = start_region_player_spawn_cuf_x,			y = start_region_player_spawn_cuf_y},
				{x = start_region_player_spawn_cuf_x + 1000,	y = start_region_player_spawn_cuf_y},
				{x = start_region_player_spawn_cuf_x,			y = start_region_player_spawn_cuf_y + 1000},
			}
			cuf_headquarters_x, cuf_headquarters_y = vectorFromAngle(cuf_spawn_angle,cuf_spawn_dist*1.5,true)
			cuf_headquarters_x = cuf_headquarters_x + start_region_player_spawn_cuf_x
			cuf_headquarters_y = cuf_headquarters_y + start_region_player_spawn_cuf_y
			cuf_headquarters = placeStation(cuf_headquarters_x,cuf_headquarters_y,"Spec Sci Fi","CUF",selected_size)
			hqs["CUF"] = cuf_headquarters
			table.insert(inner_space,{obj=cuf_headquarters,dist=station_spacing[cuf_headquarters:getTypeName()].outer_platform,shape="circle"})
			table.insert(inner_stations,cuf_headquarters)
			createOrbitingDefenses(cuf_headquarters,6)
			for i,dp in ipairs(human_headquarters.station_platforms) do
				dp:setScannedByFaction("CUF",true)
			end
			for i,dp in ipairs(tsn_headquarters.station_platforms) do
				dp:setScannedByFaction("CUF",true)
			end
			for i,dp in ipairs(cuf_headquarters.station_platforms) do
				dp:setScannedByFaction("CUF",true)
				dp:setScannedByFaction("TSN",true)
				dp:setScannedByFaction("Human Navy",true)
			end
			for i,p in ipairs(getActivePlayerShips()) do
				if i < 4 then
					p:setPosition(start_region_player_spawn[i].x,start_region_player_spawn[i].y)
					p.spawn_x = start_region_player_spawn[i].x
					p.spawn_y = start_region_player_spawn[i].y
				elseif i < 7 then
					p:setPosition(start_region_player_spawn_tsn[i-3].x,start_region_player_spawn_tsn[i-3].y)
					p.spawn_x = start_region_player_spawn_tsn[i-3].x
					p.spawn_y = start_region_player_spawn_tsn[i-3].y
				else
					p:setPosition(start_region_player_spawn_cuf[i-6].x,start_region_player_spawn_cuf[i-6].y)
					p.spawn_x = start_region_player_spawn_cuf[i-6].x
					p.spawn_y = start_region_player_spawn_cuf[i-6].y
				end
				table.insert(inner_space,{obj=p,dist=500,shape="circle"})
			end
		end
	end
	player_start_positions_constructed = true
end
function constructStartPlanets()
	region_radius = region_parameters[#getActivePlayerShips()].radius
	region_count = region_parameters[#getActivePlayerShips()].count
	local star_start_x, star_start_y = vectorFromAngle((human_navy_spawn_angle + 180) % 360,10000,true)
	star_start_x = star_start_x + start_region_center_x
	star_start_y = star_start_y + start_region_center_y
	local star_start_info = tableRemoveRandom(star_list[1].info)
	local unscanned_desc = ""
	local scanned_desc = ""
	star_start_region = Planet():setPosition(star_start_x, star_start_y):setPlanetRadius(5000)
		:setCallSign(star_start_info.name)
		:setPlanetAtmosphereTexture(star_list[1].texture.atmosphere)
		:setPlanetAtmosphereColor(star_list[1].color.red,star_list[1].color.green,star_list[1].color.blue)
		:setDistanceFromMovementPlane(1800)
	if star_start_info.unscanned ~= nil then
		unscanned_desc = star_start_info.unscanned
		scanned_desc = star_start_info.scanned
		star_start_region:setDescriptions(unscanned_desc,scanned_desc)
		star_start_region:setScanningParameters(1,2)
	end
	table.insert(inner_space,{obj=star_start_region,dist=5000,shape="circle"})
	table.insert(planet_collision_list,{planet = star_start_region, fudge = 430})
	planet_start_x, planet_start_y = vectorFromAngle((human_navy_spawn_angle + 180 + random(-45,45)) % 360,random(30000,35000),true)
	planet_start_x = planet_start_x + star_start_x
	planet_start_y = planet_start_y + star_start_y
	local planet_start_item = tableRemoveRandom(planet_list)
	local planet_start_radius = planet_start_item.radius
	planet_start_region = Planet():setPosition(planet_start_x,planet_start_y):setPlanetRadius(planet_start_radius)
	planet_start_region:setDistanceFromMovementPlane(planet_start_radius*-.3)
	planet_start_region:setCallSign(tableSelectRandom(planet_start_item.name))
	planet_start_region:setPlanetSurfaceTexture(planet_start_item.texture.surface)
	local rotation_time = random(300,500)
	planet_start_region:setAxialRotationTime(rotation_time)
	if planet_start_item.texture.atmosphere ~= nil then
		rotation_time = rotation_time * .65
		planet_start_region:setPlanetAtmosphereTexture(planet_start_item.texture.atmosphere)
	end
	if planet_start_item.texture.cloud ~= nil then
		planet_start_region:setPlanetCloudTexture(planet_start_item.texture.cloud)
	end
	if planet_start_item.color ~= nil then
		planet_start_region:setPlanetAtmosphereColor(planet_start_item.color.red,planet_start_item.color.green,planet_start_item.color.blue)
	end
	if planet_start_item.unscanned ~= nil then
		unscanned_desc = ""
		scanned_desc = ""
		if type(planet_start_item.unscanned) == "table" then
			unscanned_desc = planet_start_item.unscanned[planet_start_region:getCallSign()]
		else
			unscanned_desc = planet_start_item.unscanned
		end
		if type(planet_start_item.scanned) == "table" then
			scanned_desc = planet_start_item.scanned[planet_start_region:getCallSign()]
		else
			scanned_desc = planet_start_item.scanned
		end
		planet_start_region:setDescriptions(unscanned_desc,scanned_desc)
		planet_start_region:setScanningParameters(1,2)
	end
	table.insert(inner_space,{obj=planet_start_region,dist=planet_start_item.radius,shape="circle"})
	table.insert(planet_collision_list,{planet = planet_start_region, fudge = 187})
	start_planets_constructed = true
end
function constructStartStations()
	for i,faction in ipairs(region_parameters[p_count].start_factions) do
		local psx, psy = findClearSpot(
			inner_space,"circle",start_region_center_x,start_region_center_y,
			region_parameters[p_count].radius,nil,nil,12000,true
		)
		if psx ~= nil then
			p_station = placeStation(psx,psy,"RandomHumanNeutral",faction)
			if p_station.comms_data == nil then
				p_station.comms_data = {}
			end
			p_station.comms_data.friendlyness = random(50,100)
			p_station.comms_data.weapon_available = {}
			p_station.comms_data.weapon_available.Nuke = true
			p_station.comms_data.weapon_available.EMP = true
			p_station.comms_data.weapon_available.Homing = true
			p_station.comms_data.weapon_available.Mine = true
			p_station.comms_data.weapon_available.HVLI = true
			if random(1,100) < 38 then
				p_station.gradual_coolant_replenish = true
			end
			p_station.gradual_repair_max_health = {}
			for i,sys in ipairs(system_types) do
				if random(1,100) < 43 then
					p_station.gradual_repair_max_health[sys] = true
				else
					p_station.gradual_repair_max_health[sys] = false
				end
			end
			p_station:setShortRangeRadarRange(random(5000,20000))
			table.insert(inner_space,{obj=p_station,dist=station_spacing[p_station:getTypeName()].outer_platform,shape="circle"})
			table.insert(inner_stations,p_station)
		end
	end
	start_stations_constructed = true
end
function constructStartTerrain()
	placement_areas = {
		["Start Circle"] = {
			stations = inner_stations, 
			space = inner_space,
			shape = "circle", 
			center_x = start_region_center_x, 
			center_y = start_region_center_y, 
			radius = region_parameters[p_count].radius
		},
	}
	transport_list = {}
	local terrain = {
		{chance = 3,	count = 0,	max = math.random(1,2),		func = placeWormHole,		desc = "Wormhole",			},	--1
		{chance = 2,	count = 0,	max = math.random(1,2),		func = placeStar,			desc = "Star",				},	--2
		{chance = 7,	count = 0,	max = -1,					func = placeProbe,			desc = "Probe",				},	--3
		{chance = 4,	count = 0,	max = math.random(7,15),	func = placeWarpJammer,		desc = "Warp jammer",		},	--4
		{chance = 6,	count = 0,	max = -1,					func = placeSupplyDrop,		desc = "Supply drop",		},	--5
		{chance = 7,	count = 0,	max = math.random(6,15),	func = placeSensorJammer,	desc = "Sensor jammer",		},	--6
		{chance = 7,	count = 0,	max = -1,					func = placeSensorBuoy,		desc = "Sensor buoy",		},	--7
		{chance = 9,	count = 0,	max = -1,					func = placeAdBuoy,			desc = "Ad buoy",			},	--8
		{chance = 8,	count = 0,	max = -1,					func = placeNebula,			desc = "Nebula",			},	--9
		{chance = 5,	count = 0,	max = -1,					func = placeMine,			desc = "Mine",				},	--10
		{chance = 5,	count = 0,	max = math.random(3,9),		func = placeMineField,		desc = "Mine field",		},	--11
		{chance = 5,	count = 0,	max = math.random(2,5),		func = placeAsteroidField,	desc = "Asteroid field",	},	--12
		{chance = 5,	count = 0,	max = math.random(2,5),		func = placeRectMineField,	desc = "Rect Mine Field",	},	--13
		{chance = 6,	count = 0,	max = math.random(2,5),		func = placeAsteroidBlob,	desc = "Asteroid blob",		},	--14
		{chance = 6,	count = 0,	max = math.random(2,5),		func = placeMinefieldBlob,	desc = "Minefield blob",	},	--15
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
					local placement_result = call_function("Start Circle")
					if placement_result then
						terrain_object.count = terrain_object.count + 1
					end
				else
					placeAsteroid("Start Circle")
				end
				break
			elseif i == #terrain then
				placeAsteroid("Start Circle")
			end
		end
		objects_placed_count = objects_placed_count + 1
	until(objects_placed_count >= region_parameters[p_count].clutter)
	start_terrain_constructed = true
end
function constructMidTerrain()
	human_kraylor_angle = random(0,360)
	human_mid_angle = human_kraylor_angle
	if p_count == 1 then
		mid_region_center_x, mid_region_center_y = vectorFromAngle(human_kraylor_angle,region_parameters[p_count].radius * 2,true)
		mid_region_center_x = mid_region_center_x + start_region_center_x
		mid_region_center_y = mid_region_center_y + start_region_center_y
		kraylor_region_center_x, kraylor_region_center_y = vectorFromAngle(human_kraylor_angle,region_parameters[p_count].radius * 2,true)
		kraylor_region_center_x = kraylor_region_center_x + mid_region_center_x
		kraylor_region_center_y = kraylor_region_center_y + mid_region_center_y
	else
		mid_right = false
		human_mid_angle = (human_kraylor_angle - 30) % 360
		human_arlenian_angle = (human_kraylor_angle + 30) % 360
		if random(1,100) < 50 then
			human_mid_angle = (human_kraylor_angle + 30) % 360
			human_arlenian_angle = (human_kraylor_angle - 30) % 360
			mid_right = true
		end
		mid_region_center_x, mid_region_center_y = vectorFromAngle(human_mid_angle,region_parameters[p_count].radius * 2,true)
		mid_region_center_x = mid_region_center_x + start_region_center_x
		mid_region_center_y = mid_region_center_y + start_region_center_y
		arlenian_region_center_x, arlenian_region_center_y = vectorFromAngle(human_arlenian_angle,region_parameters[p_count].radius * 2,true)
		arlenian_region_center_x = arlenian_region_center_x + start_region_center_x
		arlenian_region_center_y = arlenian_region_center_y + start_region_center_y
		if mid_right then
			kraylor_region_center_x, kraylor_region_center_y = vectorFromAngle(human_arlenian_angle,region_parameters[p_count].radius * 2,true)
			kraylor_region_center_x = kraylor_region_center_x + mid_region_center_x
			kraylor_region_center_y = kraylor_region_center_y + mid_region_center_y
		else
			kraylor_region_center_x, kraylor_region_center_y = vectorFromAngle(human_mid_angle,region_parameters[p_count].radius * 2,true)
			kraylor_region_center_x = kraylor_region_center_x + arlenian_region_center_x
			kraylor_region_center_y = kraylor_region_center_y + arlenian_region_center_y
		end
	end
	mid_stations = {}
	mid_space = {}
	space_center[mid_space] = {x = mid_region_center_x,		y = mid_region_center_y}
	--	planet
	local mid_planet_item = tableRemoveRandom(planet_list)
	local mid_planet_radius = mid_planet_item.radius
	mid_planet_x, mid_planet_y = vectorFromAngle(random(0,360),random(0,region_parameters[p_count].radius - (mid_planet_radius * 2)),true)
	mid_planet_x = mid_planet_x + mid_region_center_x
	mid_planet_y = mid_planet_y + mid_region_center_y
	planet_mid_region = Planet():setPosition(mid_planet_x,mid_planet_y):setPlanetRadius(mid_planet_radius)
	planet_mid_region:setDistanceFromMovementPlane(mid_planet_radius*-.3)
	planet_mid_region:setCallSign(tableSelectRandom(mid_planet_item.name))
	planet_mid_region:setPlanetSurfaceTexture(mid_planet_item.texture.surface)
	local rotation_time = random(300,500)
	planet_mid_region:setAxialRotationTime(rotation_time)
	if mid_planet_item.texture.atmosphere ~= nil then
		rotation_time = rotation_time * .65
		planet_mid_region:setPlanetAtmosphereTexture(mid_planet_item.texture.atmosphere)
	end
	if mid_planet_item.texture.cloud ~= nil then
		planet_mid_region:setPlanetCloudTexture(mid_planet_item.texture.cloud)
	end
	if mid_planet_item.color ~= nil then
		planet_mid_region:setPlanetAtmosphereColor(mid_planet_item.color.red,mid_planet_item.color.green,mid_planet_item.color.blue)
	end
	if mid_planet_item.unscanned ~= nil then
		local unscanned_desc = ""
		local scanned_desc = ""
		if type(mid_planet_item.unscanned) == "table" then
			unscanned_desc = mid_planet_item.unscanned[planet_mid_region:getCallSign()]
		else
			unscanned_desc = mid_planet_item.unscanned
		end
		if type(mid_planet_item.scanned) == "table" then
			scanned_desc = mid_planet_item.scanned[planet_mid_region:getCallSign()]
		else
			scanned_desc = mid_planet_item.scanned
		end
		planet_mid_region:setDescriptions(unscanned_desc,scanned_desc)
		planet_mid_region:setScanningParameters(1,2)
	end
	table.insert(mid_space,{obj=planet_mid_region,dist=mid_planet_item.radius,shape="circle"})
	table.insert(planet_collision_list,{planet = planet_mid_region, fudge = 187})
	--	stations
	local mid_factions = {"Human Navy","Independent","Kraylor","Arlenians","Exuari","Ghosts","Ktlitans","USN","TSN","CUF"}
	for i,faction in ipairs(mid_factions) do
		local psx, psy = findClearSpot(
			mid_space,"circle",mid_region_center_x,mid_region_center_y,
			region_parameters[p_count].radius,nil,nil,12000,true
		)
		if psx ~= nil then
			p_station = placeStation(psx,psy,"RandomHumanNeutral",faction)
			if p_station.comms_date == nil then
				p_station.comms_data = {}
			end
			p_station.comms_data.friendlyness = random(1,100)
			if random(1,100) < 38 then
				p_station.gradual_coolant_replenish = true
			end
			p_station.gradual_repair_max_health = {}
			for i,sys in ipairs(system_types) do
				if random(1,100) < 43 then
					p_station.gradual_repair_max_health[sys] = true
				else
					p_station.gradual_repair_max_health[sys] = false
				end
			end
			p_station:setShortRangeRadarRange(random(5000,20000))
			table.insert(mid_space,{obj=p_station,dist=station_spacing[p_station:getTypeName()].outer_platform,shape="circle"})
			table.insert(mid_stations,p_station)
		end
	end
	local a_x, a_y = findClearSpot(
		mid_space,"circle",mid_region_center_x,mid_region_center_y,
		region_parameters[p_count].radius,nil,nil,100
	)
	if a_x ~= nil then
		local a = createCriticalArtifact(a_x,a_y)
		table.insert(mid_space,{obj=a,dist=200,shape="circle"})
	else
		print("could not find a place for primary artifact")
	end
	if p_count > 3 then
		a_x, a_y = findClearSpot(
			mid_space,"circle",mid_region_center_x,mid_region_center_y,
			region_parameters[p_count].radius,nil,nil,100
		)
		if a_x ~= nil then
			local a = createCriticalArtifact(a_x,a_y)
			table.insert(mid_space,{obj=a,dist=200,shape="circle"})
		else
			print("could not find a place for tertiary artifact")	--2nd: Arlenian region
		end
	end
	placement_areas["Mid Circle"] = {
		stations = mid_stations, 
		space = mid_space,
		shape = "circle", 
		center_x = mid_region_center_x, 
		center_y = mid_region_center_y, 
		radius = region_parameters[p_count].radius
	}
	local terrain = {
		{chance = 3,	count = 0,	max = math.random(1,2),		func = placeWormHole,		desc = "Wormhole",			},	--1
		{chance = 2,	count = 0,	max = math.random(1,2),		func = placeStar,			desc = "Star",				},	--2
		{chance = 7,	count = 0,	max = -1,					func = placeProbe,			desc = "Probe",				},	--3
		{chance = 4,	count = 0,	max = math.random(7,15),	func = placeWarpJammer,		desc = "Warp jammer",		},	--4
		{chance = 6,	count = 0,	max = -1,					func = placeSupplyDrop,		desc = "Supply drop",		},	--5
		{chance = 7,	count = 0,	max = math.random(6,15),	func = placeSensorJammer,	desc = "Sensor jammer",		},	--6
		{chance = 7,	count = 0,	max = -1,					func = placeSensorBuoy,		desc = "Sensor buoy",		},	--7
		{chance = 9,	count = 0,	max = -1,					func = placeAdBuoy,			desc = "Ad buoy",			},	--8
		{chance = 8,	count = 0,	max = -1,					func = placeNebula,			desc = "Nebula",			},	--9
		{chance = 5,	count = 0,	max = -1,					func = placeMine,			desc = "Mine",				},	--10
		{chance = 5,	count = 0,	max = math.random(3,9),		func = placeMineField,		desc = "Mine field",		},	--11
		{chance = 5,	count = 0,	max = math.random(2,5),		func = placeAsteroidField,	desc = "Asteroid field",	},	--12
		{chance = 5,	count = 0,	max = math.random(2,5),		func = placeRectMineField,	desc = "Rect Mine Field",	},	--13
		{chance = 6,	count = 0,	max = math.random(2,5),		func = placeAsteroidBlob,	desc = "Asteroid blob",		},	--14
		{chance = 6,	count = 0,	max = math.random(2,5),		func = placeMinefieldBlob,	desc = "Minefield blob",	},	--15
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
					local placement_result = call_function("Mid Circle")
					if placement_result then
						terrain_object.count = terrain_object.count + 1
					end
				else
					placeAsteroid("Mid Circle")
				end
				break
			elseif i == #terrain then
				placeAsteroid("Mid Circle")
			end
		end
		objects_placed_count = objects_placed_count + 1
	until(objects_placed_count >= region_parameters[p_count].clutter)
	mid_terrain_constructed = true
end
function constructKraylorTerrain()
	kraylor_stations = {}
	kraylor_space = {}
	space_center[kraylor_space] = {x = kraylor_region_center_x,		y = kraylor_region_center_y}
	kraylor_headquarters = placeStation(kraylor_region_center_x,kraylor_region_center_y,"RandomGenericSinister","Kraylor")
	table.insert(kraylor_space,{obj=kraylor_headquarters,dist=station_spacing[kraylor_headquarters:getTypeName()].outer_platform,shape="circle"})
	table.insert(kraylor_stations,kraylor_headquarters)
	createOrbitingDefenses(kraylor_headquarters,6)
	local kraylor_planet_item = tableRemoveRandom(planet_list)
	local kraylor_planet_radius = kraylor_planet_item.radius
	local p_x, p_y = findClearSpot(
		kraylor_space,"circle",kraylor_region_center_x,kraylor_region_center_y,
		region_parameters[p_count].radius - kraylor_planet_radius,nil,nil,kraylor_planet_radius
	)
	if p_x ~= nil then
		local rotation_time = random(300,500)
		planet_kraylor_region = Planet():setPosition(p_x,p_y):setPlanetRadius(kraylor_planet_radius)
		planet_kraylor_region
			:setDistanceFromMovementPlane(kraylor_planet_radius*-.3)
			:setCallSign(tableSelectRandom(kraylor_planet_item.name))
			:setPlanetSurfaceTexture(kraylor_planet_item.texture.surface)
			:setAxialRotationTime(rotation_time)
		if kraylor_planet_item.texture.atmosphere ~= nil then
			rotation_time = rotation_time * .65
			planet_kraylor_region:setPlanetAtmosphereTexture(kraylor_planet_item.texture.atmosphere)
		end
		if kraylor_planet_item.texture.cloud ~= nil then
			planet_kraylor_region:setPlanetCloudTexture(kraylor_planet_item.texture.cloud)
		end
		if kraylor_planet_item.color ~= nil then
			planet_kraylor_region:setPlanetAtmosphereColor(kraylor_planet_item.color.red,kraylor_planet_item.color.green,kraylor_planet_item.color.blue)
		end
		if kraylor_planet_item.unscanned ~= nil then
			local unscanned_desc = ""
			local scanned_desc = ""
			if type(kraylor_planet_item.unscanned) == "table" then
				unscanned_desc = kraylor_planet_item.unscanned[planet_kraylor_region:getCallSign()]
			else
				unscanned_desc = kraylor_planet_item.unscanned
			end
			if type(kraylor_planet_item.scanned) == "table" then
				scanned_desc = kraylor_planet_item.scanned[planet_kraylor_region:getCallSign()]
			else
				scanned_desc = kraylor_planet_item.scanned
			end
			planet_kraylor_region:setDescriptions(unscanned_desc,scanned_desc)
			planet_kraylor_region:setScanningParameters(1,2)
		end
		table.insert(kraylor_space,{obj=planet_kraylor_region,dist=kraylor_planet_item.radius,shape="circle"})
		table.insert(planet_collision_list,{planet = planet_kraylor_region, fudge = 187})
	end
	for i,faction in ipairs(region_parameters[p_count].kraylor_factions) do
		local psx, psy = findClearSpot(
			kraylor_space,"circle",kraylor_region_center_x,kraylor_region_center_y,
			region_parameters[p_count].radius,nil,nil,12000,true
		)
		if psx ~= nil then
			p_station = placeStation(psx,psy,"RandomGenericSinister",faction)
			if p_station.comms_data == nil then
				p_station.comms_data = {}
			end
			p_station.comms_data.friendlyness = random(1,100)
			p_station.comms_data.weapon_available = {}
			p_station.comms_data.weapon_available.Nuke = true
			p_station.comms_data.weapon_available.EMP = true
			p_station.comms_data.weapon_available.Homing = true
			p_station.comms_data.weapon_available.Mine = true
			p_station.comms_data.weapon_available.HVLI = true
			if random(1,100) < 38 then
				p_station.gradual_coolant_replenish = true
			end
			p_station.gradual_repair_max_health = {}
			for i,sys in ipairs(system_types) do
				if random(1,100) < 43 then
					p_station.gradual_repair_max_health[sys] = true
				else
					p_station.gradual_repair_max_health[sys] = false
				end
			end
			p_station:setShortRangeRadarRange(random(5000,20000))
			table.insert(kraylor_space,{obj=p_station,dist=station_spacing[p_station:getTypeName()].outer_platform,shape="circle"})
			table.insert(kraylor_stations,p_station)
		end
	end
	placement_areas["Kraylor Circle"] = {
		stations = kraylor_stations, 
		space = kraylor_space,
		shape = "circle", 
		center_x = kraylor_region_center_x, 
		center_y = kraylor_region_center_y, 
		radius = region_parameters[p_count].radius
	}
	local terrain = {
		{chance = 3,	count = 0,	max = math.random(1,2),		func = placeWormHole,		desc = "Wormhole",			},	--1
		{chance = 2,	count = 0,	max = math.random(1,2),		func = placeStar,			desc = "Star",				},	--2
		{chance = 7,	count = 0,	max = -1,					func = placeProbe,			desc = "Probe",				},	--3
		{chance = 4,	count = 0,	max = math.random(7,15),	func = placeWarpJammer,		desc = "Warp jammer",		},	--4
		{chance = 6,	count = 0,	max = -1,					func = placeSupplyDrop,		desc = "Supply drop",		},	--5
		{chance = 7,	count = 0,	max = math.random(6,15),	func = placeSensorJammer,	desc = "Sensor jammer",		},	--6
		{chance = 7,	count = 0,	max = -1,					func = placeSensorBuoy,		desc = "Sensor buoy",		},	--7
		{chance = 9,	count = 0,	max = -1,					func = placeAdBuoy,			desc = "Ad buoy",			},	--8
		{chance = 8,	count = 0,	max = -1,					func = placeNebula,			desc = "Nebula",			},	--9
		{chance = 5,	count = 0,	max = -1,					func = placeMine,			desc = "Mine",				},	--10
		{chance = 5,	count = 0,	max = math.random(3,9),		func = placeMineField,		desc = "Mine field",		},	--11
		{chance = 5,	count = 0,	max = math.random(2,5),		func = placeAsteroidField,	desc = "Asteroid field",	},	--12
		{chance = 5,	count = 0,	max = math.random(2,5),		func = placeRectMineField,	desc = "Rect Mine Field",	},	--13
		{chance = 6,	count = 0,	max = math.random(2,5),		func = placeAsteroidBlob,	desc = "Asteroid blob",		},	--14
		{chance = 6,	count = 0,	max = math.random(2,5),		func = placeMinefieldBlob,	desc = "Minefield blob",	},	--15
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
					local placement_result = call_function("Kraylor Circle")
					if placement_result then
						terrain_object.count = terrain_object.count + 1
					end
				else
					placeAsteroid("Kraylor Circle")
				end
				break
			elseif i == #terrain then
				placeAsteroid("Kraylor Circle")
			end
		end
		objects_placed_count = objects_placed_count + 1
	until(objects_placed_count >= region_parameters[p_count].clutter)
	kraylor_terrain_constructed = true
end
function constructArlenianTerrain()
	arlenian_terrain_constructed = true
	if arlenian_region_center_x == nil then
		return
	end
	arlenian_stations = {}
	arlenian_space = {}
	space_station[arlenian_space] = arlenian_stations
	for i,s in ipairs(spaces) do
		if i > 1 then
			table.insert(s,arlenian_space)
		end
	end
	space_center[arlenian_space] = {x = arlenian_region_center_x,		y = arlenian_region_center_y}
	arlenian_headquarters = placeStation(arlenian_region_center_x,arlenian_region_center_y,"RandomHumanNeutral","Arlenians")
	table.insert(arlenian_space,{obj=arlenian_headquarters,dist=station_spacing[arlenian_headquarters:getTypeName()].outer_platform,shape="circle"})
	table.insert(arlenian_stations,arlenian_headquarters)
	createOrbitingDefenses(arlenian_headquarters,6)
	local arlenian_planet_item = tableRemoveRandom(planet_list)
	local arlenian_planet_radius = arlenian_planet_item.radius
	local p_x, p_y = findClearSpot(
		arlenian_space,"circle",arlenian_region_center_x,arlenian_region_center_y,
		region_parameters[p_count].radius - arlenian_planet_radius,nil,nil,arlenian_planet_radius
	)
	if p_x ~= nil then
		local rotation_time = random(300,500)
		planet_arlenian_region = Planet():setPosition(p_x,p_y):setPlanetRadius(arlenian_planet_radius)
		planet_arlenian_region
			:setDistanceFromMovementPlane(arlenian_planet_radius*-.3)
			:setCallSign(tableSelectRandom(arlenian_planet_item.name))
			:setPlanetSurfaceTexture(arlenian_planet_item.texture.surface)
			:setAxialRotationTime(rotation_time)
		if arlenian_planet_item.texture.atmosphere ~= nil then
			rotation_time = rotation_time * .65
			planet_arlenian_region:setPlanetAtmosphereTexture(arlenian_planet_item.texture.atmosphere)
		end
		if arlenian_planet_item.texture.cloud ~= nil then
			planet_arlenian_region:setPlanetCloudTexture(arlenian_planet_item.texture.cloud)
		end
		if arlenian_planet_item.color ~= nil then
			planet_arlenian_region:setPlanetAtmosphereColor(arlenian_planet_item.color.red,arlenian_planet_item.color.green,arlenian_planet_item.color.blue)
		end
		if arlenian_planet_item.unscanned ~= nil then
			local unscanned_desc = ""
			local scanned_desc = ""
			if type(arlenian_planet_item.unscanned) == "table" then
				unscanned_desc = arlenian_planet_item.unscanned[planet_arlenian_region:getCallSign()]
			else
				unscanned_desc = arlenian_planet_item.unscanned
			end
			if type(arlenian_planet_item.scanned) == "table" then
				scanned_desc = arlenian_planet_item.scanned[planet_arlenian_region:getCallSign()]
			else
				scanned_desc = arlenian_planet_item.scanned
			end
			planet_arlenian_region:setDescriptions(unscanned_desc,scanned_desc)
			planet_arlenian_region:setScanningParameters(1,2)
		end
		table.insert(arlenian_space,{obj=planet_arlenian_region,dist=arlenian_planet_item.radius,shape="circle"})
		table.insert(planet_collision_list,{planet = planet_arlenian_region, fudge = 187})
	end
	for i,faction in ipairs(region_parameters[p_count].arlenian_factions) do
		local psx, psy = findClearSpot(
			arlenian_space,"circle",arlenian_region_center_x,arlenian_region_center_y,
			region_parameters[p_count].radius,nil,nil,12000,true
		)
		if psx ~= nil then
			p_station = placeStation(psx,psy,"Generic",faction)
			if p_station.comms_data == nil then
				p_station.comms_data = {}
			end
			p_station.comms_data.friendlyness = random(1,100)
			p_station.comms_data.weapon_available = {}
			p_station.comms_data.weapon_available.Nuke = true
			p_station.comms_data.weapon_available.EMP = true
			p_station.comms_data.weapon_available.Homing = true
			p_station.comms_data.weapon_available.Mine = true
			p_station.comms_data.weapon_available.HVLI = true
			if random(1,100) < 38 then
				p_station.gradual_coolant_replenish = true
			end
			p_station.gradual_repair_max_health = {}
			for i,sys in ipairs(system_types) do
				if random(1,100) < 43 then
					p_station.gradual_repair_max_health[sys] = true
				else
					p_station.gradual_repair_max_health[sys] = false
				end
			end
			p_station:setShortRangeRadarRange(random(5000,20000))
			table.insert(arlenian_space,{obj=p_station,dist=station_spacing[p_station:getTypeName()].outer_platform,shape="circle"})
			table.insert(arlenian_stations,p_station)
		end
	end
	if p_count > 2 then
		a_x, a_y = findClearSpot(
			arlenian_space,"circle",arlenian_region_center_x,arlenian_region_center_y,
			region_parameters[p_count].radius,nil,nil,100
		)
		if a_x ~= nil then
			local a = createCriticalArtifact(a_x,a_y)
			table.insert(arlenian_space,{obj=a,dist=200,shape="circle"})
		else
			print("could not find a place for secondary artifact")
		end
	end
	placement_areas["Arlenian Circle"] = {
		stations = arlenian_stations, 
		space = arlenian_space,
		shape = "circle", 
		center_x = arlenian_region_center_x, 
		center_y = arlenian_region_center_y, 
		radius = region_parameters[p_count].radius
	}
	local terrain = {
		{chance = 3,	count = 0,	max = math.random(1,2),		func = placeWormHole,		desc = "Wormhole",			},	--1
		{chance = 2,	count = 0,	max = math.random(1,2),		func = placeStar,			desc = "Star",				},	--2
		{chance = 7,	count = 0,	max = -1,					func = placeProbe,			desc = "Probe",				},	--3
		{chance = 4,	count = 0,	max = math.random(7,15),	func = placeWarpJammer,		desc = "Warp jammer",		},	--4
		{chance = 6,	count = 0,	max = -1,					func = placeSupplyDrop,		desc = "Supply drop",		},	--5
		{chance = 7,	count = 0,	max = math.random(6,15),	func = placeSensorJammer,	desc = "Sensor jammer",		},	--6
		{chance = 7,	count = 0,	max = -1,					func = placeSensorBuoy,		desc = "Sensor buoy",		},	--7
		{chance = 9,	count = 0,	max = -1,					func = placeAdBuoy,			desc = "Ad buoy",			},	--8
		{chance = 8,	count = 0,	max = -1,					func = placeNebula,			desc = "Nebula",			},	--9
		{chance = 5,	count = 0,	max = -1,					func = placeMine,			desc = "Mine",				},	--10
		{chance = 5,	count = 0,	max = math.random(3,9),		func = placeMineField,		desc = "Mine field",		},	--11
		{chance = 5,	count = 0,	max = math.random(2,5),		func = placeAsteroidField,	desc = "Asteroid field",	},	--12
		{chance = 5,	count = 0,	max = math.random(2,5),		func = placeRectMineField,	desc = "Rect Mine Field",	},	--13
		{chance = 6,	count = 0,	max = math.random(2,5),		func = placeAsteroidBlob,	desc = "Asteroid blob",		},	--14
		{chance = 6,	count = 0,	max = math.random(2,5),		func = placeMinefieldBlob,	desc = "Minefield blob",	},	--15
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
					local placement_result = call_function("Arlenian Circle")
					if placement_result then
						terrain_object.count = terrain_object.count + 1
					end
				else
					placeAsteroid("Arlenian Circle")
				end
				break
			elseif i == #terrain then
				placeAsteroid("Arlenian Circle")
			end
		end
		objects_placed_count = objects_placed_count + 1
	until(objects_placed_count >= region_parameters[p_count].clutter)
end
function constructKtlitanTerrain()
	ktlitan_terrain_constructed = true
	if p_count < 5 then
		return
	end
	human_ktlitan_angle = (human_kraylor_angle + random(90,180)) % 360
	ktlitan_region_center_x, ktlitan_region_center_y = vectorFromAngle(human_ktlitan_angle,region_parameters[p_count].radius * 2,true)
	ktlitan_region_center_x = ktlitan_region_center_x + start_region_center_x
	ktlitan_region_center_y = ktlitan_region_center_y + start_region_center_y
	ktlitan_stations = {}
	ktlitan_space = {}
	space_station[ktlitan_space] = ktlitan_stations
	for i,s in ipairs(spaces) do
		if i > 4 then
			table.insert(s,ktlitan_space)
		end
	end
	space_center[ktlitan_space] = {x = ktlitan_region_center_x,		y = ktlitan_region_center_y}
	ktlitan_headquarters = placeStation(ktlitan_region_center_x,ktlitan_region_center_y,"RandomGenericSinister","Ktlitans")
	table.insert(ktlitan_space,{obj=ktlitan_headquarters,dist=station_spacing[ktlitan_headquarters:getTypeName()].outer_platform,shape="circle"})
	table.insert(ktlitan_stations,ktlitan_headquarters)
	createOrbitingDefenses(ktlitan_headquarters,6)
	local ktlitan_planet_item = tableRemoveRandom(planet_list)
	local ktlitan_planet_radius = ktlitan_planet_item.radius
	local p_x, p_y = findClearSpot(
		ktlitan_space,"circle",ktlitan_region_center_x,ktlitan_region_center_y,
		region_parameters[p_count].radius - ktlitan_planet_radius,nil,nil,ktlitan_planet_radius
	)
	if p_x ~= nil then
		local rotation_time = random(300,500)
		planet_ktlitan_region = Planet():setPosition(p_x,p_y):setPlanetRadius(ktlitan_planet_radius)
		planet_ktlitan_region
			:setDistanceFromMovementPlane(ktlitan_planet_radius*-.3)
			:setCallSign(tableSelectRandom(ktlitan_planet_item.name))
			:setPlanetSurfaceTexture(ktlitan_planet_item.texture.surface)
			:setAxialRotationTime(rotation_time)
		if ktlitan_planet_item.texture.atmosphere ~= nil then
			rotation_time = rotation_time * .65
			planet_ktlitan_region:setPlanetAtmosphereTexture(ktlitan_planet_item.texture.atmosphere)
		end
		if ktlitan_planet_item.texture.cloud ~= nil then
			planet_ktlitan_region:setPlanetCloudTexture(ktlitan_planet_item.texture.cloud)
		end
		if ktlitan_planet_item.color ~= nil then
			planet_ktlitan_region:setPlanetAtmosphereColor(ktlitan_planet_item.color.red,ktlitan_planet_item.color.green,ktlitan_planet_item.color.blue)
		end
		if ktlitan_planet_item.unscanned ~= nil then
			local unscanned_desc = ""
			local scanned_desc = ""
			if type(ktlitan_planet_item.unscanned) == "table" then
				unscanned_desc = ktlitan_planet_item.unscanned[planet_ktlitan_region:getCallSign()]
			else
				unscanned_desc = ktlitan_planet_item.unscanned
			end
			if type(ktlitan_planet_item.scanned) == "table" then
				scanned_desc = ktlitan_planet_item.scanned[planet_ktlitan_region:getCallSign()]
			else
				scanned_desc = ktlitan_planet_item.scanned
			end
			planet_ktlitan_region:setDescriptions(unscanned_desc,scanned_desc)
			planet_ktlitan_region:setScanningParameters(1,2)
		end
		table.insert(ktlitan_space,{obj=planet_ktlitan_region,dist=ktlitan_planet_radius,shape="circle"})
		table.insert(planet_collision_list,{planet = planet_ktlitan_region, fudge = 187})
	end
	for i,faction in ipairs(region_parameters[p_count].ktlitan_factions) do
		local psx, psy = findClearSpot(
			ktlitan_space,"circle",ktlitan_region_center_x,ktlitan_region_center_y,
			region_parameters[p_count].radius,nil,nil,12000,true
		)
		if psx ~= nil then
			p_station = placeStation(psx,psy,"RandomGenericSinister",faction)
			if p_station.comms_data == nil then
				p_station.comms_data = {}
			end
			p_station.comms_data.friendlyness = random(1,100)
			p_station.comms_data.weapon_available = {}
			p_station.comms_data.weapon_available.Nuke = true
			p_station.comms_data.weapon_available.EMP = true
			p_station.comms_data.weapon_available.Homing = true
			p_station.comms_data.weapon_available.Mine = true
			p_station.comms_data.weapon_available.HVLI = true
			if random(1,100) < 38 then
				p_station.gradual_coolant_replenish = true
			end
			p_station.gradual_repair_max_health = {}
			for i,sys in ipairs(system_types) do
				if random(1,100) < 43 then
					p_station.gradual_repair_max_health[sys] = true
				else
					p_station.gradual_repair_max_health[sys] = false
				end
			end
			p_station:setShortRangeRadarRange(random(5000,20000))
			table.insert(ktlitan_space,{obj=p_station,dist=station_spacing[p_station:getTypeName()].outer_platform,shape="circle"})
			table.insert(kraylor_stations,p_station)
		end
	end
	placement_areas["Ktlitan Circle"] = {
		stations = ktlitan_stations, 
		space = ktlitan_space,
		shape = "circle", 
		center_x = ktlitan_region_center_x, 
		center_y = ktlitan_region_center_y, 
		radius = region_parameters[p_count].radius
	}
	local terrain = {
		{chance = 3,	count = 0,	max = math.random(1,2),		func = placeWormHole,		desc = "Wormhole",			},	--1
		{chance = 2,	count = 0,	max = math.random(1,2),		func = placeStar,			desc = "Star",				},	--2
		{chance = 7,	count = 0,	max = -1,					func = placeProbe,			desc = "Probe",				},	--3
		{chance = 4,	count = 0,	max = math.random(7,15),	func = placeWarpJammer,		desc = "Warp jammer",		},	--4
		{chance = 6,	count = 0,	max = -1,					func = placeSupplyDrop,		desc = "Supply drop",		},	--5
		{chance = 7,	count = 0,	max = math.random(6,15),	func = placeSensorJammer,	desc = "Sensor jammer",		},	--6
		{chance = 7,	count = 0,	max = -1,					func = placeSensorBuoy,		desc = "Sensor buoy",		},	--7
		{chance = 9,	count = 0,	max = -1,					func = placeAdBuoy,			desc = "Ad buoy",			},	--8
		{chance = 8,	count = 0,	max = -1,					func = placeNebula,			desc = "Nebula",			},	--9
		{chance = 5,	count = 0,	max = -1,					func = placeMine,			desc = "Mine",				},	--10
		{chance = 5,	count = 0,	max = math.random(3,9),		func = placeMineField,		desc = "Mine field",		},	--11
		{chance = 5,	count = 0,	max = math.random(2,5),		func = placeAsteroidField,	desc = "Asteroid field",	},	--12
		{chance = 5,	count = 0,	max = math.random(2,5),		func = placeRectMineField,	desc = "Rect Mine Field",	},	--13
		{chance = 6,	count = 0,	max = math.random(2,5),		func = placeAsteroidBlob,	desc = "Asteroid blob",		},	--14
		{chance = 6,	count = 0,	max = math.random(2,5),		func = placeMinefieldBlob,	desc = "Minefield blob",	},	--15
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
					local placement_result = call_function("Ktlitan Circle")
					if placement_result then
						terrain_object.count = terrain_object.count + 1
					end
				else
					placeAsteroid("Ktlitan Circle")
				end
				break
			elseif i == #terrain then
				placeAsteroid("Ktlitan Circle")
			end
		end
		objects_placed_count = objects_placed_count + 1
	until(objects_placed_count >= region_parameters[p_count].clutter)
end
function constructAuxTerrain()
	aux_terrain_constructed = true
	if p_count < 7 then
		return
	end
	local range_angle = human_mid_angle
	if mid_right then
		range_angle = human_arlenian_angle
	end
	local aux_angle = (((range_angle - human_ktlitan_angle) / 2) + human_ktlitan_angle) % 360
	if range_angle < human_ktlitan_angle then
		aux_angle = ((((range_angle + 360) - human_ktlitan_angle) / 2) + human_ktlitan_angle) % 360
	end
	aux_region_center_x, aux_region_center_y = vectorFromAngle(aux_angle,region_parameters[p_count].radius * 2,true)
	aux_region_center_x = aux_region_center_x + start_region_center_x
	aux_region_center_y = aux_region_center_y + start_region_center_y
	aux_stations = {}
	aux_space = {}
	space_station[aux_space] = aux_stations
	for i,s in ipairs(spaces) do
		if i > 6 then
			table.insert(s,aux_space)
		end
	end
	space_center[aux_space] = {x = aux_region_center_x,		y = aux_region_center_y}
	local aux_planet_item = tableRemoveRandom(planet_list)
	local aux_planet_radius = aux_planet_item.radius
	local p_x, p_y = findClearSpot(
		aux_space,"circle",aux_region_center_x, aux_region_center_y,
		region_parameters[p_count].radius - aux_planet_radius,nil,nil,aux_planet_radius
	)
	if p_x ~= nil then
		local rotation_time = random(300,500)
		planet_aux_region = Planet():setPosition(p_x,p_y):setPlanetRadius(aux_planet_radius)
		planet_aux_region
			:setDistanceFromMovementPlane(aux_planet_radius*-.3)
			:setCallSign(tableSelectRandom(aux_planet_item.name))
			:setPlanetSurfaceTexture(aux_planet_item.texture.surface)
			:setAxialRotationTime(rotation_time)
		if aux_planet_item.texture.atmosphere ~= nil then
			rotation_time = rotation_time * .65
			planet_aux_region:setPlanetAtmosphereTexture(aux_planet_item.texture.atmosphere)
		end
		if aux_planet_item.texture.cloud ~= nil then
			planet_aux_region:setPlanetCloudTexture(aux_planet_item.texture.cloud)
		end
		if aux_planet_item.color ~= nil then
			planet_aux_region:setPlanetAtmosphereColor(aux_planet_item.color.red,aux_planet_item.color.green,aux_planet_item.color.blue)
		end
		if aux_planet_item.unscanned ~= nil then
			local unscanned_desc = ""
			local scanned_desc = ""
			if type(aux_planet_item.unscanned) == "table" then
				unscanned_desc = aux_planet_item.unscanned[planet_aux_region:getCallSign()]
			else
				unscanned_desc = aux_planet_item.unscanned
			end
			if type(aux_planet_item.scanned) == "table" then
				scanned_desc = aux_planet_item.scanned[planet_aux_region:getCallSign()]
			else
				scanned_desc = aux_planet_item.scanned
			end
			planet_aux_region:setDescriptions(unscanned_desc,scanned_desc)
			planet_aux_region:setScanningParameters(1,2)
		end
		table.insert(aux_space,{obj=planet_aux_region,dist=aux_planet_radius,shape="circle"})
		table.insert(planet_collision_list,{planet = planet_aux_region, fudge = 187})
	end
	local aux_factions = {"Human Navy","Independent","Kraylor","Arlenians","Exuari","Ghosts","Ktlitans","USN","TSN","CUF"}
	for i,faction in ipairs(aux_factions) do
		local psx, psy = findClearSpot(
			aux_space,"circle",aux_region_center_x,aux_region_center_y,
			region_parameters[p_count].radius,nil,nil,12000,true
		)
		if psx ~= nil then
			p_station = placeStation(psx,psy,"RandomHumanNeutral",faction)
			if p_station.comms_date == nil then
				p_station.comms_data = {}
			end
			p_station.comms_data.friendlyness = random(1,100)
			if random(1,100) < 38 then
				p_station.gradual_coolant_replenish = true
			end
			p_station.gradual_repair_max_health = {}
			for i,sys in ipairs(system_types) do
				if random(1,100) < 43 then
					p_station.gradual_repair_max_health[sys] = true
				else
					p_station.gradual_repair_max_health[sys] = false
				end
			end
			p_station:setShortRangeRadarRange(random(5000,20000))
			table.insert(aux_space,{obj=p_station,dist=station_spacing[p_station:getTypeName()].outer_platform,shape="circle"})
			table.insert(aux_stations,p_station)
		end
	end
	local a_x, a_y = findClearSpot(
		aux_space,"circle",aux_region_center_x,aux_region_center_y,
		region_parameters[p_count].radius,nil,nil,100
	)
	if a_x ~= nil then
		local a = createCriticalArtifact(a_x,a_y)
		table.insert(aux_space,{obj=a,dist=200,shape="circle"})
	else
		print("could not find a place for quaternary artifact")
	end
	if p_count > 7 then
		a_x, a_y = findClearSpot(
			mid_space,"circle",mid_region_center_x,mid_region_center_y,
			region_parameters[p_count].radius,nil,nil,100
		)
		if a_x ~= nil then
			local a = createCriticalArtifact(a_x,a_y)
			table.insert(mid_space,{obj=a,dist=200,shape="circle"})
		else
			print("could not find a place for quinary artifact")	
		end
	end
	placement_areas["Aux Circle"] = {
		stations = aux_stations, 
		space = aux_space,
		shape = "circle", 
		center_x = aux_region_center_x, 
		center_y = aux_region_center_y, 
		radius = region_parameters[p_count].radius
	}
	local terrain = {
		{chance = 3,	count = 0,	max = math.random(1,2),		func = placeWormHole,		desc = "Wormhole",			},	--1
		{chance = 2,	count = 0,	max = math.random(1,2),		func = placeStar,			desc = "Star",				},	--2
		{chance = 7,	count = 0,	max = -1,					func = placeProbe,			desc = "Probe",				},	--3
		{chance = 4,	count = 0,	max = math.random(7,15),	func = placeWarpJammer,		desc = "Warp jammer",		},	--4
		{chance = 6,	count = 0,	max = -1,					func = placeSupplyDrop,		desc = "Supply drop",		},	--5
		{chance = 7,	count = 0,	max = math.random(6,15),	func = placeSensorJammer,	desc = "Sensor jammer",		},	--6
		{chance = 7,	count = 0,	max = -1,					func = placeSensorBuoy,		desc = "Sensor buoy",		},	--7
		{chance = 9,	count = 0,	max = -1,					func = placeAdBuoy,			desc = "Ad buoy",			},	--8
		{chance = 8,	count = 0,	max = -1,					func = placeNebula,			desc = "Nebula",			},	--9
		{chance = 5,	count = 0,	max = -1,					func = placeMine,			desc = "Mine",				},	--10
		{chance = 5,	count = 0,	max = math.random(3,9),		func = placeMineField,		desc = "Mine field",		},	--11
		{chance = 5,	count = 0,	max = math.random(2,5),		func = placeAsteroidField,	desc = "Asteroid field",	},	--12
		{chance = 5,	count = 0,	max = math.random(2,5),		func = placeRectMineField,	desc = "Rect Mine Field",	},	--13
		{chance = 6,	count = 0,	max = math.random(2,5),		func = placeAsteroidBlob,	desc = "Asteroid blob",		},	--14
		{chance = 6,	count = 0,	max = math.random(2,5),		func = placeMinefieldBlob,	desc = "Minefield blob",	},	--15
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
					local placement_result = call_function("Aux Circle")
					if placement_result then
						terrain_object.count = terrain_object.count + 1
					end
				else
					placeAsteroid("Aux Circle")
				end
				break
			elseif i == #terrain then
				placeAsteroid("Aux Circle")
			end
		end
		objects_placed_count = objects_placed_count + 1
	until(objects_placed_count >= region_parameters[p_count].clutter)
end
function createCriticalArtifact(x,y)
	local scanned_desc = _("scienceDescription-artifact","Clearly advanced technology that could be useful to us or to the Kraylor.")
	if starting_players > 4 then
		scanned_desc = _("scienceDescription-artifact","Clearly advanced technology that could be useful to us, the Kraylor, or the Ktlitans.")
	end
	local a = Artifact():setPosition(x,y):setDescriptions("Uncategorized technology",scanned_desc)
	a:setScanningParameters(math.random(2,3),math.random(2,3))
	if critical_artifact_id == nil then
		critical_artifact_id = 0
	end
	critical_artifact_id = critical_artifact_id + 1
	a.critical_artifact_id = critical_artifact_id
	a:onCollision(function(self,collider)
		string.format("")
		local sd = .01	--shield damage
		if collider ~= nil and collider:isValid() then
			local sc = collider:getShieldCount()	--shield count
			if sc > 0 then
				if sc == 1 then
					collider:setShields(
						math.max(0,collider:getShieldLevel(0) - (collider:getShieldMax(0) * sd))
					)
				elseif sc == 2 then
					collider:setShields(
						math.max(0,collider:getShieldLevel(0) - (collider:getShieldMax(0) * sd)),
						math.max(0,collider:getShieldLevel(1) - (collider:getShieldMax(1) * sd))
					)
				elseif sc == 3 then
					collider:setShields(
						math.max(0,collider:getShieldLevel(0) - (collider:getShieldMax(0) * sd)),
						math.max(0,collider:getShieldLevel(1) - (collider:getShieldMax(1) * sd)),
						math.max(0,collider:getShieldLevel(2) - (collider:getShieldMax(2) * sd))
					)
				elseif sc == 4 then
					collider:setShields(
						math.max(0,collider:getShieldLevel(0) - (collider:getShieldMax(0) * sd)),
						math.max(0,collider:getShieldLevel(1) - (collider:getShieldMax(1) * sd)),
						math.max(0,collider:getShieldLevel(2) - (collider:getShieldMax(2) * sd)),
						math.max(0,collider:getShieldLevel(3) - (collider:getShieldMax(3) * sd))
					)
				elseif sc == 5 then
					collider:setShields(
						math.max(0,collider:getShieldLevel(0) - (collider:getShieldMax(0) * sd)),
						math.max(0,collider:getShieldLevel(1) - (collider:getShieldMax(1) * sd)),
						math.max(0,collider:getShieldLevel(2) - (collider:getShieldMax(2) * sd)),
						math.max(0,collider:getShieldLevel(3) - (collider:getShieldMax(3) * sd)),
						math.max(0,collider:getShieldLevel(4) - (collider:getShieldMax(4) * sd))
					)
				elseif sc == 6 then
					collider:setShields(
						math.max(0,collider:getShieldLevel(0) - (collider:getShieldMax(0) * sd)),
						math.max(0,collider:getShieldLevel(1) - (collider:getShieldMax(1) * sd)),
						math.max(0,collider:getShieldLevel(2) - (collider:getShieldMax(2) * sd)),
						math.max(0,collider:getShieldLevel(3) - (collider:getShieldMax(3) * sd)),
						math.max(0,collider:getShieldLevel(4) - (collider:getShieldMax(4) * sd)),
						math.max(0,collider:getShieldLevel(5) - (collider:getShieldMax(5) * sd))
					)
				elseif sc == 7 then
					collider:setShields(
						math.max(0,collider:getShieldLevel(0) - (collider:getShieldMax(0) * sd)),
						math.max(0,collider:getShieldLevel(1) - (collider:getShieldMax(1) * sd)),
						math.max(0,collider:getShieldLevel(2) - (collider:getShieldMax(2) * sd)),
						math.max(0,collider:getShieldLevel(3) - (collider:getShieldMax(3) * sd)),
						math.max(0,collider:getShieldLevel(4) - (collider:getShieldMax(4) * sd)),
						math.max(0,collider:getShieldLevel(5) - (collider:getShieldMax(5) * sd)),
						math.max(0,collider:getShieldLevel(6) - (collider:getShieldMax(6) * sd))
					)
				elseif sc == 8 then
					collider:setShields(
						math.max(0,collider:getShieldLevel(0) - (collider:getShieldMax(0) * sd)),
						math.max(0,collider:getShieldLevel(1) - (collider:getShieldMax(1) * sd)),
						math.max(0,collider:getShieldLevel(2) - (collider:getShieldMax(2) * sd)),
						math.max(0,collider:getShieldLevel(3) - (collider:getShieldMax(3) * sd)),
						math.max(0,collider:getShieldLevel(4) - (collider:getShieldMax(4) * sd)),
						math.max(0,collider:getShieldLevel(5) - (collider:getShieldMax(5) * sd)),
						math.max(0,collider:getShieldLevel(6) - (collider:getShieldMax(6) * sd)),
						math.max(0,collider:getShieldLevel(7) - (collider:getShieldMax(7) * sd))
					)
				end
			end
		end
	end)
	a:onPickUp(function(self,player)
		if player.critical_artifacts == nil then
			player.critical_artifacts = 0
		end
		player:addReputationPoints(20)
		player.critical_artifacts = player.critical_artifacts + 1
		critical_artifact_retriever = player:getCallSign()
		for i,p in ipairs(getActivePlayerShips()) do
			if p == player then
				p:addToShipLog(_("goal-shipLog","You have retrieved a critical artifact. Return it to headquarters."),"Magenta")
			else
				p:addToShipLog(string.format(_("goal-shipLog","%s has retrieved a critical artifact in sector %s"),player:getCallSign(),player:getSectorName()),"Magenta")
			end
		end
	end)
	table.insert(critical_artifacts,a)
	return a
end
function createOrbitingDefenses(station,defense_degree)
	local fo_x, fo_y = station:getPosition()
	local angle_increment = 360/defense_degree
	local angle = 0
	local station_platforms = {}
	for i=1,defense_degree do
		local dist = station_spacing[station:getTypeName()].platform
		if difficulty < 1 then 
			dist = dist - 500
		elseif difficulty > 1 then
			dist = dist + 500
		end
		local dx, dy = vectorFromAngle(angle,dist,true)
		local dp = CpuShip():setTemplate("Defense platform"):setPosition(fo_x + dx, fo_y + dy):setFaction(station:getFaction())
		dp.focus_x = fo_x
		dp.focus_y = fo_y
		dp.angle = angle
		dp.dist = dist
		dp.speed = .01
		dp.focus = station
		dp:onDestruction(adjustDefensePlatforms)
		angle = angle + angle_increment
		table.insert(orbiting_platforms,dp)
		table.insert(station_platforms,dp)
	end
	station.station_platforms = station_platforms
end
function adjustDefensePlatforms(self,instigator)
	local dps = self.focus.station_platforms
	for i,dp in ipairs(dps) do
		if dp == self then
			table.remove(dps,i)
			break
		end
	end
	for i,dp in ipairs(dps) do
		dp.speed = dp.speed + .01
	end
	self.focus.station_platforms = dps
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
	if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
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
	if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
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
	if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,radius)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,radius)
	elseif placement_area == "Expansion Strip" or placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,radius)
	end
	if eo_x ~= nil then
		local star_info = tableRemoveRandom(star_list[1].info)
		local plane = .5
		if random(1,100) < 50 then
			plane = -.5
		end
		local star = Planet():setPosition(eo_x, eo_y)
			:setPlanetRadius(radius):setDistanceFromMovementPlane(radius*plane)
			:setCallSign(star_info.name)
			:setPlanetAtmosphereTexture(star_list[1].texture.atmosphere)
			:setPlanetAtmosphereColor(random(0.5,1),random(0.5,1),random(0.5,1))
		if star_info.unscanned ~= nil then
			local unscanned_desc = star_info.unscanned
			local scanned_desc = star_info.scanned
			star:setDescriptions(unscanned_desc,scanned_desc)
			star:setScanningParameters(1,2)
		end
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
	if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
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
	local probe_stations = {}
	if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,200)
		probe_stations = placement_areas[placement_area].stations
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,200)
	elseif placement_area == "Expansion Strip" == placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,200)
		print("probe:",area.angle)
	end
	if eo_x ~= nil then
		local sp = ScanProbe():setPosition(eo_x, eo_y)
		local station_pool = {}
		if probe_stations ~= nil and #probe_stations > 0 then
			for i,station in ipairs(probe_stations) do
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
	local jammer_stations = {}
	if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,200)
		jammer_stations = placement_areas[placement_area].stations
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
		if jammer_stations ~= nil and #jammer_stations > 0 then
			for i,station in ipairs(jammer_stations) do
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
	if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
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
			if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
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
	if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
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
	if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,200)
		local buoy_stations = placement_areas[placement_area].stations
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
		if buoy_stations ~= nil and #buoy_stations > 0 then
			for i,station in ipairs(buoy_stations) do
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
	if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
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
function placeSupplyDrop(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,200)
	end
	if eo_x ~= nil then
		local supply_types = {"energy", "ordnance", "coolant", "repair crew", "probes", "hull", "jump charge"}
		local supply_type = tableSelectRandom(supply_types)
		local object = SupplyDrop():setPosition(eo_x, eo_y)
		if player_factions == nil then
			player_factions = {}
		end
		if #player_factions == 0 then
			if p_count < 6 then
				player_factions = {"Human Navy"}
			elseif p_count < 9 then
				player_factions = {"Human Navy","TSN"}
			else
				player_factions = {"Human Navy","TSN","CUF"}
			end
		end
		local player_faction = tableRemoveRandom(player_factions)
		object:setScanningParameters(math.random(1,2),math.random(1,2)):setFaction(player_faction)
		if supply_type == "energy" then
			local energy_boost = random(300,800)
			object:setEnergy(energy_boost)
			object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%i energy boost supply drop."),math.floor(energy_boost)))
		elseif supply_type == "ordnance" then
			local ordnance_types = {"Homing", "Nuke", "Mine", "EMP", "HVLI"}
			local restock_ranges = {
				["Homing"] =	{lo = 4, hi = 12},
				["Nuke"] = 		{lo = 1, hi = 5},
				["Mine"] =		{lo = 3, hi = 8},
				["EMP"] =		{lo = 2, hi = 8},
				["HVLI"] =		{lo = 8, hi = 20},
			}
			local ordnance_type = tableSelectRandom(ordnance_types)
			local restock_amount = math.random(restock_ranges[ordnance_type].lo,restock_ranges[ordnance_type].hi)
			object:setWeaponStorage(ordnance_type,restock_amount)
			object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%i %s supply drop."),restock_amount,ordnance_type))
		else
			object:onPickUp(supplyPickupProcess)
			if supply_type == "coolant" then
				object.coolant = random(1,5)
				object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%.1f%% coolant supply drop."),object.coolant*10))
			elseif supply_type == "repair crew" then
				object.repairCrew = 1
				object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),_("scienceDescription-supplyDrop","Robotic repair crew supply drop."))
			elseif supply_type == "probes" then
				object.probes = math.random(4,12)
				object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%i probes supply drop."),object.probes))
			elseif supply_type == "hull" then
				object.armor = random(20,80)
				object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%.1f hull repair points supply drop."),object.armor))
			elseif supply_type == "jump charge" then
				object.jump_charge = random(20000,40000)
				object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%.1fK jump drive charge supply drop."),object.jump_charge/1000))
			end
		end
	end
end
function supplyPickupProcess(self, player)
	if self.repairCrew ~= nil then
		player:setRepairCrewCount(player:getRepairCrewCount() + self.repairCrew)
	end
	if self.coolant ~= nil then
		player:setMaxCoolant(player:getMaxCoolant() + self.coolant)
	end
	if self.probes ~= nil then
		player:setScanProbeCount(math.min(player:getScanProbeCount() + self.probes,player:getMaxScanProbeCount()))
	end
	if self.armor ~= nil then
		player:setHull(math.min(player:getHull() + self.armor,player:getHullMax()))
	end
	if player:hasJumpDrive() then
		if self.jump_charge ~= nil then
			player:setJumpDriveCharge(player:getJumpDriveCharge() + self.jump_charge)
		end
	end
end
function placeNebula(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,3000)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,3000)
	elseif placement_area == "Expansion Strip" or placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,area.angle,2000)
	end
	if eo_x ~= nil then
		local anomalous_nebula_types = {
			"-C",	--lose coolant
			"+C",	--gain coolant
			"-BR",	--lose beam range
			"+BR",	--gain beam range
			"-SC",	--lose shield charge
			"+SC",	--gain shield charge
		}
		local neb = Nebula():setPosition(eo_x, eo_y)
		local name = ""
		if random(1,100) < 28 then
			name = tableSelectRandom(anomalous_nebula_types)
			neb.name = name
			setAnomalousNebula(neb,name)
		end
		table.insert(area.space,{obj=neb,dist=1500,shape="circle"})
		if random(1,100) < 77 then
			local n_angle = random(0,360)
			local n_x, n_y = vectorFromAngle(n_angle,random(5000,10000))
			local neb2 = Nebula():setPosition(eo_x + n_x, eo_y + n_y)
			if random(1,100) < 28 then
				name = tableSelectRandom(anomalous_nebula_types)
				neb2.name = name
				setAnomalousNebula(neb2,name)
			end
			if random(1,100) < 37 then
				local n2_angle = (n_angle + random(120,240)) % 360
				n_x, n_y = vectorFromAngle(n2_angle,random(5000,10000))
				eo_x = eo_x + n_x
				eo_y = eo_y + n_y
				local neb3 = Nebula():setPosition(eo_x, eo_y)
				if random(1,100) < 28 then
					name = tableSelectRandom(anomalous_nebula_types)
					neb3.name = name
					setAnomalousNebula(neb3,name)
				end
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
function setAnomalousNebula(neb,name)
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
function placeMine(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
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
	if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
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
function placeRectMineField(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	local field_size = math.random(1,3)
	local radius = random(4000,10000)
	if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,4000 + (field_size*1500))
	end
	if eo_x ~= nil then
		local objects = {}
		table.insert(objects,Mine():setPosition(eo_x,eo_y))
		local reached_the_edge = false
		local object_space = 1400
		local long_axis = random(0,360)
		local reach_index, new_mine_x, new_mine_y = 0
		repeat
			reach_index = reach_index + 1
			new_obj_x, new_obj_y = vectorFromAngle(long_axis,object_space * reach_index,true)
			new_obj_x = new_obj_x + eo_x
			new_obj_y = new_obj_y + eo_y
			if distance(new_obj_x,new_obj_y,eo_x,eo_y) > radius then
				reached_the_edge = true
			else
				if random(1,100) < 77 then
					table.insert(objects,Mine():setPosition(new_obj_x, new_obj_y))
				end
				new_obj_x, new_obj_y = vectorFromAngle((long_axis + 180) % 360,object_space * reach_index,true)
				new_obj_x = new_obj_x + eo_x
				new_obj_y = new_obj_y + eo_y
				if random(1,100) < 77 then
					table.insert(objects,Mine():setPosition(new_obj_x, new_obj_y))
				end
			end
		until(reached_the_edge)
		if random(1,100) < 69 then
			reach_index = 0
			reached_the_edge = false
			local new_line_x, new_line_y = vectorFromAngle((long_axis + 90) % 360,object_space,true)
			new_line_x = new_line_x + eo_x
			new_line_y = new_line_y + eo_y
			table.insert(objects,Mine():setPosition(new_line_x, new_line_y))
			repeat
				reach_index = reach_index + 1
				new_obj_x, new_obj_y = vectorFromAngle(long_axis,object_space * reach_index,true)
				new_obj_x = new_obj_x + new_line_x
				new_obj_y = new_obj_y + new_line_y
				if distance(new_obj_x,new_obj_y,eo_x,eo_y) > radius then
					reached_the_edge = true
				else
					if random(1,100) < 77 then
						table.insert(objects,Mine():setPosition(new_obj_x, new_obj_y))
					end
					new_obj_x, new_obj_y = vectorFromAngle((long_axis + 180) % 360,object_space * reach_index,true)
					new_obj_x = new_obj_x + new_line_x
					new_obj_y = new_obj_y + new_line_y
					if random(1,100) < 77 then
						table.insert(objects,Mine():setPosition(new_obj_x, new_obj_y))
					end
				end
			until(reached_the_edge)
			if random(1,100) < 28 then
				reach_index = 0
				reached_the_edge = false
				new_line_x, new_line_y = vectorFromAngle((long_axis + 270) % 360,object_space,true)
				new_line_x = new_line_x + eo_x
				new_line_y = new_line_y + eo_y
				table.insert(objects,Mine():setPosition(new_line_x, new_line_y))
				repeat
					reach_index = reach_index + 1
					new_obj_x, new_obj_y = vectorFromAngle(long_axis,object_space * reach_index,true)
					new_obj_x = new_obj_x + new_line_x
					new_obj_y = new_obj_y + new_line_y
					if distance(new_obj_x,new_obj_y,eo_x,eo_y) > radius then
						reached_the_edge = true
					else
						if random(1,100) < 77 then
							table.insert(objects,Mine():setPosition(new_obj_x, new_obj_y))
						end
						new_obj_x, new_obj_y = vectorFromAngle((long_axis + 180) % 360,object_space * reach_index,true)
						new_obj_x = new_obj_x + new_line_x
						new_obj_y = new_obj_y + new_line_y
						if random(1,100) < 77 then
							table.insert(objects,Mine():setPosition(new_obj_x, new_obj_y))
						end
					end
				until(reached_the_edge)
			end
		end
		for i,object in ipairs(objects) do
			table.insert(area.space,{obj=object,dist=object_space,shape="circle"})
		end
	end
end
function placeAsteroidField(placement_area)
	local field_size = random(2000,8000)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
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
	if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
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
	if placement_area == "Start Circle" or placement_area == "Mid Circle" or placement_area == "Kraylor Circle" or placement_area == "Arlenian Circle" or placement_area == "Ktlitan Circle" or placement_area == "Aux Circle" then
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
	if transport_list == nil or #transport_list < 1 then
		return
	end
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
function playerDestruction(self,instigator)
	string.format("")
	for i,dp in ipairs(deployed_players) do
		if self == dp.p then
			if dp.count > player_respawn_max then
				globalMessage(string.format(_("msgMainscreen","%s has been destroyed."),self:getCallSign()))
			else
				local respawned_player = PlayerSpaceship():setTemplate(respawns[self:getTypeName()]):setFaction(dp.faction)
				dp.p = respawned_player
				dp.count = dp.count + 1
				respawned_player:setCallSign(dp.name)
				respawned_player.name_set = true
				respawned_player.spawn_count = dp.count
				respawned_player.spawn_x = self.spawn_x
				respawned_player.spawn_y = self.spawn_y
				respawned_player:setPosition(respawned_player.spawn_x, respawned_player.spawn_y)
				setPlayers()
				globalMessage(string.format(_("msgMainscreen","The %s has respawned %s %i to replace %s."),dp.faction,respawned_player:getCallSign(),dp.count,self:getCallSign()))
				self:transferPlayersToShip(respawned_player)
			end
			break
		end
	end
	if self.critical_artifacts ~= nil and self.critical_artifacts > 0 then
		local px, py = self:getPosition()
		for i=1,self.critical_artifacts do
			dx, dy = vectorFromAngle(random(0,360),random(3000,5000),true)
			createCriticalArtifact(px + dx, py + dy)
		end
	end
end
function setPlayers()
	for i,p in ipairs(getActivePlayerShips()) do
		if p.shipScore == nil then
			updatePlayerSoftTemplate(p)
		end
		local already_recorded = false
		for j,dp in ipairs(deployed_players) do
			if p == dp.p then
				already_recorded = true
				break
			end
		end
		if not already_recorded then
			table.insert(deployed_players,{p=p,name=p:getCallSign(),count=1,template=p:getTypeName(),faction=p:getFaction()})
		end
	end
end
function updatePlayerSoftTemplate(p)
	--set defaults for those ships not found in the list
	p:onTakingDamage(playerShipDamage)
	p:onDestruction(playerDestruction)
	p.shipScore = 24
	p.count = 1
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
	if not p:hasWarpDrive() and not p:hasJumpDrive() then
		if temp_type_name == "MP52 Hornet" then
			p:setWarpDrive(true)
			p:setWarpSpeed(1000)
		elseif temp_type_name == "Player Fighter" then
			p:setWarpDrive(true)
			p:setWarpSpeed(950)
--	setBeam(number index, number arc, number direction, number range, number cycle_time, number damage)
			p:setBeam(0,40,0,1000,6,8)
			p:setBeam(1,40,0,900,6,8)
		elseif temp_type_name == "Striker" then
			p:setWarpDrive(true)
			p:setWarpSpeed(900)
		elseif temp_type_name == "Phobos M3P" then
			p:setWarpDrive(true)
			p:setWarpSpeed(850)
		elseif temp_type_name == "ZX-Lindworm" then
			p:setJumpDrive(true)
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
	if array == nil then
		return nil
	end
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
		local arlenian_mission = false
		local ktlitan_mission = false
		local destroy_kraylor_out = _("orders-comms","Destroy the Kraylor military headquarters.")
		local destroy_ktlitan_out = _("orders-comms","Destroy the Ktlitan military headquarters.")
		local protect_human_out = _("orders-comms","Protect the Human Navy headquarters.")
		local destroy_both_out = _("orders-comms","Destroy the Kraylor and Ktlitan military headquarters.")
		local protect_two_out = _("orders-comms","Protect the Human Navy and Arlenian headquarters.")
		local protect_three_out = _("orders-comms","Protect the Human Navy, TSN, and Arlenian headquarters.")
		local protect_four_out = _("orders-comms","Protect the Human Navy, TSN, CUF, and Arlenian headquarters.")
		local out = string.format("%s\n%s",destroy_kraylor_out,protect_human_out)
		if starting_players > 1 then
			out = string.format("%s\n%s",destroy_kraylor_out,protect_two_out)
			arlenian_mission = true
			if starting_players > 4 then
				ktlitan_mission = true
				if kraylor_headquarters ~= nil and kraylor_headquarters:isValid() then
					if ktlitan_headquarters ~= nil and ktlitan_headquarters:isValid() then
						out = string.format("%s\n%s",destroy_both_out,protect_two_out)
					end
				else
					if ktlitan_headquarters ~= nil and ktlitan_headquarters:isValid() then
						out = string.format("%s\n%s",destroy_ktlitan_out,protect_two_out)
					end
				end
				if starting_players > 5 then
					out = string.format("%s\n%s",destroy_kraylor_out,protect_three_out)
					if kraylor_headquarters ~= nil and kraylor_headquarters:isValid() then
						if ktlitan_headquarters ~= nil and ktlitan_headquarters:isValid() then
							out = string.format("%s\n%s",destroy_both_out,protect_three_out)
						end
					else
						if ktlitan_headquarters ~= nil and ktlitan_headquarters:isValid() then
							out = string.format("%s\n%s",destroy_ktlitan_out,protect_three_out)
						end
					end
					if starting_players > 8 then
						out = string.format("%s\n%s",destroy_kraylor_out,protect_four_out)
						if kraylor_headquarters ~= nil and kraylor_headquarters:isValid() then
							if ktlitan_headquarters ~= nil and ktlitan_headquarters:isValid() then
								out = string.format("%s\n%s",destroy_both_out,protect_four_out)
							end
						else
							if ktlitan_headquarters ~= nil and ktlitan_headquarters:isValid() then
								out = string.format("%s\n%s",destroy_ktlitan_out,protect_four_out)
							end
						end
					end
				end
			end
		end
		out = string.format("%s\n%s",out,optional_orders)
		setCommsMessage(out)
		if kraylor_headquarters ~= nil and kraylor_headquarters:isValid() then
			addCommsReply(string.format(_("orders-comms","Where is Kraylor station %s located?"),kraylor_headquarters:getCallSign()),function()
				setCommsMessage(string.format(_("orders-comms","Kraylor station %s is located in sector %s."),
					kraylor_headquarters:getCallSign(),kraylor_headquarters:getSectorName()))
				addCommsReply(_("Back"), commsStation)
			end)
		end
		if arlenian_mission then
			addCommsReply(string.format(_("orders-comms","Where is Arlenian station %s located?"),arlenian_headquarters:getCallSign()),function()
				setCommsMessage(string.format(_("orders-comms","Arlenian station %s is located in sector %s."),
					arlenian_headquarters:getCallSign(),arlenian_headquarters:getSectorName()))
				addCommsReply(_("Back"), commsStation)
			end)
			if starting_players > 5 and comms_source:getFaction() == "TSN" then
				addCommsReply(_("orders-comms","Why are we protecting our enemies, the Arlenians?"),function()
					setCommsMessage(_("orders-comms","This is a joint Human Navy and TSN effort to defeat the Kraylor and the Ktlitans. For the duration of the war, we are allied with the Human Navy. This means we don't attack Arlenian targets. Be sure your science officer knows the difference between a Kraylor, a Ktlitan, and an Arlenian and can properly inform the captain and crew about these assets."))
					addCommsReply(_("Back"), commsStation)
				end)
			end
		end
		if ktlitan_mission then
			if ktlitan_headquarters ~= nil and ktlitan_headquarters:isValid() then
				addCommsReply(string.format(_("orders-comms","Where is Ktlitan station %s located?"),ktlitan_headquarters:getCallSign()),function()
					setCommsMessage(string.format(_("orders-comms","Ktlitan station %s is located in sector %s."),
						ktlitan_headquarters:getCallSign(),ktlitan_headquarters:getSectorName()))
					addCommsReply(_("Back"), commsStation)
				end)
				if starting_players > 8 and comms_source:getFaction() == "CUF" then
					addCommsReply(_("orders-comms","Why would we attack the Ktlitans? They're not enemies"),function()
						setCommsMessage(_("orders-comms","This is a joint Human Navy, TSN, and CUF effort. For the duration of the conflict, we don't have to engage the Ktlitans, we will focus on the Kraylor."))
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
		end
		addCommsReply(_("Back"), commsStation)
	end)
end
function setOptionalOrders()
	local optional_orders_header = {
		_("orders-comms","\nOptional:"),
		_("orders-comms","\nOptional orders:"),
		_("orders-comms","\nThese orders are optional:"),
		_("orders-comms","\nNot required:"),
	}
	optional_orders = tableSelectRandom(optional_orders_header)
	local artifact_mission = _("orders-comms","Retrieve critical artifact before the Kraylor can.")
	if starting_players > 2 then
		artifact_mission = _("orders-comms","Retrieve critical artifacts before the Kraylor can.")
		if starting_players > 4 then
			artifact_mission = _("orders-comms","Retrieve critical artifacts before the Kraylor and/or Ktlitan can.")
		end
	end
	optional_orders = string.format("%s\n%s",optional_orders,artifact_mission)
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
end
function scenarioMissionsUndocked()
	addCommsReply(_("Back"), commsStation)
end
function scenarioMissions()
	local option_count = 0
--	option_count = option_count + upgradeMissileCapacity()
--	option_count = option_count + upgradeLongRangeSensors()
	return option_count
end
--	update related functions
function updatePlayerInitialMissionMessage(p)
	if getScenarioTime() > initial_message_time then
		if not p.initialMissionMessage then
			if availableForComms(p) then
				local station_headquarters = human_headquarters
				if p:getFaction() == "TSN" then
					station_headquarters = tsn_headquarters
				elseif p:getFaction() == "CUF" then
					station_headquarters = cuf_headquarters
				end
				local destroy_msg = string.format(_("orders-comms","Your orders for this mission in the war against the Kraylor:\nDestroy the Kraylor military station %s in sector %s."),kraylor_headquarters:getCallSign(),kraylor_headquarters:getSectorName())
				if starting_players > 4 then
					destroy_msg = string.format(_("orders-comms","Your orders for this mission in the war against the Kraylor and Ktlitan:\nDestroy the Kraylor and Ktlitan military stations. The target Kraylor station, %s, is in sector %s. The target Ktlitan station, %s, is in sector %s"),kraylor_headquarters:getCallSign(),kraylor_headquarters:getSectorName(),ktlitan_headquarters:getCallSign(),ktlitan_headquarters:getSectorName())
				end
				local protect_msg = string.format(_("orders-comms","At the same time, you must protect Human Navy headquarters %s."),human_headquarters:getCallSign())
				if starting_players > 1 then
					protect_msg = string.format(_("orders-comms","At the same time, you must protect Human Navy headquarters %s and Arlenian headquarters %s in sector %s."),human_headquarters:getCallSign(),arlenian_headquarters:getCallSign(),arlenian_headquarters:getSectorName())
					if starting_players > 5 then
						protect_msg = string.format(_("orders-comms","At the same time, you must protect Human Navy headquarters %s, TSN headquarters %s and Arlenian headquarters %s in sector %s."),human_headquarters:getCallSign(),tsn_headquarters:getCallSign(),arlenian_headquarters:getCallSign(),arlenian_headquarters:getSectorName())
						if starting_players > 8 then
							protect_msg = string.format(_("orders-comms","At the same time, you must protect Human Navy headquarters %s, TSN headquarters %s, CUF headquarters %s, and Arlenian headquarters %s in sector %s."),human_headquarters:getCallSign(),tsn_headquarters:getCallSign(),cuf_headquarters:getCallSign(),arlenian_headquarters:getCallSign(),arlenian_headquarters:getSectorName())
						end
					end
				end
				local artifact_msg = _("orders-comms","Intelligence has intercepted Kraylor messages regarding some kind of alien artifact. It seems that this artifact may grant whichever faction finds it first a technological advantage in the war. Try your best to retrieve it before the Kraylor do.")
				if starting_players > 2 then
					artifact_msg = _("orders-comms","Intelligence has intercepted Kraylor messages regarding some kind of alien artifacts. It seems that these artifacts may grant whichever faction finds them first a technological advantage in the war. Try your best to retrieve them before the Kraylor do.")
					if starting_players > 4 then
						artifact_msg = _("orders-comms","Intelligence has intercepted Kraylor and Ktlitan messages regarding some kind of alien artifacts. It seems that these artifacts may grant whichever faction finds them first a technological advantage in the war. Try your best to retrieve them before the Kraylor or the Ktlitan do.")
					end
				end
				station_headquarters:sendCommsMessage(p,string.format("%s\n\n%s\n\n%s",destroy_msg,protect_msg,artifact_msg))
				p.initialMissionMessage = true
			end
		end
	end
end
function updatePlayerShipNameBanner(p)
	local name_banner = string.format(_("nameHelm-tab","%s %s in %s"),p:getFaction(),p:getCallSign(),p:getSectorName())
	if p.spawn_count ~= nil and p.spawn_count > 1 then
		name_banner = string.format(_("nameHelm-tab","%s %s %i in %s"),p:getFaction(),p:getCallSign(),p.spawn_count,p:getSectorName())
	end
	p.ship_name_banner_hlm = "ship_name_banner_hlm"
	p:addCustomInfo("Helms",p.ship_name_banner_hlm,name_banner,1)
	p.ship_name_banner_rel = "ship_name_banner_rel"
	p:addCustomInfo("Relay",p.ship_name_banner_rel,name_banner,1)
	p.ship_name_banner_tac = "ship_name_banner_tac"
	p:addCustomInfo("Tactical",p.ship_name_banner_tac,name_banner,1)
	p.ship_name_banner_ops = "ship_name_banner_ops"
	p:addCustomInfo("Operations",p.ship_name_banner_ops,name_banner,1)
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
				p:addCustomButton("Engineering",p.get_coolant_button,_("coolantEng-button","Get Coolant"),function() 
					string.format("")
					getCoolantGivenPlayer(p) 
				end, 24)
				p.get_coolant = true
			end
			if p:hasPlayerAtPosition("Engineering+") then
				p.get_coolant_button_plus = "get_coolant_button_plus"
				p:addCustomButton("Engineering+",p.get_coolant_button_plus,_("coolantEng-button","Get Coolant"),function() 
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
			gather_coolant_status = _("coolant-tabEngineer","Gathering Coolant")
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
			gather_coolant_status = string.format(_("coolant-tabEngineer","Deploying Collectors %i"),math.ceil(p.deploy_coolant_timer - delta))
		end
	else
		gather_coolant_status = string.format(_("coolant-tabEngineer","Configuring Collectors %i"),math.ceil(p.configure_coolant_timer - delta))
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
			dp.angle = dp.angle + dp.speed
			local x, y = vectorFromAngle(dp.angle,dp.dist,true)
			dp:setPosition(dp.focus_x + x, dp.focus_y + y)
		else
			orbiting_platforms[i] = orbiting_platforms[#orbiting_platforms]
			orbiting_platforms[#orbiting_platforms] = nil
			break
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
							ship_template_distance[obj:getTypeName()] = 400
						end
					else
						print("type name nil on cpu ship:",obj:getCallSign(),"defaulting to ship distance 400")
						ship_distance = 400
					end
					local threshold = planet:getCollisionSize() + ship_distance
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
							player_ship_stats[obj:getTypeName()].distance = 400
						end
					else
						print("type name nil on player ship:",obj:getCallSign(),"defaulting to ship distance 400")
						ship_distance = 400
					end
					if obj_dist <= (planet:getCollisionSize() + ship_distance) then
						obj:takeDamage(planet_bump_damage,"kinetic",planet_x,planet_y)
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
function updateCriticalArtifacts()
	if critical_artifacts ~= nil then
		if #critical_artifacts > 0 then
			for i,a in ipairs(critical_artifacts) do
				if a ~= nil and a:isValid() then
					if a:isScannedByFaction("Human Navy") or a:isScannedByFaction("TSN") or a:isScannedByFaction("CUF") then
						a:allowPickup(true)
					end
				else
					critical_artifacts[i] = critical_artifacts[#critical_artifacts]
					critical_artifacts[#critical_artifacts] = nil
					break
				end
			end
		end
	end
end
function getEnemyFleets()
	local fleets = {kraylor_attack_human}
	if starting_players > 1 then
		table.insert(fleets,kraylor_attack_arlenian)
		if starting_players > 4 then
			table.insert(fleets,ktlitan_attack_human)
			if starting_players > 5 then
				table.insert(fleets,kraylor_attack_tsn)
				table.insert(fleets,ktlitan_attack_tsn)
				if starting_players > 8 then
					table.insert(fleets,kraylor_attack_cuf)
				end
			end
		end
	end
	return fleets
end
function getDockedAtHQ(p)
	local docked_at_headquarters = false
	local hq_docked = nil
	if p:isDocked(human_headquarters) then
		docked_at_headquarters = true
		hq_docked = human_headquarters
	end
	if not docked_at_headquarters then
		if tsn_headquarters ~= nil and tsn_headquarters:isValid() then
			if p:isDocked(tsn_headquarters) then
				docked_at_headquarters = true
				hq_docked = tsn_headquarters
			end
		end
	end
	if not docked_at_headquarters then
		if cuf_headquarters ~= nil and cuf_headquarters:isValid() then
			if p:isDocked(cuf_headquarters) then
				docked_at_headquarters = true
				hq_docked = cuf_headquarters
			end
		end
	end
	return docked_at_headquarters, hq_docked
end
function updateCheckArtifactsImpact()
	if #critical_artifacts < starting_critical_artifacts then
		local player_artifacts_retrieved = 0
		for i,p in ipairs(getActivePlayerShips()) do
			if p.critical_artifacts ~= nil then
				if p.critical_artifacts > 0 then
					local docked_at_hq = getDockedAtHQ(p)
					if docked_at_hq then
						player_artifacts_delivered = player_artifacts_delivered + p.critical_artifacts
						if p.critical_artifacts > 1 then
							p:addToShipLog(string.format(_("goal-shipLog","You delivered %i critical artifacts."),p.critical_artifacts),"Magenta")
						else
							p:addToShipLog(_("goal-shipLog","You delivered a critical artifact."),"Magenta")
						end
						critical_artifact_deliverer = p:getCallSign()
						p:addReputationPoints(40*p.critical_artifacts)
						p.critical_artifacts = 0
					end
				end
				player_artifacts_retrieved = player_artifacts_retrieved + p.critical_artifacts
			end
		end
		local artifact_retrieval_completion = (player_artifacts_retrieved + player_artifacts_delivered) / starting_critical_artifacts
		local artifact_delivery_completion = player_artifacts_delivered / starting_critical_artifacts
--		print("PAR:",player_artifacts_retrieved,"ARC:",artifact_retrieval_completion,"ADC:",artifact_delivery_completion)
		for i,pu in ipairs(player_upgrades) do
			if artifact_retrieval_completion >= (i/#player_upgrades) then
				if pu.impl == "Instant" then
					pu.avail = true
					if pu.name == "Stronger sensors" then
						for j,p in ipairs(getActivePlayerShips()) do
							if p.artifact_sensor_upgrade == nil then
								p.normal_long_range_radar = p.normal_long_range_radar + 10000
								p:setLongRangeRadarRange(p.normal_long_range_radar)
								p.artifact_sensor_upgrade = true
								local msg = string.format(_("msgScience","The range of your sensors has been increased by 10 units based on the information retrieved from the artifact that %s just picked up"),critical_artifact_retriever)
								if critical_artifact_retriever == p:getCallSign() then
									msg = _("msgScience","The range of your sensors has been increased by 10 units based on the information retrieved from the artifact that you just picked up")
								end
								p.got_sensor_upgrade_msg_sci = "got_sensor_upgrade_msg_sci"
								p:addCustomMessage("Science",p.got_sensor_upgrade_msg_sci,msg)
								p.got_sensor_upgrade_msg_ops = "got_sensor_upgrade_msg_ops"
								p:addCustomMessage("Operations",p.got_sensor_upgrade_msg_ops,msg)
							end
						end
					end
				end
			end
			if artifact_delivery_completion >= (i/#player_upgrades) then
				pu.avail = true
				for j,p in ipairs(getActivePlayerShips()) do
					if pu.impl == "Delivery" then
						if pu.name == "Shield balancer" then
							if p.artifact_shield_balance_upgrade == nil then
								p.artifact_shield_balance_upgrade = true
								local msg = string.format(_("msgWeapons","You have a shield balancer upgrade based on the artifact %s just delivered. You can move energy from one shield to the other. Each transfer costs 5 percent energy from your batteries. It takes a few seconds to reset the mechanism. You can balance the energy between shields or focus the energy on the front or rear shield, whichever is weaker."),critical_artifact_deliverer)
								if p:getCallSign() == critical_artifact_deliverer then
									msg = _("msgWeapons","You have a shield balancer upgrade based on the artifact you just delivered. You can move energy from one shield to the other. Each transfer costs 5 percent energy from your batteries. It takes a few seconds to reset the mechanism. You can balance the energy between shields or focus the energy on the front or rear shield, whichever is weaker.")
								end
								p.got_shield_balance_msg_wea = "got_shield_balance_msg_wea"
								p:addCustomMessage("Weapons",p.got_shield_balance_msg_wea,msg)
								p.got_shield_balance_msg_tac = "got_shield_balance_msg_tac"
								p:addCustomMessage("Tactical",p.got_shield_balance_msg_tac,msg)
							end
						elseif pu.name == "Early detonation" then
							if p.trigger_missile == nil then
								p.trigger_missile = {
									["E3"] = {missile = "EMPMissile",	short = 3000, long = 4000,	button_label = _("buttonWeapons","Trigger EMP 3-4u"),	order = 1,	},
									["E4"] = {missile = "EMPMissile",	short = 4000, long = 5000,	button_label = _("buttonWeapons","Trigger EMP 4-5u"),	order = 2,	},
									["N3"] = {missile = "Nuke",			short = 3000, long = 4000,	button_label = _("buttonWeapons","Trigger Nuke 3-4u"),	order = 3,	},
									["N4"] = {missile = "Nuke",			short = 4000, long = 5000,	button_label = _("buttonWeapons","Trigger Nuke 4-5u"),	order = 4,	},
								}
								local msg = string.format(_("msgWeapons","You have an early missile detonation upgrade based on the artifact %s just delivered. This allows splash missiles to be detonated before they hit a target or before they reach the end of their fuel. This allows the weapons officer to cover their target in the missile's area of effect even if the target is trying to evade the missile."),critical_artifact_deliverer)
								if p:getCallSign() == critical_artifact_deliverer then
									msg = _("msgWeapons","You have an early missile detonation upgrade based on the artifact you just delivered. This allows splash missiles to be detonated before they hit a target or before they reach the end of their fuel. This allows the weapons officer to cover their target in the missile's area of effect even if the target is trying to evade the missile.")
								end
								p.got_trigger_missile_upgrade_msg_wea = "got_trigger_missile_upgrade_msg_wea"
								p:addCustomMessage("Weapons",p.got_trigger_missile_upgrade_msg_wea,msg)
								p.got_trigger_missile_upgrade_msg_tac = "got_trigger_missile_upgrade_msg_tac"
								p:addCustomMessage("Tactical",p.got_trigger_missile_upgrade_msg_tac,msg)
							end
						end
					end
					if pu.impl == "Docking" then
						local docked_at_headquarters, hq_docked = getDockedAtHQ(p)
						if docked_at_headquarters then
							if pu.name == "Missile capacity" then
								if p.artifact_missile_capacity_upgrade == nil then
									p.artifact_missile_capacity_upgrade = true
									local increase = {
										["Homing"] = 4,
										["HVLI"] = 4,
										["Mine"] = 3,
										["EMP"] = 2,
										["Nuke"] = 2,
									}
									for k,missile in ipairs(missile_types) do
										if p:getWeaponStorageMax(missile) > 0 then
											p:setWeaponStorageMax(missile, p:getWeaponStorageMax(missile) + increase[missile])
										end
									end
									local msg = string.format(_("msgWeapons","The missile capacity of your ship has been increased based on the artifact delivered and the technicians here on %s."),hq_docked:getCallSign())
									p.got_artifact_missile_upgrade_msg_wea = "got_artifact_missile_upgrade_msg_wea"
									p:addCustomMessage("Weapons",p.got_artifact_missile_upgrade_msg_wea,msg)
									p.got_artifact_missile_upgrade_msg_tac = "got_artifact_missile_upgrade_msg_tac"
									p:addCustomMessage("Tactical",p.got_artifact_missile_upgrade_msg_tac,msg)
								end
							end
							if pu.name == "Faster tubes" then
								if p.artifact_faster_tubes_upgrade == nil then
									p.artifact_faster_tubes_upgrade = true
									for k=1,p:getWeaponTubeCount() do
										p:setTubeLoadTime(k-1,p:getTubeLoadTime(k-1)*.5)
									end
									local msg = string.format(_("msgWeapons","The load time on your missile tubes has been cut in half based on the artifact delivered and the technicians here on %s."),hq_docked:getCallSign())
									p.got_faster_tube_upgrade_msg_wea = "got_faster_tube_upgrade_msg_wea"
									p:addCustomMessage("Weapons",p.got_faster_tube_upgrade_msg_wea,msg)
									p.got_faster_tube_upgrade_msg_tac = "got_faster_tube_upgrade_msg_tac"
									p:addCustomMessage("Tactical",p.got_faster_tube_upgrade_msg_tac,msg)
								end
							end
--							print("index:",i,"pu.name:",pu.name)
							if pu.name == "Faster spin" then
								if p.artifact_faster_spin_upgrade == nil then
									p.artifact_faster_spin_upgrade = true
									p:setRotationMaxSpeed(p:getRotationMaxSpeed()*1.4)
									local msg = string.format(_("msgHelms","Your ship's maneuver speed has been increased by 40%% based on the artifact delivered and the technicians here at %s."),hq_docked:getCallSign())
									p.got_faster_spin_upgrade_msg_hlm = "got_faster_spin_upgrade_msg_hlm"
									p:addCustomMessage("Helms",p.got_faster_spin_upgrade_msg_hlm,msg)
									p.got_faster_spin_upgrade_msg_tac = "got_faster_spin_upgrade_msg_tac"
									p:addCustomMessage("Tactical",p.got_faster_spin_upgrade_msg_tac,msg)
								end
							end
						end
					end
				end
			end
		end
		local fleets = getEnemyFleets()
		local enemy_artifacts_retrieved = 0
		for i,ship in ipairs(science_ships) do
			if ship.critical_artifacts ~= nil then
				enemy_artifacts_retrieved = enemy_artifacts_retrieved + ship.critical_artifacts
			end
		end
		artifact_retrieval_completion = (enemy_artifacts_retrieved + enemy_artifacts_delivered) / starting_critical_artifacts
		artifact_delivery_completion = enemy_artifacts_delivered / starting_critical_artifacts
		for i,eu in ipairs(enemy_upgrades) do
			if artifact_retrieval_completion > (i/#enemy_upgrades) then
				if eu.impl == "Instant" then
					eu.avail = true
					if eu.name == "Cyber attack" then
						for j,fleet in ipairs(fleets) do
							for k,ship in ipairs(fleet) do
								if ship ~= nil and ship:isValid() then
									if ship.cyber_attack_upgrade == nil then
										ship.cyber_attack_upgrade = true
										ship.cyber_attack_factor = cyber_attack_factors[math.random(1,#cyber_attack_factors)]
										ship.cyber_attack_interval = cyber_attack_intervals[math.random(1,#cyber_attack_intervals)]
										table.insert(cyber_attack_ships,ship)
										setSpecialDescription(ship)
										addEnhancementToScienceDatabase("Cyber Attack")
									end
								end
							end
						end
					end
					if eu.name == "Shield frequency" then
						for j,fleet in ipairs(fleets) do
							for k,ship in ipairs(fleet) do
								if ship ~= nil and ship:isValid() then
									if ship.shield_frequency_upgrade == nil then
										ship.shield_frequency_upgrade = true
										if ship:hasSystem("frontshield") then
											ship.adjust_shield_frequency_automatically = true
											setSpecialDescription(ship)
											addEnhancementToScienceDatabase("Shield Frequency Adjuster")
										end
									end
								end
							end
						end
					end
				end
			end
			if artifact_delivery_completion > (i/#enemy_upgrades) then
				if eu.impl == "Delivery" then
					eu.avail = true
					if eu.name == "Spiky spin" then
						for j,fleet in ipairs(fleets) do
							for k,ship in ipairs(fleet) do
								if ship ~= nil and ship:isValid() then
									if ship.spiky_spin_upgrade == nil then
										ship.spiky_spin_upgrade = true
										ship.spiky_spin = math.random(25,50)
										setSpecialDescription(ship)
										addEnhancementToScienceDatabase("Spiky Spin")
									end
								end
							end
						end
					end
					if eu.name == "Tactical hop" then
						for j,fleet in ipairs(fleets) do
							for k,ship in ipairs(fleet) do
								if ship ~= nil and ship:isValid() then
									if ship.tactical_hop_upgrade == nil then
										ship.tactical_hop_upgrade = true
										ship.tactical_hop = math.random(1,5)
										ship.tactical_hop_chance = math.random(25,50)
										setSpecialDescription(ship)
										addEnhancementToScienceDatabase("Tactical Hop")
									end
								end
							end
						end
					end
					if eu.name == "Skip beam" then
						for j,fleet in ipairs(fleets) do
							for k,ship in ipairs(fleet) do
								if ship ~= nil and ship:isValid() then
									if ship.skip_beam_upgrade == nil then
										ship.skip_beam_upgrade = true
										if ship:getBeamWeaponRange(0) > 1 then
											ship.skip_beam_factor = math.random(1,5)
											setSpecialDescription(ship)
											addEnhancementToScienceDatabase("Skip Beam")
										end
									end
								end
							end
						end
					end
					if eu.name == "Point defense" then
						for j,fleet in ipairs(fleets) do
							for k,ship in ipairs(fleet) do
								if ship ~= nil and ship:isValid() then
									if ship.point_defense_upgrade == nil then
										ship.point_defense_upgrade = true
										if ship:getBeamWeaponRange(0) > 1 then
											ship.pdc_factor = pdc_factors[math.random(1,#pdc_factors)]
											table.insert(pdc_ships,ship)
											setSpecialDescription(ship)
											addEnhancementToScienceDatabase("Point Defense Cannon")
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
end
function playerShipDamage(self,instigator)
	string.format("")
	if instigator ~= nil then
		local bi = 0	--beam index
		local beam_damage = 0
		if instigator.shield_drain_beam_factor ~= nil then
			if self:getShieldCount() > 0 then
				if self:getShieldsActive() then
					repeat
						beam_damage = beam_damage + instigator:getBeamWeaponDamage(bi)
						bi = bi + 1
					until(instigator:getBeamWeaponRange(bi) < 1)
					beam_damage = beam_damage / bi * instigator.shield_drain_beam_factor	--average multiplied by factor
					if self:getShieldCount() > 1 then
						self:setShields(math.max(self:getShieldLevel(0) - beam_damage,0),math.max(self:getShieldLevel(1) - beam_damage,0))
					else
						self:setShields(math.max(self:getShieldLevel(0) - beam_damage,0))
					end
					local template = self:getTypeName()
					local slf_x, slf_y = self:getPosition()
					local exp_size = shipTemplateDistance[template]
					if exp_size == nil then
						print("nil from shipTemplateDistance for template:",template)
						exp_size = 400
						shipTemplateDistance[template] = 400
					end
					local explosion_size = shipTemplateDistance[template]
					if explosion_size == nil then
						explosion_size = 500
					end
					ElectricExplosionEffect():setSize(explosion_size):setOnRadar(true):setPosition(slf_x, slf_y)
				end
			end
		end
		if instigator.skip_beam_factor ~= nil then
			bi = 0
			beam_damage = 0
			local beam_range = 0
			repeat
				beam_damage = beam_damage + instigator:getBeamWeaponDamage(bi)
				beam_range = beam_range + instigator:getBeamWeaponRange(bi)
				bi = bi + 1
			until(instigator:getBeamWeaponRange(bi) < 1)
			beam_damage = beam_damage / bi * instigator.skip_beam_factor / 2	--average multiplied by factor
			beam_range = beam_range / bi 
			if distance_diagnostic then
				print("distance_diagnostic 9 self:",self,"instigator:",instigator)
			end
			local dist = distance(self,instigator)
			if dist < beam_range then
				self:setHull(math.max(self:getHull() - beam_damage,0))
			end
		end
	end
end
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
function npcShipDamage(self, instigator)
	string.format("")	--serious proton needs a global context
	if self:getShieldCount() > 0 then
		if self.adjust_shield_frequency_automatically ~= nil and self.adjust_shield_frequency_automatically then
			if instigator ~= nil then
				if instigator:getBeamWeaponRange(0) > 1 then
					self:setShieldsFrequency(instigator:getBeamFrequency())
				end
			end
		end
	end
	local tactical_hop_eval = random(1,100)
	if self.tactical_hop ~= nil and tactical_hop_eval <= self.tactical_hop_chance then
		local hacked_hop = self.tactical_hop_chance
		if self:hasSystem("jumpdrive") then
			hacked_hop = hacked_hop - (hacked_hop *  self:getSystemHackedLevel("jumpdrive") / 2)
		elseif self:hasSystem("warp") then
			hacked_hop = hacked_hop - (hacked_hop *  self:getSystemHackedLevel("warp") / 2)
		else
			hacked_hop = hacked_hop - (hacked_hop *  self:getSystemHackedLevel("impulse") / 2)
		end
		if tactical_hop_eval < hacked_hop then
			if instigator ~= nil then
				if instigator:isEnemy(self) then
					local self_x, self_y = self:getPosition()
					local instigator_x, instigator_y = instigator:getPosition()
					local hop_axis = angleFromVectorNorth(instigator_x,instigator_y,self_x,self_y)
					local hop_x = 0
					local hop_y = 0
					local hop_range = 4000
					local template_name = self:getTypeName()
					if self.tactical_hop == 1 or self.tactical_hop == 2 then
						hop_x, hop_y = vectorFromAngle(hop_axis,4000,true)
						self:setPosition(instigator_x + hop_x, instigator_y + hop_y)
					end
					if self.tactical_hop == 3 or self.tactical_hop == 4 then
						if ship_template[template_name] ~= nil and ship_template[template_name].hop_range ~= nil then
							hop_range = ship_template[template_name].hop_range
						end
						hop_x, hop_y = vectorFromAngle(hop_axis,hop_range,true)
						self:setPosition(instigator_x + hop_x, instigator_y + hop_y)
					end
					if self.tactical_hop == 5 then
						if self:getHull() < self:getHullMax()/2 then
							hop_range = 5000
						else
							if ship_template[template_name] ~= nil and ship_template[template_name].hop_range ~= nil then
								hop_range = ship_template[template_name].hop_range
							end
						end
						hop_x, hop_y = vectorFromAngle(hop_axis,hop_range,true)
						self:setPosition(instigator_x + hop_x, instigator_y + hop_y)
					end
					if self.tactical_hop == 2 or self.tactical_hop == 4 or self.tactical_hop == 5 then
						local hop_angle = (hop_axis + 180) % 360
						if ship_template[template_name] ~= nil and ship_template[template_name].hop_angle ~= nil then
							hop_angle = (hop_angle + ship_template[template_name].hop_angle) % 360
						end
						self:setHeading(hop_angle)	
					end
				end
			end
		end
	end
	if self.spiky_spin ~= nil and self.spiky_spin_active == nil and self.spiky_spin_cooling == nil then
		if math.random(1,100) < self.spiky_spin then
			self.spiky_spin_normal = self:getRotationMaxSpeed()
			self:setRotationMaxSpeed(self.spiky_spin_normal * 3)
			self.spiky_spin_active = getScenarioTime() + 5
			self.spiky_spin_cooling = getScenarioTime() + 35
			table.insert(spiky_spin_ships,self)
		end
	end
	if self.boost_impulse_factor ~= nil and self.boost_impulse_active == nil and self.boost_impulse_cooling == nil then
		local desperation = (1 - self:getHull()/self:getHullMax())*100
		if math.random(1,100) + desperation > 50 then
			self.boost_impulse_normal = self:getImpulseMaxSpeed()
			self:setImpulseMaxSpeed(self:getImpulseMaxSpeed()*self.boost_impulse_degree_factor)
			self.boost_impulse_active = getScenarioTime() + self.boost_impulse_time_factor
			self.boost_impulse_cooling = getScenarioTime() + (self.boost_impulse_time_factor * 2)
			table.insert(impulse_boost_ships,self)
		end
	end
end	
function addEnhancementDatabaseEntry()
	local ships_key = _("scienceDB","Ships")
	local ship_db = queryScienceDatabase(ships_key)
	local enhancements_key = _("scienceDB","Enhancements")
	ship_db:addEntry(enhancements_key)
	local enhancement_db = queryScienceDatabase(ships_key,enhancements_key)
	enhancement_db:setLongDescription(_("scienceDB","Ship enhancements give the ship benefits during combat over and above those things possible with typical assistance from Engineering"))
end	
function addEnhancementToScienceDatabase(enhancement_type)
	local ships_key = _("scienceDB","Ships")
	local enhancements_key = _("scienceDB","Enhancements")
	local enhancement_db = queryScienceDatabase(ships_key,enhancements_key)
	if enhancement_db == nil then
		addEnhancementDatabaseEntry()
	end
	enhancement_db = queryScienceDatabase(ships_key,enhancements_key)
	if enhancement_type == "Shield Drain Beam" then
		local shield_drain_key = _("scienceDB","Shield Drain Beam")
		local shield_drain_beam_db = queryScienceDatabase(ships_key,enhancements_key,shield_drain_key)
		if shield_drain_beam_db == nil then
			enhancement_db:addEntry(shield_drain_key)
			shield_drain_beam_db = queryScienceDatabase(ships_key,enhancements_key,shield_drain_key)
			shield_drain_beam_db:setLongDescription(_("scienceDB","If a ship is equipped with Shield Drain Beam capability, their beam weapons have been enhanced to particularly negatively impact the target's shields. The damage is applied to all shield arcs and reduces the shield charge. The degree of impact depends on the shield drain factor. In addition to the normal beam damage, the draining damage is the normal beam damage multiplied by the factor applied to all shield arcs."))
		end
	elseif enhancement_type == "Boost Impulse" then
		local boost_impulse_key = _("scienceDB","Boost Impulse")
		local boost_impulse_db = queryScienceDatabase(ships_key,enhancements_key,boost_impulse_key)
		if boost_impulse_db == nil then
			enhancement_db:addEntry(boost_impulse_key)
			boost_impulse_db = queryScienceDatabase(ships_key,enhancements_key,boost_impulse_key)
			boost_impulse_db:setLongDescription(_("scienceDB","If a ship is equipped with Boost Impulse, it can temporarily increase its maximum impulse speed, something learned from observing CUF ships. The numeric expression indicates seconds x speed multiplier."))
		end
	elseif enhancement_type == "Skip Beam" then
		local skip_beam_key = _("scienceDB","Skip Beam")
		local skip_beam_db = queryScienceDatabase(ships_key,enhancements_key,skip_beam_key)
		if skip_beam_db == nil then
			enhancement_db:addEntry(skip_beam_key)
			skip_beam_db = queryScienceDatabase(ships_key,enhancements_key,skip_beam_key)
			skip_beam_db:setLongDescription(_("scienceDB","If a ship is equipped with a Skip Beam, it can directly damage the target ship hull regardless of the state of the shields. The beam is enhanced with intertwined jump characteristics allowing it to bypass the shields. The damage applied to the hull equates to the normal damage multiplied by the skip beam factor divided by two."))
		end
	elseif enhancement_type == "Shield Frequency Adjuster" then
		local shield_freq_key = _("scienceDB","Shield Frequency Adjuster")
		local shield_frequency_adjuster_db = queryScienceDatabase(ships_key,enhancements_key,shield_freq_key)
		if shield_frequency_adjuster_db == nil then
			enhancement_db:addEntry(shield_freq_key)
			shield_frequency_adjuster_db = queryScienceDatabase(ships_key,enhancements_key,shield_freq_key)
			shield_frequency_adjuster_db:setLongDescription(_("scienceDB","If a ship is equipped with Shield Frequency Adjusters, their shields automatically adjust to the best defensive shield frequency during combat."))
		end
	elseif enhancement_type == "Tactical Hop" then
		local tactical_hop_key = _("scienceDB","Tactical Hop")
		local tactical_hop_db = queryScienceDatabase(ships_key,enhancements_key,tactical_hop_key)
		if tactical_hop_db == nil then
			enhancement_db:addEntry(tactical_hop_key)
			tactical_hop_db = queryScienceDatabase(ships_key,enhancements_key,tactical_hop_key)
			tactical_hop_db:setLongDescription(_("scienceDB","If a ship is equipped with Tactical Hop, they have a rapid-acting quasi-jump drive under computer control that combat conditions can trigger. The combat computer action taken depends on the rating (the integer portion of the number given in the Science description). The likelihood of the computer taking the hop action depends on the reliability (the fractional portion of the number given in the Science description).\n\nRating actions:\n1: Hop to the other side of the target at range 4U.\n2: Hop to the other side of the target at range 4U and face weapons to target.\n3: Hop to the other side of the target at good weapons range.\n4: Hop to the other side of the target at good weapons range and face weapons to target.\n5: If hull damage at 50% or higher, hop to the other side of the target at range 5U otherwise hop to the other side of the target at good weapons range. In either case, face weapons to target."))
		end
	elseif enhancement_type == "Spiky Spin" then
		local spiky_spin_key = _("scienceDB","Spiky Spin")
		local spiky_spin_db = queryScienceDatabase(ships_key,enhancements_key,spiky_spin_key)
		if spiky_spin_db == nil then
			enhancement_db:addEntry(spiky_spin_key)
			spiky_spin_db = queryScienceDatabase(ships_key,enhancements_key,spiky_spin_key)
			spiky_spin_db:setLongDescription(_("scienceDB","If a ship is equipped with Spiky Spin, they can spike up the performance of their maneuvering systems temporarily under combat conditions. This allows them to spin rapidly to bring weapons to bear on a desired target. The number given in the Science description represents the likelihood that the spike will function when desired."))
		end
	elseif enhancement_type == "Point Defense Cannon" then
		local pdc_key = _("scienceDB","Point Defense Cannon")
		local pdc_db = queryScienceDatabase(ships_key,enhancements_key,pdc_key)
		if pdc_db == nil then
			enhancement_db:addEntry(pdc_key)
			pdc_db = queryScienceDatabase(ships_key,enhancements_key,pdc_key)
			pdc_db:setLongDescription(_("scienceDB","If a ship is equipped with a Point Defense Cannon, it can shoot down incoming missiles if the targeting computer can get a lock. The factor shown represents the percentage chance of locking on to a missile based on the targeting computer's capability."))
		end
	elseif enhancement_type == "Cyber Attack" then
		local cyber_attack_key = _("scienceDB","Cyber Attack")
		local cyber_attack_db = queryScienceDatabase(ships_key,enhancements_key,cyber_attack_key)
		if cyber_attack_db == nil then
			enhancement_db:addEntry(cyber_attack_key)
			cyber_attack_db = queryScienceDatabase(ships_key,enhancements_key,cyber_attack_key)
			cyber_attack_db:setLongDescription(_("scienceDB","If a ship is equipped with Cyber Attack, it can hack various systems on your ship. When assessing this capability the integer portion of the number represents the interval between attacks in seconds. The fractional portion of the number represents the chance of success."))
		end
	elseif enhancement_type == "Quantum Field" then
		local quantum_field_key = _("scienceDB","Quantum Field")
		local quantum_field_db = queryScienceDatabase(ships_key,enhancements_key,quantum_field_key)
		if quantum_field_db == nil then
			enhancement_db:addEntry(quantum_field_key)
			quantum_field_db = queryScienceDatabase(ships_key,enhancements_key,quantum_field_key)
			quantum_field_db:setLongDescription(_("scienceDB","If a ship is equipped with Quantum Field, it can drop an invisible field that adversely impacts ship systems. The systems impacted and the degree of impact varies. Your ship systems will put up a colored area on Science and Relay as soon as the field is identified."))
		end
	end
end
function setSpecialDescription(ship)
	local special_description = ""
	if ship.shield_drain_beam_factor ~= nil then
		special_description = string.format(_("scienceDescription-ship","Factor %i shield draining beams."),ship.shield_drain_beam_factor)
	end
	if ship.boost_impulse_factor ~= nil then
		if special_description == "" then
			special_description = string.format(_("scienceDescription-ship","Boost Impulse %s."),ship.boost_impulse_factor)
		else
			special_description = string.format(_("scienceDescription-ship","%s Boost Impulse %s."),special_description,ship.boost_impulse_factor)
		end
	end
	if ship.skip_beam_factor ~= nil then
		if special_description == "" then
			special_description = string.format(_("scienceDescription-ship","Factor %i skip beam."),ship.skip_beam_factor)
		else
			special_description = string.format(_("scienceDescription-ship","%s Factor %i skip beam."),special_description,ship.skip_beam_factor)
		end
	end
	if ship.adjust_shield_frequency_automatically ~= nil and ship.adjust_shield_frequency_automatically then
		if special_description == "" then
			special_description = _("scienceDescription-ship","Automated shield frequency adjusters.")
		else
			special_description = string.format(_("scienceDescription-ship","%s Automated shield frequency adjusters."),special_description)
		end
	end
	if ship.tactical_hop ~= nil then
		if ship.tactical_hop_chance == nil then
			ship.tactical_hop_chance = 25
		end
		if special_description == "" then
			special_description = string.format(_("scienceDescription-ship","Tactical Hop %i.%i."),ship.tactical_hop,ship.tactical_hop_chance)
		else
			special_description = string.format(_("scienceDescription-ship","%s Tactical Hop %i.%i."),special_description,ship.tactical_hop,ship.tactical_hop_chance)
		end
	end
	if ship.spiky_spin ~= nil then
		if special_description == "" then
			special_description = string.format(_("scienceDescription-ship","Spiky Spin %i."),ship.spiky_spin)
		else
			special_description = string.format(_("scienceDescription-ship","%s Spiky Spin %i."),special_description,ship.spiky_spin)
		end
	end
	if ship.pdc_factor ~= nil then
		if special_description == "" then
			special_description = string.format(_("scienceDescription-ship","Factor %i%% Point Defense Cannons."),ship.pdc_factor)
		else
			special_description = string.format(_("scienceDescription-ship","%s Factor %i%% Point Defense Cannons."),special_description,ship.pdc_factor)
		end
	end
	if ship.cyber_attack_factor ~= nil then
		if special_description == "" then
			special_description = string.format(_("scienceDescription-ship","Cyber Attack %i.%i."),ship.cyber_attack_interval,ship.cyber_attack_factor)
		else
			special_description = string.format(_("scienceDescription-ship","%s Cyber Attack %i.%i."),special_description,ship.cyber_attack_interval,ship.cyber_attack_factor)
		end
	end
	if ship.zone_weapon ~= nil then
		if special_description == "" then
			special_description = _("scienceDescription-ship","Quantum Field.")
		else
			special_description = string.format(_("scienceDescription-ship","%s Quantum Field."),special_description)
		end
	end
	if special_description == "" then
		ship:setDescriptionForScanState("notscanned"," ")
		ship:setDescriptionForScanState("friendorfoeidentified"," ")
		ship:setDescriptionForScanState("simplescan"," ")
		ship:setDescriptionForScanState("fullscan"," ")
	else	
		ship:setDescriptionForScanState("notscanned"," ")
		ship:setDescriptionForScanState("friendorfoeidentified"," ")
		ship:setDescriptionForScanState("simplescan",string.format(_("scienceDescription-ship","Enhanced %s"),ship:getTypeName()))
		ship:setDescriptionForScanState("fullscan",special_description)
	end
end
function updatePlayerMissileTriggerButtons(p)
	if p.trigger_missile == nil then
		return
	end
	local max_range = 0
	local interesting_missiles = {}		--initialize list of lists
	local find_missiles = {}			--initialize missile type list
	for trigger,blob in pairs(p.trigger_missile) do
		interesting_missiles[trigger] = {}	--initialize missile trigger type list (E3, E4, N3, N4)
		find_missiles[blob.missile] = true	--put missile type in find list
		if blob.long > max_range then
			max_range = blob.long			--set max range for getting nearby objects
		end
	end
--	["E3"] = {missile = "EMPMissile",	short = 3000, long = 4000,	button_label = "Trigger EMP 3-4u",	order = 1,	},
	local nearby_objects = p:getObjectsInRange(max_range)
	local px, py = p:getPosition()			--get player ship position coordinates
	for i,obj in ipairs(nearby_objects) do
		local is_splash = false
		if ECS then
			if isObjectType(obj,"Nuke","SplashMissile") or isObjectType(obj,"EMPMissile","SplashMissile") then
				is_splash = true
			end
		else
			if find_missiles[obj.typeName] then
				is_splash = true
			end
		end
		if is_splash and obj:getOwner() == p then	--object is missile owned by player
--		if is_splash then	--object is missile
			local mx, my = obj:getPosition()						--get missile position coordinates
			local m_dist = distance(px, py, mx, my)					--determine missile distance from player
			for trigger,blob in pairs(p.trigger_missile) do
				if m_dist < blob.long and m_dist > blob.short then			--in range
					if ECS then
						if isObjectType(obj,"Nuke","SplashMissile") and blob.missile == "Nuke" then
							table.insert(interesting_missiles[trigger],obj)		--add to proper list
						elseif isObjectType(obj,"EMPMissile","SplashMissile") and blob.missile == "EMPMissile" then
							table.insert(interesting_missiles[trigger],obj)		--add to proper list
						end
					else
						if obj.typeName == blob.missile then					--proper type
							table.insert(interesting_missiles[trigger],obj)		--add to proper list
						end
					end
				end
			end
		end
	end
	for trigger,list in pairs(interesting_missiles) do		--go through list of lists
		if #list > 0 then									--something in the list, add trigger buttons
			if p.trigger_missile_button_wea == nil then
				p.trigger_missile_button_wea = {}
			end
			p.trigger_missile_button_wea[trigger] = string.format("trigger_missile_button_wea_%s",trigger)
			p:addCustomButton("Weapons",p.trigger_missile_button_wea[trigger],p.trigger_missile[trigger].button_label,function()
				string.format("")
				for i,missile in ipairs(list) do
					missile:setLifetime(0)
				end
			end, 44 + p.trigger_missile[trigger].order)
			if p.trigger_missile_button_tac == nil then
				p.trigger_missile_button_tac = {}
			end
			p.trigger_missile_button_tac[trigger] = string.format("trigger_missile_button_tac_%s",trigger)
			p:addCustomButton("Tactical",p.trigger_missile_button_tac[trigger],p.trigger_missile[trigger].button_label,function()
				string.format("")
				for i,missile in ipairs(list) do
					missile:setLifetime(0)
				end
			end, 44 + p.trigger_missile[trigger].order)
		else	--nothing in the list, remove any related button
			if p.trigger_missile_button_wea ~= nil then
				if p.trigger_missile_button_wea[trigger] ~= nil then
					p:removeCustom(p.trigger_missile_button_wea[trigger])
				end
			end
			if p.trigger_missile_button_tac ~= nil then
				if p.trigger_missile_button_tac[trigger] ~= nil then
					p:removeCustom(p.trigger_missile_button_tac[trigger])
				end
			end
		end
	end
end
function updatePlayerBalanceShield(p)
	local function removeBalanceShieldButtons(p)
		if p.balance_shield_button_wea ~= nil then
			p:removeCustom(p.balance_shield_button_wea)
			p.balance_shield_button_wea = nil
		end
		if p.balance_shield_button_tac ~= nil then
			p:removeCustom(p.balance_shield_button_tac)
			p.balance_shield_button_tac = nil
		end
		if p.balance_shield_focus_rear_button_wea ~= nil then
			p:removeCustom(p.balance_shield_focus_rear_button_wea)
			p.balance_shield_focus_rear_button_wea = nil
		end
		if p.balance_shield_focus_rear_button_tac ~= nil then
			p:removeCustom(p.balance_shield_focus_rear_button_tac)
			p.balance_shield_focus_rear_button_tac = nil
		end
		if p.balance_shield_focus_front_button_wea ~= nil then
			p:removeCustom(p.balance_shield_focus_front_button_wea)
			p.balance_shield_focus_front_button_wea = nil
		end
		if p.balance_shield_focus_front_button_tac ~= nil then
			p:removeCustom(p.balance_shield_focus_front_button_tac)
			p.balance_shield_focus_front_button_tac = nil
		end
	end
	if p.artifact_shield_balance_upgrade then
		if p:getShieldCount() > 1 then
			if p:getShieldLevel(0) < p:getShieldMax(0) or p:getShieldLevel(1) < p:getShieldMax(1) then
				if p:getEnergy() > p:getMaxEnergy() * .1 then
					if p.balance_shield_cycle_interval == nil then
						p.balance_shield_cycle_interval = 10
					end
					if p:getShieldMax(0) == p:getShieldMax(1) then
						if p:getShieldLevel(0) ~= p:getShieldLevel(1) then
							if p.balance_shield_timer == nil then
								p.balance_shield_button_wea = "balance_shield_button_wea"
								p:addCustomButton("Weapons",p.balance_shield_button_wea,_("buttonWeapons","Balance Shields"),function()
									local average_shield = (p:getShieldLevel(0) + p:getShieldLevel(1)) / 2
									p:setShields(average_shield,average_shield)
									p:setEnergy(p:getEnergy() - p:getMaxEnergy() * .05)
									p.balance_shield_timer = getScenarioTime() + p.balance_shield_cycle_interval
									if p.balance_shield_focus_front_button_wea ~= nil then
										p:removeCustom(p.balance_shield_focus_front_button_wea)
										p.balance_shield_focus_front_button_wea = nil
									end
									if p.balance_shield_focus_front_button_tac ~= nil then
										p:removeCustom(p.balance_shield_focus_front_button_tac)
										p.balance_shield_focus_front_button_tac = nil
									end
									if p.balance_shield_focus_rear_button_wea ~= nil then
										p:removeCustom(p.balance_shield_focus_rear_button_wea)
										p.balance_shield_focus_rear_button_wea = nil
									end
									if p.balance_shield_focus_rear_button_tac ~= nil then
										p:removeCustom(p.balance_shield_focus_rear_button_tac)
										p.balance_shield_focus_rear_button_tac = nil
									end
									if p.balance_shield_button_wea ~= nil then
										p:removeCustom(p.balance_shield_button_wea)
										p.balance_shield_button_wea = nil
									end
									if p.balance_shield_button_tac ~= nil then
										p:removeCustom(p.balance_shield_button_tac)
										p.balance_shield_button_tac = nil
									end
								end, 49)
								p.balance_shield_button_tac = "balance_shield_button_tac"
								p:addCustomButton("Tactical",p.balance_shield_button_tac,_("buttonTactical","Balance Shields",function()
									local average_shield = (p:getShieldLevel(0) + p:getShieldLevel(1)) / 2
									p:setShields(average_shield,average_shield)
									p:setEnergy(p:getEnergy() - p:getMaxEnergy() * .05)
									p.balance_shield_timer = getScenarioTime() + p.balance_shield_cycle_interval
									if p.balance_shield_focus_front_button_wea ~= nil then
										p:removeCustom(p.balance_shield_focus_front_button_wea)
										p.balance_shield_focus_front_button_wea = nil
									end
									if p.balance_shield_focus_front_button_tac ~= nil then
										p:removeCustom(p.balance_shield_focus_front_button_tac)
										p.balance_shield_focus_front_button_tac = nil
									end
									if p.balance_shield_focus_rear_button_wea ~= nil then
										p:removeCustom(p.balance_shield_focus_rear_button_wea)
										p.balance_shield_focus_rear_button_wea = nil
									end
									if p.balance_shield_focus_rear_button_tac ~= nil then
										p:removeCustom(p.balance_shield_focus_rear_button_tac)
										p.balance_shield_focus_rear_button_tac = nil
									end
									if p.balance_shield_button_wea ~= nil then
										p:removeCustom(p.balance_shield_button_wea)
										p.balance_shield_button_wea = nil
									end
									if p.balance_shield_button_tac ~= nil then
										p:removeCustom(p.balance_shield_button_tac)
										p.balance_shield_button_tac = nil
									end
								end, 49)
							else
								if getScenarioTime() > p.balance_shield_timer then
									p.balance_shield_timer = nil
								end
							end
						end
					end
					local front_strength = p:getShieldLevel(0)/p:getShieldMax(0)
					local rear_strength = p:getShieldLevel(1)/p:getShieldMax(1)
					if front_strength > rear_strength then
						if p.balance_shield_timer == nil then
							p.balance_shield_focus_rear_button_wea = "balance_shield_focus_rear_button_wea"
							p:addCustomButton("Weapons",p.balance_shield_focus_rear_button_wea,_("buttonWeapons","Focus Rear Shield"),function()
								local need_transfer = p:getShieldMax(1) - p:getShieldLevel(1)
								local get_transfer = math.min(need_transfer,p:getShieldLevel(0))
								p:setShields(p:getShieldLevel(0) - get_transfer,p:getShieldLevel(1) + get_transfer)
								p:setEnergy(p:getEnergy() - p:getMaxEnergy() * .05)
								p.balance_shield_timer = getScenarioTime() + p.balance_shield_cycle_interval
							end, 50)
							p.balance_shield_focus_rear_button_tac = "balance_shield_focus_rear_button_tac"
							p:addCustomButton("Tactical",p.balance_shield_focus_rear_button_tac,_("buttonTactical","Focus Rear Shield"),function()
								local need_transfer = p:getShieldMax(1) - p:getShieldLevel(1)
								local get_transfer = math.min(need_transfer,p:getShieldLevel(0))
								p:setShields(p:getShieldLevel(0) - get_transfer,p:getShieldLevel(1) + get_transfer)
								p:setEnergy(p:getEnergy() - p:getMaxEnergy() * .05)
								p.balance_shield_timer = getScenarioTime() + p.balance_shield_cycle_interval
							end, 50)
						else
							if getScenarioTime() > p.balance_shield_timer then
								p.balance_shield_timer = nil
							end
						end
						if p.balance_shield_focus_front_button_wea ~= nil then
							p:removeCustom(p.balance_shield_focus_front_button_wea)
							p.balance_shield_focus_front_button_wea = nil
						end
						if p.balance_shield_focus_front_button_tac ~= nil then
							p:removeCustom(p.balance_shield_focus_front_button_tac)
							p.balance_shield_focus_front_button_tac = nil
						end
					elseif rear_strength > front_strength then
						if p.balance_shield_timer == nil then
							p.balance_shield_focus_front_button_wea = "balance_shield_focus_front_button_wea"
							p:addCustomButton("Weapons",p.balance_shield_focus_front_button_wea,_("buttonWeapons","Focus Front Shield"),function()
								local need_transfer = p:getShieldMax(0) - p:getShieldLevel(0)
								local get_transfer = math.min(need_transfer,p:getShieldLevel(1))
								p:setShields(p:getShieldLevel(0) + get_transfer,p:getShieldLevel(1) - get_transfer)
								p:setEnergy(p:getEnergy() - p:getMaxEnergy() * .05)
								p.balance_shield_timer = getScenarioTime() + p.balance_shield_cycle_interval
							end, 50)
							p.balance_shield_focus_front_button_tac = "balance_shield_focus_front_button_tac"
							p:addCustomButton("Tactical",p.balance_shield_focus_front_button_tac,_("buttonTactical","Focus Front Shield"),function()
								local need_transfer = p:getShieldMax(0) - p:getShieldLevel(0)
								local get_transfer = math.min(need_transfer,p:getShieldLevel(1))
								p:setShields(p:getShieldLevel(0) + get_transfer,p:getShieldLevel(1) - get_transfer)
								p:setEnergy(p:getEnergy() - p:getMaxEnergy() * .05)
								p.balance_shield_timer = getScenarioTime() + p.balance_shield_cycle_interval
							end, 50)
						else
							if getScenarioTime() > p.balance_shield_timer then
								p.balance_shield_timer = nil
							end
						end
						if p.balance_shield_focus_rear_button_wea ~= nil then
							p:removeCustom(p.balance_shield_focus_rear_button_wea)
							p.balance_shield_focus_rear_button_wea = nil
						end
						if p.balance_shield_focus_rear_button_tac ~= nil then
							p:removeCustom(p.balance_shield_focus_rear_button_tac)
							p.balance_shield_focus_rear_button_tac = nil
						end
					end
				else
					removeBalanceShieldButtons(p)
				end
			else
				removeBalanceShieldButtons(p)
			end
		else
			removeBalanceShieldButtons(p)
		end
	else
		removeBalanceShieldButtons(p)
	end
end
function finalStats()
	if player_artifacts_retrieved == nil then
		player_artifacts_retrieved = 0
	end
	local out = string.format(_("msgMainscreen","Technological artifacts in game: %i"),starting_critical_artifacts)
	local deliver_msg = string.format(_("msgMainscreen","Technological artifacts delivered by player ship: %i"),player_artifacts_delivered)
	local retrieve_msg = string.format(_("msgMainscreen","Technological artifacts retrieved by player ship: %i"),player_artifacts_delivered + player_artifacts_retrieved)
	if starting_players > 1 then
		deliver_msg = string.format(_("msgMainscreen","Technological artifacts delivered by player ships: %i"),player_artifacts_delivered)
		retrieve_msg = string.format(_("msgMainscreen","Technological artifacts retrieved by player ships: %i"),player_artifacts_delivered + player_artifacts_retrieved)
	end
	out = string.format("%s\n%s\n%s",out,deliver_msg,retrieve_msg)
	if enemy_artifacts_delivered > 0 then
		if starting_players > 4 then
			out = string.format(_("msgMainscreen","%s\nTechnological artifacts delivered by enemies: %i"),out,enemy_artifacts_delivered)
		else
			out = string.format(_("msgMainscreen","%s\nTechnological artifacts delivered by Kraylor: %i"),out,enemy_artifacts_delivered)
		end
	end
	if #critical_artifacts > 0 then
		out = string.format(_("msgMainscreen","%s\nUndiscovered technological artifacts: %i"),out,#critical_artifacts)
	end
	local deployed_count = 0
	for i,p in ipairs(getActivePlayerShips()) do
		if p.count == nil then
			p.count = 1
		end
		deployed_count = deployed_count + p.count
	end
	local deploy_msg = string.format(_("msgMainscreen","Player ships deployed: initial:%i total:%i"),starting_players,deployed_count)
	local duration_msg = formatTime(getScenarioTime())
	out = string.format(_("msgMainscreen","%s\n%s\nMission duration: %s"),out,deploy_msg,duration_msg)
	return out
end
function updateVictoryDefeat()
	if starting_players > 4 then
		if not kraylor_headquarters:isValid() and not ktlitan_headquarters:isValid() then
			local out = _("msgMainscreen","You destroyed the Kraylor and Ktlitan military stations.")
			if starting_players > 5 and starting_players < 9 then
				out = _("msgMainscreen","The joint Human Navy and TSN forces have destroyed the Kraylor and Ktlitan military stations.")
			elseif starting_players > 8 then
				out = _("msgMainscreen","The joint Human Navy, TSN, and CUF forces have destroyed the Kraylor and Ktlitan military stations.")
			end
			out = string.format("%s\n%s",out,finalStats())
			globalMessage(out)
			victory("Human Navy")
		end
	else
		if not kraylor_headquarters:isValid() then
			globalMessage(string.format(_("msgMainscreen","You destroyed the Kraylor military station.\n%s"),finalStats()))
			victory("Human Navy")
		end
	end
	if not human_headquarters:isValid() then
		globalMessage(string.format(_("msgMainscreen","Human Navy headquarters were destroyed.\n%s"),finalStats()))
		victory("Kraylor")
	end
	if starting_players > 1 then
		if not arlenian_headquarters:isValid() then
			globalMessage(string.format(_("msgMainscreen","Arlenian headquarters were destroyed.\n%s"),finalStats()))
			victory("Kraylor")
		end
	end
	if starting_players > 5 then
		if not tsn_headquarters:isValid() then
			globalMessage(string.format(_("msgMainscreen","TSN headquarters were destroyed.\n%s"),finalStats()))
			victory("Kraylor")
		end
	end
	if starting_players > 8 then
		if not cuf_headquarters:isValid() then
			globalMessage(string.format(_("msgMainscreen","CUF headquarters were destroyed.\n%s"),finalStats()))
			victory("Kraylor")
		end
	end
end
function updateAttackForce()
	if kraylor_attack_human == nil then
		if kraylor_human_attack_start_delay_time == nil then
			kraylor_human_attack_start_delay_time = getScenarioTime() + attack_force_delay
			return
		end
		if getScenarioTime() > kraylor_human_attack_start_delay_time then
			kraylor_attack_human = {}
			--	first time attack logic
			local fx, fy = vectorFromAngle(random(0,360),region_parameters[starting_players].radius)
			fx = fx + start_region_center_x
			fy = fy + start_region_center_y
			template_pool_size = 8
			fleetSpawnFaction = "Kraylor"
			local fleet_repeat = adjustFleetStrength()
			for i=1,fleet_repeat do
				local fleet = spawnRandomArmed(fx,fy)
				for j,ship in ipairs(fleet) do
					ship:onTakingDamage(npcShipDamage)
					ship:orderFlyTowards(start_region_center_x,start_region_center_y)
					table.insert(kraylor_attack_human,ship)
				end
			end
			original_kraylor_attack_human_count = #kraylor_attack_human
		else
			return
		end
	end
	local clean_list = true
	for i,ship in ipairs(kraylor_attack_human) do
		if ship == nil or not ship:isValid() then
			kraylor_attack_human[i] = kraylor_attack_human[#kraylor_attack_human]
			kraylor_attack_human[#kraylor_attack_human] = nil
			clean_list = false
			break
		end
	end
	if clean_list then
		if #kraylor_attack_human / original_kraylor_attack_human_count < .15 then
			if kraylor_headquarters:isValid() then
				fleetSpawnFaction = "Kraylor"
				local fleet_repeat = adjustFleetStrength()
				for i=1,fleet_repeat do
					local fleet = spawnRandomArmed(kraylor_region_center_x,kraylor_region_center_y)
					for j,ship in ipairs(fleet) do
						ship:onTakingDamage(npcShipDamage)
						ship:orderFlyTowards(start_region_center_x,start_region_center_y)
						table.insert(kraylor_attack_human,ship)
					end
				end
				original_kraylor_attack_human_count = #kraylor_attack_human
			end
		end
	end
	if starting_players > 1 then
		if kraylor_attack_arlenian == nil then
			if kraylor_arlenian_attack_start_delay_time == nil then
				kraylor_arlenian_attack_start_delay_time = getScenarioTime() + attack_force_delay
				return
			end
			if getScenarioTime() > kraylor_arlenian_attack_start_delay_time then
				kraylor_attack_arlenian = {}
				original_kraylor_attack_arlenian_count = 10
			else
				return
			end
		end
		clean_list = true
		for i,ship in ipairs(kraylor_attack_arlenian) do
			if ship == nil or not ship:isValid() then
				kraylor_attack_arlenian[i] = kraylor_attack_arlenian[#kraylor_attack_arlenian]
				kraylor_attack_arlenian[#kraylor_attack_arlenian] = nil
				clean_list = false
				break
			end
		end
		if clean_list then
			if #kraylor_attack_arlenian / original_kraylor_attack_arlenian_count < .15 then
				if kraylor_headquarters:isValid() then
					fleetSpawnFaction = "Kraylor"
					local fleet_repeat = adjustFleetStrength()
					for i=1,fleet_repeat do
						local fleet = spawnRandomArmed(kraylor_region_center_x,kraylor_region_center_y)
						for j,ship in ipairs(fleet) do
							ship:onTakingDamage(npcShipDamage)
							ship:orderFlyTowards(arlenian_region_center_x,arlenian_region_center_y)
							table.insert(kraylor_attack_arlenian,ship)
						end
					end
					original_kraylor_attack_arlenian_count = #kraylor_attack_arlenian
				end
			end
		end
		if arlenian_attack_kraylor == nil then
			if arlenian_kraylor_attack_start_delay_time == nil then
				arlenian_kraylor_attack_start_delay_time = getScenarioTime() + attack_force_delay
				return
			end
			if getScenarioTime() > arlenian_kraylor_attack_start_delay_time then
				arlenian_attack_kraylor = {}
				original_arlenian_attack_kraylor_count = 10
			else
				return
			end
		end
		clean_list = true
		for i,ship in ipairs(arlenian_attack_kraylor) do
			if ship == nil or not ship:isValid() then
				arlenian_attack_kraylor[i] = arlenian_attack_kraylor[#arlenian_attack_kraylor]
				arlenian_attack_kraylor[#arlenian_attack_kraylor] = nil
				clean_list = false
				break
			end
		end
		if clean_list then
			if #arlenian_attack_kraylor / original_arlenian_attack_kraylor_count < .15 then
				if kraylor_headquarters:isValid() then
					fleetSpawnFaction = "Arlenians"
					local fleet_repeat = adjustFleetStrength()
					for i=1,fleet_repeat do
						local fleet = spawnRandomArmed(arlenian_region_center_x,arlenian_region_center_y)
						for j,ship in ipairs(fleet) do
							ship:onTakingDamage(npcShipDamage)
							ship:orderFlyTowards(kraylor_region_center_x,kraylor_region_center_y)
							table.insert(arlenian_attack_kraylor,ship)
						end
					end
					original_arlenian_attack_kraylor_count = #arlenian_attack_kraylor
				end
			end
		end
		if starting_players > 4 then
			if ktlitan_attack_human == nil then
				if ktlitan_human_attack_start_delay_time == nil then
					ktlitan_human_attack_start_delay_time = getScenarioTime() + attack_force_delay
					return
				end
				if getScenarioTime() > ktlitan_human_attack_start_delay_time then
					ktlitan_attack_human = {}
					original_ktlitan_attack_human_count = 10
				else
					return
				end
			end
			clean_list = true
			for i,ship in ipairs(ktlitan_attack_human) do
				if ship == nil or not ship:isValid() then
					ktlitan_attack_human[i] = ktlitan_attack_human[#ktlitan_attack_human]
					ktlitan_attack_human[#ktlitan_attack_human] = nil
					clean_list = false
					break
				end
			end
			if clean_list then
				if #ktlitan_attack_human / original_ktlitan_attack_human_count < .15 then
					if kraylor_headquarters:isValid() then
						fleetSpawnFaction = "Ktlitans"
						local fleet_repeat = adjustFleetStrength()
						for i=1,fleet_repeat do
							local fleet = spawnRandomArmed(ktlitan_region_center_x,ktlitan_region_center_y)
							for j,ship in ipairs(fleet) do
								ship:onTakingDamage(npcShipDamage)
								ship:orderFlyTowards(start_region_center_x,start_region_center_y)
								table.insert(ktlitan_attack_human,ship)
							end
						end
						original_ktlitan_attack_human_count = #ktlitan_attack_human
					end
				end
			end
			if starting_players > 5 then
				if kraylor_attack_tsn == nil then
					if kraylor_tsn_attack_start_delay_time == nil then
						kraylor_tsn_attack_start_delay_time = getScenarioTime() + attack_force_delay
						return
					end
					if getScenarioTime() > kraylor_tsn_attack_start_delay_time then
						kraylor_attack_tsn = {}
						original_kraylor_attack_tsn_count = 10
					else
						return
					end
				end
				clean_list = true
				for i,ship in ipairs(kraylor_attack_tsn) do
					if ship == nil or not ship:isValid() then
						kraylor_attack_tsn[i] = kraylor_attack_tsn[#kraylor_attack_tsn]
						kraylor_attack_tsn[#kraylor_attack_tsn] = nil
						clean_list = false
						break
					end
				end
				if clean_list then
					if #kraylor_attack_tsn / original_kraylor_attack_tsn_count < .15 then
						if kraylor_headquarters:isValid() then
							fleetSpawnFaction = "Kraylor"
							local fleet_repeat = adjustFleetStrength()
							for i=1,fleet_repeat do
								local fleet = spawnRandomArmed(kraylor_region_center_x,kraylor_region_center_y)
								for j,ship in ipairs(fleet) do
									ship:onTakingDamage(npcShipDamage)
									ship:orderFlyTowards(tsn_headquarters_x,tsn_headquarters_y)
									table.insert(kraylor_attack_tsn,ship)
								end
							end
							original_kraylor_attack_tsn_count = #kraylor_attack_tsn
						end
					end
				end
				if ktlitan_attack_tsn == nil then
					if ktlitan_tsn_attack_start_delay_time == nil then
						ktlitan_tsn_attack_start_delay_time = getScenarioTime() + attack_force_delay
						return
					end
					if getScenarioTime() > ktlitan_tsn_attack_start_delay_time then
						ktlitan_attack_tsn = {}
						original_ktlitan_attack_tsn_count = 10
					else
						return
					end
				end
				clean_list = true
				for i,ship in ipairs(ktlitan_attack_tsn) do
					if ship == nil or not ship:isValid() then
						ktlitan_attack_tsn[i] = ktlitan_attack_tsn[#ktlitan_attack_tsn]
						ktlitan_attack_tsn[#ktlitan_attack_tsn] = nil
						clean_list = false
						break
					end
				end
				if clean_list then
					if #ktlitan_attack_tsn / original_ktlitan_attack_tsn_count < .15 then
						if ktlitan_headquarters:isValid() then
							fleetSpawnFaction = "Ktlitans"
							local fleet_repeat = adjustFleetStrength()
							for i=1,fleet_repeat do
								local fleet = spawnRandomArmed(ktlitan_region_center_x,ktlitan_region_center_y)
								for j,ship in ipairs(fleet) do
									ship:onTakingDamage(npcShipDamage)
									ship:orderFlyTowards(tsn_headquarters_x,tsn_headquarters_y)
									table.insert(ktlitan_attack_tsn,ship)
								end
							end
							original_ktlitan_attack_tsn_count = #ktlitan_attack_tsn
						end
					end
				end
				if starting_players > 8 then
					if kraylor_attack_cuf == nil then
						if kraylor_cuf_attack_start_delay_time == nil then
							kraylor_cuf_attack_start_delay_time = getScenarioTime() + attack_force_delay
							return
						end
						if getScenarioTime() > kraylor_cuf_attack_start_delay_time then
							kraylor_attack_cuf = {}
							original_kraylor_attack_cuf_count = 10
						else
							return
						end
					end
					clean_list = true
					for i,ship in ipairs(kraylor_attack_cuf) do
						if ship == nil or not ship:isValid() then
							kraylor_attack_cuf[i] = kraylor_attack_cuf[#kraylor_attack_cuf]
							kraylor_attack_cuf[#kraylor_attack_cuf] = nil
							clean_list = false
							break
						end
					end
					if clean_list then
						if #kraylor_attack_cuf / original_kraylor_attack_cuf_count < .15 then
							if kraylor_headquarters:isValid() then
								fleetSpawnFaction = "Kraylor"
								local fleet_repeat = adjustFleetStrength()
								for i=1,fleet_repeat do
									local fleet = spawnRandomArmed(kraylor_region_center_x,kraylor_region_center_y)
									for j,ship in ipairs(fleet) do
										ship:onTakingDamage(npcShipDamage)
										ship:orderFlyTowards(cuf_headquarters_x,cuf_headquarters_y)
										table.insert(kraylor_attack_cuf,ship)
									end
								end
								original_kraylor_attack_cuf_count = #kraylor_attack_cuf
							end
						end
					end
					if ktlitan_attack_cuf == nil then
						if ktlitan_cuf_attack_start_delay_time == nil then
							ktlitan_cuf_attack_start_delay_time = getScenarioTime() + attack_force_delay
							return
						end
						if getScenarioTime() > ktlitan_cuf_attack_start_delay_time then
							ktlitan_attack_cuf = {}
							original_ktlitan_attack_cuf_count = 10
						else
							return
						end
					end
					clean_list = true
					for i,ship in ipairs(ktlitan_attack_cuf) do
						if ship == nil or not ship:isValid() then
							ktlitan_attack_cuf[i] = ktlitan_attack_cuf[#ktlitan_attack_cuf]
							ktlitan_attack_cuf[#ktlitan_attack_cuf] = nil
							clean_list = false
							break
						end
					end
					if clean_list then
						if #ktlitan_attack_cuf / original_ktlitan_attack_cuf_count < .15 then
							if ktlitan_headquarters:isValid() then
								fleetSpawnFaction = "Ktlitans"
								local fleet_repeat = adjustFleetStrength()
								for i=1,fleet_repeat do
									local fleet = spawnRandomArmed(ktlitan_region_center_x,ktlitan_region_center_y)
									for j,ship in ipairs(fleet) do
										ship:onTakingDamage(npcShipDamage)
										ship:orderFlyTowards(cuf_headquarters_x,cuf_headquarters_y)
										table.insert(ktlitan_attack_cuf,ship)
									end
								end
								original_ktlitan_attack_cuf_count = #ktlitan_attack_cuf
							end
						end
					end
				end
			end
		end
	end
end
function updateArtifactForce()
	if kraylor_attack_human ~= nil then
		if kraylor_artifact_1 == nil then
			if kraylor_artifact_1_start_delay_time == nil then
				kraylor_artifact_1_start_delay_time = getScenarioTime() + (attack_force_delay/2)
				return
			end
			if getScenarioTime() > kraylor_artifact_1_start_delay_time then
				kraylor_artifact_1 = {}
				--	first time logic
				local ax, ay = critical_artifacts[1]:getPosition()
				lx = (ax + kraylor_region_center_x) / 2
				ly = (ay + kraylor_region_center_y) / 2
				ka_science_1 = scienceResearch()
				ka_science_1.critical_artifacts = 0
				ka_science_1:setPosition(lx,ly):setFaction("Kraylor"):orderDefendTarget(critical_artifacts[1])
				ka_science_1.artifact_target = critical_artifacts[1]
				table.insert(kraylor_artifact_1,ka_science_1)
				table.insert(science_ships,ka_science_1)
				template_pool_size = 8
				fleetSpawnFaction = "Kraylor"
				local fleet_repeat = adjustFleetStrength()
				for i=1,fleet_repeat do
					local fleet = spawnRandomArmed(lx,ly)
					for j,ship in ipairs(fleet) do
						ship:onTakingDamage(npcShipDamage)
						ship:orderDefendTarget(ka_science_1)
						ship:setImpulseMaxSpeed(math.max(90,ship:getImpulseMaxSpeed()))
						table.insert(kraylor_artifact_1,ship)
					end
				end
			else
				return
			end
		end
		local clean_list = true
		for i,ship in ipairs(kraylor_artifact_1) do
			if ship == nil or not ship:isValid() then
				kraylor_artifact_1[i] = kraylor_artifact_1[#kraylor_artifact_1]
				kraylor_artifact_1[#kraylor_artifact_1] = nil
				clean_list = false
				break
			end
		end
		if clean_list then
			if #kraylor_artifact_1 < 1 or ka_science_1 == nil or not ka_science_1:isValid() then
				if kraylor_headquarters:isValid() and #critical_artifacts > 0 then
					local ax, ay = critical_artifacts[1]:getPosition()
					if ka_science_1 == nil or not ka_science_1:isValid() then
						ka_science_1 = scienceResearch()
						ka_science_1.critical_artifacts = 0
						ka_science_1:setPosition(kraylor_region_center_x,kraylor_region_center_y):setFaction("Kraylor"):orderFlyTowards(ax,ay)
						ka_science_1.artifact_target = critical_artifacts[1]
						if #kraylor_artifact_1 > 0 then
							for i,ship in ipairs(kraylor_artifact_1) do
								ship:orderDefendTarget(ka_science_1)
							end
						end
						table.insert(science_ships,ka_science_1)
						table.insert(kraylor_artifact_1,ka_science_1)
					end
					template_pool_size = 8
					fleetSpawnFaction = "Kraylor"
					local fleet_repeat = adjustFleetStrength()
					for i=1,fleet_repeat do
						local fleet = spawnRandomArmed(kraylor_region_center_x,kraylor_region_center_y)
						for j,ship in ipairs(fleet) do
							ship:onTakingDamage(npcShipDamage)
							ship:orderDefendTarget(ka_science_1)
							table.insert(kraylor_artifact_1,ship)
						end
					end
				end
			end
		end
		if ka_science_1.artifact_target:isValid() then
			local current_distance_to_artifact = distance(ka_science_1,ka_science_1.artifact_target)
			local station_to_artifact_distance = 0
			if kraylor_headquarters ~= nil and kraylor_headquarters:isValid() then
				station_to_artifact_distance = distance(ka_science_1.artifact_target,kraylor_headquarters)
			end
			if current_distance_to_artifact < (.25 * station_to_artifact_distance) then
				local proximity_warning = string.format("Signals intelligence has intercepted a message from Kraylor research ship %s in sector %s. Partial decryption indicates that the ship is approaching a technological artifact of interest.",ka_science_1:getCallSign(),ka_science_1:getSectorName())
				for i,p in ipairs(getActivePlayerShips()) do
					if p.ka_science_1_warning == nil then
						if availableForComms(p) then
							hqs[p:getFaction()]:sendCommsMessage(p,proximity_warning)
							p.ka_science_1_warning = "sent"
						end
					end
				end
			end
			if current_distance_to_artifact < 3000 then
				for i,a in ipairs(critical_artifacts) do
					if a == ka_science_1.artifact_target then
						table.remove(critical_artifacts,i)
						a:destroy()
						ka_science_1:orderDock(kraylor_headquarters)
						ka_science_1.critical_artifacts = ka_science_1.critical_artifacts + 1
					end
				end
			end
		else
			if kraylor_headquarters:isValid() then
				if ka_science_1.critical_artifacts == 1 then
					if ka_science_1:isDocked(kraylor_headquarters) then
						--deliver artifact
						enemy_artifacts_delivered = enemy_artifacts_delivered + 1
						ka_science_1.critical_artifacts = 0
						if #critical_artifacts > 0 then
							local ax, ay = critical_artifacts[1]:getPosition()
							ka_science_1:orderFlyTowards(ax,ay)
							ka_science_1.artifact_target = critical_artifacts[1]
						else
							ka_science_1:destroy()
						end
					end
				else
					if ka_science_1:getOrder() ~= "Dock" then
						ka_science_1:orderDock(kraylor_headquarters)
					end
				end
			end
		end
	else
		return
	end
	if starting_players > 2 then
		if arlenian_attack_kraylor ~= nil then
			if kraylor_artifact_2 == nil then
				if kraylor_artifact_2_start_delay_time == nil then
					kraylor_artifact_2_start_delay_time = getScenarioTime() + (attack_force_delay/2)
					return
				end
				if getScenarioTime() > kraylor_artifact_2_start_delay_time then
					kraylor_artifact_2 = {}
				else
					return
				end
			end
			clean_list = true
			for i,ship in ipairs(kraylor_artifact_2) do
				if ship == nil or not ship:isValid() then
					kraylor_artifact_2[i] = kraylor_artifact_2[#kraylor_artifact_2]
					kraylor_artifact_2[#kraylor_artifact_2] = nil
					clean_list = false
					break
				end
			end
			if clean_list then
				ka_science_2 = maintainKraylorResearchFleet(kraylor_artifact_2,ka_science_2,2)
			end
			decideForKraylorResearchShip(ka_science_2,1)
			if starting_players > 3 then
				if kraylor_artifact_2 ~= nil then
					if kraylor_artifact_3 == nil then
						if kraylor_artifact_3_start_delay_time == nil then
							kraylor_artifact_3_start_delay_time = getScenarioTime() + (attack_force_delay*1.5)
							return
						end
						if getScenarioTime() > kraylor_artifact_3_start_delay_time then
							kraylor_artifact_3 = {}
						else
							return
						end
					end
					clean_list = true
					for i,ship in ipairs(kraylor_artifact_3) do
						if ship == nil or not ship:isValid() then
							kraylor_artifact_3[i] = kraylor_artifact_3[#kraylor_artifact_3]
							kraylor_artifact_3[#kraylor_artifact_3] = nil
							clean_list = false
							break
						end
					end
					if clean_list then
						ka_science_3 = maintainKraylorResearchFleet(kraylor_artifact_3,ka_science_3,3)
					end
					decideForKraylorResearchShip(ka_science_3,2)
				else
					return
				end
				if starting_players > 4 then
					if ktlitan_attack_human ~= nil then
						if ktlitan_artifact_1 == nil then
							if ktlitan_artifact_1_start_delay_time == nil then
								ktlitan_artifact_1_start_delay_time = getScenarioTime() + (attack_force_delay*1.5)
								return
							end
							if getScenarioTime() > ktlitan_artifact_1_start_delay_time then
								ktlitan_artifact_1 = {}
							else
								return
							end
						end
						clean_list = true
						for i,ship in ipairs(ktlitan_artifact_1) do
							if ship == nil or not ship:isValid() then
								ktlitan_artifact_1[i] = ktlitan_artifact_1[#ktlitan_artifact_1]
								ktlitan_artifact_1[#ktlitan_artifact_1] = nil
								clean_list = false
								break
							end
						end
						if clean_list then
							kta_science_1 = maintainKtlitanResearchFleet(ktlitan_artifact_1,kta_science_1,1)
						end
						if kta_science_1.artifact_target:isValid() then
							local current_distance_to_artifact = distance(kta_science_1,kta_science_1.artifact_target)
							local station_to_artifact_distance = 0
							if ktlitan_headquarters ~= nil and ktlitan_headquarters:isValid() then
								station_to_artifact_distance = distance(kta_science_1.artifact_target,ktlitan_headquarters)
							end
							if current_distance_to_artifact < (.25 * station_to_artifact_distance) then
								local proximity_warning = string.format("Signals intelligence has intercepted a message from Ktlitan research ship %s in sector %s. Partial decryption indicates that the ship is approaching a technological artifact of interest.",kta_science_1:getCallSign(),kta_science_1:getSectorName())
								for i,p in ipairs(getActivePlayerShips()) do
									if p.kta_science_1_warning == nil then
										if availableForComms(p) then
											hqs[p:getFaction()]:sendCommsMessage(p,proximity_warning)
											p.kta_science_1_warning = "sent"
										end
									end
								end
							end
							if current_distance_to_artifact < 3000 then
								for i,a in ipairs(critical_artifacts) do
									if a == kta_science_1.artifact_target then
										table.remove(critical_artifacts,i)
										a:destroy()
										kta_science_1:orderDock(ktlitan_headquarters)
										kta_science_1.critical_artifacts = kta_science_1.critical_artifacts + 1
									end
								end
							end
						else
							if ktlitan_headquarters:isValid() then
								if kta_science_1.critical_artifacts == 1 then
									if kta_science_1:isDocked(ktlitan_headquarters) then
										--deliver artifact
										enemy_artifacts_delivered = enemy_artifacts_delivered + 1
										kta_science_1.critical_artifacts = 0
										if #critical_artifacts > 0 then
											local ax, ay = critical_artifacts[1]:getPosition()
											kta_science_1:orderFlyTowards(ax,ay)
											kta_science_1.artifact_target = critical_artifacts[1]
										else
											kta_science_1:destroy()
										end
									end
								else
									if kta_science_1:getOrder() ~= "Dock" then
										kta_science_1:orderDock(ktlitan_headquarters)
									end
								end
							end
						end
						if ktlitan_artifact_2 == nil then
							if ktlitan_artifact_2_start_delay_time == nil then
								ktlitan_artifact_2_start_delay_time = getScenarioTime() + (attack_force_delay*1.5)
								return
							end
							if getScenarioTime() > ktlitan_artifact_2_start_delay_time then
								ktlitan_artifact_2 = {}
							else
								return
							end
						end
						clean_list = true
						for i,ship in ipairs(ktlitan_artifact_2) do
							if ship == nil or not ship:isValid() then
								ktlitan_artifact_2[i] = ktlitan_artifact_2[#ktlitan_artifact_2]
								ktlitan_artifact_2[#ktlitan_artifact_2] = nil
								clean_list = false
								break
							end
						end
						if clean_list then
							kta_science_2 = maintainKtlitanResearchFleet(ktlitan_artifact_2,kta_science_2,2)
						end
						decideForKtlitanResearchShip(kta_science_2,1)
						if ktlitan_artifact_3 == nil then
							if ktlitan_artifact_3_start_delay_time == nil then
								ktlitan_artifact_3_start_delay_time = getScenarioTime() + (attack_force_delay*1.5)
								return
							end
							if getScenarioTime() > ktlitan_artifact_3_start_delay_time then
								ktlitan_artifact_3 = {}
							else
								return
							end
						end
						clean_list = true
						for i,ship in ipairs(ktlitan_artifact_3) do
							if ship == nil or not ship:isValid() then
								ktlitan_artifact_3[i] = ktlitan_artifact_3[#ktlitan_artifact_3]
								ktlitan_artifact_3[#ktlitan_artifact_3] = nil
								clean_list = false
								break
							end
						end
						if clean_list then
							kta_science_3 = maintainKtlitanResearchFleet(ktlitan_artifact_3,kta_science_3,3)
						end
						decideForKtlitanResearchShip(kta_science_3,2)
					else
						return
					end
				end
				if starting_players > 6 then
					if ktlitan_attack_tsn ~= nil then
						if kraylor_artifact_4 == nil then
							if kraylor_artifact_4_start_delay_time == nil then
								kraylor_artifact_4_start_delay_time = getScenarioTime() + (attack_force_delay*1.5)
								return
							end
							if getScenarioTime() > kraylor_artifact_4_start_delay_time then
								kraylor_artifact_4 = {}
							else
								return
							end
						end
						clean_list = true
						for i,ship in ipairs(kraylor_artifact_4) do
							if ship == nil or not ship:isValid() then
								kraylor_artifact_4[i] = kraylor_artifact_4[#kraylor_artifact_4]
								kraylor_artifact_4[#kraylor_artifact_4] = nil
								clean_list = false
								break
							end
						end
						if clean_list then
							ka_science_4 = maintainKraylorResearchFleet(kraylor_artifact_4,ka_science_4,4)
						end
						decideForKraylorResearchShip(ka_science_4,3)
						if ktlitan_artifact_4 == nil then
							if ktlitan_artifact_4_start_delay_time == nil then
								ktlitan_artifact_4_start_delay_time = getScenarioTime() + (attack_force_delay*1.5)
								return
							end
							if getScenarioTime() > ktlitan_artifact_4_start_delay_time then
								ktlitan_artifact_4 = {}
							else
								return
							end
						end
						clean_list = true
						for i,ship in ipairs(ktlitan_artifact_4) do
							if ship == nil or not ship:isValid() then
								ktlitan_artifact_4[i] = ktlitan_artifact_4[#ktlitan_artifact_4]
								ktlitan_artifact_4[#ktlitan_artifact_4] = nil
								clean_list = false
								break
							end
						end
						if clean_list then
							kta_science_4 = maintainKtlitanResearchFleet(ktlitan_artifact_4,kta_science_4,4)
						end
						decideForKtlitanResearchShip(kta_science_4,3)
						if starting_players > 7 then
							if ktlitan_artifact_4 ~= nil then
								if kraylor_artifact_5 == nil then
									if kraylor_artifact_5_start_delay_time == nil then
										kraylor_artifact_5_start_delay_time = getScenarioTime() + (attack_force_delay*1.5)
										return
									end
									if getScenarioTime() > kraylor_artifact_5_start_delay_time then
										kraylor_artifact_5 = {}
									else
										return
									end
								end
								clean_list = true
								for i,ship in ipairs(kraylor_artifact_5) do
									if ship == nil or not ship:isValid() then
										kraylor_artifact_5[i] = kraylor_artifact_5[#kraylor_artifact_5]
										kraylor_artifact_5[#kraylor_artifact_5] = nil
										clean_list = false
										break
									end
								end
								if clean_list then
									ka_science_5 = maintainKraylorResearchFleet(kraylor_artifact_5,ka_science_5,5)
								end
								decideForKraylorResearchShip(ka_science_5,4)
								if ktlitan_artifact_5 == nil then
									if ktlitan_artifact_5_start_delay_time == nil then
										ktlitan_artifact_5_start_delay_time = getScenarioTime() + (attack_force_delay*1.5)
										return
									end
									if getScenarioTime() > ktlitan_artifact_5_start_delay_time then
										ktlitan_artifact_5 = {}
									else
										return
									end
								end
								clean_list = true
								for i,ship in ipairs(ktlitan_artifact_5) do
									if ship == nil or not ship:isValid() then
										ktlitan_artifact_5[i] = ktlitan_artifact_5[#ktlitan_artifact_5]
										ktlitan_artifact_5[#ktlitan_artifact_5] = nil
										clean_list = false
										break
									end
								end
								if clean_list then
									kta_science_5 = maintainKtlitanResearchFleet(ktlitan_artifact_5,kta_science_5,5)
								end
								decideForKtlitanResearchShip(kta_science_5,4)
							else
								return
							end
						end
					else
						return
					end
				end
			end
		else
			return
		end
	end
end
function maintainKraylorResearchFleet(research_fleet,ship,artifact_index)
	if #research_fleet < 1 or ship == nil or not ship:isValid() then
		if kraylor_headquarters:isValid() and #critical_artifacts >= artifact_index then
			local ax, ay = critical_artifacts[artifact_index]:getPosition()
			if ship == nil or not ship:isValid() then
				ship = scienceResearch()
				ship.critical_artifacts = 0
				ship:setPosition(kraylor_region_center_x,kraylor_region_center_y):setFaction("Kraylor"):orderFlyTowards(ax,ay)
				ship.artifact_target = critical_artifacts[artifact_index]
				if #research_fleet > 0 then
					for i,r_ship in ipairs(research_fleet) do
						r_ship:orderDefendTarget(ship)
					end
				end
				table.insert(science_ships,ship)
				table.insert(research_fleet,ship)
			end
			template_pool_size = 8
			fleetSpawnFaction = "Kraylor"
			local fleet_repeat = adjustFleetStrength()
			for i=1,fleet_repeat do
				local fleet = spawnRandomArmed(kraylor_region_center_x,kraylor_region_center_y)
				for j,r_ship in ipairs(fleet) do
					r_ship:onTakingDamage(npcShipDamage)
					r_ship:orderDefendTarget(ship)
					table.insert(research_fleet,r_ship)
				end
			end
		end
	end
	return ship
end
function decideForKraylorResearchShip(ship,artifact_index)
	if ship.artifact_target:isValid() then
		local current_distance_to_artifact = distance(ship,ship.artifact_target)
		local station_to_artifact_distance = 0
		if kraylor_headquarters ~= nil and kraylor_headquarters:isValid() then
			station_to_artifact_distance = distance(ship.artifact_target,kraylor_headquarters)
		end
		if current_distance_to_artifact < (artifact_threshold * station_to_artifact_distance) then
			local proximity_warning = string.format(_("goal-incCall","Signals intelligence has intercepted a message from Kraylor research ship %s in sector %s. Partial decryption indicates that the ship is approaching a technological artifact of interest."),ship:getCallSign(),ship:getSectorName())
			for i,p in ipairs(getActivePlayerShips()) do
				if p[ship:getCallSign()] == nil then
					if availableForComms(p) then
						hqs[p:getFaction()]:sendCommsMessage(p,proximity_warning)
						p[ship:getCallSign()] = "sent"
					end
				end
			end
		end
		if distance(ship,ship.artifact_target) < 3000 then
			for i,a in ipairs(critical_artifacts) do
				if a == ship.artifact_target then
					table.remove(critical_artifacts,i)
					a:destroy()
					ship:orderDock(kraylor_headquarters)
					ship.critical_artifacts = ship.critical_artifacts + 1
				end
			end
		end
	else
		if kraylor_headquarters:isValid() then
			if ship.critical_artifacts >= 1 then
				if ship:isDocked(kraylor_headquarters) then
					--deliver artifact
					enemy_artifacts_delivered = enemy_artifacts_delivered + ship.critical_artifacts
					ship.critical_artifacts = 0
					if #critical_artifacts >= artifact_index then
						local ax, ay = critical_artifacts[artifact_index]:getPosition()
						ship:orderFlyTowards(ax,ay)
						ship.artifact_target = critical_artifacts[artifact_index]
					else
						ship:destroy()
					end
				end
			else
				if ship:getOrder() ~= "Dock" then
					ship:orderDock(kraylor_headquarters)
				end
			end
		end
	end
end
function maintainKtlitanResearchFleet(research_fleet,ship,artifact_index)
	if #research_fleet < 1 or ship == nil or not ship:isValid() then
		if ktlitan_headquarters:isValid() and #critical_artifacts >= artifact_index then
			local ax, ay = critical_artifacts[artifact_index]:getPosition()
			if ship == nil or not ship:isValid() then
				ship = scienceResearch()
				ship.critical_artifacts = 0
				ship:setPosition(ktlitan_region_center_x,ktlitan_region_center_y):setFaction("Ktlitans"):orderFlyTowards(ax,ay)
				ship.artifact_target = critical_artifacts[artifact_index]
				if #research_fleet > 0 then
					for i,r_ship in ipairs(research_fleet) do
						r_ship:orderDefendTarget(ship)
					end
				end
				table.insert(science_ships,ship)
				table.insert(research_fleet,ship)
			end
			template_pool_size = 8
			fleetSpawnFaction = "Ktlitans"
			local fleet_repeat = adjustFleetStrength()
			for i=1,fleet_repeat do
				local fleet = spawnRandomArmed(ktlitan_region_center_x,ktlitan_region_center_y)
				for j,r_ship in ipairs(fleet) do
					r_ship:onTakingDamage(npcShipDamage)
					r_ship:orderDefendTarget(ship)
					table.insert(research_fleet,r_ship)
				end
			end
		end
	end
	return ship
end
function decideForKtlitanResearchShip(ship,artifact_index)
	if ship.artifact_target:isValid() then
		local current_distance_to_artifact = distance(ship,ship.artifact_target)
		local station_to_artifact_distance = 0
		if ktlitan_headquarters ~= nil and ktlitan_headquarters:isValid() then
			station_to_artifact_distance = distance(ship.artifact_target,ktlitan_headquarters)
		end
		if current_distance_to_artifact < (artifact_threshold * station_to_artifact_distance) then
			local proximity_warning = string.format(_("goal-incCall","Signals intelligence has intercepted a message from Ktlitan research ship %s in sector %s. Partial decryption indicates that the ship is approaching a technological artifact of interest."),ship:getCallSign(),ship:getSectorName())
			for i,p in ipairs(getActivePlayerShips()) do
				if p[ship:getCallSign()] == nil then
					if availableForComms(p) then
						hqs[p:getFaction()]:sendCommsMessage(p,proximity_warning)
						p[ship:getCallSign()] = "sent"
					end
				end
			end
		end
		if distance(ship,ship.artifact_target) < 3000 then
			for i,a in ipairs(critical_artifacts) do
				if a == ship.artifact_target then
					table.remove(critical_artifacts,i)
					a:destroy()
					ship:orderDock(ktlitan_headquarters)
					ship.critical_artifacts = ship.critical_artifacts + 1
				end
			end
		end
	else
		if ktlitan_headquarters:isValid() then
			if ship.critical_artifacts >= 1 then
				if ship:isDocked(ktlitan_headquarters) then
					--deliver artifact
					enemy_artifacts_delivered = enemy_artifacts_delivered + ship.critical_artifacts
					ship.critical_artifacts = 0
					if #critical_artifacts >= artifact_index then
						local ax, ay = critical_artifacts[artifact_index]:getPosition()
						ship:orderFlyTowards(ax,ay)
						ship.artifact_target = critical_artifacts[artifact_index]
					else
						ship:destroy()
					end
				end
			else
				if ship:getOrder() ~= "Dock" then
					ship:orderDock(ktlitan_headquarters)
				end
			end
		end
	end
end
function scienceResearch()
	local ship = CpuShip():setTemplate("Garbage Freighter 1")
	ship:setTypeName("Physics Research"):setCommsScript(""):setCommsFunction(commsShip)
	if ship_template["Physics Research"].short_range_radar ~= nil then
		ship:setShortRangeRadarRange(ship_template["Physics Research"].short_range_radar)
	end
	ship:onDestruction(scienceShipDestroyed)
	ship:onTakingDamage(npcShipDamage)
	ship:setImpulseMaxSpeed(85)				--faster impulse (vs 45)
	ship:setRotationMaxSpeed(10)			--faster maneuver (vs 6)
	ship:setShieldsMax(80, 80)				--stronger shields (vs 50, 50)
	ship:setShields(80, 80)					
	addFreighter("Physics Research",ship)	--update science database if applicable
	return ship
end
function scienceShipDestroyed(self,instigator)
	if self.critical_artifacts ~= nil and self.critical_artifacts > 0 then
		local ex, ey = self:getPosition()
		for i=1,self.critical_artifacts do
			local dx, dy = vectorFromAngle(random(0,360),random(3000,5000),true)
			createCriticalArtifact(ex + dx, ey + dy)
		end
	end
end
--	freighter information for science database
function addFreighters()
	local ships_key = _("scienceDB","Ships")
	local freighter_key = _("scienceDB","Freighter")
	local freighter_db = queryScienceDatabase(ships_key,freighter_key)
	if freighter_db == nil then
		local ship_db = queryScienceDatabase(ships_key)
		ship_db:addEntry(freighter_key)
		freighter_db = queryScienceDatabase(ships_key,freighter_key)
		freighter_db:setImage("radar/transport.png")
		freighter_db:setLongDescription(_("scienceDB","Small, medium and large scale transport ships. These are the working ships that keep commerce going in any sector. They may carry personnel, goods, cargo, equipment, garbage, fuel, research material, etc."))
	end
	return freighter_db
end
function addFreighter(freighter_type,ship)
	local ships_key = _("scienceDB","Ships")
	local freighter_db = addFreighters()
	local pers_freighter_1_key = "Personnel Freighter 1"
	local equip_freighter_2_key = "Equipment Freighter 2"
	local pers_jump_freighter_3_key = "Personnel Jump Freighter 3"
	local goods_freighter_3_key = "Goods Freighter 3"
	local garbage_freighter_3_key = "Garbage Freighter 3"
	local equip_jump_freighter_4_key = "Equipment Jump Freighter 4"
	local pers_jump_freighter_5_key = "Personnel Jump Freighter 5"
	local corvette_key = "Corvette"
	if freighter_type ~= nil then
		if freighter_type == "Space Sedan" then
			local space_sedan_key = _("scienceDB","Space Sedan")
			local space_sedan_db = queryScienceDatabase(ships_key,freighter_key,space_sedan_key)
			if space_sedan_db == nil then
				freighter_db:addEntry(space_sedan_key)
				space_sedan_db = queryScienceDatabase(ships_key,freighter_key,space_sedan_key)
				genericFreighterScienceInfo(space_sedan_db,queryScienceDatabase(ships_key,corvette_key,pers_jump_freighter_3_key),ship)
				space_sedan_db:setModelDataName("transport_1_3")
				space_sedan_db:setLongDescription(_("scienceDB","The Space Sedan was built around a surplus Personnel Jump Freighter 3. It's designed to provide relatively low cost transportation primarily for people, but there is also a limited amount of cargo space available"))
			end
		elseif freighter_type == "Omnibus" then
			local omnibus_key = _("scienceDB","Omnibus")
			local omnibus_db = queryScienceDatabase(ships_key,freighter_key,omnibus_key)
			if omnibus_db == nil then
				freighter_db:addEntry(omnibus_key)
				omnibus_db = queryScienceDatabase(ships_key,freighter_key,omnibus_key)
				genericFreighterScienceInfo(omnibus_db,queryScienceDatabase(ships_key,corvette_key,pers_jump_freighter_5_key),ship)
				omnibus_db:setModelDataName("transport_1_5")
				omnibus_db:setLongDescription(_("scienceDB","The Omnibus was designed from the Personnel Jump Freighter 5. It's made to transport large numbers of passengers of various types along with their luggage and any associated cargo"))
			end
		elseif freighter_type == "Service Jonque" then
			local service_jonque_key = _("scienceDB","Service Jonque")
			local service_jonque_db = queryScienceDatabase(ships_key,freighter_key,service_jonque_key)
			if service_jonque_db == nil then
				freighter_db:addEntry(service_jonque_key)
				service_jonque_db = queryScienceDatabase(ships_key,freighter_key,service_jonque_key)
				genericFreighterScienceInfo(service_jonque_db,queryScienceDatabase(ships_key,corvette_key,equip_jump_freighter_4_key),ship)
				service_jonque_db:setModelDataName("transport_4_4")
				service_jonque_db:setLongDescription(_("scienceDB","The Service Jonque is a modified Equipment Jump Freighter 4. It's designed to carry spare parts and equipment as well as the necessary repair personnel to where it's needed to repair stations and ships"))
			end
		elseif freighter_type == "Courier" then
			local courier_key = _("scienceDB","Courier")
			local courier_db = queryScienceDatabase(ships_key,freighter_key,courier_key)
			if courier_db == nil then
				freighter_db:addEntry(courier_key)
				courier_db = queryScienceDatabase(ships_key,freighter_key,courier_key)
				genericFreighterScienceInfo(courier_db,queryScienceDatabase(ships_key,corvette_key,pers_freighter_1_key),ship)
				courier_db:setModelDataName("transport_1_1")
				courier_db:setLongDescription(_("scienceDB","The Courier is a souped up Personnel Freighter 1. It's made to deliver people and messages fast. Very fast"))
			end
		elseif freighter_type == "Work Wagon" then
			local work_wagon_key = _("scienceDB","Work Wagon")
			local work_wagon_db = queryScienceDatabase(ships_key,freighter_key,work_wagon_key)
			if work_wagon_db == nil then
				freighter_db:addEntry(work_wagon_key)
				work_wagon_db = queryScienceDatabase(ships_key,freighter_key,work_wagon_key)
				genericFreighterScienceInfo(work_wagon_db,queryScienceDatabase(ships_key,corvette_key,equip_freighter_2_key),ship)
				work_wagon_db:setModelDataName("transport_4_2")
				work_wagon_db:setLongDescription(_("scienceDB","The Work Wagon is a conversion of an Equipment Freighter 2 designed to carry equipment and parts where they are needed for repair or construction."))
			end
		elseif freighter_type == "Laden Lorry" then
			local laden_lorry_key = _("scienceDB","Laden Lorry")
			local laden_lorry_db = queryScienceDatabase(ships_key,freighter_key,laden_lorry_key)
			if laden_lorry_db == nil then
				freighter_db:addEntry(laden_lorry_key)
				laden_lorry_db = queryScienceDatabase(ships_key,freighter_key,laden_lorry_key)
				genericFreighterScienceInfo(laden_lorry_db,queryScienceDatabase(ships_key,corvette_key,goods_freighter_3_key),ship)
				laden_lorry_db:setModelDataName("transport_2_3")
				laden_lorry_db:setLongDescription(_("scienceDB","As a side contract, Conversion R Us put together the Laden Lorry from some recently acquired Goods Freighter 3 hulls. The added warp drive makes for a more versatile goods carrying vessel."))
			end
		elseif freighter_type == "Physics Research" then
			local physics_research_key = _("scienceDB","Physics Research")
			local physics_research_db = queryScienceDatabase(ships_key,freighter_key,physics_research_key)
			if physics_research_db == nil then
				freighter_db:addEntry(physics_research_key)
				physics_research_db = queryScienceDatabase(ships_key,freighter_key,physics_research_key)
				genericFreighterScienceInfo(physics_research_db,queryScienceDatabase(ships_key,corvette_key,garbage_freighter_3_key),ship)
				physics_research_db:setModelDataName("transport_3_3")
				physics_research_db:setLongDescription(_("scienceDB","Conversion R Us cleaned up and converted excess freighter hulls into Physics Research vessels. The reduced weight improved the impulse speed and maneuverability."))
			end
		end
	end
end
function genericFreighterScienceInfo(specific_freighter_db,base_db,ship)
	local sub_class_key = _("scienceDB","Sub-class")
	local freighter_key = _("scienceDB","Freighter")
	local size_key = _("scienceDB","Size")
	local shield_key = _("scienceDB","Shield")
	local jump_range_key = _("scienceDB","Jump range")
	specific_freighter_db:setImage("radar/transport.png")
	specific_freighter_db:setKeyValue(sub_class_key,freighter_key)
	specific_freighter_db:setKeyValue(size_key,base_db:getKeyValue(size_key))
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
		specific_freighter_db:setKeyValue(shield_key,shield_string)
	end
	specific_freighter_db:setKeyValue(_("scienceDB","Hull"),string.format("%i",math.floor(ship:getHullMax())))
	specific_freighter_db:setKeyValue(_("scienceDB","Move speed"),string.format(_("scienceDB","%.1f u/min"),ship:getImpulseMaxSpeed()*60/1000))
	specific_freighter_db:setKeyValue(_("scienceDB","Turn speed"),string.format(_("scienceDB","%.1f deg/sec"),ship:getRotationMaxSpeed()))
	if ship:hasJumpDrive() then
		local base_jump_range = base_db:getKeyValue(jump_range_key)
		if base_jump_range ~= nil and base_jump_range ~= "" then
			specific_freighter_db:setKeyValue(jump_range_key,base_jump_range)
		else
			specific_freighter_db:setKeyValue(jump_range_key,_("scienceDB","5 - 50 u"))
		end
	end
	if ship:hasWarpDrive() then
		specific_freighter_db:setKeyValue(_("scienceDB","Warp Speed"),string.format(_("scienceDB","%.1f u/min"),ship:getWarpSpeed()*60/1000))
	end
end
function adjustFleetStrength()
	fleetStrengthByPlayerStrength = 1
	local fleet_repeat = 1
	if playerPower() > 99 then
		fleetStrengthByPlayerStrength = .5
		fleet_repeat = 2
		if playerPower() > 199 then
			fleetStrengthByPlayerStrength = 1/3
			fleet_repeat = 3
			if playerPower() > 299 then
				fleetStrengthByPlayerStrength = 1/4
				fleet_repeat = 4
				if playerPower > 399 then
					fleetStrengthByPlayerStrength = 1/5
					fleet_repeat = 5
				end
			end
		end
	end
	return fleet_repeat
end
function updateSpikySpinShips()
	for index, ship in ipairs(spiky_spin_ships) do
		local current_clock = getScenarioTime()
		if current_clock > ship.spiky_spin_active then
			if ship:getRotationMaxSpeed() ~= ship.spiky_spin_normal then
				ship:setRotationMaxSpeed(ship.spiky_spin_normal)
			end
		end
		if current_clock > ship.spiky_spin_cooling then
			ship.spiky_spin_active = nil
			ship.spiky_spin_cooling = nil
			table.remove(spiky_spin_ships,index)
			break
		end
	end
end
function updateCyberAttackShips()
	for index, ship in ipairs(cyber_attack_ships) do
		if ship ~= nil and ship:isValid() then
			if ship.cyber_attack_timer == nil then
				local obj_list = ship:getObjectsInRange(20000)
				local player_victims = {}
				local cpu_ship_victims = {}
				for i,obj in ipairs(obj_list) do
					if isObjectType(obj,"PlayerSpaceship") then
						if obj:isEnemy(ship) then
							table.insert(player_victims,obj)
						end
					elseif isObjectType(obj,"CpuShip") then
						if obj:isEnemy(ship) then
							table.insert(cpu_ship_victims,obj)
						end
					end
				end
				if #player_victims > 0 then
					if random(1,100) <= ship.cyber_attack_factor then
						local player_ship = player_victims[math.random(1,#player_victims)]
						local system_list = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield"}
						if not player_ship:hasWarpDrive() then
							table.remove(system_list,6)
							if not player_ship:hasJumpDrive() then
								table.remove(system_list,6)
							end
						elseif not player_ship:hasJumpDrive() then
							table.remove(system_list,7)
						end
						if player_ship:getShieldCount() > 1 then
							table.insert(system_list,"rearshield")
						end
						selected_system = system_list[math.random(1,#system_list)]
						player_ship:setSystemHackedLevel(selected_system,math.min(player_ship:getSystemHackedLevel(selected_system) + .5,1))
					end
					ship.cyber_attack_timer = getScenarioTime() + ship.cyber_attack_interval
				elseif #cpu_ship_victims > 0 then
					if random(1,100) <= ship.cyber_attack_factor then
						local cpu_ship = cpu_ship_victims[math.random(1,#cpu_ship_victims)]
						local system_list = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield"}
						if not cpu_ship:hasWarpDrive() then
							table.remove(system_list,6)
							if not cpu_ship:hasJumpDrive() then
								table.remove(system_list,6)
							end
						elseif not cpu_ship:hasJumpDrive() then
							table.remove(system_list,7)
						end
						if cpu_ship:getShieldCount() > 1 then
							table.insert(system_list,"rearshield")
						end
						selected_system = system_list[math.random(1,#system_list)]
						cpu_ship:setSystemHackedLevel(selected_system,math.min(cpu_ship:getSystemHackedLevel(selected_system) + .5,1))
					end
					ship.cyber_attack_timer = getScenarioTime() + ship.cyber_attack_interval
				end
			elseif getScenarioTime() > ship.cyber_attack_timer then
				ship.cyber_attack_timer = nil
			end
		else
			table.remove(cyber_attack_ships,index)
			break
		end
	end
end
function updatePointDefenseShips()
	for index, ship in pairs(pdc_ships) do
		if ship ~= nil and ship:isValid() then
			local template_name = ship:getTypeName()
			if template_name == nil then
				print("template name for item in pdc ship list cannot be determined")
			end
			local base_distance = shipTemplateDistance[template_name]
			if base_distance == nil then
				print(string.format("Cannot determine the ship size based on the template name. Check the shipTemplateDistance table for template %s",template_name))
			else
				local obj_list = ship:getObjectsInRange(base_distance + 500)
				for _, obj in ipairs(obj_list) do
					if isObjectType(obj,"HomingMissile","MovingMissile") or isObjectType(obj,"HVLI","MovingMissile") or isObjectType(obj,"Nuke","MovingMissile") or isObjectType(obj,"EMPMissile","MovingMissile") then
						if obj:getOwner() ~= ship then
							if obj.pdc_cycle == nil then
								local adjusted_factor = ship.pdc_factor * ship:getSystemHealth("beamweapons")
								obj.pdc_success = (random(1,100) <= adjusted_factor)
								obj.pdc_cycle = {}
								local attempts = math.random(1,8)
								local trigger_time = getScenarioTime()
								local interval = 1/attempts
								for i=1,attempts do
									obj.pdc_cycle[i] = {time = trigger_time, done = false, len = interval*.75}
									trigger_time = trigger_time + interval
								end
							end
							local current_time = getScenarioTime()
							local completed_shots = true
							for _, shot in ipairs(obj.pdc_cycle) do
								if not shot.done then
									if current_time >= shot.time then
										BeamEffect():setSource(ship,0,0,0):setTarget(obj,0,0):setBeamFireSoundPower(2):setRing(false):setDuration(shot.len)
										shot.done = true
									end
									completed_shots = false
								end
							end
							if completed_shots and obj.pdc_success then
								local exp_x, exp_y = obj:getPosition()
								ExplosionEffect():setPosition(exp_x,exp_y):setSize(40):setOnRadar(true)
								obj:destroy()
							end
						end
					end
				end
			end
		else
			table.remove(pdc_ships,index)
			break
		end
	end
end
function update(delta)
	if delta == 0 then
		local player_ship_count = #getActivePlayerShips()
		if player_ship_count ~= previous_player_ship_count then
			if player_ship_count > 5 then
				if player_ship_count == 6 then
					for i,p in ipairs(getActivePlayerShips()) do
						if i > 3 then
							p:setFaction("TSN")
						else
							p:setFaction("Human Navy")
						end
					end
				elseif player_ship_count == 7 or player_ship_count == 8 then
					for i,p in ipairs(getActivePlayerShips()) do
						if i > 4 then
							p:setFaction("TSN")
						else
							p:setFaction("Human Navy")
						end
					end
				else
					for i,p in ipairs(getActivePlayerShips()) do
						if i > 6 then
							p:setFaction("CUF")
						elseif i > 3 then
							p:setFaction("TSN")
						else
							p:setFaction("Human Navy")
						end
					end
				end
			end
		end
		if player_ship_count > 9 then
			for i,p in ipairs(getActivePlayerShips()) do
				if i > 9 then
					p:destroy()
				end
			end
		end
		previous_player_ship_count = player_ship_count
		return	--paused nothing else to do right now
	end
	if not environment_constructed then
		constructEnvironment()
		if starting_players == nil then
			starting_players = #getActivePlayerShips()
		end
		return	--still constructing environment
	end
	if starting_critical_artifacts == nil then
		starting_critical_artifacts = #critical_artifacts
	end
	for i,p in ipairs(getActivePlayerShips()) do
		updatePlayerInitialMissionMessage(p)
		updatePlayerInventoryButtonUtility(p)
		updatePlayerShipNameBanner(p)
--		updatePlayerInNebula(delta,p)
		updatePlayerLongRangeSensors(delta,p)
		improvedStationService(p)
		updatePlayerBalanceShield(p)
		updatePlayerMissileTriggerButtons(p)
	end
	updateVictoryDefeat()
	updateAttackForce()
	updateArtifactForce()
	updateSpikySpinShips()
	updateCyberAttackShips()
	updatePlanetCollisionDetection()
	updateOrbitingPlatforms()
--	updateStationDefense()
	maintainTransports()
	updateCheckArtifactsImpact()
	updateCriticalArtifacts()
end
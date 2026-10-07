-- Name: Treasure Race
-- Description: Be the first to get all the treasures to win
---
--- Designed for multiple player ships competing against each other in a race to gather up "treasures." Three major variations with GM controls for changing things within each variation
--- 
-- Type: Race
-- Setting[Treasure Race Type]: Selects the treasure race type. Normal is the default: get 3 treasures. Return to designated sector
-- Treasure Race Type[Normal|Default]: Get three treasures. Return to designated sector
-- Treasure Race Type[Hunger]: Get two treasures. Dock with station
-- Treasure Race Type[Explorer]: Get three treasures. Dock with station

-- How to add a variation to this scenario
--	1. 	Name it. See examples on lines 6 and 7 above
--	2.	Add related elseif clause to setVariations function
--	3.	Add related elseif clause at the end of setConstants function and create variation specific constants function shell
--	4.	Add related elseif clause to initialPlayerShipPlacement function create player placement routine shell
--	5.	Decide where players appear: write your own function or reuse an existing one
--	6.	In variation specific constants function 
--		a.	Build any static terrain
--		b.	Set functions that build terrain after players determined (when game unpaused).
--			These are postPauseBuild1, postPauseBuild2 and postPauseBuild3. 
--			Spread work between these three function to minimize impact to update loop.
--		c.	Set collection criteria list of functions. These should be per player ship
--		d.	Set completion criteria list of functions. These should be per player ship
--		e.	Set general variation updates. These are executed after the player portion of the update loop

require("utils.lua")

-- **************** --
--	Initialization  --
-- **************** --
function init()
	scenario_version = "1.3.2"
	ee_version = "2024.12.08"
	scenario_name = "Treasure Race"
	print(string.format("    ----    Scenario: %s    ----    Version %s    ----    Tested with EE version %s    ----",scenario_name,scenario_version,ee_version))
	if _VERSION ~= nil then
		print("Lua version:",_VERSION)
	end
	setVariations()
	setConstants()
	setGMButtons()
	storage = getScriptStorage()
	storage.gatherStats = gatherStats
end
function setVariations()
	variation_description = {
		["Normal"] =	"Default or normal variation summary:\nCollect three alpha type treasures\n   Scan of artifact reveals whether it is a treasure or not\nReturn to the designated completion sector\n   Sector identified by message and colored zone on Science/Relay\nTerrain and treasures randomized",
		["Hunger"] =	"Hunger variation summary:\nCollect alpha type treasure\n   Scan of artifact reveals whether it is a treasure or not\nCollect anti-social type treasure\n   Treasure protected by mines\n(third treasure collection type goal to be added later)\nDock with primary station\n   Primary station changes location according to a pattern\nTerrain somewhat randomized. Treasures random within rings around a central location.",
		["Explorer"] =	"Explorer variation summary:\nCollect jump or warp treasure\n   not strictly required, but obvious penalties if omitted\nCollect alpha type treasure\n   Scan of artifact reveals whether it is a treasure or not\nCollect foxtrot type treasure\n   Find treasure, scan it, report readings to primary station\nCollect shy type treasure\n   Treasure will evade if not approached appropriately\nDock with primary station\n   Centrally located primary station\nTerrain randomized to three regions, each region's location is randomized. Central treasure region has treasures randomized within rings",
	}
	game_variation = getScenarioSetting("Treasure Race Type")
end
function setConstants()
	-- Default values common across some or all variations
	-- Some may be overridden by variation or GM button
	-- Add a comment if variation or GM button modifies or might modify a value
	player_restart = {}
	player_restart.add = function(pidx,name,control_code,start_x,start_y,faction,respawn_count)
		if pidx == nil then
			return
		end
		if player_restart[pidx] ~= nil then
			if name == nil then
				name = player_restart[pidx].name
			end
			if control_code == nil then
				control_code = player_restart[pidx].control_code
			end
			if start_x == nil then
				start_x = player_restart[pidx].start_x
			end
			if start_y == nil then
				start_y = player_restart[pidx].start_y
			end
			if faction == nil then
				faction = player_restart[pidx].faction
			end
			if respawn_count == nil then
				respawn_count = player_restart[pidx].respawn_count
			end
		end
		player_restart[pidx] = {name = name, control_code = control_code, start_x = start_x, start_y = start_y, faction = faction, respawn_count = respawn_count}
	end
	ordered_player_ship_names = {
		"Calamity",
		"Damocles",
		"Endeavor",
		"Glitter",
		"Hyperion",
		"Onyx",
		"Prismatic",
		"Raven",
		"Satsuma",
	}
	rwc_player_ship_names = {	--rwc: random within category
		["Atlantis"] = {"Formidable","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"},
		["Benedict"] = {"Elizabeth","Ford","Avenger","Washington","Lincoln","Garibaldi","Eisenhower"},
		["Crucible"] = {"Sling", "Stark", "Torrid", "Kicker", "Flummox"},
		["Ender"] = {"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"},
		["Flavia P.Falcon"] = {"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"},
		["Hathcock"] = {"Hayha", "Waldron", "Plunkett", "Mawhinney", "Furlong", "Zaytsev", "Pavlichenko", "Fett", "Hawkeye", "Hanzo"},
		["Kiriya"] = {"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"},
		["MP52 Hornet"] = {"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"},
		["Maverick"] = {"Angel", "Thunderbird", "Roaster", "Magnifier", "Hedge"},
		["Nautilus"] = {"October", "Abdiel", "Manxman", "Newcon", "Nusret", "Pluton", "Amiral", "Amur", "Heinkel", "Dornier"},
		["Phobos M3P"] = {"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"},
		["Piranha"] = {"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"},
		["Player Cruiser"] = {"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"},
		["Player Fighter"] = {"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"},
		["Player Missile Cr."] = {"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"},
		["Repulse"] = {"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"},
		["Striker"] = {"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"},
		["ZX-Lindworm"]	= {"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"},
		["Unknown"] = {"Foregone","Righteous","Masher","Lancer","Horizon","Osiris","Athena","Poseidon","Heracles","Constitution","Stargazer","Horatio","Socrates","Galileo","Newton","Beethoven","Rabin","Spector","Akira","Thunderchild","Ambassador","Adelphi","Exeter","Ghandi","Valdemar","Yamaguchi","Zhukov","Andromeda","Drake","Prokofiev","Antares","Apollo","Ajax","Clement","Bradbury","Gage","Buran","Kearsarge","Cheyenne","Ahwahnee","Constellation","Gettysburg","Hathaway","Magellan","Farragut","Kongo","Lexington","Potempkin","Yorktown","Daedalus","Archon","Carolina","Essex","Danube","Gander","Ganges","Mekong","Orinoco","Rubicon","Shenandoah","Volga","Yangtzee Kiang","Yukon","Valiant","Deneva","Arcos","LaSalle","Al-Batani","Cairo","Charlseton","Crazy Horse","Crockett","Fearless","Fredrickson","Gorkon","Hood","Lakota","Malinche","Melbourne","Freedom","Concorde","Firebrand","Galaxy","Challenger","Odyssey","Trinculo","Venture","Yamato","Hokule'a","Tripoli","Hope","Nobel","Pasteur","Bellerophon","Voyager","Istanbul","Constantinople","Havana","Sarajevo","Korolev","Goddard","Luna","Titan","Mediterranean","Lalo","Wyoming","Merced","Trieste","Miranda","Brattain","Helin","Lantree","Majestic","Reliant","Saratoga","ShirKahr","Sitak","Tian An Men","Trial","Nebula","Bonchune","Capricorn","Hera","Honshu","Interceptor","Leeds","Merrimack","Prometheus","Proxima","Sutherland","T'Kumbra","Ulysses","New Orleans","Kyushu","Renegade","Rutledge","Thomas Paine","Niagra","Princeton","Wellington","Norway","Budapest","Nova","Equinox","Rhode Island","Columbia","Oberth","Biko","Cochraine","Copernicus","Grissom","Pegasus","Raman","Yosemite","Renaissance","Aries","Maryland","Rigel","Akagi","Tolstoy","Yeager","Sequoia","Sovereign","Soyuz","Bozeman","Springfield","Chekov","Steamrunner","Appalachia","Surak","Zapata","Sydney","Jenolen","Nash","Wambundu","Fleming","Wells","Relativity","Yorkshire","Denver","Zodiac","Centaur","Cortez","Republic","Peregrine","Calypso","Cousteau","Waverider","Scimitar"},
	}
	initialPlayerShipAdjustments = defaultPlayerShipAdjustments	--can be changed by variation
	player_ship_stats={	["MP52 Hornet"] 		= { strength = 7, 	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 4000},
						["Piranha"]				= { strength = 16,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 6000},
						["Flavia P.Falcon"]		= { strength = 13,	cargo = 15,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000},
						["Phobos M3P"]			= { strength = 19,	cargo = 10,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000},
						["Atlantis"]			= { strength = 52,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000},
						["Player Cruiser"]		= { strength = 40,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000},
						["Player Missile Cr."]	= { strength = 45,	cargo = 8,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000},
						["Player Fighter"]		= { strength = 7,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500},
						["Benedict"]			= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000},
						["Kiriya"]				= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 35000, short_range_radar = 5000},
						["Striker"]				= { strength = 8,	cargo = 4,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000},
						["ZX-Lindworm"]			= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 5500},
						["Repulse"]				= { strength = 14,	cargo = 12,	distance = 200,	long_range_radar = 38000, short_range_radar = 5000},
						["Ender"]				= { strength = 100,	cargo = 20,	distance = 2000,long_range_radar = 45000, short_range_radar = 7000},
						["Nautilus"]			= { strength = 12,	cargo = 7,	distance = 200,	long_range_radar = 22000, short_range_radar = 4000},
						["Hathcock"]			= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000},
						["Maverick"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000},
						["Crucible"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000},
						["Explorer"]			= { strength = 22,	cargo = 6,	distance = 400,	long_range_radar = 20000, short_range_radar = 5000},
					}		
	control_code_stem = {	--All control codes must use capital letters or they will not work.
		"ALWAYS",
		"BLACK",
		"BLUE",
		"BRIGHT",
		"BROWN",
		"CHAIN",
		"CHURCH",
		"DOORWAY",
		"DULL",
		"ELBOW",
		"EMPTY",
		"EPSILON",
		"FLOWER",
		"FLY",
		"FROZEN",
		"GREEN",
		"GLOW",
		"HAMMER",
		"INK",
		"JUMP",
		"KEY",
		"LETTER",
		"LIST",
		"MORNING",
		"NEXT",
		"OPEN",
		"ORANGE",
		"OUTSIDE",
		"PURPLE",
		"QUARTER",
		"QUIET",
		"RED",
		"SHINE",
		"SIGMA",
		"STAR",
		"STREET",
		"TOKEN",
		"THIRSTY",
		"UNDER",
		"VANISH",
		"WHITE",
		"WRENCH",
		"YELLOW",
	}
	player_circular_placement = {	--used by hunger and explorer variations
		{angle_increment = 0,		radius = 28000,	ring_1 = 8,		ring_2 = 16,	ring_3 = 24,	ring_4 = 36,	ring_5 = 36,	ring_6 = 45},
		{angle_increment = 180,		radius = 28000, ring_1 = 8,		ring_2 = 16,	ring_3 = 24,	ring_4 = 36,	ring_5 = 36,	ring_6 = 48},
		{angle_increment = 120,		radius = 28000, ring_1 = 9,		ring_2 = 12,	ring_3 = 24,	ring_4 = 36,	ring_5 = 36,	ring_6 = 45},
		{angle_increment = 90,		radius = 28000, ring_1 = 8,		ring_2 = 16,	ring_3 = 24,	ring_4 = 36,	ring_5 = 36,	ring_6 = 48},
		{angle_increment = 72,		radius = 28000, ring_1 = 10,	ring_2 = 15,	ring_3 = 25,	ring_4 = 35,	ring_5 = 40,	ring_6 = 45},
		{angle_increment = 60,		radius = 28000, ring_1 = 12,	ring_2 = 12,	ring_3 = 24,	ring_4 = 36,	ring_5 = 36,	ring_6 = 48},
		{angle_increment = 360/7,	radius = 30000, ring_1 = 7,		ring_2 = 14,	ring_3 = 28,	ring_4 = 35,	ring_5 = 42,	ring_6 = 56},
		{angle_increment = 360/8,	radius = 30000, ring_1 = 8,		ring_2 = 16,	ring_3 = 24,	ring_4 = 36,	ring_5 = 36,	ring_6 = 48},
		{angle_increment = 360/9,	radius = 30000, ring_1 = 9,		ring_2 = 18,	ring_3 = 27,	ring_4 = 36,	ring_5 = 36,	ring_6 = 45},
		{angle_increment = 36,		radius = 30000, ring_1 = 10,	ring_2 = 20,	ring_3 = 30,	ring_4 = 30,	ring_5 = 40,	ring_6 = 50},
		{angle_increment = 360/11,	radius = 35000, ring_1 = 11,	ring_2 = 11,	ring_3 = 22,	ring_4 = 33,	ring_5 = 44,	ring_6 = 55},
		{angle_increment = 360/12,	radius = 35000, ring_1 = 12,	ring_2 = 12,	ring_3 = 24,	ring_4 = 36,	ring_5 = 48,	ring_6 = 48},
		{angle_increment = 360/13,	radius = 35000, ring_1 = 13,	ring_2 = 26,	ring_3 = 26,	ring_4 = 39,	ring_5 = 39,	ring_6 = 52},
		{angle_increment = 360/14,	radius = 35000, ring_1 = 7,		ring_2 = 14,	ring_3 = 28,	ring_4 = 42,	ring_5 = 42,	ring_6 = 56},
		{angle_increment = 360/15,	radius = 40000, ring_1 = 15,	ring_2 = 15,	ring_3 = 30,	ring_4 = 45,	ring_5 = 45,	ring_6 = 45},
		{angle_increment = 360/16,	radius = 40000, ring_1 = 8,		ring_2 = 16,	ring_3 = 32,	ring_4 = 32,	ring_5 = 48,	ring_6 = 48},
		{angle_increment = 360/17,	radius = 40000, ring_1 = 0,		ring_2 = 17,	ring_3 = 34,	ring_4 = 34,	ring_5 = 51,	ring_6 = 68},
		{angle_increment = 360/18,	radius = 40000, ring_1 = 9,		ring_2 = 18,	ring_3 = 36,	ring_4 = 36,	ring_5 = 54,	ring_6 = 54},
		{angle_increment = 360/19,	radius = 40000, ring_1 = 0,		ring_2 = 19,	ring_3 = 19,	ring_4 = 38,	ring_5 = 38,	ring_6 = 57},
		{angle_increment = 360/20,	radius = 40000, ring_1 = 10,	ring_2 = 20,	ring_3 = 30,	ring_4 = 40,	ring_5 = 40,	ring_6 = 60},
		{angle_increment = 360/21,	radius = 40000, ring_1 = 7,		ring_2 = 21,	ring_3 = 21,	ring_4 = 42,	ring_5 = 42,	ring_6 = 63},
		{angle_increment = 360/22,	radius = 40000, ring_1 = 11,	ring_2 = 11,	ring_3 = 22,	ring_4 = 44,	ring_5 = 44,	ring_6 = 44},
		{angle_increment = 360/23,	radius = 40000, ring_1 = 0,		ring_2 = 23,	ring_3 = 23,	ring_4 = 46,	ring_5 = 46,	ring_6 = 46},
		{angle_increment = 360/24,	radius = 45000, ring_1 = 12,	ring_2 = 24,	ring_3 = 24,	ring_4 = 48,	ring_5 = 48,	ring_6 = 48},
		{angle_increment = 360/25,	radius = 45000, ring_1 = 0,		ring_2 = 25,	ring_3 = 25,	ring_4 = 25,	ring_5 = 50,	ring_6 = 50},
		{angle_increment = 360/26,	radius = 45000, ring_1 = 13,	ring_2 = 26,	ring_3 = 26,	ring_4 = 39,	ring_5 = 52,	ring_6 = 52},
		{angle_increment = 360/27,	radius = 45000, ring_1 = 9,		ring_2 = 27,	ring_3 = 27,	ring_4 = 36,	ring_5 = 54,	ring_6 = 54},
		{angle_increment = 360/28,	radius = 45000, ring_1 = 14,	ring_2 = 14,	ring_3 = 28,	ring_4 = 28,	ring_5 = 42,	ring_6 = 56},
		{angle_increment = 360/29,	radius = 45000, ring_1 = 0,		ring_2 = 0,		ring_3 = 29,	ring_4 = 29,	ring_5 = 58,	ring_6 = 58},
		{angle_increment = 360/30,	radius = 50000, ring_1 = 15,	ring_2 = 15,	ring_3 = 30,	ring_4 = 30,	ring_5 = 45,	ring_6 = 60},
		{angle_increment = 360/31,	radius = 50000, ring_1 = 0,		ring_2 = 0,		ring_3 = 31,	ring_4 = 31,	ring_5 = 62,	ring_6 = 62},
		{angle_increment = 360/32,	radius = 50000, ring_1 = 16,	ring_2 = 16,	ring_3 = 32,	ring_4 = 32,	ring_5 = 48,	ring_6 = 64},
	}
	players_on_teams = false	--may be changed by variation
	player_teams = {	--used when players_on_teams is true: currently in explorer variation
		{human =  1, kraylor =  0, hive = 0, usn = 0, tsn = 0, cuf = 0, faction_list = {"Human Navy"}},											--  1 player
		{human =  1, kraylor =  1, hive = 0, usn = 0, tsn = 0, cuf = 0, faction_list = {"Human Navy","Kraylor"}}, 								--  2 players
		{human =  1, kraylor =  1, hive = 1, usn = 0, tsn = 0, cuf = 0, faction_list = {"Human Navy","Kraylor","Ktlitans"}},					--  3 players
		{human =  0, kraylor =  1, hive = 1, usn = 1, tsn = 1, cuf = 0, faction_list = {"Kraylor","Ktlitans","USN","TSN"}},						--  4 players
		{human =  0, kraylor =  1, hive = 1, usn = 1, tsn = 1, cuf = 1, faction_list = {"Kraylor","Ktlitans","USN","TSN","CUF"}},				--  5 players
		{human =  1, kraylor =  1, hive = 1, usn = 1, tsn = 1, cuf = 1, faction_list = {"Human Navy","Kraylor","Ktlitans","USN","TSN","CUF"}},	--  6 players
		{human =  3, kraylor =  4, hive = 0, usn = 0, tsn = 0, cuf = 0, faction_list = {"Human Navy","Kraylor"}},								--  7 players
		{human =  0, kraylor =  2, hive = 2, usn = 2, tsn = 2, cuf = 0, faction_list = {"Kraylor","Ktlitans","USN","TSN"}},						--  8 players
		{human =  3, kraylor =  3, hive = 3, usn = 0, tsn = 0, cuf = 0, faction_list = {"Human Navy","Kraylor","Ktlitans"}},					--  9 players
		{human =  5, kraylor =  5, hive = 0, usn = 0, tsn = 0, cuf = 0, faction_list = {"Human Navy","Kraylor"}},								-- 10 players
		{human =  5, kraylor =  6, hive = 0, usn = 0, tsn = 0, cuf = 0, faction_list = {"Human Navy","Kraylor"}},								-- 11 players
		{human =  2, kraylor =  2, hive = 2, usn = 2, tsn = 2, cuf = 2, faction_list = {"Human Navy","Kraylor","Ktlitans","USN","TSN","CUF"}},	-- 12 players
		{human =  6, kraylor =  7, hive = 0, usn = 0, tsn = 0, cuf = 0, faction_list = {"Human Navy","Kraylor"}},								-- 13 players
		{human =  7, kraylor =  7, hive = 0, usn = 0, tsn = 0, cuf = 0, faction_list = {"Human Navy","Kraylor"}},								-- 14 players
		{human =  0, kraylor =  3, hive = 3, usn = 3, tsn = 3, cuf = 3, faction_list = {"Kraylor","Ktlitans","USN","TSN","CUF"}},				-- 15 players
		{human =  0, kraylor =  4, hive = 4, usn = 4, tsn = 4, cuf = 0, faction_list = {"Kraylor","Ktlitans","USN","TSN"}},						-- 16 players
		{human =  8, kraylor =  9, hive = 0, usn = 0, tsn = 0, cuf = 0, faction_list = {"Human Navy","Kraylor"}},								-- 17 players
		{human =  3, kraylor =  3, hive = 3, usn = 3, tsn = 3, cuf = 3, faction_list = {"Human Navy","Kraylor","Ktlitans","USN","TSN","CUF"}},	-- 18 players
		{human = 10, kraylor =  9, hive = 0, usn = 0, tsn = 0, cuf = 0, faction_list = {"Human Navy","Kraylor"}},								-- 19 players
		{human =  0, kraylor =  4, hive = 4, usn = 4, tsn = 4, cuf = 4, faction_list = {"Kraylor","Ktlitans","USN","TSN","CUF"}},				-- 20 players
		{human =  7, kraylor =  7, hive = 7, usn = 0, tsn = 0, cuf = 0, faction_list = {"Human Navy","Kraylor","Ktlitans"}},					-- 21 players
		{human = 11, kraylor = 11, hive = 0, usn = 0, tsn = 0, cuf = 0, faction_list = {"Human Navy","Kraylor"}},								-- 22 players
		{human = 11, kraylor = 12, hive = 0, usn = 0, tsn = 0, cuf = 0, faction_list = {"Human Navy","Kraylor"}},								-- 23 players
		{human =  4, kraylor =  4, hive = 4, usn = 4, tsn = 4, cuf = 4, faction_list = {"Human Navy","Kraylor","Ktlitans","USN","TSN","CUF"}},	-- 24 players
		{human =  0, kraylor =  5, hive = 5, usn = 5, tsn = 5, cuf = 5, faction_list = {"Kraylor","Ktlitans","USN","TSN","CUF"}},				-- 25 players
		{human = 13, kraylor = 13, hive = 0, usn = 0, tsn = 0, cuf = 0, faction_list = {"Human Navy","Kraylor"}},								-- 26 players
		{human =  9, kraylor =  9, hive = 9, usn = 0, tsn = 0, cuf = 0, faction_list = {"Human Navy","Kraylor","Ktlitans"}},					-- 27 players
		{human =  0, kraylor =  7, hive = 7, usn = 7, tsn = 7, cuf = 0, faction_list = {"Kraylor","Ktlitans","USN","TSN"}},						-- 28 players
		{human = 14, kraylor = 15, hive = 0, usn = 0, tsn = 0, cuf = 0, faction_list = {"Human Navy","Kraylor"}},								-- 29 players
		{human =  5, kraylor =  5, hive = 5, usn = 5, tsn = 5, cuf = 5, faction_list = {"Human Navy","Kraylor","Ktlitans","USN","TSN","CUF"}},	-- 30 players
		{human = 15, kraylor = 16, hive = 0, usn = 0, tsn = 0, cuf = 0, faction_list = {"Human Navy","Kraylor"}},								-- 31 players
		{human =  0, kraylor =  8, hive = 8, usn = 8, tsn = 8, cuf = 0, faction_list = {"Kraylor","Ktlitans","USN","TSN"}},						-- 32 players
	}
	ship_template = {	--ordered by relative strength
		["Gnat"] =				{strength = 2,	create = gnat},
		["Lite Drone"] =		{strength = 3,	create = droneLite},
		["Jacket Drone"] =		{strength = 4,	create = droneJacket},
		["Ktlitan Drone"] =		{strength = 4,	create = stockTemplate},
		["Heavy Drone"] =		{strength = 5,	create = droneHeavy},
		["Adder MK3"] =			{strength = 5,	create = adderMk3},
		["MT52 Hornet"] =		{strength = 5,	create = stockTemplate},
		["MU52 Hornet"] =		{strength = 5,	create = stockTemplate},
		["MV52 Hornet"] =		{strength = 6,	create = hornetMV52},
		["Adder MK4"] =			{strength = 6,	create = stockTemplate},
		["Fighter"] =			{strength = 6,	create = stockTemplate},
		["Ktlitan Fighter"] =	{strength = 6,	create = stockTemplate},
		["K2 Fighter"] =		{strength = 7,	create = k2fighter},
		["Adder MK5"] =			{strength = 7,	create = stockTemplate},
		["WX-Lindworm"] =		{strength = 7,	create = stockTemplate},
		["K3 Fighter"] =		{strength = 8,	create = k3fighter},
		["Adder MK6"] =			{strength = 8,	create = stockTemplate},
		["Ktlitan Scout"] =		{strength = 8,	create = stockTemplate},
		["WZ-Lindworm"] =		{strength = 9,	create = wzLindworm},
		["Adder MK7"] =			{strength = 9,	create = adderMk7},
		["Adder MK8"] =			{strength = 10,	create = adderMk8},
		["Adder MK9"] =			{strength = 11,	create = adderMk9},
		["Nirvana R3"] =		{strength = 12,	create = nirvanaR3},
		["Phobos R2"] =			{strength = 13,	create = phobosR2},
		["Missile Cruiser"] =	{strength = 14,	create = stockTemplate},
		["Waddle 5"] =			{strength = 15,	create = waddle5},
		["Jade 5"] =			{strength = 15,	create = jade5},
		["Phobos T3"] =			{strength = 15,	create = stockTemplate},
		["Piranha F8"] =		{strength = 15,	create = stockTemplate},
		["Piranha F12"] =		{strength = 15,	create = stockTemplate},
		["Phobos M3"] =			{strength = 16,	create = stockTemplate},
		["Cruiser"] =			{strength = 18,	create = stockTemplate},
		["Nirvana R5A"] =		{strength = 20,	create = stockTemplate},
		["Storm"] =				{strength = 22,	create = stockTemplate},
		["Stalker R5"] =		{strength = 22,	create = stalkerR5},
		["Stalker Q5"] =		{strength = 22,	create = stalkerQ5},
		["Ranus U"] =			{strength = 25,	create = stockTemplate},
		["Stalker Q7"] =		{strength = 25,	create = stockTemplate},
		["Stalker R7"] =		{strength = 25,	create = stockTemplate},
		["Adv. Striker"] =		{strength = 27,	create = stockTemplate},
		["Elara P2"] =			{strength = 28,	create = elaraP2},
		["Tempest"] =			{strength = 30,	create = tempest},
		["Strikeship"] =		{strength = 30,	create = stockTemplate},
		["Fiend G3"] =			{strength = 33,	create = fiendG3},
		["Fiend G4"] =			{strength = 35,	create = fiendG4},
		["Fiend G5"] =			{strength = 37,	create = fiendG5},
		["Fiend G6"] =			{strength = 39,	create = fiendG6},
		["Ktlitan Worker"] =	{strength = 40,	create = stockTemplate},
		["Predator"] =			{strength = 42,	create = predator},
		["Ktlitan Breaker"] =	{strength = 45,	create = stockTemplate},
		["Ktlitan Feeder"] =	{strength = 48,	create = stockTemplate},
		["Atlantis X23"] =		{strength = 50,	create = stockTemplate},
		["Ktlitan Destroyer"] =	{strength = 50,	create = stockTemplate},
		["Atlantis Y42"] =		{strength = 60,	create = atlantisY42},
		["Blockade Runner"] =	{strength = 65,	create = stockTemplate},
		["Starhammer II"] =		{strength = 70,	create = stockTemplate},
		["Enforcer"] =			{strength = 75,	create = enforcer},
		["Dreadnought"] =		{strength = 80,	create = stockTemplate},
		["Starhammer V"] =		{strength = 90,	create = starhammerV},
		["Battlestation"] =		{strength = 100,create = stockTemplate},
		["Tyr"] =				{strength = 150,create = tyr},
		["Odin"] =				{strength = 250,create = stockTemplate},
	}
	missile_ships = {["WX-Lindworm"] = true,["Piranha F8"] = true,["Piranha F12"] = true,["Ranus U"] = true,["Missile Cruiser"] = true,["Storm"] = true,["Tempest"] = true,["WZ-Lindworm"] = true}
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
		},
	}
	--Groups used in alphabetic order unless variation overrides. 
	--Adjust order with GM buttons or by overriding order in variation specific constants function (eg: see setNormalConstants function)
	station_pool = {
		["Science"] = {
			["Asimov"] =	{goods = {"repulsor"}, description = "Training and Coordination", general = "We train naval cadets in routine and specialized functions aboard space vessels and coordinate naval activity throughout the sector", history = "The original station builders were fans of the late 20th century scientist and author Isaac Asimov. The station was initially named Foundation, but was later changed simply to Asimov. It started off as a stellar observatory, then became a supply stop and as it has grown has become an educational and coordination hub for the region"},
			["Armstrong"] =	{goods = {"warp", "impulse"}, description = "Warp and Impulse engine manufacturing", general = "We manufacture warp, impulse and jump engines for the human navy fleet as well as other independent clients on a contract basis", history = "The station is named after the late 19th century astronaut as well as the fictionlized stations that followed. The station initially constructed entire space worthy vessels. In time, it transitioned into specializeing in propulsion systems."},
			["Broeck"] =	{goods = {"warp"}, description = "Warp drive components", general = "We provide warp drive engines and components", history = "This station is named after Chris Van Den Broeck who did some initial research into the possibility of warp drive in the late 20th century on Earth"},
			["Coulomb"] =	{goods = {"circuit"}, description = "Shielded circuitry fabrication", general = "We make a large variety of circuits for numerous ship systems shielded from sensor detection and external control interference", history = "Our station is named after the law which quantifies the amount of force with which stationary electrically charged particals repel or attact each other - a fundamental principle in the design of our circuits"},
			["Heyes"] =		{goods = {"sensor"}, description = "Sensor components", general = "We research and manufacture sensor components and systems", history = "The station is named after Tony Heyes the inventor of some of the earliest electromagnetic sensors in the mid 20th century on Earth in the United Kingdom to assist blind human mobility"},
			["Hossam"] =	{goods = {"nanites"}, description = "Nanite supplier", general = "We provide nanites for various organic and non-organic systems", history = "This station is named after the nanotechnologist Hossam Haick from the early 21st century on Earth in Israel"},
			["Maiman"] =	{goods = {"beam"}, description = "Energy beam components", general = "We research and manufacture energy beam components and systems", history = "The station is named after Theodore Maiman who researched and built the first laser in the mid 20th century on Earth"},
			["Marconi"] =	{goods = {"beam"}, description = "Energy Beam Components", general = "We manufacture energy beam components", history = "Station named after Guglielmo Marconi an Italian inventor from early 20th century Earth who, along with Nicolo Tesla, claimed to have invented a death ray or particle beam weapon"},
			["Miller"] =	{goods = {"optic"}, description = "Exobiology research", general = "We study recently discovered life forms not native to Earth", history = "This station was named after one of the early exobiologists from mid 20th century Earth, Dr. Stanley Miller"},
			["Shawyer"] =	{goods = {"impulse"}, description = "Impulse engine components", general = "We research and manufacture impulse engine components and systems", history = "The station is named after Roger Shawyer who built the first prototype impulse engine in the early 21st century"},
		},
		["History"] = {
			["Archimedes"] = {goods = {"beam"}, description = "Energy and particle beam components", general = "We fabricate general and specialized components for ship beam systems", history = "This station was named after Archimedes who, according to legend, used a series of adjustable focal length mirrors to focus sunlight on a Roman naval fleet invading Syracuse, setting fire to it"},
			["Chatuchak"] =	{goods = {"luxury"}, description = "Trading station", general = "Only the largest market and trading location in twenty sectors. You can find your heart's desire here", history = "Modeled after the early 21st century bazaar on Earth in Bangkok, Thailand. Designed and built with trade and commerce in mind"},
			["Grasberg"] =	{goods = {"luxury"}, description = "Mining", general ="We mine nearby asteroids for precious minerals and process them for sale", history = "This station's name is inspired by a large gold mine on Earth in Indonesia. The station builders hoped to have a similar amount of minerals found amongst these asteroids"},
			["Hayden"] =	{goods = {"nanites"}, description = "Observatory and stellar mapping", general = "We study the cosmos and map stellar phenomena. We also track moving asteroids. Look out! Just kidding", history = "Station named in honor of Charles Hayden whose philanthropy continued astrophysical research and education on Earth in the early 20th century"},
			["Lipkin"] =	{goods = {"autodoc"}, description = "Autodoc components", general = "", history = "The station is named after Dr. Lipkin who pioneered some of the research and application around robot assisted surgery in the area of partial nephrectomy for renal tumors in the early 21st century on Earth"},
			["Madison"] =	{goods = {"luxury"}, description = "Zero gravity sports and entertainment", general = "Come take in a game or two or perhaps see a show", history = "Named after Madison Square Gardens from 21st century Earth, this station was designed to serve similar purposes in space - a venue for sports and entertainment"},
			["Rutherford"] = {goods = {"shield"}, description = "Shield components and research", general = "We research and fabricate components for ship shield systems", history = "This station was named after the national research institution Rutherford Appleton Laboratory in the United Kingdom which conducted some preliminary research into the feasability of generating an energy shield in the late 20th century"},
			["Toohie"] =	{goods = {"shield"}, description = "Shield and armor components and research", general = "We research and make general and specialized components for ship shield and ship armor systems", history = "This station was named after one of the earliest researchers in shield technology, Alexander Toohie back when it was considered impractical to construct shields due to the physics involved."},
		},
		["Pop Sci Fi"] = {
			["Anderson"] =	{goods = {"software", "battery"}, description = "Battery and software engineering", general = "We provide high quality high capacity batteries and specialized software for all shipboard systems", history = "The station is named after a fictional software engineer in a late 20th century movie depicting humanity unknowingly conquered by aliens and kept docile by software generated illusion"},
			["Archer"] =	{goods = {"shield"}, description = "Shield and Armor Research", general = "The finest shield and armor manufacturer in the quadrant", history = "We named this station for the pioneering spirit of the 22nd century Starfleet explorer, Captain Jonathan Archer"},
			["Barclay"] =	{goods = {"communication"}, description = "Communication components", general = "We provide a range of communication equipment and software for use aboard ships", history = "The station is named after Reginald Barclay who established the first transgalactic com link through the creative application of a quantum singularity. Station personnel often refer to the station as the Broccoli station"},
			["Calvin"] =	{goods = {"robotic"}, description = "Robotic research", general = "We research and provide robotic systems and components", history = "This station is named after Dr. Susan Calvin who pioneered robotic behavioral research and programming"},
			["Cavor"] =		{goods = {"filament"}, description = "Advanced Material components", general = "We fabricate several different kinds of materials critical to various space industries like ship building, station construction and mineral extraction", history = "We named our station after Dr. Cavor, the physicist that invented a barrier material for gravity waves - Cavorite"},
			["Cyrus"] =		{goods = {"impulse"}, description = "Impulse engine components", general = "We supply high quality impulse engines and parts for use aboard ships", history = "This station was named after the fictional engineer, Cyrus Smith created by 19th century author Jules Verne"},
			["Deckard"] =	{goods = {"android"}, description = "Android components", general = "Supplier of android components, programming and service", history = "Named for Richard Deckard who inspired many of the sophisticated safety security algorithms now required for all androids"},
			["Erickson"] =	{goods = {"transporter"}, description = "Transporter components", general = "We provide transporters used aboard ships as well as the components for repair and maintenance", history = "The station is named after the early 22nd century inventor of the transporter, Dr. Emory Erickson. This station is proud to have received the endorsement of Admiral Leonard McCoy"},
			["Komov"] =		{goods = {"filament"}, description = "Xenopsychology training", general = "We provide classes and simulation to help train diverse species in how to relate to each other", history = "A continuation of the research initially conducted by Dr. Gennady Komov in the early 22nd century on Venus, supported by the application of these principles"},
			["Muddville"] = {goods = {"luxury"}, description = "Trading station", general = "Come to Muddvile for all your trade and commerce needs and desires", history = "Upon retirement, Harry Mudd started this commercial venture using his leftover inventory and extensive connections obtained while he traveled the stars as a salesman"},
			["Nexus-6"] =	{goods = {"android"}, description = "Android components", general = "Androids, their parts, maintenance and recylcling", history = "We named the station after the ground breaking android model produced by the Tyrell corporation"},
			["O'Brien"] =	{goods = {"transporter"}, description = "Transporter components", general = "We research and fabricate high quality transporters and transporter components for use aboard ships", history = "Miles O'Brien started this business after his experience as a transporter chief"},
			["Organa"] =	{goods = {"luxury"}, description = "Diplomatic training", general = "The premeire academy for leadership and diplomacy training in the region", history = "Established by the royal family so critical during the political upheaval era"},
			["Owen"] =		{goods = {"lifter"}, description = "Load lifters and components", general = "We provide load lifters and components for various ship systems", history = "Owens started off in the moisture vaporator business on Tattooine then branched out into load lifters based on acquisition of proprietary software and protocols. The station name recognizes the tragic loss of our founder to Imperial violence"},
			["Ripley"] =	{goods = {"lifter"}, description = "Load lifters and components", general = "We provide load lifters and components", history = "The station is named after Ellen Ripley who made creative and effective use of one of our load lifters when defending her ship"},
			["Soong"] =		{goods = {"android"}, description = "Android components", general = "We create androids and android components", history = "The station is named after Dr. Noonian Soong, the famous android researcher and builder"},
			["Tiberius"] =	{goods = {"food"}, description = "Logistics coordination", general = "We support the stations and ships in the area with planning and communication services", history = "We recognize the influence of Starfleet Captain James Tiberius Kirk in the 23rd century in our station name"},
			["Tokra"] =		{goods = {"filament"}, description = "Advanced material components", general = "", history = "We learned several of our critical industrial processes from the Tokra race, so we honor our fortune by naming the station after them"},
			["Utopia Planitia"] = {goods = {"warp"}, description = "Ship building and maintenance facility", general = "We work on all aspects of naval ship building and maintenance. Many of the naval models are researched, designed and built right here on this station. Our design goals seek to make the space faring experience as simple as possible given the tremendous capabilities of the modern naval vessel", history = ""},
			["Zefram"] =	{goods = {"warp"}, description = "Warp engine components", general = "We specialize in the esoteric components necessary to make warp drives function properly", history = "Zefram Cochrane constructed the first warp drive in human history. We named our station after him because of the specialized warp systems work we do"},
			["Jabba"] =		{goods = {"luxury"}, description = "Commerce and gambling", general = "Come play some games and shop. House take does not exceed 4 percent", history = ""},
			["Lando"] =		{goods = {"shield"}, description = "Casino and Gambling", general = "", history = ""},
			["Skandar"] =	{goods = {"luxury"}, description = "Routine maintenance and entertainment", general = "Stop by for repairs. Take in one of our juggling shows featuring the four-armed Skandars", history = "The nomadic Skandars have set up at this station to practice their entertainment and maintenance skills as well as build a community where Skandars can relax"},
			["Starnet"] =	{goods = {"software"}, description = "Automated weapons systems", general = "We research and create automated weapons systems to improve ship combat capability", history = "Lost the history memory bank. Recovery efforts only brought back the phrase, 'I'll be back'"},
			["Vaiken"] =	{goods = {"food","impulse"}, description = "Ship building and maintenance facility", general = "", history = ""},
		},
		["Spec Sci Fi"] = {
			["Alcaleica"] =	{goods = {"optic"}, description = "Optical Components", general = "We make and supply optic components for various station and ship systems", history = "This station continues the businesses from Earth based on the merging of several companies including Leica from Switzerland, the lens manufacturer and the Japanese advanced low carbon (ALCA) electronic and optic research and development company"},
			["Bethesda"] =	{goods = {"autodoc", "medicine"}, description = "Medical research", general = "We research and treat exotic medical conditions", history = "The station is named after the United States national medical research center based in Bethesda, Maryland on earth which was established in the mid 20th century"},
			["Deer"] =		{goods = {"tractor","repulsor"}, description = "Repulsor and Tractor Beam Components", general = "We can meet all your pushing and pulling needs with specialized equipment custom made", history = "The station name comes from a short story by the 20th century author Clifford D. Simak as well as from the 19th century developer John Deere who inspired a company that makes the Earth bound equivalents of our products"},
			["Evondos"] =	{goods = {"autodoc"}, description = "Autodoc components", general = "We provide components for automated medical machinery", history = "The station is the evolution of the company that started automated pharmaceutical dispensing in the early 21st century on Earth in Finland"},
			["Feynman"] =	{goods = {"nanites","software"}, description = "Nanotechnology research", general = "We provide nanites and software for a variety of ship-board systems", history = "This station's name recognizes one of the first scientific researchers into nanotechnology, physicist Richard Feynman"},
			["Mayo"] =		{goods = {"autodoc","medicine","food"}, description = "Medical Research", general = "We research exotic diseases and other human medical conditions", history = "We continue the medical work started by William Worrall Mayo in the late 19th century on Earth"},
			["Olympus"] =	{goods = {"optic"}, description = "Optical components", general = "We fabricate optical lenses and related equipment as well as fiber optic cabling and components", history = "This station grew out of the Olympus company based on earth in the early 21st century. It merged with Infinera, then bought several software comapnies before branching out into space based industry"},
			["Panduit"] =	{goods = {"optic"}, description = "Optic components", general = "We provide optic components for various ship systems", history = "This station is an outgrowth of the Panduit corporation started in the mid 20th century on Earth in the United States"},
			["Shree"] =		{goods = {"tractor"}, description = "Repulsor and tractor beam components", general = "We make ship systems designed to push or pull other objects around in space", history = "Our station is named Shree after one of many tugboat manufacturers in the early 21st century on Earth in India. Tugboats serve a similar purpose for ocean-going vessels on earth as tractor and repulsor beams serve for space-going vessels today"},
			["Vactel"] =	{goods = {"circuit"}, description = "Shielded Circuitry Fabrication", general = "We specialize in circuitry shielded from external hacking suitable for ship systems", history = "We started as an expansion from the lunar based chip manufacturer of Earth legacy Intel electronic chips"},
			["Veloquan"] =	{goods = {"sensor"}, description = "Sensor components", general = "We research and construct components for the most powerful and accurate sensors used aboard ships along with the software to make them easy to use", history = "The Veloquan company has its roots in the manufacturing of LIDAR sensors in the early 21st century on Earth in the United States for autonomous ground-based vehicles. They expanded research and manufacturing operations to include various sensors for space vehicles. Veloquan was the result of numerous mergers and acquisitions of several companies including Velodyne and Quanergy"},
			["Tandon"] =	{goods = {"medicine","autodoc"}, description = "Biotechnology research", general = "Merging the organic and inorganic through research", history = "Continued from the Tandon school of engineering started on Earth in the early 21st century"},
		},
		["Generic"] = {
			["California"] = {goods = {"gold", "dilithium"}, description = "Mining station", general = "", history = ""},
			["Impala"] = 	{goods = {"luxury"}, description = "Mining", general = "We mine nearby asteroids for precious minerals", history = ""},
			["Krak"] =		{goods = {"nickel","platinum"}, description = "Mining station", general = "", history = ""},
			["Krik"] =		{goods = {"nickel","cobalt"}, description = "Mining station", general = "", history = ""},
			["Kruk"] =		{goods = {"nickel","tritanium"}, description = "Mining station", general = "", history = ""},
			["Outpost-15"] = {goods = {"luxury"}, description = "Mining and trade", general = "", history = ""},
			["Outpost-21"] = {goods = {"luxury"}, description = "Mining and gambling", general = "", history = ""},
			["Science-7"] = {goods = {"food"}, description = "Observatory", general = "", history = ""},
			["Maverick"] =	{goods = {"luxury"}, description = "Gambling and resupply", general = "Relax and meet some interesting players", history = ""},
			["Nefatha"] =	{goods = {"luxury"}, description = "Commerce and recreation", general = "", history = ""},
			["Okun"] =		{goods = {"medicine"}, description = "Xenopsychology research", general = "", history = ""},
			["Outpost-7"] = {goods = {"luxury"}, description = "Resupply", general = "", history = ""},
			["Outpost-8"] = {goods = {"food"}, description = "", general = "", history = ""},
			["Outpost-33"] = {goods = {"luxury"}, description = "Resupply", general = "", history = ""},
			["Prada"] =		{goods = {"luxury"}, description = "Textiles and fashion", general = "", history = ""},
			["Research-11"] = {goods = {"medicine"}, description = "Stress Psychology Research", general = "", history = ""},
			["Research-19"] = {goods = {"sensor"}, description = "Low gravity research", general = "", history = ""},
			["Rubis"] =		{goods = {"luxury"}, description = "Resupply", general = "Get your energy here! Grab a drink before you go!", history = ""},
			["Science-2"] = {goods = {"circuit"}, description = "Research Lab and Observatory", general = "", history = ""},
			["Science-4"] = {goods = {"medicine","autodoc"}, description = "Biotech research", general = "", history = ""},
			["Spot"] =		{goods = {"food"}, description = "Observatory", general = "", history = ""},
			["Valero"] =	{goods = {"luxury"}, description = "Resupply", general = "", history = ""},
		},
		["Scout"] = {
			["MacLean"] =	{goods = {"communication"}, description = "Communications components and coordination", general = "We make communications components and manage communication traffic in the area", history = "The station founders were fans of the publisher John R. Maclean who published (among other things) The Washington Post which was founded in the late 19th century on earth"}, 
			["Farifax"] =	{goods = {"tritanium"}, description = "Mining and trading", general = "", history = ""},
			["Pipsico"] =	{goods = {"food"}, description = "Observatory", general = "We watch and track vehicular and stellar traffic in this area", history = "The station founder compared the mission of the station to watch for potential hostile traffic to the 15th century location on Earth in what was then called the new world. Pipsico was where the colonists of Jamestown posted look-outs."}, 
		},
		["DFW"] = {
			["Hurst"] =		{goods = {"cobalt"}, description = "Mining and energy production", general = "", history = ""},
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
	upgrade_artifact_description = {}
	table.insert(upgrade_artifact_description,1,{unscanned = "An unusual object",			scanned = "An object showing advanced technical characteristics"})
	table.insert(upgrade_artifact_description,2,{unscanned = "An unusual object",			scanned = "An object with an unusual energy signature"})
	table.insert(upgrade_artifact_description,3,{unscanned = "A strange looking object",	scanned = "An object with an undefined energy signature"})
	table.insert(upgrade_artifact_description,4,{unscanned = "A curious object",			scanned = "Object shows signs of low level radiation"})
	table.insert(upgrade_artifact_description,5,{unscanned = "An interesting object",		scanned = "Object container looks manufactured"})
	treasure_artifact_description = {}
	table.insert(treasure_artifact_description,1,{unscanned = "An unusual object",			scanned = "A valuable treasure"})
	table.insert(treasure_artifact_description,2,{unscanned = "An unusual object",			scanned = "An important treasure"})
	table.insert(treasure_artifact_description,3,{unscanned = "A strange object",			scanned = "A key treasure"})
	table.insert(treasure_artifact_description,4,{unscanned = "An unusual object",			scanned = "A priceless treasure"})
	table.insert(treasure_artifact_description,5,{unscanned = "A fascinating object",		scanned = "A definite treasure"})
	decoy_artifact_description = {}
	table.insert(decoy_artifact_description,1,{unscanned = "An unusual object",		scanned = "A pretty object"})
	table.insert(decoy_artifact_description,2,{unscanned = "An unusual object",		scanned = "An attractive object"})
	table.insert(decoy_artifact_description,3,{unscanned = "An unusual object",		scanned = "A dull object"})
	table.insert(decoy_artifact_description,4,{unscanned = "An unusual object",		scanned = "A bright object"})
	table.insert(decoy_artifact_description,5,{unscanned = "An unusual object",		scanned = "A decorative object"})	
	local model_choices = {"artifact1","artifact2","artifact3","artifact4","artifact5","artifact6","artifact7","artifact8"}
	local model_index = math.random(1,#model_choices)
	local treasure_model = model_choices[model_index]
	table.remove(model_choices,model_index)
	model_index = math.random(1,#model_choices)
	local upgrade_model = model_choices[model_index]
	table.remove(model_choices,model_index)
	model_index = math.random(1,#model_choices)
	local decoy_model = model_choices[model_index]
	model = {
		["treasure"] = treasure_model,
		["upgrade"] = upgrade_model,
		["decoy"] = decoy_model,
	}	
	local signature_choices = {"grav","elec","bio"}
	local signature_index = math.random(1,#signature_choices)
	local treasure_signature = signature_choices[signature_index]
	table.remove(signature_choices,signature_index)
	signature_index = math.random(1,#signature_choices)
	local upgrade_signature = signature_choices[signature_index]
	signature = {
		["treasure"] = {["grav"] = 0, ["elec"] = 0, ["bio"] = 0},
		["upgrade"] = {["grav"] = 0, ["elec"] = 0, ["bio"] = 0},
	}
	signature.treasure[treasure_signature] = random(.15,.85)
	signature.upgrade[upgrade_signature] = random(.15,.85)
--	print(string.format("Treasure: grav: %.1f, elec: %.1f, bio: %.1f",signature.treasure.grav,signature.treasure.elec,signature.treasure.bio))
--	print(string.format("Upgrade: grav: %.1f, elec: %.1f, bio: %.1f",signature.upgrade.grav,signature.upgrade.elec,signature.upgrade.bio))
	control_code_usage = "fixed"	--valid values: none, fixed or random
	fixed_control_code = {	--All control codes must be upper case or they will not work
		["Calamity"]	=	"BLOCKADE555",
		["Damocles"]	=	"CROSSFIELD345",
		["Endeavor"]	=	"ARCTIC777",
		["Glitter"]		=	"TRACTOR432",
		["Hyperion"]	=	"VOYAGER987",
		["Liberty"]		=	"AVENGER123",
		["Prismatic"]	=	"NEBULA789",
		["Raven"]		=	"VORTEX234",
		["Satsuma"]		=	"SCANNER678",
	}	
	terrain_center_x = 410000	--sector M25. Don't change here, change in variation specific function
	terrain_center_y = 150000
	game_length = 60*60			--\
	game_time_limit = game_length	--can be changed by GM button
	timer_fudge = 0				--/
	difficulty = 1				--valid values:   .5,      1,    2		can be changed by GM button
	difficulty_text = "normal"	--valid values: easy, normal, hard
	scan_complexity = {		--number of bars
		["easy"] =		1,
		["normal"] =	2,
		["hard"] =		3,
	}
	scan_depth = {			--number of popup screens
		["easy"] =		1,
		["normal"] =	2,
		["hard"] =		2,
	}
	mortal_repair_crew = false	--can be changed by GM button
	coolant_may_leak = false	--can be changed by GM button
	player_message_buttons = "both"
	completion_difficulty = 1
	completion_difficulty_text = "normal"
	allowed_angle_variance = 4
	shy_config = {4,5,7,8,9,11,14}
	max_approach_velocity = 1
	ships_carry_cargo = false	--may be changed by variation
	prefix_length = 0
	suffix_index = 0
	enemy_reverts = {}
	revert_timer_interval = 7
	revert_timer = revert_timer_interval
	plotRevert = revertWait
	check_continuum = false
	world = updateSystem()
	distance_diagnostic = false		--final value should be false
	zone_color_list = {
		{r = 255, g =   0, b =   0},	--red
		{r =   0, g = 255, b =   0},	--green
		{r =   0, g =   0, b = 255},	--blue
		{r = 186, g =  85, b = 211},	--medium orchid
		{r =  95, g = 158, b = 160},	--cadet blue
		{r =  55, g =  55, b =  55},	--dark gray
		{r = 255, g =  69, b =   0},	--orange red
		{r = 255, g = 127, b =  80},	--coral
		{r =  65, g = 105, b = 255},	--royal blue
		{r =  85, g = 107, b =  47},	--dark olive green
		{r = 160, g =  82, b =  45},	--sienna
		{r =  34, g = 139, b =  34},	--forest green
		{r = 178, g =  34, b =  34},	--firebrick red
	}
	if game_variation == "Hunger" then
		setHungerConstants()
	elseif game_variation == "Explorer" then
		setExplorerConstants()
	else	--normal, or default or no variation
		setNormalConstants()
	end
end
function analyzeBlob(object_list)
--given a blob (list) of objects, find the center and the max and min perimeter values
	local center_x = 0
	local center_y = 0
	local max_perimeter = 0
	local min_perimeter = 999999
	if object_list ~= nil and #object_list > 0 then
		for i=1,#object_list do
			local obj_x, obj_y = object_list[i]:getPosition()
			center_x = center_x + obj_x
			center_y = center_y + obj_y
		end
		center_x = center_x/#object_list
		center_y = center_y/#object_list
		for i=1,#object_list do
			if distance_diagnostic then
				print("function analyzeBlob")
				if object_list[i] == nil then
					print("   object_list[i] is nil")
					print("   " .. i)
					print("   " .. object_list)
				else
					print("   " .. i,object_list[i])
				end
				if center_x == nil then
					print("   center_x is nil")
				else
					print("   center_x: " .. center_x)
				end
			end
			local current_distance = distance(object_list[i],center_x,center_y)
			if current_distance >= max_perimeter then
				max_perimeter = current_distance
			end
			if current_distance <= min_perimeter then
				min_perimeter = current_distance
			end
		end
	end
	return center_x, center_y, max_perimeter, min_perimeter
end
function farEnough(list,pos_x,pos_y,bubble)
	local far_enough = true
	for i=1,#list do
		local list_item = list[i]
		if distance_diagnostic then
			print("function farEnough")
			if list_item == nil then
				print("   list_item is nil")
				print("   " .. i)
				print("   " .. list)
			else
				print("   " .. i)
				print(list_item)
			end
			if pos_x == nil then
				print("   pos_x is nil")
			else
				print("   pos_x: " .. pos_x)
			end
		end
		local distance_away = distance(list_item,pos_x,pos_y)
		if distance_away < bubble then
			far_enough = false
			break
		end
		if list_item.typeName == "BlackHole" or list_item.typeName == "WormHole" then
			if distance_away < 6000 then
				far_enough = false
				break
			end
		end
		if list_item.typeName == "Planet" then
			if distance_away < 4000 then
				far_enough = false
				break
			end
		end
	end
	return far_enough
end
--------------------------------
--	World Building Functions  --
--------------------------------
function stationSizeTemplate()
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
function selectArtifactUpgradeType()
	--currently used by the normal and explorer variations
	if artifact_upgrade_type_list == nil or #artifact_upgrade_type_list < 1 then
		artifact_upgrade_type_list = {}
		table.insert(artifact_upgrade_type_list,upgradeBeamDamageArtifact)
		table.insert(artifact_upgrade_type_list,upgradeBeamRangeArtifact)
		table.insert(artifact_upgrade_type_list,upgradeBeamCycleArtifact)
		table.insert(artifact_upgrade_type_list,upgradeBeamHeatArtifact)
		table.insert(artifact_upgrade_type_list,upgradeAuxTubeArtifact)
		table.insert(artifact_upgrade_type_list,upgradeMoreMissilesArtifact)
		table.insert(artifact_upgrade_type_list,upgradeManeuverArtifact)
		table.insert(artifact_upgrade_type_list,upgradeImpulseArtifact)
		table.insert(artifact_upgrade_type_list,upgradeJumpArtifact)
		table.insert(artifact_upgrade_type_list,upgradeWarpArtifact)
		table.insert(artifact_upgrade_type_list,upgradeHullArtifact)
		table.insert(artifact_upgrade_type_list,upgradeShieldArtifact)
		table.insert(artifact_upgrade_type_list,upgradeEnergyArtifact)
		table.insert(artifact_upgrade_type_list,upgradeProbeArtifact)
		table.insert(artifact_upgrade_type_list,upgradeSensorArtifact)
	end
	local upgrade_index = math.random(1,#artifact_upgrade_type_list)
	local upgrade_artifact, upgrade_type = artifact_upgrade_type_list[upgrade_index]()
	table.remove(artifact_upgrade_type_list,upgrade_index)
	upgrade_artifact:setDescriptions("An unusual object","A valuable upgrade")
	return upgrade_artifact, upgrade_type
end
--	Ship upgrades  --
function upgradeBeamDamageArtifact()
	local upgrade_artifact = Artifact():allowPickup(true):setSpin(.7):setRadarSignatureInfo(signature.upgrade.grav,signature.upgrade.elec,signature.upgrade.bio):setModel(model.upgrade)
	upgrade_artifact:onPickUp(function(self,grabber)
		string.format("")	--necessary to have global reference for Serious Proton engine
		local beam_index = 0
		if grabber.beam_damage_upgrade_count == nil then
			grabber.beam_damage_upgrade_count = 0
		end
		if grabber:getBeamWeaponRange(0) > 0 then
			if grabber.normal_beam_damage == nil then
				grabber.normal_beam_damage = {}
				beam_index = 0
				repeat
					table.insert(grabber.normal_beam_damage,grabber:getBeamWeaponDamage(beam_index))
					beam_index = beam_index + 1
				until(grabber:getBeamWeaponRange(beam_index) < 1)
			end
			beam_index = 0
			repeat
				local temp_arc = grabber:getBeamWeaponArc(beam_index)
				local temp_dir = grabber:getBeamWeaponDirection(beam_index)
				local temp_rng = grabber:getBeamWeaponRange(beam_index)
				local temp_cyc = grabber:getBeamWeaponCycleTime(beam_index)
				local temp_dmg = grabber:getBeamWeaponDamage(beam_index)
				grabber:setBeamWeapon(beam_index,temp_arc,temp_dir,temp_rng,temp_cyc,temp_dmg * 1.1)
				beam_index = beam_index + 1
			until(grabber:getBeamWeaponRange(beam_index) < 1)
			grabber.beam_damage_upgrade_count = grabber.beam_damage_upgrade_count + 1
			if grabber:hasPlayerAtPosition("Weapons") then
				local beam_damage_improved_message = "beam_damage_improved_message"
				grabber:addCustomMessage("Weapons",beam_damage_improved_message,"Beam weapon damage has increased")
			end
			if grabber:hasPlayerAtPosition("Tactical") then
				local beam_damage_improved_message_tactical = "beam_damage_improved_message_tactical"
				grabber:addCustomMessage("Tactical",beam_damage_improved_message_tactical,"Beam weapon damage has increased")
			end
		else
			grabber:setBeamWeapon(0,60,0,800,6,4)
			grabber.normal_beam_damage = {}
			table.insert(grabber.normal_beam_damage,4)
			if grabber:hasPlayerAtPosition("Weapons") then
				local beam_weapon_added_message = "beam_weapon_added_message"
				grabber:addCustomMessage("Weapons",beam_weapon_added_message,"Beam weapon has been added")
			end
			if grabber:hasPlayerAtPosition("Tactical") then
				local beam_weapon_added_message_tactical = "beam_weapon_added_message_tactical"
				grabber:addCustomMessage("Tactical",beam_weapon_added_message_tactical,"Beam weapon has been added")
			end
		end
	end)
	return upgrade_artifact, "Beam Damage"
end
function upgradeBeamRangeArtifact()
	local upgrade_artifact = Artifact():allowPickup(true):setSpin(.7):setRadarSignatureInfo(signature.upgrade.grav,signature.upgrade.elec,signature.upgrade.bio):setModel(model.upgrade)
	upgrade_artifact:onPickUp(function(self,grabber)
		string.format("")	--necessary to have global reference for Serious Proton engine
		local beam_index = 0
		if grabber.beam_range_upgrade_count == nil then
			grabber.beam_range_upgrade_count = 0
		end
		if grabber:getBeamWeaponRange(0) > 0 then
			if grabber.normal_beam_range == nil then
				grabber.normal_beam_range = {}
				beam_index = 0
				repeat
					table.insert(grabber.normal_beam_range,grabber:getBeamWeaponRange(beam_index))
					beam_index = beam_index + 1
				until(grabber:getBeamWeaponRange(beam_index) < 1)
			end
			beam_index = 0
			repeat
				local temp_arc = grabber:getBeamWeaponArc(beam_index)
				local temp_dir = grabber:getBeamWeaponDirection(beam_index)
				local temp_rng = grabber:getBeamWeaponRange(beam_index)
				local temp_cyc = grabber:getBeamWeaponCycleTime(beam_index)
				local temp_dmg = grabber:getBeamWeaponDamage(beam_index)
				grabber:setBeamWeapon(beam_index,temp_arc,temp_dir,temp_rng * 1.1,temp_cyc,temp_dmg)
				beam_index = beam_index + 1
			until(grabber:getBeamWeaponRange(beam_index) < 1)
			grabber.beam_range_upgrade_count = grabber.beam_range_upgrade_count + 1
			if grabber:hasPlayerAtPosition("Weapons") then
				local beam_range_improved_message = "beam_range_improved_message"
				grabber:addCustomMessage("Weapons",beam_range_improved_message,"Beam weapon range has increased")
			end
			if grabber:hasPlayerAtPosition("Tactical") then
				local beam_range_improved_message_tactical = "beam_range_improved_message_tactical"
				grabber:addCustomMessage("Tactical",beam_range_improved_message_tactical,"Beam weapon range has increased")
			end
		else
			grabber:setBeamWeapon(0,60,0,800,6,4)
			grabber.normal_beam_range = {}
			table.insert(grabber.normal_beam_range,800)
			if grabber:hasPlayerAtPosition("Weapons") then
				local beam_weapon_added_message = "beam_weapon_added_message"
				grabber:addCustomMessage("Weapons",beam_weapon_added_message,"Beam weapon has been added")
			end
			if grabber:hasPlayerAtPosition("Tactical") then
				local beam_weapon_added_message_tactical = "beam_weapon_added_message_tactical"
				grabber:addCustomMessage("Tactical",beam_weapon_added_message_tactical,"Beam weapon has been added")
			end
		end
	end)
	return upgrade_artifact, "Beam Range"
end
function upgradeBeamCycleArtifact()
	local upgrade_artifact = Artifact():allowPickup(true):setSpin(.7):setRadarSignatureInfo(signature.upgrade.grav,signature.upgrade.elec,signature.upgrade.bio):setModel(model.upgrade)
	upgrade_artifact:onPickUp(function(self,grabber)
		string.format("")	--necessary to have global reference for Serious Proton engine
		local beam_index = 0
		if grabber.beam_cycle_upgrade_count == nil then
			grabber.beam_cycle_upgrade_count = 0
		end
		if grabber:getBeamWeaponRange(0) > 0 then
			if grabber.normal_beam_cycle == nil then
				grabber.normal_beam_cycle = {}
				beam_index = 0
				repeat
					table.insert(grabber.normal_beam_cycle,grabber:getBeamWeaponCycleTime(beam_index))
					beam_index = beam_index + 1
				until(grabber:getBeamWeaponRange(beam_index) < 1)
			end
			beam_index = 0
			repeat
				local temp_arc = grabber:getBeamWeaponArc(beam_index)
				local temp_dir = grabber:getBeamWeaponDirection(beam_index)
				local temp_rng = grabber:getBeamWeaponRange(beam_index)
				local temp_cyc = grabber:getBeamWeaponCycleTime(beam_index)
				local temp_dmg = grabber:getBeamWeaponDamage(beam_index)
				grabber:setBeamWeapon(beam_index,temp_arc,temp_dir,temp_rng,temp_cyc * .9,temp_dmg)
				beam_index = beam_index + 1
			until(grabber:getBeamWeaponRange(beam_index) < 1)
			grabber.beam_cycle_upgrade_count = grabber.beam_cycle_upgrade_count + 1
			if grabber:hasPlayerAtPosition("Weapons") then
				local beam_cycle_improved_message = "beam_cycle_improved_message"
				grabber:addCustomMessage("Weapons",beam_cycle_improved_message,"Beam weapon cycle time has decreased")
			end
			if grabber:hasPlayerAtPosition("Tactical") then
				local beam_cycle_improved_message_tactical = "beam_cycle_improved_message_tactical"
				grabber:addCustomMessage("Tactical",beam_cycle_improved_message_tactical,"Beam weapon cycle time has decreased")
			end
		else
			grabber:setBeamWeapon(0,60,0,800,6,4)
			grabber.normal_beam_cycle = {}
			table.insert(grabber.normal_beam_cycle,6)
			if grabber:hasPlayerAtPosition("Weapons") then
				local beam_weapon_added_message = "beam_weapon_added_message"
				grabber:addCustomMessage("Weapons",beam_weapon_added_message,"Beam weapon has been added")
			end
			if grabber:hasPlayerAtPosition("Tactical") then
				local beam_weapon_added_message_tactical = "beam_weapon_added_message_tactical"
				grabber:addCustomMessage("Tactical",beam_weapon_added_message_tactical,"Beam weapon has been added")
			end
		end
	end)
	return upgrade_artifact, "Beam Cycle"
end
function upgradeBeamHeatArtifact()
	local upgrade_artifact = Artifact():allowPickup(true):setSpin(.7):setRadarSignatureInfo(signature.upgrade.grav,signature.upgrade.elec,signature.upgrade.bio):setModel(model.upgrade)
	upgrade_artifact:onPickUp(function(self,grabber)
		string.format("")	--necessary to have global reference for Serious Proton engine
		local beam_index = 0
		if grabber.beam_heat_upgrade_count == nil then
			grabber.beam_heat_upgrade_count = 0
		end
		if grabber:getBeamWeaponRange(0) > 0 then
			if grabber.normal_beam_heat == nil then
				grabber.normal_beam_heat = {}
				beam_index = 0
				repeat
					table.insert(grabber.normal_beam_heat,grabber:getBeamWeaponHeatPerFire(beam_index))
					beam_index = beam_index + 1
				until(grabber:getBeamWeaponRange(beam_index) < 1)
			end
			beam_index = 0
			repeat
				grabber:setBeamWeaponHeatPerFire(beam_index,grabber:getBeamWeaponHeatPerFire(beam_index) * .8)
				beam_index = beam_index + 1
			until(grabber:getBeamWeaponRange(beam_index) < 1)
			grabber.beam_heat_upgrade_count = grabber.beam_heat_upgrade_count + 1
			if grabber:hasPlayerAtPosition("Weapons") then
				local beam_heat_improved_message = "beam_heat_improved_message"
				grabber:addCustomMessage("Weapons",beam_heat_improved_message,"Beam weapon heat generated per fire has decreased")
			end
			if grabber:hasPlayerAtPosition("Tactical") then
				local beam_heat_improved_message_tactical = "beam_heat_improved_message_tactical"
				grabber:addCustomMessage("Tactical",beam_heat_improved_message_tactical,"Beam weapon heat generated per fire has decreased")
			end
		else
			grabber:setBeamWeapon(0,60,0,800,6,4)
			grabber.normal_beam_heat = {}
			table.insert(grabber.normal_beam_heat,grabber:getBeamWeaponHeatPerFire(0))
			if grabber:hasPlayerAtPosition("Weapons") then
				local beam_weapon_added_message = "beam_weapon_added_message"
				grabber:addCustomMessage("Weapons",beam_weapon_added_message,"Beam weapon has been added")
			end
			if grabber:hasPlayerAtPosition("Tactical") then
				local beam_weapon_added_message_tactical = "beam_weapon_added_message_tactical"
				grabber:addCustomMessage("Tactical",beam_weapon_added_message_tactical,"Beam weapon has been added")
			end
		end
	end)
	return upgrade_artifact, "Beam Heat"
end
function upgradeAuxTubeArtifact()
	local upgrade_artifact = Artifact():allowPickup(true):setSpin(.7):setRadarSignatureInfo(signature.upgrade.grav,signature.upgrade.elec,signature.upgrade.bio):setModel(model.upgrade)
	upgrade_artifact:onPickUp(function(self,grabber)
		string.format("")	--necessary to have global reference for Serious Proton engine
		if grabber.aux_tube_upgrade_count == nil then
			grabber.aux_tube_upgrade_count = 0
		end
		if grabber.aux_tube_upgrade_count == 0 then
			--add tube with hvli
			local original_tubes = grabber:getWeaponTubeCount()
			local new_tubes = original_tubes + 1
			grabber:setWeaponTubeCount(new_tubes)
			grabber:setWeaponTubeExclusiveFor(original_tubes,"HVLI")
			grabber:setWeaponStorageMax("HVLI",grabber:getWeaponStorageMax("HVLI") + 2)
			grabber:setWeaponStorage("HVLI",grabber:getWeaponStorage("HVLI") + 2)
			if grabber:hasPlayerAtPosition("Weapons") then
				local aux_tube_added_message = "aux_tube_added_message"
				grabber:addCustomMessage("Weapons",aux_tube_added_message,"Added front HVLI missile tube")
			end
			if grabber:hasPlayerAtPosition("Tactical") then
				local aux_tube_added_message_tactical = "aux_tube_added_message_tactical"
				grabber:addCustomMessage("Tactical",aux_tube_added_message_tactical,"Added front HVLI missile tube")
			end
		elseif grabber.aux_tube_upgrade_count == 1 then
			--allow tube for homing
			grabber:weaponTubeAllowMissle(grabber:getWeaponTubeCount() - 1,"Homing")
			grabber:setWeaponStorageMax("Homing",grabber:getWeaponStorageMax("Homing") + 2)
			grabber:setWeaponStorage("Homing",grabber:getWeaponStorage("Homing") + 2)
			if grabber:hasPlayerAtPosition("Weapons") then
				aux_tube_added_message = "aux_tube_added_message"
				grabber:addCustomMessage("Weapons",aux_tube_added_message,"Enabled front missile tube to fire Homing missiles")
			end
			if grabber:hasPlayerAtPosition("Tactical") then
				aux_tube_added_message_tactical = "aux_tube_added_message_tactical"
				grabber:addCustomMessage("Tactical",aux_tube_added_message_tactical,"Enabled front missile tube to fire Homing missiles")
			end
		elseif grabber.aux_tube_upgrade_count == 2 then
			--allow tube for EMP
			grabber:weaponTubeAllowMissle(grabber:getWeaponTubeCount() - 1,"EMP")
			grabber:setWeaponStorageMax("EMP",grabber:getWeaponStorageMax("EMP") + 2)
			grabber:setWeaponStorage("EMP",grabber:getWeaponStorage("EMP") + 2)
			if grabber:hasPlayerAtPosition("Weapons") then
				aux_tube_added_message = "aux_tube_added_message"
				grabber:addCustomMessage("Weapons",aux_tube_added_message,"Enabled front missile tube to fire EMP missiles")
			end
			if grabber:hasPlayerAtPosition("Tactical") then
				aux_tube_added_message_tactical = "aux_tube_added_message_tactical"
				grabber:addCustomMessage("Tactical",aux_tube_added_message_tactical,"Enabled front missile tube to fire EMP missiles")
			end
		elseif grabber.aux_tube_upgrade_count == 3 then
			--allow tube for Nuke
			grabber:weaponTubeAllowMissle(grabber:getWeaponTubeCount() - 1,"Nuke")
			grabber:setWeaponStorageMax("Nuke",grabber:getWeaponStorageMax("Nuke") + 2)
			grabber:setWeaponStorage("Nuke",grabber:getWeaponStorage("Nuke") + 2)
			if grabber:hasPlayerAtPosition("Weapons") then
				aux_tube_added_message = "aux_tube_added_message"
				grabber:addCustomMessage("Weapons",aux_tube_added_message,"Enabled front missile tube to fire Nukes")
			end
			if grabber:hasPlayerAtPosition("Tactical") then
				aux_tube_added_message_tactical = "aux_tube_added_message_tactical"
				grabber:addCustomMessage("Tactical",aux_tube_added_message_tactical,"Enabled front missile tube to fire Nukes")
			end
		elseif grabber.aux_tube_upgrade_count == 4 then
			--add 2 hvli to stock capacity
			grabber:setWeaponStorageMax("HVLI",grabber:getWeaponStorageMax("HVLI") + 2)
			grabber:setWeaponStorage("HVLI",grabber:getWeaponStorage("HVLI") + 2)
			if grabber:hasPlayerAtPosition("Weapons") then
				aux_tube_added_message = "aux_tube_added_message"
				grabber:addCustomMessage("Weapons",aux_tube_added_message,"Increased HVLI missile capacity")
			end
			if grabber:hasPlayerAtPosition("Tactical") then
				aux_tube_added_message_tactical = "aux_tube_added_message_tactical"
				grabber:addCustomMessage("Tactical",aux_tube_added_message_tactical,"Increased HVLI missile capacity")
			end
		elseif grabber.aux_tube_upgrade_count == 5 then
			--add 2 homing to stock capacity
			grabber:setWeaponStorageMax("Homing",grabber:getWeaponStorageMax("Homing") + 2)
			grabber:setWeaponStorage("Homing",grabber:getWeaponStorage("Homing") + 2)
			if grabber:hasPlayerAtPosition("Weapons") then
				aux_tube_added_message = "aux_tube_added_message"
				grabber:addCustomMessage("Weapons",aux_tube_added_message,"Increased Homing missile capacity")
			end
			if grabber:hasPlayerAtPosition("Tactical") then
				aux_tube_added_message_tactical = "aux_tube_added_message_tactical"
				grabber:addCustomMessage("Tactical",aux_tube_added_message_tactical,"Increased Homing missile capacity")
			end
		elseif grabber.aux_tube_upgrade_count == 6 then
			--add 2 EMP to stock capacity
			grabber:setWeaponStorageMax("EMP",grabber:getWeaponStorageMax("EMP") + 2)
			grabber:setWeaponStorage("EMP",grabber:getWeaponStorage("EMP") + 2)
			if grabber:hasPlayerAtPosition("Weapons") then
				aux_tube_added_message = "aux_tube_added_message"
				grabber:addCustomMessage("Weapons",aux_tube_added_message,"Increased EMP missile capacity")
			end
			if grabber:hasPlayerAtPosition("Tactical") then
				aux_tube_added_message_tactical = "aux_tube_added_message_tactical"
				grabber:addCustomMessage("Tactical",aux_tube_added_message_tactical,"Increased EMP missile capacity")
			end
		elseif grabber.aux_tube_upgrade_count == 7 then
			--add 2 Nuke to stock capacity
			grabber:setWeaponStorageMax("Nuke",grabber:getWeaponStorageMax("Nuke") + 2)
			grabber:setWeaponStorage("Nuke",grabber:getWeaponStorage("Nuke") + 2)
			if grabber:hasPlayerAtPosition("Weapons") then
				aux_tube_added_message = "aux_tube_added_message"
				grabber:addCustomMessage("Weapons",aux_tube_added_message,"Increased Nuke capacity")
			end
			if grabber:hasPlayerAtPosition("Tactical") then
				aux_tube_added_message_tactical = "aux_tube_added_message_tactical"
				grabber:addCustomMessage("Tactical",aux_tube_added_message_tactical,"Increased Nuke capacity")
			end
		end
		grabber.aux_tube_upgrade_count = grabber.aux_tube_upgrade_count + 1
	end)
	return upgrade_artifact, "Auxiliary Tube"
end
function upgradeMoreMissilesArtifact()
	local upgrade_artifact = Artifact():allowPickup(true):setSpin(.7):setRadarSignatureInfo(signature.upgrade.grav,signature.upgrade.elec,signature.upgrade.bio):setModel(model.upgrade)
	upgrade_artifact:onPickUp(function(self,grabber)
		--print(string.format("Missile capacity upgrade: before: Homing: %i, Nuke: %i, Mine: %i, EMP: %i, HVLI: %i",grabber:getWeaponStorageMax("Homing"),grabber:getWeaponStorageMax("Nuke"),grabber:getWeaponStorageMax("Mine"),grabber:getWeaponStorageMax("EMP"),grabber:getWeaponStorageMax("HVLI")))
		string.format("")	--necessary to have global reference for Serious Proton engine
		if grabber.more_missiles_upgrade_count == nil then
			grabber.more_missiles_upgrade_count = 0
		end
		local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		if grabber:getWeaponTubeCount() > 0 then
			for _, missile_type in ipairs(missile_types) do
				grabber:setWeaponStorageMax(missile_type,math.ceil(grabber:getWeaponStorageMax(missile_type) * 1.1))
			end
			if grabber:hasPlayerAtPosition("Weapons") then
				local more_missiles_upgrade_message = "more_missiles_upgrade_message"
				grabber:addCustomMessage("Weapons",more_missiles_upgrade_message,"Increased missile storage capacity")
			end
			if grabber:hasPlayerAtPosition("Tactical") then
				local more_missiles_upgrade_message_tactical = "more_missiles_upgrade_message_tactical"
				grabber:addCustomMessage("Tactical",more_missiles_upgrade_message_tactical,"Increased missile storage capacity")
			end
		else
			grabber:setWeaponTubeCount(1)
			grabber:setTubeDirection(0,180)
			for _, missile_type in ipairs(missile_types) do
				grabber:setWeaponStorageMax(missile_type,1)
			end
			if grabber:hasPlayerAtPosition("Weapons") then
				more_missiles_upgrade_message = "more_missiles_upgrade_message"
				grabber:addCustomMessage("Weapons",more_missiles_upgrade_message,"Added rear facing missile tube")
			end
			if grabber:hasPlayerAtPosition("Tactical") then
				more_missiles_upgrade_message_tactical = "more_missiles_upgrade_message_tactical"
				grabber:addCustomMessage("Tactical",more_missiles_upgrade_message_tactical,"Added rear facing missile tube")
			end
		end
		grabber.more_missiles_upgrade_count = grabber.more_missiles_upgrade_count + 1
		--print(string.format("   After: Homing: %i, Nuke: %i, Mine: %i, EMP: %i, HVLI: %i",grabber:getWeaponStorageMax("Homing"),grabber:getWeaponStorageMax("Nuke"),grabber:getWeaponStorageMax("Mine"),grabber:getWeaponStorageMax("EMP"),grabber:getWeaponStorageMax("HVLI")))
	end)
	return upgrade_artifact, "Missile Capacity"
end
function upgradeManeuverArtifact()
	local upgrade_artifact = Artifact():allowPickup(true):setSpin(.7):setRadarSignatureInfo(signature.upgrade.grav,signature.upgrade.elec,signature.upgrade.bio):setModel(model.upgrade)
	upgrade_artifact:onPickUp(function(self,grabber)
		--print(string.format("Manuever upgrade: before: %.1f",grabber:getRotationMaxSpeed()))
		string.format("")	--necessary to have global reference for Serious Proton engine
		if grabber.maneuver_upgrade_count == nil then
			grabber.maneuver_upgrade_count = 0
		end
		grabber:setRotationMaxSpeed(grabber:getRotationMaxSpeed() * 1.1)
		if grabber:hasPlayerAtPosition("Helms") then
			grabber:addCustomMessage("Helms","better_maneuver_message","Maneuver speed has been increased")
		end
		if grabber:hasPlayerAtPosition("Operations") then
			grabber:addCustomMessage("Operations","better_maneuver_message_operations","Maneuver speed has been increased")
		end
		grabber.maneuver_upgrade_count = grabber.maneuver_upgrade_count + 1
		--print(string.format("   After: %.1f",grabber:getRotationMaxSpeed()))
	end)
	return upgrade_artifact, "Maneuver"
end
function upgradeImpulseArtifact()
	local upgrade_artifact = Artifact():allowPickup(true):setSpin(.7):setRadarSignatureInfo(signature.upgrade.grav,signature.upgrade.elec,signature.upgrade.bio):setModel(model.upgrade)
	upgrade_artifact:onPickUp(function(self,grabber)
		--print(string.format("Impulse upgrade: before: %.1f",grabber:getImpulseMaxSpeed()))
		string.format("")	--necessary to have global reference for Serious Proton engine
		if grabber.impulse_upgrade_count == nil then
			grabber.impulse_upgrade_count = 0
		end
		grabber:setImpulseMaxSpeed(grabber:getImpulseMaxSpeed() * 1.1)
		if grabber:hasPlayerAtPosition("Helms") then
			grabber:addCustomMessage("Helms","better_impulse_message","Impulse speed has been increased")
		end
		if grabber:hasPlayerAtPosition("Operations") then
			grabber:addCustomMessage("Operations","better_impulse_message_operations","Impulse speed has been increased")
		end
		grabber.impulse_upgrade_count = grabber.impulse_upgrade_count + 1
		--print(string.format("   After: %.1f",grabber:getImpulseMaxSpeed()))
	end)
	return upgrade_artifact, "Impulse"
end
function upgradeJumpArtifact()
	local upgrade_artifact = Artifact():allowPickup(true):setSpin(.7):setRadarSignatureInfo(signature.upgrade.grav,signature.upgrade.elec,signature.upgrade.bio):setModel(model.upgrade)
	upgrade_artifact:onPickUp(function(self,grabber)
		string.format("")	--necessary to have global reference for Serious Proton engine
		local function applyUpgrade(self, grabber)
			if grabber:hasJumpDrive() then
				if grabber.jump_upgrade_count == nil then
					grabber.jump_upgrade_count = 0
				end
				if grabber.jump_max == nil then
					grabber.jump_max = 50000
					grabber.jump_min = 5000
				end
				grabber.jump_max = grabber.jump_max + 5000
				grabber:setJumpDriveRange(grabber.jump_min,grabber.jump_max)
				if grabber:hasPlayerAtPosition("Helms") then
					grabber:addCustomMessage("Helms","better_jump_message","Jump range has been increased")
				end
				if grabber:hasPlayerAtPosition("Tactical") then
					grabber:addCustomMessage("Tactical","better_jump_message_tactical","Jump range has been increased")
				end
				grabber.jump_upgrade_count = grabber.jump_upgrade_count + 1			
			elseif grabber:hasWarpDrive() then
				if grabber.jump_upgrade_count == nil then
					grabber.jump_upgrade_count = 0
				end
				grabber:setJumpDrive(true)
				grabber.jump_max = 20000
				grabber.jump_min = 2000
				grabber:setJumpDriveRange(grabber.jump_min,grabber.jump_max)
				if grabber:hasPlayerAtPosition("Helms") then
					grabber:addCustomMessage("Helms","added_jump_message","Jump drive has been added")
				end
				if grabber:hasPlayerAtPosition("Tactical") then
					grabber:addCustomMessage("Tactical","added_jump_message_tactical","Jump drive has been added")
				end
				grabber.jump_upgrade_count = grabber.jump_upgrade_count + 1
				--[[
				if grabber.warp_upgrade_count == nil then
					grabber.warp_upgrade_count = 0
				end
				grabber:setWarpSpeed(grabber:getWarpSpeed() + 50)
				if grabber:hasPlayerAtPosition("Helms") then
					grabber:addCustomMessage("Helms","better_warp_message","Warp speed has been increased")
				end
				if grabber:hasPlayerAtPosition("Tactical") then
					grabber:addCustomMessage("Tactical","better_warp_message_tactical","Warp speed has been increased")
				end
				grabber.warp_upgrade_count = grabber.warp_upgrade_count + 1
				--]]
			else
				if grabber.jump_upgrade_count == nil then
					grabber.jump_upgrade_count = 0
				end
				grabber:setJumpDrive(true)
				grabber.jump_max = 20000
				grabber.jump_min = 2000
				grabber:setJumpDriveRange(grabber.jump_min,grabber.jump_max)
				if grabber:hasPlayerAtPosition("Helms") then
					grabber:addCustomMessage("Helms","added_jump_message","Jump drive has been added")
				end
				if grabber:hasPlayerAtPosition("Tactical") then
					grabber:addCustomMessage("Tactical","added_jump_message_tactical","Jump drive has been added")
				end
				grabber.jump_upgrade_count = grabber.jump_upgrade_count + 1
			end
		end
		--[[
		if game_variation == "Explorer" then
			if grabber:hasJumpDrive() or grabber:hasWarpDrive() then
				local all_ftl = true
				for pidx=1,player_count do
					local p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						if not p:hasJumpDrive() and not p:hasWarpDrive() then
							all_ftl = false
							break
						end
					end
				end
				if all_ftl then
					applyUpgrade(self, grabber)
				else
					grabber:setSystemHealth("warp",grabber:getSystemHealth("warp") - .1)
					grabber:setSystemHealth("jumpdrive",grabber:getSystemHealth("jumpdrive") - .1)
					grabber:setSystemHealth("impulse",grabber:getSystemHealth("impulse") - .1)
					local new_upgrade_artifact = upgradeJumpArtifact()
					local x, y = self:getPosition()
					local dx, dy = vectorFromAngle(random(0,360),random(3500,4500))
					new_upgrade_artifact:setPosition(x+dx,y+dy)
					new_upgrade_artifact:setDescriptionForScanState("unscanned",self:getDescription("unscanned"))
					new_upgrade_artifact:setDescriptionForScanState("scanned",self:getDescription("scanned"))
					local scan_complexity = self:scanningComplexity(self)
					local scan_depth = self:scanningChannelDepth(self)
					new_upgrade_artifact:setScanningParameters(scan_complexity,scan_depth)
				end
			else
				applyUpgrade(self, grabber)
			end
		else
			applyUpgrade(self, grabber)
		end
		--]]
		applyUpgrade(self, grabber)	
	end)
	return upgrade_artifact, "Jump"
end
function upgradeWarpArtifact()
	local upgrade_artifact = Artifact():allowPickup(true):setSpin(.7):setRadarSignatureInfo(signature.upgrade.grav,signature.upgrade.elec,signature.upgrade.bio):setModel(model.upgrade)
	upgrade_artifact:onPickUp(function(self,grabber)
		string.format("")	--necessary to have global reference for Serious Proton engine
		local function applyUpgrade(self, grabber)
			if grabber:hasWarpDrive() then
				if grabber.warp_upgrade_count == nil then
					grabber.warp_upgrade_count = 0
				end
				grabber:setWarpSpeed(grabber:getWarpSpeed() + 50)
				if grabber:hasPlayerAtPosition("Helms") then
					grabber:addCustomMessage("Helms","better_warp_message","Warp speed has been increased")
				end
				if grabber:hasPlayerAtPosition("Tactical") then
					grabber:addCustomMessage("Tactical","better_warp_message_tactical","Warp speed has been increased")
				end
				grabber.warp_upgrade_count = grabber.warp_upgrade_count + 1
			elseif grabber:hasJumpDrive() then
				if grabber.warp_upgrade_count == nil then
					grabber.warp_upgrade_count = 0
				end
				grabber:setWarpDrive(true)
				grabber:setWarpSpeed(400)
				if grabber:hasPlayerAtPosition("Helms") then
					grabber:addCustomMessage("Helms","added_warp_message","Warp drive has been added")
				end
				if grabber:hasPlayerAtPosition("Tactical") then
					grabber:addCustomMessage("Tactical","added_warp_message_tactical","Warp drive has been added")
				end
				grabber.warp_upgrade_count = grabber.warp_upgrade_count + 1
				--[[
				if grabber.jump_upgrade_count == nil then
					grabber.jump_upgrade_count = 0
				end
				if grabber.jump_max == nil then
					grabber.jump_max = 50000
					grabber.jump_min = 5000
				end
				grabber.jump_max = grabber.jump_max + 2000
				grabber:setJumpDriveRange(grabber.jump_min,grabber.jump_max)
				if grabber:hasPlayerAtPosition("Helms") then
					grabber:addCustomMessage("Helms","better_jump_message","Jump range has been increased")
				end
				if grabber:hasPlayerAtPosition("Tactical") then
					grabber:addCustomMessage("Tactical","better_jump_message_tactical","Jump range has been increased")
				end
				grabber.jump_upgrade_count = grabber.jump_upgrade_count + 1		
				--]]	
			else
				if grabber.warp_upgrade_count == nil then
					grabber.warp_upgrade_count = 0
				end
				grabber:setWarpDrive(true)
				grabber:setWarpSpeed(400)
				if grabber:hasPlayerAtPosition("Helms") then
					grabber:addCustomMessage("Helms","added_warp_message","Warp drive has been added")
				end
				if grabber:hasPlayerAtPosition("Tactical") then
					grabber:addCustomMessage("Tactical","added_warp_message_tactical","Warp drive has been added")
				end
				grabber.warp_upgrade_count = grabber.warp_upgrade_count + 1
			end
		end
		--[[
		if game_variation == "Explorer" then
			if grabber:hasJumpDrive() or grabber:hasWarpDrive() then
				local all_ftl = true
				for pidx=1,player_count do
					local p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						if not p:hasJumpDrive() and not p:hasWarpDrive() then
							all_ftl = false
							break
						end
					end
				end
				if all_ftl then
					applyUpgrade(self, grabber)
				else
					grabber:setSystemHealth("warp",grabber:getSystemHealth("warp") - .1)
					grabber:setSystemHealth("jumpdrive",grabber:getSystemHealth("jumpdrive") - .1)
					grabber:setSystemHealth("impulse",grabber:getSystemHealth("impulse") - .1)
					local new_upgrade_artifact = upgradeJumpArtifact()
					local x, y = self:getPosition()
					local dx, dy = vectorFromAngle(random(0,360),random(3500,4500))
					new_upgrade_artifact:setPosition(x+dx,y+dy)
					new_upgrade_artifact:setDescriptionForScanState("unscanned",self:getDescription("unscanned"))
					new_upgrade_artifact:setDescriptionForScanState("scanned",self:getDescription("scanned"))
					local scan_complexity = self:scanningComplexity(self)
					local scan_depth = self:scanningChannelDepth(self)
					new_upgrade_artifact:setScanningParameters(scan_complexity,scan_depth)
				end
			else
				applyUpgrade(self, grabber)
			end
		else
			applyUpgrade(self, grabber)
		end
		--]]
		applyUpgrade(self, grabber)
	end)
	return upgrade_artifact, "Warp"
end
function upgradeHullArtifact()
	local upgrade_artifact = Artifact():allowPickup(true):setSpin(.7):setRadarSignatureInfo(signature.upgrade.grav,signature.upgrade.elec,signature.upgrade.bio):setModel(model.upgrade)
	upgrade_artifact:onPickUp(function(self,grabber)
		string.format("")	--necessary to have global reference for Serious Proton engine
		if grabber.hull_upgrade_count == nil then
			grabber.hull_upgrade_count = 0
		end
		grabber:setHullMax(grabber:getHullMax() * 1.1)
		grabber:setHull(grabber:getHullMax())
		if grabber:hasPlayerAtPosition("Engineering") then
			grabber:addCustomMessage("Engineering","better_hull_message","Hull strength has been increased")
		end
		if grabber:hasPlayerAtPosition("Engineering+") then
			grabber:addCustomMessage("Engineering+","better_hull_message_plus","Hull strength has been increased")
		end
		grabber.hull_upgrade_count = grabber.hull_upgrade_count + 1
	end)
	return upgrade_artifact, "Hull"
end
function upgradeShieldArtifact()
	local upgrade_artifact = Artifact():allowPickup(true):setSpin(.7):setRadarSignatureInfo(signature.upgrade.grav,signature.upgrade.elec,signature.upgrade.bio):setModel(model.upgrade)
	upgrade_artifact:onPickUp(function(self,grabber)
		string.format("")	--necessary to have global reference for Serious Proton engine
		if grabber.shield_upgrade_count == nil then
			grabber.shield_upgrade_count = 0
		end
		if grabber:getShieldCount() == 1 then
			grabber:setShieldsMax(grabber:getShieldMax(0) * 1.1)
		else
			grabber:setShieldsMax(grabber:getShieldMax(0) * 1.1,grabber:getShieldMax(1) * 1.1)
		end
		if grabber:hasPlayerAtPosition("Engineering") then
			grabber:addCustomMessage("Engineering","better_shield_message","Maximum shield strength has been increased")
		end
		if grabber:hasPlayerAtPosition("Engineering+") then
			grabber:addCustomMessage("Engineering+","better_shield_message_plus","Maximum shield strength has been increased")
		end
		grabber.shield_upgrade_count = grabber.shield_upgrade_count + 1
	end)
	return upgrade_artifact, "Shield"
end
function upgradeEnergyArtifact()
	local upgrade_artifact = Artifact():allowPickup(true):setSpin(.7):setRadarSignatureInfo(signature.upgrade.grav,signature.upgrade.elec,signature.upgrade.bio):setModel(model.upgrade)
	upgrade_artifact:onPickUp(function(self,grabber)
		string.format("")	--necessary to have global reference for Serious Proton engine
		if grabber.energy_upgrade_count == nil then
			grabber.energy_upgrade_count = 0
		end
		grabber:setMaxEnergy(grabber:getMaxEnergy() * 1.1)
		grabber:setEnergy(grabber:getMaxEnergy())
		if grabber:hasPlayerAtPosition("Engineering") then
			grabber:addCustomMessage("Engineering","better_energy_message","Battery efficiency has been increased")
		end
		if grabber:hasPlayerAtPosition("Engineering+") then
			grabber:addCustomMessage("Engineering+","better_energy_message_plus","Battery efficiency has been increased")
		end
		grabber.energy_upgrade_count = grabber.energy_upgrade_count + 1
	end)
	return upgrade_artifact, "Energy"
end
function upgradeProbeArtifact()
	local upgrade_artifact = Artifact():allowPickup(true):setSpin(.7):setRadarSignatureInfo(signature.upgrade.grav,signature.upgrade.elec,signature.upgrade.bio):setModel(model.upgrade)
	upgrade_artifact:onPickUp(function(self,grabber)
		string.format("")	--necessary to have global reference for Serious Proton engine
		if grabber.probe_upgrade_count == nil then
			grabber.probe_upgrade_count = 0
		end
		grabber:setMaxScanProbeCount(grabber:getMaxScanProbeCount() + 2)
		grabber:setScanProbeCount(grabber:getMaxScanProbeCount())
		if grabber:hasPlayerAtPosition("Relay") then
			grabber:addCustomMessage("Relay","better_probes_message","Probe capacity and count has been increased")
		end
		if grabber:hasPlayerAtPosition("Operations") then
			grabber:addCustomMessage("Operations","better_probes_message_plus","Probe capacity and count has been increased")
		end
		grabber.probe_upgrade_count = grabber.probe_upgrade_count + 1
	end)
	return upgrade_artifact, "Probe"
end
function upgradeSensorArtifact()
	local upgrade_artifact = Artifact():allowPickup(true):setSpin(.7):setRadarSignatureInfo(signature.upgrade.grav,signature.upgrade.elec,signature.upgrade.bio):setModel(model.upgrade)
	upgrade_artifact:onPickUp(function(self,grabber)
		string.format("")	--necessary to have global reference for Serious Proton engine
		if grabber.sensor_upgrade_count == nil then
			grabber.sensor_upgrade_count = 0
		end
		if grabber.normal_long_range_radar == nil then
			grabber.normal_long_range_radar = 30000
		end
		grabber:setLongRangeRadarRange(grabber:getLongRangeRadarRange() + grabber.normal_long_range_radar*.1)
		if grabber:hasPlayerAtPosition("Science") then
			grabber:addCustomMessage("Science","better_sensors_message","Sensor range has been increased")
		end
		if grabber:hasPlayerAtPosition("Operations") then
			grabber:addCustomMessage("Operations","better_probes_message_plus","Sensor range has been increased")
		end
		grabber.sensor_upgrade_count = grabber.sensor_upgrade_count + 1
	end)
	return upgrade_artifact, "Sensor"
end
--	Alpha type treasures  --
function treasureAlpha(sub_class,x,y)
	local treasure = Artifact():allowPickup(true):setSpin(.5):setRadarSignatureInfo(signature.treasure.grav,signature.treasure.elec,signature.treasure.bio):setModel(model.treasure)
	if sub_class == nil then
		treasure:onPickUp(function(self,grabber)
			string.format("")	--necessary to have global reference for Serious Proton engine
			grabber.alpha = "simple"
			if grabber.alpha_count == nil then
				grabber.alpha_count = 0
			end
			if grabber.reputation == nil then
				grabber.reputation = 0
			end
			grabber.reputation = grabber.reputation + 20
			grabber.alpha_count = grabber.alpha_count + 1
		end)
	elseif sub_class == "respawn" then
		if x ~= nil and y ~= nil then
			treasure:setPosition(x,y)
		end
		treasure:onPickUp(function(self,grabber)
			string.format("")	--necessary to have global reference for Serious Proton engine
			if grabber.alpha ~= nil then
				local self_x, self_y = self:getPosition()
				local new_treasure = treasureAlpha("respawn",self_x,self_y)
				new_treasure:setDescriptionForScanState("unscanned",self:getDescription("unscanned"))
				new_treasure:setDescriptionForScanState("scanned",self:getDescription("scanned"))
				local scan_complexity = self:scanningComplexity(self)
				local scan_depth = self:scanningChannelDepth(self)
				new_treasure:setScanningParameters(scan_complexity,scan_depth):setRadarSignatureInfo(signature.treasure.grav,signature.treasure.elec,signature.treasure.bio):setModel(model.treasure)
			else
				if grabber.reputation == nil then
					grabber.reputation = 0
				end
				grabber.reputation = grabber.reputation + 20
			end
			grabber.alpha = "respawn"
		end)
	elseif sub_class == "move" then
		if x ~= nil and y ~= nil then
			treasure:setPosition(x,y)
		end
		treasure:onPickUp(function(self,grabber)
			string.format("")	--necessary to have global reference for Serious Proton engine
			if grabber.alpha ~= nil then
				local move_x, move_y = placeTreasureAlpha()
				local new_treasure = treasureAlpha("move",move_x,move_y)
				new_treasure:setDescriptionForScanState("unscanned",self:getDescription("unscanned"))
				new_treasure:setDescriptionForScanState("scanned",self:getDescription("scanned"))
				local scan_complexity = self:scanningComplexity(self)
				local scan_depth = self:scanningChannelDepth(self)
				new_treasure:setScanningParameters(scan_complexity,scan_depth):setRadarSignatureInfo(signature.treasure.grav,signature.treasure.elec,signature.treasure.bio):setModel(model.treasure)
			else
				if grabber.reputation == nil then
					grabber.reputation = 0
				end
				grabber.reputation = grabber.reputation + 20
			end
			grabber.alpha = "move"
		end)
	elseif sub_class == "respawn damage" then
		if x ~= nil and y ~= nil then
			treasure:setPosition(x,y)
		end
		treasure:onPickUp(function(self,grabber)
			string.format("")	--necessary to have global reference for Serious Proton engine
			if grabber.alpha ~= nil then
				local self_x, self_y = self:getPosition()
				local new_treasure = treasureAlpha("respawn damage",self_x,self_y)
				new_treasure:setDescriptionForScanState("unscanned",self:getDescription("unscanned"))
				new_treasure:setDescriptionForScanState("scanned",self:getDescription("scanned"))
				local scan_complexity = self:scanningComplexity(self)
				local scan_depth = self:scanningChannelDepth(self)
				new_treasure:setScanningParameters(scan_complexity,scan_depth):setRadarSignatureInfo(signature.treasure.grav,signature.treasure.elec,signature.treasure.bio):setModel(model.treasure)
				grabber:setSystemHealth("warp",grabber:getSystemHealth("warp") - .8)
				grabber:setSystemHealth("jumpdrive",grabber:getSystemHealth("jumpdrive") - .8)
				grabber:setSystemHealth("impulse",grabber:getSystemHealth("impulse") - .8)
				if grabber:hasPlayerAtPosition("Engineering") then
					grabber.treasure_engine_message = "treasure_engine_message"
					grabber:addCustomMessage("Engineering",grabber.treasure_engine_message,"When we brought that thing on board, proximity to the other one caused severe damage to all of our engine systems. We immediately shoved it out an airlock before it could completely destroy us")
				end
				if grabber:hasPlayerAtPosition("Engineering+") then
					grabber.treasure_engine_message_plus = "treasure_engine_message_plus"
					grabber:addCustomMessage("Engineering",grabber.treasure_engine_message_plus,"When we brought that thing on board, proximity to the other one caused severe damage to all of our engine systems. We immediately shoved it out an airlock before it could completely destroy us")
				end
			else
				if grabber.reputation == nil then
					grabber.reputation = 0
				end
				grabber.reputation = grabber.reputation + 20
			end
			grabber.alpha = "respawn damage"
		end)
	elseif sub_class == "move damage" then
		if x ~= nil and y ~= nil then
			treasure:setPosition(x,y)
		end
		treasure:onPickUp(function(self,grabber)
			string.format("")	--necessary to have global reference for Serious Proton engine
			if grabber.alpha ~= nil then
				local move_x, move_y = placeTreasureAlpha()
				local new_treasure = treasureAlpha("move damage",move_x,move_y)
				new_treasure:setDescriptionForScanState("unscanned",self:getDescription("unscanned"))
				new_treasure:setDescriptionForScanState("scanned",self:getDescription("scanned"))
				local scan_complexity = self:scanningComplexity(self)
				local scan_depth = self:scanningChannelDepth(self)
				new_treasure:setScanningParameters(scan_complexity,scan_depth):setRadarSignatureInfo(signature.treasure.grav,signature.treasure.elec,signature.treasure.bio):setModel(model.treasure)
				grabber:setSystemHealth("warp",grabber:getSystemHealth("warp") - .8)
				grabber:setSystemHealth("jumpdrive",grabber:getSystemHealth("jumpdrive") - .8)
				grabber:setSystemHealth("impulse",grabber:getSystemHealth("impulse") - .8)
				if grabber:hasPlayerAtPosition("Engineering") then
					grabber.treasure_engine_message = "treasure_engine_message"
					grabber:addCustomMessage("Engineering",grabber.treasure_engine_message,"Before that thing disappeared, proximity to the other one already on board caused severe damage to all of our engine systems. I'm glad it did not stay around for long")
				end
				if grabber:hasPlayerAtPosition("Engineering+") then
					grabber.treasure_engine_message_plus = "treasure_engine_message_plus"
					grabber:addCustomMessage("Engineering",grabber.treasure_engine_message_plus,"Before that thing disappeared, proximity to the other one already on board caused severe damage to all of our engine systems. I'm glad it did not stay around for long")
				end
			else
				if grabber.reputation == nil then
					grabber.reputation = 0
				end
				grabber.reputation = grabber.reputation + 20
			end
			grabber.alpha = "move damage"
			if game_variation == "Explorer" then
				addToVespucciBarricade()
			end
		end)
	end
	return treasure
end
function placeTreasureAlpha()
	if game_variation == "Normal" then
		local bubble = (40000 - (player_count * 1000))/2
		local center_x, center_y, perimeter = analyzeBlob(place_ref_list)
		local stretch_bound = 1000
		repeat
			candidate_x, candidate_y = vectorFromAngle(random(0,360),random(0,perimeter + bubble + stretch_bound))
			candidate_x = center_x + candidate_x
			candidate_y = center_y + candidate_y
			stretch_bound = stretch_bound + 500
		until(farEnough(place_ref_list,candidate_x,candidate_y,bubble))
		return candidate_x, candidate_y
	end
	if game_variation == "Explorer" then
		local x, y = vectorFromAngle(random(0,360),random(80000,100000))
		x = terrain_center_x + x
		y = terrain_center_y + y
		return x, y
	end
end
--	Foxtrot type treasures  --
function treasureFoxtrot(unscanned_description)
	local treasure = Artifact():allowPickup(false):setSpin(.5):setRadarSignatureInfo(signature.treasure.grav,signature.treasure.elec,signature.treasure.bio):setModel(model.treasure)
	if unscanned_description == nil then
		unscanned_description = "An unusual object"
	end
	treasure.electro_mechanical = math.random(0,9)
	treasure.bio_neural = math.random(0,9)
	treasure.chrono_anomalous = math.random(0,9)
	treasure:setDescriptions(unscanned_description,string.format("A treasure with these readings: electromechanical: %i, bioneural: %i, chronoanomalous: %i",treasure.electro_mechanical,treasure.bio_neural,treasure.chrono_anomalous))
	treasure:setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text]+1)
	return treasure
end
--	Shy treasure type
function listActiveSystems(p)
	local active_systems = {"impulse","maneuver","reactor","frontshield"}
	if p:getShieldCount() > 1 then
		table.insert(active_systems,"rearshield")
	end
	if p:getBeamWeaponRange(0) > 0 then
		table.insert(active_systems,"beamweapons")
	end
	if p:getWeaponTubeCount() > 0 then
		table.insert(active_systems,"missilesystem")
	end
	if p:hasWarpDrive() then
		table.insert(active_systems,"warp")
	end
	if p:hasJumpDrive() then
		table.insert(active_systems,"jumpdrive")
	end
	return active_systems
end
--[[	Deprecated. Use angleFromVectorNorth
function angleFromVector(p1x, p1y, p2x, p2y)
	TWOPI = 6.2831853071795865
	RAD2DEG = 57.2957795130823209
	atan2parm1 = p2x - p1x
	atan2parm2 = p2y - p1y
	theta = math.atan2(atan2parm1, atan2parm2)
	if theta < 0 then
		theta = theta + TWOPI
	end
	return RAD2DEG * theta
end
--]]
function vectorFromAngleNorth(angle,distance)
--	print("input angle to vectorFromAngleNorth:")
--	print(angle)
	angle = (angle + 270) % 360
	local x, y = vectorFromAngle(angle,distance)
	return x, y
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
function treasureShy(unscanned_description)
	local treasure = Artifact():allowPickup(true):setSpin(.5):setRadarSignatureInfo(signature.treasure.grav,signature.treasure.elec,signature.treasure.bio):setModel(model.treasure)
	if unscanned_description == nil then
		unscanned_description = "An unusual object"
	end
	local increment = allowed_angle_variance + 1
	local slots = 360/increment - 1
	treasure.approach_angle = math.random(0,slots)*increment
	treasure:setDescriptions(unscanned_description,string.format("An object with a polycarbonate protrusion pointing in direction %i",treasure.approach_angle))
	treasure:setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
	if shy_treasure_list == nil then
		shy_treasure_list = {}
	end
	table.insert(shy_treasure_list,treasure)
	treasure:onPickUp(function(self,grabber)
		string.format("")	--necessary to have global reference for Serious Proton engine
		if grabber.shy ~= nil then
			local active_systems = listActiveSystems(grabber)
			for i=1,(math.ceil(difficulty * 1.1) + 1) do
				local system_index = math.random(1,#active_systems)
				grabber:setSystemHealth(active_systems.system_index,grabber:getSystemHealth(active_systems.system_index) - 1.5)
				table.remove(active_systems,system_index)
			end
		else
			if grabber.reputation == nil then
				grabber.reputation = 0
			end
			grabber.reputation = grabber.reputation + 20
		end
		grabber.shy = "retrieved"
		if grabber.shy_count == nil then
			grabber.shy_count = 0
		end
		for index, treasure in ipairs(shy_treasure_list) do
			if treasure == self then
				table.remove(shy_treasure_list,index)
				break
			end
		end
		grabber.shy_count = grabber.shy_count + 1
	end)
	return treasure
end
--	Antisocial type treasure type  --
function treasureAntisocial(x,y)
	if x == nil or y == nil then
		print("Must provide x and y coordinates for treasureAntisocial function")
		return
	end
	local treasure = Artifact():allowPickup(true):setSpin(.5):setRadarSignatureInfo(signature.treasure.grav,signature.treasure.elec,signature.treasure.bio):setModel(model.treasure)
	treasure:setPosition(x,y)
	local slow_orbit_time = 160
	local fast_orbit_time = 100
	local angle = 0
	treasure.mine_list = {}
	for i=1,4 do
		local distance = 1500
		for j=1,3 do
			local antisocial_mine = Mine()
			world:addOrbitTargetSpeedCycleUpdate(antisocial_mine,x,y,distance,slow_orbit_time,fast_orbit_time,1,angle)
			table.insert(treasure.mine_list,antisocial_mine)
			distance = distance + 1000
		end
		angle = angle + 90
	end
	treasure:onPickUp(function(self,grabber)
		string.format("")	--necessary to have global reference for Serious Proton engine
		if grabber.antisocial ~= nil then
			local active_systems = listActiveSystems(grabber)
			for i=1,(math.ceil(difficulty * 1.1) + 1) do
				local system_index = math.random(1,#active_systems)
				grabber:setSystemHealth(active_systems.system_index,grabber:getSystemHealth(active_systems.system_index) - 1.5)
				table.remove(active_systems,system_index)
			end
		else
			if grabber.reputation == nil then
				grabber.reputation = 0
			end
			grabber.reputation = grabber.reputation + 20
		end
		grabber.antisocial = "retrieved"
		local ax, ay = self:getPosition()
		WarpJammer():setPosition(ax,ay):setRange(5000+difficulty*1000):setFaction(grabber:getFaction())
	end)
	return treasure
end
--	Player ship functions  --
function pausedPlayerShipConstraints(p)
	if p.pidx == nil then
		identifyPlayerShip(p)
	end
end
function identifyPlayerShip(p)
	for pidx=1,32 do
		if p == getPlayerShip(pidx) then
			p.pidx = pidx
			p:onDestroyed(playerDestroyed)
			if pidx <= #ordered_player_ship_names then
				p:setCallSign(ordered_player_ship_names[pidx])
			else
				if player_restart ~= nil and player_restart[pidx] ~= nil and player_restart[pidx].name ~= nil then
					p:setCallSign(player_restart[pidx].name)
				else
					local template_player_type = p:getTypeName()
					if rwc_player_ship_names[template_player_type] ~= nil and #rwc_player_ship_names[template_player_type] > 0 then
						local selected_name_index = math.random(1,#rwc_player_ship_names[template_player_type])
						p:setCallSign(rwc_player_ship_names[template_player_type][selected_name_index])
						table.remove(rwc_player_ship_names[template_player_type],selected_name_index)
					else
						if rwc_player_ship_names["Unknown"] ~= nil and #rwc_player_ship_names["Unknown"] > 0 then
							selected_name_index = math.random(1,#rwc_player_ship_names["Unknown"])
							p:setCallSign(rwc_player_ship_names["Unknown"][selected_name_index])
							table.remove(rwc_player_ship_names["Unknown"],selected_name_index)
						end
					end
				end
			end
			player_restart.add(pidx,p:getCallSign())
			if control_code_usage ~= "none" then
				if player_restart ~= nil and player_restart[pidx] ~= nil and player_restart[pidx].control_code ~= nil then
					p.control_code = player_restart[pidx].control_code
					p:setControlCode(player_restart[pidx].control_code)
				else
					if control_code_usage == "fixed" and pidx <= #ordered_player_ship_names then
						p.control_code = fixed_control_code[p:getCallSign()]
						p:setControlCode(fixed_control_code[p:getCallSign()])
					else
						local control_code_index = math.random(1,#control_code_stem)
						local stem = control_code_stem[control_code_index]
						table.remove(control_code_stem,control_code_index)
						local branch = math.random(100,999)
						p.control_code = stem .. branch
						p:setControlCode(stem .. branch)
					end
				end
				player_restart.add(pidx,nil,p.control_code)
				print("Control Code for " .. p:getCallSign(), p.control_code)
			end
			if p:getTypeName() ~= player_template then
				p:setTemplate(player_template)
			end
			initialPlayerShipAdjustments(p)
			if player_restart ~= nil and player_restart[pidx] ~= nil and player_restart[pidx].faction ~= nil then
				p:setFaction(player_restart[pidx].faction)
			end
			break
		end
	end
end
function defaultPlayerShipAdjustments(p)
	p.max_repair_crew = p:getRepairCrewCount()
	p:setTypeName(player_template)
	p.ship_score = player_ship_stats[player_template].strength
	p.max_cargo = player_ship_stats[player_template].cargo
	p.cargo = p.max_cargo
	p:setLongRangeRadarRange(player_ship_stats[player_template].long_range_radar)
	p.normal_long_range_radar = player_ship_stats[player_template].long_range_radar
	p:setShortRangeRadarRange(player_ship_stats[player_template].short_range_radar)
end
function initialPlayerShipPlacement()
	if game_variation == "Hunger" then
		placeHungerPlayerShips()
	elseif game_variation == "Explorer" then
		placeExplorerPlayerShips()
	else	--normal, or default or no variation
		placeNormalPlayerShips()
	end
end
function getPlayers()
	local player_list = {}
	for pidx=1,player_count do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			table.insert(player_list,p)
		end
	end
	return player_list
end
function playerDestroyed(self,instigator)
	local respawn_list = {}
	local spawned_object = nil
	local px, py = self:getPosition()
	if self.harass_list ~= nil then
		for _, ship in pairs(self.harass_list) do
			if ship ~= nil and ship:isValid() then
				ship:orderRoaming()
			end
		end
	end
	if self.alpha ~= nil then
		local unscanned_description = ""
		local scanned_description = ""
		if self.alpha == "simple" then
			for i=1,self.alpha_count do
				spawned_object = treasureAlpha()
				unscanned_description = treasure_artifact_description[math.random(1,#treasure_artifact_description)].unscanned
				scanned_description = treasure_artifact_description[math.random(1,#treasure_artifact_description)].scanned
--				print("unscanned description of respawned alpha treasure:",unscanned_description)
--				print("scanned description of respawned alpha treasure:",scanned_description)
				spawned_object:setDescriptions(unscanned_description,scanned_description):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
				table.insert(respawn_list,spawned_object)
			end
		else
			spawned_object = treasureAlpha(self.alpha)
			unscanned_description = treasure_artifact_description[math.random(1,#treasure_artifact_description)].unscanned
			scanned_description = treasure_artifact_description[math.random(1,#treasure_artifact_description)].scanned
			spawned_object:setDescriptions(unscanned_description,scanned_description):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			table.insert(respawn_list,spawned_object)			
		end
	end
	if self.antisocial ~= nil then
		spawned_object = treasureAntisocial(px,py)
		spawned_object:setDescriptions(treasure_artifact_description[math.random(1,#treasure_artifact_description)].unscanned,treasure_artifact_description[math.random(1,#treasure_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
		table.insert(respawn_list,spawned_object)
	end
	if self.sensor_upgrade_count ~= nil then
		for i=1,self.sensor_upgrade_count do
			spawned_object = upgradeSensorArtifact()
			spawned_object:setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			table.insert(respawn_list,spawned_object)			
		end
	end
	if self.probe_upgrade_count ~= nil then
		for i=1,self.probe_upgrade_count do
			spawned_object = upgradeProbeArtifact()
			spawned_object:setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			table.insert(respawn_list,spawned_object)			
		end
	end
	if self.energy_upgrade_count ~= nil then
		for i=1,self.energy_upgrade_count do
			spawned_object = upgradeEnergyArtifact()
			spawned_object:setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			table.insert(respawn_list,spawned_object)			
		end
	end
	if self.shield_upgrade_count ~= nil then
		for i=1,self.shield_upgrade_count do
			spawned_object = upgradeShieldArtifact()
			spawned_object:setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			table.insert(respawn_list,spawned_object)			
		end
	end
	if self.hull_upgrade_count ~= nil then
		for i=1,self.hull_upgrade_count do
			spawned_object = upgradeHullArtifact()
			spawned_object:setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			table.insert(respawn_list,spawned_object)			
		end
	end
	if self.warp_upgrade_count ~= nil then
		for i=1,self.warp_upgrade_count do
			spawned_object = upgradeWarpArtifact()
			spawned_object:setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			table.insert(respawn_list,spawned_object)			
		end
	end
	if self.jump_upgrade_count ~= nil then
		for i=1,self.jump_upgrade_count do
			spawned_object = upgradeJumpArtifact()
			spawned_object:setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			table.insert(respawn_list,spawned_object)			
		end
	end
	if self.impulse_upgrade_count ~= nil then
		for i=1,self.impulse_upgrade_count do
			spawned_object = upgradeImpulseArtifact()
			spawned_object:setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			table.insert(respawn_list,spawned_object)			
		end
	end
	if self.maneuver_upgrade_count ~= nil then
		for i=1,self.maneuver_upgrade_count do
			spawned_object = upgradeManeuverArtifact()
			spawned_object:setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			table.insert(respawn_list,spawned_object)			
		end
	end
	if self.more_missiles_upgrade_count ~= nil then
		for i=1,self.more_missiles_upgrade_count do
			spawned_object = upgradeMoreMissilesArtifact()
			spawned_object:setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			table.insert(respawn_list,spawned_object)			
		end
	end
	if self.aux_tube_upgrade_count ~= nil then
		for i=1,self.aux_tube_upgrade_count do
			spawned_object = upgradeAuxTubeArtifact()
			spawned_object:setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			table.insert(respawn_list,spawned_object)			
		end
	end
	if self.beam_heat_upgrade_count ~= nil then
		for i=1,self.beam_heat_upgrade_count do
			spawned_object = upgradeBeamHeatArtifact()
			spawned_object:setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			table.insert(respawn_list,spawned_object)			
		end
	end
	if self.beam_cycle_upgrade_count ~= nil then
		for i=1,self.beam_cycle_upgrade_count do
			spawned_object = upgradeBeamCycleArtifact()
			spawned_object:setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			table.insert(respawn_list,spawned_object)			
		end
	end
	if self.beam_range_upgrade_count ~= nil then
		for i=1,self.beam_range_upgrade_count do
			spawned_object = upgradeBeamRangeArtifact()
			spawned_object:setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			table.insert(respawn_list,spawned_object)			
		end
	end
	if self.beam_damage_upgrade_count ~= nil then
		for i=1,self.beam_damage_upgrade_count do
			spawned_object = upgradeBeamDamageArtifact()
			spawned_object:setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			table.insert(respawn_list,spawned_object)			
		end
	end
	if #respawn_list > 0 then
		local px, py = self:getPosition()
		local angle = random(0,360)
		local angle_increment = 360/#respawn_list
		for i=1,#respawn_list do
			local chosen_index = math.random(1,#respawn_list)
			local cx, cy = vectorFromAngle(angle,1000)
			respawn_list[chosen_index]:setPosition(px+cx,py+cy)
			table.remove(respawn_list,chosen_index)
			angle = angle + angle_increment
		end
	end
end
-- ************************************* --
--	Variation or Map Specific Functions  --
-- ************************************* --
----------------------------------
--	Normal variation functions  --
----------------------------------
-- 	Default or normal variation summary:
--		Collect three alpha type treasures
--			Scan of artifact reveals whether it is a treasure or not
--		Return to the designated completion sector
--			Sector identified by message and colored zone on Science/Relay
--	Set up  --
function setNormalConstants()
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
	postPauseBuild1 = buildNormalTerrain
	postPauseBuild2 = buildNormalUpgrades
	postPauseBuild3 = buildNormalArtifacts
	treasure_clue_time = getScenarioTime() + game_length / 6	--final:6
	treasure_scan_clue_time = getScenarioTime() + game_length / 10	--final:10
	complete_sector = "M25"
	complete_sector_x = 410000
	complete_sector_y = 150000
	broadcast_messages = {
		["Introduction"] = {long_text = "Welcome to the Treasure Race\n\nBe the first to gather up three treasures\n\nA number of anomalies have been discovered and observed in the area. These artifacts or anomalies or objects (we're still trying to come up with a good name for them - for now we'll call them treasures) turn out to have potentially powerful properties. After careful study the research department has updated your internal science database so that your science officer can identify these treasures after they've been scanned. Unfortunately, the information about these treasures has become public and now several ships are all looking for these treasures. Fame, glory, respect and promotion will go to the first space ship that can find and return three of these treasures. Good luck.",
							short_text = "Be the first to gather and return three treasures",
							count = 0},
		["Collected"] = {long_text = string.format("You have collected all the treasures. You now need to return to sector %s",complete_sector),
						 short_text = string.format("Collected Treasures. Go to %s",complete_sector),
						 count = 0,
						 trigger = collectThreeSimpleAlpha},
	}
	player_updates = {
		clues =			{check = treasureClue,	name = "Treasure Clue"},
	}
	collection_criteria = {
		treasure = {check = collectThreeSimpleAlpha, name = "Collect 3 simple alpha"},
	}
	completion_criteria = {
		sector = {check = completeSector, name = "Complete sector"},
	}
	general_variation_updates = {
		normalHarassment,
		treasureClues,
		identifyCompleteSector,
	}
end
function placeNormalPlayerShips()
	--[[	original placement method
	local angle = random(0,360)
	local psx = 0
	local psy = 0
	for pidx=1,player_count do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			psx, psy = vectorFromAngle(angle,player_circular_placement[player_count].radius)
			psx = terrain_center_x + psx
			psy = terrain_center_y + psy
			p:setPosition(psx,psy)
			p.start_x = psx
			p.start_y = psy
			angle = angle + player_circular_placement[player_count].angle_increment
		end
	end
	--]]
	local player_list = {}
	for i=1,player_count do
		table.insert(player_list,getPlayerShip(i))
	end
	local placed_players = {}
	local start_x = 0
	local start_y = 0
	local player_center_x = 0
	local player_center_y = 0
	local perimeter = 0
	for i=1,player_count do
		local selected_index = math.random(1,#player_list)
		local p = player_list[selected_index]
		table.remove(player_list,selected_index)
		if #placed_players == 0 then
			p.start_x = terrain_center_x
			p.start_y = terrain_center_y
			p:setPosition(p.start_x,p.start_y)
		else
			player_center_x, player_center_y, perimeter = analyzeBlob(placed_players)
			local stretch_bound = 1000
			local player_bubble = 40000 - (player_count*1000)
			repeat
				start_x, start_y = vectorFromAngle(random(0,360),random(stretch_bound,perimeter + player_bubble + stretch_bound))
				p.start_x = player_center_x + start_x
				p.start_y = player_center_y + start_y
				stretch_bound = stretch_bound + 500
			until(farEnough(placed_players,p.start_x,p.start_y,player_bubble))
			p:setPosition(p.start_x,p.start_y)
		end
		table.insert(placed_players,p)
		player_restart.add(p.pidx,nil,nil,p.start_x,p.start_y)
	end
end
function selectRandomStation()
	local selected_station = nil
	local selected_group = nil
	local remaining_stations = 0
	for _, group in ipairs(station_priority) do
		if station_pool[group] ~= nil then
			local station_selection_list = {}
			for station, details in pairs(station_pool[group]) do
				table.insert(station_selection_list,station)
			end
			if #station_selection_list > 0 then
				remaining_stations = remaining_stations + #station_selection_list
				if selected_station == nil then
					selected_station = station_selection_list[math.random(1,#station_selection_list)]
					selected_group = group
				end
			end
		end
	end
	return selected_group, selected_station, remaining_stations
end
--[[	original terrain setup for normal variation
function buildNormalStations(delta)
	place_ref_list = getPlayers()
	if station_priority == nil then
		station_priority = {}
		for group, list in pairs(station_pool) do
			table.insert(station_priority,group)
		end
		table.sort(station_priority)
	end
	station_list = {}
	human_station_list = {}
	independent_station_list = {}
	enemy_station_list = {}
	local candidate_x = 0
	local candidate_y = 0
	local center_x = 0
	local center_y = 0
	local perimeter = 0
	for i=1,50 do
		local selected_group, selected_station, number_of_stations = selectRandomStation()
		local station_details = station_pool[selected_group][selected_station]
		center_x, center_y, perimeter = analyzeBlob(place_ref_list)
		local stretch_bound = 1000
		local bubble = (40000 - (player_count * 1000))/2
		repeat
			candidate_x, candidate_y = vectorFromAngle(random(0,360),random(0,perimeter + bubble + stretch_bound))
			candidate_x = center_x + candidate_x
			candidate_y = center_y + candidate_y
			stretch_bound = stretch_bound + 500
		until(farEnough(place_ref_list,candidate_x,candidate_y,bubble))
		local station = SpaceStation():setTemplate(stationSizeTemplate()):setPosition(candidate_x,candidate_y):setCommsScript(""):setCommsFunction(commsStation)
		local faction_choice = random(1,100)
		if faction_choice <= 9 then
			station:setFaction("Human Navy")
		elseif faction_choice >= 91 then
			station:setFaction("Kraylor")
			local station_selection_list = {}
			for station, details in pairs(station_pool["Sinister"]) do
				table.insert(station_selection_list,station)
			end
			if #station_selection_list > 0 then
				selected_station = station_selection_list[math.random(1,#station_selection_list)]
				selected_group = "Sinister"
				station_details = station_pool[selected_group][selected_station]
			else
				station:setFaction("Independent")				
			end
		else
			station:setFaction("Independent")
		end
		station:setCallSign(selected_station):setDescription(station_details.description)
		station.comms_data = {
			friendlyness = random(1,100),
			weapons = 			{Homing = "neutral",		HVLI = "neutral", 		Mine = "neutral",		Nuke = "neutral", 		EMP = "neutral"},
			weapon_available = 	{Homing = random(1,10)<=8,	HVLI = random(1,10)<=9,	Mine = random(1,10)<=7,	Nuke = random(1,10)<=5,	EMP = random(1,10)<=6},
			service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
			reputation_cost_multipliers = {friend = 1.0, neutral = random(1,4)},
			max_weapon_refill_amount = {friend = 1.0, neutral = random(.2,.8)},
			goods = {},
			trade = {food = random(1,10)<=(5-difficulty), medicine = random(1,10)<=(5-difficulty), luxury = random(1,10)<=(5-difficulty)},
			general_information = station_details.general,
			history = station_details.history,
		}
		for _, good in pairs(station_details.goods) do
			if good == "food" then
				station.comms_data.goods[good] = {quantity = math.random(5,10), cost = 1}
			elseif good == "medicine" then
				station.comms_data.goods[good] = {quantity = math.random(5,10), cost = 5}
			elseif good == "luxury" then
				station.comms_data.goods[good] = {quantity = math.random(5,10), cost = math.random(25,50)}
			else
				station.comms_data.goods[good] = {quantity = math.random(5,10), cost = math.random(50,120)}
			end
		end
		station_pool[selected_group][selected_station] = nil	--remove station from list
		if station:getFaction() == "Kraylor" then
			table.insert(enemy_station_list,station)
		else
			table.insert(station_list,station)
			if station:getFaction() == "Independent" then
				table.insert(independent_station_list,station)
			else
				table.insert(human_station_list,station)
			end
		end
		table.insert(place_ref_list,station)
	end
end
function buildNormalUpgrades(delta)
	local candidate_x = 0
	local candidate_y = 0
	local center_x = 0
	local center_y = 0
	local perimeter = 0
	upgrade_list = {}
	for i=1,player_count*4 do
		center_x, center_y, perimeter = analyzeBlob(place_ref_list)
		local stretch_bound = 1000
		local bubble = (40000 - (player_count * 1000))/2
		repeat
			candidate_x, candidate_y = vectorFromAngle(random(0,360),random(0,perimeter + bubble + stretch_bound))
			candidate_x = center_x + candidate_x
			candidate_y = center_y + candidate_y
			stretch_bound = stretch_bound + 500
		until(farEnough(place_ref_list,candidate_x,candidate_y,bubble))
		local upgrade_artifact = selectArtifactUpgradeType()
		upgrade_artifact:setPosition(candidate_x,candidate_y):setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned)
		upgrade_artifact:setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
		upgrade_artifact:setPosition(candidate_x,candidate_y):setDescriptions(treasure_artifact_description[math.random(1,#treasure_artifact_description)].unscanned,treasure_artifact_description[math.random(1,#treasure_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
		table.insert(upgrade_list,upgrade_artifact)
		table.insert(place_ref_list,upgrade_artifact)
	end
end
function buildNormalArtifacts(delta)
	local candidate_x = 0
	local candidate_y = 0
	local center_x = 0
	local center_y = 0
	local perimeter = 0
	treasure_list = {}
	for i=1,player_count*4 do
		center_x, center_y, perimeter = analyzeBlob(place_ref_list)
		local stretch_bound = 1000
		local bubble = (40000 - (player_count * 1000))/2
		repeat
			candidate_x, candidate_y = vectorFromAngle(random(0,360),random(0,perimeter + bubble + stretch_bound))
			candidate_x = center_x + candidate_x
			candidate_y = center_y + candidate_y
			stretch_bound = stretch_bound + 500
		until(farEnough(place_ref_list,candidate_x,candidate_y,bubble))
		local treasure = treasureAlpha()
		treasure:setPosition(candidate_x,candidate_y):setDescriptions(treasure_artifact_description[math.random(1,#treasure_artifact_description)].unscanned,treasure_artifact_description[math.random(1,#treasure_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
		table.insert(treasure_list,treasure)
		table.insert(place_ref_list,treasure)
	end
end
--]]
function buildNormalTerrain(delta)
	local station_quantity = 50
	local treasure_quantity = player_count * 4
	local upgrade_quantity = player_count * 4
	local wormhole_quantity = 5
	local blackhole_quantity = 3
	local planet_quantity = 3
	place_ref_list = getPlayers()
	if station_priority == nil then
		station_priority = {}
		for group, list in pairs(station_pool) do
			table.insert(station_priority,group)
		end
		table.sort(station_priority)
	end
	station_list = {}
	human_station_list = {}
	independent_station_list = {}
	enemy_station_list = {}
	local candidate_x = 0
	local candidate_y = 0
	local center_x = 0
	local center_y = 0
	local perimeter = 0
	center_x, center_y, perimeter = analyzeBlob(place_ref_list)
	local bubble = (40000 - (player_count * 1000))/2
	local stretch_bound = 1000
	repeat
		candidate_x, candidate_y = vectorFromAngle(random(0,360),random(0,perimeter + bubble + stretch_bound))
		candidate_x = center_x + candidate_x
		candidate_y = center_y + candidate_y
		stretch_bound = stretch_bound + 500
	until(farEnough(place_ref_list,candidate_x,candidate_y,bubble))
	local selected_group, selected_station, number_of_stations = selectRandomStation()
	local station_details = station_pool[selected_group][selected_station]
	primaryStation = SpaceStation():setTemplate("Huge Station"):setCommsScript(""):setCommsFunction(commsStation)
	primaryStation:setFaction("Human Navy"):setPosition(candidate_x,candidate_y)
	primaryStation:setCallSign(selected_station):setDescription(station_details.description)
	primaryStation.comms_data = {
		friendlyness = 80,
		weapons = 			{Homing = "neutral",	HVLI = "neutral", 	Mine = "neutral",	Nuke = "neutral",	EMP = "neutral"},
		weapon_available = 	{Homing = true,			HVLI = true,		Mine = true,		Nuke = true,		EMP = true},
		service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
		reputation_cost_multipliers = {friend = 1.0, neutral = random(1,4)},
		max_weapon_refill_amount = {friend = 1.0, neutral = random(.2,.8)},
		goods = {},
		trade = {food = false, medicine = false, luxury = false},
		general_information = station_details.general,
		history = station_details.history,
	}
	for _, good in pairs(station_details.goods) do
		if good == "food" then
			primaryStation.comms_data.goods[good] = {quantity = math.random(5,10), cost = 1}
		elseif good == "medicine" then
			primaryStation.comms_data.goods[good] = {quantity = math.random(5,10), cost = 5}
		elseif good == "luxury" then
			primaryStation.comms_data.goods[good] = {quantity = math.random(5,10), cost = math.random(25,50)}
		else
			primaryStation.comms_data.goods[good] = {quantity = math.random(5,10), cost = math.random(50,120)}
		end
	end
	station_pool[selected_group][selected_station] = nil	--remove station from list
	table.insert(independent_station_list,primaryStation)
	table.insert(station_list,primaryStation)
	table.insert(place_ref_list,primaryStation)
	treasure_list = {}
	upgrade_list = {}
	local planet_list = {
		{radius = 1000, distance = -2000, 
			name = {"Gamma Piscium","Beta Lyporis","Sigma Draconis","Iota Carinae","Theta Arietis","Epsilon Indi","Beta Hydri"},
			color = {
				red = 1, green = 1, blue = 1
			},
			texture = {
				atmosphere = "planets/star-1.png"
			},
		},
		{radius = 3000, distance = -2000, rotation = 300,
			name = {"Bespin","Aldea","Bersallis","Alpha Omicron","Farius Prime","Deneb","Mordan","Nelvana"},
			texture = {
				surface = "planets/gas-1.png"
			},
		},
		{radius = 3000, distance = -2000, rotation = 400,
			name = {"Alderaan","Dagobah","Dantooine","Rigel","Pahvo","Penthara","Scalos","Tanuga","Vacca","Terlina","Timor"},
			color = {
				red = 0.2, green = 0.2, blue = 1
			},
			texture = {
				surface = "planets/planet-1.png", cloud = "planets/clouds-1.png", atmosphere = "planets/atmosphere.png"
			},
		},
	}
	local feature = nil
	repeat
		bubble = (40000 - (player_count * 1000))/2
		center_x, center_y, perimeter = analyzeBlob(place_ref_list)
		local terrain_feature_choice = random(1,100)
		if terrain_feature_choice <= 27 then
			--asteroid
			bubble = 500
			feature = "Asteroid"
		elseif terrain_feature_choice <= 39 then
			--station
			if station_quantity <= 0 then
				feature = "Treasure"
			else
				feature = "Station"
			end
		elseif terrain_feature_choice <= 47 then
			--treasure
			if treasure_quantity <= 0 then
				feature = "Station"
			else
				feature = "Treasure"
			end
		elseif terrain_feature_choice <= 57 then
			--upgrade
			if upgrade_quantity <= 0 then
				if decoy_enabled == "Yes" then
					feature = "Decoy"
				else
					bubble = 500
					feature = "Asteroid"
				end
			else
				feature = "Upgrade"
			end
		elseif terrain_feature_choice <= 67 then
			--mine
			bubble = 1000
			feature = "Mine"
		elseif terrain_feature_choice <= 72 then
			--wormhole
			if wormhole_quantity <= 0 then
				bubble = 500
				feature = "Asteroid"
			else
				bubble = 6000
				feature = "Wormhole"
			end
		elseif terrain_feature_choice <= 75 then
			--blackhole
			if blackhole_quantity <= 0 then
				bubble = 500
				feature = "Asteroid"
			else
				bubble = 6000
				feature = "Blackhole"
			end
		elseif terrain_feature_choice <= 87 then
			--decoy
			if decoy_enabled == "Yes" then
				feature = "Decoy"
			else
				bubble = 500
				feature = "Asteroid"
			end
		elseif terrain_feature_choice <= 97 then
			--supply drop
			bubble = 500
			feature = "Supply"
		else
			--planet
			if planet_quantity <= 0 then
				bubble = 500
				feature = "Asteroid"
			else
				feature = "Planet"
			end
		end
		local stretch_bound = 1000
		repeat
			candidate_x, candidate_y = vectorFromAngle(random(0,360),random(0,perimeter + bubble + stretch_bound))
			candidate_x = center_x + candidate_x
			candidate_y = center_y + candidate_y
			stretch_bound = stretch_bound + 500
		until(farEnough(place_ref_list,candidate_x,candidate_y,bubble))
		if feature == "Supply" then
			local supply = SupplyDrop():setPosition(candidate_x,candidate_y):setFaction("Human Navy")
			local supply_label = ""
			local supply_details = ""
			if random(1,100) <= 10 then
				supply:setWeaponStorage("HVLI",2)
				supply_label = supply_label .. " L2"
				supply_details = supply_details .. "2 HVLI\n"
			end
			if random(1,100) <= 9 then
				supply:setWeaponStorage("Homing",2)
				supply_label = supply_label .. " H2"
				supply_details = supply_details .. "2 Homing\n"
			end
			if random(1,100) <= 8 then
				supply:setWeaponStorage("Mine",2)
				supply_label = supply_label .. " M2"
				supply_details = supply_details .. "2 Mine\n"
			end
			if random(1,100) <= 7 then
				supply:setWeaponStorage("EMP",2)
				supply_label = supply_label .. " E2"
				supply_details = supply_details .. "2 EMP\n"
			end
			if random(1,100) <= 6 then
				supply:setWeaponStorage("Nuke",2)
				supply_label = supply_label .. " N2"
				supply_details = supply_details .. "2 Nuke\n"
			end
			if random(1,100) <= 5 then
				supply.coolant = 1
				supply_label = supply_label .. " C1"
				supply_details = supply_details .. "Coolant\n"
			end
			if random(1,100) <= 4 then
				supply.repair_crew = 1
				supply_label = supply_label .. " R1"
				supply_details = supply_details .. "Repair Bot\n"
			end
			if supply_label == "" then
				local energy = math.random(3,8)
				supply_label = supply_label .. "B" .. energy
				supply_details = supply_details .. energy*100 .. " Energy\n"
				supply:setEnergy(energy*100)
			end
			supply:setDescriptions(supply_label,supply_details):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			supply:onPickUp(function(self, player)
				string.format("")	--necessary to have global reference for Serious Proton engine
				if self.repair_crew ~= nil then
					player:setRepairCrewCount(player:getRepairCrewCount() + self.repair_crew)
				end
				if self.coolant ~= nil then
					player:setMaxCoolant(player:getMaxCoolant() + self.coolant)
				end
			end)
		elseif feature == "Planet" then
			local planet = Planet():setPosition(candidate_x,candidate_y):setPlanetRadius(planet_list[planet_quantity].radius):setDistanceFromMovementPlane(planet_list[planet_quantity].distance)
			if planet_list[planet_quantity].texture.surface ~= nil then
				planet:setPlanetSurfaceTexture(planet_list[planet_quantity].texture.surface)
			end
			if planet_list[planet_quantity].texture.atmosphere ~= nil then
				planet:setPlanetAtmosphereTexture(planet_list[planet_quantity].texture.atmosphere)
			end
			if planet_list[planet_quantity].texture.cloud ~= nil then
				planet:setPlanetCloudTexture(planet_list[planet_quantity].texture.cloud)
			end
			if planet_list[planet_quantity].color ~= nil then
				planet:setPlanetAtmosphereColor(planet_list[planet_quantity].color.red,planet_list[planet_quantity].color.green,planet_list[planet_quantity].color.blue)
			end
			if planet_list[planet_quantity].rotation ~= nil then
				planet:setAxialRotationTime(planet_list[planet_quantity].rotation)
			end
			table.insert(place_ref_list,planet)
			planet_quantity = planet_quantity - 1
		elseif feature == "Blackhole" then
			table.insert(place_ref_list,BlackHole():setPosition(candidate_x,candidate_y))
			blackhole_quantity = blackhole_quantity - 1
		elseif feature == "Wormhole" then
			local wex, wey = vectorFromAngle(random(0,360),random(80000,200000))
			table.insert(place_ref_list,WormHole():setPosition(candidate_x,candidate_y):setTargetPosition(candidate_x+wex,candidate_y+wey))
			wormhole_quantity = wormhole_quantity - 1
		elseif feature == "Decoy" then
			local decoy = Artifact():allowPickup(true):setSpin(.5):setRadarSignatureInfo(signature.treasure.grav,signature.treasure.elec,signature.treasure.bio):setModel(model.decoy)
			decoy:setPosition(candidate_x,candidate_y):setDescriptions("An unusual object","A pretty object"):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			table.insert(place_ref_list,decoy)
		elseif feature == "Upgrade" then
			local upgrade_artifact, upgrade_type = selectArtifactUpgradeType()
			upgrade_artifact:setPosition(candidate_x,candidate_y):setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned)
			upgrade_artifact:setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			upgrade_quantity = upgrade_quantity - 1
			upgrade_artifact.upgrade_type = upgrade_type
			table.insert(upgrade_list,upgrade_artifact)
			table.insert(place_ref_list,upgrade_artifact)
		elseif feature == "Treasure" then
			local treasure = treasureAlpha()
			treasure:setPosition(candidate_x,candidate_y):setDescriptions(treasure_artifact_description[math.random(1,#treasure_artifact_description)].unscanned,treasure_artifact_description[math.random(1,#treasure_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			treasure_quantity = treasure_quantity - 1
			table.insert(treasure_list,treasure)
			table.insert(place_ref_list,treasure)
		elseif feature == "Station" then
			selected_group, selected_station, number_of_stations = selectRandomStation()
			station_details = station_pool[selected_group][selected_station]
			local station = SpaceStation():setTemplate(stationSizeTemplate()):setPosition(candidate_x,candidate_y):setCommsScript(""):setCommsFunction(commsStation)
			local faction_choice = random(1,100)
			if faction_choice <= 9 then
				station:setFaction("Human Navy")
			elseif faction_choice >= 91 then
				station:setFaction("Kraylor")
				local station_selection_list = {}
				for station, details in pairs(station_pool["Sinister"]) do
					table.insert(station_selection_list,station)
				end
				if #station_selection_list > 0 then
					selected_station = station_selection_list[math.random(1,#station_selection_list)]
					selected_group = "Sinister"
					station_details = station_pool[selected_group][selected_station]
				else
					station:setFaction("Independent")				
				end
			else
				station:setFaction("Independent")
			end
			station:setCallSign(selected_station):setDescription(station_details.description)
			station.comms_data = {
				friendlyness = random(1,100),
				weapons = 			{Homing = "neutral",		HVLI = "neutral", 		Mine = "neutral",		Nuke = "neutral", 		EMP = "neutral"},
				weapon_available = 	{Homing = random(1,10)<=8,	HVLI = random(1,10)<=9,	Mine = random(1,10)<=7,	Nuke = random(1,10)<=5,	EMP = random(1,10)<=6},
				service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
				reputation_cost_multipliers = {friend = 1.0, neutral = random(1,4)},
				max_weapon_refill_amount = {friend = 1.0, neutral = random(.2,.8)},
				goods = {},
				trade = {food = random(1,10)<=(5-difficulty), medicine = random(1,10)<=(5-difficulty), luxury = random(1,10)<=(5-difficulty)},
				general_information = station_details.general,
				history = station_details.history,
			}
			for _, good in pairs(station_details.goods) do
				if good == "food" then
					station.comms_data.goods[good] = {quantity = math.random(5,10), cost = 1}
				elseif good == "medicine" then
					station.comms_data.goods[good] = {quantity = math.random(5,10), cost = 5}
				elseif good == "luxury" then
					station.comms_data.goods[good] = {quantity = math.random(5,10), cost = math.random(25,50)}
				else
					station.comms_data.goods[good] = {quantity = math.random(5,10), cost = math.random(50,120)}
				end
			end
			station_pool[selected_group][selected_station] = nil	--remove station from list
			if station:getFaction() == "Kraylor" then
				table.insert(enemy_station_list,station)
			else
				table.insert(station_list,station)
				if station:getFaction() == "Independent" then
					table.insert(independent_station_list,station)
				else
					table.insert(human_station_list,station)
				end
			end
			station_quantity = station_quantity - 1
			table.insert(place_ref_list,station)
		elseif feature == "Mine" then
			table.insert(place_ref_list,Mine():setPosition(candidate_x,candidate_y))
		else	--Asteroid
			local asteroid = Asteroid():setPosition(candidate_x,candidate_y)
	        local asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
	        asteroid:setSize(asteroid_size)
			table.insert(place_ref_list,asteroid)
		end
--		print(string.format("Stations: %i, Treasures: %i",station_quantity,treasure_quantity))
--		print(string.format("Blackholes: %i, Wormholes: %i, Upgrades: %i, Planets: %i",blackhole_quantity,wormhole_quantity,upgrade_quantity,planet_quantity)) 
	until(station_quantity <= 0 and treasure_quantity <= 0)
	center_x, center_y, perimeter = analyzeBlob(place_ref_list)
	placeRandomAroundPoint(Nebula,math.random(10,20),1,perimeter,center_x,center_y)
end
--	Ongoing  --
function collectThreeSimpleAlpha(p)
	--currently only used by the normal variation, but it could be used by other variations
	if p.alpha_count ~= nil and p.alpha_count >= 3 then
		return true
	else
		return false
	end
end
function treasureClues(delta)
	if getScenarioTime() > treasure_clue_time then
		if treasure_clue == nil then
			treasure_clue = 0
		end
		treasure_clue = treasure_clue + 1
		treasure_clue_time = getScenarioTime() + game_length / 6
	end
	if getScenarioTime() > treasure_scan_clue_time then
		if treasure_scan_clue == nil then
			treasure_scan_clue = 0
		end
		treasure_scan_clue = treasure_scan_clue + 1
		treasure_scan_clue_time = getScenarioTime() + game_length / 10
	end
end
function treasureClue(p)
	if treasure_scan_clue ~= nil then
		if p.treasure_clue_list == nil then
			p.treasure_clue_list = {}
		end
		local treasure_clue_scan_count = 0
		for i,clue in ipairs(p.treasure_clue_list) do
			if clue.clue_type == "scan" then
				treasure_clue_scan_count = treasure_clue_scan_count + 1
			end
		end
		if treasure_clue_scan_count < treasure_scan_clue then
			local closest_treasure_distance = 999999
			local closest_treasure = nil
			for i, treasure in ipairs(treasure_list) do
				if treasure ~= nil and treasure:isValid() then
					if distance(p,treasure) < closest_treasure_distance then
						closest_treasure_distance = distance(p,treasure)
						closest_treasure = treasure
					end
				end
			end
			local in_list = false
			for i,clue in ipairs(p.treasure_clue_list) do
				if closest_treasure == clue.treasure then
					in_list = true
					break
				end
			end
			if not in_list then
				local px, py = p:getPosition()
				local tx, ty = closest_treasure:getPosition()
				local bearing = angleHeading(px, py, tx, ty)
				local q_scan = {
					{confidence = 25,	
						blur = {
							{thresh = 45,	bear = 0},
							{thresh = 135,	bear = 90},
							{thresh = 225,	bear = 180},
							{thresh = 315,	bear = 270},
						},
					},
					{confidence = 50,	
						blur = {
							{thresh = 22.5,			bear = 0},
							{thresh = 45 + 22.5,	bear = 45},
							{thresh = 90 + 22.5,	bear = 90},
							{thresh = 135 + 22.5,	bear = 135},
							{thresh = 180 + 22.5,	bear = 180},
							{thresh = 225 + 22.5,	bear = 225},
							{thresh = 270 + 22.5,	bear = 270},
							{thresh = 315 + 22.5,	bear = 315},
						},
					},
					{confidence = 95},
				}
				local qi = math.min(treasure_scan_clue,3)
				local report_bearing = bearing
				local report_distance = math.floor(closest_treasure_distance/1000)
				if q_scan[qi].blur ~= nil then
					if q_scan[qi].confidence == 25 then
						report_distance = math.floor(report_distance/10)*10
					else
						report_distance = math.floor(report_distance/5)*5
					end
					report_bearing = 0
					for i,b in ipairs(q_scan[qi].blur) do
						if bearing < b.thresh then
							report_bearing = b.bear
							break
						end
					end
				end
				local clue_fragment = string.format(
					"Quantum resonance scan has identified a treasure at approximate bearing %s, distance %sU from",
					math.floor(report_bearing), report_distance
				)
				px = px % 20000
				if px < 0 then 
					px = px + 20000
				end
				py = py % 20000
				if py < 0 then
					py = py + 20000
				end
				local mark = 0
				if px < 20000/3 then
					mark = 1
				elseif px < 20000/3*2 then
					mark = 2
				else
					mark = 3
				end
				if py > 20000/3 then
					if py > 20000/3*2 then
						mark = mark + 6
					else
						mark = mark + 3
					end
				end
				table.insert(p.treasure_clue_list, {
					clue = string.format("%s sector %s mark %i; confidence: %s%%",clue_fragment,p:getSectorName(),mark,q_scan[qi].confidence),
					treasure = closest_treasure,
					clue_type = "quantum scan",
				})
				p:addToShipLog(string.format("%s your current location; confidence: %s%%",clue_fragment,q_scan[qi].confidence),"Magenta")
			end
		end
	end	
	if treasure_clue ~= nil then
		if p.treasure_clue_list == nil then
			p.treasure_clue_list = {}
		end
		local treasure_clue_sector_count = 0
		for i,clue in ipairs(p.treasure_clue_list) do
			if clue.clue_type == "sector" then
				treasure_clue_sector_count = treasure_clue_sector_count + 1
			end
		end
		if treasure_clue_sector_count < treasure_clue then
			closest_treasure_distance = 999999
			closest_treasure = nil
			for index, treasure in pairs(treasure_list) do
				if treasure ~= nil and treasure:isValid() then
					local current_distance = distance(p,treasure)
					if current_distance < closest_treasure_distance then
						closest_treasure_distance = current_distance
						closest_treasure = treasure
					end
				end
			end
			in_list = false
			for i,clue in ipairs(p.treasure_clue_list) do
				if closest_treasure == clue.treasure and clue.clue_type == "sector" then
					in_list = true
					break
				end
			end
			if not in_list then
				table.insert(p.treasure_clue_list, {
					clue = string.format("Sensors have identified a treasure in sector %s",closest_treasure:getSectorName()),
					treasure = closest_treasure,
					clue_type = "sector",
				})
				p:addToShipLog(string.format("Sensors have identified a treasure in sector %s",closest_treasure:getSectorName()),"Magenta")
			end
		end
	end
end
function identifyCompleteSector(delta)
	if complete_sector_identifier_zone ~= nil then
		zone_color_timer = zone_color_timer - delta
		if zone_color_timer < 0 then
			complete_sector_identifier_zone:setColor(
				zone_color_list[zone_color_index].r,
				zone_color_list[zone_color_index].g,
				zone_color_list[zone_color_index].b
			)
			zone_color_index = zone_color_index + 1
			if zone_color_index > #zone_color_list then
				zone_color_index = 1
			end
			zone_color_timer = zone_color_interval
		end
	end
end
function completeSector(p)
	--currently only used by the normal variation, but it could be used by other variations
	if complete_sector == nil then
		complete_sector = "M25"
		complete_sector_x = 410000
		complete_sector_y = 150000
	end
	if complete_sector_identifier_zone == nil then
		complete_sector_x = math.floor(complete_sector_x / 20000)
		complete_sector_x = complete_sector_x * 20000
		complete_sector_y = math.floor(complete_sector_y / 20000)
		complete_sector_y = complete_sector_y * 20000
		complete_sector_identifier_zone = Zone():setPoints(
			complete_sector_x,			complete_sector_y,
			complete_sector_x + 20000,	complete_sector_y,
			complete_sector_x + 20000,	complete_sector_y + 20000,
			complete_sector_x,			complete_sector_y + 20000
		)
		zone_color_interval = 3
		zone_color_timer = zone_color_interval
		zone_color_index = 1
	end
	if p:getSectorName() == complete_sector then
		return true
	else
		return false
	end
end
function normalHarassment(delta)
	if harass_timer == nil then
		harass_timer_interval = 120
		harass_timer = delta + harass_timer_interval + random(0,10)
		harass_danger_interval = .15
		harass_danger = 1
	end
	harass_timer = harass_timer - delta
	if harass_timer < 0 then
		local reference_harass_list = nil
		local increment_danger = false
		for pidx=1,player_count do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p.harass_list == nil then
					p.harass_list = {}
					p.harass_check_count = 0
				end
				p.harass_check_count = p.harass_check_count + 1
				if #p.harass_list < 3 or p.harass_check_count >= 5 then
					local harass_list = nil
					print("danger in normal harassment: " .. harass_danger)
					if reference_harass_list == nil then
						harass_list = vectorOn(p,harass_danger)
						reference_harass_list = harass_list
					else
						harass_list = vectorOn(p,harass_danger,nil,nil,reference_harass_list)
					end
					if p.harass_type == nil or #p.harass_type < 1 then
						p.harass_type = {"roam","attack","move"}
					end
					local harass_index = math.random(1,#p.harass_type)
					if p.harass_type[harass_index] == "roam" then
						for _, enemy in ipairs(harass_list) do
							enemy:orderRoaming()
							if p.harass_check_count >= 5 then
								enemy:setWarpDrive(true)
							end
							table.insert(p.harass_list,enemy)
						end
					elseif p.harass_type[harass_index] == "attack" then
						for _, enemy in ipairs(harass_list) do
							enemy:orderAttack(p)
							if p.harass_check_count >= 5 then
								enemy:setWarpDrive(true)
							end
							table.insert(p.harass_list,enemy)
						end
					else
						for _, enemy in ipairs(harass_list) do
							if p.harass_check_count >= 5 then
								enemy:setWarpDrive(true)
							end
							table.insert(p.harass_list,enemy)
						end
					end
					table.remove(p.harass_type,harass_index)
					p.harass_check_count = 0
					increment_danger = true
				end
			end
		end
		harass_danger = harass_danger + harass_danger_interval
		harass_timer = delta + harass_timer_interval
	end
end
----------------------------------
--	Hunger variation functions  --
----------------------------------
--	Hunger variation summary:
--		Collect alpha type treasure
--			Scan of artifact reveals whether it is a treasure or not
--		Collect anti-social type treasure
--			Treasure protected by mines
--		(third treasure collection type goal to be added later)
--		Dock with primary station
--			Primary stations changes location according to a pattern
--  Set up  --
function setHungerConstants()
	postPauseBuild1 = buildHungerRings
	postPauseBuild2 = buildHungerAnitsocialTreasure
	postPauseBuild3 = buildOuterElements
	ring_spawn_timer_interval = 120
	ring_spawn_timer = ring_spawn_timer_interval
	hunger_primary_station_stopped = true
	broadcast_messages = {
		["Introduction"] = {long_text = "Welcome to the Treasure Race\n\nBe the first to gather the treasures\n\nA number of anomalies have been discovered and observerd in the area. These artifacts or anomalies or objects (we're still trying to come up with a good name for them - for now we'll call them treasures) turn out to have potentially powerful properties. After careful study the research department has updated your internal science database so that your science officer can identify these treasures after they've been scanned. Unfortunately, the information about these treasures has become public and now several ships are all looking for these treasures. Fame, glory, respect and promotion will go to the first space ship that can find and return these treasures and then dock with the primary station. Good luck.",
							short_text = "Be the first to gather treasures and then dock with primary station",
							count = 0},
	}
	collection_criteria = {
		alpha = {check = collectAlpha, name = "Collect alpha"},
		antisocial = {check = collectAntisocial, name = "Collect antisocial"},
	}
	completion_criteria = {
		dock = {check = dockWithPrimary, name = "Dock with primary"},
	}
	general_variation_updates = {
		hungerInnerRingSpawnCheck,
	}
	normal_stationary_interval = 40		--for mission completion station that moves
	hunger_nebula_min = 10
	hunger_nebula_max = 20
end
function placeHungerPlayerShips()
	local angle = random(0,360)
	--Asteroid():setPosition(terrain_center_x,terrain_center_y)
	local psx = 0
	local psy = 0
	for pidx=1,player_count do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			psx, psy = vectorFromAngle(angle,player_circular_placement[player_count].radius)
			psx = terrain_center_x + psx
			psy = terrain_center_y + psy
			p:setPosition(psx,psy)
			local tra = angle + 180
			if tra > 360 then
				tra = tra - 360
			end
			p:commandTargetRotation(tra)
			local ha = angle + 270
			if ha > 360 then 
				ha = ha - 360
			end
			p:setHeading(ha)
			p.start_x = psx
			p.start_y = psy
			angle = angle + player_circular_placement[player_count].angle_increment
			if angle > 360 then
				angle = angle - 360
			end
			player_restart.add(pidx,nil,nil,p.start_x,p.start_y)
		end
	end
end
function buildHungerRings(delta)
	local angle = random(0,360)
	local rix = 0
	local riy = 0
	local angle_increment = 0
	if player_circular_placement[player_count].ring_1 > 0 then
		angle_increment = 360/player_circular_placement[player_count].ring_1
		for i=1,player_circular_placement[player_count].ring_1 do
			rix, riy = vectorFromAngle(angle,player_circular_placement[player_count].radius*.25)
			rix = terrain_center_x + rix
			riy = terrain_center_y + riy
			local rot_choice = random(1,100)	--random object type choice
--			print(string.format("   i: %i, angle: %i, choice: %i",i,math.floor(angle),math.floor(rot_choice)))
			if rot_choice < 20 then
				Mine():setPosition(rix,riy):setDescriptions("An unusual object","A device with high explosives"):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			elseif rot_choice < 40 then
				--upgrade
				local upgrade_artifact = selectHungerUpgradeType()
				upgrade_artifact:setPosition(rix,riy):setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned)
				upgrade_artifact:setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			elseif rot_choice < 60 then
				--decoy
				Artifact():setPosition(rix,riy):setDescriptions("An unusual object","A pretty object"):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text]):setRadarSignatureInfo(signature.treasure.grav,signature.treasure.elec,signature.treasure.bio):setModel(model.decoy)
			elseif rot_choice < 80 then
				--asteroid
				Asteroid():setPosition(rix,riy)
			else
				--treasure
				local treasure = treasureAlpha()
				treasure:setPosition(rix,riy):setDescriptions(treasure_artifact_description[math.random(1,#treasure_artifact_description)].unscanned,treasure_artifact_description[math.random(1,#treasure_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			end
			angle = (angle + angle_increment) % 360
		end
	end
	if player_circular_placement[player_count].ring_2 > 0 then
		angle_increment = 360/player_circular_placement[player_count].ring_2
		for i=1,player_circular_placement[player_count].ring_2 do
			rix, riy = vectorFromAngle(angle,player_circular_placement[player_count].radius*.4)
			rix = terrain_center_x + rix
			riy = terrain_center_y + riy
			local rot_choice = random(1,100)	--random object type choice
			if rot_choice < 20 then
				Mine():setPosition(rix,riy):setDescriptions("An unusual object","A device with high explosives"):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			elseif rot_choice < 40 then
				--upgrade
				local upgrade_artifact = selectHungerUpgradeType()
				upgrade_artifact:setPosition(rix,riy):setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned)
				upgrade_artifact:setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			elseif rot_choice < 60 then
				--decoy
				Artifact():setPosition(rix,riy):setDescriptions("An unusual object","A pretty object"):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text]):setRadarSignatureInfo(signature.treasure.grav,signature.treasure.elec,signature.treasure.bio):setModel(model.decoy)
			elseif rot_choice < 80 then
				--asteroid
				Asteroid():setPosition(rix,riy)
			else
				--treasure
				local treasure = treasureAlpha()
				treasure:setPosition(rix,riy):setDescriptions(treasure_artifact_description[math.random(1,#treasure_artifact_description)].unscanned,treasure_artifact_description[math.random(1,#treasure_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			end
			angle = (angle + angle_increment) % 360
		end
	end
	if player_circular_placement[player_count].ring_3 > 0 then
		angle_increment = 360/player_circular_placement[player_count].ring_3
		for i=1,player_circular_placement[player_count].ring_3 do
			rix, riy = vectorFromAngle(angle,player_circular_placement[player_count].radius*.65)
			rix = terrain_center_x + rix
			riy = terrain_center_y + riy
			local rot_choice = random(1,100)	--random object type choice
			if rot_choice < 20 then
				Mine():setPosition(rix,riy):setDescriptions("An unusual object","A device with high explosives"):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			elseif rot_choice < 40 then
				--upgrade
				local upgrade_artifact = selectHungerUpgradeType()
				upgrade_artifact:setPosition(rix,riy):setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned)
				upgrade_artifact:setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			elseif rot_choice < 60 then
				--decoy
				Artifact():setPosition(rix,riy):setDescriptions("An unusual object","A pretty object"):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text]):setRadarSignatureInfo(signature.treasure.grav,signature.treasure.elec,signature.treasure.bio):setModel(model.decoy)
			elseif rot_choice < 80 then
				--asteroid
				Asteroid():setPosition(rix,riy)
			else
				--treasure
				local treasure = treasureAlpha()
				treasure:setPosition(rix,riy):setDescriptions(treasure_artifact_description[math.random(1,#treasure_artifact_description)].unscanned,treasure_artifact_description[math.random(1,#treasure_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			end
			angle = (angle + angle_increment) % 360
		end
	end
	ring_spawn_timer_interval = 120
	ring_spawn_timer = ring_spawn_timer_interval
	ringSpawn(player_circular_placement[player_count].radius*.8,1,true)
	if player_circular_placement[player_count].ring_4 > 0 then
		angle_increment = 360/player_circular_placement[player_count].ring_4
		for i=1,player_circular_placement[player_count].ring_4 do
			rix, riy = vectorFromAngle(angle,player_circular_placement[player_count].radius*1.5)
			rix = terrain_center_x + rix
			riy = terrain_center_y + riy
			local rot_choice = random(1,100)	--random object type choice
			if rot_choice < 20 then
				Mine():setPosition(rix,riy):setDescriptions("An unusual object","A device with high explosives"):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			elseif rot_choice < 40 then
				--upgrade
				local upgrade_artifact = selectHungerUpgradeType()
				upgrade_artifact:setPosition(rix,riy):setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned)
				upgrade_artifact:setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			elseif rot_choice < 60 then
				--decoy
				Artifact():setPosition(rix,riy):setDescriptions("An unusual object","A pretty object"):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text]):setRadarSignatureInfo(signature.treasure.grav,signature.treasure.elec,signature.treasure.bio):setModel(model.decoy)
			elseif rot_choice < 80 then
				--asteroid
				Asteroid():setPosition(rix,riy)
			else
				--treasure
				local treasure = treasureAlpha()
				treasure:setPosition(rix,riy):setDescriptions(treasure_artifact_description[math.random(1,#treasure_artifact_description)].unscanned,treasure_artifact_description[math.random(1,#treasure_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			end
			angle = (angle + angle_increment) % 360
		end
	end
	if player_circular_placement[player_count].ring_5 > 0 then
		angle_increment = 360/player_circular_placement[player_count].ring_5
		for i=1,player_circular_placement[player_count].ring_5 do
			rix, riy = vectorFromAngle(angle,player_circular_placement[player_count].radius*2)
			rix = terrain_center_x + rix
			riy = terrain_center_y + riy
			local rot_choice = random(1,100)	--random object type choice
			if rot_choice < 20 then
				Mine():setPosition(rix,riy):setDescriptions("An unusual object","A device with high explosives"):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			elseif rot_choice < 40 then
				--upgrade
				local upgrade_artifact = selectHungerUpgradeType()
				upgrade_artifact:setPosition(rix,riy):setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned)
				upgrade_artifact:setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			elseif rot_choice < 60 then
				--decoy
				Artifact():setPosition(rix,riy):setDescriptions("An unusual object","A pretty object"):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text]):setRadarSignatureInfo(signature.treasure.grav,signature.treasure.elec,signature.treasure.bio):setModel(model.decoy)
			elseif rot_choice < 80 then
				--asteroid
				Asteroid():setPosition(rix,riy)
			else
				--treasure
				local treasure = treasureAlpha()
				treasure:setPosition(rix,riy):setDescriptions(treasure_artifact_description[math.random(1,#treasure_artifact_description)].unscanned,treasure_artifact_description[math.random(1,#treasure_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			end
			angle = (angle + angle_increment) % 360
		end
	end
	if player_circular_placement[player_count].ring_6 > 0 then
		angle_increment = 360/player_circular_placement[player_count].ring_6
		for i=1,player_circular_placement[player_count].ring_6 do
			rix, riy = vectorFromAngle(angle,player_circular_placement[player_count].radius*2.5)
			rix = terrain_center_x + rix
			riy = terrain_center_y + riy
			local rot_choice = random(1,100)	--random object type choice
			if rot_choice < 20 then
				Mine():setPosition(rix,riy):setDescriptions("An unusual object","A device with high explosives"):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			elseif rot_choice < 40 then
				--upgrade
				local upgrade_artifact = selectHungerUpgradeType()
				upgrade_artifact:setPosition(rix,riy):setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned)
				upgrade_artifact:setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			elseif rot_choice < 60 then
				--decoy
				Artifact():setPosition(rix,riy):setDescriptions("An unusual object","A pretty object"):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text]):setRadarSignatureInfo(signature.treasure.grav,signature.treasure.elec,signature.treasure.bio):setModel(model.decoy)
			elseif rot_choice < 80 then
				--asteroid
				Asteroid():setPosition(rix,riy)
			else
				--treasure
				local treasure = treasureAlpha()
				treasure:setPosition(rix,riy):setDescriptions(treasure_artifact_description[math.random(1,#treasure_artifact_description)].unscanned,treasure_artifact_description[math.random(1,#treasure_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			end
			angle = (angle + angle_increment) % 360
		end
	end
	placeRandomAroundPoint(Nebula,math.random(hunger_nebula_min,hunger_nebula_max),1,player_circular_placement[player_count].radius*2.5,terrain_center_x,terrain_center_y)
end
function buildHungerAnitsocialTreasure(delta)
	local angle = random(0,360)
	local angle_increment = 360/player_count
	for i=1,player_count do
		local rix, riy = vectorFromAngle(angle,random(80000,100000))
		local treasure = treasureAntisocial(terrain_center_x + rix,terrain_center_y + riy)
		treasure:setDescriptions(treasure_artifact_description[math.random(1,#treasure_artifact_description)].unscanned,treasure_artifact_description[math.random(1,#treasure_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
		angle = angle + angle_increment
	end
end
function buildOuterElements(delta)
	shuffled_stations = {}
	for group, list in pairs(station_pool) do
		if group ~= "Sinister" then
			for station, details in pairs(list) do
				table.insert(shuffled_stations,{station,details})
			end
		end
	end
	local station_index = math.random(1,#shuffled_stations)
	local selected_station = shuffled_stations[station_index][1]
	local station_details = shuffled_stations[station_index][2]
	table.remove(shuffled_stations,station_index)
	primaryStation = SpaceStation():setTemplate("Huge Station"):setPosition(terrain_center_x,terrain_center_y):setCommsScript(""):setCommsFunction(commsStation):setFaction("Human Navy")
	primaryStation:setCallSign(selected_station):setDescription(station_details.description)
	primaryStation.comms_data = {
		friendlyness = 80,
		weapons = 			{Homing = "neutral",	HVLI = "neutral", 	Mine = "neutral",	Nuke = "neutral", 	EMP = "neutral"},
		weapon_available = 	{Homing = true,			HVLI = true,		Mine = true,		Nuke = true,		EMP = true},
		service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
		reputation_cost_multipliers = {friend = 1.0, neutral = math.random(1,4)},
		max_weapon_refill_amount = {friend = 1.0, neutral = random(.2,.8)},
		goods = {},
		trade = {food = false, medicine = false, luxury = false},
		general_information = station_details.general,
		history = station_details.history,
	}
--	world:addMigratoryPrimaryStation(primaryStation,terrain_center_x,terrain_center_y,0,130000,completion_difficulty)
	broadcast_messages["Collected"] = {
		long_text = string.format("You have collected all the treasures. You now need to dock with %s",primaryStation:getCallSign()),
		short_text = string.format("Collected Treasures. Dock with %s",primaryStation:getCallSign()),
		count = 0,
		trigger = collectHungerTreasures
	}
end
function selectHungerUpgradeType()
	if hunger_upgrade_type_list == nil or #hunger_upgrade_type_list < 1 then
		hunger_upgrade_type_list = {}
		table.insert(hunger_upgrade_type_list,upgradeBeamDamageArtifact)
		table.insert(hunger_upgrade_type_list,upgradeBeamRangeArtifact)
		table.insert(hunger_upgrade_type_list,upgradeBeamCycleArtifact)
		table.insert(hunger_upgrade_type_list,upgradeBeamHeatArtifact)
		table.insert(hunger_upgrade_type_list,upgradeAuxTubeArtifact)
		table.insert(hunger_upgrade_type_list,upgradeMoreMissilesArtifact)
	end
	local upgrade_index = math.random(1,#hunger_upgrade_type_list)
	local upgrade_artifact = hunger_upgrade_type_list[upgrade_index]()
	table.remove(hunger_upgrade_type_list,upgrade_index)
	upgrade_artifact:setDescriptions("An unusual object","A valuable upgrade")
	return upgrade_artifact
end
--	Ongoing  --
function collectAntisocial(p)
	if p.antisocial ~= nil then
		return true
	end
	return false
end
function hungerInnerRingSpawnCheck(delta)
	ring_spawn_timer = ring_spawn_timer - delta
	if ring_spawn_timer < 0 then
		if ring_enemy_list ~= nil then
			local ship_count = 0
			for index, list in ipairs(ring_enemy_list) do
				for _, ship in pairs(list) do
					if ship ~= nil and ship:isValid() then
						ship_count = ship_count + 1
					end
				end
			end
			if ship_count < player_count/10 then
				ringSpawn(player_circular_placement[player_count].radius*.8,1,true)
			end
		else
			ringSpawn(player_circular_placement[player_count].radius*.8,1,true)
		end
		ring_spawn_timer = delta + ring_spawn_timer_interval + random(0,20)
	end
end
function collectHungerTreasures(p)
	if collectAlpha(p) and collectAntisocial(p) then
		return true
	end
	return false
end
------------------------------------
--	Explorer variation functions  --
------------------------------------
--	Explorer variation summary:
--		Collect jump or warp treasure
--			not strictly required, but obvious penalties if omitted
--		Collect alpha type treasure
--			Scan of artifact reveals whether it is a treasure or not
--		Collect foxtrot type treasure
--			Find treasure, scan it, report readings to primary station
--		Collect shy type treasure
--			Treasure will evade if not approached appropriately
--		Dock with primary station
--			Centrally located primary station
--	Set up  --
function setExplorerConstants()
	player_template = "Atlantis"
	players_on_teams = true
	initialPlayerShipAdjustments = explorerPlayerShipAdjustments
	station_priority = {}
	table.insert(station_priority,"Pop Sci Fi")
	table.insert(station_priority,"Spec Sci Fi")
	table.insert(station_priority,"Science")
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
	postPauseBuild1 = buildExplorerRings
	postPauseBuild2 = buildExplorerPlanetarySystem
	postPauseBuild3 = buildExplorerShyPlanetarySystem
	broadcast_messages = {
		["Introduction"] = {
			long_text = "Welcome to the Treasure Race\n\nBe the first to gather up three treasures\n\nA number of anomalies have been discovered and observerd in the area. We'll call them treasures. They turn out to have potentially powerful properties. Unfortunately, the information about these treasures has become public and now several ships are all looking for these treasures. We gave you the best ships we could find, but they don't have faster than light engines. There are lots of upgrades nearby including faster engines. You should look for the engine upgrades. The first treasure can also be found nearby. Fame, glory, respect and promotion will go to the first space ship that can get these treasures. Good luck.",
			short_text = "Be the first to gather and return three treasures",
			count = 0,
		},
		["Inner Treasure Collected"] = {	--redefined when building explorer rings with name of primary station
			long_text = "You picked up one of the treasures! Based on the data you transmitted on this treasure, we think that another treasure may be in one of the planetary systems nearby. We need the treasure or readings on the treasure. Oh, before I forget, our analysis of the treasure you just picked up indicates that it reacts badly in proximity to other treasures of the same type. We advise you not to pick up another one near your primary station",
			short_text = "You got a treasure. Pick up or get readings on the others.",
			count = 0,
			trigger = collectAlpha,
		},
	}
	collection_criteria = {
		alpha = {check = collectAlpha, name = "Collect alpha"},
		foxtrot = {check = collectFoxtrot, name = "Collect foxtrot"},
		shy = {check = collectShy, name = "Collect shy"},
	}
	completion_criteria = {
		dock = {check = dockWithPrimary, name = "Dock with primary"},
	}
	player_max_distance_from_center = 0
	general_variation_updates = {
		explorerRingSpawnCheck,
	}
end
function placeExplorerPlayerShips()
	local angle = random(0,360)
	local psx = 0
	local psy = 0
	for pidx=1,player_count do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			psx, psy = vectorFromAngle(angle,15000)
			psx = terrain_center_x + psx
			psy = terrain_center_y + psy
			p:setPosition(psx,psy)
			local tra = angle + 180
			if tra > 360 then
				tra = tra - 360
			end
			p:commandTargetRotation(tra)
			local ha = angle + 270
			if ha > 360 then 
				ha = ha - 360
			end
			p:setHeading(ha)
			p.start_x = psx
			p.start_y = psy
			angle = angle + player_circular_placement[player_count].angle_increment
			if angle > 360 then
				angle = angle - 360
			end
			player_restart.add(p.pidx,nil,nil,p.start_x,p.start_y)
		end
	end
end
function buildExplorerRings(delta)
	station_list = {}
	player_station_list = {}
	independent_station_list = {}
	enemy_station_list = {}
	local selected_group, selected_station, number_of_stations = selectRandomStation()
	local station_details = station_pool[selected_group][selected_station]
	primaryStation = SpaceStation():setTemplate("Huge Station"):setPosition(terrain_center_x,terrain_center_y):setCommsScript(""):setCommsFunction(commsStation):setFaction("Independent")
	primaryStation:setCallSign(selected_station):setDescription(station_details.description)
	primaryStation.comms_data = {
		friendlyness = 80,
		weapons = 			{Homing = "neutral",	HVLI = "neutral", 	Mine = "neutral",	Nuke = "neutral", 	EMP = "neutral"},
		weapon_available = 	{Homing = true,			HVLI = true,		Mine = true,		Nuke = true,		EMP = true},
		service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
		reputation_cost_multipliers = {friend = 1.0, neutral = math.random(1,4)},
		max_weapon_refill_amount = {friend = 1.0, neutral = random(.2,.8)},
		goods = {},
		trade = {food = false, medicine = false, luxury = false},
		general_information = station_details.general,
		history = station_details.history,
	}
	for _, good in pairs(station_details.goods) do
		if good == "food" then
			primaryStation.comms_data.goods[good] = {quantity = math.random(5,10), cost = 1}
		elseif good == "medicine" then
			primaryStation.comms_data.goods[good] = {quantity = math.random(5,10), cost = 5}
		elseif good == "luxury" then
			primaryStation.comms_data.goods[good] = {quantity = math.random(5,10), cost = math.random(25,50)}
		else
			primaryStation.comms_data.goods[good] = {quantity = math.random(5,10), cost = math.random(50,120)}
		end
	end
	station_pool[selected_group][selected_station] = nil	--remove station from list
	table.insert(station_list,primaryStation)
	table.insert(independent_station_list,primaryStation)
	table.insert(player_station_list,primaryStation)
	broadcast_messages["Collected"] = {
		long_text = string.format("You have collected all the treasures. You now need to dock with %s in sector %s",primaryStation:getCallSign(),primaryStation:getSectorName()),
		short_text = string.format("Collected Treasures. Dock with %s in %s",primaryStation:getCallSign(),primaryStation:getSectorName()),
		count = 0,
		trigger = collectExplorerTreasures,
	}						 
	broadcast_messages["Inner Treasure Collected"] = {
		long_text = string.format("You picked up one of the treasures! Based on the data you transmitted on this treasure, we think that another treasure may be in one of the planetary systems nearby. We need the treasure or readings on the treasure. Oh, before I forget, our analysis of the treasure you just picked up indicates that it reacts badly in proximity to other treasures of the same type. We advise you not to pick up another one near %s",primaryStation:getCallSign()),
		short_text = "You got a treasure. Pick up or get readings on the others.",
		count = 0,
		trigger = collectAlpha,
	}
	local angle = random(0,360)
	local rix = 0
	local riy = 0
	local angle_increment = 0
	local ftl_upgrade_count = player_count
	local max_stations = 50
	local rot_choice = 0
	local asteroid = nil
	local asteroid_size = 120
	local faction_deck = {}
	local selected_faction = nil
	local ring_number = {
		{player_circular_placement[player_count].ring_1, radius = 4000,  asteroid =  5, station = 10, treasure = 15, upgrade = 85, mine = 90, decoy = 95},
		{player_circular_placement[player_count].ring_2, radius = 6000,  asteroid = 10, station = 20, treasure = 30, upgrade = 70, mine = 80, decoy = 90},
		{player_circular_placement[player_count].ring_3, radius = 8000,  asteroid = 10, station = 20, treasure = 30, upgrade = 70, mine = 80, decoy = 90},
		{player_circular_placement[player_count].ring_4, radius = 10000, asteroid = 15, station = 35, treasure = 40, upgrade = 55, mine = 70, decoy = 85},
		{player_circular_placement[player_count].ring_5, radius = 12000, asteroid = 25, station = 45, treasure = 50, upgrade = 60, mine = 70, decoy = 80},
	}
	for ring_index=1,#ring_number do
		local circle_slots = ring_number[ring_index][1]
		if circle_slots > 0 then
			angle_increment = 360/circle_slots
			for i=1,circle_slots do
				rix, riy = vectorFromAngle(angle,ring_number[ring_index].radius)
				rix = terrain_center_x + rix
				riy = terrain_center_y + riy
				rot_choice = random(1,100)
				if rot_choice <= ring_number[ring_index].asteroid then
					asteroid = Asteroid():setPosition(rix,riy)
					asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
					asteroid:setSize(asteroid_size)
				elseif rot_choice <= ring_number[ring_index].station then
					if max_stations > 0 then
						drawStation(rix,riy,faction_deck)
						max_stations = max_stations - 1
					else
						asteroid = Asteroid():setPosition(rix,riy)
						asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
						asteroid:setSize(asteroid_size)
					end
				elseif rot_choice <= ring_number[ring_index].treasure then
					local treasure = treasureAlpha("move damage")
					treasure:setPosition(rix,riy):setDescriptions(treasure_artifact_description[math.random(1,#treasure_artifact_description)].unscanned,treasure_artifact_description[math.random(1,#treasure_artifact_description)].scanned):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
				elseif rot_choice <= ring_number[ring_index].upgrade then
					local upgrade_artifact = nil
					if ftl_upgrade_count > 0 then
						if random(1,100) < 50 then
							upgrade_artifact = upgradeJumpArtifact():setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,"Jump drive upgrade")
						else
							upgrade_artifact = upgradeWarpArtifact():setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,"Warp drive upgrade")
						end
						ftl_upgrade_count = ftl_upgrade_count - 1
					else
						upgrade_artifact = selectArtifactUpgradeType()
						upgrade_artifact:setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned)
					end
					upgrade_artifact:setPosition(rix,riy)
					upgrade_artifact:setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
				elseif rot_choice <= ring_number[ring_index].mine then
					Mine():setPosition(rix,riy):setDescriptions("An unusual object","A device with high explosives"):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
				elseif rot_choice <= ring_number[ring_index].decoy then
					if decoy_enabled == "Yes" then
						Artifact():setPosition(rix,riy):setDescriptions("An unusual object","A pretty object"):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text]):setRadarSignatureInfo(signature.treasure.grav,signature.treasure.elec,signature.treasure.bio):setModel(model.decoy)
					else
						asteroid = Asteroid():setPosition(rix,riy)
						asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
						asteroid:setSize(asteroid_size)
					end
				else
					drawSupply(rix,riy,faction_deck)
				end
				angle = (angle + angle_increment) % 360
			end
		end
	end
	placeRandomAroundPoint(Nebula,math.random(10,20),1,ring_number[#ring_number].radius*4,terrain_center_x,terrain_center_y)
end
function buildExplorerPlanetarySystem(delta)
	vespucci_angle = random(0,360)
	local vespucci_distance = 100000
	star_vespucci_x, star_vespucci_y = vectorFromAngle(vespucci_angle,vespucci_distance)
	star_vespucci_x = terrain_center_x + star_vespucci_x
	star_vespucci_y = terrain_center_y + star_vespucci_y
	star_vespucci = Planet():setPosition(star_vespucci_x,star_vespucci_y):setPlanetRadius(1000):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,1.0)
	local vespucci_names = {
		"Vespucci",
		"Alpha Centauri",
		"Vega",
		"Sirius",
	}
	star_vespucci:setCallSign(vespucci_names[math.random(1,#vespucci_names)])
	--vespucci barricade data points
	vb_x = (terrain_center_x + star_vespucci_x)/2
	vb_y = (terrain_center_y + star_vespucci_y)/2
--	print(string.format("vb x: %.1f, vb y: %.1f",vb_x,vb_y))
	vb_patrol_angle = (vespucci_angle + 180) % 360
	vb_extend_left_angle = (vb_patrol_angle + 270) % 360
	vb_extend_right_angle = (vb_patrol_angle + 90) % 360
	vb_patrol_x, vb_patrol_y = vectorFromAngle(vb_patrol_angle,vespucci_distance)
	vb_patrol_x = vb_x + vb_patrol_x
	vb_patrol_y = vb_y + vb_patrol_y
	vb_slot_count = 0
	-- innermost planet (Primus) --
	local primus_orbit = random(8000,20000)
	local primus_angle = random(0,360)
	local primus_x, primus_y = vectorFromAngle(primus_angle,primus_orbit)
	local primus_radius = random(800,1200)
	planet_vespucci_primus = Planet():setPosition(star_vespucci_x+primus_x,star_vespucci_y+primus_y):setPlanetRadius(primus_radius):setAxialRotationTime(random(200,250)):setDistanceFromMovementPlane(-primus_radius/2)
	planet_vespucci_primus:setPlanetSurfaceTexture("planets/planet-2.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,0.1)
	local vespucci_primus_names = {
		"Hoth",
		"Dagobah",
		"Alderaan",
		"Dantooine",
		"Rigel",
		"Pahvo",
		"Penthara",
		"Scalos",
		"Tanuga",
		"Vacca",
		"Terlina",
		"Timor",
	}
	planet_vespucci_primus:setCallSign(vespucci_primus_names[math.random(1,#vespucci_primus_names)])
	planet_vespucci_primus.orbit_speed = random(600,900) - difficulty*100
	planet_vespucci_primus:setOrbit(star_vespucci,planet_vespucci_primus.orbit_speed)
	planet_vespucci_primus.orbit = primus_orbit
	planet_vespucci_primus.radius = primus_radius
	broadcast_messages["Flotsam Treasure Collected"] = {
		long_text = string.format("You provided readings on the treasure near %s hiding amidst the rest of the flotsam orbiting %s.",star_vespucci:getCallSign(),planet_vespucci_primus:getCallSign()),
		short_text = string.format("Treasure near %s completed",star_vespucci:getCallSign()),
		count = 0,
		trigger = collectFoxtrot,
	}
	local treasure_count = 0
	local upgrade_count = 0
	local angle = random(0,360)
	local cx = 0
	local cy = 0
	local primus_orbit_time = 180
	local faction_deck = {}
	local function establishPrimusAsteroid(flotsam_radius,primus_orbit_time,angle,primus_x,primus_y)
		local cx, cy = vectorFromAngle(angle,flotsam_radius)
		local asteroid = Asteroid():setPosition(primus_x+cx,primus_x+cy)
		local asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
		asteroid:setSize(asteroid_size)
		world:addOrbitTargetUpdate(asteroid,planet_vespucci_primus,flotsam_radius,primus_orbit_time,angle)
	end
	repeat
		local flotsam_choice = random(1,100)
		local flotsam_radius = random(primus_radius*2,primus_radius*2 + 2000 + (70 * player_count)) 
		if flotsam_choice <= 50 then
			establishPrimusAsteroid(flotsam_radius,primus_orbit_time,angle,primus_x,primus_y)
		elseif flotsam_choice <= 60 then
			if vespucci_treasure == nil then
				vespucci_treasure = treasureFoxtrot()
				vespucci_treasure:setPosition(primus_x+cx,primus_x+cy)
				world:addOrbitTargetUpdate(vespucci_treasure,planet_vespucci_primus,flotsam_radius,primus_orbit_time,angle)
				foxtrot_treasure = vespucci_treasure
				treasure_count = treasure_count + 1
			else
				establishPrimusAsteroid(flotsam_radius,primus_orbit_time,angle,primus_x,primus_y)
			end
		elseif flotsam_choice <= 70 then
			local upgrade_artifact = selectArtifactUpgradeType()
			upgrade_artifact:setDescriptions(upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].unscanned,upgrade_artifact_description[math.random(1,#upgrade_artifact_description)].scanned)
			upgrade_artifact:setPosition(primus_x+cx,primus_x+cy)
			upgrade_artifact:setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			world:addOrbitTargetUpdate(upgrade_artifact,planet_vespucci_primus,flotsam_radius,primus_orbit_time,angle)
			upgrade_count = upgrade_count + 1
		elseif flotsam_choice <= 80 then
			local supply = drawSupply(primus_x+cx,primus_x+cy,faction_deck)
			world:addOrbitTargetUpdate(supply,planet_vespucci_primus,flotsam_radius,primus_orbit_time,angle)
		elseif flotsam_choice <= 90 then
			local mine = Mine():setPosition(primus_x+cx,primus_x+cy):setDescriptions("An unusual object","A device with high explosives"):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
			world:addOrbitTargetUpdate(mine,planet_vespucci_primus,flotsam_radius,primus_orbit_time,angle)
		else
			if decoy_enabled == "Yes" then
				local decoy = Artifact():setPosition(primus_x+cx,primus_x+cy):setDescriptions("An unusual object","A pretty object"):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text]):setRadarSignatureInfo(signature.treasure.grav,signature.treasure.elec,signature.treasure.bio):setModel(model.decoy)
				world:addOrbitTargetUpdate(decoy,planet_vespucci_primus,flotsam_radius,primus_orbit_time,angle)
			else
				establishPrimusAsteroid(flotsam_radius,primus_orbit_time,angle,primus_x,primus_y)
			end
		end
		angle = (angle + random(1,3)) % 360
	until(upgrade_count >= player_count and treasure_count > 0 and #faction_deck/player_count == 0)
	placeRandomAroundPoint(Nebula,math.random(5,10),1,primus_orbit*2.5,star_vespucci_x, star_vespucci_y)
--[[	test code
	for i=1,5 do
		local oa = Asteroid()
--		addOrbitUpdate = function(self, obj, center_x, center_y, distance, orbit_time, initial_angle)
--		world:addOrbitUpdate(oa,star_vespucci_x,star_vespucci_y,4000,20,i*10)
--		addOrbitTargetUpdate = function (self, obj, orbit_target, distance, orbit_time, initial_angle)
		world:addOrbitTargetUpdate(oa,planet_vespucci_primus,planet_vespucci_primus.radius*2,30,i*10)
	end
--]]
end
function buildExplorerShyPlanetarySystem(delta)
	star_sacagawea_x, star_sacagawea_y = vectorFromAngle((vespucci_angle + random(120,240)) % 360,150000)
	star_sacagawea_x = terrain_center_x + star_sacagawea_x
	star_sacagawea_y = terrain_center_y + star_sacagawea_y
	star_sacagawea = Planet():setPosition(star_sacagawea_x,star_sacagawea_y):setPlanetRadius(1000):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,0.6)
	local sacagawea_names = {
		"Sacagawea",
		"Cygnus",
		"Scorpius",
		"Taurus",
	}
	star_sacagawea:setCallSign(sacagawea_names[math.random(1,#sacagawea_names)])
	-- innermost planet (Primus) --
	local primus_orbit = random(25000,50000)
	local primus_angle = random(0,360)
	local primus_x, primus_y = vectorFromAngle(primus_angle,primus_orbit)
	local primus_radius = random(3000,8000)
	planet_sacagawea_primus = Planet():setPosition(star_sacagawea_x+primus_x,star_sacagawea_y+primus_y):setPlanetRadius(primus_radius):setAxialRotationTime(random(200,250)):setDistanceFromMovementPlane(-primus_radius/2)
	planet_sacagawea_primus:setPlanetSurfaceTexture("planets/gas-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,0.1)
	local sacagawea_primus_names = {
		"Bespin",
		"Camus",
		"Mariposa",
		"Endor",
		"Kazzkark",
		"Priam",
		"Heinlein",
		"Polarfrey",
		"Taloraan",
	}
	planet_sacagawea_primus:setCallSign(sacagawea_primus_names[math.random(1,#sacagawea_primus_names)])
	planet_sacagawea_primus.orbit_speed = random(600,900)
	planet_sacagawea_primus:setOrbit(star_sacagawea,planet_sacagawea_primus.orbit_speed)
	planet_sacagawea_primus.orbit = primus_orbit
	planet_sacagawea_primus.radius = primus_radius
	broadcast_messages["Shy Treasure Collected"] = {
		long_text = string.format("You successfully collected the treasure near %s.",star_sacagawea:getCallSign()),
		short_text = string.format("Treasure near %s collected",star_sacagawea:getCallSign()),
		count = 0,
		trigger = collectShy,
	}
--	local upgrade_count = 0	--maybe scatter these among the asteroids later
--	local faction_deck = {}
	local function establishSacagaweaAsteroid(angle,inner_radius,outer_radius,orbit_time)
		local radius = random(inner_radius,outer_radius)
		local cx, cy = vectorFromAngle(angle,radius)
		local asteroid = Asteroid():setPosition(star_sacagawea_x+cx,star_sacagawea_y+cy)
		local asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
		asteroid:setSize(asteroid_size)
		--world:addOrbitTargetUpdate(asteroid,star_sacagawea,radius,orbit_time,angle)
		world:addOrbitUpdate(asteroid,star_sacagawea_x,star_sacagawea_y,radius,orbit_time,angle)
	end
	local orbit_time = planet_sacagawea_primus.orbit_speed - random(50,100)
	for i=1,50 do
		establishSacagaweaAsteroid(random(0,360),primus_orbit - primus_radius - 400 - 1000,primus_orbit - primus_radius - 400,orbit_time)
	end
	orbit_time = orbit_time - random(50,100)
	for i=1,50 do
		establishSacagaweaAsteroid(random(0,360),primus_orbit - primus_radius - 400 - 2400,primus_orbit - primus_radius - 400 - 1400,orbit_time)
	end
	orbit_time = planet_sacagawea_primus.orbit_speed + random(50,100)
	for i=1,50 do
		establishSacagaweaAsteroid(random(0,360),primus_orbit + primus_radius + 400,primus_orbit + primus_radius + 400 + 1000,orbit_time)
	end
	orbit_time = orbit_time + random(50,100)
	for i=1,50 do
		establishSacagaweaAsteroid(random(0,360),primus_orbit + primus_radius + 400 + 1400,primus_orbit + primus_radius + 400 + 2400,orbit_time)
	end
	local angle = random(0,360)
	local angle_increment = 360/player_count
	for i=1,player_count do
		local treasure = treasureShy()
		local tx, ty = vectorFromAngle(angle,random(1500,primus_orbit - primus_radius - 400 - 3000))
		treasure:setPosition(star_sacagawea_x+tx,star_sacagawea_y+ty)
		angle = (angle + angle_increment) % 360
	end
	placeRandomAroundPoint(Nebula,math.random(5,10),1,primus_orbit*1.5,star_sacagawea_x,star_sacagawea_y)
end
function drawSupply(x,y,faction_deck)
	local supply = SupplyDrop():setPosition(x,y)
	local supply_label = ""
	local supply_details = ""
	if random(1,100) <= 10 then
		supply:setWeaponStorage("HVLI",2)
		supply_label = supply_label .. " L2"
		supply_details = supply_details .. "2 HVLI\n"
	end
	if random(1,100) <= 9 then
		supply:setWeaponStorage("Homing",2)
		supply_label = supply_label .. " H2"
		supply_details = supply_details .. "2 Homing\n"
	end
	if random(1,100) <= 8 then
		supply:setWeaponStorage("Mine",2)
		supply_label = supply_label .. " M2"
		supply_details = supply_details .. "2 Mine\n"
	end
	if random(1,100) <= 7 then
		supply:setWeaponStorage("EMP",2)
		supply_label = supply_label .. " E2"
		supply_details = supply_details .. "2 EMP\n"
	end
	if random(1,100) <= 6 then
		supply:setWeaponStorage("Nuke",2)
		supply_label = supply_label .. " N2"
		supply_details = supply_details .. "2 Nuke\n"
	end
	if random(1,100) <= 5 then
		supply.coolant = 1
		supply_label = supply_label .. " C1"
		supply_details = supply_details .. "Coolant\n"
	end
	if random(1,100) <= 4 then
		supply.repair_crew = 1
		supply_label = supply_label .. " R1"
		supply_details = supply_details .. "Repair Bot\n"
	end
	if supply_label == "" then
		local energy = math.random(3,8)
		supply_label = supply_label .. "B" .. energy
		supply_details = supply_details .. energy*100 .. " Energy\n"
		supply:setEnergy(energy*100)
	end
	supply:setDescriptions(supply_label,supply_details):setScanningParameters(scan_complexity[difficulty_text],scan_depth[difficulty_text])
	supply:onPickUp(function(self, player)
		string.format("")	--necessary to have global reference for Serious Proton engine
		if self.repair_crew ~= nil then
			player:setRepairCrewCount(player:getRepairCrewCount() + self.repair_crew)
		end
		if self.coolant ~= nil then
			player:setMaxCoolant(player:getMaxCoolant() + self.coolant)
		end
	end)
	if #faction_deck < 1 then
		faction_deck = replenishFactionDeck()
	end
	supply:setFaction(drawFaction(faction_deck))
	return supply
end
function drawStation(x,y,faction_deck)
	local selected_group, selected_station, number_of_stations = selectRandomStation()
	local station_details = station_pool[selected_group][selected_station]
	local station = SpaceStation():setTemplate("Small Station"):setPosition(x,y):setCommsScript(""):setCommsFunction(commsStation)
	local faction_choice = random(1,100)
	if faction_choice <= 9 then
		if #faction_deck < 1 then
			faction_deck = replenishFactionDeck()
		end
		station:setFaction(drawFaction(faction_deck))
	elseif faction_choice >= 91 then
		station:setFaction("Exuari")
		local station_selection_list = {}
		for station, details in pairs(station_pool["Sinister"]) do
			table.insert(station_selection_list,station)
		end
		if #station_selection_list > 0 then
			selected_station = station_selection_list[math.random(1,#station_selection_list)]
			selected_group = "Sinister"
			station_details = station_pool[selected_group][selected_station]
		else
			station:setFaction("Independent")				
		end
	else
		station:setFaction("Independent")
	end
	station:setCallSign(selected_station):setDescription(station_details.description)
	station.comms_data = {
		friendlyness = random(1,100),
		weapons = 			{Homing = "neutral",		HVLI = "neutral", 		Mine = "neutral",		Nuke = "neutral", 		EMP = "neutral"},
		weapon_available = 	{Homing = random(1,10)<=8,	HVLI = random(1,10)<=9,	Mine = random(1,10)<=7,	Nuke = random(1,10)<=5,	EMP = random(1,10)<=6},
		service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
		reputation_cost_multipliers = {friend = 1.0, neutral = random(1,4)},
		max_weapon_refill_amount = {friend = 1.0, neutral = random(.2,.8)},
		goods = {},
		trade = {food = random(1,10)<=(5-difficulty), medicine = random(1,10)<=(5-difficulty), luxury = random(1,10)<=(5-difficulty)},
		general_information = station_details.general,
		history = station_details.history,
	}
	for _, good in pairs(station_details.goods) do
		if good == "food" then
			station.comms_data.goods[good] = {quantity = math.random(5,10), cost = 1}
		elseif good == "medicine" then
			station.comms_data.goods[good] = {quantity = math.random(5,10), cost = 5}
		elseif good == "luxury" then
			station.comms_data.goods[good] = {quantity = math.random(5,10), cost = math.random(25,50)}
		else
			station.comms_data.goods[good] = {quantity = math.random(5,10), cost = math.random(50,120)}
		end
	end
	station_pool[selected_group][selected_station] = nil	--remove station from list
	if station:getFaction() == "Exuari" then
		table.insert(enemy_station_list,station)
	else
		table.insert(station_list,station)
		if station:getFaction() == "Independent" then
			table.insert(independent_station_list,station)
		else
			table.insert(player_station_list,station)
		end
	end
end
function drawFaction(deck)
	local faction_index = math.random(1,#deck)
	local faction = deck[faction_index]
	table.remove(deck,faction_index)
	return faction
end
function replenishFactionDeck()
	local deck = {}
	for _, faction in ipairs(player_teams[player_count].faction_list) do
		table.insert(deck,faction)
	end
	return deck
end
function explorerPlayerShipAdjustments(p)
	local new_player_template = "Explorer"
	p:setTypeName(new_player_template)
	p.ship_score = player_ship_stats[new_player_template].strength
	p.max_cargo = player_ship_stats[new_player_template].cargo
	p:setLongRangeRadarRange(player_ship_stats[new_player_template].long_range_radar)
	p.normal_long_range_radar = player_ship_stats[new_player_template].long_range_radar
	p:setShortRangeRadarRange(player_ship_stats[new_player_template].short_range_radar)
	p:setWarpDrive(false)
	p:setJumpDrive(false)
	p:setRotationMaxSpeed(8)
	p:setImpulseMaxSpeed(60)
	p:setScanProbeCount(4)
--						Arc, Dir, Range, CycleTime, Dmg
	p:setBeamWeapon(0,  10, -20,  1000,         6, 6)
	p:setBeamWeapon(1,  10,  20,  1000,         6, 6)
--							 Arc, Dir, Rotate speed
	p:setBeamWeaponTurret(0,  60, -20, .2)
	p:setBeamWeaponTurret(1,  60,  20, .2)
	p:setWeaponTubeCount(2)
	p:setWeaponTubeDirection(1, 90)
	p:setWeaponTubeExclusiveFor(0,"HVLI")
	p:setWeaponTubeExclusiveFor(1,"HVLI")
	p:setWeaponStorageMax("HVLI",10)
	p:setWeaponStorage("HVLI", 10)				
	p:setWeaponStorageMax("Homing",0)
	p:setWeaponStorage("Homing", 0)				
	p:setWeaponStorageMax("Mine",0)
	p:setWeaponStorage("Mine", 0)				
	p:setWeaponStorageMax("EMP",0)
	p:setWeaponStorage("EMP", 0)				
	p:setWeaponStorageMax("Nuke",0)
	p:setWeaponStorage("Nuke", 0)				
end
--	Ongoing  --
function collectExplorerTreasures(p)
	if collectAlpha(p) and collectFoxtrot(p) and collectShy(p) then
		return true
	end
	return false
end
function collectAlpha(p)
	--currently used by the Explorer and Hunger variations, but it could be used by other variations
	if p.alpha ~= nil then
		if game_variation == "Hunger" then
			if hunger_primary_station_stopped then
				hunger_primary_station_stopped = false
				world:addMigratoryPrimaryStation(primaryStation,terrain_center_x,terrain_center_y,0,130000,completion_difficulty)
				for pidx=1,player_count do
					local mp = getPlayerShip(pidx)
					if mp ~= nil and mp:isValid() then
						mp:addToShipLog(string.format("[%s] Intelligence indicates that Exuari plan to attack. They've got some kind of jump technology that lets them send ships to a remote destination without installing a jump drive on the ship. As a protective counter measure, we are initiating continuous evasive jump protocol around the perimeter",primaryStation:getCallSign()),"Magenta")
					end
				end
			end
		end
		return true
	end
	return false
end
function shyJump(treasure,approach_angle,approach_distance)
	local ctx, cty = treasure:getPosition()
	if random(1,100) < 50 then
		approach_angle = (approach_angle + 90) % 360
	else
		approach_angle = (approach_angle + 270) % 360
	end
	local vx, vy = vectorFromAngle(approach_angle,approach_distance+1500)
	treasure:setPosition(ctx+vx,cty+vy)
	local increment = allowed_angle_variance + 1
	local slots = 360/increment -1
	treasure.approach_angle = math.random(0,slots)*increment
	local unscanned_description = treasure:getDescription("unscanned")
	if difficulty ~= 1 then
		unscanned_description = "An unusual skittish object with velocity approach sensors"
	end
	treasure:setDescriptions(unscanned_description,string.format("An object with a polycarbonate protrusion now pointing in direction %i",treasure.approach_angle))
	treasure:setScanned(false)
end
function collectShy(p)
	if shy_treasure_list ~= nil then
		for index, treasure in ipairs(shy_treasure_list) do
			if distance_diagnostic then
				print("function collectShy(p)")
				if p == nil then
					print("   p is nil")
				else
					print("   " .. p:getCallSign())
				end
			end
			local approach_distance = distance(treasure,p)
			if approach_distance < 1000 then
				local tx, ty = treasure:getPosition()
				local px, py = p:getPosition()
				local approach_angle = angleFromVectorNorth(px,py,tx,ty) 
				if difficulty ~= 1 then
					local vx, vy = p:getVelocity()
					local player_velocity = math.abs(vx) + math.abs(vy)
					print(string.format("Velocity: %.1f",player_velocity))
					if player_velocity > max_approach_velocity then
						shyJump(treasure,approach_angle,approach_distance)
						break
					end
				end
				if difficulty >= 1 then
					print(string.format("Angle: treasure: %.1f, %s: %.1f",treasure.approach_angle,p:getCallSign(),approach_angle))
					local greater_threshold = treasure.approach_angle + allowed_angle_variance
					local lesser_threshold = treasure.approach_angle - allowed_angle_variance
					if treasure.approach_angle > 0 then
						if approach_angle >= greater_threshold then
							shyJump(treasure,approach_angle,approach_distance)
							break
						end
						if approach_angle <= lesser_threshold then
							shyJump(treasure,approach_angle,approach_distance)
							break
						end
					else
						if approach_angle <= (360 - allowed_angle_variance) and approach_angle >= allowed_angle_variance then
							shyJump(treasure,approach_angle,approach_distance)
							break
						end
					end
					--[[
					if treasure.approach_angle > 0 then
						if approach_angle >= greater_threshold then
							shyJump(treasure,approach_angle,approach_distance)
							break
						end
						local lesser_threshold
						
						if approach_angle <= (treasure.approach_angle - 4) or approach_angle >= (treasure.approach_angle + 4) then
							shyJump(treasure,approach_angle,approach_distance)
							break
						end
					else
						if approach_angle <= 356 and approach_angle >= 4 then
							shyJump(treasure,approach_angle,approach_distance)
							break
						end
					end
					--]]
				end
			end
		end
	end
	if p.shy ~= nil then
		return true
	end
	return false
end
function collectFoxtrot(p)
	if p.foxtrot ~= nil then
		return true
	end
	return false
end
function dockWithPrimary(p)
	--currently used by the Explorer variation, but it could be used by other variations
	if primaryStation ~= nil then
		if primaryStation:isValid() then
			if p:isDocked(primaryStation) then
				return true
			end
		else
			globalMessage("Primary station destroyed")
			game_state = "victory Exuari"
			gatherStats(true)
			victory("Exuari")
		end
	else
		globalMessage("Primary station destroyed")
		game_state = "victory Exuari"
		gatherStats(true)
		victory("Exuari")
	end
	return false
end
function explorerRingSpawnCheck(delta)
	if ring_spawn_timer == nil then
		ring_spawn_timer_interval = 60	--final:60
		ring_spawn_timer = delta + ring_spawn_timer_interval + random(0,10)
		ring_spawn_danger_interval = .25
		ring_spawn_danger = 1.5
	end
	ring_spawn_timer = ring_spawn_timer - delta
	if ring_spawn_timer < 0 then
		if ring_enemy_list ~= nil then
			if player_max_distance_from_center <= 15000 then
				local ship_count = 0
				for index, list in ipairs(ring_enemy_list) do
					for _, ship in pairs(list) do
						if ship ~= nil and ship:isValid() then
							ship_count = ship_count + 1
						end
					end
				end
				if ship_count < player_count/4 then
					ringSpawn(18000,ring_spawn_danger)
					ring_spawn_danger = ring_spawn_danger + ring_spawn_danger_interval
				end
			end
		else
			ringSpawn(18000,ring_spawn_danger)
			ring_spawn_danger = ring_spawn_danger + ring_spawn_danger_interval
		end
		ring_spawn_timer = delta + ring_spawn_timer_interval + random(0,10)
	end
end
function addToVespucciBarricade()
	local enemy_list = spawnEnemies(vb_x,vb_y)
	for i=1,#enemy_list do
		local ship = enemy_list[i]
		local patrol_points = {}
		if vb_slot_count == 0 then
			ship:setPosition(vb_x, vb_y)
			ship:orderFlyTowards(vb_patrol_x,vb_patrol_y)
			patrol_points = {
				{x = vb_x, y = vb_y},
				{x = vb_patrol_x, y = vb_patrol_y},
			}
		else
			local ex = 0
			local ey = 0
			local extend_distance = math.ceil(vb_slot_count/2)*1000
			if vb_slot_count % 2 == 0 then
				ex, ey = vectorFromAngle(vb_extend_left_angle,extend_distance)
			else
				ex, ey = vectorFromAngle(vb_extend_right_angle,extend_distance)
			end
			ship:setPosition(vb_x + ex, vb_y + ey)
			ship:orderFlyTowards(vb_patrol_x + ex, vb_patrol_y + ey)
			patrol_points = {
				{x = vb_x + ex, y = vb_y + ey},
				{x = vb_patrol_x + ex, y = vb_patrol_y + ey},
			}
		end
		world:addPatrol(ship, patrol_points, 2, 5)
		vb_slot_count = vb_slot_count + 1
		if vb_slot_count > 21 then
			vb_slot_count = 0
		end
	end
end
-- **************************** --
--	Enemy management functions  --
-- **************************** --
function personalInterest()
end
function incidentalInterest()
end
function personalAmbush()
end
function vectorOn(p,danger,radius,angle,list)
	if p == nil then
		return
	end
	if danger == nil then
		danger = 1
	end
	if radius == nil then
		radius = p:getLongRangeRadarRange()
	end
	if angle == nil then
		angle = random(0,360)
	end
	local enemy_list = {}
	local vx, vy = vectorFromAngle(angle,radius)
	local px, py = p:getPosition()
	if list == nil then
		print("danger in vectorOn: " .. danger)
		enemy_list = spawnEnemies(px+vx,py+vy,danger,"Exuari",nil,nil,"none")
	else
		enemy_list = replicate(list)
	end
	local pyramid_tier = math.min(#enemy_list,9)
	for index, ship in ipairs(enemy_list) do
		if index <= 9 then
			local pyramid_angle = angle + formation_delta.pyramid[pyramid_tier][index].angle
			if pyramid_angle < 0 then 
				pyramid_angle = pyramid_angle + 360
			end
			pyramid_angle = pyramid_angle % 360
			rx, ry = vectorFromAngle(pyramid_angle,radius + formation_delta.pyramid[pyramid_tier][index].distance * 800)
			ship:setPosition(px+rx,py+ry)
		else
			ship:setPosition(px+vx,py+vy)
		end
		ship:setHeading((angle + 270) % 360)
		ship:orderFlyTowards(px,py)
	end
	return enemy_list
end
function ringSpawn(radius,danger,inner)
	if danger == nil then
		danger = 1
	end
	if inner == nil then
		inner = false
	end
	ring_enemy_list = {}
	local angle = random(0,360)
	local angle_increment = 360/player_count
	local enemy_list = {}
	for i=1,player_count do
		local rx, ry = vectorFromAngle(angle,radius)
		if #ring_enemy_list < 1 then
			enemy_list = spawnEnemies(terrain_center_x+rx,terrain_center_y+ry,danger,"Exuari",nil,nil,"none")
		else
			enemy_list = replicate(enemy_list)
		end
		local pyramid_tier = math.min(#enemy_list,9)
		for index, ship in ipairs(enemy_list) do
			if index <= 9 then
				local pyramid_angle = angle + formation_delta.pyramid[pyramid_tier][index].angle
				if pyramid_angle < 0 then 
					pyramid_angle = pyramid_angle + 360
				end
				pyramid_angle = pyramid_angle % 360
				if inner then
					rx, ry = vectorFromAngle(pyramid_angle,radius - formation_delta.pyramid[pyramid_tier][index].distance * 800)
				else
					rx, ry = vectorFromAngle(pyramid_angle,radius + formation_delta.pyramid[pyramid_tier][index].distance * 800)
				end
				ship:setPosition(terrain_center_x+rx,terrain_center_y+ry)
				if inner then
					ship:setHeading((angle + 90) % 360)
				else
					ship:setHeading((angle + 270) % 360)
				end
			end
		end
		table.insert(ring_enemy_list,enemy_list)
		angle = angle + angle_increment
	end
	ring_enemy_list.total_ships = player_count * #enemy_list
end
function replicate(list)
	local replicated_list = {}
	for index, ship in ipairs(list) do
		local template = ship:getTypeName()
		local faction = ship:getFaction()
		cloned_ship = ship_template[template].create(faction,template)
		cloned_ship:setCommsScript(""):setCommsFunction(commsShip)
		cloned_ship:setCallSign(generateCallSign(nil,faction))
		table.insert(replicated_list,cloned_ship)
	end
	return replicated_list
end
function spawnEnemies(origin_x, origin_y, danger, faction, strength, pool_size, shape)
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
	if danger == nil then 
		danger = 1
	end
	if faction == nil then
		faction = "Exuari"
	end
--	print("danger in spawnEnemies: " .. danger)
	if strength == nil then
		local p = getPlayerShip(-1)
		local current_template = p:getTypeName()
		strength = math.max(danger * difficulty * player_ship_stats[current_template].strength,5)
		print(string.format("danger: %.1f, difficulty: %.1f, current template: %s, ship strength: %i, calculated strength: %.1f",danger,difficulty,current_template,player_ship_stats[current_template].strength,strength))
	end
	if pool_size == nil then
		pool_size = 5
	end
	if shape == nil then
		shape = "square"
		if random(1,100) < 50 then
			shape = "hexagonal"
		end
	end
--	print("shape: " .. shape)
	local enemy_position = 0
	local sp = irandom(500,1000)			--random spacing of spawned group
	local enemy_list = {}
	while strength > 0 do
		local template_pool = {}
		for _, current_ship_template in ipairs(ship_template_by_strength) do
			if ship_template[current_ship_template].strength <= strength then
				table.insert(template_pool,current_ship_template)
			end
			if #template_pool >= pool_size then
				break
			end
		end
		if #template_pool > 0 then
			local selected_template = template_pool[math.random(1,#template_pool)]
			local ship = ship_template[selected_template].create(faction,selected_template)
			enemy_position = enemy_position + 1
			if shape == "none" then
				ship:setPosition(origin_x,origin_y)
			else
				ship:setPosition(origin_x + formation_delta[shape].x[enemy_position] * sp, origin_y + formation_delta[shape].y[enemy_position] * sp)
			end
			ship:setCommsScript(""):setCommsFunction(commsShip)
			table.insert(enemy_list, ship)
			ship:setCallSign(generateCallSign(nil,faction))
			strength = strength - ship_template[selected_template].strength
		else
			break
		end
	end
	return enemy_list
end
--------------------------
--	Create Enemy Ships  --
--------------------------
function stockTemplate(enemyFaction,template)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate(template):orderRoaming()
	return ship
end
--	Non-standard ships
function adderMk3(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK4"):orderRoaming()
	ship:setTypeName("Adder MK3")
	ship:setHullMax(35)				--weaker hull (vs 40)
	ship:setHull(35)
	ship:setShieldsMax(15)			--weaker shield (vs 20)
	ship:setShields(15)
	ship:setRotationMaxSpeed(35)	--faster maneuver (vs 20)
	return ship
end
function adderMk7(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK6"):orderRoaming()
	ship:setTypeName("Adder MK7")
	ship:setShieldsMax(40)					--stronger shields (vs 30)
	ship:setShields(40)
	ship:setBeamWeapon(0,30,0,900,5.0,2.0)	--narrower (30 vs 35) but longer (900 vs 800) beam
	return ship
end
function adderMk8(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5"):orderRoaming()
	ship:setTypeName("Adder MK8")
	ship:setShieldsMax(50)					--stronger shields (vs 30)
	ship:setShields(50)
	ship:setBeamWeapon(0,30,0,900,5.0,2.3)	--narrower (30 vs 35) but longer (900 vs 800) and stronger (2.3 vs 2.0) beam
	ship:setRotationMaxSpeed(30)			--faster maneuver (vs 25)
	return ship
end
function adderMk9(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5"):orderRoaming()
	ship:setTypeName("Adder MK9")
	ship:setShieldsMax(50)					--stronger shields (vs 30)
	ship:setShields(50)
	ship:setBeamWeapon(0,30,0,900,4.5,2.5)	--narrower (30 vs 35) but longer (900 vs 800), faster (4.5 vs 5.0) and stronger (2.5 vs 2.0) beam
	ship:setRotationMaxSpeed(30)			--faster maneuver (vs 25)
	ship:setWeaponStorageMax("Nuke",2)		--more nukes (vs 0)
	ship:setWeaponStorage("Nuke",2)
	return ship
end
function atlantisY42(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Atlantis X23"):orderRoaming()
	ship:setTypeName("Atlantis Y42")
	ship:setImpulseMaxSpeed(65)									--faster impulse (vs 30)
	ship:setRotationMaxSpeed(15)								--faster maneuver (vs 3.5)
	ship:setShieldsMax(300,200,300,200)							--stronger shields (vs 200,200,200,200)
	ship:setShields(300,200,300,200)					
	ship:setWeaponStorageMax("Homing",16)						--more (vs 4)
	ship:setWeaponStorage("Homing", 16)		
	return ship		
end
function droneHeavy(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone"):orderRoaming()
	ship:setTypeName("Heavy Drone")
	ship:setHullMax(40)					--stronger hull (vs 30)
	ship:setHull(40)
	ship:setImpulseMaxSpeed(110)		--slower impulse (vs 120)
	ship:setBeamWeapon(0,40,0,600,4,8)	--stronger (vs 6) beam
	return ship
end
function droneJacket(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone"):orderRoaming()
	ship:setTypeName("Jacket Drone")
	ship:setShieldsMax(20)				--stronger shields (vs none)
	ship:setShields(20)
	ship:setImpulseMaxSpeed(110)		--slower impulse (vs 120)
	ship:setBeamWeapon(0,40,0,600,4,4)	--weaker (vs 6) beam
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
	return ship
end
function elaraP2(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:setTypeName("Elara P2")
	ship:setWarpDrive(true)			--warp drive (vs none)
	ship:setShieldsMax(70,40)		--stronger front shield (vs 50,40)
	ship:setShields(70,40)
	return ship
end
function enforcer(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Blockade Runner"):orderRoaming()
	ship:setTypeName("Enforcer")
	ship:setRadarTrace("ktlitan_destroyer.png")			--different radar trace
	ship:setWarpDrive(true)										--warp (vs none)
	ship:setWarpSpeed(600)
	ship:setImpulseMaxSpeed(100)								--faster impulse (vs 60)
	ship:setRotationMaxSpeed(20)								--faster maneuver (vs 15)
	ship:setShieldsMax(200,100,100)								--stronger shields (vs 100,150)
	ship:setShields(200,100,100)					
	ship:setHullMax(100)										--stronger hull (vs 70)
	ship:setHull(100)
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,	30,	  -15,	1500,		6,		10)	--narrower (vs 60), longer (vs 1000), stronger (vs 8)
	ship:setBeamWeapon(1,	30,	   15,	1500,		6,		10)
	ship:setBeamWeapon(2,	 0,	    0,	   0,		0,		 0)	--fewer (vs 4)
	ship:setBeamWeapon(3,	 0,	    0,	   0,		0,		 0)
	ship:setWeaponTubeCount(3)									--more (vs 0)
	ship:setWeaponTubeDirection(1,-30)				
	ship:setWeaponTubeDirection(2, 30)				
	ship:setWeaponStorageMax("Homing",18)						--more (vs 0)
	ship:setWeaponStorage("Homing", 18)		
	return ship		
end
function fiendG3(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Gunship"):orderRoaming()
	ship:setTypeName("Fiend G3")
	ship:setJumpDrive(true)
	ship:setJumpDriveRange(5000,35000)			
	return ship
end
function fiendG4(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Gunship"):orderRoaming()
	ship:setTypeName("Fiend G4")
	ship:setWarpDrive(true)
	return ship
end
function fiendG5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adv. Gunship"):orderRoaming()
	ship:setTypeName("Fiend G5")
	ship:setJumpDrive(true)
	ship:setJumpDriveRange(5000,35000)			
	return ship
end
function fiendG6(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adv. Gunship"):orderRoaming()
	ship:setTypeName("Fiend G6")
	ship:setWarpDrive(true)
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
	return ship
end
function hornetMV52(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("MT52 Hornet"):orderRoaming()
	ship:setTypeName("MV52 Hornet")
	ship:setBeamWeapon(0, 30, 0, 1000.0, 4.0, 4.0)	--longer and stronger beam (vs 700 & 3)
	ship:setRotationMaxSpeed(30)					--faster maneuver (vs 25)
	ship:setImpulseMaxSpeed(130)					--faster impulse (vs 120)
	return ship
end
function jade5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5"):orderRoaming()
	ship:setTypeName("Jade 5")
	ship:setJumpDrive(true)				--added jump drive
	ship:setJumpDriveRange(5000,35000)			
	return ship
end
function k2fighter(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Fighter"):orderRoaming()
	ship:setTypeName("K2 Fighter")
	ship:setBeamWeapon(0, 60, 0, 1200.0, 2.5, 6)	--beams cycle faster (vs 4.0)
	ship:setHullMax(65)								--weaker hull (vs 70)
	ship:setHull(65)
	return ship
end	
function k3fighter(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Fighter"):orderRoaming()
	ship:setTypeName("K3 Fighter")
	ship:setBeamWeapon(0, 60, 0, 1200.0, 2.5, 9)	--beams cycle faster and damage more (vs 4.0 & 6)
	ship:setHullMax(60)								--weaker hull (vs 70)
	ship:setHull(60)
	return ship
end	
function nirvanaR3(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Nirvana R5"):orderRoaming()
	ship:setTypeName("Nirvana R3")
	ship:setBeamWeapon(0, 90, -15, 1000.0, 3, 1)	--shorter beams (vs 1200)
	ship:setBeamWeapon(1, 90,  15, 1000.0, 3, 1)	--shorter beams
	ship:setBeamWeapon(2, 90, -50, 1000.0, 3, 1)	--shorter beams
	ship:setBeamWeapon(3, 90,  50, 1000.0, 3, 1)	--shorter beams
	ship:setHullMax(60)								--weaker hull (vs 70)
	ship:setHull(60)
	ship:setShields(40,30)							--weaker shields (vs 50,40)
	ship:setImpulseMaxSpeed(65)						--slower impulse (vs 70)
	return ship
end
function phobosR2(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:setTypeName("Phobos R2")
	ship:setWeaponTubeCount(1)			--one tube (vs 2)
	ship:setWeaponTubeDirection(0,0)	
	ship:setImpulseMaxSpeed(55)			--slower impulse (vs 60)
	ship:setRotationMaxSpeed(15)		--faster maneuver (vs 10)
	return ship
end
function predator(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Piranha F8"):orderRoaming()
	ship:setTypeName("Predator")
	ship:setRadarTrace("missile_cruiser.png")				--different radar trace
	ship:setJumpDrive(true)
	ship:setJumpDriveRange(5000,35000)			
	ship:setImpulseMaxSpeed(65)									--faster impulse (vs 40)
	ship:setRotationMaxSpeed(15)								--faster maneuver (vs 6)
	ship:setShieldsMax(100,100)									--stronger shields (vs 30,30)
	ship:setShields(100,100)					
	ship:setHullMax(80)											--stronger hull (vs 70)
	ship:setHull(80)
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
	return ship		
end
function stalkerQ5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Stalker Q7"):orderRoaming()
	ship:setTypeName("Stalker Q5")
	ship:setShieldsMax(50,50)		--weaker shields (vs 80,30,30,30)
	ship:setShields(50,50)
	ship:setHullMax(45)				--weaker hull (vs 50)
	ship:setHull(45)
	ship:setRotationMaxSpeed(15)	--faster maneuver (vs 12)
	return ship
end
function stalkerR5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Stalker R7"):orderRoaming()
	ship:setTypeName("Stalker R5")
	ship:setShieldsMax(50,50)		--weaker shields (vs 80,30,30,30)
	ship:setShields(50,50)
	ship:setHullMax(45)				--weaker hull (vs 50)
	ship:setHull(45)
	ship:setRotationMaxSpeed(15)	--faster maneuver (vs 12)
	return ship
end
function starhammerV(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Starhammer II"):orderRoaming()
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
	return ship		
end
function tempest(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Piranha F12"):orderRoaming()
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
	return ship
end
function tyr(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Battlestation"):orderRoaming()
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
	return ship
end
function waddle5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5"):orderRoaming()
	ship:setTypeName("Waddle 5")
	ship:setWarpDrive(true)				--added warp drive
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
	return ship
end
--	Generate call sign functions
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
	table.insert(human_names,"Hurricane")
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
	table.insert(human_names,"Tempest")
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
-- ************************* --
--	Communication functions  --
-- ************************* --
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
            preorder = "friend"
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
    if comms_source:isEnemy(comms_target) then
        return false
    end
--	if comms_target:areEnemiesInRange(5000) then
--		setCommsMessage("We are under attack! No time for chatting!");
--		return true
--	end
    if not comms_source:isDocked(comms_target) then
        handleUndockedState()
    else
        handleDockedState()
    end
    return true
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
	setCommsMessage(oMsg)
	if not comms_target:isEnemy(comms_source) then
		if ctd.got_sensor_upgrade == nil then
			ctd.got_sensor_upgrade = {}
		end
		if not ctd.got_sensor_upgrade[comms_source] then
			addCommsReply("Increase range of long range sensors",function()
				if comms_source.sensor_upgrade_rep_count == nil then
					comms_source.sensor_upgrade_rep_count = 1
				end
				setCommsMessage("We can increase the range of your ship's long range sensors by five units.\nHow would you like to increase the range of your ship's long range sensors?")
				addCommsReply(string.format("Spend %s reputation",comms_source.sensor_upgrade_rep_count*10),function()
				    if not comms_source:isDocked(comms_target) then 
						setCommsMessage("You need to stay docked for that action.")
					else
						if comms_source:takeReputationPoints(comms_source.sensor_upgrade_rep_count*10) then
							comms_source:setLongRangeRadarRange(comms_source:getLongRangeRadarRange() + 5000)
							comms_source.sensor_upgrade_rep_count = comms_source.sensor_upgrade_rep_count + 1
							setCommsMessage("The range of your long range sensors has been increased by five units")
							ctd.got_sensor_upgrade[comms_source] = true
						else
							setCommsMessage("Insufficient reputation")
						end
					end
				end)
				addCommsReply("Reduce battery capacity by 50",function()
				    if not comms_source:isDocked(comms_target) then 
						setCommsMessage("You need to stay docked for that action.")
					else
						if comms_source:getEnergyLevelMax() <= 100 then
							setCommsMessage("Insufficient spare battery capacity")
						else
							comms_source:setEnergyLevelMax(comms_source:getEnergyLevelMax() - 50)
							comms_source:setLongRangeRadarRange(comms_source:getLongRangeRadarRange() + 5000)
							ctd.got_sensor_upgrade[comms_source] = true
							setCommsMessage("The range of your long range sensors has been increased by five units")
						end
					end
				end)
				addCommsReply("Reduce maximum impulse speed by five percent",function()
				    if not comms_source:isDocked(comms_target) then 
						setCommsMessage("You need to stay docked for that action.")
					else
						local forward, reverse = comms_source:getImpulseMaxSpeed()
						comms_source:setImpulseMaxSpeed(forward*.95,reverse*.95)
						comms_source:setLongRangeRadarRange(comms_source:getLongRangeRadarRange() + 5000)
						ctd.got_sensor_upgrade[comms_source] = true
						setCommsMessage("The range of your long range sensors has been increased by five units")
					end
				end)
				addCommsReply("Back", commsStation)
			end)
		end
	end
	if collection_criteria.foxtrot ~= nil and foxtrot_treasure:isScannedBy(comms_source) then
		foxtrotReadings()
	end
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
				setCommsMessage("What type of ordnance?")
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
	if (ctd.general ~= nil and ctd.general ~= "") or (ctd.history ~= nil and ctd.history ~= "") then
		addCommsReply("Tell me more about your station", function()
			setCommsMessage("What would you like to know?")
			if ctd.general ~= nil and ctd.general ~= "" then
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
		end)
	end
	if mortal_repair_crew then
		if ctd.repair_crew_for_hire == nil then
			ctd.repair_crew_for_hire = math.random(2,5)
		end
		if p:getRepairCrewCount() < p.max_repair_crew then
			addCommsReply("Hire repair crew for ship", function()
				if ctd.repair_crew_for_hire > 0 then
					setCommsMessage(string.format("We have %i repair crew available",ctd.repair_crew_for_hire))
					local hire_cost = math.random(20,40)
					addCommsReply(string.format("Recruit repair crew member for %i reputation",hire_cost), function()
						if not comms_source:takeReputationPoints(hire_cost) then
							if comms_source.reputation > hire_cost then
								comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
								setCommsMessage("Repair crew member hired")
								ctd.repair_crew_for_hire = ctd.repair_crew_for_hire - 1
								comms_source.reputation = comms_source.reputation - hire_cost
							else
								setCommsMessage("Insufficient reputation")
							end
						else
							comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
							setCommsMessage("Repair crew member hired")
							ctd.repair_crew_for_hire = ctd.repair_crew_for_hire - 1
						end
						addCommsReply("Back", commsStation)
					end)
				else
					setCommsMessage("We have no repair crew available for hire")
				end
				addCommsReply("Back",commsStation)
			end)
		end
	end
	if coolant_may_leak then
		if ctd.coolant_stored == nil then
			ctd.coolant_stored = math.random(2,5)
		end
		if p:getMaxCoolant() < 10 then
			addCommsReply("Get coolant for ship", function()
				if ctd.coolant_stored > 0 then
					setCommsMessage(string.format("We have %i units of coolant available",ctd.coolant_stored))
					local coolant_cost = math.random(10,30)
					addCommsReply(string.format("Purchase coolant for %i reputation",coolant_cost), function()
						if not comms_source:takeReputationPoints(coolant_cost) then
							if comms_source.reputation > coolant_cost then
								comms_source:setMaxCoolant(comms_source:getMaxCoolant() + 1)
								setCommsMessage("Coolant purchased")
								ctd.coolant_stored = ctd.coolant_stored - 1
								comms_source.reputation = comms_source.reputation - coolant_cost
							else
								setCommsMessage("Insufficient reputation")
							end
						else
							comms_source:setMaxCoolant(comms_source:getMaxCoolant() + 1)
							setCommsMessage("Coolant purchased")
							ctd.coolant_stored = ctd.coolant_stored - 1
						end
						addCommsReply("Back", commsStation)
					end)
				else
					setCommsMessage("We have no coolant available")
				end
				addCommsReply("Back",commsStation)
			end)
		end
	end
	if ships_carry_cargo then
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
				if ctd.trade.food and comms_source.goods ~= nil and comms_source.goods.food ~= nil and comms_source.goods.food.quantity > 0 then
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
				if ctd.trade.medicine and comms_source.goods ~= nil and comms_source.goods.medicine ~= nil and comms_source.goods.medicine.quantity > 0 then
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
				if ctd.trade.luxury and comms_source.goods ~= nil and comms_source.goods.luxury ~= nil and comms_source.goods.luxury.quantity > 0 then
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
	end
end	--end of handleDockedState function
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
				if comms_source.reputation ~= nil then
					if comms_source.reputation > points_per_item * item_amount then
						comms_source.reputation = comms_source.reputation - points_per_item * item_amount
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
					setCommsMessage("Not enough reputation.")
					return
				end
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
				if comms_source.reputation ~= nil then
					if comms_source.reputation > points_per_item then
						setCommsMessage("You can't afford as much as I'd like to give you")
						addCommsReply("Get just one", function()
							if comms_source.reputation > points_per_item then
								comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + 1)
								comms_source.reputation = comms_source.reputation - points_per_item
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
				else
					setCommsMessage("Not enough reputation.")
					return		
				end		
			end
		end
        addCommsReply("Back", commsStation)
    end
end
function getWeaponCost(weapon)
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function foxtrotReadings()
	addCommsReply("Report treasure readings",function()
		setCommsMessage("Please provide electro-mechanical reading:")
		for electro_mechanical=0,9 do
			addCommsReply(electro_mechanical,function()
				setCommsMessage("Now we need the bio-neural reading:")
				for bio_neural=0,9 do
					addCommsReply(bio_neural,function()
						setCommsMessage("And what is the chorno-anomalous reading?")
						for chrono_anomalous=0,9 do
							addCommsReply(chrono_anomalous,function()
								if foxtrot_treasure.electro_mechanical == electro_mechanical and
									foxtrot_treasure.bio_neural == bio_neural and
									foxtrot_treasure.chrono_anomalous == chrono_anomalous then
									setCommsMessage("That's it!")
									comms_source.foxtrot = "provided"
								else
									setCommsMessage("That does not match our readings. Please double check") 
								end
								addCommsReply("Back",commsStation)
							end)
						end
						addCommsReply("Back",commsStation)
					end)
				end
				addCommsReply("Back",commsStation)
			end)
		end
		addCommsReply("Back",commsStation)
	end)
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
	if collection_criteria.foxtrot ~= nil and foxtrot_treasure:isScannedBy(comms_source) then
		foxtrotReadings()
	end
 	addCommsReply("I need information", function()
		setCommsMessage("What kind of information do you need?")
		if comms_target.migrate_timer ~= nil then	--migratory station in Hunger scenario
			if comms_source.alpha_count ~= nil and comms_source.alpha_count > 1 then
				addCommsReply("How many treasures do I need?",function()
					if comms_source.antisocial then
						setCommsMessage("You've got plenty of normal treasures and an antisocial treasure. You should dock with us and win this thing.")
					else
						setCommsMessage("You've got plenty of normal treasures. I'd start hunting for an antisocial treasure.")
						addCommsReply("What is an antisocial treasure?",function()
							setCommsMessage("It's a treasure that does not want to be picked up. It's got its own defense mechanism.")
							addCommsReply("Where can I find an antisocial treasure?",function()
								setCommsMessage("The last time I saw one was around the exterior of the arena. There's no guarantee that's where you can find one now. After all, it is antisocial.")
								addCommsReply("Back", commsStation)
							end)
							addCommsReply("Back", commsStation)
						end)
					end
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Why do you keep moving?",function()
				setCommsMessage("The Exuari plan to attack, so we are proactively evading them")
				addCommsReply("Can you please stop moving?",function()
					setCommsMessage("The technicians have automated the evasive mechanism. It's too dangerous to alter it with the Exuari attack forecast. However, we can disable the evasive mechanism when you get within 30 units so that you can dock. Be sure you dock quickly, though.")
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("How can we finish our mission with you moving?",function()
					setCommsMessage("You need to figure out where we're going next. Either that or wait at a current location. The pattern eventually repeats itself")
					addCommsReply("Can't you just tell me where you're moving next?",function()
						setCommsMessage("We have security protocols we must follow in case the Exuari are monitoring our communication. The Exuari may have trouble with pattern recognition and rapid calculation, but they have purchased language modules which they can use to monitor our communication. We can give you some hints, though.")
						addCommsReply("How often do you move?", function()
							if comms_target.difficulty > 1 then
								setCommsMessage(string.format("It varies between about every %i seconds, %i seconds and %i seconds",math.floor(comms_target.stationary_interval/2),comms_target.stationary_interval,comms_target.stationary_interval*2))
								addCommsReply("How long before your next move?",function()
									setCommsMessage(string.format("We'll move again in about %i seconds",math.floor(comms_target.migrate_timer)))
									addCommsReply("Back", commsStation)
								end)
							else
								setCommsMessage(string.format("We currently move about every %i seconds",comms_target.stationary_interval))
								addCommsReply("How long before your next move?",function()
									setCommsMessage(string.format("We'll move again in about %i seconds",math.floor(comms_target.migrate_timer)))
									addCommsReply("Back", commsStation)
								end)
							end
							addCommsReply("Back", commsStation)
						end)
						addCommsReply("How many different locations do you move to?",function()
							setCommsMessage("That depends on how many player ships are participating in the treasure race and how difficult the treasure race master has made the race.")
							addCommsReply("How exactly does it depend on number of player ships?",function()
								setCommsMessage("There are a certain number of directional angles from the center of the treasure formation along which we calculate our next position. That number of directional angles is calculated using the following algorithm:\n    if number of participating player ships is even,\n        the number of directional angles = the number of participating player ships\n    else\n        The number of directional andles = two times the number of participating player ships\nYou'll have to do the math yourself.")
								addCommsReply("How are the directional angles calculated?",function()
									setCommsMessage("The directional angles are spread equally around the perimeter of the treasure area.")
									addCommsReply("Back", commsStation)
								end)
								addCommsReply("Back", commsStation)
							end)
							addCommsReply("How exactly does the difficulty affect the number of locations?",function()
								setCommsMessage("When the difficulty is set at normal or hard, we alternate between a base distance and a base distance plus 20 units along the directional angle. The base distance depends on the current ring.")
								addCommsReply("What difficulty is the current treasure race?",function()
									local positional_difficulty = "normal"
									if comms_target.difficulty > 1 then
										positional_difficulty = "hard"
									elseif comms_target.difficulty < 1 then
										positional_difficulty = "easy"
									end
									setCommsMessage(string.format("For purposes of station moving, the difficulty is set to %s",positional_difficulty))
									addCommsReply("Back", commsStation)
								end)
								addCommsReply("Rings? What are those?",function()
									setCommsMessage(string.format("To minimize the risk of the Exuari figuring out our movement pattern, we gradually increase our base distance. We do this using a total of %i rings. Each ring is ten units farther out than the previous ring. Once we reach the outermost ring, we start over at the innermost ring.",comms_target.ring_max))
									addCommsReply("What ring are you currently on in your cycle?",function()
										setCommsMessage(string.format("We're on ring %i",comms_target.ring_count))
										addCommsReply("Back", commsStation)
									end)
									addCommsReply("Back", commsStation)
								end)
								addCommsReply("Back", commsStation)
							end)
						end)
						addCommsReply("How far are you from the center of the treasure formation?",function()
							local s_x, s_y = comms_target:getPosition()
							local current_distance = distance(s_x, s_y, comms_target.center_x, comms_target.center_y)
							setCommsMessage(string.format("We are approximately %.3f units away from the center of the treasure formation",current_distance/1000))
							addCommsReply("Back", commsStation)
						end)
						addCommsReply("Back", commsStation)
					end)
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Back", commsStation)
			end)
		end
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
		if ships_carry_cargo then
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
		end
		if (ctd.general ~= nil and ctd.general ~= "") or (ctd.history ~= nil and ctd.history ~= "") then
			addCommsReply("Tell me more about your station", function()
				setCommsMessage("What would you like to know?")
				if ctd.general ~= nil and ctd.general ~= "" then
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
			end)
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
						if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
							ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
							ship:setCommsScript(""):setCommsFunction(commsShip)
							--ship:setCallSign(generateCallSign(nil,"Human Navy"))
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
	if ships_carry_cargo then
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
	if ships_carry_cargo and shipType:find("Freighter") ~= nil then
		if distance(comms_source, comms_target) < 5000 then
			if shipCommsDiagnostic then print("close enough to trade or sell") end
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
				if shipCommsDiagnostic then print("friendliest branch") end
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					if shipCommsDiagnostic then print("goods or equipment freighter") end
					if comms_source.goods ~= nil and comms_source.goods.luxury ~= nil and comms_source.goods.luxury > 0 then
						if shipCommsDiagnostic then print("player has luxury to trade") end
						for good, goodData in pairs(comms_data.goods) do
							if shipCommsDiagnostic then print("in freighter goods loop") end
							if goodData.quantity > 0 and good ~= "luxury" then
								if shipCommsDiagnostic then print("has something other than luxury") end
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
					if shipCommsDiagnostic then print("player has room to purchase") end
					for good, goodData in pairs(comms_data.goods) do
						if shipCommsDiagnostic then print("in freighter goods loop") end
						if goodData.quantity > 0 then
							if shipCommsDiagnostic then print("found something to sell") end
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
				if shipCommsDiagnostic then print("average frienliness branch") end
				if comms_source.cargo > 0 then
					if shipCommsDiagnostic then print("player has room to purchase") end
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						if shipCommsDiagnostic then print("goods or equipment type freighter") end
						for good, goodData in pairs(comms_data.goods) do
							if shipCommsDiagnostic then print("in freighter cargo loop") end
							if goodData.quantity > 0 then
								if shipCommsDiagnostic then print("Found something to sell") end
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
						if shipCommsDiagnostic then print("not a goods or equipment freighter") end
						for good, goodData in pairs(comms_data.goods) do
							if shipCommsDiagnostic then print("in freighter cargo loop") end
							if goodData.quantity > 0 then
								if shipCommsDiagnostic then print("found something to sell") end
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
				if shipCommsDiagnostic then print("least friendly branch") end
				if comms_source.cargo > 0 then
					if shipCommsDiagnostic then print("player has room for purchase") end
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						if shipCommsDiagnostic then print("goods or equipment freighter") end
						for good, goodData in pairs(comms_data.goods) do
							if shipCommsDiagnostic then print("in freighter cargo loop") end
							if goodData.quantity > 0 then
								if shipCommsDiagnostic then print("found something to sell") end
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
					end
					if current_order == "Attack" or current_order == "Dock" or current_order == "Defend Target" then
						local original_target = comms_target:getOrderTarget()
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
					check_continuum = true
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
	for pidx=1,8 do
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
						p:addCustomInfo("Relay",p.continuum_timer_display,timer_display,9)
					end
					if p:hasPlayerAtPosition("Operations") then
						p.continuum_timer_display_ops = "continuum_timer_display_ops"
						p:addCustomInfo("Operations",p.continuum_timer_display_ops,timer_display,9)
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
	if shipType:find("Freighter") ~= nil and ships_carry_cargo then
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
-- ********************* --
--	GM Button functions  --
-- ********************* --
function setGMButtons()
	mainGMButtons = mainGMButtonsDuringPause
	mainGMButtons()
end
function mainGMButtonsAfterPause()
	clearGMFunctions()
	addGMFunction(string.format("Version %s",scenario_version),function()
		local version_message = string.format("Scenario version %s\n LUA version %s",scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	addGMFunction("Show control codes",function()
		local code_list = {}
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				code_list[p:getCallSign()] = p.control_code
			end
		end
		local sorted_names = {}
		for name in pairs(code_list) do
			table.insert(sorted_names,name)
		end
		table.sort(sorted_names)
		local output = ""
		for _, name in ipairs(sorted_names) do
			output = output .. string.format("%s: %s\n",name,code_list[name])
		end
		addGMMessage(output)
	end)
	addGMFunction(string.format("describe %s",game_variation),function()
		addGMMessage(variation_description[game_variation])
	end)
	addGMFunction("+Change Game Timer",changeGameTimer)
	addGMFunction("+Diagnostics",showDiagnostics)
	if game_variation == "Normal" then
		addGMFunction("+Clues",normalGMClues)
		addGMFunction("+Enemy Harassment",normalEnemyHarassment)
	end
	if game_variation == "Explorer" then
		addGMFunction("Player Progress",function()
			local progress_list = {}
			for pidx=1,player_count do
				local p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					progress_list[p:getCallSign()] = {inner_treasure = false, vespucci_treasure = false, sacagawea_treasure = false}
					if p.alpha == "move damage" then
						progress_list[p:getCallSign()].inner_treasure = true
					end
					if p.foxtrot == "provided" then
						progress_list[p:getCallSign()].vespucci_treasure = true
					end
					if p.shy == "retrieved" then
						progress_list[p:getCallSign()].sacagawea_treasure = true
					end
				end
			end
			local sorted_names = {}
			for name in pairs(progress_list) do
				table.insert(sorted_names,name)
			end
			table.sort(sorted_names)
			local output = ""
			for _, name in ipairs(sorted_names) do
				output = output .. string.format("%s:\n   Treasure near %s: %s\n   Treasure near %s: %s\n   Treasure near %s: %s\n",name,primaryStation:getCallSign(),tostring(progress_list[name].inner_treasure),planet_vespucci_primus:getCallSign(),tostring(progress_list[name].vespucci_treasure),star_sacagawea:getCallSign(),tostring(progress_list[name].sacagawea_treasure))
			end
			addGMMessage(output)
		end)
	end
end
function normalEnemyHarassment()
	clearGMFunctions()
	addGMFunction("-From Harassment",mainGMButtons)
	addGMFunction(string.format("%i+10=%i Seconds",harass_timer_interval,harass_timer_interval+10),function()
		harass_timer_interval = harass_timer_interval + 10
		if harass_timer_interval < 10 then
			harass_timer_interval = 10
			addGMMessage("Minimum is 10")
		end
		normalEnemyHarassment()
	end)
	addGMFunction(string.format("%i-10=%i Seconds",harass_timer_interval,harass_timer_interval-10),function()
		harass_timer_interval = harass_timer_interval - 10
		if harass_timer_interval > 900 then
			harass_timer_interval = 900
			addGMMessage("Maximum is 900")
		end
		normalEnemyHarassment()
	end)
	addGMFunction("Explain",function()
		addGMMessage("This is where you increase or decrease the number of seconds between each spawn of enemy ships that harass the players.")
		normalEnemyHarassment()
	end)
end
function normalGMClues()
	clearGMFunctions()
	addGMFunction("-Main from clues",mainGMButtons)
	addGMFunction("Treasures",function()
		local treasure_report = "Treasures located in these sectors:\n"
		local sorted_treasures = {}
		for _, treasure in pairs(treasure_list) do
			if treasure ~= nil and treasure:isValid() then
				table.insert(sorted_treasures,treasure:getSectorName())
			end
		end
		table.sort(sorted_treasures)
		for _, sector in ipairs(sorted_treasures) do
			treasure_report = treasure_report .. " " .. sector
		end
		addGMMessage(treasure_report)
	end)
	addGMFunction("Upgrade locations",function()
		local upgrade_report = "Upgrade locations and types:"
		local sorted_upgrades = {}
		for _, upgrade in pairs(upgrade_list) do
			if upgrade ~= nil and upgrade:isValid() then
				table.insert(sorted_upgrades,upgrade:getSectorName() .. " " .. upgrade.upgrade_type)
			end
		end
		table.sort(sorted_upgrades)
		for _, report_line in ipairs(sorted_upgrades) do
			upgrade_report = upgrade_report .. "\n" .. report_line
		end
		addGMMessage(upgrade_report)
	end)
	addGMFunction("Upgrade types",function()
		local upgrade_report = "Upgrade types and locations:"
		local sorted_upgrades = {}
		for _, upgrade in pairs(upgrade_list) do
			if upgrade ~= nil and upgrade:isValid() then
				table.insert(sorted_upgrades,upgrade.upgrade_type .. " " .. upgrade:getSectorName())
			end
		end
		table.sort(sorted_upgrades)
		for _, report_line in ipairs(sorted_upgrades) do
			upgrade_report = upgrade_report .. "\n" .. report_line
		end
		addGMMessage(upgrade_report)
	end)
	addGMFunction("Explain",function()
		addGMMessage("This is where the GM gathers information to give to one or more player ship if desired.\n\nTreasure: reports the sectors where mission completion treasures are located\nUpgrade locations and types: Lists the upgrade treasures (sector and type) sorted by sector\nUpgrade types and locations: Lists the upgrade treasures (type and sector) sorted by type")
	end)
end
function playerShipSelected()
	local p = getPlayerShip(-1)
	local object_list = getGMSelection()
	local selected_matches_player = false
	for i=1,#object_list do
		local current_selected_object = object_list[i]
		for pidx=1,32 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p == current_selected_object then
					selected_matches_player = true
					break
				end
			end
		end
		if selected_matches_player then
			break
		end
	end
	if selected_matches_player then
		return p
	end
	return nil
end
function changeGameTimer()
	clearGMFunctions()
	addGMFunction("-Main from timer",mainGMButtons)
	if game_length == game_time_limit then	--paused
		if game_length <= 60*60*2 then
			addGMFunction(string.format("%i + 5 = %i Minutes",game_length/60,(game_length + 300)/60),function()
				if game_length == game_time_limit then
					game_time_limit = game_time_limit + 300
					game_length = game_time_limit
				else
					addGMMessage("Game already started. No action taken")
				end
				changeGameTimer()
			end)
		end
		if game_length >= 300 then
			addGMFunction(string.format("%i - 5 = %i Minutes",game_length/60,(game_length - 300)/60),function()
				if game_length == game_time_limit then
					game_time_limit = game_time_limit - 300
					game_length = game_time_limit
				else
					addGMMessage("Game already started. No action taken")
				end
				changeGameTimer()
			end)
		end
		addGMFunction("Explain",function()
			addGMMessage("Change the overall game timer here. Once the game is unpaused, you may change the game timer in other ways.")
		end)
	else	--not paused
		addGMFunction("Add 1 second",function()
			local prev_timer_value = game_time_limit
			game_time_limit = game_time_limit + 1
			addGMMessage(string.format("Timer changed from %.1f to %.1f",prev_timer_value,game_time_limit))
			changeGameTimer()
		end)
		addGMFunction("Add 10 seconds",function()
			local prev_timer_value = game_time_limit
			game_time_limit = game_time_limit + 10
			addGMMessage(string.format("Timer changed from %.1f to %.1f",prev_timer_value,game_time_limit))
			changeGameTimer()
		end)
		addGMFunction("Del 1 second",function()
			local prev_timer_value = game_time_limit
			game_time_limit = game_time_limit - 1
			addGMMessage(string.format("Timer changed from %.1f to %.1f",prev_timer_value,game_time_limit))
			changeGameTimer()
		end)
		addGMFunction("Del 10 seconds",function()
			local prev_timer_value = game_time_limit
			game_time_limit = game_time_limit - 10
			addGMMessage(string.format("Timer changed from %.1f to %.1f",prev_timer_value,game_time_limit))
			changeGameTimer()
		end)
		local button_label = "Slow Down"
		if timer_fudge > 0 then
			button_label = string.format("%s %.3f",button_label,timer_fudge)
		end
		addGMFunction(button_label,function()
			timer_fudge = timer_fudge + .005
			changeGameTimer()
		end)
		addGMFunction("Normalize",function()
			timer_fudge = 0
			changeGameTimer()
		end)
		button_label = "Speed Up"
		if timer_fudge < 0 then
			button_label = string.format("%s %.3f",button_label,-timer_fudge)
		end
		addGMFunction(button_label,function()
			timer_fudge = timer_fudge - .005
			changeGameTimer()
		end)
		addGMFunction("Explain",function()
			addGMMessage("The Add and Del buttons add and delete one or 10 seconds from the game timer. You can make subtler changes using the speed up and slow down buttons. Use the normalize button to set the game time back to something close to reality after using the speed up and/or slow down buttons.")
		end)
	end
end
function showDiagnostics()
	clearGMFunctions()
	addGMFunction("-From Diagnostics",mainGMButtons)
	addGMFunction("Player Restart",function()
		local output = "Values in player_restart table:"
		for pidx, detail in pairs(player_restart) do
			if type(pidx) == "number" then
				output = output .. "\n   " .. pidx
				if detail["name"] ~= nil then
					output = output .. "   name:" .. detail["name"]
				end
				if detail.control_code ~= nil then
					output = output .. "   control_code:" .. detail.control_code
				end
				if detail.start_x ~= nil then
					output = string.format("%s   start_x:%.1f",output,detail.start_x)
				end
				if detail.start_y ~= nil then
					output = string.format("%s   start_y:%.1f",output,detail.start_y)
				end
				if detail.faction ~= nil then
					output = output .. "   faction:" .. detail.faction
				end
			end
		end
		addGMMessage(output)
	end)
	if game_variation == "Normal" then
		addGMFunction("Player treasures",function()
			local output = "Player treasure counts:"
			for i=1,player_count do
				local p = getPlayerShip(i)
				if p ~= nil and p:isValid() then
					output = output .. "\n" .. p:getCallSign() .. ": "
					if p.alpha_count ~= nil then
						output = output .. p.alpha_count
					else
						output = output .. "nil"
					end
				end
			end
			addGMMessage(output)
		end)
	end
end
----------------------------------------
--	GM Button Functions while paused  --
----------------------------------------
function mainGMButtonsDuringPause()
	clearGMFunctions()
	addGMFunction(string.format("Version %s",scenario_version),function()
		local version_message = string.format("Scenario version %s\n LUA version %s",scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	addGMFunction("Show control codes",function()
		local code_list = {}
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				code_list[p:getCallSign()] = p.control_code
			end
		end
		local sorted_names = {}
		for name in pairs(code_list) do
			table.insert(sorted_names,name)
		end
		table.sort(sorted_names)
		local output = ""
		for _, name in ipairs(sorted_names) do
			output = output .. string.format("%s: %s\n",name,code_list[name])
		end
		addGMMessage(output)
	end)
	addGMFunction(string.format("describe %s",game_variation),function()
		addGMMessage(variation_description[game_variation])
	end)
	addGMFunction("+Rename player ship",renamePlayerShip)
	addGMFunction("+Change Game Timer",changeGameTimer)
	addGMFunction("+Station Categories",stationCategories)
	addGMFunction("+Player Msg Buttons",setPlayerMessageButtons)
	if difficulty == nil then
		difficulty = 1
		difficulty_text = "normal"
	end
	addGMFunction(string.format("+Difficulty %s",difficulty_text),setDifficulty)
end
function setEngineeringDamage()
	clearGMFunctions()
	addGMFunction("-Main from Eng Dmg",setDifficulty)
	local repair_crew_state = "Immortal"
	if mortal_repair_crew then
		repair_crew_state = "Mortal"
	end
	addGMFunction(string.format("Repair Crew %s",repair_crew_state),function()
		if mortal_repair_crew then
			mortal_repair_crew = false
		else
			mortal_repair_crew = true
		end
		setEngineeringDamage()
	end)
	local coolant_leaks = "No"
	if coolant_may_leak then
		coolant_leaks = "Yes"
	end
	addGMFunction(string.format("Coolant Leaks: %s",coolant_leaks),function()
		if coolant_may_leak then
			coolant_may_leak = false
		else
			coolant_may_leak = true
		end
		setEngineeringDamage()
	end)
	addGMFunction("Explain",function()
		addGMMessage("Repair Crew Mortal/Immortal: This switches between whether or not damage to the player ship has the possibility to kill the repair crew in engineering or not.\nCoolant Leaks: true/false: This switches between whether or not damage to the player ship has the possibility to cause coolant in engineering to leak.")
	end)
end
function stationCategories()
	clearGMFunctions()
	addGMFunction("-Main from categories",mainGMButtons)
	addGMFunction("+Display Categories",displayStationCategories)
	addGMFunction("+Reorder Categories",reorderStationCategories)
end
function displayStationCategories()
	clearGMFunctions()
	addGMFunction("-Main from categories",mainGMButtons)
	addGMFunction("-From Display",stationCategories)
	if station_priority == nil then
		station_priority = {}
		for group, list in pairs(station_pool) do
			table.insert(station_priority,group)
		end
		table.sort(station_priority)
	end
	for _, group in ipairs(station_priority) do
		addGMFunction(group,function()
			local o_line = ""
			for station, details in pairs(station_pool[group]) do
				o_line = o_line .. station
				if details.goods ~= nil then
					o_line = o_line .. "   goods: "
					for _, good in pairs(details.goods) do
						o_line = o_line .. good .. " "
					end
				end
				o_line = o_line .. "   Description: " .. details.description
				o_line = o_line .. "\n   General: " .. details.general
				o_line = o_line .. "\n   History: " .. details.history .. "\n\n"
			end
			addGMMessage(o_line)
		end)
	end
	addGMFunction("Explain",function()
		addGMMessage("Station names are randomly selected from categories. Each of these category buttons list the stations in that category giving a little bit of information about each one. Use 'Reorder Categories' to change the random selection priority of the station categories")
	end)
end
function reorderStationCategories()
	clearGMFunctions()
	addGMFunction("-Main from categories",mainGMButtons)
	addGMFunction("-From Reorder",stationCategories)
	if station_priority == nil then
		station_priority = {}
		for group, list in pairs(station_pool) do
			table.insert(station_priority,group)
		end
		table.sort(station_priority)
	end
	for index, group in ipairs(station_priority) do
		addGMFunction(group,function()
			table.remove(station_priority,index)
			table.insert(station_priority,1,group)
			reorderStationCategories()
		end)
	end
	addGMFunction("Explain",function()
		addGMMessage("Change the priority order of the station categories here. Whichever category you select moves to the top of the priority list. Use 'Display Categories' to see what stations are in each category.")
	end)
end
function setDifficulty()
	clearGMFunctions()
	addGMFunction("-Main from Difficulty",mainGMButtons)
	addGMFunction("+General",setGeneralDifficulty)
	addGMFunction("+Engineering Damage",setEngineeringDamage)
	if game_variation == "Normal" or game_variation == "Explorer" then
		if decoy_enabled == nil then
			decoy_enabled = "Yes"
		end
		addGMFunction(string.format("Decoys %s",decoy_enabled),function()
			if decoy_enabled == "Yes" then
				decoy_enabled = "No"
				addGMMessage("Decoy treasures (treasures with no intrinsic game play value) have been disabled")
			else
				decoy_enabled = "Yes"
				addGMMessage("Decoy treasures (treasures with no intrinsic game play value) have been enabled")
			end
			setDifficulty()
		end)
	end
	if game_variation == "Hunger" then
		if completion_difficulty == nil then
			completion_difficulty = 1
			completion_difficulty_text = "normal"
		end
		addGMFunction(string.format("+End Difficulty %s",completion_difficulty_text),setCompletionDifficulty)
		addGMFunction(string.format("+Nebula %i-%i",hunger_nebula_min,hunger_nebula_max),setNebula)
	end
	if game_variation == "Explorer" then
		addGMFunction(string.format("+Shy variance: %i",allowed_angle_variance*2),setShyVariance)
	end
end
function setNebula()
	clearGMFunctions()
	addGMFunction("-Main from Nebula",mainGMButtons)
	addGMFunction("-Difficulty",setDifficulty)
	if hunger_nebula_min >= 5 then
		addGMFunction(string.format("Min %i + 1 = %i",hunger_nebula_min,hunger_nebula_min + 1),function()
			if hunger_nebula_min + 1 >= hunger_nebula_max then
				addGMMessage("Don't try to make the minimum number of nebula exceed the maximum number of nebula. No action taken.")
			else
				hunger_nebula_min = hunger_nebula_min + 1
			end
			setNebula()
		end)
		addGMFunction(string.format("Min %i - 1 = %i",hunger_nebula_min,hunger_nebula_min - 1),function()
			if hunger_nebula_min - 1 < 5 then
				addGMMessage("You're only allowed to reduce the minimum number of nebula to 5. No action taken.")
			else
				hunger_nebula_min = hunger_nebula_min - 1
			end
			setNebula()
		end)
	end
	if hunger_nebula_max <= 50 then
		addGMFunction(string.format("Max %i + 1 = %i",hunger_nebula_max,hunger_nebula_max + 1),function()
			if hunger_nebula_max + 1 > 50 then
				addGMMessage("You're only allowed to raise the maximum number of nebula to 50. No action taken.")
			else
				hunger_nebula_max = hunger_nebula_max + 1
			end
			setNebula()
		end)
		addGMFunction(string.format("Max %i - 1 = %i",hunger_nebula_max,hunger_nebula_max - 1),function()
			if hunger_nebula_max - 1 <= hunger_nebula_min then
				addGMMessage("Don't try to make the maximum number of nebula lower than the minimum number of nebula. No action taken.")
			else
				hunger_nebula_max = hunger_nebula_max - 1
			end
			setNebula()
		end)
	end
	addGMFunction("Explain",function()
		addGMMessage("As part of the terrain generation, the Hunger scenario spreads nebula randomly around the treasure gathering area. This is where you can configure the minimum number and the maximum number of nebula that appear. The more nebula, the harder the scenario.")
	end)
end
function setShyVariance()
	clearGMFunctions()
	addGMFunction("-Main from Shy",mainGMButtons)
	addGMFunction("-Difficulty",setDifficulty)
	if allowed_angle_variance < shy_config[#shy_config] then
		addGMFunction(string.format("%i Next Angle Var",allowed_angle_variance*2),function()
			for i=1,#shy_config do
				if shy_config[i] == allowed_angle_variance then
					allowed_angle_variance = shy_config[i+1]
					break
				end
			end
			setShyVariance()
		end)
	end
	if allowed_angle_variance > shy_config[1] then
		addGMFunction(string.format("%i Prev Angle Var",allowed_angle_variance*2),function()
			for i=1,#shy_config do
				if shy_config[i] == allowed_angle_variance then
					allowed_angle_variance = shy_config[i-1]
					break
				end
			end
			setShyVariance()
		end)
	end
	if difficulty ~= 1 then
		if max_approach_velocity < 5 then
			addGMFunction(string.format("%i Next Velocity Var",max_approach_velocity),function()
				max_approach_velocity = max_approach_velocity + 1
				setShyVariance()
			end)
		end
		if max_approach_velocity > 1 then
			addGMFunction(string.format("%i Prev Velocity Var",max_approach_velocity),function()
				max_approach_velocity = max_approach_velocity - 1
				setShyVariance()
			end)
		end
	end
	addGMFunction("Explain",function()
		addGMMessage("The 'shy' treasure type can only be picked up if approached from a particular angle. The next and prev angle var (short for variance) widen and narrow the required approach angle. The narrower the angle, the harder to retrieve.\n\nDepending on the general difficulty, there may be a velocity requirement, too. Change the velocity threshold here. Player ships cannot exceed the specified velocity as they approach the treasure.\n\nPlayer ships outside the approach angle or faster than the velocity threshold trigger the treasure to move to a different location.")
	end)
end
function setGeneralDifficulty()
	clearGMFunctions()
	addGMFunction("-Main From Gen Diff",mainGMButtons)
	addGMFunction("-Difficulty",setDifficulty)
	local button_text = "easy"
	if difficulty_text == "easy" then
		button_text = "easy*"
	end
	addGMFunction(button_text,function()
		difficulty = .5
		difficulty_text = "easy"
		setGeneralDifficulty()
	end)
	button_text = "normal"
	if difficulty_text == "normal" then
		button_text = "normal*"
	end
	addGMFunction(button_text,function()
		difficulty = 1
		difficulty_text = "normal"
		setGeneralDifficulty()
	end)
	button_text = "hard"
	if difficulty_text == "hard" then
		button_text = "hard*"
	end
	addGMFunction(button_text,function()
		difficulty = 2
		difficulty_text = "hard"
		setGeneralDifficulty()
	end)
	addGMFunction("Explain",function()
		local out = "General difficulty sets a number used in a variety of game play influences: Hard = 2, 1 = normal, .5 = easy.\nThe strength of any spawned enemies are compared to the player: normal: they're roughly equivalent, hard: they're twice as strong, easy: they're half as strong.\nOther factors influenced by difficulty:\nConsequences of a failed taunt attempt\nTreasure and supply drop scanning complexity/depth\nNumber of subsystems damaged when inappropriately retrieving a shy or anti-social treasure\nSize of warp jammer field deployed after anti-social treasure retrieved\nTrade good availability at stations"
		if game_variation == "Explorer"	then
			out = string.format("%s\n\nExplorer variation specific influences:\nPlanet orbit speed",out)
		end
		if game_variation == "Hunger"	then
			out = string.format("%s\n\nSee 'End Difficulty' for specifics on the difficulty associated with completing the Hunger variation",out)
		end
		addGMMessage(out)
	end)
end
function setCompletionDifficulty()
	clearGMFunctions()
	addGMFunction("-From End Difficulty",setDifficulty)
	local button_text = "easy"
	if completion_difficulty_text == "easy" then
		button_text = "easy*"
	end
	addGMFunction(button_text,function()
		completion_difficulty = .5
		completion_difficulty_text = "easy"
		setCompletionDifficulty()
	end)
	button_text = "normal"
	if completion_difficulty_text == "normal" then
		button_text = "normal*"
	end
	addGMFunction(button_text,function()
		completion_difficulty = 1
		completion_difficulty_text = "normal"
		setCompletionDifficulty()
	end)
	button_text = "hard"
	if completion_difficulty_text == "hard" then
		button_text = "hard*"
	end
	addGMFunction(button_text,function()
		completion_difficulty = 2
		completion_difficulty_text = "hard"
		setCompletionDifficulty()
	end)
	addGMFunction("Explain",function()
		addGMMessage(string.format("The numeric values are the same as general difficulty: Hard = 2, Normal = 1, Easy = .5\nNormal and hard variations have the station alternate 20 unit distance from central point as it moves.\nHard difficulty has the time interval between moves vary: normal, normal * 2 and normal/2. The current normal stationary interval is %i seconds.",normal_stationary_interval))
	end)
end
function setPlayerMessageButtons()
	clearGMFunctions()
	addGMFunction("-From Plyr Msg Btns",mainGMButtons)
	if player_message_buttons == nil then
		player_message_buttons = "both"
	end
	local button_text = "relay"
	if player_message_buttons == "relay" then
		button_text = button_text .. "*"
	end
	addGMFunction(button_text,function()
		player_message_buttons = "relay"
		setPlayerMessageButtons()
	end)
	button_text = "ship log"
	if player_message_buttons == "ship log" then
		button_text = button_text .. "*"
	end
	addGMFunction(button_text,function()
		player_message_buttons = "ship log"
		setPlayerMessageButtons()
	end)
	button_text = "both"
	if player_message_buttons == "both" then
		button_text = button_text .. "*"
	end
	addGMFunction(button_text,function()
		player_message_buttons = "both"
		setPlayerMessageButtons()
	end)
end
--
--	Rename player ship functions  --
--
function renamePlayerShip()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("+Corvette",corvetteNameCategory)
	addGMFunction("+Frigate",frigateNameCategory)
	addGMFunction("+Dreadnaught Plus",dreadnaughtNameCategory)
	addGMFunction("+Starfighter",starfighterNameCategory)
	addGMFunction("+Old Template",oldTemplateNameCategory)
	addGMFunction("Explain",function()
		addGMMessage("By default, there are fixed player ship names. This section lets you change a player ship name to something else. Go to the ship category and sub-category. Select the player ship. When you click a name, that name will replace the name given to the player ship.")
	end)
end
--	Player ship name categories
function corvetteNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Corvette",renamePlayerShip)
	if #rwc_player_ship_names["Atlantis"] > 0 then
		addGMFunction("+Atlantis",atlantisNameCategory)
	end
	if #rwc_player_ship_names["Benedict"] > 0 then
		addGMFunction("+Benedict",benedictNameCategory)
	end
	if #rwc_player_ship_names["Crucible"] > 0 then
		addGMFunction("+Crucible",crucibleNameCategory)
	end
	if #rwc_player_ship_names["Kiriya"] > 0 then
		addGMFunction("+Kiriya",kiriyaNameCategory)
	end
	if #rwc_player_ship_names["Maverick"] > 0 then
		addGMFunction("+Maverick",maverickNameCategory)
	end
end
function frigateNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Frigate",renamePlayerShip)
	if #rwc_player_ship_names["Flavia P.Falcon"] > 0 then
		addGMFunction("+Flavia P.Falcon",flaviaNameCategory)
	end
	if #rwc_player_ship_names["Hathcock"] > 0 then
		addGMFunction("+Hathcock",hathcockNameCategory)
	end
	if #rwc_player_ship_names["Nautilus"] > 0 then
		addGMFunction("+Nautilus",nautilusNameCategory)
	end
	if #rwc_player_ship_names["Phobos M3P"] > 0 then
		addGMFunction("+Phobos M3P",phobosNameCategory)
	end
	if #rwc_player_ship_names["Piranha"] > 0 then
		addGMFunction("+Piranha",piranhaNameCategory)
	end
	if #rwc_player_ship_names["Repulse"] > 0 then
		addGMFunction("+Repulse",repulseNameCategory)
	end
end
function dreadnaughtNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Dreadnaught+",renamePlayerShip)
	if #rwc_player_ship_names["Ender"] > 0 then
		addGMFunction("+Ender",enderNameCategory)
	end
	if #rwc_player_ship_names["Unknown"] > 0 then
		addGMFunction("+Unknown",unknownNameCategory)
	end
end
function starfighterNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Starfighter",renamePlayerShip)
	if #rwc_player_ship_names["MP52 Hornet"] > 0 then
		addGMFunction("+MP52 Hornet",hornetNameCategory)
	end
	if #rwc_player_ship_names["Striker"] > 0 then
		addGMFunction("+Striker",strikerNameCategory)
	end
	if #rwc_player_ship_names["ZX-Lindworm"] > 0 then
		addGMFunction("+ZX-Lindworm",lindwormNameCategory)
	end
end
function oldTemplateNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Old Template",renamePlayerShip)
	if #rwc_player_ship_names["Player Cruiser"] > 0 then
		addGMFunction("+Player Cruiser",playerCruiserNameCategory)
	end
	if #rwc_player_ship_names["Player Fighter"] > 0 then
		addGMFunction("+Player Fighter",playerFighterNameCategory)
	end
	if #rwc_player_ship_names["Player Missile Cr."] > 0 then
		addGMFunction("+Player Missile Cr.",playerMissileCruiserNameCategory)
	end
end
--	Player ship template name lists
function atlantisNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Corvette",renamePlayerShip)	
	addGMFunction("-From Atlantis",corvetteNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["Atlantis"]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["Atlantis"][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			atlantisNameCategory()
		end)
	end
end
function benedictNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Corvette",renamePlayerShip)	
	addGMFunction("-From Benedict",corvetteNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["Benedict"]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["Benedict"][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			benedictNameCategory()
		end)
	end
end
function crucibleNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Corvette",renamePlayerShip)	
	addGMFunction("-From Crucible",corvetteNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["Crucible"]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["Crucible"][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			crucibleNameCategory()
		end)
	end
end
function kiriyaNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Corvette",renamePlayerShip)	
	addGMFunction("-From Kiriya",corvetteNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["Kiriya"]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["Kiriya"][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			kiriyaNameCategory()
		end)
	end
end
function maverickNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Corvette",renamePlayerShip)	
	addGMFunction("-From Maverick",corvetteNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["Maverick"]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["Maverick"][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			maverickNameCategory()
		end)
	end
end
function flaviaNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Frigate",renamePlayerShip)	
	addGMFunction("-From Flavia",frigateNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["Flavia P.Falcon"]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["Flavia P.Falcon"][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			flaviaNameCategory()
		end)
	end
end
function hathcockNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Frigate",renamePlayerShip)	
	addGMFunction("-From Hathcock",frigateNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["Hathcock"]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["Hathcock"][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			hathcockNameCategory()
		end)
	end
end
function nautilusNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Frigate",renamePlayerShip)	
	addGMFunction("-From Nautilus",frigateNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["Nautilus"]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["Nautilus"][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			nautilusNameCategory()
		end)
	end
end
function phobosNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Frigate",renamePlayerShip)	
	addGMFunction("-From Phobos M3P",frigateNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["Phobos M3P"]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["Phobos M3P"][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			phobosNameCategory()
		end)
	end
end
function piranhaNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Frigate",renamePlayerShip)	
	addGMFunction("-From Piranha",frigateNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["Piranha"]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["Piranha"][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			piranhaNameCategory()
		end)
	end
end
function repulseNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Frigate",renamePlayerShip)	
	addGMFunction("-From Repulse",frigateNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["Repulse"]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["Repulse"][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			repulseNameCategory()
		end)
	end
end
function enderNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Dreadnaught+",renamePlayerShip)	
	addGMFunction("-From Ender",dreadnaughtNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["Ender"]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["Ender"][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			enderNameCategory()
		end)
	end
end
function unknownNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Dreadnaught+",renamePlayerShip)	
	addGMFunction("-From Unknown",dreadnaughtNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["Unknown"]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["Unknown"][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			unknownNameCategory()
		end)
	end
end
function hornetNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Starfighter",renamePlayerShip)	
	addGMFunction("-From MP52 Hornet",starfighterNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["MP52 Hornet"]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["MP52 Hornet"][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			hornetNameCategory()
		end)
	end
end
function strikerNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Starfighter",renamePlayerShip)	
	addGMFunction("-From Striker",starfighterNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["Striker"]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["Striker"][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			strikerNameCategory()
		end)
	end
end
function lindwormNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Starfighter",renamePlayerShip)	
	addGMFunction("-From ZX-Lindworm",starfighterNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["ZX-Lindworm"]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["ZX-Lindworm"][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			lindwormNameCategory()
		end)
	end
end
function playerCruiserNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Old Template",renamePlayerShip)	
	addGMFunction("-From Plyr Cruiser",oldTemplateNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["Player Cruiser"]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["Player Cruiser"][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			playerCruiserNameCategory()
		end)
	end
end
function playerFighterNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Old Template",renamePlayerShip)	
	addGMFunction("-From Plyr Fighter",oldTemplateNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["Player Fighter"]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["Player Fighter"][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			playerFighterNameCategory()
		end)
	end
end
function playerMissileCruiserNameCategory()
	clearGMFunctions()
	addGMFunction("-Main from rename",mainGMButtons)
	addGMFunction("-From Old Template",renamePlayerShip)	
	addGMFunction("-From Plyr Mssl Cru",oldTemplateNameCategory)
	for name_index, name in ipairs(rwc_player_ship_names["Player Missile Cr."]) do
		addGMFunction(name,function()
			local p = playerShipSelected()
			if p ~= nil then
				local old_name = p:getCallSign()
				p:setCallSign(name)
				rwc_player_ship_names["Player Missile Cr."][name_index] = old_name
				player_restart.add(pidx,p:getCallSign())
			else
				addGMMessage("No player ship selected. No action taken")
			end
			playerMissileCruiserNameCategory()
		end)
	end
end
-- ****************** --
--	Update Functions  --
-- ****************** --
function gatherStats(final_score)
	local stat_list = {}
	stat_list.scenario = {name = "Treasure Race", version = scenario_version, variation = game_variation}
	stat_list.ship = {}
	stat_list.times = {}
	stat_list.times.game_time = game_length
	stat_list.times.game_timer = game_time_limit
	stat_list.times.stage = game_state
	local score_list = {}
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if player_restart[pidx].respawn_count == nil then
				player_restart[pidx].respawn_count = 0
			end
			score_list[p:getCallSign()] = {
				treasure = {
					alpha = p.alpha_count,
					shy = p.shy,
					foxtrot = p.foxtrot,
					antisocial = p.antisocial,
				},
				rank = 0,
				respawn_count = player_restart[pidx].respawn_count,
			}
--			score_list[p:getCallSign()] = {laps = p.laps, goal = p.goal, drone_points = 0, rank = 0, score = 0, time = 0}
			if p.alpha_count == nil then
				p.alpha_count = 0
			end
			score_list[p:getCallSign()].rank = p.alpha_count
			if game_variation == "Normal" then
				if complete_sector == nil then
					complete_sector = "M25"
				end
				if score_list[p:getCallSign()].rank >= 3 and p:getSectorName() == complete_sector then
					score_list[p:getCallSign()].rank = score_list[p:getCallSign()].rank + 100
				end
			elseif game_variation == "Hunger" then
				if p.antisocial == "retrieved" then
					score_list[p:getCallSign()].rank = score_list[p:getCallSign()].rank + 10
				end
				if score_list[p:getCallSign()].rank >= 11 and primaryStation:isDocked(p) then
					score_list[p:getCallSign()].rank = score_list[p:getCallSign()].rank + 100
				end
			elseif game_variation == "Explorer" then
				if p.shy == "retrieved" then
					score_list[p:getCallSign()].rank = score_list[p:getCallSign()].rank + 10
				end
				if p.foxtrot == "provided" then
					score_list[p:getCallSign()].rank = score_list[p:getCallSign()].rank + 10
				end
				if score_list[p:getCallSign()].rank >= 21 and primaryStation:isDocked(p) then
					score_list[p:getCallSign()].rank = score_list[p:getCallSign()].rank + 100
				end
			end
			stat_list.ship[p:getCallSign()] = {
				treasure = score_list[p:getCallSign()].treasure,
				rank = score_list[p:getCallSign()].rank,
				respawn_count = score_list[p:getCallSign()].respawn_count
			}
		end
	end
	local sorted_score_list = {}
	for name, details in pairs(score_list) do
		table.insert(sorted_score_list,{name=name,rank=details.rank,respawn_count=details.respawn_count})
	end
	table.sort(sorted_score_list,function(a,b)
		return a.rank > b.rank
	end)
	if final_score then
		local sorted_stat_list = {}
		for name, details in pairs(stat_list.ship) do
			table.insert(sorted_stat_list,{name=name,rank=details.rank,respawn_count=details.respawn_count})
		end
		print("Name","Rank","Respawns")
		for i, item in ipairs(sorted_stat_list) do
			print(item.name,item.rank,item.respawn_count)
		end
		return stat_list, sorted_stat_list
	else
		return stat_list
	end
end
function updateSystem()
	return {
		_update_objects={},
		update = function(self,delta)
			-- we iterate through the _update_objects in reverse order so removed entries don't result in skipped updates
			for index = #self._update_objects,1,-1 do
				if self._update_objects[index]:isValid() then
					self._update_objects[index]:update(delta)
				else
					table.remove(self._update_objects,index)
				end
			end
		end,
		--note: all update functions are currently mutually exclusive, so delete duplicates
		addUpdate = function(self,obj)
			for i = 0,#self._update_objects do
				assert(type(self)=="table")
				if self._update_objects[i]==obj then
					table.remove(self._update_objects,i)
				end
			end
			table.insert(self._update_objects,obj)
		end,
		addOrbitUpdate = function(self, obj, center_x, center_y, distance, orbit_time, initial_angle)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(center_x)=="number")
			assert(type(center_y)=="number")
			assert(type(distance)=="number")
			assert(type(orbit_time)=="number")
			assert(type(initial_angle)=="number" or initial_angle == nil)
			obj.center_x = center_x
			obj.center_y = center_y
			obj.distance = distance
			obj.orbit_time = orbit_time
			if initial_angle == nil then
				obj.angle = 0
			else
				obj.angle = initial_angle
			end
			obj.update = function (self,delta)
				self.angle = (self.angle + 360/self.orbit_time*delta) % 360
				self:setPosition(self.center_x + (math.cos(self.angle / 180 * math.pi) * self.distance),self.center_y + (math.sin(self.angle / 180 * math.pi) * self.distance))
			end
			self:addUpdate(obj)
		end,
		addOrbitTargetUpdate = function (self, obj, orbit_target, distance, orbit_time, initial_angle)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(orbit_target)=="table")
			assert(type(distance)=="number")
			assert(type(orbit_time)=="number")
			assert(type(initial_angle)=="number" or initial_angle == nil)
			obj.orbit_target = orbit_target
			obj.distance = distance
			obj.orbit_time = orbit_time
			if initial_angle == nil then
				obj.angle = 0
			else
				obj.angle = initial_angle
			end
			obj.update = function (self,delta)
				if self.orbit_target ~= nil and self.orbit_target:isValid() then
					local orbit_target_x, orbit_target_y = self.orbit_target:getPosition()
					self.angle = (self.angle + 360/self.orbit_time*delta) % 360
					self:setPosition(orbit_target_x + (math.cos(self.angle / 180 * math.pi) * self.distance),orbit_target_y + (math.sin(self.angle / 180 * math.pi) * self.distance))
				end
			end
			self:addUpdate(obj)
		end,
		addOrbitTargetSpeedCycleUpdate = function (self, obj, center_x, center_y, distance, slow_orbit_time, fast_orbit_time, change_frequency, initial_angle)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(center_x)=="number")
			assert(type(center_y)=="number")
			assert(type(distance)=="number")
			assert(type(slow_orbit_time)=="number")
			assert(type(fast_orbit_time)=="number")
			assert(type(change_frequency)=="number")
			assert(type(initial_angle)=="number" or initial_angle == nil)
			obj.center_x = center_x
			obj.center_y = center_y
			obj.distance = distance
			obj.orbit_time = slow_orbit_time
			obj.slow_orbit_time = slow_orbit_time
			obj.fast_orbit_time = fast_orbit_time
			obj.change_frequency = change_frequency
			obj.change_timer = change_frequency
			if initial_angle == nil then
				obj.angle = 0
			else
				obj.angle = initial_angle
			end
			obj.throttle = "accelerate"
			obj.update = function (self, delta)
				self.angle = (self.angle + 360/self.orbit_time*delta) % 360
				self:setPosition(self.center_x + (math.cos(self.angle / 180 * math.pi) * self.distance),self.center_y + (math.sin(self.angle / 180 * math.pi) * self.distance))
				self.change_timer = self.change_timer - delta
				if self.change_timer < 0 then
					if self.throttle == "accelerate" then
						self.orbit_time = self.orbit_time - 1
						if self.orbit_time <= self.fast_orbit_time then
							self.orbit_time = self.fast_orbit_time
							self.throttle = "decelerate"
						end
					else
						self.orbit_time = self.orbit_time + 1
						if self.orbit_time >= self.slow_orbit_time then
							self.orbit_time = self.slow_orbit_time
							self.throttle = "accelerate"
						end
					end
					self.change_timer = delta + self.change_frequency
				end
			end
			self:addUpdate(obj)
		end,
		addPatrol = function (self, obj, patrol_points, patrol_point_index, patrol_check_timer_interval)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(patrol_points)=="table")
			assert(type(patrol_point_index)=="number")
			assert(type(patrol_check_timer_interval)=="number")
			obj.patrol_points = patrol_points
			obj.patrol_point_index = patrol_point_index
			obj.patrol_check_timer_interval = patrol_check_timer_interval
			obj.patrol_check_timer = patrol_check_timer_interval
			obj.update = function (self, delta)
				self.patrol_check_timer = self.patrol_check_timer - delta
				if self.patrol_check_timer < 0 then
					if string.find(self:getOrder(),"Defend") then
						self.patrol_point_index = self.patrol_point_index + 1
						if self.patrol_point_index > #self.patrol_points then
							self.patrol_point_index = 1
						end
						self:orderFlyTowards(self.patrol_points[self.patrol_point_index].x,self.patrol_points[self.patrol_point_index].y)
					end
					self.patrol_check_timer = self.patrol_check_timer_interval
				end
			end
			self:addUpdate(obj)
		end,
		addMigratoryPrimaryStation = function(self, obj, center_x, center_y, initial_angle, base_distance, pattern_difficulty)
			assert(type(self)=="table")
			assert(type(obj)=="table")
			assert(type(center_x)=="number")
			assert(type(center_y)=="number")
			assert(type(base_distance)=="number")
			assert(type(pattern_difficulty)=="number")
			assert(type(initial_angle)=="number" or initial_angle == nil)
			if pattern_difficulty == nil then
				pattern_difficulty = difficulty
			end
			obj.difficulty = pattern_difficulty
			obj.center_x = center_x
			obj.center_y = center_y
			obj.distance = base_distance
			obj.base_distance = base_distance
			if initial_angle == nil then
				obj.angle = 0
			else
				obj.angle = initial_angle
			end
			if player_count % 2 == 0 then
				obj.migratory_slots = player_count
			else
				obj.migratory_slots = player_count * 2
			end
			obj.migratory_slot_counter = 0
			obj.angle_increment = 360/obj.migratory_slots
			obj.ring_count = 0
			obj.ring_max = 5
			obj.stationary_interval = normal_stationary_interval
			obj.migrate_timer = obj.stationary_interval
			obj.update = function(self,delta)
				self.migrate_timer = self.migrate_timer - delta
				if self.migrate_timer < 0 then
					local station_waits = false
					if distance(self,terrain_center_x,terrain_center_y) > 1000 then
						for pidx=1,player_count do
							local p = getPlayerShip(pidx)
							if p ~= nil and p:isValid() then
								if distance(self,p) < 30000 then
									if p.station_waits == nil then
										p.station_waits = true
										station_waits = true
										local wp_x, wp_y = p:getPosition()
										local ws_x, ws_y = self:getPosition()
										spawnEnemies((wp_x+ws_x)/2,(wp_y+ws_y)/2,1,"Exuari",nil,10)	--distraction
										break
									end
								else
									if p.station_waits ~= nil then
										p.station_waits = nil
									end
								end
							end
						end
					end
					if station_waits then
						self.migrate_timer = self.stationary_interval
					else
						local positional_distance = self.distance
						if obj.difficulty >= 1 then
							if self.migratory_slot_counter % 2 == 0 then
								positional_distance = positional_distance + 20000
							end
						end
						self:setPosition(self.center_x + (math.cos(self.angle / 180 * math.pi) * positional_distance),self.center_y + (math.sin(self.angle / 180 * math.pi) * positional_distance))
						self.migratory_slot_counter = self.migratory_slot_counter + 1
						if self.migratory_slot_counter >= self.migratory_slots then
							self.ring_count = self.ring_count + 1
							if self.ring_count >= self.ring_max then
								self.distance = self.base_distance
								self.ring_count = 0
							else
								self.distance = self.distance + 10000
							end
							self.migratory_slot_counter = 0
						end
						self.angle = (self.angle + self.angle_increment) % 360
						self.migrate_timer = self.stationary_interval
						if obj.difficulty > 1 then
							if self.migratory_slot_counter % 3 == 0 then
								self.migrate_timer = self.stationary_interval * 2
							elseif (self.migratory_slot_counter + 1) % 3 == 0 then
								self.migrate_timer = self.stationary_interval / 2
							end
						end
					end
				end
			end
			self:addUpdate(obj)
		end,
		addTimeToLiveUpdate = function(self, obj)
			assert(type(self)=="table")
			obj.timeToLive = 300
			obj.update = function (self,delta)
				self.timeToLive = self.timeToLive - delta
				if self.timeToLive < 0 then
					self:destroy()
				end
			end
			self:addUpdate(obj)
		end,
	}
end
function update(delta)
	if delta == 0 then
		--game paused
		game_state = "paused"
		local paused_player_count = 0
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if player_template == nil then
					player_template = p:getTypeName()
				end
				pausedPlayerShipConstraints(p)
				paused_player_count = paused_player_count + 1
			end
		end
		if players_on_teams then
			for pidx=1,paused_player_count do
				local p = getPlayerShip(pidx)
				local faction_count = pidx
				if faction_count > player_teams[paused_player_count].human then
					faction_count = faction_count - player_teams[paused_player_count].human
					if faction_count > player_teams[paused_player_count].kraylor then
						faction_count = faction_count - player_teams[paused_player_count].kraylor
						if faction_count > player_teams[paused_player_count].hive then
							faction_count = faction_count - player_teams[paused_player_count].hive
							if faction_count > player_teams[paused_player_count].usn then
								faction_count = faction_count - player_teams[paused_player_count].usn
								if faction_count > player_teams[paused_player_count].tsn then
									p:setFaction("CUF")
								else
									p:setFaction("TSN")
								end
							else
								p:setFaction("USN")
							end
						else
							p:setFaction("Ktlitans")
						end
					else
						p:setFaction("Kraylor")
					end
				else
					p:setFaction("Human Navy")
				end
				if player_restart ~= nil then
					player_restart.add(pidx,nil,nil,nil,nil,p:getFaction())
				end
			end
		end
		return
	end	--end game paused processing
	game_state = "running"
	if mainGMButtons == mainGMButtonsDuringPause then
		mainGMButtons = mainGMButtonsAfterPause
		mainGMButtons()
	end
	if player_count == nil then
		player_count = 0
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				player_count = player_count + 1
			end
		end
	end
	if post_pause_initialization == nil then
		--Last is post pause build three.
		--The build routines are ordered and coded this way so that we don't try to build Rome in one update cycle.
		--In other words, break up your dynamic build routines into three pieces.
		if post_pause_built_2 ~= nil then
			if post_pause_built_3 == nil then
				if postPauseBuild3 ~= nil then
					postPauseBuild3(delta)
				end
				post_pause_built_3 = true
			end
		end
		--Next to last is post pause build two.
		if post_pause_built_1 ~= nil then
			if post_pause_built_2 == nil then
				if postPauseBuild2 ~= nil then
					postPauseBuild2(delta)
				end
				post_pause_built_2 = true
			end
		end
		--After players positioned (see player loop below), then start dynamic terrain.
		if players_positioned ~= nil then
			if post_pause_built_1 == nil then
				if postPauseBuild1 ~= nil then
					postPauseBuild1(delta)
				end
				post_pause_built_1 = true
			end
		end
		--After all is done, set post pause initialization done so this stuff gets skipped
		if players_positioned and post_pause_built_1 and post_pause_built_2 and post_pause_built_3 then
			post_pause_initialization = "Done"
		end
	end
	world:update(delta)
	--Local functions to be called from within the player loop below
	local function shipLogButtons(p)
		if player_message_buttons == "both" or player_message_buttons == "ship log" then
			if p:hasPlayerAtPosition("ShipLog") then
				if p.alpha_count ~= nil and p.alpha_count > 0 then
					p.alpha_count_display = "alpha_count_display"
					p:addCustomInfo("ShipLog",p.alpha_count_display,string.format("Treasures: %i",p.alpha_count),2)
				end
				if p.treasure_clue_list ~= nil then
					if p.treasure_clue_list_button == nil then
						p.treasure_clue_list_button = "treasure_clue_list_button"
						p:addCustomButton("ShipLog",p.treasure_clue_list_button,"Treasure Clues",function()
							local clue_messages = ""
							for index, clue in ipairs(p.treasure_clue_list) do
								if clue.treasure:isValid() then
									clue_messages = clue_messages .. clue.clue .. "\n"
								end
							end
							p:addCustomMessage("ShipLog","all_clues",clue_messages)
						end)
					end
				end
				if p.long_messages == nil and p.mission_message ~= nil then
					p.long_messages = "long_messages"
					p:addCustomButton("ShipLog",p.long_messages,"Long Mission Msgs",function()
						local long_messages = ""
						for message_type, message in pairs(p.mission_message) do
							long_messages = string.format("%s\n%s:\n%s\n",long_messages,message_type,message.long_text)
						end
						p:addCustomMessage("ShipLog","all_long_messages",long_messages)
					end)
				end
				if p.short_messages == nil and p.mission_message ~= nil then
					p.short_messages = "short_messages"
					p:addCustomButton("ShipLog",p.short_messages,"Short Mission Msgs",function()
						local short_messages = ""
						for message_type, message in pairs(p.mission_message) do
							short_messages = string.format("%s\n%s:\n%s\n",short_messages,message_type,message.short_text)
						end
						p:addCustomMessage("ShipLog","all_short_messages",short_messages)
					end)
				end
			end
		end
		if player_message_buttons == "both" or player_message_buttons == "relay" then
			if p:hasPlayerAtPosition("Relay") then
				if p.treasure_clue_list ~= nil then
					if p.treasure_clue_list_button_relay == nil then
						p.treasure_clue_list_button_relay = "treasure_clue_list_button_relay"
						p:addCustomButton("Relay",p.treasure_clue_list_button_relay,"Treasure Clues",function()
							local clue_messages = ""
							for index, clue in ipairs(p.treasure_clue_list) do
								if clue.treasure:isValid() then
									clue_messages = clue_messages .. clue.clue .. "\n"
								end
							end
							p:addCustomMessage("Relay","all_clues",clue_messages)
						end)
					end
				end
				if p.long_messages == nil and p.mission_message ~= nil then
					p.long_messages_relay = "long_messages_relay"
					p:addCustomButton("Relay",p.long_messages_relay,"Long Mission Msgs",function()
						local long_messages = ""
						for message_type, message in pairs(p.mission_message) do
							long_messages = string.format("%s\n%s:\n%s\n",long_messages,message_type,message.long_text)
						end
						p:addCustomMessage("Relay","all_long_messages",long_messages)
					end)
				end
				if p.short_messages == nil and p.mission_message ~= nil then
					p.short_messages_relay = "short_messages_relay"
					p:addCustomButton("Relay",p.short_messages_relay,"Short Mission Msgs",function()
						local short_messages = ""
						for message_type, message in pairs(p.mission_message) do
							short_messages = string.format("%s\n%s:\n%s\n",short_messages,message_type,message.short_text)
						end
						p:addCustomMessage("Relay","all_short_messages",short_messages)
					end)
				end
			end
			if p:hasPlayerAtPosition("Operations") then
				if p.treasure_clue_list ~= nil then
					if p.treasure_clue_list_button_ops == nil then
						p.treasure_clue_list_button_ops = "treasure_clue_list_button_ops"
						p:addCustomButton("Operations",p.treasure_clue_list_button_ops,"Treasure Clues",function()
							local clue_messages = ""
							for index, clue in ipairs(p.treasure_clue_list) do
								if clue.treasure:isValid() then
									clue_messages = clue_messages .. clue.clue .. "\n"
								end
							end
							p:addCustomMessage("Operations","all_clues",clue_messages)
						end)
					end
				end
				if p.long_messages == nil and p.mission_message ~= nil then
					p.long_messages_ops = "long_messages_ops"
					p:addCustomButton("Operations",p.long_messages_ops,"Long Mission Msgs",function()
						local long_messages = ""
						for message_type, message in pairs(p.mission_message) do
							long_messages = string.format("%s\n%s:\n%s\n",long_messages,message_type,message.long_text)
						end
						p:addCustomMessage("Operations","all_long_messages",long_messages)
					end)
				end
				if p.short_messages == nil and p.mission_message ~= nil then
					p.short_messages_ops = "short_messages_ops"
					p:addCustomButton("Operations",p.short_messages_ops,"Short Mission Msgs",function()
						local short_messages = ""
						for message_type, message in pairs(p.mission_message) do
							short_messages = string.format("%s\n%s:\n%s\n",short_messages,message_type,message.short_text)
						end
						p:addCustomMessage("Operations","all_short_messages",short_messages)
					end)
				end
			end
		end
	end
	local function treasureCounter(p)
		if p:hasPlayerAtPosition("Relay") then
			if p.alpha_count ~= nil and p.alpha_count > 0 then
				p.alpha_count_display_relay = "alpha_count_display_relay"
				p:addCustomInfo("Relay",p.alpha_count_display_relay,string.format("Treasures: %i",p.alpha_count),3)
			end
			if game_variation == "Explorer" then
				if p.alpha == "move damage" then
					p.alpha_move_damage_display_relay = "alpha_move_damage_display_relay"
					p:addCustomInfo("Relay",p.alpha_move_damage_display_relay,string.format("Got treasure near %s",primaryStation:getCallSign()),4)
				end
				if p.foxtrot == "provided" then
					p.foxtrot_display_relay = "foxtrot_display_relay"
					p:addCustomInfo("Relay",p.foxtrot_display_relay,string.format("Got treasure near %s",planet_vespucci_primus:getCallSign()),5)
				end
				if p.shy == "retrieved" then
					p.shy_display_relay = "shy_display_relay"
					p:addCustomInfo("Relay",p.shy_display_relay,string.format("Got treasure near %s",star_sacagawea:getCallSign()),6)
				end
			end
			if game_variation == "Hunger" then
				if p.antisocial == "retrieved" then
					p.antisocial_display_relay = "antisocial_display_relay"
					p:addCustomInfo("Relay",p.antisocial_display_relay,"Got antisocial treasure",7)
				end
			end
		end
		if p:hasPlayerAtPosition("Operations") then
			if p.alpha_count ~= nil and p.alpha_count > 0 then
				p.alpha_count_display_ops = "alpha_count_display_ops"
				p:addCustomInfo("Operations",p.alpha_count_display_ops,string.format("Treasures: %i",p.alpha_count),3)
			end
			if game_variation == "Explorer" then
				if p.alpha == "move damage" then
					p.alpha_move_damage_display_ops = "alpha_move_damage_display_ops"
					p:addCustomInfo("Relay",p.alpha_move_damage_display_ops,string.format("Got treasure near %s",primaryStation:getCallSign()),4)
				end
				if p.foxtrot == "provided" then
					p.foxtrot_display_ops = "foxtrot_display_ops"
					p:addCustomInfo("Relay",p.foxtrot_display_ops,string.format("Got treasure near %s",planet_vespucci_primus:getCallSign()),5)
				end
				if p.shy == "retrieved" then
					p.shy_display_ops = "shy_display_ops"
					p:addCustomInfo("Relay",p.shy_display_ops,string.format("Got treasure near %s",star_sacagawea:getCallSign()),6)
				end
			end
			if game_variation == "Hunger" then
				if p.antisocial == "retrieved" then
					p.antisocial_display_ops = "antisocial_display_ops"
					p:addCustomInfo("Relay",p.antisocial_display_ops,"Got antisocial treasure",7)
				end
			end
		end
	end
	local function countdownTimer(p,timer_string)
		timer_string = "Time remaining: " .. timer_string
		p:addCustomInfo("Helms","countdown_timer_helm",timer_string,8)
		p:addCustomInfo("Weapons","countdown_timer_weapons",timer_string,8)
		p:addCustomInfo("Engineering","countdown_timer_engineering",timer_string,8)
		p:addCustomInfo("Science","countdown_timer_science",timer_string,8)
		p:addCustomInfo("Tactical","countdown_timer_tactical",timer_string,8)
		p:addCustomInfo("ShipLog","countdown_timer_shiplog",timer_string,8)
		p:addCustomInfo("DamageControl","countdown_timer_damagecontrol",timer_string,8)
	end
	local function sendPlayerMessage(p,message_type,message)
		if p.mission_message == nil then
			p.mission_message = {}
		end
		if p.mission_message[message_type] == nil then
			if primaryStation ~= nil then
				p.mission_message[message_type] = {long_text = message.long_text, short_text = message.short_text}
				primaryStation:sendCommsMessage(p,message.long_text)
				message.count = message.count + 1
			end
		end
	end
	local function infoBanner(p)
		local info_banner = string.format("%s in %s",p:getCallSign(),p:getSectorName())
		p.info_banner_hlm = "info_banner_hlm"
		p:addCustomInfo("Helms",p.info_banner_hlm,info_banner,1)
		p.info_banner_tac = "info_banner_tac"
		p:addCustomInfo("Tactical",p.info_banner_tac,info_banner,1)
	end
	local function resetContinuum(p)
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
	local minutes = math.floor(game_time_limit / 60)
	local seconds = math.floor(game_time_limit % 60)
	local remaining_time = ""
	if minutes < 1 then
		remaining_time = string.format("%i seconds",seconds)
	else
		remaining_time = string.format("%i:%.2i",minutes,seconds)
	end
	--Player loop. Place all player related things in the update cycle here
	local continuum_count = 0
	if player_max_distance_from_center ~= nil then
		player_max_distance_from_center = 0
	end
	local valid_players = 0
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil then
			if p:isValid() then
				valid_players = valid_players + 1
				if pidx > player_count then
					p:destroy()	--once the game starts, no more players are allowed
				else
					if p.pidx == nil then
						identifyPlayerShip(p)
					end
					if p.start_x == nil then
						if players_positioned == nil then
							initialPlayerShipPlacement()	--determine and set player initial positions
							players_positioned = true
						else
							p.start_x = player_restart[pidx].start_x
							p.start_y = player_restart[pidx].start_y
							p:setPosition(p.start_x,p.start_y)
						end
					end
				end
				if broadcast_messages ~= nil then
--					print("broadcast messages exist")
					for message_type, message in pairs(broadcast_messages) do
--						print("message type:",message_type,"count:",message.count)
						if message.count < player_count then
							if message.trigger ~= nil then
--								print("message trigger exists")
								if message.trigger(p) then
--									print("message trigger true for ",p:getCallSign())
									sendPlayerMessage(p,message_type,message)
								end
							else
--								print("message trigger is nil, sending message for ",p:getCallSign())
								sendPlayerMessage(p,message_type,message)
							end
						end
					end
				end
				if check_continuum then
					if p.continuum_target then
						continuum_count = continuum_count + 1
						if p.continuum_timer == nil then
							p.continuum_timer = delta + 10
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
								p:addCustomInfo("Relay",p.continuum_timer_display,timer_display,9)
							end
							if p:hasPlayerAtPosition("Operations") then
								p.continuum_timer_display_ops = "continuum_timer_display_ops"
								p:addCustomInfo("Operations",p.continuum_timer_display_ops,timer_display,9)
							end
						end
					else
						resetContinuum(p)
					end
				end
				shipLogButtons(p)
				treasureCounter(p)
				infoBanner(p)
				countdownTimer(p,remaining_time)
				if player_max_distance_from_center ~= nil then
					if distance_diagnostic then
						print("function update in player loop")
						if terrain_center_x == nil then
							print("   terrain_center_x is nil")
						else
							print("   terrain_center_x: " .. terrain_center_x)
						end
					end
					local current_player_distance = distance(p,terrain_center_x,terrain_center_y)
					player_max_distance_from_center = math.max(current_player_distance,player_max_distance_from_center)
				end
				if player_updates ~= nil then
					for player_update, check in pairs(player_updates) do
						if check ~= nil then
							check.check(p)
						end
					end
				end
				local collected = true
				for criteria, check in pairs(collection_criteria) do
					if check ~= nil then
						if check.check ~= nil then
							if not check.check(p) then
								collected = false
								break
							end
						else
							collected = false
							break
						end
					else
						collected = false
						break
					end
				end
				if collected then
					for criteria, check in pairs(completion_criteria) do
						if check ~= nil then
							if check.check ~= nil then
								if check.check(p) then
									local win_msg = string.format("%s wins with %s to spare",p:getCallSign(),remaining_time)
									for j,rp in ipairs(getActivePlayerShips()) do
										if rp ~= p then
											if rp ~= nil and rp:isValid() then
												if rp.alpha_count ~= nil and rp.alpha_count > 0 then
													if rp.alpha_count > 1 then
														win_msg = string.format("%s\n%s: %i treasures",win_msg,rp:getCallSign(),rp.alpha_count)
													else
														win_msg = string.format("%s\n%s: one treasure",win_msg,rp:getCallSign())
													end
												else
													win_msg = string.format("%s\n%s: no treasures",win_msg,rp:getCallSign())
												end
											end
										end
									end
									globalMessage(win_msg)
									addGMMessage(win_msg)
									game_state = string.format("victory %s",p:getFaction())
									gatherStats(true)
									victory(p:getFaction())
								end
							end
						end
					end
				end
			end
		end
	end
	if valid_players < player_count then
		local respawned_player = PlayerSpaceship()
		identifyPlayerShip(respawned_player)
		local pidx = respawned_player.pidx
		respawned_player:setPosition(player_restart[pidx].start_x,player_restart[pidx].start_y)
		if player_restart[pidx].respawn_count == nil then
			player_restart[pidx].respawn_count = 0
		end
		player_restart[pidx].respawn_count = player_restart[pidx].respawn_count + 1
	end
	if general_variation_updates ~= nil then
		for variation_index, variation_update in ipairs(general_variation_updates) do
			variation_update(delta)
		end
	end
	if continuum_count == 0 then
		check_continuum = false
	end
	if plotRevert ~= nil then
		plotRevert(delta)
	end
	game_time_limit = game_time_limit - delta + timer_fudge
	if game_time_limit < 0 then
		globalMessage("Time has expired")
		game_state = "victory Exuari"
		gatherStats(true)
		victory("Exuari")
	end
	--[[	test code
	if test_treasure == nil then
		test_treasure = treasureShy()
		test_treasure:setPosition(250000,250000)
		test_timer = delta + 1
	end
	test_timer = test_timer - delta
	if test_angle == nil then
		test_angle = 0
	end
	if test_timer < 0 then
		local p = getPlayerShip(-1)
		local px, py = vectorFromAngleNorth(test_angle,10000)
		px = 250000 + px
		py = 250000 + py
		p:setPosition(px,py)
		test_timer = delta + 1
		--local test_approach_angle = angleFromVector(250000,250000,px,py)
		--local inverse_test_approach_angle = angleFromVector(px,py,250000,250000)
		--local recip_inv_angle = 360 - angleFromVector(px,py,250000,250000)
		--print(string.format("test angle: %i, approach angle: %.1f, inverted angle: %.1f, reciprocal inverted angle: %.1f",test_angle,test_approach_angle,inverse_test_approach_angle,recip_inv_angle))
		local compare_angle = angleFromVectorNorth(px,py,250000,250000)
		print(string.format("Test angle: %i, compare angle: %.1f",test_angle,compare_angle))
		test_angle = (test_angle + 1) % 360
	end
	--]]
end
